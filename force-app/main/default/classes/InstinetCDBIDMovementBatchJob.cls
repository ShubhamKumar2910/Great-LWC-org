public class InstinetCDBIDMovementBatchJob implements Database.Batchable<Id>,Database.Stateful {
    public static final String COVERAGE_ENTITY_TYPE = 'Coverage';
    public static final String CHAMPION_ENTITY_TYPE = 'Champion';

    public List<Instinet_Coverage_Champion_Aggregated__c> instinetRecordErrorUpdateList;
    public List<Instinet_Mapping__c> instinetMappingErrorUpdateList;
    public String entityType;
    public Boolean chainAnotherBatch = true;
    public String championLastUpdatedTimestamp;
    public String coverageLastUpdatedTimestamp;
    
    public InstinetCDBIDMovementBatchJob(String strEntityType) {
        instinetRecordErrorUpdateList = new List<Instinet_Coverage_Champion_Aggregated__c>();
        instinetMappingErrorUpdateList = new List<Instinet_Mapping__c>();
        entityType = strEntityType;
        championLastUpdatedTimestamp = CommonTools.getParameterValueFromConfiguration('Instinet_Champion_Staging','LastUpdatedTimeStamp',true);
        coverageLastUpdatedTimestamp = CommonTools.getParameterValueFromConfiguration('Instinet_Coverage_Staging','LastUpdatedTimeStamp',true);
    }

    public Iterable<Id> start(Database.BatchableContext batchableContext){
        List<Id> instinetMappingIdList = new List<Id>(); 
        
        Map<Id,Instinet_Mapping__c> instinetMappingMap = new Map<Id,Instinet_Mapping__c>([
            SELECT Id, CDB_ID__c FROM Instinet_Mapping__c
            WHERE Previous_RM__c <> null  
        ]);

        if(instinetMappingMap != null && !instinetMappingMap.isEmpty()){
            instinetMappingIdList.addAll(instinetMappingMap.keySet());
        }

        return instinetMappingIdList;
    }

    //scope would be 1 - one record (i.e one CDB ID movement) would be handled at a time
    public void execute(Database.BatchableContext batchableContext, List<Id> instinetMappingIdList){
        Map<String,String> instinetCDBIDWithOldRMMap = new Map<String,String>();
        Map<String,List<Instinet_Coverage_Champion_Staging__c>> instinetCDBIDMap = new Map<String,List<Instinet_Coverage_Champion_Staging__c>>();
        List<Instinet_Coverage_Champion_Staging__c> instinetStagingList = new List<Instinet_Coverage_Champion_Staging__c>();
        
        if(instinetMappingIdList != null && !instinetMappingIdList.isEmpty())
        {
            //Fetch only Active Records
            if(CHAMPION_ENTITY_TYPE.equalsIgnoreCase(entityType)){
                if(String.isNotEmpty(championLastUpdatedTimestamp)){
                    DateTime lastUpdatedDateTime = DateTime.valueOfGmt(championLastUpdatedTimestamp);

                    instinetStagingList = [
                        SELECT Id, CDB_ID__c, Instinet_CDB_ID__c, 
                            Instinet_CDB_ID__r.RM_Id__c, Instinet_CDB_ID__r.RM_Id__r.RDM_Org_ID__c, 
                            Instinet_CDB_ID__r.RM_Id__r.ParentId, Instinet_CDB_ID__r.RM_Id__r.Parent.RDM_Org_ID__c, 
                            Instinet_CDB_ID__r.Previous_RM__c, 
                            Login_ID__c, Champion_Login_ID_Detail__c, Product_Region__c
                        FROM Instinet_Coverage_Champion_Staging__c 
                        WHERE Instinet_CDB_ID__c IN :instinetMappingIdList AND 
                            RecordType.DeveloperName = 'Instinet_Champion' AND Product__c = 'Instinet Champion' AND 
                            Champion_Login_ID_Detail__c <> null AND 
                            Has_Ended__c = 0 AND
                            LastModifiedDate > :lastUpdatedDateTime 
                        ORDER BY LastModifiedDate

                    ];
                }
            }
            else if(COVERAGE_ENTITY_TYPE.equalsIgnoreCase(entityType)){
                if(String.isNotEmpty(coverageLastUpdatedTimestamp)){
                    DateTime lastUpdatedDateTime = DateTime.valueOfGmt(coverageLastUpdatedTimestamp);

                    instinetStagingList = [
                        SELECT Id, CDB_ID__c, Instinet_CDB_ID__c, 
                            Instinet_CDB_ID__r.RM_Id__c, Instinet_CDB_ID__r.RM_Id__r.RDM_Org_ID__c, 
                            Instinet_CDB_ID__r.RM_Id__r.ParentId, Instinet_CDB_ID__r.RM_Id__r.Parent.RDM_Org_ID__c, 
                            Instinet_CDB_ID__r.Previous_RM__c, 
                            Login_ID__c, Coverage_Login_ID_Detail__c, Product_Region__c, Product__c
                        FROM Instinet_Coverage_Champion_Staging__c 
                        WHERE Instinet_CDB_ID__c IN :instinetMappingIdList AND 
                            RecordType.DeveloperName = 'Instinet_Coverage' AND 
                            Coverage_Login_ID_Detail__c <> null AND 
                            Start_Date__c <> null AND 
                            Has_Ended__c = 0 AND
                            LastModifiedDate > :lastUpdatedDateTime 
                        ORDER BY LastModifiedDate
                    ];
                }
            }


            if(!instinetStagingList.isEmpty()){

                for(Instinet_Coverage_Champion_Staging__c instinetRecordObj : instinetStagingList){
                    String instinetCDBID = String.valueOf(instinetRecordObj.Instinet_CDB_ID__c);
                    List<Instinet_Coverage_Champion_Staging__c> instinetCoverageChampionRecordList = 
                        (instinetCDBIDMap.containsKey(instinetCDBID)) ? instinetCDBIDMap.get(instinetCDBID) : new List<Instinet_Coverage_Champion_Staging__c>();
                    
                    instinetCoverageChampionRecordList.add(instinetRecordObj);

                    instinetCDBIDWithOldRMMap.put(instinetCDBID, instinetRecordObj.Instinet_CDB_ID__r.Previous_RM__c);
                    instinetCDBIDMap.put(instinetCDBID, instinetCoverageChampionRecordList);
                }

                //Process Champion Records
                if(CHAMPION_ENTITY_TYPE.equalsIgnoreCase(entityType)){
                    processChampionRecords(instinetCDBIDWithOldRMMap, instinetCDBIDMap);
                }

                //Process Coverage Records
                if(COVERAGE_ENTITY_TYPE.equalsIgnoreCase(entityType)){
                    processCoverageRecords(instinetCDBIDWithOldRMMap, instinetCDBIDMap);
                }

                
            }
        }
    }

    public void finish(Database.BatchableContext batchableContext){
        
        if(COVERAGE_ENTITY_TYPE.equalsIgnoreCase(entityType)){
            chainAnotherBatch = false;
            clearPreviousRMData();
        }
        
        /*
         * Once Champion records are processed, start the batch for Coverage records
         */
        if(chainAnotherBatch){
            //Process Coverage Records
            Id batchProcessId = Database.executeBatch(new InstinetCDBIDMovementBatchJob('Coverage'),1);
        }
    }

    public void clearPreviousRMData(){
        //Blank out the value in Previous_RM__c field
        List<Instinet_Mapping__c> instinetMappingList = [SELECT Id, CDB_ID__c FROM Instinet_Mapping__c
                                                         WHERE Previous_RM__c <> null];

        if(instinetMappingList != null && instinetMappingList.size() > 0){
            for(Instinet_Mapping__c instinetMappingObj : instinetMappingList){
                instinetMappingObj.Previous_RM__c = '';
            }

            updateInstinetMappingRecords(instinetMappingList);
        }

    }

    public void processChampionRecords(Map<String,String> instinetCDBIDWithOldRMMap,
                                       Map<String,List<Instinet_Coverage_Champion_Staging__c>> instinetCDBIDMap)
    {
        Map<String, Set<String>> accountRMAndsubsetUniqueIDMap = new Map<String, Set<String>>();
        List<Instinet_Coverage_Champion_Staging__c> championRecordDeletionList = new List<Instinet_Coverage_Champion_Staging__c>();
        Set<String> subsetUniqueIDDeletionSet = new Set<String>();
        
        //For each moved CDB ID, find the other records present with CDBID's old RM
        if(!instinetCDBIDWithOldRMMap.isEmpty() && String.isNotEmpty(championLastUpdatedTimestamp)){
            DateTime lastUpdatedDateTime = DateTime.valueOfGmt(championLastUpdatedTimestamp);

            //Fetch Only Active Records
            List<Instinet_Coverage_Champion_Staging__c> activeRecordsWithOldRMAsCurrentList = 
                [
                    SELECT Id, CDB_ID__c, Instinet_CDB_ID__c, 
                    Instinet_CDB_ID__r.RM_Id__c, Instinet_CDB_ID__r.RM_Id__r.RDM_Org_ID__c, 
                    Login_ID__c, Champion_Login_ID_Detail__c,
                    Product_Region__c
                    FROM Instinet_Coverage_Champion_Staging__c
                    WHERE Instinet_CDB_ID__c NOT IN :instinetCDBIDWithOldRMMap.keyset() AND
                     Instinet_CDB_ID__r.RM_Id__r.RDM_Org_ID__c IN :instinetCDBIDWithOldRMMap.values() AND
                     RecordType.DeveloperName = 'Instinet_Champion' AND Product__c = 'Instinet Champion' AND
                     Champion_Login_ID_Detail__c <> null AND
                     Has_Ended__c = 0 AND
                     Instinet_CDB_ID__r.Previous_RM__c = '' AND
                     LastModifiedDate > :lastUpdatedDateTime
                ];
        
            if(activeRecordsWithOldRMAsCurrentList != null && !activeRecordsWithOldRMAsCurrentList.isEmpty()){
                for(Instinet_Coverage_Champion_Staging__c instinetChampionObj : activeRecordsWithOldRMAsCurrentList){
                    String accountRM = String.valueOf(instinetChampionObj.Instinet_CDB_ID__r.RM_Id__c);
                    Set<String> subsetUniqueIDSet = 
                        (accountRMAndsubsetUniqueIDMap.containsKey(accountRM)) ? accountRMAndsubsetUniqueIDMap.get(accountRM) : new Set<String>();

                    String subsetUniqueID = instinetChampionObj.Instinet_CDB_ID__r.RM_Id__r.RDM_Org_ID__c +
                        '#' + instinetChampionObj.Login_ID__c + '#' + instinetChampionObj.Product_Region__c;

                    subsetUniqueIDSet.add(subsetUniqueID);

                    accountRMAndsubsetUniqueIDMap.put(accountRM, subsetUniqueIDSet);
                }
            }
        
        }

        if(!instinetCDBIDWithOldRMMap.isEmpty()){
            //Fetch RDM_Org_ID__c for Previous_RM__c
            Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id, RDM_Org_ID__c FROM Account WHERE Id IN :instinetCDBIDWithOldRMMap.values()]);

            //Check whether record with Old RM exists as active record for Current RM
            for(String instinetCDBID : instinetCDBIDWithOldRMMap.keySet()){
                List<Instinet_Coverage_Champion_Staging__c> instinetChampionWithOldRMList = instinetCDBIDMap.get(instinetCDBID);
                String previousRM = instinetCDBIDWithOldRMMap.get(instinetCDBID);
                String accountRDMOrgId = accountMap.containsKey(previousRM) ? (accountMap.get(previousRM).RDM_Org_Id__c) : '';
                
                if(String.isNotEmpty(accountRDMOrgId)){
                    for(Instinet_Coverage_Champion_Staging__c championRecordObj : instinetChampionWithOldRMList){
                        Boolean recordToBeDeleted = true;
                        String subsetUniqueId = accountRDMOrgId + '#' + championRecordObj.Login_ID__c + '#' + championRecordObj.Product_Region__c;
                        
                        if(accountRMAndsubsetUniqueIDMap.containsKey(previousRM)){
                             Set<String> subsetUniqueIDSet = accountRMAndsubsetUniqueIDMap.get(previousRM);
                             //If record is not present then add the record for deletion
                             if(subsetUniqueIDSet.contains(subsetUniqueId)) {
                                 recordToBeDeleted = false;
                             }  
                        }

                        if(recordToBeDeleted){
                            championRecordDeletionList.add(championRecordObj);
                            subsetUniqueIDDeletionSet.add(subsetUniqueId);
                        }
                    }
                }
            }
        }

        if(!championRecordDeletionList.isEmpty() && !subsetUniqueIDDeletionSet.isEmpty()){
            List<Instinet_Coverage_Champion_Aggregated__c> instinetChampionAggregatedList = 
                [
                    SELECT Id, Champion_Login_ID_Detail__c, Product_Region__c, Account__c
                    FROM Instinet_Coverage_Champion_Aggregated__c
                    WHERE Subset_Unique_ID__c IN :subsetUniqueIDDeletionSet
                        AND Active__c = true AND RecordType.DeveloperName = 'Instinet_Champion'
                ];

            if(!instinetChampionAggregatedList.isEmpty()) {
                for(Instinet_Coverage_Champion_Aggregated__c instinetChampionRecordObj : instinetChampionAggregatedList){
                    //Change only the Active__c flag. No need to change the Unique_ID__c field. 
                    //Because InstinetChampionStagingBatchjob will anyways delete this record. And new active record will get inserted
                    instinetChampionRecordObj.Active__c = false;
                }

                updateInstinetAggregatedRecords(instinetChampionAggregatedList);
            }
        }
    }

    public void processCoverageRecords(Map<String,String> instinetCDBIDWithOldRMMap,
                                       Map<String,List<Instinet_Coverage_Champion_Staging__c>> instinetCDBIDMap)
    {

        Map<String, Set<String>> accountRMAndsubsetUniqueIDMap = new Map<String, Set<String>>();
        List<Instinet_Coverage_Champion_Staging__c> coverageRecordDeletionList = new List<Instinet_Coverage_Champion_Staging__c>();
        Set<String> subsetUniqueIDDeletionSet = new Set<String>();

        //Fetch Instinet Nomura Product Mappings
        Map<String,List<Instinet_Product_Mapping__mdt>> instinetNomuraProductMapping = getInstinetNomuraProductMappingList();

        //For each moved CDB ID, find the other records present with CDBID's old RM
        if(!instinetCDBIDWithOldRMMap.isEmpty() && String.isNotEmpty(coverageLastUpdatedTimestamp)){
            DateTime lastUpdatedDateTime = DateTime.valueOfGmt(coverageLastUpdatedTimestamp);

            //Fetch Only Active Records
            List<Instinet_Coverage_Champion_Staging__c> activeRecordsWithOldRMAsCurrentList = 
                [
                    SELECT Id, CDB_ID__c, Instinet_CDB_ID__c, 
                    Instinet_CDB_ID__r.RM_Id__c, Instinet_CDB_ID__r.RM_Id__r.RDM_Org_ID__c, 
                    Login_ID__c, Coverage_Login_ID_Detail__c,
                    Product_Region__c, Product__c
                    FROM Instinet_Coverage_Champion_Staging__c
                    WHERE Instinet_CDB_ID__c NOT IN :instinetCDBIDWithOldRMMap.keyset() AND
                     Instinet_CDB_ID__r.RM_Id__r.RDM_Org_ID__c IN :instinetCDBIDWithOldRMMap.values() AND
                     Instinet_CDB_ID__r.RM_Id__r.RDM_Org_ID__c <> 'RM000000' AND
                     RecordType.DeveloperName = 'Instinet_Coverage' AND
                     Coverage_Login_ID_Detail__c <> null AND
                     Has_Ended__c = 0 AND
                     Instinet_CDB_ID__r.Previous_RM__c = '' AND 
                     LastModifiedDate > :lastUpdatedDateTime
                ];

             if(activeRecordsWithOldRMAsCurrentList != null && !activeRecordsWithOldRMAsCurrentList.isEmpty()){
                 for(Instinet_Coverage_Champion_Staging__c instinetCoverageObj : activeRecordsWithOldRMAsCurrentList){
                    String accountRM = String.valueOf(instinetCoverageObj.Instinet_CDB_ID__r.RM_Id__c);
                    
                    Set<String> subsetUniqueIDSet = 
                        (accountRMAndsubsetUniqueIDMap.containsKey(accountRM)) ? accountRMAndsubsetUniqueIDMap.get(accountRM) : new Set<String>();

                    String instinetProduct =  instinetCoverageObj.Product_Region__c + '#' + instinetCoverageObj.Product__c;
                    instinetProduct = instinetProduct.toUpperCase();

                    if(instinetNomuraProductMapping.containsKey(instinetProduct)){
                        for(Instinet_Product_Mapping__mdt prdMapping :instinetNomuraProductMapping.get(instinetProduct)){

                            String subsetUniqueID = instinetCoverageObj.Instinet_CDB_ID__r.RM_Id__r.RDM_Org_ID__c +
                                '#' + instinetCoverageObj.Login_ID__c + 
                                '#' + prdMapping.Nomura_Region__c + '#' + prdMapping.Nomura_Product__c;

                            subsetUniqueIDSet.add(subsetUniqueID);
                        }
                        accountRMAndsubsetUniqueIDMap.put(accountRM, subsetUniqueIDSet);   
                    }
                 }
             }    
        }

        if(!instinetCDBIDWithOldRMMap.isEmpty()){
            //Fetch RDM_Org_ID__c for Previous_RM__c
            Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id, RDM_Org_ID__c FROM Account WHERE Id IN :instinetCDBIDWithOldRMMap.values()]);

            //Check whether record with Old RM exists as active record for Current RM
            for(String instinetCDBID : instinetCDBIDWithOldRMMap.keySet()){
                List<Instinet_Coverage_Champion_Staging__c> instinetCoverageWithOldRMList = instinetCDBIDMap.get(instinetCDBID);
                String previousRM = instinetCDBIDWithOldRMMap.get(instinetCDBID);
                String accountRDMOrgId = accountMap.containsKey(previousRM) ? (accountMap.get(previousRM).RDM_Org_Id__c) : '';
                
                if(String.isNotEmpty(accountRDMOrgId)){
                    for(Instinet_Coverage_Champion_Staging__c coverageRecordObj : instinetCoverageWithOldRMList){
                        
                        String instinetProduct =  coverageRecordObj.Product_Region__c + '#' + coverageRecordObj.Product__c;
                        instinetProduct = instinetProduct.toUpperCase();
                        
                        if(instinetNomuraProductMapping.containsKey(instinetProduct)){
                            for(Instinet_Product_Mapping__mdt prdMapping :instinetNomuraProductMapping.get(instinetProduct)){
                                Boolean recordToBeDeleted = true;

                                 String subsetUniqueId = accountRDMOrgId + 
                                    '#' + coverageRecordObj.Login_ID__c + 
                                    '#' + prdMapping.Nomura_Region__c + '#' + prdMapping.Nomura_Product__c;

                                 if(accountRMAndsubsetUniqueIDMap.containsKey(previousRM)){
                                    Set<String> subsetUniqueIDSet = accountRMAndsubsetUniqueIDMap.get(previousRM);
                                    if(subsetUniqueIDSet.contains(subsetUniqueId)) {
                                        recordToBeDeleted = false;
                                    }  
                                }

                                //If record is not present then add the record for deletion
                                if(recordToBeDeleted){
                                    coverageRecordDeletionList.add(coverageRecordObj);
                                    subsetUniqueIDDeletionSet.add(subsetUniqueId);
                                }       
                            }
                        }   
                    }
                }
            }
        }

        if(!coverageRecordDeletionList.isEmpty() && !subsetUniqueIDDeletionSet.isEmpty()){
            List<Instinet_Coverage_Champion_Aggregated__c> instinetCoverageAggregatedList = 
                [
                    SELECT Id, Coverage_Login_ID_Detail__c, Product_Region__c, Product__c, Account__c
                    FROM Instinet_Coverage_Champion_Aggregated__c
                    WHERE Subset_Unique_ID__c IN :subsetUniqueIDDeletionSet
                        AND Active__c = true AND RecordType.DeveloperName = 'Instinet_Coverage'
                ];

            if(!instinetCoverageAggregatedList.isEmpty()) {
                for(Instinet_Coverage_Champion_Aggregated__c instinetCoverageRecordObj : instinetCoverageAggregatedList){
                    //Change only the Active__c flag and End_Date__c
                    //No need to change the Unique_ID__c field. 
                    //Because InstinetCoverageStagingBatchjob will anyways delete this record. And new active record will get inserted
                    instinetCoverageRecordObj.Active__c = false;
                    instinetCoverageRecordObj.End_Date__c = Date.today();
                }

                updateInstinetAggregatedRecords(instinetCoverageAggregatedList);
            }
        }


    }

    public Map<String,List<Instinet_Product_Mapping__mdt>> getInstinetNomuraProductMappingList(){
        Map<String,List<Instinet_Product_Mapping__mdt>> instinetNomuraProductMapping = new Map<String,List<Instinet_Product_Mapping__mdt>>();

        List<Instinet_Product_Mapping__mdt> instinetNomuraProductList = 
            [
             SELECT Instinet_Product__c, Instinet_Region__c,
             Nomura_Product__c, Nomura_Region__c 
             FROM Instinet_Product_Mapping__mdt 
             WHERE Nomura_Product__c <> '' AND Nomura_Region__c <> '' AND Instinet_Product__c <> '' AND Instinet_Region__c <> ''
            ];

        if(instinetNomuraProductList != null && !instinetNomuraProductList.isEmpty()){
            for(Instinet_Product_Mapping__mdt prdMapping : instinetNomuraProductList){
            	String instinetProduct = prdMapping.Instinet_Region__c + '#' + prdMapping.Instinet_Product__c;
                instinetProduct = instinetProduct.toUpperCase();
               	List<Instinet_Product_Mapping__mdt> nomuraProductList = 
                        instinetNomuraProductMapping.containsKey(instinetProduct) ? instinetNomuraProductMapping.get(instinetProduct) : new List<Instinet_Product_Mapping__mdt>();
                nomuraProductList.add(prdMapping);
                instinetNomuraProductMapping.put(instinetProduct, nomuraProductList);
            }
        }

        return instinetNomuraProductMapping;
    }

    public void updateInstinetAggregatedRecords(List<Instinet_Coverage_Champion_Aggregated__c> instinetRecordsList){
        if(instinetRecordsList != null && !instinetRecordsList.isEmpty()){
            List<Database.SaveResult> resultList = Database.update(instinetRecordsList, false); 
            for(Integer i=0; i<resultList.size(); i++){            
                Database.SaveResult resultObj = resultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        if(String.isNotEmpty(errorObj.getMessage())){
                            instinetRecordErrorUpdateList.add(instinetRecordsList.get(i));
                        }
                    }
                }
            }
        }
    }

    public void updateInstinetMappingRecords(List<Instinet_Mapping__c> instinetMappingList){
        if(instinetMappingList != null && !instinetMappingList.isEmpty()){
            List<Database.SaveResult> resultList = Database.update(instinetMappingList, false); 
            for(Integer i=0; i<resultList.size(); i++){            
                Database.SaveResult resultObj = resultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        if(String.isNotEmpty(errorObj.getMessage())){
                            instinetMappingErrorUpdateList.add(instinetMappingList.get(i));
                        }
                    }
                }
            }
        }
    }
}