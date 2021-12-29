@isTest
public class AnalyticsAccountControllerExtensionTest {
    @isTest
    public static void testController() {
        String roleName = 'TEST - FI - Sales - TESTTEST';

        User u = createUser(null);
        Analytics_User_Default__c def = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(u);
        def.user__c = u.id;
        saveDefault(def);
        Account acct = makeAccount();
        String testrdm = acct.RDM_Org_ID__c;
        ApexPages.StandardController sc = new ApexPages.StandardController(acct);

        Test.startTest();
        System.runAs(u) {
            
            AnalyticsAccountControllerExtension theController = new AnalyticsAccountControllerExtension(sc);
            String rdm = theController.getRdmOrgId();
            System.assertEquals(testrdm, rdm);
            System.assert(null != theController.getClientScorecard(),'Controller returned null value for client scorecard');
        }
        
    }
    private static Account makeAccount() {
        return TestRevenueKPIDataFactory.createRgAccount('RGNAME');
    }
    private static void saveDefault(Analytics_User_Default__c def) {
        insert def;
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