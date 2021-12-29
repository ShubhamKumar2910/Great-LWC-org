public with sharing class  CoverageToolDataController {
    public static Decimal YTDSummary {get;set;}
    public static Decimal WTDSummary {get;set;}
    public static Decimal MTDSummary {get;set;}
    public static Decimal YTDBudgetSummary {get;set;}
    public static string userRegion = '';
    public static string csvString = '';
    public static List<string> csvKeys = new List<string>();
    public static Boolean doNotShowRevenueColumns = false;
    public static string uComments = '';
    public static string uStartdate = '';
    public static string uRole = '';
    public static string uRegion = '';
    public static string uGroup = '';
    public static Boolean uIsAttested = false;
    public static List<string> uProducts = new List<string>();
    public static List<string> uSalesTeamCoverageIds = new List<string>();
    public static Set<string> uniqueKeys = new Set<string>();
    public static Map<string,List<string>> mapRGRequestNFPE = new Map<string,List<string>>();
    public static List<Sales_Team_for_Coverage__c> salesTeamCoverage = new List<Sales_Team_for_Coverage__c>();

    public static Set<string> Types = new Set<string>();
    public static  Map<string,List<string>> coverageTypesMap = new Map<string,List<string>>();
    public static  List<Account_Coverage_Types__mdt> cTypes = new  List<Account_Coverage_Types__mdt>();
    public static string FLAG_NFPE_SUBTYPE1_APINAME = CoverageUtil.FLAG_NFPE_SUBTYPE1_APINAME;
    public static string FLAG_NFPE_SUBTYPE2_APINAME = CoverageUtil.FLAG_NFPE_SUBTYPE2_APINAME;
	public static string FLAG_NFPE_SUBTYPE3_APINAME = CoverageUtil.FLAG_NFPE_SUBTYPE3_APINAME;
    public static string FLAG_NFPE1_APINAME = CoverageUtil.FLAG_NFPE1_APINAME;
    public static string FLAG_NFPE_APINAME = CoverageUtil.FLAG_NFPE_APINAME;
    static string rgOrgID= System.Label.RGID;
    static string clientRG=  System.Label.CVGTOOL_ACCOUNT_NAME;
    static string TypeCSV=  System.Label.CVGTOOL_Type;
    static string team=  System.Label.CVGTOOL_TEAM;
    static string salesPerson=  System.Label.CVGTOOL_SALESPERSON;
    static string coverageID= System.Label.SalesCode;
    static string teamrole=  System.Label.CVGTOOL_ROLE;
    static string startDate=  System.Label.CVGTOOL_START_DATE;
    static string status=  System.Label.CVGTOOL_STATUS;
    static string Comments=  System.Label.CVGTOOL_Comment;
    static string ytdRevenue=  System.Label.CVGTOOL_YTD_USD;
    static string ytdBudget=  System.Label.CVGTOOL_BUDGET_USD;
    static string mtdRevenue=  System.Label.CVGTOOL_MTD_USD;
    static string wtdRevenue=  System.Label.CVGTOOL_WTD_USD;
    static string endDate=  System.Label.CVGTOOL_END_DATE;
    static string region=  System.Label.CVGTOOL_REGION;
    static string desk=  System.Label.CVGTOOL_DESK;
    static string product=  System.Label.CVGTOOL_PRODUCT;
    static string productRegion=  System.Label.CVGTOOL_PRODUCT_REGION;
    
    public CoverageToolDataController(){
      //  rgOrgID = Label.RGID_label;

    }
    
    @AuraEnabled
    public static List<CoverageDataWrapper> getExistingCoveragesExcludingSalesCode(string product, string productRegion,
                                                                                   string productGroup, string salesCodeId, 
                                                                                   string clientId, boolean isRM , boolean isRG,string salesteam,
                                                                                  string coveragetype,string subType)
    {
        CoverageToolController.isCommentAccessible();
        system.debug('product: '+product);
        system.debug('productRegion: '+productRegion);
        system.debug('productGroup: '+productGroup);
        system.debug('salesCodeId: '+salesCodeId);
        system.debug('clientId: '+clientId);
        system.debug('isRM: '+isRM);
        system.debug('isRG: '+isRG);
        system.debug('salesteam: '+salesteam); 
        system.debug('coveragetype: '+coveragetype); 
         system.debug('subType: '+subType); 
        
        
        List<CoverageDataWrapper> wrapperlist = new List<CoverageDataWrapper>();
        Map<string,string> mapofYTDByRG = new Map<string,string>();
        
        string rgquery = 'SELECT MIN(id) coverageID, MIN(Account__r.Parent.RDM_Org_ID__c) RGORGID, Account__r.Parent.Id RGID,'+
            'MIN(Account__r.Parent.Name) RGNAME, MIN(Account__c) RMID,MIN(Account__r.Name) RMNAME, Product_Group__c PGRP, Product_Region__c PREG,'+
            'Product__c PRD,MIN(Team_Role__c) TMROLE, MIN(Start_Date__c) STARTDATE, MIN(End_Date__c) ENDDATE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Division__c) DIV,MIN(Sales_Team_for_Coverage__r.Coverage_ID__c) CODEID,Sales_Team_for_Coverage__c CVGID,'+
            'MIN(Account__r.RDM_Org_ID__c) RMORGID, MIN(Sales_Team_for_Coverage__r.Desk_Name__c) DESK,'+
            'MIN(Sales_Team_for_Coverage__r.Sales_Team__c) TEAM, MIN(Sales_Team_for_Coverage__r.Name) SPerson, MIN(Team_Member__c)'+
            'SPID, MIN(LastModifiedBy.Name) MODIFIED, MIN(LastModifiedById) MODIFIEDID FROM Coverage_Team_Member__c';
        
        string rmquery = 'SELECT MIN(id) coverageID, MIN(Account__r.Parent.RDM_Org_ID__c) RGORGID, MIN(Account__r.Parent.Id) RGID,'+
            'MIN(Account__r.Parent.Name) RGNAME, Account__c RMID,MIN(Account__r.Name) RMNAME, Product_Group__c PGRP, Product_Region__c PREG,'+
            'Product__c PRD,MIN(Team_Role__c) TMROLE, MIN(Start_Date__c) STARTDATE, MIN(End_Date__c) ENDDATE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Division__c) DIV,MIN(Sales_Team_for_Coverage__r.Coverage_ID__c) CODEID,Sales_Team_for_Coverage__c CVGID,'+
            'MIN(Account__r.RDM_Org_ID__c) RMORGID, MIN(Sales_Team_for_Coverage__r.Desk_Name__c) DESK,'+
            'MIN(Sales_Team_for_Coverage__r.Sales_Team__c) TEAM, MIN(Sales_Team_for_Coverage__r.Name) SPerson, MIN(Team_Member__c)'+
            'SPID, MIN(LastModifiedBy.Name) MODIFIED, MIN(LastModifiedById) MODIFIEDID FROM Coverage_Team_Member__c';
        
        string whereClause = '';
        if(!test.isRunningTest())
        {
            if(coveragetype.trim() == CoverageUtil.FLAG_NFPE)
            {
                //Added for SALES 3660
                 if(subType!=null && (subType == CoverageUtil.FLAG_NFPE_SUBTYPE1 || subType == CoverageUtil.FLAG_NFPE_SUBTYPE1_1)){
                    whereClause = ' where Sales_Team_for_Coverage__c !=:salesCodeId and Product_Group__c=:productGroup and Product_Region__c=:productRegion and Product__c=:product and Is_Deleted__c = false and END_DATE__c = null and Sales_Team_for_Coverage__r.Sales_Team__c=:salesteam and (NOT UniqueId__c Like  \'%PREVDELETE%\')';
                    whereClause += ' and '+FLAG_NFPE_SUBTYPE1_APINAME+' = true';
                }
                
                if(subType!=null && subType == CoverageUtil.FLAG_NFPE_SUBTYPE2){
                    whereClause = ' where Sales_Team_for_Coverage__c !=:salesCodeId and Product_Group__c=:productGroup and Product_Region__c=:productRegion and Product__c=:product and Is_Deleted__c = false and END_DATE__c = null and Sales_Team_for_Coverage__r.Sales_Team__c=:salesteam and (NOT UniqueId__c Like  \'%PREVDELETE%\')';
                    whereClause += ' and '+FLAG_NFPE_SUBTYPE2_APINAME+' = true';
                }
				//Added for SALES JIRA 3660
				if(subType!=null && (subType == CoverageUtil.FLAG_NFPE_SUBTYPE3 || subType == CoverageUtil.FLAG_NFPE_SUBTYPE3_1)){
                    whereClause = ' where Sales_Team_for_Coverage__c !=:salesCodeId and Product_Group__c=:productGroup and Product_Region__c=:productRegion and Product__c=:product and Is_Deleted__c = false and END_DATE__c = null and Sales_Team_for_Coverage__r.Sales_Team__c=:salesteam and (NOT UniqueId__c Like  \'%PREVDELETE%\')';
                    whereClause += ' and '+FLAG_NFPE_SUBTYPE3_APINAME+' = true';
                }
				
				
                
            }
            else if(coveragetype.trim() == 'NFPE1')
            {
                whereClause = ' where Sales_Team_for_Coverage__c !=:salesCodeId and Product_Group__c=:productGroup and Product_Region__c=:productRegion and Product__c=:product and Is_Deleted__c = false and END_DATE__c = null and Sales_Team_for_Coverage__r.Sales_Team__c=:salesteam and (NOT UniqueId__c Like  \'%PREVDELETE%\')';
                whereClause += ' and '+FLAG_NFPE1_APINAME+' = true';
            }
            else
                whereClause = ' where Sales_Team_for_Coverage__c !=:salesCodeId and Product_Group__c=:productGroup and Product_Region__c=:productRegion and Product__c=:product and Is_Deleted__c = false and END_DATE__c = null and Sales_Team_for_Coverage__r.Sales_Team__c=:salesteam and (NOT UniqueId__c Like  \'%PREVDELETE%\')';
        }
        else
        {
            whereClause = ' where Product_Group__c=:productGroup'+
                +' and Product_Region__c=:productRegion and Product__c=:product and Is_Deleted__c = false and END_DATE__c = null and (NOT UniqueId__c Like  \'%PREVDELETE%\')';
        }
        
        string rggroupClause = ' group by Account__r.Parent.Id,Sales_Team_for_Coverage__c, Product_Group__c, Product_Region__c, Product__c';
        string rmgroupClause = ' group by Account__c,Sales_Team_for_Coverage__c, Product_Group__c, Product_Region__c, Product__c';
        
        
        string rmOrRGClause = '';
        List<AggregateResult> cvglist = new List<AggregateResult>();
        
        
        if(isRM)
        {
            system.debug('In RM');
            whereClause +=' and Account__c=:clientId';
            rmquery += whereClause;
            rmquery += rmgroupClause;
            cvglist =  CoverageDataWithoutSharingController.getTeamCoverageTeamMember (product, productRegion,
                                                                                       productGroup,  salesCodeId, 
                                                                                       clientId,  isRM ,  isRG, salesteam,rmQuery);
        }
        else if(isRG)
        {
            whereClause +=' and Account__r.ParentId=:clientId';
            rgquery += whereClause;
            rgquery += rggroupClause;
            cvglist = CoverageDataWithoutSharingController.getTeamCoverageTeamMember (product, productRegion,
                                                                                      productGroup,  salesCodeId, 
                                                                                      clientId,  isRM ,  isRG, salesteam,rgQuery);
        }
        
        /********************* GET LOGGED IN USER REGION ******************************/
        User callingUser = [SELECT Id,User_Profile_Name__c,Name, Region__c FROM User WHERE Id = : UserInfo.getUserId()] ;  
        if(callingUser.Region__c!=null)
            userRegion = callingUser.Region__c;
        
        
        set<string> RGIds = new Set<string>();
        set<string> restrictedrmIds = new Set<string>();
        set<string> coverageIds = new Set<string>();
        set<string> SalesTeamCoverageIds = new Set<string>();
        
        
        for(AggregateResult clientCVG:cvglist){
            if(clientCVG.get('RGID')!=null && clientCVG.get('RGID')!='' && clientCVG.get('CVGID')!=null && clientCVG.get('CVGID')!='')
            {
                RGIds.add(string.valueOf(clientCVG.get('RGID')));
                SalesTeamCoverageIds.add(string.valueOf(clientCVG.get('CVGID')));
            }
            
            if(clientCVG.get('CODEID')!=null && clientCVG.get('CODEID')!='')
            {
                coverageIds.add(string.valueOf(clientCVG.get('CODEID')));
            } 
        }
        
        mapofYTDByRG = getYTDList(coverageIds,RGIds);
        Integer i = 1;
        YTDSummary = 0;
        YTDBudgetSummary = 0;
        WTDSummary = 0;
        MTDSummary = 0;
       
        
        for(AggregateResult clientCVG:cvglist)
        {
            CoverageDataWrapper wrapper = new CoverageDataWrapper();
            wrapper.rowNumber = i;
            
            if(clientCVG.get('RGID')!=null && clientCVG.get('SPerson')!=null && clientCVG.get('RGID')!='' && clientCVG.get('SPerson')!='')
                wrapper.Id = string.valueOf(clientCVG.get('RGID')).trim()+':' + string.valueOf(clientCVG.get('SPerson')).trim();
            
            
            if(clientCVG.get('PGRP')!=null && clientCVG.get('PGRP')!='')
                wrapper.productGroup =string.valueOf(clientCVG.get('PGRP'));
            else
                wrapper.productGroup = '';
            
            if(clientCVG.get('PREG')!=null && clientCVG.get('PREG')!='')
                wrapper.productRegion = string.valueOf(clientCVG.get('PREG'));
            else
                wrapper.productRegion = '';    
            
            if(clientCVG.get('PRD')!=null && clientCVG.get('PRD')!='')
                wrapper.product = string.valueOf(clientCVG.get('PRD'));
            else
                wrapper.product = '';
            
           
                if(!CoverageToolController.isEquityUser){
                    if(clientCVG.get('RGID')!=null && clientCVG.get('RGID')!='' && clientCVG.get('CODEID')!=null && clientCVG.get('CODEID')!='')
                    {
                        if(mapofYTDByRG.get(string.valueOf(clientCVG.get('RGID'))+string.valueOf(clientCVG.get('CODEID')))!=null)
                        {
                            string[] revenue = mapofYTDByRG.get(string.valueOf(clientCVG.get('RGID'))+string.valueOf(clientCVG.get('CODEID'))).split(':');
                            if(revenue.size() == 4)
                            {
                                wrapper.ytdRevenue = Decimal.valueOf(Double.valueOf(revenue[0]));
                                YTDSummary +=  Decimal.valueOf(Double.valueOf(revenue[0]));
                                wrapper.ytdBudget = Decimal.valueOf(Double.valueOf(revenue[1]));
                                YTDBudgetSummary +=  Decimal.valueOf(Double.valueOf(revenue[1]));
                                wrapper.wtdRevenue = Decimal.valueOf(Double.valueOf(revenue[2]));
                                WTDSummary +=  Decimal.valueOf(Double.valueOf(revenue[2]));
                                wrapper.mtdRevenue = Decimal.valueOf(Double.valueOf(revenue[3]));
                                MTDSummary +=  Decimal.valueOf(Double.valueOf(revenue[3]));
                            }
                        }
                        else
                        {
                            wrapper.ytdRevenue = 0;
                            wrapper.ytdBudget = 0;
                            wrapper.wtdRevenue = 0;
                            wrapper.mtdRevenue = 0;
                            
                        }
                    }
                    else
                    {
                        wrapper.ytdRevenue = 0;
                        wrapper.ytdBudget = 0;
                        wrapper.wtdRevenue = 0;
                        wrapper.mtdRevenue = 0;
                    }
                }
                else
                {
                    wrapper.ytdRevenue = null;
                    wrapper.ytdBudget = null;
                    wrapper.wtdRevenue = null;
                    wrapper.mtdRevenue = null;
                    
                }
           
            
            if(clientCVG.get('TEAM')!=null && clientCVG.get('TEAM')!='')
                wrapper.team = string.valueOf(clientCVG.get('TEAM'));
            else
                wrapper.team = '';
            
            
            if(clientCVG.get('CVGID')!=null)
                wrapper.salesCodeID = string.valueOf(clientCVG.get('CVGID'));
            else
                wrapper.salesCodeID = '';
            
            if(clientCVG.get('CODEID')!=null && clientCVG.get('CODEID')!='')
                wrapper.coverageID = string.valueOf(clientCVG.get('CODEID'));
            else
                wrapper.coverageID = '';
            
            
            if(clientCVG.get('SPerson')!=null && clientCVG.get('SPerson')!='')
                wrapper.salesPerson = string.valueOf(clientCVG.get('SPerson'));
            else
                wrapper.salesPerson = '';
            
            if(clientCVG.get('SPID')!=null && clientCVG.get('SPID')!='')
                wrapper.salesPersonId = string.valueOf(clientCVG.get('SPID'));
            else
                wrapper.salesPersonId = '';
            
            if(clientCVG.get('RGID')!=null && clientCVG.get('RGID')!='')
            {
                wrapper.clientRGId = string.valueOf(clientCVG.get('RGID'));
            }
            else
            {
                wrapper.clientRGId = '';
            }
            
            if(clientCVG.get('RGNAME')!=null && clientCVG.get('RGNAME')!='')
            {
                wrapper.clientRG = string.valueOf(clientCVG.get('RGNAME'));
                wrapper.accountName = string.valueOf(clientCVG.get('RGNAME'));
            }
            else
                wrapper.clientRG = '';
            
            if(clientCVG.get('RMID')!=null && clientCVG.get('RMID')!='')
            {
                wrapper.clientRMId = string.valueOf(clientCVG.get('RMID'));           }
            else
            {
                wrapper.clientRMId = '';
            }
            
            if(clientCVG.get('RMNAME')!=null && clientCVG.get('RMNAME')!='')
            {
                wrapper.clientRM = string.valueOf(clientCVG.get('RMNAME'));
                wrapper.accountName = string.valueOf(clientCVG.get('RMNAME'));
            }
            else
                wrapper.clientRM = ''; 
            
            
            if(clientCVG.get('TMROLE')!=null && clientCVG.get('TMROLE')!='')
                wrapper.role = string.valueOf(clientCVG.get('TMROLE'));
            else
                wrapper.role = '';
            
            wrapper.isChecked = false;
            
            wrapperlist.add(wrapper);
            i++;
        }
         if(CoverageToolController.isEquityUser)
            doNotShowRevenueColumns = true;
        else
            doNotShowRevenueColumns = false;
        return wrapperlist;
    }    
    
    
    @AuraEnabled
    public static String getLoggedInUserDivision() {
        return userinfo.getName();
    }
    
    public static void populateCoverageTypesInfo(list<string> coverageTypes,string operation){
        system.debug('populate coverage types called');
        Types = new Set<string>();
        coverageTypesMap = new Map<string,List<string>>();
       Set<string> actualtypes = new Set<string>();
        for(string cvType:coverageTypes){
            string nfpe_sub1 = coverageutil.FLAG_NFPE_SUBTYPE1;
            string nfpe_sub2 = coverageutil.FLAG_NFPE_SUBTYPE2;
			string nfpe_sub3 = coverageutil.FLAG_NFPE_SUBTYPE3;
            //Added for JIRA Sales 3660
            string nfpe_sub3_1 = coverageutil.FLAG_NFPE_SUBTYPE3_1;
            string nfpe_sub1_1 = coverageutil.FLAG_NFPE_SUBTYPE1_1;
            
            string nfpe1 = coverageutil.FLAG_NFPE1;
           if(cvType.replace('_',' ').toLowerCase() == nfpe_sub1.toLowerCase() || cvType.replace('_',' ').toLowerCase() == nfpe_sub1_1.toLowerCase())
            actualtypes.add(coverageutil.FLAG_NFPE_SUBTYPE1.replace(' ','_'));
           if(cvType.replace('_',' ').toLowerCase() == nfpe_sub2.toLowerCase())
            actualtypes.add(coverageutil.FLAG_NFPE_SUBTYPE2.replace(' ','_'));
			if(cvType.replace('_',' ').toLowerCase() == nfpe_sub3.toLowerCase()  || cvType.replace('_',' ').toLowerCase() == nfpe_sub3_1.toLowerCase())
            actualtypes.add(coverageutil.FLAG_NFPE_SUBTYPE3.replace(' ','_'));
           if(cvType.replace('_',' ').toLowerCase() == nfpe1.toLowerCase())
            actualtypes.add(coverageutil.FLAG_NFPE1.replace(' ','_'));
        }
        cTypes = [SELECT Id, Type__c,QualifiedApiName,Label FROM Account_Coverage_Types__mdt where QualifiedApiName in: actualtypes];
    
        
        for(Account_Coverage_Types__mdt ctype: cTypes)
        {
            Types.add(ctype.Type__c);
            if(coverageTypesMap.get(ctype.Type__c) == null){
                coverageTypesMap.put(ctype.Type__c, new List<string>{ctype.label});
            }
            else
            {
                coverageTypesMap.get(ctype.Type__c).add(ctype.label);
            }
        }
    }

    public static List<CoverageWrapper> getSelectedRMCoveragesforCSV(List<CoverageWrapper> csvRecords,Map<string,string> rgMap
                                                                    ,Set<string> csvRGIds)
    {
        try{
        system.debug('************** FETCHING RMs for CSV (START)***********************');
        string clientRGKey = '';
        string salesCode = '';
        string productName = '';
        string productGroup = '';
        string productRegion = '';
        string role = '';
        string startDate = '';
        List<string> coverageTypes = new List<string>();
        List<string> clientIDS = new List<string>();
        List<string> subset_clientIDS = new List<string>();
        List<string> salesTeamCoverageIds = new List<string>();
        List<string> all_salesTeamCoverageIds = new List<string>();
        List<string> products = new List<string>();
        string comments = '';
        List<CoverageDataWrapper> datawrapper = new List<CoverageDataWrapper>(); 
        List<CoverageWrapper> wrapperList = new List<CoverageWrapper>(); 
        Map<Integer,List<string>> maprecordCoverageTypes = new Map<Integer,List<string>>();
        
        Integer i = 0;
        for(CoverageWrapper record: csvRecords){
            coverageTypes = new List<string>();
            
            if(record.Type!=null && record.Type!='' && record.action == 'Add'){
                for(String ctype: record.Type.split(',')){
                    coverageTypes.add(ctype.trim().replace(' ','_').trim());    
                }
            }
            
            if(coverageTypes.size()>0)
                maprecordCoverageTypes.put(i, coverageTypes);
            
            if(record.clientRGKey!=null && record.clientRGKey!='')
            {
                clientRGKey = record.clientRGKey;
                if(rgmap.get(clientRGKey)!=null)
                    clientIDS.add(rgmap.get(clientRGKey));
            }
            
            if(record.salesCode!=null && record.salesCode!='')
            {
                salesCode = record.salesCode;
                string salesCodeModified = '';
                if(record.salesCode.trim().length() == 3)
                    salesCodeModified = '0'+record.salesCode.trim();
                else if(record.salesCode.trim().length() == 2)
                    salesCodeModified = '00'+record.salesCode.trim();
                else if(record.salesCode.trim().length() == 1)
                    salesCodeModified = '000'+record.salesCode.trim();
                else
                    salesCodeModified = record.salesCode.trim();
                
                if(CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified)!=null)
                {
                    all_salesTeamCoverageIds.add(CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified).Id);
                }							
                
            }
            i++;
        }
        
        Map<string,Sales_Team_for_Coverage__c> salesCodeMap = new  Map<string,Sales_Team_for_Coverage__c>();
        for(Sales_Team_for_Coverage__c scode: CoverageUtil.getSalesTeamCoverage(all_salesTeamCoverageIds))
            salesCodeMap.put(scode.Id, scode);
        
        List<Account> nfpe_accountListCSV = new List<Account>();
        List<Account> std_accountListCSV = new List<Account>();
        coverageTypes = new List<string>();
            
        if(maprecordCoverageTypes.size()>0)
        {
            for(Integer c : maprecordCoverageTypes.keyset())
            coverageTypes.addAll(maprecordCoverageTypes.get(c));
            if(coverageTypes.size() > 0){
                populateCoverageTypesInfo(coverageTypes,'CSV');
                nfpe_accountListCSV =  getNFPEAccountList(Types,clientIDS); 
                std_accountListCSV =  getStandardAccountList(clientIDS);   
            }
        }
        else
        {
			 std_accountListCSV =  getStandardAccountList(clientIDS);             
        }
        
        Integer k = 0;      
        for(CoverageWrapper record: csvRecords){
           salesTeamCoverageIds = new List<string>();
            products = new List<string>();
            subset_clientIDS = new List<string>();
            if(record.clientRGKey!=null && record.clientRGKey!='')
            {
                clientRGKey = record.clientRGKey;
                if(rgmap.get(clientRGKey)!=null)
                    subset_clientIDS.add(rgmap.get(clientRGKey));
            }
            string salesCodeModified = '';
            string salesCodeId = '';    
            if(record.salesCode!=null && record.salesCode!='')
            {
                salesCode = record.salesCode;
                if(record.salesCode.trim().length() == 3)
                    salesCodeModified = '0'+record.salesCode.trim();
                else if(record.salesCode.trim().length() == 2)
                    salesCodeModified = '00'+record.salesCode.trim();
                else if(record.salesCode.trim().length() == 1)
                    salesCodeModified = '000'+record.salesCode.trim();
                else
                    salesCodeModified = record.salesCode.trim();
                
                if(CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified)!=null)
                {
                    salesCodeId = CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified).Id;
                    salesTeamCoverageIds.add(CoverageBulkUploadUtility.mapSalesCodeByTeamCoverageId.get(salesCodeModified).Id);
                }							
                
            }
            if(record.productName!=null && record.productName!='')
            {
                productName = record.productName;
                products.add(productName);
            }
            if(record.productGroup!=null && record.productGroup!='')
                productGroup = record.productGroup;
            if(record.productRegion!=null && record.productRegion!='')
                productRegion = record.productRegion;
            if(record.role!=null && record.role!='')
                role = record.role;
            if(record.fromDate!=null && record.fromDate!='')
                startDate = CoverageBulkUploadController.readDateValue(record.fromDate);
            else
                startDate = string.valueOf(system.today());
            
             if(record.Comments!=null && record.Comments!='')
                 Comments = record.Comments;
            
            system.debug(subset_clientIDS);
            system.debug(salesTeamCoverageIds);
            system.debug(products);
            system.debug(productGroup);
            system.debug(productRegion);
            system.debug(role);
            system.debug(Types);
            system.debug(startDate);
            system.debug(Comments);
            
            if(productName!='' && record.productName!=null && record.productName!='')
            {
                string key = clientRGKey + '#' + salesCodeId;
                CoverageBulkUploadController.withProductKeys.add(key);
            }

            List<CoverageDataWrapper> lst =new List<CoverageDataWrapper>();
            
            List<string> subValuesNFPE = new List<string>();
            for(List<string> subvalues: coverageTypesMap.values())
            {
                for(string subtype: subvalues){
                    subValuesNFPE.add(subtype.toLowerCase());
                }
            }
           
            List<string> nfpe_subType= new List<string>();
            if(record.Type!=null && record.Type!='')
            nfpe_subType = record.Type.split(',');
			Boolean valid = true;
            for(string nfpe: nfpe_subType)
            {
                if(!subValuesNFPE.contains(nfpe.trim().toLowerCase())){
                    valid = false;
                    break;
                }
            }
            if(maprecordCoverageTypes.get(k)==null && valid)
            {
                lst = getSelectedAddCoverages(subset_clientIDS, salesTeamCoverageIds, productGroup,
                                              productRegion, products, role, false, startDate, 
                                              comments, new List<string>(),null,std_accountListCSV,salesCodeMap,record.action,'CSV',record);
            }
            else
            {
                lst = getSelectedAddCoverages(subset_clientIDS, salesTeamCoverageIds, productGroup,
                                              productRegion, products, role, false, startDate, 
                                              comments, coverageTypes,nfpe_accountListCSV,std_accountListCSV,salesCodeMap,record.action,'CSV',record);
            }
            
            datawrapper.addAll(lst);
            //break;
            k++;
        }
      
        for(CoverageDataWrapper wrapper:datawrapper)
        {
          
            CoverageWrapper wp = new  CoverageWrapper();
            wp.Comments = wrapper.Comments;
            wp.salesCode = wrapper.coverageID;
            wp.salesCodeID = wrapper.salesCodeID;
            if(wrapper.productRegionCombination!=null)
                wp.productRegionCombination = wrapper.productRegionCombination;
            
            if(wrapper.salesRefCodeID!=null && wrapper.salesRefCodeID!='') 
                wp.salesRefCodeID = wrapper.salesRefCodeID;
            if(wrapper.salesRefCode!=null && wrapper.salesRefCode!='') 
                wp.salesRefCode = wrapper.salesRefCode;
            if(wrapper.OpptId!=null && wrapper.OpptId!='') 
                wp.OpptId = wrapper.OpptId;
            if(wrapper.OpptStage!=null && wrapper.OpptStage!='') 
                wp.OpptStage = wrapper.OpptStage;
            if(wrapper.isCreateupdate!=null) 
                wp.isCreateupdate = wrapper.isCreateupdate;
            
            if(wrapper.rmOrgID!=null && wrapper.rmOrgID!='')    
                CoverageBulkUploadUtility.csvRMIds.add(wrapper.rmOrgID);
            
            wp.coverageType= wrapper.coverageType;
            if(wrapper.coverageType!='Standard' && wrapper.rmRestricted==null)
            {
                if(wrapper.subType!=null && wrapper.subType!='')
                    wp.clientRMKey = wrapper.rmOrgID + ' - ' + wrapper.subType;
                else
                    wp.clientRMKey = wrapper.rmOrgID + ' - ' + wrapper.coverageType;
                 wp.clientKey = wrapper.rmOrgID;
            }
            else if(wrapper.coverageType=='Standard' && wrapper.rmRestricted!=null && wrapper.rmRestricted)
            {
                wp.clientRMKey = wrapper.rmOrgID;
                 wp.clientKey = wrapper.rmOrgID;
            }
            else
            {
                wp.clientRGKey = wrapper.rgOrgID;
                wp.clientKey = null;
            }
            wp.subtype = wrapper.subType;
            wp.productGroup = wrapper.productGroup;
            wp.productName = wrapper.product;
            wp.productRegion = wrapper.productRegion;
            wp.role = wrapper.role;
            Date startdate1 = null;
            if(wrapper.startDate!=null)
                startdate1 = wrapper.startDate;
            else
                startdate1 = system.today();
           if(startdate1!=null)
            wp.fromDate = startdate1.month() + '/' + startdate1.day() + '/' + startdate1.year();
            wp.isAttested = wrapper.isAttested;
            wp.Comments = wrapper.Comments;
            wp.action = wrapper.action;
            wp.Type = wrapper.Type;
            wp.includeRestrictedAccounts = wrapper.includeRestrictedAccounts;
            wrapperList.add(wp);
        }
        
        datawrapper.clear();
             return wrapperList;
        }
        catch(Exception e){
            system.debug(e.getStackTraceString());
            system.debug(e);
        }
        //wrapperList = new List<CoverageWrapper>(); 
        system.debug('************** FETCHING RMs for CSV (END)***********************');
       return null;
    }

    public static List<Account> getNFPEAccountList(Set<string> Types,string[] clientIDS){
        List<Account> accountList = new List<Account>();
        string query = '';
        String rmquery_select = 'SELECT Id, Name,parent.RDM_Org_ID__c,ParentId,Domicile_Country__c, RDM_Org_ID__c,restricted_flag__c';
        string rmquery_columns = '';
        String whereTypeClause = ' WHERE (';
        for(string ctype: Types){
            rmquery_columns += ','+ctype+'__c ';
            
            if(whereTypeClause == ' WHERE (')
                whereTypeClause += ctype+'__c=true ';
            else
                whereTypeClause += ' or '+ctype+'__c=true ';
        }
        if(Types.size()>0)
        {
            query = rmquery_select + rmquery_columns + 'FROM Account ';
            query += whereTypeClause+') ';
            query += ' and Active__c = true and parentId in:clientIDS and Recordtype.DeveloperName=\'RM_Account\'';
            accountList =  (List<Account>)database.query(query); 
        }
        return accountList;
    }    
    
    public static Map<string,List<string>> getAccountTypeMap(Set<string> Types, Account rmAccount,Map<string,List<string>> accountTypeMap){
        if(Types.size()>0)
        {
            if(Types.contains(CoverageUtil.FLAG_NFPE) && rmAccount.NFPE__c  && !rmAccount.restricted_flag__c)
            {
                if(accountTypeMap.get(rmAccount.RDM_Org_ID__c) == null)
                    accountTypeMap.put(rmAccount.RDM_Org_ID__c,new List<string>{CoverageUtil.FLAG_NFPE});
                else
                    accountTypeMap.get(rmAccount.RDM_Org_ID__c).add(CoverageUtil.FLAG_NFPE);
            }
            
            //for NFPE 1
            if(Types.contains(CoverageUtil.FLAG_NFPE1) && rmAccount.NFPE1__c && !rmAccount.restricted_flag__c)
            {
                if(accountTypeMap.get(rmAccount.RDM_Org_ID__c) == null)
                    accountTypeMap.put(rmAccount.RDM_Org_ID__c,new List<string>{CoverageUtil.FLAG_NFPE1});
                else
                    accountTypeMap.get(rmAccount.RDM_Org_ID__c).add(CoverageUtil.FLAG_NFPE1);
            }
         }
        return accountTypeMap;
    }    
    
    public static List<Account> getStandardAccountList(string[] clientIDS){
        List<Account> accountList = new List<Account>();
        string query1 = 'SELECT Id, Name,Domicile_Country__c, Parent.RDM_Org_ID__c,Parent.Name, ParentId,RDM_Org_ID__c,restricted_flag__c,'+FLAG_NFPE_APINAME+','+FLAG_NFPE1_APINAME+' from Account ';
        query1 += 'Where Active__c = true and parentId in:clientIDS and Recordtype.DeveloperName=\'RM_Account\'';
        accountList =  (List<Account>)database.query(query1); 
        return accountList;
    }    

    
    @AuraEnabled
    public static List<CoverageDataWrapper> getSelectedAddCoverages(string[] clientIDS,string[] salesTeamCoverageIds, 
                                                                    string pGroup, string pRegion, string[] products,
                                                                    string role, Boolean isAttested, string startdate,
                                                                    string comments,list<string> coverageTypes,
                                                                    list<Account> nfpe_accountListCSV,
                                                                    list<Account> std_accountListCSV,
                                                                    Map<string,Sales_Team_for_Coverage__c> salesCodeMapCSV,
                                                                    string csv_action,
                                                                    string operation,
                                                                    CoverageWrapper csvrecord
                                                                   )
    {
        Map<string,List<string>> accountTypeMap = new Map<string,List<string>>();
        Map<string,List<string>> accountMap = new Map<string,List<string>>();
        Map<string,Account> accountIdbyRDM = new Map<string,Account>();
        Map<string,Account> accountbyId = new Map<string,Account>();
        List<CoverageDataWrapper> wrapperlist = new List<CoverageDataWrapper>();
        string c_action = '';
        system.debug(operation); //ADD
        
        if(csv_action!=null && csv_action!='')
            c_action = csv_action;
        
        if(operation == 'ADD' && coverageTypes.size() > 0) //call only when no call from csv 
            populateCoverageTypesInfo(coverageTypes,operation);
        
      
        /***** INIT */
        ucomments = comments;
        urole = role;
        system.debug(urole); 
        if(operation == 'ADD')
        uproducts.addAll(products);
        else if(operation == 'CSV')
        uproducts = products;    
        ustartdate = startdate;
        uRegion = pRegion;
        uGroup = pGroup;
        uIsAttested = isAttested;
        if(operation == 'ADD')
        usalesTeamCoverageIds.addAll(salesTeamCoverageIds);
        else if(operation == 'CSV')
        usalesTeamCoverageIds = salesTeamCoverageIds;
        
        /**************** ACCOUNT WITH TYPES - AS CHECKBOX SELECTED************************/
        List<Account> nfpeAccountList =  new List<Account>(); 
        if(nfpe_accountListCSV == null && coverageTypes.size() == 0)
        {
            Types = new Set<string>(); 
        }
        else {
           if(Types.size() == 0)
           populateCoverageTypesInfo(coverageTypes,operation);
        }
        if(Types.size()>0)
        {
            if(nfpe_accountListCSV!=null && nfpe_accountListCSV.size()>0){
                nfpeAccountList = nfpe_accountListCSV;
            }
            else
            {
                if(operation == 'ADD')
                nfpeAccountList =  getNFPEAccountList(Types,clientIDS); 
            }
             System.debug(nfpeAccountList);
            for(Account rmAccount: nfpeAccountList){
                if(clientIds.contains(rmAccount.Parent.Id)){
                    boolean found = false;
                    accountTypeMap = getAccountTypeMap(Types, rmAccount,accountTypeMap);
                    
                    if(accountTypeMap.size()>0)
                        found = true;  
                    if(found){
                        accountIdbyRDM.put(rmAccount.RDM_Org_ID__c,rmAccount);
                        accountIdbyRDM.put(rmAccount.Parent.RDM_Org_ID__c,rmAccount);
                        accountbyId.put(rmAccount.Id,rmAccount);
                        accountbyId.put(rmAccount.ParentId,rmAccount);
                    }
                }
                //Add more (else if) new NFPE comes
            }
            
            /*if(accountTypeMap.size() == 0 && Types.size()!=0 && Types.contains('Standard') && operation == 'ADD'){
            }
            else{
                if(accountTypeMap.size() == 0 && Types.size()!=0 && operation == 'ADD'){
                    CoverageDataWrapper wrapper = new CoverageDataWrapper();
                    wrapper.errorResponse = 'Selected Type cannot be applied as no accounts have been flagged as them.';
                    if(c_action!='')
                        wrapper.action = c_action;
                    wrapperlist.add(wrapper);
                    return wrapperlist;
                }
            }*/
           
            /*List<string> indexArray = new List<string>();
            Set<string> clientSet = new Set<string>();
            clientSet.addAll(clientIDS);
            if(Types.size()>0 && accountTypeMap.size()>0 && clientIDS.size()>1){
                for(string client_id: clientIDS){
                    if(!accountbyId.keyset().contains(client_id)){
                       // integer index = clientIDS.indexOf(client_id);
                        indexArray.add(client_id);
                    }
                } 
                
                
                if(indexArray.size()>0)
                clientSet.removeall(indexArray);
                
            } 
            
            
            if(clientSet.size()>0)
            {
                clientIDS.clear();
                clientIDS.addall(clientSet);
                system.debug('clientIDS after: '+clientIDS);
            }*/
            
        }
       
        
        /**************************************************************************************/
        /**************** STANDARD ************************/
        List<Account> standard_accountList =  new List<Account>(); 
        if(std_accountListCSV!=null && std_accountListCSV.size()>0){
            standard_accountList = std_accountListCSV;
        }
        else
        {
            standard_accountList =  getStandardAccountList(clientIDS); 
        }

        for(Account rmAccount: standard_accountList){
            if(clientIds.contains(rmAccount.Parent.Id)){
                if(rmAccount.restricted_flag__c){                    
                    Boolean recordToBeIncluded = true;

                    if('CSV'.equalsIgnoreCase(operation) && 'FALSE'.equalsIgnoreCase(csvrecord.includeRestrictedAccounts)){
                        recordToBeIncluded = false;
                    }

                    if(recordToBeIncluded){
                        if(accountMap.get(rmAccount.Parent.RDM_Org_ID__c) == null)
                        {
                        //updated for JIRA 3646 Fix for deletion of Restricted RM when only one RM in rg
                        //accountMap.put(rmAccount.Parent.RDM_Org_ID__c,new List<string>{rmAccount.RDM_Org_ID__c});
                            if(csvrecord!=null && csvrecord.action.toLowerCase()=='delete')
                                accountMap.put(rmAccount.Parent.RDM_Org_ID__c,new List<string>{'RG',rmAccount.RDM_Org_ID__c});
                            else
                                accountMap.put(rmAccount.Parent.RDM_Org_ID__c,new List<string>{rmAccount.RDM_Org_ID__c});
                        }
                        else
                            accountMap.get(rmAccount.Parent.RDM_Org_ID__c).add(rmAccount.RDM_Org_ID__c);
                    }
                    
                }
                if(!rmAccount.Restricted_Flag__c){
                    if(!rmAccount.NFPE__c && !rmAccount.NFPE1__c || Types.size() == 0){
                        if(accountMap.get(rmAccount.Parent.RDM_Org_ID__c) != null && !accountMap.get(rmAccount.Parent.RDM_Org_ID__c).contains('RG'))
                            accountMap.get(rmAccount.Parent.RDM_Org_ID__c).add('RG');
                        else if(accountMap.get(rmAccount.Parent.RDM_Org_ID__c) == null){
                            accountMap.put(rmAccount.Parent.RDM_Org_ID__c,new List<string>{'RG'});
                        }
                    }
                    
                }
                if(CoverageBulkUploadUtility.csvRMIds!=null)
                    CoverageBulkUploadUtility.csvRMIds.add(rmAccount.RDM_Org_ID__c);
                accountIdbyRDM.put(rmAccount.RDM_Org_ID__c,rmAccount);
                accountIdbyRDM.put(rmAccount.parent.RDM_Org_ID__c,rmAccount);
            }
           
        }
        
        /**************************************************************************************/
        /* SALES CODE MAP - WITHOUT SHARING*/
        Map<string,Sales_Team_for_Coverage__c> salesCodeMap = new  Map<string,Sales_Team_for_Coverage__c>();
        if(operation == 'CSV' && salesCodeMapCSV!=null)
        {
            salesCodeMap = salesCodeMapCSV;
            system.debug('in salescodes csv');
        }
        else
        {
            system.debug('in salescodes add');
            salesTeamCoverage = CoverageUtil.getSalesTeamCoverage(salesTeamCoverageIds);
            for(Sales_Team_for_Coverage__c scode: salesTeamCoverage)
                salesCodeMap.put(scode.Id, scode);
        }
        wrapperlist = getDataWrapper(accountTypeMap, accountMap, accountIdbyRDM, salesCodeMap,coverageTypesMap,csv_action,csvrecord,operation);
        return wrapperlist;
    }
    
    public static List<CoverageDataWrapper>  getDataWrapper(Map<string,List<string>> accountTypeMap,
                                                            Map<string,List<string>> accountMap,
                                                            Map<string,Account> accountIdbyRDM,
                                                            Map<string,Sales_Team_for_Coverage__c> salesCodeMap,
                                                            Map<string,List<string>> coverageTypesMap,
                                                           string action, CoverageWrapper csvrecord,string operation)
    {
        //NFPE Wrapper
        List<CoverageDataWrapper> dataWrapper = new List<CoverageDataWrapper>();
        Set<string> uniqueKeys = new Set<string>();
        Integer counter = 0;
        List<CoverageDataWrapper> secRecordsDataWrapper = new List<CoverageDataWrapper>(); 
        Map<String,List<Sales_Team_for_Coverage__c>> secRecords = new Map<String,List<Sales_Team_for_Coverage__c>>();
        if(uRole == CoverageUtil.primaryAndSecondaryTeam)
        {
            secRecords = CoverageUtil.getSalesTeamSecCoverage(salesTeamCoverage);
        }
        /* NFPE */
        for(string rdmId: accountTypeMap.keyset()){
            for(string nfpetype: accountTypeMap.get(rdmId)){
                for(String cType: coverageTypesMap.get(nfpetype)){
                    Boolean create = false;
                    List<string> csvTypes = new List<string>();
                    string ctypelowercase = '';
                    if(csvrecord!=null && csvrecord.Type!=null && csvrecord.Type!='')
                    {
                        csvrecord.Type = csvrecord.Type.trim().toLowerCase();
                        csvTypes = csvrecord.Type.trim().split(',');
                    }
                  
                    ctypelowercase = cType.toLowerCase();
                   

                    if((csvrecord!=null && csvrecord.Type!=null && csvrecord.Type!='' && operation == 'CSV')){
                           for(string types : csvTypes)
                           {
                               if(types.trim().toLowerCase() == ctypelowercase)
                               {
                                    create = true;
                                    break;
                               }
                           }
                    }

                    if(csvrecord == null)
                    create = true;


                    if(create){
                         for(String codeId: usalesTeamCoverageIds)
                        {
                            String uniqueKey = '';
                            Account rmAccount = accountIdbyRDM.get(rdmId);
                            if(uproducts.size()==0)
                            {
                                uniqueKey = rmAccount.RDM_Org_ID__c+'#'+codeId+'#'+cType;
                                if(!uniqueKeys.contains(uniqueKey))
                                {
                                    uniqueKeys.add(uniqueKey);   
                                }
                                String includeRestrictedAccountsData = (csvrecord != null ? csvrecord.includeRestrictedAccounts : 'True' );
								CoverageDataWrapper wp = getWrapper(false, false,rmAccount, nfpetype,cType, codeId, salesCodeMap.get(codeId).Coverage_ID__c, salesCodeMap.get(codeId).Name, salesCodeMap.get(codeId).Sales_Team__c, salesCodeMap.get(codeId).Company__c, salesCodeMap.get(codeId).Sales_Desk_Region__c, uIsAttested, false,'','','',action,includeRestrictedAccountsData,false);
                                wp.Id = ''+counter;
                                wp.subType = cType;
                                if(accountMap!=null && !accountMap.keyset().contains(rmAccount.Parent.rdm_org_id__c))
                                    wp.numberOfRMs = 1;
                                if(csvrecord!=null && csvrecord.Type!=null)
                                wp.Type = csvrecord.Type;
                                if(csvrecord!=null && csvrecord.productRegionCombination!=null)
                                    wp.productRegionCombination = csvrecord.productRegionCombination;
                                if(csvrecord!=null){
                                    if(csvrecord.salesRefCodeID!=null && csvrecord.salesRefCodeID!='') 
                                        wp.salesRefCodeID = csvrecord.salesRefCodeID;
                                    if(csvrecord.salesRefCode!=null && csvrecord.salesRefCode!='') 
                                        wp.salesRefCode = csvrecord.salesRefCode;
                                    if(csvrecord.OpptId!=null && csvrecord.OpptId!='') 
                                        wp.OpptId = csvrecord.OpptId;
                                    if(csvrecord.OpptStage!=null && csvrecord.OpptStage!='') 
                                        wp.OpptStage = csvrecord.OpptStage;
                                    if(csvrecord.isCreateupdate!=null) 
                                        wp.isCreateupdate = csvrecord.isCreateupdate;
                                }
                                dataWrapper.add(wp);   
                                counter++;
                            }   
                            else
                            {
                                for(String product: uproducts)
                                {
                                    uniqueKey = rmAccount.RDM_Org_ID__c+'#'+codeId+'#'+product+'#'+uRegion+'#'+uGroup+'#'+cType;
                                    if(!uniqueKeys.contains(uniqueKey))
                                    {
                                        uniqueKeys.add(uniqueKey);   
                                    }
                                    String includeRestrictedAccountsData = (csvrecord != null ? csvrecord.includeRestrictedAccounts : 'True' );
									CoverageDataWrapper wp = getWrapper(false, false,rmAccount, nfpetype,cType, codeId, salesCodeMap.get(codeId).Coverage_ID__c, salesCodeMap.get(codeId).Name, salesCodeMap.get(codeId).Sales_Team__c, salesCodeMap.get(codeId).Company__c, salesCodeMap.get(codeId).Sales_Desk_Region__c, uIsAttested, false,product,uRegion,uGroup,action,includeRestrictedAccountsData,false);
                                    wp.Id = ''+counter;
                                    wp.subType = cType;
                                      if(accountMap!=null && !accountMap.keyset().contains(rmAccount.Parent.rdm_org_id__c))
                                    wp.numberOfRMs = 1;
                              		if(csvrecord!=null && csvrecord.productRegionCombination!=null)
                                    wp.productRegionCombination = csvrecord.productRegionCombination;
                                    if(csvrecord!=null && csvrecord.Type!=null)
                                    wp.Type = csvrecord.Type;
                                    if(csvrecord!=null){
                                        if(csvrecord.salesRefCodeID!=null && csvrecord.salesRefCodeID!='') 
                                            wp.salesRefCodeID = csvrecord.salesRefCodeID;
                                        if(csvrecord.salesRefCode!=null && csvrecord.salesRefCode!='') 
                                            wp.salesRefCode = csvrecord.salesRefCode;
                                        if(csvrecord.OpptId!=null && csvrecord.OpptId!='') 
                                            wp.OpptId = csvrecord.OpptId;
                                        if(csvrecord.OpptStage!=null && csvrecord.OpptStage!='') 
                                            wp.OpptStage = csvrecord.OpptStage;
                                        if(csvrecord.isCreateupdate!=null) 
                                            wp.isCreateupdate = csvrecord.isCreateupdate;
                                    }
                                    dataWrapper.add(wp); 
                                    counter++;
                                }
                            }
                            
                        }
                    }
                }
                
                
            }
        }
        
        /* STANDARD*/
        for(string rgorgId: accountMap.keyset()){
            for(string rmorrg: accountMap.get(rgorgId)){
                if(rmorrg == 'RG'){
                    for(String codeId: usalesTeamCoverageIds)
                    {
                        String uniqueKey = '';
                        Account rmAccount1 = accountIdbyRDM.get(rgorgId);
                        if(uproducts.size()==0)
                        {
                            uniqueKey = rmAccount1.Parent.RDM_Org_ID__c+'#'+codeId+'#'+'Standard';
                            if(!uniqueKeys.contains(uniqueKey))
                            {
                                uniqueKeys.add(uniqueKey);   
                            }
                            String includeRestrictedAccountsData = (csvrecord != null ? csvrecord.includeRestrictedAccounts : 'True' );
							CoverageDataWrapper wp1 = getWrapper(true, true, rmAccount1, 'Standard','', codeId, salesCodeMap.get(codeId).Coverage_ID__c, salesCodeMap.get(codeId).Name, salesCodeMap.get(codeId).Sales_Team__c, salesCodeMap.get(codeId).Company__c, salesCodeMap.get(codeId).Sales_Desk_Region__c, uIsAttested, false,'','','',action,includeRestrictedAccountsData,false);
                            if(uRole == CoverageUtil.primaryAndSecondaryTeam)
                            {
                                List<Sales_Team_for_Coverage__c> secRecordsList = secRecords.get(codeId);
                                for(Sales_Team_for_Coverage__c i : secRecordsList){
                                CoverageDataWrapper dw = getWrapper(true, true, rmAccount1, 'Standard','', i.Id, i.Coverage_ID__c, i.Name, i.Sales_Team__c, i.Company__c, i.Sales_Desk_Region__c, uIsAttested, false,'','','',action,includeRestrictedAccountsData,true);
                                secRecordsDataWrapper.add(dw);
                                }
                            }
                            wp1.Id = ''+counter;
                            wp1.subType = '';
                            if(accountMap.get(rgorgId).size() == 1)
                                 wp1.numberOfRMs = 1;
                            if(csvrecord!=null && csvrecord.Type!=null)
                                wp1.Type = csvrecord.Type;
                            if(csvrecord!=null && csvrecord.productRegionCombination!=null)
                                wp1.productRegionCombination = csvrecord.productRegionCombination;
                            if(csvrecord!=null){
                                if(csvrecord.salesRefCodeID!=null && csvrecord.salesRefCodeID!='') 
                                    wp1.salesRefCodeID = csvrecord.salesRefCodeID;
                                if(csvrecord.salesRefCode!=null && csvrecord.salesRefCode!='') 
                                    wp1.salesRefCode = csvrecord.salesRefCode;
                                if(csvrecord.OpptId!=null && csvrecord.OpptId!='') 
                                    wp1.OpptId = csvrecord.OpptId;
                                if(csvrecord.OpptStage!=null && csvrecord.OpptStage!='') 
                                    wp1.OpptStage = csvrecord.OpptStage;
                                if(csvrecord.isCreateupdate!=null) 
                                    wp1.isCreateupdate = csvrecord.isCreateupdate;
                                if('CSV'.equalsIgnoreCase(operation))
                                	wp1.isAttested = csvrecord.isAttested;
                            }
                            dataWrapper.add(wp1); 
                            dataWrapper.addAll(secRecordsDataWrapper);                  
                            counter++;
                        }
                        else
                        {
                            for(String product: uproducts)
                            {
                                uniqueKey = rmAccount1.Parent.RDM_Org_ID__c+'#'+codeId+'#'+product+'#'+uRegion+'#'+uGroup+'#'+'Standard';
                                if(!uniqueKeys.contains(uniqueKey))
                                {
                                    uniqueKeys.add(uniqueKey);   
                                }
                                String includeRestrictedAccountsData = (csvrecord != null ? csvrecord.includeRestrictedAccounts : 'True' );
                                CoverageDataWrapper wp2 = getWrapper(true, true, rmAccount1, 'Standard', '',codeId, salesCodeMap.get(codeId).Coverage_ID__c, salesCodeMap.get(codeId).Name, salesCodeMap.get(codeId).Sales_Team__c, salesCodeMap.get(codeId).Company__c, salesCodeMap.get(codeId).Sales_Desk_Region__c, uIsAttested, false,product,uRegion,uGroup,action,includeRestrictedAccountsData,false);
                                if(uRole == CoverageUtil.primaryAndSecondaryTeam)
                                {
                                    List<Sales_Team_for_Coverage__c> secRecordsList = secRecords.get(codeId);
                                    for(Sales_Team_for_Coverage__c i : secRecordsList){
                                    CoverageDataWrapper dw = getWrapper(true, true, rmAccount1, 'Standard','', i.Id, i.Coverage_ID__c, i.Name, i.Sales_Team__c, i.Company__c, i.Sales_Desk_Region__c, uIsAttested,false,product,uRegion,uGroup,action,includeRestrictedAccountsData,true);
                                    secRecordsDataWrapper.add(dw);
                                }
                                }
                                wp2.Id = ''+counter;
                                wp2.subType = '';
                                if(csvrecord!=null &&  csvrecord.Type!=null)
                                wp2.Type = csvrecord.Type;
                                if(accountMap.get(rgorgId).size() == 1)
                                    wp2.numberOfRMs = 1;
                                if(csvrecord!=null && csvrecord.productRegionCombination!=null)
                                    wp2.productRegionCombination = csvrecord.productRegionCombination;
                                if(csvrecord!=null){
                                    if(csvrecord.salesRefCodeID!=null && csvrecord.salesRefCodeID!='') 
                                        wp2.salesRefCodeID = csvrecord.salesRefCodeID;
                                    if(csvrecord.salesRefCode!=null && csvrecord.salesRefCode!='') 
                                        wp2.salesRefCode = csvrecord.salesRefCode;
                                    if(csvrecord.OpptId!=null && csvrecord.OpptId!='') 
                                        wp2.OpptId = csvrecord.OpptId;
                                    if(csvrecord.OpptStage!=null && csvrecord.OpptStage!='') 
                                        wp2.OpptStage = csvrecord.OpptStage;
                                    if(csvrecord.isCreateupdate!=null) 
                                        wp2.isCreateupdate = csvrecord.isCreateupdate;
                                    if('CSV'.equalsIgnoreCase(operation))
                                	    wp2.isAttested = csvrecord.isAttested;
                                }
                                dataWrapper.add(wp2);  
                                dataWrapper.addAll(secRecordsDataWrapper);                                                 
                                counter++;
                            }
                        }
                        
                    }
                }
                else if(action.toLowerCase()!='delete')
                {
                    for(String codeId: usalesTeamCoverageIds)
                    {
                        String uniqueKey = '';
                        Account rmAccount2 = accountIdbyRDM.get(rmorrg);
                        if(uproducts.size()==0)
                        {
                            uniqueKey = rmAccount2.RDM_Org_ID__c+'#'+codeId+'#'+'Standard';
                            if(!uniqueKeys.contains(uniqueKey))
                            {
                                uniqueKeys.add(uniqueKey);   
                            }
                            String includeRestrictedAccountsData = (csvrecord != null ? csvrecord.includeRestrictedAccounts : 'True' );
							CoverageDataWrapper wp1 = getWrapper(false, true, rmAccount2, 'Standard','', codeId, salesCodeMap.get(codeId).Coverage_ID__c, salesCodeMap.get(codeId).Name, salesCodeMap.get(codeId).Sales_Team__c, salesCodeMap.get(codeId).Company__c, salesCodeMap.get(codeId).Sales_Desk_Region__c, uIsAttested, true,'','','',action,includeRestrictedAccountsData,false);
                            if(uRole == CoverageUtil.primaryAndSecondaryTeam)
                            {
                                List<Sales_Team_for_Coverage__c> secRecordsList = secRecords.get(codeId);
                                for(Sales_Team_for_Coverage__c i : secRecordsList){
                                CoverageDataWrapper dw = getWrapper(false, true, rmAccount2, 'Standard','', i.Id, i.Coverage_ID__c, i.Name, i.Sales_Team__c, i.Company__c, i.Sales_Desk_Region__c, uIsAttested, true,'','','',action,includeRestrictedAccountsData,true);
                                secRecordsDataWrapper.add(dw);
                                }
                            }
                            wp1.Id = ''+counter;
                            wp1.subType = '';
                            if(csvrecord!=null && csvrecord.Type!=null)
                            wp1.Type = csvrecord.Type;
                            if(csvrecord!=null && csvrecord.productRegionCombination!=null)
                                    wp1.productRegionCombination = csvrecord.productRegionCombination;
                            if(csvrecord!=null){
                                if(csvrecord.salesRefCodeID!=null && csvrecord.salesRefCodeID!='') 
                                    wp1.salesRefCodeID = csvrecord.salesRefCodeID;
                                if(csvrecord.salesRefCode!=null && csvrecord.salesRefCode!='') 
                                    wp1.salesRefCode = csvrecord.salesRefCode;
                                if(csvrecord.OpptId!=null && csvrecord.OpptId!='') 
                                    wp1.OpptId = csvrecord.OpptId;
                                if(csvrecord.OpptStage!=null && csvrecord.OpptStage!='') 
                                    wp1.OpptStage = csvrecord.OpptStage;
                                if(csvrecord.isCreateupdate!=null) 
                                    wp1.isCreateupdate = csvrecord.isCreateupdate;
                                if('CSV'.equalsIgnoreCase(operation))
                                	wp1.isAttested = csvrecord.isAttested;
                            }
                            dataWrapper.add(wp1);  
                            dataWrapper.addAll(secRecordsDataWrapper);                  
                            counter++;
                        }
                        else
                        {
                            for(String product: uproducts)
                            {
                                uniqueKey = rmAccount2.RDM_Org_ID__c+'#'+codeId+'#'+product+'#'+uRegion+'#'+uGroup+'#'+'Standard';
                                if(!uniqueKeys.contains(uniqueKey))
                                {
                                    uniqueKeys.add(uniqueKey);   
                                }
                                String includeRestrictedAccountsData = (csvrecord != null ? csvrecord.includeRestrictedAccounts : 'True' );
								CoverageDataWrapper wp2 = getWrapper(false, true, rmAccount2, 'Standard','', codeId, salesCodeMap.get(codeId).Coverage_ID__c, salesCodeMap.get(codeId).Name, salesCodeMap.get(codeId).Sales_Team__c, salesCodeMap.get(codeId).Company__c, salesCodeMap.get(codeId).Sales_Desk_Region__c, uIsAttested,true,product,uRegion,uGroup,action,includeRestrictedAccountsData,false);                             
                                if(uRole == CoverageUtil.primaryAndSecondaryTeam)
                                {
                                    List<Sales_Team_for_Coverage__c> secRecordsList = secRecords.get(codeId);
                                    for(Sales_Team_for_Coverage__c i : secRecordsList){
                                    CoverageDataWrapper dw = getWrapper(false, true, rmAccount2, 'Standard','', i.Id, i.Coverage_ID__c, i.Name, i.Sales_Team__c, i.Company__c, i.Sales_Desk_Region__c, uIsAttested,true,product,uRegion,uGroup,action,includeRestrictedAccountsData,true);
                                    secRecordsDataWrapper.add(dw);
                                }
                                }
                                wp2.Id = ''+counter;
                                wp2.subType = '';
                                if(csvrecord!=null && csvrecord.Type!=null)
                                wp2.Type = csvrecord.Type;
                                if(csvrecord!=null && csvrecord.productRegionCombination!=null)
                                    wp2.productRegionCombination = csvrecord.productRegionCombination;
                                if(csvrecord!=null){
                                    if(csvrecord.salesRefCodeID!=null && csvrecord.salesRefCodeID!='') 
                                        wp2.salesRefCodeID = csvrecord.salesRefCodeID;
                                    if(csvrecord.salesRefCode!=null && csvrecord.salesRefCode!='') 
                                        wp2.salesRefCode = csvrecord.salesRefCode;
                                    if(csvrecord.OpptId!=null && csvrecord.OpptId!='') 
                                        wp2.OpptId = csvrecord.OpptId;
                                    if(csvrecord.OpptStage!=null && csvrecord.OpptStage!='') 
                                        wp2.OpptStage = csvrecord.OpptStage;
                                    if(csvrecord.isCreateupdate!=null) 
                                        wp2.isCreateupdate = csvrecord.isCreateupdate;
                                    if('CSV'.equalsIgnoreCase(operation))
                                	    wp2.isAttested = csvrecord.isAttested;
                                }
                                dataWrapper.add(wp2);  
                                dataWrapper.addAll(secRecordsDataWrapper);                  
                                counter++;
                            }
                        }
                        
                    }
                }
            }
        }
        
        return dataWrapper;
    }
    
    public static CoverageDataWrapper getWrapper
        (
            Boolean isRG, 
            Boolean isStandard,
            Account accountData, 
            string nfpetype,
            string cType,
            string codeId,
            string coverageID,
            string salesPerson,
            string salesteam,
            string company,
            string salesDeskRegion,
            Boolean isAttested,
            Boolean isRestricted,
            string product,
            string productRegion,
            string productGroup,
            string action,
            string includeRestrictedAccounts,
            Boolean isSecondary
        )
    {
        CoverageDataWrapper wrapper = new CoverageDataWrapper();
        wrapper.salesCodeID = codeId;
        wrapper.coverageID = coverageID;
        wrapper.salesPerson = salesPerson;
        if(action!=null && action != '')
        wrapper.action = action;
        wrapper.team = salesteam;
        if(isRG)
        {
            wrapper.clientRGId = accountData.ParentId;
            wrapper.accountName = accountData.Parent.Name ;
            wrapper.rgOrgID = accountData.Parent.RDM_Org_ID__c; 
            wrapper.coverageType = 'Standard';
            wrapper.rmRestricted = false;
        } 
        else
        {
            wrapper.clientRMId = accountData.Id;
            wrapper.clientRM =accountData.Name;
             wrapper.clientRGId = accountData.ParentId;
            wrapper.rmOrgID = accountData.RDM_Org_ID__c;
            if(isRestricted && nfpetype == 'Standard' || nfpetype == null)
            {
                wrapper.accountName='('+accountData.Domicile_Country__c+'-Restricted Jurisdiction) - '+accountData.Name;
                wrapper.coverageType = 'Standard';
                wrapper.rmRestricted = true;
            }
            else
            {
                if(cType!='')
                    wrapper.accountName='('+cType+') - '+accountData.Name;
                else
                    wrapper.accountName='('+nfpetype+') - '+accountData.Name;
                wrapper.coverageType = nfpetype;
                wrapper.clientRGId = accountData.Parent.Id;
                wrapper.rgOrgID = accountData.Parent.RDM_Org_ID__c; 
            }
        }  
        
        if(product!='' && product!=null){
            wrapper.product = product;
            wrapper.productGroup = productGroup;
            wrapper.productRegion = productRegion;
            
        }  
        wrapper.userComments = uComments;
        if(uRole == CoverageUtil.primaryAndSecondaryTeam) {
            if(isSecondary == true)
                wrapper.role = 'Secondary';
            else
                wrapper.role = 'Primary';
        }  
        else{
            wrapper.role = uRole;
        }
        wrapper.isAttested = (CoverageUtil.company).indexOf(company)>-1 && (CoverageUtil.mandatoryPrimaryAttestRegion).indexOf(salesDeskRegion)>-1 && (CoverageUtil.userRole).indexOf(wrapper.role)>-1 ? uIsAttested : false;
        if(ustartdate!=null && ustartdate!='') 
        wrapper.startDate = date.valueOf(ustartdate);
        wrapper.isChecked = true;
        wrapper.includeRestrictedAccounts = includeRestrictedAccounts;  
        return wrapper;
    }
    
    public static List<CoverageDataWrapper> getCoverage(string[] clientIDS,string include,string[] clientType, 
                                                        string[] pGroups, string[] pRegions, string[] products,
                                                        string[] role, string[] salesPersonIDS, string isAndOR, string[] salesTeam,string level,Decimal softLimit,
                                                        Boolean isInit, Boolean allCoverages,boolean isSearch,string customWhereClause,
                                                        Set<string> salesDivisions,Set<string> salesRegions,Set<string> salesDesks,Set<string> salesTeams,Set<string> fieldAPIs,
                                                        Set<string> teamKeys,Set<string> deskKeys,string currentUserRegion,
                                                        list<string> nfpeTypes
                                                       )
    {
        string query = '';
        string groupClause = '';
        Schema.DescribeSObjectResult coverageObject = Schema.SObjectType.Coverage_Team_Member__c;
        Map<String,Schema.RecordTypeInfo> rtMapByDeveloperName = coverageObject.getRecordTypeInfosByDeveloperName();
        Id activeCoverageId = rtMapByDeveloperName.get('Active_Coverage').getRecordTypeId();
        Id InactiveCoverageId = rtMapByDeveloperName.get('Inactive_Coverage').getRecordTypeId();
        userRegion = currentUserRegion;
        string isCommentAccessible = CoverageToolController.isCommentAccessible;
        if(isCommentAccessible == 'true' || isCommentAccessible == 'true:rw')
            isCommentAccessible = 'true';
        Boolean isEquityUser = CoverageToolController.isEquityUser;
        
        /********************* DEFINING CSV COLUMNS ******************************/
        if(level == 'Client')
        {
            if(isCommentAccessible == 'true'){
                if(!allCoverages)
                {
                    if(include == 'Active')
                    {
                        if(!isEquityUser)
                        {
                            //csvString = 'ACCOUNT,TEAM,SALESPERSON,YTD,BUDGET,MTD,WTD,ROLE,START DATE,STATUS,COMMENT'+':';
                            //removed type for SALES - 3698
							//csvKeys = new List<string>{''+rgOrgID,''+clientRG,''+TypeCSV,''+team,''+salesPerson,''+coverageID,''+ytdRevenue,''+ytdBudget,''+mtdRevenue,''+wtdRevenue,''+teamrole,''+''+startDate,''+status,''+Comments};
                            csvKeys = new List<string>{''+rgOrgID,''+clientRG,''+team,''+salesPerson,''+coverageID,''+ytdRevenue,''+ytdBudget,''+mtdRevenue,''+wtdRevenue,''+teamrole,''+''+startDate,''+status,''+Comments};
                            
                        }
                        else
                        {
                          //  csvString = 'ACCOUNT,TEAM,SALESPERSON,ROLE,START DATE,STATUS,COMMENT'+':';
                          //removed type for SALES - 3698
                        //csvKeys = new List<string>{''+rgOrgID,''+clientRG,''+TypeCSV,''+team,''+salesPerson,''+coverageID,''+teamrole,''+startDate,''+status,''+Comments};
                            csvKeys = new List<string>{''+rgOrgID,''+clientRG,''+team,''+salesPerson,''+coverageID,''+teamrole,''+startDate,''+status,''+Comments};
                        }
                    }
                    else
                    {
                        if(!isEquityUser)
                        {
                        //    csvString = 'ACCOUNT,TEAM,SALESPERSON,YTD,BUDGET,MTD,WTD,ROLE,START DATE,END DATE,COMMENT'+':';
                        //removed type for SALES - 3698
                        //csvKeys = new List<string>{''+rgOrgID,''+clientRG,''+TypeCSV,''+team,''+salesPerson,''+coverageID,''+ytdRevenue,''+ytdBudget,''+mtdRevenue,''+wtdRevenue,''+teamrole,''+startDate,''+endDate,''+Comments};
                            csvKeys = new List<string>{''+rgOrgID,''+clientRG,''+team,''+salesPerson,''+coverageID,''+ytdRevenue,''+ytdBudget,''+mtdRevenue,''+wtdRevenue,''+teamrole,''+startDate,''+endDate,''+Comments};
                        }
                        else
                        {
                      //      csvString = 'ACCOUNT,TEAM,SALESPERSON,ROLE,START DATE,END DATE,COMMENT'+':';
                        //removed type for SALES - 3698
                            //csvKeys = new List<string>{''+rgOrgID,''+clientRG,''+TypeCSV,''+team,''+salesPerson,''+coverageID,''+teamrole,''+startDate,''+endDate,''+Comments};
                           csvKeys = new List<string>{''+rgOrgID,''+clientRG,''+team,''+salesPerson,''+coverageID,''+teamrole,''+startDate,''+endDate,''+Comments};
                        }
                    }
                    
                    
                }
                else
                {
                    //csvString = 'REGION,DESK,TEAM,SALESPERSON,ROLE,ACCOUNT,COMMENT'+':';
                    //removed type for SALES - 3698      
                   // csvKeys = new List<string>{''+region,''+desk,''+team,''+salesPerson,''+coverageID,''+teamrole,''+clientRG,''+rgOrgID,''+TypeCSV,''+Comments};
                    csvKeys = new List<string>{''+region,''+desk,''+team,''+salesPerson,''+coverageID,''+teamrole,''+clientRG,''+rgOrgID,''+Comments};
                }
            }
            else
            {
                if(!allCoverages)
                {
                    if(include == 'Active')
                    {
                        if(!isEquityUser)
                        {
                            //csvString = 'ACCOUNT,TEAM,SALESPERSON,YTD,BUDGET,MTD,WTD,ROLE,START DATE,STATUS'+':';
                            //removed type for SALES - 3698 
                            //csvKeys = new List<string>{''+rgOrgID,''+clientRG,''+TypeCSV,''+team,''+salesPerson,''+coverageID,''+ytdRevenue,''+ytdBudget,''+mtdRevenue,''+wtdRevenue,''+teamrole,''+startDate,''+status}; 
                            csvKeys = new List<string>{''+rgOrgID,''+clientRG,''+team,''+salesPerson,''+coverageID,''+ytdRevenue,''+ytdBudget,''+mtdRevenue,''+wtdRevenue,''+teamrole,''+startDate,''+status};
                        }
                        else
                        {
                            //csvString = 'ACCOUNT,TEAM,SALESPERSON,ROLE,START DATE,STATUS'+':';
                            //removed type for SALES - 3698  
                            //csvKeys = new List<string>{''+rgOrgID,''+clientRG,''+TypeCSV,''+team,''+salesPerson,''+coverageID,''+teamrole,''+startDate,''+status};
                            csvKeys = new List<string>{''+rgOrgID,''+clientRG,''+team,''+salesPerson,''+coverageID,''+teamrole,''+startDate,''+status};
                        }
                    }
                    else
                    {
                        if(!isEquityUser)
                        {
                            //csvString = 'ACCOUNT,TEAM,SALESPERSON,YTD,BUDGET,MTD,WTD,ROLE,START DATE,END DATE'+':';
                            //removed type for SALES - 3698  
                            //csvKeys = new List<string>{''+rgOrgID,''+clientRG,''+TypeCSV,''+team,''+salesPerson,''+coverageID,''+ytdRevenue,''+ytdBudget,''+mtdRevenue,''+wtdRevenue,''+teamrole,''+startDate,''+endDate};
                            csvKeys = new List<string>{''+rgOrgID,''+clientRG,''+team,''+salesPerson,''+coverageID,''+ytdRevenue,''+ytdBudget,''+mtdRevenue,''+wtdRevenue,''+teamrole,''+startDate,''+endDate};
                        }
                        else
                        {
                            //csvString = 'ACCOUNT,TEAM,SALESPERSON,ROLE,START DATE,END DATE'+':';
                            //removed type for SALES - 3698  
                            //csvKeys = new List<string>{''+rgOrgID,''+clientRG,''+TypeCSV,''+team,''+salesPerson,''+coverageID,''+teamrole,''+startDate,''+endDate};
                            csvKeys = new List<string>{''+rgOrgID,''+clientRG,''+team,''+salesPerson,''+coverageID,''+teamrole,''+startDate,''+endDate};
                        }
                    }
                }
                else
                {
                    //csvString = 'REGION,DESK,TEAM,SALESPERSON,ROLE,ACCOUNT'+':';
                    //removed type for SALES - 3698  
                    //csvKeys = new List<string>{''+region,''+desk,''+team,''+salesPerson,''+coverageID,''+teamrole,''+clientRG,''+rgOrgID,''+TypeCSV};
                    csvKeys = new List<string>{''+region,''+desk,''+team,''+salesPerson,''+coverageID,''+teamrole,''+clientRG,''+rgOrgID};
                }
            }
        }
        else
        {
            if(isCommentAccessible == 'true'){
                if(!allCoverages)
                {
                    if(include == 'Active')
                    {
                        //csvString = 'ACCOUNT,TEAM,SALESPERSON,PRODUCT,PRODUCT REGION,ROLE,START DATE,STATUS,COMMENT'+':';
                        //removed type for SALES - 3698
                        //csvKeys = new List<string>{''+rgOrgID,''+clientRG,''+TypeCSV,''+team,''+salesPerson,''+coverageID,''+product,''+productRegion,''+teamrole,''+startDate,''+status,''+Comments};
                        csvKeys = new List<string>{''+rgOrgID,''+clientRG,''+team,''+salesPerson,''+coverageID,''+product,''+productRegion,''+teamrole,''+startDate,''+status,''+Comments};
                            
                    }
                    else
                    {
                        //csvString = 'ACCOUNT,TEAM,SALESPERSON,PRODUCT,PRODUCT REGION,ROLE,START DATE,END DATE,COMMENT'+':';
                        //removed type for SALES - 3698  
                        //csvKeys = new List<string>{''+rgOrgID,''+clientRG,''+TypeCSV,''+team,''+salesPerson,''+coverageID,''+product,''+productRegion,''+teamrole,''+startDate,''+endDate,''+Comments};
                        csvKeys = new List<string>{''+rgOrgID,''+clientRG,''+team,''+salesPerson,''+coverageID,''+product,''+productRegion,''+teamrole,''+startDate,''+endDate,''+Comments};
                    }
                }
                else
                {
            //        csvString = 'REGION,DESK,TEAM,SALESPERSON,PRODUCT,PRODUCT REGION,ROLE,ACCOUNT,COMMENT'+':';
                    //removed type for SALES - 3698  
                    //csvKeys = new List<string>{''+region,''+desk,''+team,''+salesPerson,''+coverageID,''+product,''+productRegion,''+teamrole,''+clientRG,''+rgOrgID,''+TypeCSV,''+Comments};
                    csvKeys = new List<string>{''+region,''+desk,''+team,''+salesPerson,''+coverageID,''+product,''+productRegion,''+teamrole,''+clientRG,''+rgOrgID,''+Comments};
                }
            }
            else
            {
                if(!allCoverages)
                {
                    if(include == 'Active')
                    {
                        //csvString = 'ACCOUNT,TEAM,SALESPERSON,PRODUCT,PRODUCT REGION,ROLE,START DATE,STATUS'+':';
                        //removed type for SALES - 3698  
                        //csvKeys = new List<string>{''+rgOrgID,''+clientRG,''+TypeCSV,''+team,''+salesPerson,''+coverageID,''+product,''+productRegion,''+teamrole,''+startDate,''+status};
                        csvKeys = new List<string>{''+rgOrgID,''+clientRG,''+team,''+salesPerson,''+coverageID,''+product,''+productRegion,''+teamrole,''+startDate,''+status};
                        
                    }
                    else
                    {
                        
                        //csvString = 'ACCOUNT,TEAM,SALESPERSON,PRODUCT,PRODUCT REGION,ROLE,START DATE,END DATE'+':';
                        //removed type for SALES - 3698  
                        //csvKeys = new List<string>{''+rgOrgID,''+clientRG,''+TypeCSV,''+team,''+salesPerson,''+coverageID,''+product,''+productRegion,''+teamrole,''+startDate,''+endDate};
                        csvKeys = new List<string>{''+rgOrgID,''+clientRG,''+team,''+salesPerson,''+coverageID,''+product,''+productRegion,''+teamrole,''+startDate,''+endDate};
                    }
                    
                }
                else
                {
                    //csvString = 'REGION,DESK,TEAM,SALESPERSON,PRODUCT,PRODUCT REGION,ROLE,ACCOUNT'+':';
                    //removed type for SALES - 3698  
                    // csvKeys = new List<string>{''+region,''+desk,''+team,''+salesPerson,''+coverageID,''+product,''+productRegion,''+teamrole,''+clientRG,''+rgOrgID,''+TypeCSV};
                    csvKeys = new List<string>{''+region,''+desk,''+team,''+salesPerson,''+coverageID,''+product,''+productRegion,''+teamrole,''+clientRG,''+rgOrgID};

                }
            }
            
            
        }
        
        
        system.debug(teamrole);
        
        Map<string,AggregateResult> mapRGCoverageStatus = new Map<string,AggregateResult>();
        Map<string,string> mapofYTDByRG = new Map<string,string>();
        List<AggregateResult> cvglist = new  List<AggregateResult>();
        
        /********************* QUERY BUILDER ******************************/
        List<CoverageDataWrapper> wrapperlist = new List<CoverageDataWrapper>();
        if(level == 'Client')
        {
            query = 'SELECT MIN(uniqueid__c) uniqueKey,NFPE_Primary_Relationship_Coverage__c nfpetype1,NFPE_Primary_Product_Coverage__c nfpetype2,NFPE_Overseas_Authorised_Coverage__c nfpetype3, NFPE1__c nfpe1,MIN(Account__r.Parent.RDM_Org_ID__c) RGORGID,MAX(Comment__c) userComment,Account__r.Parent.Id RGID,MIN(Account__r.Parent.Name) RGNAME,MIN(Account__c) RMID,MIN(Account__r.Name) RMNAME,'+
                'MIN(Start_Date__c) STARTDATE,MAX(End_Date__c) ENDDATE,MIN(Sales_Team_for_Coverage__r.Company__c) DESKCODE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Region__c) DESKREGION,MIN(Account__r.RDM_Org_ID__c) RMORGID,Sales_Team_for_Coverage__r.Id CVGID,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Division__c) DIV,MIN(Sales_Team_for_Coverage__r.Coverage_ID__c) CODEID,MIN(Sales_Team_for_Coverage__r.Desk_Name__c) DESK,'+
                'MIN(Sales_Team_for_Coverage__r.Sales_Team__c) TEAM, MIN(Sales_Team_for_Coverage__r.Name) SPerson,MIN(Team_Member__c) SPID,MIN(Team_Role__c) TEAMROLE,'+
                'MIN(LastModifiedBy.Name) MODIFIED, MIN(LastModifiedById) MODIFIEDID FROM Coverage_Team_Member__c';
            groupClause = ' group by Account__r.Parent.Id,Sales_Team_for_Coverage__r.Id,NFPE_Primary_Relationship_Coverage__c,NFPE_Primary_Product_Coverage__c,NFPE_Overseas_Authorised_Coverage__c,NFPE1__c';
        }
        else
        { 
            query = 'SELECT MIN(uniqueid__c) uniqueKey,NFPE_Primary_Relationship_Coverage__c nfpetype1,NFPE_Primary_Product_Coverage__c nfpetype2,NFPE_Overseas_Authorised_Coverage__c nfpetype3, NFPE1__c nfpe1,MIN(id) coverageID, MIN(Account__r.Parent.RDM_Org_ID__c) RGORGID,MAX(Comment__c) userComment, Account__r.Parent.Id RGID,'+
                'MIN(Account__r.Parent.Name) RGNAME, MIN(Account__c) RMID,MIN(Sales_Team_for_Coverage__r.Company__c) DESKCODE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Region__c) DESKREGION,MIN(Account__r.Name) RMNAME, Product_Group__c PGRP, Product_Region__c PREG,'+
                'Product__c PRD,MIN(Team_Role__c) TEAMROLE, MIN(Start_Date__c) STARTDATE, MAX(End_Date__c) ENDDATE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Division__c) DIV,MIN(Sales_Team_for_Coverage__r.Coverage_ID__c) CODEID,Sales_Team_for_Coverage__r.Id CVGID,'+
                'MIN(Account__r.RDM_Org_ID__c) RMORGID, MIN(Sales_Team_for_Coverage__r.Desk_Name__c) DESK,'+
                'MIN(Sales_Team_for_Coverage__r.Sales_Team__c) TEAM, MIN(Sales_Team_for_Coverage__r.Name) SPerson, MIN(Team_Member__c)'+
                'SPID, MIN(LastModifiedBy.Name) MODIFIED, MIN(LastModifiedById) MODIFIEDID FROM Coverage_Team_Member__c';
            groupClause = ' group by Account__r.Parent.Id,Sales_Team_for_Coverage__r.Id, Product_Group__c, Product_Region__c, Product__c,NFPE_Primary_Relationship_Coverage__c,NFPE_Primary_Product_Coverage__c,NFPE_Overseas_Authorised_Coverage__c,NFPE1__c';        
        }
        system.debug(customWhereClause);
        if(customWhereClause.toLowerCase().contains('where'))
            customWhereClause += ' and ';
        else
            customWhereClause += ' where ';
        
        if(level == 'Client')// and (Sales_Team_for_Coverage__r.Active__c = false or Sales_Team_for_Coverage__r.Owner_Active__c = false)
        {
            if(include == 'Active')
                customWhereClause += ' RecordTypeId = \'' + activeCoverageId + '\'';
            else if(include == 'InActive')
                customWhereClause += ' RecordTypeId = \'' + InactiveCoverageId + '\'';
            
            query += customWhereClause;
            query += groupClause;
        }
        else
        {
            if(include == 'Active')
                customWhereClause += ' (Product__c!=null and RecordTypeId = \'' + activeCoverageId + '\')';
            else if(include == 'InActive')
                customWhereClause += ' (Product__c!=null and RecordTypeId = \'' + InactiveCoverageId + '\')';
            query += customWhereClause;
            query += groupClause;
        }
        /********************* DATA FETCH ******************************/
        if(allCoverages) // CHANCES OF HITTING ROWS FETCH LIMIT > 10000
            cvglist = CoverageDataWithOutSharingController.getCoverageTeamMember(clientIDS,include,clientType, 
                                                                                 pGroups,pRegions,products,
                                                                                 role,salesPersonIDS,  isAndOR, salesTeam, level, softLimit,
                                                                                 isInit,allCoverages,query,salesDivisions,salesRegions,salesDesks,salesTeams,fieldAPIs,teamKeys,deskKeys);
        else
            cvglist = CoverageDataWithSharingController.getCoverageTeamMember(clientIDS,include,clientType, 
                                                                              pGroups,pRegions,products,
                                                                              role,salesPersonIDS,  isAndOR, salesTeam, level, softLimit,
                                                                              isInit,allCoverages,query,salesDivisions,salesRegions,salesDesks,salesTeams,fieldAPIs,teamKeys,deskKeys);
        if(include == 'Active' && !allCoverages)
        {
            
            /********************* READ RG PENDING REQUEST ******************************/
            mapRGCoverageStatus = getRGCoverageRequestStatusDynamicQuery(clientIDS,include,clientType, 
                                                                         pGroups,pRegions,products,
                                                                         role,salesPersonIDS,isAndOR, 
                                                                         salesTeam,level,softLimit,
                                                                         isInit,allCoverages,isSearch,
                                                                         salesDivisions,salesRegions,
                                                                         salesDesks,salesTeams,fieldAPIs,
                                                                         'Pending Approval',teamKeys,deskKeys,nfpeTypes);
            system.debug('RG Coverage Pending Request: '+mapRGCoverageStatus.size());
            /********************* READ RM PENDING REQUEST ******************************/
            mapRGCoverageStatus = getRMCoverageRequestStatusDynamicQuery(clientIDS,include,clientType, 
                                                                         pGroups,pRegions,products,
                                                                         role,salesPersonIDS,isAndOR, 
                                                                         salesTeam,level,softLimit,
                                                                         isInit,allCoverages,isSearch,
                                                                         salesDivisions,salesRegions,
                                                                         salesDesks,salesTeams,fieldAPIs,
                                                                         'Pending Approval',mapRGCoverageStatus,teamKeys,deskKeys,nfpeTypes);
            system.debug('RM Coverage Pending Request: '+mapRGCoverageStatus);
            
        }
        if(level == 'Client')
        {
            /********************* PREPARE MAP to update REVENUE DATA ******************************/
            set<string> RGIds = new Set<string>();
            set<string> coverageIds = new Set<string>();
            
            for(AggregateResult clientCVG : cvglist){
                if(clientCVG.get('RGID')!=null && clientCVG.get('RGID')!='')
                {
                    RGIds.add(string.valueOf(clientCVG.get('RGID')));
                }
                if(clientCVG.get('CODEID')!=null && clientCVG.get('CODEID')!='')
                {
                    coverageIds.add(string.valueOf(clientCVG.get('CODEID')));
                }
            }
            
            AggregateResult clientCVGRequest;
            for(string rgkey: mapRGCoverageStatus.keySet()) 
            {
                clientCVGRequest =  mapRGCoverageStatus.get(rgkey);
                if(clientCVGRequest.get('RGID')!=null && clientCVGRequest.get('RGID')!='')
                {
                    RGIds.add(string.valueOf(clientCVGRequest.get('RGID')));
                }
                if(clientCVGRequest.get('CODEID')!=null && clientCVGRequest.get('CODEID')!='')
                {
                    coverageIds.add(string.valueOf(clientCVGRequest.get('CODEID')));
                }
            }
            if(!isEquityUser)
                mapofYTDByRG = getYTDList(coverageIds,RGIds);
            
        }
        
        
        /********************* PREPARE WRAPPER DATA  - COVERAGE TEAM MEMBER ******************************/
        Integer i = 1;
        YTDSummary = 0;
        YTDBudgetSummary = 0;
        WTDSummary = 0;
        MTDSummary = 0;
        Set<string> coverageMap = new Set<string>();
        
        
        CoverageDataWrapper wrapper;
        Map<string,CoverageDataWrapper> nfpeCTMMapByUniqueId = new  Map<string,CoverageDataWrapper>();
        Map<string,List<string>> nfpeKey = new Map<string,List<string>>();
        Map<string,string> rgPrimaryKey  = new Map<string,string>();
        for(AggregateResult clientCVG : cvglist)
        {
            Boolean nfpe = false;
            Boolean nfpe_subtype1 = false;
            Boolean nfpe_subtype2 = false;
			Boolean nfpe_subtype3 = false;
            Boolean nfpe1 = false;
            string uniqueKey = '';
            
            if(CoverageUtil.FLAG_NFPE_SUBTYPE1!=null && CoverageUtil.FLAG_NFPE_SUBTYPE1!=''){
                if(clientCVG.get('nfpetype1')!=null){
                    if(Boolean.valueOf(clientCVG.get('nfpetype1'))){
                        nfpe_subtype1 = true;
                    }
                }
            }
            
            if(CoverageUtil.FLAG_NFPE_SUBTYPE2!=null && CoverageUtil.FLAG_NFPE_SUBTYPE2!=''){
                if(clientCVG.get('nfpetype2')!=null){
                    if(Boolean.valueOf(clientCVG.get('nfpetype2'))){
                        nfpe_subtype2 = true;
                    }
                }
            }
			
			if(CoverageUtil.FLAG_NFPE_SUBTYPE3!=null && CoverageUtil.FLAG_NFPE_SUBTYPE3!=''){
                if(clientCVG.get('nfpetype3')!=null){
                    if(Boolean.valueOf(clientCVG.get('nfpetype3'))){
                        nfpe_subtype3 = true;
                    }
                }
            }
            
            if(CoverageUtil.FLAG_NFPE1!=null && CoverageUtil.FLAG_NFPE1!=''){
                if(clientCVG.get('nfpe1')!=null){
                    if(Boolean.valueOf(clientCVG.get('nfpe1'))){
                        nfpe1 = true;
                    }
                }
            }
            
         	if(clientCVG.get('uniqueKey')!=null)
            {
                uniqueKey = string.valueOf(clientCVG.get('uniqueKey'));
                if(clientCVG.get('RMORGID')!=null && clientCVG.get('RGORGID')!=null)
                uniqueKey = uniqueKey.trim().replace(string.valueOf(clientCVG.get('RMORGID')), string.valueOf(clientCVG.get('RGORGID')));
            }
            string[] key = uniqueKey.split('#');
            string modifiedkey = '';
            wrapper = wrapperMapping(clientCVG,i,level,coverageMap,mapRGCoverageStatus,allCoverages,mapofYTDByRG,false,isCommentAccessible,include,isEquityUser,false);
            if(include == 'Active')
            {
                modifiedkey = uniqueKey;
            }
            else
            {
                if(level == 'Product'){
                    modifiedkey = key[0]+key[1] +key[2]+key[3] + key[4];
                }
                else
                {
                    modifiedkey = uniqueKey;
                }
            }
            
             string flag = '';
            if(level == 'Client')
            {
                flag = key[0]+key[1]+key[2];
            }
            else
            {
                if(include == 'Active')
                {
                    flag = uniqueKey;
                }
                else
                {
                    if(level == 'Product'){
                        flag = key[0]+key[1] +key[2]+key[3] + key[4];
                    }
                    else
                    {
                        flag = uniqueKey;
                    }
                }
            }
            
            
            if(nfpe_subtype1 || nfpe1 || nfpe_subtype2 || nfpe_subtype3 )
            {
                //modified for JIRA 3660
                if(nfpeKey.get(modifiedkey)==null && nfpe_subtype1)
                    //nfpeKey.put(modifiedkey,new List<string>{CoverageUtil.FLAG_NFPE_SUBTYPE1});
                    nfpeKey.put(modifiedkey,new List<string>{CoverageUtil.FLAG_NFPE_SUBTYPE1_1});
                else if(nfpeKey.get(modifiedkey)!=null && nfpe_subtype1)
                {
                    //if(!nfpeKey.get(modifiedkey).contains(CoverageUtil.FLAG_NFPE_SUBTYPE1))
                        //nfpeKey.get(modifiedkey).add(CoverageUtil.FLAG_NFPE_SUBTYPE1);
                    if(!nfpeKey.get(modifiedkey).contains(CoverageUtil.FLAG_NFPE_SUBTYPE1_1))
                        nfpeKey.get(modifiedkey).add(CoverageUtil.FLAG_NFPE_SUBTYPE1_1);
                }
                
                
                if(nfpeKey.get(modifiedkey)==null && nfpe_subtype2)
                    nfpeKey.put(modifiedkey,new List<string>{CoverageUtil.FLAG_NFPE_SUBTYPE2});
                else  if(nfpeKey.get(modifiedkey)!=null && nfpe_subtype2){
                    if(!nfpeKey.get(modifiedkey).contains(CoverageUtil.FLAG_NFPE_SUBTYPE2))
                        nfpeKey.get(modifiedkey).add(CoverageUtil.FLAG_NFPE_SUBTYPE2);
                }
                //modified for JIRA 3660
				if(nfpeKey.get(modifiedkey)==null && nfpe_subtype3)
                    //nfpeKey.put(modifiedkey,new List<string>{CoverageUtil.FLAG_NFPE_SUBTYPE3});
                    nfpeKey.put(modifiedkey,new List<string>{CoverageUtil.FLAG_NFPE_SUBTYPE3_1});
                else  if(nfpeKey.get(modifiedkey)!=null && nfpe_subtype3){
                    //if(!nfpeKey.get(modifiedkey).contains(CoverageUtil.FLAG_NFPE_SUBTYPE3))
                      //  nfpeKey.get(modifiedkey).add(CoverageUtil.FLAG_NFPE_SUBTYPE3);
                    if(!nfpeKey.get(modifiedkey).contains(CoverageUtil.FLAG_NFPE_SUBTYPE3_1))
                        nfpeKey.get(modifiedkey).add(CoverageUtil.FLAG_NFPE_SUBTYPE3_1);
                }
				
                if(nfpeKey.get(modifiedkey)==null && nfpe1){
                    nfpeKey.put(modifiedkey,new List<string>{CoverageUtil.FLAG_NFPE1});
                }
                else if(nfpeKey.get(modifiedkey)!=null && nfpe1){
                    if(!nfpeKey.get(modifiedkey).contains(CoverageUtil.FLAG_NFPE1))
                    nfpeKey.get(modifiedkey).add(CoverageUtil.FLAG_NFPE1);
                }
                
            }
            else
            {
                if(wrapper.role == 'Primary')
                    rgPrimaryKey.put(flag,'Primary');
            }
           
            nfpeCTMMapByUniqueId.put(flag,wrapper);
            i++;
        }
       
        
        for(string key: nfpeKey.Keyset()){
            string s = '';
            for(string type1: nfpeKey.get(key)){
                if(s==''){
                    s = type1;
                }
                else
                {
                    s += ', '+type1;
                }
            }
            string[] key1 = key.split('#');
            string flag1	 = '';
            if(level == 'Client')
                flag1 = key1[0]+key1[1]+key1[2];
            else
                flag1 = key;
            
            if(nfpeCTMMapByUniqueId.get(flag1)!=null)
            {
                if(nfpeCTMMapByUniqueId.get(flag1).Type!=null && nfpeCTMMapByUniqueId.get(flag1).Type!='' && nfpeCTMMapByUniqueId.get(flag1).Type.indexOf(s.toUpperCase())==-1)
                {
                    string[] data = s.split(',');
                     for(string sd: data){
                        if(!nfpeCTMMapByUniqueId.get(flag1).Type.contains(sd.toUpperCase().trim()))
                        {
                            nfpeCTMMapByUniqueId.get(flag1).Type = nfpeCTMMapByUniqueId.get(flag1).Type+','+sd.toUpperCase();        
                        }
                    }
                }
                else
                {
                    nfpeCTMMapByUniqueId.get(flag1).Type = s.toUpperCase();
                }
                if(rgPrimaryKey.get(flag1)!=null)
                nfpeCTMMapByUniqueId.get(flag1).role = 'Primary'; 
            
            }
            
           
            
            
        }
        wrapperlist.addAll(nfpeCTMMapByUniqueId.values());
        
        
        /********************* PREPARE WRAPPER DATA  - COVERAGE REQUEST (RG & RM) ******************************/
        Integer j = 1;
        AggregateResult clientCVG;
        for(string rgkey: mapRGCoverageStatus.keySet()) 
        {
            //nfpeType
            Boolean nfpe = false;
            Boolean nfpe1 = false;
            string uniqueKey = '';
           
            
            if(!coverageMap.contains(rgkey))
            {
                system.debug('inside request');
                clientCVG =  mapRGCoverageStatus.get(rgkey);
                wrapper = wrapperMapping(clientCVG,j,level,coverageMap,mapRGCoverageStatus,allCoverages,mapofYTDByRG,true,isCommentAccessible,include,isEquityUser,true);
                wrapperlist.add(wrapper);
                j++;
            }
        }
        
        if(isEquityUser)
            doNotShowRevenueColumns = true;
        else
            doNotShowRevenueColumns = false;
        
        return wrapperlist;
    }
    
    public static CoverageDataWrapper wrapperMapping(AggregateResult clientCVG,Integer i,string level,
                                                     Set<string> coverageMap
                                                     ,Map<string,AggregateResult> mapRGCoverageStatus,
                                                     Boolean allCoverages,Map<string,string> mapofYTDByRG,Boolean isCVGRequest,string isCommentAccessible,string include,Boolean isEquityUser,
                                                    Boolean isOnlyRequest)
    {
        CoverageDataWrapper wrapper = new CoverageDataWrapper();
        string YTD = '';
        string budget = '';
        string WTD = '';
        string MTD = '';
        boolean foundPendingRequest = false; 
        wrapper.rowNumber = i;
        wrapper.newRole = '';
        wrapper.newStartDate = system.today();
        wrapper.updateAction = '';
        wrapper.Comments = '';
        wrapper.userComments = '';
        string startDate = '';
        string endDate = ''; 
        string deskCode = '';
        String productContainingRegion = '';
        
        wrapper.rowDisabledClass = '';
        
        if(clientCVG.get('DESKCODE')!=null)
        {
            boolean flag = false;
            deskCode = string.valueOf(clientCVG.get('DESKCODE'));
            
            if(level == 'Product' && clientCVG!=null && clientCVG.get('PRD')!=null && clientCVG.get('PRD')!='' && clientCVG.get('PREG') != null && clientCVG.get('PREG') != ''){
            	productContainingRegion = String.valueOf(clientCVG.get('PRD')).toLowerCase() + ' - ' +  String.valueOf(clientCVG.get('PREG')).toLowerCase();
            }
            
            if(level == 'Product' && clientCVG!=null && coverageutil.productsWithRegionsToIncludeForInstinet.contains(productContainingRegion)){
            		flag = true;
            }
                
            if(flag)    
            {
                wrapper.salesCodeCompany = 'N'; // Enabling if product access is open for instinet from coverage util
                wrapper.rowDisabledClass = 'NONE';
            }
            else
            {
                wrapper.salesCodeCompany = deskCode;
                if(CoverageUtil.salescode_company_to_exclude.contains(deskCode)  &&  !allCoverages)
                    wrapper.rowDisabledClass = 'disableRow';
            }
            
        }
        
        if(clientCVG.get('STARTDATE')!=null)
        {
            startDate = date.valueOf(clientCVG.get('STARTDATE')).format();                                              
        }
        if(clientCVG.get('ENDDATE')!=null)
        {
            endDate = date.valueOf(clientCVG.get('ENDDATE')).format();                                              
        }
        if(clientCVG.get('userComment')!=null && clientCVG.get('userComment')!='')
        {
            wrapper.userComments = string.valueOf(clientCVG.get('userComment'));
            wrapper.Comments = string.valueOf(clientCVG.get('userComment'));
        }
        
        if(clientCVG.get('ENDDATE')!=null && clientCVG.get('ENDDATE')!='')
            wrapper.endDate = Date.valueOf(clientCVG.get('ENDDATE'));
        else
            wrapper.endDate = System.today();
        
        if(clientCVG.get('DESK')!=null && clientCVG.get('DESK')!='')
            wrapper.desk = string.valueOf(clientCVG.get('DESK'));
        else
            wrapper.desk = '';
        
       
        
        if(clientCVG.get('DESKREGION')!=null && clientCVG.get('DESKREGION')!='')
            wrapper.region = string.valueOf(clientCVG.get('DESKREGION'));
        else
            wrapper.region = '';
        
        if(clientCVG.get('TEAM')!=null && clientCVG.get('TEAM')!='')
            wrapper.team = string.valueOf(clientCVG.get('TEAM'));
        else
            wrapper.team = '';
        
        if(clientCVG.get('RGORGID')!=null && clientCVG.get('RGORGID')!='')
            wrapper.rgOrgID = string.valueOf(clientCVG.get('RGORGID'));
        else
            wrapper.rgOrgID = '';
        
        if(!isCVGRequest)
        {
            if(clientCVG.get('RMORGID')!=null && clientCVG.get('RMORGID')!='')
                wrapper.rmOrgID = string.valueOf(clientCVG.get('RMORGID'));
            else
                wrapper.rmOrgID = '';
        }
         
        
        
        if(clientCVG.get('CVGID')!=null)
            wrapper.salesCodeID = string.valueOf(clientCVG.get('CVGID'));
        else
            wrapper.salesCodeID = '';
        
        if(clientCVG.get('CODEID')!=null && clientCVG.get('CODEID')!='')
            wrapper.coverageID = string.valueOf(clientCVG.get('CODEID'));
        else
            wrapper.coverageID = '';
        
        if(clientCVG.get('SPerson')!=null && clientCVG.get('SPerson')!='')
            wrapper.salesPerson = string.valueOf(clientCVG.get('SPerson'));
        else
            wrapper.salesPerson = '';
        
        if(clientCVG.get('SPID')!=null && clientCVG.get('SPID')!='')
            wrapper.salesPersonId = string.valueOf(clientCVG.get('SPID'));
        else
            wrapper.salesPersonId = '';
        
        if(clientCVG.get('RGNAME')!=null && clientCVG.get('RGNAME')!='')
        {
            wrapper.clientRG = string.valueOf(clientCVG.get('RGNAME'));
            wrapper.accountName=string.valueOf(clientCVG.get('RGNAME'));
            
        }
        else
            wrapper.clientRG = '';
        if(!isCVGRequest)
        {
            if(clientCVG.get('RMID')!=null && clientCVG.get('RMID')!='')
            {
                wrapper.clientRMId = string.valueOf(clientCVG.get('RMID'));           
            }
            else
            {
                wrapper.clientRMId = '';
            }
            
            if(clientCVG.get('RMNAME')!=null && clientCVG.get('RMNAME')!='')
            {
                wrapper.clientRM = string.valueOf(clientCVG.get('RMNAME'));
                wrapper.accountName = string.valueOf(clientCVG.get('RMNAME'));
            }
            else
                wrapper.clientRM = '';     
        }
        if(clientCVG.get('TEAMROLE')!=null && clientCVG.get('TEAMROLE')!='')
            wrapper.role = string.valueOf(clientCVG.get('TEAMROLE'));
        else
            wrapper.role = '';
        
        if(clientCVG.get('STARTDATE')!=null && clientCVG.get('STARTDATE')!='')
            wrapper.startDate = Date.valueOf(clientCVG.get('STARTDATE'));
        
        if(clientCVG.get('MODIFIED')!=null && clientCVG.get('MODIFIED')!='')
            wrapper.lastModifiedBy = string.valueOf(clientCVG.get('MODIFIED'));
        else
            wrapper.lastModifiedBy = ''; 
        
        if(clientCVG.get('MODIFIEDID')!=null && clientCVG.get('MODIFIEDID')!='')
            wrapper.lastModifiedId = string.valueOf(clientCVG.get('MODIFIEDID'));
        else
            wrapper.lastModifiedId = '';
        
        if(level == 'Client')
        {
            wrapper.level = 'Client';
            if(clientCVG.get('RGID')!=null && clientCVG.get('CVGID')!=null && clientCVG.get('RGID')!='' && clientCVG.get('CVGID')!='')
                wrapper.Id = string.valueOf(clientCVG.get('RGID')).trim()+':' + string.valueOf(clientCVG.get('CVGID')).trim();
            
            if(!isCVGRequest)
            {
                if(clientCVG.get('RGID')!=null && clientCVG.get('RGID')!='')
                {
                    wrapper.clientRGId = string.valueOf(clientCVG.get('RGID'));
                    if(clientCVG.get('CVGID')!=null && clientCVG.get('CVGID')!='' && 
                       !allCoverages)
                    {
                        string datakey = string.valueOf(clientCVG.get('RGID')) + string.valueOf(clientCVG.get('CVGID'));
                        coverageMap.add(datakey);
                        if(mapRGCoverageStatus.containsKey(datakey))
                        {
                            wrapper.status = 'Pending'; 
                            foundPendingRequest = true;
                            wrapper.rowDisabledClass = 'disableRow';
                            string s = '';
                            
                            if(mapRGRequestNFPE.get(datakey)!=null && isOnlyRequest){
                                for(string type1: mapRGRequestNFPE.get(datakey)){
                                    string[] ctypes = type1.split(':');
                                    string ctype = '';
                                    if(ctypes.size() == 2)
                                        ctype = ctypes[1];
                                    else
                                        ctype = ctypes[0];   
                                    if(s==''){
                                        s = ctype;
                                    }
                                    else
                                    {
                                        s += ', '+ctype;
                                    }
                                }
                                if(s!='')
                                    wrapper.Type = s.toUpperCase();
                            }
                            
                        }  
                    }
                }
                else
                {
                    wrapper.clientRGId = '';
                }
                
            }
            else
            {
                if(clientCVG.get('RGID')!=null && clientCVG.get('RGID')!='')
                {
                    wrapper.clientRGId = string.valueOf(clientCVG.get('RGID'));
                    wrapper.status = 'Pending'; 
                    wrapper.rowDisabledClass = 'disableRow';
                    String s = '';
                    string datakey = string.valueOf(clientCVG.get('RGID')) + string.valueOf(clientCVG.get('CVGID'));
                    if(mapRGRequestNFPE.get(datakey)!=null){
                        for(string type1: mapRGRequestNFPE.get(datakey)){
                            string[] ctypes = type1.split(':');
                            string ctype = '';
                            if(ctypes.size() == 2)
                                ctype = ctypes[1];
                            else
                                ctype = ctypes[0];   
                            if(s==''){
                                s = ctype;
                            }
                            else
                            {
                                s += ', '+ctype;
                            }
                        }
                        if(s!='')
                            wrapper.Type = s.toUpperCase();
                    }
                    foundPendingRequest = true;
                }
                else
                {
                    wrapper.clientRGId = '';
                }
            }
            
            if(!isEquityUser)
            {
                if(clientCVG.get('RGID')!=null && clientCVG.get('RGID')!='' && clientCVG.get('CODEID')!=null && clientCVG.get('CODEID')!='')
                {
                    if(mapofYTDByRG.get(string.valueOf(clientCVG.get('RGID'))+string.valueOf(clientCVG.get('CODEID')))!=null)
                    {
                        string[] revenue = mapofYTDByRG.get(string.valueOf(clientCVG.get('RGID'))+string.valueOf(clientCVG.get('CODEID'))).split(':');
                        if(revenue.size() == 4)
                        {
                            wrapper.ytdRevenue = Decimal.valueOf(Double.valueOf(revenue[0]));
                            YTD = revenue[0];
                            YTDSummary +=  Decimal.valueOf(Double.valueOf(revenue[0]));
                            wrapper.ytdBudget = Decimal.valueOf(Double.valueOf(revenue[1]));
                            Budget = revenue[1];
                            YTDBudgetSummary +=  Decimal.valueOf(Double.valueOf(revenue[1]));
                            
                            wrapper.wtdRevenue = Decimal.valueOf(Double.valueOf(revenue[2]));
                            WTDSummary +=  Decimal.valueOf(Double.valueOf(revenue[2]));
                            WTD = revenue[2];
                            
                            wrapper.mtdRevenue = Decimal.valueOf(Double.valueOf(revenue[3]));
                            MTDSummary +=  Decimal.valueOf(Double.valueOf(revenue[3]));
                            MTD = revenue[3];
                        }
                    }
                    else
                    {
                        wrapper.ytdRevenue = 0;
                        wrapper.ytdBudget = 0;
                        wrapper.wtdRevenue = 0;
                        wrapper.mtdRevenue = 0;
                    }
                }
                else
                {
                    wrapper.ytdRevenue = 0;
                    wrapper.ytdBudget = 0;
                    wrapper.wtdRevenue = 0;
                    wrapper.mtdRevenue = 0;
                }
                //   containsFI = true;
            }
            else
            {
                wrapper.ytdRevenue = null;
                wrapper.ytdBudget = null;
                wrapper.wtdRevenue = null;
                wrapper.mtdRevenue = null;
            }
           
            if(!foundPendingRequest)
            {
                wrapper.disabled = true; 
                wrapper.buttonVariant = 'success';
                wrapper.buttonIcon = 'action:approval';
                wrapper.status = 'Approved';
            }else
            {
                wrapper.disabled = false;
                wrapper.buttonVariant = 'Outline Brand';
                wrapper.buttonIcon = 'action:following';
            }
        }
        else
        {
            wrapper.level = 'Product';
            if(clientCVG.get('RGID')!=null && clientCVG.get('CVGID')!=null && clientCVG.get('RGID')!='' && clientCVG.get('CVGID')!=''
               && clientCVG.get('PRD')!=null && clientCVG.get('PRD')!='' &&clientCVG.get('PREG')!=null && clientCVG.get('PREG')!=''
               && clientCVG.get('PGRP')!=null && clientCVG.get('PGRP')!='')
                wrapper.Id = string.valueOf(clientCVG.get('RGID')).trim()+':' + string.valueOf(clientCVG.get('CVGID')).trim() + ':' + string.valueOf(clientCVG.get('PGRP')).trim()+':'+string.valueOf(clientCVG.get('PREG')).trim()+':'+string.valueOf(clientCVG.get('PRD')).trim();
            
            if(!isCVGRequest)
            {
                if(clientCVG.get('RGID')!=null && clientCVG.get('RGID')!='')
                {
                    wrapper.clientRGId = string.valueOf(clientCVG.get('RGID'));
                    if(clientCVG.get('CVGID')!=null && clientCVG.get('CVGID')!='' && 
                       clientCVG.get('PGRP')!=null && clientCVG.get('PGRP')!='' && 
                       clientCVG.get('PREG')!=null && clientCVG.get('PREG')!='' && 
                       clientCVG.get('PRD')!=null && clientCVG.get('PRD')!='' && 
                       !allCoverages)
                    {
                        string datakey = string.valueOf(clientCVG.get('RGID')) + string.valueOf(clientCVG.get('CVGID')) +
                            string.valueOf(clientCVG.get('PGRP'))+
                            string.valueOf(clientCVG.get('PREG'))+
                            string.valueOf(clientCVG.get('PRD'));
                        coverageMap.add(datakey);
                        if(mapRGCoverageStatus.containsKey(datakey) )
                        {
                            wrapper.status = 'Pending'; 
                            wrapper.rowDisabledClass = 'disableRow';
                            string s = '';
                            if(mapRGRequestNFPE.get(datakey)!=null && isOnlyRequest){
                                for(string type1: mapRGRequestNFPE.get(datakey)){
                                    string[] ctypes = type1.split(':');
                                    string ctype = '';
                                    if(ctypes.size() == 2)
                                        ctype = ctypes[1];
                                    else
                                        ctype = ctypes[0];   
                                    if(s==''){
                                        s = ctype;
                                    }
                                    else
                                    {
                                        s += ', '+ctype;
                                    }
                                }
                                if(s!='')
                                    wrapper.Type = s.toUpperCase();
                            }
                            foundPendingRequest = true;
                        }  
                    }
                }
                else
                {
                    wrapper.clientRGId = '';
                }
                
            }
            else
            {
                if(clientCVG.get('RGID')!=null && clientCVG.get('RGID')!='')
                {
                    wrapper.clientRGId = string.valueOf(clientCVG.get('RGID'));
                    wrapper.status = 'Pending'; 
                    wrapper.rowDisabledClass = 'disableRow';
                    string s = '';
                    string datakey = string.valueOf(clientCVG.get('RGID')) + string.valueOf(clientCVG.get('CVGID')) +
                        string.valueOf(clientCVG.get('PGRP'))+
                        string.valueOf(clientCVG.get('PREG'))+
                        string.valueOf(clientCVG.get('PRD'));
                    if(mapRGRequestNFPE.get(datakey)!=null){
                        for(string type1: mapRGRequestNFPE.get(datakey)){
                            string[] ctypes = type1.split(':');
                            string ctype = '';
                            if(ctypes.size() == 2)
                                ctype = ctypes[1];
                            else
                                ctype = ctypes[0];   
                            if(s==''){
                                s = ctype;
                            }
                            else
                            {
                                s += ', '+ctype;
                            }
                        }
                        if(s!='')
                            wrapper.Type = s.toUpperCase();
                    }
                    foundPendingRequest = true;
                }
                else
                {
                    wrapper.clientRGId = '';
                }
            }
            
            if(clientCVG.get('PGRP')!=null && clientCVG.get('PGRP')!='')
                wrapper.productGroup =string.valueOf(clientCVG.get('PGRP'));
            else
                wrapper.productGroup = '';
            
            if(clientCVG.get('PREG')!=null && clientCVG.get('PREG')!='')
                wrapper.productRegion = string.valueOf(clientCVG.get('PREG'));
            else
                wrapper.productRegion = '';    
            
            if(clientCVG.get('PRD')!=null && clientCVG.get('PRD')!='')
                wrapper.product = string.valueOf(clientCVG.get('PRD'));
            else
                wrapper.product = '';
            
            if(!foundPendingRequest)
            {
                wrapper.disabled = true; 
                wrapper.buttonVariant = 'success';
                wrapper.buttonIcon = 'action:approval';
                wrapper.status = 'Approved';
            }else
            {
                wrapper.disabled = false;
                wrapper.buttonVariant = 'Outline Brand';
                wrapper.buttonIcon = 'action:following';
                wrapper.rowDisabledClass = 'disableRow';
            }
            
        }
        wrapper.isChecked = false;
        return wrapper;
    }
    
    public static Map<string,string> getYTDList(set<string> coverageIds, set<string> RGIds)
    {
        Map<string,string> mapofYTDByRG = new Map<string,string>();
        mapofYTDByRG =  CoverageDataWithoutSharingController.getYTDList(coverageIds, RGIds, userRegion);
        return mapofYTDByRG;
    }
    
    
    public static Map<string,AggregateResult> getRGCoverageRequestStatusDynamicQuery(string[] clientIDS,string include,string[] clientType, 
                                                                                     string[] pGroups, string[] pRegions, string[] products,
                                                                                     string[] role, string[] salesPersonIDS, string isAndOR, 
                                                                                     string[] salesTeam,string level,Decimal softLimit,
                                                                                     Boolean isInit, Boolean allCoverages,boolean isSearch,
                                                                                     Set<string> salesDivisions,Set<string> salesRegions,
                                                                                     Set<string> salesDesks,Set<string> salesTeams,Set<string> fieldAPIs,
                                                                                     string status,Set<string> teamKeys,Set<string> deskKeys,list<string> nfpeTypes)
    {
        if(Test.isRunningTest())
            status = 'Approved';
        Map<string,AggregateResult> mapCoverageStatus = new Map<string,AggregateResult>();
        string query = '';
        string groupClause = '';
        
        if(level == 'Product')
        {
            query = 'SELECT MIN(type__c) nfpeType,MIN(sub_Type__c) nfpeSubType,MIN(id) coverageID, MIN(RG_Account__r.RDM_Org_ID__c) RGORGID,MAX(Comment__c) userComment, RG_Account__r.Id RGID,MIN(Sales_Team_for_Coverage__r.Name) SPERSON,MIN(Requested_for_User__c) SPID,'+
                'MIN(RG_Account__r.Name) RGNAME,MIN(Sales_Team_for_Coverage__r.Company__c) DESKCODE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Region__c) DESKREGION,Product_Group__c PGRP, Product_Region__c PREG,'+
                'Product2__c PRD,MIN(Role__c) TEAMROLE, MIN(Start_Date__c) STARTDATE, MIN(End_Date__c) ENDDATE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Division__c) DIV,MIN(Sales_Team_for_Coverage__r.Coverage_ID__c) CODEID,Sales_Team_for_Coverage__r.Id CVGID,'+
                'MIN(Sales_Team_for_Coverage__r.Desk_Name__c) DESK,'+
                'MIN(Sales_Team_for_Coverage__r.Sales_Team__c) TEAM,'+
                'MIN(LastModifiedBy.Name) MODIFIED, MIN(LastModifiedById) MODIFIEDID FROM RG_Coverage_Request__c';
            groupClause = ' group by RG_Account__r.Id,Sales_Team_for_Coverage__r.Id, Product_Group__c, Product_Region__c,Product2__c';        
            
        }
        else
        {
            query = 'SELECT MIN(type__c) nfpeType,MIN(sub_Type__c) nfpeSubType,MIN(id) coverageID, MIN(RG_Account__r.RDM_Org_ID__c) RGORGID, RG_Account__r.Id RGID,MAX(Comment__c) userComment,MIN(Sales_Team_for_Coverage__r.Name) SPERSON,MIN(Requested_for_User__c) SPID,'+
                'MIN(RG_Account__r.Name) RGNAME,MIN(Sales_Team_for_Coverage__r.Company__c) DESKCODE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Region__c) DESKREGION,'+
                'MIN(Start_Date__c) STARTDATE,MIN(Role__c) TEAMROLE, MIN(End_Date__c) ENDDATE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Division__c) DIV,MIN(Sales_Team_for_Coverage__r.Coverage_ID__c) CODEID,Sales_Team_for_Coverage__r.Id CVGID,'+
                'MIN(Sales_Team_for_Coverage__r.Desk_Name__c) DESK,'+
                'MIN(Sales_Team_for_Coverage__r.Sales_Team__c) TEAM,'+
                'MIN(LastModifiedBy.Name) MODIFIED, MIN(LastModifiedById) MODIFIEDID FROM RG_Coverage_Request__c';
            groupClause = ' group by RG_Account__r.Id,Sales_Team_for_Coverage__r.Id';        
            
        }
        
        string customWhereClause = '';
        Boolean containsFilter = false;
        Set<string> ctypes = new Set<string>();
        if(nfpeTypes.size() > 0)
        {
            String s = '';
            for(string nType : nfpeTypes)
            {
                s = nType.replace('_',' ');
                ctypes.add(s);
            }
            if(customWhereClause == '')
                customWhereClause += ' where (sub_Type__c in:ctypes or Type__c in:ctypes) ';
            else
                customWhereClause += ' and (sub_Type__c in:ctypes or Type__c in:ctypes) ';
            
            containsFilter = true;
        }
        
        if(clientIDS.size() > 0)
        {
            if(customWhereClause == '')
                customWhereClause += ' where RG_Account__r.Id in:clientIDS';
            else
                customWhereClause += ' and RG_Account__r.Id in:clientIDS';
            
            containsFilter = true;
        }
        if(clientType.size() > 0)
        {
            if(customWhereClause == '')
                customWhereClause += ' where RG_Account__r.Sales_Client_Type__c in:clientType';
            else
                customWhereClause += ' and RG_Account__r.Sales_Client_Type__c in:clientType';
            
            containsFilter = true;
        }
        
        if(level == 'Product')
        {
            if(pGroups.size() > 0)
            {
                if(customWhereClause == '')
                    customWhereClause += ' where Product_Group__c in:pGroups';
                else
                    customWhereClause += ' and Product_Group__c in:pGroups';
                containsFilter = true;
            }
            
            if(pRegions.size() > 0)
            {
                if(customWhereClause == '')
                    customWhereClause += ' where Product_Region__c in:pRegions';
                else
                    customWhereClause += ' and Product_Region__c in:pRegions';
                containsFilter = true;
            }
            
            if(products.size() > 0)
            {
                if(customWhereClause == '')
                    customWhereClause += ' where Product2__c in:products';
                else
                    customWhereClause += ' and Product2__c in:products';
                containsFilter = true;
            }
            
            
            
            
        }
        
        if(role.size() > 0)
        {
            if(customWhereClause == '')
                customWhereClause += ' where Role__c in:role';
            else
                customWhereClause += ' and Role__c in:role';
            
            containsFilter = true;
        }
        
        if(salesPersonIDS.size() > 0 || salesTeam.size()>0)
        {
     
            
            if(salesPersonIDS.size() == 0 && salesTeam.size()>0)
            {
                if(customWhereClause.contains('where'))
                    customWhereClause += ' and ';
                else
                    customWhereClause += ' where ';
                
                if(salesDesks.size() > 0 && salesTeams.size() > 0)
                    customWhereClause += ' (Sales_Team_for_Coverage__r.Desk_SearchKey__c in:deskKeys or Sales_Team_for_Coverage__r.Team_SearchKey__c in:teamKeys) ';
                else if(salesDesks.size() > 0 && salesTeams.size() == 0)
                    customWhereClause += '  Sales_Team_for_Coverage__r.Desk_SearchKey__c in:deskKeys ';
                else if(salesDesks.size() == 0 && salesTeams.size() > 0)
                    customWhereClause += '  Sales_Team_for_Coverage__r.Team_SearchKey__c in:teamKeys ';
                containsFilter = true;
            }
            else if(salesPersonIDS.size() > 0 && salesTeam.size() == 0)
            {   
                if(customWhereClause.contains('where')){
                    customWhereClause +=' and Sales_Team_for_Coverage__c in:salesPersonIDS';
                    containsFilter = true;
                }
                else
                {
                    customWhereClause +=' where Sales_Team_for_Coverage__c in:salesPersonIDS';
                    containsFilter = true;
                }
            }
            else
            {
                if(customWhereClause.contains('where'))
                    customWhereClause += ' and ';
                else
                    customWhereClause += ' where ';
                
                if(salesDesks.size() > 0 && salesTeams.size() > 0)
                    customWhereClause += ' (Sales_Team_for_Coverage__c in:salesPersonIDS '+isAndOR+' (Sales_Team_for_Coverage__r.Desk_SearchKey__c in:deskKeys or Sales_Team_for_Coverage__r.Team_SearchKey__c in:teamKeys)) ';
                else if(salesDesks.size() > 0 && salesTeams.size() == 0)
                    customWhereClause += ' (Sales_Team_for_Coverage__c in:salesPersonIDS '+isAndOR+' Sales_Team_for_Coverage__r.Desk_SearchKey__c in:deskKeys) ';
                else if(salesDesks.size() == 0 && salesTeams.size() > 0)
                    customWhereClause += ' (Sales_Team_for_Coverage__c in:salesPersonIDS '+isAndOR+' Sales_Team_for_Coverage__r.Team_SearchKey__c in:teamKeys) ';
                containsFilter = true;
                
            }
            
        }
        if(customWhereClause.contains('where'))
            customWhereClause += ' and ';
        else
            customWhereClause += ' where ';
        
        if(include == 'Active')
        {
            
            if(level == 'Product')
                customWhereClause += ' (Product2__c!=null and status__c = \'' + status + '\' and (Sales_Team_for_Coverage__r.Active__c = true or Sales_Team_for_Coverage__r.Owner_Active__c = true))';
            else
                customWhereClause += ' (status__c = \'' + status + '\' and (Sales_Team_for_Coverage__r.Active__c = true or Sales_Team_for_Coverage__r.Owner_Active__c = true))';
        }
        else if(include == 'InActive') //and (Sales_Team_for_Coverage__r.Active__c = false or Sales_Team_for_Coverage__r.Owner_Active__c = false)
        {
            if(level == 'Product')
                customWhereClause += ' (Product2__c!=null and status__c = \'' + status + '\' and (Sales_Team_for_Coverage__r.Active__c = false or Sales_Team_for_Coverage__r.Owner_Active__c = false))';
            else
                customWhereClause += ' (status__c = \'' + status + '\' and (Sales_Team_for_Coverage__r.Active__c = false or Sales_Team_for_Coverage__r.Owner_Active__c = false))';
        }
        query += customWhereClause;
        query += groupClause;
        List<AggregateResult> rglist = Database.query(query);
        for(AggregateResult result: rglist)
        {
            string[] productandRegion = new string[]{};
                string productRegionCombinedValue  = '';
            string product  = '';
            string productRegion  = '';
            string productGroup  = '';
            
            if(level == 'Product')
            {
                if(result.get('PGRP')!=null && result.get('PGRP')!='')
                    productGroup = string.valueOf(result.get('PGRP'));
                
                if(result.get('PRD')!=null && result.get('PRD')!='')
                {
                    product = string.valueOf(result.get('PRD'));
                }             
                if(result.get('PREG')!=null && result.get('PREG')!='')
                {
                    productRegion = string.valueOf(result.get('PREG'));
                } 
            }
            
            
            
            if(result.get('RGID')!=null && result.get('RGID')!='' && result.get('CVGID')!=null && result.get('CVGID')!='')
            {
                if(level == 'Product' && productGroup!='' && productRegion!='' && product!='')
                    mapCoverageStatus.put(string.valueOf(result.get('RGID'))+string.valueOf(result.get('CVGID'))+productGroup+productRegion+product,result);  
                else
                    mapCoverageStatus.put(string.valueOf(result.get('RGID'))+string.valueOf(result.get('CVGID')),result);      
            } 
        } 
        return mapCoverageStatus;      
    } 
    
    public static Map<string,AggregateResult> getRMCoverageRequestStatusDynamicQuery(string[] clientIDS,string include,string[] clientType, 
                                                                                     string[] pGroups, string[] pRegions, string[] products,
                                                                                     string[] role, string[] salesPersonIDS, string isAndOR, 
                                                                                     string[] salesTeam,string level,Decimal softLimit,
                                                                                     Boolean isInit, Boolean allCoverages,boolean isSearch,
                                                                                     Set<string> salesDivisions,Set<string> salesRegions,
                                                                                     Set<string> salesDesks,Set<string> salesTeams,Set<string> fieldAPIs,
                                                                                     string status,Map<string,AggregateResult> rgMap,Set<string> teamKeys,Set<string> deskKeys,list<string> nfpeTypes)
    {
        if(Test.isRunningTest())
            status = 'Approved';
        //Map<string,AggregateResult> mapCoverageStatus = new Map<string,AggregateResult>();
        string query = '';
        string groupClause = '';
        
        if(level == 'Product')
        {
            query = 'SELECT type__c nfpeType,sub_Type__c nfpeSubType,MIN(id) coverageID, MIN(Account__r.Parent.RDM_Org_ID__c) RGORGID,MAX(Comment__c) userComment, Account__r.Parent.Id RGID,MIN(Sales_Team_for_Coverage__r.Name) SPERSON,MIN(Requested_for_User__c) SPID,'+
                'MIN(Account__r.Parent.Name) RGNAME,MIN(Sales_Team_for_Coverage__r.Company__c) DESKCODE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Region__c) DESKREGION,Product_Group__c PGRP, Product_Region__c PREG,'+
                'Product2__c PRD,MIN(Role__c) TEAMROLE, MIN(Start_Date__c) STARTDATE, MIN(End_Date__c) ENDDATE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Division__c) DIV,MIN(Sales_Team_for_Coverage__r.Coverage_ID__c) CODEID,Sales_Team_for_Coverage__r.Id CVGID,'+
                'MIN(Sales_Team_for_Coverage__r.Desk_Name__c) DESK,'+
                'MIN(Sales_Team_for_Coverage__r.Sales_Team__c) TEAM,'+
                'MIN(LastModifiedBy.Name) MODIFIED, MIN(LastModifiedById) MODIFIEDID FROM Coverage_Access_Request__c';
            groupClause = ' group by Account__r.Parent.Id,type__c,sub_Type__c,Sales_Team_for_Coverage__r.Id, Product_Group__c, Product_Region__c,Product2__c';        
        }
        else
        {
            query = 'SELECT type__c nfpeType,sub_Type__c nfpeSubType,MIN(id) coverageID, MIN(Account__r.Parent.RDM_Org_ID__c) RGORGID,MAX(Comment__c) userComment, Account__r.Parent.Id RGID,MIN(Sales_Team_for_Coverage__r.Name) SPERSON,MIN(Requested_for_User__c) SPID,'+
                'MIN(Account__r.Parent.Name) RGNAME,MIN(Sales_Team_for_Coverage__r.Company__c) DESKCODE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Region__c) DESKREGION,'+
                'MIN(Start_Date__c) STARTDATE,MIN(Role__c) TEAMROLE, MIN(End_Date__c) ENDDATE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Division__c) DIV,MIN(Sales_Team_for_Coverage__r.Coverage_ID__c) CODEID,Sales_Team_for_Coverage__r.Id CVGID,'+
                'MIN(Sales_Team_for_Coverage__r.Desk_Name__c) DESK,'+
                'MIN(Sales_Team_for_Coverage__r.Sales_Team__c) TEAM,'+
                'MIN(LastModifiedBy.Name) MODIFIED, MIN(LastModifiedById) MODIFIEDID FROM Coverage_Access_Request__c';
            groupClause = ' group by Account__r.Parent.Id,type__c,sub_Type__c,Sales_Team_for_Coverage__r.Id';        
        }
        
        string customWhereClause = '';
            Boolean containsFilter = false;
    	
        Set<string> ctypes = new Set<string>();
        if(nfpeTypes.size() > 0)
        {
            String s = '';
            for(string nType : nfpeTypes)
            {
                s = nType.replace('_',' ');
                ctypes.add(s);
            }
            if(customWhereClause == '')
                customWhereClause += ' where (sub_Type__c in:ctypes or Type__c in:ctypes) ';
            else
                customWhereClause += ' and (sub_Type__c in:ctypes or Type__c in:ctypes) ';
            
            containsFilter = true;
        }
        
        if(clientIDS.size() > 0)
        {
            if(customWhereClause == '')
                customWhereClause += ' where Account__r.Parent.Id in:clientIDS';
            else
                customWhereClause += ' and Account__r.Parent.Id in:clientIDS';
            
            containsFilter = true;
        }
        if(clientType.size() > 0)
        {
            if(customWhereClause == '')
                customWhereClause += ' where Account__r.Parent.Sales_Client_Type__c in:clientType';
            else
                customWhereClause += ' and Account__r.Parent.Sales_Client_Type__c in:clientType';
            
            containsFilter = true;
        }
        
        if(level == 'Product')
        {            
            if(pGroups.size() > 0)
            {
                if(customWhereClause == '')
                    customWhereClause += ' where Product_Group__c in:pGroups';
                else
                    customWhereClause += ' and Product_Group__c in:pGroups';
                containsFilter = true;
            }
            
            if(pRegions.size() > 0)
            {
                if(customWhereClause == '')
                    customWhereClause += ' where Product_Region__c in:pRegions';
                else
                    customWhereClause += ' and Product_Region__c in:pRegions';
                containsFilter = true;
            }
            
            if(products.size() > 0)
            {
                if(customWhereClause == '')
                    customWhereClause += ' where Product2__c in:products';
                else
                    customWhereClause += ' and Product2__c in:products';
                containsFilter = true;
            }
            
            
        }
        if(role.size() > 0)
        {
            
            if(customWhereClause == '')
                customWhereClause += ' where Role__c in:role';
            else
                customWhereClause += ' and Role__c in:role';
            
            containsFilter = true;
        }   
        if(salesPersonIDS.size() > 0 || salesTeam.size()>0)
        {
            if(salesPersonIDS.size() == 0 && salesTeam.size()>0)
            {
                if(customWhereClause.contains('where'))
                    customWhereClause += ' and ';
                else
                    customWhereClause += ' where ';
                
                if(salesDesks.size() > 0 && salesTeams.size() > 0)
                    customWhereClause += ' (Sales_Team_for_Coverage__r.Desk_SearchKey__c in:deskKeys or Sales_Team_for_Coverage__r.Team_SearchKey__c in:teamKeys) ';
                else if(salesDesks.size() > 0 && salesTeams.size() == 0)
                    customWhereClause += '  Sales_Team_for_Coverage__r.Desk_SearchKey__c in:deskKeys ';
                else if(salesDesks.size() == 0 && salesTeams.size() > 0)
                    customWhereClause += '  Sales_Team_for_Coverage__r.Team_SearchKey__c in:teamKeys ';
                containsFilter = true;
            }
            else if(salesPersonIDS.size() > 0 && salesTeam.size() == 0)
            {   
                if(customWhereClause.contains('where')){
                    customWhereClause +=' and Sales_Team_for_Coverage__c in:salesPersonIDS';
                    containsFilter = true;
                }
                else
                {
                    customWhereClause +=' where Sales_Team_for_Coverage__c in:salesPersonIDS';
                    containsFilter = true;
                }
            }
            else
            {
                if(customWhereClause.contains('where'))
                    customWhereClause += ' and ';
                else
                    customWhereClause += ' where ';
                
                if(salesDesks.size() > 0 && salesTeams.size() > 0)
                    customWhereClause += ' (Sales_Team_for_Coverage__c in:salesPersonIDS '+isAndOR+' (Sales_Team_for_Coverage__r.Desk_SearchKey__c in:deskKeys or Sales_Team_for_Coverage__r.Team_SearchKey__c in:teamKeys)) ';
                else if(salesDesks.size() > 0 && salesTeams.size() == 0)
                    customWhereClause += ' (Sales_Team_for_Coverage__c in:salesPersonIDS '+isAndOR+' Sales_Team_for_Coverage__r.Desk_SearchKey__c in:deskKeys) ';
                else if(salesDesks.size() == 0 && salesTeams.size() > 0)
                    customWhereClause += ' (Sales_Team_for_Coverage__c in:salesPersonIDS '+isAndOR+' Sales_Team_for_Coverage__r.Team_SearchKey__c in:teamKeys) ';
                containsFilter = true;
                
            }
            
            
        }
        
        if(customWhereClause.toLowerCase().contains('where'))
            customWhereClause += ' and ';
        else
            customWhereClause += ' where ';
        
        if(include == 'Active')//Sales_Team_for_Coverage__r.Active__c = false
        {
            if(level == 'Product')
                customWhereClause += ' (Product2__c!=null and status__c = \'' + status + '\' and (Sales_Team_for_Coverage__r.Active__c = true or Sales_Team_for_Coverage__r.Owner_Active__c = true))';
            else
                customWhereClause += ' (status__c = \'' + status + '\' and (Sales_Team_for_Coverage__r.Active__c = true or Sales_Team_for_Coverage__r.Owner_Active__c = true))';
        }
        else if(include == 'InActive')
        {
            if(level == 'Product')
                customWhereClause += ' (Product2__c!=null and status__c = \'' + status + '\' and (Sales_Team_for_Coverage__r.Active__c = false or Sales_Team_for_Coverage__r.Owner_Active__c = false))';
            else
                customWhereClause += ' (status__c = \'' + status + '\' and (Sales_Team_for_Coverage__r.Active__c = false or Sales_Team_for_Coverage__r.Owner_Active__c = false))';
            
        }
        
        query += customWhereClause;
        query += groupClause;
        
        List<AggregateResult> rmlist = Database.query(query);
        for(AggregateResult result: rmlist)
        {
            string[] productandRegion = new string[]{};
                string productRegionCombinedValue  = '';
            string product  = '';
            string productRegion  = '';
            string productGroup  = '';
            
            if(level == 'Product')
            {
                if(result.get('PGRP')!=null && result.get('PGRP')!='')
                    productGroup = string.valueOf(result.get('PGRP'));
                
                if(result.get('PRD')!=null && result.get('PRD')!='')
                {
                    product = string.valueOf(result.get('PRD'));
                }             
                if(result.get('PREG')!=null && result.get('PREG')!='')
                {
                    productRegion = string.valueOf(result.get('PREG'));
                }             
            }
            
            if(result.get('RGID')!=null && result.get('RGID')!='' && result.get('CVGID')!=null && result.get('CVGID')!='')
            {
                string key = '';
                if(level == 'Product'  && productGroup!='' && productRegion!='' && product!='')
                {
                    key =string.valueOf(result.get('RGID'))+string.valueOf(result.get('CVGID'))+productGroup+productRegion+product;    
                }
                else
                {
                    key = string.valueOf(result.get('RGID'))+string.valueOf(result.get('CVGID'));
                }
                  rgMap.put(key,result);
                
                string nfpeType = '';
                if(result.get('nfpeType')!=null && string.valueOf(result.get('nfpeType'))!= '' && string.valueOf(result.get('nfpeType'))!='Standard'){
                    string ctype = '';
                    string nfpeSubType = '';
                    nfpeType = string.valueOf(result.get('nfpeType')); // parent type
                    
                    if(result.get('nfpeSubType')!=null && result.get('nfpeSubType')!=''){
                        nfpeSubType = string.valueOf(result.get('nfpeSubType'));
                        if(nfpeSubType!='')
                          ctype =  nfpeType + ':' +  nfpeSubType;
                    }
                    else
                    {
                        ctype =  nfpeType;
                    }
                    
                    if(string.valueOf(result.get('nfpeType'))!='Standard'){
                        if(mapRGRequestNFPE.get(key) == null)
                            mapRGRequestNFPE.put(key,new List<string>{ctype});
                        else
                            mapRGRequestNFPE.get(key).add(ctype);
                    }
                }
            } 
        } 
        system.debug('flag-last');
        system.debug(rgMap);
        return rgMap;      
    } 
    
    
    
}