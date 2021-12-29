public class RMMergeNFPEChampionEntityBatch implements Database.Batchable<sObject>,Database.Stateful {
    List<Account> accountErrorUpdateList = null;
    List<Map<Sales_Champion__c,String>> salesChampionErrorUpdateList = null;
    
    public RMMergeNFPEChampionEntityBatch() {
        accountErrorUpdateList = new List<Account>();
        salesChampionErrorUpdateList = new List<Map<Sales_Champion__c,String>>();
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        //Select the criteria for RM Merge (Move and [Merge and Move] not considered)
        String query = 'SELECT RG_ACTION__c, RM_ACTION__c, OLD_RG__c, NEW_RG__c, OLD_RM__c, NEW_RM__c, OLD_RG_Account__c, NEW_RG_Account__c, OLD_RM_Account__c, OLD_RM_Account__r.NFPE__c, NEW_RM_Account__c, NEW_RM_Account__r.NFPE__c, New_RM_Account__r.RDM_Org_ID__c FROM Client_Remediation__c WHERE RM_ACTION__c IN (\'MERGE\') AND OLD_RM_Account__r.NFPE__c = true' ;
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext batchableContext, List<sObject> scope){
        List<Client_Remediation__c> clientRemediationList = (List<Client_Remediation__c>) scope;
        List<Account> destinationAccountNFPEList = new List<Account>();
        List<Id> nonNFPEAccountIdList = new List<Id>();
        Set<Id> sourceAccountIdNFPESet = new Set<Id>();
        Map<Id,Id> sourceDestinationAccountIdMap = new Map<Id,Id>();
        List<Sales_Champion__c> updatedSalesChampionList = new List<Sales_Champion__c>();

        if(clientRemediationList != null && !clientRemediationList.isEmpty()){
            
            //Find Destination RMs that are not NFPE. Check NFPE__c flag as true
            for(Client_Remediation__c crObj : clientRemediationList){
                if(String.isNotEmpty(crObj.OLD_RM__c) && String.isNotEmpty(crObj.NEW_RM__c)){
                   
                   sourceAccountIdNFPESet.add(crObj.OLD_RM_Account__c);
                   sourceDestinationAccountIdMap.put(crObj.OLD_RM_Account__c, crObj.NEW_RM_Account__c);
                   
                   if(crObj.NEW_RM_Account__r.NFPE__c == false){
                        nonNFPEAccountIdList.add(crObj.NEW_RM_Account__c);
                   }
                }
            }

            //Set NFPE Flag as true
            if(nonNFPEAccountIdList != null && !nonNFPEAccountIdList.isEmpty()){
                for(Id accountId : nonNFPEAccountIdList){
                    Account accountObj = new Account();
                    accountObj.Id = accountId;
                    accountObj.NFPE__c = true;
                    destinationAccountNFPEList.add(accountObj);
                }

                accountErrorUpdateList.addAll(updateAccountRecords(destinationAccountNFPEList));
            }

            //Fetch NFPE Champion Data
            List<Sales_Champion__c> salesChampionNFPEList = 
                [SELECT Id, Account__c, Account__r.RDM_Org_ID__c, Account__r.Name, 
                Sales_Champion__c, Sales_Champion__r.Login_Id__c, Sales_Champion__r.Name, 
                Champion_Type__c, Product__c, RecordType.DeveloperName 
                FROM Sales_Champion__c 
                WHERE RecordType.DeveloperName = 'NFPE_Champion' AND Account__c IN :sourceAccountIdNFPESet];

            
            /* 
             * For each NFPE Champion Record in Source RM, we will create the corresponding record in destination RM
             * There are few validations :
             * 1. Can have only one PRC Champion for NFPE Account (For Product : NFPE PRC (EMEA Product))
             * 2. Duplicate NFPE Champion Restricted for same Product and Account
             * 3. We will perform updates one at a time. Even though its wrong to call update inside "for loop" but if we do not this then duplicate rule won't get fired
             * 4. So the job RMMergeNFPEChampionEntityBatch should always run in batch of 1. (Assuming 1 RM won't have greater than 149 Champions)
             * 5. Also we need to capture the errors so that we can send those on mail
             */ 
            if(!Test.isRunningTest()){
                for(Sales_Champion__c salesChampObj : salesChampionNFPEList){
                    if(sourceDestinationAccountIdMap.containsKey(salesChampObj.Account__c)){
                        salesChampObj.Account__c = sourceDestinationAccountIdMap.get(salesChampObj.Account__c);
                        
                        updatedSalesChampionList.add(salesChampObj);
                    }
                }
            }

            if(updatedSalesChampionList != null && !updatedSalesChampionList.isEmpty()){
               salesChampionErrorUpdateList.addAll(updateSalesChampionRecords(updatedSalesChampionList));
            }
        }


    }

    public void finish(Database.BatchableContext batchableContext){
        //Handling Errors
        String toEmailAddress = null;
        String emailBody = null;
        String subject = 'RMMergeNFPEChampionEntityBatch Job Status';
        
        AsyncApexJob apexJob = [SELECT Id, JobType, Status, JobItemsProcessed, TotalJobItems, 
                               NumberOfErrors, CompletedDate, MethodName, ExtendedStatus
                               FROM AsyncApexJob 
                               WHERE JobType = 'BatchApex' AND Id = :batchableContext.getJobId()
                               ];
                               
        if(apexJob != null && (apexJob.NumberOfErrors > 0 || accountErrorUpdateList.size() > 0  || salesChampionErrorUpdateList.size() > 0)){
            //If Apex Batch fails then email will be sent out 
        	NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
        	toEmailAddress = nomuraSettings.To_Email_Addr_NomuraEmpReplacement_Batch__c;
            
            if(String.isNotEmpty(toEmailAddress)){
            	String[] toEmailArray = toEmailAddress.split(';');
                emailBody = getEmailBody(apexJob);
                Boolean isSuccess = MailUtility.sendMail(toEmailArray, subject, emailBody);
                if(!isSuccess){
                    System.debug('Error Occurred while sending mail');
                }
            }
        }
    }

    public List<Account> updateAccountRecords(List<Account> accountList){
        List<Account> accountErrorUpdateList = new List<Account>();

        if(accountList != null && !accountList.isEmpty()){
            Database.SaveResult[] saveResultList = Database.update(accountList, false);
            
            for(Integer i=0; i<saveResultList.size(); i++){            
                Database.SaveResult resultObj = saveResultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        System.debug('Error Status Code for Account Update :'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                    }
                    
                    Account accountObj = accountList.get(i);
                    accountErrorUpdateList.add(accountObj);
                }
            }
        }

        return accountErrorUpdateList;
    }

    public List<Map<Sales_Champion__c,String>> updateSalesChampionRecords(List<Sales_Champion__c> salesChampionList){
        List<Map<Sales_Champion__c,String>> salesChampionErrorList = new List<Map<Sales_Champion__c,String>>();
        Map<Sales_Champion__c,String> salesChampionErrorMap = new Map<Sales_Champion__c,String>();
        
        for(Sales_Champion__c salesChampionObj : salesChampionList){
           
            //Calling one at a time
            Database.SaveResult resultObj = Database.update(salesChampionObj, false);
    
            String errorMessage = '';
            if(!resultObj.isSuccess()){ 
                for(Database.Error errorObj : resultObj.getErrors()){
                    errorMessage = errorMessage + ' Error Status Code for Sales Champion Update :'+errorObj.getStatusCode() +' Message :'+errorObj.getMessage();
                }
                salesChampionErrorMap.put(salesChampionObj, errorMessage);
            }
            
        }

        if(salesChampionErrorMap != null && !salesChampionErrorMap.isEmpty()){
           salesChampionErrorList.add(salesChampionErrorMap); 
        }

        return salesChampionErrorList;
    }

    public String getEmailBody(AsyncApexJob apexJob){
        String emailBody = null;
        String apexJobId = apexJob.Id;
        emailBody = '<p> The Batch Apex Job (' + apexJobId.substring(0,15) + ') processed '
                    + apexJob.TotalJobItems + ' batche(s) with ' + apexJob.NumberOfErrors + ' failure(s). </p>';

        /* Update Account Record Failure */
        if(accountErrorUpdateList.size() > 0){
        	emailBody = emailBody + '<p> Failed for below update Account records (NFPE__c field) : </p><br><br>';
            emailBody = emailBody + '<table border=1 cellspacing=1 cellpadding=1>';
            //Insert Table Header
            emailBody = emailBody + '<tr><td>Account Details</td></tr>';
            
            //Insert Table Body
            for(Account accountObj : accountErrorUpdateList){
                emailBody = emailBody + '<tr><td>';
                emailBody = emailBody + (accountObj.RDM_Org_ID__c) ;
                emailBody = emailBody + '</td></tr>';
            }
            
            emailBody = emailBody + '</table> <br>';
        }

        /* Update NFPE Champion Record Failure */
        if(salesChampionErrorUpdateList.size() > 0){
        	emailBody = emailBody + '<p> Failed for below Update NFPE Champion records : </p><br><br>';
            emailBody = emailBody + '<table border=1 cellspacing=1 cellpadding=1>';
            //Insert Table Header
            emailBody = emailBody + '<tr>';
            emailBody = emailBody + '<td>Account</td>';
            emailBody = emailBody + '<td>Sales Champion</td>';
            emailBody = emailBody + '<td>Champion Type</td>';
            emailBody = emailBody + '<td>Product</td>';
            emailBody = emailBody + '<td>Error</td>';
            emailBody = emailBody + '</tr>';
            
            //Insert Table Body
            for(Map<Sales_Champion__c,String> salesChampionErrorMap : salesChampionErrorUpdateList){
                for(Sales_Champion__c salesChampionObj : salesChampionErrorMap.keySet()){
                    emailBody = emailBody + '<tr>';

                    emailBody = emailBody + '<td>';
                    emailBody = emailBody + (salesChampionObj.Account__r.RDM_Org_ID__c) ;
                    emailBody = emailBody + '</td>';

                    emailBody = emailBody + '<td>';
                    emailBody = emailBody + (salesChampionObj.Sales_Champion__r.Login_Id__c) ;
                    emailBody = emailBody + '</td>';

                    emailBody = emailBody + '<td>';
                    emailBody = emailBody + (salesChampionObj.Champion_Type__c) ;
                    emailBody = emailBody + '</td>';

                    emailBody = emailBody + '<td>';
                    emailBody = emailBody + (salesChampionObj.Product__c) ;
                    emailBody = emailBody + '</td>';

                     emailBody = emailBody + '<td>';
                    emailBody = emailBody + (salesChampionErrorMap.get(salesChampionObj)) ;
                    emailBody = emailBody + '</td>';

                    emailBody = emailBody + '</tr>';
                }               
               
            }
            
            emailBody = emailBody + '</table> <br>';
        }
        
        return emailBody;
    }

    

    
}