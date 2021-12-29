global class EventUpdatesForClientRemediationBatch implements Database.Batchable<sObject>,Database.Stateful {
	//Execute this batch taking Batch size as 1
	//Contacts Should have been updated before running this job
	//Please perform this job for RM first and then RM for DACCUpdatesforClientRemediationBatch
	//1. EventUpdatesForClientRemediationBatch With RM
	//2. EventUpdatesForClientRemediationBatch With RG
	
    global List<Event> errorUpdateList;
    global Map<String,Integer> rgEventCountMap;
    global Map<String,Integer> rmEventCountMap;
    
    //Required for CorpClient
    global Map<Id,DACorpClientWrapper> eventIdCorpClientMap;
    
    global String clientType;
    global Integer MAX_EVENTS_TO_BE_UPDATED = 2000;
    
    global EventUpdatesForClientRemediationBatch(String strClientType){
        errorUpdateList = new List<Event>();
        rgEventCountMap = new Map<String,Integer>();
        rmEventCountMap = new Map<String,Integer>();
        eventIdCorpClientMap = new Map<Id,DACorpClientWrapper>();
        clientType = strClientType;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String clientTypeCondition = '';
        
        if('RM'.equalsIgnoreCase(clientType)){
            clientTypeCondition = 'RM_ACTION__c IN (\'MERGE\',\'MOVE\',\'MERGE AND MOVE\')';
        }
        else if('RG'.equalsIgnoreCase(clientType)){
            clientTypeCondition = 'RG_ACTION__c IN (\'MERGE\',\'MOVE\')';
        }
        
        String query = 'SELECT RG_ACTION__c, RM_ACTION__c, OLD_RG__c, NEW_RG__c, OLD_RM__c, NEW_RM__c, OLD_RG_Account__c, NEW_RG_Account__c, OLD_RM_Account__c, NEW_RM_Account__c FROM Client_Remediation__c WHERE ' + clientTypeCondition;
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
    
    global void finish(Database.BatchableContext bc){
    	
        //Call Batch for DACorpClient
        callBatchForDACorpClient();
        
        String toEmailAddress = null;
        String emailBody = null;
        String subject = null;
        
        AsyncApexJob apexJob = [SELECT Id, JobType, Status, JobItemsProcessed, TotalJobItems, 
                               NumberOfErrors, CompletedDate, MethodName, ExtendedStatus
                               FROM AsyncApexJob 
                               WHERE JobType = 'BatchApex' AND Id = :bc.getJobId()
                               ];
        if(apexJob != null && (apexJob.NumberOfErrors > 0 
                               || errorUpdateList.size() > 0 
                               || rgEventCountMap.size() > 0 
                               || rmEventCountMap.size() > 0)){
            /* If Apex Batch fails then email will be sent out */
        	NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
        	toEmailAddress = nomuraSettings.To_Email_Addr_NomuraEmpReplacement_Batch__c;
            
            if(String.isNotEmpty(toEmailAddress)){
            	String[] toEmailArray = toEmailAddress.split(';');
                subject = 'SF - Event Updates(' + clientType + ') for Client Remediation Status';
                emailBody = getEmailBody(apexJob);
                Boolean isSuccess = MailUtility.sendMail(toEmailArray, subject, emailBody);
                if(!isSuccess){
                    System.debug('Error Occurred while sending mail');
                }
            }
        }
    }
    
    global void callBatchForDACorpClient(){
        /* Call the batch for DA Client Corp */
        List<String> oldNewCPIdList = new List<String>();
        
        if(eventIdCorpClientMap != null && eventIdCorpClientMap.size() > 0){
            
            for(Id eventId : eventIdCorpClientMap.keySet()){
                DACorpClientWrapper corpClientObj = eventIdCorpClientMap.get(eventId);
                if(String.isNotEmpty(corpClientObj.oldCPId) && 
                   String.isNotEmpty(corpClientObj.newCPId) &&
                   !corpClientObj.oldCPId.equalsIgnoreCase(corpClientObj.newCPId)
                  )
                {
                	String oldNewCPId = corpClientObj.oldCPId + '~' + corpClientObj.newCPId;
                    oldNewCPIdList.add(oldNewCPId);
                }
            }
            
            if(oldNewCPIdList.size() > 0){
                DAUpdatesforClientRemediationBatch corpClientUpdatesBatch = new DAUpdatesforClientRemediationBatch(oldNewCPIdList);
                Id batchProcessId = Database.executeBatch(corpClientUpdatesBatch);
            }
       	}   
    }
    
    global void handleForRG(List<Client_Remediation__c> clientRemediationList){
        Map<Id,Id> oldNewIdMap = new Map<Id,Id>();
        Map<String,String> oldNewRDMOrgIdMap = new Map<String,String>();
        List<Event> eventList = null;
        
        if(clientRemediationList != null && clientRemediationList.size() > 0){
            for(Client_Remediation__c crObj : clientRemediationList){
                if(String.isNotEmpty(crObj.OLD_RG__c) &&
                   String.isNotEmpty(crObj.NEW_RG__c) &&
                   crObj.OLD_RG_Account__c != null && crObj.NEW_RG_Account__c != null &&
                   !crObj.OLD_RG__c.equalsIgnoreCase(crObj.NEW_RG__c)) 
                {
                    oldNewIdMap.put(crObj.OLD_RG_Account__c, crObj.NEW_RG_Account__c); 
                    oldNewRDMOrgIdMap.put(crObj.OLD_RG__c, crObj.NEW_RG__c);
                }
            }
        }
           
        if(oldNewIdMap != null && oldNewIdMap.size() > 0){
            eventList = [SELECT Id, Subject, WhatId, What.Name, CP_Id__c, RecordType.Name
                        FROM Event 
                        WHERE IsChild = FALSE AND What.Type = 'Account' AND WhatId IN :oldNewIdMap.keySet()
                        AND IsDeleted = FALSE
                        ALL ROWS];
                
            System.debug('**Size of EventList:'+eventList.size());
            if(eventList != null && eventList.size() > 0){
                for(Event eventObj : eventList){
                    if(oldNewIdMap.containsKey(eventObj.WhatId)){
                        //Update WhatId
                        eventObj.WhatId = oldNewIdMap.get(eventObj.WhatId);
                        
                        /*if(String.isNotEmpty(eventObj.CP_Id__c) && 
                           eventObj.CP_Id__c.contains('#RG') &&
                           'DealAxis Event Integration'.equalsIgnoreCase(eventObj.RecordType.Name))
                        {
                           
                           //Append new RG to the end only if there is change in RG
                           Integer indexForRG = eventObj.CP_Id__c.lastIndexOf('#RG');
                           if(indexForRG != -1){
                               String remainingCPId = eventObj.CP_Id__c.substring(indexForRG + 1);
                               Boolean containsOtherData = (String.isNotBlank(remainingCPId) && remainingCPId.contains('#')) ? TRUE : FALSE;
                              
                               String oldRGKey = eventObj.CP_Id__c.substring(indexForRG + 1, (containsOtherData ? eventObj.CP_Id__c.lastIndexOf('#') : eventObj.CP_Id__c.length())); 
                               
                               if(oldNewRDMOrgIdMap.containsKey(oldRGKey)){
                                   String newRGKey = oldNewRDMOrgIdMap.get(oldRGKey);
                                   if(String.isNotEmpty(newRGKey) && !oldRGKey.equalsIgnoreCase(newRGKey)){
                                       String actualCPId = eventObj.CP_Id__c + '#' + newRGKey;
                                       
                                       eventIdCorpClientMap.put(eventObj.Id, new DACorpClientWrapper(eventObj.Id, eventObj.CP_Id__c, actualCPId));
                                       
                                       eventObj.CP_Id__c = actualCPId;
                                   }
                               }
                           } 
                        }*/
                        
                        //TODO : Check for Standard Events
                        /*if(String.isNotEmpty(eventObj.CP_Id__c) && 
                           eventObj.CP_Id__c.contains('--RG') &&
                           'Standard Event'.equalsIgnoreCase(eventObj.RecordType.Name))
                        {
                            //Replace RG
                            Integer indexForRG = eventObj.CP_Id__c.indexOf('--RG');
                            if(indexForRG != -1){
                           	   String prePart = eventObj.CP_Id__c.substring(0, indexForRG);
                               String oldRGKey = eventObj.CP_Id__c.substring(indexForRG + 2); 
                               
                                if(oldNewRDMOrgIdMap.containsKey(oldRGKey)){
                                   String newRGKey = oldNewRDMOrgIdMap.get(oldRGKey);
                                   if(String.isNotEmpty(newRGKey) && !oldRGKey.equalsIgnoreCase(newRGKey)){
                                       String actualCPId = prePart + '--' + newRGKey;
                                       eventObj.CP_Id__c = actualCPId;
                                   }
                               }
                            } 
                        }*/
                    }
                }
                
                //Perform Event Updates -- We are executing taking batch size as 1
                if(eventList.size() > MAX_EVENTS_TO_BE_UPDATED){
                    List<Event> finalListToBeUpdated = new List<Event>();
                    List<Event> excludedList = new List<Event>();
                    for(Integer i=0; i<eventList.size(); i++){
                        Event eventObj = eventList.get(i);
                        if(i >= MAX_EVENTS_TO_BE_UPDATED){
                            excludedList.add(eventObj);
                        }
                        else {
                            finalListToBeUpdated.add(eventObj);
                        }
                    }
                    
                    if(finalListToBeUpdated.size() > 0){
                         updateEvent(finalListToBeUpdated);
                    }
                    
                    if(excludedList.size() > 0){
                        for(Event eventObj : excludedList){
                            if(String.isNotEmpty(eventObj.CP_Id__c) && eventObj.CP_Id__c.contains('#RG')){
                                Integer indexForRG = eventObj.CP_Id__c.indexOf('#RG');
                                String oldRGKey = eventObj.CP_Id__c.substring(indexForRG, eventObj.CP_Id__c.lastIndexOf('#'));
                                if(rgEventCountMap.containsKey(oldRGKey)){
                                    Integer eventCount = rgEventCountMap.get(oldRGKey);
                                    eventCount = eventCount + 1;
                                    rgEventCountMap.put(oldRGKey, eventCount);
                                }
                                else {
                                    rgEventCountMap.put(oldRGKey, 1);
                                }
                                
                            } 
                        }
                    }
                }
                else {
                	//Update all Events
                    System.debug('**Size of EventList In Update:'+eventList.size());
                    updateEvent(eventList);
                }
            }
        }
    }
    
    global void handleForRM(List<Client_Remediation__c> clientRemediationList){
        List<Event> eventListForUpdate = new List<Event>();
        Map<String,String> oldNewRDMOrgIdMap = new Map<String,String>();
        Map<String,Id> rmRDMOrgIdRGIdMap = new Map<String,Id>();
        Map<String,String> rmRGRDMOrgIdMap = new Map<String,String>();
        Map<String,Id> oldRMRDMOrgIdRGIdMap = new Map<String,Id>();
        
        if(clientRemediationList != null && clientRemediationList.size() > 0){
            for(Client_Remediation__c crObj : clientRemediationList){
                if(String.isNotEmpty(crObj.OLD_RM__c) &&
                   String.isNotEmpty(crObj.NEW_RM__c) ) 
                {
                    oldNewRDMOrgIdMap.put(crObj.OLD_RM__c, crObj.NEW_RM__c);
                    oldRMRDMOrgIdRGIdMap.put(crObj.OLD_RM__c, crObj.OLD_RG_Account__c);
                }
                
            }
        }
           
        if(oldNewRDMOrgIdMap != null && oldNewRDMOrgIdMap.size() > 0){
            List<Account> accountList = [SELECT Id, Name, RDM_Org_Id__c, Parent.Id, Parent.RDM_Org_Id__c 
                                         FROM Account 
                                         WHERE RDM_Org_Id__c IN : oldNewRDMOrgIdMap.values() ];
            
            if(accountList != null && accountList.size() > 0){
                for(Account accountObj : accountList){
                    rmRDMOrgIdRGIdMap.put(accountObj.RDM_Org_Id__c, accountObj.Parent.Id);
                    rmRGRDMOrgIdMap.put(accountObj.RDM_Org_Id__c, accountObj.Parent.RDM_Org_Id__c);
                }
            }
            
            //It will run in batch size of 1
            for(String oldRMKey : oldNewRDMOrgIdMap.keySet()){
                List<Event> eventList = new List<Event>();
                Map<Id,Event> eventMap = new Map<Id,Event>();
                String rmLikeCriteria = '%' + oldRMKey + '%';
                
                Map<Id,Event> eventMapPart1 = new Map<Id,Event>(
                    [SELECT Id, Subject, WhatId, What.Name, CP_Id__c, WhoId, RecordType.Name
                     FROM Event
                     WHERE IsChild = FALSE AND 
                     What.Type = 'Account' AND
                     WhoId IN (SELECT Id FROM Contact WHERE Account.RDM_Org_Id__c = :oldRMKey) AND
                     RecordType.Name = 'Standard Event'
                     AND IsDeleted = FALSE
                     ALL ROWS
					]);
                
                Map<Id,Event> eventMapPart2 = new Map<Id,Event>(
                    [SELECT Id, Subject, WhatId, What.Name, CP_Id__c, WhoId, RecordType.Name
                     FROM Event
                     WHERE IsChild = FALSE AND 
                     What.Type = 'Account' AND
                     CP_Id__c LIKE :rmLikeCriteria AND
                     RecordType.Name = 'CP Event Integration'
                     AND IsDeleted = FALSE
                     ALL ROWS
                    ]);
                
                if(eventMapPart1 != null && eventMapPart1.size() > 0){
                    for(Id eventId : eventMapPart1.keySet()){
                        eventMap.put(eventId, eventMapPart1.get(eventId));
                    }
                }
                
                if(eventMapPart2 != null && eventMapPart2.size() > 0){
                    for(Id eventId : eventMapPart2.keySet()){
                        eventMap.put(eventId, eventMapPart2.get(eventId));
                    }
                }
                
                if(eventMap != null && eventMap.size() > 0){
                    eventList.addAll(eventMap.values());
                }
                
                if(eventList != null && eventList.size() > 0){
                    
                    for(Event eventObj : eventList){
                        Boolean recordChanged = FALSE;
                        
                        String currentWhatId = eventObj.WhatId;
                        String oldWhatId = oldRMRDMOrgIdRGIdMap.get(oldRMKey);
                        
                        String whatIdToBe = rmRDMOrgIdRGIdMap.get(oldRMKey);
                        
                        //For Standard Events only
                        if('Standard Event'.equalsIgnoreCase(eventObj.RecordType.Name) &&
                           String.isNotEmpty(oldWhatId) &&
                           String.isNotEmpty(currentWhatId) && 
                           currentWhatId.equalsIgnoreCase(oldWhatId) &&
                           String.isNotEmpty(whatIdToBe) && 
                           !currentWhatId.equalsIgnoreCase(whatIdToBe)){
                            
                               //Change WhatId
                               eventObj.WhatId = whatIdToBe;
                               recordChanged = TRUE;
                               
                               System.debug('Standard Event What Id Changed:'+eventObj.Id);
                               
                               /*if(String.isNotEmpty(eventObj.CP_Id__c) && 
                                  eventObj.CP_Id__c.contains('RG') )
                                 ){
                                    //Replace RG
                                    Integer indexForRG = eventObj.CP_Id__c.indexOf('--RG');
                                    if(indexForRG != -1){
                                       String prePart = eventObj.CP_Id__c.substring(0, indexForRG);
									   String currentRGKey = eventObj.CP_Id__c.substring(indexForRG + 2); 
                                        if(String.isNotEmpty(currentRGKey) && !currentRGKey.equalsIgnoreCase(rmRGRDMOrgIdMap.get(oldRMKey))) {
                                          String actualCPId = prePart + '--' + rmRGRDMOrgIdMap.get(oldNewRDMOrgIdMap.get(oldRMKey));
                                       	  eventObj.CP_Id__c = actualCPId;  
                                        }
                                       
                                    } 
                               }*/
                        }
                        
                        //For DealAxis Events
                        /*if(String.isNotEmpty(eventObj.CP_Id__c) && 
                           eventObj.CP_Id__c.contains('#RG') &&
                           'DealAxis Event Integration'.equalsIgnoreCase(eventObj.RecordType.Name))
                        {
                            
                            //Append RG to the end
                            Integer indexForRG = eventObj.CP_Id__c.lastIndexOf('#RG');
                            if(indexForRG != -1){
                                String remainingCPId = eventObj.CP_Id__c.substring(indexForRG + 1);
                                Boolean containsOtherData = (String.isNotBlank(remainingCPId) && remainingCPId.contains('#')) ? TRUE : FALSE;
                                String currentRGKey = eventObj.CP_Id__c.substring(indexForRG + 1, (containsOtherData ? eventObj.CP_Id__c.lastIndexOf('#') : eventObj.CP_Id__c.length())); 
                                
								String keyToBe = rmRGRDMOrgIdMap.get(oldNewRDMOrgIdMap.get(oldRMKey));

								if(String.isNotEmpty(currentRGKey) && !currentRGKey.equalsIgnoreCase(keyToBe)){
                                    String actualCPId = eventObj.CP_Id__c + '#' + keyToBe;
                                    eventIdCorpClientMap.put(eventObj.Id, new DACorpClientWrapper(eventObj.Id, eventObj.CP_Id__c, actualCPId));
                                    eventObj.CP_Id__c = actualCPId;
                                }
                            } 
                        }*/
                        
                        
                        //Specific to CP Event Integration Events
                        if('CP Event Integration'.equalsIgnoreCase(eventObj.RecordType.Name) && 
                           String.isNotEmpty(eventObj.CP_Id__c) && 
                           eventObj.CP_Id__c.contains('RM') &&
                           !eventObj.CP_Id__c.endsWithIgnoreCase('#CHANGED')){
                            String oldRMKeyFromEvent = eventObj.CP_Id__c.substring(eventObj.CP_Id__c.lastIndexOf('RM'));
                            if(!oldRMKeyFromEvent.equalsIgnoreCase(oldNewRDMOrgIdMap.get(oldRMKey)) &&
                               oldRMKey.equalsIgnoreCase(oldRMKeyFromEvent) )
                            {
                            	System.debug('***Changed for Event Id:'+eventObj.Id);
                                String actualCPId = eventObj.CP_Id__c + '#' + oldNewRDMOrgIdMap.get(oldRMKey) + '#CHANGED';
                            	eventObj.CP_Id__c = actualCPId;
                            	recordChanged = TRUE;
                            }
                    	}
                        
                        if(recordChanged){
                            eventListForUpdate.add(eventObj);
                        }
                    }
                }
            	
            }
           
        }
        
        if(eventListForUpdate.size() > 0){
             if(eventListForUpdate.size() > MAX_EVENTS_TO_BE_UPDATED){
                 List<Event> finalListToBeUpdated = new List<Event>();
                 List<Event> excludedList = new List<Event>();
                 for(Integer i=0; i<eventListForUpdate.size(); i++){
                     Event eventObj = eventListForUpdate.get(i);
                     if(i >= MAX_EVENTS_TO_BE_UPDATED){
                         excludedList.add(eventObj);
                     }
                     else {
                         finalListToBeUpdated.add(eventObj);
                     }
                 }
                 
                 if(finalListToBeUpdated.size() > 0){
                     updateEvent(finalListToBeUpdated);
                 }
                 
                 if(excludedList.size() > 0){
                     for(Event eventObj : excludedList){
                         if(String.isNotEmpty(eventObj.CP_Id__c) && eventObj.CP_Id__c.contains('RM')){
                             Integer indexForRM = eventObj.CP_Id__c.indexOf('RM');
                             String oldRMKey = eventObj.CP_Id__c.substring(indexForRM);
                             if(rmEventCountMap.containsKey(oldRMKey)){
                                 Integer eventCount = rmEventCountMap.get(oldRMKey);
                                 eventCount = eventCount + 1;
                                 rmEventCountMap.put(oldRMKey, eventCount);
                             }
                             else {
                                 rmEventCountMap.put(oldRMKey, 1);
                             }
                             
                         } 
                     }
                 }
            }
            else {
                //Update all Events
                updateEvent(eventListForUpdate);
            }
        }
        
        
    }
    
	global void updateEvent(List<Event> eventList){
        if(eventList != null && eventList.size() > 0){
            Database.SaveResult[] saveResultList = Database.update(eventList, false);
            
            for(Integer i=0; i<saveResultList.size(); i++){            
                Database.SaveResult resultObj = saveResultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        System.debug('Error Status Code for Event Update :'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                    }
                    
                    errorUpdateList.add(eventList.get(i));
                    
                    //If there is failure then remove from eventIdCorpClientMap
                    if(eventIdCorpClientMap.containsKey(eventList.get(i).Id)){
                        eventIdCorpClientMap.remove(eventList.get(i).Id);
                    }
                }
            }
        }
    }
    
    global String getEmailBody(AsyncApexJob apexJob){
        String emailBody = null;
        String apexJobId = apexJob.Id;
        emailBody = '<p> The Batch Apex Job (' + apexJobId.substring(0,15) + ') processed '
                    + apexJob.TotalJobItems + ' batche(s) with ' + apexJob.NumberOfErrors + ' failure(s). </p>';
        
        /* Update Record Failure */
        if(errorUpdateList.size() > 0){
        	emailBody = emailBody + '<p> Failed for below Update Event records : </p><br>';
            emailBody = emailBody + '<br>'
                + '<table border=1 cellspacing=1 cellpadding=1>';
            emailBody = emailBody + '<tr>';
            emailBody = emailBody + '<td>Event Details</td>';
            emailBody = emailBody + '</tr>';
            
            for(Event eventObj : errorUpdateList){
                String eventDetails = 'Id : ' + eventObj.Id + ' Subject : ' + eventObj.Subject + ' WhatId : ' + eventObj.WhatId + ' CP_Id__c : ' + eventObj.CP_Id__c;
                emailBody = emailBody + '<tr>';
                
                emailBody = emailBody + '<td>';
                emailBody = emailBody + eventDetails ;
                emailBody = emailBody + '</td>';
                
                emailBody = emailBody + '</tr>';
            }
            emailBody = emailBody + '</table> <br>';
        }
        
        if('RG'.equalsIgnoreCase(clientType)){
            /* RGs where Number of records greater than MAX_EVENTS_TO_BE_UPDATED */
        
            if(rgEventCountMap.size() > 0){
                emailBody = emailBody + '<p> Partial Update for below RG Records : </p><br>';
                emailBody = emailBody + '<br>'
                    + '<table border=1 cellspacing=1 cellpadding=1>';
                emailBody = emailBody + '<tr>';
                emailBody = emailBody + '<td>RG Key</td>';
                emailBody = emailBody + '<td>Count</td>';
                emailBody = emailBody + '</tr>';
                
                for(String strRGKey : rgEventCountMap.keySet()){
                    emailBody = emailBody + '<tr>';
                    
                    emailBody = emailBody + '<td>';
                    emailBody = emailBody + strRGKey ;
                    emailBody = emailBody + '</td>';
                    
                    emailBody = emailBody + '<td>';
                    emailBody = emailBody + rgEventCountMap.get(strRGKey) ;
                    emailBody = emailBody + '</td>';
                    
                    emailBody = emailBody + '</tr>';
                }
                emailBody = emailBody + '</table> <br>';
            }
        }
        
        if('RM'.equalsIgnoreCase(clientType)){
            /* RMs where Number of records greater than MAX_EVENTS_TO_BE_UPDATED */
        
            if(rgEventCountMap.size() > 0){
                emailBody = emailBody + '<p> Partial Update for below RM Records : </p><br>';
                emailBody = emailBody + '<br>'
                    + '<table border=1 cellspacing=1 cellpadding=1>';
                emailBody = emailBody + '<tr>';
                emailBody = emailBody + '<td>RM Key</td>';
                emailBody = emailBody + '<td>Count</td>';
                emailBody = emailBody + '</tr>';
                
                for(String strRMKey : rmEventCountMap.keySet()){
                    emailBody = emailBody + '<tr>';
                    
                    emailBody = emailBody + '<td>';
                    emailBody = emailBody + strRMKey ;
                    emailBody = emailBody + '</td>';
                    
                    emailBody = emailBody + '<td>';
                    emailBody = emailBody + rmEventCountMap.get(strRMKey) ;
                    emailBody = emailBody + '</td>';
                    
                    emailBody = emailBody + '</tr>';
                }
                emailBody = emailBody + '</table> <br>';
            }
        }
        
        return emailBody;
    }

       
}