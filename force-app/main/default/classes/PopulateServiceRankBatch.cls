global class PopulateServiceRankBatch implements Database.batchable<sObject>, Database.Stateful{
    
    global Map<Id,Decimal> modelVersionMap = new Map<Id,Decimal>();
    global List<String> errorMessageList = new List<String>();  
    
    global PopulateServiceRankBatch() {
    }
    
    global Database.QueryLocator start (Database.BatchableContext info) {
        return Database.getQueryLocator('select id, name, item_name__c, recordType.name, inprogress_version__c from Account_Service_Model__c where inprogress_version__c != null');
        //return Database.getQueryLocator('select id, name, item_name__c, recordType.name from Account_Service_Model__c where external_id__c=\'Equity Core (value):Total\'');
        //return Database.getQueryLocator('select id, name, item_name__c, recordType.name from Account_Service_Model__c where external_id__c=\'Equity Core (value):Analyst scheduled conf call\'');
    }
    
    global void execute (Database.BatchableContext info, List<sObject> models) {
        Account_Service_Model__c model = (Account_Service_Model__c)models.get(0);
        List<Account_Service_Rank__c> serviceRankList = null;
        if (model.recordType.name.equals('Total')) {
            serviceRankList = queryAndCreateServiceRanks(model);
            sortAndUpdateRankings(serviceRankList );
            insertServiceRankList(serviceRankList); //Rank, points, count inserts should go
        }
        else {
            serviceRankList  = queryServiceRanks(model);
            sortAndUpdateRankings(serviceRankList );
            //Below is required for upsert
            initializePointsAndCountFieldsToCipher(serviceRankList);    
            upsertServiceRankList(serviceRankList); //Only rank update should go
        }   
        modelVersionMap.put(model.Id, model.inprogress_version__c);
     }
     
    private void insertServiceRankList (List<Account_Service_Rank__c> serviceRankList) {
        if (serviceRankList != null && serviceRankList.size() > 0) {
                System.debug('Before insert');
                Database.SaveResult[] results = Database.insert(serviceRankList, true);
                doLogging(results, serviceRankList[0].model__r.external_id__c);
        }
    }    
     
    private void upsertServiceRankList (List<Account_Service_Rank__c> serviceRankList) {
        if (serviceRankList != null && serviceRankList.size() > 0) {
                Schema.SObjectField externalIdField = Account_Service_Rank__c.Fields.external_id__c;
                System.debug('Before update');
                Database.UpsertResult[] results = Database.upsert(serviceRankList, externalIdField , true);
                doLogging(results, serviceRankList[0].model__r.external_id__c );
        }
    }
    
    private void doLogging(Database.UpsertResult[] results, String modelName) {
        for (Database.upsertResult sr : results) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted rank. ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        String errorMessage = 'PopulateServiceRankBatch failed for '+modelName + '. Error status = ' +  err.getStatusCode() +
                            ', Error message = ' + err.getMessage() + ', Error fields = ' + err.getFields();
                        System.debug(errorMessage);                     
                        errorMessageList.add(errorMessage);                     
                    }
                }
            }   
    }    
    
    private void doLogging(Database.SaveResult[] results, String modelName) {
        for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted rank. ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        String errorMessage = 'PopulateServiceRankBatch failed for '+modelName + '. Error status = ' +  err.getStatusCode() +
                            ', Error message = ' + err.getMessage() + ', Error fields = ' + err.getFields();
                        System.debug(errorMessage);                     
                        errorMessageList.add(errorMessage);                     
                    }
                }
            }   
    }       
     
    private void sortAndUpdateRankings(List<Account_Service_Rank__c> serviceRankList) {
        if (serviceRankList != null && serviceRankList.size() > 0) {
            Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Account_Service_Rank__c.fields.getMap(); 
            for (String fieldName : mapFields.keyset()) 
            { 
                if (fieldName.toUpperCase().contains('_POINTS__C')) {
                    sortAndUpdateRankings(serviceRankList, fieldName);
                }
            } 
        }
    }   
    
    private void sortAndUpdateRankings (List<Account_Service_Rank__c> serviceRankList, String fieldToSort) {
        Map<Decimal, Integer> fieldValueRankingMap = getFieldValueRankingMap(serviceRankList, fieldToSort);
        updateRanking(serviceRankList, fieldValueRankingMap,fieldToSort);
    }
    
    private void updateRanking (List<Account_Service_Rank__c> serviceRankList, Map<Decimal, Integer> fieldValueRankingMap, String fieldToSort) {
        String fieldToUpdate = fieldToSort.replace('points','Rank');
        System.debug(fieldValueRankingMap);
        for (Account_Service_Rank__c serviceRank: serviceRankList) {
            Decimal fieldValue = (Decimal)serviceRank.get(fieldToSort);
            Decimal fieldRank = fieldValueRankingMap.get(fieldValue );
            System.debug (' fieldToSort = ' + fieldToSort + ' fieldToUpdate = ' + fieldToUpdate + ' fieldValue = ' + fieldValue + ' fieldRank = ' + fieldRank );
            if (fieldValue != null && fieldValue > 0) {
                serviceRank.put(fieldToUpdate, fieldRank);
            }   
        }
    }
    
 /*   private Map<Decimal, Integer> getFieldValueRankingMap(List<Account_Service_Rank__c> serviceRankList, String fieldToSort) {
        Map<Decimal, Integer> fieldValueRankingMap = new Map<Decimal, Integer>();
        List<Decimal> fieldValues = new List<Decimal>();
        for (Account_Service_Rank__c serviceRank: serviceRankList) {
            Decimal fieldValue = (Decimal)serviceRank.get(fieldToSort);
            fieldValues.add((-1 * fieldValue )); // For descending ordering
        }
        fieldValues.sort();
        integer rankCounter = 1;
        for (Decimal fieldValue:  fieldValues) {
            fieldValueRankingMap.put((-1* fieldValue), rankCounter);
            rankCounter ++;
        }
        return fieldValueRankingMap;
    } */
    
    private Map<Decimal, Integer> getFieldValueRankingMap(List<Account_Service_Rank__c> serviceRankList, String fieldToSort) {
        Map<Decimal, Integer> fieldValueRankingMap = new Map<Decimal, Integer>();
        Map<Decimal, Integer> fieldValueRankingTempMap = new Map<Decimal, Integer>();
        List<Decimal> fieldValues = null;
        for (Account_Service_Rank__c serviceRank: serviceRankList) {
            Decimal fieldValue = (Decimal)serviceRank.get(fieldToSort);
            //setting the counter for skipping same values JIRA 3652
            //fieldValueRankingMap.put(fieldValue,null ); // For descending ordering            
            if(fieldValueRankingTempMap.containsKey(fieldValue)){
                Integer iCount = fieldValueRankingTempMap.get(fieldValue);
                fieldValueRankingTempMap.put(fieldValue,iCount + 1);
            }
            else{
                fieldValueRankingTempMap.put(fieldValue,0);
            }
        }
        system.debug('fieldValueRankingMap :: '+ fieldValueRankingTempMap);
        fieldValues = new List<Decimal>(fieldValueRankingTempMap.keyset());
        fieldValues.sort();
        system.debug('fieldValues :: '+ fieldValues);
        integer rankCounter = 1;
        integer size = fieldValues.size();
        for (integer index = size-1 ; index >= 0; index -- ) {
            //fieldValueRankingMap.put(fieldValues[index], rankCounter);
            system.debug('msg::'+fieldValues[index]);            
            system.debug('msg::'+rankCounter);
            system.debug('msg::'+index);
            system.debug('msg::'+size);
            if(index != size-1){
                system.debug('msg::'+fieldValueRankingTempMap.get(fieldValues[index + 1]));
                rankCounter = fieldValueRankingTempMap.get(fieldValues[index + 1]) + rankCounter;
                fieldValueRankingMap.put(fieldValues[index], rankCounter);
            }               
            else
               fieldValueRankingMap.put(fieldValues[index], rankCounter);
            rankCounter ++;
        }
        system.debug('fieldValueRankingMap 2 :: '+ fieldValueRankingMap);
        return fieldValueRankingMap;
    }   
    
    private List<Account_Service_Rank__c> queryServiceRanks(Account_Service_Model__c model) {
        List<Account_Service_Rank__c> serviceRankList = null;
        String soqlQuery = getSelectQuery2() + getPointsFields() + getWhereCondition2(model);
        Decimal inProgressVersion = model.inprogress_version__c;
        System.debug('soqlQuery = ' + soqlQuery);
        //Bind varaibles
        Id modelId = model.Id;
        serviceRankList = Database.query(soqlQuery );
        if (serviceRankList != null)
            system.debug ('Queries serviceRankList size = ' + serviceRankList.size());

        return serviceRankList ;
    }   
    
    private String getWhereCondition2(Account_Service_Model__c  model) {
        String whereCondition = null;
        whereCondition = ' from Account_Service_Rank__c where ';
        whereCondition = whereCondition + ' version__c = :inProgressVersion and ';
        whereCondition = whereCondition + ' Model__r.id = : modelId';
        return whereCondition;
    }   
    
    private String getPointsFields() {
        String pointFields = null;
        Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Account_Service_Rank__c.fields.getMap(); 
    
        for (String fieldName : mapFields.keyset()) 
        { 
            if (fieldName.toUpperCase().contains('_POINTS__C')) {
                if (pointFields == null) {
                    pointFields = fieldName;
                }
                else {
                    pointFields = pointFields + ' ,' + fieldName;
                }
            }
        }       
        return pointFields;
    }   
    
    
    
    private String getSelectQuery2() {
        return 'select id, external_id__c, version__c, ';
    }
    
    private void initializePointsAndCountFieldsToCipher (List<Account_Service_Rank__c> serviceRankList) {
        if (serviceRankList != null && serviceRankList.size() > 0) {
            Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Account_Service_Rank__c.fields.getMap(); 
            for (Account_Service_Rank__c serviceRank: serviceRankList) {
                for (String fieldName : mapFields.keyset()) 
                { 
                    if (fieldName.toUpperCase().contains('_COUNT__C') || fieldName.toUpperCase().contains('_POINTS__C')) {
                            serviceRank.put(fieldName , 0);
                    }
                } 
            }
        }
    }   
    
    private List<Account_Service_Rank__c> queryAndCreateServiceRanks(Account_Service_Model__c model) {
        List<Account_Service_Rank__c> serviceRankList = null;
        String soqlQuery = getSoqlQuery(model);
        AggregateResult[] results = getAggregratedResults(soqlQuery, model);
        serviceRankList = createServiceRankObject(results, model);
        return serviceRankList ;
    }
    
    global void finish (Database.BatchableContext bc) {
        AsyncApexJob apexJob = [SELECT Id, JobType, Status, JobItemsProcessed, TotalJobItems, 
                               NumberOfErrors, CompletedDate, MethodName, ExtendedStatus
                               FROM AsyncApexJob 
                               WHERE JobType = 'BatchApex' AND Id = :bc.getJobId()
                               ];
        if(apexJob != null && apexJob.NumberOfErrors > 0 ) {
            errorMessageList.add(apexJob.ExtendedStatus);
        }

        if( errorMessageList.size() > 0){
            String emailBody = getEmailBody(apexJob);
        EventServiceStatsUtility.emailErrorLog('FAILURE','PopulateServiceRankBatch',emailBody+'\n\nRegards,\nSalesforce Tech');
        }
        else {  
            updateVersion();
           ///////////////////////// if(!Test.isRunningTest())
               /////////////////////////////// Database.executeBatch(new CleanupOldServiceRankBatch(), 3000);
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
        return emailBody;
    }       
    
    private List<Account_Service_Rank__c> createServiceRankObject (AggregateResult[] results, Account_Service_Model__c model) {
        List<Account_Service_Rank__c> serviceRankList = new List<Account_Service_Rank__c>();
        if (results != null && results.size() > 0) {
            for (AggregateResult result: results) {
                
                Account_Service_Rank__c serviceRank = new Account_Service_Rank__c();
                serviceRank.version__c= model.inprogress_version__c;
                
                System.debug(result);
                Id accountId = (Id)result.get('whatid');
                System.debug('whatid = ' + accountId);
                Account accountReference = new Account(Id=accountId);
                System.debug(accountReference);
                serviceRank.Account__c = accountReference.id;
                
                Id modelId= model.Id;
                Account_Service_Model__c modelReference = new Account_Service_Model__c(Id=modelId);
                serviceRank.Model__c = modelReference.id;
                
                serviceRank.external_id__c= accountId +'_'+ modelId +'_'+ String.valueOf(model.inprogress_version__c);
                updateCountAndPointFields(serviceRank, result);
                system.debug('serviceRank = '+ serviceRank);
                serviceRankList.add(serviceRank);
            }
        }
        System.debug('serviceRankList size = ' + serviceRankList.size());
        return serviceRankList;
    }   
    
    private void updateCountAndPointFields (Account_Service_Rank__c serviceRank, AggregateResult result) {
        Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Account_Service_Rank__c.fields.getMap(); 
    
        for (String fieldName : mapFields.keyset()) 
        { 
            if (fieldName.toUpperCase().contains('_COUNT__C') || fieldName.toUpperCase().contains('_POINTS__C')) {
                Decimal fieldValue = (Decimal) result.get(fieldName);
                if (fieldValue  != null && fieldValue  > 0) {
                    serviceRank.put(fieldName , fieldValue );
                }
                else {
                    serviceRank.put(fieldName , 0);
                }
            }
        } 
    }
    
    private AggregateResult[] getAggregratedResults (String soqlQuery, Account_Service_Model__c model) {
        AggregateResult[] results = null;
        //Bind variable starts
        String modelName = model.name;
        Decimal inProgressVersion = model.inprogress_version__c;
        System.debug('inProgressVersion =' + inProgressVersion);
        System.debug('modelName =' + modelName);
        //Bind variables end
        
        results  = Database.query(soqlQuery);
        if (results != null)
            system.debug ('Aggregrated Results size = ' + results.size());
        return results ;
    }
    
    private String getSoqlQuery(Account_Service_Model__c model) {
        String soqlQuery = null;
        soqlQuery = getBaseSelect() + getAggregratedFields() + getWhereCondition(model) + getGroupByCondition();
        System.debug('soqlQuery = ' + soqlQuery);
        return soqlQuery;
    }
    
    private String getGroupByCondition() {
        return ' group by account__r.id, model__r.name';
    }
    
    private String getWhereCondition(Account_Service_Model__c model) {
        String whereCondition = null;
        whereCondition = ' from Account_Service_Rank__c where ';
        whereCondition = whereCondition + '  is_latest_version__c = true and  ';
        whereCondition = whereCondition + ' Model__r.name = : modelName';
        return whereCondition;
    }
    
    private String getBaseSelect() {
        return 'select account__r.id whatid, ';
    }
    
    private String getAggregratedFields() {
        String aggregratedFields = null;
        Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Account_Service_Rank__c.fields.getMap(); 
    
        for (String fieldName : mapFields.keyset()) 
        { 
            if (fieldName.toUpperCase().contains('_COUNT__C') || fieldName.toUpperCase().contains('_POINTS__C')) {
                String aggregratedF = 'sum(' + fieldName + ')' +fieldName;
                if (aggregratedFields == null) {
                    aggregratedFields = aggregratedF;
                }
                else {
                    aggregratedFields = aggregratedFields + ' ,' + aggregratedF;
                }
            }
        }       
        return aggregratedFields;
    }
    
    private void updateVersion() {
        Schema.SObjectField idField = Account_Service_Model__c.Fields.Id;
        List<Account_Service_Model__c> models = new List<Account_Service_Model__c>();
        
        for (Id modelId :modelVersionMap.keyset()) {
            Account_Service_Model__c model = new Account_Service_Model__c();
            model.Id = modelId;
            model.stable_version__c = modelVersionMap.get(modelId);
            model.inprogress_version__c = null;
            models.add(model);
        }
        if (models.size() > 0) {
            Database.UpsertResult[] results = Database.upsert(models, idField , true);
            doLogging(results, null);
        }   
    }

}

//Database.executeBatch(new PopulateServiceRankBatch(), 1);