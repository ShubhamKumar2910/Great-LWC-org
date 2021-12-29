public without sharing class CoverageDataWithoutSharingController {
    
    public static List<Coverage_Team_Member__c> getRestrictedCoverage(string query,SET<String> filterRGOrgId,
                                                                     SET<String> filterSalesCode,Set<ID> rmRestrictedIds,
                                                                     SET<String> filterProduct, SET<String> filterProductgroup,
                                                                     SET<String> filterProductregion){
        return (List<Coverage_Team_Member__c>)database.query(query);
    }
    
     public static List<AggregateResult> getAggregatedCoverage(string query,SET<String> filterRGOrgId,
                                                                     SET<String> filterSalesCode,
                                                                     SET<String> filterProduct, SET<String> filterProductgroup,
                                                                     SET<String> filterProductregion){
        return (List<AggregateResult>)database.query(query);
    }
    
    
    public static List<AggregateResult> getCoverageTeamMember(string[] clientIDS,string include,string[] clientType, 
                                               string[] pGroups, string[] pRegions, string[] products,
                                               string[] role, string[] salesPersonIDS, string isAndOR, string[] salesTeam,string level,Decimal softLimit,
                                               Boolean isInit, Boolean allCoverages,string query,Set<string> salesDivisions,Set<string> salesRegions,Set<string> salesDesks,Set<string> salesTeams,Set<string> fieldAPIs,Set<string> teamKeys,Set<string> deskKeys)
    {
        List<string> salescode_company_to_exclude = CoverageUtil.salescode_company_to_exclude;		      
        List<string> productsaccessforInstinet = CoverageUtil.productsWithRegionsToIncludeForInstinet;
        
        return Database.query(query);
    }
    
    public static List<Coverage_team_member__c> getCoverageTeamMember(set<Id> rg_accountIds,list<string> fromSalescodeIds)
    {
        return [select Id,UniqueId__c,Account__r.Parent.Recordtype.Name,
                Account__r.parent.rdm_org_id__c,Team_Role__c,start_date__c,
                Product_Group__c,Product__c,Product_Region__c from Coverage_team_member__c where recordtype.Name = 'Active Coverage' and account__r.parentId in:rg_accountIds 
         and Sales_team_for_Coverage__c in:fromSalescodeIds];
    }
    
    public static List<Sales_Team_for_Coverage__c> getSalesCodeDetails(string[] salesPersonIDS){
    	system.debug(salesPersonIDS);
        return [select id, Sales_Code_Login_ID__c,Is_Dummy__c  from Sales_Team_for_Coverage__c where Id in: salesPersonIDS];    
    }
    
    public static Set<Id> getUserIdsbyLoginId(set<string> loginIds){
        return new Map<Id,User>([SELECT Id,Name from User where Login_Id__c in:loginIds]).keyset();
    }
    
    public static List<Sales_Team_User__c> getSalesTeamUser(set<Id> salesPersonIDS){
        return [select id, Sales_Team_for_Coverage__c from Sales_Team_User__c WHERE  User__c in:salesPersonIDS ORDER BY User__r.Name ASC];
    }
    public static List<Sales_Team_User__c> getSalesTeamUser2(set<String> salesPersonIDS){
        return [select id, Sales_Team_for_Coverage__c from Sales_Team_User__c WHERE  User__r.Login_Id__c in:salesPersonIDS ORDER BY User__r.Name ASC];
    }

    public static Map<Id,Set<Id>> fetchActiveUserSalesCodeDetails (Set<string> userloginIds){
        Map<Id,Set<Id>> userSalesCodeMap = new Map<Id,Set<Id>>();
        
        List<Sales_Team_User__c> salesTeamUserList = [SELECT Id, Source_Id__c, User__c, 
                                                      Sales_Team_for_Coverage__c, Sales_Team_for_Coverage__r.Coverage_Id__c
                                                      FROM Sales_Team_User__c
                                                      WHERE User__r.login_id__c IN :userloginIds and User__r.IsActive=true and Sales_Team_for_Coverage__r.Active__c=true 
                                                      ORDER BY User__r.Name ASC];
        
        if(salesTeamUserList != null && salesTeamUserList.size() > 0){
            for(Sales_Team_User__c salesTeamUserObj : salesTeamUserList){
                Set<Id> salesCodeSet = userSalesCodeMap.containsKey(salesTeamUserObj.User__c) ? userSalesCodeMap.get(salesTeamUserObj.User__c) : new Set<Id>();
                salesCodeSet.add(salesTeamUserObj.Sales_Team_for_Coverage__c);
                userSalesCodeMap.put(salesTeamUserObj.User__c, salesCodeSet);
            }
        }
        
        return userSalesCodeMap;
    }
    
     public static List<AggregateResult> getTeamCoverageTeamMember(string product, string productRegion,
                                                                                   string productGroup, string salesCodeId, 
                                                                                   string clientId, boolean isRM , boolean isRG,string salesteam,string query)
     {
         
         system.debug(query);
         return Database.query(query);
     }
    
    public static List<Sales_Team_for_Coverage__c> getSalesTeamStructureSOQL(String searchStringForTree, string query)
    {
        List<Sales_Team_for_Coverage__c> solist  = (List<Sales_Team_for_Coverage__c>) Database.query(query);        
         return solist;
    }
    
    public static Map<string,string> getYTDList(set<string> coverageIds, set<string> RGIds, string userRegion)
    {
        Map<string,string> mapofYTDByRG = new Map<string,string>();
        List<AggregateResult> ytdList = new List<AggregateResult>();
        if(userRegion == 'Japan')
        {
            ytdList = Database.query('SELECT rg__c RG,sales_id__c CODEID, SUM(fytd_gross_yen__c) YTDRevenue,SUM(WTD_Gross_Yen__c) WTDRevenue,SUM(MTD_Gross_Yen__c) MTDRevenue, SUM(FYTD_Budget_Gross_Yen__c) YTDBudget from revenue__c where sales_id__c IN: coverageIds  and rg__r.Id IN: RGIds group by rg__c,sales_id__c');     
        }
        else
        {
            ytdList = Database.query('SELECT rg__c RG,sales_id__c CODEID, SUM(fytd_gross_usd__c) YTDRevenue,SUM(WTD_Gross_USD__c) WTDRevenue,SUM(MTD_Gross_USD__c) MTDRevenue, SUM(FYTD_Budget_Gross_USD__c) YTDBudget  from revenue__c where sales_id__c IN: coverageIds  and rg__r.Id IN: RGIds group by rg__c,sales_id__c');     
        }
        
        for(AggregateResult ytd : ytdList)
        {
            if(ytd.get('RG')!=null && ytd.get('RG')!='' && ytd.get('CODEID')!=null && ytd.get('CODEID')!='' && ytd.get('YTDRevenue')!=null && ytd.get('YTDRevenue')!='')
            {
                //mapofYTDByRG.put(string.valueOf(ytd.get('RG'))+string.valueOf(ytd.get('CODEID')), Decimal.valueOf(Double.valueOf(ytd.get('YTDRevenue'))));
                mapofYTDByRG.put(string.valueOf(ytd.get('RG'))+string.valueOf(ytd.get('CODEID')),ytd.get('YTDRevenue')+':'+ytd.get('YTDBudget')+':'+ytd.get('WTDRevenue')+':'+ytd.get('MTDRevenue'));
            }
        }
        return mapofYTDByRG;
    }
   
}