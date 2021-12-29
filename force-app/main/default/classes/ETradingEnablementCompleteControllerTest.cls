/*
	Author 		: Pravin Kundal
	Company 	: Nomura
	Date 		: 01/04/2019
	Description : Tests for the ETradingEnablementCompleteController class.        			  
*/
@isTest
public class ETradingEnablementCompleteControllerTest {
	static testMethod void testSuccessScenario() {
		// insert test data
		Account sLevel = UtilityTesting.createRSAccount(
                'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        insert sLevel;
        Account rg1 = UtilityTesting.createRGAccount(
                'G Test Account', sLevel.Id, 'Test2', '52nd Street', 'California', 'United States', true);
        insert rg1;
        Account rg1rm1 = UtilityTesting.createRMAccount(
                'RM Test Account 1', rg1.Id, 'Test3', '52nd Street', 'California', 'United States', true);
        insert rg1rm1;

		List<Contact> ContactList = new List<Contact>(); 
		// Contact 1
		Contact c1 = UtilityTesting.createContact('John', 'Smith', 'johnnysmith@test.com', '(212) 333-4567', 'Dear [FirstName]', rg1rm1.Id, true);
        ContactList.add(c1);
        // Contact 2
        Contact c2 = UtilityTesting.createContact('James', 'Smith', 'jamessmith@test.com', '(212) 333-4567', 'Dear [FirstName]', rg1rm1.Id, true);
        ContactList.add(c2);
        insert ContactList; 
		
		Sales_Team_for_Coverage__c salesTeamForCoverage = new Sales_Team_for_Coverage__c();
		salesTeamForCoverage.Name = 'Test Sales Team for Coverage';
		salesTeamForCoverage.Active__c = true;
		salesTeamForCoverage.Coverage_ID__c = '007';
		salesTeamForCoverage.Sales_Desk_Region__c = 'USA';
		salesTeamForCoverage.Sales_Desk_Division__c = 'Fixed Income';
		salesTeamForCoverage.Sales_Team__c = 'Test Team';
		insert salesTeamForCoverage; 
			
		Sales_Team_User__c salesTeamUser = new Sales_Team_User__c();
		salesTeamUser.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
		salesTeamUser.User__c = UserInfo.getUserId();
		salesTeamUser.Source_Id__c = salesTeamForCoverage.Id + '#' + UserInfo.getUserId();
		insert salesTeamUser;
		
		List<ETradingEnablementProduct__c> ETProductList = new List<ETradingEnablementProduct__c>();
		// Product 1
		ETradingEnablementProduct__c eTProd1 = new ETradingEnablementProduct__c();
		eTProd1.Category__c = 'Credit Cash';
		eTProd1.Subcategory__c = 'US Cash Credit'; 
		eTProd1.Product__c = 'CC_US_FRN'; 
		eTProd1.ProductLabel__c = 'FRN';
		ETProductList.add(eTProd1);
		// Product 2
		ETradingEnablementProduct__c eTProd2 = new ETradingEnablementProduct__c();
		eTProd2.Category__c = 'Credit Cash'; 	
		eTProd2.Subcategory__c = 'US Cash Credit'; 
		eTProd2.Product__c = 'CC_US_HY'; 
		eTProd2.ProductLabel__c = 'HY';
		ETProductList.add(eTProd2);
		insert ETProductList;
		
		List<ContactPlatform__c> ContPlatList = new List<ContactPlatform__c>();
		// Contact Platform 1
		ContactPlatform__c oCP1 = new ContactPlatform__c();
		oCP1.Name='B_c1_PFID1';
		oCP1.Contact__c=c1.Id;
		oCP1.Platform__c='Bloomberg';
		oCP1.Email__c='email1_c1_@test.com';
		ContPlatList.add(oCP1);
		// Contact Platform 2
		ContactPlatform__c oCP2 = new ContactPlatform__c();
		oCP2.Name='B_c2_PFID2';
		oCP2.Contact__c=c2.Id;
		oCP2.Platform__c='Bloomberg';
		oCP2.Email__c='email1_c2_@test.com';
		ContPlatList.add(oCP2);
		insert ContPlatList;
		
		List<ETradingEnablement__c> ETradingList = new List<ETradingEnablement__c>();
		// ET 1
		ETradingEnablement__c eET1= new ETradingEnablement__c();
	 	eET1.Contact__c = c1.Id;
		eET1.ETradingEnablementProduct__c = eTProd1.Id;
		eET1.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
		eET1.Electronic_Platform__c='Bloomberg';
	    eET1.Comments__c = 'Test Request1';
	    ETradingList.add(eET1);
	    // ET 2
		ETradingEnablement__c eET2= new ETradingEnablement__c();
	 	eET2.Contact__c = c2.Id;
		eET2.ETradingEnablementProduct__c = eTProd2.Id;
		eET2.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
		eET2.Electronic_Platform__c='Bloomberg';
	    eET2.Comments__c = 'Test Request2';
	    eET2.Platform_Id__c = 'testPFId100';
	    ETradingList.add(eET2);
	    insert ETradingList;
	    
	    Boolean isErr = false;
	    ETradingEnablementCompleteController.ETradingToCompleteData eTData;
	    ETradingEnablementCompleteController.CompleteETEnablementResult eTCompleteRslt;
	    Test.Starttest();
	    	try {
	    		List<String> ETRecIdList = new List<String>();
	    		ETRecIdList.add(eET1.Id);
	    		ETRecIdList.add(eET2.Id);
	    		eTData = ETradingEnablementCompleteController.getEtradingEnablementToCompleteData(ETRecIdList);
				String eTDataStr = JSON.serialize(eTData);
				System.debug('eTDataStr : '+eTDataStr);
	    		eTCompleteRslt = ETradingEnablementCompleteController.completeEtradingEnablements(eTDataStr, 'Add');
	    	} catch( Exception ex) {
	    		System.debug('Error : '+ex.getMessage());
	    		isErr = true;
	    	}
	    Test.Stoptest();
	    System.assertEquals(isErr, false);
	    System.assertNotEquals(eTData, null);
	    System.assertNotEquals(eTCompleteRslt, null);
	    Map<String, ETradingEnablement__c> ETCoverageMap = new Map<String, ETradingEnablement__c>([SELECT Id, Name, Status__c, RecordType.Name FROM ETradingEnablement__c 
	    	WHERE RecordTypeId = :(ETradingEnablementService.ETERecTypeInfoByRecTypeDevNameMap.get(ETradingEnablementService.ETE_RT_NAME_COVERAGE).getRecordTypeId())]); 
    	System.assertEquals(ETCoverageMap.size(), 3);


		// Revoke Scenario
		ETradingEnablementService.createRevokeETradingRequests(new List<String>(ETCoverageMap.keySet()), 'Test Comment');
		Map<String, ETradingEnablement__c> ETRevokeReqMap = new Map<String, ETradingEnablement__c>([SELECT Id, Name, Parent_Coverage__c, RecordType.Name, Status__c FROM ETradingEnablement__c WHERE Request_Type__c='Revoke']);
		System.debug('ETRevokeReqMap : '+ETRevokeReqMap);
		System.debug('ETRevokeReqMap size : '+ETRevokeReqMap.size());
		eTData = ETradingEnablementCompleteController.getEtradingEnablementToCompleteData(new List<String>(ETRevokeReqMap.keySet()));
		System.debug('eTData :'+eTData);
		String eTDataStr = JSON.serialize(eTData);
		ETradingEnablementTriggerHandler.isCompleteEtradingReqExecuted = false;
		ETradingEnablementTriggerHandler.ETAddRequestIdToCompleteSet.clear();
		eTCompleteRslt = ETradingEnablementCompleteController.completeEtradingEnablements(eTDataStr, 'Revoke');
		System.debug('eTCompleteRslt : '+eTCompleteRslt);
		System.debug('eTCompleteRslt.hasErrors : '+eTCompleteRslt.hasErrors);
		System.debug('eTCompleteRslt.cov : '+eTCompleteRslt.ETEnablementUpdateResultList[0].ETradingCoverageList[0]);
		System.debug('eTCompleteRslt.cov : '+eTCompleteRslt.ETEnablementUpdateResultList[0].ETradingCoverageList[0].status);
		System.assertNotEquals(eTData, null);
	    System.assertNotEquals(eTCompleteRslt, null);
		List<ETradingEnablement__c> ETRevokedCoverageList = [SELECT Id, Name, Status__c, RecordType.Name FROM ETradingEnablement__c 
	    	WHERE RecordTypeId = :(ETradingEnablementService.ETERecTypeInfoByRecTypeDevNameMap.get(ETradingEnablementService.ETE_RT_NAME_COVERAGE).getRecordTypeId()) AND
				Status__c='Inactive']; 
		System.debug('ETRevokedCoverageList : '+ETRevokedCoverageList);
		System.assertEquals(ETRevokedCoverageList.size(), 3);


	}
	
	static testMethod void testErrorScenario() {
		// insert test data
		Account sLevel = UtilityTesting.createRSAccount(
                'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        insert sLevel;
        Account rg1 = UtilityTesting.createRGAccount(
                'G Test Account', sLevel.Id, 'Test2', '52nd Street', 'California', 'United States', true);
        insert rg1;
        Account rg1rm1 = UtilityTesting.createRMAccount(
                'RM Test Account 1', rg1.Id, 'Test3', '52nd Street', 'California', 'United States', true);
        insert rg1rm1;

		List<Contact> ContactList = new List<Contact>(); 
		// Contact 1
		Contact c1 = UtilityTesting.createContact('John', 'Smith', 'johnnysmith@test.com', '(212) 333-4567', 'Dear [FirstName]', rg1rm1.Id, true);
        ContactList.add(c1);
        // Contact 2
        Contact c2 = UtilityTesting.createContact('James', 'Smith', 'jamessmith@test.com', '(212) 333-4568', 'Dear [FirstName]', rg1rm1.Id, true);
        ContactList.add(c2);
        // Contact 2
        Contact c3 = UtilityTesting.createContact('Jonty', 'Rhodes', 'rhodes@test.com', '(212) 333-4569', 'Dear [FirstName]', rg1rm1.Id, true);
        ContactList.add(c3);
        insert ContactList; 
		
		Sales_Team_for_Coverage__c salesTeamForCoverage = new Sales_Team_for_Coverage__c();
		salesTeamForCoverage.Name = 'Test Sales Team for Coverage';
		salesTeamForCoverage.Active__c = true;
		salesTeamForCoverage.Coverage_ID__c = '007';
		salesTeamForCoverage.Sales_Desk_Region__c = 'USA';
		salesTeamForCoverage.Sales_Desk_Division__c = 'Fixed Income';
		salesTeamForCoverage.Sales_Team__c = 'Test Team';
		insert salesTeamForCoverage; 
			
		Sales_Team_User__c salesTeamUser = new Sales_Team_User__c();
		salesTeamUser.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
		salesTeamUser.User__c = UserInfo.getUserId();
		salesTeamUser.Source_Id__c = salesTeamForCoverage.Id + '#' + UserInfo.getUserId();
		insert salesTeamUser;
		
		List<ETradingEnablementProduct__c> ETProductList = new List<ETradingEnablementProduct__c>();
		// Product 1
		ETradingEnablementProduct__c eTProd1 = new ETradingEnablementProduct__c();
		eTProd1.Category__c = 'Credit Cash';
		eTProd1.Subcategory__c = 'US Cash Credit'; 
		eTProd1.Product__c = 'CC_US_FRN'; 
		eTProd1.ProductLabel__c = 'FRN';
		ETProductList.add(eTProd1);
		// Product 2
		ETradingEnablementProduct__c eTProd2 = new ETradingEnablementProduct__c();
		eTProd2.Category__c = 'Credit Cash'; 	
		eTProd2.Subcategory__c = 'US Cash Credit'; 
		eTProd2.Product__c = 'CC_US_HY'; 
		eTProd2.ProductLabel__c = 'HY';
		ETProductList.add(eTProd2);
		insert ETProductList;
		
		List<ContactPlatform__c> ContPlatList = new List<ContactPlatform__c>();
		// Contact Platform 1
		ContactPlatform__c oCP1 = new ContactPlatform__c();
		oCP1.Name='B_c1_PFID1';
		oCP1.Contact__c=c1.Id;
		oCP1.Platform__c='Bloomberg';
		oCP1.Email__c='email1_c1_@test.com';
		ContPlatList.add(oCP1);
		// Contact Platform 2
		ContactPlatform__c oCP2 = new ContactPlatform__c();
		oCP2.Name='B_c2_PFID2';
		oCP2.Contact__c=c2.Id;
		oCP2.Platform__c='Bloomberg';
		oCP2.Email__c='email1_c2_@test.com';
		ContPlatList.add(oCP2);
		insert ContPlatList;
		
		List<ETradingEnablement__c> ETradingList = new List<ETradingEnablement__c>();
		// ET 1
		ETradingEnablement__c eET1= new ETradingEnablement__c();
	 	eET1.Contact__c = c1.Id;
		eET1.ETradingEnablementProduct__c = eTProd1.Id;
		eET1.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
		eET1.Electronic_Platform__c='Bloomberg';
	    eET1.Comments__c = 'Test Request1';
	    ETradingList.add(eET1);
	    // ET 2
		ETradingEnablement__c eET2= new ETradingEnablement__c();
	 	eET2.Contact__c = c2.Id;
		eET2.ETradingEnablementProduct__c = eTProd2.Id;
		eET2.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
		eET2.Electronic_Platform__c='Bloomberg';
	    eET2.Comments__c = 'Test Request2';
	    eET2.Platform_Id__c = 'testPFId100';
	    ETradingList.add(eET2);
	    // ET 3
		ETradingEnablement__c eET3= new ETradingEnablement__c();
	 	eET3.Contact__c = c1.Id;
		eET3.ETradingEnablementProduct__c = eTProd2.Id;
		eET3.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
		eET3.Electronic_Platform__c='Bloomberg';
	    eET3.Comments__c = 'Test Request3';
	    eET3.Platform_Id__c = 'testPFId100';
	    ETradingList.add(eET3);
	    // ET 4
		ETradingEnablement__c eET4 = new ETradingEnablement__c();
	 	eET4.Contact__c = c3.Id;
		eET4.ETradingEnablementProduct__c = eTProd1.Id;
		eET4.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
		eET4.Electronic_Platform__c='Bloomberg';
	    eET4.Comments__c = 'Test Request4';
	    ETradingList.add(eET4);
	    insert ETradingList;
	    
	    Boolean isErr = false;
	    ETradingEnablementCompleteController.ETradingToCompleteData eTData;
	    ETradingEnablementCompleteController.CompleteETEnablementResult eTCompleteRslt;
	    Test.Starttest();
	    	try {
	    		List<String> ETRecIdList = new List<String>();
	    		ETRecIdList.add(eET1.Id);
	    		ETRecIdList.add(eET2.Id);
	    		ETRecIdList.add(eET3.Id);
	    		ETRecIdList.add(eET4.Id);
	    		eTData = ETradingEnablementCompleteController.getEtradingEnablementToCompleteData(ETRecIdList);
				String eTDataStr = JSON.serialize(eTData);	    				
	    		eTCompleteRslt = ETradingEnablementCompleteController.completeEtradingEnablements(eTDataStr, 'Add');
	    	} catch( Exception ex) {
	    		System.debug('Error : '+ex.getMessage());
	    		isErr = true;
	    	}
	    Test.Stoptest();
	    System.assertEquals(isErr, false);
	    System.assertNotEquals(eTData, null);
	    System.assertNotEquals(eTCompleteRslt, null);
	    Integer countCovRecs = [SELECT count() FROM ETradingEnablement__c 
	    	WHERE RecordTypeId = :(ETradingEnablementService.ETERecTypeInfoByRecTypeDevNameMap.get(ETradingEnablementService.ETE_RT_NAME_COVERAGE).getRecordTypeId())]; 
    	System.assertEquals(countCovRecs, 0);
	}
}