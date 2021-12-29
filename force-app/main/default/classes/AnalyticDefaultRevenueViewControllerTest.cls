@IsTest
private class AnalyticDefaultRevenueViewControllerTest {
    @IsTest
    public static void testController() {
        String roleName = 'TEST - FI - Sales - TESTTEST';
        String devName = 'TEST_FI_Sales_TESTTEST';
        
        createRole(roleName,devName);
        User u = createUser(roleName);
        Analytics_User_Default__c def = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(roleName, 'Japan');
        def.user__c = u.id;
        Test.startTest();
        System.runAs(u) {
            saveDefault(def);
            AnalyticsDefaultRevenueViewController theController = new AnalyticsDefaultRevenueViewController();
            String dash = theController.getDashboard();
            System.debug('Found dash '+ dash);
            System.assertEquals(AnalyticsUserDefaultHelper.defaultDashboard, dash);
        }
        
    }

    private static void saveDefault(Analytics_User_Default__c def) {
        insert def;
    }
    private static void updateDefault(Analytics_User_Default__c def) {
        update def;
    }
    private static void createRole(String roleName, String devName) {
        UserRole r = new UserRole(DeveloperName=devName, Name=roleName);
        List<UserRole> roles = new List<UserRole>();
        roles.add(r);
        Database.insert(roles);
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
                                 TimeZoneSidKey = 'America/Los_Angeles'
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