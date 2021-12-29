@isTest
public class FenergoCaseTriggerHandlerTest {
    
    @testSetup
    static void setupData() {
        Account rgAccount = UtilityTesting.createRGAccount('RG Account', null, '12345', 'Biling street', 'Billing City', 'United Kingdom', true);
        insert rgAccount;
        
        Account rmAccount = UtilityTesting.createRMAccount('RM Test Account 1', rgAccount.Id, 'RM1113', '52nd Street', 'California', 'United States', true);
        insert rmAccount; 
        
        Contact cont =  UtilityTesting.createContact('firstname', 'lastname', 'test@test.com', '020204040404', 'Mr', rmAccount.Id, true);
        insert cont;
        
        List<User> users = UtilityTesting.CreateUsers(1);
        
        Onboarding_Request__c obRequest = UtilityTesting.createOnboardingRequest ('LegacyAccount', cont.Id, 'meet', 'New Contact', 1200000.0, 'No', 'Yes','No', users[0].Id, UserInfo.getUserId(),rmAccount.Id);
        insert obRequest;
        
        Fenergo_Case__c fenergoCase = UtilityTesting.createFenergoCase (
            obRequest.Id, 'Test Fenergo Case', 010101, 'Client Onboarding', 'Open', 1113, 1113,'Legal Entity Name', 'Booking Entity Name', 'Product Type', 'Product Category', false 
        );  
        insert fenergoCase;
    }
    
    @isTest
    static void testCreationOfAccountProduct() {
        List<Account_Product__c> accountProducts = [SELECT Id, CaseId__c, CaseStatus__c, BookingEntityName__c, ProductCategory__c, ProductType__c, Account__c FROM Account_Product__c];
        System.assertEquals(1, accountProducts.size());
        
        Fenergo_Case__c fenergoCase = [SELECT Id, RM_Account__c, CaseId__c, CaseStatus__c, BookingEntityName__c, ProductCategory__c, ProductType__c FROM Fenergo_Case__c WHERE CaseId__c = :accountProducts[0].CaseId__c LIMIT 1];
        
        System.assertEquals(accountProducts[0].Account__c, fenergoCase.RM_Account__c);
        System.assertEquals(accountProducts[0].CaseStatus__c, fenergoCase.CaseStatus__c);
        System.assertEquals(accountProducts[0].CaseId__c, fenergoCase.CaseId__c);
        System.assertEquals(accountProducts[0].BookingEntityName__c, fenergoCase.BookingEntityName__c);
        System.assertEquals(accountProducts[0].ProductCategory__c, fenergoCase.ProductCategory__c);
       	System.assertEquals(accountProducts[0].ProductType__c, fenergoCase.ProductType__c);
    }
    
    @isTest
    static void testUpdateOfAccountProductForAccount() {
        // Query existing fenergo case and account product from @testSetup
        List<Account_Product__c> accountProducts = [SELECT Id, CaseId__c, CaseStatus__c, BookingEntityName__c, ProductCategory__c, ProductType__c, Account__c FROM Account_Product__c];        
        Fenergo_Case__c fenergoCaseOld = [SELECT Id, CaseId__c, CaseStatus__c FROM Fenergo_Case__C LIMIT 1];
        Onboarding_Request__c obRequest = [SELECT Id, RM_Account__c FROM Onboarding_Request__c LIMIT 1];
        
        Test.startTest();
		fenergoCaseOld.CaseStatus__c = 'In Progress';
        update fenergoCaseOld;
        Test.stopTest();
        
        // Query updated Account Product - Should only still have one account product, only CaseStatus changed
        List<Account_Product__c> accountProductsUpdated = [SELECT Id, CaseId__c, CaseStatus__c FROM Account_Product__c];
        System.assertEquals(1, accountProductsUpdated.size());
        
        Fenergo_Case__c fenergoCaseNew = [SELECT Id, CaseId__c, CaseStatus__c,BookingEntityName__c,ProductCategory__c,ProductType__c FROM Fenergo_Case__C LIMIT 1];
        
        // Account Product should now have updated field values from the new fenergo case. 
        System.assertEquals(accountProductsUpdated[0].CaseStatus__c, fenergoCaseNew.CaseStatus__c);
        // Other values on the account product should be the same
        System.assertEquals(accountProducts[0].BookingEntityName__c, fenergoCaseNew.BookingEntityName__c);
        System.assertEquals(accountProducts[0].ProductCategory__c, fenergoCaseNew.ProductCategory__c);
        System.assertEquals(accountProducts[0].ProductType__c, fenergoCaseNew.ProductType__c);
        System.assertEquals(accountProducts[0].Account__c, [SELECT Id, RM_Account__c FROM Fenergo_Case__c WHERE Id = :fenergoCaseNew.Id LIMIT 1].RM_Account__c);
    }    
    
    @isTest
    static void testMissingInfoFromFenergoCase() {
        // Insert a fenergo case with a new product type - this should mean a new account product is created rather than updating the existing one. 
        Test.startTest();
        Onboarding_Request__c obRequest = [SELECT Id FROM Onboarding_Request__c LIMIT 1];
        Fenergo_Case__c fenergoCase = UtilityTesting.createFenergoCase (
            obRequest.Id, 'Test Fenergo Case', 030303, 'Client Onboarding', 'In Progress', 1113, 000002,'Legal Entity Name', null, 'Product Type 2', 'Product Category', false 
        );  
        insert fenergoCase;
        Test.stopTest(); 
        
        // Account Product shouldn't have been created as missing booking entity name
        System.assertEquals(1, [SELECT COUNT() FROM Account_Product__c]);
    }
}