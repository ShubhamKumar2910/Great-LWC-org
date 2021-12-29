/**
 *	Author 		: Pravin Kundal
 *	Company 	: Nomura
 *  Description : This class contains unit tests for validating the behavior of Apex class - ContactTriggerHandler 
 *
 */
@isTest
public class ContactTriggerHandlerTest {
	static testMethod void testCheckAndUpdateMiFIDIIEntitlementsFromRMAccount() {
		System.debug('#### ContactChangeValidationTest::testVlidateMiFIDIIEntitlementChange()');
        	
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
        
      	Boolean isErr=false;
      	Test.startTest();
      	try {
      		insert ContactList;
      	} catch(Exception ex) {
      		System.debug('Error : '+ex.getMessage());
      		isErr = true;
      	}
      	Test.stopTest();

		System.assertEquals(isErr, false);
		List<Contact> ContFromDBList = [SELECT Id, AccountId, MiFIDII_in_Scope__c, MiFIDII_Sales_Commentary_Allowed__c 
			FROM Contact ORDER BY AccountId];
		System.assertEquals(ContFromDBList.size(), 200);
		for(Contact oCont : ContFromDBList ) {
			if(oCont.accountId==rg1rm1.Id) {
				System.assertEquals(oCont.MiFIDII_in_Scope__c, true);
				System.assertEquals(oCont.MiFIDII_Sales_Commentary_Allowed__c, 'Allowed');
			} else if(oCont.accountId==rg2rm2.Id) {
				System.assertEquals(oCont.MiFIDII_in_Scope__c, true);
				System.assertEquals(oCont.MiFIDII_Sales_Commentary_Allowed__c, 'Not Allowed');
			} else if(oCont.accountId==rg3rm3.Id) {
				System.assertEquals(oCont.MiFIDII_in_Scope__c, false);
				System.assertEquals(String.isBlank(oCont.MiFIDII_Sales_Commentary_Allowed__c), true);
			} 
		}
	}
	
	static testMethod void testActivateDeactivateContact() {
		User integrationUserObj = [SELECT Id, Login_Id__c, Alias, LastName, Email, UserName, ProfileId 
                        		   FROM User WHERE Login_Id__c = 'sfadmin' LIMIT 1];
        System.runAs(integrationUserObj){
		
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
			insert testAccounts;
			testAccounts.clear();
				
			Account rg1rm1 = UtilityTesting.createRMAccount(
					'RM Test Account 1', rg1.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
			testAccounts.add(rg1rm1);
			Account rg2rm2 = UtilityTesting.createRMAccount(
					'RM Test Account 2', rg2.Id, 'RMTest4', '52nd Street', 'California', 'United States', true);
			testAccounts.add(rg2rm2);
			Account rg3rm3 = UtilityTesting.createRMAccount(
					'RM Test Account 3', rg3.Id, 'RMTest5', '56nd Street', 'California', 'United States', true);
			testAccounts.add(rg3rm3);
			insert testAccounts;

			//SALES-3839
			Instinet_Mapping__c instinetMappingObj = new Instinet_Mapping__c(CDB_Id__c = '1234', Name = 'Test RM Account 1234',RM_Id__c = rg2rm2.Id);
			insert instinetMappingObj;
			
			List<Contact> ContactList = new List<Contact>();
			for(Integer i=0; i<50; ++i) {
				if(i<25) {
					Contact oCOnt = UtilityTesting.createContact('John'+i, 'Smith'+i, 'johnnysmith'+i+'@test'+i+'.com', '(212) 333-456'+i, 'Dear [FirstName]', rg1rm1.Id, true);
					oCOnt.RG_Account__c=rg1.Id;
					if(i<10){
						oCOnt.Source__c = 'Feed';
					}else{
						oCOnt.Source__c = 'Instinet';
						oCOnt.CDB_Id__c = '1234';
						oCOnt.CDB_Name__c = 'Test RM Account 1234';                    
					}
					ContactList.add(oCOnt);
				} else if(i < 50) {
					Contact oCOnt = UtilityTesting.createContact('John'+i, 'Smith'+i, 'johnnysmith'+i+'@test'+i+'.com', '(212) 333-45'+i, 'Dear [FirstName]', rg2rm2.Id, true);
					oCOnt.RG_Account__c=rg2.Id;
					oCOnt.Active__c = false;
					oCOnt.Inactive_Reason__c='Other';
					oCOnt.Other_Inactive_Reason__c = 'Other';
					if(i<35){
						oCOnt.Source__c = 'Feed';
					}else{
						oCOnt.Source__c = 'Instinet';
						oCOnt.CDB_Id__c = '5678';
						oCOnt.CDB_Name__c = 'Test RM Account 5678';
					}
					ContactList.add(oCOnt);
				}            
			}

			Test.startTest();		
			insert ContactList;
			Test.stopTest();
		
			List<Contact> ContList = [SELECT Id, Active__c, RG_Account__c, RecordType.Name FROM Contact WHERE Active__c = true];        
			for(Contact oCont : ContList) {
				System.assertEquals(oCont.Active__c, true);
				System.assertEquals(oCont.RecordType.Name, 'Active Contact');
				System.assertNotEquals(oCont.RG_Account__c, null);
			}
			
			List<Contact> ContToDeactivateList = [SELECT Id, Active__c, Inactive_Reason__c FROM Contact];
			for(Contact oCont : ContToDeactivateList) {
				oCont.Active__c = false;
				oCont.Inactive_Reason__c = 'Left the Firm';
			}
			update ContToDeactivateList;
			
			ContToDeactivateList = [SELECT Id, Active__c, RecordType.Name FROM Contact];
			for(Contact oCont : ContToDeactivateList) {
				//System.assertEquals(oCont.RecordType.Name, 'Inactive Contact');
			}
			
			List<Contact> ContToActivateList = [SELECT Id, Active__c, Inactive_Reason__c FROM Contact];
			for(Contact oCont : ContToActivateList) {
				oCont.Active__c = true;
			}
			update ContToActivateList;
			
			ContToActivateList = [SELECT Id, Active__c, RecordType.Name FROM Contact];
			for(Contact oCont : ContToActivateList) {
				System.assertEquals(oCont.RecordType.Name, 'Active Contact');
			}
		}        
	}
    
    static testMethod void testNotifyContactSponsorChange() {
       //Insert RG Account
       Account accountRG = UtilityTesting.createRGAccount('RG_Account_Dummy', null, 'RG111111', null, null, null, TRUE); 
       insert accountRG;
      
       //Insert RM Account 
       Account accountRM = UtilityTesting.createRMAccount('RM_Account_Dummy', accountRG.Id, 'RM222222', '52nd Street', 'California', 'United States', TRUE); 
       insert accountRM;
        
       //Insert Contact
       Contact contactObj = new Contact();
       contactObj.AccountId = accountRM.Id;
       contactObj.FirstName = 'TestDummyFN_1'; 
       contactObj.LastName = 'TestDummyLN_1';    
       contactObj.Active__c = TRUE;
       contactObj.Email = 'TestDummy1@testOrg.com';
       contactObj.Phone = '+0000000000'; 
       contactObj.Salutation = 'M.';    
       contactObj.Mailing_Address_Same_As_Account_Address__c = TRUE;
       contactObj.RG_Account__c = accountRG.Id;
       contactObj.GRP_Access__c = TRUE;
       contactObj.Investor_Type__c = 'Americas- Qualified Institutional Buyer';
       contactObj.Region__c = 'Americas';
       contactObj.Preferred_Language__c = 'English';
       contactObj.Sales_Sponsor__c = 'Sankarkartik Raman';
       contactObj.Sponsor_Email_Text__c = 'sankarkartik.raman@nomura.com';
        
       insert contactObj;
        
       List<Id> contactIdList = new List<Id>();
       contactIdList.add(contactObj.Id);
        
       ContactTriggerHandler.notifyContactSponsorChange(contactIdList);
        
    }
}