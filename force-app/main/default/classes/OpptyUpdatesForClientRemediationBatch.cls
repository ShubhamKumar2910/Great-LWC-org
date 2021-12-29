global class OpptyUpdatesForClientRemediationBatch implements Database.Batchable<sObject>,Database.Stateful {
	//Important Execute this batch taking Batch size as 1
    
    global List<Opportunity> errorUpdateList;
    global List<Event> eventErrorUpdateList;
    global List<Task> taskErrorUpdateList;
    global String clientType;
    
    
    global OpptyUpdatesForClientRemediationBatch(String strClientType){
    	errorUpdateList = new List<Opportunity>();
        eventErrorUpdateList = new List<Event>();
        taskErrorUpdateList = new List<Task>();
        clientType = strClientType;
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String clientTypeCondition = '';
        String orderByCondition = '';
        
        if('RM'.equalsIgnoreCase(clientType)){
            clientTypeCondition = ' RM_ACTION__c IN (\'MERGE\',\'MOVE\',\'MERGE AND MOVE\') ';
            orderByCondition = ' ORDER BY NEW_RM__c ';
        }
        else if('RG'.equalsIgnoreCase(clientType)){
            clientTypeCondition = ' RG_ACTION__c IN (\'MERGE\',\'MOVE\') ';
            orderByCondition = ' ORDER BY NEW_RG__c ';
        }
        
        String query = 'SELECT RG_ACTION__c, RM_ACTION__c, OLD_RG__c, NEW_RG__c, OLD_RM__c, NEW_RM__c, OLD_RG_Account__c, NEW_RG_Account__c, OLD_RM_Account__c, NEW_RM_Account__c FROM Client_Remediation__c WHERE ' + clientTypeCondition + orderByCondition;
        System.debug('*** query is:'+query);
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
       List<Client_Remediation__c> clientRemediationList = (List<Client_Remediation__c>) scope;
        
       if('RG'.equalsIgnoreCase(clientType)){
            handleForRG(clientRemediationList);
       }
       else if('RM'.equalsIgnoreCase(clientType)){
            handleForRM(clientRemediationList);
       } 
        
    }
    
    global void handleForRG(List<Client_Remediation__c> clientRemediationList){
         Map<Id,Id> oldNewIdMap = new Map<Id,Id>();
        
         if(clientRemediationList != null && clientRemediationList.size() > 0){
            for(Client_Remediation__c crObj : clientRemediationList){
                if(String.isNotEmpty(crObj.OLD_RG__c) &&
                   String.isNotEmpty(crObj.NEW_RG__c) &&
                   crObj.OLD_RG_Account__c != null && 
                   crObj.NEW_RG_Account__c != null &&
                  !crObj.OLD_RG__c.equalsIgnoreCase(crObj.NEW_RG__c)) 
                {
                   oldNewIdMap.put(crObj.OLD_RG_Account__c, crObj.NEW_RG_Account__c);    
                }
            }
            
            if(oldNewIdMap.size() > 0){
                //Manual opportunities
                processManualOpportunities(oldNewIdMap);
            }
        }
    }
    
    global void handleForRM(List<Client_Remediation__c> clientRemediationList){
        Map<Id,Id> oldNewIdMap = new Map<Id,Id>();
        
         if(clientRemediationList != null && clientRemediationList.size() > 0){
            for(Client_Remediation__c crObj : clientRemediationList){
                if(String.isNotEmpty(crObj.OLD_RM__c) &&
                   String.isNotEmpty(crObj.NEW_RM__c) &&
                   crObj.OLD_RM_Account__c != null && 
                   crObj.NEW_RM_Account__c != null &&
                  !crObj.OLD_RM__c.equalsIgnoreCase(crObj.NEW_RM__c)) 
                {
                   oldNewIdMap.put(crObj.OLD_RM_Account__c, crObj.NEW_RM_Account__c);    
                }
            }
            
            if(oldNewIdMap.size() > 0){
                //Japan FI Automated Opportunities
                processAutomatedOpportunities(oldNewIdMap);
            }
        }
    }
    
    global void processManualOpportunities(Map<Id,Id> oldNewIdMap){
        List<Opportunity> finalOpptyList = new List<Opportunity>();
        
        List<Opportunity> opportunityList = [SELECT Id, Name, AccountId, Account.RDM_Org_Id__c, Account__c, Account__r.RecordType.Name, Active__c
                                             FROM Opportunity 
                                             WHERE AccountId IN :oldNewIdMap.keySet() AND
                                             SystemAuto_Type__c = null];
                
        if(opportunityList != null && opportunityList.size() > 0){
           
            for(Opportunity opptyObj : opportunityList){
                if(oldNewIdMap.containsKey(opptyObj.AccountId) 
                   && !String.valueOf(opptyObj.AccountId).equalsIgnoreCase(String.valueOf(oldNewIdMap.get(opptyObj.AccountId)))   )
                {
                    Id recordId = oldNewIdMap.get(opptyObj.AccountId);
                    
                    opptyObj.AccountId = recordId;
                    opptyObj.Account__c = recordId;
                    finalOpptyList.add(opptyObj);
                }
            }
            
            //Update Manually created Opportunities
            if(finalOpptyList.size() > 0){
                updateOpportunities(finalOpptyList);
            }
        }
    }
    
    global void processAutomatedOpportunities(Map<Id,Id> oldNewIdMap){
        //Map of Opportunity Id having events 
        Map<Id,List<Event>> opptyIdEventMap = new Map<Id,List<Event>>();
        //Map of Opportunity Id having tasks 
        Map<Id,List<Task>> opptyIdTaskMap = new Map<Id,List<Task>>();
        
        List<Event> eventToBeUpdatedList = new List<Event>();
        List<Task> taskToBeUpdatedList = new List<Task>();
        Map<Id,opportunity> opptyToBeUpdatedMap = new Map<Id,opportunity>();
        
        Set<Id> targetAccountIdSet = new Set<Id>();
        List<Opportunity> targetOpptyList = new List<Opportunity>();
        
        Map<Id,Opportunity> automatedOpptyMap = new Map<Id,Opportunity>([SELECT Id, Name, AccountId, Account.RDM_Org_Id__c,
                                                                         SystemAuto_Type__c,
                                                                         SystemAuto_Target_ID__c, SystemAuto_Person_Role_ID__c
                                                                         FROM Opportunity
                                                                         WHERE 
                                                                         AccountId IN :oldNewIdMap.keySet() AND
                                                                         SystemAuto_Type__c <> null 
                                                                        ]);
        if(automatedOpptyMap != null && automatedOpptyMap.size() > 0){
            List<Event> eventList = [SELECT Id, WhatId, Subject FROM Event
                                     WHERE IsChild = FALSE 
                                     	AND WhatId IN :automatedOpptyMap.keySet()
                                    	AND IsDeleted = FALSE ALL ROWS];
            List<Task> taskList = [SELECT Id, WhatId, Subject FROM Task
                                   WHERE WhatId IN :automatedOpptyMap.keySet()
                                  	AND IsDeleted = FALSE ALL ROWS];
            
            //Check for Events
            if(eventList != null && eventList.size() > 0){
                for(Event eventObj : eventList){
                    if(String.isNotEmpty(eventObj.WhatId)){
                        List<Event> eventListAssociatedToOppty = 
                            opptyIdEventMap.containsKey(eventObj.WhatId) ? opptyIdEventMap.get(eventObj.WhatId) : new List<Event>();
                        eventListAssociatedToOppty.add(eventObj);
                        
                        opptyIdEventMap.put(eventObj.WhatId, eventListAssociatedToOppty);
                    }
                }
            }
            
            //Check for Tasks
            if(taskList != null && taskList.size() > 0){
                for(Task taskObj : taskList){
                    if(String.isNotEmpty(taskObj.WhatId)){
                        List<Task> taskListAssociatedToOppty = 
                            opptyIdTaskMap.containsKey(taskObj.WhatId) ? opptyIdTaskMap.get(taskObj.WhatId) : new List<Task>();
                        taskListAssociatedToOppty.add(taskObj);
                        
                        opptyIdTaskMap.put(taskObj.WhatId, taskListAssociatedToOppty);
                    }
                }
            }
            
           
            //Fetch opportunities of target Accounts
            targetAccountIdSet.addAll(oldNewIdMap.values());
            
            if(targetAccountIdSet.size() > 0){
                targetOpptyList = [SELECT Id, Name, AccountId, Account.RDM_Org_Id__c,
                                   SystemAuto_Type__c, SystemAuto_Target_ID__c, SystemAuto_Person_Role_ID__c 
                                   FROM Opportunity 
                                   WHERE AccountId IN :targetAccountIdSet AND SystemAuto_Type__c <> null];
            }
            
            
            //Handle for Events
            if(opptyIdEventMap.size() > 0){
                for(Id opptyId : opptyIdEventMap.keySet()){
                    Opportunity opptyObj = automatedOpptyMap.get(opptyId);
                    
                    Id targetAccountId = oldNewIdMap.get(opptyObj.AccountId);
                    
                    //Check whether same opportunity exists at target RM
                    Id targetOpportunityId = opportunityExistsAtTargetEnd(opptyObj, targetOpptyList, targetAccountId);
                    
                    //If same opportunity exists at target side then associate the events with that Opportunity Id
                    if(targetOpportunityId != null){
                        List<Event> eventUpdateList = opptyIdEventMap.get(opptyId);
                        
                        if(eventUpdateList != null && eventUpdateList.size() > 0){
                            for(Event eventObj : eventUpdateList){
                                eventObj.WhatId = targetOpportunityId;
                                eventToBeUpdatedList.add(eventObj);
                            }
                        }
                    }
                    else { //Otherwise Change the AccountId for this opportunity
                        opptyObj.AccountId = targetAccountId;
                        opptyToBeUpdatedMap.put(opptyObj.Id, opptyObj);
                    }
                    
                }
            }
            
            //Handle for Tasks
            if(opptyIdTaskMap.size() > 0){
                for(Id opptyId : opptyIdTaskMap.keySet()){
                    Opportunity opptyObj = automatedOpptyMap.get(opptyId);
                    
                    Id targetAccountId = oldNewIdMap.get(opptyObj.AccountId);
                    
                    //Check whether same opportunity exists at target RM
                    Id targetOpportunityId = opportunityExistsAtTargetEnd(opptyObj, targetOpptyList, targetAccountId);
                    
                    //If same opportunity exists at target side then associate the tasks with that Opportunity Id
                    if(targetOpportunityId != null){
                        List<Task> taskUpdateList = opptyIdTaskMap.get(opptyId);
                        if(taskUpdateList != null && taskUpdateList.size() > 0){
                            for(Task taskObj : taskUpdateList){
                                taskObj.WhatId = targetOpportunityId;
                                taskToBeUpdatedList.add(taskObj);
                            }
                        }
                    }
                    else { //Otherwise Change the AccountId for this opportunity
                        opptyObj.AccountId = targetAccountId;
                        opptyToBeUpdatedMap.put(opptyObj.Id, opptyObj); //Since we are running this in batch size of 1 so it wont cause any issue
                    }
                    
                }
            }
            
            //Update Events
            if(eventToBeUpdatedList.size() > 0){
                updateEvents(eventToBeUpdatedList);
            }
            
            //Update tasks
            if(taskToBeUpdatedList.size() > 0){
                updateTasks(taskToBeUpdatedList);
            }
            
            //Update Opportunities
            if(opptyToBeUpdatedMap.size() > 0){
                updateOpportunities(opptyToBeUpdatedMap.values());
            }
            
            
        }
    }
    
    global Id opportunityExistsAtTargetEnd(Opportunity sourceOpptyObj, List<Opportunity> targetOpptyList, Id targetAccountId){
        Id opportunityId = null;
        
        String systemAutoType = sourceOpptyObj.SystemAuto_Type__c;
        String systemAutoTargetId = sourceOpptyObj.SystemAuto_Target_ID__c;
		String systemAutoPersonRoleId = sourceOpptyObj.SystemAuto_Person_Role_ID__c;
		            
		//Check whether same opportunity exists at target RM
        if(targetOpptyList.size() > 0){
            for(Opportunity targetOpptyObj : targetOpptyList){
                if(String.valueOf(targetAccountId).equalsIgnoreCase(targetOpptyObj.AccountId) &&
                   systemAutoType.equalsIgnoreCase(targetOpptyObj.SystemAuto_Type__c) &&
                   systemAutoTargetId.equalsIgnoreCase(targetOpptyObj.SystemAuto_Target_ID__c) &&
                   systemAutoPersonRoleId == targetOpptyObj.SystemAuto_Person_Role_ID__c
                  ){
                      opportunityId = targetOpptyObj.Id;
                      break;  
                  }
            }
        }
                    
        return opportunityId;
    }
    
    global void finish(Database.BatchableContext bc){
    	String toEmailAddress = null;
        String emailBody = null;
        String subject = null;
        
        AsyncApexJob apexJob = [SELECT Id, JobType, Status, JobItemsProcessed, TotalJobItems, 
                               NumberOfErrors, CompletedDate, MethodName, ExtendedStatus
                               FROM AsyncApexJob 
                               WHERE JobType = 'BatchApex' AND Id = :bc.getJobId()
                               ];
        if(apexJob != null && (apexJob.NumberOfErrors > 0 || errorUpdateList.size() > 0)){
            /* If Apex Batch fails then email will be sent out */
        	NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
        	toEmailAddress = nomuraSettings.To_Email_Addr_NomuraEmpReplacement_Batch__c;
            
            if(String.isNotEmpty(toEmailAddress)){
            	String[] toEmailArray = toEmailAddress.split(';');
                subject = 'SF - Opportunity Updates For Client Remediation Status';
                emailBody = getEmailBody(apexJob);
                Boolean isSuccess = MailUtility.sendMail(toEmailArray, subject, emailBody);
                if(!isSuccess){
                    System.debug('Error Occurred while sending mail');
                }
            }
        }
    }
    
    global void updateOpportunities(List<Opportunity> opportunityList){
        if(opportunityList != null && opportunityList.size() > 0){
            Database.SaveResult[] saveResultList = Database.update(opportunityList, false);
            
            for(Integer i=0; i<saveResultList.size(); i++){            
                Database.SaveResult resultObj = saveResultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        System.debug('Error Status Code for Opportunity Update :'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                    }
                    
                    errorUpdateList.add(opportunityList.get(i));
                }
            }
        }
    }
    
    global void updateEvents(List<Event> eventList){
        if(eventList != null && eventList.size() > 0){
            Database.SaveResult[] saveResultList = Database.update(eventList, false);
            
            for(Integer i=0; i<saveResultList.size(); i++){            
                Database.SaveResult resultObj = saveResultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        System.debug('Error Status Code for Event Update :'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                    }
                    
                    eventErrorUpdateList.add(eventList.get(i));
                }
            }
        }
    }
    
    global void updateTasks(List<Task> taskList){
        if(taskList != null && taskList.size() > 0){
            Database.SaveResult[] saveResultList = Database.update(taskList, false);
            
            for(Integer i=0; i<saveResultList.size(); i++){            
                Database.SaveResult resultObj = saveResultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        System.debug('Error Status Code for Task Update :'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                    }
                    
                    taskErrorUpdateList.add(taskList.get(i));
                }
            }
        }
    }
    
        
    global String getEmailBody(AsyncApexJob apexJob){
        String emailBody = null;
        String apexJobId = apexJob.Id;
        emailBody = '<p> The Batch Apex Job (' + apexJobId.substring(0,15) + ') processed '
                    + apexJob.TotalJobItems + ' batche(s) with ' + apexJob.NumberOfErrors + ' failure(s). </p>';
        
        /* Update Opportunity Record Failure */
        if(errorUpdateList.size() > 0){
        	emailBody = emailBody + '<p> Failed for below Update Opportunity records : </p><br>';
            emailBody = emailBody + '<br>'
                + '<table border=1 cellspacing=1 cellpadding=1>';
            emailBody = emailBody + '<tr>';
            emailBody = emailBody + '<td>Opportunity Details</td>';
            emailBody = emailBody + '</tr>';
            
            for(Opportunity opptyObj : errorUpdateList){
                String opptyDetails = 'Id : ' + opptyObj.Id + ' Name : ' + opptyObj.Name;
                emailBody = emailBody + '<tr>';
                
                emailBody = emailBody + '<td>';
                emailBody = emailBody + opptyDetails ;
                emailBody = emailBody + '</td>';
                
                emailBody = emailBody + '</tr>';
            }
            emailBody = emailBody + '</table> <br>';
        }
        
        /* Update Event Record Failure */
        if(eventErrorUpdateList.size() > 0){
        	emailBody = emailBody + '<p> Failed for below Update Event records : </p><br>';
            emailBody = emailBody + '<br>'
                + '<table border=1 cellspacing=1 cellpadding=1>';
            emailBody = emailBody + '<tr>';
            emailBody = emailBody + '<td>Event Details</td>';
            emailBody = emailBody + '</tr>';
            
            for(Event eventObj : eventErrorUpdateList){
                String eventDetails = 'Id : ' + eventObj.Id + ' Subject : ' + eventObj.Subject;
                emailBody = emailBody + '<tr>';
                
                emailBody = emailBody + '<td>';
                emailBody = emailBody + eventDetails ;
                emailBody = emailBody + '</td>';
                
                emailBody = emailBody + '</tr>';
            }
            emailBody = emailBody + '</table> <br>';
        }
        
        /* Update Task Record Failure */
        if(taskErrorUpdateList.size() > 0){
        	emailBody = emailBody + '<p> Failed for below Update Task records : </p><br>';
            emailBody = emailBody + '<br>'
                + '<table border=1 cellspacing=1 cellpadding=1>';
            emailBody = emailBody + '<tr>';
            emailBody = emailBody + '<td>Task Details</td>';
            emailBody = emailBody + '</tr>';
            
            for(Task taskObj : taskErrorUpdateList){
                String taskDetails = 'Id : ' + taskObj.Id + ' Subject : ' + taskObj.Subject;
                emailBody = emailBody + '<tr>';
                
                emailBody = emailBody + '<td>';
                emailBody = emailBody + taskDetails ;
                emailBody = emailBody + '</td>';
                
                emailBody = emailBody + '</tr>';
            }
            emailBody = emailBody + '</table> <br>';
        }
        
        return emailBody;
    }
}