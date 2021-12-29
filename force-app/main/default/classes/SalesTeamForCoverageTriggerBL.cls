public class SalesTeamForCoverageTriggerBL {
    
    public static String BATCH_FEED = 'BATCH FEED';
    public static void processBatchforSalesCodes(Map<Id, Sales_Team_for_Coverage__c> newRecords, Map<Id, Sales_Team_for_Coverage__c> oldRecords){
        Set<Id> salesTeamForCoverageIdSet = new Set<Id>();
        if(newRecords != null && newRecords.size() > 0){
            for(Id salesTeamForCoverageId : newRecords.keySet()){
                Sales_Team_for_Coverage__c salesTeamForCoverageObj = newRecords.get(salesTeamForCoverageId);
                Sales_Team_for_Coverage__c salesCodeOldRecord = oldRecords.get(salesTeamForCoverageObj.Id);
                if(salesTeamForCoverageObj != null &&
                   salesTeamForCoverageObj.Process_Coverage_Related_Entities__c == TRUE &&
                   salesCodeOldRecord.Process_Coverage_Related_Entities__c == FALSE &&
                   salesTeamForCoverageObj.is_Dummy__c == false
                  ){
                      salesTeamForCoverageIdSet.add(salesTeamForCoverageObj.Id);
                  }
            }
            
            if(salesTeamForCoverageIdSet.size() > 0 && !Test.isRunningTest()){
                Database.executeBatch(new UpdateCoverageRelatedEntitiesBatch(salesTeamForCoverageIdSet), 5);
            } 
        }
    } 
    
    
    public static void changeOwner(List<Sales_Team_for_Coverage__c> newRecords){
        Set<String> salesCodeLoginIdSet = new Set<String>();
        Map<String,Id> loginIdUserIdMap = new Map<String,Id>();
        Map<string,Boolean> loginIdUserActiveMap = new Map<string,Boolean>();
        
        
        User loggedInUserObj = [SELECT Id, Name, Login_Id__c, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1]; 
        
        if(loggedInUserObj != null && 'Nomura - Integration'.equalsIgnoreCase(loggedInUserObj.Profile.Name)){
            //Fetch the loginId of Sales Codes
            for(Sales_Team_for_Coverage__c salesTeamForCoverageObj : newRecords){
                if(salesTeamForCoverageObj.Is_Split_Sales_Code__c == FALSE &&
                   String.isNotEmpty(salesTeamForCoverageObj.Sales_Code_Login_ID__c))
                {
                    salesCodeLoginIdSet.add(salesTeamForCoverageObj.Sales_Code_Login_ID__c);
                }
            }
            system.debug('salesCodeLoginIdSet: '+salesCodeLoginIdSet);
            if(salesCodeLoginIdSet.size() > 0){
                /* Profile.UserLicense.Name Condition included for ignoring other users like Chatter Users, etc */
				List<User> userList = [SELECT Id, Login_Id__c, IsActive FROM User WHERE Login_Id__c IN :salesCodeLoginIdSet AND Profile.UserLicense.Name = 'Salesforce'];
                system.debug('userList: '+userList);
                if(userList != null && userList.size() > 0){
                    for(User userObj : userList){
                        if(String.isNotEmpty(userObj.Login_Id__c)){
                            loginIdUserIdMap.put(userObj.Login_Id__c.toUpperCase(), userObj.Id);
                            loginIdUserActiveMap.put(userObj.Login_Id__c.toUpperCase(),userObj.IsActive);
                        }
                    }
                }
                
                //if(loginIdUserIdMap.size() > 0){
                for(Sales_Team_for_Coverage__c salesTeamForCoverageObj : newRecords){
                    if(salesTeamForCoverageObj.Is_Split_Sales_Code__c == FALSE &&
                       String.isNotEmpty(salesTeamForCoverageObj.Sales_Code_Login_ID__c) 
                      )
                    {
                        String salesCodeLoginId = salesTeamForCoverageObj.Sales_Code_Login_ID__c.toUpperCase();
                        
                        if(loginIdUserIdMap.containsKey(salesCodeLoginId)){
                            system.debug('1. If');
                            if(loginIdUserActiveMap.get(salesCodeLoginId) == true) //Only if user is active
                            {
                                salesTeamForCoverageObj.OwnerId = loginIdUserIdMap.get(salesCodeLoginId);
                                salesTeamForCoverageObj.is_dummy__c = false;
                            }
                            else
                            {
                                salesTeamForCoverageObj.is_dummy__c = true;
                                salesTeamForCoverageObj.OwnerId = String.valueOf(loggedInUserObj.Id);     
                            }
                        }
                        
                        //1. When salescode from sms comes as owner as sfadmin, we mark it as dummy.
                        //2. if not present as sf user,then we overrite existing owner of salescode to sfadmin
                        else {
                            system.debug('2. If');
                            salesTeamForCoverageObj.is_dummy__c = true;
                            if(!loginIdUserIdMap.containsKey(salesCodeLoginId)){
                                if(!String.valueOf(loggedInUserObj.Id).equalsIgnoreCase(String.valueOf(salesTeamForCoverageObj.OwnerId)))
                                    salesTeamForCoverageObj.OwnerId = String.valueOf(loggedInUserObj.Id);    
                            }
                            
                        }
                        
                        
                        
                        
                    }
                    else if(salesTeamForCoverageObj.Sales_Code_Login_ID__c==null || salesTeamForCoverageObj.Sales_Code_Login_ID__c ==''){
                        salesTeamForCoverageObj.OwnerId = String.valueOf(loggedInUserObj.Id);  
                        salesTeamForCoverageObj.Is_dummy__c = true;
                    }
                    
                    
                    
                }
                //}
            }
        }
        
    }
    
    
    /*public static void changeOwnerForJointSalesCode_bkup(List<Sales_Team_for_Coverage__c> newRecords){
        Set<String> salesCodeSet = new Set<String>();
        Map<String,List<Sales_Team_User__c>> salesCodeUserMap = new Map<String,List<Sales_Team_User__c>>();
        
        User loggedInUserObj = [SELECT Id, Name, Login_Id__c, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1]; 
        
        if(loggedInUserObj != null && 'Nomura - Integration'.equalsIgnoreCase(loggedInUserObj.Profile.Name)){
            //Fetch the Joint Sales Codes
            for(Sales_Team_for_Coverage__c salesTeamForCoverageObj : newRecords){
                if(salesTeamForCoverageObj.Is_Split_Sales_Code__c == TRUE)
                {
                    salesCodeSet.add(salesTeamForCoverageObj.Coverage_Id__c);
                }
            }
            
            if(salesCodeSet.size() > 0){
                List<Sales_Team_User__c> salesTeamUserList = [SELECT Id, Sales_Team_for_Coverage__r.Coverage_Id__c, 
                                                              Sales_Team_for_Coverage__r.OwnerId, Sales_Team_for_Coverage__r.Owner.IsActive,
                                                              User__c, User__r.Login_Id__c, User__r.IsActive
                                                              FROM Sales_Team_User__c 
                                                              WHERE Sales_Team_for_Coverage__r.Coverage_Id__c IN :salesCodeSet];
                
                system.debug('salesTeamUserList: '+salesTeamUserList.size());
                if(salesTeamUserList != null && salesTeamUserList.size() != 0){
                    
                    for(Sales_Team_User__c salesTeamUserObj : salesTeamUserList){
                        String salesCode = salesTeamUserObj.Sales_Team_for_Coverage__r.Coverage_Id__c;
                        List<Sales_Team_User__c> userList = salesCodeUserMap.containsKey(salesCode) ? salesCodeUserMap.get(salesCode) : new List<Sales_Team_User__c>();
                        userList.add(salesTeamUserObj);
                        salesCodeUserMap.put(salesCode, userList);
                    }
                    
                    system.debug('salesCodeUserMap: '+salesCodeUserMap);
                    
                    for(Sales_Team_for_Coverage__c salesTeamForCoverageObj : newRecords){
                        if(salesTeamForCoverageObj.Is_Split_Sales_Code__c == TRUE){
                            String salesCode = salesTeamForCoverageObj.Coverage_ID__c;
                            system.debug('salesCodeUserMap: '+salesCodeUserMap.containsKey(salesCode));
                            if(salesCodeUserMap.containsKey(salesCode)){
                                List<Sales_Team_User__c> userList = salesCodeUserMap.get(salesCode);
                                boolean ownerChangeRequired = FALSE;
                                for(Sales_Team_User__c salesCodeUserObj : userList){
                                    //If 'sfadmin' is Owner or If Owner is inactive then change the owner
                                    if(String.valueOf(loggedInUserObj.Id).equalsIgnoreCase(String.valueOf(salesCodeUserObj.Sales_Team_for_Coverage__r.OwnerId)) ||
                                       salesCodeUserObj.Sales_Team_for_Coverage__r.Owner.IsActive == FALSE
                                      ){
                                          ownerChangeRequired = TRUE;
                                          break;
                                      }
                                }
                                system.debug('ownerChangeRequired: '+ownerChangeRequired);
                                boolean IsActiveSalesTeamUserFound = false;
                                if(ownerChangeRequired){
                                    for(Sales_Team_User__c salesCodeUserObj : userList){
                                        if(salesCodeUserObj.User__r.IsActive == TRUE){
                                            salesTeamForCoverageObj.OwnerId = salesCodeUserObj.User__c;
                                            salesTeamForCoverageObj.is_dummy__c = false;
                                            IsActiveSalesTeamUserFound = true;
                                            break;  
                                        }
                                    }
                                    if(!IsActiveSalesTeamUserFound){
                                        salesTeamForCoverageObj.is_dummy__c = true;
                                        salesTeamForCoverageObj.OwnerId =loggedInUserObj.Id; 
                                    }
                                }
                            }
                            else
                            {
                                salesTeamForCoverageObj.OwnerId = String.valueOf(loggedInUserObj.Id);
                                salesTeamForCoverageObj.is_dummy__c = true;
                            }
                        }
                    }
                }
                
                if(salesTeamUserList.size() == 0){
                    for(Sales_Team_for_Coverage__c salesTeamForCoverageObj : newRecords){
                        if(salesTeamForCoverageObj.Is_Split_Sales_Code__c == TRUE){
                            String salesCode = salesTeamForCoverageObj.Coverage_ID__c;
                            system.debug(salesCodeUserMap.containsKey(salesCode));
                            if(!salesCodeUserMap.containsKey(salesCode)){
                                if(String.valueOf(loggedInUserObj.Id).equalsIgnoreCase(String.valueOf(salesTeamForCoverageObj.OwnerId)))
                                {
                                    salesTeamForCoverageObj.OwnerId = String.valueOf(loggedInUserObj.Id);
                                    salesTeamForCoverageObj.is_dummy__c = true;
                                }
                            }
                        }
                    }
                }
            }
        }
    }*/
    
    public static void changeOwnerForJointSalesCode(List<Sales_Team_for_Coverage__c> newRecords){
        Set<String> salesCodeSet = new Set<String>();
        Map<String,List<Sales_Team_User__c>> salesCodeUserMap = new Map<String,List<Sales_Team_User__c>>();
        Map<string,Set<Boolean>> salesCode_SalesTeamUser_Map = new Map<string,Set<Boolean>>();
        User loggedInUserObj = [SELECT Id, Name, Login_Id__c, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1]; 
        
        if(loggedInUserObj != null && 'Nomura - Integration'.equalsIgnoreCase(loggedInUserObj.Profile.Name)){
            //Fetch the Joint Sales Codes
            for(Sales_Team_for_Coverage__c salesTeamForCoverageObj : newRecords){
                if(salesTeamForCoverageObj.Is_Split_Sales_Code__c == TRUE)
                {
                    salesCodeSet.add(salesTeamForCoverageObj.Coverage_Id__c);
                }
            }
            
            if(salesCodeSet.size() > 0){
                List<Sales_Team_User__c> salesTeamUserList = [SELECT Id, Sales_Team_for_Coverage__r.Coverage_Id__c, 
                                                              Sales_Team_for_Coverage__r.OwnerId, Sales_Team_for_Coverage__r.Owner.IsActive,
                                                              User__c, User__r.Login_Id__c, User__r.IsActive
                                                              FROM Sales_Team_User__c 
                                                              WHERE Sales_Team_for_Coverage__r.Coverage_Id__c IN :salesCodeSet];
                
                system.debug('salesTeamUserList: '+salesTeamUserList.size());
                for(Sales_Team_User__c teamUser : salesTeamUserList){
                    
                    if(salesCode_SalesTeamUser_Map.get(teamUser.Sales_Team_for_Coverage__r.Coverage_Id__c)==null && teamUser.User__r.IsActive)
                    {
                        salesCodeUserMap.put(teamUser.Sales_Team_for_Coverage__r.Coverage_Id__c, new List<Sales_Team_User__c>{teamUser});
                        salesCode_SalesTeamUser_Map.put(teamUser.Sales_Team_for_Coverage__r.Coverage_Id__c,new Set<Boolean>{teamUser.User__r.IsActive});
                    }
                    else if(salesCode_SalesTeamUser_Map.get(teamUser.Sales_Team_for_Coverage__r.Coverage_Id__c)!=null && teamUser.User__r.IsActive)
                    {
                        salesCode_SalesTeamUser_Map.get(teamUser.Sales_Team_for_Coverage__r.Coverage_Id__c).add(teamUser.User__r.IsActive);
                        salesCodeUserMap.get(teamUser.Sales_Team_for_Coverage__r.Coverage_Id__c).add(teamUser);
                    }
                }    
                
                for(Sales_Team_for_Coverage__c salesTeamForCoverageObj : newRecords){
                    //if sales team user present
                    if(salesTeamForCoverageObj.Is_Split_Sales_Code__c == TRUE && salesCode_SalesTeamUser_Map.get(salesTeamForCoverageObj.Coverage_Id__C)!=null){
                        system.debug(salesTeamForCoverageObj.OwnerId);
                        system.debug(String.valueOf(loggedInUserObj.Id).equalsIgnoreCase(String.valueOf(salesTeamForCoverageObj.OwnerId))); 
                        system.debug(salesCode_SalesTeamUser_Map.get(salesTeamForCoverageObj.Coverage_Id__c).contains(true));             
                        //If incoming salescode is sfadmin, and any of its salesteamuser is active
                        if(String.valueOf(loggedInUserObj.Id).equalsIgnoreCase(String.valueOf(salesTeamForCoverageObj.OwnerId))
                           && salesCode_SalesTeamUser_Map.get(salesTeamForCoverageObj.Coverage_Id__c).contains(true))
                        {
                            system.debug('block1');
                            salesTeamForCoverageObj.is_Dummy__c = false;
                            salesTeamForCoverageObj.OwnerId =salesCodeUserMap.get(salesTeamForCoverageObj.Coverage_Id__c)[0].User__c; 
                        }//If incoming salescode is sfadmin, and none of its salesteamuser is active
                        else if(String.valueOf(loggedInUserObj.Id).equalsIgnoreCase(String.valueOf(salesTeamForCoverageObj.OwnerId))
                                && !salesCode_SalesTeamUser_Map.get(salesTeamForCoverageObj.Coverage_Id__c).contains(true))
                        {
                            system.debug('block2');
                            salesTeamForCoverageObj.is_Dummy__c = true;
                            salesTeamForCoverageObj.OwnerId = loggedInUserObj.Id;
                        }//If incoming salescode is not sfadmin, and any of its salesteamuser is active
                        else if(!String.valueOf(loggedInUserObj.Id).equalsIgnoreCase(String.valueOf(salesTeamForCoverageObj.OwnerId))
                                && salesCode_SalesTeamUser_Map.get(salesTeamForCoverageObj.Coverage_Id__c).contains(true))
                        {
                            salesTeamForCoverageObj.is_Dummy__c = false;
                            salesTeamForCoverageObj.OwnerId =salesCodeUserMap.get(salesTeamForCoverageObj.Coverage_Id__c)[0].User__c; 
                        }
                        //If incoming salescode is not sfadmin, and none of its salesteamuser is active
                        else if(!String.valueOf(loggedInUserObj.Id).equalsIgnoreCase(String.valueOf(salesTeamForCoverageObj.OwnerId))
                                && !salesCode_SalesTeamUser_Map.get(salesTeamForCoverageObj.Coverage_Id__c).contains(true))
                        {
                            salesTeamForCoverageObj.is_Dummy__c = true;
                            salesTeamForCoverageObj.OwnerId = loggedInUserObj.Id;
                        }
                    }
                    
                    //If no sales team user present
                    if(salesTeamForCoverageObj.Is_Split_Sales_Code__c == TRUE && salesCode_SalesTeamUser_Map.get(salesTeamForCoverageObj.Coverage_Id__C)==null){
                        salesTeamForCoverageObj.is_Dummy__c = true;
                        salesTeamForCoverageObj.OwnerId = String.valueOf(loggedInUserObj.Id);
                    }
                }
                
                
                
                
            }
        }
    }
    
    public static void createSharing(List<Sales_Team_for_Coverage__c> newRecords){
        Map<Id,String> salesCodeIdLoginIdMap = new Map<Id,String>();
        Map<String,Id> userManagerLoginIdMap = new Map<String,Id>();
        Map<Id,Set<Id>> recordUserMap = new Map<Id,Set<Id>>();
        List<Id> salesTeamForCoverageIdList = new List<Id>();
        
        //Fetch the loginId of Sales Codes
        for(Sales_Team_for_Coverage__c salesTeamForCoverageObj : newRecords){
            if(salesTeamForCoverageObj.Is_Split_Sales_Code__c == FALSE &&
               String.isNotEmpty(salesTeamForCoverageObj.Sales_Code_Login_ID__c))
            {
                salesCodeIdLoginIdMap.put(salesTeamForCoverageObj.Id, salesTeamForCoverageObj.Sales_Code_Login_ID__c);
            }

            if(salesTeamForCoverageObj.Source__c != BATCH_FEED){
                salesTeamForCoverageIdList.add(salesTeamForCoverageObj.Id);
            }
        }

        if(salesTeamForCoverageIdList.size() > 0){
            //to populate coverage Maintenance Level (RG/RM) for each salesperson 
            Database.executeBatch(new PopulateCvgMaintenanceForSalescodeBatch(salesTeamForCoverageIdList),2000);
        }    

        if(salesCodeIdLoginIdMap.size() > 0){
            //Fetch the Manager Data 
             /* Profile.UserLicense.Name Condition included for ignoring other users like Chatter Users, etc */
			List<User> userList = [SELECT Id, Login_Id__c, ManagerId, Manager.IsActive FROM User WHERE Login_Id__c IN :salesCodeIdLoginIdMap.values() AND Profile.UserLicense.Name = 'Salesforce'];
            
            if(userList != null && userList.size() > 0){
                for(User userObj : userList){
                    //Only Take Active Managers
                    if(String.isNotEmpty(userObj.ManagerId) && userObj.Manager.IsActive == TRUE){
                        userManagerLoginIdMap.put(userObj.Login_Id__c.toUpperCase(), userObj.ManagerId);
                    }
                }
            }
            
            //Create the map for sharing Sales Team for Coverage records with Manager
            if(userManagerLoginIdMap.size() > 0){
                for(Id recordId : salesCodeIdLoginIdMap.keySet()){
                    String userLoginId = salesCodeIdLoginIdMap.get(recordId);
                    userLoginId = String.isNotEmpty(userLoginId) ? userLoginId.toUpperCase() : userLoginId;
                    if(userManagerLoginIdMap.containsKey(userLoginId)){
                        Id userManagerId = userManagerLoginIdMap.get(userLoginId);
                        
                        Set<Id> userIdSet = recordUserMap.containsKey(recordId) ? recordUserMap.get(recordId) : new Set<Id>();
                        userIdSet.add(userManagerId);
                        
                        recordUserMap.put(recordId, userIdSet);
                    }
                }
            }
        }
        
        if(recordUserMap.size() > 0){
            CoverageRequestSharing.manualShareEditForSalesTeamForCoverage(recordUserMap);
        }
        
        
    }
    
    public static void createSharingForJointSalesCode(List<Sales_Team_for_Coverage__c> newRecords){
        Map<Id,String> salesCodeOwnerMap = new Map<Id,String>();
        Map<Id,List<Sales_Team_User__c>> salesCodeUserMap = new Map<Id,List<Sales_Team_User__c>>();
        Map<Id,Set<Id>> recordUserMap = new Map<Id,Set<Id>>();
        
        User loggedInUserObj = [SELECT Id, Name, Login_Id__c, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1]; 
        
        if(loggedInUserObj != null && 'Nomura - Integration'.equalsIgnoreCase(loggedInUserObj.Profile.Name)){
            //Create map for SalesCode and Owner
            for(Sales_Team_for_Coverage__c salesTeamForCoverageObj : newRecords){
                if(salesTeamForCoverageObj.Is_Split_Sales_Code__c == TRUE &&
                   !String.valueOf(loggedInUserObj.Id).equalsIgnoreCase(String.valueOf(salesTeamForCoverageObj.OwnerId))
                  )
                {
                    salesCodeOwnerMap.put(salesTeamForCoverageObj.Id, salesTeamForCoverageObj.OwnerId);
                }
            }
            
            //Fetch Sales Code User Data
            List<Sales_Team_User__c> salesTeamUserList = [SELECT Id, Sales_Team_for_Coverage__c, Sales_Team_for_Coverage__r.Coverage_Id__c, 
                                                          User__c, User__r.IsActive, User__r.ManagerId, User__r.Manager.IsActive
                                                          FROM Sales_Team_User__c
                                                          WHERE Sales_Team_for_Coverage__c IN :salesCodeOwnerMap.keySet()
                                                         ];
            
            
            if(salesTeamUserList != null && salesTeamUserList.size() > 0){
                for(Sales_Team_User__c salesTeamUserObj : salesTeamUserList){
                    String salesCodeId = salesTeamUserObj.Sales_Team_for_Coverage__c;
                    List<Sales_Team_User__c> userList = salesCodeUserMap.containsKey(salesCodeId) ? salesCodeUserMap.get(salesCodeId) : new List<Sales_Team_User__c>();
                    userList.add(salesTeamUserObj);
                    salesCodeUserMap.put(salesCodeId, userList);
                }
                
                for(String salesCodeId : salesCodeOwnerMap.keySet()){
                    if(salesCodeUserMap.containsKey(salesCodeId)){
                        List<Sales_Team_User__c> userList = salesCodeUserMap.get(salesCodeId);
                        Set<Id> userIdSet = recordUserMap.containsKey(salesCodeId) ? recordUserMap.get(salesCodeId) : new Set<Id>();
                        
                        for(Sales_Team_User__c salesTeamUserObj : userList){
                            //Share with other users of Joint Sales Code
                            if(!String.valueOf(salesTeamUserObj.User__c).equalsIgnoreCase(String.valueOf(salesCodeOwnerMap.get(salesCodeId))) &&
                               salesTeamUserObj.User__r.IsActive == TRUE 
                              ){
                                  userIdSet.add(salesTeamUserObj.User__c);
                              }
                            
                            //Share with Managers
                            if(String.isNotEmpty(salesTeamUserObj.User__r.ManagerId) && salesTeamUserObj.User__r.Manager.IsActive == TRUE){
                                userIdSet.add(salesTeamUserObj.User__r.ManagerId);
                            }
                        }
                        
                        
                        if(userIdSet.size() > 0){
                            recordUserMap.put(salesCodeId, userIdSet);
                        }
                        
                    }
                }
            }
        }
        
        
        if(recordUserMap.size() > 0){
            CoverageRequestSharing.manualShareEditForSalesTeamForCoverage(recordUserMap);
        }
        
    }
}