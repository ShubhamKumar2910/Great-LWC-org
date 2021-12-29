/*
	Author 		: Simon Foden
	Company 	: Nomura
	Date 		: 12/07/2018
	Description : Test class for the LinkETradingEnablementRecords 
				  Queueable job      
	
*/
@isTest
private class LinkETradingEnablementRecordsTest 
{
	// As LinkETradingEnablementRecords class is not required and commented out, this code is not required
	// ToDo : delete this file in future once eTrading is released
    /*
	static testMethod void linkETradingEnablementRecordsTest() 
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
        salesTeamForCoverage.OwnerId = testUser.Id;
        insert salesTeamForCoverage;

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
	    eTradingEnablement.Comments__c = 'Test Request';
	    eTradingEnablement.Status__c = 'Complete';
	    insert eTradingEnablement;
	    
	    Test.startTest();
	    
	    System.assertEquals(eTradingEnablement.Coverage__c, null);
	    
	    Map<Id, Id> eTradingEnablementRequestIdCoverageRecordIds = new Map<Id, Id>();
    	
   		eTradingEnablementRequestIdCoverageRecordIds.put(eTradingEnablement.Id, eTradingEnablementCoverage.Id);
    	
    	Id jobId = System.enqueueJob(new LinkETradingEnablementRecords(eTradingEnablementRequestIdCoverageRecordIds));
	    
	    Test.stopTest();
	    
	    eTradingEnablement = [SELECT Id,
							  Coverage__c  
	    					  FROM ETradingEnablement__c 
	    					  WHERE Id = :eTradingEnablement.Id];
	    
	    
	    System.assertEquals(eTradingEnablement.Coverage__c, eTradingEnablementCoverage.Id);
    }
	*/
}