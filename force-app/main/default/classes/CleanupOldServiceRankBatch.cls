global class CleanupOldServiceRankBatch implements Database.batchable<sObject>, Database.Stateful{
    
    global List<String> errorMessageList = new List<String>();  
    
    global CleanupOldServiceRankBatch() {
    }    
    
    global Database.QueryLocator start (Database.BatchableContext info) {
        return Database.getQueryLocator('Select id from Account_Service_Rank__c where is_stable_version__c = false');
        //return Database.getQueryLocator('Select id from Account_Service_Rank__c');
    }
    
    global void execute (Database.BatchableContext info, List<sObject> oldServiceRanks) {
        Database.DeleteResult[] dr =  Database.delete(oldServiceRanks, true);
        doDeleteFromRecycleBin(dr);
        doLogging(dr);
    }
    
    private void doDeleteFromRecycleBin(Database.DeleteResult[] results) {
        List<Id> itemsToRemoveFromRecycle = new List<Id>();
        for (Database.DeleteResult result: results) {
            if (result.isSuccess()) {
                itemsToRemoveFromRecycle.add(result.getId());
            }
        }
        if (itemsToRemoveFromRecycle.size()>0) {
            System.debug(LoggingLevel.INFO,'Removing old account servicestats from the recycle bin. Number of items to remove: '+ itemsToRemoveFromRecycle.size());
            DataBase.emptyRecycleBin(itemsToRemoveFromRecycle);
        }
    
    }
    
    global void finish (Database.BatchableContext bc) {
        AsyncApexJob apexJob = [SELECT Id, JobType, Status, JobItemsProcessed, TotalJobItems, 
                               NumberOfErrors, CompletedDate, MethodName, ExtendedStatus
                               FROM AsyncApexJob 
                               WHERE JobType = 'BatchApex' AND Id = :bc.getJobId()
                               ];
							   
		System.debug('errorMessageList 1 = ' + errorMessageList); 
        if(apexJob != null && apexJob.NumberOfErrors > 0 ) {
			System.debug('Error = ' + apexJob.ExtendedStatus);
            errorMessageList.add(apexJob.ExtendedStatus);
        }

		System.debug('errorMessageList 2 = ' + errorMessageList); 		
		
        if( errorMessageList.size() > 0){
            String emailBody = getEmailBody(apexJob);
			System.debug('errorMessageList 3 = ' + errorMessageList); 				
			EventServiceStatsUtility.emailErrorLog('FAILURE','CleanupOldServiceRankBatch',emailBody+'\n\nRegards,\nSalesforce Tech');
        }
        else {  
            System.debug('Account service rank is populated successfully !!');
        }        
    }

    private String getEmailBody(AsyncApexJob apexJob){
        String emailBody = null;
        String apexJobId = apexJob.Id;
        emailBody = '<p> The Batch Apex Job (' + apexJobId.substring(0,15) + ') processed '
                    + apexJob.TotalJobItems + ' batche(s) with ' + apexJob.NumberOfErrors + ' failure(s). </p>';
        emailBody = emailBody + '<p> Failed for below records : </p><br>';
        
        for (String errorMessage: errorMessageList) {
             emailBody = emailBody + '<br>' + errorMessage;
        }
		System.debug('ErrorEmailBody = ' + emailBody);
        return emailBody;
    }       
    
    private void doLogging(Database.DeleteResult[] results) {
		System.debug('errorMessageList 4 = ' + errorMessageList); 		
        for (Database.DeleteResult sr : results) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully deleted rank. ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        String errorMessage = 'CleanupOldServiceRankBatch failed . Error status = ' +  err.getStatusCode() +
                            ', Error message = ' + err.getMessage() + ', Error fields = ' + err.getFields();
                        System.debug(errorMessage);                     
                        errorMessageList.add(errorMessage);                     
                    }
                }
            }    
		System.debug('errorMessageList 5 = ' + errorMessageList); 		
    }
    
}
    
//    Database.executeBatch(new PopulateServiceRankBatch(), 2000);