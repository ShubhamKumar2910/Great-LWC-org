@isTest
public class MyCoverage_Test {
    
  @testSetup 
    private static void setupTestData(){
       Integer numTestAccounts = 4;
   Integer numTestUsers = 4;     
   List<Contact> contacts = new List<Contact>(); 
   List<Coverage_Team_Member__c> cvgTmMbrs =  new List<Coverage_Team_Member__c>(); 
   List<Task> Tasks = new List<Task>();
   List<Event> Events = new List<Event>(); 
   List<Opportunity> Opportunities = new List<Opportunity>(); 
   List<Revenue_Rollup__c> revenueRollups = new List<Revenue_Rollup__c>(); 
   List<Account> testAccounts =  new List<Account>();     
  integer limits = 100;    
  String recordTypeIdForCPEventIntegration = null;
   String recordTypeIdForStandardAccount = null;
        
    RecordType RGRecordType = [SELECT Id FROM RecordType WHERE Name = 'RG Account' ];
    RecordType RSRecordType = [SELECT Id FROM RecordType WHERE Name = 'RS Account' ];
    RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account' ];
        
    system.debug('RGRecordType : ' + RGRecordType.Id);
    system.debug('RSRecordType : ' + RSRecordType.Id);  
    system.debug('RMRecordType : ' + RMRecordType.Id) ; 
        
   
        List<User> userList = new List<User>();
        Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        
        User userObj1 = new User();
        userObj1.Login_ID__c = 'test1tmp';
        userObj1.Alias = 'test1tmp';
        userObj1.FirstName = 'Test1TempFN';
        userObj1.LastName = 'Test1TempLN';
        userObj1.Email = 'Test1Temp@testOrg.com';
        userObj1.UserName = 'Test1Temp@testOrg.com';
        userObj1.ProfileId = profileNomuraSales.Id;
        userObj1.EmailEncodingKey = 'UTF-8';
        userObj1.LanguageLocaleKey = 'en_US';
        userObj1.LocaleSidKey = 'en_US';
        userObj1.TimeZoneSidKey = 'America/Los_Angeles';
        userObj1.Region__c = 'Americas';
        
        userList.add(userObj1);
        
        User userObj2 = new User();
        userObj2.Login_ID__c = 'test2tmp';
        userObj2.Alias = 'test2tmp';
        userObj2.FirstName = 'Test2TempFN';
        userObj2.LastName = 'Test2TempLN';
        userObj2.Email = 'Test2Temp@testOrg.com';
        userObj2.UserName = 'Test2Temp@testOrg.com';
        userObj2.ProfileId = profileNomuraSales.Id;
        userObj2.EmailEncodingKey = 'UTF-8';
        userObj2.LanguageLocaleKey = 'en_US';
        userObj2.LocaleSidKey = 'en_US';
        userObj2.TimeZoneSidKey = 'America/Los_Angeles';
        userObj2.Region__c = 'Japan';
        userList.add(userObj2);
     
        insert userList; 
        
        
    //List<User> users = UtilityTesting.CreateUsersWithManager(numTestUsers);
         system.runas(userList[1]){
        
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
    //fix for phone validation SALEs-3531
    contactAdd.Phone = '+1 (212) 333-4567'; 
    contactAdd.Salutation = 'Dear [FirstName]';    
    Contacts.add(contactAdd);
    contactAdd = new Contact();
    
    contactAdd.AccountId = account4.Id;
    contactAdd.FirstName = 'Suren';
    contactAdd.LastName = 'pillai';       
    contactAdd.Active__c = true;
    contactAdd.Email = 'b@b.com';
    //fix for phone validation SALEs-3531
    contactAdd.Phone = '+1 (212) 333-4567'; 
    contactAdd.Salutation = 'Dear [FirstName]';  
    Contacts.add(contactAdd);   
        
    insert Contacts; 
        
    system.debug('Contact Account :'+ Contacts[0].AccountId) ;  
    system.debug('Contact Account 2 :'+ Contacts[1].AccountId) ;  
        
    Sales_Team_For_Coverage__c salescvgTeam = new  Sales_Team_For_Coverage__c ();
    salescvgTeam.Name = 'Test Sales Team';
    salescvgTeam.Coverage_ID__c = '1234';
    insert salescvgTeam;
             
    /* Insert Sales_Team_User__c */
    Sales_Team_User__c salesTeamUserObj = new Sales_Team_User__c();
    salesTeamUserObj.Sales_Team_for_Coverage__c = salescvgTeam.Id;
    salesTeamUserObj.User__c = userList[0].Id;
    
    insert salesTeamUserObj;   
          
        
    Coverage_Team_Member__c cvgTm =  new Coverage_Team_Member__c();
    cvgTm.Account__c = account3.id;   
    cvgTm.Team_Member__c = userList[0].Id;
    cvgTm.Team_Role__c = 'Primary';
    cvgTm.Sales_Team_for_Coverage__c = salescvgTeam.id;
    cvgTmMbrs.add(cvgTm);
             
    cvgTm = new Coverage_Team_Member__c();
    cvgTm.Account__c = account4.Id;   
    cvgTm.Team_Member__c = userList[0].Id;
    cvgTm.Team_Role__c = 'Primary';
    cvgTm.Sales_Team_for_Coverage__c = salescvgTeam.id;
    cvgTmMbrs.add(cvgTm); 
     
    insert cvgTmMbrs;
  
/*             
     /* Record Type 
        List<RecordType> recordTypeList = [Select Id, Name FROM RecordType 
                                           WHERE Name IN ('Standard Event', 'CP Event Integration')  ];
        if(recordTypeList != null && recordTypeList.size() > 0){
            for(RecordType recordType : recordTypeList){
                if('Standard Event'.equalsIgnoreCase(recordType.Name) ){
                    recordTypeIdForStandardAccount = recordType.Id;
                }
                else if('CP Event Integration'.equalsIgnoreCase(recordType.Name)){
                    recordTypeIdForCPEventIntegration = recordType.Id;
                }
            }
        }         
             
             
             
	Datetime startDateTime = Datetime.now();
		Datetime endDateTime = startDateTime.addHours(1);
        
        Event eventObj = new Event();
        eventObj.WhatId = account2.Id;
        eventObj.WhoId = Contacts[0].Id;
        eventObj.OwnerId = userList[0].Id;
        eventObj.Subject = 'Test Event';
        eventObj.StartDateTime = startDateTime;
        eventObj.EndDateTime = endDateTime;
        eventObj.RecordTypeId = recordTypeIdForCPEventIntegration;
        
        insert eventObj;
        
        system.debug('eventObj :' +eventObj.id);             
*/             
    //system.debug('cvg Account :'+ cvgTmMbrs[0].Account__c) ;  
    //system.debug('cvg Account 2 :'+ cvgTmMbrs[1].Account__c) ;     
    
         }
    }
    
  static testmethod void MyCoverage_Test(){  
	
      List<User> userList = [SELECT Id from User where login_id__c = : 'test1tmp']	;
	  system.debug('userList::' + userList);      
      System.runas(userList[0]){
      Test.startTest();
      
      List<Account> accnt = [SELECT Id  from Account WHERE NAME = 'TestAccount2'];
      system.debug('accnt:::'+ accnt);
          
//      List<Coverage_Team_Member__c> cvg = [SELECT Account__c FROM Coverage_Team_Member__c WHERE Team_Member__c = : userList[0].Id];
  	      
      Set<Account> ParentAccountRG = new Set<Account>([SELECT ParentId FROM Account WHERE Id = :accnt[0].id]);     
      system.debug('parentAccount:'  + ParentAccountRG); 
      CoverageRGController controller = new CoverageRGController(new ApexPages.StandardController([SELECT Id,Name,ParentId,RecordTypeId,RDM_ORG_ID__c FROM Account WHERE NAme = 'TestAccount4']));
      controller.limits = 1;
              
      controller.previous();      
      controller.Next();   
      controller.getHasPrevious();     
      controller.getHasNext();
      controller.getResultSize();     
      controller.getPageSize();
      controller.getRecords();     
      controller.getPageNumber();
              
      Test.stopTest();  
      }
    }
       
}