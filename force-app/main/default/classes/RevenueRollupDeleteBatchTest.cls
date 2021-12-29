@isTest
public class RevenueRollupDeleteBatchTest {
    @testSetUp
    public static void testSetupForRevenueRollupDeleteBatch() {
        Id recordTypeIdForRM = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();   
        
        
        //Insert Account
        Account accountRM  = new Account();  
        accountRM.Name = 'RM_Account_Dummy_Old';
        accountRM.RDM_Org_ID__c = 'RM333333';            
        accountRM.RecordTypeId = recordTypeIdForRM;
        accountRM.BillingStreet = '52nd Street' ;
        accountRM.BillingCity = 'Los Angeles';
        accountRM.BillingPostalCode = '90001';
        accountRM.BillingCountry = 'United States';
        accountRM.Active__c = TRUE; 
        
        insert accountRM; 
       
        //Insert Revenue Rollup
        Revenue_Rollup__c revenueRollup = new Revenue_Rollup__c();
        revenueRollup.region__c = 'MSP';
        revenueRollup.RM__c = accountRM.id;
        
        insert revenueRollup;
    }

    @isTest 
    public static void TestRevenueRollupDeleteBatch(){
       
       Test.startTest();

       Id batchProcessId = Database.executeBatch(new RevenueRollupDeleteBatch(), 1000);

       Test.stopTest();

       //Test Whether Revenue_Rollup__c record present or not

       List<Revenue_Rollup__c> revenueRollupList = [SELECT Id FROM Revenue_Rollup__c];
       
       System.assert(revenueRollupList == null || revenueRollupList.isEmpty());
   
   }
}