@isTest
public class AccountServiceModelCloneController_Test {
    
    @testSetup
    private static void setupTestData(){
        RecordType actualType = [SELECT Id FROM RecordType WHERE Name = 'Actual' ];
        
        Account_Service_Model__c equityCoreserviceModel2 = new Account_Service_Model__c();
        equityCoreserviceModel2.Name = 'Equity Core (value)';
        equityCoreserviceModel2.RecordTypeId = actualType.Id;
        equityCoreserviceModel2.Is_Contact_Count__c = 'NO';
        equityCoreserviceModel2.Item_Name__c = 'Analyst : calls';
        equityCoreserviceModel2.Order__c = 3;
        equityCoreserviceModel2.stable_version__c=1;
        equityCoreserviceModel2.CALL_REPORT_TYPE__C='Dialer;Voicemail';
        equityCoreserviceModel2.WEIGHT__C= 5;
        insert equityCoreserviceModel2;         
        
    }
    
    static testMethod void testAccountServiceModelCloneController(){
        Test.startTest();
        
        Account_Service_Model__c[] models = [Select Id, Name, Is_Contact_Count__c, Item_Name__c, RecordTypeId, Order__c, stable_version__c, CALL_REPORT_TYPE__C, WEIGHT__C from Account_Service_Model__c ];
        Account_Service_Model__c model = models[0];
        model.Item_Name__c='Changed';
        AccountServiceModelCloneController controller = new AccountServiceModelCloneController(new ApexPages.StandardController(model));
        controller.cloneAccountServiceModel();
    }
}