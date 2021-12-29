@isTest
public class FenergoCaseAndStageAndTaskServiceTest {

    @testSetup
    static void testData() {
        Account rgAccount = UtilityTesting.createRGAccount('RG Account', null, '12345', 'Biling street', 'Billing City', 'United Kingdom', true);
        insert rgAccount;
        
        Account rmAccount = UtilityTesting.createRMAccount('RM Test Account 1', rgAccount.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        rmAccount.Override_Contacts_MiFID_II_Entitlement__c = true;
        rmAccount.MiFID_II_Research_In_Scope__c = true;
        rmAccount.MiFIDII_Sales_Commentary_Allowed__c = 'Allowed';
        insert rmAccount; 
        
        User salesRequestor = UtilityTesting.createUsersWithProfile(1, 'Nomura - Sales')[0];
        salesRequestor.Region__c = 'EMEA';
        salesRequestor.IsActive = true;
        salesRequestor.FederationIdentifier = salesRequestor.Id;
        update salesRequestor;

        Contact cont =  UtilityTesting.createContact('firstname', 'lastname', 'test@test.com', '020204040404', 'Mr', rmAccount.Id, true);
        insert cont;
        
        Onboarding_Request__c obRequest = UtilityTesting.createOnboardingRequest ('LegacyAccount', cont.Id, 'meet', 'New Contact', 1200000.0, 'No', 'Yes','No', salesRequestor.Id, UserInfo.getUserId(),rmAccount.Id);
        insert obRequest;
                
        Fenergo_Case__c fenergoCase = UtilityTesting.createFenergoCase (
            obRequest.Id, 'Test Fenergo Case', 010101, 'Client Onboarding', 'Open', 12346, 000002,'Legal Entity Name', 'Booking Entity Name', 'Product Type', 'Product Category', false 
        );  
        insert fenergoCase;
        
        Fenergo_Case_Stage__c fenergoStage = UtilityTesting.createFenergoCaseStage('In Progress', 1, 010101, fenergoCase.Id, 12346, null, false);
        insert fenergoStage;
        
        Fenergo_Task__c fenergoTask = UtilityTesting.createFenergoTask('taskName', 12345, FenergoCaseAndStageAndTaskService.FEN_TASK_TEMP_ID_THAT_NEEDS_SALES_APPROVAL, 'taskStatus', 010101, fenergoStage.Id, salesRequestor.Id, false);
        fenergoTask.Fenergo_Case__c = fenergoCase.Id;
        fenergoTask.Fenergo_Case_Stage__c = fenergoStage.Id;
        insert fenergoTask;
        
    }
    
    @isTest
    static void testGetFenergoTaskAndStagesForFenergoCaseIds() {
        Fenergo_Case__c fenergoCase = [SELECT Id, CaseId__c FROM Fenergo_Case__c WHERE CaseId__c = 010101];
        
        Test.startTest();
        Map<Integer, Fenergo_Case__c> fenCaseByFenCaseIdMap = new Map<Integer, Fenergo_Case__c>();
        Map<Integer, Map<String, Fenergo_Case_Stage__c>> fenStageByFenStageNameMapByFenCaseIdMap = new Map<Integer, Map<String, Fenergo_Case_Stage__c>>();
        FenergoCaseAndStageAndTaskService.getFenergoTaskAndStagesForFenergoCaseIds(new Set<Integer> {010101}, FenCaseByFenCaseIdMap, fenStageByFenStageNameMapByFenCaseIdMap);
        Test.stopTest();
        
        System.assertEquals(true, fenCaseByFenCaseIdMap.containsKey(010101));
        System.assertEquals(true, fenStageByFenStageNameMapByFenCaseIdMap.containsKey(010101));
        System.assertEquals(1, fenStageByFenStageNameMapByFenCaseIdMap.get(010101).size());
        System.assertEquals(true, fenStageByFenStageNameMapByFenCaseIdMap.get(010101).containsKey('In Progress'));
    }
    
    @isTest
    static void testGetFenCaseShareForPreObReq() {
        Fenergo_Task__c fenergoTask = [SELECT Id, Fenergo_Case__c, AssignedTo__c FROM Fenergo_Task__c LIMIT 1];
        Fenergo_Case__Share fenCaseShare = FenergoCaseAndStageAndTaskService.createFenergoShareRec(fenergoTask.Fenergo_Case__c, fenergoTask.AssignedTo__c, 'Read', FenergoCaseAndStageAndTaskService.FEN_CASE_SHR_REASON_REQ_REQUESTOR);
        insert fenCaseShare;
        
        Test.startTest();
        List<Fenergo_Case__Share> fenCaseShareList = FenergoCaseAndStageAndTaskService.getFenCaseShareForPreObReq(new Set<String> {fenergoTask.Fenergo_Case__c}, new Set<String> {fenergoTask.AssignedTo__c}, null, null);
        Test.stopTest();
        
        System.assertEquals(true, !fenCaseShareList.isEmpty());
        System.assertEquals(fenCaseShare.ParentId, fenCaseShareList[0].ParentId);
    }
    
    @isTest
    static void testGetFenCaseShareForFenTask() {
        Fenergo_Task__c fenergoTask = [SELECT Id, Fenergo_Case__c, AssignedTo__c FROM Fenergo_Task__c LIMIT 1];
        Fenergo_Case__Share fenCaseShare = FenergoCaseAndStageAndTaskService.createFenergoShareRec(fenergoTask.Fenergo_Case__c, fenergoTask.AssignedTo__c, 'Read', FenergoCaseAndStageAndTaskService.FEN_CASE_SHR_REASON_FEN_TASK_SALES_APPR);
        insert fenCaseShare;
        
        Test.startTest();
        List<Fenergo_Case__Share> fenCaseShareList = FenergoCaseAndStageAndTaskService.getFenCaseShareForFenTask(new Set<String> {fenergoTask.Fenergo_Case__c}, new Set<String> {fenergoTask.AssignedTo__c}, null, null);
        Test.stopTest();
        
        System.assertEquals(true, !fenCaseShareList.isEmpty());
        System.assertEquals(fenCaseShare.ParentId, fenCaseShareList[0].ParentId);
    }
    
    @isTest
    static void testManageFenCaseSharingBasedOnPreObReq() {
        Contact cont = [SELECT Id FROM Contact WHERE Email = 'test@test.com'];
        Account rmAccount = [SELECT Id FROM Account WHERE Name = 'RM Test Account 1'];
        User salesRequestor = [SELECT Id FROM User WHERE Email LIKE '%@testorg.com'];
        Onboarding_Request__c obRequest = UtilityTesting.createOnboardingRequest ('LegacyAccount', cont.Id, 'meet', 'New Contact', 1200000.0, 'No', 'Yes','No', salesRequestor.Id, UserInfo.getUserId(),rmAccount.Id);
        insert obRequest;
        
        Test.startTest();
        Fenergo_Case__c fenergoCase = [SELECT Id, Onboarding_Request__c FROM Fenergo_Case__c WHERE CaseId__c = 010101];
        fenergoCase.Onboarding_Request__c = obRequest.Id;
        update fenergoCase;
        Test.stopTest();
    }
}