@isTest
public class DailyRMFeedSchedulableTestClass {
    static testMethod void testRMFeedSchedulableClass(){
        Test.startTest();
        DailyRMFeedSchedulableClass sh1 = new DailyRMFeedSchedulableClass();
        String sch = '0 0 23 * * ?'; system.schedule('feed Schedule', sch, sh1); 
        Test.stopTest(); 
    }
}