global class LegalAgreementDeleteBatch implements Database.Batchable<SObject>{

    global String currentTimeStamp = '';
    global String currentDate = '';
    global String lastUpdatedDate = '';
    global String lastUpdatedTimeStamp = '';
    global List<Legal_Agreement__c> blankList = null;

    global final String CONFIG_NAME = 'Importerjob_Legal_Agreement__c';
    global final String PARAM_NAME = 'LastUpdatedTimeStamp';

    global LegalAgreementDeleteBatch (){
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        system.debug('***Inside Start()***');
        currentTimeStamp = datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        currentDate = datetime.now().formatGMT('yyyy-MM-dd');

        lastUpdatedTimeStamp = CommonTools.getParameterValueFromConfiguration(CONFIG_NAME,PARAM_NAME,true);
        if(lastUpdatedTimeStamp!= '' && lastUpdatedTimeStamp!= null) {
                lastUpdatedDate = lastUpdatedTimeStamp.split('T')[0];

                if(currentDate.equals(lastUpdatedDate)) {
                        String currentDateTimeStamp = currentDate + 'T00:00:00.000+0000';

                        String query = 'SELECT id FROM Legal_Agreement__c WHERE LastModifiedDate < ' + currentDateTimeStamp;
                        system.debug('***Query execution to fetch delete records Ids*** : ' + query);
                        return Database.getQueryLocator(query);
                }
                system.debug('***No Records to delete, returning null***');
        }
        String name = 'nofund';
        String query = 'SELECT id FROM Legal_Agreement__c WHERE fund_name__c = \'' + name + '\' limit 0';
        return Database.getQueryLocator(query);	
    }

    global void execute(Database.BatchableContext bc, List<Legal_Agreement__c> deleteRecordIds){
        system.debug('***In execute()***');
        if(deleteRecordIds!= null && deleteRecordIds.size() > 0){
                List<Database.DeleteResult> resultList = Database.delete(deleteRecordIds, false);
                for(Integer i=0; i<resultList.size(); i++){            
                        Database.DeleteResult resultObj = resultList.get(i);
                        if(!resultObj.isSuccess()){
                            for(Database.Error errorObj : resultObj.getErrors()){
                                if(String.isNotEmpty(errorObj.getMessage())){
                                    system.debug(LoggingLevel.INFO, '---Failed to delete record--- : ' + errorObj.getMessage());
                                }
                            }
                       }
                 }            
        }
    }

    global void finish(Database.BatchableContext bc){
        system.debug('***In finish()***');
        AsyncApexJob apexJob = [SELECT Id, JobType, Status, JobItemsProcessed, TotalJobItems, 
                               NumberOfErrors, CompletedDate, MethodName, ExtendedStatus
                               FROM AsyncApexJob 
                               WHERE JobType = 'BatchApex' AND Id = :bc.getJobId()
                               ];

        if(apexJob != null && apexJob.NumberOfErrors > 0 ){
            system.debug('Error while executing LegalAgreementDeleteBatch Job at timestamp: ' + currentTimeStamp);
        }
    }
}