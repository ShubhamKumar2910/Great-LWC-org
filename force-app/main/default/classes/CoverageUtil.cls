public without sharing class CoverageUtil {
    //Added FLAG_NFPE_SUBTYPE1_1,FLAG_NFPE_SUBTYPE3_1 JIRA Sales 3660 
    public static string FLAG_NFPE = 'NFPE';
    public static string FLAG_NFPE1 = 'NFPE1';
    public static string FLAG_NFPE_SUBTYPE1 = 'NFPE Primary Relationship Coverage';
    public static string FLAG_NFPE_SUBTYPE1_1 = 'NFPE PRC (EMEA Product)';
	public static string FLAG_NFPE_SUBTYPE2 = 'NFPE Primary Product Coverage';
	public static string FLAG_NFPE_SUBTYPE3 = 'NFPE Overseas Authorised Coverage';
    public static string FLAG_NFPE_SUBTYPE3_1 = 'NFPE PRC (Non EMEA Product)';
    public static string FLAG_NFPE_SUBTYPE1_APINAME = 'NFPE_Primary_Relationship_Coverage__c';
    public static string FLAG_NFPE_SUBTYPE2_APINAME = 'NFPE_Primary_Product_Coverage__c';
	public static string FLAG_NFPE_SUBTYPE3_APINAME = 'NFPE_Overseas_Authorised_Coverage__c';
    public static string FLAG_NFPE1_APINAME = 'NFPE1__c';
    public static string FLAG_NFPE_APINAME = 'NFPE__c';
    public static List<string> disableCoverage_as_per_roles = new List<string>{};
    public static List<string> salescode_company_to_exclude = new List<string>{'I'};
    public static List<string> productsaccessforInstinet = new List<string>{'prime finance', 'nes - cash', 'nes - ets', 'nes - pt'}; //Not Used
    public static string FIXED_INCOME = 'Fixed Income';
    public static string EQUITY = 'Equity';
    public static string INVESTMENT_BANKING = 'Investment Banking';
    public static string primaryAndSecondaryTeam = 'Primary + Secondary Team';
    public static List<string> productstoskip = new List<string>{'flow derivatives - usa'}; 
    public static List<string> mandatoryPrimaryAttestRegion = new List<string>{'Europe'}; 
    public static List<string> company = new List<string>{'N'};
    public static List<string> userRole = new List<string>{'Primary','Primary + Secondary Team'}; 
    public static List<string> productstoskipInstinet = new List<string>{'instinet - content related','instinet - execonly','instinet - ets','instinet - cash', 'instinet - pt','instinet - lset', 'instinet - futures', 'instinet - other'}; 
    //Introduced for JIRA SALES-3983 (Product Including Region)
    public static List<String> productsWithRegionsToIncludeForInstinet = new List<String>{'content - asia','futures - asia','content - japan','futures - japan','nes - cash - asia','nes - ets - asia','nes - pt - asia','nes - cash - japan','nes - ets - japan','nes - pt - japan','prime finance - usa','prime finance - europe','prime finance - asia','prime finance - japan'};
    public static string CROSS_SELL_REFERRAL = 'Cross Sell Referral';
    
    public CoverageUtil(){
       
    }
    
    @AuraEnabled
    public static List<Sales_Team_for_Coverage__c> getSalesTeamCoverage(string[] salesTeamCoverageIds){
        return [select Id,Name,Owner_Active__c,Owner_Country__c,Company__c,Sales_Desk_Region__c,Coverage_ID__c,Sales_Team_Code__c,Sales_Team__c from Sales_Team_for_Coverage__c where Id in:salesTeamCoverageIds];    
    } 

    @AuraEnabled
    public static Map<String,List<Sales_Team_for_Coverage__c>> getSalesTeamSecCoverage(List<Sales_Team_for_Coverage__c> salesTeamCoverage){
        Map<String,List<Sales_Team_for_Coverage__c>> secondaryCoverageMap = new Map<String,List<Sales_Team_for_Coverage__c>>();
        Map<String,String> idTeamCodeMap = new Map<String,String>();
        List<String> teamCodes = new List<String>();
        List<String> salespersonIds = new List<String>();

        for(Sales_Team_for_Coverage__c salesPersonRecord : salesTeamCoverage)
        {
            idTeamCodeMap.put(salesPersonRecord.Id, salesPersonRecord.Sales_Team_Code__c);
            teamCodes.add(salesPersonRecord.Sales_Team_Code__c);    
            salespersonIds.add(salesPersonRecord.Id);
        }
        List<Sales_Team_for_Coverage__c> salesSecondaryCoverages = [select Id,Name,Owner_Active__c,Owner_Country__c,Company__c,Sales_Desk_Region__c,Coverage_ID__c,Sales_Team_Code__c,Sales_Team__c from Sales_Team_for_Coverage__c where Sales_Team_Code__c in:teamCodes and Id not in:salespersonIds and is_Dummy__c = false and Is_Split_Sales_Code__c = false and Active__c = true];
        
        for(String codeId : salespersonIds)
        {
            List<Sales_Team_for_Coverage__c> secondaryCoverageList = new List<Sales_Team_for_Coverage__c>();
            for(Sales_Team_for_Coverage__c record : salesSecondaryCoverages)
            {
                if(record.Sales_Team_Code__c == idTeamCodeMap.get(codeId))
                    secondaryCoverageList.add(record);
            }
            secondaryCoverageMap.put(codeId,secondaryCoverageList);
        }
        return secondaryCoverageMap;
    } 
    
    @AuraEnabled
    public static List<Sales_Team_User__c> getSalesTeamUsers(){
        return [select Sales_Team_for_Coverage__c from Sales_Team_User__c where User__c=:UserInfo.getUserId()];    
    } 
    
    public static Boolean doesRGCoversSalesCode(Map<Id,Set<string>> newRG_salesCode_map,string rgAccountId,string salescode){
        if(newRG_salesCode_map.get(rgAccountId)!=null){
            if(newRG_salesCode_map.get(rgAccountId).contains(salescode)){
                return true;
            }
        }
        return false;
    }   
    public static Boolean doesRGhasSameCoverage(Map<Id,Set<string>> newRG_UniqueKey_map,string rgAccountId,string partUniqueKey){
        if(newRG_UniqueKey_map.get(rgAccountId)!=null){
            if(newRG_UniqueKey_map.get(rgAccountId).contains(partUniqueKey)){
                return true;
            }
        }
        return false;
    }
   //method modifed for JIRA SALES 3653
    /*public static List<Coverage_Team_Member__c> getDatafromNewRGCoveragesOnNewRM(Map<Id,List<Coverage_Team_Member__c>> newRG_Coverage_map
                                                                                 ,string rgAccountId,string rmAccountId,string rdmOrgId,Map<Id,string> newRG_ResRM_Countrymap,
                                                                                 Set<string> partUniqueCoverageIdentifier_non_res,Set<string> partUniqueCoverageIdentifier_res,
                                                                                 Boolean isNewRMRestricted,Map<Id,User> new_salesCodeAndUserMapRM){
                                                                                     
                                                                                     
                                                                                     List<Coverage_Team_Member__c> newRGCoverageData = new List<Coverage_Team_Member__c>();
                                                                                     if(newRG_Coverage_map.get(rgAccountId)!=null ){
                                                                                         for(Coverage_Team_Member__c newRG_Coverage: newRG_Coverage_map.get(rgAccountId)){
                                                                                             string salescode_new = newRG_Coverage.sales_team_for_Coverage__r.Coverage_ID__c;
                                                                                             string uniqueId_new  = newRG_Coverage.UniqueId__c;
                                                                                             string rdmOrgId_new = newRG_Coverage.Account__r.RDM_Org_ID__c;
                                                                                             string partUniqueId_new = uniqueId_new.replace(rdmOrgId_new, '').trim();
                                                                                             string salescode_id_new = newRG_Coverage.sales_team_for_Coverage__c;
                                                                                             Boolean isDummy = newRG_Coverage.Sales_Team_For_Coverage__r.Is_dummy__c;
                                                                                                                                            
                                                                                             
                                                                                             // coverage (rm restricted/non-rest) && new rm non-restricted (put it directly if it don't covers)
                                                                                             if(!isNewRMRestricted && !partUniqueCoverageIdentifier_non_res.contains(partUniqueId_new)){
                                                                                                 Coverage_Team_Member__c clonedCoverage3 = newRG_Coverage.clone(false,true);
                                                                                                 clonedCoverage3.Account__c =rmAccountId;
                                                                                                 clonedCoverage3.Start_Date__c = system.today();
                                                                                                 clonedCoverage3.End_Date__c =null;
                                                                                                 clonedCoverage3.Called_from__c ='';
                                                                                                 clonedCoverage3.UniqueId__c =  clonedCoverage3.UniqueId__c.replace(clonedCoverage3.Account__r.RDM_Org_Id__c,rdmOrgId);
                                                                                                 newRGCoverageData.add(clonedCoverage3);
                                                                                                 partUniqueCoverageIdentifier_non_res.add(partUniqueId_new);
                                                                                             }
                      
                                                                                             
                                                                                              // coverage (rm restricted/non-rest) && new rm restricted (check if country matches && dont cover)
                                                                                             if(isNewRMRestricted && !partUniqueCoverageIdentifier_res.contains(partUniqueId_new)){
                                                                                                 if(new_salesCodeAndUserMapRM.get(salescode_id_new)!=null && newRG_ResRM_Countrymap.get(rmAccountId)!=null){
                                                                                                     if((newRG_ResRM_Countrymap.get(rmAccountId) == new_salesCodeAndUserMapRM.get(salescode_id_new).CountryCode) && !isDummy){
                                                                                                         Coverage_Team_Member__c clonedCoverage3 = newRG_Coverage.clone(false,true);
                                                                                                         clonedCoverage3.Account__c =rmAccountId;
                                                                                                         clonedCoverage3.Start_Date__c = system.today();
                                                                                                         clonedCoverage3.End_Date__c =null;
                                                                                                         clonedCoverage3.Called_from__c ='';
                                                                                                         clonedCoverage3.UniqueId__c =  clonedCoverage3.UniqueId__c.replace(clonedCoverage3.Account__r.RDM_Org_Id__c,rdmOrgId);
                                                                                                         partUniqueCoverageIdentifier_res.add(partUniqueId_new);
                                                                                                         newRGCoverageData.add(clonedCoverage3);        
                                                                                                     }
                                                                                                 }
                                                                                             }                                                                              
                                                                                         }
                                                                                     }
                                                                                     
                                                                                     return newRGCoverageData;
                                                                                 }  
    
    */
    public static List<Coverage_Team_Member__c> getDatafromNewRGCoveragesOnNewRM(Map<Id,List<Coverage_Team_Member__c>> newRG_Coverage_map
                                                                                 ,Set<Id> new_rmIds, Map<Id,Account> newRG_ResRM_Countrymap
                                                                                 , Map<Id,User> new_salesCodeAndUserMapRM){                                                                                     
        List<Coverage_Team_Member__c> newRGCoverageData = new List<Coverage_Team_Member__c>();
        Map<String,Coverage_Team_Member__c> mapCoverageMem = new Map<String,Coverage_Team_Member__c>();
        for(Id RMId : new_rmIds){
            if(newRG_ResRM_Countrymap.containsKey(RMId)){
                Account RMAccount = newRG_ResRM_Countrymap.get(RMId);
                Boolean isRestricted = RMAccount.Restricted_Flag__c;
                String ParentID = RMAccount.parentId;
                if(newRG_Coverage_map.containsKey(ParentID)){
                    for(Coverage_Team_Member__c newRG_Coverage: newRG_Coverage_map.get(ParentID)){
                        Coverage_Team_Member__c clonedCoverage3 = newRG_Coverage.clone(false,true);
                        String UniqueID = clonedCoverage3.UniqueId__c;
                        UniqueID =  UniqueID.replace(clonedCoverage3.Account__r.RDM_Org_Id__c,RMAccount.RDM_Org_Id__c);
                        if(!mapCoverageMem.containsKey(UniqueID)){
                            // coverage (rm restricted/non-rest) && new rm non-restricted (put it directly if it don't covers)
                            if(!isRestricted || (!newRG_Coverage.Sales_Team_For_Coverage__r.Is_dummy__c && new_salesCodeAndUserMapRM.get(newRG_Coverage.Sales_Team_for_Coverage__c)!=null && (RMAccount.Domicile_Country__c == new_salesCodeAndUserMapRM.get(newRG_Coverage.Sales_Team_for_Coverage__c).CountryCode))){
                                clonedCoverage3.Account__c =RMAccount.Id;
                                clonedCoverage3.Start_Date__c = system.today();
                                clonedCoverage3.End_Date__c =null;
                                clonedCoverage3.Called_from__c ='';
                                clonedCoverage3.UniqueId__c =  UniqueID;
                                newRGCoverageData.add(clonedCoverage3);   
                                mapCoverageMem.put(clonedCoverage3.UniqueId__c,clonedCoverage3);                         
                            }   
                        }                                             
                    }
                }
            }
        } 
        system.debug('size of records:: '+ newRGCoverageData.size());
        for(Coverage_Team_Member__c tm: newRGCoverageData){
            system.debug('unique id 11:: '+ tm.uniqueId__c);
        }        
        //system.debug('newRGCoverageData ::'+ newRGCoverageData);
        return newRGCoverageData;
    }
    /*
        Method returns a set of current users active Sales Team Ids
    */
    private static Set<Id> getUsersActiveSalesTeamIds()
    {
        List<Sales_Team_User__c> usersSalesTeamUsers = new List<Sales_Team_User__c>();
        usersSalesTeamUsers = [
            SELECT Sales_Team_for_Coverage__c 
            FROM Sales_Team_User__c 
            WHERE User__c =: UserInfo.getUserId()
            AND Sales_Team_for_Coverage__r.Active__c = true
        ];

        Set<Id> usersActiveSalesTeamIds = new Set<Id>();
        for(Sales_Team_User__c loopUsersSalesTeamUser :  usersSalesTeamUsers)
        {
            usersActiveSalesTeamIds.add(loopUsersSalesTeamUser.Sales_Team_for_Coverage__c);    
        }
        return usersActiveSalesTeamIds;
    }
    
    /*
        Method returns true if current user has active coverage of provide RG or RM account
    */

    @AuraEnabled
    public static boolean isUserOnCoverageForAccount(String accountId)
    {
        List<Coverage_Team_Member__c> coverage = new List<Coverage_Team_Member__c>();
        
        // get user's Sales Team
        Set<Id> usersActiveSalesTeams = getUsersActiveSalesTeamIds();

        coverage = [
            SELECT Id 
            FROM Coverage_Team_Member__c
            WHERE (
                Account__c = : accountId
                OR
                Account__r.ParentId = : accountId
            )
            AND
            Sales_Team_for_Coverage__c in :usersActiveSalesTeams
            AND
            RecordType.DeveloperName = 'Active_Coverage'
        ];

        if(coverage.size() > 0)
        {
            return true;
        }
        return false;
    } 

}