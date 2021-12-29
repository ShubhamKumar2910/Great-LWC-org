@isTest
public class RevenueKPIDeleteBatchTest {
    @testSetUp
    public static void testSetupForRevenueKPIDeleteBatch() {
        Account rgAccount = TestRevenueKPIDataFactory.createRgAccount('RGNAME');
        List<Account> rgAccounts = new List<Account>();
        rgAccounts.add(rgAccount);

        User kpiOwner = TestRevenueKPIDataFactory.createKPIOwner();
        
        List<Revenue_KPI__c> kpis = TestRevenueKPIDataFactory.createKPIs(rgAccounts, kpiOwner);
    }

    @isTest 
    public static void TestRevenueKPIDeleteBatch(){
       
       Test.startTest();

       Id batchProcessId = Database.executeBatch(new RevenueKPIDeleteBatch(), 1000);

       Test.stopTest();

       //Test Whether Revenue_KPI__c record present or not

       List<Revenue_KPI__c> revenueKPIList = [SELECT Id FROM Revenue_KPI__c];
       
       System.assert(revenueKPIList == null || revenueKPIList.isEmpty());
   
   }
}