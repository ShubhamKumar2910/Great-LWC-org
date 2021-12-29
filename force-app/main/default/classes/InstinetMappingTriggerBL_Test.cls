@isTest
public with sharing class InstinetMappingTriggerBL_Test {
    @TestSetup
    static void makeData(){
      
        List<Account> testAccounts =  new List<Account>(); 
        Account rg3 = UtilityTesting.createRGAccount(
                'G3 Test Account', null, 'RGTest2', '56rd Street', 'California', 'United States', true);
        testAccounts.add(rg3);
                    
        Account rg1rm1 = UtilityTesting.createRMAccount(
                'RM Test Account 1', rg3.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1rm1);        
        
        Account rg1rm2 = UtilityTesting.createRMAccount(
        'RM Test Account 2', rg3.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1rm2);

        insert testAccounts;       
        
        Instinet_Mapping__c newInstinetMappingObj = new Instinet_Mapping__c();
        newInstinetMappingObj.Name = 'Test Instinet Account';
        newInstinetMappingObj.CDB_Id__c = '123456789';
        newInstinetMappingObj.RM_Id__c = rg1rm1.Id;
        insert newInstinetMappingObj;        
    }

    @IsTest
    static void testTrigger(){
      
        test.startTest();
        List<Account> accountRM1 = [SELECT Id, Name FROM Account Where Name = 'RM Test Account 1' LIMIT 1];
        List<Account> accountRM2 = [SELECT Id, Name FROM Account Where Name = 'RM Test Account 2' LIMIT 1];

        for ( Instinet_Mapping__c instinetMappingObj : [SELECT Id, Name, Previous_RM__c FROM Instinet_Mapping__c WHERE CDB_Id__c ='123456789' LIMIT 1]){
            instinetMappingObj.RM_Id__c = accountRM2[0].Id;            
            update instinetMappingObj;            
        }
        List<Instinet_Mapping__c> instinetMappingList1 = [SELECT Id, Name, Previous_RM__c FROM Instinet_Mapping__c WHERE CDB_Id__c ='123456789' LIMIT 1];
        System.assertEquals(instinetMappingList1[0].Previous_RM__c, accountRM1[0].Id);
        
        for(Instinet_Mapping__c insMapObj : instinetMappingList1){
            insMapObj.RM_Id__c = accountRM1[0].Id;            
            update insMapObj;            
        }
        List<Instinet_Mapping__c> instinetMappingList2 = [SELECT Id, Name, Previous_RM__c FROM Instinet_Mapping__c WHERE CDB_Id__c ='123456789' LIMIT 1];        
		System.assert(instinetMappingList2[0].Previous_RM__c == null);

      test.stopTest();
      
    }
}