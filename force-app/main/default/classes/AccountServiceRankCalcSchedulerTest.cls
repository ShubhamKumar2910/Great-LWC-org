@isTest
private class AccountServiceRankCalcSchedulerTest {

    @isTest
    public static void testSchedule() {
        String sched_exp = '0 0 1 1 4 ?';
        Test.startTest();
        String jobId = system.schedule('Create AccountServiceRankCalculationScheduler Test', sched_exp, new AccountServiceRankCalculationScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sched_exp,ct.CronExpression);
        Test.stopTest();
    }
}