@IsTest
public class AccountRevenueDashboardControllerTest {

    @isTest
    static void testGetProfileName() {
        User u = createUser(null);
        Test.startTest();
        System.runAs(u) {
            String profileName = AccountRevenueDashboardController.getUserProfileName();
            System.assertEquals(profileName, 'System Administrator');
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