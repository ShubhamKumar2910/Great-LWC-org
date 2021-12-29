@isTest
private class CallRankRevenueProcessTest {
    @isTest public static void testCall() {
        String ID = CallRankRevenueProcess.executeRevenueRankProcess();
        System.assert(ID!=null);
    }
}