public class InstinetChampionAggregatedBatchJob implements Database.Batchable<sObject>,Database.Stateful {
    public static final String INSTINET_CHAMPION_TYPE = 'EQ - Execution Champion';
    public List<Sales_Champion__c> errorInsertList;
    public List<Sales_Champion__c> errorDeleteList;
    
    public InstinetChampionAggregatedBatchJob() {
        errorInsertList = new List<Sales_Champion__c>();
        errorDeleteList = new List<Sales_Champion__c>();
    }

    public Database.QueryLocator start(Database.BatchableContext batchableContext){
        String query = null;
        String lastUpdatedTimestamp = CommonTools.getParameterValueFromConfiguration('Instinet_Champion_Aggregated','LastUpdatedTimeStamp',true);
        
        if(String.isNotEmpty(lastUpdatedTimestamp)){
            //Make sure all delete records gets processed first
            query = 'SELECT Id, Champion_Login_ID_Detail__c, Account__r.ParentId, Account__r.Parent.Active__c,Product_Region__c, Active__c ' 
            + 'FROM Instinet_Coverage_Champion_Aggregated__c WHERE RecordType.DeveloperName = \'Instinet_Champion\' AND ' 
            + 'Account__r.ParentId <> null AND '
            + 'LastModifiedDate > ' + lastUpdatedTimestamp + ' ORDER BY Active__c ';

            System.debug('query:'+query);
        }

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext batchableContext, List<sObject> scope){

        List<Instinet_Coverage_Champion_Aggregated__c> instinetChampionAggregatedList = (List<Instinet_Coverage_Champion_Aggregated__c>)scope;
        List<Sales_Champion__c> activeInstinetChampionList = new List<Sales_Champion__c>();
        List<Sales_Champion__c> inactiveInstinetChampionList = new List<Sales_Champion__c>();
        List<Sales_Champion__c> deleteInstinetChampionList =  new List<Sales_Champion__c>();
        String championQueryCriteria = '', salesChampionQuery = '';
        Id instinetChampionRecordTypeId = CommonTools.getRecordTypeId('Sales_Champion__c','Instinet Champion');

        for(Instinet_Coverage_Champion_Aggregated__c instinetChampionAggregatedObj : instinetChampionAggregatedList){
            
            //Make sure RG Account is present
            Id accountRGId = instinetChampionAggregatedObj.Account__r.ParentId;

            if(accountRGId != null && String.isNotEmpty(accountRGId)){
                if(instinetChampionAggregatedObj.Active__c){
                    //Add only when RG Account is active
                    if(instinetChampionAggregatedObj.Account__r.Parent.Active__c){
                    	activeInstinetChampionList.add(getSalesChampionRecord(instinetChampionAggregatedObj, instinetChampionRecordTypeId));
                    }
                }
                else {
                    inactiveInstinetChampionList.add(getSalesChampionRecord(instinetChampionAggregatedObj, instinetChampionRecordTypeId));
                }
            }
        }

        //For Inactive Records
        if(!inactiveInstinetChampionList.isEmpty()){
            //Form query criteria for deleting Instinet Champions
            for(Sales_Champion__c salesChampionObj : inactiveInstinetChampionList){
                championQueryCriteria = championQueryCriteria + '(Account__c = \'' +  salesChampionObj.Account__c + '\' AND Instinet_Champion__c = \'' + salesChampionObj.Instinet_Champion__c + '\' AND Region__c = \'' + salesChampionObj.Region__c + '\') OR ';
            }

            if(String.isNotEmpty(championQueryCriteria)){
                championQueryCriteria = championQueryCriteria.substring(0, championQueryCriteria.lastIndexOf('OR'));
                salesChampionQuery = 'SELECT Id FROM Sales_Champion__c WHERE ' + championQueryCriteria;
                deleteInstinetChampionList = Database.query(salesChampionQuery);
                errorDeleteList.addAll(InstinetFeedUtility.deleteInstinetChampionRecords(deleteInstinetChampionList));
            }
        }

        //For Active Records
        if(!activeInstinetChampionList.isEmpty()){
            //Insert the records in Sales_Champion__c table
            errorInsertList.addAll(InstinetFeedUtility.insertInstinetChampionRecords(activeInstinetChampionList));
        }

    }

    public void finish(Database.BatchableContext batchableContext){
        /*
         *  Update the timestamp in Configuration__c for Instinet_Champion_Aggregated entry 
         *  by fetching the MAX(LastModifiedDate) from Instinet_Coverage_Champion_Aggregated__c records 
         */
        AggregateResult aggregateResultObj = [SELECT MAX(LastModifiedDate) LastModifiedDate FROM Instinet_Coverage_Champion_Aggregated__c 
                                              WHERE RecordType.DeveloperName = 'Instinet_Champion'];

        if(aggregateResultObj != null){
            DateTime lastModifiedDate = DateTime.valueOf(aggregateResultObj.get('LastModifiedDate'));
            String strLastModifiedDate = lastModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            if(String.isNotEmpty(strLastModifiedDate)){
                CommonTools.updateParameterValueInConfiguration('Instinet_Champion_Aggregated','LastUpdatedTimeStamp', strLastModifiedDate);
            }
        } 

        if(!Test.isRunningTest()){
	        Id batchProcessId = Database.executeBatch(new InstinetCoverageStagingBatchJob(),1);
        } 
    }

    public Sales_Champion__c getSalesChampionRecord(Instinet_Coverage_Champion_Aggregated__c instinetChampionAggregatedObj, Id recordTypeId){
        Sales_Champion__c salesChampionObj = new Sales_Champion__c();

        salesChampionObj.Account__c = instinetChampionAggregatedObj.Account__r.ParentId;
        salesChampionObj.Instinet_Champion__c = instinetChampionAggregatedObj.Champion_Login_ID_Detail__c;
        salesChampionObj.Region__c = InstinetFeedUtility.getSalesChampionRegion(instinetChampionAggregatedObj.Product_Region__c);
        salesChampionObj.Champion_Type__c = INSTINET_CHAMPION_TYPE;
        salesChampionObj.RecordTypeId = recordTypeId;

        return salesChampionObj;
    }

 
}