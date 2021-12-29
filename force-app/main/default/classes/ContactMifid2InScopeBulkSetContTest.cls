/**
 *	Author 		: Pravin Kundal
 *	Company 	: Nomura
 *  Description : This class contains unit tests for validating the behavior of Apex class - ContactMifid2InScopeBulkSetController 
 *
 */
@isTest
public class ContactMifid2InScopeBulkSetContTest {
	
	static testMethod void testGetProductSubscriptionPicklistValues() {
		System.debug('#### ContactMifid2InScopeBulkSetContTest::testGetProductSubscriptionPicklistValues()');
		ContactMifid2InScopeBulkSetController.getProductSubscriptionPicklistValues();
	}
	
	static testMethod void testApplySponsor() {
	   System.debug('#### ContactMifid2InScopeBulkSetContTest::testApplySponsor()');
	   Integer numTestAccounts = 4;
	   Integer numTestUsers = 4;     
	   List<Contact> contacts = new List<Contact>(); 
	   List<Coverage_Team_Member__c> cvgTmMbrs =  new List<Coverage_Team_Member__c>(); 
	   List<Task> Tasks = new List<Task>();
	   List<Event> Events = new List<Event>(); 
	   List<Opportunity> Opportunities = new List<Opportunity>(); 
	   List<Revenue_Rollup__c> revenueRollups = new List<Revenue_Rollup__c>(); 
	   List<Account> testAccounts =  new List<Account>();     
	   
	   List<Id> AccIdList = new List<Id>();
	        
	 
	    RecordType RGRecordType = [SELECT Id FROM RecordType WHERE Name = 'RG Account' ];
	    RecordType RSRecordType = [SELECT Id FROM RecordType WHERE Name = 'RS Account' ];
	    RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account' ];
	        
	    system.debug('RGRecordType : ' + RGRecordType.Id);
	    system.debug('RSRecordType : ' + RSRecordType.Id);  
	    system.debug('RMRecordType : ' + RMRecordType.Id) ; 
	        
	    List<User> users = UtilityTesting.CreateUsersWithManager(numTestUsers);
	    
	    Account accountAdd = new Account();
	    accountAdd.Name = 'TestAccount1';
	    accountAdd.RDM_Org_ID__c = 'test1';            
	    accountAdd.RecordTypeId = RSRecordType.Id;
	    accountAdd.BillingCity = 'California';
	    accountAdd.BillingCountry = 'United States';
	    accountAdd.BillingStreet = '52nd Street' ;
	    accountAdd.Restricted_Flag__c=true;
	    accountAdd.Domicile_Country__c='US';
	    insert accountAdd;    
	
	    Account account2  = new Account(); 
	    account2.Name = 'TestAccount2';
	    account2.RDM_Org_ID__c = 'test1';            
	    account2.RecordTypeId = RGRecordType.Id;
	    account2.ParentId = accountAdd.Id;
		account2.BillingCity = 'California';
	    account2.BillingCountry = 'United States';
	    account2.BillingStreet = '52nd Street' ;
	    account2.Restricted_Flag__c=true;
	    account2.Domicile_Country__c='US';
	    insert account2;
	    AccIdList.add(account2.Id);
	        
	    Account account3  = new Account(); 
	    account3.Name = 'TestAccount3';
	    account3.RDM_Org_ID__c = 'test3';            
	    account3.RecordTypeId = RMRecordType.Id;
	    account3.ParentId = account2.Id;
	    account3.Active__c = true;
	    account3.BillingCity = 'California';
	    account3.BillingCountry = 'United States';
	    account3.BillingStreet = '52nd Street' ;
	    account3.Restricted_Flag__c=true;
	    account3.Domicile_Country__c='US';
		insert account3;
		AccIdList.add(account3.Id); 
	        
	    system.debug('RM Account 1 :'+ account3.Id) ;  
	    system.debug('RG Account  :'+ account2.id) ;
	    system.debug('RS Account  :'+ accountAdd.id) ; 
	    system.debug('ParentId RM Account 1  :'+ account3.ParentId) ;
	    system.debug('ParentId RG Account  :'+ account2.ParentId) ;     
	        
	    Contact contactAdd = new Contact();
	
	    contactAdd.AccountId = account3.id;
	    contactAdd.FirstName = 'vipin'; 
	    contactAdd.LastName = 'pillai';    
	    contactAdd.Active__c = true;
	    contactAdd.Email = 'a@a.com';
	    contactAdd.Phone = '(212) 333-4567'; 
	    contactAdd.Salutation = 'Dear [FirstName]';    
	    Contacts.add(contactAdd);
	    contactAdd = new Contact();
	    
	    insert Contacts; 
	        
	    system.debug('Contact Account :'+ Contacts[0].AccountId) ;  
	    
	    Test.startTest();
			Contact oCont = ContactMifid2InScopeBulkSetController.applySponsor(users[0].Id);
			System.assertNotEquals(oCont, null);
			oCont = ContactMifid2InScopeBulkSetController.applySponsor(Contacts[0].Id);
			System.assertNotEquals(oCont, null);	    
	    Test.stopTest();  
	}
	
	static testMethod void testCheckBatchSize() {
		System.debug('#### ContactMifid2InScopeBulkSetContTest::testCheckBatchSize()');
		List<String> EmailList = new List<String>();
		for(Integer i=1;i<=20;++i) {
			EmailList.add('abc'+i+'@xyz.com');
		} 
		ContactMifid2InScopeBulkSetController.checkBatchSize(EmailList, 'In Scope', 200);
		ContactMifid2InScopeBulkSetController.checkBatchSize(EmailList, 'In Scope', 10);
		ContactMifid2InScopeBulkSetController.checkBatchSize(EmailList, 'Out Of Scope', 200);
		ContactMifid2InScopeBulkSetController.checkBatchSize(EmailList, 'Out Of Scope', 10);
	}
	
	static testMethod void testGetContactsFromEmails() {
		System.debug('#### ContactMifid2InScopeBulkSetContTest::testGetContactsFromEmails()');
		
		Integer numTestAccounts = 4;
	   Integer numTestUsers = 4;     
	   List<Contact> contacts = new List<Contact>(); 
	   List<Coverage_Team_Member__c> cvgTmMbrs =  new List<Coverage_Team_Member__c>(); 
	   List<Task> Tasks = new List<Task>();
	   List<Event> Events = new List<Event>(); 
	   List<Opportunity> Opportunities = new List<Opportunity>(); 
	   List<Revenue_Rollup__c> revenueRollups = new List<Revenue_Rollup__c>(); 
	   List<Account> testAccounts =  new List<Account>();     
	   List<String> contactEmailList = new List<String>();
	 

	    RecordType RGRecordType = [SELECT Id FROM RecordType WHERE Name = 'RG Account' ];
	    RecordType RSRecordType = [SELECT Id FROM RecordType WHERE Name = 'RS Account' ];
	    RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account' ];
		RecordType PODRecordType = [SELECT Id FROM RecordType WHERE Name = 'POD Account' ];
	        
	    system.debug('RGRecordType : ' + RGRecordType.Id);
	    system.debug('RSRecordType : ' + RSRecordType.Id);  
	    system.debug('RMRecordType : ' + RMRecordType.Id);
		system.debug('PODRecordType : ' + PODRecordType.Id);

	   
	    List<User> users = UtilityTesting.CreateUsersWithManager(numTestUsers);
	        
	    Account accountAdd = new Account();
	    accountAdd.Name = 'TestAccount1';
	    accountAdd.RDM_Org_ID__c = 'test1';            
	    accountAdd.RecordTypeId = RSRecordType.Id;
	    accountAdd.BillingCity = 'California';
	    accountAdd.BillingCountry = 'United States';
	    accountAdd.BillingStreet = '52nd Street' ;
		testAccounts.add(accountAdd);
	
	    Account account2  = new Account(); 
	    account2.Name = 'TestAccount2';
	    account2.RDM_Org_ID__c = 'test1';            
	    account2.RecordTypeId = RGRecordType.Id;
	    account2.ParentId = accountAdd.Id;
		account2.BillingCity = 'California';
	    account2.BillingCountry = 'United States';
	    account2.BillingStreet = '52nd Street' ;
		testAccounts.add(account2);
	        
	    Account account3  = new Account(); 
	    account3.Name = 'TestAccount3';
	    account3.RDM_Org_ID__c = 'test3';            
	    account3.RecordTypeId = RMRecordType.Id;
	    account3.ParentId = account2.Id;
	    account3.Active__c = true;
	    account3.BillingCity = 'California';
	    account3.BillingCountry = 'United States';
	    account3.BillingStreet = '52nd Street' ;
		testAccounts.add(account3);
	        
		Account account4  = new Account();  
		account4.Name = 'TestAccount4';
		account4.RDM_Org_ID__c = 'test4';            
		account4.RecordTypeId = RMRecordType.Id;
		account4.ParentId = account2.id;
		account4.Active__c = true; 
		account4.BillingCity = 'California';
		account4.BillingCountry = 'United States';
		account4.BillingStreet = '52nd Street' ;

		testAccounts.add(account4);
	   
	    Account account5  = new Account();  
		account5.Name = 'TestAccount5';
		account5.RDM_Org_ID__c = 'test5';            
		account5.RecordTypeId = PODRecordType.Id;
		account5.ParentId = account2.id;
		account5.Active__c = true; 
		account5.BillingCity = 'California';
		account5.BillingCountry = 'United States';
		account5.BillingStreet = '52nd Street' ;

		testAccounts.add(account5);

	    Account account6  = new Account(); 
	    account6.Name = 'TestAccount6';
	    account6.RDM_Org_ID__c = 'test6';            
	    account6.RecordTypeId = RGRecordType.Id;
	    account6.ParentId = accountAdd.Id;
		account6.BillingCity = 'California';
	    account6.BillingCountry = 'United States';
	    account6.BillingStreet = '52nd Street' ;

		testAccounts.add(account6);

		Account account7  = new Account(); 
	    account7.Name = 'TestAccount7';
	    account7.RDM_Org_ID__c = 'test7';            
	    account7.RecordTypeId = RMRecordType.Id;
	    account7.ParentId = account6.Id;
	    account7.Active__c = true;
	    account7.BillingCity = 'California';
	    account7.BillingCountry = 'United States';
	    account7.BillingStreet = '52nd Street' ;

		testAccounts.add(account7);

		insert testAccounts;
	       
	    system.debug('RM Account 1 :'+ account3.Id) ;  
	    system.debug('RM Account 2 :'+ account4.id) ; 
	    system.debug('RG Account  :'+ account2.id) ;
	    system.debug('RS Account  :'+ accountAdd.id) ; 
	    system.debug('ParentId RM Account 1  :'+ account3.ParentId) ;
	    system.debug('ParentId RM Account 2  :'+account4.ParentId) ;   
	    system.debug('ParentId RG Account  :'+ account2.ParentId) ;     
	    
	    List<String> EmailList = new List<String>();
	    List<String> NotContEmailList = new List<String>{'abcd1@xyz.com', 'abcd2@xyz.com'};
	        
	    for(Integer i=1; i<=20; ++i) {
		    Contact contactAdd = new Contact();
		    contactAdd.AccountId = account3.id;
		    contactAdd.FirstName = 'fn'+i; 
		    contactAdd.LastName = 'ln'+i;    
		    contactAdd.Active__c = true;
		    contactAdd.Email = 'fnln'+i+'@abcd.com';
		    contactAdd.Phone = '(212) 333-456'+i; 
		    contactAdd.Salutation = 'Dear [FirstName]';    
			if(i == Integer.valueOf(2)) {
				contactAdd.RG_Account__c = account2.Id;
				contactAdd.AccountId = account4.Id;
			}
			if(i == Integer.valueOf(3)) {
				contactAdd.RG_Account__c = account6.Id;
				contactAdd.AccountId = account7.Id;
			}
			if(i == Integer.valueOf(4))
			{	contactAdd.RG_Account__c = account2.Id;
        		contactAdd.AccountId = account4.Id;
			}
		    Contacts.add(contactAdd);
		    EmailList.add('fnln'+i+'@abcd.com');
	    }
	    insert Contacts;
	    EmailList.add('fnln'+30+'@abcd.com');
	    EmailList.add('fnln'+31+'@abcd.com');
	    
	     
		
		List<String> ProdList = new List<String>{'FIGL'};
		List<String> emptyEmailList = new List<String>{'notfound@abc.com'};
		ContactMifid2InScopeBulkSetController.getContactsFromEmails(EmailList, 'In Scope', 'Allowed', 2,  
			'Enable','True', 'Full Service', ProdList, null, 
			'English', 'AEJ', 'NJA-Qualifed User', 'LMN OPQ', 'lmn.opq@xyz.com', true);
		ContactMifid2InScopeBulkSetController.getContactsFromEmails(NotContEmailList, 'In Scope', 'Allowed', 200,  
			'Enable', 'True', 'Full Service', ProdList, null, 
			'English', 'AEJ', 'NJA-Qualifed User', 'LMN OPQ', 'lmn.opq@xyz.com', true);
		ContactMifid2InScopeBulkSetController.getContactsFromEmails(EmailList, 'In Scope', 'Allowed', 200,  
			'Enable','False', 'Full Service', ProdList, null, 
			'English', 'AEJ', 'NJA-Qualifed User', 'LMN OPQ', 'lmn.opq@xyz.com', true);
		ContactMifid2InScopeBulkSetController.getContactsFromEmails(EmailList, 'In Scope', 'Allowed', 2,  
			'Enable','False', 'Full Service', ProdList, null, 
			'English', 'AEJ', 'NJA-Qualifed User', 'LMN OPQ', 'lmn.opq@xyz.com', true, 'Other Attributes', account5.Id, account5.Name, 'Add/Update');
		ContactMifid2InScopeBulkSetController.getContactsFromEmails(EmailList, 'In Scope', 'Allowed', 2,  
			'Enable','False', 'Full Service', ProdList, null, 
			'English', 'AEJ', 'NJA-Qualifed User', 'LMN OPQ', 'lmn.opq@xyz.com', true, 'Other Attributes', account5.Id, account5.Name, 'Remove');
		ContactMifid2InScopeBulkSetController.getContactsFromEmails(emptyEmailList, 'In Scope', 'Allowed', 2,  
			'Enable','False', 'Full Service', ProdList, null, 
			'English', 'AEJ', 'NJA-Qualifed User', 'LMN OPQ', 'lmn.opq@xyz.com', true, 'Other Attributes', account5.Id, account5.Name, 'Remove');	
		/*ContactMifid2InScopeBulkSetController.getContactsFromEmails(EmailList, 'Out of Scope', null, 200,  
			null, null, null, null, null,
			null, null, null, null, null, false);*/
	}
	
	static testMethod void testGetContactsFromEmailsDisable() {
		System.debug('#### ContactMifid2InScopeBulkSetContTest::testGetContactsFromEmails()');
		
		Integer numTestAccounts = 4;
	   Integer numTestUsers = 4;     
	   List<Contact> contacts = new List<Contact>(); 
	   List<Coverage_Team_Member__c> cvgTmMbrs =  new List<Coverage_Team_Member__c>(); 
	   List<Task> Tasks = new List<Task>();
	   List<Event> Events = new List<Event>(); 
	   List<Opportunity> Opportunities = new List<Opportunity>(); 
	   List<Revenue_Rollup__c> revenueRollups = new List<Revenue_Rollup__c>(); 
	   List<Account> testAccounts =  new List<Account>();     
	        
	 
	    RecordType RGRecordType = [SELECT Id FROM RecordType WHERE Name = 'RG Account' ];
	    RecordType RSRecordType = [SELECT Id FROM RecordType WHERE Name = 'RS Account' ];
	    RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account' ];
	        
	    system.debug('RGRecordType : ' + RGRecordType.Id);
	    system.debug('RSRecordType : ' + RSRecordType.Id);  
	    system.debug('RMRecordType : ' + RMRecordType.Id) ; 
	        
	   
	    List<User> users = UtilityTesting.CreateUsersWithManager(numTestUsers);
	        
	    Account accountAdd = new Account();
	    accountAdd.Name = 'TestAccount1';
	    accountAdd.RDM_Org_ID__c = 'test1';            
	    accountAdd.RecordTypeId = RSRecordType.Id;
	    accountAdd.BillingCity = 'California';
	    accountAdd.BillingCountry = 'United States';
	    accountAdd.BillingStreet = '52nd Street' ;
	    insert accountAdd;    
	
	    Account account2  = new Account(); 
	    account2.Name = 'TestAccount2';
	    account2.RDM_Org_ID__c = 'test1';            
	    account2.RecordTypeId = RGRecordType.Id;
	    account2.ParentId = accountAdd.Id;
		account2.BillingCity = 'California';
	    account2.BillingCountry = 'United States';
	    account2.BillingStreet = '52nd Street' ;
	    insert account2;
	        
	    Account account3  = new Account(); 
	    account3.Name = 'TestAccount3';
	    account3.RDM_Org_ID__c = 'test3';            
	    account3.RecordTypeId = RMRecordType.Id;
	    account3.ParentId = account2.Id;
	    account3.Active__c = true;
	    account3.BillingCity = 'California';
	    account3.BillingCountry = 'United States';
	    account3.BillingStreet = '52nd Street' ;
		insert account3; 
	        
		Account account4  = new Account();  
		account4.Name = 'TestAccount4';
		account4.RDM_Org_ID__c = 'test4';            
		account4.RecordTypeId = RMRecordType.Id;
		account4.ParentId = account2.id;
		account4.Active__c = true; 
		account4.BillingCity = 'California';
		account4.BillingCountry = 'United States';
		account4.BillingStreet = '52nd Street' ;
	        
	   insert account4;   
	       
	    system.debug('RM Account 1 :'+ account3.Id) ;  
	    system.debug('RM Account 2 :'+ account4.id) ; 
	    system.debug('RG Account  :'+ account2.id) ;
	    system.debug('RS Account  :'+ accountAdd.id) ; 
	    system.debug('ParentId RM Account 1  :'+ account3.ParentId) ;
	    system.debug('ParentId RM Account 2  :'+account4.ParentId) ;   
	    system.debug('ParentId RG Account  :'+ account2.ParentId) ;     
	    
	    List<String> EmailList = new List<String>();
	    List<String> NotContEmailList = new List<String>{'abcd1@xyz.com', 'abcd2@xyz.com'};
	        
	    for(Integer i=1; i<=20; ++i) {
		    Contact contactAdd = new Contact();
		    contactAdd.AccountId = account3.id;
		    contactAdd.FirstName = 'fn'+i; 
		    contactAdd.LastName = 'ln'+i;    
		    contactAdd.Active__c = true;
		    contactAdd.Email = 'fnln'+i+'@abcd.com';
		    contactAdd.Phone = '(212) 333-456'+i; 
		    contactAdd.Salutation = 'Dear [FirstName]';    
		    Contacts.add(contactAdd);
		    EmailList.add('fnln'+i+'@abcd.com');
	    }
	    insert Contacts;
	    EmailList.add('fnln'+30+'@abcd.com');
	    EmailList.add('fnln'+31+'@abcd.com');
	    
	     
		
		List<String> ProdList = new List<String>{'FIGL'};
		
		ContactMifid2InScopeBulkSetController.getContactsFromEmails(EmailList, 'Out of Scope', null, 200,  
			null, null, null, null, null,
			null, null, null, null, null, false);
	}
}