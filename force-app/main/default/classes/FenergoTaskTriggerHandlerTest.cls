/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**  Date 		: 11/02/2020
**	Description : Test class for FenergoTaskTriggerHandler
**/ 
// To Do..currently this has real data creation script...will be changed to test clss later
@isTest
public without sharing class FenergoTaskTriggerHandlerTest {
    
    @testSetup
    static void testData(){
        List<User> users = UtilityTesting.CreateUsers(1);
        
        Account rgAccount = UtilityTesting.createRGAccount('RG Account', null, '12345', 'Biling street', 'Billing City', 'United Kingdom', true);
        insert rgAccount;
        
        Account rmAccount = UtilityTesting.createRMAccount('RM Test Account 1', rgAccount.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        insert rmAccount; 
        
        Contact cont =  UtilityTesting.createContact('firstname', 'lastname', 'test@test.com', '020204040404', 'Mr', rmAccount.Id, true);
        insert cont;
        
        Onboarding_Request__c obRequest = UtilityTesting.createOnboardingRequest ('LegacyAccount', cont.Id, 'meet', 'New Contact', 1200000.0, 'No', 'Yes','No', users[0].Id, UserInfo.getUserId(),rmAccount.Id);
        insert obRequest;
    }
    
    public static void createFenergoCases(Integer strtingcaseNo) {
        // 'FIDELITY BUSINESS SERVICES INDIA', 
        // 'BLACKROCK GLOBAL INVESTORS AUSTRALIA LTD' 
        // 'FRANKLIN MUTUAL FUNDBRAZIL'
        // TIFFANY + CO
        // BLACKROCK -3
        List<Integer> RdmIdList = new List<Integer>{313059, 259996, 998627, 536399, 15213};
        List<Fenergo_Case__c> FenergocaseList = new List<Fenergo_Case__c>();
        
        Onboarding_Request__c obReq = [SELECT Id FROM Onboarding_Request__c LIMIT 1];
        for(Integer i=strtingcaseNo; i<strtingcaseNo+2; ++i) {
            FenergocaseList.add(UtilityTesting.createFenergoCase(obReq.Id, 'Test-'+i, i, 'Client Onboarding', 'Open', 
                RdmIdList.get(Math.mod(i,RdmIdList.size())), RdmIdList.get(Math.mod(i,RdmIdList.size()))+10, 
                'Test-legalEntityName-'+i, 'NBI - NOMURA BANK INTERNATIONAL PLC', null, null, false));
        }
        FenergocaseList.get(1).Onboarding_Request__c = null;
        insert FenergocaseList;

        List<Fenergo_Case_Stage__c> FenCaseStageList = new List<Fenergo_Case_Stage__c>();
        List<Fenergo_Task__c> FenTaskList = new List<Fenergo_Task__c>();
      
        Fenergo_Case__c oFenCase1 = FenergocaseList.get(0);
        FenCaseStageList.add(UtilityTesting.createFenergoCaseStage('Classifications', 6, (Integer)oFenCase1.CaseId__c, oFenCase1.Id,
                (Integer)oFenCase1.LegalEntityId__c, null, false));
        FenCaseStageList.add(UtilityTesting.createFenergoCaseStage('Review and Approval', 7, (Integer)oFenCase1.CaseId__c, oFenCase1.Id,
                (Integer)oFenCase1.LegalEntityId__c, null, false));
        
        FenTaskList.add(UtilityTesting.createFenergoTask('Classifications', ((((Integer)oFenCase1.CaseId__c*10)+7)*10)+1, 1, 
                'In Progress', (Integer)oFenCase1.CaseId__c, 'Enrich Client Information', 'KYC', false));
        FenTaskList.add(UtilityTesting.createFenergoTask('Sales Approval', ((((Integer)(oFenCase1.CaseId__c)*10)+7)*10)+5, 5, 
                'In Progress', (Integer)oFenCase1.CaseId__c, 'Review and Approval', 'jkanejam', false));
        FenTaskList.add(UtilityTesting.createFenergoTask('Desk Approval', ((((Integer)oFenCase1.CaseId__c*10)+7)*10)+71, 7, 
                'In Progress', (Integer)oFenCase1.CaseId__c, 'Review and Approval', 'rohrober', false));
        FenTaskList.add(UtilityTesting.createFenergoTask('Desk Approval1', ((((Integer)oFenCase1.CaseId__c*10)+7)*10)+72, 7, 
                'In Progress', (Integer)oFenCase1.CaseId__c, 'Review and Approval', 'yamayuy', false));
        //------------
        oFenCase1 = FenergocaseList.get(1);
        FenCaseStageList.add(UtilityTesting.createFenergoCaseStage('Classifications', 6, (Integer)oFenCase1.CaseId__c, oFenCase1.Id,
                (Integer)oFenCase1.LegalEntityId__c, null, false));
        FenCaseStageList.add(UtilityTesting.createFenergoCaseStage('Review and Approval', 7, (Integer)oFenCase1.CaseId__c, oFenCase1.Id,
                (Integer)oFenCase1.LegalEntityId__c, null, false));
        
        FenTaskList.add(UtilityTesting.createFenergoTask('Classifications', ((((Integer)oFenCase1.CaseId__c*10)+7)*10)+11, 1, 
                'In Progress', (Integer)oFenCase1.CaseId__c, 'Enrich Client Information', 'KYC', false));
        FenTaskList.add(UtilityTesting.createFenergoTask('Sales Approval', ((((Integer)oFenCase1.CaseId__c*10)+7)*10)+51, 5, 
                'In Progress', (Integer)oFenCase1.CaseId__c, 'Review and Approval', 'jkanejam', false));
        FenTaskList.add(UtilityTesting.createFenergoTask('Desk Approval', ((((Integer)oFenCase1.CaseId__c*10)+7)*10)+73, 7, 
                'In Progress', (Integer)oFenCase1.CaseId__c, 'Review and Approval', 'rohrober', false));
        
        insert FenCaseStageList;
        insert FenTaskList;
    }

    // Testing validateFenergoTasks method.
    // Result should be an error.
    @isTest
    static void testValidationErrorOnUpdateOfTask() {
        User user = [SELECT Id, FederationIdentifier FROM User WHERE Email LIKE '%@testorg.com' LIMIT 1];
        user.FederationIdentifier = '1245678';
        update user;

        String federationId = user.FederationIdentifier;
        Onboarding_Request__c obReq = [SELECT Id FROM Onboarding_Request__c LIMIT 1];
        Fenergo_Case__c fenergoCase = UtilityTesting.createFenergoCase(
            obReq.Id, 'Test Fenergo Case', 010101, 'Client Onboarding', 'Open', 00001, 000002,'Legal Entity Name', 'Booking Entity Name', 'Product Type', 'Product Category', true 
        );    

        Fenergo_Task__c fenergoTask = UtilityTesting.createFenergoTask('Fen-Task0001', 21232, 32002, 'Review and Approval', 01234567, 'In Progress', 'federationId', false);
        fenergoTask.Fenergo_Case__c = fenergoCase.Id;
        insert fenergoTask;

        String error;
        
        Test.startTest();
        System.runAs(user) {
            fenergoTask.Approval_Status__c = 'Not Required';
            fenergoTask.Approval_Review_Outcome__c = 'Approve';
            try {
                update fenergoTask;
            } catch (Exception e) {
                error = e.getMessage();       
            }
        }
        Test.stopTest();
		
        System.assertEquals(String.isNotBlank(error), true, 'Error should have been thrown');
        System.assert(error.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        System.assert(error.contains('This task is not eligible to be updated'));
    }
    
    @isTest
    static void testUpdateTaskWhenChangedFromTerminated() {
        Onboarding_Request__c obReq = [SELECT Id FROM Onboarding_Request__c LIMIT 1];
        Fenergo_Case__c fenergoCase = UtilityTesting.createFenergoCase(
            obReq.Id, 'Test Fenergo Case', 010101, 'Client Onboarding', 'Open', 00001, 000002,'Legal Entity Name', 'Booking Entity Name', 'Product Type', 'Product Category', true 
        ); 
        Fenergo_Task__c fenergoTask = UtilityTesting.createFenergoTask('Fen-Task0001', 21232, 32002, 'Terminated', 01234567, 'In Progress', 'federationId', false);
        fenergoTask.Fenergo_Case__c = fenergoCase.Id;
		insert fenergoTask;
        
        Test.startTest();
        fenergoTask.TaskStatus__c = 'In Progress';
        update fenergoTask;
        Test.stopTest();
        
        Fenergo_Task__c fenergoTaskUpdated = [SELECT Id, Approval_Status__c, Approval_Review_Outcome__c, ReviewNotes__c, ReviewerId__c, ReviewDate__c FROM Fenergo_Task__c WHERE Id = :fenergoTask.Id LIMIT 1];
   		System.assertEquals('Pending', fenergoTaskUpdated.Approval_Status__c);
        System.assertEquals(null, fenergoTaskUpdated.Approval_Review_Outcome__c);
        System.assertEquals(null, fenergoTaskUpdated.ReviewNotes__c);
        System.assertEquals(null, fenergoTaskUpdated.ReviewerId__c);
        System.assertEquals(null, fenergoTaskUpdated.ReviewDate__c);
    }
    
    @isTest
    static void testUpdateAssignedToUserLookup() {
        User user = [SELECT Id, FederationIdentifier FROM User WHERE Email LIKE '%@testorg.com' LIMIT 1];
        user.FederationIdentifier = '1245678';
        update user;

        Onboarding_Request__c obReq = [SELECT Id FROM Onboarding_Request__c LIMIT 1];
        Fenergo_Case__c fenergoCase = UtilityTesting.createFenergoCase(
            obReq.Id, 'Test Fenergo Case', 010101, 'Client Onboarding', 'Open', 00001, 000002,'Legal Entity Name', 'Booking Entity Name', 'Product Type', 'Product Category', true 
        );    
		
        Test.startTest();
        System.runAs(user) {
            List<Fenergo_Task__c> fenergoTasks = new List<Fenergo_Task__c>();
            Fenergo_Task__c fenergoTask = UtilityTesting.createFenergoTask('Fen-Task0001', 21232, 32002, 'Review and Approval', 01234567, 'In Progress', user.FederationIdentifier, false);
            fenergoTask.Fenergo_Case__c = fenergoCase.Id;
            fenergoTasks.add(fenergoTask);
            
            Fenergo_Task__c fenergoTask2 = UtilityTesting.createFenergoTask('Fen-Task0002', 21233, 32002, 'Review and Approval', 01234567, 'In Progress', '', false);
            fenergoTask2.Fenergo_Case__c = fenergoCase.Id;
            fenergoTasks.add(fenergoTask2);
            
            insert fenergoTasks;
        }
        Test.stopTest();
        
        System.assertEquals(User.Id, [SELECT Id, Assigned_To_User__c FROM Fenergo_Task__c WHERE TaskId__c = 21232 LIMIT 1].Assigned_To_User__c);
        System.assertEquals(null, [SELECT Id, Assigned_To_User__c FROM Fenergo_Task__c WHERE TaskId__c = 21233 LIMIT 1].Assigned_To_User__c);

        
        Fenergo_Task__c fenergoTask = [SELECT Id, AssignedTo__c FROM Fenergo_Task__c WHERE TaskId__c = 21232 LIMIT 1];
        fenergoTask.AssignedTo__c = null;
        update fenergoTask;
        
        System.assertEquals(null, [SELECT Id, Assigned_To_User__c FROM Fenergo_Task__c WHERE TaskId__c = 21232 LIMIT 1].Assigned_To_User__c);
    }
}