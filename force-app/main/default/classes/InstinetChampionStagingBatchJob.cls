public class InstinetChampionStagingBatchJob implements Database.Batchable<AggregateResult>,Database.Stateful {
    
    public List<Instinet_Coverage_Champion_Aggregated__c> errorInsertList;
    public List<Instinet_Coverage_Champion_Aggregated__c> errorDeleteList;
    
    public InstinetChampionStagingBatchJob() {
        errorInsertList = new List<Instinet_Coverage_Champion_Aggregated__c>();
        errorDeleteList = new List<Instinet_Coverage_Champion_Aggregated__c>();
    }

    public Iterable<AggregateResult> start(Database.BatchableContext batchableContext){
        List<AggregateResult> aggregatedChampionList = new List<AggregateResult>();

        String lastUpdatedTimestamp = CommonTools.getParameterValueFromConfiguration('Instinet_Champion_Staging','LastUpdatedTimeStamp',true);

        if(String.isNotEmpty(lastUpdatedTimestamp)){
            DateTime lastUpdatedDateTime = DateTime.valueOfGmt(lastUpdatedTimestamp);
            //We are taking up records for Global region as well 
            aggregatedChampionList = [SELECT Instinet_CDB_ID__r.RM_Id__c RMId,
                                    Instinet_CDB_ID__r.RM_Id__r.RDM_Org_ID__c RMKey,
                                    Login_ID__c, Champion_Login_ID_Detail__c,  
                                    Product_Region__c, 
                                    MIN(Start_Date__c) Start_Date__c, MAX(End_Date__c) End_Date__c, MIN(Has_Ended__c) Has_Ended__c 
                                    FROM Instinet_Coverage_Champion_Staging__c 
                                    WHERE RecordType.DeveloperName = 'Instinet_Champion' AND 
                                    Champion_Login_ID_Detail__c <> '' AND 
                                    Instinet_CDB_ID__c <> '' AND
                                    Instinet_CDB_ID__r.RM_Id__c <> null AND Instinet_CDB_ID__r.RM_Id__c <> '' AND 
                                    Product__c = 'Instinet Champion' AND
                                    LastModifiedDate > :lastUpdatedDateTime 
                                    GROUP BY Instinet_CDB_ID__r.RM_Id__c,Instinet_CDB_ID__r.RM_Id__r.RDM_Org_ID__c,Login_ID__c,Champion_Login_ID_Detail__c,Product_Region__c
                                    ORDER BY Instinet_CDB_ID__r.RM_Id__c,Instinet_CDB_ID__r.RM_Id__r.RDM_Org_ID__c,Login_ID__c,Champion_Login_ID_Detail__c,Product_Region__c];

             System.debug('lastUpdatedDateTime:'+lastUpdatedDateTime);                       

        }                        

        return aggregatedChampionList;
    }

    public void execute(Database.BatchableContext batchableContext, List<AggregateResult> aggregatedChampionList){
        List<Instinet_Coverage_Champion_Aggregated__c> instinetChampionList = new List<Instinet_Coverage_Champion_Aggregated__c>();
        
        Id instinetChampionRecordTypeId = CommonTools.getRecordTypeId('Instinet_Coverage_Champion_Aggregated__c','Instinet Champion');

        if(aggregatedChampionList != null && !aggregatedChampionList.isEmpty() && 
            String.isNotEmpty(instinetChampionRecordTypeId))
        {
            for(AggregateResult aggregatedChampionRecord : aggregatedChampionList){
                instinetChampionList.add(getInstinetChampionRecord(aggregatedChampionRecord, instinetChampionRecordTypeId));
            }

            if(!instinetChampionList.isEmpty()){
                
                //Fetch the list of champion records for deletion from Instinet_Coverage_Champion_Aggregated__c table
                List<Instinet_Coverage_Champion_Aggregated__c> instinetChampionDeleteList = getInstinetChampionRecordListForDeletion(instinetChampionList);
                errorDeleteList.addAll(InstinetFeedUtility.deleteInstinetChampionAggregatedRecords(instinetChampionDeleteList));

                //Insert the records in Instinet_Coverage_Champion_Aggregated__c table based on Unique_ID__c
                errorInsertList.addAll(InstinetFeedUtility.insertInstinetChampionAggregatedRecords(instinetChampionList));
           
            }
        }
    }

    public void finish(Database.BatchableContext batchableContext){
        //TODO : To check for mail

        //Call Batch for putting the records from Aggregated to Main table
        //We are keeping size as 1 otherwise duplicate rule will not fire
        if(Test.isRunningTest()){
             Id batchProcessId = Database.executeBatch(new InstinetChampionAggregatedBatchJob(), 10);
        }
        else {
            Id batchProcessId = Database.executeBatch(new InstinetChampionAggregatedBatchJob(), 1);
        }

        /*
         *  Update the timestamp in Configuration__c for Instinet_Champion_Staging entry 
         *  by fetching the MAX(LastModifiedDate) from Instinet_Coverage_Champion_Staging__c records 
         */
        AggregateResult aggregateResultObj = [SELECT MAX(LastModifiedDate) LastModifiedDate FROM Instinet_Coverage_Champion_Staging__c 
                                              WHERE RecordType.DeveloperName = 'Instinet_Champion'];

        if(aggregateResultObj != null){
            DateTime lastModifiedDate = DateTime.valueOf(aggregateResultObj.get('LastModifiedDate'));
            String strLastModifiedDate = lastModifiedDate.formatGMT('yyyy-MM-dd HH:mm:ss');
            if(String.isNotEmpty(strLastModifiedDate)){
                CommonTools.updateParameterValueInConfiguration('Instinet_Champion_Staging','LastUpdatedTimeStamp', strLastModifiedDate);
            }

        }   
    }

    public Instinet_Coverage_Champion_Aggregated__c getInstinetChampionRecord(AggregateResult resultObj, Id instinetChampionRecordTypeId){
        Instinet_Coverage_Champion_Aggregated__c instinetChampionRecord = new Instinet_Coverage_Champion_Aggregated__c();
        
        instinetChampionRecord.RecordTypeId = instinetChampionRecordTypeId;
        instinetChampionRecord.Account__c = String.valueOf(resultObj.get('RMId'));
        instinetChampionRecord.Champion_Login_ID_Detail__c = String.valueOf(resultObj.get('Champion_Login_ID_Detail__c'));
        instinetChampionRecord.Product_Region__c = String.valueOf(resultObj.get('Product_Region__c'));
        instinetChampionRecord.Start_Date__c = Date.valueOf(resultObj.get('Start_Date__c'));
        instinetChampionRecord.End_Date__c =  Date.valueOf(resultObj.get('End_Date__c'));
        Boolean activeFlag = (resultObj.get('Has_Ended__c') != null && Integer.valueOf(resultObj.get('Has_Ended__c')) == 0);
        instinetChampionRecord.Active__c = activeFlag;

         //Unique_ID__c is combination of RDM Org ID, Login_ID__c, Product_Region__c, Start_Date__c, End_Date__c
        instinetChampionRecord.Unique_ID__c = resultObj.get('RMKey') + '#' + resultObj.get('Login_ID__c') + '#' + resultObj.get('Product_Region__c') 
            + '#' + resultObj.get('Start_Date__c')
            + (activeFlag ? '' : ('#' + resultObj.get('End_Date__c')));
        
        //Subset_Unique_ID__c is combination of RDM Org ID, Login_ID__c, Product_Region__c
        instinetChampionRecord.Subset_Unique_ID__c = resultObj.get('RMKey') + '#' + resultObj.get('Login_ID__c') + '#' + resultObj.get('Product_Region__c');

        return instinetChampionRecord;
    }

    public List<Instinet_Coverage_Champion_Aggregated__c> getInstinetChampionRecordListForDeletion(List<Instinet_Coverage_Champion_Aggregated__c> instinetChampionList){
        List<Instinet_Coverage_Champion_Aggregated__c> instinetChampionDeleteList = new List<Instinet_Coverage_Champion_Aggregated__c>();
        Set<String> subsetUniqueIDList = new Set<String>();

        if(instinetChampionList != null && !instinetChampionList.isEmpty()){

                //Fetch the Unique_ID__c for records with Active__c = FALSE
                for(Instinet_Coverage_Champion_Aggregated__c instinetChampionRecord : instinetChampionList){
                    String subsetUniqueID = instinetChampionRecord.Subset_Unique_ID__c;
                    if(instinetChampionRecord.Active__c == FALSE && String.isNotEmpty(subsetUniqueID)){
                        subsetUniqueIDList.add(subsetUniqueID);
                    }
                }

                if(!subsetUniqueIDList.isEmpty()){
                    //Fetch the records from Instinet_Coverage_Champion_Aggregated__c based on Subset_Unique_ID__c for deletion
                    if(!subsetUniqueIDList.isEmpty()){
                        instinetChampionDeleteList = [SELECT Id, Subset_Unique_ID__c 
                                                      FROM Instinet_Coverage_Champion_Aggregated__c 
                                                      WHERE Subset_Unique_ID__c IN :subsetUniqueIDList AND Active__c = TRUE];
                    }
                }
        }        

        return instinetChampionDeleteList;
    }

    

}