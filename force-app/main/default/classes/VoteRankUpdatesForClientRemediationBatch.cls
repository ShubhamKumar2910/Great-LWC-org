global class VoteRankUpdatesForClientRemediationBatch implements Database.Batchable<sObject>,Database.Stateful {
	global List<Account_Vote_Ranks__c> errorUpdateList;
    global List<Account_Vote_Ranks__c> errorDeleteList;
    
    
    global VoteRankUpdatesForClientRemediationBatch(){
    	errorUpdateList = new List<Account_Vote_Ranks__c>();
        errorDeleteList = new List<Account_Vote_Ranks__c>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT RG_ACTION__c, OLD_RG__c, NEW_RG__c, OLD_RM__c, NEW_RM__c, OLD_RG_Account__c, NEW_RG_Account__c, OLD_RM_Account__c, NEW_RM_Account__c FROM Client_Remediation__c WHERE RG_ACTION__c IN (\'MERGE\',\'MOVE\')';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        Map<Id,Id> oldNewIdMap = new Map<Id,Id>();
        List<Client_Remediation__c> clientRemediationList = (List<Client_Remediation__c>) scope;
        Map<String, List<Account_Vote_Ranks__c>> errorRecordsMap = new Map<String, List<Account_Vote_Ranks__c>>();
        
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
                List<Account_Vote_Ranks__c> accountVoteRankList = [SELECT Id, Name, Account__c, Account__r.RDM_Org_Id__c
                                                             FROM Account_Vote_Ranks__c 
                                                             WHERE Account__c IN :oldNewIdMap.keySet()];
                
                if(accountVoteRankList != null && accountVoteRankList.size() > 0){
                    for(Account_Vote_Ranks__c voteRankObj : accountVoteRankList){
                        if(oldNewIdMap.containsKey(voteRankObj.Account__c)){
                            if(!test.isRunningTest()){
                            	voteRankObj.Account__c = oldNewIdMap.get(voteRankObj.Account__c);
                            }
                        }
                    }
                    
                    //Update Account Vote Rank
                    updateAccountVoteRank(accountVoteRankList);
                    
                    /*Boolean processFlag = (errorRecordsMap != null && errorRecordsMap.size() > 0);
                    System.debug('****processFlag:'+processFlag);
                    while(processFlag){
                        
                        processFlag = false;
                        
                        List<Account_Vote_Ranks__c> duplicateList = errorRecordsMap.get('DUPLICATE');
                        List<Account_Vote_Ranks__c> latestVoteList = errorRecordsMap.get('LATESTVOTE');
                        
                        //Delete Duplicate List
                        if(duplicateList != null && duplicateList.size() > 0){
                            deleteAccountVoteRank(duplicateList);
                        }
                        
                        //Again Update latestVoteList
                        if(latestVoteList != null && latestVoteList.size() > 0){
                            for(Account_Vote_Ranks__c voteRankObj : latestVoteList){
                                voteRankObj.Latest_Vote__c = 'No';
                            }
                            errorRecordsMap = updateAccountVoteRank(latestVoteList);
                            if(errorRecordsMap != null && errorRecordsMap.size() > 0){
                                processFlag = true;
                            }
                        }
                    }*/
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
                subject = 'SF - Account Vote Rank Updates For Client Remediation Status';
                emailBody = getEmailBody(apexJob);
                Boolean isSuccess = MailUtility.sendMail(toEmailArray, subject, emailBody);
                if(!isSuccess){
                    System.debug('Error Occurred while sending mail');
                }
            }
        }
    }
    
    global void updateAccountVoteRank(List<Account_Vote_Ranks__c> accountVoteRankList){
        Map<String,List<Account_Vote_Ranks__c>> errorRecordsMap = new Map<String,List<Account_Vote_Ranks__c>>();
            
        if(accountVoteRankList != null && accountVoteRankList.size() > 0){
            Database.SaveResult[] saveResultList = Database.update(accountVoteRankList, false);
            
            for(Integer i=0; i<saveResultList.size(); i++){            
                Database.SaveResult resultObj = saveResultList.get(i);
                if(!resultObj.isSuccess()){ 
                    Boolean duplicateRecord = FALSE;
                    Boolean latestVoteRecord = FALSE;
                    
                    for(Database.Error errorObj : resultObj.getErrors()){
                        System.debug('Error Status Code for Account Vote Rank Update :'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                        errorUpdateList.add(accountVoteRankList.get(i));
                        /*if(errorObj.getMessage().contains('There already exists a vote  in this Period  for the same Product-Service and Region having same Latest Vote.')){
                           System.debug('**Inside Latest Vote');
                           latestVoteRecord = TRUE;
                        }
                        else if(errorObj.getMessage().contains('There already exists a vote  in this Period for the same Product-Service and Region.')){
                           System.debug('***Duplicate Record');
                           duplicateRecord = TRUE; 
                        }*/
                        
                    }
                    
                    /*if(duplicateRecord == TRUE){
                        System.debug('***Duplicate Vote Found Name :'+accountVoteRankList.get(i).Name);
                        
                        List<Account_Vote_Ranks__c> duplicateList = errorRecordsMap.get('DUPLICATE') != null ? errorRecordsMap.get('DUPLICATE') : new List<Account_Vote_Ranks__c>();
                        duplicateList.add(accountVoteRankList.get(i));
                        errorRecordsMap.put('DUPLICATE', duplicateList);
                    }
                    else if(latestVoteRecord == TRUE){
                        System.debug('***Latest Vote Found Name :'+accountVoteRankList.get(i).Name);
                        
                        List<Account_Vote_Ranks__c> latestVoteList = errorRecordsMap.get('LATESTVOTE') != null ? errorRecordsMap.get('LATESTVOTE') : new List<Account_Vote_Ranks__c>();
                        latestVoteList.add(accountVoteRankList.get(i));
                        errorRecordsMap.put('LATESTVOTE', latestVoteList);
                    }
                    else {
                    	errorUpdateList.add(accountVoteRankList.get(i));
                    }*/
                }
            }
        }
        
        //return errorRecordsMap;
    }
    
    global void deleteAccountVoteRank(List<Account_Vote_Ranks__c> accountVoteRankList){
        Database.DeleteResult[] deleteResultList = Database.delete(accountVoteRankList, false);
        
        for(Integer i=0; i<deleteResultList.size(); i++){            
            Database.DeleteResult deleteResult = deleteResultList.get(i);
            
            if(!deleteResult.isSuccess()){ 
                for(Database.Error errorObj : deleteResult.getErrors()){
                    System.debug('Account Vote Rank Id :' + accountVoteRankList.get(i).Id + ' Error Status Code for Vote Rank Delete:'+errorObj.getStatusCode() +' Message:'+errorObj.getMessage());
                }
                
                errorDeleteList.add(accountVoteRankList.get(i));
            }
       }
    }
    
    global List<Account_Vote_Ranks__c> processLatestVoteRank(List<Account_Vote_Ranks__c> accountVoteRankList){
        for(Account_Vote_Ranks__c voteRankObj : accountVoteRankList){
            voteRankObj.Latest_Vote__c = 'No';
        }

        return accountVoteRankList;
    }
        
    global String getEmailBody(AsyncApexJob apexJob){
        String emailBody = null;
        String apexJobId = apexJob.Id;
        emailBody = '<p> The Batch Apex Job (' + apexJobId.substring(0,15) + ') processed '
                    + apexJob.TotalJobItems + ' batche(s) with ' + apexJob.NumberOfErrors + ' failure(s). </p>';
        
        /* Update Record Failure */
        if(errorUpdateList.size() > 0){
        	emailBody = emailBody + '<p> Failed for below Update Account Vote Rank records : </p><br>';
            emailBody = emailBody + '<br>'
                + '<table border=1 cellspacing=1 cellpadding=1>';
            emailBody = emailBody + '<tr>';
            emailBody = emailBody + '<td>Account Vote Rank Details</td>';
            emailBody = emailBody + '</tr>';
            
            for(Account_Vote_Ranks__c voteRankObj : errorUpdateList){
                String voteRankDetails = 'Id : ' + voteRankObj.Id + ' Name : ' + voteRankObj.Name;
                emailBody = emailBody + '<tr>';
                
                emailBody = emailBody + '<td>';
                emailBody = emailBody + voteRankDetails ;
                emailBody = emailBody + '</td>';
                
                emailBody = emailBody + '</tr>';
            }
            emailBody = emailBody + '</table> <br>';
        }
        
        /* Delete Record Failure */
        if(errorDeleteList.size() > 0){
        	emailBody = emailBody + '<p> Failed for below Delete  Account Vote Rank records : </p><br>';
            emailBody = emailBody + '<br>'
                + '<table border=1 cellspacing=1 cellpadding=1>';
            emailBody = emailBody + '<tr>';
            emailBody = emailBody + '<td>Account Vote Rank Details</td>';
            emailBody = emailBody + '</tr>';
            
            for(Account_Vote_Ranks__c voteRankObj : errorDeleteList){
                String voteRankDetails = 'Id : ' + voteRankObj.Id + ' Name : ' + voteRankObj.Name;
                emailBody = emailBody + '<tr>';
                
                emailBody = emailBody + '<td>';
                emailBody = emailBody + voteRankDetails ;
                emailBody = emailBody + '</td>';
                
                emailBody = emailBody + '</tr>';
            }
            emailBody = emailBody + '</table> <br>';
        }
        
        return emailBody;
    }
}