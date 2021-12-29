public without sharing class CoverageRequestUtility {
    /**
    * @Description: Fetch User Details
    * @Param: Set<Id> userIdSet, Boolean onlyActiveUsers
    * @Return: Map<Id,User>
    * */
    public static Map<Id,User> fetchUserDetails(Set<Id> userIdSet, Boolean onlyActiveUsers){
    	Map<Id,User> userMap = new Map<Id,User>();
        
        if(userIdSet != null && userIdSet.size() > 0){
            String userActiveCriteria = (onlyActiveUsers == TRUE) ? ' AND IsActive = TRUE ' : '';
        	
            String userClause = formCommaSeparatedStringOfId(userIdSet);
            
        	String strQuery = 'SELECT Id, Login_Id__c, Country,CountryCode, IsActive, ManagerId,  Manager.IsActive, UserRole.Id,UserRole.Name , UserRole.ParentRoleId '
               + 'FROM User '
               + 'WHERE Id IN '
               + userClause
               + userActiveCriteria;
        
            userMap = new Map<Id, User>((List<User>)Database.query(strQuery)); 
        }   
        
        return userMap;
    }
 
    /**
     * @Description: Fetches the Id of user whose Sales Code is selected for Coverage_Access_Request__c
     * @Param: Set<String> salesCodeAndAccountIdSet, Map<Id,Account> accountMap
     * @Return: Map<Id,User>
     * */
    public static Map<Id,User> fetchRequestedForUserForRMRequest(Set<String> salesCodeAndAccountIdSet, Map<Id,Account> accountMap){
        Map<Id,User> salesCodeAndUserMap = new Map<Id,User>();
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> salesCodeRecordIdSet = new Set<Id>();
        
        //Fetch SalesCodes - SalesCodeId and AccountId separated by #
        for(String salesCodeAndAccountKey : salesCodeAndAccountIdSet){
            if(String.isNotEmpty(salesCodeAndAccountKey))
            	salesCodeRecordIdSet.add(salesCodeAndAccountKey.substring(0, salesCodeAndAccountKey.indexOf('#')));
        }
        
        //Fetch details of Sales Codes
        Map<Id, Set<Id>> salesCodeAllUserDetailsMap = fetchSalesCodeAllUserDetails(salesCodeRecordIdSet, false);
        
        if(salesCodeAllUserDetailsMap != null && salesCodeAllUserDetailsMap.size() > 0){
            for(Id recordId : salesCodeAllUserDetailsMap.keySet()){
                userIdSet.addAll(salesCodeAllUserDetailsMap.get(recordId));
            }
            
            if(userIdSet.size() > 0){
            	Map<Id,User> userMap = fetchUserDetails(userIdSet, FALSE);
				
                for(String salesCodeAndAccountKey : salesCodeAndAccountIdSet){
                    Integer indexForSeparator = salesCodeAndAccountKey.indexOf('#');
                    String salesCodeId = salesCodeAndAccountKey.substring(0, indexForSeparator);
                    String accountId = salesCodeAndAccountKey.substring(indexForSeparator + 1);
                    Account accountObj = accountMap.get(accountId);
                    
                    populateSalesCodeAndUserDetails('RM', salesCodeId, accountObj, salesCodeAllUserDetailsMap, userMap, salesCodeAndUserMap);
                    
                }
            }
        }
        
        return salesCodeAndUserMap;
    }
    
    /**
     * @Description: Fetches the Id of user whose Sales Code is selected for RG_Coverage_Request__c
     * @Param: Set<Id> salesCodeRecordIdSet
     * @Return: Map<Id,User>
     * */
    public static Map<Id,User> fetchRequestedForUserForRGRequest(Set<Id> salesCodeRecordIdSet){
        Map<Id,User> salesCodeAndUserMap = new Map<Id,User>();
        Set<Id> userIdSet = new Set<Id>();
        
        //Fetch details of Sales Codes
        Map<Id, Set<Id>> salesCodeAllUserDetailsMap = fetchSalesCodeAllUserDetails(salesCodeRecordIdSet, false);
        
        if(salesCodeAllUserDetailsMap != null && salesCodeAllUserDetailsMap.size() > 0){
            for(Id recordId : salesCodeAllUserDetailsMap.keySet()){
                userIdSet.addAll(salesCodeAllUserDetailsMap.get(recordId));
            }
            
            if(userIdSet.size() > 0){
            	Map<Id,User> userMap = fetchUserDetails(userIdSet, FALSE);
				
                for(Id salesCodeId : salesCodeRecordIdSet){
                    populateSalesCodeAndUserDetails('RG', salesCodeId, null, salesCodeAllUserDetailsMap, userMap, salesCodeAndUserMap);
                }
            }
        }
        
        return salesCodeAndUserMap;
    }
    
    /**
     * @Description: Finds user for salescode
     * @Param: String requestType, String salesCodeId, Account accountObj, 
               Map<Id, Set<Id>> salesCodeAllUserDetailsMap,
               Map<Id,User> userMap,
               Map<Id,User> salesCodeAndUserMap
     * */
    public static void populateSalesCodeAndUserDetails(String requestType, String salesCodeId, Account accountObj, 
                                                      Map<Id, Set<Id>> salesCodeAllUserDetailsMap,
                                                      Map<Id,User> userMap,
                                                      Map<Id,User> salesCodeAndUserMap){
		   Set<Id> userSet = new Set<Id>();                                                          
                                                          
		   if(salesCodeAllUserDetailsMap.containsKey(salesCodeId)){
           		
                    for(Id userId : salesCodeAllUserDetailsMap.get(salesCodeId)){
                        if(userMap.containsKey(userId)){
                            userSet.add(userId);
                        }
                    }
                    
                    Boolean userFoundForRequest = false;
                    
                    //For Coverage_Access_Request__c Object and Restricted Account
                    if('RM'.equalsIgnoreCase(requestType) && accountObj != null && accountObj.Restricted_Flag__c){
                        //Consider Active User and User's Country not matching with Account Country Criteria and Active Manager Criteria
                        for(Id userId : userSet){
                            User userObj = userMap.get(userId);
                            if(userObj.IsActive){
                                if(String.isNotEmpty(accountObj.Domicile_Country__c) &&
                                   String.isNotEmpty(userObj.CountryCode) &&
                                   !accountObj.Domicile_Country__c.equalsIgnoreCase(userObj.CountryCode) && 
                                   String.isNotEmpty(userObj.ManagerId) && 
                                   userObj.Manager.IsActive == TRUE)
                                {
                                    userFoundForRequest = true;
                                    salesCodeAndUserMap.put(salesCodeId, userMap.get(userId));
                                    break;
                                }
                            }
                        }
                        
                        //Consider Active User and User's Country not matching with Account Country Criteria and Manager Criteria
                        if(!userFoundForRequest){
                            for(Id userId : userSet){
                                User userObj = userMap.get(userId);
                                if(userObj.IsActive){
                                    if(String.isNotEmpty(accountObj.Domicile_Country__c) &&
                                       String.isNotEmpty(userObj.CountryCode) &&
                                       !accountObj.Domicile_Country__c.equalsIgnoreCase(userObj.CountryCode) && 
                                       String.isNotEmpty(userObj.ManagerId))
                                    {
                                        userFoundForRequest = true;
                                        salesCodeAndUserMap.put(salesCodeId, userMap.get(userId));
                                        break;
                                    }
                                }
                            }
                        }
                        
                        //Consider Active User and User's Country not matching with Account Country Criteria
                        if(!userFoundForRequest){
                            for(Id userId : userSet){
                                User userObj = userMap.get(userId);
                                if(userObj.IsActive){
                                    if(String.isNotEmpty(accountObj.Domicile_Country__c) &&
                                       String.isNotEmpty(userObj.CountryCode) &&
                                       !accountObj.Domicile_Country__c.equalsIgnoreCase(userObj.CountryCode))
                                    {
                                        userFoundForRequest = true;
                                        salesCodeAndUserMap.put(salesCodeId, userMap.get(userId));
                                        break;
                                    }
                                }
                            }
                        }
                        
                    }
               		
                    //Consider only Active User Criteria (Having Active Manager Data Present)
                    if(!userFoundForRequest){
                        for(Id userId : userSet){
                            User userObj = userMap.get(userId);
                            if(userObj.IsActive && String.isNotEmpty(userObj.ManagerId) && userObj.Manager.IsActive == TRUE){
                                userFoundForRequest = true;
                                salesCodeAndUserMap.put(salesCodeId, userMap.get(userId));
                                break;
                            }    
                        }
                    }
               
               		//Consider only Active User Criteria (Having Manager Data Present)
                    if(!userFoundForRequest){
                        for(Id userId : userSet){
                            User userObj = userMap.get(userId);
                            if(userObj.IsActive && String.isNotEmpty(userObj.ManagerId)){
                                userFoundForRequest = true;
                                salesCodeAndUserMap.put(salesCodeId, userMap.get(userId));
                                break;
                            }    
                        }
                    }
               
               		//Consider only Active User Criteria
                    if(!userFoundForRequest){
                        for(Id userId : userSet){
                            User userObj = userMap.get(userId);
                            if(userObj.IsActive){
                                userFoundForRequest = true;
                                salesCodeAndUserMap.put(salesCodeId, userMap.get(userId));
                                break;
                            }    
                        }
                    }
                    
                    //If user still not found that means only inactive users left
                    //Consider user (i.e Inactive) having active manager data present
                    if(!userFoundForRequest){
                        for(Id userId : userSet){
                            User userObj = userMap.get(userId);
                            if(String.isNotEmpty(userObj.ManagerId) && userObj.Manager.IsActive == TRUE){
                                userFoundForRequest = true;
                                salesCodeAndUserMap.put(salesCodeId, userMap.get(userId));
                                break;
                            }
                        }
                    }
               
               		//Consider user (i.e Inactive) having manager data present
                    if(!userFoundForRequest){
                        for(Id userId : userSet){
                            User userObj = userMap.get(userId);
                            if(String.isNotEmpty(userObj.ManagerId)){
                                userFoundForRequest = true;
                                salesCodeAndUserMap.put(salesCodeId, userMap.get(userId));
                                break;
                            }
                        }
                    }
                            
                    //If user still not found then pick any user
                    if(!userFoundForRequest){
                        for(Id userId : userSet){
                            userFoundForRequest = true;
                            salesCodeAndUserMap.put(salesCodeId, userMap.get(userId));
                            break;
                        }
                    }
                
           }
    }
     
    /**
     * @Description: Fetches the user Ids that form the salesCode (For Joint Sales Codes, one Sales Code can have multiple User Ids)
     * @Param: Set<Id> salesTeamForCoverageIdSet, Boolean onlyActiveUsers
     * @Return:Map<Id,Set<Id>> 
     * */
    public static Map<Id,Set<Id>> fetchSalesCodeAllUserDetails (Set<Id> salesTeamForCoverageIdSet, Boolean onlyActiveUsers){
       Map<Id,Set<Id>> salesCodeUserMap = new Map<Id,Set<Id>>();
        
       if(salesTeamForCoverageIdSet != null && salesTeamForCoverageIdSet.size() > 0){
           String userActiveCriteria = (onlyActiveUsers == TRUE) ? ' WHERE User__r.IsActive = TRUE ' : '';
           String salesCodeClause = formCommaSeparatedStringOfId(salesTeamForCoverageIdSet);
           
           String strQuery = 'SELECT Id, Coverage_ID__c, Sales_Code_Login_ID__c, '
               + '( '
               + 'SELECT Id, Source_Id__c, Sales_Team_for_Coverage__c, User__c FROM Sales_Team_Users__r '
               + userActiveCriteria
               + ') '
               + 'FROM Sales_Team_for_Coverage__c '
               + 'WHERE Id IN '
               + salesCodeClause;
           
           salesCodeUserMap = fetchSalesCodeAllUserDetails(strQuery);
       }
       
       return salesCodeUserMap;
    }
    
     /**
     * @Description: Forms the comma separated string of Ids
     * @Param: Set<Id> recordIdSet
     * */
    public static String formCommaSeparatedStringOfId(Set<Id> recordIdSet){
        String inClause = '';
        
        inClause = '(';
        for(Id recordId : recordIdSet){
            inClause = inClause + '\'' + recordId + '\'' + ',';
        }
        inClause = inClause.substring(0, inClause.lastIndexOf(','));
        inClause = inClause + ')';
        
        return inClause;
    }
    
     /**
     * @Description: Forms the comma separated string of strings
     * @Param: Set<Id> recordIdSet
     * */
    public static String formCommaSeparatedStringOfString(Set<string> recordIdSet){
        String inClause = '';
        
        inClause = '(';
        for(string recordId : recordIdSet){
            inClause = inClause + '\'' + recordId + '\'' + ',';
        }
        inClause = inClause.substring(0, inClause.lastIndexOf(','));
        inClause = inClause + ')';
        
        return inClause;
    }
    
    /**
     * @Description: Fetches all Sales Code details along with User details
     * @Return:Map<Id,Set<Id>> 
     * */
    public static Map<Id,Set<Id>> fetchAllSalesCodeAllUserDetails (){
       Map<Id,Set<Id>> salesCodeUserMap = new Map<Id,Set<Id>>();
       
       String strQuery = 'SELECT Id, Coverage_ID__c, Sales_Code_Login_ID__c, '
            + '( SELECT Id, Source_Id__c, Sales_Team_for_Coverage__c, User__c FROM Sales_Team_Users__r )'
            + 'FROM Sales_Team_for_Coverage__c ';
            
       salesCodeUserMap = fetchSalesCodeAllUserDetails(strQuery);
       
       return salesCodeUserMap;
    }
    
     /**
     * @Description: Forms the salesCodeUserMap from Sales_Team_for_Coverage__c map
     * @Param: String strQuery
     * @Return:Map<Id,Set<Id>> 
     * */
    public static Map<Id,Set<Id>> fetchSalesCodeAllUserDetails(String strQuery){
        Map<Id,Set<Id>> salesCodeUserMap = new Map<Id,Set<Id>>();
        
        Map<Id, Sales_Team_for_Coverage__c> salesTeamForCoverageMap = new Map<Id, Sales_Team_for_Coverage__c>((List<Sales_Team_for_Coverage__c>)Database.query(strQuery)); 
        
        if(salesTeamForCoverageMap != null && salesTeamForCoverageMap.size() > 0){
               for(Id salesTeamForCoverageId : salesTeamForCoverageMap.keySet()){
                   Sales_Team_for_Coverage__c salesTeamDetailsObj = salesTeamForCoverageMap.get(salesTeamForCoverageId);
                   if(salesTeamDetailsObj.Sales_Team_Users__r != null && salesTeamDetailsObj.Sales_Team_Users__r.size() > 0){
                       Set<Id> userSet = new Set<Id>();
                       for(Sales_Team_User__c salesTeamUser : salesTeamDetailsObj.Sales_Team_Users__r){
                           userSet.add(salesTeamUser.User__c);
                       }
                       if(userSet.size() > 0){
                           salesCodeUserMap.put(salesTeamForCoverageId,userSet);
                       }
                   }     
               }
        }
        
        return salesCodeUserMap;
    }
    
    
    /**
     * @Description: Fetches all sales codes present for User
     * @Param: Set<Id> userIdSet
     * @Return:Map<Id,Set<Id>> 
     * */
    public static Map<Id,Set<Id>> fetchUserSalesCodeDetails (Set<Id> userIdSet){
        Map<Id,Set<Id>> userSalesCodeMap = new Map<Id,Set<Id>>();
        
        List<Sales_Team_User__c> salesTeamUserList = [SELECT Id, Source_Id__c, User__c, 
                                                      Sales_Team_for_Coverage__c, Sales_Team_for_Coverage__r.Coverage_Id__c
                                                      FROM Sales_Team_User__c
                                                      WHERE User__c IN :userIdSet];
        
        if(salesTeamUserList != null && salesTeamUserList.size() > 0){
            for(Sales_Team_User__c salesTeamUserObj : salesTeamUserList){
                Set<Id> salesCodeSet = userSalesCodeMap.containsKey(salesTeamUserObj.User__c) ? userSalesCodeMap.get(salesTeamUserObj.User__c) : new Set<Id>();
                salesCodeSet.add(salesTeamUserObj.Sales_Team_for_Coverage__c);
                userSalesCodeMap.put(salesTeamUserObj.User__c, salesCodeSet);
            }
        }
        
        return userSalesCodeMap;
    }

     /**
     * @Description: Fetches all sales codes present for User
     * @Param: Set<Id> userIdSet
     * @Return:Map<Id,Set<Id>> 
     * */
    public static Map<Id,Map<Id,Set<Id>>> getRelatedSalesCodesWithUserIdDetails(Set<Id> salesTeamForCoverageIdSet){
		Map<Id,Map<Id,Set<Id>>> relatedSalesCodesUserMap = new Map<Id,Map<Id,Set<Id>>>();
        Map<Id,Set<Id>> allSalesCodeUserMap = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> salesCodeUserMap = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> userSalesCodeMap = new Map<Id,Set<Id>>();
        Set<Id> userIdSet = new Set<Id>();

        //For each SalesCode, fetch the UserIds
        allSalesCodeUserMap = fetchAllSalesCodeAllUserDetails();
        if(allSalesCodeUserMap.size() > 0){
            for(Id salesTeamForCoverageId : salesTeamForCoverageIdSet){
                if(allSalesCodeUserMap.containsKey(salesTeamForCoverageId)){
                    salesCodeUserMap.put(salesTeamForCoverageId, allSalesCodeUserMap.get(salesTeamForCoverageId));
                    Set<Id> salesCodeUserSet = allSalesCodeUserMap.get(salesTeamForCoverageId);
                    if(salesCodeUserSet != null && salesCodeUserSet.size() > 0){
                        userIdSet.addAll(salesCodeUserSet);
                    }
                }
                
            }
            
            //For each user, fetch the salescodes
            if(userIdSet.size() > 0){
                for(Id userId : userIdSet){
                    for(Id salesTeamForCoverageId : allSalesCodeUserMap.keySet()){
                        Set<Id> userSet = allSalesCodeUserMap.get(salesTeamForCoverageId);
                        Set<Id> salesTeamForCoverageSet = (userSalesCodeMap.containsKey(userId)) ? userSalesCodeMap.get(userId) : new Set<Id>();
                        if(userSet.contains(userId)){
                            salesTeamForCoverageSet.add(salesTeamForCoverageId);
                            userSalesCodeMap.put(userId, salesTeamForCoverageSet);
                        }
                    }
                }
            }
            
            //For each salescode, find the related salescodes
            if(userSalesCodeMap.size() > 0){
                for(Id salesTeamForCoverageId : salesTeamForCoverageIdSet){
                    if(salesCodeUserMap.containsKey(salesTeamForCoverageId)){
                        Map<Id,Set<Id>> relatedDataMap = new Map<Id,Set<Id>>();
                        Set<Id> userSet = salesCodeUserMap.get(salesTeamForCoverageId);
                        if(userSet != null && userSet.size() > 0){
                            for(Id userId : userSet){
                                if(userSalesCodeMap.containsKey(userId)){
                                    for(Id salesCodeId : userSalesCodeMap.get(userId)){
                                        if(allSalesCodeUserMap.containsKey(salesCodeId)){
                                            relatedDataMap.put(salesCodeId, allSalesCodeUserMap.get(salesCodeId));
                                        }
                                    }
                                }
                            }
                        }
                        
                        if(relatedDataMap.size() > 0){
                            relatedSalesCodesUserMap.put(salesTeamForCoverageId, relatedDataMap);
                        }
                    }
                }
            }
        }
        
        return relatedSalesCodesUserMap;        
    }
    
    
    /**
     * @Description: Fetches details of given sales codes
     * @Param: Set<Id> salesCodeRecordIdSet
     * @Return: Map<Id,Sales_Team_for_Coverage__c>
     * */
    public static Map<Id,Sales_Team_for_Coverage__c> fetchsalesCodeDetails (Set<Id> salesCodeRecordIdSet){
       Map<Id,Sales_Team_for_Coverage__c> salesCodeMap = new Map<Id,Sales_Team_for_Coverage__c>();
       
       salesCodeMap = new Map<Id,Sales_Team_for_Coverage__c>(
           [SELECT Id, Name, Coverage_ID__c, Sales_Team__c, Desk_Name__c, Sales_Desk_Region__c, Sales_Desk_Division__c, 
            Sales_Code_Login_ID__c, Active__c, Is_Split_Sales_Code__c, Is_Country_Same__c 
            FROM Sales_Team_for_Coverage__c
            WHERE Id IN :salesCodeRecordIdSet]);
       
       return salesCodeMap;
    }
    
   
     /**
     * @Description:(Bulk Upload) Fetches the user Ids that form the salesCode (For Joint Sales Codes, one Sales Code can have multiple User Ids)
     * @Param: Set<string> salesTeamCodeSet, Boolean onlyActiveUsers
     * @Return:Map<string,Sales_Team_for_Coverage__c> 
     * */
    public static Map<string,Sales_Team_for_Coverage__c> fetchSalesCodeMapUsingSalesCodeSet (Set<string> salesTeamCodeSet, Boolean onlyActiveUsers){
       Map<string,Sales_Team_for_Coverage__c> salesTeamCoverageMap = new Map<string,Sales_Team_for_Coverage__c>();
           
       if(salesTeamCodeSet != null && salesTeamCodeSet.size() > 0){
           String userActiveCriteria = (onlyActiveUsers == TRUE) ? ' WHERE User__r.IsActive = TRUE ' : '';  
           //added field for JIRA SALES 1588
           String salesCodeClause = formCommaSeparatedStringOfString(salesTeamCodeSet);
                      String strQuery = 'SELECT Id,Name, Coverage_ID__c,Is_Dummy__c, Sales_Code_Login_ID__c,Sales_Team__c, Sales_Desk_Division__c,Sales_Desk_Region__c,OwnerId, Active__c,Is_Split_Sales_Code__c,Company__c,Sales_Team_Code__c,Desk_Code__c,'
               + '( '
               + 'SELECT Id, Source_Id__c, Sales_Team_for_Coverage__c, User__c, User__r.UserRole.Id,User__r.Country,User__r.CountryCode,User__r.UserRole.ParentRoleId,User__r.Name,User__r.IsActive,User__r.ManagerId FROM Sales_Team_Users__r '
               + userActiveCriteria
               + ') '
               + 'FROM Sales_Team_for_Coverage__c '
               + 'WHERE Coverage_ID__c IN '
               + salesCodeClause;
           
           for(Sales_Team_for_Coverage__c tm: (List<Sales_Team_for_Coverage__c>)Database.query(strQuery))
           {
              if(tm.Coverage_ID__c!=null)
              {
                	salesTeamCoverageMap.put(tm.Coverage_ID__c,tm);
              }
           }
       }
       return salesTeamCoverageMap;
    }
    
    public static AccountTeamMember getAccountTeamMember(Id AccountId, Id userId){
        AccountTeamMember accountTeamMemberObj = new AccountTeamMember();
        
        accountTeamMemberObj.AccountId = accountId;
        accountTeamMemberObj.UserId = userId;
        
        return accountTeamMemberObj;
    }
    
    public static AccountShare getAccountShare(Id AccountId, Id userId, 
                                               String accountAccessLevel, String contactAccessLevel,
                                               String opportunityAccessLevel, String caseAccessLevel){
        AccountShare accountShareObj = new AccountShare();
        
        accountShareObj.AccountId = accountId;
        accountShareObj.UserOrGroupId = userId;
        accountShareObj.AccountAccessLevel = accountAccessLevel;
        accountShareObj.ContactAccessLevel = contactAccessLevel;
        accountShareObj.OpportunityAccessLevel = opportunityAccessLevel;
        accountShareObj.CaseAccessLevel = caseAccessLevel;
        
        return accountShareObj;
    }
    
    public static Revenue_Rollup__Share getRevenueRollupShare(Id revenueRollupId, Id userId){
        Revenue_Rollup__Share revenueRollupShareObj = new Revenue_Rollup__Share();
        
        revenueRollupShareObj.ParentId = revenueRollupId;
        revenueRollupShareObj.UserOrGroupId = userId;
        revenueRollupShareObj.AccessLevel = 'Read';
        
        return revenueRollupShareObj;
    }
    
    public static Revenue_KPI__Share getRevenueKPIShare(Id revenueKPIId, Id userId){
        Revenue_KPI__Share revenueKPIShareObj = new Revenue_KPI__Share();
        
        revenueKPIShareObj.ParentId = revenueKPIId;
        revenueKPIShareObj.UserOrGroupId = userId;
        revenueKPIShareObj.AccessLevel = 'Read';
        
        return revenueKPIShareObj;
    }
}