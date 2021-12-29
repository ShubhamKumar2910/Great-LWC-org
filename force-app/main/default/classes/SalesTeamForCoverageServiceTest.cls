/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : Test class for class - SalesTeamForCoverageService
**				   
**/ 
@isTest 
public class SalesTeamForCoverageServiceTest {

	static testMethod void testSalesTeamForCoverage () {
    	System.debug('#### SalesTeamForCoverageServiceTest::testSalesTeamForCoverage()');
    	
    	String userName = 'standarduser' + DateTime.now().getTime() + '@nomuratest.com';
		Profile testProfile = [SELECT Id FROM Profile WHERE Name='Nomura - Sales'];
		User testUser = new User(Alias = 'standt', Email='standarduser@nomuratest.com',
									EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
									LocaleSidKey='en_US', ProfileId = testProfile.Id,
									TimeZoneSidKey='America/Los_Angeles',
									UserName=userName);
		testUser.Login_Id__c = 'test_login-id';							
		insert testUser;
		
		PermissionSet eTradingEnablementPermissionSet = [SELECT Id, Name FROM PermissionSet WHERE Name = 'ETrading_Enablement_Admin'];
		
		PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment();
		permissionSetAssignment.AssigneeId = testUser.Id;
		permissionSetAssignment.PermissionSetId = eTradingEnablementPermissionSet.Id;
		insert permissionSetAssignment;

		System.runAs(testUser) {	
		// Insert RS Account
		Id rsAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RS Account').getRecordTypeId();
		Account rsAccount = AccountTestData.getAccount();
		rsAccount.RecordTypeId = rsAccountRecordTypeId;
		rsAccount.RDM_Org_ID__c = 'RS Account';
		rsAccount.Active__c = true; 
		insert rsAccount;
			
		// Insert RG Account
		Id rgAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();
		Account rgAccount = AccountTestData.getAccount();
		rgAccount.RecordTypeId = rgAccountRecordTypeId;
		rgAccount.RDM_Org_ID__c = 'RG Account';
		rgAccount.ParentId = rsAccount.Id;
		rgAccount.Active__c = true;
		insert rgAccount;
			
		// Insert RM Account
		Id rmAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
		Account account = AccountTestData.getAccount();
		account.RecordTypeId = rmAccountRecordTypeId;
		account.RDM_Org_ID__c = 'RM Account';
		account.ParentId = rgAccount.Id;
		account.Active__c = true; 
		insert account;

		Contact contact = ContactTestData.getContact(account.Id);
		contact.RG_Account__c = rgAccount.Id;
		insert contact;

		Id eTradingEnablementRequestRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Request').getRecordTypeId();
			
		/*List<ETradingEnablement__c> eTradingEnablements = new List<ETradingEnablement__c>();
		for (Integer intLoop = 0; intLoop <= 19; intLoop++)
		{
			ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
			eTradingEnablement.Status__c = 'On Hold';
			eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
			eTradingEnablement.Platform_First_Name__c = 'Test First Name ' + String.valueOf(intLoop);
			eTradingEnablement.Platform_Id__c = String.valueOf(intLoop);
			eTradingEnablement.Platform_Last_Name__c  = 'Test Last Name ' + String.valueOf(intLoop);
			eTradingEnablement.Contact__c = contact.Id;
			eTradingEnablement.RecordTypeId = eTradingEnablementRequestRecordTypeId;

			eTradingEnablements.add(eTradingEnablement);  
		}
		insert eTradingEnablements;*/

		Sales_Team_for_Coverage__c salesTeamForCoverage = new Sales_Team_for_Coverage__c();
		salesTeamForCoverage.Name = 'Test Sales Team for Coverage';
		salesTeamForCoverage.Active__c = true;
		salesTeamForCoverage.Coverage_ID__c = '007';
		salesTeamForCoverage.Sales_Desk_Region__c = 'USA';
		salesTeamForCoverage.Sales_Desk_Division__c = 'Fixed Income';
		salesTeamForCoverage.Sales_Team__c = 'Test Team';
		salesTeamForCoverage.Sales_Code_Login_ID__c='test_login-id';
		insert salesTeamForCoverage; 
				
		Sales_Team_User__c salesTeamUser = new Sales_Team_User__c();
		salesTeamUser.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
		salesTeamUser.User__c = testUser.Id;
		salesTeamUser.Source_Id__c = salesTeamForCoverage.Id + '#' + testUser.Id;
		insert salesTeamUser;
		}		
		Sales_Team_for_Coverage__c oSalesTeamForCoverage = [SELECT Id,Coverage_ID__c FROM Sales_Team_for_Coverage__c LIMIT 1][0];
		Test.startTest();
			System.runAs(testUser) {
				String currentUsersSalesCode = SalesTeamForCoverageService.getCurrentUserSalesCode();
				System.assertEquals(currentUsersSalesCode, oSalesTeamForCoverage.Id);
			}
			
			Map<String, Set<String>> UserIdSetBySalesCodeIdMap = 
				SalesTeamForCoverageService.getAllActiveSalesCodeForUsers(new List<String>{testUser.Id});
			System.assertEquals(UserIdSetBySalesCodeIdMap.isEmpty(), false);
			
			Map<String, Sales_Team_for_Coverage__c> SalesTeamForCoverageBySalesCodeMap = 
				SalesTeamForCoverageService.getSalesTeamCoverageForSalesCode(new Set<String>{oSalesTeamForCoverage.Coverage_ID__c});
			System.assertEquals(SalesTeamForCoverageBySalesCodeMap.isEmpty(), false);
		Test.stopTest();
	}
}