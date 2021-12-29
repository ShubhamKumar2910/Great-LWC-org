@isTest
public class SendTaskNotifyController_Test {
     @testSetup 
    private static void setupTestData(){
        List<Account> testAccounts =  new List<Account>();   
         List<Contact> contacts = new List<Contact>(); 
        
 
    RecordType RGRecordType = [SELECT Id FROM RecordType WHERE Name = 'RG Account' ];
    RecordType RSRecordType = [SELECT Id FROM RecordType WHERE Name = 'RS Account' ];
    RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account' ];
        
    system.debug('RGRecordType : ' + RGRecordType.Id);
    system.debug('RSRecordType : ' + RSRecordType.Id);  
    system.debug('RMRecordType : ' + RMRecordType.Id); 
        
   
    List<User> users = UtilityTesting.CreateUsersWithManager(3);
        
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
    
    contactAdd.AccountId = account3.Id;
    contactAdd.FirstName = 'Suren';
    contactAdd.LastName = 'pillai';       
    contactAdd.Active__c = true;
    contactAdd.Key_Person__c = true;    
    contactAdd.Email = 'b@b.com';
    contactAdd.Phone = '(212) 333-4567'; 
    contactAdd.Salutation = 'Dear [FirstName]';  
    Contacts.add(contactAdd); 
        
    contactAdd = new Contact();
    
    contactAdd.AccountId = account3.Id;
    contactAdd.FirstName = 'Advait';
    contactAdd.LastName = 'pillai';       
    contactAdd.Active__c = true;
    contactAdd.Key_Person__c = true;    
    contactAdd.Email = 'advait@v.com';
    contactAdd.Phone = '(212) 333-4567'; 
    contactAdd.Salutation = 'Dear [FirstName]';  
    Contacts.add(contactAdd);
        
    insert Contacts; 
        
       
        Task tsk = new Task();
        tsk.subject = 'vipin test task';
        tsk.WhoId = contacts[0].id;
        tsk.WhatId = account2.id; 
        tsk.Type = 'Internal account review';
        tsk.ActivityDate = Date.newInstance(2016, 11, 20);
        tsk.Priority = 'Medium';
        tsk.Region__c = 'Japan';
        tsk.Product__c = 'Commodities';
        tsk.Status = 'Open';
        tsk.OwnerId = users[1].Id;
        
        insert tsk;
        
        Attachment attmnt = new Attachment();
        attmnt.ParentId = tsk.id;
        attmnt.Name = 'Test Attachment';
        attmnt.OwnerId = users[1].Id;
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attmnt.body=bodyBlob;

        
        insert attmnt;
        
    }
    
   static testmethod void SendTaskNotifyController_Test(){  
    
    Test.startTest(); 
  
     
    SendTaskNotifyController controller = new SendTaskNotifyController(new ApexPages.StandardController([SELECT Id,Status,WhatId,WhoId,Subject,Description,Type,LastModifiedById,Region__c,Product__c,Priority,CreatedDate,ActivityDate,OwnerId FROM Task WHERE Subject = 'vipin test task']));
    
      
  
    
      
    Test.stopTest();  
 
    } 
}