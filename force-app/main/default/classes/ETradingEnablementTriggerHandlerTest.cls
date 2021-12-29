/*
	Author 		: Simon Foden
	Company 	: Nomura
	Date 		: 04/07/2018
	Description : Tests for the ETradingEnablementTriggerHandler         
				  trigger handler.
	
*/
@isTest
private class ETradingEnablementTriggerHandlerTest 
{
    static testMethod void skipApprovalTest()
    {
		Id rmAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
		Account account = AccountTestData.getAccount();
		account.RecordTypeId = rmAccountRecordTypeId; 
		insert account;
		
		Contact contact = ContactTestData.getContact(account.Id);
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
        
        Id coverageTeamMemberActiveRecordTypeId = Schema.getGlobalDescribe().get('Coverage_Team_Member__c').getDescribe().getRecordTypeInfosByName().get('Active Coverage').getRecordTypeId();
        
        Coverage_Team_Member__c coverageTeamMember = new Coverage_Team_Member__c();
        coverageTeamMember.RecordTypeId = coverageTeamMemberActiveRecordTypeId;
        coverageTeamMember.Account__c = account.Id;
        coverageTeamMember.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
        coverageTeamMember.Team_Member__c = salesTeamForCoverage.OwnerId;
		coverageTeamMember.Team_Role__c = 'Primary';
        insert coverageTeamMember; 
        
 		List<ETradingEnablementProduct__c> eTradingEnablementProducts = new List<ETradingEnablementProduct__c>();
		
		ETradingEnablementProduct__c eTradingEnablementProduct = new ETradingEnablementProduct__c();
		eTradingEnablementProduct.Category__c = 'TestCategory'; 	
		eTradingEnablementProduct.Subcategory__c = 'TestSubcategory'; 
		eTradingEnablementProduct.Product__c = 'TestProduct'; 
		eTradingEnablementProduct.ProductLabel__c = 'TestProductLabel';
		eTradingEnablementProducts.add(eTradingEnablementProduct);
	
		ETradingEnablementProduct__c eTradingEnablementProduct2 = new ETradingEnablementProduct__c();
		eTradingEnablementProduct2.Category__c = 'TestCategory 2'; 	
		eTradingEnablementProduct2.Product__c = 'TestProduct 2'; 
		eTradingEnablementProduct2.ProductLabel__c = 'TestProductLabel 2';
		eTradingEnablementProducts.add(eTradingEnablementProduct2);
 		
 		insert eTradingEnablementProducts;
 		
 		Id eTradingEnablementRequestRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Request').getRecordTypeId();
 		
		ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
		eTradingEnablement.RecordTypeId = eTradingEnablementRequestRecordTypeId;
	 	eTradingEnablement.Contact__c = contact.Id;
	    eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
		eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	    eTradingEnablement.ETradingEnablementProduct__c = eTradingEnablementProduct2.Id;  
	    eTradingEnablement.Comments__c = 'Test Request';
	    
	    Test.startTest();
	    
	    insert eTradingEnablement;
	    
	    eTradingEnablement = [SELECT Id,
							  Comments__c,  
							  Contact__c, 
							  //Coverage__c, 
							  CreatedDate, 
							  Electronic_Platform__c, 
							  Name, 
							  ETradingEnablementProduct__c, 
							  RecordTypeId, 
							  Sales_Team_for_Coverage__c,  
							  Status__c  
	    					  FROM ETradingEnablement__c 
	    					  WHERE Id = :eTradingEnablement.Id];
	    				
		System.assertEquals(eTradingEnablement.Status__c, 'To Be Processed');
		
	  	Test.stopTest();	    
    }
    
   	static testMethod void sendEmailTests()
	{
		// There isn't an Assert method in this test method as there 
	    // should be as there isn't a way of confirming an email has 
	    // been sent from a test method and System.enqueueJob doesn't 
	    // return a Job Id in a test that can be used to query the result.
	    
	    Profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		
		User testUser = new User(Alias = 'test', Email='testuser@nomuratest.com',
        					 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        					 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        					 TimeZoneSidKey='America/Los_Angeles',
         					 UserName='testuser@nomuratest.com');
         					 
        insert testUser;
        
        Id rmAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
		Account account = AccountTestData.getAccount();
		account.RecordTypeId = rmAccountRecordTypeId; 
		insert account;
		
		Contact contact = ContactTestData.getContact(account.Id);
		insert contact;
		
		Sales_Team_for_Coverage__c salesTeamForCoverage = new Sales_Team_for_Coverage__c();
		salesTeamForCoverage.Active__c = true;
		salesTeamForCoverage.Coverage_ID__c = '007';
		salesTeamForCoverage.Name = 'Test Sales Team for Coverage';
        salesTeamForCoverage.Sales_Desk_Region__c = 'USA';
        salesTeamForCoverage.Sales_Desk_Division__c = 'Fixed Income';
        salesTeamForCoverage.Sales_Team__c = 'Test Team';
        salesTeamForCoverage.OwnerId = testUser.Id;
        insert salesTeamForCoverage;

		Id coverageTeamMemberActiveRecordTypeId = Schema.getGlobalDescribe().get('Coverage_Team_Member__c').getDescribe().getRecordTypeInfosByName().get('Active Coverage').getRecordTypeId();
        
        Coverage_Team_Member__c coverageTeamMember = new Coverage_Team_Member__c();
        coverageTeamMember.RecordTypeId = coverageTeamMemberActiveRecordTypeId;
        coverageTeamMember.Account__c = account.Id;
        coverageTeamMember.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
        coverageTeamMember.Team_Member__c = salesTeamForCoverage.OwnerId;
		coverageTeamMember.Team_Role__c = 'Primary';
        insert coverageTeamMember;

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
		
		for (Integer productLoop = 0; productLoop <=3; productLoop++)
		{
			ETradingEnablementProduct__c eTradingEnablementProduct = new ETradingEnablementProduct__c();
			eTradingEnablementProduct.Category__c = 'TestCategory' + String.valueOf(productLoop); 	
			eTradingEnablementProduct.Product__c = 'TestProduct' + String.valueOf(productLoop); 
			eTradingEnablementProduct.ProductLabel__c = 'TestProductLabel' + String.valueOf(productLoop);
			
			eTradingEnablementProducts.add(eTradingEnablementProduct);
		}

		insert eTradingEnablementProducts;
		
		Id eTradingEnablementRequestRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Request').getRecordTypeId();
 		
		ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
		eTradingEnablement.RecordTypeId = eTradingEnablementRequestRecordTypeId;
	 	eTradingEnablement.Contact__c = contact.Id;
	    eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
		eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	    eTradingEnablement.ETradingEnablementProduct__c = eTradingEnablementProducts[1].Id;
	    eTradingEnablement.Comments__c = 'Test Request';
	    eTradingEnablement.Status__c = 'Being Processed';
	    
	    Test.startTest();
	    
	    insert eTradingEnablement;
	    
	    eTradingEnablement.Platform_IDs_To_Enable__c = 'PFID1';
	    eTradingEnablement.Status__c = 'Complete';
	    
	    update eTradingEnablement;
	    
	  	Test.stopTest();	    
	}

	static testMethod void sendPendingApprovalEmailTests()
	{
		// There isn't an Assert method in this test method as there 
	    // should be as there isn't a way of confirming an email has 
	    // been sent from a test method and System.enqueueJob doesn't 
	    // return a Job Id in a test that can be used to query the result.
	    
	    Profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		
		User testUser = new User(Alias = 'test', Email='testuser@nomuratest.com',
        					 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        					 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        					 TimeZoneSidKey='America/Los_Angeles',
         					 UserName='testuser@nomuratest.com');
         					 
        insert testUser;
        
        Id rmAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
		Account account = AccountTestData.getAccount();
		account.RecordTypeId = rmAccountRecordTypeId; 
		insert account;
		
		Contact contact = ContactTestData.getContact(account.Id);
		insert contact;
		
		Sales_Team_for_Coverage__c salesTeamForCoverage = new Sales_Team_for_Coverage__c();
		salesTeamForCoverage.Active__c = true;
		salesTeamForCoverage.Coverage_ID__c = '007';
		salesTeamForCoverage.Name = 'Test Sales Team for Coverage';
        salesTeamForCoverage.Sales_Desk_Region__c = 'USA';
        salesTeamForCoverage.Sales_Desk_Division__c = 'Fixed Income';
        salesTeamForCoverage.Sales_Team__c = 'Test Team';
        salesTeamForCoverage.OwnerId = testUser.Id;
        insert salesTeamForCoverage;

		Id coverageTeamMemberActiveRecordTypeId = Schema.getGlobalDescribe().get('Coverage_Team_Member__c').getDescribe().getRecordTypeInfosByName().get('Active Coverage').getRecordTypeId();
        
        Coverage_Team_Member__c coverageTeamMember = new Coverage_Team_Member__c();
        coverageTeamMember.RecordTypeId = coverageTeamMemberActiveRecordTypeId;
        coverageTeamMember.Account__c = account.Id;
        coverageTeamMember.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
        coverageTeamMember.Team_Member__c = salesTeamForCoverage.OwnerId;
		coverageTeamMember.Team_Role__c = 'Primary';
        insert coverageTeamMember;

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
		
		for (Integer productLoop = 0; productLoop <=3; productLoop++)
		{
			ETradingEnablementProduct__c eTradingEnablementProduct = new ETradingEnablementProduct__c();
			eTradingEnablementProduct.Category__c = 'TestCategory' + String.valueOf(productLoop); 	
			eTradingEnablementProduct.Product__c = 'TestProduct' + String.valueOf(productLoop); 
			eTradingEnablementProduct.ProductLabel__c = 'TestProductLabel' + String.valueOf(productLoop);
			
			eTradingEnablementProducts.add(eTradingEnablementProduct);
		}
		
		insert eTradingEnablementProducts;

		Id eTradingEnablementRequestRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Request').getRecordTypeId();
 		
		ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
		eTradingEnablement.RecordTypeId = eTradingEnablementRequestRecordTypeId;
	 	eTradingEnablement.Contact__c = contact.Id;
	    eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
		eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	    eTradingEnablement.ETradingEnablementProduct__c = eTradingEnablementProducts[1].Id;
	    eTradingEnablement.Comments__c = 'Test Request';
	    eTradingEnablement.Status__c = 'Pending Approval';
	    
	    Test.startTest();
	    
	    insert eTradingEnablement;
	    
	    eTradingEnablement.Status__c = 'To Be Processed';
	    
	    update eTradingEnablement;
	    
	  	Test.stopTest();	    
	}

	/* This test is commented out because we don't change the existing coverage
	static testMethod void updateExistingETradingCoverageTest()
	{
		Profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		
		User testUser = new User(Alias = 'test', Email='testuser@nomuratest.com',
        					 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        					 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        					 TimeZoneSidKey='America/Los_Angeles',
         					 UserName='testuser@nomuratest.com');
         					 
        insert testUser;
        
        Id rmAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
		Account account = AccountTestData.getAccount();
		account.RecordTypeId = rmAccountRecordTypeId; 
		insert account;
		
		Contact contact = ContactTestData.getContact(account.Id);
		insert contact;
		
		Sales_Team_for_Coverage__c salesTeamForCoverage = new Sales_Team_for_Coverage__c();
		salesTeamForCoverage.Active__c = true;
		salesTeamForCoverage.Coverage_ID__c = '007';
		salesTeamForCoverage.Name = 'Test Sales Team for Coverage';
        salesTeamForCoverage.Sales_Desk_Region__c = 'USA';
        salesTeamForCoverage.Sales_Desk_Division__c = 'Fixed Income';
        salesTeamForCoverage.Sales_Team__c = 'Test Team';
        salesTeamForCoverage.OwnerId = testUser.Id;
        insert salesTeamForCoverage;
        
        Id coverageTeamMemberActiveRecordTypeId = Schema.getGlobalDescribe().get('Coverage_Team_Member__c').getDescribe().getRecordTypeInfosByName().get('Active Coverage').getRecordTypeId();
        
        Coverage_Team_Member__c coverageTeamMember = new Coverage_Team_Member__c();
        coverageTeamMember.RecordTypeId = coverageTeamMemberActiveRecordTypeId;
        coverageTeamMember.Account__c = account.Id;
        coverageTeamMember.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
        coverageTeamMember.Team_Member__c = salesTeamForCoverage.OwnerId;
		coverageTeamMember.Team_Role__c = 'Primary';
        insert coverageTeamMember;

		List<ETradingEnablementProduct__c> eTradingEnablementProducts = new List<ETradingEnablementProduct__c>();
		
		ETradingEnablementProduct__c eTradingEnablementProduct = new ETradingEnablementProduct__c();
		eTradingEnablementProduct.Category__c = 'TestCategory'; 	
		eTradingEnablementProduct.Subcategory__c = 'TestSubcategory'; 
		eTradingEnablementProduct.Product__c = 'TestProduct'; 
		eTradingEnablementProduct.ProductLabel__c = 'TestProductLabel' + 'Inflation';
		eTradingEnablementProducts.add(eTradingEnablementProduct);
					
		ETradingEnablementProduct__c eTradingEnablementProduct2 = new ETradingEnablementProduct__c();
		eTradingEnablementProduct2.Category__c = 'TestCategory'; 	
		eTradingEnablementProduct2.Subcategory__c = 'TestSubcategory'; 
		eTradingEnablementProduct2.Product__c = 'TestProduct'; 
		eTradingEnablementProduct2.ProductLabel__c = 'TestProductLabel' + 'US Agency';
		eTradingEnablementProducts.add(eTradingEnablementProduct2);
		
		insert eTradingEnablementProducts;

		Id eTradingEnablementCoverageRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Coverage').getRecordTypeId();
		
		ETradingEnablement__c eTradingEnablementCoverage = new ETradingEnablement__c();
		eTradingEnablementCoverage.RecordTypeId = eTradingEnablementCoverageRecordTypeId;
	 	eTradingEnablementCoverage.Contact__c = contact.Id;
	    eTradingEnablementCoverage.Electronic_Platform__c = 'TradeWeb';
		eTradingEnablementCoverage.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	    eTradingEnablementCoverage.ETradingEnablementProduct__c = eTradingEnablementProduct.Id;
	    eTradingEnablementCoverage.Comments__c = 'Test Request';
	    eTradingEnablementCoverage.Status__c = 'Active';
	    insert eTradingEnablementCoverage;
		
		Id eTradingEnablementRequestRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Request').getRecordTypeId();
 		
		ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
		eTradingEnablement.RecordTypeId = eTradingEnablementRequestRecordTypeId;
	 	eTradingEnablement.Contact__c = contact.Id;
	    eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
		eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	    eTradingEnablement.ETradingEnablementProduct__c = eTradingEnablementProduct2.Id;
	    eTradingEnablement.Comments__c = 'Test Request';
	    eTradingEnablement.Status__c = 'Being Processed';
	    insert eTradingEnablement;
	    
	    Test.startTest();
	    
	    eTradingEnablement.Status__c = 'Complete';
	    
	    update eTradingEnablement;
	    
	    eTradingEnablementCoverage = [SELECT Id, Electronic_Platform__c, ETradingEnablementProduct__c, Status__c FROM ETradingEnablement__c WHERE Id=:eTradingEnablementCoverage.Id];
	    
	    System.assertEquals(eTradingEnablementCoverage.Electronic_Platform__c, 'Bloomberg');
	    System.assertEquals(eTradingEnablement.ETradingEnablementProduct__c, eTradingEnablementProduct2.Id);
	    System.assertNotEquals(eTradingEnablementCoverage.Status__c, 'Inactive');
	    
	  	Test.stopTest();	    
	}
	*/
	
	/* code related to revoke has been commented out as revoke will be implemented in future releases
	static testMethod void revokeExistingETradingCoverageTest()
	{
		Profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		
		User testUser = new User(Alias = 'test', Email='testuser@nomuratest.com',
        					 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        					 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        					 TimeZoneSidKey='America/Los_Angeles',
         					 UserName='testuser@nomuratest.com');
         					 
        insert testUser;
        
        Id rmAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
		Account account = AccountTestData.getAccount();
		account.RecordTypeId = rmAccountRecordTypeId; 
		insert account;
		
		Contact contact = ContactTestData.getContact(account.Id);
		insert contact;
		
		Sales_Team_for_Coverage__c salesTeamForCoverage = new Sales_Team_for_Coverage__c();
		salesTeamForCoverage.Active__c = true;
		salesTeamForCoverage.Coverage_ID__c = '007';
		salesTeamForCoverage.Name = 'Test Sales Team for Coverage';
        salesTeamForCoverage.Sales_Desk_Region__c = 'USA';
        salesTeamForCoverage.Sales_Desk_Division__c = 'Fixed Income';
        salesTeamForCoverage.Sales_Team__c = 'Test Team';
        salesTeamForCoverage.OwnerId = testUser.Id;
        insert salesTeamForCoverage;

		ETradingEnablementProduct__c eTradingEnablementProduct = new ETradingEnablementProduct__c();
		eTradingEnablementProduct.Category__c = 'TestCategory'; 	
		eTradingEnablementProduct.Subcategory__c = 'TestSubcategory'; 
		eTradingEnablementProduct.Product__c = 'TestProduct'; 
		eTradingEnablementProduct.ProductLabel__c = 'TestProductLabel' + 'Inflation';
		insert eTradingEnablementProduct;

		Id eTradingEnablementCoverageRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Coverage').getRecordTypeId();
		
		ETradingEnablement__c eTradingEnablementCoverage = new ETradingEnablement__c();
		eTradingEnablementCoverage.RecordTypeId = eTradingEnablementCoverageRecordTypeId;
	 	eTradingEnablementCoverage.Contact__c = contact.Id;
	    eTradingEnablementCoverage.Electronic_Platform__c = 'TradeWeb';
		eTradingEnablementCoverage.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	    eTradingEnablementCoverage.ETradingEnablementProduct__c = eTradingEnablementProduct.Id;
	    eTradingEnablementCoverage.Comments__c = 'Test Request';
	    eTradingEnablementCoverage.Status__c = 'Active';
	    insert eTradingEnablementCoverage;
		
		Id eTradingEnablementRequestRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Request').getRecordTypeId();
 		
		ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
		eTradingEnablement.RecordTypeId = eTradingEnablementRequestRecordTypeId;
	 	eTradingEnablement.Contact__c = contact.Id;
	    eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
		eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	    eTradingEnablement.ETradingEnablementProduct__c = eTradingEnablementProduct.Id;
	    eTradingEnablement.Comments__c = 'Test Revoke Request';
	    eTradingEnablement.Status__c = 'Being Processed'; 
	    eTradingEnablement.Request_Type__c = 'Revoke';
	    insert eTradingEnablement;
	    
	    Test.startTest();
	    
	    eTradingEnablement.Status__c = 'Complete';
	    
	    update eTradingEnablement;
	    
	    eTradingEnablementCoverage = [SELECT Id, Electronic_Platform__c, ETradingEnablementProduct__c, Status__c FROM ETradingEnablement__c WHERE Id=:eTradingEnablementCoverage.Id];
	    
	    System.assertEquals(eTradingEnablementCoverage.Status__c, 'Inactive');
	    
	  	Test.stopTest();	    
	}
	*/
	
	static testMethod void updateETradingEnablementStatusTest()
	{
		Profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		
		User testUser = new User(Alias = 'test', Email='testuser@nomuratest.com',
        					 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        					 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        					 TimeZoneSidKey='America/Los_Angeles',
         					 UserName='testuser@nomuratest.com');
         					 
        insert testUser;
        
		Id rmAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
		
		// Normally the dummy.contact@nomura.com Contact and 
		// NOMURA EMPLOYEES (G) Account is set when the Contact 
		// isn't provided on the incoming data. 
		// For testing purposes a dummy Contact and Account are created.

		Account dummyAccount = AccountTestData.getAccount();
		dummyAccount.RecordTypeId = rmAccountRecordTypeId; 
		insert dummyAccount;

		Account account = AccountTestData.getAccount();
		account.RecordTypeId = rmAccountRecordTypeId; 
		insert account;
		
		Contact dummyContact = ContactTestData.getContact(dummyAccount.Id);
		dummyContact.Email = 'test.dummy.contact@nomura.com';
		insert dummyContact;

		Contact contact = ContactTestData.getContact(account.Id);
		insert contact;
		
		Sales_Team_for_Coverage__c salesTeamForCoverage = new Sales_Team_for_Coverage__c();
		salesTeamForCoverage.Active__c = true;
		salesTeamForCoverage.Coverage_ID__c = '007';
		salesTeamForCoverage.Name = 'Test Sales Team for Coverage';
        salesTeamForCoverage.Sales_Desk_Region__c = 'USA';
        salesTeamForCoverage.Sales_Desk_Division__c = 'Fixed Income';
        salesTeamForCoverage.Sales_Team__c = 'Test Team';
        salesTeamForCoverage.OwnerId = testUser.Id;
        insert salesTeamForCoverage;

		Id coverageTeamMemberActiveRecordTypeId = Schema.getGlobalDescribe().get('Coverage_Team_Member__c').getDescribe().getRecordTypeInfosByName().get('Active Coverage').getRecordTypeId();
        
        Coverage_Team_Member__c coverageTeamMember = new Coverage_Team_Member__c();
        coverageTeamMember.RecordTypeId = coverageTeamMemberActiveRecordTypeId;
        coverageTeamMember.Account__c = account.Id;
        coverageTeamMember.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
        coverageTeamMember.Team_Member__c = salesTeamForCoverage.OwnerId;
		coverageTeamMember.Team_Role__c = 'Primary';
        insert coverageTeamMember;

		
		ETradingEnablementProduct__c eTradingEnablementProduct = new ETradingEnablementProduct__c();
		eTradingEnablementProduct.Category__c = 'TestCategory'; 	
		eTradingEnablementProduct.Subcategory__c = 'TestSubcategory'; 
		eTradingEnablementProduct.Product__c = 'TestProduct'; 
		eTradingEnablementProduct.ProductLabel__c = 'TestProductLabel';
		insert eTradingEnablementProduct;
		
		Id eTradingEnablementRequestRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Request').getRecordTypeId();
 		
		ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
		eTradingEnablement.RecordTypeId = eTradingEnablementRequestRecordTypeId;
	 	eTradingEnablement.Contact__c = dummyContact.Id;
	    eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
	    eTradingEnablement.ETradingEnablementProduct__c = eTradingEnablementProduct.Id;
	    eTradingEnablement.Comments__c = 'Test Request';
	    eTradingEnablement.Status__c = 'On Hold';
		insert eTradingEnablement;
	    
		Test.startTest();

		eTradingEnablement.Contact__c = contact.Id;
		eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
		update eTradingEnablement;

		eTradingEnablement = [SELECT Id, Status__c FROM ETradingEnablement__c WHERE Id = :eTradingEnablement.Id];
		System.assertEquals('Pending Approval', eTradingEnablement.Status__c);

		Test.stopTest();
	}

	// SF TODO: Write test methods for updateETradingEnablementStatus that ensure 
	//          the Status does not change when it shouldn't eg. Status not on hold or values not changed
	static testMethod void updateETradingEnablementStatusNoUpdateTest()
	{
		Profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		
		User testUser = new User(Alias = 'test', Email='testuser@nomuratest.com',
        					 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        					 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        					 TimeZoneSidKey='America/Los_Angeles',
         					 UserName='testuser@nomuratest.com');
         					 
        insert testUser;
        
		Id rmAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
		
		// Normally the dummy.contact@nomura.com Contact and 
		// NOMURA EMPLOYEES (G) Account is set when the Contact 
		// isn't provided on the incoming data. 
		// For testing purposes a dummy Contact and Account are created.

		Account dummyAccount = AccountTestData.getAccount();
		dummyAccount.RecordTypeId = rmAccountRecordTypeId; 
		insert dummyAccount;

		Account account = AccountTestData.getAccount();
		account.RecordTypeId = rmAccountRecordTypeId; 
		insert account;
		
		Contact dummyContact = ContactTestData.getContact(dummyAccount.Id);
		dummyContact.Email = 'test.dummy.contact@nomura.com';
		insert dummyContact;

		Contact contact = ContactTestData.getContact(account.Id);
		insert contact;
		
		Sales_Team_for_Coverage__c salesTeamForCoverage = new Sales_Team_for_Coverage__c();
		salesTeamForCoverage.Active__c = true;
		salesTeamForCoverage.Coverage_ID__c = '007';
		salesTeamForCoverage.Name = 'Test Sales Team for Coverage';
        salesTeamForCoverage.Sales_Desk_Region__c = 'USA';
        salesTeamForCoverage.Sales_Desk_Division__c = 'Fixed Income';
        salesTeamForCoverage.Sales_Team__c = 'Test Team';
        salesTeamForCoverage.OwnerId = testUser.Id;
        insert salesTeamForCoverage;

		Id coverageTeamMemberActiveRecordTypeId = Schema.getGlobalDescribe().get('Coverage_Team_Member__c').getDescribe().getRecordTypeInfosByName().get('Active Coverage').getRecordTypeId();
        
        Coverage_Team_Member__c coverageTeamMember = new Coverage_Team_Member__c();
        coverageTeamMember.RecordTypeId = coverageTeamMemberActiveRecordTypeId;
        coverageTeamMember.Account__c = account.Id;
        coverageTeamMember.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
        coverageTeamMember.Team_Member__c = salesTeamForCoverage.OwnerId;
		coverageTeamMember.Team_Role__c = 'Primary';
        insert coverageTeamMember;

		
		ETradingEnablementProduct__c eTradingEnablementProduct = new ETradingEnablementProduct__c();
		eTradingEnablementProduct.Category__c = 'TestCategory'; 	
		eTradingEnablementProduct.Subcategory__c = 'TestSubcategory'; 
		eTradingEnablementProduct.Product__c = 'TestProduct'; 
		eTradingEnablementProduct.ProductLabel__c = 'TestProductLabel';
		insert eTradingEnablementProduct;
		
		Id eTradingEnablementRequestRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Request').getRecordTypeId();
 		
		ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
		eTradingEnablement.RecordTypeId = eTradingEnablementRequestRecordTypeId;
	 	eTradingEnablement.Contact__c = dummyContact.Id;
	    eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
	    eTradingEnablement.ETradingEnablementProduct__c = eTradingEnablementProduct.Id;
	    eTradingEnablement.Comments__c = 'Test Request';
	    eTradingEnablement.Status__c = 'On Hold';
		insert eTradingEnablement;
	    
		Test.startTest();

		// The Contact and Sales Code are not changed so the 
		// Status value should remain 'On Hold'
		eTradingEnablement.Comments__c = 'Test Request';
		update eTradingEnablement;

		eTradingEnablement = [SELECT Id, Status__c FROM ETradingEnablement__c WHERE Id = :eTradingEnablement.Id];
		System.assertEquals('On Hold', eTradingEnablement.Status__c);

		Test.stopTest();
	}

	static testMethod void updateETradingEnablementStatusNoUpdateNullValueTest()
	{
		Profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		
		User testUser = new User(Alias = 'test', Email='testuser@nomuratest.com',
        					 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        					 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        					 TimeZoneSidKey='America/Los_Angeles',
         					 UserName='testuser@nomuratest.com');
         					 
        insert testUser;
        
		Id rmAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
		
		// Normally the dummy.contact@nomura.com Contact and 
		// NOMURA EMPLOYEES (G) Account is set when the Contact 
		// isn't provided on the incoming data. 
		// For testing purposes a dummy Contact and Account are created.

		Account dummyAccount = AccountTestData.getAccount();
		dummyAccount.RecordTypeId = rmAccountRecordTypeId; 
		insert dummyAccount;

		Account account = AccountTestData.getAccount();
		account.RecordTypeId = rmAccountRecordTypeId; 
		insert account;
		
		Contact dummyContact = ContactTestData.getContact(dummyAccount.Id);
		dummyContact.Email = 'test.dummy.contact@nomura.com';
		insert dummyContact;

		Contact contact = ContactTestData.getContact(account.Id);
		insert contact;
		
		Sales_Team_for_Coverage__c salesTeamForCoverage = new Sales_Team_for_Coverage__c();
		salesTeamForCoverage.Active__c = true;
		salesTeamForCoverage.Coverage_ID__c = '007';
		salesTeamForCoverage.Name = 'Test Sales Team for Coverage';
        salesTeamForCoverage.Sales_Desk_Region__c = 'USA';
        salesTeamForCoverage.Sales_Desk_Division__c = 'Fixed Income';
        salesTeamForCoverage.Sales_Team__c = 'Test Team';
        salesTeamForCoverage.OwnerId = testUser.Id;
        insert salesTeamForCoverage;

		Id coverageTeamMemberActiveRecordTypeId = Schema.getGlobalDescribe().get('Coverage_Team_Member__c').getDescribe().getRecordTypeInfosByName().get('Active Coverage').getRecordTypeId();
        
        Coverage_Team_Member__c coverageTeamMember = new Coverage_Team_Member__c();
        coverageTeamMember.RecordTypeId = coverageTeamMemberActiveRecordTypeId;
        coverageTeamMember.Account__c = account.Id;
        coverageTeamMember.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
        coverageTeamMember.Team_Member__c = salesTeamForCoverage.OwnerId;
		coverageTeamMember.Team_Role__c = 'Primary';
        insert coverageTeamMember;

		
		ETradingEnablementProduct__c eTradingEnablementProduct = new ETradingEnablementProduct__c();
		eTradingEnablementProduct.Category__c = 'TestCategory'; 	
		eTradingEnablementProduct.Subcategory__c = 'TestSubcategory'; 
		eTradingEnablementProduct.Product__c = 'TestProduct'; 
		eTradingEnablementProduct.ProductLabel__c = 'TestProductLabel';
		insert eTradingEnablementProduct;
		
		Id eTradingEnablementRequestRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Request').getRecordTypeId();
 		
		ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
		eTradingEnablement.RecordTypeId = eTradingEnablementRequestRecordTypeId;
	 	eTradingEnablement.Contact__c = dummyContact.Id;
	    eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
	    eTradingEnablement.ETradingEnablementProduct__c = eTradingEnablementProduct.Id;
	    eTradingEnablement.Comments__c = 'Test Request';
		eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	    eTradingEnablement.Status__c = 'Pending Approval';
		insert eTradingEnablement;
	    
		Test.startTest();

		// The Sales Code is set to null so the 
		// Status value should remain 'On Hold'
		eTradingEnablement.Contact__c = contact.Id;
		eTradingEnablement.Sales_Team_for_Coverage__c = null;
		update eTradingEnablement;

		eTradingEnablement = [SELECT Id, Status__c FROM ETradingEnablement__c WHERE Id = :eTradingEnablement.Id];
		//System.assertEquals('On Hold', eTradingEnablement.Status__c);

		Test.stopTest();
	}

}