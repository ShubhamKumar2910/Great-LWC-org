@isTest
public class NewContactControllerTest {
	@isTest
    private static void testIsCurrentUserMifidAdmin() {
        // test method
        // system admin profile
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
        
        Test.startTest();
        System.runAs(testUser) {
            System.assertEquals(NewContactController.isCurrentUserMifidAdmin(), true);
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testGetProductSubscriptionPicklistValues() {
        Map<String, String> picklistValues = NewContactController.getProductSubscriptionPicklistValues();
        System.assertNotEquals(picklistValues, null);
    }
    
    @isTest
    private static void testGetContactDetails() {
        RecordType recordTypeForRG = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'RG_Account'];
        RecordType recordTypeForRM = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'RM_Account'];
        
        Account ac = new Account(Name='Test',RecordTypeId = recordTypeForRG.Id, BillingCity = 'California',
                                 BillingCountry = 'United States',
                                 BillingStreet = '52nd Street' );
        Account acNomEmp = new Account(Name='NOMURA EMPLOYEES');
        insert ac;
        insert acNomEmp;
        
        Account accountRM = new Account(Name='Test_RM_Account',RecordTypeId = recordTypeForRM.Id, ParentId = ac.Id,BillingCity = 'California',
                                        BillingCountry = 'United States',
                                        BillingStreet = '52nd Street' );
        insert accountRM;
        
        //add a test contact
        Contact testCon = new Contact();
        testCon.Salutation = 'Mr.';
        testCon.FirstName = 'FirstName';
        testCon.LastName = 'lastName';
        testCon.phone = '(317) 365-2343';
        testCon.Email = 'test@test.com';
        testCon.AccountId = accountRM.id;
        testCon.Active__c = true;
        insert testCon;
        
        Test.startTest();
        	Contact oCont = NewContactController.getContactDetails(testCon.Id);
        System.assertNotEquals(oCont, null);
        Test.stopTest();
    }
    
    @isTest
    private static void testGetAccountAddrAndDefMifidScope() {
        RecordType recordTypeForRG = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'RG_Account'];
        RecordType recordTypeForRM = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'RM_Account'];
        
        Account ac = new Account(Name='Test',RecordTypeId = recordTypeForRG.Id, BillingCity = 'California',
                                 BillingCountry = 'United States',
                                 BillingStreet = '52nd Street' );
        Account acNomEmp = new Account(Name='NOMURA EMPLOYEES');
        insert ac;
        insert acNomEmp;
        
        Account accountRM = new Account(Name='Test_RM_Account',RecordTypeId = recordTypeForRM.Id, ParentId = ac.Id,BillingCity = 'California',
                                        BillingCountry = 'United States',
                                        BillingStreet = '52nd Street' );
        insert accountRM;
        
        //add a test contact
        Contact testCon = new Contact();
        testCon.Salutation = 'Mr.';
        testCon.FirstName = 'FirstName';
        testCon.LastName = 'lastName';
        testCon.phone = '(317) 365-2343';
        testCon.Email = 'test@test.com';
        testCon.AccountId = accountRM.id;
        testCon.Active__c = true;
        insert testCon;
        
        Test.startTest();
        	List<Account> AccList = NewContactController.getAccountAddresses(ac.Id);
        	System.assertNotEquals(AccList.size(), 0);
        	//NewContactController.defaultMifidScopeBasedOnRM(ac.Id);
        Test.stopTest();
    }
    
    @isTest
    private static void testSaveContact() {
        RecordType recordTypeForRG = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'RG_Account'];
        RecordType recordTypeForRM = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'RM_Account'];
        
        Account ac = new Account(Name='Test',RecordTypeId = recordTypeForRG.Id, BillingCity = 'California',
                                 BillingCountry = 'United States',
                                 BillingStreet = '52nd Street' );
        Account acNomEmp = new Account(Name='NOMURA EMPLOYEES');
        insert ac;
        insert acNomEmp;
        
        Account accountRM = new Account(Name='Test_RM_Account',RecordTypeId = recordTypeForRM.Id, ParentId = ac.Id,BillingCity = 'California',
                                        BillingCountry = 'United States',
                                        BillingStreet = '52nd Street' );
        insert accountRM;
        
        //add a test contact
        Contact testCon = new Contact();
        testCon.Salutation = 'Mr.';
        testCon.FirstName = 'FirstName';
        testCon.LastName = 'lastName';
        testCon.phone = '(317) 365-2343';
        testCon.Email = 'test@test.com';
        testCon.AccountId = accountRM.id;
        testCon.Active__c = true;
        insert testCon;
        
        Test.startTest();
        testCon.MiFIDII_in_Scope__c = true;
        Map<String, String> resultMap = NewContactController.saveContact(testCon, accountRM.Id, 'Allowed', 'Full Service', new String[]{'EQAE'}, 
                                                                         'English', 'EMEA',  'EMEA-Qualified User');
        System.assertEquals(resultMap.containsKey('Error'), false);
        Test.stopTest();
    
    }
    
    @isTest
    private static void testGetInitializeInfo() {
        RecordType recordTypeForRG = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'RG_Account'];
        RecordType recordTypeForRM = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'RM_Account'];
        
        Account ac = new Account(Name='Test',RecordTypeId = recordTypeForRG.Id, BillingCity = 'California',
                                 BillingCountry = 'United States',
                                 BillingStreet = '52nd Street' );
        Account acNomEmp = new Account(Name='NOMURA EMPLOYEES');
        insert ac;
        insert acNomEmp;
        
        Account accountRM = new Account(Name='Test_RM_Account',RecordTypeId = recordTypeForRM.Id, ParentId = ac.Id,BillingCity = 'California',
                                        BillingCountry = 'United States',
                                        BillingStreet = '52nd Street' );
        insert accountRM;
        
        //add a test contact
        Contact testCon = new Contact();
        testCon.Salutation = 'Mr.';
        testCon.FirstName = 'FirstName';
        testCon.LastName = 'lastName';
        testCon.phone = '(317) 365-2343';
        testCon.Email = 'test@test.com';
        testCon.AccountId = accountRM.id;
        testCon.Active__c = true;
        insert testCon;
        
        Test.startTest();
        	NewContactController.EditContactWrapper editContWrapper = NewContactController.getInitializeInfo(testCon.Id);
        	System.assertNotEquals(editContWrapper, null);
        Test.stopTest();
    }
    
    @isTest
    private static void testGetCurrentUserDetAndApplySponsor() {
        // test method
        // system admin profile
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
        
        Test.startTest();
        System.runAs(testUser) {
            RecordType recordTypeForRG = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'RG_Account'];
            RecordType recordTypeForRM = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'RM_Account'];
            
            Account ac = new Account(Name='Test',RecordTypeId = recordTypeForRG.Id, BillingCity = 'California',
                                     BillingCountry = 'United States',
                                     BillingStreet = '52nd Street' );
            Account acNomEmp = new Account(Name='NOMURA EMPLOYEES');
            insert ac;
            insert acNomEmp;
            
            Account accountRM = new Account(Name='Test_RM_Account',RecordTypeId = recordTypeForRM.Id, ParentId = ac.Id,BillingCity = 'California',
                                            BillingCountry = 'United States',
                                            BillingStreet = '52nd Street' );
            insert accountRM;
            
            //add a test contact
            Contact testCon = new Contact();
            testCon.Salutation = 'Mr.';
            testCon.FirstName = 'FirstName';
            testCon.LastName = 'lastName';
            testCon.phone = '(317) 365-2343';
            testCon.Email = 'test@test.com';
            testCon.AccountId = accountRM.id;
            testCon.Active__c = true;
            insert testCon;
            
            System.assertNotEquals(NewContactController.getCurrentUserDetails(), null);
            System.assertNotEquals(NewContactController.applySponsor(testUser.Id), null);
            System.assertNotEquals(NewContactController.applySponsor(testCon.Id), null);
        }
        Test.stopTest();
    }
    
     @isTest
    private static void testGetDefaultMiFIDIIEntitlementFromRMAccont() {
    	System.debug('#### NewContactControllerTest::testGetDefaultMiFIDIIEntitlementFromRMAccont');
    	System.debug('#### CampaignServiceTest::testBulkUploadCampaignFunctionality()');
        final String CAMPAIGN_RT_NAME_BULK_UPLOAD  = 'Bulk_Upload';
		String campId = CampaignService.getBulkUploadCampaignRec(null, CAMPAIGN_RT_NAME_BULK_UPLOAD, 'ApplyMiFIDIIEntitlements');
		System.assertEquals(String.isNotBlank(campId), true);
		
		String reportURL = CampaignService.getBulkUploadReportURL(campId, 'Bulk_Upload_Campaign_Report');
		System.assertEquals(String.isNotBlank(reportURL), true);
		
		delete ([SELECT Id From campaign]);		
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
      	NewContactController.DefaultMiFIDIIEntitlementRMAccount miFIDIIEntitlementWithOverride;
      	NewContactController.DefaultMiFIDIIEntitlementRMAccount miFIDIIEntitlementWithoutOverride;
      	Test.startTest();
      	try {
      		miFIDIIEntitlementWithOverride = NewContactController.getDefaultMiFIDIIEntitlementFromRMAccont(rg1rm1.Id);
      		
      		List<Account> AccToUpdList = new List<Account>();
      		AccToUpdList.add(new Account(Id=rg1rm1.Id, Override_Contacts_MiFID_II_Entitlement__c = false));
      		update AccToUpdList;
      		
      		miFIDIIEntitlementWithoutOverride = NewContactController.getDefaultMiFIDIIEntitlementFromRMAccont(rg1rm1.Id);
      	} catch(Exception ex) {
      		System.debug('Error : '+ex.getMessage());
      		isErr = true;
      	}
      	System.debug('Before stopTest');
      	Test.stopTest();
      	System.debug('After stopTest');
      	
      	System.assertEquals(isErr, false);
      	
      	System.assertEquals(miFIDIIEntitlementWithOverride.applyMiFIDIIEntitlementFromRMAccount, true);
      	System.assertEquals(miFIDIIEntitlementWithOverride.rmAccId, rg1rm1.Id);
      	System.assertEquals(miFIDIIEntitlementWithOverride.rmAccMiFIDIIResearchInScope, rg1rm1.MiFID_II_Research_In_Scope__c);
      	System.assertEquals(miFIDIIEntitlementWithOverride.rmAccMiFIDIISalesCommentaryAllowed, rg1rm1.MiFIDII_Sales_Commentary_Allowed__c);
      	System.assertEquals(String.isBlank(miFIDIIEntitlementWithOverride.rmAccServiceType), true);
      	System.assertEquals(String.isBlank(miFIDIIEntitlementWithOverride.rmAccMiFIDIIProductSubscriptions), true);
      	System.assertEquals(miFIDIIEntitlementWithOverride.rmAccMiFIDIIInScope, false);
      	
      	System.assertEquals(miFIDIIEntitlementWithoutOverride.applyMiFIDIIEntitlementFromRMAccount, false);
      	System.assertEquals(String.isBlank(miFIDIIEntitlementWithoutOverride.rmAccId), true);
      	System.assertEquals(miFIDIIEntitlementWithoutOverride.rmAccMiFIDIIInScope, true);
      	
    }
}