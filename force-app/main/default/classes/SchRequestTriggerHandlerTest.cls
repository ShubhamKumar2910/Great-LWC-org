/*
	Author 		: Pravin Kundal
	Company 	: Nomura
	Date 		: 08/01/2020
	Description : Tests for the SchRequestTriggerHandler class.        			  
*/
@isTest
public class SchRequestTriggerHandlerTest {
    static testMethod void testHandleSchReqIncomplete() {
        System.debug('#### SchRequestTriggerHandlerTest.testHandleSchReqIncomplete()');
    	// insert test data
        Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
		Profile profileNomuraBM = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Business Management' LIMIT 1];
        List<UserRole> userRoleList = [SELECT Id, Name, DeveloperName FROM UserRole WHERE DeveloperName = 'Japan_EQ_Sales_Region_Head'];
        List<User> userList = new List<User>();
        // Create Japan Approver User Record 
        User userObjApp = new User();
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
        User userObjSales = new User();
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

        // create SCH request without RS and RG account hierarchy
        SCH_Request__c oSchReq;
        Test.startTest();
        System.runAs(userObjSales) {
            Account sLevel = UtilityTesting.createRSAccount(
                'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
            insert sLevel;
            Account rg1 = UtilityTesting.createRGAccount(
                    'G Test Account1', sLevel.Id, 'Test2', '52nd Street', 'California', 'United States', true);
            insert rg1;
            Account rg1rm1 = UtilityTesting.createRMAccount(
                    'RM Test Account 1', rg1.Id, 'Test3', '52nd Street', 'California', 'United States', true);
            insert rg1rm1;
            
            oSchReq = UtilityTesting.createSchRequest('Test RM Acc Name', 'US',  'BK', 'Prospect', 
                null, 'testRG (G)', 
                null, 'testRS (S)', null,
                true);
        }
        Test.stopTest(); 
        
        System.runAs(userObjApp) {
            SchRequestService.SchRequestAction schReqAct = new SchRequestService.SchRequestAction();
            schReqAct.comments = 'test comments';
            schReqAct.schReqAction = SchRequestService.SCH_REQUEST_BULK_ACTION.SCH_REQ_APPROVE.name();
            schReqAct.SchReqIdList = new List<String>{oSchReq.Id};
            List<String> MsgList = SchRequestService.processSchReqAction(new List<SchRequestService.SchRequestAction>{schReqAct});
            System.debug('MsgList : '+MsgList);
            System.assertNotEquals(MsgList.size(), 0);
        }
    }

    static testMethod void testHandleSchReqComplete() {
        System.debug('#### SchRequestTriggerHandlerTest.testHandleSchReqComplete()');
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
        
        Test.startTest();
        System.runAs(userObjSales) {
            oSchReq = UtilityTesting.createSchRequest('Test RM Acc Name', 'US',  'BK', 'Prospect', 
                null, 'Test RG Acc (RG)', 
                null, 'Test RS Acc (RS)', 'US',
                true);
        }
        Test.stopTest(); 

        System.runAs(userObjApp) {
            System.debug('oSchReq : '+oSchReq);
            SchRequestService.SchRequestAction schReqAct = new SchRequestService.SchRequestAction();
            schReqAct.comments = 'test comments';
            schReqAct.schReqAction = SchRequestService.SCH_REQUEST_BULK_ACTION.SCH_REQ_APPROVE.name();
            schReqAct.SchReqIdList = new List<String>{oSchReq.Id};
            List<String> MsgList = SchRequestService.processSchReqAction(new List<SchRequestService.SchRequestAction>{schReqAct});
            System.debug('MsgList : '+MsgList);
        }
    }

    static testMethod void testReqSubmittedByJpnApprover() {
        System.debug('#### SchRequestTriggerHandlerTest.testReqSubmittedByJpnApprover()');
    	// insert test data
        User userObjApp, userObjSales;
        List<User> userList = new List<User>();
        User currUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs(currUser) {
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
        
        Test.startTest();
        System.runAs(userObjApp) {
            oSchReq = UtilityTesting.createSchRequest('Test RM Acc Name', 'US',  'BK', 'Prospect', 
                null, 'Test RG Acc (RG)', 
                null, 'Test RS Acc (RS)', 'US',
                true);
        }
        Test.stopTest(); 
    }

    static testMethod void testUpdSystemLog() {
        System.debug('#### SchRequestTriggerHandlerTest.testUpdSystemLog()');
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
        
        Test.startTest();
        System.runAs(userObjSales) {
            

            oSchReq = UtilityTesting.createSchRequest('Test RM Acc Name', 'US',  'BK', 'Prospect', 
                null, 'Test RG Acc (RG)', 
                null, 'Test RS Acc (RS)', 'US',
                true);
        }
        Test.stopTest(); 
        oSchReq.System_log__c = 'error 1';
        update oSchReq;

        //Update the request with same RS Account Name
        Account sLevel = UtilityTesting.createRSAccount(
                'Test RS Account (RS)', 'Test1', '52nd Street', 'California', 'United States', true);
        insert sLevel;
        Account rg1 = UtilityTesting.createRGAccount(
                    'Test RG Account (RG)', sLevel.Id, 'Test2', '52nd Street', 'California', 'United States', true);
         insert rg1;
         Account rg1rm1 = UtilityTesting.createRMAccount(
                    'Test RM Acc Name', rg1.Id, 'Test3', '52nd Street', 'California', 'United States', true);
        insert rg1rm1;

        try {
            oSchReq.RS_Account_Name__c = 'Test RS Account (RS)';
            oSchReq.RG_Account_Name__c = 'Test RG Account (RG)';
            oSchReq.RM_Account_Name__c = 'Test RM Acc Name';
            update oSchReq;
        }
        catch(Exception ex){
            System.debug('****Exception:'+ex.getMessage());
        }
        
    }
}