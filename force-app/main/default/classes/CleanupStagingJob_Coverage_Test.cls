@isTest
private class CleanupStagingJob_Coverage_Test {
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    
	@isTest static void step1()
    {
        Coverage_Temp__c temp = new Coverage_Temp__c();
        temp.action__c = 'add';
        temp.GUID__c = 'GUID-123';
        temp.clientKey__c = 'RM12345';
        insert temp; 
        system.debug(temp.id);
        
        Test.startTest();
        String jobId = System.schedule('CleanupStagingJob_Coverage_Test',
                                       CRON_EXP,
                                       new CleanupStagingJob_CoverageSchedulable());
        Id batchJobId = Database.executeBatch(new CleanupStagingJob_Coverage(), 200);
        Test.stopTest();
    }
}