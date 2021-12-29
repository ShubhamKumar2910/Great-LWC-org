/*
* This Job deletes Instinet Champion records in Sales_Champion__c Object for INSTINET EMPLOYEES Contact that is Inactive
*/

global class NomuraContactDependentDataBatchJob implements Database.Batchable<SObject>, Database.Stateful,Database.AllowsCallouts{

    global List<Sales_Champion__c> errorDeleteList;
    global AsyncApexJob apexJobDetails;

    public NomuraContactDependentDataBatchJob () {
        errorDeleteList = new List<Sales_Champion__c>();
        apexJobDetails = new AsyncApexJob();
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id FROM Sales_Champion__c WHERE Instinet_Champion__c IN (SELECT Id FROM Contact'+
        ' WHERE Account.RDM_Org_Id__c = \'IN12345\' AND Active__c = False)';
        System.debug('Query: '+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Sales_Champion__c> salesChampionIdsList){
        deleteInstinetChampion(bc, salesChampionIdsList);        
    }

    global void finish(Database.BatchableContext bc){
        String batchName = null;
        String emailBody = null;
        String subject = '';
        
        AsyncApexJob apexJob = apexJobDetails != null ? apexJobDetails : getApexJobDetails(bc);
        if(apexJob != null && apexJob.NumberOfErrors > 0 ){
            /* If Apex Batch fails then email will be sent out */
            subject = 'SF - Nomura Employee Contact Dependent Data Batch - Failed';
            emailBody = getEmailBody(apexJob);
            batchName = 'NomuraContactDependentDataBatchJob';
            CommonTools.emailLog(subject, batchName, emailBody, null, null);
        }
    }

    global void deleteInstinetChampion(Database.BatchableContext bc, List<Sales_Champion__c> salesChampionIdsList){
        if(salesChampionIdsList != null && !salesChampionIdsList.isEmpty()){
            if(Test.isRunningTest())
                Database.delete(salesChampionIdsList, false);
                
            List<Database.DeleteResult> resultList = Database.delete(salesChampionIdsList, false);
            for(Integer i=0; i<resultList.size(); i++){
                Database.DeleteResult resultObj = resultList.get(i);
                if(!resultObj.isSuccess()){
                    for(Database.Error errorObj : resultObj.getErrors()){
                        if(String.isNotEmpty(errorObj.getMessage())){
                            errorDeleteList.add(salesChampionIdsList.get(i));
                        }
                    }
                }
            }

            /* Send email if there is failure in delete operation / Delete opertaion for any record did not succeed */
            if(errorDeleteList != null && !errorDeleteList.isEmpty()){
                String batchName = null;
                String emailBody = null;
                String subject = '';

                subject = 'SF - Nomura Employee Contact Dependent Data Batch Job - Instinet Champion Not Deleted';
                emailBody = getEmailBodyForDeleteFailure(errorDeleteList, getApexJobDetails(bc));
                batchName = 'NomuraContactDependentDataBatchJob';
                CommonTools.emailLog(subject, batchName, emailBody, null, null);
            }
        }
    }

    global AsyncApexJob getApexJobDetails(Database.BatchableContext bc){
        apexJobDetails =   [SELECT Id, JobType, Status, JobItemsProcessed, TotalJobItems, 
                    NumberOfErrors, CompletedDate, MethodName, ExtendedStatus
                    FROM AsyncApexJob 
                    WHERE JobType = 'BatchApex' AND Id = :bc.getJobId()
                    ];
        return apexJobDetails;
    }

    global String getEmailBody(AsyncApexJob apexJob){
        String emailBody = null;
        String apexJobId = apexJob.Id;
        emailBody = 'The Batch Apex Job (' + apexJobId.substring(0,15) + ') processed '
                    + apexJob.TotalJobItems + ' batche(s) with ' + apexJob.NumberOfErrors + ' failure(s).';
                
        return emailBody;
    }

    global String getEmailBodyForDeleteFailure(List<Sales_Champion__c> errorDeleteList,AsyncApexJob apexJob){
        String emailBody = null;
        String idList = null;
        String apexJobId = apexJob.Id;

        emailBody = 'Delete operation for Batch Apex Job (' + apexJobId.substring(0,15) + ') failed.\n'+
                    'Failed Record Id:\n';

        for(Sales_Champion__c salesChamption : errorDeleteList){
            idList = String.isBlank(idList) ? '\''+salesChamption.Id+'\'' : idList + '\''+salesChamption.Id+'\'';
            idList = idList + '\n';
        }
        
        emailBody = emailBody + idList;
        return emailBody;
    }
}