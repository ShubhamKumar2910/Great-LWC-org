@isTest
public with sharing class OnbReqCaptureIdsVFControllerTest {
    static testMethod void testVFController() {
        System.debug('#### OnbRequestCaptureSelIdsVFControllerTest.testVFController()');
        List<Onboarding_Request__c>ONBRequestList = new List<Onboarding_Request__c>();

        Account rgAccount = UtilityTesting.createRGAccount('RG Account', null, '12345', 'Biling street', 'Billing City', 'United Kingdom', true);
        insert rgAccount;
        
        Account rmAccount = UtilityTesting.createRMAccount('RM Test Account 1', rgAccount.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);       
        insert rmAccount; 
        
        Contact cont =  UtilityTesting.createContact('firstname', 'lastname', 'test@test.com', '020204040404', 'Mr', rmAccount.Id, true);
        insert cont;
        
        User salesRequestor = UtilityTesting.createUsersWithProfile(1, 'Nomura - Sales')[0];        
        update salesRequestor;
        
        Onboarding_Request__c obRequest = UtilityTesting.createOnboardingRequest ('LegacyAccount', cont.Id, 'meet', 'New Contact', 1200000.0, 'No', 'Yes','No', salesRequestor.Id, UserInfo.getUserId(),rmAccount.Id);
        ONBRequestList.add(obRequest);

        insert ONBRequestList;

        Test.startTest();
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(ONBRequestList);
            stdSetController.setSelected(ONBRequestList);
            OnbReqCaptureIdsVFController apexCont = new OnbReqCaptureIdsVFController(stdSetController);
            apexCont.initializeApproveAction();
            apexCont.initializeRejectAction();
           
        Test.stopTest();
    }
}