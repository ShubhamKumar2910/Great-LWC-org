@isTest
public class US_Monthly_Subscription_Report_Test {
   public static testMethod void testClassMethod(){
    
        test.startTest();
      US_Monthly_Subscription_Report subRptclass = new US_Monthly_Subscription_Report('Americas - GM Sales - Region Head');
        database.executeBatch(subRptclass); 
        test.stopTest();
    }
}