@isTest
public class FenergoTasksControllerTest {

    @testSetup
    static void setupFenergoData() {

        List<User> users = UtilityTesting.CreateUsers(1);
        users[0].FederationIdentifier = '1245678';
        update users;

        String federationId = users[0].FederationIdentifier;
        
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

        List<Fenergo_Case_Stage__c> fenergoStages = new List<Fenergo_Case_Stage__c>{
            UtilityTesting.createFenergoCaseStage('New Request', 1, 010101 , fenergoCase.Id, 020202, date.today(), true),
            UtilityTesting.createFenergoCaseStage('AML', 1, 010101, fenergoCase.Id, 020202, date.today(), true),
            UtilityTesting.createFenergoCaseStage('Risk Assessment', 1, 010101, fenergoCase.Id,  020202, date.today(), true)
        };

        Fenergo_Task__c fenergoTask1 = UtilityTesting.createFenergoTask('Task001', 0001, 4, 'In Progress', 01234567, 'New Request', federationId, false);
        
        Fenergo_Task__c fenergoTask2 = UtilityTesting.createFenergoTask('Task002', 0002, 4, 'In Progress', 01234567, 'AML', federationId, false);

        Fenergo_Task__c fenergoTask3 = UtilityTesting.createFenergoTask('Task003', 0003, 4, 'In Progress', 01234567, 'Risk Assessment', federationId, false);

        fenergoTask1.Fenergo_Case_Stage__c = fenergoStages[0].Id;
        fenergoTask2.Fenergo_Case_Stage__c = fenergoStages[1].Id;
        fenergoTask3.Fenergo_Case_Stage__c = fenergoStages[2].Id;
        fenergoTask1.Fenergo_Case__c = fenergoCase.Id;
        fenergoTask2.Fenergo_Case__c = fenergoCase.Id;
        fenergoTask3.Fenergo_Case__c = fenergoCase.Id;

        List<Fenergo_Task__c> fenergoTasks = new List<Fenergo_Task__c> {fenergoTask1,fenergoTask2,fenergoTask3};

        insert fenergoTasks;
    }

    @isTest
    static void testQueryFenergoTasksAndStagesWithFenergoId() {
        Fenergo_Case__c fenergoCase = [SELECT Id FROM Fenergo_Case__c WHERE CaseId__c = 010101 LIMIT 1];
        
        Test.startTest();
        List<Fenergo_Case_Stage__c> fenergoTasksAndStages = FenergoTasksController.queryFenergoTasksAndStages(fenergoCase.Id);
        Test.stopTest();

        // Check that the list is not empty
        System.assertEquals(false, fenergoTasksAndStages.isEmpty(), 'Fenergo Task List Should be populated');

        // Check that the right number of stages were retrieved
        System.assertEquals( [SELECT COUNT() FROM Fenergo_Case_Stage__c], fenergoTasksAndStages.size());

        for (Fenergo_Case_Stage__c fenergoStage : fenergoTasksAndStages) {
            List<Fenergo_Task__c> fenergoTasks = fenergoStage.Fenergo_Tasks__r;
            System.assertEquals(false, fenergoTasks.isEmpty(), 'Fenergo Tasks should have a record');
            System.assertEquals(1, fenergoTasks.size(), 'Only one fenergo task has been created per stage');
        }
    }

    @isTest
    static void testQueryFenergoTasksAndStagesWithoutFenergoId() {

        Test.startTest();
        List<Fenergo_Case_Stage__c> fenergoTasksAndStages = FenergoTasksController.queryFenergoTasksAndStages(null);
        Test.stopTest();

        System.assertEquals(true, fenergoTasksAndStages.isEmpty(), 'List should be empty');
    }

    @isTest
    static void testUpdateOfFenergoTaskWithoutError() {
        List<Fenergo_Task__c> fenergoTasks = [SELECT Id FROM Fenergo_Task__c ORDER BY TaskId__c ASC];

        Test.startTest();
        FenergoTasksController.updateFenergoTasks(new List<String> {fenergoTasks[0].Id}, 'Approve', 'test comment');
        FenergoTasksController.updateFenergoTasks(new List<String> {fenergoTasks[1].Id}, 'Refer', 'test comment');
        FenergoTasksController.updateFenergoTasks(new List<String> {fenergoTasks[2].Id}, 'Cancel', 'test comment');
        Test.stopTest();

        List<Fenergo_Task__c> fenergoTaskUpdated = [SELECT Id, Approval_Status__c, Comment__c, Approval_Review_Outcome__c FROM Fenergo_Task__c ORDER BY TaskId__c ASC];

        System.assertEquals('Approve', fenergoTaskUpdated[0].Approval_Review_Outcome__c);
        System.assertEquals('Refer', fenergoTaskUpdated[1].Approval_Review_Outcome__c);
        System.assertEquals('Cancel', fenergoTaskUpdated[2].Approval_Review_Outcome__c);
    }
}