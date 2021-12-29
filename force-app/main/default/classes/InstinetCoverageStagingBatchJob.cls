public class InstinetCoverageStagingBatchJob implements Database.Batchable<NomuraInstinetProductMapping>,Database.Stateful {
    public List<Instinet_Coverage_Champion_Aggregated__c> errorInsertList;
    public List<Instinet_Coverage_Champion_Aggregated__c> errorDeleteList;

    public class NomuraInstinetProductMapping {
        
        public NomuraInstinetProductMapping(){}
        
        public String nomuraProduct;
        public String nomuraProductRegion;
        public List<Instinet_Product_Mapping__mdt> instinetProductMappingList;
    }

    public InstinetCoverageStagingBatchJob() {
        errorInsertList = new List<Instinet_Coverage_Champion_Aggregated__c>();
        errorDeleteList = new List<Instinet_Coverage_Champion_Aggregated__c>();
    }

    public Iterable<NomuraInstinetProductMapping> start(Database.BatchableContext batchableContext){
        List<NomuraInstinetProductMapping> nomuraInstinetProductMappingList = getNomuraInstinetProductMappingList();
        //We cannot execute more than one batch in Test Class
        if(Test.isRunningTest()){
            List<NomuraInstinetProductMapping> testProductMappingList = new List<NomuraInstinetProductMapping>();
            for(NomuraInstinetProductMapping productMapping : nomuraInstinetProductMappingList){
                if('Asia'.equalsIgnoreCase(productMapping.nomuraProductRegion) && 'Instinet - Cash'.equalsIgnoreCase(productMapping.nomuraProduct)){
                    testProductMappingList.add(productMapping);
                    break;
                }
            }

            return testProductMappingList;

        }
        
        return nomuraInstinetProductMappingList;
    }

    //scope would be 1 - one record (Nomura Product) would be handled at a time so only one region would be present
    public void execute(Database.BatchableContext batchableContext, List<NomuraInstinetProductMapping> nomuraInstinetProductMappingList){
        List<AggregateResult> groupedCoverageList = new List<AggregateResult>();
        List<Instinet_Coverage_Champion_Aggregated__c> instinetCoverageList = new List<Instinet_Coverage_Champion_Aggregated__c>();
        Set<String> subsetUniqueIdList = new Set<String>();
        Set<String> productSet = new Set<String>();
        Set<String> productRegionSet = new Set<String>();
        String nomuraProduct = '', nomuraProductRegion = '';
        Id instinetCoverageRecordTypeId = CommonTools.getRecordTypeId('Instinet_Coverage_Champion_Aggregated__c','Instinet Coverage');
        String lastUpdatedTimestamp = CommonTools.getParameterValueFromConfiguration('Instinet_Coverage_Staging','LastUpdatedTimeStamp',true);

        if(nomuraInstinetProductMappingList != null && !nomuraInstinetProductMappingList.isEmpty()){
            
            for(NomuraInstinetProductMapping nomuraInstinetProductMappingObj : nomuraInstinetProductMappingList){
                nomuraProduct = nomuraInstinetProductMappingObj.nomuraProduct;
                nomuraProductRegion = nomuraInstinetProductMappingObj.nomuraProductRegion;

                List<Instinet_Product_Mapping__mdt> instinetProductList = nomuraInstinetProductMappingObj.instinetProductMappingList;
                if(instinetProductList != null && !instinetProductList.isEmpty()){
                    for(Instinet_Product_Mapping__mdt instinetProduct : instinetProductList){
                        productSet.add(instinetProduct.Instinet_Product__c);
                        productRegionSet.add(instinetProduct.Instinet_Region__c);
                    }
                }
                
            }

            if(!productSet.isEmpty() && !productRegionSet.isEmpty() && 
                nomuraProductRegion != null && String.isNotEmpty(nomuraProductRegion) &&
                nomuraProduct != null && String.isNotEmpty(nomuraProduct) &&
                String.isNotEmpty(lastUpdatedTimestamp))
            {
                DateTime lastUpdatedDateTime = DateTime.valueOfGmt(lastUpdatedTimestamp);
                
                /* It would be one region value in productRegionSet */
                /* Global region not considered in Instinet_Product_Mapping__mdt */
                /* Ignored products listed below. These products are not present in Instinet_Product_Mapping__mdt 
                 * Mkt Access, Equities
                 * Mkt Access, Options
                 * BlockCross Coverage
                 */
                groupedCoverageList = [ SELECT Instinet_CDB_ID__r.RM_Id__c RMId,
                                        Instinet_CDB_ID__r.RM_Id__r.RDM_Org_ID__c RMKey,
                                        Login_ID__c,Coverage_Login_ID_Detail__c, 
                                        MIN(Start_Date__c) Start_Date__c, MAX(End_Date__c) End_Date__c, MIN(Has_Ended__c) Has_Ended__c 
                                        FROM Instinet_Coverage_Champion_Staging__c 
                                        WHERE RecordType.DeveloperName = 'Instinet_Coverage' AND 
                                        Coverage_Login_ID_Detail__c <> '' AND 
                                        Instinet_CDB_ID__c <> '' AND
                                        Instinet_CDB_ID__r.RM_Id__c <> null AND Instinet_CDB_ID__r.RM_Id__c <> '' AND 
                                        Instinet_CDB_ID__r.RM_Id__r.RDM_Org_ID__c <> 'RM000000' AND 
                                        Instinet_CDB_ID__r.RM_Id__r.Active__c = TRUE AND
                                        Start_Date__c <> null AND 
                                        Product__c IN :productSet AND 
                                        Product_Region__c IN :productRegionSet AND 
                                        Coverage_Login_ID_Detail__r.Active__c = TRUE AND
                                        LastModifiedDate > :lastUpdatedDateTime 
                                        GROUP BY Instinet_CDB_ID__r.RM_Id__c,Instinet_CDB_ID__r.RM_Id__r.RDM_Org_ID__c,Login_ID__c,Coverage_Login_ID_Detail__c
                                        ORDER BY Instinet_CDB_ID__r.RM_Id__c,Instinet_CDB_ID__r.RM_Id__r.RDM_Org_ID__c,Login_ID__c,Coverage_Login_ID_Detail__c];

                if(!groupedCoverageList.isEmpty() && String.isNotEmpty(instinetCoverageRecordTypeId)){
                    for(AggregateResult resultObj : groupedCoverageList){
                        instinetCoverageList.add(getInstinetCoverageRecord(resultObj, instinetCoverageRecordTypeId, nomuraProductRegion, nomuraProduct));
                    }

                    if(!instinetCoverageList.isEmpty()){
                        //Fetch the list of coverage records for deletion from Instinet_Coverage_Champion_Aggregated__c table
                        List<Instinet_Coverage_Champion_Aggregated__c> instinetCoverageDeleteList = getInstinetCoverageRecordListForDeletion(instinetCoverageList);
                        deleteInstinetCoverageRecords(instinetCoverageDeleteList);

                        //Insert the records in Instinet_Coverage_Champion_Aggregated__c table based on Unique_ID__c
                        insertInstinetCoverageRecords(instinetCoverageList);
                    }
                }
            }
        }

    }

    public void finish(Database.BatchableContext batchableContext){
        //Call Batch for putting the records from Aggregated to Main table
        Id batchProcessId = Database.executeBatch(new InstinetCoverageAggregatedBatchJob(false), 5);

        /*
         *  Update the timestamp in Configuration__c for Instinet_Coverage_Staging entry 
         *  by fetching the MAX(LastModifiedDate) from Instinet_Coverage_Champion_Staging__c records 
         */
        AggregateResult aggregateResultObj = [SELECT MAX(LastModifiedDate) LastModifiedDate FROM Instinet_Coverage_Champion_Staging__c 
                                              WHERE RecordType.DeveloperName = 'Instinet_Coverage'];

        if(aggregateResultObj != null){
            DateTime lastModifiedDate = DateTime.valueOf(aggregateResultObj.get('LastModifiedDate'));
            String strLastModifiedDate = lastModifiedDate.formatGMT('yyyy-MM-dd HH:mm:ss');
            if(String.isNotEmpty(strLastModifiedDate)){
                CommonTools.updateParameterValueInConfiguration('Instinet_Coverage_Staging','LastUpdatedTimeStamp', strLastModifiedDate);
            }

        }   
    }

    public Instinet_Coverage_Champion_Aggregated__c getInstinetCoverageRecord(AggregateResult resultObj, Id instinetCoverageRecordTypeId, String nomuraProductRegion, String nomuraProduct){
        Instinet_Coverage_Champion_Aggregated__c instinetCoverageRecord = new Instinet_Coverage_Champion_Aggregated__c();
        
        instinetCoverageRecord.RecordTypeId = instinetCoverageRecordTypeId;
        instinetCoverageRecord.Account__c = String.valueOf(resultObj.get('RMId'));
        instinetCoverageRecord.Coverage_Login_ID_Detail__c = String.valueOf(resultObj.get('Coverage_Login_ID_Detail__c'));
        instinetCoverageRecord.Product_Region__c = nomuraProductRegion;
        instinetCoverageRecord.Product__c = nomuraProduct;
        instinetCoverageRecord.Start_Date__c = Date.valueOf(resultObj.get('Start_Date__c'));
        instinetCoverageRecord.End_Date__c =  Date.valueOf(resultObj.get('End_Date__c'));
        Boolean activeFlag = (resultObj.get('Has_Ended__c') != null && Integer.valueOf(resultObj.get('Has_Ended__c')) == 0);
        instinetCoverageRecord.Active__c = activeFlag;

        //Unique_ID__c is combination of RDM Org ID, Login_ID__c, Product_Region__c, Product__c, Start_Date__c and End_Date__c
        instinetCoverageRecord.Unique_ID__c = resultObj.get('RMKey') + '#' + resultObj.get('Login_ID__c') + '#' 
            + nomuraProductRegion + '#' + nomuraProduct + '#' 
            + resultObj.get('Start_Date__c') 
            + (activeFlag ? '' : ('#' + resultObj.get('End_Date__c')));

        //Subset_Unique_ID__c is combination of RDM Org ID, Login_ID__c, Product_Region__c, Product__c
        instinetCoverageRecord.Subset_Unique_ID__c = resultObj.get('RMKey') + '#' + resultObj.get('Login_ID__c') + '#' 
            + nomuraProductRegion + '#' + nomuraProduct;

        return instinetCoverageRecord;
    }

     public List<Instinet_Coverage_Champion_Aggregated__c> getInstinetCoverageRecordListForDeletion(List<Instinet_Coverage_Champion_Aggregated__c> instinetCoverageList){
        List<Instinet_Coverage_Champion_Aggregated__c> instinetCoverageDeleteList = new List<Instinet_Coverage_Champion_Aggregated__c>();
        Set<String> subsetUniqueIDForInactiveRecordList = new Set<String>();

        if(instinetCoverageList != null && !instinetCoverageList.isEmpty()){

                //Fetch the Subset_Unique_ID__c for records with Active__c = FALSE
                for(Instinet_Coverage_Champion_Aggregated__c instinetCoverageRecord : instinetCoverageList){
                    String subsetUniqueID = instinetCoverageRecord.Subset_Unique_ID__c;
                    if(instinetCoverageRecord.Active__c == FALSE && String.isNotEmpty(subsetUniqueID)){
                        subsetUniqueIDForInactiveRecordList.add(subsetUniqueID);
                    }
                }

                if(!subsetUniqueIDForInactiveRecordList.isEmpty()){
                    //Fetch the records from Instinet_Coverage_Champion_Aggregated__c based on Subset_Unique_ID__c for deletion
                    //When corresponding active records are present
                    if(!subsetUniqueIDForInactiveRecordList.isEmpty()){
                        instinetCoverageDeleteList = [SELECT Id, Subset_Unique_ID__c 
                                                      FROM Instinet_Coverage_Champion_Aggregated__c 
                                                      WHERE Subset_Unique_ID__c IN :subsetUniqueIDForInactiveRecordList AND Active__c = TRUE];
                    }
                }
        }        

        return instinetCoverageDeleteList;
    }

    public void deleteInstinetCoverageRecords(List<Instinet_Coverage_Champion_Aggregated__c> instinetCoverageChampionAggregatedList){
        if(instinetCoverageChampionAggregatedList != null && !instinetCoverageChampionAggregatedList.isEmpty()){
            List<Database.DeleteResult> resultList = Database.delete(instinetCoverageChampionAggregatedList, false);
            for(Integer i=0; i<resultList.size(); i++){            
                Database.DeleteResult resultObj = resultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        if(String.isNotEmpty(errorObj.getMessage())){
                            errorDeleteList.add(instinetCoverageChampionAggregatedList.get(i));
                        }
                    }
                }
            }
        }
    }

    public void insertInstinetCoverageRecords(List<Instinet_Coverage_Champion_Aggregated__c> instinetCoverageChampionAggregatedList){
        if(instinetCoverageChampionAggregatedList != null && !instinetCoverageChampionAggregatedList.isEmpty()){
            
            List<Database.SaveResult> resultList = Database.insert(instinetCoverageChampionAggregatedList, false); 
            for(Integer i=0; i<resultList.size(); i++){            
                Database.SaveResult resultObj = resultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        
                        if(String.isNotEmpty(errorObj.getMessage()) 
                            && !errorObj.getMessage().contains('duplicate value found: Unique_ID__c duplicates value')){
                            errorInsertList.add(instinetCoverageChampionAggregatedList.get(i));
                        }
                    }
                }
            }
        }
    }

    public List<NomuraInstinetProductMapping> getNomuraInstinetProductMappingList(){
        Map<String,List<Instinet_Product_Mapping__mdt>> nomuraInstinetProductMapping = new Map<String,List<Instinet_Product_Mapping__mdt>>();
        List<NomuraInstinetProductMapping> nomuraInstinetProductMappingList = new List<NomuraInstinetProductMapping>();
        
        /* We cannout use GROUP BY for Custom Metadata */
        List<Instinet_Product_Mapping__mdt> instinetNomuraProductList = 
            [SELECT Instinet_Product__c, Instinet_Region__c,
             Nomura_Product__c, Nomura_Region__c 
             FROM Instinet_Product_Mapping__mdt 
             WHERE Nomura_Product__c <> '' AND Nomura_Region__c <> '' ];
        
        if(instinetNomuraProductList != null && !instinetNomuraProductList.isEmpty()){
            for(Instinet_Product_Mapping__mdt prdMapping : instinetNomuraProductList){
            	String nomuraProduct = prdMapping.Nomura_Region__c + '#' + prdMapping.Nomura_Product__c;
               	List<Instinet_Product_Mapping__mdt> instinetProductList = 
                        nomuraInstinetProductMapping.containsKey(nomuraProduct) ? nomuraInstinetProductMapping.get(nomuraProduct) : new List<Instinet_Product_Mapping__mdt>();
                instinetProductList.add(prdMapping);
                nomuraInstinetProductMapping.put(nomuraProduct, instinetProductList);
            }

            if(!nomuraInstinetProductMapping.isEmpty()){
                for(String nomuraProductDetails : nomuraInstinetProductMapping.keySet()){
                    
                    String strNomuraProductRegion = nomuraProductDetails.substring(0,nomuraProductDetails.indexOf('#'));
                    String strNomuraProduct = nomuraProductDetails.substring(nomuraProductDetails.lastIndexOf('#') + 1);
                    
                    NomuraInstinetProductMapping nomuraInstinetProductMappingObj = new NomuraInstinetProductMapping();
                    nomuraInstinetProductMappingObj.nomuraProduct = strNomuraProduct;
                    nomuraInstinetProductMappingObj.nomuraProductRegion = strNomuraProductRegion;
                    
                    List<Instinet_Product_Mapping__mdt> instinetProductMappingList = nomuraInstinetProductMapping.get(nomuraProductDetails);
                    nomuraInstinetProductMappingObj.instinetProductMappingList = instinetProductMappingList;

                    nomuraInstinetProductMappingList.add(nomuraInstinetProductMappingObj);
                }
            }
        }
        
        return nomuraInstinetProductMappingList;
    }
}