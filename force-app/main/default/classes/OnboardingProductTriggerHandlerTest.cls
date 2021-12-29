@isTest
public class OnboardingProductTriggerHandlerTest {
    
    @testSetup static void testData () {        
        Account rgAccount = UtilityTesting.createRGAccount('RG Account', null, '12345', 'Biling street', 'Billing City', 'United Kingdom', true);
        insert rgAccount;
        
        Account rmAccount = UtilityTesting.createRMAccount('RM Test Account 1', rgAccount.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        insert rmAccount; 
        
        Contact cont =  UtilityTesting.createContact('firstname', 'lastname', 'test@test.com', '020204040404', 'Mr', rmAccount.Id, true);
        insert cont;
	
        User salesRequestor = UtilityTesting.createUsersWithProfile(1, 'Nomura - Sales')[0];
        salesRequestor.Region__c = 'EMEA';
        update salesRequestor;
        
        // RM_Account__c
        Onboarding_Request__c obRequest = UtilityTesting.createOnboardingRequest ('LegacyAccount', cont.Id, 'meet', 'New Contact', 1200000.0, 'No', 'Yes','No', salesRequestor.Id, salesRequestor.Id, rmAccount.Id);
        insert obRequest;
        
        Onboarding_Product__c obProduct = UtilityTesting.createOnboardingProduct('Cash', 'Fixed Income Cash', obRequest.Id, 'High', 'Principal', '6-10', '3M-5M', 'Yes', 
                                                                                'Consistently highly relevant to market price action and trends', 'Straightforward bid offer and capturable predictability/ programs plus reliable dialogue around intentions/axes',
                                                                                'United Kingdom - London', new List<String> {'NIHK - NOMURA INTERNATIONAL (HONG KONG) LIMITED'}, 
                                                                                'United Kingdom - London');
        insert obProduct;
    }
    
    /**
     * Verify that the Unique Key was created from the OnboardingProductTriggerHandler
     */
    @isTest
    static void verifyUniqueKeyWasCreated() {
		Onboarding_Product__c obProduct = [SELECT Id, Unique_Key__c, Onboarding_Request__c, Products_Category__c, Product_Type__c, Nomura_Entity_client_being_onboarded_to__c FROM Onboarding_Product__c WHERE Products_Category__c = 'Cash' LIMIT 1];
    	String uniqueKey = obProduct.Onboarding_Request__c+'_'+ obProduct.Products_Category__c+'_'+ obProduct.Product_Type__c+'_'+obProduct.Nomura_Entity_client_being_onboarded_to__c;
    	System.assert(String.isNotBlank(obProduct.Unique_Key__c), 'Unique Key should not be blank');
        System.assertEquals(uniqueKey, obProduct.Unique_Key__c);
    }
    
    @isTest
    static void errorOnboardingProductWithoutSalesRequestorRole() {
        Test.startTest();
        String errMessage;
        User user = [SELECT Id, Region__c FROM User WHERE Email LIKE '%@testorg.com' LIMIT 1];
        user.Region__c = null;
        update user;
        Onboarding_Request__c obRequest = [SELECT Id FROM Onboarding_Request__c LIMIT 1];
        Onboarding_Product__c obProduct = UtilityTesting.createOnboardingProduct('Cash', 'Equity Cash', obRequest.Id, 'High', 'Principal', '6-10', '3M-5M', 'Yes', 
                                                                                 'Consistently highly relevant to market price action and trends', 'Straightforward bid offer and capturable predictability/ programs plus reliable dialogue around intentions/axes',
                                                                                 'United Kingdom - London', new List<String> {'NIHK - NOMURA INTERNATIONAL (HONG KONG) LIMITED'}, 
                                                                                 'United Kingdom - London');
        try{
            insert obProduct;
        } catch(Exception e) {
            errMessage = e.getMessage();
        }
        Test.stopTest();
        
        System.assertEquals(false, String.isBlank(errMessage));
    }
    
    @isTest
    static void verifyUniqueKeyOnUpdate() {
        Test.startTest();
        Onboarding_Product__c obProduct = [SELECT Id, Unique_Key__c, Onboarding_Request__c, Products_Category__c, Product_Type__c, Nomura_Entity_client_being_onboarded_to__c FROM Onboarding_Product__c WHERE Products_Category__c = 'Cash' LIMIT 1];
		obProduct.Product_Type__c = 'Equity Cash';
        update obProduct;
        Test.stopTest();
        
        Onboarding_Product__c obProductUpdated = [SELECT Id, Unique_Key__c, Onboarding_Request__c, Products_Category__c, Product_Type__c, Nomura_Entity_client_being_onboarded_to__c FROM Onboarding_Product__c WHERE Products_Category__c = 'Cash' LIMIT 1];
        String uniqueKey = obProductUpdated.Onboarding_Request__c+'_'+ obProductUpdated.Products_Category__c+'_'+ obProductUpdated.Product_Type__c+'_'+obProductUpdated.Nomura_Entity_client_being_onboarded_to__c;
        System.assert(String.isNotBlank(obProductUpdated.Unique_Key__c), 'Unique Key should not be blank');
        System.assertEquals(uniqueKey, obProductUpdated.Unique_Key__c);
        System.assert(uniqueKey.contains('Equity Cash') && !uniqueKey.contains('Fixed Income Cash'), 'Unique Key should contain Equity Cash, not Fixed Income Cash');
    }
    
    /**
     * Description: On insert of the OB Product, the regional flags should be updated on the parent OB Request. 
     */
    @isTest
    static void verifyRegionalFlagsOnInsert() {
		Onboarding_Request__c obRequest = [SELECT Id, Is_EMEA_Topup_Required__c, Is_AEJ_Topup_Required__c, Is_US_Topup_Required__c FROM Onboarding_Request__c LIMIT 1];
        System.assertEquals(true, obRequest.Is_EMEA_Topup_Required__c, 'Is_EMEA_Topup_Required__c should be true as Sales Requestor Location is EMEA');
        System.assertEquals(true, obRequest.Is_AEJ_Topup_Required__c, 'Is_AEJ_Topup_Required__c should be true as Booking entity is an AEJ booking entity');
        System.assertEquals(false, obRequest.Is_US_Topup_Required__c, 'Is_US_Topup_Required__c should be false');
    }
    
    /**
     * Description: Update the onboaring products and their booking entities, this should update the Regional Flags related to the parent OB Request.
     */
    @isTest
    static void verifyRegionalFlagsOnUpdateOfProducts() {
        Test.startTest();
        Onboarding_Product__c obProduct = [SELECT Id, Nomura_Entity_client_being_onboarded_to__c FROM Onboarding_Product__c WHERE Products_Category__c = 'Cash' LIMIT 1];
        delete obProduct;
        
        Onboarding_Request__c obRequest = [SELECT Id, Is_EMEA_Topup_Required__c, Is_AEJ_Topup_Required__c, Is_US_Topup_Required__c FROM Onboarding_Request__c LIMIT 1];

        Onboarding_Product__c obProductNew = UtilityTesting.createOnboardingProduct('Cash', 'Fixed Income Cash', obRequest.Id, 'High', 'Principal', '6-10', '3M-5M', 'Yes', 
                                                                                    'Consistently highly relevant to market price action and trends', 'Straightforward bid offer and capturable predictability/ programs plus reliable dialogue around intentions/axes',
                                                                                    'United Kingdom - London', new List<String> {'NAUR - NOMURA AMERICAS US RE LIMITED'}, 
                                                                                    'United Kingdom - London');
        insert obProductNew;
        Test.stopTest();
        
		Onboarding_Request__c obRequestAfter = [SELECT Id, Is_EMEA_Topup_Required__c, Is_AEJ_Topup_Required__c, Is_US_Topup_Required__c FROM Onboarding_Request__c LIMIT 1];
        
        System.assertEquals(true, obRequestAfter.Is_EMEA_Topup_Required__c, 'Is_EMEA_Topup_Required__c should be true as Sales Requestor Location is EMEA');
        System.assertEquals(true, obRequestAfter.Is_US_Topup_Required__c, 'Is_US_Topup_Required__c should be true as booking entity is an Americas booking entity');
        System.assertEquals(false, obRequestAfter.Is_AEJ_Topup_Required__c, 'Is_AEJ_Topup_Required__c should be false as the AEJ product was deleted');        
    }    
    
    @isTest
    static void checkIfProductAlreadyOnboardedTest() {
        Account rmAccount = [SELECT Id FROM Account WHERE Name = 'RM Test Account 1' LIMIT 1];
        Account_Product__c accountProduct = new Account_Product__c (
        	ProductCategory__c='Cash', 
            ProductType__c='Fixed Income Cash', 
			Account__c=rmAccount.Id,
            BookingEntityName__c='NIHK - NOMURA INTERNATIONAL (HONG KONG) LIMITED'
        );
        
        insert accountProduct;
        
        String error;
        Test.startTest();
        try {
            Onboarding_Request__c obRequest = [SELECT Id FROM Onboarding_Request__c LIMIT 1];
            Onboarding_Product__c obProduct = UtilityTesting.createOnboardingProduct('Cash', 'Fixed Income Cash', obRequest.Id, 'High', 'Principal', '6-10', '3M-5M', 'Yes', 
                                                                                     'Consistently highly relevant to market price action and trends', 'Straightforward bid offer and capturable predictability/ programs plus reliable dialogue around intentions/axes',
                                                                                     'United Kingdom - London', new List<String> {'NIHK - NOMURA INTERNATIONAL (HONG KONG) LIMITED'}, 
                                                                                     'United Kingdom - London');
            insert obProduct;
        } catch (exception e) {
            error = e.getMessage();
        }
        Test.stopTest();
        
        System.assertEquals(true, String.isNotBlank(error), 'Duplicate Product inserted - error should have been thrown');
        System.assertEquals(1, [SELECT COUNT() FROM Onboarding_Product__c WHERE RM_Account__c = :rmAccount.Id]);
          
    }
}