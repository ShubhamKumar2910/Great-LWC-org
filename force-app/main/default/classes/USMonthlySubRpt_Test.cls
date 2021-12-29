@isTest(SeeAllData=true)
public class USMonthlySubRpt_Test {
    static testmethod void test(){        
        string RoleName = 'Americas - GM Sales - Region Head';
        Test.startTest();
        //US_Monthly_Subscription_Report sbclass = new US_Monthly_Subscription_Report(RoleName);
        //Database.executeBatch(sbclass);
        Test.stopTest();
    }
}