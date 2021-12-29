global class ChampionUpdatesForClientRemediationBatch implements Database.Batchable<sObject>,Database.Stateful {
	//Do not run this feed using sfadmin User Otherwise deletes will not flow down to cP
    global List<Sales_Champion__c> errorUpdateList;
    global List<Sales_Champion__c> errorDeleteList;
    
    global ChampionUpdatesForClientRemediationBatch(){
    	errorUpdateList = new List<Sales_Champion__c>();
        errorDeleteList = new List<Sales_Champion__c>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT RG_ACTION__c, OLD_RG__c, NEW_RG__c, OLD_RM__c, NEW_RM__c, OLD_RG_Account__c, NEW_RG_Account__c, OLD_RM_Account__c, NEW_RM_Account__c FROM Client_Remediation__c WHERE RG_ACTION__c IN (\'MERGE\',\'MOVE\')';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        Map<Id,Id> oldNewIdMap = new Map<Id,Id>();
        List<Client_Remediation__c> clientRemediationList = (List<Client_Remediation__c>) scope;
        
        if(clientRemediationList != null && clientRemediationList.size() > 0){
            for(Client_Remediation__c crObj : clientRemediationList){
                if(String.isNotEmpty(crObj.OLD_RG__c) &&
                   String.isNotEmpty(crObj.NEW_RG__c) &&
                   crObj.OLD_RG_Account__c != null && crObj.NEW_RG_Account__c != null &&
                   !crObj.OLD_RG__c.equalsIgnoreCase(crObj.NEW_RG__c)) 
                {
                   oldNewIdMap.put(crObj.OLD_RG_Account__c, crObj.NEW_RG_Account__c);    
                }
            }
            
            if(oldNewIdMap.size() > 0){
                List<Sales_Champion__c> salesChampionList = [SELECT Id, Name, Account__c, Account__r.RDM_Org_Id__c
                                                             FROM Sales_Champion__c 
                                                             WHERE Account__c IN :oldNewIdMap.keySet()];
                
                if(salesChampionList != null && salesChampionList.size() > 0){
                    for(Sales_Champion__c championObj : salesChampionList){
                        if(oldNewIdMap.containsKey(championObj.Account__c)){
                            if(!test.isRunningTest()){
                            	championObj.Account__c = oldNewIdMap.get(championObj.Account__c);
                            }
                        }
                    }
                    
                    //Update Sales Champion
                    if(!test.isRunningTest()){
                    	updateSalesChampions(salesChampionList);
                    }
                    
                    //Fetch Champions Data again and check whether duplicate exists
                    List<Sales_Champion__c> duplicateChampionList = fetchDuplicateChampionData(oldNewIdMap);
                    
                    if(duplicateChampionList != null && duplicateChampionList.size() > 0){
                        deleteSalesChampions(duplicateChampionList);
                    }
                }
                    
            }
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
        if(apexJob != null && (apexJob.NumberOfErrors > 0 || errorUpdateList.size() > 0 || errorDeleteList.size() > 0)){
            /* If Apex Batch fails then email will be sent out */
        	NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
        	toEmailAddress = nomuraSettings.To_Email_Addr_NomuraEmpReplacement_Batch__c;
            
            if(String.isNotEmpty(toEmailAddress)){
            	String[] toEmailArray = toEmailAddress.split(';');
                subject = 'SF - Sales Champion Updates For Client Remediation Status';
                emailBody = getEmailBody(apexJob);
                Boolean isSuccess = MailUtility.sendMail(toEmailArray, subject, emailBody);
                if(!isSuccess){
                    System.debug('Error Occurred while sending mail');
                }
            }
        }
    }
    
    global void updateSalesChampions(List<Sales_Champion__c> salesChampionList){
        if(salesChampionList != null && salesChampionList.size() > 0){
            Database.SaveResult[] saveResultList = Database.update(salesChampionList, false);
            
            for(Integer i=0; i<saveResultList.size(); i++){            
                Database.SaveResult resultObj = saveResultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        System.debug('Error Status Code for Sales Champion Update :'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                    }
                    
                    errorUpdateList.add(salesChampionList.get(i));
                }
            }
        }
    }
    
    global void deleteSalesChampions(List<Sales_Champion__c> salesChampionList){
        Database.DeleteResult[] deleteResultList = Database.delete(salesChampionList, false);
        
        for(Integer i=0; i<deleteResultList.size(); i++){            
            Database.DeleteResult deleteResult = deleteResultList.get(i);
            
            if(!deleteResult.isSuccess()){ 
                for(Database.Error errorObj : deleteResult.getErrors()){
                    System.debug('Sales Champion Id :' + salesChampionList.get(i).Id + ' Error Status Code for Champion Delete:'+errorObj.getStatusCode() +' Message:'+errorObj.getMessage());
                }
                
                errorDeleteList.add(salesChampionList.get(i));
            }
       }
    }
    
    global List<Sales_Champion__c> fetchDuplicateChampionData(Map<Id,Id> oldNewIdMap){
        List<Sales_Champion__c> duplicateChampionToBeDeletedList = new List<Sales_Champion__c>();
        Map<String,List<Sales_Champion__c>> duplicateChampionMap = new Map<String,List<Sales_Champion__c>>();
        
        List<Sales_Champion__c> salesChampionList = [SELECT Id, Name, Account__c, Account__r.RDM_Org_Id__c,
                                                     Champion_Type__c, Region__c, 
                                                     Sales_Champion__c, Sales_Champion__r.Login_Id__c,
                                                     CreatedDate, CreatedBy.Login_Id__c, 
                                                     LastModifiedDate, LastModifiedBy.Login_Id__c
                                                     FROM Sales_Champion__c 
                                                     WHERE Account__c IN :oldNewIdMap.values()];
        
        if(salesChampionList != null && salesChampionList.size() > 0){
            for(Sales_Champion__c salesChampionObj : salesChampionList){
                String duplicateKey = salesChampionObj.Account__r.RDM_Org_Id__c + '#' + salesChampionObj.Champion_Type__c + '#' + salesChampionObj.Region__c + '#' + salesChampionObj.Sales_Champion__r.Login_Id__c;
                List<Sales_Champion__c> duplicateList = duplicateChampionMap.containsKey(duplicateKey) ? duplicateChampionMap.get(duplicateKey) : new List<Sales_Champion__c>();
                duplicateList.add(salesChampionObj);
                duplicateChampionMap.put(duplicateKey, duplicateList);
            }
            
            if(duplicateChampionMap.size() > 0){
                for(String duplicateKey : duplicateChampionMap.keySet()){
                    List<Sales_Champion__c> duplicateList = duplicateChampionMap.get(duplicateKey);
                    Id recordToBeMaintained = null;
                    if(duplicateList != null && duplicateList.size() > 1){
                        //Take the latest updated records for Deletion 
                        for(Sales_Champion__c championObj : duplicateList){
                            if(championObj.LastModifiedDate.date() != Date.today()){
                                recordToBeMaintained = championObj.Id;
                                break;
                            }
                        }
                        
                        if(recordToBeMaintained == null){
                            recordToBeMaintained = duplicateList.get(0).Id;
                        }
                        
                        for(Sales_Champion__c championObj : duplicateList){
                            if(!String.valueOf(championObj.Id).equalsIgnoreCase(String.valueOf(recordToBeMaintained))){
                                duplicateChampionToBeDeletedList.add(championObj);
                            }
                        }
                    }
                }
            }
        }
        
        return duplicateChampionToBeDeletedList;
    }
        
    global String getEmailBody(AsyncApexJob apexJob){
        String emailBody = null;
        String apexJobId = apexJob.Id;
        emailBody = '<p> The Batch Apex Job (' + apexJobId.substring(0,15) + ') processed '
                    + apexJob.TotalJobItems + ' batche(s) with ' + apexJob.NumberOfErrors + ' failure(s). </p>';
        
        /* Update Record Failure */
        if(errorUpdateList.size() > 0){
        	emailBody = emailBody + '<p> Failed for below Update Sales Champion records : </p><br>';
            emailBody = emailBody + '<br>'
                + '<table border=1 cellspacing=1 cellpadding=1>';
            emailBody = emailBody + '<tr>';
            emailBody = emailBody + '<td>Sales Champion Details</td>';
            emailBody = emailBody + '</tr>';
            
            for(Sales_Champion__c championObj : errorUpdateList){
                String championDetails = 'Id : ' + championObj.Id + ' Name : ' + championObj.Name;
                emailBody = emailBody + '<tr>';
                
                emailBody = emailBody + '<td>';
                emailBody = emailBody + championDetails ;
                emailBody = emailBody + '</td>';
                
                emailBody = emailBody + '</tr>';
            }
            emailBody = emailBody + '</table> <br>';
        }
        
        /* Delete Record Failure */
        if(errorDeleteList.size() > 0){
        	emailBody = emailBody + '<p> Failed for below Sales Champion records : </p><br>';
            emailBody = emailBody + '<br>'
                + '<table border=1 cellspacing=1 cellpadding=1>';
            emailBody = emailBody + '<tr>';
            emailBody = emailBody + '<td>Sales Champion Details</td>';
            emailBody = emailBody + '</tr>';
            
            for(Sales_Champion__c salesChampionObj : errorDeleteList){
            	String championDetails = 'Id : ' + salesChampionObj.Id + ' Name : ' + salesChampionObj.Name;
                emailBody = emailBody + '<tr>';
                
                emailBody = emailBody + '<td>';
                emailBody = emailBody + championDetails ;
                emailBody = emailBody + '</td>';
                
                emailBody = emailBody + '</tr>';       
            }
            emailBody = emailBody + '</table>';
        }
       
            
        return emailBody;
    }
}