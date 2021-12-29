@isTest
private class PopulateAnalyticUserDefaultBatchTest {
    
    @isTest public static void TestCreateUserDefaults() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
			//set the last run time for job
            String configName = 'testConfig';
            String paramName = 'testParam';
        	AnalyticsUserDefaultHelper.saveLastRunDate(DateTime.now(),configName,paramName);
            
            //create a role and user
            String roleName = 'TEST - EQ Sales - TESTTEST';
            String devName = 'TEST_EQ_Sales_TESTTEST';
            createRole(roleName,devName);
            User u = createUser(roleName);
            Id userId = u.id;
            
            Test.startTest();
            //fire the batch
            Database.executeBatch(new PopulateAnalyticUserDefaultBatch(configName, paramName),200);
            Test.stopTest();
            List<Analytics_User_Default__c> defList = [SELECT id, Accounting_Filter__c, Currency_Filter__c, Regional_Client_Scorecard_Rev_2_Group__c, ClientScorecardConfig__c, Default_Revenue_Dashboard__c,User__c from Analytics_User_Default__c where User__c=:userId];
            if (defList.size()>0) {
                Analytics_User_Default__c def = defList.get(0);
                System.assert(null != def);
                System.assert(null != def.Accounting_Filter__c);
                System.assert(null != def.Currency_Filter__c);
                System.assert(null != def.Default_Revenue_Dashboard__c);
                System.assert(null != def.Regional_Client_Scorecard_Rev_2_Group__c);
                System.assert(null != def.ClientScorecardConfig__c);
            }
        }
        
    }
    
    @isTest public static void TestEditUserDefaults() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
			//set the last run time for job
            String configName = 'testConfig';
            String paramName = 'testParam';
        	AnalyticsUserDefaultHelper.saveLastRunDate(DateTime.now(),configName,paramName);
            
            //create a role and user
            String roleName = 'TEST - EQ Sales - TESTTEST';
            String devName = 'TEST_EQ_Sales_TESTTEST';
            createRole(roleName,devName);
            User u = createUser(roleName);
            Id userId = u.id;
            Analytics_User_Default__c defaultValue = new Analytics_User_Default__c();
            defaultValue.User__c = userId;
            insert defaultValue;
            
            Test.startTest();
            //fire the batch
            Database.executeBatch(new PopulateAnalyticUserDefaultBatch(configName, paramName),200);
            Test.stopTest();
            List<Analytics_User_Default__c> defList = [SELECT id, Accounting_Filter__c, Currency_Filter__c, Regional_Client_Scorecard_Rev_2_Group__c, ClientScorecardConfig__c, Default_Revenue_Dashboard__c, User__c from Analytics_User_Default__c where User__c=:userId];
            Analytics_User_Default__c def = defList.get(0);
            System.assert(null != def);
            System.assert(null != def.Accounting_Filter__c);
            System.assert(null != def.Currency_Filter__c);
            System.assert(null != def.Default_Revenue_Dashboard__c);
            System.assert(null != def.Regional_Client_Scorecard_Rev_2_Group__c);
            System.assert(null != def.ClientScorecardConfig__c);
        }
        
        
    }
    
    @isTest public static void TestPartiallyEditedUserDefaults() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
			//set the last run time for job
            String configName = 'testConfig';
            String paramName = 'testParam';
        	AnalyticsUserDefaultHelper.saveLastRunDate(DateTime.now(),configName,paramName);
            
            //create a role and user
            String roleName = 'TEST - EQ Sales - TESTTEST';
            String devName = 'TEST_EQ_Sales_TESTTEST';
            createRole(roleName,devName);
            User u = createUser(roleName);
            Id userId = u.id;
            Analytics_User_Default__c defaultValue = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(u);
            defaultValue.User__c = userId;
            defaultValue.Accounting_Filter__c = null;
            defaultValue.Currency_Filter__c = null;
            defaultValue.Default_Revenue_Dashboard__c = null;
            defaultValue.ClientScorecardConfig__c = null;
            insert defaultValue;
            
            Test.startTest();
            //fire the batch
            Database.executeBatch(new PopulateAnalyticUserDefaultBatch(configName, paramName),200);
            Test.stopTest();
            List<Analytics_User_Default__c> defList = [SELECT id, Accounting_Filter__c, Currency_Filter__c, Regional_Client_Scorecard_Rev_2_Group__c, ClientScorecardConfig__c, Default_Revenue_Dashboard__c, User__c from Analytics_User_Default__c where User__c=:userId];
            Analytics_User_Default__c def = defList.get(0);
            System.assert(null != def);
            System.assert(null != def.Accounting_Filter__c);
            System.assert(null != def.Currency_Filter__c);
            System.assert(null != def.Default_Revenue_Dashboard__c);
            System.assert(null != def.Regional_Client_Scorecard_Rev_2_Group__c);
            System.assert(null != def.ClientScorecardConfig__c);
        }
        
    }
    
    @isTest public static void TestFullyPopulated() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
			//set the last run time for job
            String configName = 'testConfig';
            String paramName = 'testParam';
        	AnalyticsUserDefaultHelper.saveLastRunDate(DateTime.now(),configName,paramName);
            
            //create a role and user
            String roleName = 'TEST - EQ Sales - TESTTEST';
            String devName = 'TEST_EQ_Sales_TESTTEST';
            createRole(roleName,devName);
            User u = createUser(roleName);
            Id userId = u.id;
            Analytics_User_Default__c defaultValue = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(u);
            defaultValue.User__c = userId;
            insert defaultValue;
            
            Test.startTest();
            //fire the batch
            Database.executeBatch(new PopulateAnalyticUserDefaultBatch(configName, paramName),200);
            Test.stopTest();
            List<Analytics_User_Default__c> defList = [SELECT id, Accounting_Filter__c, Currency_Filter__c, Regional_Client_Scorecard_Rev_2_Group__c, ClientScorecardConfig__c, Default_Revenue_Dashboard__c,User__c from Analytics_User_Default__c where User__c=:userId];
            Analytics_User_Default__c def = defList.get(0);
            System.assert(null != def);
            System.assert(null != def.Accounting_Filter__c);
            System.assert(null != def.Currency_Filter__c);
            System.assert(null != def.Default_Revenue_Dashboard__c);
            System.assert(null != def.Regional_Client_Scorecard_Rev_2_Group__c);
            System.assert(null != def.ClientScorecardConfig__c);
        }
        
    }
    
    private static void createRole(String roleName, String devName) {
        UserRole r = new UserRole(DeveloperName=devName, Name=roleName);
        List<UserRole> roles = new List<UserRole>();
        roles.add(r);
        Database.insert(roles);
    }
    @isTest static void testSchedule(){
        AnalyticsUserDefaultHelper.saveLastRunDate(DateTime.now(),null,null);
		String sched_exp = '0 0 1 1 4 ?';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
			//set the last run time for job
        
			Test.startTest();
	    	String jobId = system.schedule('Analtyics User Default Scheduled Job', sched_exp, new PopAnalyticUsrDefBatchScheduler());
	    	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
   	    	System.assertEquals(sched_exp,ct.CronExpression);
	    	Test.stopTest();
        }
   }
    
    private static User createUser(String roleName) {
        Profile p  = [SELECT Id From Profile WHERE Name='System Administrator' limit 1];
        UserRole role = null;
        if (null != roleName) {
            role = [SELECT id from UserRole Where Name=: roleName LIMIT 1];
        }
        User kpiOwner = new User( Alias = 'testtest',
                                 Email ='newUserKPIOwner@testorg.com',
                                 EmailEncodingKey = 'UTF-8',
                                 LastName = 'newUserKPIOwner',
                                 LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', 
                                 UserName='newUserKPIOwner@testorg.com',
                                 ProfileId=p.Id,
                                 TimeZoneSidKey = 'America/Los_Angeles',
                                 Region__c='Americas'
                                );
        if (null != role) {
            kpiOwner.UserRoleId = role.Id;
        }
        kpiOwner.IsActive = True;
        insert kpiOwner;
        System.debug('Init. owner id ' + kpiOwner.Id);
        return kpiOwner;
    }
    
}