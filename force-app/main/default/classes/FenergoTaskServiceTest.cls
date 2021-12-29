@isTest
private class FenergoTaskServiceTest {

    @testSetup
    static void setupData () {
        List<User> users = UtilityTesting.CreateUsers(1);
        users[0].FederationIdentifier = 'test1234';
        update users;
                
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
        
        Fenergo_Task__c fenergoTask = UtilityTesting.createFenergoTask('Fen-Task0001', 123456, 7, 'Review and Approval', 01234567, 'In Progress', users[0].FederationIdentifier, false);
    	fenergoTask.Fenergo_Case__c = fenergoCase.Id;
        insert fenergoTask;
    }
    
    @isTest
    static void testProcessFenergoTaskApproval() {
        Fenergo_Task__c fenergoTask = [SELECT Id, AssignedTo__c FROM Fenergo_Task__c LIMIT 1];
        FenergoTaskService.FenergoTaskApproval approvalObj = new FenergoTaskService.FenergoTaskApproval();
        approvalObj.actionType = 'Approve';
        approvalObj.fenergoTaskIds = new List<String> {fenergoTask.Id};
        approvalObj.comment = 'Test comment';
        
        Test.startTest();
        List<String> returnResult = FenergoTaskService.processFenergoTaskApproval(new List<FenergoTaskService.FenergoTaskApproval> {approvalObj});
        Test.stopTest();
        
        System.assertEquals('Action performed Successfully', returnResult[0]);
            
        
        
    }
}