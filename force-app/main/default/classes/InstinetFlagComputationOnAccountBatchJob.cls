public class InstinetFlagComputationOnAccountBatchJob implements Database.Batchable<sObject>,Database.Stateful {
    public List<Account> errorUpdateList;
    List<String> newAccountRGWithInstinetFlagList;

    public InstinetFlagComputationOnAccountBatchJob() {
        errorUpdateList = new List<Account>();
        newAccountRGWithInstinetFlagList = new List<String>();
    }

    public Database.QueryLocator start(Database.BatchableContext batchableContext){
        //Not Considering only Active Accounts
        //As there is one job that takes care of closing coverages when account gets deactivated
        String query = 'SELECT Id, RDM_Org_ID__C, Name, Instinet_Coverage__c, Active__c, Closing_Date__c FROM Account WHERE RecordType.DeveloperName = \'RG_Account\'';
        return Database.getQueryLocator(query);
    }

    //Scope size would be 100
    public void execute(Database.BatchableContext batchableContext, List<sObject> scope){
        List<Account> accountList = (List<Account>)scope;
        Map<Id,Account> accountMap = new Map<Id,Account>();
        List<AggregateResult> accountRGActiveCoverageList = new List<AggregateResult>();
        Set<Id> accountRGIdForActiveInstinetCoverageSet = new Set<Id>();
        List<Account> accountUpdateList = new List<Account>();
        


        for(Account accountObj : accountList){
            accountMap.put(accountObj.Id, accountObj);
        }

        if(accountMap != null && !accountMap.isEmpty()){
            //Check Whether any instinet salesperson coverage is present for these RG accounts
            accountRGActiveCoverageList = [SELECT Account__r.ParentId RGID FROM Coverage_Team_Member__c 
                                            WHERE Sales_Team_for_Coverage__r.Company__c = 'I' AND 
                                            Sales_Team_for_Coverage__r.Active__c = TRUE AND 
                                            End_Date__c = null AND 
                                            RecordType.DeveloperName = 'Active_Coverage' AND
                                            Account__r.ParentId IN :accountMap.keySet()
                                            GROUP BY Account__r.ParentId];

            for(AggregateResult resultObj : accountRGActiveCoverageList){
               accountRGIdForActiveInstinetCoverageSet.add(String.valueOf(resultObj.get('RGID')));
            }

            for(Id accountRGId : accountMap.keySet()){
                Boolean recordToBeUpdated = false;
                Account retrievedAccountObj = accountMap.get(accountRGId);
                Boolean instinetCoverageFlag = retrievedAccountObj.Instinet_Coverage__c;

                //Account To Be Updated
                Account accountObj = new Account();
                accountObj.Id = accountRGId;

                //Active Instinet Coverage is present for this account and Instinet_Coverage__c is TRUE
                if(accountRGIdForActiveInstinetCoverageSet.contains(accountRGId) && instinetCoverageFlag == true){
                    recordToBeUpdated = false;
                }
                 //Active Instinet Coverage is present for this account and before it was not marked as true
                else if(accountRGIdForActiveInstinetCoverageSet.contains(accountRGId) && instinetCoverageFlag == false){
                    recordToBeUpdated = true;
                    
                    accountObj.Instinet_Coverage__c = true;
                    
                    //Since it was not marked as true previously so we need to put these account details in configuration so that historic contact data can be sent out to Instinet
                    newAccountRGWithInstinetFlagList.add(retrievedAccountObj.RDM_Org_ID__C);
                }
                //Active Instinet Coverage is not present for this account and before it was marked as true
                else if(!accountRGIdForActiveInstinetCoverageSet.contains(accountRGId) && instinetCoverageFlag == true){
                    recordToBeUpdated = true;

                     accountObj.Instinet_Coverage__c = false;
                }

                if(recordToBeUpdated){
                    accountUpdateList.add(accountObj);
                }
            }

            //Update Account Records
            if(accountUpdateList != null && !accountUpdateList.isEmpty()){
                errorUpdateList.addAll(updateAccountRecords(accountUpdateList));
            }

            

        }
    }

    public void finish(Database.BatchableContext batchableContext){
        //Update Configuration Item

        //Blank Out Values
        CommonTools.updateParameterValueInConfiguration('ExporterJob_INSTINET_Contact','NewRGAccount', '');

        //Update if new records found
        if(newAccountRGWithInstinetFlagList != null && !newAccountRGWithInstinetFlagList.isEmpty()){
            String accountRGStr = String.join(newAccountRGWithInstinetFlagList, ',');
            //It will perform update in Configuration parameter
            if(String.isNotEmpty(accountRGStr)){
                CommonTools.updateParameterValueInConfiguration('ExporterJob_INSTINET_Contact','NewRGAccount', accountRGStr);
            }
        }
        
        
        //Handling Errors
        String toEmailAddress = null;
        String emailBody = null;
        String subject = 'SF - Instinet Flag Computation on Account Batch Job Status';
        
        AsyncApexJob apexJob = [SELECT Id, JobType, Status, JobItemsProcessed, TotalJobItems, 
                               NumberOfErrors, CompletedDate, MethodName, ExtendedStatus
                               FROM AsyncApexJob 
                               WHERE JobType = 'BatchApex' AND Id = :batchableContext.getJobId()
                               ];
        if(apexJob != null && (apexJob.NumberOfErrors > 0 || errorUpdateList.size() > 0 )){
            /* If Apex Batch fails then email will be sent out */
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

    public static List<Account> updateAccountRecords(List<Account> accountList){
        List<Account> errorUpdateList = new List<Account>();
        if(accountList != null && !accountList.isEmpty()){
            
            List<Database.SaveResult> resultList = Database.update(accountList, false); 
            for(Integer i=0; i<resultList.size(); i++){            
                Database.SaveResult resultObj = resultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        
                        if(String.isNotEmpty(errorObj.getMessage())){
                            errorUpdateList.add(accountList.get(i));
                        }
                    }
                }
            }
        }

        return errorUpdateList;
    }

    public String getEmailBody(AsyncApexJob apexJob){
        String emailBody = null;
        String apexJobId = apexJob.Id;
        emailBody = '<p> The Batch Apex Job (' + apexJobId.substring(0,15) + ') processed '
                    + apexJob.TotalJobItems + ' batche(s) with ' + apexJob.NumberOfErrors + ' failure(s). </p>';
        
        /* Update Record Failure */
        if(errorUpdateList.size() > 0){
        	emailBody = emailBody + '<p> Failed for below Update Account records : </p><br><br>';
            emailBody = emailBody + '<table border=1 cellspacing=1 cellpadding=1>';
            //Insert Table Header
            emailBody = emailBody + '<tr><td>Account Details</td></tr>';
            
            //Insert Table Body
            for(Account accountObj : errorUpdateList){
                emailBody = emailBody + '<tr><td>';
                emailBody = emailBody + (accountObj.Id) ;
                emailBody = emailBody + '</td></tr>';
            }
            
            emailBody = emailBody + '</table> <br>';
        }
        
        return emailBody;
    }



}