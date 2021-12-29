@isTest
public class GlblHdSalesContactShareGlblRscAccBL_Test {

    static testMethod void ShareContactWithGlobalHeadResearchAccount (){
       Integer numTestAccounts = 4;
  
   List<Contact> contacts = new List<Contact>();  
   List<Account> testAccounts =  new List<Account>();     
        
 
    RecordType RGRecordType = [SELECT Id FROM RecordType WHERE Name = 'RG Account' ];
    RecordType RSRecordType = [SELECT Id FROM RecordType WHERE Name = 'RS Account' ];
    RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account' ];
        
    system.debug('RGRecordType : ' + RGRecordType.Id);
    system.debug('RSRecordType : ' + RSRecordType.Id);  
    system.debug('RMRecordType : ' + RMRecordType.Id) ; 
        
   
      Integer numTestUsers = 4;  
    List<User> users = UtilityTesting.CreateUsersWithManager(numTestUsers);
    User owneruser = [select id,name,ManagerId,Manager.Name,Region__c from user where id =:users[1].id];   
    system.runas(users[0]){
        
  
        
    Account account3  = new Account(); 
    account3.Name = 'TestAccount3';
    account3.RDM_Org_ID__c = 'test1';            
    account3.RecordTypeId = RMRecordType.Id;
    account3.Restricted_Flag__c = true; 
    account3.BillingCountry  = 'United States'; 
                 account3.BillingCity = 'California';
    
    account3.BillingStreet = '52nd Street' ;
   
    account3.Active__c = true;    
    insert account3; 
        
    Account account4  = new Account();  
    account4.Name = 'TestAccount4';
    account4.RDM_Org_ID__c = 'test1';            
    account4.RecordTypeId = RMRecordType.Id;
    account4.Restricted_Flag__c = false;
                 account4.BillingCity = 'California';
    account4.BillingCountry = 'United States';
    account4.BillingStreet = '52nd Street' ;
    account4.CapIntro__c = true;
    account4.CapIntro_Only__c = true;    
    account4.Active__c = true; 
        
   insert account4;   
       
 testAccounts.add(account3);
 testAccounts.add(account4);       
        
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
        
     Account[] accounts = [SELECT Id,Restricted_Flag__c FROM Account WHERE ID IN : testAccounts ] ; 
        
        update accounts;
    }
    }
    
}