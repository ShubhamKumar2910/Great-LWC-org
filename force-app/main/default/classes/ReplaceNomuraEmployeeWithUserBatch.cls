global class ReplaceNomuraEmployeeWithUserBatch implements Database.Batchable<sObject>,Database.Stateful {

    /*
     * This class will identify contacts of "Nomura Employees" which exist as Active Salesforce User
     * and it will replace those contacts with equivalent users in Events and Tasks.
     * After replacement, it will hard delete those contacts.
     */
    
    global Map<Integer,List<String>> batchLoginIdMap;
    global Integer batchCount;
    
    
    global ReplaceNomuraEmployeeWithUserBatch(){
        batchLoginIdMap = new Map<Integer,List<String>>();
        batchCount = 0;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = null;
        if(Test.isRunningTest()){
            String dummyLoginId = 'testdummy';
            query = 'SELECT Id, Name, Email, Login_Id__c, IsActive FROM User WHERE IsActive = TRUE AND Login_Id__c = :dummyLoginId LIMIT 1';
        }
        else {
            query = 'SELECT Id, Name, Email, Login_Id__c, IsActive FROM User WHERE IsActive = TRUE';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        List<String> loginIdList = new List<String>();
        List<Contact> contactList = new List<Contact>();
        Map<String,Id> userLoginIdMap = new Map<String,Id>();
        Map<Id,Id> contactUserMap = new Map<Id,Id>();
        Set<Id> contactPresentAsActiveUserSet = new Set<Id>();
        List<EventRelation> eventRelationListForNomuraContactsAsActiveUsers = new List<EventRelation>();
        List<EventRelation> userTypeEventRelationList = new List<EventRelation>();
        List<Event> eventListToBeUpdated = new List<Event>();
        Map<Id,Id> affectedEventOwnerMap = new Map<Id,Id>();
        String nomuraEmployeeAccountRDMOrgId = 'CP12345';
        
        //nomuraEmployeeContactList
        List<User> userList = (List<User>)scope;
        
        for(User userObj : userList){
            System.debug('USER LOGINID:'+userObj.Login_Id__c);
            if(String.isNotEmpty(userObj.Login_Id__c)){
                String loginIdUpperCase = userObj.Login_Id__c.toUpperCase();
                loginIdList.add(userObj.Login_Id__c);
                userLoginIdMap.put(loginIdUpperCase,userObj.Id);
            }
        }
        
        /* Storing Batch Details */
        batchCount = batchCount + 1;
        batchLoginIdMap.put(batchCount,loginIdList);
        
        if(userLoginIdMap.values() != null && userLoginIdMap.values().size() > 0){
            contactList = [ SELECT Id, Account.RDM_Org_Id__c, Name, Email, Active__c, Login_Id__c, Affiliation_Id__c
                            FROM Contact
                            WHERE IsDeleted = FALSE AND Account.RDM_Org_Id__c = :nomuraEmployeeAccountRDMOrgId
                            AND Login_Id__c IN :userLoginIdMap.keySet()
                          ];
            if(contactList != null && contactList.size() > 0){
                for(Contact contactObj : contactList){
                    if(String.isNotEmpty(contactObj.Login_Id__c)){
                        String contactLoginIdUpperCase = contactObj.Login_Id__c.toUpperCase();
                        if(userLoginIdMap.containsKey(contactLoginIdUpperCase)){
                            contactPresentAsActiveUserSet.add(contactObj.Id);
                            contactUserMap.put(contactObj.Id,userLoginIdMap.get(contactLoginIdUpperCase));
                        }
                    }
                }
                
                if(contactPresentAsActiveUserSet.size() > 0){
                    eventRelationListForNomuraContactsAsActiveUsers = getEventRelationsForNomuraContactsAsActiveUsers(contactPresentAsActiveUserSet);
                    affectedEventOwnerMap = getAffectedEventOwnerMap(eventRelationListForNomuraContactsAsActiveUsers);
                    if(eventRelationListForNomuraContactsAsActiveUsers.size() > 0){
                        userTypeEventRelationList = createEventRelations(eventRelationListForNomuraContactsAsActiveUsers, contactUserMap, affectedEventOwnerMap);
                        if(userTypeEventRelationList != null && userTypeEventRelationList.size() > 0){
                            insertEventRelations(userTypeEventRelationList);
                            eventListToBeUpdated = fetchEventsToBeUpdated(userTypeEventRelationList);
                            if(eventListToBeUpdated != null && eventListToBeUpdated.size() > 0){
                                updateEvents(eventListToBeUpdated);
                            }
                        }
                    }

                    /* Update Sales Rep's User Data, SALES-4932, 2021-06-25 by Copper */
                    updateSalesRepsForNomuraContactsAsActiveUsers(contactPresentAsActiveUserSet, contactUserMap);
                    
                    /* Deleting Nomura Employee Contacts present as Active Users */
                    deleteNomuraEmpContactsPresentAsActiveUsers(contactPresentAsActiveUserSet);
                }
            }
        }
        batchLoginIdMap.remove(batchCount);
        
    }
    
    global void finish(Database.BatchableContext bc){
        String toEmailAddress = null;
        String emailBody = null;
        
        /* If Apex Batch fails then email will be sent out */
        NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
        toEmailAddress = nomuraSettings.To_Email_Addr_NomuraEmpReplacement_Batch__c;
        
        AsyncApexJob apexJob = [SELECT Id, JobType, Status, JobItemsProcessed, TotalJobItems, 
                               NumberOfErrors, CompletedDate, MethodName, ExtendedStatus
                               FROM AsyncApexJob 
                               WHERE JobType = 'BatchApex' AND Id = :bc.getJobId()
                               ];
        if(apexJob != null){
            if(String.isNotEmpty(toEmailAddress)){
                String[] toEmailArray = toEmailAddress.split(';');
                if(toEmailArray != null && toEmailArray.size() > 0){
                    Messaging.SingleEmailMessage mailObj = new Messaging.SingleEmailMessage();
                    
                    mailObj.setToAddresses(toEmailArray);
                    mailObj.setSubject('SF - Nomura Employee Contact To User Conversion Batch Job Status');
                    
                    emailBody = getEmailBody(apexJob);
                    mailObj.setHtmlBody(emailBody);
                    
                    /* Send Email only in case of errors */
                    if(apexJob.NumberOfErrors > 0){
                        Messaging.SendEmailResult [] emailResults= Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mailObj}); 
                        if(emailResults != null && emailResults.size() > 0 && emailResults[0].success){
                            System.debug('The email was sent successfully');
                        }
                        else {
                            System.debug('Failed to send Email');
                        }
                    }
                    
                }
            }
        }
        
        
    }
    
    global List<EventRelation> getEventRelationsForNomuraContactsAsActiveUsers(Set<Id> contactIdSet){
        List<EventRelation> eventRelationList = new List<EventRelation>();
        
        /* Checking for both type of Events */
        /* TODO : Check for Nomura Employees As primary Contact for events from cP */
        eventRelationList = [SELECT Id, EventId, RelationId, Relation.Name, IsWhat, IsParent, IsInvitee, 
                             Status, Response, RespondedDate
                             FROM EventRelation
                             WHERE IsDeleted = FALSE AND Relation.Type = 'Contact' AND 
                                   RelationId IN :contactIdSet
                            ];
        
        return eventRelationList;
    }

    /* Update Nomura Contacts to Active Users for Sales Rep, SALES-4932, 2021-06-25 by Copper */
    global void updateSalesRepsForNomuraContactsAsActiveUsers(Set<Id> contactIdSet, Map<Id,Id> contactUserMap){
        List<DA_CorpClient_Attendee__c> salesRepList = new List<DA_CorpClient_Attendee__c>();

        salesRepList = [SELECT Id, Nomura_Employee_Contact__c, Sales_Rep__c 
                        FROM DA_CorpClient_Attendee__c 
                        WHERE Record_Type__c='Sales Rep' AND Nomura_Employee_Contact__c IN :contactIDSet
                       ];

        List<DA_CorpClient_Attendee__c> salesRepList2 = new List<DA_CorpClient_Attendee__c>();
        for (DA_CorpClient_Attendee__c salesRep : salesRepList) {
            if (contactUserMap.containsKey(salesRep.Nomura_Employee_Contact__c)) {
                salesRep.Sales_Rep__c = contactUserMap.get(salesRep.Nomura_Employee_Contact__c);
                salesRep.Nomura_Employee_Contact__c = null;
                salesRepList2.add(SalesRep);
            }
        }
        if (salesRepList2.size()>0)
            update SalesRepList2;

    }
    
    global Map<Id,Id> getAffectedEventOwnerMap(List<EventRelation> eventRelationListForNomuraContactsAsActiveUsers){
        Map<Id,Id> eventOwnerMap = new Map<Id,Id>();
        List<Event> events = null;
        if (eventRelationListForNomuraContactsAsActiveUsers != null && eventRelationListForNomuraContactsAsActiveUsers.size() > 0) {
            for (EventRelation eventRelation: eventRelationListForNomuraContactsAsActiveUsers) {
                eventOwnerMap.put(eventRelation.EventId, null);
            }
            if (eventOwnerMap != null && eventOwnerMap.size() > 0) {
                events = [select id, ownerid from event where id=:eventOwnerMap.keyset()];
                if (events != null && events.size() > 0) {
                    for (Event event: events) {
                        Id eventId = event.Id;
                        Id ownerId = event.OwnerId;
                        eventOwnerMap.put(eventId, ownerId);
                    }
                }
            }
        }
        return eventOwnerMap;
    }
    
    global List<EventRelation> createEventRelations(List<EventRelation> eventRelationList, Map<Id,Id> contactUserMap, Map<Id,Id> affectedEventOwnerMap){
        List<EventRelation> userTypeEventRelationList = new List<EventRelation>();
        
        for(EventRelation eventRelationObj : eventRelationList){
            String relationId = eventRelationObj.RelationId;
            if(contactUserMap.containsKey(relationId) && String.isNotEmpty(contactUserMap.get(relationId))) {
              if (!isParticipantAddedAsOwner(contactUserMap.get(relationId), eventRelationObj.EventId, affectedEventOwnerMap)) {
                    EventRelation eventRelation = new EventRelation();
                    eventRelation.EventId = eventRelationObj.EventId;
                    eventRelation.RelationId = contactUserMap.get(relationId);
                    eventRelation.IsInvitee = eventRelationObj.IsInvitee;
                    eventRelation.Status = eventRelationObj.Status;
                    eventRelation.Response = eventRelationObj.Response;
                    
                    userTypeEventRelationList.add(eventRelation);
                }   
            }
        }
        
        return userTypeEventRelationList;
    }
    
    global boolean isParticipantAddedAsOwner (Id participantId, Id eventId,  Map<Id, Id> affectedEventOwnerMap) {
        boolean isParticipantAddedAsOwner = false;
        Id ownerId = affectedEventOwnerMap.get(eventId);
        if (ownerId == participantId) {
            System.debug('Participant is added as owner: Event = ' + eventId +' , Owner= '+participantId);
            isParticipantAddedAsOwner = true;
        }
        else {
            System.debug('Participant is NOT added as owner: Event = ' + eventId +' , Owner= '+participantId);
        }
        return isParticipantAddedAsOwner;
    }
    
    global void insertEventRelations(List<EventRelation> eventRelationList){
        insert eventRelationList;
        
        /*Database.SaveResult[] saveResultList = Database.insert(eventRelationList, false);
        for(Database.SaveResult saveResult : saveResultList){
            if(!saveResult.isSuccess()){
                for(Database.Error errorObj : saveResult.getErrors()){
                    System.debug('****Error Status Code for Event Relation Insert:'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                }
            }
        }*/
    }
    
    global List<Event> fetchEventsToBeUpdated(List<EventRelation> eventRelationList){
        Set<Id> eventIdSet = new Set<Id>();
        List<Event> eventList = new List<Event>();
        for(EventRelation eventRelationObj : eventRelationList){
            eventIdSet.add(eventRelationObj.EventId);
        }
        if(eventIdSet.size() > 0){
            eventList = [SELECT Id FROM Event WHERE Id IN :eventIdSet];
        }
        
        return eventList;
    }
    
    global void updateEvents(List<Event> eventList){
        update eventList;
        
        /*Database.SaveResult[] saveResultList = Database.update(eventList, false);
        for(Database.SaveResult saveResult : saveResultList){
            if(!saveResult.isSuccess()){
                System.debug('Update failed for Event Id:'+saveResult.getId());
                for(Database.Error errorObj : saveResult.getErrors()){
                    System.debug('****Error Status Code for Event Update:'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                }
            }
        }*/
    }

    global void deleteNomuraEmpContactsPresentAsActiveUsers(Set<Id> contactIdSet){
        List<Contact> contactList = new List<Contact>();
        for(Id contactId : contactIdSet){
            Contact contactObj = new Contact();
            contactObj.Id = contactId;
            
            contactList.add(contactObj);
        }
        
        if(contactList.size() > 0){
            delete contactList;
            
            /*Database.DeleteResult[] deleteResultList = Database.delete(contactList, false);
            for(Database.DeleteResult deleteResult : deleteResultList){
                if(!deleteResult.isSuccess()){
                    System.debug('Delete failed for Contact Id:'+deleteResult.getId());
                    for(Database.Error errorObj : deleteResult.getErrors()){
                        System.debug('****Error Status Code for Contact Delete:'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                    }
                }
            }*/
        }
    }
    
    global String getEmailBody(AsyncApexJob apexJob){
        String emailBody = null;
        String apexJobId = apexJob.Id;
        emailBody = '<p> The Batch Apex Job (' + apexJobId.substring(0,15) + ') processed '
                    + apexJob.TotalJobItems + ' batche(s) with ' + apexJob.NumberOfErrors + ' failure(s). </p>';
        emailBody = emailBody + '<p> Failed for below records : </p><br>';
        
        if(batchLoginIdMap.size() > 0){
            emailBody = emailBody + '<br>'
                + '<table border=1 cellspacing=1 cellpadding=1>';
            emailBody = emailBody + '<tr>';
            emailBody = emailBody + '<td>Nomura Employee Contact LoginId</td>';
            emailBody = emailBody + '</tr>';
            
            for(Integer batchNo : batchLoginIdMap.keySet()){
                    emailBody = emailBody + '<tr>';
                    emailBody = emailBody + '<td>';
                    for(String loginId : batchLoginIdMap.get(batchNo)){
                       emailBody = emailBody + loginId + '<br>';
                    }
                    emailBody = emailBody + '</td>';
                    emailBody = emailBody + '</tr>';
            }
            emailBody = emailBody + '</table>';
        }
            
        return emailBody;
    }
}