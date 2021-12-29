/*
	Author 		: Peter Gascoyne
	Company 	: Nomura
	Date 		: 20/07/2018
	Description : Tests for the ETradingEnablementService class.        			  
*/
@isTest
private class ETradingEnablementServiceTest 
{

    static testMethod void verifyGetEtradingEnablementsForRecType() 
    {
    	System.debug('#### ETradingEnablementServiceTest.verifyGetEtradingEnablementsForRecType()');
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
        eTradingEnablementProduct.Name = 'Rates Cash - Gilts';
        eTradingEnablementProduct.Category__c = 'Rates Cash';
        eTradingEnablementProduct.Product__c = 'GILTS'; 
        eTradingEnablementProduct.ProductLabel__c = 'Gilts';
        insert eTradingEnablementProduct;
 		
		ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
	 	eTradingEnablement.Contact__c = contact.Id;
	    eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
		eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	    eTradingEnablement.ETradingEnablementProduct__c = eTradingEnablementProduct.id;
	    insert eTradingEnablement;
    	
    	Test.startTest(); 
        
        	List<ETradingEnablement__c> et = ETradingEnablementService.getEtradingEnablementsForRecType(
        		new List<String>{'Rejected'},
				new List<String>{'Bloomberg'}, 
				new List<String>{eTradingEnablementProduct.id},
				new List<String>{rg1.id},
				'Request',
				new List<String>{salesTeamForCoverage.id},
				new List<String>{contact.Id});
			
			// System.assertEquals(et.size(), 1);
			
			ETradingEnablementService.QueryWithoutSharing queryWSCont= new ETradingEnablementService.QueryWithoutSharing();
			queryWSCont.updateETEnablementRecs(et, true);
        	
        Test.stopTest();
    	
    }
    
	/* commented out for Simon's change
    static testMethod void testPopulateStatusAndRecordType() {
    	System.debug('#### ETradingEnablementServiceTest.testPopulateStatusAndRecordType()');
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
        eTradingEnablementProduct.Name = 'Rates Cash - Gilts';
        eTradingEnablementProduct.Category__c = 'Rates Cash';
        eTradingEnablementProduct.Product__c = 'GILTS'; 
        eTradingEnablementProduct.ProductLabel__c = 'Gilts';
        insert eTradingEnablementProduct;
 		
 		List<ETradingEnablement__c> ETEnablementList = new List<ETradingEnablement__c>();
		for(Integer i=0; i<100; ++i) {
        	ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
		 	eTradingEnablement.Contact__c = contact.Id;
		    eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
			eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
		    eTradingEnablement.ETradingEnablementProduct__c = eTradingEnablementProduct.id;
		    if(i<50) {
		    	eTradingEnablement.Request_Stage__c = 'Open';
		    } else {
		    	eTradingEnablement.Request_Stage__c = 'Complete';
		    }
		    ETEnablementList.add(eTradingEnablement);
        }
        
        Test.startTest();
        	insert ETEnablementList;
        Test.stopTest();
        
        Integer countOnHoldReq = 0;
        Integer countPendAppReq = 0;
        for(ETradingEnablement__c oET : [SELECT Id, Request_Stage__c, Status__c, RecordTypeId FROM ETradingEnablement__c]) {
        	System.debug('oET : '+oET);
        	if(oET.Status__c=='On Hold' && 
        			oET.RecordTypeId==ETradingEnablementService.ETERecTypeInfoByRecTypeDevNameMap.get(ETradingEnablementService.ETE_RT_NAME_REQUEST).getRecordTypeId()) {
        		++countOnHoldReq;
        	} else if(oET.Status__c=='Complete' &&
        			oET.RecordTypeId==ETradingEnablementService.ETERecTypeInfoByRecTypeDevNameMap.get(ETradingEnablementService.ETE_RT_NAME_REQUEST).getRecordTypeId()) {
        		++countPendAppReq;
        	}
        }
        
		System.assertEquals(countOnHoldReq, 50);
		System.assertEquals(countPendAppReq, 50);
    }
    
    static testMethod void testPopulateSalesCode() {
    	System.debug('#### ETradingEnablementServiceTest.testPopulateSalesCode()');
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
        eTradingEnablementProduct.Name = 'Rates Cash - Gilts';
        eTradingEnablementProduct.Category__c = 'Rates Cash';
        eTradingEnablementProduct.Product__c = 'GILTS'; 
        eTradingEnablementProduct.ProductLabel__c = 'Gilts';
        insert eTradingEnablementProduct;
 		
 		List<ETradingEnablement__c> ETEnablementList = new List<ETradingEnablement__c>();
		for(Integer i=0; i<100; ++i) {
        	ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
		 	eTradingEnablement.Contact__c = contact.Id;
		    eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
		    eTradingEnablement.ETradingEnablementProduct__c = eTradingEnablementProduct.id;
		    eTradingEnablement.Request_Stage__c = 'Open';
		    if(i<50) {
		    	eTradingEnablement.Platform_Sales_Code__c = '007';
		    } else {
				eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;		    	
		    }
		    ETEnablementList.add(eTradingEnablement);
        }
        
        Test.startTest();
        	insert ETEnablementList;
        Test.stopTest();
        
        Integer countETWithsalesCode = [SELECT count() FROM ETradingEnablement__c WHERE Sales_Team_for_Coverage__c = :salesTeamForCoverage.Id];
		System.assertEquals(countETWithsalesCode, 100);
    }
    
    static testMethod void testPopulateProduct() {
    	System.debug('#### ETradingEnablementServiceTest.testPopulateProduct()');
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
        eTradingEnablementProduct.Name = 'Rates Cash - Gilts';
        eTradingEnablementProduct.Category__c = 'Rates Cash';
        eTradingEnablementProduct.Product__c = 'GILTS'; 
        eTradingEnablementProduct.ProductLabel__c = 'Gilts';
        insert eTradingEnablementProduct;
        
        ETradingEnablementProduct__c eTradingEnablementProduct2 = new ETradingEnablementProduct__c();
        eTradingEnablementProduct2.Name = 'Rates Cash - ADN';
        eTradingEnablementProduct2.Category__c = 'Rates Cash';
        eTradingEnablementProduct2.Product__c = 'ADN'; 
        eTradingEnablementProduct2.ProductLabel__c = 'ADN';
        insert eTradingEnablementProduct2;
        
 		
 		List<ETradingEnablement__c> ETEnablementList = new List<ETradingEnablement__c>();
		for(Integer i=0; i<100; ++i) {
        	ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
		 	eTradingEnablement.Contact__c = contact.Id;
		    eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
		    eTradingEnablement.Request_Stage__c = 'Open';
		    eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
		    if(i<50) {
		    	eTradingEnablement.ETradingEnablementProduct__c = eTradingEnablementProduct.id;
		    } else {
				eTradingEnablement.Platform_Product__c = 'ADN';
		    }
		    ETEnablementList.add(eTradingEnablement);
        }
        
        Test.startTest();
        	insert ETEnablementList;
        Test.stopTest();
        
        Integer countETWithADNProduct = [SELECT count() FROM ETradingEnablement__c WHERE ETradingEnablementProduct__c = :eTradingEnablementProduct2.Id];
		System.assertEquals(countETWithADNProduct, 50);
    }
    
    static testMethod void testPopulateContact() {
    	System.debug('#### ETradingEnablementServiceTest.opulateContact()');
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
        
        RecordType recordTypeForNM = [SELECT Id, Name FROM RecordType WHERE Name = 'NOMURA EMPLOYEES'];
        Account acNomEmp = new Account(Name='NOMURA EMPLOYEES',RDM_Org_ID__c='CP12345',RecordTypeId = recordTypeForNM.Id);
        insert acNomEmp;
		
		List<Contact> Contacts = new List<Contact>();
		for(Integer i=1; i<=3; ++i) {
		    Contact contactAdd = new Contact();
		    contactAdd.AccountId = rg1rm1.Id;
		    contactAdd.FirstName = 'fn'+i; 
		    contactAdd.LastName = 'ln'+i;    
		    contactAdd.Active__c = true;
		    contactAdd.Email = 'fnln'+i+'@abcd.com';
		    contactAdd.Phone = '(212) 333-456'+i; 
		    contactAdd.Salutation = 'Dear [FirstName]';    
		    Contacts.add(contactAdd);
	    }
	    
	    Contact oUnassignedCont = new Contact();
	    oUnassignedCont.AccountId = acNomEmp.Id;
	    oUnassignedCont.FirstName = 'Unassigned'; 
	    oUnassignedCont.LastName = 'Contact';    
	    oUnassignedCont.Active__c = true;
	    oUnassignedCont.Email = 'unassigned.etrading@nomura.com';
	    oUnassignedCont.Salutation = 'Mr.';
	    oUnassignedCont.Developer_Reference__c = 'Unassigned eTrading';    
	    Contacts.add(oUnassignedCont);
	    insert Contacts;
		
		List<ContactPlatform__c> ContPlatList = new List<ContactPlatform__c>(); 
		ContPlatList.add(new ContactPlatform__c(Name='BL_PF_ID_1',Contact__c=Contacts[0].Id,Email__c=Contacts[0].Email, 
			External_Id__c='Bloomberg-BL_PF_ID_1',Platform__c='Bloomberg',Status__c='Active'));
		ContPlatList.add(new ContactPlatform__c(Name='TW_PF_ID_1',Contact__c=Contacts[1].Id,Email__c=Contacts[1].Email, 
			External_Id__c='TradeWeb-TW_PF_ID_1',Platform__c='TradeWeb',Status__c='Active'));
		ContPlatList.add(new ContactPlatform__c(Name='BL_PF_ID_2',Contact__c=Contacts[2].Id,Email__c=Contacts[1].Email, 
			External_Id__c='Bloomberg-BL_PF_ID_2',Platform__c='Bloomberg',Status__c='Inactive'));
		insert ContPlatList;
		
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
        eTradingEnablementProduct.Name = 'Rates Cash - Gilts';
        eTradingEnablementProduct.Category__c = 'Rates Cash';
        eTradingEnablementProduct.Product__c = 'GILTS'; 
        eTradingEnablementProduct.ProductLabel__c = 'Gilts';
        insert eTradingEnablementProduct;
        
 		List<ETradingEnablement__c> ETEnablementList = new List<ETradingEnablement__c>();
		for(Integer i=0; i<100; ++i) {
        	ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
		 	eTradingEnablement.Request_Stage__c = 'Open';
		    eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
		    eTradingEnablement.ETradingEnablementProduct__c = eTradingEnablementProduct.id;
		    if(i<20) {
		    	eTradingEnablement.Contact__c = Contacts[2].Id;  
		    } else if(i<90){
		    	if(i<55) {
					eTradingEnablement.Electronic_Platform__c='Bloomberg';
					eTradingEnablement.Platform_Id__c='BL_PF_ID_1';
		    	} else {
		    		eTradingEnablement.Electronic_Platform__c='TradeWeb';
					eTradingEnablement.Platform_Id__c='TW_PF_ID_1';
		    	}
		    } else {
		    	eTradingEnablement.Electronic_Platform__c='Bloomberg';
				eTradingEnablement.Platform_Id__c='BL_PF_ID_2';
		    }
		    ETEnablementList.add(eTradingEnablement);
        }
        
        Test.startTest();
        	insert ETEnablementList;
        Test.stopTest();
        
		Integer noETRecsWithCont1 = 0;
		Integer noETRecsWithCont2 = 0;
		Integer noETRecsWithCont3 = 0;
		Integer noETRecsWithContUnAssgn = 0;
		for(ETradingEnablement__c oET : [SELECT Id, Contact__c FROM ETradingEnablement__c]) {
			if(oET.Contact__c==Contacts[0].Id) {
				++noETRecsWithCont1;
			} else if(oET.Contact__c==Contacts[1].Id) {
				++noETRecsWithCont2;
			} else if(oET.Contact__c==Contacts[2].Id) {
				++noETRecsWithCont3;
			}else if(oET.Contact__c==Contacts[3].Id) {
				++noETRecsWithContUnAssgn;
			}
		}
		System.assertEquals(noETRecsWithCont3, 20);
		System.assertEquals(noETRecsWithCont1, 35);
		System.assertEquals(noETRecsWithCont2, 35);
		System.assertEquals(noETRecsWithContUnAssgn, 10);
    }
	*/
}