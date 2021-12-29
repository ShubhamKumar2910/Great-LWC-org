@isTest
private class BatchUpdatingCampaignOwnerRolesTest {
    static Campaign camp1;
    static Campaign camp2;
    static User user1;
    static User user2;
    
    private static String testCampName1 = 'Test Code Campaign-Updated';
    private static String testCampName2 = 'Test Code Campaign-NotUpdated';
    private static String testRoleName1 = 'Technology';
    private static String testRoleName2 = 'Japan - EQ - Research Teams';
    private static String testUserName1 = 'Test Code User First Name(Technology)';
    private static String testUserName2 = 'Test Code User First Name(Research)';
    
    static void init(){
    }
    
    static void loadTestData(){
        camp1 = [SELECT Id, Name, Owner.UserRole.Name, Campaign_Owner_Role__c, LastModifiedDate FROM Campaign WHERE Name = :testCampName1 LIMIT 1];
        camp2 = [SELECT Id, Name, Owner.UserRole.Name, Campaign_Owner_Role__c, LastModifiedDate FROM Campaign WHERE Name = :testCampName2 LIMIT 1];
        user1 = [SELECT Id, UserRole.Name FROM User WHERE FirstName = :testUserName1 LIMIT 1];
        user2 = [SELECT Id, UserRole.Name FROM User WHERE FirstName = :testUserName2 LIMIT 1];
    }
    
    @testSetup
    static void setupTestData(){
        /* Test user roles : Technology and Japan - EQ - Research Teams */
        UserRole r1 = [SELECT Id, Name FROM UserRole WHERE Name = :testRoleName1];
        UserRole r2 = [SELECT Id, Name FROM UserRole WHERE Name = :testRoleName2];
        
        /* Test users : 2 Technology users and 1 Japan - EQ - Research Teams user */
        User user = [SELECT Id, FirstName, LastName, UserRoleId FROM User WHERE Id=:UserInfo.getUserId()];
        user.FirstName = testUserName1;
        user.LastName = 'UserLastName';
        user.UserRoleId = r1.Id;
        update user;

        User randomUser = [SELECT Id, FirstName, LastName, UserRoleId FROM User WHERE IsActive = TRUE AND Id !=:user.Id AND Name != null AND Email != null AND Profile.Name='System Administrator' LIMIT 1];
		randomUser.FirstName = testUserName2;
		randomUser.LastName = 'RandomUserLastName';
		randomUser.UserRoleId = r2.Id;
		update randomUser;
        
        /* Test Campaigns 
		Campaign 1 : Campaign_Owner_Role__c = Technology, Actual Owner Role = Technology
		Campaign 2 : Campaign_Owner_Role__c = Technology, Actual Owner Role = Research
		*/
        System.runAs(randomUser){
            RecordType crt = [select Id from RecordType where Name = 'Mass Email' and SobjectType = 'Campaign'];
        	Campaign camp1 = new Campaign(RecordTypeId=crt.Id, Name=testCampName1, OwnerId=user.Id, Campaign_Owner_Role__c =r1.Name);
       		insert camp1;
        	Campaign camp2 = new Campaign(RecordTypeId=crt.Id, Name=testCampName2, OwnerId=randomUser.Id, Campaign_Owner_Role__c =r1.Name);
        	insert camp2;

        }
    }
    
    @isTest
    static void testLoadTestData(){
        loadTestData();
        
        System.assertEquals(testRoleName1, camp1.Campaign_Owner_Role__c);
        System.assertEquals(testRoleName1, camp1.Owner.UserRole.Name);
        System.assertEquals(testRoleName1, camp2.Campaign_Owner_Role__c);
        System.assertEquals(testRoleName2, camp2.Owner.UserRole.Name);
    }

    @isTest
    static void testBatchUpdatingCampaignOwnerRoles(){
        loadTestData();
        Datetime lastModifiedDate1 = camp1.LastModifiedDate;
        Datetime lastModifiedDate2 = camp2.LastModifiedDate;
        
        Id camp1Id = camp1.Id;
        Id camp2Id = camp2.id;
        
        sleep(1000); // Wait 1 sec to make lastModifiedDate different
        
        Test.startTest();
        
        BatchUpdatingCampaignOwnerRoles batch = new BatchUpdatingCampaignOwnerRoles();
        ID batchprocessid = Database.executeBatch(batch);
        
        Test.stopTest();
        
        Campaign camp1After = [SELECT Id, Name, Owner.UserRole.Name, Campaign_Owner_Role__c, LastModifiedDate FROM Campaign WHERE Id = :camp1Id];
        Campaign camp2After = [SELECT Id, Name, Owner.UserRole.Name, Campaign_Owner_Role__c, LastModifiedDate FROM Campaign WHERE Id = :camp2Id];
        
        /* Camp 1 is not updated*/
        System.assertEquals(lastModifiedDate1, camp1After.LastModifiedDate);
        
        /* Camp 2 is updated */
        System.assertEquals(camp2After.Owner.UserRole.Name, camp2After.Campaign_Owner_Role__c);
        System.assertNotEquals(lastModifiedDate2, camp2After.LastModifiedDate);

    }
    
    // Method to wait
    private static void sleep(Long milliSecs){
        Long timeDiff = 0;
        DateTime firstTime = System.now();
        do{
            timeDiff = System.now().getTime() - firstTime.getTime();
        }while(timeDiff <= milliSecs);
    }
	
}