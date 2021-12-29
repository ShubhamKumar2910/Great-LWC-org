/*
	Author 		: Simon Foden
	Company 	: Nomura
	Date 		: 04/06/2018
	Description : Test class for the ETradingEnablementRequest  
				  controller class.
	
*/
@isTest
public class ETradingEnablementRequestControllerTest 
{
	static testMethod void readDataTest()
	{
        String userName = 'standarduser' + DateTime.now().getTime() + '@nomuratest.com';
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name='Nomura - Sales'];
                
        User testUser = new User(Alias = 'standt', Email='standarduser@nomuratest.com',
        						 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        						 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        						 TimeZoneSidKey='America/Los_Angeles',
         						 UserName=userName);
        insert testUser;
        
		PermissionSet eTradingEnablementPermissionSet = [SELECT Id, Name FROM PermissionSet WHERE Name = 'ETrading_Enablement_Admin'];
        
        PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment();
        permissionSetAssignment.AssigneeId = testUser.Id;
        permissionSetAssignment.PermissionSetId = eTradingEnablementPermissionSet.Id;
        insert permissionSetAssignment;

        System.runAs(testUser) 
        {
        	List<ETradingEnablementProduct__c> eTradingEnablementProducts = new List<ETradingEnablementProduct__c>();
		
			for (Integer productLoop = 0; productLoop <=8; productLoop++)
			{
				ETradingEnablementProduct__c eTradingEnablementProduct = new ETradingEnablementProduct__c();
				eTradingEnablementProduct.Category__c = 'TestCategory' + String.valueOf(productLoop); 	
				eTradingEnablementProduct.Subcategory__c = 'TestSubcategory' + String.valueOf(productLoop); 
				eTradingEnablementProduct.Product__c = 'TestProduct' + String.valueOf(productLoop); 
				eTradingEnablementProduct.ProductLabel__c = 'TestProductLabel' + String.valueOf(productLoop);

				if (productLoop == 7)
				{
					eTradingEnablementProduct.ClearingBilateral__c = true;
				}
				
				eTradingEnablementProducts.add(eTradingEnablementProduct);
			}		
			
			for (Integer productLoop = 0; productLoop <=3; productLoop++)
			{
				ETradingEnablementProduct__c eTradingEnablementProduct = new ETradingEnablementProduct__c();
				eTradingEnablementProduct.Category__c = 'TestCategory' + String.valueOf(productLoop); 	
				eTradingEnablementProduct.Product__c = 'TestProduct' + String.valueOf(productLoop); 
				eTradingEnablementProduct.ProductLabel__c = 'TestProductLabel' + String.valueOf(productLoop);
				
				eTradingEnablementProducts.add(eTradingEnablementProduct);
			}
			
			insert eTradingEnablementProducts;
        	
            Test.startTest();
            
            String eTradingEnablementDataJSON = ETradingEnablementRequestController.readData();
            
            ETradingEnablementRequestController.ETradingEnablementData eTradingEnablementData = new ETradingEnablementRequestController.ETradingEnablementData(); 
            eTradingEnablementData = (ETradingEnablementRequestController.ETradingEnablementData)JSON.deserialize(eTradingEnablementDataJSON, ETradingEnablementRequestController.ETradingEnablementData.class);
            
            System.assertEquals(eTradingEnablementData.error, false);
            System.assertEquals(eTradingEnablementData.errorMessage, '');
                        
            System.assert(eTradingEnablementData.platforms.size() > 0, true);
            System.assert(eTradingEnablementData.products.size() > 0, true);
            
            Test.stopTest();
        }
	}
	
	static testMethod void checkFieldLevelSecurityTest()
	{
		String userName = 'standarduser' + DateTime.now().getTime() + '@nomuratest.com';
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name='Nomura - Sales'];
        
        User testUser = new User(Alias = 'standt', Email='standarduser@nomuratest.com',
        						 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        						 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        						 TimeZoneSidKey='America/Los_Angeles',
         						 UserName=userName);
        insert testUser;
        
        // The ETrading_Enablement_Admin permission set is not applied to this user 
        // so a Field Level Security Error is raised

        System.runAs(testUser) 
        {
        	Test.startTest();
        	
			String eTradingEnablementDataJSON = ETradingEnablementRequestController.readData();
		
			ETradingEnablementRequestController.ETradingEnablementData eTradingEnablementData = new ETradingEnablementRequestController.ETradingEnablementData(); 
			eTradingEnablementData = (ETradingEnablementRequestController.ETradingEnablementData)JSON.deserialize(eTradingEnablementDataJSON, ETradingEnablementRequestController.ETradingEnablementData.class);
			
			System.assertEquals(eTradingEnablementData.error, true);
			System.assertNotEquals(eTradingEnablementData.errorMessage, '');
		
			Test.stopTest();
        }
	}
	
	static testMethod void insertRequestsTest()
	{
		String userName = 'standarduser' + DateTime.now().getTime() + '@nomuratest.com';
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name='Nomura - Sales'];
		
		User testUser = new User(Alias = 'standt', Email='standarduser04062018@nomuratest.com',
        						 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        						 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        						 TimeZoneSidKey='America/Los_Angeles',
         						 UserName=userName);
		insert testUser;
		
		Account account = new Account();
		account.name = 'Universal Exports';
		account.BillingStreet = '413 Longstream Road';
		account.BillingCity = 'London';
		account.BillingCountry = 'United Kingdom';
		insert account;
		
		Contact contact = new Contact();
		contact.Salutation = 'Mr.';
		contact.FirstName = 'James';
		contact.LastName = 'Bond';
		contact.Email = 'jamesbond04062018@univeralexports.com';
		contact.AccountId = account.Id; 
		insert contact;
		
		String[] contactIds = new String[]{};
		contactIds.add(contact.Id);
		
		Sales_Team_for_Coverage__c salesTeamForCoverage = new Sales_Team_for_Coverage__c();
		salesTeamForCoverage.Name = 'Test Sales Team for Coverage';
		salesTeamForCoverage.Active__c = true;
		salesTeamForCoverage.Coverage_ID__c = '007';
		salesTeamForCoverage.Sales_Desk_Region__c = 'USA';
		salesTeamForCoverage.Sales_Desk_Division__c = 'Fixed Income';
		salesTeamForCoverage.Sales_Team__c = 'Test Team';
		salesTeamForCoverage.OwnerId = testUser.Id; 
		insert salesTeamForCoverage; 
		 
		Sales_Team_User__c salesTeamUser = new Sales_Team_User__c();
		salesTeamUser.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
		salesTeamUser.User__c = testUser.Id;
		salesTeamUser.Source_Id__c = salesTeamForCoverage.Id + '#' + testUser.Id;
		insert salesTeamUser;
		
		Id coverageTeamMemberActiveRecordTypeId = Schema.getGlobalDescribe().get('Coverage_Team_Member__c').getDescribe().getRecordTypeInfosByName().get('Active Coverage').getRecordTypeId();
        
        Coverage_Team_Member__c coverageTeamMember = new Coverage_Team_Member__c();
        coverageTeamMember.RecordTypeId = coverageTeamMemberActiveRecordTypeId;
        coverageTeamMember.Account__c = account.Id;
        coverageTeamMember.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
        coverageTeamMember.Team_Member__c = salesTeamForCoverage.OwnerId;
		coverageTeamMember.Team_Role__c = 'Primary';
        insert coverageTeamMember;
		
		String[] platformIds = new String[]{};
		platformIds.add('Bloomberg');
		
		List<ETradingEnablementProduct__c> eTradingEnablementProducts = new List<ETradingEnablementProduct__c>();
		
		for (Integer productLoop = 0; productLoop <=8; productLoop++)
		{
			ETradingEnablementProduct__c eTradingEnablementProduct = new ETradingEnablementProduct__c();
			eTradingEnablementProduct.Category__c = 'TestCategory' + String.valueOf(productLoop); 	
			eTradingEnablementProduct.Subcategory__c = 'TestSubcategory' + String.valueOf(productLoop); 
			eTradingEnablementProduct.Product__c = 'TestProduct' + String.valueOf(productLoop); 
			eTradingEnablementProduct.ProductLabel__c = 'TestProductLabel' + String.valueOf(productLoop);
			eTradingEnablementProduct.ClearingBilateral__c = true;
			
			eTradingEnablementProducts.add(eTradingEnablementProduct);
		}		
		
		insert eTradingEnablementProducts;
		
		String salesCodeProducts = '{';
		salesCodeProducts += '  "salesCodeProducts": [';
		salesCodeProducts += '    {';
		salesCodeProducts += '      "salesCode": "' + salesTeamForCoverage.Id + '",';
		salesCodeProducts += '      "products": [';
		salesCodeProducts += '        "' + eTradingEnablementProducts[0].Id + '",';
		salesCodeProducts += '        "' + eTradingEnablementProducts[1].Id + '",';
		salesCodeProducts += '        "' + eTradingEnablementProducts[2].Id + '",';
		salesCodeProducts += '        "' + eTradingEnablementProducts[3].Id + '",';
		salesCodeProducts += '        "' + eTradingEnablementProducts[4].Id + '",';
		salesCodeProducts += '        "' + eTradingEnablementProducts[5].Id + '",';
		salesCodeProducts += '        "' + eTradingEnablementProducts[6].Id + '",';
		salesCodeProducts += '        "' + eTradingEnablementProducts[7].Id + '",';
		salesCodeProducts += '        "' + eTradingEnablementProducts[8].Id + '"';
		salesCodeProducts += '      ]';
		salesCodeProducts += '    }';
		salesCodeProducts += '  ]';
		salesCodeProducts += '}';
		
		String salesCodeCashRDMs = '{"salesCodeCashRDMs":[{"salesCode":"' + salesTeamForCoverage.Id + '","cashRDM":""}]}';
		String salesCodeCashRDMEntities = '{"salesCodeCashRDMEntities":[{"salesCode":"' + salesTeamForCoverage.Id + '","cashRDMEntity":""}]}';
		String salesCodeIRSRDMs = '{"salesCodeIRSRDMs":[{"salesCode":"' + salesTeamForCoverage.Id + '","irsRDM":""}]}';
		String salesCodeIRSRDMEntities = '{"salesCodeIRSRDMEntities":[{"salesCode":"' + salesTeamForCoverage.Id + '","irsRDMEntity":""}]}';
		String salesCodeRepoRDMs = '{"salesCodeRepoRDMs":[{"salesCode":"' + salesTeamForCoverage.Id + '","repoRDM":""}]}';
		String salesCodeRepoRDMEntities = '{"salesCodeRepoRDMEntities":[{"salesCode":"' + salesTeamForCoverage.Id + '","repoRDMEntity":""}]}';
	   
		Schema.DescribeFieldResult clearingHousesFieldResult = ETradingEnablement__c.Clearing_House__c.getDescribe();
		List<Schema.PicklistEntry> clearingHousesPicklistEntries = clearingHousesFieldResult.getPicklistValues();

		String clearingHouseValues = '';
		
		for (Schema.PicklistEntry clearingHousePicklistEntry : clearingHousesPicklistEntries)
		{
			clearingHouseValues += '"' + clearingHousePicklistEntry.getValue() + '"';

			if (clearingHousesPicklistEntries.indexOf(clearingHousePicklistEntry) != clearingHousesPicklistEntries.size() -1)
			{
				clearingHouseValues += ',';
			}
		}

     	String salesCodeClearings = '{"salesCodeClearings":[{"salesCode":"' + salesTeamForCoverage.Id + '","clearing":true}]}';
		String salesCodeBilaterals = '{"salesCodeBilaterals":[{"salesCode":"' + salesTeamForCoverage.Id + '","bilateral":true}]}';
		 
		String salesCodeClearingHouses = '{"salesCodeClearingHouses":[{"salesCode":"' + salesTeamForCoverage.Id + '","clearingHouses":[' + clearingHouseValues + ']}]}';

		Schema.DescribeFieldResult globalMarginRequirementsFieldResult = ETradingEnablement__c.Global_Margin_Requirements__c.getDescribe();
		List<Schema.PicklistEntry> globalMarginRequirementsPicklistEntries = globalMarginRequirementsFieldResult.getPicklistValues();

		Schema.PicklistEntry clearingHousePicklistEntry = globalMarginRequirementsPicklistEntries.get(0);
		String globalMarginRequirementsValues = '"' + clearingHousePicklistEntry.getValue() + '"';
		String salesCodeGlobalMarginRequirements = '{"salesCodeGlobalMarginRequirements":[{"salesCode":"' + salesTeamForCoverage.Id + '","globalMarginRequirements":' + globalMarginRequirementsValues + '}]}';
		
		Schema.DescribeFieldResult collateralCurrenciesFieldResult = ETradingEnablement__c.Collateral_Currencies__c.getDescribe();
		List<Schema.PicklistEntry> collateralCurrenciesPicklistEntries = collateralCurrenciesFieldResult.getPicklistValues();
		String collateralCurrenciesValues = '';
		
		for (Schema.PicklistEntry collateralCurrenciesPicklistEntry : collateralCurrenciesPicklistEntries)
		{
			collateralCurrenciesValues += '"' + collateralCurrenciesPicklistEntry.getValue() + '"';

			if (collateralCurrenciesPicklistEntries.indexOf(collateralCurrenciesPicklistEntry) != collateralCurrenciesPicklistEntries.size() -1)
			{
				collateralCurrenciesValues += ',';
			}
		}
		 
		String salesCodeCollateralCurrencies = '{"salesCodeCollateralCurrencies":[{"salesCode":"' + salesTeamForCoverage.Id + '","collateralCurrencies":[' + collateralCurrenciesValues + ']}]}';

 		Schema.DescribeFieldResult collateralTypesFieldResult = ETradingEnablement__c.Collateral_Types__c.getDescribe();
		List<Schema.PicklistEntry> collateralTypesPicklistEntries = collateralTypesFieldResult.getPicklistValues();

		Schema.PicklistEntry collateralTypesPicklistEntry = collateralTypesPicklistEntries.get(0);
		String collateralTypesValues = '"' + collateralTypesPicklistEntry.getValue() + '"';
		String salesCodeCollateralTypes = '{"salesCodeCollateralTypes":[{"salesCode":"' + salesTeamForCoverage.Id + '","collateralTypes":' + collateralTypesValues + '}]}';
		
		String salesCodeTenorRestriction = '{"salesCodeTenorRestrictions":[{"salesCode":"' + salesTeamForCoverage.Id + '","tenorRestriction":"Tenor Restriction"}]}		';
		String salesCodeBreakClause = '{"salesCodeBreakClauses":[{"salesCode":"' + salesTeamForCoverage.Id + '","breakClause":"Break Clause"}]}';

		String comments = 'Test Request';
		
		Test.startTest();
		
		ETradingEnablementRequestController.ETradingEnablementRequestData eTradingEnablementRequestData = new ETradingEnablementRequestController.ETradingEnablementRequestData();
		String eTradingEnablementRequestDataJSON = ETradingEnablementRequestController.insertRequests(contactIds, platformIds, salesCodeProducts, salesCodeCashRDMs, salesCodeCashRDMEntities, salesCodeIRSRDMs, salesCodeIRSRDMEntities, salesCodeRepoRDMs, salesCodeRepoRDMEntities, salesCodeClearings, salesCodeBilaterals, salesCodeClearingHouses, salesCodeGlobalMarginRequirements, salesCodeCollateralCurrencies, salesCodeCollateralTypes, salesCodeTenorRestriction, salesCodeBreakClause, comments); 
		eTradingEnablementRequestData = (ETradingEnablementRequestController.ETradingEnablementRequestData)JSON.deserializeStrict(eTradingEnablementRequestDataJSON, ETradingEnablementRequestController.ETradingEnablementRequestData.class); 
		
		System.assertEquals(eTradingEnablementRequestData.error, false);
		System.assertEquals(eTradingEnablementRequestData.errorMessage, '');
		
		ETradingEnablement__c request = [SELECT Id,  
										 Contact__c, 
										 Electronic_Platform__c, 
										 Comments__c, 
										 RecordType.Name   
										 FROM ETradingEnablement__c 
										 LIMIT 1];
										  
		System.assertEquals(request.Contact__c, contact.Id);
		System.assertEquals(request.Electronic_Platform__c, 'Bloomberg');
		
		String currentDate = Datetime.now().format('d-MMM-yyyy');
		String commentValue = request.Comments__c;
		if(System.UserInfo.getFirstName()!=null){
            System.assertEquals(commentValue.contains(System.UserInfo.getFirstName()), true); 
        }
            System.assertEquals(commentValue.contains(System.UserInfo.getLastName()), true);
            System.assertEquals(commentValue.contains(currentDate), true);
            System.assertEquals(commentValue.contains(comments), true);
       
        	if(request.RecordType.Name!=null)
		System.assertEquals(request.RecordType.Name, 'Request');
		
		Test.stopTest();
	} 
	
	static testMethod void insertRequestsErrorTest()
	{
		String userName = 'standarduser' + DateTime.now().getTime() + '@nomuratest.com';
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name='Nomura - Sales'];
		
		User testUser = new User(Alias = 'standt', Email='standarduser04062018@nomuratest.com',
        						 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        						 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        						 TimeZoneSidKey='America/Los_Angeles',
         						 UserName=userName);
		insert testUser;
		
		Account account = new Account();
		account.name = 'Universal Exports';
		account.BillingStreet = '413 Longstream Road';
		account.BillingCity = 'London';
		account.BillingCountry = 'United Kingdom';
		insert account;
		
		Contact contact = new Contact();
		contact.Salutation = 'Mr.';
		contact.FirstName = 'James';
		contact.LastName = 'Bond';
		contact.Email = 'jamesbond04062018@univeralexports.com';
		contact.AccountId = account.Id; 
		insert contact;
		
		String[] contactIds = new String[]{};
		contactIds.add(contact.Id);
		
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
		salesTeamUser.User__c = testUser.Id;
		salesTeamUser.Source_Id__c = salesTeamForCoverage.Id + '#' + testUser.Id;
		insert salesTeamUser;
		
		String[] platformIds = new String[]{};
		platformIds.add('Bloomberg');
		String salesCodeProducts = '{';
		salesCodeProducts += '"salesCodeProducts": [';
		salesCodeProducts += '    {';
		salesCodeProducts += '      "salesCode": "' + salesTeamForCoverage.Id + '",';
		salesCodeProducts += '      "products": [';
		salesCodeProducts += '        "Missing"';
		salesCodeProducts += '      ]';
		salesCodeProducts += '    }';
		salesCodeProducts += '  ]';
		salesCodeProducts += '}';
		
		String salesCodeCashRDMs = '{"salesCodeCashRDMs":[{"salesCode":"' + salesTeamForCoverage.Id + '","cashRDM":""}]}';
		String salesCodeCashRDMEntities = '{"salesCodeCashRDMEntities":[{"salesCode":"' + salesTeamForCoverage.Id + '","cashRDMEntity":""}]}';
		String salesCodeIRSRDMs = '{"salesCodeIRSRDMs":[{"salesCode":"' + salesTeamForCoverage.Id + '","irsRDM":""}]}';
		String salesCodeIRSRDMEntities = '{"salesCodeIRSRDMEntities":[{"salesCode":"' + salesTeamForCoverage.Id + '","irsRDMEntity":""}]}';
		String salesCodeRepoRDMs = '{"salesCodeRepoRDMs":[{"salesCode":"' + salesTeamForCoverage.Id + '","repoRDM":""}]}';
		String salesCodeRepoRDMEntities = '{"salesCodeRepoRDMEntities":[{"salesCode":"' + salesTeamForCoverage.Id + '","repoRDMEntity":""}]}';
		
		Schema.DescribeFieldResult clearingHousesFieldResult = ETradingEnablement__c.Clearing_House__c.getDescribe();
		List<Schema.PicklistEntry> clearingHousesPicklistEntries = clearingHousesFieldResult.getPicklistValues();

		String clearingHouseValues = '';
		
		for (Schema.PicklistEntry clearingHousePicklistEntry : clearingHousesPicklistEntries)
		{
			clearingHouseValues += '"' + clearingHousePicklistEntry.getValue() + '"';

			if (clearingHousesPicklistEntries.indexOf(clearingHousePicklistEntry) != clearingHousesPicklistEntries.size() -1)
			{
				clearingHouseValues += ',';
			}
		}

     	String salesCodeClearings = '{"salesCodeClearings":[{"salesCode":"' + salesTeamForCoverage.Id + '","clearing":true}]}';
		String salesCodeBilaterals = '{"salesCodeBilaterals":[{"salesCode":"' + salesTeamForCoverage.Id + '","bilateral":true}]}';
		 
		String salesCodeClearingHouses = '{"salesCodeClearingHouses":[{"salesCode":"' + salesTeamForCoverage.Id + '","clearingHouses":[' + clearingHouseValues + ']}]}';

		Schema.DescribeFieldResult globalMarginRequirementsFieldResult = ETradingEnablement__c.Global_Margin_Requirements__c.getDescribe();
		List<Schema.PicklistEntry> globalMarginRequirementsPicklistEntries = globalMarginRequirementsFieldResult.getPicklistValues();

		Schema.PicklistEntry clearingHousePicklistEntry = globalMarginRequirementsPicklistEntries.get(0);
		String globalMarginRequirementsValues = '"' + clearingHousePicklistEntry.getValue() + '"';
		String salesCodeGlobalMarginRequirements = '{"salesCodeGlobalMarginRequirements":[{"salesCode":"' + salesTeamForCoverage.Id + '","globalMarginRequirements":' + globalMarginRequirementsValues + '}]}';
		
		Schema.DescribeFieldResult collateralCurrenciesFieldResult = ETradingEnablement__c.Collateral_Currencies__c.getDescribe();
		List<Schema.PicklistEntry> collateralCurrenciesPicklistEntries = collateralCurrenciesFieldResult.getPicklistValues();
		String collateralCurrenciesValues = '';
		
		for (Schema.PicklistEntry collateralCurrenciesPicklistEntry : collateralCurrenciesPicklistEntries)
		{
			collateralCurrenciesValues += '"' + collateralCurrenciesPicklistEntry.getValue() + '"';

			if (collateralCurrenciesPicklistEntries.indexOf(collateralCurrenciesPicklistEntry) != collateralCurrenciesPicklistEntries.size() -1)
			{
				collateralCurrenciesValues += ',';
			}
		}
		 
		String salesCodeCollateralCurrencies = '{"salesCodeCollateralCurrencies":[{"salesCode":"' + salesTeamForCoverage.Id + '","collateralCurrencies":[' + collateralCurrenciesValues + ']}]}';

 		Schema.DescribeFieldResult collateralTypesFieldResult = ETradingEnablement__c.Collateral_Types__c.getDescribe();
		List<Schema.PicklistEntry> collateralTypesPicklistEntries = collateralTypesFieldResult.getPicklistValues();

		Schema.PicklistEntry collateralTypesPicklistEntry = collateralTypesPicklistEntries.get(0);
		String collateralTypesValues = '"' + collateralTypesPicklistEntry.getValue() + '"';
		String salesCodeCollateralTypes = '{"salesCodeCollateralTypes":[{"salesCode":"' + salesTeamForCoverage.Id + '","collateralTypes":' + collateralTypesValues + '}]}';
		
		String salesCodeTenorRestriction = '{"salesCodeTenorRestrictions":[{"salesCode":"' + salesTeamForCoverage.Id + '","tenorRestriction":"Tenor Restriction"}]}		';
		String salesCodeBreakClause = '{"salesCodeBreakClauses":[{"salesCode":"' + salesTeamForCoverage.Id + '","breakClause":"Break Clause"}]}';

		String comments = 'Test Request';
		
		Test.startTest();
		
		ETradingEnablementRequestController.ETradingEnablementRequestData eTradingEnablementRequestData = new ETradingEnablementRequestController.ETradingEnablementRequestData();
		
		String eTradingEnablementRequestDataJSON = ETradingEnablementRequestController.insertRequests(contactIds, platformIds, salesCodeProducts, salesCodeCashRDMs, salesCodeCashRDMEntities, salesCodeIRSRDMs, salesCodeIRSRDMEntities, salesCodeRepoRDMs, salesCodeRepoRDMEntities, salesCodeClearings, salesCodeBilaterals, salesCodeClearingHouses, salesCodeGlobalMarginRequirements, salesCodeCollateralCurrencies, salesCodeCollateralTypes, salesCodeTenorRestriction, salesCodeBreakClause, comments); 
		eTradingEnablementRequestData = (ETradingEnablementRequestController.ETradingEnablementRequestData)JSON.deserializeStrict(eTradingEnablementRequestDataJSON, ETradingEnablementRequestController.ETradingEnablementRequestData.class); 
		
		System.assertEquals(eTradingEnablementRequestData.error, true);
		System.assertEquals(eTradingEnablementRequestData.errorMessage, 'Unable to create requests : Invalid id: Missing');
		
		Test.stopTest();
	}

	static testMethod void insertRequestsEmptyPicklistValuesTest()
	{
		String userName = 'standarduser' + DateTime.now().getTime() + '@nomuratest.com';
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name='Nomura - Sales'];
		
		User testUser = new User(Alias = 'standt', Email='standarduser04062018@nomuratest.com',
        						 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        						 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        						 TimeZoneSidKey='America/Los_Angeles',
         						 UserName=userName);
		insert testUser;
		
		Account account = new Account();
		account.name = 'Universal Exports';
		account.BillingStreet = '413 Longstream Road';
		account.BillingCity = 'London';
		account.BillingCountry = 'United Kingdom';
		insert account;
		
		Contact contact = new Contact();
		contact.Salutation = 'Mr.';
		contact.FirstName = 'James';
		contact.LastName = 'Bond';
		contact.Email = 'jamesbond04062018@univeralexports.com';
		contact.AccountId = account.Id; 
		insert contact;
		
		String[] contactIds = new String[]{};
		contactIds.add(contact.Id);
		
		Sales_Team_for_Coverage__c salesTeamForCoverage = new Sales_Team_for_Coverage__c();
		salesTeamForCoverage.Name = 'Test Sales Team for Coverage';
		salesTeamForCoverage.Active__c = true;
		salesTeamForCoverage.Coverage_ID__c = '007';
		salesTeamForCoverage.Sales_Desk_Region__c = 'USA';
		salesTeamForCoverage.Sales_Desk_Division__c = 'Fixed Income';
		salesTeamForCoverage.Sales_Team__c = 'Test Team';
		salesTeamForCoverage.OwnerId = testUser.Id; 
		insert salesTeamForCoverage; 
		 
		Sales_Team_User__c salesTeamUser = new Sales_Team_User__c();
		salesTeamUser.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
		salesTeamUser.User__c = testUser.Id;
		salesTeamUser.Source_Id__c = salesTeamForCoverage.Id + '#' + testUser.Id;
		insert salesTeamUser;
		
		Id coverageTeamMemberActiveRecordTypeId = Schema.getGlobalDescribe().get('Coverage_Team_Member__c').getDescribe().getRecordTypeInfosByName().get('Active Coverage').getRecordTypeId();
        
        Coverage_Team_Member__c coverageTeamMember = new Coverage_Team_Member__c();
        coverageTeamMember.RecordTypeId = coverageTeamMemberActiveRecordTypeId;
        coverageTeamMember.Account__c = account.Id;
        coverageTeamMember.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
        coverageTeamMember.Team_Member__c = salesTeamForCoverage.OwnerId;
		coverageTeamMember.Team_Role__c = 'Primary';
        insert coverageTeamMember;
		
		String[] platformIds = new String[]{};
		platformIds.add('Bloomberg');
		
		List<ETradingEnablementProduct__c> eTradingEnablementProducts = new List<ETradingEnablementProduct__c>();
		
		for (Integer productLoop = 0; productLoop <=8; productLoop++)
		{
			ETradingEnablementProduct__c eTradingEnablementProduct = new ETradingEnablementProduct__c();
			eTradingEnablementProduct.Category__c = 'TestCategory' + String.valueOf(productLoop); 	
			eTradingEnablementProduct.Subcategory__c = 'TestSubcategory' + String.valueOf(productLoop); 
			eTradingEnablementProduct.Product__c = 'TestProduct' + String.valueOf(productLoop); 
			eTradingEnablementProduct.ProductLabel__c = 'TestProductLabel' + String.valueOf(productLoop);
			
			eTradingEnablementProducts.add(eTradingEnablementProduct);
		}		
		
		insert eTradingEnablementProducts;
		
		String salesCodeProducts = '{';
		salesCodeProducts += '  "salesCodeProducts": [';
		salesCodeProducts += '    {';
		salesCodeProducts += '      "salesCode": "' + salesTeamForCoverage.Id + '",';
		salesCodeProducts += '      "products": [';
		salesCodeProducts += '        "' + eTradingEnablementProducts[0].Id + '",';
		salesCodeProducts += '        "' + eTradingEnablementProducts[1].Id + '",';
		salesCodeProducts += '        "' + eTradingEnablementProducts[2].Id + '",';
		salesCodeProducts += '        "' + eTradingEnablementProducts[3].Id + '",';
		salesCodeProducts += '        "' + eTradingEnablementProducts[4].Id + '",';
		salesCodeProducts += '        "' + eTradingEnablementProducts[5].Id + '",';
		salesCodeProducts += '        "' + eTradingEnablementProducts[6].Id + '",';
		salesCodeProducts += '        "' + eTradingEnablementProducts[7].Id + '",';
		salesCodeProducts += '        "' + eTradingEnablementProducts[8].Id + '"';
		salesCodeProducts += '      ]';
		salesCodeProducts += '    }';
		salesCodeProducts += '  ]';
		salesCodeProducts += '}';
		
     	String salesCodeCashRDMs = '{"salesCodeCashRDMs":[{"salesCode":"' + salesTeamForCoverage.Id + '","cashRDM":""}]}';
		String salesCodeCashRDMEntities = '{"salesCodeCashRDMEntities":[{"salesCode":"' + salesTeamForCoverage.Id + '","cashRDMEntity":""}]}';
		String salesCodeIRSRDMs = '{"salesCodeIRSRDMs":[{"salesCode":"' + salesTeamForCoverage.Id + '","irsRDM":""}]}';
		String salesCodeIRSRDMEntities = '{"salesCodeIRSRDMEntities":[{"salesCode":"' + salesTeamForCoverage.Id + '","irsRDMEntity":""}]}';
		String salesCodeRepoRDMs = '{"salesCodeRepoRDMs":[{"salesCode":"' + salesTeamForCoverage.Id + '","repoRDM":""}]}';
		String salesCodeRepoRDMEntities = '{"salesCodeRepoRDMEntities":[{"salesCode":"' + salesTeamForCoverage.Id + '","repoRDMEntity":""}]}';
		String salesCodeClearings = '{"salesCodeClearings":[{"salesCode":"' + salesTeamForCoverage.Id + '","clearing":true}]}';
		String salesCodeBilaterals = '{"salesCodeBilaterals":[{"salesCode":"' + salesTeamForCoverage.Id + '","bilateral":true}]}';
		String salesCodeClearingHouses = ' {"salesCodeClearingHouses":[{"salesCode":"' + salesTeamForCoverage.Id + '","clearingHouses":[]}]}';
		String salesCodeGlobalMarginRequirements = '{"salesCodeGlobalMarginRequirements":[{"salesCode":"' + salesTeamForCoverage.Id + '"}]}';
		String salesCodeCollateralCurrencies = '{"salesCodeCollateralCurrencies":[{"salesCode":"' + salesTeamForCoverage.Id + '","collateralCurrencies":[]}]}';
		String salesCodeCollateralTypes = '{"salesCodeCollateralTypes":[{"salesCode":"' + salesTeamForCoverage.Id + '"}]}';
		String salesCodeTenorRestriction = '{"salesCodeTenorRestrictions":[{"salesCode":"' + salesTeamForCoverage.Id + '","tenorRestriction":""}]}		';
		String salesCodeBreakClause = '{"salesCodeBreakClauses":[{"salesCode":"' + salesTeamForCoverage.Id + '","breakClause":""}]}';

		String comments = 'Test Request';
		
		Test.startTest();
		
		ETradingEnablementRequestController.ETradingEnablementRequestData eTradingEnablementRequestData = new ETradingEnablementRequestController.ETradingEnablementRequestData();
		String eTradingEnablementRequestDataJSON = ETradingEnablementRequestController.insertRequests(contactIds, platformIds, salesCodeProducts, salesCodeCashRDMs, salesCodeCashRDMEntities, salesCodeIRSRDMs, salesCodeIRSRDMEntities, salesCodeRepoRDMs, salesCodeRepoRDMEntities, salesCodeClearings, salesCodeBilaterals, salesCodeClearingHouses, salesCodeGlobalMarginRequirements, salesCodeCollateralCurrencies, salesCodeCollateralTypes, salesCodeTenorRestriction, salesCodeBreakClause, comments); 
		eTradingEnablementRequestData = (ETradingEnablementRequestController.ETradingEnablementRequestData)JSON.deserializeStrict(eTradingEnablementRequestDataJSON, ETradingEnablementRequestController.ETradingEnablementRequestData.class); 
		
		System.assertEquals(eTradingEnablementRequestData.error, false);
		System.assertEquals(eTradingEnablementRequestData.errorMessage, '');
		
		ETradingEnablement__c request = [SELECT Id,  
										 Contact__c, 
										 Electronic_Platform__c, 
										 Comments__c, 
										 RecordType.Name   
										 FROM ETradingEnablement__c 
										 LIMIT 1];
										  
		System.assertEquals(request.Contact__c, contact.Id);
		System.assertEquals(request.Electronic_Platform__c, 'Bloomberg');
		
		String currentDate = Datetime.now().format('d-MMM-yyyy');
        String commentValue = request.Comments__c;
        if(System.UserInfo.getFirstName()!=null){
            System.assertEquals(commentValue.contains(System.UserInfo.getFirstName()), true);
        }
            System.assertEquals(commentValue.contains(System.UserInfo.getLastName()), true);
            System.assertEquals(commentValue.contains(currentDate), true);
            System.assertEquals(commentValue.contains(comments), true);
        
        
		if(request.RecordType.Name!=null){
		System.assertEquals(request.RecordType.Name, 'Request');
        }
		Test.stopTest();
	} 
}