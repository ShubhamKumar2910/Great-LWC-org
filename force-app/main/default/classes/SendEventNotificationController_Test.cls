@isTest
public class SendEventNotificationController_Test {
    /* @testSetup 
    
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
        
        Event eventObj = new Event();
        eventObj.WhatId = account2.Id;
        eventObj.WhoId = Contacts[0].Id;
        eventObj.OwnerId = users[1].Id;
        eventObj.Subject = 'Test Event';
        eventObj.Description = 'This is a test event';
        eventObj.StartDateTime = Date.newInstance(2016, 11, 15);
        eventObj.EndDateTime = Date.newInstance(2016, 11, 17);
        eventObj.Ticker__c = 'AAPL,23HK';
        
        
        insert eventObj;
        
        EventRelation eventRelationObj1 = new EventRelation();
        eventRelationObj1.EventId = eventObj.Id;
        eventRelationObj1.RelationId = Contacts[1].Id;
        eventRelationObj1.IsParent = TRUE;
        eventRelationObj1.IsInvitee = TRUE;
        
        insert eventRelationObj1;
        
        EventRelation eventRelationObj2 = new EventRelation();
        eventRelationObj2.EventId = eventObj.Id;
        eventRelationObj2.RelationId = Contacts[2].Id;
        eventRelationObj2.IsParent = TRUE;
        eventRelationObj2.IsInvitee = TRUE;
        
        insert eventRelationObj2;
        
        Attachment attmnt = new Attachment();
        attmnt.ParentId = eventObj.id;
        attmnt.Name = 'Test Attachment';
        attmnt.OwnerId = users[1].Id;
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attmnt.body=bodyBlob;

        
        insert attmnt;
        
    }
    
   static testmethod void SendEventNotificationController_Test(){  
    
    Test.startTest(); 
  
     
    SendEventNotificationController controller = new SendEventNotificationController(new ApexPages.StandardController([SELECT Id,WhatId,WhoId,Subject,Description,Type,Ticker__c,ActivityDate,OwnerId FROM EVENT WHERE Subject = 'Test Event']));
    
       string [] firstNames = new string []{};
           firstNames.add('Vipin Pillai');
           firstNames.add('Advait Pillai');
           firstNames.add('Suren Pillai');
       
      
       
       List<Contact> testContacts = [SELECT Id FROM Contact WHERE Name IN : firstNames];
       
       List<String> contacts = new List<String>();             
       for(Contact cont : testContacts){
           contacts.add(cont.id);
       }
       
     controller.whereClause = 'Vipin';
     controller.ccCoverageTeam = true;     
     controller.ccInvitee = true; 
     controller.selectedUserIds = contacts;
     controller.removedUserIds = contacts;
     controller.selectedUsersMap.put(contacts[0],contacts[0]);
     controller.filterAvailableOptions();
     controller.getAvailableUsers() ;
     controller.getSelectedUsers() ;
     controller.goBackToPreviousPage();
     controller.addFIDCoverageMembers();
     controller.addEQCoverageMembers();
     controller.sendEmailInBatches();
     controller.DefaultSetupbasedonUser();
     controller.addOpportunityMembers();
     controller.addInviteesbyDefault();  
     //controller.getContactbasedonEmailAddress('vipinkumar.pillai@nomura.com');
     //controller.sendEmail(); 
     controller.sendEmailToSelf();
     controller.add();
     controller.remove();
    
      
    Test.stopTest();  
 
    } 
*/
}