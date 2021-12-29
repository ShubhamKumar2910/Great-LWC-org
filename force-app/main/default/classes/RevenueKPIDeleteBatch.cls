public class RevenueKPIDeleteBatch implements Database.Batchable<sObject>,Database.Stateful {
    List<Revenue_KPI__c> revenueKPIErrorDeleteList = null;

    public RevenueKPIDeleteBatch() {
        revenueKPIErrorDeleteList = new List<Revenue_KPI__c>();
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        //Select the criteria for Revenue_KPI__c deletion
        String query = 'SELECT Id FROM Revenue_KPI__c' ;
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext batchableContext, List<sObject> scope){
        List<Revenue_KPI__c> revenueKPIList = (List<Revenue_KPI__c>) scope;
        
        if(revenueKPIList != null && !revenueKPIList.isEmpty()){
            revenueKPIErrorDeleteList.addAll(deleteRevenueKPIRecords(revenueKPIList));
        }
    }

    public void finish(Database.BatchableContext batchableContext){
        //Handling Errors
        String toEmailAddress = null;
        String emailBody = null;
        String subject = 'RevenueKPIDeleteBatch Job Status';
        
        AsyncApexJob apexJob = [SELECT Id, JobType, Status, JobItemsProcessed, TotalJobItems, 
                               NumberOfErrors, CompletedDate, MethodName, ExtendedStatus
                               FROM AsyncApexJob 
                               WHERE JobType = 'BatchApex' AND Id = :batchableContext.getJobId()
                               ];
                               
        if(apexJob != null && (apexJob.NumberOfErrors > 0 || revenueKPIErrorDeleteList.size() > 0)){
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

    public List<Revenue_KPI__c> deleteRevenueKPIRecords(List<Revenue_KPI__c> revenueKPIList){
        List<Revenue_KPI__c> revenueKPIErrorRecordDeleteList = new List<Revenue_KPI__c>();

        if(revenueKPIList != null && !revenueKPIList.isEmpty()){
            Database.DeleteResult[] deleteResultList = Database.delete(revenueKPIList, false);
            
            for(Integer i=0; i<deleteResultList.size(); i++){            
                Database.DeleteResult resultObj = deleteResultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        System.debug('Error Status Code for Revenue_KPI__c Delete :'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                    }
                    
                    Revenue_KPI__c revenueKPIObj = revenueKPIList.get(i);
                    revenueKPIErrorRecordDeleteList.add(revenueKPIObj);
                }
            }
        }

        return revenueKPIErrorRecordDeleteList;
    }

    public String getEmailBody(AsyncApexJob apexJob){
        String emailBody = null;
        String apexJobId = apexJob.Id;
        emailBody = 'The Batch Apex Job (' + apexJobId.substring(0,15) + ') processed '
                    + apexJob.TotalJobItems + ' batche(s) with ' + (revenueKPIErrorDeleteList.size()) + ' record failure(s).';
                
        return emailBody;
    }
}