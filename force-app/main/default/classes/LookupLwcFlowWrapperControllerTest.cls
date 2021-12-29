/*
	Author 		: Manmeet Singh Sahani
	Company 	: Nomura
	Description : Tests for the LookupLwcFlowWrapperController class.
*/
@isTest
public class LookupLwcFlowWrapperControllerTest {
    static testMethod void testSearchFenergoRMAccounts() {
        String rgAccID;
            
        System.debug('#### LookupLwcFlowWrapperControllerTest.testSearchFenergoRMAccounts()');

        Account sLevel = UtilityTesting.createRSAccount(
                'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        insert sLevel;
        Account newRGAccount = UtilityTesting.createRGAccount(
                'G Test Account', sLevel.Id, 'Test2', '52nd Street', 'California', 'United States', true);
        insert newRGAccount;
        System.debug('---rgnewRGAccount1--' + newRGAccount);
        
        
        Account newRMAccount = UtilityTesting.createRMAccount(
                'Black Diamond Clo 2019-3 Ltd', newRGAccount.Id, 'Test3', '52nd Street', 'California', 'United States', true);
        
        insert newRMAccount;

        
      	Contact newContact =  UtilityTesting.createContact('firstname', 'lastname', 'test@test.com', '020204040404', 'Mr', newRMAccount.Id, true);
        insert newContact;
		System.debug('--newContact--' + newContact);
        
        //Insert Instinet Employees Account IN12345
        Id nomuraEmployeesRecordTypeId = CommonTools.getRecordTypeId('Account','NOMURA EMPLOYEES');

        Account instinetEmployeesAccount  = new Account();  
        instinetEmployeesAccount.Name = 'INSTINET EMPLOYEES';
        instinetEmployeesAccount.RDM_Org_ID__c = 'IN12345';            
        instinetEmployeesAccount.RecordTypeId = nomuraEmployeesRecordTypeId;
        instinetEmployeesAccount.Active__c = TRUE; 
        
        insert instinetEmployeesAccount;

        //Insert Instinet Employee Contact
        Contact instinetEmployeeRecord = new Contact();
        instinetEmployeeRecord.Salutation = 'M.';
        instinetEmployeeRecord.FirstName = 'Instinet_Emp_FN';
        instinetEmployeeRecord.LastName = 'Instinet_Emp_LN';
        instinetEmployeeRecord.Email = 'instinet_emp@test.comx';
        instinetEmployeeRecord.AccountId = instinetEmployeesAccount.Id;
        instinetEmployeeRecord.Active__c = TRUE;
        instinetEmployeeRecord.Login_Id__c = 'testtmpX';

        insert instinetEmployeeRecord;
        
        Contact contactnameRecord = new Contact();
        contactnameRecord.Salutation = 'M.';
        contactnameRecord.FirstName = 'Fname';
        contactnameRecord.LastName = 'Lname';
        contactnameRecord.Email = 'Fname@test.comx';
        contactnameRecord.AccountId = instinetEmployeesAccount.Id;
        contactnameRecord.Active__c = TRUE;
        contactnameRecord.Login_Id__c = 'testtmpX1';

        insert contactnameRecord;
        
        
        User newUser = UtilityTesting.createUsersWithProfile(1, 'Nomura - Sales')[0];
      
        Event newEvent = UtilityTesting.createEvent('Standard_Event', newContact.Id, 'Analyst Meeting');
        insert newEvent;
		System.debug('---newEvent--' + newEvent);
        
      	Id [] fixedSearchResults = new Id[6];
        fixedSearchResults[0] = newRGAccount.Id;
        fixedSearchResults[1] = newRMAccount.Id;
        fixedSearchResults[2] = newContact.Id;
        fixedSearchResults[3] = newUser.Id;
        fixedSearchResults[4] = newEvent.Id;
        fixedSearchResults[5] = instinetEmployeeRecord.Id;

        Test.setFixedSearchResults(fixedSearchResults);
        
       	List<A1Flows_LookupSearchResult> rmLookupSrchRsltList = LookupLwcFlowWrapperController.SearchFenergoRMAccounts('Black', null, null, true);
        System.debug('---rmLookupSrchRsltList--' + rmLookupSrchRsltList); 
        List<A1Flows_LookupSearchResult> rgLookupSrchRsltList = LookupLwcFlowWrapperController.searchRGAccounts('G', null, true);
        System.debug('---rgLookupSrchRsltList--' + rgLookupSrchRsltList); 
        
        List<A1Flows_LookupSearchResult> npLookupSrchRsltList = LookupLwcFlowWrapperController.searchNomuraPerson('Testing', null, false, true);
        System.debug('---npLookupSrchRsltList--' + npLookupSrchRsltList);
        List<A1Flows_LookupSearchResult> callReportLookupSrchRsltList = LookupLwcFlowWrapperController.searchCallReport('Test CP', newRGAccount.Id, 1, null);
        System.debug('---callReportLookupSrchRsltList--' + callReportLookupSrchRsltList);
        List<A1Flows_LookupSearchResult> contactLookupSrchRsltList = LookupLwcFlowWrapperController.searchContact('firstname', newRGAccount.Id, 1, null, true);
        System.debug('---contactLookupSrchRsltList--' + contactLookupSrchRsltList);
       
        
        //For pre-defined--
        Account rgAcc = [SELECT Id, Name from Account WHERE Name LIKE 'G Test%'];
        if(rgAcc !=null){
        	rgAccID = rgAcc.Id;
            List<A1Flows_LookupSearchResult> preRG = LookupLwcFlowWrapperController.searchPreDefined(rgAccID, 'RG Account', null, true);
			System.debug('---preRG--' + preRG);
            System.assertEquals(preRg[0].Id, rgAccID);
        }
        
        Account rmAcc = [SELECT Id, Name from Account WHERE Name LIKE 'Black%'];
        if(rmAcc != null){
            String rmAccID = rmAcc.Id;
            List<A1Flows_LookupSearchResult> preRM = LookupLwcFlowWrapperController.searchPreDefined(rmAccID, 'RM Account', rmAccID, true);
			System.debug('---preRM--' + preRM);
            System.assertEquals(preRM[0].Id, rmAccID);
        }
        
        
        Contact con = [SELECT Id, Name FROM Contact WHERE FirstName = 'firstname' LIMIT 1];
        if(con != null){
            String conId = con.Id;
            Contact conobj = LookupLwcFlowWrapperController.getContact(conId);
			System.debug('---conobj--' + conobj);
            System.assertEquals(conobj.Id, con.Id);
        }
        
        Contact con2 = [SELECT Id, Name FROM Contact WHERE FirstName = 'Instinet_Emp_FN' LIMIT 1];
        if(con2 != null){
            String conId2 = con2.Id;
            List<A1Flows_LookupSearchResult> preCon2 = LookupLwcFlowWrapperController.searchPreDefined(conId2, 'Nomura Person', '', true);
			System.debug('---preCon2--' + preCon2);
            System.assertEquals(preCon2[0].Id, conId2);
        }
        
        Contact con3 = [SELECT Id, Name FROM Contact WHERE FirstName = 'Fname' LIMIT 1];
        if(con != null){
            String conId = con.Id;
            List<A1Flows_LookupSearchResult> preCon = LookupLwcFlowWrapperController.searchPreDefined(conId, 'Contact', rgAccID, true);
			System.debug('---preCon--' + preCon);
            System.assertEquals(preCon[0].Id, conId);
        }
        
        User user = [SELECT Id, Name from User WHERE LastName LIKE 'Testing%'];
        if(user != null){
            String userId = user.Id;
            List<A1Flows_LookupSearchResult> preUser = LookupLwcFlowWrapperController.searchPreDefined(userId, 'Nomura Person', '', true);
			System.debug('---preUser--' + preUser);
			System.assertEquals(preUser[0].Id, userId);            
        }
        
        
        Event event = [SELECT Id, Subject from Event WHERE Subject LIKE 'Test CP'];
        if(event != null){
            String eventId = event.Id;
            List<A1Flows_LookupSearchResult> preEvent = LookupLwcFlowWrapperController.searchPreDefined(eventId, 'Call Report', null, true);
            System.assertEquals(preEvent[0].Id, eventId);
        } 
        
                
    }

    
}