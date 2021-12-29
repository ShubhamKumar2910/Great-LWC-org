/**
 *	Author 		: Pravin Kundal
 *	Company 	: Nomura
 *  Description : This class contains unit tests for validating the behavior of Apex class - AccountMiFIDIIMesageController  
 *
 */
@isTest 
public class AccountMiFIDIIMesageControllerTest {
	static testMethod void testInitialize() {
		System.debug('#### AccountMiFIDIIMesageControllerTest::testInitialize()');
		Profile p  = [SELECT Id From Profile WHERE Name='System Administrator' limit 1];

		// insert user test
		User testUser = new User();
		testUser.Alias = 'newUser';
		testUser.UserName = 'unit.test@nomura.com';
        testUser.Email ='unit.test@nomura.com';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.LastName = 'Testing1';
        testUser.LanguageLocaleKey='en_US';
        testUser.LocaleSidKey='en_US';
        testUser.ProfileId=p.Id;
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.SingletrackMIFIDII_ResearchAdmin__c = true;

        insert testUser;
        Boolean result = false; 
        Test.startTest();
        System.runAs(testUser) {
        	result = AccountMiFIDIIMesageController.initialize('System Administrator,Nomura - Production Services,Singletrack_Administrator');
        }
        Test.stopTest();				
		System.assertEquals(result, true);
	}
	
	static testMethod void testGetJobStatus() {
		System.debug('#### AccountMiFIDIIMesageControllerTest::testGetJobStatus()');
	
		// create some accounts	
    	List<Account> testAccounts =  new List<Account>();  
   		List<Contact> contacts = new List<Contact>(); 

        Account sLevel = UtilityTesting.createRSAccount(
            'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(sLevel);
            
        Account rg1 = UtilityTesting.createRGAccount(
                'G1 Test Account', sLevel.Id, 'RGTest1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1);
            
        Account rg1rm1 = UtilityTesting.createRMAccount(
                'RM Test Account 1', rg1.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        rg1rm1.Override_Contacts_MiFID_II_Entitlement__c = true;
        rg1rm1.MiFID_II_Research_In_Scope__c = true;
        rg1rm1.MiFIDII_Sales_Commentary_Allowed__c = 'Not Allowed';
        testAccounts.add(rg1rm1);
        
        insert testAccounts;
        System.debug('Accounts inserted');
        
        List<Contact> ContactList = new List<Contact>();
        Contact oCOnt = UtilityTesting.createContact('John', 'Smith', 'johnnysmith@test.com', '(212) 333-4561', 'Dear [FirstName]', rg1rm1.Id, true);
    	oCOnt.RG_Account__c=rg1.Id;
    	ContactList.add(oCOnt);
        insert ContactList;
        
        System.debug('contacts inserted');
        
      	Boolean isErr=false;
      	Test.startTest();
      	try {
      		List<Account> AccToUpdList = new List<Account>();
      		AccToUpdList.add(new Account(Id=rg1rm1.Id, MiFIDII_Sales_Commentary_Allowed__c = 'Allowed', MiFID_II_Product_Subscriptions__c='FIGL',
      				Service_Type__c='Full Service'));
      		update AccToUpdList;
      	} catch(Exception ex) {
      		System.debug('Error : '+ex.getMessage());
      		isErr = true;
      	}
      	System.debug('Before stopTest');
      	Test.stopTest();
      	System.debug('After stopTest');
      	
      	AccountMiFIDIIMesageController.MiFIDIIEntitlementJobInfo jobInfo = AccountMiFIDIIMesageController.getJobStatus(rg1rm1.Id, null);
      	System.assertEquals(String.isNotBlank(jobInfo.campaignId), true);
      	System.assertEquals(String.isNotBlank(jobInfo.reportURL), true);
      	System.assertEquals(String.isNotBlank(jobInfo.percentProg), true);
	}
}