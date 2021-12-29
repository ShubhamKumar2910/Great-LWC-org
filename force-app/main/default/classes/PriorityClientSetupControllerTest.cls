/**
 *	Author 		: Pravin Kundal
 *	Company 	: Nomura
 *  Description : This class contains unit tests for validating the behavior of Apex class - PriorityClientSetupController
 *
 */
 
@isTest
public class PriorityClientSetupControllerTest {
	
	public static User userAsMgrObj; 
    public static User userObj;
    public static string jsonString;
    public static Id dummyRMNonRestrictedId;  
    public static Id dummySalesCodeActiveId; 
    
    static testMethod void testInitialize() {
    	System.debug('#### PriorityClientSetupControllerTest::testInitialize()');
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
	        
	    Sales_Team_For_Coverage__c salescvgTeam = new  Sales_Team_For_Coverage__c ();
	    salescvgTeam.Name = 'Test';
	    salescvgTeam.Sales_Team__c = 'Test Sales Team';
	    salescvgTeam.Coverage_ID__c = '1234';
	    salescvgTeam.Sales_Desk_Region__c = 'Europe';
	       
	    insert salescvgTeam;
	       
	    // Insert Sales_Team_User__c 
	    Sales_Team_User__c salesTeamUserObj = new Sales_Team_User__c();
	    salesTeamUserObj.Sales_Team_for_Coverage__c = salescvgTeam.Id;
	    salesTeamUserObj.User__c = users[1].Id;
	    
	    insert salesTeamUserObj;   
	          
	        
	    Coverage_Team_Member__c cvgTm =  new Coverage_Team_Member__c();
	       
	    cvgTm.Account__c = account3.id;
	    //cvgTm.OwnerId = users[0].Id;
	    cvgTm.Team_Member__c = users[1].Id;
	    cvgTm.Team_Role__c = 'Primary';
	    cvgTm.Sales_Team_for_Coverage__c = salescvgTeam.id;
	    cvgTmMbrs.add(cvgTm);
	    
	    cvgTm = new Coverage_Team_Member__c();
	    cvgTm.Account__c = account4.Id;
	    //cvgTm.OwnerId = users[0].Id;
	    cvgTm.Team_Member__c = users[1].Id;
	    cvgTm.Team_Role__c = 'Primary';
	    cvgTm.Sales_Team_for_Coverage__c = salescvgTeam.id;
	    cvgTmMbrs.add(cvgTm); 
	     
	    insert cvgTmMbrs;
	    
	    userObj = users[1];
	        
	    system.debug('cvg Account :'+ cvgTmMbrs[0].Account__c) ;  
	    system.debug('cvg Account 2 :'+ cvgTmMbrs[1].Account__c) ;     
	    System.debug('userObj : '+userObj);
	    
	    PriorityClientSetupController.ClientPrioritySetupInitInfo clntPrioritySetupInfo;
	    Test.startTest();
	    System.runas(userObj){
    		clntPrioritySetupInfo = PriorityClientSetupController.initialize(true);
    	}
    	Test.stopTest();
    	
    	System.assertEquals(clntPrioritySetupInfo.currentUserId, userObj.Id);
    	System.assertNotEquals(clntPrioritySetupInfo.CoalitionPickListLabValMap, null);
    	System.assertEquals(clntPrioritySetupInfo.PriorityClientWrapperList.size(), 1);
    	System.assertEquals(clntPrioritySetupInfo.PriorityClientWrapperList[0].priorityClientId, null);
    }
    
    static testMethod void testSave() {
    	System.debug('#### PriorityClientSetupControllerTest::testInitialize()');
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
	        
	    Sales_Team_For_Coverage__c salescvgTeam = new  Sales_Team_For_Coverage__c ();
	    salescvgTeam.Name = 'Test';
	    salescvgTeam.Sales_Team__c = 'Test Sales Team';
	    salescvgTeam.Coverage_ID__c = '1234';
	    salescvgTeam.Sales_Desk_Region__c = 'Europe';
	       
	    insert salescvgTeam;
	       
	    // Insert Sales_Team_User__c 
	    Sales_Team_User__c salesTeamUserObj = new Sales_Team_User__c();
	    salesTeamUserObj.Sales_Team_for_Coverage__c = salescvgTeam.Id;
	    salesTeamUserObj.User__c = users[1].Id;
	    
	    insert salesTeamUserObj;   
	          
	        
	    Coverage_Team_Member__c cvgTm =  new Coverage_Team_Member__c();
	       
	    cvgTm.Account__c = account3.id;
	    //cvgTm.OwnerId = users[0].Id;
	    cvgTm.Team_Member__c = users[1].Id;
	    cvgTm.Team_Role__c = 'Primary';
	    cvgTm.Sales_Team_for_Coverage__c = salescvgTeam.id;
	    cvgTmMbrs.add(cvgTm);
	    
	    cvgTm = new Coverage_Team_Member__c();
	    cvgTm.Account__c = account4.Id;
	    //cvgTm.OwnerId = users[0].Id;
	    cvgTm.Team_Member__c = users[1].Id;
	    cvgTm.Team_Role__c = 'Primary';
	    cvgTm.Sales_Team_for_Coverage__c = salescvgTeam.id;
	    cvgTmMbrs.add(cvgTm); 
	     
	    insert cvgTmMbrs;
	    
	    userObj = users[1];
	        
	    system.debug('cvg Account :'+ cvgTmMbrs[0].Account__c) ;  
	    system.debug('cvg Account 2 :'+ cvgTmMbrs[1].Account__c) ;     
	    System.debug('userObj : '+userObj);
	    
	    PriorityClientSetupController.ClientPrioritySaveResult clntPrioritySaveRslt;
	    PriorityClientSetupController.ClientPrioritySaveResult clntPrioritySaveDelRslt;
	    Test.startTest();
	    System.runas(userObj){
	    	PriorityClientSetupController.ClientPrioritySetupInitInfo clntPrioritySetupInfo = 
	    			PriorityClientSetupController.initialize(true);
	    	clntPrioritySetupInfo.PriorityClientWrapperList[0].rgAccId = account2.Id;
	    	clntPrioritySetupInfo.PriorityClientWrapperList[0].isClientSurvey = true;
	    	clntPrioritySetupInfo.PriorityClientWrapperList[0].coalitionPLvals = 'ABS';
	    	clntPrioritySetupInfo.PriorityClientWrapperList[0].greenwichPLvals = '	Eu - Distressed Debt';
	    	clntPrioritySetupInfo.PriorityClientWrapperList[0].isPrioirtyClient = true;
	    	String PriorityClientListToUpserStr = System.JSON.serialize(clntPrioritySetupInfo.PriorityClientWrapperList);

    		clntPrioritySaveRslt = PriorityClientSetupController.save(PriorityClientListToUpserStr, null);

    		System.assertEquals(clntPrioritySaveRslt.UpsertResultList.size(), 1);
    		System.assertEquals(clntPrioritySaveRslt.DeleteResultList.size(), 0);
    		System.assertEquals(clntPrioritySaveRslt.UpsertResultList[0].hasErrors, false);
    		System.assertNotEquals(clntPrioritySaveRslt.UpsertResultList[0].priorityClientId, null);
    		PriorityClientSetupController.initialize(false);
        
        	clntPrioritySetupInfo.PriorityClientWrapperList[0].priorityClientId = clntPrioritySaveRslt.UpsertResultList[0].priorityClientId;
        	String PriorityClientListToDelStr = System.JSON.serialize(clntPrioritySetupInfo.PriorityClientWrapperList);
        	clntPrioritySaveDelRslt = PriorityClientSetupController.save(null, PriorityClientListToDelStr);
        	System.assertEquals(clntPrioritySaveDelRslt.DeleteResultList[0].hasErrors, false);
    	}
    	Test.stopTest();
    }
}