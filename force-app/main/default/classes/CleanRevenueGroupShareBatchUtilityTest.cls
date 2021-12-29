@isTest
private class CleanRevenueGroupShareBatchUtilityTest {
    @isTest public static void testListErrorsAndNotify(){
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            String jobName = 'testMapErrorsAndNotify';
            List<String> errors = new List<String>();
            Map<String, String> jobStats = new Map<String, String>();
            jobStats.put(RevenueRankUtility.JOB_ITEMS, '1');
            jobStats.put(RevenueRankUtility.JOB_ERRORS, '0');
            String[] toAddress = new String[]{UserInfo.getUserEmail()};
            boolean result = CleanRevenueGroupShareBatchUtility.listErrorsAndNotify(errors, jobName, Id.valueOf('001xa000003DIlo'),jobStats,toAddress);
            System.assert(!result);
            
            errors.add('Test error');
            
            result = CleanRevenueGroupShareBatchUtility.listErrorsAndNotify(errors, jobName, Id.valueOf('001xa000003DIlo'), jobStats,toAddress);
            System.assert(result);
            jobStats.put('ExtendedStatus', 'test');
            jobStats.put(RevenueRankUtility.JOB_ERRORS, '1');
            errors.clear();
            result = CleanRevenueGroupShareBatchUtility.listErrorsAndNotify(errors, jobName, Id.valueOf('001xa000003DIlo'), jobStats,toAddress);
        }
    }
    @isTest public static void testPopulateRevenueShareErrorList() {
        Map<Integer, String> errorMap = new Map<Integer, String>();
        errorMap.put(0, 'Test message 2');
        errorMap.put(1, 'Test message 5');
        List<Revenue__Share> shares = new List<Revenue__Share>();
        Revenue__Share share1 = new Revenue__Share();
        shares.add(share1);
        Revenue__Share share2 = new Revenue__Share();
        shares.add(share2);
        List<String> errors = CleanRevenueGroupShareBatchUtility.populateRevenueShareErrorList(errorMap, 'TEST', shares);
        System.assert(errors.size() == 2);
    }

}