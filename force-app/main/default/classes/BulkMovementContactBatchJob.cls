/*
 * This batch job will run once a day to handle activity movement
 * BulkMovementContactBatchJob calls BulkMovementContactHandleCIBatch to handle Contact Interests data
 * Batch 1 - BulkMovementContactBatchJob
 * Batch 2 - BulkMovementContactHandleCIBatch
 */
public class BulkMovementContactBatchJob implements Database.Batchable<BulkMovementContactAtRMLevelWrapper>,Database.Stateful  {
    
    //For each campaign only one Destination account is possible
    public class BulkMovementContactAtRMLevelWrapper {

        public BulkMovementContactAtRMLevelWrapper() {}

        public Id campaignId;
        public Id accountRGId;
        public Id accountRMId;
        public String accountRMKey;
        public Boolean isAccountRMCapIntro;
        public Id newAccountRGId;
        public Id newAccountRMId;
        public String newAccountRMKey;
        public Boolean isNewAccountRMCapIntro;
        public Set<Id> contactIdSet;
    }
    
    public BulkMovementContactBatchJob() {
    }

    public Iterable<BulkMovementContactAtRMLevelWrapper> start(Database.BatchableContext batchableContext){
        List<BulkMovementContactAtRMLevelWrapper> campaignAtRMLevelList = getBulkMovementContactData();

        return campaignAtRMLevelList;
    }

    //Scope would be 1
    public void execute(Database.BatchableContext batchableContext, List<BulkMovementContactAtRMLevelWrapper> campaignAtRMLevelList){
        List<Event> eventUpdateList = new List<Event>();
        List<Task> taskUpdateList = new List<Task>();
        List<Event> eventErrorUpdateList = new List<Event>();
        List<Task> taskErrorUpdateList = new List<Task>();
        Integer batchSize = 500;
        
        if(campaignAtRMLevelList != null && !campaignAtRMLevelList.isEmpty()){
            //The list will always contain 1 record as we are specifying the scope as 1 while executing the batch 
            BulkMovementContactAtRMLevelWrapper campaignAtRMLevelObj = campaignAtRMLevelList.get(0);
            if(campaignAtRMLevelObj != null 
                && String.isNotEmpty(campaignAtRMLevelObj.accountRGId) 
                && String.isNotEmpty(campaignAtRMLevelObj.newAccountRGId)
                && campaignAtRMLevelObj.contactIdSet != null && !campaignAtRMLevelObj.contactIdSet.isEmpty()){
                
                 //We have to split list into multiple lists 
                 Map<Integer,List<Id>> recordIdMap = CommonTools.getRecordIdSubsetLists(campaignAtRMLevelObj.contactIdSet, batchSize);
                
                
                if(campaignAtRMLevelObj.accountRGId <> campaignAtRMLevelObj.newAccountRGId){
                    
                    //Fetch Events
                    eventUpdateList.addAll(fetchEventUpdateList(campaignAtRMLevelObj, recordIdMap));

                    //Fetch Tasks
                    taskUpdateList = fetchTaskUpdateList(campaignAtRMLevelObj, recordIdMap);
                }

                //Fetch CapIntro Events
                eventUpdateList.addAll(fetchCapIntroEventUpdateList(campaignAtRMLevelObj, recordIdMap));

                //Update Events
                if(!eventUpdateList.isEmpty()){
                    eventErrorUpdateList.addAll(updateEventRecords(eventUpdateList));
                }

                //It is possible that same event is present for Rep Name Change. 
                //Reset the eventUpdateList
                eventUpdateList = new List<Event>();

                //Fetch CapIntro Events for Rep Name Change
                eventUpdateList.addAll(fetchCapIntroEventUpdateListForRepName(campaignAtRMLevelObj, recordIdMap));
                if(!eventUpdateList.isEmpty()){
                    eventErrorUpdateList.addAll(updateEventRecords(eventUpdateList));
                }

                
                //Update Tasks
                if(!taskUpdateList.isEmpty()){
                    taskErrorUpdateList.addAll(updateTaskRecords(taskUpdateList));
                }

                
                /* 
                 * Mark ths status as Failed in case of Move Historic Activities Failure at Campaign Level
                 */
                 if((eventErrorUpdateList != null && !eventErrorUpdateList.isEmpty()) ||
                    (taskErrorUpdateList != null && !taskErrorUpdateList.isEmpty()))
                    {
                        
                        //Update the status for Campaign to Move Historic Activity Failed
                        Campaign campaignObj = new Campaign(Id = campaignAtRMLevelObj.campaignId, Status = 'Move Historic Activity Failed');
                        update campaignObj;
                    }
                
            }
        }
    }

    public void finish(Database.BatchableContext batchableContext){
        //Call the batch for Copy Contact Interests
         Id batchProcessId = Database.executeBatch(new BulkMovementContactHandleCIBatch(),10);
    }

    
    public List<BulkMovementContactAtRMLevelWrapper> getBulkMovementContactData(){
        Map<Id,List<CampaignMember>> campaignIdAndMemberMap = new Map<Id,List<CampaignMember>>();
        List<BulkMovementContactAtRMLevelWrapper> campaignAtRMLevelList = new List<BulkMovementContactAtRMLevelWrapper>();
        
        List<CampaignMember> campaignMemberList = [SELECT Id, ContactId, Old_RG_Account__c, Old_RM_Account__c,
                                                    Old_RM_Account__r.RDM_Org_ID__c, Old_RM_Account__r.CapIntro__c,
                                                    Contact.AccountId, Contact.Account.ParentId, 
                                                    CampaignId, Campaign.New_RG_Account__c, Campaign.New_RM_Account__c,
                                                    Campaign.New_RM_Account__r.RDM_Org_ID__c, Campaign.New_RM_Account__r.CapIntro__c,
                                                    Campaign.Contact_Related_Entities_Handling__c, 
                                                    Campaign.Status, Campaign.OwnerId
                                                    FROM CampaignMember
                                                    WHERE Campaign.RecordType.DeveloperName = 'Bulk_Movement_Contact' 
                                                        AND Campaign.Status = 'Planned'
                                                        AND Campaign.Contact_Related_Entities_Handling__c includes ('Move Historic Activities')
                                                    ORDER BY CreatedDate];

        if(campaignMemberList != null && !campaignMemberList.isEmpty()){
            //Create Map - Campaign id as Key and CampaignMember as value
            for(CampaignMember campaignMemberObj : campaignMemberList){
                Id campaignId = campaignMemberObj.CampaignId;
                List<CampaignMember> childList = campaignIdAndMemberMap.containsKey(campaignId) ? campaignIdAndMemberMap.get(campaignId) : new List<CampaignMember>();
                childList.add(campaignMemberObj);
                campaignIdAndMemberMap.put(campaignId, childList);
            }

            //Create Data at Campaign Level and RM Account Level
            if(!campaignIdAndMemberMap.isEmpty()){
                for(Id campaignId : campaignIdAndMemberMap.keySet()){
                    List<CampaignMember> memberList = campaignIdAndMemberMap.get(campaignId);
                    Map<String,BulkMovementContactAtRMLevelWrapper> campaignRMLevelMap = new Map<String,BulkMovementContactAtRMLevelWrapper>();
                    if(memberList != null && !memberList.isEmpty()){
                        //Create Data at RM Account Level
                        for(CampaignMember campaignMemberObj : memberList){
                            String uniqueKey = campaignId + '#' + campaignMemberObj.Old_RM_Account__c + '#' + campaignMemberObj.Old_RG_Account__c;
                            BulkMovementContactAtRMLevelWrapper campaignRMLevelObj  = (campaignRMLevelMap.containsKey(uniqueKey)) ? campaignRMLevelMap.get(uniqueKey) : new BulkMovementContactAtRMLevelWrapper();
                            Set<Id> contactIdSet = campaignRMLevelObj.contactIdSet;

                            if(!campaignRMLevelMap.containsKey(uniqueKey)){
                                
                                //Create BulkMovementContactAtRMLevelWrapper Data
                                campaignRMLevelObj.campaignId = campaignId;
                                campaignRMLevelObj.accountRGId = campaignMemberObj.Old_RG_Account__c;
                                campaignRMLevelObj.accountRMId = campaignMemberObj.Old_RM_Account__c;
                                campaignRMLevelObj.accountRMKey = campaignMemberObj.Old_RM_Account__r.RDM_Org_ID__c;
                                campaignRMLevelObj.isAccountRMCapIntro = campaignMemberObj.Old_RM_Account__r.CapIntro__c;
                                campaignRMLevelObj.newAccountRGId = campaignMemberObj.Campaign.New_RG_Account__c;
                                campaignRMLevelObj.newAccountRMId = campaignMemberObj.Campaign.New_RM_Account__c;
                                campaignRMLevelObj.newAccountRMKey = campaignMemberObj.Campaign.New_RM_Account__r.RDM_Org_ID__c;
                                campaignRMLevelObj.isNewAccountRMCapIntro = campaignMemberObj.Campaign.New_RM_Account__r.CapIntro__c;
  
                            }
                            
                            if(contactIdSet == null){
                                contactIdSet = new Set<Id>();
                            }
                            contactIdSet.add(campaignMemberObj.ContactId);
                            campaignRMLevelObj.contactIdSet = contactIdSet;
                            
                            campaignRMLevelMap.put(uniqueKey, campaignRMLevelObj);
                        }
                    }

                    if(!campaignRMLevelMap.isEmpty()){
                        campaignAtRMLevelList.addAll(campaignRMLevelMap.values());
                    }
                }
            }
        }

        return campaignAtRMLevelList;
    }

    public List<Event> fetchEventUpdateList(BulkMovementContactAtRMLevelWrapper campaignAtRMLevelObj, Map<Integer,List<Id>> recordIdMap){
        List<Event> eventList = new List<Event>();
        List<Event> eventUpdateList = new List<Event>();

        //Fetch Events - Considering Archived Events
        for(Integer i : recordIdMap.keySet()){
                List<Id> recordIdInnerList = recordIdMap.get(i);
                List<Event> eventInnerList = [SELECT Id, WhoId, WhatId, RecordType.DeveloperName
                                    FROM Event
                                    WHERE IsChild = FALSE
                                    AND What.Type = 'Account'
                                    AND WhatId = :campaignAtRMLevelObj.accountRGId
                                    AND WhoId IN :recordIdInnerList 
                                    AND IsDeleted = FALSE 
                                    ALL ROWS];

            if(eventInnerList != null && !eventInnerList.isEmpty()){
                eventList.addAll(eventInnerList);
            }
        }
        
        
        //Find Events that needs to be updated
        for(Event eventObj : eventList){
            eventObj.WhatId = campaignAtRMLevelObj.newAccountRGId;
            eventUpdateList.add(eventObj);
        }

        return eventUpdateList;
    }

    public List<Task> fetchTaskUpdateList(BulkMovementContactAtRMLevelWrapper campaignAtRMLevelObj, Map<Integer,List<Id>> recordIdMap){
        List<Task> taskList = new List<Task>();
        List<Task> taskUpdateList = new List<Task>();

        //Fetch Tasks - Considering Archived Tasks
        for(Integer i : recordIdMap.keySet()){
                List<Id> recordIdInnerList = recordIdMap.get(i);
                List<Task> taskInnerList = [SELECT Id, WhoId, WhatId, RecordType.DeveloperName,Private__c
                                    FROM Task
                                    WHERE What.Type = 'Account'
                                    AND WhatId = :campaignAtRMLevelObj.accountRGId
                                    AND WhoId IN :recordIdInnerList 
                                    AND IsDeleted = FALSE 
                                    ALL ROWS];

            if(taskInnerList != null && !taskInnerList.isEmpty()){
                taskList.addAll(taskInnerList);
            }
        }
        
        //Find Tasks that needs to be updated
        for(Task taskObj : taskList){
            taskObj.WhatId = campaignAtRMLevelObj.newAccountRGId;
            taskUpdateList.add(taskObj);
        }

        return taskUpdateList;
    }

    public List<Event> fetchCapIntroEventUpdateList(BulkMovementContactAtRMLevelWrapper campaignAtRMLevelObj, Map<Integer,List<Id>> recordIdMap){
        List<Event> eventList = new List<Event>();
        List<Event> eventUpdateList = new List<Event>();
        Opportunity opportunityObj = null;

        //If Source Account is CapIntro 
        if(campaignAtRMLevelObj.isAccountRMCapIntro == TRUE){
            
            //Fetch Cap Intro Events - Considering Archived Events
            for(Integer i : recordIdMap.keySet()){
                List<Id> recordIdInnerList = recordIdMap.get(i);
                List<Event> eventInnerList = [SELECT Id, WhoId, WhatId, What.Type, RecordType.DeveloperName,
                                     Create_Type__c, Rep_Name__c
                                    FROM Event
                                    WHERE IsChild = FALSE
                                    AND What.Type = 'Opportunity'
                                    AND WhoId IN :recordIdInnerList 
                                    AND Create_Type__c IN ('Call Report/Notes','CI Interactions')
                                    AND Private__c = 'True'
                                    AND IsDeleted = FALSE 
                                    ALL ROWS];

                if(eventInnerList != null && !eventInnerList.isEmpty()){
                    eventList.addAll(eventInnerList);
                }
            }
        }

        /*
         * If Destination Account is CapIntro then we are assuming that Opportunity related to destination's RG Account would be present
         * If Opportunity is not present then leave it
         */   
        if(campaignAtRMLevelObj.isNewAccountRMCapIntro == TRUE){
            //Fetch CapIntro Opportunity
            opportunityObj = fetchCapIntroOpportunity(campaignAtRMLevelObj.newAccountRGId);
        }
        else {
            //If Destination Account is not Cap Intro then we have to make that record as CapIntro
            //Making the Account as CapIntro will automatically create the opportunity

            Account accountObj = new Account();
            accountObj.id = campaignAtRMLevelObj.newAccountRMId;
            accountObj.CapIntro__c = TRUE;

            Database.SaveResult saveResultObj = Database.update(accountObj, false);
            if(!saveResultObj.isSuccess()){ 
                for(Database.Error errorObj : saveResultObj.getErrors()){
                    System.debug('Error Status Code for Account Update :'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                }
            }
            else {
                //Fetch CapIntro Opportunity
                opportunityObj = fetchCapIntroOpportunity(campaignAtRMLevelObj.newAccountRGId);
            }
        }

        //Update Events
        eventUpdateList.addAll(getEventUpdatedListBasedOnOppty(opportunityObj, eventList));

        return eventUpdateList;
    }

    public List<Event> fetchCapIntroEventUpdateListForRepName(BulkMovementContactAtRMLevelWrapper campaignAtRMLevelObj, Map<Integer,List<Id>> recordIdMap){
        List<EventRelation> eventRelationList = new List<EventRelation>();
        Map<Id,List<EventRelation>> eventRelationMap = new Map<Id,List<EventRelation>>();
        List<Event> eventUpdateList = new List<Event>();
        Map<Id,String> eventRepNameMap = new Map<Id,String>();

        //Fetch Cap Intro Event Relations - Considering Archived Events
        for(Integer i : recordIdMap.keySet()){
            List<Id> recordIdInnerList = recordIdMap.get(i);
            List<EventRelation> eventRelationInnerList = 
                [   
                    SELECT Id, RelationId,
                    EventId, Event.Rep_Name__c
                    FROM EventRelation
                    WHERE RelationId IN :recordIdInnerList 
                    AND Event.IsChild = FALSE
                    AND Event.Rep_Name__c <> ''
                    AND Event.Create_Type__c IN ('Call Report/Notes','CI Interactions','Event Call Report/Notes(Non Cap Intro)')
                    AND Event.Private__c = 'True'
                    AND IsDeleted = FALSE 
                    ALL ROWS  
                ];


            if(eventRelationInnerList != null && !eventRelationInnerList.isEmpty()){
                eventRelationList.addAll(eventRelationInnerList);
            }
        }    

        for(EventRelation eventRelationObj : eventRelationList){
            Id eventId = eventRelationObj.EventId;
            List<EventRelation> relationList = (eventRelationMap.containsKey(eventId)) ? eventRelationMap.get(eventId) : new List<EventRelation>();
            relationList.add(eventRelationObj);

            eventRelationMap.put(eventId, relationList);
        }

        if(eventRelationMap != null && !eventRelationMap.isEmpty()){
            for(Id eventId : eventRelationMap.keySet()){
                List<EventRelation> eventRelationTempList = eventRelationMap.get(eventId);
                String updatedRepName = (eventRepNameMap.containsKey(eventId)) ? eventRepNameMap.get(eventId) : '';
                for(EventRelation eventRelationObj : eventRelationTempList){
                    if(updatedRepName == null || String.isEmpty(updatedRepName)){
                        updatedRepName = eventRelationObj.Event.Rep_Name__c;
                    }
                    if(String.isNotEmpty(updatedRepName)){
                        String[] repNameArr = updatedRepName.split(',');
                        for(Integer index = 0; index < repNameArr.size(); index++){
                            String rmKey = repNameArr[index];
                            if(String.isNotEmpty(rmKey) && rmKey.equalsIgnoreCase(campaignAtRMLevelObj.accountRMKey)){
                                repNameArr[index] = campaignAtRMLevelObj.newAccountRMKey;
                            }
                        }

                        updatedRepName = String.join(repNameArr, ',');
                    }
                    
                    eventRepNameMap.put(eventId, updatedRepName);
                }

            }
        }

        if(eventRepNameMap != null && !eventRepNameMap.isEmpty()){
            List<Event> eventList = [SELECT Id, Rep_Name__c FROM Event WHERE Id IN :eventRepNameMap.keySet()];
            if(eventList != null && !eventList.isEmpty()){
                for(Event eventObj : eventList){
                    String actualRepName = eventObj.Rep_Name__c;
                    String expectedRepName = (eventRepNameMap.containsKey(eventObj.Id)) ? eventRepNameMap.get(eventObj.Id) : '';
                    
                    if(String.isNotEmpty(actualRepName) && String.isNotEmpty(expectedRepName) && !actualRepName.equalsIgnoreCase(expectedRepName)){
                        eventObj.Rep_Name__c = expectedRepName;
                        eventUpdateList.add(eventObj);
                    }
                }
            }
        }
        

        return eventUpdateList;
    }    

    public Opportunity fetchCapIntroOpportunity(Id accountRGId){
        Opportunity opportunityObj;
        List<Opportunity> opportunityList = [SELECT Id, Name, CapIntro__c, AccountId, Account__c
                                                FROM Opportunity
                                                WHERE RecordType.DeveloperName = 'Automated'
                                                AND CapIntro__c = TRUE
                                                AND AccountId = :accountRGId
                                                AND Account__c = :accountRGId
                                                AND Owner.Login_Id__c = 'sfadmin'];

        if(opportunityList != null && !opportunityList.isEmpty()){
            opportunityObj = opportunityList.get(0);
        }

        return opportunityObj;
    }

    public List<Event> getEventUpdatedListBasedOnOppty(Opportunity opportunityObj, List<Event> eventList){
        List<Event> eventUpdateList = new List<Event>();

        if(opportunityObj != null){
            for(Event eventObj : eventList){
                if(eventObj.WhatId <> opportunityObj.Id){
                    eventObj.WhatId = opportunityObj.Id;
                    eventUpdateList.add(eventObj);
                }
            }
        }

        return eventUpdateList;
    }

    public List<Event> updateEventRecords(List<Event> eventList){
        List<Event> eventErrorUpdateList = new List<Event>();

        if(eventList !=  null && !eventList.isEmpty()){
            Database.SaveResult[] saveResultList = Database.update(eventList, false);
            
            for(Integer i=0; i<saveResultList.size(); i++){            
                Database.SaveResult resultObj = saveResultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        System.debug('Error Status Code for Event Update :'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                    }
                    
                    Event eventObj = eventList.get(i);
                    eventErrorUpdateList.add(eventObj);
                }
            }
        }

        return eventErrorUpdateList;
    }

    public List<Task> updateTaskRecords(List<Task> taskList){
        List<Task> taskErrorUpdateList = new List<Task>();

        if(taskList !=  null && !taskList.isEmpty()){
            Database.SaveResult[] saveResultList = Database.update(taskList, false);
            
            for(Integer i=0; i<saveResultList.size(); i++){            
                Database.SaveResult resultObj = saveResultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        System.debug('Error Status Code for Task Update :'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                    }
                    
                    Task taskObj = taskList.get(i);
                    taskErrorUpdateList.add(taskObj);
                }
            }
        }

        return taskErrorUpdateList;
    }

}