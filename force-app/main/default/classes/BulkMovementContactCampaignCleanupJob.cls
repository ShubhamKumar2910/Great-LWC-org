public class BulkMovementContactCampaignCleanupJob implements Database.Batchable<sObject>,Database.Stateful {
    public List<Campaign> errorDeleteList;
    public Set<String> statusSet;
    public String recordTypeDeveloperName;
    public Integer lastNDays; 
    
    public BulkMovementContactCampaignCleanupJob(Set<String> statusSet, String recordTypeDeveloperName, Integer lastNDays) {
        errorDeleteList = new List<Campaign>();
        this.statusSet = statusSet;
        this.recordTypeDeveloperName = recordTypeDeveloperName;
        this.lastNDays = lastNDays;
    }

    public Database.QueryLocator start(Database.BatchableContext batchableContext){
        String query = null;
        
        if(String.isNotEmpty(recordTypeDeveloperName)){
            query = 'SELECT Id, Name, RecordTypeId, RecordType.Name, Status '
                + 'FROM Campaign '
                + 'WHERE RecordType.DeveloperName = \'' + recordTypeDeveloperName + '\' '
                + 'AND CreatedDate < LAST_N_DAYS:'
                + ((lastNDays != null && lastNDays != 0) ? String.valueOf(lastNDays) : '180');

            if(statusSet != null && !statusSet.isEmpty()) {
                String statusCriteria = CommonTools.formCommaSeparatedStringOfString(statusSet);
                query = query + ' AND Status IN ' + statusCriteria;
            }
        }

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext batchableContext, List<sObject> scope){
        List<Campaign> campaignList = (List<Campaign>)scope;

        errorDeleteList.addAll(deleteCampaignRecords(campaignList));
        
    }

    public void finish(Database.BatchableContext batchableContext){
        
        //Send Mail in case of failure
        String toEmailAddress = null;
        String emailBody = null;
        String subject = null;
        
        AsyncApexJob apexJob = [SELECT Id, JobType, Status, JobItemsProcessed, TotalJobItems, 
                               NumberOfErrors, CompletedDate, MethodName, ExtendedStatus
                               FROM AsyncApexJob 
                               WHERE JobType = 'BatchApex' AND Id = :batchableContext.getJobId()
                               ];

        if(apexJob != null && (apexJob.NumberOfErrors > 0 || errorDeleteList.size() > 0)){
            /* If Apex Batch fails then email will be sent out */

            NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
        	toEmailAddress = nomuraSettings.To_Email_Addr_NomuraEmpReplacement_Batch__c;
            
            if(String.isNotEmpty(toEmailAddress)){
            	String[] toEmailArray = toEmailAddress.split(';');
                subject = 'BulkMovementContactCampaignCleanupJob Status';
                emailBody = getEmailBody(apexJob);
                Boolean isSuccess = MailUtility.sendMail(toEmailArray, subject, emailBody);
                if(!isSuccess){
                    System.debug('Error Occurred while sending mail');
                }
            }
        }                               
    }

    public static List<Campaign>  deleteCampaignRecords(List<Campaign> campaignList){
        List<Campaign> errorDeleteList = new List<Campaign>();
        if(campaignList != null && !campaignList.isEmpty()){
            List<Database.DeleteResult> resultList = Database.delete(campaignList, false);
            for(Integer i=0; i<resultList.size(); i++){            
                Database.DeleteResult resultObj = resultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        System.debug('Error Status Code for Campaign Delete:'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                    }
                     errorDeleteList.add(campaignList.get(i));
                }
            }
        }

        return errorDeleteList;
    }

    public String getEmailBody(AsyncApexJob apexJob){
        String emailBody = null;
        String apexJobId = apexJob.Id;
        emailBody = '<p> The Batch Apex Job (' + apexJobId.substring(0,15) + ') processed '
                    + apexJob.TotalJobItems + ' batche(s) with ' + apexJob.NumberOfErrors + ' failure(s). </p>';
        emailBody = emailBody + '<p> Failed for below records : </p><br>';
        
        if(errorDeleteList.size() > 0){
            emailBody = emailBody + '<br>'
                + '<table border=1 cellspacing=1 cellpadding=1>';
            emailBody = emailBody + '<tr>';
            emailBody = emailBody + '<td>Campaign Id</td>';
            emailBody = emailBody + '</tr>';
            
            for(Campaign campaignObj : errorDeleteList){
                    emailBody = emailBody + '<tr>';
                    emailBody = emailBody + '<td>';
                    emailBody = emailBody + campaignObj.Id ;
                    emailBody = emailBody + '</td>';
                    emailBody = emailBody + '</tr>';
            }
            emailBody = emailBody + '</table>';
        }
            
        return emailBody;
    }
}