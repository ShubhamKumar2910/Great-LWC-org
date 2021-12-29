/*
 * This batch job will call BulkMovementContactQueueable
 */
public class RMMergeContactEntityBatch implements Database.Batchable<sObject>,Database.Stateful {
    public RMMergeContactEntityBatch() {

    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id FROM Campaign WHERE Status IN (\'Submitted\') AND RecordType.DeveloperName = \'Bulk_Movement_Contact\' AND Name LIKE \'QuantexaBulkMovementContact%\' ' ;
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext batchableContext, List<sObject> scope){
        List<Campaign> campaignList = (List<Campaign>) scope;

        if(campaignList != null && !campaignList.isEmpty()){
            for(Campaign campaignObj : campaignList){
                BulkMovementContactQueueable bulkMovmentContactJob = new BulkMovementContactQueueable(campaignObj.Id);
                String jobId = System.enqueueJob(bulkMovmentContactJob);
                
                
            }
        }
    }

    public void finish(Database.BatchableContext batchableContext){
        //Handling Errors
        String toEmailAddress = null;
        String emailBody = null;
        String subject = 'RMMergeContactEntityBatch Job Status';
        
        AsyncApexJob apexJob = [SELECT Id, JobType, Status, JobItemsProcessed, TotalJobItems, 
                               NumberOfErrors, CompletedDate, MethodName, ExtendedStatus
                               FROM AsyncApexJob 
                               WHERE JobType = 'BatchApex' AND Id = :batchableContext.getJobId()
                               ];
        if(apexJob != null && apexJob.NumberOfErrors > 0 ){
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

    public String getEmailBody(AsyncApexJob apexJob){
        String emailBody = null;
        String apexJobId = apexJob.Id;
        emailBody = '<p> The Batch Apex Job (' + apexJobId.substring(0,15) + ') processed '
                    + apexJob.TotalJobItems + ' batche(s) with ' + apexJob.NumberOfErrors + ' failure(s). </p>';
        
        return emailBody;
    }


}