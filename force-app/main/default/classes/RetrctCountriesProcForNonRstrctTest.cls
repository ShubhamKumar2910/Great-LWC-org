/**
 *	Author 		: Pravin Kundal
 *	Company 	: Nomura
 *  Description : This class contains unit tests for validating the behavior of Apex class - RetrctCountriesProcessingForNonRstrct 
 *
 */
 @isTest
public class RetrctCountriesProcForNonRstrctTest {
	static testMethod void testBatchJob() {
	   System.debug('#### RetrctCountriesProcForNonRstrctTest::testBatchJob()');
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
	    accountAdd.Restricted_Flag__c=false;
	    accountAdd.Domicile_Country__c='TW';
	    insert accountAdd;    
	
	    Account account2  = new Account(); 
	    account2.Name = 'TestAccount2';
	    account2.RDM_Org_ID__c = 'test1';            
	    account2.RecordTypeId = RGRecordType.Id;
	    account2.ParentId = accountAdd.Id;
		account2.BillingCity = 'California';
	    account2.BillingCountry = 'United States';
	    account2.BillingStreet = '52nd Street' ;
	    account2.Restricted_Flag__c=false;
	    account2.Domicile_Country__c='TW';
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
	    account3.Restricted_Flag__c=false;
	    account3.Domicile_Country__c='TW';
		insert account3;
		AccIdList.add(account3.Id); 
	        
		Account account4  = new Account();  
		account4.Name = 'TestAccount4';
		account4.RDM_Org_ID__c = 'test4';            
		account4.RecordTypeId = RMRecordType.Id;
		account4.ParentId = account2.id;
		account4.Active__c = true; 
		account4.BillingCity = 'California';
		account4.BillingCountry = 'United States';
		account4.BillingStreet = '52nd Street' ;
	    account4.Restricted_Flag__c=false;
	    account4.Domicile_Country__c='TW';    
		insert account4;
		AccIdList.add(account4.Id);
	       
	    system.debug('RM Account 1 :'+ account3.Id) ;  
	    system.debug('RM Account 2 :'+ account4.id) ; 
	    system.debug('RG Account  :'+ account2.id) ;
	    system.debug('RS Account  :'+ accountAdd.id) ; 
	    system.debug('ParentId RM Account 1  :'+ account3.ParentId) ;
	    system.debug('ParentId RM Account 2  :'+account4.ParentId) ;   
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
	    
	    contactAdd.AccountId = account4.Id;
	    contactAdd.FirstName = 'Suren';
	    contactAdd.LastName = 'pillai';       
	    contactAdd.Active__c = true;
	    contactAdd.Email = 'b@b.com';
	    contactAdd.Phone = '(212) 333-4567'; 
	    contactAdd.Salutation = 'Dear [FirstName]';  
	    Contacts.add(contactAdd);   
	        
	    insert Contacts; 
	        
	    system.debug('Contact Account :'+ Contacts[0].AccountId) ;  
	    system.debug('Contact Account 2 :'+ Contacts[1].AccountId) ;  

		List<Group> GroupList = new List<Group>();
		Group oRschGrp1 = new Group();
        oRschGrp1.DeveloperName = 'Research_1_GROUP';
        oRschGrp1.Name = 'Research_1_GROUP';
        oRschGrp1.Type = 'Regular';
        GroupList.add(oRschGrp1);
        Group oRschGrp2 = new Group();
        oRschGrp2.DeveloperName = 'Research_2_GROUP';
        oRschGrp2.Name = 'Research_2_GROUP';
        oRschGrp2.Type = 'Regular';
        GroupList.add(oRschGrp2);
        insert GroupList;
        
        List<Id> GrpIdList = new List<Id>{oRschGrp1.Id, oRschGrp2.Id};
        
        List<AccountShare> AccShareList = [SELECT Id,AccountId,UserorGroupId FROM AccountShare WHERE AccountId IN :AccIdList AND UserOrGroupId IN :GrpIdList];
        System.assertEquals(AccShareList.size(), 0);

	    Test.startTest();
	    	id batchinstanceidNonRestricted = database.executeBatch(new RetrctCountriesProcessingForNonRstrct(AccIdList),40);
    	Test.stopTest();
    	
    	AccShareList = [SELECT Id,AccountId,UserorGroupId FROM AccountShare WHERE AccountId IN :AccIdList];
        System.assertNotEquals(AccShareList.size(), 0);
	}
}