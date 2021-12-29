/**
 *	Author 		: Pravin Kundal
 *	Company 	: Nomura
 *  Description : This class contains unit tests for validating the behavior of Apex class - AccountMifidIIDetailController 
 *
 */
@isTest
public class AccountMifidIIDetailControllerTest {
	static testMethod void testController() {
		System.debug('#### AccountMifidIIDetailControllerTest::testController()');
		
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
		account4.Override_Contacts_MiFID_II_Entitlement__c = true;
        account4.MiFID_II_Research_In_Scope__c = true;
        account4.MiFIDII_Sales_Commentary_Allowed__c = 'Allowed';
        account4.MiFID_II_Product_Subscriptions__c='FIGL';
        account4.Service_Type__c='Full Service';
	        
	   insert account4;   
	       
	    system.debug('RM Account 1 :'+ account3.Id) ;  
	    system.debug('RM Account 2 :'+ account4.id) ; 
	    system.debug('RG Account  :'+ account2.id) ;
	    system.debug('RS Account  :'+ accountAdd.id) ; 
	    system.debug('ParentId RM Account 1  :'+ account3.ParentId) ;
	    system.debug('ParentId RM Account 2  :'+account4.ParentId) ;   
	    system.debug('ParentId RG Account  :'+ account2.ParentId) ;     
	    
	    for(Integer i=1; i<=20; ++i) {
		    Contact contactAdd = new Contact();
		    contactAdd.AccountId = account4.id;
		    contactAdd.FirstName = 'fn'+i; 
		    contactAdd.LastName = 'ln'+i;    
		    contactAdd.Active__c = true;
		    contactAdd.Email = 'fnln'+i+'@abcd.com';
		    contactAdd.Phone = '(212) 333-456'+i; 
		    contactAdd.Salutation = 'Dear [FirstName]';
		    contactAdd.DeskCommentaryProhibited__c='US';    
		    Contacts.add(contactAdd);
	    }
	    insert Contacts;
	    
	    Test.StartTest();
	    	AccountMifidIIDetailController.getAccountSubscriptions(account2.Id);
	    Test.StopTest();

	}
}