/*
	Author 		: Simon Foden
	Company 	: Nomura
	Date 		: 04/07/2018
	Description : Tests for the ETradingEnablementSendEmail class.        
				  
	
*/
@isTest
private class ETradingEnablementSendEmailTest 
{
    // There isn't an Assert method in this test class as there 
    // should be as there isn't a way of confirming an email has 
    // been sent from a test method and System.enqueueJob doesn't 
    // return a Job Id in a test that can be used to query the result.
    static testMethod void sendEmailTest() 
    {    
		Account account = AccountTestData.getAccount();
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
 		
		ETradingEnablementProduct__c eTradingEnablementProduct = new ETradingEnablementProduct__c();
		eTradingEnablementProduct.Category__c = 'TestCategory'; 	
		eTradingEnablementProduct.Subcategory__c = 'TestSubcategory'; 
		eTradingEnablementProduct.Product__c = 'TestProduct'; 
		eTradingEnablementProduct.ProductLabel__c = 'TestProductLabel';
 		insert eTradingEnablementProduct;

		ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
	 	eTradingEnablement.Contact__c = contact.Id;
	    eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
		eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	    eTradingEnablement.ETradingEnablementProduct__c = eTradingEnablementProduct.Id;
	    eTradingEnablement.Comments__c = 'Test Request';
	    insert eTradingEnablement;
	    
	    Map<Id, ETradingEnablement__c> eTradingEnablements = new Map<Id, ETradingEnablement__c>();
	    eTradingEnablements.put(eTradingEnablement.Id, eTradingEnablement);
	    
	    Test.startTest();

		System.enqueueJob(new ETradingEnablementSendEmail(eTradingEnablements));
		
	    Test.stopTest();
    }
    
    static testMethod void sendProcessingEmailTest() 
    {       
		Account account = AccountTestData.getAccount();
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

		ETradingEnablementProduct__c eTradingEnablementProduct = new ETradingEnablementProduct__c();
		eTradingEnablementProduct.Category__c = 'TestCategory'; 	
		eTradingEnablementProduct.Subcategory__c = 'TestSubcategory'; 
		eTradingEnablementProduct.Product__c = 'TestProduct'; 
		eTradingEnablementProduct.ProductLabel__c = 'TestProductLabel';
 		insert eTradingEnablementProduct;

		ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
	 	eTradingEnablement.Contact__c = contact.Id;
	    eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
		eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	    eTradingEnablement.ETradingEnablementProduct__c = eTradingEnablementProduct.Id;
	    eTradingEnablement.Comments__c = 'Test Request';
	    insert eTradingEnablement;
	    
	    eTradingEnablement.Status__c = 'To Be Processed';
	    update eTradingEnablement;
	    
	    Map<Id, ETradingEnablement__c> eTradingEnablements = new Map<Id, ETradingEnablement__c>();
	    eTradingEnablements.put(UserInfo.getUserId(), eTradingEnablement);
	    
	    Test.startTest();

		System.enqueueJob(new ETradingEnablementSendEmail(eTradingEnablements));
		
	    Test.stopTest();
    }
    
    static testMethod void sendCompletedEmailTest() 
    {
        Profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		
		User testUser = new User(Alias = 'test', Email='testuser@nomuratest.com',
        					 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        					 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        					 TimeZoneSidKey='America/Los_Angeles',
         					 UserName='testuser@nomuratest.com');
         					 
        insert testUser;
        
		Account account = AccountTestData.getAccount();
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
 		
		ETradingEnablementProduct__c eTradingEnablementProduct = new ETradingEnablementProduct__c();
		eTradingEnablementProduct.Category__c = 'TestCategory'; 	
		eTradingEnablementProduct.Subcategory__c = 'TestSubcategory'; 
		eTradingEnablementProduct.Product__c = 'TestProduct'; 
		eTradingEnablementProduct.ProductLabel__c = 'TestProductLabel';
 		insert eTradingEnablementProduct;
		
		ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
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
	    
	    Map<Id, ETradingEnablement__c> eTradingEnablements = new Map<Id, ETradingEnablement__c>();
	    eTradingEnablements.put(UserInfo.getUserId(), eTradingEnablement);
	    
	    Test.startTest(); 

		System.enqueueJob(new ETradingEnablementSendEmail(eTradingEnablements));
		
	    Test.stopTest();
    }
}