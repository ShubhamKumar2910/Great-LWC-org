/*
	Author 		: Pravin Kundal
	Company 	: Nomura
	Date 		: 15/01/2020
	Description : Tests for the SchRequestController class.
*/
@isTest
public class SchRequestControllerTest {
    static testMethod void testLoadSchRequest() {
        System.debug('#### SchRequestTriggerHandlerTest.testLoadSchRequest()');
    	// insert test data
        User userObjApp, userObjSales;
        List<User> userList = new List<User>();
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs(thisUser) {
            Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
            Profile profileNomuraBM = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Business Management' LIMIT 1];
            List<UserRole> userRoleList = [SELECT Id, Name, DeveloperName FROM UserRole WHERE DeveloperName = 'Japan_EQ_Sales_Region_Head'];
            // Create Japan Approver User Record 
            userObjApp = new User();
            userObjApp.Login_ID__c = 'testApp1';
            userObjApp.Alias = 'testApp1';
            userObjApp.LastName = 'TestDummy1App';
            userObjApp.Email = 'TestDummyApp@testOrg.com';
            userObjApp.UserName = 'TestDummyApp@testOrg.com';
            userObjApp.TimeZoneSidKey = 'America/Los_Angeles';
            userObjApp.ProfileId = profileNomuraBM.Id;
            userObjApp.EmailEncodingKey = 'UTF-8';
            userObjApp.LanguageLocaleKey = 'en_US';
            userObjApp.LocaleSidKey = 'en_US';
            userObjApp.Region__c = 'Japan';
            userObjApp.IsActive = TRUE;
            userObjApp.AdditionalPermissions__c = 'SCH Approver Regional';
            if(userRoleList != null && !userRoleList.isEmpty()){
                userObjApp.UserRoleId = userRoleList.get(0).Id;
            }
            userList.add(userObjApp);

            // Create Japan Sales User Record 
            userObjSales = new User();
            userObjSales.Login_ID__c = 'testdum1';
            userObjSales.Alias = 'testdum1';
            userObjSales.LastName = 'TestDummy1LN';
            userObjSales.Email = 'TestDummy1@testOrg.com';
            userObjSales.UserName = 'TestDummy1@testOrg.com';
            userObjSales.TimeZoneSidKey = 'America/Los_Angeles';
            userObjSales.ProfileId = profileNomuraSales.Id;
            userObjSales.EmailEncodingKey = 'UTF-8';
            userObjSales.LanguageLocaleKey = 'en_US';
            userObjSales.LocaleSidKey = 'en_US';
            userObjSales.Region__c = 'Japan';
            userObjSales.IsActive = TRUE;
            if(userRoleList != null && !userRoleList.isEmpty()){
                userObjSales.UserRoleId = userRoleList.get(0).Id;
            }
            userList.add(userObjSales);
            insert userList;
        }

        // create SCH request without RS and RG account hierarchy
        SCH_Request__c oSchReq;
        
        SchRequestController.SchRequestWrapper reqWrapper;
        Test.startTest();
        System.runAs(userObjSales) {
            oSchReq = UtilityTesting.createSchRequest('Test RM Acc Name', 'US',  'BK', 'Prospect', 
                null, 'Test RG Acc (RG)', 
                null, 'Test RS Acc (RS)', 'US',
                true);
            reqWrapper = SchRequestController.loadSchRequest(oSchReq.Id);
            System.debug('reqWrapper : '+reqWrapper);
        }
        Test.stopTest(); 
        
        reqWrapper = SchRequestController.loadSchRequest(oSchReq.Id);
        System.debug('currUser reqWrapper : '+reqWrapper);

        System.runAs(userObjApp) {
            System.debug('oSchReq : '+oSchReq);
            reqWrapper = SchRequestController.loadSchRequest(oSchReq.Id);
            System.debug('reqWrapper : '+reqWrapper);
            SchRequestService.SchRequestAction schReqAct = new SchRequestService.SchRequestAction();
            schReqAct.comments = 'test comments';
            schReqAct.schReqAction = SchRequestService.SCH_REQUEST_BULK_ACTION.SCH_REQ_APPROVE.name();
            schReqAct.SchReqIdList = new List<String>{oSchReq.Id};
            List<String> MsgList = SchRequestService.processSchReqAction(new List<SchRequestService.SchRequestAction>{schReqAct});
            System.debug('MsgList : '+MsgList);
            reqWrapper = SchRequestController.loadSchRequest(oSchReq.Id);
            System.debug('reqWrapper : '+reqWrapper);
        }
    }

    static testMethod void testSearchCapability() {
        System.debug('#### SchRequestTriggerHandlerTest.testSearchCapability()');

        Account sLevel = UtilityTesting.createRSAccount(
                'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        insert sLevel;
        Account rg1 = UtilityTesting.createRGAccount(
                'G Test Account', sLevel.Id, 'Test2', '52nd Street', 'California', 'United States', true);
        insert rg1;
        Account rg1rm1 = UtilityTesting.createRMAccount(
                'Black Diamond Clo 2019-3 Ltd', rg1.Id, 'Test3', '52nd Street', 'California', 'United States', true);
        insert rg1rm1;
        Account rg1rm2 = UtilityTesting.createRMAccount(
                'Black Diamond Clo 2019-5 Ltd', rg1.Id, 'Test3', '52nd Street', 'California', 'United States', true);
        insert rg1rm2;
        
        Account rg1rm3 = UtilityTesting.createRMAccount(
                'Red Comp', rg1.Id, 'Test3', '52nd Street', 'California', 'United States', true);
        insert rg1rm3;
        Id [] fixedSearchResultsAcc = new Id[2];
        fixedSearchResultsAcc[0] = rg1rm1.Id;
        fixedSearchResultsAcc[1] = rg1rm2.Id;
        Test.setFixedSearchResults(fixedSearchResultsAcc);
        List<Account> AccList = SchRequestController.findAccounts('Black', 'US', 0);
        
        
        List<Bloomberg_Entity_Data__c> BbgEntDataList = new List<Bloomberg_Entity_Data__c>();
        BbgEntDataList.add(UtilityTesting.createBloombergEntData('65096088', null, 'US', 
            '701664', 'Black Diamond Clo 2019-3 Ltd', 'Black Diamond CLO Ltd', '701664', 'Black Diamond Clo Parent', 'Active', false));
        BbgEntDataList.add(UtilityTesting.createBloombergEntData('65096089', null, 'US', 
            '701664', 'Black Diamond Clo 2019-4 Ltd', 'Black Diamond CLO Ltd', '701664', 'Black Diamond Clo Parent', 'Active', false));
        BbgEntDataList.add(UtilityTesting.createBloombergEntData('65096090', null, 'US', 
            '701664', 'Black Diamond Clo 2019-5 Ltd', 'Black Diamond CLO Ltd', '701664', 'Black Diamond Clo Parent', 'Active', false));
        BbgEntDataList.add(UtilityTesting.createBloombergEntData('65096091', null, 'US', 
            '701664', 'Black Diamond Clo 2019-6 Ltd', 'Black Diamond CLO Ltd', '701664', 'Black Diamond Clo Parent', 'Active', false));
        BbgEntDataList.add(UtilityTesting.createBloombergEntData('65096092', null, 'US', 
            '701664', 'Black Diamond Clo 2019-7 Ltd', 'Black Diamond CLO Ltd', '701664', 'Black Diamond Clo Parent', 'Active', false));
        BbgEntDataList.add(UtilityTesting.createBloombergEntData('701664', null, 'US', 
            null, 'Black Diamond Clo Parent', null, '701664', 'Black Diamond Clo Parent', 'Active', false));
        insert BbgEntDataList;
       
        Id [] fixedSearchResultsBbg = new Id[5];
        fixedSearchResultsBbg[0] = BbgEntDataList[0].Id;
        fixedSearchResultsBbg[1] = BbgEntDataList[1].Id;
        fixedSearchResultsBbg[2] = BbgEntDataList[2].Id;
        fixedSearchResultsBbg[3] = BbgEntDataList[3].Id;
        fixedSearchResultsBbg[4] = BbgEntDataList[4].Id;
        Test.setFixedSearchResults(fixedSearchResultsBbg);
        List<Bloomberg_Entity_Data__c> BbgEntityDataList = SchRequestController.findBBGLegalEntities('Black', 'US', 0);
        List<Bloomberg_Entity_Data__c> BbgUltParentEntDataList = SchRequestController.findBBGUltimateParentEntities('Black', 
            null , 0);
        BbgUltParentEntDataList = SchRequestController.findBBGUltimateParentEntities(null, 
            new List<String>{'65096088', '65096089', '65096090', '65096091', '65096092'} , 0);
        
        BbgUltParentEntDataList = BloombergEntityDataService.getUltimateParentMatchingName('Black Diamond');

        //Test getInputAccountHierarchyDetails
        SchRequestController.AccountHierarchyDetailsWrapper accountHierarchyDetailsWrapperObj1 = SchRequestController.getInputAccountHierarchyDetails('Black Diamond', null, BbgEntDataList[0].Name);
        SchRequestController.AccountHierarchyDetailsWrapper accountHierarchyDetailsWrapperObj2 = SchRequestController.getInputAccountHierarchyDetails('Black Diamond', null, null);

        //Test getRGAccountsForRS
        List<Account> accountRGListForRS = SchRequestController.getRGAccountsForRS(sLevel.Id);
        System.assert(accountRGListForRS != null && !accountRGListForRS.isEmpty());

        //Test getRGAccountList
        List<Account> accountRGListWithRSAccountId = SchRequestController.getRGAccountList(null, sLevel.Id);
        System.assert(accountRGListWithRSAccountId != null && !accountRGListWithRSAccountId.isEmpty());
        List<Account> accountRGList = SchRequestController.getRGAccountList('G Test', null);
        //System.assert(accountRGList != null && !accountRGList.isEmpty());

        //Test getRSAccountList
        List<Account> accountRSList = SchRequestController.getRSAccountList('S Test');
        //System.assert(accountRSList != null && !accountRSList.isEmpty());

        //Test checkAccountNameAlreadyExists
        Boolean accountRMAlreadyExists = SchRequestController.checkAccountNameAlreadyExists('Black Diamond Clo 2019-3 Ltd');
        System.assert(accountRMAlreadyExists == true);

        //Test getUltimateParentRSEntityIdDetails
        Map<String,String> ultimateParentRSEntityMap = SchRequestController.getUltimateParentRSEntityIdDetails('701664');

    }
}