@isTest
public class OnboardingReqAndProdControllerTest {
    
    @testSetup
    static void testData() {
        Account rgAccount = UtilityTesting.createRGAccount('RG Account', null, '12345', 'Biling street', 'Billing City', 'United Kingdom', true);
        insert rgAccount;
        
        Account rmAccount = UtilityTesting.createRMAccount('RM Test Account 1', rgAccount.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        rmAccount.Override_Contacts_MiFID_II_Entitlement__c = true;
        rmAccount.MiFID_II_Research_In_Scope__c = true;
        rmAccount.MiFIDII_Sales_Commentary_Allowed__c = 'Allowed';
        insert rmAccount; 
        
        Contact cont =  UtilityTesting.createContact('firstname', 'lastname', 'test@test.com', '020204040404', 'Mr', rmAccount.Id, true);
        insert cont;
                
        User salesRequestor = UtilityTesting.createUsersWithProfile(1, 'Nomura - Sales')[0];
        salesRequestor.Region__c = 'EMEA';
        salesRequestor.IsActive = true;
        update salesRequestor;
        
        Onboarding_Request__c obRequest = UtilityTesting.createOnboardingRequest ('LegacyAccount', cont.Id, 'meet', 'New Contact', 1200000.0, 'No', 'Yes','No', salesRequestor.Id, UserInfo.getUserId(),rmAccount.Id);
        insert obRequest;
        
        Onboarding_Product__c obProduct = UtilityTesting.createOnboardingProduct('Cash', 'Fixed Income Cash', obRequest.Id, 'High', 'Principal', '6-10', '3M-5M', 'Yes', 
                                                                                'Consistently highly relevant to market price action and trends', 'Straightforward bid offer and capturable predictability/ programs plus reliable dialogue around intentions/axes',
                                                                                'United Kingdom - London', new List<String> {'NIHK - NOMURA INTERNATIONAL (HONG KONG) LIMITED'}, 
                                                                                'United Kingdom - London');
        insert obProduct;
    }
    
    @isTest
    static void testDeleteOnboardingProduct() {
        Boolean isSuccess = false;
        Test.startTest();
        Onboarding_Product__c obProduct = [SELECT Id FROM Onboarding_Product__c WHERE Products_Category__c = 'Cash' LIMIT 1];
        isSuccess = OnboardingReqAndProdController.deleteProdReqs(new List<String> {obProduct.Id});
        Test.stopTest();
        
        System.assertEquals(true, isSuccess);
        System.assertEquals(0, [SELECT COUNT() FROM Onboarding_Product__c WHERE Products_Category__c = 'Cash']);
    }
    
    @isTest
    static void testRetrieveOfOnboardingReqAndProdData() {
        Test.startTest();
        Onboarding_Request__c obReq = [SELECT Id, RM_Account__c FROM Onboarding_Request__c LIMIT 1];
        Onboarding_Product__c obProduct = [SELECT Id FROM Onboarding_Product__c WHERE Products_Category__c = 'Cash' LIMIT 1];

        List<OnboardingReqAndProdController.OnbRequestWrapper> obReqWrapperList = OnboardingReqAndProdController.loadOnbReqWithOnbProds(obReq.RM_Account__c, obReq.Id);
		Test.stopTest();

        System.assertEquals(1, obReqWrapperList.size());
        System.assertEquals(1, obReqWrapperList[0].OnbProdWrapperList.size());
        System.assertEquals(obProduct.Id, obReqWrapperList[0].OnbProdWrapperList[0].oOnbProd.Id);
    }    
    
    @isTest
    static void testGetAccountProductData() {
        Onboarding_Request__c obReq = [SELECT Id, RM_Account__c FROM Onboarding_Request__c LIMIT 1];
        Onboarding_Product__c obProduct = [SELECT Id, Products_Category__c, Product_Type__c, Nomura_Entity_client_being_onboarded_to__c FROM Onboarding_Product__c WHERE Products_Category__c = 'Cash' LIMIT 1];

        
        Test.startTest();
        Account_Product__c accProduct = new Account_Product__c(
            BookingEntityName__c = obProduct.Nomura_Entity_client_being_onboarded_to__c,
            Account__c = obReq.RM_Account__c,
            ProductCategory__c = obProduct.Products_Category__c,
            ProductType__c = obProduct.Product_Type__c
        );
        insert accProduct;
        
        List<Account_Product__c> accProducts = OnboardingReqAndProdController.getAccountProductData(obReq.Id);
        Test.stopTest();
        
        System.assertEquals(1, accProducts.size());
        System.assertEquals(accProduct.Id, accProducts[0].Id);
    }
  
}