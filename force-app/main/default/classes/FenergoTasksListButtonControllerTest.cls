@isTest
public class FenergoTasksListButtonControllerTest {
    
    @testSetup
    static void testData() {
        List<User> users = UtilityTesting.CreateUsers(1);
        
        Account rgAccount = UtilityTesting.createRGAccount('RG Account', null, '12345', 'Biling street', 'Billing City', 'United Kingdom', true);
        insert rgAccount;
        
        Account rmAccount = UtilityTesting.createRMAccount('RM Test Account 1', rgAccount.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        insert rmAccount; 
        
        Contact cont =  UtilityTesting.createContact('firstname', 'lastname', 'test@test.com', '020204040404', 'Mr', rmAccount.Id, true);
        insert cont;
        
        Onboarding_Request__c obRequest = UtilityTesting.createOnboardingRequest ('LegacyAccount', cont.Id, 'meet', 'New Contact', 1200000.0, 'No', 'Yes','No', users[0].Id, UserInfo.getUserId(),rmAccount.Id);
        insert obRequest;
        
        Fenergo_Case__c fenergoCase = UtilityTesting.createFenergoCase(
            obRequest.Id, 'Test Fenergo Case', 010101, 'Client Onboarding', 'Open', 00001, 000002,'Legal Entity Name', 'Booking Entity Name', 'Product Type', 'Product Category', true 
        ); 
        Fenergo_Task__c fenergoTask = UtilityTesting.createFenergoTask('Fen-Task0001', 21232, 32002, 'Terminated', 01234567, 'In Progress', 'federationId', false);
        fenergoTask.Fenergo_Case__c = fenergoCase.Id;
        insert fenergoTask;
        
        Fenergo_Task__c fenergoTask2 = UtilityTesting.createFenergoTask('Fen-Task0002', 21233, 32002, 'Terminated', 0123567, 'In Progress', 'federationId', false);
        fenergoTask2.Fenergo_Case__c = fenergoCase.Id;
        insert fenergoTask2;
        
    }
    
    @isTest
    static void testSetActions() {
        List<Fenergo_Task__c> fenergoTasks = [SELECT Id FROM Fenergo_Task__c];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(fenergoTasks);
        stdSetController.setSelected(fenergoTasks);
        FenergoTasksListButtonController controller = new FenergoTasksListButtonController(stdSetController);
        
        Test.startTest();
        controller.setApproveAction();
        controller.setReferAction();
        controller.setCancelAction();
        Test.stopTest();
    }
}