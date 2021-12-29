public class InstinetCoverageAggregatedBatchJob implements Database.Batchable<sObject>,Database.Stateful {
    public static final String PRODUCT_GROUP = 'Equity';
    public List<Coverage_Team_Member__c> errorInsertList;
    public List<Coverage_Team_Member__c> errorDeleteList;
    public List<Coverage_Team_Member__c> errorUpdateList;
    public Id inactiveCoverageRecordTypeId = null;
    public Id activeCoverageRecordTypeId = null;
    public Boolean chainAnotherBatch = true;
    public Boolean activeFlag;
    
    public InstinetCoverageAggregatedBatchJob(Boolean bActiveFlag) {
        errorInsertList = new List<Coverage_Team_Member__c>();
        errorDeleteList = new List<Coverage_Team_Member__c>();
        errorUpdateList = new List<Coverage_Team_Member__c>();
        inactiveCoverageRecordTypeId = CommonTools.getRecordTypeId('Coverage_Team_Member__c', 'Inactive Coverage');
        activeCoverageRecordTypeId = CommonTools.getRecordTypeId('Coverage_Team_Member__c', 'Active Coverage');
        activeFlag = bActiveFlag;
    }

    public Database.QueryLocator start(Database.BatchableContext batchableContext){
        String query = null;
        String lastUpdatedTimestamp = CommonTools.getParameterValueFromConfiguration('Instinet_Coverage_Aggregated','LastUpdatedTimeStamp',true);
        
        if(String.isNotEmpty(lastUpdatedTimestamp)){
            //Make sure all inactive records gets processed first
            /*
             * Here we are not using ORDER By Active__c flag to process both active and inactive records simultaneously
             * As the order is not guaranteed
             */
            query = 'SELECT Id, Coverage_Login_ID_Detail__c, Coverage_Login_ID_Detail__r.Coverage_ID__c,'
            + 'Coverage_Login_ID_Detail__r.Active__c, Coverage_Login_ID_Detail__r.is_Dummy__c, Coverage_Login_ID_Detail__r.Is_Leaver__c, '
            + 'Coverage_Login_ID_Detail__r.Sales_Code_Login_ID__c, Coverage_Login_ID_Detail__r.Is_Split_Sales_Code__c, '
            + 'Coverage_Login_ID_Detail__r.Company__c, Coverage_Login_ID_Detail__r.Owner_Active__c, '
            + 'Account__c, Account__r.RDM_Org_ID__c, Account__r.Active__c, Account__r.BillingCountry, ' 
            + 'Account__r.ParentId, Account__r.Parent.Active__c, '
            + 'Product_Region__c, Product__c, Active__c, ' 
            + 'Start_Date__c, End_Date__c, '
            + 'Unique_ID__c, Subset_Unique_ID__c '
            + 'FROM Instinet_Coverage_Champion_Aggregated__c '
            + 'WHERE RecordType.DeveloperName = \'Instinet_Coverage\' AND ' 
            + 'Account__r.RDM_Org_ID__c <> null AND '
            + 'Account__r.RDM_Org_ID__c <> \'RM000000\' AND '
            + 'Account__r.Active__c = TRUE AND '
            + 'Coverage_Login_ID_Detail__r.Active__c = TRUE AND '
            + 'LastModifiedDate > ' + lastUpdatedTimestamp + ' AND Active__c = ' + (activeFlag ? 'true' : 'false');

            System.debug('query:'+query);
        }

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext batchableContext, List<sObject> scope){
        List<Instinet_Coverage_Champion_Aggregated__c> inactiveInstinetCoverageList = new List<Instinet_Coverage_Champion_Aggregated__c>();
        List<Instinet_Coverage_Champion_Aggregated__c> activeInstinetCoverageList = new List<Instinet_Coverage_Champion_Aggregated__c>();

        List<Instinet_Coverage_Champion_Aggregated__c> instinetCoverageList = (List<Instinet_Coverage_Champion_Aggregated__c>)scope;
        if(instinetCoverageList != null && !instinetCoverageList.isEmpty())
        {
            for(Instinet_Coverage_Champion_Aggregated__c aggregatedCoverageObj : instinetCoverageList){
                if(aggregatedCoverageObj.Active__c){
                    activeInstinetCoverageList.add(aggregatedCoverageObj);
                }
                else {
                    inactiveInstinetCoverageList.add(aggregatedCoverageObj);
                }
            }

            //Process Inactive Records
            if(!inactiveInstinetCoverageList.isEmpty()){
                processInactiveInstinetCoverageRecords(inactiveInstinetCoverageList);
            }

            //Process Active Records
            if(!activeInstinetCoverageList.isEmpty()){
                processActiveInstinetCoverageRecords(activeInstinetCoverageList);
            }
        }
    }

    public void finish(Database.BatchableContext batchableContext){
        
        if(activeFlag == true){
            chainAnotherBatch = false;
        }

        /*
         * Once inactive records are processed, start the batch for active records
         */
        if(chainAnotherBatch){
            //Process Active Records
            Id batchProcessId = Database.executeBatch(new InstinetCoverageAggregatedBatchJob(true), 5);
        }
        else {
            /*
            *  Update the timestamp in Configuration__c for Instinet_Coverage_Aggregated entry 
            *  by fetching the MAX(LastModifiedDate) from Instinet_Coverage_Champion_Aggregated__c records 
            */
            AggregateResult aggregateResultObj = [SELECT MAX(LastModifiedDate) LastModifiedDate FROM Instinet_Coverage_Champion_Aggregated__c 
                                                WHERE RecordType.DeveloperName = 'Instinet_Coverage'];

            if(aggregateResultObj != null){
                DateTime lastModifiedDate = DateTime.valueOf(aggregateResultObj.get('LastModifiedDate'));
                String strLastModifiedDate = lastModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                if(String.isNotEmpty(strLastModifiedDate)){
                    CommonTools.updateParameterValueInConfiguration('Instinet_Coverage_Aggregated','LastUpdatedTimeStamp', strLastModifiedDate);
                }
            }

            //Chain Another Batch
            if(!Test.isRunningTest()){
	            Id batchProcessId = Database.executeBatch(new InstinetFlagComputationOnAccountBatchJob(), 100);
            }
        }  

   
    }

    public void processInactiveInstinetCoverageRecords(List<Instinet_Coverage_Champion_Aggregated__c> inactiveInstinetCoverageList){
        Set<String> inactiveUniqueIDSet = new Set<String>();
        Set<String> activeUniqueIDSet = new Set<String>();
        Set<String> recordProcessedSet = new Set<String>();
        List<Coverage_Team_Member__c> inactiveInstinetCoverageTeamMemberList = new List<Coverage_Team_Member__c>();
        Map<String,Coverage_Team_Member__c> updateActiveInstinetCoverageToInactiveMap = new Map<String,Coverage_Team_Member__c>();
        Map<String, Coverage_Team_Member__c> activeInstinetCoverageMap = new Map<String, Coverage_Team_Member__c>();
        
        
        for(Instinet_Coverage_Champion_Aggregated__c inactiveInstinetCoverageObj : inactiveInstinetCoverageList){
            String uniqueID = formUniqueIdPart(inactiveInstinetCoverageObj);

            String activeUniqueID =   uniqueID + 'FALSE' ;
            activeUniqueIDSet.add(activeUniqueID);

            String inactiveUniqueID =   uniqueID + 'TRUE' ;
            inactiveUniqueIDSet.add(inactiveUniqueID);
        }

        /*
         * Check whether inactive record is already present. 
         * If yes we need to replace 'TRUE' part in UniqueId__c field with PREVDELETE and Id
         * Because UniqueId__c old logic is built this way
         */
        if(!inactiveUniqueIDSet.isEmpty()){
            List<Coverage_Team_Member__c> alreadyInactiveInstinetCoverageList = 
                            [SELECT Id, UniqueId__c FROM Coverage_Team_Member__c
                             WHERE UniqueId__c IN :inactiveUniqueIDSet];

            if(alreadyInactiveInstinetCoverageList != null && !alreadyInactiveInstinetCoverageList.isEmpty()) {
                for(Coverage_Team_Member__c inactiveInstinetCoverageObj : alreadyInactiveInstinetCoverageList){
                    inactiveInstinetCoverageObj.UniqueId__c = String.valueOf(inactiveInstinetCoverageObj.uniqueId__c).replace('TRUE','PREVDELETE') + '#' + inactiveInstinetCoverageObj.Id;
                }

                //Perform Update
                updateInstinetCoverageRecords(alreadyInactiveInstinetCoverageList);
            }
        }

        /*
         * Check whether active record is already present. 
         * If yes we need to make it inactive
         */
        if(!activeUniqueIDSet.isEmpty()){
            List<Coverage_Team_Member__c> activeInstinetCoverageList = 
                            [SELECT Id, UniqueId__c, End_Date__c, Is_Deleted__c, RecordTypeId FROM Coverage_Team_Member__c
                             WHERE UniqueId__c IN :activeUniqueIDSet];

            if(activeInstinetCoverageList != null && !activeInstinetCoverageList.isEmpty()) {

                for(Coverage_Team_Member__c activeInstinetCoverageObj : activeInstinetCoverageList) {
                    activeInstinetCoverageMap.put(activeInstinetCoverageObj.UniqueId__c, activeInstinetCoverageObj);
                }     
                
                for(Instinet_Coverage_Champion_Aggregated__c inactiveInstinetCoverageObj : inactiveInstinetCoverageList){
                    String uniqueId =  String.valueOf(formUniqueIdPart(inactiveInstinetCoverageObj));
                    String activeUniqueId =  uniqueId + 'FALSE'; // Check whether active version of inactive record is present
                    String inactiveUniqueId =  uniqueId + 'TRUE';

                    if(activeInstinetCoverageMap.containsKey(activeUniqueId)) {
                        Coverage_Team_Member__c coverageTeamMemberObj = activeInstinetCoverageMap.get(activeUniqueId);
                        
                        coverageTeamMemberObj.UniqueId__c = inactiveUniqueId;
                        coverageTeamMemberObj.End_Date__c = inactiveInstinetCoverageObj.End_Date__c;
                        coverageTeamMemberObj.Is_Deleted__c = TRUE;
                        coverageTeamMemberObj.RecordTypeId = inactiveCoverageRecordTypeId;
                        
                        updateActiveInstinetCoverageToInactiveMap.put(inactiveUniqueId, coverageTeamMemberObj);

                        recordProcessedSet.add(inactiveInstinetCoverageObj.Id);
                    }   
                }

                //Perform Update
                if(!updateActiveInstinetCoverageToInactiveMap.isEmpty()){
                    updateInstinetCoverageRecords(updateActiveInstinetCoverageToInactiveMap.values());
                }
            }
        }

        /*
         * Insert remaining records as inactive
         */
        for(Instinet_Coverage_Champion_Aggregated__c inactiveInstinetCoverageObj : inactiveInstinetCoverageList){
            if(!recordProcessedSet.contains(inactiveInstinetCoverageObj.Id)){
                inactiveInstinetCoverageTeamMemberList.add(formCoverageTeamMember(inactiveInstinetCoverageObj));
            }
        }

        if(!inactiveInstinetCoverageTeamMemberList.isEmpty()){
            populateTeamMemberFieldData(inactiveInstinetCoverageTeamMemberList);

            insertInstinetCoverageRecords(inactiveInstinetCoverageTeamMemberList);
        } 
    }

    public void processActiveInstinetCoverageRecords(List<Instinet_Coverage_Champion_Aggregated__c> activeInstinetCoverageList){
        Set<String> activeUniqueIDSet = new Set<String>();
        Set<String> recordProcessedSet = new Set<String>();
        Map<String,Coverage_Team_Member__c> activeCoverageMapBasedOnUniqueId = new Map<String,Coverage_Team_Member__c>();
        List<Coverage_Team_Member__c> activeInstinetCoverageTeamMemberList = new List<Coverage_Team_Member__c>();
        Map<String,Coverage_Team_Member__c> updateInstinetCoverageTeamMemberMap = new Map<String,Coverage_Team_Member__c>();

        /*
         * In case of active Instinet records, if active record is already present then we need to change its Start_Date__c
         */
        for(Instinet_Coverage_Champion_Aggregated__c activeInstinetCoverageObj : activeInstinetCoverageList){
            String uniqueID = formUniqueIdPart(activeInstinetCoverageObj);

            String activeUniqueID = uniqueID + 'FALSE' ;
            activeUniqueIDSet.add(activeUniqueID);
        }

        if(!activeUniqueIDSet.isEmpty()){
            List<Coverage_Team_Member__c> activeCoverageList = [SELECT Id, UniqueId__c, Start_Date__c FROM Coverage_Team_Member__c 
                                                                WHERE UniqueId__c IN :activeUniqueIDSet];

            if(activeCoverageList != null && !activeCoverageList.isEmpty()){
                for(Coverage_Team_Member__c coverageTeamMemberObj : activeCoverageList){
                   activeCoverageMapBasedOnUniqueId.put(coverageTeamMemberObj.UniqueId__c, coverageTeamMemberObj);
                }
            }    
        }

        for(Instinet_Coverage_Champion_Aggregated__c activeInstinetCoverageObj : activeInstinetCoverageList){
            String uniqueID = formUniqueIdPart(activeInstinetCoverageObj);
            String activeUniqueID = uniqueID + 'FALSE' ;
            if(activeCoverageMapBasedOnUniqueId.containsKey(activeUniqueID)){
                //Only Start Date can change
                Coverage_Team_Member__c coverageTeamMemberObj = activeCoverageMapBasedOnUniqueId.get(activeUniqueID);
                coverageTeamMemberObj.Start_Date__c = activeInstinetCoverageObj.Start_Date__c;
                updateInstinetCoverageTeamMemberMap.put(activeUniqueID, coverageTeamMemberObj);
                
                recordProcessedSet.add(activeInstinetCoverageObj.Id);
            }
        }

        //Perform Update
        if(!updateInstinetCoverageTeamMemberMap.isEmpty()){
            updateInstinetCoverageRecords(updateInstinetCoverageTeamMemberMap.values());
        }

        //Insert remaining active records
        for(Instinet_Coverage_Champion_Aggregated__c activeInstinetCoverageObj : activeInstinetCoverageList){
            if(!recordProcessedSet.contains(activeInstinetCoverageObj.Id)){
                activeInstinetCoverageTeamMemberList.add(formCoverageTeamMember(activeInstinetCoverageObj));
            }
        }

        if(!activeInstinetCoverageTeamMemberList.isEmpty()){
            populateTeamMemberFieldData(activeInstinetCoverageTeamMemberList);

            insertInstinetCoverageRecords(activeInstinetCoverageTeamMemberList);
        }
    }

    public String formUniqueIdPart(Instinet_Coverage_Champion_Aggregated__c instinetCoverageObj){
        String uniqueID = instinetCoverageObj.Account__r.RDM_Org_ID__c + '#'
            + instinetCoverageObj.Coverage_Login_ID_Detail__r.Sales_Code_Login_ID__c + '#'
            + instinetCoverageObj.Coverage_Login_ID_Detail__r.Coverage_ID__c + '#'
            + PRODUCT_GROUP + '#'
            + instinetCoverageObj.Product__c + ' - ' + instinetCoverageObj.Product_Region__c + '#';

        return uniqueID;
    }

    public Coverage_Team_Member__c formCoverageTeamMember(Instinet_Coverage_Champion_Aggregated__c instinetCoverageAggregatedObj){
        Coverage_Team_Member__c coverageTeamMemberObj = new Coverage_Team_Member__c();
        String uniqueID = formUniqueIdPart(instinetCoverageAggregatedObj);
        
        if(instinetCoverageAggregatedObj.Active__c){
            coverageTeamMemberObj.RecordTypeId = activeCoverageRecordTypeId;
            coverageTeamMemberObj.Is_Deleted__c = FALSE;
            coverageTeamMemberObj.UniqueId__c = uniqueID + 'FALSE' ;
        }
        else {
             coverageTeamMemberObj.RecordTypeId = inactiveCoverageRecordTypeId;
             coverageTeamMemberObj.End_Date__c = instinetCoverageAggregatedObj.End_Date__c;
             coverageTeamMemberObj.Is_Deleted__c = TRUE;
             coverageTeamMemberObj.UniqueId__c = uniqueID + 'TRUE' ;
        }
        coverageTeamMemberObj.Sales_Team_for_Coverage__c = instinetCoverageAggregatedObj.Coverage_Login_ID_Detail__c;
        coverageTeamMemberObj.Account__c = instinetCoverageAggregatedObj.Account__c;
        coverageTeamMemberObj.RG_Account__c = instinetCoverageAggregatedObj.Account__r.ParentId;

        coverageTeamMemberObj.Start_Date__c = instinetCoverageAggregatedObj.Start_Date__c;
        coverageTeamMemberObj.Team_Role__c = 'Primary';

        coverageTeamMemberObj.Product_Group__c = PRODUCT_GROUP;
        coverageTeamMemberObj.Product_Region__c = instinetCoverageAggregatedObj.Product_Region__c;
        coverageTeamMemberObj.Product__c = instinetCoverageAggregatedObj.Product__c;
        coverageTeamMemberObj.Product2__c = instinetCoverageAggregatedObj.Product__c;

        coverageTeamMemberObj.Account_Access__c = 'Read/Write';
        coverageTeamMemberObj.Contact_Access__c = 'Read/Write';
        coverageTeamMemberObj.Opportunity_Access__c = 'Private';
        coverageTeamMemberObj.Case_Access__c = 'Private';
        
        return coverageTeamMemberObj;
    }

    public void populateTeamMemberFieldData(List<Coverage_Team_Member__c> coverageTeamMemberList){
        /*
         * In RG_Coverage_Request__c Object, for dummy sales codes, Team_Member__c field contains the data of logged-in user. 
         * And for non dummy sales codes, it gets the data from CoverageRequestUtility.fetchRequestedForUserForRGRequest() method.
         * Here we follow the same logic. But logged-in user will always be sfadmin as we will run this job using sfadmin user
         * Also if there is no entry in Sales_Team_User__c object for any sales code then Team_Member__c will contain sfadmin's Id
         */
         Set<Id> salesCodeRecordIdSet = new Set<Id>();
         Map<Id,User> salesCodeAndUserMap = new Map<Id,User>();
         Id currentUserId = UserInfo.getUserId();
         Map<Id,Sales_Team_for_Coverage__c> dummySalesCodeMap = new Map<Id,Sales_Team_for_Coverage__c>();

         for(Coverage_Team_Member__c coverageTeamMemberObj : coverageTeamMemberList){
             salesCodeRecordIdSet.add(coverageTeamMemberObj.Sales_Team_for_Coverage__c);
         }

         if(!salesCodeRecordIdSet.isEmpty()){
             dummySalesCodeMap = new Map<Id,Sales_Team_for_Coverage__c>([
                 SELECT Id, is_Dummy__c FROM Sales_Team_for_Coverage__c
                 WHERE is_Dummy__c = TRUE AND Id IN :salesCodeRecordIdSet
             ]);
         }

         salesCodeAndUserMap = CoverageRequestUtility.fetchRequestedForUserForRGRequest(salesCodeRecordIdSet);  

         for(Coverage_Team_Member__c coverageTeamMemberObj : coverageTeamMemberList){
             Id salesCodeRecordId = coverageTeamMemberObj.Sales_Team_for_Coverage__c;
             if(dummySalesCodeMap != null && dummySalesCodeMap.containsKey(salesCodeRecordId)) //Dummy sales Code
             {
                coverageTeamMemberObj.Team_Member__c = currentUserId;
             }
             else if(salesCodeAndUserMap != null  && salesCodeAndUserMap.containsKey(salesCodeRecordId)) //Non Dummy sales Code
             {
                coverageTeamMemberObj.Team_Member__c = salesCodeAndUserMap.get(salesCodeRecordId).Id;
             }
         }
    }

    
    public void updateInstinetCoverageRecords(List<Coverage_Team_Member__c> instinetCoverageList){
        if(instinetCoverageList != null && !instinetCoverageList.isEmpty()){
            
            List<Database.SaveResult> resultList = Database.update(instinetCoverageList, false); 
            for(Integer i=0; i<resultList.size(); i++){            
                Database.SaveResult resultObj = resultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        if(String.isNotEmpty(errorObj.getMessage())){
                            errorUpdateList.add(instinetCoverageList.get(i));
                        }
                    }
                }
            }
        }
    }

    public void insertInstinetCoverageRecords(List<Coverage_Team_Member__c> instinetCoverageList){
        if(instinetCoverageList != null && !instinetCoverageList.isEmpty()){
            
            List<Database.SaveResult> resultList = Database.insert(instinetCoverageList, false); 
            for(Integer i=0; i<resultList.size(); i++){            
                Database.SaveResult resultObj = resultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        
                        if(String.isNotEmpty(errorObj.getMessage()) 
                            && !errorObj.getMessage().contains('duplicate value found: UniqueId__c duplicates value')){
                            Coverage_Team_Member__c testObj = instinetCoverageList.get(i);
                            errorInsertList.add(instinetCoverageList.get(i));
                        }
                    }
                }
            }
        }
    }

    
}