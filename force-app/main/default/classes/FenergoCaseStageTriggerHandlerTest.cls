@isTest
private class FenergoCaseStageTriggerHandlerTest {

    @testSetup
    static void setupData() {
        Account rgAccount = UtilityTesting.createRGAccount('RG Account', null, '12345', 'Biling street', 'Billing City', 'United Kingdom', true);
        insert rgAccount;
        
        Account rmAccount = UtilityTesting.createRMAccount('RM Test Account 1', rgAccount.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        insert rmAccount; 
        
        Contact cont =  UtilityTesting.createContact('firstname', 'lastname', 'test@test.com', '020204040404', 'Mr', rmAccount.Id, true);
        insert cont;
        
        List<User> users = UtilityTesting.CreateUsers(1);
        
        Onboarding_Request__c obRequest = UtilityTesting.createOnboardingRequest ('LegacyAccount', cont.Id, 'meet', 'New Contact', 1200000.0, 'No', 'Yes','No', users[0].Id, UserInfo.getUserId(),rmAccount.Id);
        insert obRequest;
        
        Fenergo_Case__c fenergoCase = UtilityTesting.createFenergoCase (
            obRequest.Id, 'Test Fenergo Case', 010101, 'Client Onboarding', 'Open', 12346, 000002,'Legal Entity Name', 'Booking Entity Name', 'Product Type', 'Product Category', false 
        );  
        insert fenergoCase;
        
        Fenergo_Case_Stage__c fenergoCaseStage = UtilityTesting.createFenergoCaseStage(
        	'Requires Review', 1, Integer.valueOf(fenergoCase.CaseId__c), fenergoCase.Id, Integer.valueOf(fenergocase.LegalEntityId__c), datetime.now(), true 
        );
    }
    
    @isTest
    static void testUpdateParentCaseStatusToSuspended() {
        Fenergo_Case_Stage__c fenergoCaseStage = [SELECT Id, StageStatus__c, StageName__c FROM Fenergo_Case_Stage__c LIMIT 1];
        Fenergo_Case__c fenergoCase = [SELECT Id, CaseStatus__c FROM Fenergo_Case__c LIMIT 1];
        
        System.assertNotEquals('Suspended', [SELECT Id, CaseStatus__c FROM Fenergo_Case__c WHERE CaseId__c = 010101 LIMIT 1].CaseStatus__c);
        
        Test.startTest();
        fenergoCaseStage.StageStatus__c = 'Suspended';
        update fenergoCaseStage;
        Test.stopTest();
        
        System.assertEquals('Suspended', [SELECT Id, CaseStatus__c FROM Fenergo_Case__c WHERE CaseId__c = 010101 LIMIT 1].CaseStatus__c);
    }
    
    @isTest
    static void testUpdateParentCaseStatusToInProgress() {
        Fenergo_Case_Stage__c fenergoCaseStage = [SELECT Id, StageStatus__c, StageName__c FROM Fenergo_Case_Stage__c LIMIT 1];
        Fenergo_Case__c fenergoCase = [SELECT Id, CaseStatus__c FROM Fenergo_Case__c LIMIT 1];
                
        fenergoCase.CaseStatus__c = 'Suspended';
        update fenergoCase;
        
        Test.startTest();
        fenergoCaseStage.StageStatus__c = 'In Progress';
        update fenergoCaseStage;
        Test.stopTest();
        
        System.assertEquals('In Progress', [SELECT Id, CaseStatus__c FROM Fenergo_Case__c WHERE CaseId__c = 010101 LIMIT 1].CaseStatus__c);
    }
    
    @isTest
    static void testUpdateParentCaseStatusToClosed() {
        Fenergo_Case_Stage__c fenergoCaseStage = [SELECT Id, StageStatus__c, StageName__c FROM Fenergo_Case_Stage__c LIMIT 1];
        Fenergo_Case__c fenergoCase = [SELECT Id, CaseStatus__c FROM Fenergo_Case__c LIMIT 1];
        
        fenergoCase.CaseType__c = 'Product Onboarding';
        update fenergoCase;
        
        Test.startTest();
        fenergoCaseStage.StageStatus__c = 'Completed';
        fenergoCaseStage.StageName__c = 'Review & Activation';
        update fenergoCaseStage;
        Test.stopTest();
        
        System.assertEquals('Closed', [SELECT Id, CaseStatus__c FROM Fenergo_Case__c WHERE CaseId__c = 010101 LIMIT 1].CaseStatus__c);
    }
}