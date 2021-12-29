/**
 *	Author 		: Pravin Kundal
 *	Company 	: Nomura
 *  Description : This class contains unit tests for validating the behavior of Apex class - ContactChangeAddressController 
 *
 */
@isTest
public class ContactChangeAddressControllerTest {
	static testMethod void testGetAccountAddresses() {
		System.debug('#### ContactChangeAddressControllerTest::testGetAccountAddresses()');
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
	        
	 
	    RecordType RGRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'RG_Account' ];
	    RecordType RSRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'RS_Account' ];
	    RecordType RMRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'RM_Account' ];
	        
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
		
		Account account4  = new Account(); 
	    account4.Name = 'TestAccount4';
	    account4.RDM_Org_ID__c = 'test4';            
	    account4.RecordTypeId = RMRecordType.Id;
	    account4.ParentId = account2.Id;
	    account4.Active__c = true;
	    account4.BillingCity = 'California';
	    account4.BillingCountry = 'United States';
	    account4.BillingStreet = '**Not Entered**';
	    account4.Restricted_Flag__c=true;
	    account4.Domicile_Country__c='US';
		insert account4;
		AccIdList.add(account4.Id); 
	        
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
	    
	    ContactChangeAddressController.getAccountAddresses(account2.Id);
	    ContactChangeAddressController.getContactDetails(Contacts[0].Id);
	    ContactChangeAddressController.saveContact(contactAdd, account4.Id, Contacts[0].Id);
	}
}