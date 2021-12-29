/*
	Author 		: Simon Foden
	Company 	: Nomura
	Date 		: 30/10/2018
	Description : Test class for the ETradingEnablementCloneController 
				  controller class.
	
*/
@isTest
public class ETradingEnablementCloneControllerTest 
{
    static testMethod void getETradingEnablementsTest()
    {
		/*String userName = 'standarduser' + DateTime.now().getTime() + '@nomuratest.com';
        
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
		
        ETradingEnablementProduct__c eTradingEnablementProduct = new ETradingEnablementProduct__c();
        eTradingEnablementProduct.Category__c = 'TestCategory'; 	
        eTradingEnablementProduct.Subcategory__c = 'TestSubcategory'; 
        eTradingEnablementProduct.Product__c = 'TestProduct'; 
        eTradingEnablementProduct.ProductLabel__c = 'TestProductLabel';
		insert eTradingEnablementProduct;

		Id eTradingEnablementCoverageRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Coverage').getRecordTypeId();

        ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
        eTradingEnablement.Contact__c = contact.Id;
        eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
        eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
        eTradingEnablement.ETradingEnablementProduct__c = eTradingEnablementProduct.Id;
		eTradingEnablement.RecordTypeId = eTradingEnablementCoverageRecordTypeId;
        insert eTradingEnablement;
        */
        
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
        eTradingEnablementProduct.ProductLabel__c = 'TestProductLabel';
		insert eTradingEnablementProduct;
		
		Id eTradingEnablementRequestRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Request').getRecordTypeId();
 		
		ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
		eTradingEnablement.RecordTypeId = eTradingEnablementRequestRecordTypeId;
	 	eTradingEnablement.Contact__c = contact.Id;
	    eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
		eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	    eTradingEnablement.ETradingEnablementProduct__c = eTradingEnablementProduct.Id;
	    eTradingEnablement.Comments__c = 'Test Request';
	    eTradingEnablement.Status__c = 'Being Processed';
	    
	    insert eTradingEnablement;
	    
	    eTradingEnablement.Platform_IDs_To_Enable__c = 'PFID1';
	    eTradingEnablement.Status__c = 'Complete';
	    
	    update eTradingEnablement;
        
        Test.startTest();

        ETradingEnablementCloneController.ETradingEnablementData eTradingEnablementData = new ETradingEnablementCloneController.eTradingEnablementData();

        String eTradingEnablementDataJSON = ETradingEnablementCloneController.getETradingEnablements(contact.Id);
        eTradingEnablementData = (ETradingEnablementCloneController.ETradingEnablementData)JSON.deserializeStrict(eTradingEnablementDataJSON, ETradingEnablementCloneController.ETradingEnablementData.class);
        
        System.assertEquals(eTradingEnablementData.error, false);
		System.assertEquals(eTradingEnablementData.errorMessage, '');
        System.assertEquals(eTradingEnablementData.eTradingEnablements.size(), 1);
        System.assertEquals(eTradingEnablementData.eTradingEnablements[0].platform, 'Bloomberg');
        System.assertEquals(eTradingEnablementData.eTradingEnablements[0].salesCode, 'Test Sales Team for Coverage (007) Test Team');
        System.assertEquals(eTradingEnablementData.eTradingEnablements[0].salesCodeId, salesTeamForCoverage.Id);
        System.assertEquals(eTradingEnablementData.eTradingEnablements[0].product, 'TestCategory - TestSubcategory - TestProductLabel');
        System.assertEquals(eTradingEnablementData.eTradingEnablements[0].productId, eTradingEnablementProduct.Id);
        
        Test.stopTest();


    }

    static testMethod void missingContactIdParameterTest()
    {
        Test.startTest();

        ETradingEnablementCloneController.ETradingEnablementData eTradingEnablementData = new ETradingEnablementCloneController.eTradingEnablementData();

        String eTradingEnablementDataJSON = ETradingEnablementCloneController.getETradingEnablements(null);
        eTradingEnablementData = (ETradingEnablementCloneController.ETradingEnablementData)JSON.deserializeStrict(eTradingEnablementDataJSON, ETradingEnablementCloneController.ETradingEnablementData.class);
        
        System.assertEquals(eTradingEnablementData.error, true);
		System.assertEquals(eTradingEnablementData.errorMessage, 'Error : No Contact selected');

        Test.stopTest();
    }

    static testMethod void checkFieldLevelSecurityTest()
	{
        /*
        String userName = 'standarduser' + DateTime.now().getTime() + '@nomuratest.com';
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name='Nomura - Sales'];
        
        User testUser = new User(Alias = 'standt', Email='standarduser@nomuratest.com',
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
		
        ETradingEnablementProduct__c eTradingEnablementProduct = new ETradingEnablementProduct__c();
        eTradingEnablementProduct.Category__c = 'TestCategory'; 	
        eTradingEnablementProduct.Subcategory__c = 'TestSubcategory'; 
        eTradingEnablementProduct.Product__c = 'TestProduct'; 
        eTradingEnablementProduct.ProductLabel__c = 'TestProductLabel';
		insert eTradingEnablementProduct;

        Id eTradingEnablementCoverageRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Coverage').getRecordTypeId();
		
		ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
        eTradingEnablement.Contact__c = contact.Id;
        eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
        eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
        eTradingEnablement.ETradingEnablementProduct__c = eTradingEnablementProduct.Id;
		eTradingEnablement.RecordTypeId = eTradingEnablementCoverageRecordTypeId;
        insert eTradingEnablement;
        */

		String userName = 'standarduser' + DateTime.now().getTime() + '@nomuratest.com';
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name='Nomura - Sales'];
        
        User testUser = new User(Alias = 'standt', Email='standarduser@nomuratest.com',
        						 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        						 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        						 TimeZoneSidKey='America/Los_Angeles',
         						 UserName=userName);
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
	    
	    insert eTradingEnablement;
	    
	    eTradingEnablement.Platform_IDs_To_Enable__c = 'PFID1';
	    eTradingEnablement.Status__c = 'Complete';
	    
	    update eTradingEnablement;


        System.runAs(testUser) 
        {

            Test.startTest();

            ETradingEnablementCloneController.ETradingEnablementData eTradingEnablementData = new ETradingEnablementCloneController.eTradingEnablementData();

            String eTradingEnablementDataJSON = ETradingEnablementCloneController.getETradingEnablements(contact.Id);
            eTradingEnablementData = (ETradingEnablementCloneController.ETradingEnablementData)JSON.deserializeStrict(eTradingEnablementDataJSON, ETradingEnablementCloneController.ETradingEnablementData.class);
            
            System.assertEquals(eTradingEnablementData.error, true);
            System.assertEquals(eTradingEnablementData.errorMessage, 'Field Level Security Error : User does not have permission to view the data');
            
            Test.stopTest();

        }
    }

    static testMethod void cloneETradingEnablementsTest()
    {
        /*String userName = 'standarduser' + DateTime.now().getTime() + '@nomuratest.com';
        
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
		
		Contact sourceContact = new Contact();
		sourceContact.Salutation = 'Mr.';
		sourceContact.FirstName = 'James';
		sourceContact.LastName = 'Bond';
		sourceContact.Email = 'jamesbond04062018@univeralexports.com';
		sourceContact.AccountId = account.Id; 
		insert sourceContact;

        Contact targetContact = new Contact();
		targetContact.Salutation = 'Miss.';
		targetContact.FirstName = 'Eve';
		targetContact.LastName = 'Moneypenny';
		targetContact.Email = 'missmoneypenny04062018@univeralexports.com';
		targetContact.AccountId = account.Id; 
		insert targetContact;
		
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
		
        ETradingEnablementProduct__c eTradingEnablementProduct = new ETradingEnablementProduct__c();
        eTradingEnablementProduct.Category__c = 'TestCategory'; 	
        eTradingEnablementProduct.Subcategory__c = 'TestSubcategory'; 
        eTradingEnablementProduct.Product__c = 'TestProduct'; 
        eTradingEnablementProduct.ProductLabel__c = 'TestProductLabel';
		insert eTradingEnablementProduct;

        Id eTradingEnablementCoverageRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Coverage').getRecordTypeId();
		
		ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
        eTradingEnablement.Contact__c = sourceContact.Id;
        eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
        eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
        eTradingEnablement.ETradingEnablementProduct__c = eTradingEnablementProduct.Id;
		eTradingEnablement.RecordTypeId = eTradingEnablementCoverageRecordTypeId;
        insert eTradingEnablement;
		*/
		
		String userName = 'standarduser' + DateTime.now().getTime() + '@nomuratest.com';
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name='Nomura - Sales'];
        
        User testUser = new User(Alias = 'standt', Email='standarduser@nomuratest.com',
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
		
		Contact sourceContact = new Contact();
		sourceContact.Salutation = 'Mr.';
		sourceContact.FirstName = 'James';
		sourceContact.LastName = 'Bond';
		sourceContact.Email = 'jamesbond04062018@univeralexports.com';
		sourceContact.AccountId = account.Id; 
		insert sourceContact;

        Contact targetContact = new Contact();
		targetContact.Salutation = 'Miss.';
		targetContact.FirstName = 'Eve';
		targetContact.LastName = 'Moneypenny';
		targetContact.Email = 'missmoneypenny04062018@univeralexports.com';
		targetContact.AccountId = account.Id; 
		insert targetContact;
		
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
	 	eTradingEnablement.Contact__c = sourceContact.Id;
	    eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
		eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	    eTradingEnablement.ETradingEnablementProduct__c = eTradingEnablementProducts[1].Id;
	    eTradingEnablement.Comments__c = 'Test Request';
	    eTradingEnablement.Status__c = 'Being Processed';
	    
	    insert eTradingEnablement;
	    
	    eTradingEnablement.Platform_IDs_To_Enable__c = 'PFID1';
	    eTradingEnablement.Status__c = 'Complete';
	    
	    update eTradingEnablement;
		
        String[] targetContactIds = new String[]{targetContact.Id};

        String comments = 'Test comment';
                    
        Test.startTest();

        ETradingEnablementCloneController.ETradingEnablementData eTradingEnablementData = new ETradingEnablementCloneController.eTradingEnablementData();

        String eTradingEnablementDataJSON = ETradingEnablementCloneController.getETradingEnablements(sourceContact.Id);
        eTradingEnablementData = (ETradingEnablementCloneController.ETradingEnablementData)JSON.deserializeStrict(eTradingEnablementDataJSON, ETradingEnablementCloneController.ETradingEnablementData.class);
        
        ETradingEnablementCloneController.ETradingEnablementClone eTradingEnablementClone = new ETradingEnablementCloneController.ETradingEnablementClone();

        String cloneData = JSON.serialize(eTradingEnablementData.eTradingEnablements);

        String eTradingEnablementCloneJSON = ETradingEnablementCloneController.cloneETradingEnablements(sourceContact.Id, targetContactIds, comments, cloneData);

        eTradingEnablementClone = (ETradingEnablementCloneController.ETradingEnablementClone)JSON.deserializeStrict(eTradingEnablementCloneJSON, ETradingEnablementCloneController.ETradingEnablementClone.class);

        System.assertEquals(eTradingEnablementClone.error, false);
		System.assertEquals(eTradingEnablementClone.errorMessage, '');

        List<ETradingEnablement__c> eTradingEnablements = [SELECT Id, 
                                                           Contact__c, 
                                                           Electronic_Platform__c, 
                                                           Sales_Team_for_Coverage__c, 
                                                           ETradingEnablementProduct__c, 
                                                           Comments__c  
                                                           FROM ETradingEnablement__c 
                                                           WHERE Contact__c = :targetContact.Id];

        System.assertEquals(eTradingEnablements.size(), 1);
        System.assertEquals(eTradingEnablements[0].Electronic_Platform__c, eTradingEnablement.Electronic_Platform__c);
        System.assertEquals(eTradingEnablements[0].Sales_Team_for_Coverage__c, eTradingEnablement.Sales_Team_for_Coverage__c);
        System.assertEquals(eTradingEnablements[0].ETradingEnablementProduct__c , eTradingEnablement.ETradingEnablementProduct__c);
        System.assertEquals(eTradingEnablements[0].Comments__c, comments);

        Test.stopTest();        
    }

    static testMethod void cloneETradingEnablementsErrorTest()
    {
        /*
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
		
		Contact sourceContact = new Contact();
		sourceContact.Salutation = 'Mr.';
		sourceContact.FirstName = 'James';
		sourceContact.LastName = 'Bond';
		sourceContact.Email = 'jamesbond04062018@univeralexports.com';
		sourceContact.AccountId = account.Id; 
		insert sourceContact;

        Contact targetContact = new Contact();
		targetContact.Salutation = 'Miss.';
		targetContact.FirstName = 'Eve';
		targetContact.LastName = 'Moneypenny';
		targetContact.Email = 'missmoneypenny04062018@univeralexports.com';
		targetContact.AccountId = account.Id; 
		insert targetContact;
		
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
		
        ETradingEnablementProduct__c eTradingEnablementProduct = new ETradingEnablementProduct__c();
        eTradingEnablementProduct.Category__c = 'TestCategory'; 	
        eTradingEnablementProduct.Subcategory__c = 'TestSubcategory'; 
        eTradingEnablementProduct.Product__c = 'TestProduct'; 
        eTradingEnablementProduct.ProductLabel__c = 'TestProductLabel';
		insert eTradingEnablementProduct;

        Id eTradingEnablementCoverageRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Coverage').getRecordTypeId();

		ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
        eTradingEnablement.Contact__c = sourceContact.Id;
        eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
        eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
        eTradingEnablement.ETradingEnablementProduct__c = eTradingEnablementProduct.Id;
		eTradingEnablement.RecordTypeId = eTradingEnablementCoverageRecordTypeId;
        insert eTradingEnablement;
        */

		String userName = 'standarduser' + DateTime.now().getTime() + '@nomuratest.com';
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name='Nomura - Sales'];
        
        User testUser = new User(Alias = 'standt', Email='standarduser@nomuratest.com',
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
		
		Contact sourceContact = new Contact();
		sourceContact.Salutation = 'Mr.';
		sourceContact.FirstName = 'James';
		sourceContact.LastName = 'Bond';
		sourceContact.Email = 'jamesbond04062018@univeralexports.com';
		sourceContact.AccountId = account.Id; 
		insert sourceContact;

        Contact targetContact = new Contact();
		targetContact.Salutation = 'Miss.';
		targetContact.FirstName = 'Eve';
		targetContact.LastName = 'Moneypenny';
		targetContact.Email = 'missmoneypenny04062018@univeralexports.com';
		targetContact.AccountId = account.Id; 
		insert targetContact;
		
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
	 	eTradingEnablement.Contact__c = sourceContact.Id;
	    eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
		eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	    eTradingEnablement.ETradingEnablementProduct__c = eTradingEnablementProducts[1].Id;
	    eTradingEnablement.Comments__c = 'Test Request';
	    eTradingEnablement.Status__c = 'Being Processed';
	    
	    insert eTradingEnablement;
	    
	    eTradingEnablement.Platform_IDs_To_Enable__c = 'PFID1';
	    eTradingEnablement.Status__c = 'Complete';
	    
	    update eTradingEnablement;

        String[] targetContactIds = new String[]{targetContact.Id};

        String comments = 'Test comment';

        delete targetContact;
                    
        Test.startTest();

        ETradingEnablementCloneController.ETradingEnablementData eTradingEnablementData = new ETradingEnablementCloneController.eTradingEnablementData();

        String eTradingEnablementDataJSON = ETradingEnablementCloneController.getETradingEnablements(sourceContact.Id);
        eTradingEnablementData = (ETradingEnablementCloneController.ETradingEnablementData)JSON.deserializeStrict(eTradingEnablementDataJSON, ETradingEnablementCloneController.ETradingEnablementData.class);
        
        ETradingEnablementCloneController.ETradingEnablementClone eTradingEnablementClone = new ETradingEnablementCloneController.ETradingEnablementClone();

        String cloneData = JSON.serialize(eTradingEnablementData.eTradingEnablements);

        String eTradingEnablementCloneJSON = ETradingEnablementCloneController.cloneETradingEnablements(sourceContact.Id, targetContactIds, comments, cloneData);

        eTradingEnablementClone = (ETradingEnablementCloneController.ETradingEnablementClone)JSON.deserializeStrict(eTradingEnablementCloneJSON, ETradingEnablementCloneController.ETradingEnablementClone.class);

        System.assertEquals(eTradingEnablementClone.error, true);

        Test.stopTest();        
    }
}