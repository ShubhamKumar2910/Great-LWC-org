@isTest
public class OnboardingProductFormControllerTest {

    @testSetup
    static void testData() {
        List<String> bookingEntities = UtilityTesting.getOnboardingBookingEntities();
        String bookingEntity = !bookingEntities.isEmpty() ? bookingEntities[0] : ''; 

        Account rgAccount = UtilityTesting.createRGAccount('RG Account', null, '12345', 'Biling street', 'Billing City', 'United Kingdom', true);
        insert rgAccount;
        
        Account rmAccount = UtilityTesting.createRMAccount('RM Test Account 1', rgAccount.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        insert rmAccount; 
        
        Contact cont =  UtilityTesting.createContact('firstname', 'lastname', 'test@test.com', '020204040404', 'Mr', rmAccount.Id, true);
        insert cont;
    
        User salesRequestor = UtilityTesting.createUsersWithProfile(1, 'Nomura - Sales')[0];
        salesRequestor.Region__c = 'EMEA';
        update salesRequestor;
        
        Onboarding_Request__c obRequest = UtilityTesting.createOnboardingRequest ('LegacyAccount', cont.Id, 'meet', 'New Contact', 1200000.0, 'No', 'Yes','No', salesRequestor.Id, salesRequestor.Id, rmAccount.Id);
        insert obRequest;
        
        Onboarding_Product__c obProduct = UtilityTesting.createOnboardingProduct('Cash', 'Fixed Income Cash', obRequest.Id, 'High', 'Principal', '6-10', '3M-5M', 'Yes', 
                                                                                'Consistently highly relevant to market price action and trends', 'Straightforward bid offer and capturable predictability/ programs plus reliable dialogue around intentions/axes',
                                                                                'United Kingdom - London', new List<String> {bookingEntity}, 
                                                                                'United Kingdom - London');
        insert obProduct;
    }
    
    @isTest
    static void testLoadOnbProdReqsAndMetadata() {
        List<String> bookingEntities = UtilityTesting.getOnboardingBookingEntities();
        String bookingEntity = (!bookingEntities.isEmpty() && bookingEntities[1] != null) ? bookingEntities[1] : bookingEntities[0]; 
        Onboarding_Request__c obRequest = [SELECT Id FROM Onboarding_Request__c LIMIT 1];
        
        Onboarding_Product__c obProduct = UtilityTesting.createOnboardingProduct('Cash', 'Fixed Income Cash', obRequest.Id, 'High', 'Principal', '6-10', '3M-5M', 'Yes', 
                                                                                 'Consistently highly relevant to market price action and trends', 'Straightforward bid offer and capturable predictability/ programs plus reliable dialogue around intentions/axes',
                                                                                 'United Kingdom - London', new List<String> {bookingEntity}, 
                                                                                 'United Kingdom - London');
        insert obProduct;
        
        Test.startTest();
        OnboardingProductFormController.OnbProdRequestWrpper obReqData = OnboardingProductFormController.loadOnbProdReqsAndMetadata(obRequest.Id, 'Cash', 'Fixed Income Cash');
        Test.stopTest();

        System.assertEquals(true, obReqData != null);        
        System.assertEquals(2, obReqData.OnbProdList.size());
    }
    
    @isTest
    static void testGetNomuraBookingEntitiesForRequestRecordType() {
        Onboarding_Request__c obRequest = [SELECT Id FROM Onboarding_Request__c LIMIT 1];
        Test.startTest();
        List<String> bookingEntities = OnboardingProductFormController.getNomuraBookingEntitiesForRequestRecordType(obRequest.Id);
        Test.stopTest();
        
        System.assertEquals(false, bookingEntities.isEmpty());
    }
    
    @isTest
    static void testGetHistoricProdReqData() {        
        Onboarding_Request__c obRequest = [SELECT Id, RM_Account__c, Status__c FROM Onboarding_Request__c LIMIT 1];
        Account rmAccount = [SELECT Id, Stage__c FROM Account WHERE Id = :obRequest.RM_Account__c];

        Test.startTest();
        rmAccount.Stage__c = 'Fenergo Managed Client';
        update rmAccount;
        obRequest.Status__c = 'Submitted';
        update obRequest;
        Map<String, String> historicData = OnboardingProductFormController.getHistoricProdReqData(obRequest.Id, 'Cash', 'Fixed Income Cash');
        Test.stopTest();

        System.assert(!historicData.isEmpty());
        System.assertEquals(historicData.get('Trading_Desk_Rank_Relevance_To_Market__c'), [SELECT Trading_Desk_Rank_Relevance_To_Market__c FROM Onboarding_Product__c WHERE Products_Category__c = 'Cash' LIMIT 1].Trading_Desk_Rank_Relevance_To_Market__c);
    }
    
    @isTest
    static void testSaveOnbRequest() {
        List<String> bookingEntities = UtilityTesting.getOnboardingBookingEntities();
        String bookingEntity = (!bookingEntities.isEmpty() && bookingEntities[1] != null) ? bookingEntities[1] : bookingEntities[0]; 
        Onboarding_Request__c obRequest = [SELECT Id FROM Onboarding_Request__c LIMIT 1];
        
        Onboarding_Product__c obProduct = UtilityTesting.createOnboardingProduct('Cash', 'Equity Cash', obRequest.Id, 'High', 'Principal', '6-10', '3M-5M', 'Yes', 
                                                                                 'Consistently highly relevant to market price action and trends', 'Straightforward bid offer and capturable predictability/ programs plus reliable dialogue around intentions/axes',
                                                                                 'United Kingdom - London', new List<String> {bookingEntity}, 
                                                                                 'United Kingdom - London');
        
        Test.startTest();
        List<OnboardingProductFormController.OnbProdSaveResult> obReqSaveResult = OnboardingProductFormController.saveOnbRequest(new List<Onboarding_Product__c> {obProduct},null, true);
        Test.stopTest();
        
        System.assertEquals(true, String.isBlank(obReqSaveResult[0].errors));
        System.assertEquals(1, [SELECT COUNT() FROM Onboarding_Product__c WHERE Products_Category__c = 'Cash' AND Product_Type__c = 'Equity Cash']);
    }
}