@isTest
public with sharing class PreOnbPDFforLegacyAccountControllerTest {
    @testSetup
    private static void setupTestData(){
        Account rgAccount = UtilityTesting.createRGAccount('RG Account', null, '12345', 'Biling street', 'Billing City', 'United Kingdom', true);
        insert rgAccount;
        
        Account rmAccount = UtilityTesting.createRMAccount('RM Test Account 1', rgAccount.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);       
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

    static testMethod void testPreOnbPDF(){
        PreOnbPDFforLegacyAccountController preOnb = new PreOnbPDFforLegacyAccountController(new ApexPages.StandardController([SELECT Id, Name from Onboarding_Request__c WHERE How_do_you_know_of_this_client__c = 'meet']));
        System.debug('--preOnb--' + preOnb);
        System.assert(preOnb != null);
    }
}