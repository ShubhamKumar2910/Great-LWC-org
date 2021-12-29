/**
 *	Author 		: Pravin Kundal
 *	Company 	: Nomura
 *  Description : This class contains unit tests for validating the behavior of Apex class - AccountTriggerHandler  
 *
 */
@isTest
public class AccountTriggerHandlerTest {
	static testMethod void testChackAndResetMiFIDIIEntitlements() {
		System.debug('#### AccountTriggerHandlerTest::testChackAndResetMiFIDIIEntitlements()');
		// create some accounts	
    	List<Account> testAccounts =  new List<Account>();  
   		List<Contact> contacts = new List<Contact>(); 

        Account sLevel = UtilityTesting.createRSAccount(
            'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(sLevel);
            
        Account rg1 = UtilityTesting.createRGAccount(
                'G1 Test Account', sLevel.Id, 'RGTest1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1);
        Account rg2 = UtilityTesting.createRGAccount(
                'G2 Test Account', sLevel.Id, 'RGTest2', '53rd Street', 'California', 'United States', true);
        testAccounts.add(rg2);
        Account rg3 = UtilityTesting.createRGAccount(
                'G3 Test Account', sLevel.Id, 'RGTest3', '56rd Street', 'California', 'United States', true);
        testAccounts.add(rg3);
        
            
        Account rg1rm1 = UtilityTesting.createRMAccount(
                'RM Test Account 1', rg1.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        rg1rm1.Override_Contacts_MiFID_II_Entitlement__c = true;
        rg1rm1.MiFID_II_Research_In_Scope__c = true;
        rg1rm1.MiFIDII_Sales_Commentary_Allowed__c = 'Allowed';
        rg1rm1.MiFID_II_Product_Subscriptions__c='FIGL';
        rg1rm1.Service_Type__c='Full Service';
        testAccounts.add(rg1rm1);
        
        Account rg2rm2 = UtilityTesting.createRMAccount(
                'RM Test Account 2', rg2.Id, 'RMTest4', '52nd Street', 'California', 'United States', true);
        rg2rm2.Default_New_Contact_MiFID_II_Entitlement__c = true;
        rg2rm2.MiFID_II_Research_In_Scope__c = true;
        rg2rm2.MiFIDII_Sales_Commentary_Allowed__c = 'Not Allowed';
        testAccounts.add(rg2rm2);
		Account rg3rm3 = UtilityTesting.createRMAccount(
                'RM Test Account 3', rg3.Id, 'RMTest5', '56nd Street', 'California', 'United States', true);
        testAccounts.add(rg3rm3);
		
        insert testAccounts;
        
        Boolean isErr=false;
      	List<Contact> UpdContList = new List<Contact>();
      	Test.startTest();
      	try {
			List<Account> AccToUpdList = new List<Account>();
			AccToUpdList.add(new Account(Id=rg1rm1.Id, Override_Contacts_MiFID_II_Entitlement__c=false));
			AccToUpdList.add(new Account(Id=rg2rm2.Id, Default_New_Contact_MiFID_II_Entitlement__c=false));
			update AccToUpdList;
      	} catch(Exception ex) {
      		System.debug('Error : '+ex.getMessage());
      		System.debug('Error stack: '+ex.getStackTraceString());
      		isErr = true;
      	}
      	Test.stopTest();

		System.assertEquals(isErr, false);
		List<Id> AccIdList = new List<Id>{rg1rm1.Id, rg2rm2.Id, rg3rm3.Id};
		Map<Id, Account> RMAccMap = new Map<Id, Account>([SELECT Id,MiFID_II_Research_In_Scope__c,
				MiFIDII_Sales_Commentary_Allowed__c, MiFID_II_Product_Subscriptions__c, Service_Type__c 
			FROM Account WHERE Id IN :AccIdList]);
		
		System.assertEquals(RMAccMap.get(rg1rm1.Id).MiFID_II_Research_In_Scope__c, false);
		System.assertEquals(String.isBlank(RMAccMap.get(rg1rm1.Id).MiFIDII_Sales_Commentary_Allowed__c), true);
		System.assertEquals(String.isBlank(RMAccMap.get(rg1rm1.Id).MiFID_II_Product_Subscriptions__c), true);
		System.assertEquals(String.isBlank(RMAccMap.get(rg1rm1.Id).Service_Type__c), true);
		
		System.assertEquals(RMAccMap.get(rg2rm2.Id).MiFID_II_Research_In_Scope__c, false);
		System.assertEquals(String.isBlank(RMAccMap.get(rg2rm2.Id).MiFIDII_Sales_Commentary_Allowed__c), true);
		System.assertEquals(String.isBlank(RMAccMap.get(rg2rm2.Id).MiFID_II_Product_Subscriptions__c), true);
		System.assertEquals(String.isBlank(RMAccMap.get(rg2rm2.Id).Service_Type__c), true);
		
		System.assertEquals(RMAccMap.get(rg1rm1.Id).MiFID_II_Research_In_Scope__c, false);
		System.assertEquals(String.isBlank(RMAccMap.get(rg3rm3.Id).MiFIDII_Sales_Commentary_Allowed__c), true);
		System.assertEquals(String.isBlank(RMAccMap.get(rg3rm3.Id).MiFID_II_Product_Subscriptions__c), true);
		System.assertEquals(String.isBlank(RMAccMap.get(rg3rm3.Id).Service_Type__c), true);
	}
	
	static testMethod void testIdentifyAndUpdateMiFIDIIEntitlementsFromRMAccount() {
		System.debug('#### AccountTriggerHandlerTest::testIdentifyAndUpdateMiFIDIIEntitlementsFromRMAccount()');
        	
        // create some accounts	
    	List<Account> testAccounts =  new List<Account>();  
   		List<Contact> contacts = new List<Contact>(); 

        Account sLevel = UtilityTesting.createRSAccount(
            'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(sLevel);
            
        Account rg1 = UtilityTesting.createRGAccount(
                'G1 Test Account', sLevel.Id, 'RGTest1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1);
        Account rg2 = UtilityTesting.createRGAccount(
                'G2 Test Account', sLevel.Id, 'RGTest2', '53rd Street', 'California', 'United States', true);
        testAccounts.add(rg2);
        Account rg3 = UtilityTesting.createRGAccount(
                'G3 Test Account', sLevel.Id, 'RGTest3', '56rd Street', 'California', 'United States', true);
        testAccounts.add(rg3);
        
            
        Account rg1rm1 = UtilityTesting.createRMAccount(
                'RM Test Account 1', rg1.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        rg1rm1.Override_Contacts_MiFID_II_Entitlement__c = true;
        rg1rm1.MiFID_II_Research_In_Scope__c = true;
        rg1rm1.MiFIDII_Sales_Commentary_Allowed__c = 'Not Allowed';
        testAccounts.add(rg1rm1);
        Account rg2rm2 = UtilityTesting.createRMAccount(
                'RM Test Account 2', rg2.Id, 'RMTest4', '52nd Street', 'California', 'United States', true);
        rg2rm2.Default_New_Contact_MiFID_II_Entitlement__c = true;
        rg2rm2.MiFID_II_Research_In_Scope__c = true;
        rg2rm2.MiFIDII_Sales_Commentary_Allowed__c = 'Allowed';
        testAccounts.add(rg2rm2);
		Account rg3rm3 = UtilityTesting.createRMAccount(
                'RM Test Account 3', rg3.Id, 'RMTest5', '56nd Street', 'California', 'United States', true);
        testAccounts.add(rg3rm3);
		
        insert testAccounts;
        
        System.debug('Accounts inserted');
        
        List<Contact> ContactList = new List<Contact>();
        for(Integer i=0; i<200; ++i) {
        	if(i<10) {
	        	Contact oCOnt = UtilityTesting.createContact('John'+i, 'Smith'+i, 'johnnysmith'+i+'@test'+i+'.com', '(212) 333-456'+i, 'Dear [FirstName]', rg1rm1.Id, true);
	        	oCOnt.RG_Account__c=rg1.Id;
	        	ContactList.add(oCOnt);
        	} else if(i<100) {
	        	Contact oCOnt = UtilityTesting.createContact('John'+i, 'Smith'+i, 'johnnysmith'+i+'@test'+i+'.com', '(212) 333-45'+i, 'Dear [FirstName]', rg1rm1.Id, true);
	        	oCOnt.RG_Account__c=rg1.Id;
	        	ContactList.add(oCOnt);
        	} else if(i < 150) {
        		Contact oCOnt = UtilityTesting.createContact('John'+i, 'Smith'+i, 'johnnysmith'+i+'@test'+i+'.com', '(212) 333-45'+i, 'Dear [FirstName]', rg2rm2.Id, true);
	        	oCOnt.RG_Account__c=rg2.Id;
	        	ContactList.add(oCOnt);
        	} else {
        		Contact oCOnt = UtilityTesting.createContact('John'+i, 'Smith'+i, 'johnnysmith'+i+'@test'+i+'.com', '(212) 333-45'+i, 'Dear [FirstName]', rg3rm3.Id, true);
	        	oCOnt.RG_Account__c=rg3.Id;
	        	ContactList.add(oCOnt);
        	} 
        }
        insert ContactList;
        
        System.debug('contacts inserted');
        
      	Boolean isErr=false;
      	Test.startTest();
      	try {
      		List<Account> AccToUpdList = new List<Account>();
      		AccToUpdList.add(new Account(Id=rg1rm1.Id, MiFIDII_Sales_Commentary_Allowed__c = 'Allowed', MiFID_II_Product_Subscriptions__c='FIGL',
      				Service_Type__c='Full Service'));
      		AccToUpdList.add(new Account(Id=rg2rm2.Id, MiFIDII_Sales_Commentary_Allowed__c = 'Not Allowed'));
      		
      		update AccToUpdList;
      	} catch(Exception ex) {
      		System.debug('Error : '+ex.getMessage());
      		isErr = true;
      	}
      	
      	System.debug('Before stopTest');
      	Test.stopTest();
      	System.debug('After stopTest');

		System.assertEquals(isErr, false);
		
		List<Contact> ContFromDBList = [SELECT Id, AccountId, MiFIDII_in_Scope__c, MiFIDII_Sales_Commentary_Allowed__c, 
				MiFID_II_Product_Subscriptions__c, Service_Type__c
			FROM Contact ORDER BY AccountId];

		List<CampaignMember> CMList = [SELECT Id, Status, Short_Description__c FROM CampaignMember];
		for(CampaignMember oCM : CMList) {
			System.debug('oCM : '+oCM);
		}
			
		System.assertEquals(ContFromDBList.size(), 200);
		for(Contact oCont : ContFromDBList ) {
			if(oCont.accountId==rg1rm1.Id) {
				System.assertEquals(oCont.MiFIDII_in_Scope__c, true);
				System.assertEquals(oCont.MiFIDII_Sales_Commentary_Allowed__c, 'Allowed');
				System.assertEquals(oCont.MiFID_II_Product_Subscriptions__c, 'FIGL');
				System.assertEquals(oCont.Service_Type__c, 'Full Service');
			} else if(oCont.accountId==rg2rm2.Id) {
				System.assertEquals(oCont.MiFIDII_in_Scope__c, true);
				System.assertEquals(oCont.MiFIDII_Sales_Commentary_Allowed__c, 'Allowed');
				System.assertEquals(String.isBlank(oCont.MiFID_II_Product_Subscriptions__c), true);
				System.assertEquals(String.isBlank(oCont.Service_Type__c), true);
			} else if(oCont.accountId==rg3rm3.Id) {
				System.assertEquals(oCont.MiFIDII_in_Scope__c, false);
				System.assertEquals(String.isBlank(oCont.MiFIDII_Sales_Commentary_Allowed__c), true);
				System.assertEquals(String.isBlank(oCont.MiFID_II_Product_Subscriptions__c), true);
				System.assertEquals(String.isBlank(oCont.Service_Type__c), true);
			} 
		}
	}
}