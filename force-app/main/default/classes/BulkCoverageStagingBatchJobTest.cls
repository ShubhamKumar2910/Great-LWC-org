@isTest
public class BulkCoverageStagingBatchJobTest {
    @TestSetup
    public static void testSetup(){

        Id RGRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('RG_Account').getRecordTypeId();
        Id RMRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('RM_Account').getRecordTypeId();

        Account accountRG  = new Account(); 
        accountRG.Name = 'RG_Account_Dummy';
        accountRG.RDM_Org_ID__c = 'RGXXXXXX';            
        accountRG.RecordTypeId = RGRecordType;
        accountRG.Active__c = TRUE;
        accountRG.Symphony_Room_Id__c = '0UjLldk1Qj/18dYG2b1+O0H///o54eljCdA==';  
        
        insert accountRG;

        Account accountRM  = new Account();  
        accountRM.Name = 'RM_Account_Dummy';
        accountRM.RDM_Org_ID__c = 'RMXXXXXX';
        accountRM.RecordTypeId = RMRecordType;
        accountRM.BillingStreet = 'XXX' ;
        accountRM.BillingCity = 'XXX';
        accountRM.BillingPostalCode = 'XXX';
        accountRM.BillingCountry = 'United States';
        accountRM.Active__c = TRUE; 
        accountRM.ParentId = accountRG.Id;

        insert accountRM;

        Sales_Team_For_Coverage__c salescvgTeam = new  Sales_Team_For_Coverage__c ();
        salescvgTeam.Name = 'Test';
        salescvgTeam.Sales_Team__c = 'Test Sales Team';
        salescvgTeam.Coverage_ID__c = '1234';
        salescvgTeam.Sales_Desk_Region__c = 'Asia';
            
        insert salescvgTeam;

        Bulk_Coverage_Staging__c bulkData = new Bulk_Coverage_Staging__c();
        bulkData.RM_Account__c = accountRM.Id;
        bulkData.Action__c = 'add';
        bulkData.Sales_Team_for_Coverage__c = salescvgTeam.Id;
        bulkData.Date__c = Date.newInstance(2016, 12, 9);
        bulkData.Role__c = 'Primary';

        insert bulkData;
    }
        
    public static testMethod void testBatch(){
        Database.executeBatch(new BulkCoverageStagingBatchJob(), 1);
    }
    
}