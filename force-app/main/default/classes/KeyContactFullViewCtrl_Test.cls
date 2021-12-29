@isTest
public class KeyContactFullViewCtrl_Test {
/*    
  @testSetup 
    private static void setupTestData(){
    Integer numTestAccounts = 4;
   Integer numTestUsers = 4;     
   List<Contact> contacts = new List<Contact>(); 
 
   List<Account> testAccounts =  new List<Account>();     
        
 
    RecordType RGRecordType = [SELECT Id FROM RecordType WHERE Name = 'RG Account' ];
    RecordType RSRecordType = [SELECT Id FROM RecordType WHERE Name = 'RS Account' ];
    RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account' ];
        
    system.debug('RGRecordType : ' + RGRecordType.Id);
    system.debug('RSRecordType : ' + RSRecordType.Id);  
    system.debug('RMRecordType : ' + RMRecordType.Id); 
        
   
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
    account3.RDM_Org_ID__c = 'test1';            
    account3.RecordTypeId = RMRecordType.Id;
    account3.ParentId = account2.Id;
    account3.Active__c = true; 
                 account3.BillingCity = 'California';
    account3.BillingCountry = 'United States';
    account3.BillingStreet = '52nd Street' ;
   insert account3; 
        
    Account account4  = new Account();  
    account4.Name = 'TestAccount4';
    account4.RDM_Org_ID__c = 'test1';            
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
    contactAdd.Key_Person__c = true;
    contactAdd.Email = 'a@a.com';
    contactAdd.Phone = '(212) 333-4567'; 
    contactAdd.Salutation = 'Dear [FirstName]';    
    Contacts.add(contactAdd);
    contactAdd = new Contact();
    
    contactAdd.AccountId = account4.Id;
    contactAdd.FirstName = 'Suren';
    contactAdd.LastName = 'pillai';       
    contactAdd.Active__c = true;
    contactAdd.Key_Person__c = true;    
    contactAdd.Email = 'b@b.com';
    contactAdd.Phone = '(212) 333-4567'; 
    contactAdd.Salutation = 'Dear [FirstName]';  
    Contacts.add(contactAdd);   
        
    insert Contacts; 
        
    system.debug('Contact Account :'+ Contacts[0].AccountId) ;  
    system.debug('Contact Account 2 :'+ Contacts[1].AccountId) ;  
        
      
    }   
  static testmethod void KeyContactFullViewCtrl_Test(){  
    
    Test.startTest(); 
      
    Account act = [SELECT Id,Name,ParentId,RecordTypeId,RDM_ORG_ID__c FROM Account WHERE Name = 'TestAccount2'];  
      
    ApexPages.currentPage().getParameters().put('AccountId', act.id);
   
    KeyContactFullViewCtrl controller = new KeyContactFullViewCtrl(new ApexPages.StandardController([SELECT Id,Name,ParentId,RecordTypeId,RDM_ORG_ID__c FROM Account WHERE NAme = 'TestAccount2']));
    
      
    /*controller.getHasNext();
    controller.getHasPrevious();
    controller.getPageNumber() ;
    controller.getRecords();
    controller.getPageSize();
    controller.previous();
    controller.Next();
    controller.getResultSize();
    
      
    Test.stopTest();  
 
    } 
*/
}