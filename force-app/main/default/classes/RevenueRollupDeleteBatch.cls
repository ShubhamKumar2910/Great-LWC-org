public class RevenueRollupDeleteBatch implements Database.Batchable<sObject>,Database.Stateful {
    List<Revenue_Rollup__c> revenueRollupErrorDeleteList = null;

    public RevenueRollupDeleteBatch() {
        revenueRollupErrorDeleteList = new List<Revenue_Rollup__c>();
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        //Select the criteria for Revenue_Rollup__c deletion
        String query = 'SELECT Id FROM Revenue_Rollup__c' ;
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext batchableContext, List<sObject> scope){
        List<Revenue_Rollup__c> revenueRollupList = (List<Revenue_Rollup__c>) scope;
        
        if(revenueRollupList != null && !revenueRollupList.isEmpty()){
            revenueRollupErrorDeleteList.addAll(deleteRevenueRollupRecords(revenueRollupList));
        }
    }

    public void finish(Database.BatchableContext batchableContext){
        //Handling Errors
        String toEmailAddress = null;
        String emailBody = null;
        String subject = 'RevenueRollupDeleteBatch Job Status';
        
        AsyncApexJob apexJob = [SELECT Id, JobType, Status, JobItemsProcessed, TotalJobItems, 
                               NumberOfErrors, CompletedDate, MethodName, ExtendedStatus
                               FROM AsyncApexJob 
                               WHERE JobType = 'BatchApex' AND Id = :batchableContext.getJobId()
                               ];
                               
        if(apexJob != null && (apexJob.NumberOfErrors > 0 || revenueRollupErrorDeleteList.size() > 0)){
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

    public List<Revenue_Rollup__c> deleteRevenueRollupRecords(List<Revenue_Rollup__c> revenueRollupList){
        List<Revenue_Rollup__c> revenueRollupErrorRecordDeleteList = new List<Revenue_Rollup__c>();

        if(revenueRollupList != null && !revenueRollupList.isEmpty()){
            Database.DeleteResult[] deleteResultList = Database.delete(revenueRollupList, false);
            
            for(Integer i=0; i<deleteResultList.size(); i++){            
                Database.DeleteResult resultObj = deleteResultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        System.debug('Error Status Code for Revenue_Rollup__c Delete :'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                    }
                    
                    Revenue_Rollup__c revenueRollUpObj = revenueRollupList.get(i);
                    revenueRollupErrorRecordDeleteList.add(revenueRollUpObj);
                }
            }
        }

        return revenueRollupErrorRecordDeleteList;
    }

    public String getEmailBody(AsyncApexJob apexJob){
        String emailBody = null;
        String apexJobId = apexJob.Id;
        emailBody = 'The Batch Apex Job (' + apexJobId.substring(0,15) + ') processed '
                    + apexJob.TotalJobItems + ' batche(s) with ' + (revenueRollupErrorDeleteList.size()) + ' record failure(s).';
                
        return emailBody;
    }
}