/**
* @Description: Business Logic/Util class for the Coverage Team Member Trigger
*

* Change Log
*
* Date         Author          Change Description
* ---------------------------------------------------------------------------------------------------------------------------------
* 17/05/2017   T.Sotiraki      Refactored populateUniqueField method to prevent Too Many SOQLs error
* 25/05/2017   T.Sotiraki      Reverted back populateUniqueField method as changes pushed back to next sprint
* 21/06/2017   T.Sotiraki      Removed commented out method DeleteAccountTeamMembers 
* 21/06/2017   T.Sotiraki      Refactored populateUniqueField method to prevent Too Many SOQLs error 
*/
Public without sharing class CoverageTeamMemberTriggerBL{    
    
    public static Nomura_Trigger_Activation__c triggerSettingsSharesPart = Nomura_Trigger_Activation__c.getInstance('CoverageTrigger_RevenueRollupKPI_Share');
    
    public static void populateUniqueField(List<Coverage_Team_Member__c> newRecords){
        
        Set<Id> coverageTeamMemberIdSet = new Set<Id>();
        Set<Id> rmAccountIdSet = new Set<Id>();
        Set<Id> salesTeamIdSet = new Set<Id>();
        
        Map<Coverage_Team_Member__c, String> coverageTeamMemberToUniqueIdMap = new Map<Coverage_Team_Member__c, String>();
        
        List<user> cvgUsers = new List<user>();
        List<Sales_Team_for_Coverage__c> salescvg = new List<Sales_Team_for_Coverage__c>();
        List<Account> cvgAccount = new List<Account>();
        string uniqueId='';
        
        for(Coverage_Team_Member__c ctm : newRecords){   
            coverageTeamMemberIdSet.add(ctm.Team_Member__c);
            rmAccountIdSet.add(ctm.Account__c) ;
            salesTeamIdSet.add(ctm.Sales_Team_for_Coverage__c);             
        } 
        
        cvgAccount = [SELECT Id,Name,RDM_Org_Id__c 
                      FROM Account 
                      WHERE Id IN : rmAccountIdSet];
        
        salescvg = [SELECT Id,Name,Coverage_ID__c,Sales_Code_Login_ID__c 
                    FROM Sales_Team_for_Coverage__c 
                    WHERE Id IN : salesTeamIdSet];
        
        for(Coverage_Team_Member__c actTM : newRecords) {
            // Changes for JIRA SALES-1490  : Start 
            for(Account cvgAcnt : cvgAccount){
                if(actTM.Account__c == cvgAcnt.Id){
                    actTM.Product__c = actTM.Product2__c;                  
                    uniqueId = string.valueof(cvgAcnt.RDM_Org_Id__c)+'#';
                    for(Sales_Team_for_Coverage__c salestmcvg : salescvg){
                        if(actTM.Sales_Team_for_Coverage__c == salestmcvg.Id){
                            uniqueId = uniqueId + string.valueOf(salestmcvg.Sales_Code_Login_ID__c)+'#';
                            uniqueId = uniqueId + string.valueOf(salestmcvg.Coverage_ID__c)+'#';
                            
                            //Populating Sales_Person__c field
                            actTM.Sales_Person__c = salestmcvg.Name;
                            
                            break;
                        }                              
                    }
                    break;
                }
            }
            // Changes for JIRA SALES-1490  : End  
            
            if(actTM.Product_Group__c <> null){
                uniqueId = uniqueId + string.valueOf(actTM.Product_Group__c) +'#'+string.valueOf(actTM.Product2__c) + ' - ' + string.valueOf(actTM.Product_Region__c) +'#';
            }
            if(string.isNotEmpty(string.valueOf(actTM.End_Date__c))){
                uniqueId = uniqueId +  'TRUE';
            }
            if(string.isEmpty(string.valueOf(actTM.End_Date__c)))
            {
                uniqueId = uniqueId + 'FALSE';              
            }
            if(string.valueOf(actTM.Called_From__c) == 'RESTRICTEDDELETE'){
                uniqueId = uniqueId + '#' + actTM.Called_From__c;
            }
            actTM.UniqueId__c = uniqueId.removeEnd('#');
            System.debug('*****actTM.UniqueId__c:'+actTM.UniqueId__c);
            coverageTeamMemberToUniqueIdMap.put(actTM, uniqueId);
            
        }
        
        
        List<Coverage_Team_Member__c> cvgm = [Select Id, uniqueId__c 
                                              From Coverage_Team_Member__c 
                                              Where uniqueId__c IN : coverageTeamMemberToUniqueIdMap.values()];
        
        
        
        if(cvgm.size() > 0){
            
            for(Coverage_Team_Member__c actTM : coverageTeamMemberToUniqueIdMap.keyset()){
                
                for(Coverage_Team_Member__c member : cvgm){
                    if(actTM.UniqueId__c == member.UniqueId__c){
                        String uniqId = coverageTeamMemberToUniqueIdMap.get(actTM);
                        
                        if(string.isNotEmpty(actTM.Called_From__c)){
                            actTM.End_Date__c = actTM.Start_Date__c;
                            actTM.Is_Deleted__c = true;
                            actTM.Called_From__c = 'PERMANENTDELETE';
                            
                            string [] uniqueIdSplit   = uniqId.split('#');
                            
                            if(uniqueIdSplit.size() == 6){
                                
                                if(string.valueOf(uniqueIdSplit[5]) == 'FALSE'){
                                    actTM.UniqueId__c = uniqueIdSplit[0]+'#'+uniqueIdSplit[1]+'#'+uniqueIdSplit[2]+'#'+uniqueIdSplit[3]
                                        +'#'+uniqueIdSplit[4]+'#'+'NotNeeded';
                                }
                                else if(string.valueOf(uniqueIdSplit[5]) == 'TRUE'){
                                    actTM.UniqueId__c = uniqueIdSplit[0]+'#'+uniqueIdSplit[1]+'#'+uniqueIdSplit[2]+'#'+uniqueIdSplit[3]
                                        +'#'+uniqueIdSplit[4]+'#'+'NotNeeded';
                                }
                            }
                            
                            else if(uniqueIdSplit.size() == 4){
                                
                                if(string.valueOf(uniqueIdSplit[3]) == 'FALSE'){
                                    actTM.UniqueId__c = uniqueIdSplit[0]+'#'+uniqueIdSplit[1]+'#'+uniqueIdSplit[2]+'#'+'NotNeeded';
                                }
                                else if(string.valueOf(uniqueIdSplit[3]) == 'TRUE'){
                                    actTM.UniqueId__c = uniqueIdSplit[0]+'#'+uniqueIdSplit[1]+'#'+uniqueIdSplit[2]+'#'+'NotNeeded';
                                }
                            }
                            
                        }else if (cvgm.size() >0){
                            string [] uniqueIdSplit   = uniqId.split('#');
                            
                            if(uniqueIdSplit.size() == 6){              
                                if(string.valueOf(uniqueIdSplit[5]) == 'TRUE'){
                                    actTM.UniqueId__c = uniqueIdSplit[0]+'#'+uniqueIdSplit[1]+'#'+uniqueIdSplit[2]+'#'+uniqueIdSplit[3]
                                        +'#'+uniqueIdSplit[4]+'#'+'NotNeeded';
                                }
                            }
                            
                            else if(uniqueIdSplit.size() == 4){
                                
                                if(string.valueOf(uniqueIdSplit[3]) == 'TRUE'){
                                    actTM.UniqueId__c = uniqueIdSplit[0]+'#'+uniqueIdSplit[1]+'#'+uniqueIdSplit[2]+'#'+'NotNeeded';
                                }
                            }
                        }
                    }
                    
                    
                }
                System.debug('*****actTM.UniqueId__c:'+actTM.UniqueId__c);
            }
        }
        
    }
    
    public static void createSharesOnUpdate(Map<Id,Coverage_Team_Member__c> newRecords){
        Map<Id,Coverage_Team_Member__c> cvgmem = new  Map<Id,Coverage_Team_Member__c>([SELECT Account__c,Account_Access__c,End_Date__c,Contact_Access__c,Opportunity_Access__c,Case_Access__c,Sales_Team_for_Coverage__c FROM Coverage_Team_Member__c where Id in:newRecords.keyset()
                                                                                       and Recordtype.DeveloperName = 'Active_Coverage']);
        Map<Id,Set<Id>> salesCodeUserMap = CoverageTeamMemberTriggerBL.getSalesCodeUserDetailsForInsert(cvgmem); 
        CoverageTeamMemberTriggerBL.CreateAccountTeamMember(cvgmem, salesCodeUserMap);
        if(triggerSettingsSharesPart == null || (triggerSettingsSharesPart != null && triggerSettingsSharesPart.Active__c == true)){
            CoverageTeamMemberTriggerBL.CreateRevenureRollupShares(cvgmem, salesCodeUserMap); 
            RevenueKPIBL.createRevenueSharesFromNewCoverage(cvgmem.values(), salesCodeUserMap);
        }
    }
    
    
    /* Changes for JIRA SALES-1490 */
    private static  AccountTeamMember formAccountTeamMember(Coverage_Team_Member__c coverageTeamMemberObj, Id userId){
        AccountTeamMember accountTeamMemberObj = new AccountTeamMember();
        
        accountTeamMemberObj.AccountId = coverageTeamMemberObj.Account__c;
        accountTeamMemberObj.UserId = userId;
        /*accountTeamMemberObj.TeamMemberRole = coverageTeamMemberObj.Team_Role__c;*/ //Not Required
        
        return accountTeamMemberObj;
    }
    
    private static AccountShare formAccountShare(Coverage_Team_Member__c coverageTeamMemberObj, Id userId){
        AccountShare accountShareObj = new AccountShare();
        
        accountShareObj.AccountId = coverageTeamMemberObj.Account__c;
        accountShareObj.UserOrGroupId = userId;
        accountShareObj.AccountAccessLevel = ShareAccess(coverageTeamMemberObj.Account_Access__c);
        accountShareObj.ContactAccessLevel = ShareAccess(coverageTeamMemberObj.Contact_Access__c);
        accountShareObj.OpportunityAccessLevel = ShareAccess(coverageTeamMemberObj.Opportunity_Access__c);
        accountShareObj.CaseAccessLevel = ShareAccess(coverageTeamMemberObj.Case_Access__c);
        
        return accountShareObj;
    }
    
    private static Revenue_Rollup__Share formRevenueRollupShare(Id revenueRollupId, Id userId){
        Revenue_Rollup__Share revenueRollupShare = new Revenue_Rollup__Share();
        
        revenueRollupShare.ParentId = revenueRollupId;
        revenueRollupShare.UserOrGroupId = userId;
        revenueRollupShare.AccessLevel = 'Read';
        
        return revenueRollupShare;
    }
    
    /**
* @Description: Fetches the active user Ids that form the salesCode 
* @Param: (Map<ID,Coverage_Team_Member__c> coverageTeamMemberMap
* @Return:Map<Id,Set<Id>> 
* */   
    public static Map<Id,Set<Id>> getSalesCodeUserDetailsForInsert(Map<ID,Coverage_Team_Member__c> coverageTeamMemberMap){
        Map<Id,Set<Id>> salesCodeUserMap = new Map<Id,Set<Id>>();
        Set<Id> salesTeamForCoverageIdSet = new Set<Id>();
        
        if(coverageTeamMemberMap != null && coverageTeamMemberMap.size() > 0){
            for(Id coverageTeamMemberId : coverageTeamMemberMap.keySet()){
                Coverage_Team_Member__c coverageTeamMemberObj = coverageTeamMemberMap.get(coverageTeamMemberId);
                salesTeamForCoverageIdSet.add(coverageTeamMemberObj.Sales_Team_for_Coverage__c);
            }
            if(salesTeamForCoverageIdSet.size() > 0){
                //Fetch active users present for each sales code
                salesCodeUserMap = CoverageRequestUtility.fetchSalesCodeAllUserDetails(salesTeamForCoverageIdSet, TRUE);
            }
        }
        return salesCodeUserMap; 
    } 
    /* Changes for JIRA SALES-1490 */ 
    
    Public static void CreateAccountTeamMember(Map<Id, Coverage_Team_Member__c> newRecords, Map<Id,Set<Id>> salesCodeUserMap){
        List<AccountTeamMember> AccountTeamMemberList = new List<AccountTeamMember>();
        List<AccountShare> AcctShareList = new List<AccountShare>();
        for(Coverage_Team_Member__c actTM : newRecords.values()){
            
            if(string.isEmpty(string.valueOf(actTM.End_Date__c))){
                /* Changes for JIRA SALES-1490 : Start */
                if(salesCodeUserMap.containsKey(actTM.Sales_Team_for_Coverage__c)){
                    for(Id userId : salesCodeUserMap.get(actTM.Sales_Team_for_Coverage__c)){
                        AccountTeamMemberList.add(formAccountTeamMember(actTM, userId));
                        AcctShareList.add(formAccountShare(actTM, userId));
                    }
                }
                /* Changes for JIRA SALES-1490 : End */
            }
        }
        
        if(AccountTeamMemberList.size()>0){
            saveInserts(AccountTeamMemberList,newRecords.values());
        }
        
        if(AcctShareList.size()>0){
            saveInserts(AcctShareList,newRecords.values());
        }
        
    }
    
    
    Public static void CreateRevenureRollupShares(Map<Id, Coverage_Team_Member__c> newRecords, Map<Id,Set<Id>> salesCodeUserMap){
        
        Set<Id> accountSet = new Set<Id>();
        Map<id,list<Coverage_Team_Member__c>> coverageTeamMemberMap = new Map<id,list<Coverage_Team_Member__c>>();
        
        for(Coverage_Team_Member__c acctTeam : newRecords.values()){
            
            if(string.isEmpty(string.valueOf(acctTeam.End_Date__c)))  { 
                
                accountSet.add(acctTeam.account__c);     
                
                list<Coverage_Team_Member__c> actTeamList = coverageTeamMemberMap.get(acctTeam.account__c)!=null? coverageTeamMemberMap.get(acctTeam.account__c): new list<Coverage_Team_Member__c>();
                actTeamList.add(acctTeam);
                coverageTeamMemberMap.put(acctTeam.account__c,actTeamList);
            }
        }
        
        List<Revenue_Rollup__c > RevenueRollupList = [Select id,name,Region__c,ownerid,account__c,RM__c from Revenue_Rollup__c where RM__c in : accountset];
        List<Revenue_Rollup__share> reverollupshareList = new List<Revenue_Rollup__share>();
        
        for(Revenue_Rollup__c revrollup : RevenueRollupList){
            if(coverageTeamMemberMap.containskey(revrollup.RM__c)){
                for(Coverage_Team_Member__c acctTeam : coverageTeamMemberMap.get(revrollup.RM__c)){
                    /* Changes for JIRA SALES-1490 : Start */
                    if(salesCodeUserMap.containsKey(acctTeam.Sales_Team_for_Coverage__c)){
                        for(Id userId : salesCodeUserMap.get(acctTeam.Sales_Team_for_Coverage__c)){
                            if(revrollup.ownerid != userId){
                                reverollupshareList.add(formRevenueRollupShare(revrollup.Id, userId));   
                            }
                        }
                    }  
                    /* Changes for JIRA SALES-1490 : End */  
                }
            }
        }
        
        if(reverollupshareList.size()>0){
            saveInserts(reverollupshareList,newRecords.values());
        }
    }
    
    /**
* @Description: Gets Coverage_Team_Member__c updated records
* @Param: Map<Id,Coverage_Team_Member__c> oldRecords, List<Coverage_Team_Member__c> newRecords
* @Return: Map<String,List<Coverage_Team_Member__c>> 
* */
    public static List<Coverage_Team_Member__c> getCoverageTeamMemberUpdatedRecords(List<Coverage_Team_Member__c> newRecords){
        List<Coverage_Team_Member__c> deletedCoverageRecords = new List<Coverage_Team_Member__c>();
        for(Coverage_Team_Member__c updatedRecord : newRecords){
            if(!String.valueOf(updatedRecord.UniqueId__c).contains('PREVDELETE')){
                if(updatedRecord.End_Date__c != null){
                    deletedCoverageRecords.add(updatedRecord);            
                }
            }
        }
        System.debug('***deletedCoverageRecords:'+deletedCoverageRecords);
        return deletedCoverageRecords;
    }
    
    public static void DeleteNotNeededIntegrationRecords(List<Coverage_Team_Member__c> newRecords){
        
        List<Coverage_Team_Member__c> cvgMem = [SELECT Id FROM Coverage_Team_Member__c WHERE Id IN: newRecords];
        
        try{
            Delete cvgMem;
        }
        
        catch(Exception ex){
            newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()+'CoverageBLForIntegration-DeleteNotNeededIntegrationRecords');
        }
    }
    
    
    
    
    Public static void DeleteAccountTeamMembersAltered(List<Coverage_Team_Member__c> newRecords, 
                                                       Set<String> accountAndTeamMemberSet){
                                                           
                                                           Boolean codeToBeExecuted = (triggerSettingsSharesPart == null || (triggerSettingsSharesPart != null && triggerSettingsSharesPart.Active__c == true)) ? true : false;
                                                           /* Changes for JIRA SALES-1490 : Start */
                                                           Set<Id> accountIdSet = new Set<Id>();
                                                           Map<Id,Set<Id>> accountAndRevenueRollUpIdMap = new Map<Id,Set<Id>>();  
                                                           List<AccountTeamMember> accountTeamMemberList;
                                                           List<AccountShare> accountShareList;
                                                           List<Revenue_Rollup__Share> revenueRollupShareList;
                                                           String acctTeamMemberQueryCriteria = '';
                                                           String acctShareQueryCriteria = '';
                                                           String revRollUpShareQueryCriteria = '';  
                                                           
                                                           if(accountAndTeamMemberSet.size() > 0){
                                                               //Fetch the Accounts Ids to be considered
                                                               for(String acctAndTMStr : accountAndTeamMemberSet){
                                                                   String accountId = acctAndTMStr.substring(0,acctAndTMStr.lastIndexOf('#'));
                                                                   accountIdSet.add(accountId);
                                                               }     
                                                               
                                                               if(codeToBeExecuted){
                                                                    List<Revenue_Rollup__c> revenueRollupList = [SELECT Id, Name, Region__c, Ownerid, RM__c FROM Revenue_Rollup__c WHERE RM__c IN : accountIdSet];
                                                                    
                                                                    if(revenueRollupList !=  null && revenueRollupList.size() > 0){
                                                                        for(Revenue_Rollup__c revenueRollUpObj : revenueRollupList){
                                                                            Set<Id> revenueRollUpIdSet = accountAndRevenueRollUpIdMap.containsKey(revenueRollUpObj.RM__c) ? accountAndRevenueRollUpIdMap.get(revenueRollUpObj.RM__c) : new set<Id>();
                                                                            revenueRollUpIdSet.add(revenueRollUpObj.Id);
                                                                            accountAndRevenueRollUpIdMap.put(revenueRollUpObj.RM__c, revenueRollUpIdSet);
                                                                        }
                                                                    }
                                                               }
                                                               
                                                               //Form query criteria for deleting AccountTeamMember, AccountShare and Revenue_Rollup__Share
                                                               for(String acctAndTMStr : accountAndTeamMemberSet){
                                                                   String accountId = acctAndTMStr.substring(0,acctAndTMStr.lastIndexOf('#'));
                                                                   String teamMemberId = acctAndTMStr.substring(acctAndTMStr.lastIndexOf('#') + 1);
                                                                   
                                                                   acctTeamMemberQueryCriteria = acctTeamMemberQueryCriteria + '(AccountId = \'' + accountId + '\' AND UserId = \'' + teamMemberId + '\') OR ';
                                                                   acctShareQueryCriteria = acctShareQueryCriteria + '(AccountId = \'' + accountId + '\' AND UserOrGroupId = \'' + teamMemberId + '\') OR ';
                                                                   
                                                                   if(codeToBeExecuted){
                                                                        if(accountAndRevenueRollUpIdMap.containsKey(accountId)){
                                                                            String parentIdSet = CoverageRequestUtility.formCommaSeparatedStringOfId(accountAndRevenueRollUpIdMap.get(accountId));
                                                                            revRollUpShareQueryCriteria = revRollUpShareQueryCriteria + '(ParentId IN ' + parentIdSet + ' AND UserOrGroupId = \'' + teamMemberId + '\') OR ';
                                                                        }
                                                                        System.debug('****revRollUpShareQueryCriteria:'+revRollUpShareQueryCriteria);
                                                                   } 
                                                               }
                                                               
                                                               //Fetch data for AccountTeamMember, AccountShare and Revenue_Rollup__Share
                                                               if(String.isNotEmpty(acctTeamMemberQueryCriteria)){
                                                                   acctTeamMemberQueryCriteria = acctTeamMemberQueryCriteria.substring(0, acctTeamMemberQueryCriteria.lastIndexOf('OR '));
                                                                   String acctTeamMemberQuery = 'SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE '
                                                                       + acctTeamMemberQueryCriteria;
                                                                   accountTeamMemberList = Database.query(acctTeamMemberQuery);
                                                               }
                                                               
                                                               if(String.isNotEmpty(acctShareQueryCriteria)){
                                                                   acctShareQueryCriteria = acctShareQueryCriteria.substring(0, acctShareQueryCriteria.lastIndexOf('OR'));
                                                                   String acctShareQuery = 'SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE '
                                                                       + acctShareQueryCriteria;
                                                                   accountShareList = Database.query(acctShareQuery);
                                                               }
                                                               
                                                               if(codeToBeExecuted){
                                                                    if(String.isNotEmpty(revRollUpShareQueryCriteria)){
                                                                        revRollUpShareQueryCriteria = revRollUpShareQueryCriteria.substring(0, revRollUpShareQueryCriteria.lastIndexOf('OR'));
                                                                        String revRollUpShareQuery = 'SELECT Id, ParentId, UserOrGroupId FROM Revenue_Rollup__Share WHERE '
                                                                            + revRollUpShareQueryCriteria;
                                                                        System.debug('****revRollUpShareQuery:'+revRollUpShareQuery);
                                                                        revenueRollupShareList = Database.query(revRollUpShareQuery);
                                                                    }
                                                               } 

                                                               //Deleting AccountTeamMember, AccountShare and Revenue_Rollup__Share
                                                               try {
                                                                   if(accountTeamMemberList != null && accountTeamMemberList.size() > 0)
                                                                       delete accountTeamMemberList;
                                                                   if(accountShareList != null && accountShareList.size() > 0)
                                                                       delete accountShareList;
                                                                   if(codeToBeExecuted){
                                                                        if(revenueRollupShareList != null && revenueRollupShareList.size() > 0)
                                                                            delete revenueRollupShareList;
                                                                   }
                                                                   
                                                               }
                                                               catch(Exception ex){
                                                                   if(newRecords!=null)
                                                                       newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
                                                               }
                                                           }
                                                           
                                                           /* Changes for JIRA SALES-1490 : End */  
                                                       }
    
    Public static string ShareAccess(string access){
        string returnAccess;
        if(access == 'Private'){
            
            returnAccess = 'None';
            
        }else if(access == 'Read Only'){
            
            returnAccess = 'Read';
            
        }else if(access == 'Read/Write'){
            
            returnAccess = 'Edit';     
        }
        return returnAccess;
    }
    
    
    public static void saveInserts(LIST<sObject> sObjInsertLIST, list<sobject> newRecords)
    {
        system.debug('in save inserts');
        if (sObjInsertLIST.size()>0) {
            try{
                system.debug('++++'+sObjInsertLIST);
                insert sObjInsertLIST;
            }catch(exception ex)
            {
                newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
            }
        }
    }
    
    /**
* @Description: Combines Sales Code Data with Account Data
* @Param: Set<String> accountAndSalesCodeSet, Map<Id,Map<Id,Set<Id>>> relatedSalesCodesUserMap
* @Return: Map<String,Map<String,Set<String>>> 
* */
    public static  Map<String,Map<String,Set<String>>> getCombinedAccountAndSalesCodeData(Set<String> accountAndSalesCodeSet, Map<Id,Map<Id,Set<Id>>> relatedSalesCodesUserMap){
        Map<String,Map<String,Set<String>>> accountAndSalesCodeMap = new Map<String,Map<String,Set<String>>>();
        
        for(String accountAndSalesCodeStr : accountAndSalesCodeSet){
            String accountId = accountAndSalesCodeStr.substring(0,accountAndSalesCodeStr.lastIndexOf('#'));
            String salesCodeId = accountAndSalesCodeStr.substring(accountAndSalesCodeStr.lastIndexOf('#') + 1);
            
            if(relatedSalesCodesUserMap.containsKey(salesCodeId)){
                Map<Id,Set<Id>> salesCodeWithUserIdMap = relatedSalesCodesUserMap.get(salesCodeId);
                Map<String,Set<String>> accountAndSalesCodeWithUserIdMap = new Map<String,Set<String>>();
                for(Id salesTeamId : salesCodeWithUserIdMap.keySet()){
                    String accAndSalesCodeStr =  accountId + '#' + salesTeamId;
                    Set<String> accountAndUserSet = new Set<String>();
                    for(Id userId : salesCodeWithUserIdMap.get(salesTeamId)){
                        accountAndUserSet.add(accountId + '#' + userId);
                    }
                    
                    accountAndSalesCodeWithUserIdMap.put(accAndSalesCodeStr, accountAndUserSet);
                }
                
                accountAndSalesCodeMap.put(accountAndSalesCodeStr,accountAndSalesCodeWithUserIdMap);
            }         
        }
        
        return accountAndSalesCodeMap;
    }
    
    /**
* @Description: Get Coverage details for provided Sales Code and Account Data
* @Param: Set<Id> accountIdSet, Set<Id> salesCodesToBeSearchedSet
* @Return: Set<String>
* */
    public static Set<String> getActiveAccountAndSalesCodeDetails(Set<Id> accountIdSet, Set<Id> salesCodesToBeSearchedSet){
        Set<String> activeAccountAndSalesCodeSet = new Set<String>();
        
        List<Coverage_Team_Member__c> activeCoverageList = [SELECT Id, Account__c, Sales_Team_for_Coverage__c FROM Coverage_Team_Member__c 
                                                            WHERE End_Date__c = NULL
                                                            AND Account__c IN :accountIdSet
                                                            AND Sales_Team_for_Coverage__c IN :salesCodesToBeSearchedSet
                                                            ORDER BY Account__c,Sales_Team_for_Coverage__c ];
        if(activeCoverageList != null){
            for(Coverage_Team_Member__c coverageObj : activeCoverageList){
                activeAccountAndSalesCodeSet.add(coverageObj.Account__c + '#' + coverageObj.Sales_Team_for_Coverage__c);
            }
        } 
        
        return activeAccountAndSalesCodeSet;
    }
    
    /**
* @Description: Get Account and Team member data for Deletion
* @Param: Set<String> activeAccountAndSalesCodeSet, Map<String,Map<String,Set<String>>> accountAndSalesCodeMap
* @Return: Set<String>
* */
    public static Set<String> getAccountAndTeamMemberDetails(Set<String> activeAccountAndSalesCodeSet, 
                                                             Map<String,Map<String,Set<String>>> accountAndSalesCodeMap) {
                                                                 Set<String> accountAndTeamMemberSet = new Set<String>();
                                                                 
                                                                 if(activeAccountAndSalesCodeSet != null && activeAccountAndSalesCodeSet.size() > 0){
                                                                     for(String accountAndSalesCodeStr : accountAndSalesCodeMap.keySet()){
                                                                         Map<String,Set<String>> accountAndSalesCodeWithUserIdMap = accountAndSalesCodeMap.get(accountAndSalesCodeStr);
                                                                         Set<String> foundAccountAndTeamMemberIdSet = new Set<String>();
                                                                         Set<String> notFoundAccountAndTeamMemberIdSet = new Set<String>();
                                                                         
                                                                         for(String accountAndSalesCodeKey : accountAndSalesCodeWithUserIdMap.keySet()){
                                                                             if(activeAccountAndSalesCodeSet.contains(accountAndSalesCodeKey)){
                                                                                 foundAccountAndTeamMemberIdSet.addAll(accountAndSalesCodeWithUserIdMap.get(accountAndSalesCodeKey));
                                                                             }
                                                                             else {
                                                                                 notFoundAccountAndTeamMemberIdSet.addAll(accountAndSalesCodeWithUserIdMap.get(accountAndSalesCodeKey));
                                                                             }
                                                                         }
                                                                         
                                                                         if(foundAccountAndTeamMemberIdSet.size() > 0){
                                                                             for(String accountAndTeamMemberId : notFoundAccountAndTeamMemberIdSet){
                                                                                 if(!foundAccountAndTeamMemberIdSet.contains(accountAndTeamMemberId)){
                                                                                     accountAndTeamMemberSet.add(accountAndTeamMemberId);
                                                                                 }
                                                                             }
                                                                         }
                                                                         else {
                                                                             accountAndTeamMemberSet.addAll(notFoundAccountAndTeamMemberIdSet);
                                                                         }
                                                                     }
                                                                 }
                                                                 else {
                                                                     for(String accountAndSalesCodeStr : accountAndSalesCodeMap.keySet()){
                                                                         Map<String,Set<String>> accountAndSalesCodeWithUserIdMap = accountAndSalesCodeMap.get(accountAndSalesCodeStr);
                                                                         if(accountAndSalesCodeWithUserIdMap.containsKey(accountAndSalesCodeStr)){
                                                                             accountAndTeamMemberSet.addAll(accountAndSalesCodeWithUserIdMap.get(accountAndSalesCodeStr));
                                                                         }
                                                                     }
                                                                 }
                                                                 
                                                                 return accountAndTeamMemberSet;
                                                             }
    
    /**
* @Description: Get Account and Team member data for Deletion
* @Param: List<Coverage_Team_Member__c> newRecords
* @Return: Set<String>
* */
    Public static Set<String> getAccountAndTeamMemberDetailsForDeletion(List<Coverage_Team_Member__c> newRecords){
        
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> salesTeamForCoverageIdSet = new Set<Id>();
        Set<String> accountAndSalesCodeSet = new Set<String>();
        Set<Id> salesCodesToBeSearchedSet = new Set<Id>();
        Set<String> activeAccountAndSalesCodeSet = new Set<String>();
        Set<String> accountAndTeamMemberSet = new Set<String>();
        Map<Id,Map<Id,Set<Id>>> relatedSalesCodesUserMap = new Map<Id,Map<Id,Set<Id>>>();  
        Map<String,Map<String,Set<String>>> accountAndSalesCodeMap = new Map<String,Map<String,Set<String>>>();
        
        if(newRecords != null && newRecords.size() > 0){
            for(Coverage_Team_Member__c coverageTeamMember : newRecords){
                accountIdSet.add(coverageTeamMember.Account__c);
                salesTeamForCoverageIdSet.add(coverageTeamMember.Sales_Team_for_Coverage__c);
                
                String accountAndSalesCode = coverageTeamMember.Account__c + '#' + coverageTeamMember.Sales_Team_for_Coverage__c;
                accountAndSalesCodeSet.add(accountAndSalesCode);
            }
            
            if(salesTeamForCoverageIdSet.size() > 0){
                relatedSalesCodesUserMap = CoverageRequestUtility.getRelatedSalesCodesWithUserIdDetails(salesTeamForCoverageIdSet);
            }
            
            accountAndSalesCodeMap = getCombinedAccountAndSalesCodeData(accountAndSalesCodeSet, relatedSalesCodesUserMap);  
            
            for(Map<Id,Set<Id>> salesCodeAndUserMap : relatedSalesCodesUserMap.values()){
                salesCodesToBeSearchedSet.addAll(salesCodeAndUserMap.keySet());
            }
            
            if(accountIdSet.size() > 0 && salesCodesToBeSearchedSet.size() > 0){
                //Fetch Active Coverage Details
                activeAccountAndSalesCodeSet = getActiveAccountAndSalesCodeDetails(accountIdSet, salesCodesToBeSearchedSet);
                
                //Fetch Account and Team Member Details for Deletion
                accountAndTeamMemberSet = getAccountAndTeamMemberDetails(activeAccountAndSalesCodeSet, accountAndSalesCodeMap);
            }
        }
        
        return accountAndTeamMemberSet;  
    }
    
    
}