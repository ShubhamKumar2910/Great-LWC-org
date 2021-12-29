global class TaskUpdatesForClientRemediationBatch implements Database.Batchable<sObject>,Database.Stateful {
	global List<Task> errorUpdateList;
    global String clientType;
    
    
    global TaskUpdatesForClientRemediationBatch(String strClientType){
    	errorUpdateList = new List<Task>();
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
                subject = 'SF - Task Updates(' + clientType + ') for Client Remediation Status';
                emailBody = getEmailBody(apexJob);
                Boolean isSuccess = MailUtility.sendMail(toEmailArray, subject, emailBody);
                if(!isSuccess){
                    System.debug('Error Occurred while sending mail');
                }
            }
        }
    }
    
    global void handleForRG(List<Client_Remediation__c> clientRemediationList){
        List<Task> taskList = null;
        Map<Id,Id> oldNewIdMap = new Map<Id,Id>();
        //Map of old RG Account Id as Key and New RDM_Org_Id__c as Value
        Map<Id,String> oldIdNewRDMOrgIdMap = new Map<Id,String>();
        
        if(clientRemediationList != null && clientRemediationList.size() > 0){
            for(Client_Remediation__c crObj : clientRemediationList){
                if(String.isNotEmpty(crObj.OLD_RG__c) &&
                   String.isNotEmpty(crObj.NEW_RG__c) &&
                   crObj.OLD_RG_Account__c != null && crObj.NEW_RG_Account__c != null &&
                   !crObj.OLD_RG__c.equalsIgnoreCase(crObj.NEW_RG__c)) 
                {
                    oldNewIdMap.put(crObj.OLD_RG_Account__c, crObj.NEW_RG_Account__c); 
                    oldIdNewRDMOrgIdMap.put(crObj.OLD_RG_Account__c, crObj.NEW_RG__c);
                }
                
            }
        }
           
        if(oldNewIdMap != null && oldNewIdMap.size() > 0){
            taskList = [SELECT Id, Subject, WhatId, What.Name, CP_Id__c
                        FROM Task 
                        WHERE What.Type = 'Account' AND WhatId IN :oldNewIdMap.keySet() AND IsDeleted = FALSE
                        ALL ROWS];
                
            if(taskList != null && taskList.size() > 0){
                for(Task taskObj : taskList){
                    if(oldNewIdMap.containsKey(taskObj.WhatId)){
                        //Change WhatId
                        taskObj.WhatId = oldNewIdMap.get(taskObj.WhatId);
                        
                        if(String.isNotEmpty(taskObj.CP_Id__c) && taskObj.CP_Id__c.contains('#RG')){
                            String prePart = taskObj.CP_Id__c.substring(0,taskObj.CP_Id__c.indexOf('#RG'));
                            String postPart = taskObj.CP_Id__c.substring(taskObj.CP_Id__c.lastIndexOf('#') + 1);   
                            String oldRGKey = taskObj.CP_Id__c.substring(taskObj.CP_Id__c.indexOf('#RG') + 1, taskObj.CP_Id__c.lastIndexOf('#'));   
                            String actualCPId = prePart + '#' + oldIdNewRDMOrgIdMap.get(taskObj.WhatId)  + '#' + postPart;
                            
                            taskObj.Cp_Id__c = actualCPId;
                        }
                    }
                }
            }
            
            //Perform Task Updates
            updateTask(taskList);
            
        }
    }
    
    global void handleForRM(List<Client_Remediation__c> clientRemediationList){
        List<Task> updatedTaskList = new List<Task>();
        //Map of old RDM_Org_Id__c as Key and New RDM_Org_Id__c as Value
        Map<String,String> oldNewRDMOrgIdMap = new Map<String,String>();
        Map<String,Id> rmRDMOrgIdRGIdMap = new Map<String,Id>();
        Map<String,String> rmRGRDMOrgIdMap = new Map<String,String>();
        Map<String,Id> oldRMRDMOrgIdRGIdMap = new Map<String,Id>();
        
        if(clientRemediationList != null && clientRemediationList.size() > 0){
            for(Client_Remediation__c crObj : clientRemediationList){
                if(String.isNotEmpty(crObj.OLD_RM__c) &&
                   String.isNotEmpty(crObj.NEW_RM__c)) 
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
            
            for(String oldRMKey : oldNewRDMOrgIdMap.keySet()){
                String rmLikeCritera = '%#' + oldRMKey + '%';
                List<Task> taskList = new List<Task>();
                Map<Id,Task> taskMap = new Map<Id,Task>();
                
                Map<Id,Task> taskMapPart1 = new Map<Id,Task>([SELECT Id, Subject, WhatId, What.Name, CP_Id__c
                                                            FROM Task 
                                                            WHERE What.Type = 'Account' AND 
                                                            (WhoId IN (SELECT Id FROM Contact WHERE Account.RDM_Org_Id__c = :oldRMKey))
                                                            AND IsDeleted = FALSE
                                                            ALL ROWS ]);
            
            	Map<Id,Task> taskMapPart2 = new Map<Id,Task>([SELECT Id, Subject, WhatId, What.Name, CP_Id__c
                                                                FROM Task 
                                                                WHERE What.Type = 'Account' AND CP_Id__c LIKE :rmLikeCritera
                                                                AND IsDeleted = FALSE
                                                                ALL ROWS]);
                
                if(taskMapPart1 != null && taskMapPart1.size() > 0){
                    for(Id taskId : taskMapPart1.keySet()){
                        taskMap.put(taskId, taskMapPart1.get(taskId));
                    }
                }
                
                if(taskMapPart2 != null && taskMapPart2.size() > 0){
                    for(Id taskId : taskMapPart2.keySet()){
                        taskMap.put(taskId, taskMapPart2.get(taskId));
                    }
                }
                
                if(taskMap != null && taskMap.size() > 0){
                    taskList.addAll(taskMap.values());
                }
                
                if(taskList != null && taskList.size() > 0){
                    for(Task taskObj : taskList){
                        Boolean recordChanged = FALSE;
                        
                        String currentWhatId = taskObj.WhatId;
                        String oldWhatId = oldRMRDMOrgIdRGIdMap.get(oldRMKey);
                            
                        String whatIdToBe = rmRDMOrgIdRGIdMap.get(oldRMKey);
                        
                        //For What Id 
                        if( String.isNotEmpty(oldWhatId) &&
                             String.isNotEmpty(currentWhatId) && 
                             currentWhatId.equalsIgnoreCase(oldWhatId) &&
                             String.isNotEmpty(whatIdToBe) && 
                             !currentWhatId.equalsIgnoreCase(whatIdToBe))
                         {
                             //Change WhatId
                             taskObj.WhatId = whatIdToBe;
                             recordChanged = TRUE;
                             
                             System.debug('Task What Id Changed:'+taskObj.Id);
                         }
                        
                        //For CP_Id__c containing RG
                        if(String.isNotEmpty(taskObj.CP_Id__c) && taskObj.CP_Id__c.contains('#RG')){
                            String currentRGKey = taskObj.CP_Id__c.substring(taskObj.CP_Id__c.indexOf('#RG') + 1, taskObj.CP_Id__c.lastIndexOf('#'));
                            String keyToBe = rmRGRDMOrgIdMap.get(oldNewRDMOrgIdMap.get(oldRMKey));
                            
                            if(String.isNotEmpty(keyToBe) && !currentRGKey.equalsIgnoreCase(keyToBe) ){
                                String prePart = taskObj.CP_Id__c.substring(0,taskObj.CP_Id__c.indexOf('#RG'));
                            	String postPart = taskObj.CP_Id__c.substring(taskObj.CP_Id__c.lastIndexOf('#') + 1);   
                                String actualCPId = prePart + '#' + keyToBe  + '#' + postPart;
                            	taskObj.CP_Id__c = actualCPId;
                                
                                recordChanged = TRUE;
                                
                                System.debug('***Changed RG Part in CP_Id__c for Task Id:'+taskObj.Id);
                            }
                        }
                        
                        //For CP_Id__c containing RM
                        if(String.isNotEmpty(taskObj.CP_Id__c) && 
                           taskObj.CP_Id__c.contains('#RM') && 
                           !taskObj.CP_Id__c.endsWithIgnoreCase('#CHANGED'))
                        {
                            String oldRMKeyFromTask = taskObj.CP_Id__c.substring(taskObj.CP_Id__c.lastIndexOf('#RM') + 1);   
                            if(oldRMKey.equalsIgnoreCase(oldRMKeyFromTask) &&
                               !oldRMKeyFromTask.equalsIgnoreCase(oldNewRDMOrgIdMap.get(oldRMKey)))
                            {
                                //Change CP_Id__c
                                String actualCPId = taskObj.CP_Id__c + '#' + oldNewRDMOrgIdMap.get(oldRMKey) + '#CHANGED';
                            	taskObj.CP_Id__c = actualCPId;
                                
                            	recordChanged = TRUE;
                                
                                System.debug('***Changed for Task Id:'+taskObj.Id);
                            }
                        }
                        
                        if(recordChanged){
                        	updatedTaskList.add(taskObj);
                        }
                    }
            	}
            }
            
            //Perform Task Updates
            if(updatedTaskList.size() > 0){
            	updateTask(updatedTaskList);
            }
            
        }
    }
    
    global void updateTask(List<Task> taskList){
        if(taskList != null && taskList.size() > 0){
            Database.SaveResult[] saveResultList = Database.update(taskList, false);
            
            for(Integer i=0; i<saveResultList.size(); i++){            
                Database.SaveResult resultObj = saveResultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        System.debug('Error Status Code for Task Update :'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                    }
                    
                    errorUpdateList.add(taskList.get(i));
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
        	emailBody = emailBody + '<p> Failed for below Update Task records : </p><br>';
            emailBody = emailBody + '<br>'
                + '<table border=1 cellspacing=1 cellpadding=1>';
            emailBody = emailBody + '<tr>';
            emailBody = emailBody + '<td>Task Details</td>';
            emailBody = emailBody + '</tr>';
            
            for(Task taskObj : errorUpdateList){
                String taskDetails = 'Id : ' + taskObj.Id + ' Subject : ' + taskObj.Subject + ' WhatId : ' + taskObj.WhatId + ' CP_Id__c : ' + taskObj.CP_Id__c;
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