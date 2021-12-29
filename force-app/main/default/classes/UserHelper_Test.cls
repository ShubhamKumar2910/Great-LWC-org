@isTest
public class UserHelper_Test {

   static testMethod void CheckInsertUpdateofUsersInGroup (){
       Integer numTestAccounts = 4;
  
 
        
   
    Integer numTestUsers = 4;  
    List<User> users = UtilityTesting.CreateUsersWithManager(numTestUsers);
    User owneruser = [select id,name,ManagerId,Manager.Name,Region__c from user where id =:users[1].id];   
    system.runas(users[0]){
        
  
        
    Profile ResearchProfile = [SELECT Id FROM Profile Where Name =: 'Nomura - Research'] ;
        
    Profile SalesProfile = [SELECT Id FROM Profile Where Name =: 'Nomura - Sales'] ;   
        
     user adduser = new user();        
        adduser.Email = 'test@user.com';
        adduser.LastName = 'user45';
        adduser.FirstName = 'Test';
        adduser.LanguageLocaleKey = 'en_US';
        adduser.LocaleSidKey = 'en_US';
        adduser.Alias = 'ciuig';
        adduser.CommunityNickname = 'ciuig';
        adduser.Username = 'Kwid@kwid.com';
        adduser.EmailEncodingKey = 'UTF-8';
        adduser.ProfileId = ResearchProfile.Id;
        adduser.TimeZoneSidKey = 'America/Los_Angeles';
        adduser.Country = 'Hong Kong';
        
        
          insert adduser;
        
        
        
        
    User TestUser = [SELECT Id,ProfileId,Country FROM User WHERE id=:users[1].id];     
      
        
        TestUser.ProfileId = ResearchProfile.Id;
        TestUser.Country = 'Canada';
        
        update TestUser;
        
        TestUser.Country = 'United States';
        
        update TestUser;
        
        TestUser.ProfileId = SalesProfile.Id;
        
        update TestUser;
        
        TestUser.ProfileId = ResearchProfile.Id;
        TestUser.Country = 'United Kingdom';
        update TestUser;
              
        
    
    }
    }
    
    static testMethod void testChampionRecordDeletionForTerminatedUsers() {
        //Activate Trigger
        setNomuraTriggerActivation();
        
        Integer numTestUsers = 1;  
        List<User> users = new List<User>();
            System.runAs(new User(Id=UserInfo.getUserId())) {        
                users = UtilityTesting.CreateUsersWithManager(numTestUsers);
            }
            
        
        RecordType recordTypeRG = [SELECT Id FROM RecordType WHERE Name = 'RG Account' LIMIT 1];
       
        system.runas(users[0]){
            
            //Insert Accounts
            List<Account> accountList = new List<Account>();
            
            Account accountObj1 = new Account();
            accountObj1.Name = 'Test_Account1';
            accountObj1.RDM_Org_Id__c = 'RGAccount1';
            accountObj1.RecordTypeId = recordTypeRG.Id;
            accountObj1.Active__c = TRUE;   
            
            accountList.add(accountObj1);
            
            Account accountObj2 = new Account();
            accountObj2.Name = 'Test_Account2';
            accountObj2.RDM_Org_Id__c = 'RGAccount2';
            accountObj2.RecordTypeId = recordTypeRG.Id;
            accountObj2.Active__c = TRUE;   
           
            accountList.add(accountObj2);
            
            insert accountList;
            
            //Insert User
            Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
            User userObj = new User();
            userObj.Login_ID__c = 'User1';
            userObj.Alias = 'User1';
            userObj.LastName = 'User1';
            userObj.Email = 'User1@testOrg.com';
            userObj.UserName = 'User1_hack@testOrg.com';
            userObj.ProfileId = profileNomuraSales.Id;
            userObj.EmailEncodingKey = 'UTF-8';
            userObj.LanguageLocaleKey = 'en_US';
            userObj.LocaleSidKey = 'en_US';
            userObj.TimeZoneSidKey = 'America/Los_Angeles';
            userObj.Region__c = 'Americas';
            
            System.runAs(new User(Id=UserInfo.getUserId())) { 
                insert userObj;
            }
            
            //Insert Champions
            List<Sales_Champion__c> salesChampionList = new List<Sales_Champion__c>();
            
            Sales_Champion__c champion1Obj = new Sales_Champion__c();
            champion1Obj.Account__c = accountObj1.Id;
            champion1Obj.Region__c = 'Americas';
            champion1Obj.Champion_Type__c = 'Rsch Sales Champion';
            champion1Obj.Sales_Champion__c = userObj.Id;
            
            salesChampionList.add(champion1Obj);
            
            Sales_Champion__c champion2Obj = new Sales_Champion__c();
            champion2Obj.Account__c = accountObj2.Id;
            champion2Obj.Region__c = 'Americas';
            champion2Obj.Champion_Type__c = 'Rsch Sales Champion';
            champion2Obj.Sales_Champion__c = userObj.Id;
            
            salesChampionList.add(champion2Obj);
            
            insert salesChampionList;
            
            //Check the Champion Records
            
            Set<Id> userIdSet = new Set<Id>();
            userIdSet.add(userObj.Id);
            Sales_Champion__c [] salesChampionData = [SELECT Id, Name FROM Sales_Champion__c
                                                      WHERE Sales_Champion__r.Id IN :userIdSet 
                                                     ];
            
           
            if(salesChampionData != null && salesChampionData.size() > 0){
                 System.assertEquals(salesChampionList.size(), salesChampionData.size());
                
                 
                //Update isActive of User
                userObj.isActive = false;
                Test.startTest();
                System.runAs(new User(Id=UserInfo.getUserId())) {   
                    update userObj;
                    
                }
                Test.stopTest();
                Set<Id> terminatedUserIdSet = new Set<Id>(); 
                terminatedUserIdSet.add(userObj.Id);
                //Fetch the Champion records again. It should be 0
                Sales_Champion__c [] deletedSalesChampionData = [SELECT Id, Name FROM Sales_Champion__c
                                                                 WHERE Sales_Champion__r.Id IN :terminatedUserIdSet 
                                                                ];
                System.debug('deletedSalesChampionData:'+deletedSalesChampionData.size());
                
                System.assertEquals(0, deletedSalesChampionData.size());
            }    
        }
     
    
    }
    
    static testMethod void testUpdateUserDetails() {
        //Activate Trigger
        setNomuraTriggerActivation();
        
        
        Test.startTest();
        
        //Insert User Record
        Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        
        User userObj = new User();
        userObj.Login_ID__c = 'testdummy';
        userObj.Alias = 'testdum';
        userObj.LastName = 'TestDummyLN';
        userObj.Email = 'TestDummy@testOrg.com';
        userObj.UserName = 'TestDummy@testOrg.com';
        userObj.ProfileId = profileNomuraSales.Id;
        userObj.EmailEncodingKey = 'UTF-8';
        userObj.LanguageLocaleKey = 'en_US';
        userObj.LocaleSidKey = 'en_US';
        userObj.TimeZoneSidKey = 'Asia/Kolkata';
        userObj.Region__c = 'Americas';
        userObj.IsActive = TRUE;
        
        System.runAs(new User(Id=UserInfo.getUserId())) {        
            insert userObj;
        }
        
        //Fetching Inserted User
        User insertedUserObj = [SELECT Id, Login_ID__c, LanguageLocaleKey, User_Language__c, TimeZoneSidKey, Timezone_Offset__c FROM User 
                                WHERE Login_Id__c = 'testdummy' AND IsActive = TRUE LIMIT 1];
        
        if(insertedUserObj != null){
             //Check whether User Language is set to English
            System.assertEquals('English', insertedUserObj.User_Language__c);
			
			//Check whether Timezone_Offset__c is set to 5.5
            System.assertEquals(5.5, insertedUserObj.Timezone_Offset__c);
        }
        
        //Updating Language to Japanese
        insertedUserObj.LanguageLocaleKey = 'ja';
		
		//Updating Timezone to Kathmandu
        insertedUserObj.TimeZoneSidKey = 'Asia/Kathmandu';
        
        System.runAs(new User(Id=UserInfo.getUserId())) {        
            update insertedUserObj;
        } 
        
        //Fetching Updated User
        User updatedUserObj = [SELECT Id, Login_ID__c, LanguageLocaleKey, User_Language__c, Timezone_Offset__c FROM User 
                               WHERE Login_Id__c = 'testdummy' AND IsActive = TRUE LIMIT 1];
        
        if(updatedUserObj != null){
            //Check whether User Language is set to Japanese
            System.assertEquals('Japanese', updatedUserObj.User_Language__c);
            
            //Check whether Timezone_Offset__c is set to 5.75
            System.assertEquals(5.75, updatedUserObj.Timezone_Offset__c);
        }
        
        Test.stopTest();
    }
    
    
    static testMethod void testUserNameChangeOnDeactivation (){
        Integer numOfTestUsers = 2;  
        List<User> users = UtilityTesting.CreateUsersWithManager(numOfTestUsers);
        
        Test.startTest();
        
        User userObj = users[1];
        String userObjId = userObj.Id;
        //String newUserNameToBe = userObj.UserName + userObj.Login_ID__c;
        String newUsernameToBe = userObj.Username;
        System.debug('****newUsernameToBe:'+newUsernameToBe);
        //Deactivate the User
        userObj.IsActive = false;
        try {
            update userObj;
        }
        catch(DMLException ex){
            System.debug('****EXCEPTION OCCURRED WHILE DEACTIVATING:'+ex.getMessage());
        }
        
        Test.stopTest();
        
        
        User deactivatedUserObj = [SELECT Id, Login_Id__c, username, IsActive FROM User 
                                   WHERE Id = :userObjId LIMIT 1];
        System.assertEquals(TRUE, deactivatedUserObj.Username.containsIgnoreCase(newUsernameToBe));
         
         
    }
    
    static testMethod void testComputeManagerIdBeforeInsert() {
        // set up two users to be managers, with unique Login_IDs
        List<User> managerList = UtilityTesting.CreateUsersWithProfile(2, 'Nomura - Sales');
        User manager1 = managerList.get(0);
        manager1.Login_ID__c = 'manager1login';
        User manager2 = managerList.get(1);
        manager2.Login_ID__c = 'manager2login';
        update managerList;
        System.debug('isrt mgrList: ' + managerList);

        List<User> userList = new List<User>();
        //Create User1 setting managerId == manager1.Id
        User userObj1 = new User();
        userObj1.Login_ID__c = 'User1Log';
        userObj1.Alias = 'User1';
        userObj1.LastName = 'User1';
        userObj1.Email = 'User1@testOrg.com';
        userObj1.UserName = 'User1_hack@testOrg.com';
        userObj1.ProfileId = manager1.profileId;
        userObj1.EmailEncodingKey = 'UTF-8';
        userObj1.LanguageLocaleKey = 'en_US';
        userObj1.LocaleSidKey = 'en_US';
        userObj1.TimeZoneSidKey = 'America/Los_Angeles';
        userObj1.Region__c = 'Americas';
        userObj1.managerId = manager1.Id;
        userList.add(userObj1);
        // Create User2 setting managerCode == manager1.Login_ID__c
        User userObj2 = new User();
        userObj2.Login_ID__c = 'User2Log';
        userObj2.Alias = 'User2';
        userObj2.LastName = 'User2';
        userObj2.Email = 'User2@testOrg.com';
        userObj2.UserName = 'User2_hack@testOrg.com';
        userObj2.ProfileId = manager1.profileId;
        userObj2.EmailEncodingKey = 'UTF-8';
        userObj2.LanguageLocaleKey = 'en_US';
        userObj2.LocaleSidKey = 'en_US';
        userObj2.TimeZoneSidKey = 'America/Los_Angeles';
        userObj2.Region__c = 'Americas';
        userObj2.managerCode__c = manager1.Login_ID__c;
        userList.add(userObj2);
        // Create User3 setting managerId == manager2.Id and managerCode == manager2.Login_ID__c
        User userObj3 = new User();
        userObj3.Login_ID__c = 'User3Log';
        userObj3.Alias = 'User3';
        userObj3.LastName = 'User3';
        userObj3.Email = 'User3@testOrg.com';
        userObj3.UserName = 'User3_hack@testOrg.com';
        userObj3.ProfileId = manager2.profileId;
        userObj3.EmailEncodingKey = 'UTF-8';
        userObj3.LanguageLocaleKey = 'en_US';
        userObj3.LocaleSidKey = 'en_US';
        userObj3.TimeZoneSidKey = 'America/Los_Angeles';
        userObj3.Region__c = 'Americas';
        userObj3.managerId = manager2.Id;
        userObj3.managerCode__c = manager2.Login_ID__c;
        userList.add(userObj3);

        Test.startTest();
        insert userList;
        Test.stopTest();

        List<User> results = [SELECT Id, Alias, ManagerId, ManagerCode__c FROM User WHERE Id IN (:userObj1.Id, :userObj2.Id, :userObj3.Id) ];
        System.assert(results.size() == 3);
        for(User u : results) {
            System.debug('isrt id='+u.Id+' alias='+u.alias+' managerId='+u.ManagerId+' managerCode='+u.ManagerCode__c);
            if(u.Id == userObj1.Id || u.Id == userObj2.Id) {
                System.assertEquals(u.managerId, manager1.Id);
                System.assertEquals(u.managerCode__c, manager1.Login_ID__c);
            } else if(u.Id == userObj3.Id) {
                System.assertEquals(u.managerId, manager2.Id);
                System.assertEquals(u.managerCode__c, manager2.Login_ID__c);
            } else {
                System.assert(false);
            }
        }
    }

    static testMethod void testComputeManagerIdBeforeUpdate() {
        // set up three users to be managers, with unique Login_IDs
        List<User> managerList = UtilityTesting.CreateUsersWithProfile(3, 'Nomura - Sales');
        User manager1 = managerList.get(0);
        manager1.Login_ID__c = 'manager1login';
        User manager2 = managerList.get(1);
        manager2.Login_ID__c = 'manager2login';
        User manager3 = managerList.get(2);
        manager3.Login_ID__c = 'manager3login';
        update managerList;
        System.debug('updt mgrList: ' + managerList);

        List<User> userList = new List<User>();
        // Create User1 setting managerId == manager1.Id and managerCode == manager1.Login_ID
        User userObj1 = new User();
        userObj1.Login_ID__c = 'User1Log';
        userObj1.Alias = 'User1';
        userObj1.LastName = 'User1';
        userObj1.Email = 'User1@testOrg.com';
        userObj1.UserName = 'User1_hack@testOrg.com';
        userObj1.ProfileId = manager1.profileId;
        userObj1.EmailEncodingKey = 'UTF-8';
        userObj1.LanguageLocaleKey = 'en_US';
        userObj1.LocaleSidKey = 'en_US';
        userObj1.TimeZoneSidKey = 'America/Los_Angeles';
        userObj1.Region__c = 'Americas';
        userObj1.managerId = manager1.Id;
        userObj1.ManagerCode__c = manager1.Login_ID__c;
        userList.add(userObj1);
        // Create User2 setting managerId == manager1.Id and managerCode == manager1.Login_ID__c
        User userObj2 = new User();
        userObj2.Login_ID__c = 'User2Log';
        userObj2.Alias = 'User2';
        userObj2.LastName = 'User2';
        userObj2.Email = 'User2@testOrg.com';
        userObj2.UserName = 'User2_hack@testOrg.com';
        userObj2.ProfileId = manager1.profileId;
        userObj2.EmailEncodingKey = 'UTF-8';
        userObj2.LanguageLocaleKey = 'en_US';
        userObj2.LocaleSidKey = 'en_US';
        userObj2.TimeZoneSidKey = 'America/Los_Angeles';
        userObj2.Region__c = 'Americas';
        userObj2.ManagerId = manager1.Id;
        userObj2.managerCode__c = manager1.Login_ID__c;
        userList.add(userObj2);
        // Create User3 setting managerId == manager1.Id and managerCode == manager2.Login_ID__c
        User userObj3 = new User();
        userObj3.Login_ID__c = 'User3Log';
        userObj3.Alias = 'User3';
        userObj3.LastName = 'User3';
        userObj3.Email = 'User3@testOrg.com';
        userObj3.UserName = 'User3_hack@testOrg.com';
        userObj3.ProfileId = manager2.profileId;
        userObj3.EmailEncodingKey = 'UTF-8';
        userObj3.LanguageLocaleKey = 'en_US';
        userObj3.LocaleSidKey = 'en_US';
        userObj3.TimeZoneSidKey = 'America/Los_Angeles';
        userObj3.Region__c = 'Americas';
        userObj3.managerId = manager1.Id;
        userObj3.managerCode__c = manager2.Login_ID__c;
        userList.add(userObj3);

        insert userList;

        Test.startTest();
        // override user1 to manager3 -- the managerCode shouldn't change
        userObj1.managerId = manager3.Id;
        // user2 ldap manager change to manager3 == the managerId should be changed to manager3.Id
        userObj2.ManagerCode__c = manager3.Login_ID__c;
        // user3 ldap manager change to manager3 -- the (overridden) managerId shouldn't change
        userObj3.ManagerCode__c = manager3.Login_ID__c;

        update userList;
        Test.stopTest();

        List<User> results = [SELECT Id, Alias, ManagerId, ManagerCode__c FROM User WHERE Id IN (:userObj1.Id, :userObj2.Id, :userObj3.Id) ];
        System.assert(results.size() == 3);
        for(User u : results) {
            System.debug('updt id='+u.Id+' alias='+u.alias+' managerId='+u.ManagerId+' managerCode='+u.ManagerCode__c);
            if(u.Id == userObj1.Id) {
                System.assertEquals(u.managerId, manager3.Id);
                System.assertEquals(u.managerCode__c, manager1.Login_ID__c);
            } else if(u.Id == userObj2.Id) {
                System.assertEquals(u.managerId, manager3.Id);
                System.assertEquals(u.managerCode__c, manager3.Login_ID__c);
            } else if(u.Id == userObj3.Id) {
                System.assertEquals(u.managerId, manager1.Id);
                System.assertEquals(u.managerCode__c, manager3.Login_ID__c);
            } else {
                System.assert(false);
            }
        }
    }
    
    static testMethod void testHandleForUserToRevenueStatsGroup(){
        //Activate Trigger
        setNomuraTriggerActivation();
        
        User sfAdminUserObj = [SELECT Id, Name FROm User WHERE Login_Id__c = 'sfadmin' LIMIT 1];
        
        if(sfAdminUserObj != null){
            System.runAs(sfAdminUserObj) {
                Test.startTest();
                
                //Insert User Record
                Profile profileNomuraResearch = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Research' LIMIT 1];
                
                User userObj = new User();
                userObj.Login_ID__c = 'testdummy';
                userObj.Alias = 'testdum';
                userObj.LastName = 'TestDummyLN';
                userObj.Email = 'TestDummy@testOrg.com';
                userObj.UserName = 'TestDummy@testOrg.com';
                userObj.ProfileId = profileNomuraResearch.Id;
                userObj.EmailEncodingKey = 'UTF-8';
                userObj.LanguageLocaleKey = 'en_US';
                userObj.LocaleSidKey = 'en_US';
                userObj.TimeZoneSidKey = 'America/Los_Angeles';
                userObj.Region__c = 'Americas';
                userObj.IsActive = TRUE;
                userObj.View_Research_Statistics__c = TRUE;
                
                insert userObj;
                
                //Fetch Group
                Group groupObj = [SELECT Id, Name, DeveloperName FROM Group WHERE Name = 'Research_View_Revenue_Statistics' LIMIT 1];
                
                if(groupObj != null){
                     //Fetch Group Member Record
                     List<GroupMember> memberList = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember
                                                     WHERE GroupId = :groupObj.Id AND
                                                     UserOrGroupId = :userObj.Id];
                    
                    if(memberList != null){
                        //Check whether entry is present in GroupMember Obj
                        System.assertEquals(1, memberList.size());
                    }
                }
                
                //Update User - Uncheck View_Research_Statistics__c
                userObj.View_Research_Statistics__c = FALSE;
                
                update userObj;
                
                //Fetch Group Member Record
                List<GroupMember> memberListAfterUpdate = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember
                                                WHERE GroupId = :groupObj.Id AND
                                                UserOrGroupId = :userObj.Id];
                
                System.assert(memberListAfterUpdate == null || (memberListAfterUpdate != null && memberListAfterUpdate.size() == 0));
                
                Test.stopTest();
            }
        }
    }
    //getUserDetailsByUserFedId
    
    @isTest
    static void testGetUserDetailsByUserFedId() {
        User salesUser = UtilityTesting.createUsersWithProfile(1, 'Nomura - Sales')[0];
        salesUser.FederationIdentifier = 'FEDID1235';
        update salesUser;
        
        Test.startTest();
        Map<String, String> fedIdToUserId = UserHelper.getUserDetailsByUserFedId(new Set<String> {salesUser.FederationIdentifier});
        Test.stopTest();
        
        System.assertEquals(true, fedIdToUserId.containsKey(salesUser.FederationIdentifier));
        System.assertEquals(salesUser.Id, fedIdToUserId.get(salesUser.FederationIdentifier));
    }
   
    @isTest
    static void testSetupSCHApprQueueDataStructure() {
        Test.startTest();
        Map<String, Set<String>> schApprUserIdSetBySchApprQueueIdMap = UserHelper.SCHApprUserIdSetBySCHApprQueueIdMap;
        Test.stopTest();
        
        System.assertEquals(false, schApprUserIdSetBySchApprQueueIdMap.isEmpty());
    }
   
    @isTest
    static void testIsCurrentSchApprover() {
        User salesUser = UtilityTesting.createUsersWithProfile(1, 'Nomura - Sales')[0];
        salesUser.IsActive = true;
        salesUser.Region__c = 'AEJ';
        salesUser.UserRoleId = [SELECT Id, Name FROM UserRole WHERE Name LIKE 'AEJ - EQ%' LIMIT 1].Id;
        salesUser.AdditionalPermissions__c = 'SCH Approver Regional';
        update salesUser;
        
        Test.startTest();
        Boolean isCurrentSchApprover = false;
        System.runAs(salesUser){
            isCurrentSchApprover = UserHelper.isCurrentSchApprover;
        }
        Test.stopTest();
        System.assertEquals(true, isCurrentSchApprover);
    }
    
    @isTest
    static void testIsCurrentPreOnboardingApprover() {
        User salesUser = UtilityTesting.createUsersWithProfile(1, 'Nomura - Sales')[0];
        salesUser.Region__c = 'AEJ';
        salesUser.IsActive = true;
        salesUser.FederationIdentifier = salesUser.Id;
        salesUser.UserRoleId = [SELECT Id, Name FROM UserRole WHERE Name LIKE 'AEJ - EQ%' LIMIT 1].Id;
        salesUser.AdditionalPermissions__c = 'SALES CAO FI Regional';
        update salesUser;
        
        Test.startTest();
        Boolean isCurrentPreOnboardingApprover = false;
        System.runAs(salesUser){
             isCurrentPreOnboardingApprover = UserHelper.isCurrentPreOnboardingApprover;
        }
        Test.stopTest();
        System.assertEquals(true, isCurrentPreOnboardingApprover);
    }
    
    @isTest
    static void testGetUserDetailsAndPermissionMap() {
        Set<UserHelper.USER_DETAILS_AND_PERMISSIONS> detailsAndPermissionSet = new Set<UserHelper.USER_DETAILS_AND_PERMISSIONS> {
            	UserHelper.USER_DETAILS_AND_PERMISSIONS.IS_ROLE_BASED_REGION_EMEA, 
                UserHelper.USER_DETAILS_AND_PERMISSIONS.IS_ROLE_BASED_REGION_AMERICAS, 
                UserHelper.USER_DETAILS_AND_PERMISSIONS.IS_ROLE_BASED_REGION_AEJ, 
                UserHelper.USER_DETAILS_AND_PERMISSIONS.IS_ROLE_BASED_REGION_JAPAN,
                UserHelper.USER_DETAILS_AND_PERMISSIONS.IS_SCH_APPROVER_REG,
                UserHelper.USER_DETAILS_AND_PERMISSIONS.IS_SCH_APPROVER_GBL,
                UserHelper.USER_DETAILS_AND_PERMISSIONS.IS_SALES_CAO_FI_REG
        };
        Test.startTest();
        User salesUser = UtilityTesting.createUsersWithProfile(1, 'Nomura - Sales')[0];
        salesUser.Region__c = 'AEJ';
        salesUser.IsActive = true;
        salesUser.FederationIdentifier = salesUser.Id;
        salesUser.UserRoleId = [SELECT Id, Name FROM UserRole WHERE Name LIKE 'AEJ - EQ%' LIMIT 1].Id;
        salesUser.AdditionalPermissions__c = 'SALES CAO EQ Global';
        update salesUser;
        
        Map<UserHelper.USER_DETAILS_AND_PERMISSIONS, Set<String>> UserIdSetByDetAndPermEnum = UserHelper.getUserDetailsAndPermissionMap(detailsAndPermissionSet, new Set<String> {salesUser.Id});
        Test.stopTest();
		
        System.assertEquals(true,UserIdSetByDetAndPermEnum.containsKey(UserHelper.USER_DETAILS_AND_PERMISSIONS.IS_ROLE_BASED_REGION_AEJ));
    }
    
    @isTest 
    static void testCheckAndConfigureSalesCAOsApprovalQueues() {
        Test.startTest();
        User salesUser = UtilityTesting.createUsersWithProfile(1, 'Nomura - Sales')[0];
        salesUser.Region__c = 'AEJ';
        salesUser.IsActive = true;
        salesUser.FederationIdentifier = salesUser.Id;
        salesUser.UserRoleId = [SELECT Id, Name FROM UserRole WHERE Name LIKE 'AEJ - EQ%' LIMIT 1].Id;
        salesUser.AdditionalPermissions__c = 'SALES CAO EQ Global';
        update salesUser;
        Test.stopTest();
        
        List<GroupMember> registeredQueue = [SELECT Group.Name FROM GroupMember WHERE UserOrGroupId = :salesUser.Id];
        System.assertEquals(false, registeredQueue.isEmpty());
    }
    
    @isTest 
    static void testRemoveFromSalesCAOsApprovalQueues() {
        User salesUser = UtilityTesting.createUsersWithProfile(1, 'Nomura - Sales')[0];
        salesUser.Region__c = 'AEJ';
        salesUser.IsActive = true;
        salesUser.FederationIdentifier = salesUser.Id;
        salesUser.UserRoleId = [SELECT Id, Name FROM UserRole WHERE Name LIKE 'AEJ - EQ%' LIMIT 1].Id;
        salesUser.AdditionalPermissions__c = 'SALES CAO EQ Global';
        update salesUser;
        
        List<GroupMember> registeredQueue = [SELECT Group.Name FROM GroupMember WHERE UserOrGroupId = :salesUser.Id];
        System.assertEquals(false, registeredQueue.isEmpty());
        
        Test.startTest();
        salesUser.AdditionalPermissions__c = null;
        update salesUser;
        Test.stopTest();
        
        List<GroupMember> registeredQueueUpdate = [SELECT Group.Name FROM GroupMember WHERE UserOrGroupId = :salesUser.Id];
        System.assertEquals(true, registeredQueueUpdate.isEmpty());
    }
    
    @isTest
    static void testCheckAndConfigureDeskHeadApprovals() {
        Test.startTest();
        User salesUser = UtilityTesting.createUsersWithProfile(1, 'Nomura - Sales')[0];
        salesUser.Region__c = 'AEJ';
        salesUser.IsActive = true;
        salesUser.FederationIdentifier = salesUser.Id;
        salesUser.AdditionalPermissions__c = 'Desk Head Approver';
        update salesUser;
        Test.stopTest();
        
        System.assertEquals(System.Label.PreOnb_Desk_Head_Approver_Public_Group_DeveloperName, 
                            [SELECT Group.Name FROM GroupMember WHERE UserOrGroupId = :salesUser.Id LIMIT 1].Group.Name);
    }
    
    @isTest
    static void testRemoveDeskHeadApprovals() {
        User salesUser = UtilityTesting.createUsersWithProfile(1, 'Nomura - Sales')[0];
        salesUser.Region__c = 'AEJ';
        salesUser.IsActive = true;
        salesUser.FederationIdentifier = salesUser.Id;
        salesUser.AdditionalPermissions__c = 'Desk Head Approver';
        update salesUser;
        
        Test.startTest();
        salesUser.AdditionalPermissions__c = null;
        update salesUser;
        Test.stopTest();
        
        System.assertEquals(0, [SELECT COUNT() FROM GroupMember WHERE UserOrGroupId = :salesUser.Id AND 
                                Group.Name = :System.Label.PreOnb_Desk_Head_Approver_Public_Group_DeveloperName]);
    }
    
    @isTest
    static void testCheckAndConfigureSchApprovalQueues() {
        User sfAdminUserObj = [SELECT Id, Name FROm User WHERE Login_Id__c = 'sfadmin' LIMIT 1];
        User salesUser = null;
        System.runAs(new User(Id=UserInfo.getUserId())) {        
            salesUser = UtilityTesting.createUsersWithProfile(1, 'Nomura - Sales')[0];
        }
        
        
        List<GroupMember> registeredQueueBefore = [SELECT Group.Name FROM GroupMember WHERE UserOrGroupId = :salesUser.Id];
        System.assertEquals(true, registeredQueueBefore.isEmpty());
        
        
        salesUser.Region__c = 'AEJ';
        salesUser.IsActive = true;
        salesUser.FederationIdentifier = salesUser.Id;
        salesUser.AdditionalPermissions__c = 'SCH Approver Regional';
        salesUser.UserRoleId = [SELECT Id, Name FROM UserRole WHERE Name LIKE 'AEJ - EQ%' LIMIT 1].Id;
        
        Test.startTest();
        System.runAs(sfAdminUserObj) {        
            //salesUser = UtilityTesting.createUsersWithProfile(1, 'Nomura - Sales')[0];
            update salesUser;
            
            List<GroupMember> registeredQueues = [SELECT Group.DeveloperName, Group.Name FROM GroupMember WHERE UserOrGroupId = :salesUser.Id];
        System.assertEquals(false, registeredQueues.isEmpty());
        
        List<String> queueNames = new List<String>();
        for (GroupMember member : registeredQueues) {
            queueNames.add(member.Group.DeveloperName);
        }
        System.assertEquals(true, queueNames.contains('SCH_Approver_AEJ_Queue'));
        }
       
        
         Test.stopTest();
    }

    
    static testMethod void testGetProfileAndPermissionSetsForUser() {
    	System.debug('#### testGetProfileAndPermissionSetsForUser()');

    	Profile p  = [SELECT Id From Profile WHERE Name='System Administrator' limit 1];
		// insert user test
		User testUser = new User();
		testUser.Alias = 'newUser';
		testUser.UserName = 'unit.test@nomura.com';
        testUser.Email ='unit.test@nomura.com';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.LastName = 'Testing1';
        testUser.LanguageLocaleKey='en_US';
        testUser.LocaleSidKey='en_US';
        testUser.ProfileId=p.Id;
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.SingletrackMIFIDII_ResearchAdmin__c = true;
        insert testUser;

		String currentUserId;
		Map<String, String> UserProfileNameByUserIdMap = new Map<String, String>(); 
   		Map<String, Set<String>> PSNameSetByUserIdMap = new Map<String, Set<String>>();

        Test.startTest();
        System.runAs(testUser) {
        	currentUserId = UserInfo.getUserId();
			UserHelper.getProfileAndPermissionSetsForUser(new List<String>{currentUserId}, UserProfileNameByUserIdMap, PSNameSetByUserIdMap);        	
        }
        Test.stopTest();				
		System.debug('UserProfileNameByUserIdMap : '+UserProfileNameByUserIdMap);
		System.debug('PSNameSetByUserIdMap : '+PSNameSetByUserIdMap);
		System.assertEquals(UserProfileNameByUserIdMap.get(testUser.Id), 'System Administrator');
		System.assertEquals(PSNameSetByUserIdMap.get(testUser.Id).contains('Singletrack_Administrator'), true);
		
    }
    
     private static void setNomuraTriggerActivation(){
        //Nomura_Trigger_Activation__c
        Nomura_Trigger_Activation__c userTriggerActivation = new Nomura_Trigger_Activation__c();
        userTriggerActivation.Name = 'UserTrigger';
        userTriggerActivation.Object__c = 'User';
        userTriggerActivation.Active__c = TRUE;
        insert userTriggerActivation;
    }

}