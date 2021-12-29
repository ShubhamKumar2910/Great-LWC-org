@isTest
private class ETradingEnablementHomeControllerTest {
	// Author : Pravin Kundal
	static testMethod void testGetEtradingEnablementCoverage() {
		String userName = 'standarduser' + DateTime.now().getTime() + '@nomuratest.com';
		Profile testProfile = [SELECT Id FROM Profile WHERE Name='Nomura - Sales'];
		User testUser = new User(Alias = 'standt', Email='standarduser@nomuratest.com',
									EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
									LocaleSidKey='en_US', ProfileId = testProfile.Id,
									TimeZoneSidKey='America/Los_Angeles',
									UserName=userName);
		insert testUser;
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

		Sales_Team_for_Coverage__c salesTeamForCoverage2 = new Sales_Team_for_Coverage__c();
		salesTeamForCoverage2.Name = 'Test Sales Team for Coverage2';
		salesTeamForCoverage2.Active__c = true;
		salesTeamForCoverage2.Coverage_ID__c = '008';
		salesTeamForCoverage2.Sales_Desk_Region__c = 'USA';
		salesTeamForCoverage2.Sales_Desk_Division__c = 'Fixed Income';
		salesTeamForCoverage2.Sales_Team__c = 'Test Team2';
		salesTeamForCoverage2.OwnerId = testUser.Id;
		insert salesTeamForCoverage2; 
			
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
		eET1.Status__c='To Be Processed';
		eET1.RecordTypeId=ETradingEnablementService.ETERecTypeInfoByRecTypeDevNameMap.get(ETradingEnablementService.ETE_RT_NAME_REQUEST).getRecordTypeId();
	    ETradingList.add(eET1);
	    // ET 2
		ETradingEnablement__c eET2= new ETradingEnablement__c();
	 	eET2.Contact__c = c2.Id;
		eET2.ETradingEnablementProduct__c = eTProd2.Id;
		eET2.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
		eET2.Electronic_Platform__c='Bloomberg';
	    eET2.Comments__c = 'Test Request2';
	    eET2.Platform_Id__c = 'testPFId100';
		eET2.RecordTypeId=ETradingEnablementService.ETERecTypeInfoByRecTypeDevNameMap.get(ETradingEnablementService.ETE_RT_NAME_REQUEST).getRecordTypeId();
	    ETradingList.add(eET2);
	    insert ETradingList;
	    
	    Boolean isErr = false;
	    ETradingEnablementHomeController.ETradingCoverageData eTradingData;
	    Test.Starttest();
	    	try {
				eTradingData = ETradingEnablementHomeController.getEtradingEnablementCoverage(true, 
					new List<String>{'To Be Processed', 'Pending Approaval', 'Being Processed'},
					new List<String>{'Bloomberg'}, new List<String>{eTProd1.Id, eTProd2.Id},
					new List<String>(), 'Request', new List<String>(), new List<String>(), 2000);

					eTradingData = ETradingEnablementHomeController.getEtradingEnablementCoverage(false, 
					new List<String>{'To Be Processed', 'Pending Approaval', 'Being Processed'},
					new List<String>{'Bloomberg'}, new List<String>{eTProd1.Id, eTProd2.Id},
					new List<String>(), 'Request', new List<String>(), new List<String>(), 2000);
	    	} catch( Exception ex) {
	    		System.debug('Error : '+ex.getMessage());
	    		isErr = true;
	    	}
	    Test.Stoptest();
	    System.assertEquals(isErr, false);
	    System.assertNotEquals(eTradingData, null);
	}

	
	// Author : Pravin Kundal
	static testMethod void testUpdateSalesCodeEtradingEnablement() {
		String userName = 'standarduser' + DateTime.now().getTime() + '@nomuratest.com';
		Profile testProfile = [SELECT Id FROM Profile WHERE Name='Nomura - Sales'];
		User testUser = new User(Alias = 'standt', Email='standarduser@nomuratest.com',
									EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
									LocaleSidKey='en_US', ProfileId = testProfile.Id,
									TimeZoneSidKey='America/Los_Angeles',
									UserName=userName);
		insert testUser;
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

		Sales_Team_for_Coverage__c salesTeamForCoverage2 = new Sales_Team_for_Coverage__c();
		salesTeamForCoverage2.Name = 'Test Sales Team for Coverage2';
		salesTeamForCoverage2.Active__c = true;
		salesTeamForCoverage2.Coverage_ID__c = '008';
		salesTeamForCoverage2.Sales_Desk_Region__c = 'USA';
		salesTeamForCoverage2.Sales_Desk_Division__c = 'Fixed Income';
		salesTeamForCoverage2.Sales_Team__c = 'Test Team2';
		salesTeamForCoverage2.OwnerId = testUser.Id;
		insert salesTeamForCoverage2; 
			
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
		eET1.Status__c='To Be Processed';
		eET1.RecordTypeId=ETradingEnablementService.ETERecTypeInfoByRecTypeDevNameMap.get(ETradingEnablementService.ETE_RT_NAME_REQUEST).getRecordTypeId();
	    ETradingList.add(eET1);
	    // ET 2
		ETradingEnablement__c eET2= new ETradingEnablement__c();
	 	eET2.Contact__c = c2.Id;
		eET2.ETradingEnablementProduct__c = eTProd2.Id;
		eET2.Sales_Team_for_Coverage__c = salesTeamForCoverage2.Id;
		eET2.Electronic_Platform__c='Bloomberg';
	    eET2.Comments__c = 'Test Request2';
	    eET2.Platform_Id__c = 'testPFId100';
		eET2.RecordTypeId=ETradingEnablementService.ETERecTypeInfoByRecTypeDevNameMap.get(ETradingEnablementService.ETE_RT_NAME_REQUEST).getRecordTypeId();
	    ETradingList.add(eET2);
	    insert ETradingList;
	    

		String fieldUpdateListParam = '{"ETEnablementUpdateParamsList":[{"colFieldName":"comments","fieldApiName":"Comments__c","fieldVal":"Pravin Kundal, 17-5-2019 - test1"},{"colFieldName":"salesPersonId","fieldApiName":"Sales_Team_for_Coverage__c","fieldVal":"a0G0p000000D6R7EAK"}]}';
		String fieldPostUpdateListParam = '{"ETEnablementUpdateParamsList":[{"colFieldName":"salesPersonName","fieldApiName":"Sales_Team_for_Coverage__r.Name"},{"colFieldName":"status","fieldApiName":"Status__c"}]}';
		List<ETradingEnablement__c> EtradingEnablementList = new List<ETradingEnablement__c>(); 
		EtradingEnablementList.add(new ETradingEnablement__c(Id=eET2.Id, Comments__c='test comment 1', Sales_Team_for_Coverage__c=salesTeamForCoverage.Id));

	    Boolean isErr = false;
	    ETradingEnablementHomeController.ETEnablementUpdateResult eTradingUpdResult;
	    Test.Starttest();
	    	try {
				eTradingUpdResult = ETradingEnablementHomeController.updateEtradingEnablement(fieldUpdateListParam, UserInfo.getUserId(),
					EtradingEnablementList, fieldPostUpdateListParam);
	    	} catch( Exception ex) {
	    		System.debug('Error : '+ex.getMessage());
	    		isErr = true;
	    	}
	    Test.Stoptest();
	    System.assertEquals(isErr, false);
	    System.assertNotEquals(eTradingUpdResult, null);
	}

    static testMethod void verifyGetEtradingEnablementCoverage() 
    {
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
		
		Contact contact = ContactTestData.getContact(rg1rm1.Id);
		insert contact;
		
		Sales_Team_for_Coverage__c salesTeamForCoverage = new Sales_Team_for_Coverage__c();
		salesTeamForCoverage.Active__c = true;
		salesTeamForCoverage.Coverage_ID__c = '007';
		salesTeamForCoverage.Name = 'Test Sales Team for Coverage';
        salesTeamForCoverage.Sales_Desk_Region__c = 'USA';
        salesTeamForCoverage.Sales_Desk_Division__c = 'Fixed Income';
        salesTeamForCoverage.Sales_Team__c = 'Test Team';
        salesTeamForCoverage.OwnerId = UserInfo.getUserId();
        insert salesTeamForCoverage;
 		
		ETradingEnablementProduct__c eTradingEnablementProduct = new ETradingEnablementProduct__c();
		eTradingEnablementProduct.Category__c = 'TestCategory'; 	
		eTradingEnablementProduct.Subcategory__c = 'TestSubcategory'; 
		eTradingEnablementProduct.Product__c = 'TestProduct'; 
		eTradingEnablementProduct.ProductLabel__c = 'TestProductLabel';
		insert eTradingEnablementProduct;

		ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
	 	eTradingEnablement.Contact__c = contact.Id;
		eTradingEnablement.ETradingEnablementProduct__c = eTradingEnablementProduct.Id;
		eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	    eTradingEnablement.Comments__c = 'Test Request';
	    insert eTradingEnablement;
    	
		ETradingEnablement__c eTradingEnablement2 = new ETradingEnablement__c();
	 	eTradingEnablement2.Contact__c = contact.Id;
		eTradingEnablement2.ETradingEnablementProduct__c = eTradingEnablementProduct.Id;
		eTradingEnablement2.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	    eTradingEnablement2.Comments__c = 'Test Request';
	    insert eTradingEnablement2;

		Test.startTest();
        
        	ETradingEnablementHomeController.ETradingCoverageData etData = ETradingEnablementHomeController.getEtradingEnablementCoverage(
        		false,
        		new List<String>{'To Be Processed'},
				new List<String>{'Bloomberg'},
				new List<String>{'Gilts'},
				new List<String>{rg1.id},
				'Request',
				new List<String>{salesTeamForCoverage.id},
				new List<String>{contact.Id},
				1);
			
			//System.assertEquals(etData.ETadingEnablementWrapperList.size(), 1);

			// verify attach file //
			// insert test file
			ContentVersion testFile = new ContentVersion(); 
			testFile.ContentURL='http://www.google.com/'; 
			testFile.Title ='Google.com'; 
			testFile.FirstPublishLocationId =  eTradingEnablement.Id;        
			insert testFile; 

			List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

			List<ETradingEnablementHomeController.ETadingEnablementWrapper> eTradingEnablementList = new List<ETradingEnablementHomeController.ETadingEnablementWrapper>();
			ETradingEnablementHomeController.ETadingEnablementWrapper eEW1 = new ETradingEnablementHomeController.ETadingEnablementWrapper(1, eTradingEnablement);
			eTradingEnablementList.add(eEW1);
			ETradingEnablementHomeController.ETadingEnablementWrapper eEW2= new ETradingEnablementHomeController.ETadingEnablementWrapper(2, eTradingEnablement2);
			eTradingEnablementList.add(eEW2);

			ETradingEnablementHomeController.attachFile(String.valueOf(documents[0].id), 
					String.valueOf(eTradingEnablement.id), 'test comment', System.JSON.serialize(eTradingEnablementList));
			
			// verify delete attach file
			ETradingEnablementHomeController.deleteAttachFile(String.valueOf(documents[0].id));

        Test.stopTest();
    }

}