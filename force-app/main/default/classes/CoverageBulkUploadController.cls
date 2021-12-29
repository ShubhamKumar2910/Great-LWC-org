global without sharing class CoverageBulkUploadController {
    
    public static Integer totalCount{get;set;}
    public static Integer totalFailed{get;set;}
    public static Integer totalSuccess{get;set;}
    public static Integer totalWarning{get;set;}
    public static string FLAG_NFPE = CoverageUtil.FLAG_NFPE;
    public static string FLAG_NFPE1 = CoverageUtil.FLAG_NFPE1;
    public static string FLAG_NFPE_SUBTYPE1 = CoverageUtil.FLAG_NFPE_SUBTYPE1;
    public static string FLAG_NFPE_SUBTYPE2 = CoverageUtil.FLAG_NFPE_SUBTYPE2;
	public static string FLAG_NFPE_SUBTYPE3 = CoverageUtil.FLAG_NFPE_SUBTYPE3;
    //Added FLAG_NFPE_SUBTYPE1_1,FLAG_NFPE_SUBTYPE3_1 JIRA Sales 3660 
    public static string FLAG_NFPE_SUBTYPE3_1 = CoverageUtil.FLAG_NFPE_SUBTYPE3_1;
    public static string FLAG_NFPE_SUBTYPE1_1 = CoverageUtil.FLAG_NFPE_SUBTYPE1_1;
	//added for JIRA 1588
	public static String strOpportunityflow = CoverageUtil.CROSS_SELL_REFERRAL;
    public static List<CoverageWrapper> xlRecords{get;set;}
    public static List<CoverageWrapper> xlRecords_With_Errors{get;set;}
    public static Map<string,string> existing_coverages_nfpe_request = new Map<string,string>();
    public static List<Coverage_Temp__c> coveragesToInsert{get;set;} //Staging object
    public static Boolean processedSuccessfully {get;set;}
    public static Boolean containsValidationError{get;set;}
    public static string currentbatchId{get;set;}
    public static string isCommentAccessible = '';
    public static string msgType{get;set;}
    public static string csvString{get;set;}
    private static  String exception_message{get;set;}
    private static  String guid{get;set;}
    public static Map<string, Set<string>> rgRMmap = new Map<string, Set<string>>();
    public static Map<string, string> rmRGmap = new Map<string, string>();
    public static Set<String> uniqueKeyforDelete = new Set<string>();  
    public static Map<Id, User> currentUser = new Map<Id,User>();
    public static set<string> productRegionCombinationSetCSV = new Set<string>();
	public static string source{get;set;} //CSV or CVGTOOL
    public static Set<string> coverageTypes = new Set<string>();
    public static Set<string> withProductKeys = new Set<string>();
    static string EQ = coverageutil.EQUITY;
    static string FI = coverageutil.FIXED_INCOME;
    static string IB = coverageutil.INVESTMENT_BANKING;
    //Iniitialisation 
    public static void initializeValues()
    {
        currentbatchId = '';
        totalCount = 0;
        totalFailed = 0;
        totalWarning = 0;
        totalSuccess=0;
        msgType = 'slds-theme_info slds-hide';
        exception_message = '';
        xlRecords = new List<CoverageWrapper>();
        xlRecords_With_Errors = new List<CoverageWrapper>();
        coveragesToInsert = new List<Coverage_Temp__c>();
        containsValidationError = false;
        processedSuccessfully = false;     
    }
    
    
    //constructor
    public CoverageBulkUploadController(){
        try
        {
            initializeValues();
        }
        catch(Exception e)
        {
            exception_message += e+'\n'+e.getStackTraceString();
            exception_message += '\n';
            processedSuccessfully = false;
            system.debug('Exception (Constructor) : '+exception_message);
        }
        
    }
    
    
    //Method to convert json into list<CSVRecords>
    public static void parseJSONString(String jsonStr) {
        if(jsonStr!=null && jsonStr!='')
        {
            xlRecords = new List<CoverageWrapper>();
            JSONParser parser = JSON.createParser(jsonStr);
            totalCount = 0;
            
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while (parser.nextToken() != null) {
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) 
                        {
                            CoverageWrapper coverage = (CoverageWrapper)parser.readValueAs(CoverageWrapper.class);
                            system.debug('coverage ** ' + coverage);
                            //Fix for 3698
                            /*if(coverage.coverageType!=null && coverage.coverageType!='Standard' && coverage.coverageType.tolowerCase()!='cross sell')
                            {
                                coverage.clientRGKey = '';
                            }
                            if(coverage.Type!=null && coverage.Type!='')
                            {
                                coverageTypes.addAll(coverage.Type.split(','));
                            }*/
                            coverage.containsError = false;

                            //For Include Restricted Accounts
                            /* if('FALSE'.equalsIgnoreCase(coverage.includeRestrictedAccounts)){
                                coverage.includeRestrictedAccounts = 'False';
                            }
                            else {
                                coverage.includeRestrictedAccounts = 'True';
                            } */

                            if('YES'.equalsIgnoreCase(coverage.includeRestrictedAccounts) || coverage.includeRestrictedAccounts=='Y' || coverage.includeRestrictedAccounts==''){
                                coverage.includeRestrictedAccounts = 'True';
                            }
                            else {
                                coverage.includeRestrictedAccounts = 'False';
                            }
                        
                            xlRecords.add(coverage);
                            
                            if(coverage.clientRGKey!=null && coverage.clientRGKey!='')
                            {
                                CoverageBulkUploadUtility.csvRGIds.add(coverage.clientRGKey);
                            }
                            
                            if(coverage.clientKey!=null && coverage.clientKey!='')    
                                CoverageBulkUploadUtility.csvRMIds.add(coverage.clientKey);
                           
                            if(coverage.salesCode!=null && coverage.salesCode!='')
                            {
                                string salesCodeModified = '';
                                if(coverage.salesCode.trim().length() == 3)
                                    salesCodeModified = '0'+coverage.salesCode.trim();
                                else if(coverage.salesCode.trim().length() == 2)
                                    salesCodeModified = '00'+coverage.salesCode.trim();
                                else if(coverage.salesCode.trim().length() == 1)
                                    salesCodeModified = '000'+coverage.salesCode.trim();
                                else
                                    salesCodeModified = coverage.salesCode.trim();
                                CoverageBulkUploadUtility.csvSalesCodes.add(salesCodeModified);
                            }
							//added for JIRA SALES 1588
							if(coverage.salesRefCode!=null && coverage.salesRefCode!='')
                            {
                                string salesCodeRefModified = '';
                                if(coverage.salesRefCode.trim().length() == 3)
                                    salesCodeRefModified = '0'+coverage.salesRefCode.trim();
                                else if(coverage.salesRefCode.trim().length() == 2)
                                    salesCodeRefModified = '00'+coverage.salesRefCode.trim();
                                else if(coverage.salesRefCode.trim().length() == 1)
                                    salesCodeRefModified = '000'+coverage.salesRefCode.trim();
                                else
                                    salesCodeRefModified = coverage.salesRefCode.trim();
                                CoverageBulkUploadUtility.csvSalesCodes.add(salesCodeRefModified);
                            }
                            system.debug('CSVSALESCDE **'+ CoverageBulkUploadUtility.csvSalesCodes);
                            if(coverage.productName!=null && coverage.productRegion!=null && coverage.productName!='' && coverage.productRegion!=null)
                            {
                                productRegionCombinationSetCSV = new Set<string>();
                                productRegionCombinationSetCSV.add(coverage.productName.trim().toLowerCase()+' - '+coverage.productRegion.trim().toLowerCase()) ;
                                coverage.productRegionCombination = productRegionCombinationSetCSV;
                                
                            }

                            totalCount++;
                            parser.skipChildren();
                        }
                    }
                }
            }
        }
    }
	
    //start processing  record using tool
    //updated for JIRA 1588 
    @AuraEnabled
    public static BulkUploaderCoverageWrapper processImportFromTool(String jsonStr, String strSource){
        //updated for JIRA 1588 
		//source = 'CVGTOOL';
		source = strSource;
        return processImport(jsonStr);
    }    
      
    //start processing  record using CSV
    @AuraEnabled
    public static BulkUploaderCoverageWrapper processImportFromCSV(String jsonStr){
        source = 'CSV';
        return processImport(jsonStr);
    }
	
    //start processing csv record
    @AuraEnabled
    public static BulkUploaderCoverageWrapper processImport(String jsonStr){
        SavePoint sp = Database.setSavepoint() ;
        isCommentAccessible = CoverageToolController.isCommentAccessible();
        
        try
        {
            system.debug('Process started.....');
            initializeValues();
            CoverageBulkUploadUtility.getRoles();
            system.debug('Total Roles: '+CoverageBulkUploadUtility.Roles.size());
            
            CoverageBulkUploadUtility.getAction();
            system.debug('Total Action: '+CoverageBulkUploadUtility.action.size());
            
            CoverageBulkUploadUtility.getProductGroup();
            system.debug('Total Product Group: '+CoverageBulkUploadUtility.productGroup.size());
            
            CoverageBulkUploadUtility.getProductRegion();
            system.debug('Total Product Region: '+CoverageBulkUploadUtility.ProductRegion.size());
            
            CoverageBulkUploadUtility.getProductName();
            system.debug('Total ProductName: '+CoverageBulkUploadUtility.ProductName.size());
            
            CoverageBulkUploadUtility.getProductRegionSet();
            system.debug('Total Product Region set: '+CoverageBulkUploadUtility.productRegionSet.size());
   
             
            CoverageBulkUploadUtility.csvRGIds = new Set<string>();
            CoverageBulkUploadUtility.csvRGIdsDelete = new Set<string>();
            CoverageBulkUploadUtility.csvRMIds = new Set<string>();
            CoverageBulkUploadUtility.csvSalesCodes = new Set<string>();
            CoverageBulkUploadUtility.csvSalesCodes_Delete = new Set<string>();
            CoverageBulkUploadUtility.coverageMap = new Map<String,List<Coverage_Team_Member__c>>();
            Set<Id> childRMs = new Set<Id>();
            
            system.debug('Parsing JSON Started');
            system.debug(jsonStr);
            parseJSONString(jsonStr);
            system.debug('Parsing JSON Completed');
            system.debug('Total excel records: '+xlRecords.size());
            system.debug(xlRecords);
            system.debug('Step 1 : Retrieving Salescode Map');
            system.debug('CoverageBulkUploadUtility.csvSalesCodes **'+ CoverageBulkUploadUtility.csvSalesCodes);
            //Get sales team coverage data using csv salescodes
            if(CoverageBulkUploadUtility.csvSalesCodes.size()>0)
                CoverageBulkUploadUtility.getSalesTeamCoverageMap(CoverageBulkUploadUtility.csvSalesCodes);
           
            Map<Id,User> salesCodeAndUserMapRG = new Map<Id,User>();
            // RG - Block
            if(CoverageBulkUploadUtility.csvRGIds.size()>0)
            {  
                system.debug('Step 2 : Retrieving RG Salesforce ID Map');
                CoverageBulkUploadUtility.storeRGMap(CoverageBulkUploadUtility.csvRGIds);
                system.debug('Finished Retrieving RG Salescode Map : '+CoverageBulkUploadUtility.rgMap.size()); 
                if(CoverageBulkUploadUtility.rgMap.size() > 0)
                {
                    system.debug('Source: '+source);
                    //Fetch RMs data for CSV using RG 
                    if(source == 'CSV' || strOpportunityflow.contains(source))
                    {
                        List<CoverageWrapper> wpList = new List<CoverageWrapper>();
                        List<CoverageWrapper> xlRecordsTemp = new List<CoverageWrapper>();
                        xlRecordsTemp = xlRecords;
                        

                        wpList = CoverageToolDataController.getSelectedRMCoveragesforCSV(xlRecords,CoverageBulkUploadUtility.rgMap,CoverageBulkUploadUtility.csvRGIds);
                        xlRecords = new List<CoverageWrapper>();
                        if(wpList.size() > 0)
                            xlRecords.addAll(wpList);
                        else
                             xlRecords.addAll(xlRecordsTemp);

                            
                    }
                    system.debug(xlRecords);
                    CoverageBulkUploadUtility.csvRGIds = null;
                    
                    //Fetch Parent and child RMs
                    for(Account rec: [SELECT Id, parent.RDM_Org_ID__c,RDM_Org_ID__c FROM Account WHERE Active__c = TRUE AND parentId IN: CoverageBulkUploadUtility.rgMap.values()])
                    {  
                        childRMs.add(rec.Id);
                        if(rgRMmap.get(rec.parent.RDM_Org_ID__c) == null)
                            rgRMmap.put(rec.parent.RDM_Org_ID__c, new Set<string>{rec.RDM_Org_ID__c});
                        else
                            rgRMmap.get(rec.parent.RDM_Org_ID__c).add(rec.RDM_Org_ID__c);


                            rmRGmap.put(rec.RDM_Org_ID__c,rec.parent.RDM_Org_ID__c);
                    }
                    system.debug(' **** Finished Retrieving RG Child RMs Accounts : '+childRMs);
                }
                system.debug('Step 7 : Retrieving User Assignment Coverage Map (RG)');
               
                if(CoverageBulkUploadUtility.teamCoverageIds!=null)
                {
                    //Fetch requested user for RG coverage request
                    if(CoverageBulkUploadUtility.teamCoverageIds.size() > 0){
                        salesCodeAndUserMapRG = CoverageRequestUtility.fetchRequestedForUserForRGRequest(CoverageBulkUploadUtility.teamCoverageIds); 
                    }
                    system.debug('salesCodeAndUserMapRG Size: '+salesCodeAndUserMapRG);
                    system.debug('Finished Retrieving User Assignment Coverage Map (RG)');
                    
                }
            }
            
            
            Map<Id,User> salesCodeAndUserMapRM = new Map<Id,User>();
            system.debug('Step 4 : Retrieving RM Salesforce ID Map');
            //RM - Block
            if(CoverageBulkUploadUtility.csvRMIds.size()>0)
            {
                CoverageBulkUploadUtility.storeRMMap(CoverageBulkUploadUtility.csvRMIds);
                //system.debug('RM Map : '+CoverageBulkUploadUtility.rmMap);
                system.debug('Finished Retrieving RM Salescode Map : '+CoverageBulkUploadUtility.rmMap.size());
                CoverageBulkUploadUtility.csvRMIds = null;
                
                system.debug('Step 8 : Retrieving User Assignment Coverage Map (RM)');
                system.debug('Step 8-1 : Creating SalesTeamCoverageId and AccountId Key');
                Set<String> salesCodeAndAccountIdSet = new Set<String>(); 
                Set<Id> accountIdSet = new Set<Id>();
                boolean skipRMKeyFormation =false;
                
                if(CoverageBulkUploadUtility.rmMap.size() > 0)
                {
                    for(CoverageWrapper record: xlRecords){
                        string salesCodeModified = '';
                        
                        if(record.salesCode!=null)
                        {
                            if(record.salesCode.trim().length() == 3)
                                salesCodeModified = '0'+record.salesCode.trim();
                            else if(record.salesCode.trim().length() == 2)
                                salesCodeModified = '00'+record.salesCode.trim();
                            else if(record.salesCode.trim().length() == 1)
                                salesCodeModified = '000'+record.salesCode.trim();
                            else
                                salesCodeModified = record.salesCode.trim();
                            
                            if(CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified)!=null){
                                record.salesDeskRegion = (CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified)).Sales_Desk_Region__c;
                            }
                            
                        }
                        
                        if(record.clientRGKey!=null && CoverageBulkUploadUtility.rgMap!=null)
                        {
                            if(CoverageBulkUploadUtility.rgMap.get(record.clientRGKey)!=null)
                                skipRMKeyFormation = true; 
                        }
                        //system.debug(record);
                        if(record.clientKey!=null && skipRMKeyFormation == false && salesCodeModified!='')
                        {
                            if(CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified)!=null && CoverageBulkUploadUtility.rmMap.get(record.clientKey.trim())!=null)
                            {
                                salesCodeAndAccountIdSet.add(CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified).Id + '#' + CoverageBulkUploadUtility.rmMap.get(record.clientKey.trim()));
                                accountIdSet.add(CoverageBulkUploadUtility.rmMap.get(record.clientKey.trim()));
                            }    
                        }
                        skipRMKeyFormation = false;
                    }
                    system.debug('Step 8 -1 : Finished Creating SalesTeamCoverageId and AccountId Key :'+salesCodeAndAccountIdSet.size());
                    
                    //Fetch salescode and account id set to fetch requested for user for RM coverage request
                    if(salesCodeAndAccountIdSet.size() > 0 && accountIdSet.size() > 0)
                    {
                        Map<Id,Account> accountMap = new Map<Id,Account>([
                            SELECT Id, Restricted_Flag__c, BillingCountry,Domicile_country__c, Closing_Date__c, Active__c FROM Account 
                            WHERE Id IN :accountIdSet
                        ]);
                        
                        system.debug(salesCodeAndAccountIdSet);
                        accountMap = (accountMap == null) ? new Map<Id,Account>() : accountMap;
                        salesCodeAndUserMapRM = CoverageRequestUtility.fetchRequestedForUserForRMRequest(salesCodeAndAccountIdSet, accountMap);
                    }
                }
                system.debug('salesCodeAndUserMapRM Size: '+salesCodeAndUserMapRM.size());
                system.debug('Finished Retrieving User Assignment Coverage Map (RM)');
                salesCodeAndAccountIdSet = null;
                accountIdSet = null;
            }
            
            
            Set<String> uniqueKeyCoverageMembers = new Set<string>();
            Map<string,List<string>> existing_coverages = new Map<string,List<string>>();
            Map<string,string> existing_coverages_nfpe = new Map<string,string>();
            Set<Id> allAccountIds = new Set<Id>();
            Set<string> rgkeyset = new Set<string>();
            Set<string> rmkeyset = new Set<string>();
            Set<string> teamIdSet = new Set<string>();
            if(CoverageBulkUploadUtility.rgMap!=null){ 
                for(string rgAccountId: CoverageBulkUploadUtility.rgMap.values())
                {
                    allAccountIds.add(rgAccountId);
                    rgkeyset.add(rgAccountId);
                }
            }
            if(CoverageBulkUploadUtility.rmMap!=null){ 
                for(string rmAccountId: CoverageBulkUploadUtility.rmMap.values())
                {
                    allAccountIds.add(rmAccountId);
                    rmkeyset.add(rmAccountId);
                }
            }
           
            Map<string,List<string>> map_CoverageStatus = new Map<string,List<string>>();
                 Set<string> rmkeyList = new Set<string>();
            
            
            Set<string> rmkeyListwoproduct = new Set<string>();
            if(CoverageBulkUploadUtility.csvSalesCodes.size()>0)
            {
                Set<Id> newIds = new Set<Id>();
                newIds.addAll(allAccountIds);
                newIds.addAll(childRMs);
               
                for(Id teamId: CoverageBulkUploadUtility.teamCoverageIds)
                    teamIdSet.add(teamId);
                CoverageBulkUploadUtility.teamCoverageIds = null;    
                
                //Fetch coverage Request data from backend
                map_CoverageStatus = checkCoverageRequestStatus(rgkeyset,teamIdSet,'Pending Approval',rmkeyset,newIds);
                system.debug('map_CoverageStatus **'+ map_CoverageStatus);
                
                //Fetch nfpe coverage data from backend irrespective of given salescodes
                //Only when csv has nfpe coverage request
                //if(coverageTypes.size()>0){
                    for(Coverage_Team_Member__c nfpetm : getNFPECoverageTeamMembers(newIds))
                    {
                        string exist_coverage_Flag_nfpe = '';
                        boolean nfpe = false;
                        boolean nfpe1 = false;
                        boolean nfpeprimaryproduct = false;
						boolean nfpeoverseas = false;
                        boolean nfpeprimaryrelationship = false;
                        string productKey = '';
                        string productGroupKey = '';
                        string productRegionKey = '';
                        //JIRA SALES 3660 FLAG_NFPE_SUBTYPE1_1
                        if((FLAG_NFPE_SUBTYPE1 !=null || FLAG_NFPE_SUBTYPE1_1!=null) && FLAG_NFPE_SUBTYPE1!='')
                        {
                            if(nfpetm.NFPE_Primary_Relationship_Coverage__c){
                                nfpeprimaryrelationship = true;
                            }
                        }
                        
                         if(FLAG_NFPE_SUBTYPE2 !=null && FLAG_NFPE_SUBTYPE2!='')
                        {
                            if(nfpetm.NFPE_Primary_Product_Coverage__c){
                                nfpeprimaryproduct = true;
                            }
                        }
                        //JIRA SALES 3660 FLAG_NFPE_SUBTYPE3_1
                         if((FLAG_NFPE_SUBTYPE3 !=null || FLAG_NFPE_SUBTYPE3_1!=null) && FLAG_NFPE_SUBTYPE3!='')
                        {
                            if(nfpetm.NFPE_Overseas_Authorised_Coverage__c){
                                nfpeoverseas = true;
                            }
                        }
                        
                        if(FLAG_NFPE1 !=null && FLAG_NFPE1!='')
                        {
                            if(nfpetm.NFPE1__c){
                                nfpe1 = true;
                            }
                        }
                        
                        string primaryKey = '';
                        if(nfpetm.Product__c!=null && nfpetm.Product__c!=''){
                            productKey = nfpetm.Product__c;
                        }
                        if(nfpetm.Product_Group__c!=null && nfpetm.Product_Group__c!=''){
                            productGroupKey = nfpetm.Product_Group__c;
                        }
                        if(nfpetm.Product_Region__c!=null && nfpetm.Product_Region__c!=''){
                            productRegionKey = nfpetm.Product_Region__c;
                        }
                        

                        //modified for JIRA SALES 3660
                        /*if(nfpetm.Product__c!=null && nfpetm.Product__c!='')
                        {*/
                           	if(nfpe1 && FLAG_NFPE1 !=null && FLAG_NFPE1!='')
                            {
                                //primaryKey = nfpetm.Account__r.RDM_Org_ID__c+'#'+nfpetm.Team_Role__c+'#'+nfpetm.Product__c+'#'+nfpetm.Product_Region__c+'#'+nfpetm.Product_Group__c +'#'+FLAG_NFPE1;
                                primaryKey = nfpetm.Account__r.RDM_Org_ID__c+'#'+nfpetm.Team_Role__c+'#'+productKey+'#'+productGroupKey+'#'+productRegionKey+'#'+FLAG_NFPE1;
                                existing_coverages_nfpe.put(primaryKey.toUpperCase(),nfpetm.Sales_Team_for_Coverage__c);
                                rmkeyListwoproduct.add(primaryKey.toUpperCase());
                            }
                            if(nfpeprimaryrelationship && (FLAG_NFPE_SUBTYPE1 !=null||CoverageUtil.FLAG_NFPE_SUBTYPE1_1!=null) && FLAG_NFPE_SUBTYPE1!='')
                            {
                                //primaryKey = nfpetm.Account__r.RDM_Org_ID__c+'#'+nfpetm.Team_Role__c+'#'+nfpetm.Product__c+'#'+nfpetm.Product_Region__c+'#'+nfpetm.Product_Group__c +'#'+FLAG_NFPE_SUBTYPE1;
                                primaryKey = nfpetm.Account__r.RDM_Org_ID__c+'#'+nfpetm.Team_Role__c+'#'+productKey+'#'+productGroupKey+'#'+productRegionKey+'#'+CoverageUtil.FLAG_NFPE_SUBTYPE1_1;
                                existing_coverages_nfpe.put(primaryKey.toUpperCase(),nfpetm.Sales_Team_for_Coverage__c);
                                rmkeyListwoproduct.add(primaryKey.toUpperCase());
                            }
                            if(nfpeprimaryproduct && FLAG_NFPE_SUBTYPE2 !=null && FLAG_NFPE_SUBTYPE2!='')
                            {
                                //primaryKey = nfpetm.Account__r.RDM_Org_ID__c+'#'+nfpetm.Team_Role__c+'#'+nfpetm.Product__c+'#'+nfpetm.Product_Region__c+'#'+nfpetm.Product_Group__c +'#'+FLAG_NFPE_SUBTYPE2;
                                primaryKey = nfpetm.Account__r.RDM_Org_ID__c+'#'+nfpetm.Team_Role__c+'#'+productKey+'#'+productGroupKey+'#'+productRegionKey+'#'+FLAG_NFPE_SUBTYPE2;
                                existing_coverages_nfpe.put(primaryKey.toUpperCase(),nfpetm.Sales_Team_for_Coverage__c);
                                rmkeyListwoproduct.add(primaryKey.toUpperCase());
                            }
							if(nfpeoverseas && (FLAG_NFPE_SUBTYPE3 !=null ||CoverageUtil.FLAG_NFPE_SUBTYPE3_1!=null)  && FLAG_NFPE_SUBTYPE3!='')
                            {
                                //primaryKey = nfpetm.Account__r.RDM_Org_ID__c+'#'+nfpetm.Team_Role__c+'#'+nfpetm.Product__+'#'+nfpetm.Product_Region__c+'#'+nfpetm.Product_Group__c +'#'+FLAG_NFPE_SUBTYPE3;
                                primaryKey = nfpetm.Account__r.RDM_Org_ID__c+'#'+nfpetm.Team_Role__c+'#'+productKey+'#'+productGroupKey+'#'+productRegionKey+'#'+CoverageUtil.FLAG_NFPE_SUBTYPE3_1;
                                existing_coverages_nfpe.put(primaryKey.toUpperCase(),nfpetm.Sales_Team_for_Coverage__c);
                                rmkeyListwoproduct.add(primaryKey.toUpperCase());
                            }
                        /*}
                        else
                        {
                            if(nfpe1 && FLAG_NFPE1 !=null && FLAG_NFPE1!='')
                            {
                                primaryKey = nfpetm.Account__r.RDM_Org_ID__c+'#'+nfpetm.Team_Role__c+'####'+FLAG_NFPE1;
                                existing_coverages_nfpe.put(primaryKey.toUpperCase(),nfpetm.Sales_Team_for_Coverage__c);
                                rmkeyListwoproduct.add(primaryKey.toUpperCase());
                            }
                            if(nfpeprimaryrelationship && FLAG_NFPE_SUBTYPE1 !=null && FLAG_NFPE_SUBTYPE1!='')
                            {
                                primaryKey = nfpetm.Account__r.RDM_Org_ID__c+'#'+nfpetm.Team_Role__c+'####'+FLAG_NFPE_SUBTYPE1;
                                existing_coverages_nfpe.put(primaryKey.toUpperCase(),nfpetm.Sales_Team_for_Coverage__c);
                                rmkeyListwoproduct.add(primaryKey.toUpperCase());
                            }
                            if(nfpeprimaryproduct && FLAG_NFPE_SUBTYPE2 !=null && FLAG_NFPE_SUBTYPE2!='')
                            {
                                primaryKey = nfpetm.Account__r.RDM_Org_ID__c+'#'+nfpetm.Team_Role__c+'####'+FLAG_NFPE_SUBTYPE2;
                                existing_coverages_nfpe.put(primaryKey.toUpperCase(),nfpetm.Sales_Team_for_Coverage__c);
                                rmkeyListwoproduct.add(primaryKey.toUpperCase());
                            }
                            if(nfpeoverseas && FLAG_NFPE_SUBTYPE3 !=null && FLAG_NFPE_SUBTYPE3!='')
                            {
                                primaryKey = nfpetm.Account__r.RDM_Org_ID__c+'#'+nfpetm.Team_Role__c+'####'+FLAG_NFPE_SUBTYPE3;
                                existing_coverages_nfpe.put(primaryKey.toUpperCase(),nfpetm.Sales_Team_for_Coverage__c);
                                rmkeyListwoproduct.add(primaryKey.toUpperCase());
                            }
                        }  */
                        
                    }
                    
                //}
                 system.debug(rmkeyListwoproduct);
                system.debug('newIds **'+CoverageBulkUploadUtility.csvSalesCodes);
                system.debug('newIds **'+newIds);
                //fetch coverage data from backend for given salescodes
                for(Coverage_Team_Member__c tm : getCoverageTeamMembersForSalesCode(CoverageBulkUploadUtility.csvSalesCodes,newIds))
                {
                    system.debug(tm);
                     string rgkey = '';
                     string rmkey = '';
                     string rgkeywoproduct = '';
                     string rmkeywoproduct = '';
                     string product = '';
                     string productGrp = '';
                     string productRegion = '';
             		
                    
                    if(tm.Product2__c!=null)
                        product = tm.Product2__c.trim().toLowerCase();
                    if(tm.Product_Group__c!=null)
                        productGrp = tm.Product_Group__c.trim().toLowerCase();
                    if(tm.Product_Region__c!=null)
                        productRegion = tm.Product_Region__c.trim().toLowerCase();
                    
                   
                    rgkey = tm.Account__r.Parent.RDM_Org_ID__c+'#'+tm.Sales_Team_for_Coverage__c+'#'+product+'#'+productGrp+'#'+productRegion;
                    rmkey = tm.Account__r.RDM_Org_ID__c+'#'+tm.Sales_Team_for_Coverage__c+'#'+product+'#'+productGrp+'#'+productRegion;
                    rgkeywoproduct = tm.Account__r.Parent.RDM_Org_ID__c+'#'+tm.Sales_Team_for_Coverage__c;
                    rmkeywoproduct = tm.Account__r.RDM_Org_ID__c+'#'+tm.Sales_Team_for_Coverage__c;
                    
                    //section modified for JIRA 3660
                    List<string> nfpelist = new List<string>();
                    if(FLAG_NFPE1 !=null && FLAG_NFPE1!=''){
                        if(tm.NFPE1__c)
                        nfpelist.add(FLAG_NFPE1);
                    }
                    if(FLAG_NFPE_SUBTYPE1 !=null && FLAG_NFPE_SUBTYPE1!=''){
                        if(tm.NFPE_Primary_Relationship_Coverage__c)
                        nfpelist.add(FLAG_NFPE_SUBTYPE1_1);
                    }
                    if(FLAG_NFPE_SUBTYPE2 !=null && FLAG_NFPE_SUBTYPE2!=''){
                        if(tm.NFPE_Primary_Product_Coverage__c)
                        nfpelist.add(FLAG_NFPE_SUBTYPE2);
                    }
                    if(FLAG_NFPE_SUBTYPE3 !=null && FLAG_NFPE_SUBTYPE3!=''){
                        if(tm.NFPE_Overseas_Authorised_Coverage__c)
                        nfpelist.add(FLAG_NFPE_SUBTYPE3_1);
                    }
                    if(tm.Account__r.Restricted_Flag__c || tm.NFPE1__c || tm.NFPE_Primary_Product_Coverage__c || tm.NFPE_Overseas_Authorised_Coverage__c || tm.NFPE_Primary_Relationship_Coverage__c)
                    {
                        if(product == null || product == ''){
                            if(existing_coverages.get(rmkeywoproduct)==null)
                                existing_coverages.put(rmkeywoproduct,nfpelist);
                            else
                                existing_coverages.get(rmkeywoproduct).addall(nfpelist);
                        }
                        else{
                             if(existing_coverages.get(rmkey)==null)
                                existing_coverages.put(rmkey,nfpelist);
                            else
                                existing_coverages.get(rmkey).addall(nfpelist);
                        }
                    }
                    else
                    {
                        if(product == null || product == ''){
                            if(existing_coverages.get(rgkeywoproduct)==null)
                                existing_coverages.put(rgkeywoproduct,nfpelist);
                            else
                                existing_coverages.get(rgkeywoproduct).addall(nfpelist);
                        }
                        else{
                            if(existing_coverages.get(rgkey)==null)
                                existing_coverages.put(rgkey,nfpelist);
                            else
                                existing_coverages.get(rgkey).addall(nfpelist);
                             rmkeyList.add(rmkey);
                        }
                       
                    }
                    system.debug('uniqueKeyforDelete **'+ uniqueKeyforDelete);
                    system.debug('uniqueKeyforDelete **'+ tm.Account__c);
                    system.debug('uniqueKeyforDelete **'+ tm.Account__r.RDM_Org_ID__c);
                    system.debug('uniqueKeyforDelete **'+ tm.Sales_Team_for_Coverage__c);
                    system.debug('uniqueKeyforDelete **'+ product);
                    system.debug('uniqueKeyforDelete **'+ productGrp);
                    system.debug('uniqueKeyforDelete **'+ productRegion);
                    
                    uniqueKeyforDelete.add(tm.Account__r.RDM_Org_ID__c+'#'+tm.Sales_Team_for_Coverage__c+'#'+product+'#'+productGrp+'#'+productRegion);    
				
                    }
            
                
                CoverageBulkUploadUtility.csvSalesCodes = null;
                newIds = null;
                childRMs = null;
            }
            
           
            
            system.debug('************************START VALIDATIONS*******************************');
            currentUser = getCurrentUser();
            processValidations(xlRecords,salesCodeAndUserMapRG,salesCodeAndUserMapRM,existing_coverages,existing_coverages_nfpe,map_CoverageStatus,source,rmkeyList,rmkeyListwoproduct);
            salesCodeAndUserMapRG = null;
            salesCodeAndUserMapRM = null;
            uniqueKeyCoverageMembers = null;
            //uniqueKeyforDelete = null;
            uniqueKeyforDelete = new Set<string>();
        
            CoverageBulkUploadUtility.coverageMap = null;
            CoverageBulkUploadUtility.rgMap = null;
            CoverageBulkUploadUtility.rmMap = null;
            CoverageBulkUploadUtility.rmMapBySalesCode = null;
            CoverageBulkUploadUtility.rgMapDelete = null;
            CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId = null;
            system.debug('************************VALIDATIONS COMPLETE****************************');
            
            system.debug('Validation Errors: '+xlRecords_With_Errors.size());
            system.debug('Validation Errors: '+xlRecords_With_Errors);
            
            
        }
        catch(Exception e)
        {
            if(sp!=null)
                Database.rollback(sp);
            exception_message += e+'\n'+e.getStackTraceString();
            exception_message += '\n';
            processedSuccessfully = false;
            system.debug('Exception (Processing Import): '+exception_message);
        }
        
        BulkUploaderCoverageWrapper bcw = new BulkUploaderCoverageWrapper();
        bcw.coverageRecords = xlRecords_With_Errors;
        bcw.fromNumber = 0;
        bcw.toNumber = 0;
        bcw.totalFailed = totalFailed;
        bcw.totalWarning = totalWarning;
        bcw.totalCount = xlrecords.size();
        bcw.totalSuccess = totalSuccess;		
        bcw.exceptionMsg = exception_message;
        bcw.csvString = csvString;
        bcw.successRecords = coveragesToInsert;
        bcw.guid = guid;
        xlRecords = null;
        
        if(Test.isRunningTest())
        {
            submitPartialData(coveragesToInsert,totalCount, 'GUID-1');
            
        }
        system.debug('Process completed.....');
        return bcw;
    }
    
    //NFPE Coverage team members
    public static List<Coverage_Team_Member__c> getNFPECoverageTeamMembers(Set<Id> rmAccountIds)
    {
        return [SELECT UniqueId__c,NFPE1__c, Team_Member__c,NFPE_Primary_Relationship_Coverage__c,NFPE_Primary_Product_Coverage__c,NFPE_Overseas_Authorised_Coverage__c,Sales_Team_for_Coverage__c,Account__r.Restricted_Flag__c,Account__r.Parent.RDM_Org_ID__c,Account__r.RDM_Org_ID__c,Product2__c,Product_Group__c,Product_Region__c,Account__c,Product__c, Account__r.ParentId,Team_Role__c FROM Coverage_Team_Member__c 
                WHERE Account__c IN : rmAccountIds AND recordtype.Name = 'Active Coverage' and (NFPE1__c = true or NFPE_Overseas_Authorised_Coverage__c = true or NFPE_Primary_Product_Coverage__c = true or NFPE_Primary_Relationship_Coverage__c = true)]; 
    }
     
    //get Coverage team members
    public static List<Coverage_Team_Member__c> getCoverageTeamMembersForSalesCode(Set<string> salesCodes, Set<Id> rmAccountIds)
    {
        return [SELECT UniqueId__c,NFPE1__c, Team_Member__c,Sales_Team_for_Coverage__c,NFPE_Primary_Relationship_Coverage__c,NFPE_Primary_Product_Coverage__c,NFPE_Overseas_Authorised_Coverage__c,Account__r.Restricted_Flag__c,Account__r.Parent.RDM_Org_ID__c,Account__r.RDM_Org_ID__c,Product2__c,Product_Group__c,Product_Region__c,Account__c, Account__r.ParentId,Team_Role__c FROM Coverage_Team_Member__c 
                WHERE Account__c IN : rmAccountIds AND recordtype.Name = 'Active Coverage'
                AND Sales_Team_for_Coverage__r.Coverage_ID__c IN :salesCodes]; 
    }
    
    //get NFPE RM Coverage Request
    public static List<Coverage_Access_Request__c> getNFPE_RMCoverageRequest(Set<Id> rmAccountIds){
         return [SELECT Id,Product2__c,Product_Region__c,type__c,sub_type__c,role__c, Account__c,Account__r.rdm_org_ID__c, Account__r.Parent.rdm_org_ID__c,
                 Account__r.ParentId,Product__c,Product_Group__c, Sales_Team_for_Coverage__c, Status__c FROM Coverage_Access_Request__c 
                 where Account__c in:rmAccountIds and Type__c!='Standard' and Type__c!='Cross Sell' and Status__c ='Pending Approval' and Account__r.Active__c = true];

    }
  
    
    public static Map<string,List<string>> checkCoverageRequestStatus(Set<string> rgAccountIds, Set<string> salesTeamCodeIds,
                                                                string status,Set<string> restrictedrmIds,Set<Id> rmAccountIds)
    {
        Map<string,List<string>> mapClient_CoverageStatus = new Map<string,List<string>>();
        system.debug(rmAccountIds);
        //RG Request data
        List<RG_Coverage_Request__c> requestRGList = [SELECT Id, Name, RG_Account__c,RG_Account__r.rdm_org_ID__c, Product__c,Product_Group__c,Sales_Team_for_Coverage__c, Status__c FROM RG_Coverage_Request__c 
                                                      where RG_Account__c IN:rgAccountIds and 
                                                      Sales_Team_for_Coverage__c IN:salesTeamCodeIds and 
                                                      Status__c =:status and RG_Account__r.Active__c = true];
        for(RG_Coverage_Request__c request: requestRGList)
        {
            string rgkey = '';
            string product = '';
            string productGrp = '';
            string productRegion = '';
            if(request.Product__c!=null)
            {
                product = request.Product__c.substring(0,string.valueOf(request.Product__c).lastIndexOf('-')).trim().toLowerCase();
                productRegion =   request.Product__c.substring(string.valueOf(request.Product__c).lastIndexOf('-')+1).trim().toLowerCase();                          
            }
            if(request.Product_Group__c!=null)
                productGrp = request.Product_Group__c.trim().toLowerCase();
            rgkey = request.RG_Account__r.RDM_Org_ID__c+'#'+request.Sales_Team_for_Coverage__c+'#'+product+'#'+productGrp+'#'+productRegion;
            List<string> nfpelist = new List<string>();
            if(mapClient_CoverageStatus.get(rgkey)==null)
                mapClient_CoverageStatus.put(rgkey,nfpelist);
        } 
        system.debug('Request RG size: '+requestRGList.size());
        
        List<Coverage_Access_Request__c> requestRMList = [SELECT Id,type__c,role__c,sub_type__c, Account__c,Account__r.rdm_org_ID__c, Account__r.Parent.rdm_org_ID__c,Account__r.ParentId,Product__c,Product_Group__c, Sales_Team_for_Coverage__c, Status__c FROM Coverage_Access_Request__c 
                                                          where (Account__c IN: restrictedrmIds) and 
                                                          Sales_Team_for_Coverage__c IN:salesTeamCodeIds and 
                                                          Status__c =:status and Account__r.Active__c = true and (Type__c ='Standard' or Type__c = 'Cross Sell')];
        
        system.debug('Request RM size: '+requestRMList.size());
        //Standard restricted RM request data
        for(Coverage_Access_Request__c request: requestRMList)
        {
            string rmkey = '';
            string product = '';
            string productGrp = '';
            string productRegion = '';
            string exist_coverage_Flag_nfpe = '';
            if(request.Product__c!=null)
            {
                product = request.Product__c.substring(0,string.valueOf(request.Product__c).lastIndexOf('-')).trim().toLowerCase();
                productRegion =   request.Product__c.substring(string.valueOf(request.Product__c).lastIndexOf('-')+1).trim().toLowerCase();                          
            }
            if(request.Product_Group__c!=null)
                productGrp = request.Product_Group__c.trim().toLowerCase();
            rmkey = request.Account__r.RDM_Org_ID__c+'#'+request.Sales_Team_for_Coverage__c+'#'+product+'#'+productGrp+'#'+productRegion;
            List<string> nfpelist = new List<string>();
            if(mapClient_CoverageStatus.get(rmkey)==null)
                mapClient_CoverageStatus.put(rmkey,nfpelist);
            else
                 mapClient_CoverageStatus.get(rmkey).addall(nfpelist);
            
        }
        
        
        //RM NFPE Request data
        for(Coverage_Access_Request__c nfperequest: getNFPE_RMCoverageRequest(rmAccountIds)){
            string exist_coverage_Flag_nfpe = '';
            boolean nfpe = false;
            boolean nfpe1 = false;
            boolean nfpeprimaryproduct = false;
            boolean nfpeprimaryrelationship = false;
			boolean nfpeoverseas = false;
            string rmkey = '';
            string product = '';
            string productGrp = '';
            string productRegion = '';
            if(nfperequest.Product__c!=null)
            {
                product = nfperequest.Product__c.substring(0,string.valueOf(nfperequest.Product__c).lastIndexOf('-')).trim().toLowerCase();
                productRegion =   nfperequest.Product__c.substring(string.valueOf(nfperequest.Product__c).lastIndexOf('-')+1).trim().toLowerCase();                          
            }
            if(nfperequest.Product_Group__c!=null)
                productGrp = nfperequest.Product_Group__c.trim().toLowerCase();
            rmkey = nfperequest.Account__r.RDM_Org_ID__c+'#'+nfperequest.Sales_Team_for_Coverage__c+'#'+product+'#'+productGrp+'#'+productRegion;
            
            List<string> nfpelist = new List<string>();
            if(nfperequest.TYpe__c !=null && nfperequest.TYpe__c!='')
                nfpelist.add(nfperequest.TYpe__c);
            if(nfperequest.sub_TYpe__c !=null && nfperequest.sub_TYpe__c!='')
                nfpelist.add(nfperequest.sub_TYpe__c);
            
            
            if(mapClient_CoverageStatus.get(rmkey)==null)
            {
                mapClient_CoverageStatus.put(rmkey,nfpelist);
            }
            else
            {
                mapClient_CoverageStatus.get(rmkey).addall(nfpelist);
            }
            
            //modified for JIRA SALES 3660
            if(FLAG_NFPE !=null && FLAG_NFPE!='')
            {
                if(nfperequest.type__c == FLAG_NFPE && nfperequest.Sub_Type__c!='' && (nfperequest.Sub_Type__c == FLAG_NFPE_SUBTYPE1 || nfperequest.Sub_Type__c == CoverageUtil.FLAG_NFPE_SUBTYPE1_1)){
                    nfpeprimaryrelationship = true;
                    exist_coverage_Flag_nfpe = nfperequest.Account__r.RDM_Org_ID__c+'#'+nfperequest.role__c+'#'+product+'#'+productGrp+'#'+productRegion+'#'+FLAG_NFPE_SUBTYPE1_1;
                    existing_coverages_nfpe_request.put(exist_coverage_Flag_nfpe.toUpperCase(),nfperequest.Sales_Team_for_Coverage__c);
                }
                 if(nfperequest.type__c == FLAG_NFPE && nfperequest.Sub_Type__c!='' && nfperequest.Sub_Type__c == FLAG_NFPE_SUBTYPE2){
                    nfpeprimaryproduct = true;
                    exist_coverage_Flag_nfpe = nfperequest.Account__r.RDM_Org_ID__c+'#'+nfperequest.role__c+'#'+product+'#'+productGrp+'#'+productRegion+'#'+FLAG_NFPE_SUBTYPE2;
                    existing_coverages_nfpe_request.put(exist_coverage_Flag_nfpe.toUpperCase(),nfperequest.Sales_Team_for_Coverage__c);
                }
				 if(nfperequest.type__c == FLAG_NFPE && nfperequest.Sub_Type__c!='' && (nfperequest.Sub_Type__c == FLAG_NFPE_SUBTYPE3 || nfperequest.Sub_Type__c == CoverageUtil.FLAG_NFPE_SUBTYPE3_1)){
                    nfpeoverseas = true;
                    exist_coverage_Flag_nfpe = nfperequest.Account__r.RDM_Org_ID__c+'#'+nfperequest.role__c+'#'+product+'#'+productGrp+'#'+productRegion+'#'+FLAG_NFPE_SUBTYPE3_1;
                    existing_coverages_nfpe_request.put(exist_coverage_Flag_nfpe.toUpperCase(),nfperequest.Sales_Team_for_Coverage__c);
                }
            }
            
            if(FLAG_NFPE1 !=null && FLAG_NFPE1 !='')
            {
                if(nfperequest.type__c == FLAG_NFPE1)
                    nfpe1 = true;
                    exist_coverage_Flag_nfpe = nfperequest.Account__r.RDM_Org_ID__c+'#'+nfperequest.role__c+'#'+product+'#'+productGrp+'#'+productRegion+'#'+FLAG_NFPE1;
                    existing_coverages_nfpe_request.put(exist_coverage_Flag_nfpe.toUpperCase(),nfperequest.Sales_Team_for_Coverage__c);
            }
        }
        return mapClient_CoverageStatus;
    }
    
    public static Map<Id,User> getCurrentUser()
    {
        for(User u: [select id,Name,Region__c,IsActive,Country,CountryCode, Managerid,Manager.IsActive,UserRole.Name,UserRole.Id,UserRole.ParentRoleId from User where Id=:UserInfo.getUserId()])
        currentUser.put(u.Id, u);
        return currentUser;
    }
    public static Map<Id,User> getSfAdminUser()
    {
        for(User u: [select id,Name,Region__c,IsActive,Country,CountryCode, Managerid,Manager.IsActive,UserRole.Name,UserRole.Id,UserRole.ParentRoleId from User where NAme = 'sfadmin'])
        currentUser.put(u.Id, u);
        return currentUser;
    }
    //Validations
   public static void processValidations(List<CoverageWrapper> xlsRecords,Map<Id,User> salesCodeAndUserMapRG,
                                          Map<Id,User> salesCodeAndUserMapRM,Map<string,List<string>> existing_coverages,
                                         Map<string,string> existing_coverages_nfpe
                                         ,Map<string,List<string>> map_CoverageStatus,string source,Set<string> rmkeyList,Set<string> rmkeyListwoproduct)
   {
       guid = GUIDGenerator.NewGuid();
       
       Boolean isBM = false;
       //added JIRA 3410
       Boolean isAdmin = false;
       List<Profile> profile = [SELECT Name FROM Profile WHERE Id=: UserInfo.getProfileId()];
        if(string.valueOf(profile[0].Name).indexOf('Business')  > -1){
           isBM = true;
        }
        if(profile[0].Name == 'System Administrator' || profile[0].Name == 'Nomura - Integration'){
           isAdmin = true;
        }
        system.debug('isAdmin ** '+profile[0].Name);
        system.debug('isAdmin ** '+isAdmin);
      
       string errormsg = '';
       totalFailed = 0;
       totalSuccess = 0;
       totalWarning = 0;
       csvString = 'clientRGKey,clientKey,salesCode,productGroup,productRegion,productName,role,action,fromDate,IncludeRestrictedAccounts,attest,Error'+':';
       Boolean hasError = false;
       Boolean hasWarning = false;
       Boolean hasOnlyRG =false;
       Boolean hasOnlyRM =false;
       Boolean hasBoth =false;
       Boolean hasRMORRG = false;
       Boolean hasSalesCode = false;
       Boolean hasRole = false;
       Boolean hasAction = false;
       String action = '';
       Integer count = 2;
       containsValidationError = false;
       Set<string> uniqueKey = new Set<string>();
       
       //added for JIRA 1588
       Boolean hasRefSalesCode = false;   
       system.debug('existing_coverages ** ' + existing_coverages);
       
       Map<String,List<String>> valueMap = PicklistFieldController.getDependentOptionsImpl('Coverage_Team_Member__c','Product_Group__c','Product2__c');
       system.debug('***: '+valueMap);   
       Set<Id> researchSalesCodeOwnerIds = new Set<Id>();
       if(CoverageBulkUploadUtility.salesCodeOwnerIds!=null)                                     
           researchSalesCodeOwnerIds  = CoverageToolController.getUserRoleAEJResearchBySalesCodeOwnerId(CoverageBulkUploadUtility.salesCodeOwnerIds);
       system.debug('actual research salescode csv Owner Id: '+researchSalesCodeOwnerIds.size()); 
       system.debug('actual research salescode csv Owner Id: '+xlsRecords); 
       for(CoverageWrapper record: xlsRecords)
       {
           system.debug('looping records: '+record);
           system.debug(record.Type);
           action = '';
           errormsg = '';
           hasError = false;
           hasOnlyRG =false;
           hasOnlyRM =false;
           hasRMORRG = false;
           hasSalesCode = false;
           hasWarning = false;
           hasRole = false;
           hasAction = false;
           string salesCodeModified = '';
           Id salesCodeTeamMemberId;
           string company = '';
           User requestedForUserRG;
           User requestedForUserRM;
           if(record.clientKey!=null && record.clientKey!='')
               record.clientRGKey = null;    
           
           string deletekey = '';
           string product_key = '';
           string productGrp_key = '';
           string productRegion_key = '';
           string key = '';
           string RDM_key = '';
           string TeamCoverage_key = '';
           string exist_coverage_Flag_rg = '';
           string exist_coverage_Flag_rm = '';
           string exist_coverage_Flag_nfpe = '';
           //added for JIRA 1588
           hasRefSalesCode = false;
           string salesCodeRefModified = '';
           string TeamRefCoverage_key = '';
           Id salesCodeRefMemberId;
           string Refkey = '';
           
           
           //skip for DELETE SALES -3646
           //removed headquater for JIRA 3327 as no longer required record.productRegion.toLowerCase() == 'headquarter'
           if(record.productName!=null)
           {
               product_key = record.productName.trim().toLowerCase();
               if(record.productGroup.toLowerCase() == EQ.toLowerCase() && record.productRegion.toLowerCase() == 'global' && record.action.toLowerCase() != 'delete')
               {
                   if(errormsg == '')
                       errormsg = 'Region is not valid for Equity Product Group.';
                   else
                       errormsg += ', Region is not valid for Equity Product Group.';
                   hasError = true;
               }
           }
           //commented for JIRA 3410 as no longer required
		   //added for JIRA 1588
		   /* if(product_key.contains('(') && strOpportunityflow.contains(source)){
			   product_key = product_key.substring(product_key.indexOf('('),product_key.indexOf(')')-product_key.indexOf('('));
			}*/
           if(record.productGroup!=null)
               productGrp_key = record.productGroup.trim().toLowerCase();
           if(record.productRegion!=null)
               productRegion_key = record.productRegion.trim().toLowerCase();
           if(record.salesCode!=null && record.salesCode!='')
           {
               if(record.salesCode.trim().length() == 3)
                   salesCodeModified = '0'+record.salesCode.trim();
               else if(record.salesCode.trim().length() == 2)
                   salesCodeModified = '00'+record.salesCode.trim();
               else if(record.salesCode.trim().length() == 1)
                   salesCodeModified = '000'+record.salesCode.trim();
               else
                   salesCodeModified = record.salesCode.trim();
               if(CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified.trim())!=null)
               {
                   salesCodeTeamMemberId = CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified.trim()).Id;
                   TeamCoverage_key = salesCodeTeamMemberId;                   
				   company = CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified.trim()).Company__c;
	                   
                   system.debug('SalesCode Team Member Id: '+salesCodeTeamMemberId+ ' for code ('+salesCodeModified.trim()+')');  
                   if(salesCodeAndUserMapRG.get(salesCodeTeamMemberId)!=null && !CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified.trim()).Is_dummy__c)
                       requestedForUserRG = salesCodeAndUserMapRG.get(salesCodeTeamMemberId);
                   else
                       requestedForUserRG = currentUser.get(UserInfo.getUserId());
                   
                   
                   if(salesCodeAndUserMapRM.get(salesCodeTeamMemberId)!=null && !CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified.trim()).Is_dummy__c)
                       requestedForUserRM = salesCodeAndUserMapRM.get(salesCodeTeamMemberId);
                   else
                       requestedForUserRM = currentUser.get(UserInfo.getUserId());
               }
               
               system.debug('isAttested?: ' + record.isAttested);
               if(record.action.trim().toLowerCase() == 'add') {
                    if((CoverageUtil.company).indexOf(company)>-1 && (CoverageUtil.userRole).indexOf(record.role)>-1  && (CoverageUtil.mandatoryPrimaryAttestRegion).indexOf(record.salesDeskRegion)>-1 && !record.isAttested)
                    {
                        if(errormsg == '')
                                errormsg = 'Please attest primary coverage.';
                            else
                                errormsg += ', Please attest primary coverage.';
                            hasError = true;
                    } 
                }        
           }
           //added for JIRA 1588
           if(record.salesRefCode!=null && record.salesRefCode!=''){
               if(record.salesRefCode.trim().length() == 3)
                   salesCodeRefModified = '0'+record.salesRefCode.trim();
               else if(record.salesRefCode.trim().length() == 2)
                   salesCodeRefModified = '00'+record.salesRefCode.trim();
               else if(record.salesRefCode.trim().length() == 1)
                   salesCodeRefModified = '000'+record.salesRefCode.trim();
               else
                   salesCodeRefModified = record.salesRefCode.trim();
               
               if(CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeRefModified.trim())!=null){
                   salesCodeRefMemberId = CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeRefModified.trim()).Id;
                   TeamRefCoverage_key = salesCodeRefMemberId;
               }
               
           }
           system.debug('Refkey **'+ TeamCoverage_key);
           system.debug('Refkey **'+ TeamRefCoverage_key);
           system.debug('Refkey **'+ salesCodeRefMemberId);
           system.debug('Refkey **'+ salesCodeTeamMemberId);
           system.debug(record.clientRGKey + '' + record.clientKey);
           if(record.clientRGKey!=null && record.clientRGKey!='')
           {
               RDM_key = record.clientRGKey.trim();
               //exist_coverage_Flag_rg = record.clientRGKey+'#'+TeamCoverage_key+'#'+product_key+'#'+productGrp_key+'#'+productRegion_key;
               hasOnlyRG = true;
           }
           
           if(record.clientKey!=null && record.clientKey!='')
           {
               RDM_key = record.clientKey.trim();
               if(record.coverageType!='Standard')
               {
                   if(record.subType!=null && record.subType!='')
                   {
                       //exist_coverage_Flag_nfpe = record.clientKey+'#'+record.role+'#'+product_key+'#'+productRegion_key+'#'+productGrp_key+'#'+record.subType.trim();
                       exist_coverage_Flag_nfpe = record.clientKey+'#'+record.role+'#'+product_key+'#'+productGrp_key+'#'+productRegion_key+'#'+record.subType.trim();
                   }
                   else
                   {
                       //exist_coverage_Flag_nfpe = record.clientKey+'#'+record.role+'#'+product_key+'#'+productRegion_key+'#'+productGrp_key+'#'+record.coverageType.trim();    
                       exist_coverage_Flag_nfpe = record.clientKey+'#'+record.role+'#'+product_key+'#'+productGrp_key+'#'+productRegion_key+'#'+record.coverageType.trim();    
                   }
                   
                   exist_coverage_Flag_nfpe = exist_coverage_Flag_nfpe.toUpperCase();
                   
                   system.debug(exist_coverage_Flag_nfpe);
                   
                  
               }
                       
               hasOnlyRM = true;
           }
           
           
           
            hasBoth = false;
           
           system.debug(hasOnlyRG + '' + hasOnlyRM);
           
           if(record.coverageType=='Standard'){
               if(record.productName == null || record.productName == ''){
                   key = RDM_key+'#'+TeamCoverage_key;
               }
               else{
                   key = RDM_key+'#'+TeamCoverage_key+'#'+product_key.trim().toLowerCase()+'#'+productGrp_key.trim().toLowerCase()+'#'+productRegion_key.trim().toLowerCase();	
                   if(TeamRefCoverage_key != '')
                       Refkey = RDM_key+'#'+TeamRefCoverage_key+'#'+product_key.trim().toLowerCase()+'#'+productGrp_key.trim().toLowerCase()+'#'+productRegion_key.trim().toLowerCase();	
               }
           }
           else
           {
               key = RDM_key+'#'+TeamCoverage_key+'#'+product_key+'#'+productGrp_key+'#'+productRegion_key;	
                   if(TeamRefCoverage_key != '')
                       Refkey = RDM_key+'#'+TeamRefCoverage_key+'#'+product_key.trim().toLowerCase()+'#'+productGrp_key.trim().toLowerCase()+'#'+productRegion_key.trim().toLowerCase();	
              
          
           }
          
           
            deletekey = RDM_key+'#'+TeamCoverage_key+'#'+product_key+'#'+productGrp_key+'#'+productRegion_key;
           
                     
			//RG  & RM will be  coming via tool
            if(containsRGRMBoth(record.clientRGKey, record.clientKey)==true || containsRGORRM(record.clientRGKey, record.clientKey) == true)
            {
                hasRMORRG = true;
            }
            else{
                if(errormsg == '')
                    errormsg = 'RGKey is mandatory';
                else
                    errormsg += ', RGKey is mandatory';
                hasError = true;
                hasRMORRG = false;
            }
            
			//salesCode Mandate Check
            if((!containsSalesCode(record.salesCode) && !strOpportunityflow.contains(source))  || (strOpportunityflow.contains(source) && !containsSalesCode(record.salesCode) && !isAdmin))
            {
                if(strOpportunityflow.contains(source)){
                    if(errormsg == '')
                        errormsg = System.Label.ValidateSalesCodeReferral;
                    else
                        errormsg += ', ' + System.Label.ValidateSalesCodeReferral;
                }else{
                    if(errormsg == '')
                        errormsg = 'salesCode is mandatory';
                    else
                        errormsg += ', salesCode is mandatory';
                }
                hasError = true;
                hasSalesCode = false;
            }
            else{hasSalesCode = true;}
            //added for JIRA 1588
			//salesRefCode Mandate Check
                system.debug('hasRefSalesCode **'+ hasRefSalesCode);
           system.debug('Refkey **'+ Refkey);
           system.debug('Refkey **'+ key);
           system.debug('hasRefSalesCode **'+ containsSalesCode(record.salesrefCode));
           system.debug('hasRefSalesCode **'+ record.salesrefCode);
            if(strOpportunityflow.contains(source) && !containsSalesCode(record.salesrefCode) && !isAdmin)
            {
                if(errormsg == '')
                    errormsg = System.Label.ValidateSalesCodeReferrer;
                else
                    errormsg += ', '+ System.Label.ValidateSalesCodeReferrer;                
                hasError = true;
                hasRefSalesCode = false;
            }else{hasRefSalesCode = true;}
            //role Mandate Check
            if(!containsRole(record.role))
            {
                if(errormsg == '')
                    errormsg = 'role is mandatory';
                else
                    errormsg += ', role is mandatory';
                hasError = true;
                hasRole = false;
            }else{hasRole = true;}            
            
            //action Mandate Check
            if(!containsAction(record.action))
            {
                if(errormsg == '')
                    errormsg = 'action is mandatory';
                else
                    errormsg += ', action is mandatory';
                hasError = true;
                hasAction =false;
            }else{hasAction =true;} 
            
            boolean isTypeValid = true;
            //Added section for JIRA 3698
            if(record.Type!=null && record.Type!=''){
               if(errormsg == '')
                errormsg = 'Type cannot be set from Coverage. Please download the updated template.';
                else
                    errormsg += ', Type cannot set from Coverage. Please download the updated template.';
                hasError = true; 
            } 
            if(record.Type!=null && record.Type!='' && CoverageToolDataController.coverageTypesMap.size() == 0 )
            {
                system.debug('inside 1');
                isTypeValid = false;
            }
            else if (record.Type!=null && record.Type!='' && CoverageToolDataController.coverageTypesMap.size() > 0 ){
                
                system.debug('inside 2');
                List<string> subtypes = new List<string>();
                List<string> types = new List<string>();
                types = record.Type.split(',');
                for(List<String> valueList : CoverageToolDataController.coverageTypesMap.values()) {
                    for(string s: valueList)
                    subtypes.add(s.trim().toLowerCase());
                }
                
                for(string t: types){
                    if(!subtypes.contains(t.trim().toLowerCase()))
                    {isTypeValid = false;break;}
                }
            }

            if(!isTypeValid && record.action!=null && record.action.toLowerCase() == 'add' ){
                if(errormsg == '')
                errormsg = 'Type is invalid';
                else
                    errormsg += ', Type is invalid';
                hasError = true;
            }
           if(hasSalesCode){
               if(salesCodeModified!='' && CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified)!=null){
                   Sales_Team_for_Coverage__c code = CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified);
                   boolean showValidation = true;
                   String productIncludingRegion = null;
                   if(record.productName != null && String.isNotEmpty(record.productName) && record.productRegion != null && String.isNotEmpty(record.productRegion)){
                       productIncludingRegion = record.productName.toLowerCase() + ' - ' + record.productRegion.toLowerCase(); 
                   }
                   
                   if(record.productName!= null && Coverageutil.productsWithRegionsToIncludeForInstinet.contains(productIncludingRegion))
                       showValidation = false;
                   
                   if(code.Company__c == 'I' && showValidation){
                       string operation = '';
                       if(record.action!=null)
                       operation = record.action;
                       
                       if(errormsg == '')
                           errormsg = 'You cannot '+operation+' Instinet salescode coverage request';
                       else
                           errormsg += ', You cannot '+operation+' Instinet salescode coverage request';
                           hasError = true; 
                   }
               }
           }
           system.debug('hasRefSalesCode **'+ hasRefSalesCode);
            //updated for JIRA SALES - 1588
            if((hasRMORRG && hasSalesCode && hasRole && hasAction && !strOpportunityflow.contains(source)) || (hasRMORRG && hasSalesCode && hasRefSalesCode && hasRole && hasAction && strOpportunityflow.contains(source)))
            {
				//Check RGKey is valid
				if(record.clientRGKey!=null && record.clientRGKey!='')
                {                    
                    if(!isRGValid(record.clientRGKey.trim()))
                    {
                        if(errormsg == '')
                            errormsg = 'clientRGKey is not valid';
                        else
                            errormsg += ', clientRGKey is not valid';
                        hasError = true;
                        hasOnlyRG = false;
                    }
                }
                
                if(record.clientKey!=null && record.clientKey!='')    
                {
                    if(!isRMValid(record.clientKey.trim()))
                    {
                        if(errormsg == '')
                            errormsg = 'clientRMKey is not valid';
                        else
                            errormsg += ', clientRMKey is not valid';
                        hasError = true;
                        hasOnlyRM = false;   
                    }
                }
             
                if(hasOnlyRG)
                {
                    record.IsRG = true;
                }
                
                if(hasOnlyRM)
                {record.IsRG = false;}
                
                if(record.action!=null && record.action.trim()!='')
                {
                    if(!isActionValid(record.action))
                    {
                        if(errormsg == '')
                            errormsg = 'action is not valid';
                        else
                            errormsg += ', action is not valid';
                        hasError = true; 
                    }
                    else
                    {
                        action = record.action.trim().toLowerCase();
                    }
                }
                
                
                //added check for admin for JIRA 3410
                //added for JIRA 1588
                if(record.salesRefcode!=null && record.salesRefcode!='' && strOpportunityflow.contains(source) && isAdmin == false){                    
                    system.debug(salesCodeRefModified);
                    if(CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeRefModified)==null){
                        if(errormsg == '')
                            errormsg = 'salesCode of Referee is not valid';
                        else
                            errormsg += ', salesCode of Referee is not valid';
                        hasError = true;
                    }
				}
                //SKIP for Deletion for SALES-3646
                if(record.salescode!=null && record.salescode!='' && ((strOpportunityflow.contains(source) == false && record.action.toLowerCase() != 'delete') || (strOpportunityflow.contains(source) == true && isAdmin == false)))
                {
                    if(CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified)==null)
                    {
                        if(errormsg == '')
                            errormsg = 'salesCode is not valid';
                        else
                            errormsg += ', salesCode is not valid';
                        hasError = true;
                    }
                    else
                    {
                        if(record.action.trim().toLowerCase() == 'add' &&  (hasBoth || hasOnlyRG) )
                        {
                            if(rgRMmap.get(RDM_key) == null)
                            {
                                if(errormsg == '')
                                    errormsg = 'No RMs found under this Account';
                                else
                                    errormsg += ', No RMs found under this Account';
                                hasError = true;
                            }
                        }	
                        
                        if(record.action.trim().toLowerCase() == 'add' && CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified).Active__c == false)
                        {
                            if(errormsg == '')
                                errormsg = 'An inactive SalesCode is not valid for action - Add';
                            else
                                errormsg += ', An inactive SalesCode is not valid for action - Add';
                            hasError = true;
                        }
                        else
                        {
                          //updated for JIRA 1588               
						    if(hasOnlyRG && !CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified).is_Dummy__c && !strOpportunityflow.contains(source))
                            {
                                if(salesCodeAndUserMapRG.get(salesCodeTeamMemberId) == null)
                                {
                                    if(errormsg == '')
                                        errormsg = 'Team member for salesCode '+salesCodeModified+' not found';
                                    else
                                        errormsg += ', Team member for salesCode '+salesCodeModified+' not found';
                                    hasError = true;
                                }
                                else
                                {
                                    
                                    if(!salesCodeAndUserMapRG.containsKey(salesCodeTeamMemberId)){
                                        if(errormsg == '')
                                            errormsg = System.Label.Coverage_Request_User_Not_Setup;
                                        else
                                            errormsg += ', '+System.Label.Coverage_Request_User_Not_Setup;
                                        hasError = true;
                                    }	
                                    else
                                    {
                                        if(record.action.trim().toLowerCase() == 'add' && requestedForUserRG.IsActive == false)
                                        {
                                            if(errormsg == '')
                                                errormsg = System.Label.Coverage_Request_Add_With_Inactive_User;
                                            else
                                                errormsg += ', '+System.Label.Coverage_Request_Add_With_Inactive_User;
                                            hasError = true;
                                        }
                                        
                                    }
                                }
                                
                            }
							else if(hasOnlyRG && !CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified).is_Dummy__c && strOpportunityflow.contains(source)){
							    if(CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified).Is_Split_Sales_Code__c){
								     if(errormsg == '')
                                        errormsg = System.Label.ValidateActiveSalesCode;
									else
										errormsg += ', '+ System.Label.ValidateActiveSalesCode;
									hasError = true; 
								}
								else{
								    system.debug(' Print 1** '+salesCodeAndUserMapRG.get(salesCodeTeamMemberId));
									system.debug(' Print 1** '+salesCodeAndUserMapRG);
									system.debug(' Print 1** '+salesCodeTeamMemberId);
								    if(salesCodeAndUserMapRG.get(salesCodeTeamMemberId) == null){
										if(errormsg == '')
											errormsg = 'Team member for salesCode '+salesCodeModified+' not found';
										else
											errormsg += ', Team member for salesCode '+salesCodeModified+' not found';
										hasError = true;
									}
									else{										
										if(!salesCodeAndUserMapRG.containsKey(salesCodeTeamMemberId)){
											if(errormsg == '')
												errormsg = System.Label.Coverage_Request_User_Not_Setup;
											else
												errormsg += ', '+System.Label.Coverage_Request_User_Not_Setup;
											hasError = true;
										}	
										else{
											if(record.action.trim().toLowerCase() == 'add' && requestedForUserRG.IsActive == false){
												if(errormsg == '')
													errormsg = System.Label.Coverage_Request_Add_With_Inactive_User;
												else
													errormsg += ', '+System.Label.Coverage_Request_Add_With_Inactive_User;
												hasError = true;
											}											
										}
									}
								}
							}
							else if(hasOnlyRG && CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified).is_Dummy__c && strOpportunityflow.contains(source) && CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified).Company__c != 'I'){
							    if(errormsg == '')
                                    errormsg = 'The Sales code cannot be of Dummy. Need an active sales code.';
                                else
                                    errormsg += ', '+ 'The Sales code cannot be of Dummy. Need an active sales code.';
                                hasError = true; 
							}
                            
                            if(hasOnlyRM && !CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified).is_Dummy__c)
                            {
                                system.debug(salesCodeAndUserMapRM);
                                if(salesCodeAndUserMapRM.get(salesCodeTeamMemberId) == null)
                                {
                                    boolean found = false;
                                    if(record.coverageType!='Standard' && salesCodeAndUserMapRG.get(salesCodeTeamMemberId) !=null){
                                        found = true;
                                    }
                                    
                                    if(!found){
                                        if(errormsg == '')
                                            errormsg = 'Team member for salesCode '+salesCodeModified+' not found';
                                        else
                                            errormsg += ', Team member for salesCode '+salesCodeModified+' not found';
                                        hasError = true;
                                    }
                                    
                                }
                                else
                                {
                                    
                                    if(!salesCodeAndUserMapRM.containsKey(salesCodeTeamMemberId)){
                                        if(errormsg == '')
                                            errormsg = System.Label.Coverage_Request_User_Not_Setup;
                                        else
                                            errormsg += ', '+System.Label.Coverage_Request_User_Not_Setup;
                                        hasError = true;
                                    }	
                                    else
                                    {
                                        if(record.action.trim().toLowerCase() == 'add' && requestedForUserRM.IsActive == false)
                                        {
                                            if(errormsg == '')
                                                errormsg = System.Label.Coverage_Request_Add_With_Inactive_User;
                                            else
                                                errormsg += ', '+System.Label.Coverage_Request_Add_With_Inactive_User;
                                            hasError = true;
                                        }
                                        
                                    }
                                }
                            }
                        }
                        
                        
                        
                    }
                    
                }
                
                //JIRA 3699 skip flow derivative products
                String tempproductname='';
                //SKIP for Deletion SALES-3646
                if(record.productRegion != null && record.productRegion != '' && record.action.toLowerCase() != 'delete')
                {
                    system.debug(record.productRegion);
                    system.debug(!isProductRegionValid(record.productRegion));
                    if(!isProductRegionValid(record.productRegion))
                    {
                        if(errormsg == '')
                            errormsg = 'productRegion is not valid';
                        else
                            errormsg += ', productRegion is not valid';
                        hasError = true;    
                    }
                    else{
                        //JIRA 3699 skip flow derivative products
                            tempproductname = record.productRegion;
                    }
                }
                
                if(record.productName != null && record.productName != '' && record.action.toLowerCase() != 'delete')
                {
                    if(!isProductNameValid(record.productName.trim()))
                    {
                        if(errormsg == '')
                            errormsg = 'productName is not valid';
                        else
                            errormsg += ', productName is not valid';
                        hasError = true;    
                    }
                     else{
                        //JIRA 3699 skip flow derivative products
                            tempproductname = record.productName + ' - ' + tempproductname;
                    }
                }
                system.debug('tempproductname **:'+tempproductname);
                //JIRA 3699 skip flow derivative products
                if(tempproductname != '' && tempproductname.contains(' - ') && record.action.toLowerCase() != 'delete' && Coverageutil.productstoskip.contains(tempproductname.tolowerCase())){
                    if(errormsg == '')
                            errormsg = 'Cannot add this product: '+ record.productName.trim();
                        else
                            errormsg += ', Cannot add this product: ' + record.productName.trim();
                    hasError = true; 
                }
                //JIRA 3699 skip Instinet products || JIRAA 3862 do not skip Instinet products for instnet contacts
                 if(record.productName != null && record.productName != '' && record.action.toLowerCase() != 'delete' && Coverageutil.productstoskipInstinet.contains(record.productName.tolowerCase()) && CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified).Company__c != 'I')
                {
                    if(errormsg == '')
                            errormsg = 'Cannot add Instinet products';
                        else
                            errormsg += ', Cannot add Instinet products';
                    hasError = true;    
                }

                if(record.productGroup != null &&  record.productGroup!= '' && record.action.toLowerCase() != 'delete')
                {
                    if(!isProductGroupValid(record.productGroup))
                        
                    {
                        if(errormsg == '')
                            errormsg = 'productGroup is not valid';
                        else
                            errormsg += ', productGroup is not valid';
                        hasError = true;    
                    }
                }
                
                
                if(record.role!=null && record.role!='')
                {
                    
                    if(!isRoleValid(record.role))
                    {
                        if(errormsg == '')
                            errormsg = 'role is not valid';
                        else
                            errormsg += ', role is not valid';
                        hasError = true;
                    }
                }
                
                Boolean isGroupNull = false;
                Boolean iProductNull = false;
                Boolean iProductRegionNull = false;
                if(record.productName != null)
                {
                    List<string> productValues = new List<string>();
                    Set<string> productValuesSet = new Set<string>();
                    productValues = record.productName.trim().split(';');
                    productValuesSet.addAll(productValues);							
                    if(record.productName.trim() == '')
                    {
                        iProductNull = true;
                    }
                }
                else
                    iProductNull = true;
                
                
                if(record.productGroup != null)
                {	
                    if(record.productGroup == '')
                    {
                        isGroupNull = true;
                    }
                    else
                    {
                        if(record.productGroup.trim().toLowerCase() == EQ.toLowerCase() || record.productGroup.trim().toLowerCase() == FI.toLowerCase())
                        {
                            boolean found = false;
                            string mapKey = '';
                            if(record.productGroup.trim().toLowerCase() == EQ.toLowerCase())
                                mapKey = EQ;
                            else
                                mapKey = FI;
                     
							if(valueMap.get(mapKey)!=null){
                                for(String prd: valueMap.get(mapKey))
                                {
                                    if(!iProductNull && prd.trim() == record.productName.trim())
                                    {
                                        found = true;
                                        break;
                                    }
                                }
                            }
                            //SKIP for Deletion SALES-3646
                            if(!found && !iProductNull && isProductNameValid(record.productName.trim()) && record.action.toLowerCase() != 'delete')
                            {
                                if(errormsg == '')
                                    errormsg = 'productName is not valid for given productGroup';
                                else
                                    errormsg += ', productName is not valid for given productGroup';
                                hasError = true;
                                
                            }
                        }
                    }
                }
                else
                    isGroupNull = true;
                
                
                if(record.productRegion != null)
                {
                    if(record.productRegion.trim() == '')
                    {
                        iProductRegionNull = true;
                    }
                }
                else
                    iProductRegionNull = true;
                
                
                
                if((!isGroupNull && (iProductNull || iProductRegionNull)) && record.action.trim().toLowerCase() == 'add')
                {
                    if(isProductGroupValid(record.productGroup.trim()))
                    {
                        if(errormsg == '')
                            errormsg = 'productGroup, productRegion and productName are mandatory while associating a product';
                        else
                            errormsg += ', productGroup, productRegion and productName are mandatory while associating a product';
                        hasError = true;
                    }
                    
                }
                else if((!iProductNull && (iProductRegionNull || isGroupNull)) && record.action.trim().toLowerCase() == 'add')
                {
                    
                    if(isProductNameValid(record.productName.trim()))
                    {
                        
                        if(errormsg == '')
                            errormsg = 'productGroup, productRegion and productName are mandatory while associating a product';
                        else
                            errormsg += ', productGroup, productRegion and productName are mandatory while associating a product';
                        hasError = true;   
                    }
                }
                else if((!iProductRegionNull && (isGroupNull && iProductNull)) && record.action.trim().toLowerCase() == 'add')
                {
                    if(isProductRegionValid(record.productRegion.trim()))
                    {
                        if(errormsg == '')
                            errormsg = 'productGroup, productRegion and productName are mandatory while associating a product';
                        else
                            errormsg += ', productGroup, productRegion and productName are mandatory while associating a product';
                        hasError = true;
                    }
                }
                
                system.debug(record.productRegionCombination);
                system.debug(CoverageBulkUploadUtility.productRegionSet);
                
                if(!iProductRegionNull && !iProductNull && !hasError)
                {
                    if(isProductNameValid(record.productName.trim()) && isProductRegionValid(record.productRegion.trim()))
                    {
                        if(record.productRegionCombination!=null && record.productRegionCombination.size() > 0)
                        {
                            
                            for(string p:record.productRegionCombination)
                            {
                                //SKIP Ffor Deletion SALES-3646
                                if(!CoverageBulkUploadUtility.productRegionSet.contains(p.trim().toLowerCase()) && record.action.toLowerCase() != 'delete')
                                {
                                    if(errormsg == '')
                                        errormsg = 'productRegion is not valid for given product';
                                    else
                                        errormsg += ', productRegion is not valid for given product';
                                    
                                    hasError = true;
                                    break;
                                }
                            }
                        }
                    }
                }
                
                if(salesCodeModified!='' && CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified)!=null)
                {
                    if(!(researchSalesCodeOwnerIds.contains(CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified).OwnerId)) &&
                        CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified.trim()).Sales_Desk_Division__c == EQ && (record.productGroup==null || record.productGroup=='') && (record.productName=='' || record.productName == null))
                    {
                        
                        if(record.action != null && record.action !='')
                        {
                            if(record.action.trim().toLowerCase()=='add' )
                            {
                                if(errormsg == '')
                                    errormsg = 'product and productGroup is mandatory for equity Users';
                                else
                                    errormsg += ', product and productGroup is mandatory for equity Users';
                                
                                hasError = true;
                            }
                        }
                    }
                    
                    
                     if(record.transferFromId!=null)
                     {
                         if(CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified.trim()).Id == record.transferFromId.trim())
                         {
                             if(record.action.trim().toLowerCase()=='add' )
                             {
                                 if(errormsg == '')
                                     errormsg = 'Cannot be transferred to same salesCode';
                                 else
                                     errormsg += ', Cannot be transferred to same salesCode';
                                 
                                 hasError = true;
                             }
                         }
                     }
                }
                if(record.fromDate != null && record.fromDate!='') //Meeting date
                {
                    If(!IsValidDate(record.fromDate))
                    {
                        
                        if(errormsg == '')
                            errormsg = 'fromDate not in valid format (mm/dd/yyyy)';
                        else
                            errormsg += ', fromDate not in valid format (mm/dd/yyyy)';
                        hasError = true;
                    } 
                }
                
                if(!hasError)
                {
                    system.debug('IMP: hasonlyRG: '+hasOnlyRG+' hasOnlyRM: '+hasOnlyRM);
                    if(hasOnlyRG)
                    {
                        if(CoverageBulkUploadUtility.rgMapAccStatus.get(record.clientRGkey.trim()) == false &&  record.action.trim().toLowerCase() == 'add')
                        {
                            if(errormsg == '')
                                errormsg = 'You cannot raise coverage for inactive account';
                            else
                                errormsg += ', You cannot raise coverage for inactive account';
                            hasError = true; 
                        }
                    }
                    else if(hasOnlyRM)
                    {
                        if(CoverageBulkUploadUtility.rmMapAccStatus.get(record.clientkey.trim()) == false &&  record.action.trim().toLowerCase() == 'add')
                        {
                            if(errormsg == '')
                                errormsg = 'You cannot raise coverage for inactive account';
                            else
                                errormsg += ', You cannot raise coverage for inactive account';
                            hasError = true; 
                        }
                    }
                    else
                    {
                        if((CoverageBulkUploadUtility.rmMapAccStatus.get(record.clientkey.trim()) == false || CoverageBulkUploadUtility.rgMapAccStatus.get(record.clientRGkey.trim()) == false)&&  record.action.trim().toLowerCase() == 'add')
                        {
                            if(errormsg == '')
                                errormsg = 'You cannot raise coverage for inactive account';
                            else
                                errormsg += ', You cannot raise coverage for inactive account';
                            hasError = true; 
                        }
                    }
                    
                    /***********************************    KEYS START *********************************************************/
                    Integer keySize = 0;
                    List<string> keyData = new List<string>();
                    keyData = key.split('#');
                    keySize = keyData.size();
                    boolean newInsertHasProduct = false;
                    string tempKey = '';
                    
                    if(keySize == 2)
                        newInsertHasProduct = false;
                    if(keySize == 5)
                        newInsertHasProduct = true;
                    tempKey = keyData[0] + '#' + keyData[1];
                    boolean foundKey = false;
                    
                    
                    
                    
                    if(!newInsertHasProduct && !existing_coverages.keyset().contains(key)){
                        for(string presentKeys: existing_coverages.keyset()){
                            system.debug('presentKeys: '+presentKeys);
                            system.debug('tempKey: '+tempKey);
                            string tempKey1 = tempKey;
                            string[] presentKeysClone = presentKeys.split('#');
                            if(rmRGmap.get(keyData[0])!=null)
                            tempKey1 = tempKey1.replace(keyData[0], rmRGmap.get(keyData[0]));
                            if(presentKeys.contains(tempKey) || (presentKeys.contains(tempKey1) && presentKeysClone.size()>=3))
                            {foundKey = true;break;}
                        }
                    }
                    
                    boolean foundRequestKey = false;
                    if(!newInsertHasProduct && !map_CoverageStatus.containsKey(key)){
                        for(string presentRKeys: map_CoverageStatus.keyset()){
                            string tempKey1 = tempKey;
                            if(rmRGmap.get(keyData[0])!=null)
                                tempKey1 = tempKey1.replace(keyData[0], rmRGmap.get(keyData[0]));
                            if(presentRKeys.contains(tempKey) || (presentRKeys.contains(tempKey1) && record.coverageType=='Standard'))
                            {foundRequestKey = true;break;}
                        }
                    }
                    
                    if(record.coverageType!='Standard' && (record.productName==null || record.productName=='')){
                        
                        for(string rmKey: rmkeyList){
                            if(rmKey.contains(key))
                            {foundKey=true;break;}
                        }
                    }
                   
                    
                    

                    if(product_key == '' &&  record.action.trim().toLowerCase() == 'add'){
                        string[] keyElements = key.split('#');
                        if(keyElements!=null && keyElements.size()>0 && rgRMmap.get(keyElements[0])!=null)
                        {
                            for(string rmorgId: rgRMmap.get(keyElements[0])){
                                string keyClone = key;
                                boolean valuefound = false;
                                string rm_replaceby_rg = keyClone.replace(keyElements[0],rmorgId);
                                for(string k: existing_coverages.keyset()){
                                    if(k.contains(rm_replaceby_rg))
                                    {
                                        foundKey=true;
                                        valuefound = true;
                                        break;
                                    }
                                }
                                if(valuefound)
                                break;
                            }
                        }
                    }
                    
                    if(product_key == '' &&  record.action.trim().toLowerCase() == 'add'){
                    for(string productKey :withProductKeys){
                        string[] keyElements = key.split('#');
                        if
                        (  (rmRGmap.get(keyElements[0])!=null && productKey.contains(rmRGmap.get(keyElements[0])+'#'+keyElements[1])) ||
                            (productKey.contains(keyElements[0]+'#'+keyElements[1]))
                        )
                        {
                            if(errormsg == '')
                            errormsg = 'You already have product request for same account and salesperson in your file';
                            else
                                errormsg += ', You already have product request for same account and salesperson in your file';
                            hasError = true;
                            break;
                        }
                    }
                    }
                    
                    if((existing_coverages.keyset().contains(key) || foundKey ) && record.action.trim().toLowerCase() == 'add'){
                        boolean errorfound = true;
                        system.debug('inside ****')  ;
                        system.debug(key);
                        
                        system.debug(existing_coverages);
                        system.debug(record.coverageType);
                        if(existing_coverages.get(key)!=null && record.coverageType!='Standard' && !existing_coverages.get(key).contains(record.coverageType.trim())){
                            errorfound = false;                              
                        }
                        if(existing_coverages.get(key)!=null && record.coverageType!='Standard' && record.subtype!=null && record.subtype!='' && existing_coverages.get(key).contains(record.subType.trim())){
                            errorfound = true;                              
                        }
                        
                        if(record.coverageType!='Standard')
                        {
                            string clonedNFPEkey = key;
                            String[] keyFlag = clonedNFPEkey.split('#');
                            String flag = '';
                            if(record.productName == null || record.productName == '')
                                flag = keyFlag[0] + '#' + keyFlag[1];
                            else
                                flag = key;
                            
                            system.debug(record.subType.trim());
                            system.debug(existing_coverages.get(flag));
                            
                            if(existing_coverages.get(flag)!=null && record.coverageType!='Standard' && record.subtype!=null && record.subtype!='' && existing_coverages.get(flag).contains(record.subType.trim())){
                                errorfound = true;                              
                            }
							else if(existing_coverages.get(flag)!=null && record.coverageType!='Standard' && record.subtype!=null && record.subtype!='' && !existing_coverages.get(flag).contains(record.subType.trim())){
                                errorfound = false;                              
                            }
                            
                            
                        }
                          system.debug(errorfound);
                          if(errorfound && !strOpportunityflow.contains(source)){
                              if(errormsg == '')
                                  errormsg = 'You already have the requested coverage';
                              else
                                  errormsg += ', You already have the requested coverage';
                              hasError = true;
                          }
                          else if(errorfound && strOpportunityflow.contains(source)){
                            //update oppt stage to pending, close te request
                            record.isCreateupdate = true;
                          }
						
					}

                    
                    //added for JIRA 1588 validate Coverage and Coverage Requests exists for Referrer
                    if(RefKey != '' && existing_coverages.get(RefKey)!=null && strOpportunityflow.contains(source)){
                        hasError = true;
                        if(errormsg == '')
                           errormsg = System.Label.ValidateCoverageRequestExists;
                         else
                           errormsg += ', ' + System.Label.ValidateCoverageRequestExists;
                        
                    }
                    if(RefKey != '' && map_CoverageStatus.get(RefKey)!=null && strOpportunityflow.contains(source)){
                        hasError = true;
                        if(errormsg == '')
                           errormsg = System.Label.ValidateCoverageRequestExists;
                         else
                           errormsg += ', '+ System.Label.ValidateCoverageRequestExists;                        
                    }
                    
                    if(record.transferFromId!=null && record.transferTo!=null && record.coverageType!='Standard')
                    {
                        existing_coverages_nfpe.remove(exist_coverage_Flag_nfpe);
                    }
                    
                    system.debug(exist_coverage_Flag_nfpe);
                    system.debug(existing_coverages_nfpe);
                    system.debug(existing_coverages_nfpe.get(exist_coverage_Flag_nfpe));
     				system.debug(record.subType);
                    system.debug(CoverageUtil.FLAG_NFPE_SUBTYPE1_1.toLowerCase());
                    //modified for JIRA sales 3660
					 if(record.role == 'Primary' && record.subType!=null && record.coverageType!='Standard' && existing_coverages_nfpe.get(exist_coverage_Flag_nfpe)!=null && record.subType.toLowerCase() == CoverageUtil.FLAG_NFPE_SUBTYPE1_1.toLowerCase())
                    {
                        string existSalesCode = existing_coverages_nfpe.get(exist_coverage_Flag_nfpe);
                       if(existSalesCode != TeamCoverage_key && existing_coverages_nfpe.get(exist_coverage_Flag_nfpe)!=null){
                            if(!errormsg.contains('You already have the requested coverage')){
                                if(errormsg == '')
                                    errormsg = 'Only one primary coverage is allowed';
                                else
                                    errormsg += ', Only one primary coverage is allowed';
                                hasError = true;
                            }
                        }
                    }
                    
                    system.debug(map_CoverageStatus);
                    system.debug(key);
                    if(record.action == 'delete' && record.clientRGKey!=null)
                    {
                        for(string keyflag: map_CoverageStatus.keyset()){
                            string[] keyclone = keyflag.split('#');
                            string key1 = keyflag;
                           if(!key1.contains(keyclone[0]))
                            key1 = key1.replace(keyclone[0],rmRGmap.get(keyclone[0]));
                            if(key1.toLowerCase() == key.toLowerCase()){
                                if(errormsg == '')
                                    errormsg = 'Your requested coverage is pending for approval';
                                else
                                    errormsg += ', Your requested coverage is pending for approval';
                                hasError = true;
                                break;
                            }
                        }
                    }
                    
                    
                    if((map_CoverageStatus.containsKey(key) || foundRequestKey) && (record.action.trim().toLowerCase() == 'add' || record.action.trim().toLowerCase() == 'delete'))
                    {
                        Set<string> ctypes = new Set<string>();
                        if(map_CoverageStatus.get(key)!=null){
                            for(string s1:  map_CoverageStatus.get(key)){
                                ctypes.addAll(s1.split(':'));
                            }
                        }
                        
                        boolean errorfound = true;
                        system.debug(ctypes);
                        if(ctypes.size() == 1){
                            if(map_CoverageStatus.get(key)!=null && record.coverageType!='Standard' && !map_CoverageStatus.get(key).contains(record.coverageType.trim())){
                                errorfound = false;                              
                            }    
                        }
                        else if(ctypes.size() > 1){
                            if(map_CoverageStatus.get(key)!=null && record.coverageType!='Standard' && record.subtype!=null && record.subtype!='' && ctypes.contains(record.subtype.trim())){
                                errorfound = true;                              
                            }
                            if(map_CoverageStatus.get(key)!=null && record.coverageType!='Standard' && record.subtype!=null && record.subtype!='' && !ctypes.contains(record.subtype.trim())){
                                errorfound = false;                              
                            }
                            
                        }
                        
                        if(errorfound && !strOpportunityflow.contains(source) && !errormsg.contains('You already have the requested coverage') && record.action.toLowerCase()!='delete'){
                            if(errormsg == '')
                                errormsg = 'Your requested coverage is pending for approval';
                            else
                                errormsg += ', Your requested coverage is pending for approval';
                            hasError = true;
                        }
                        else if(errorfound && strOpportunityflow.contains(source)){//add the check for source of the record as cross sell
                            //update oppt stage to pending, cancel te request
                            record.isCreateupdate = true;
                        }
                    }
                    system.debug(existing_coverages_nfpe_request);
                    system.debug(exist_coverage_Flag_nfpe);
                    system.debug(existing_coverages_nfpe_request.get(exist_coverage_Flag_nfpe));
                    if(record.role == 'Primary' && record.subType!=null && record.coverageType!='Standard' && existing_coverages_nfpe_request.get(exist_coverage_Flag_nfpe)!=null 
                       && record.subType.toLowerCase() == CoverageUtil.FLAG_NFPE_SUBTYPE1.toLowerCase())
                    {
                        string existSalesCode = existing_coverages_nfpe_request.get(exist_coverage_Flag_nfpe);
                        if(existSalesCode != TeamCoverage_key && existing_coverages_nfpe_request.get(exist_coverage_Flag_nfpe)!=null){
                            if(!errormsg.contains('You already have the requested coverage') && !errormsg.contains('Your requested coverage is pending for approval')){
                                if(errormsg == '')
                                    errormsg = 'Primary coverage request pending approval for this account';
                                else
                                    errormsg += ', Primary coverage request pending approval for this account';
                                hasError = true;
                            }
                        }
                    }
                    												
						/***********************************    KEYS END *********************************************************/
					system.debug(deletekey);
                    system.debug(rgRMmap);
                    system.debug(RDM_key);
                    system.debug(uniqueKeyforDelete);
                    
                    //added null pointer check for delete
						if(uniqueKeyforDelete.size() > 0 && (!uniqueKeyforDelete.contains(deletekey)) && record.action.trim().toLowerCase() == 'delete')
						{
							boolean found =false;
							if(rgRMmap.get(RDM_key)!=null)
							{
								for(string s: rgRMmap.get(RDM_key))
								{
                                    system.debug(deletekey.replace(RDM_key, s));
                                    
									if(uniqueKeyforDelete.contains(deletekey.replace(RDM_key, s)))
									{
										found = true;
										break;
									}
								}
							}
							system.debug('found '+found);
							if(found == false)
							{
								if(errormsg == '')
									errormsg = 'No coverage found to delete';
								else
									errormsg += ', No coverage found to delete';
								hasError = true;
								hasWarning = true;								
							}
							
						}
                        else if (uniqueKeyforDelete.size() <= 0 && record.action.trim().toLowerCase() == 'delete'){
                            //section added to SKIP for Deletion SALES-3646
                                if(errormsg == '')
									errormsg = 'No coverage found to delete';
								else
									errormsg += ', No coverage found to delete';
								hasError = true;
								//hasWarning = true;
                        }				
                        
                }
            }
            
            
            //if(!hasError)
            //{
                string key1 = '';
                string rgkey = '';
                string rmkey = '';
                string salescodekey = '';
                string productGrpkey = '';
                string productRegionkey = '';
                string productNamekey = '';
                string rolekey = '';
                string actionkey = '';
                string fromDatekey = '';
                string ctype = '';
                string csubtype = '';
                if(record.clientRGKey!=null && record.clientRGKey!='')
                    rgkey = record.clientRGKey.trim();
                if(record.clientKey!=null && record.clientKey!='')
                    rmkey = record.clientKey.trim();
                if(record.salesCode!=null && record.salesCode!='')
                    salescodekey = record.salesCode.trim();
                if(record.productGroup!=null && record.productGroup!='')
                    productGrpkey = record.productGroup.trim();
                if(record.productRegion!=null && record.productRegion!='')
                    productRegionkey = record.productRegion.trim();
                if(record.productName!=null && record.productName!='')
                    productNamekey = record.productName.trim();
                if(record.role!=null && record.role!='')
                    rolekey = record.role.trim();
                if(record.action!=null && record.action!='')
                    actionkey = record.action.trim();
                if(record.fromDate!=null && record.fromDate!='')
                    fromDatekey = record.fromDate.trim();
                if(record.Type!=null && record.Type!='')
                    ctype = record.Type.trim();
                if(record.subType!=null && record.subType!='')
                    csubtype = record.subType.trim();


                if(hasOnlyRM)
                    key1 = rmkey+salescodekey+productGrpkey+productRegionkey+productNamekey+actionkey;
                else
                    key1 = rgkey+salescodekey+productGrpkey+productRegionkey+productNamekey+actionkey;
                
                
                if(uniqueKey.contains(key1))
                {
                    //if(errormsg == '')
                        errormsg = 'Duplicate coverage request found';
                   // else
                        //errormsg += ', Duplicate coverage request found';
                    hasError = true;
                    //hasWarning = true;
                }
                else
                    uniqueKey.add(key1);
                
            //}
            
               
            if(record.clientRGKey!=null && record.clientRGKey!=''){
                if(CoverageBulkUploadUtility.rgMap.get(record.clientRGKey.trim())!=null){
                    record.accountId = CoverageBulkUploadUtility.rgMap.get(record.clientRGKey.trim());
                    record.clientName = CoverageBulkUploadUtility.rgMapAccName.get(record.clientRGKey.trim());
                    record.BillingCountryCode = '';
                }                    
            }
            else if(record.clientKey!=null && record.clientKey!=''){
                if(CoverageBulkUploadUtility.rmMap.get(record.clientKey.trim())!=null) {
                    
                    record.accountId = CoverageBulkUploadUtility.rmMap.get(record.clientKey.trim());
                    
                    
                    if(CoverageBulkUploadUtility.rmMapBillingCode.get(record.clientKey.trim())!=null)
                        record.BillingCountryCode = string.valueof(CoverageBulkUploadUtility.rmMapBillingCode.get(record.clientKey.trim()));
                    if(CoverageBulkUploadUtility.rmMapAccRestricted.get(record.clientKey.trim())) {
                        record.clientName = '(' + record.BillingCountryCode + '-Restricted Jurisdiction) - ' + CoverageBulkUploadUtility.rmMapAccName.get(record.clientKey.trim());
                    }						
                    else {
                        record.clientName = CoverageBulkUploadUtility.rmMapAccName.get(record.clientKey.trim());
                    }
                } 
            }
            
            if(!hasError){
                if(record.productGroup == 'Financial Institutions Group' && !isBM){
                    if(errormsg == '')
                        errormsg = 'Only Business Managers can raise coverage for Financial Institutions Group';
                    else
                        errormsg += ', Only Business Managers can raise coverage for Financial Institutions Group';
                    hasError = true;
                    hasOnlyRG = false;
                }
            }
            //If entire record contains error
            if(hasError){
                if(hasWarning)
                {
                    record.errorType = 'warning';
                    totalWarning++;
                }
                else
                {
                    record.errorType = 'error';
                    csvString += '"'+record.clientRGKey+'"'+','+'"'+record.clientRMKey+'"'+','+'"'+record.salesCode+'"'+','+'"'+record.productGroup+'"'+','+'"'+record.productRegion+'"'+','+'"'+record.productName+'"'+','+'"'+record.role+'"'+','+'"'+record.action+'"'+','+'"'+record.fromDate+'"'+','+'"'+record.includeRestrictedAccounts+'"'+','+'"'+errorMsg+'"'+':'; 
                    totalFailed++;
                }
                
                record.containsError = hasError;
                record.errorMessage = errormsg;
                record.rowNumber = count;
                containsValidationError = true;                
            }
            else {
                record.containsError = false;
                record.rowNumber = count;
                record.errorMessage = 'No Validation Errors';
                record.errorType = 'success';
				//if(record.OpptStage == null)
				//   record.OpptStage = 'Coverage Request';
				if(record.isCreateupdate == null)
                    record.isCreateupdate = false;
				doMapping(record,requestedForUserRG,requestedForUserRM,salesCodeTeamMemberId);
                totalSuccess++;
            }
            
            
            if(record.salesCode!=null && record.salesCode!='') {
                if(CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(record.salesCode)!=null){
                    record.salesCodeID = CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(record.salesCode).Id; 
                    record.salesPerson = CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(record.salesCode).Name; 
                    record.salesTeam = CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(record.salesCode).Sales_Team__c; 
                    record.salesTeamDetails = CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(record.salesCode).Sales_Team_Code__c; 
                }
            }
            //added for JIRA 1588
            if(record.salesRefCode!=null && record.salesRefCode!=''){
                if(CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(record.salesRefCode)!=null){
                    record.salesRefCodeID = CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(record.salesRefCode).Id; 
                    record.salesRefCodeName = CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(record.salesRefCode).Name;
                    record.readOnlyDeskCodes = CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(record.salesRefCode).Desk_Code__c;
                }
            }

            xlRecords_With_Errors.add(record);
            count++;  
        }
    } 
   //commented as no longer required and moved to process staging JIRA 1588
   //public static string submitPartialData(List<Coverage_Temp__c> successList,List<RG_Coverage_Request__c> rgRequestsToDelete,List<Coverage_Access_Request__c> rmRequestsToDelete,Integer totalCount,string guid1)
   @AuraEnabled
    public static string submitPartialData(List<Coverage_Temp__c> successList,Integer totalCount,string guid1)
    {
        string result = '';
        try{
            //Decimal a = 2/0;\
            if(Test.isRunningTest()) {
                guid1 = 'GUID-1';
            }
            system.debug(successList);
            //updated for JIRA SALES !588
           //result = saveToStaging(true,successList,rgRequestsToDelete,rmRequestsToDelete,totalCount,guid1); //IsPartial
           result = saveToStaging(successList,guid1); 
        }
        catch(Exception e){
            processedSuccessfully = false;
            exception_message += e+'\n'+e.getStackTraceString();
            exception_message += '\n';
            result = exception_message;
        }
        return result;
    }
   
   
	
    //modifed for JIRA SALES 1588
	@AuraEnabled
    public static string saveToStaging(List<Coverage_Temp__c> successList,string guid1)
    {
        string result = '';
        //Decimal a = 2/0;
        if(successList.size()>0)
        {
            system.debug('**********SUCCESS LIST*********');
            Database.SaveResult[] results = Database.insert(successList, false);
            Integer countSuccess = 0;
            Integer countFailed = 0;
            Integer count = 0;
            for(Database.SaveResult sr : results){
                if(!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        system.debug('error: '+err.getMessage());
                    }
                    countFailed++;
                }
                else{
                    countSuccess++;
                    system.debug('success');
                }
                count++;
            }
            processedSuccessfully = true;            
            result = startBatch(guid1); 
        }
        else{
            msgType = 'slds-hide';
            processedSuccessfully = false;
        }
        return result;        
    }
    
    
	@AuraEnabled
    public static string startBatch(string guidToProcess)
    { 
        If(Test.isRunningTest())
            currentbatchId = Database.executeBatch(new ProcessStagingCoverages(guidToProcess), 5);
        else
            currentbatchId = Database.executeBatch(new ProcessStagingCoverages(guidToProcess), 1);    
        totalSuccess = 0;
        return  'Your requested Coverage are submitted for processing.'; 
    }
    
   /* @InvocableMethod (label='Process Opportunity' description='This call creates the json and calls the same process')
    public static List<List<String>>  processOppt(List<string> OpportunityIds)
    { 
        //Set<Id> setAccList = new Set<Id>();	
        List<String> result = null;
        List<List<String>> listOfResult = new List<List<String>>(); 

		List<CoverageWrapper> lstCovWrapper = new List<CoverageWrapper>();
		Map<Id,List<Account>> mapParentRMChild = new Map<Id, List<Account>>();
		Map<Id,Opportunity> mapoppAccount = new Map<Id, Opportunity>();
		Id currentUserID = UserInfo.getUserId();
      
		List<Opportunity> opptList = [select id, name, account__c, account__r.RDM_Org_ID__c,StageName,Division__c,Product__c,Product_Region__c,Referral__c,Referral_Sales_Code__c, Referral_Sales_Code__r.Coverage_ID__c,Referre_Sales_Code__c, Referre_Sales_Code__r.Coverage_ID__c from opportunity where id in: OpportunityIds];
		if(opptList.size () >0){
		    for(Opportunity oppt: opptList){
			    //setAccList.add(oppt.account__c);
				CoverageWrapper cov = new CoverageWrapper();
				cov.clientRGKey = oppt.account__r.RDM_Org_ID__c;
				cov.action = 'Add';
				cov.productGroup = oppt.Division__c;
				cov.productName = oppt.Product__c;
				cov.productRegion = oppt.Product_Region__c;
                system.debug('Sales Code **'+ oppt.Referre_Sales_Code__c);
                system.debug('Sales Code **'+ oppt.Referral_Sales_Code__c);
				if(oppt.Referre_Sales_Code__c != null)
				cov.salesRefCode = oppt.Referre_Sales_Code__r.Coverage_ID__c;
				if(oppt.Referral_Sales_Code__c != null)
				cov.Salescode = oppt.Referral_Sales_Code__r.Coverage_ID__c;				
				cov.role = 'Primary';
				cov.OpptId = oppt.Id;
                lstCovWrapper.add(cov);

 				mapoppAccount.put(oppt.account__c,oppt);
			}
		    system.debug('in covebulkuploader 1**'+ mapoppAccount);
            system.debug('in covebulkuploader 1**'+ mapoppAccount.keyset());
            
		    List<Account> lstAccount = [Select Id, Name, Restricted_Flag__c,parentId from Account where ParentId in : mapoppAccount.keyset() and RecordType.Name = 'RM Account'];
		    system.debug('in lstAccount 1**'+ lstAccount);
            if(lstAccount.size() > 0){
			    for(Account acc: lstAccount){
					if(mapParentRMChild.containskey(acc.parentId)){
					   List<Account> lstAcc = mapParentRMChild.get(acc.parentId);
                       lstAcc.add(acc);
					   mapParentRMChild.put(acc.ParentId,lstAcc);
					}
					else{
					   mapParentRMChild.put(acc.ParentId,new List <Account> {acc});
					}
				}
			}
			
			if(mapParentRMChild.size() >0){
			   for(Id ParentRG : mapParentRMChild.keySet()){
			        List<Account> lstacc = new List<Account>();
					lstacc = mapParentRMChild.get(ParentRG);
					for(Account accObj:lstacc){
					    if(accObj.Restricted_Flag__c){
					        Opportunity oppt =  mapoppAccount.get(accObj.ParentId);
							CoverageWrapper cov = new CoverageWrapper();
							cov.clientRGKey = oppt.Account__r.RDM_Org_ID__c;
							cov.action = 'Add';
							cov.productGroup = oppt.Division__c;
							cov.productName = oppt.Product__c;
							cov.productRegion = oppt.Product_Region__c;
							if(oppt.Referre_Sales_Code__c != null)
							cov.salesRefCode = oppt.Referre_Sales_Code__r.Coverage_ID__c;
							if(oppt.Referral_Sales_Code__c != null)
							cov.Salescode = oppt.Referral_Sales_Code__r.Coverage_ID__c;
							cov.role = 'Primary';
							cov.OpptId = oppt.Id;
							lstCovWrapper.add(cov);
                        }					   
					}					
			    }
			}
			if(lstCovWrapper.size() > 0){
			    String strJson = JSON.serialize(lstCovWrapper);
                BulkUploaderCoverageWrapper bulkcov = processImportFromTool(strJson, 'Cross Sell Referral');
                system.debug('bulk ************'+ bulkcov);
                system.debug('bulk ************'+ bulkcov.exceptionMsg);
                system.debug('bulk ************'+ bulkcov.successRecords);
                system.debug('bulk ************'+ bulkcov.successRecords.size());
				if((bulkcov.exceptionMsg == null || bulkcov.exceptionMsg == '') && bulkcov.successRecords != null && bulkcov.successRecords.size() > 0){
				    List<Coverage_Temp__c> lstCov = bulkcov.successRecords; 
					String guid = bulkcov.guid;
                    system.debug('bulk ************'+ guid);
					String strResult = saveToStaging(lstCov, guid);
                    system.debug('strResult ***'+strResult);
                    result.add(strResult);
                    listOfResult.add(result);
				}                
			}
		}
        return listOfResult;
    }*/
     
    //doMapping Wrapper to actualObject
    public static void doMapping(CoverageWrapper xlsRecord,User requestedForUserRG,User requestedForUserRM, Id salesCodeTeamMemberId)
    {
        system.debug('requestedForUserRM Country amd User : '+requestedForUserRM);
        system.debug(xlsRecord);
        Coverage_Temp__c newRecord = new Coverage_Temp__c();
        if(xlsRecord.coverageType!=null)
            newRecord.Type__c = xlsRecord.coverageType.trim();
        if(xlsRecord.subType!=null && xlsRecord.subType!='')
            newRecord.Sub_Type__c = xlsRecord.subType.trim();
        if(xlsRecord.action!=null)
            newRecord.action__c = xlsRecord.action.trim();
        if(xlsRecord.clientKey!=null)
            newRecord.clientKey__c = xlsRecord.clientKey.trim();
        if(xlsRecord.clientRGKey!=null)
            newRecord.clientRGKey__c = xlsRecord.clientRGKey.trim();
        if(xlsRecord.productGroup!=null)
            newRecord.productGroup__c = xlsRecord.productGroup.trim();
        if(xlsRecord.productName!=null)
            newRecord.productName__c = xlsRecord.productName.trim();
        if(xlsRecord.productRegion!=null)
            newRecord.productRegion__c = xlsRecord.productRegion.trim();
        if(xlsRecord.role!=null)
            newRecord.role__c = xlsRecord.role.trim();  
        if(xlsRecord.isAttested!=null)
            newRecord.isAttested__c = xlsRecord.isAttested;
        if(source!=null)
        newRecord.Source__c = source;
         //added for JIRA 1588
        /*if(strOpportunityflow.contains(source) && xlsRecord.OpptId != null){
           //set oppt id 
           newRecord.Referral_Opportunity__c = xlsRecord.OpptId;           
        }*/
        
        if(xlsRecord.userComments!=null && xlsRecord.userComments!='')
        {
             newRecord.Comment__c = xlsRecord.userComments;
        }
        else if(xlsRecord.Comments!=null && xlsRecord.Comments!='')
        {
            xlsRecord.userComments = xlsRecord.Comments;
            newRecord.Comment__c = xlsRecord.userComments;
            //xlsRecord.Comments = '';
        }
        
        if(xlsRecord.transferFromId!=null)
        {
            newRecord.del_salesCode__c = xlsRecord.transferFromId.trim();
           
        }
        if(xlsRecord.salesCode!=null)
        {
            string salesCodeModified2 = '';
            if(xlsRecord.salesCode.trim().length() == 3)
                salesCodeModified2 = '0'+xlsRecord.salesCode.trim();
            else if(xlsRecord.salesCode.trim().length() == 2)
                salesCodeModified2 = '00'+xlsRecord.salesCode.trim();
            else if(xlsRecord.salesCode.trim().length() == 1)
                salesCodeModified2 = '000'+xlsRecord.salesCode.trim();
            else
                salesCodeModified2 = xlsRecord.salesCode.trim();
            
            newRecord.salesCode__c = salesCodeModified2;
            if(CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified2.trim())!=null)
            {
                newRecord.SalesDeskDivision__c = CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified2.trim()).Sales_Desk_Division__c;
                newRecord.SalesDeskRegion__c = CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified2.trim()).Sales_Desk_Region__c;
                newRecord.Is_Dummy__c = CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified2.trim()).Is_dummy__c;
            }
            newRecord.SalesTeamCoverageId__c = salesCodeTeamMemberId;
            system.debug('In Mapping: '+salesCodeTeamMemberId);
            system.debug('requestedForUserRG: '+requestedForUserRG);
            if(xlsRecord.IsRG && requestedForUserRG!=null)
            {
                
                /*if(CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified2.trim()).Is_dummy__c)
                {
                    newRecord.TeamMemberId__c = CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified2.trim()).OwnerId;
                }
                else
                {*/
                    if(requestedForUserRG.Id!=null)
                        newRecord.TeamMemberId__c = requestedForUserRG.Id;
                //}
                if(requestedForUserRG.UserRole.Id!=null)
                    newRecord.RoleId__c = requestedForUserRG.UserRole.Id;
                if(requestedForUserRG.UserRole.ParentRoleId!=null)
                    newRecord.ParentRoleId__c = requestedForUserRG.UserRole.ParentRoleId;
                if(requestedForUserRG.ManagerId!=null)
                {
                    if(requestedForUserRG.Manager.IsActive)
                    newRecord.ManagerId__c = requestedForUserRG.ManagerId;
                }
                if(requestedForUserRG.CountryCode!=null)
                    newRecord.Country__c = requestedForUserRG.CountryCode;
               
                //newRecord.SalesTeamCoverageId__c = CoverageBulkUploadUtility.salesCodeMap.get(salesCodeModified2).Id;
            }
            else if(requestedForUserRM!=null)
            {
                if(requestedForUserRM.Id!=null)
                    newRecord.TeamMemberId__c = requestedForUserRM.Id;
                if(requestedForUserRM.UserRole.Id!=null)
                    newRecord.RoleId__c = requestedForUserRM.UserRole.Id;
                if(requestedForUserRM.UserRole.ParentRoleId!=null)
                    newRecord.ParentRoleId__c = requestedForUserRM.UserRole.ParentRoleId;
                if(requestedForUserRM.ManagerId!=null)
                {
                    if(requestedForUserRM.Manager.IsActive)
                    newRecord.ManagerId__c = requestedForUserRM.ManagerId;
                }
                if(requestedForUserRM.CountryCode!=null)
                    newRecord.Country__c = requestedForUserRM.CountryCode; 
            }
        }
        if(xlsRecord.fromDate!=null && xlsRecord.fromDate!='')
            newRecord.fromDate__c = Date.valueOf(readDateValue(xlsRecord.fromDate));
        else
            newRecord.fromDate__c = system.today();
        
        if(xlsRecord.IsRG)
        {
            if(CoverageBulkUploadUtility.rgMap.get(xlsRecord.clientRGKey.trim())!=null)
            {
                newRecord.accountId__c = CoverageBulkUploadUtility.rgMap.get(xlsRecord.clientRGKey.trim()); 
                newRecord.IsRG__c = true;
            }
        }
        else
        {
            if(CoverageBulkUploadUtility.rmMap.get(xlsRecord.clientKey.trim())!=null)
            {
                newRecord.accountId__c = string.valueOf(CoverageBulkUploadUtility.rmMap.get(xlsRecord.clientKey.trim()));
                newRecord.IsRM__c = true;
            }   
        }

        if(Test.isRunningTest())
            newRecord.GUID__c = 'GUID-1';
        else
            newRecord.GUID__c = guid;    
        
        if(xlsrecord.rowNumber!=null)
            newRecord.rowNumber__c = Integer.valueOf(xlsrecord.rowNumber);
        
        ////added for JIRA 1588
        if((strOpportunityflow.contains(source) && !xlsRecord.isCreateupdate) || !strOpportunityflow.contains(source))
            coveragesToInsert.add(newRecord);
        system.debug('coverage to insert***'+ coveragesToInsert);
    }
    /***************************** VALIDATION FUNCTIONS START**********************************************/
    //0. Check RGKey and RM Both Present (Mandate)
    public static boolean containsRGRMBoth(String rgkey, String rmKey)
    {
        if(rgKey != null && rmKey != null && rgKey != '' && rmKey != '') //No rg and rm
        {
            return true;
        }
        else
        {
            return false;
        }
        return false;
    }
    //1. Check RGKey / RM Present (Mandate)
    public static boolean containsRGORRM(String rgkey, String rmKey)
    {
        if(rgKey == null && rmKey == null || rgKey == '' && rmKey == '') //No rg and rm
        {
            return false;
        }
        else
        {
            return true;
        }
        return false;
    }
	 //0. Check RGKey (Mandate)
    public static boolean containsRG(String rgkey)
    {
        if(rgKey != null  && rgKey != '') //No rg
        {
            return true;
        }
        else
        {
            return false;
        }
        return false;
    }
    //2. Check RGKey
    public static boolean isRGValid(String rgkey)
    {
        if(CoverageBulkUploadUtility.rgMap.get(rgkey.trim())!=null)
        {
            
            return true;
        }
        else
        {
            return false;
        }
        
        return false;
    }
    //3. Check RM Valid
    public static boolean isRMValid(String rmkey)
    {
        system.debug('rmkey: '+rmkey);
        system.debug('CoverageBulkUploadUtility rmMap: '+CoverageBulkUploadUtility.rmMap.size());
        if(CoverageBulkUploadUtility.rmMap.get(rmkey.trim())!=null)
        {
            return true;
        }
        else
        {
            return false;
        }
        return false;
    }
    //4. Check SalesCode Present (Mandate)
    public static boolean containsSalesCode(String code)
    {
        if(code == null|| code == '' ) //No salescode
        {
            return false;
        }
        else
        {
            return true;
        }
        return false;
    }
    //7. Check Roles Present (Mandate)
    public static boolean containsRole(String role)
    {
        if(role == null  || role == '') //No rg and rm
        {
            return false;
        }
        else
        {
            return true;
        }
        return false;
    }
    //8. Check roles Valid
    public static boolean isRoleValid(String role)
    {
        if(CoverageBulkUploadUtility.Roles.contains(role.trim().toLowerCase()))
            return true;
        else
            return false;
        return false;
    }
    //9. Check Action Present (Mandate)
    public static boolean containsAction(String action)
    {
        if(action == null  || action == '') 
        {
            return false;
        }
        else
        {
            return true;
        }
        return false;
    }
    
    //10. Check Action Valid
    public static boolean isActionValid(String action)
    {
        if(CoverageBulkUploadUtility.Action.contains(action.trim().toLowerCase()))
            return true;
        else
            return false;
        return false;
    }
    
    //11. Check Date Valid (yyyy-mm-dd)
    public static Boolean IsValidDate(string datedata)
    {
        Integer monthValue = 0;
        Integer dayValue = 0;
        Integer YearValue = 0;
        List<String> dateParts = new List<String>();
        system.debug('Date: '+datedata);
        try
        {
            dateParts = datedata.split('/');
            if(dateParts.size() == 3)
            {   
                dayValue = Integer.valueOf(dateParts[1]);
                monthValue = Integer.valueOf(dateParts[0]);
                YearValue = Integer.valueOf(dateParts[2]);
                system.debug('day: '+dayValue);
                system.debug('month: '+monthValue);
                system.debug('year: '+YearValue);
                
                if(monthValue < 0 || monthValue > 12)
                    return false;
                
                if(dayValue <= 0 || dayValue > 31)
                    return false;
                
                return true;
            }
            else
            {
                return false;
            }
        }
        catch(Exception e)
        {
            return false;
        }
        
        
        /*Pattern datePattern = Pattern.compile('^(([0-9])|([0-2][0-9])|([3][0-1]))-(Jan|JAN|Feb|FEB|Mar|MAR|Apr|APR|May|MAY|Jun|JUN|Jul|JUL|Aug|AUG|Sep|SEP|Oct|OCT|Nov|NOV|Dec|DEC)-[0-9][0-9][0-9][0-9]$');
matcher myMatcher = datePattern.matcher(datedata);

if(myMatcher.matches())
return true;
else
return false;
return false;*/
    }
    
    public static string readDateValue(string datedata)
    {
        Integer monthValue = 0;
        Integer dayValue = 0;
        Integer YearValue = 0;
        List<String> dateParts = new List<String>();
        system.debug('Date: '+datedata);
        try
        {
            dateParts = datedata.split('/');
            if(dateParts.size() == 3)
            {   
                dayValue = Integer.valueOf(dateParts[1]);
                monthValue = Integer.valueOf(dateParts[0]);
                YearValue = Integer.valueOf(dateParts[2]);
                system.debug('day: '+dayValue);
                system.debug('month: '+monthValue);
                system.debug('year: '+YearValue);
                
                return YearValue+'-'+monthValue+'-'+dayValue;
            }
            else
            {
                return 'error';
            }
        }
        catch(Exception e)
        {
            return 'error';
        }
        
    }
    
    //12. Check ProductGroup Valid
    public static boolean isProductGroupValid(string productGroup)
    {
        string [] ProductRegions = productGroup.trim().split(';');
        boolean status = true;
        for(String region: ProductRegions)
        {
            if(!CoverageBulkUploadUtility.ProductGroup.contains(region.toLowerCase()))
            {
                status = false;
            }
        }
        return status;
    }
    
    //13. Check ProductRegion Valid
    public static boolean isProductRegionValid(String productRegion)
    {
        system.debug('CoverageBulkUploadUtility.ProductRegion **'+CoverageBulkUploadUtility.ProductRegion);
        if(CoverageBulkUploadUtility.ProductRegion.contains(productRegion.trim().toLowerCase()))
            return true;
        else
            return false;
        return false;
    }
    
    //14. Check ProductName Valid
    public static boolean isProductNameValid(string productNameSet)
    {
        boolean isValid = true;
        
        if(!CoverageBulkUploadUtility.ProductName.contains(productNameSet.trim().toLowerCase()))
            return false;
        
        
        return true;
    }
    
    /***************************** VALIDATION FUNCTIONS END**********************************************/
    
    
    @AuraEnabled
    public static Map<String,String> getSampleTemplateDownloadID()
    {
        Map<String,String> templateMap = new Map<String,String>();
        string isCommentAccessible = CoverageToolController.isCommentAccessible();
        system.debug('isCommentAccessible (download): '+isCommentAccessible);
        Set<String> templateNameSet = new Set<String>();

        templateNameSet.add('Coverage_Without_Product_Sample_Template');
        if(isCommentAccessible=='true:rw'){
            templateNameSet.add('Coverage_Sample_Template_BM');
        }
        else {
            templateNameSet.add('Coverage_Sample_Template');
        }    
        
        List<Document> templateList = [
                        SELECT Id, DeveloperName FROM Document 
                        WHERE DeveloperName IN :templateNameSet
                    ];
        
        if(templateList != null && templateList.size() > 0){
                for(Document documentObj : templateList){
                    if('Coverage_Sample_Template'.equalsIgnoreCase(documentObj.DeveloperName)){
                        templateMap.put('coverageSampleTemplate', documentObj.Id);
                    }
                    else if('Coverage_Sample_Template_BM'.equalsIgnoreCase(documentObj.DeveloperName)){
                        templateMap.put('coverageSampleTemplateBM', documentObj.Id);
                    }
                    else if('Coverage_Without_Product_Sample_Template'.equalsIgnoreCase(documentObj.DeveloperName)){
                        templateMap.put('coverageWithoutProductSampleTemplate', documentObj.Id);
                    }
                }
            }            

        return templateMap;
        
    } 
    
}