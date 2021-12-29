@isTest
public with sharing class AddEditOnboardingRequestTest {
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
    public static void testMethods() {
        Onboarding_Request__c onbReq = [SELECT ID FROM Onboarding_Request__c WHERE How_do_you_know_of_this_client__c = 'meet'];
        if(onbReq != null){
            AddEditOnboardingRequest.RequestDetails reqDetailsObj = AddEditOnboardingRequest.getOnboardingStatus(onbReq.Id);
            System.assert(reqDetailsObj != null);

            String onbReqStr = AddEditOnboardingRequest.getNewlyCreatedOnboardingRecordIdbyUser();
            System.assert(onbReqStr != null);
        }
    }

   
}