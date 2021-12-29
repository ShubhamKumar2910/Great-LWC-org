@isTest
public class AccountRecentViewedContactsContTest 
{
    /* SHIELD - START :     
    @isTest
    static void verifiyAccountContactsController()
    {
        List<Account> testAccounts =  new List<Account>();  
        List<Contact> contacts = new List<Contact>(); 

        RecordType RGRecordType = [SELECT Id FROM RecordType WHERE Name = 'RG Account' ];
        RecordType RSRecordType = [SELECT Id FROM RecordType WHERE Name = 'RS Account' ];
        RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account' ];
        
        Account testAccountG1 = new Account();
        testAccountG1.Name = 'Test-AccountRecentViewedContactsContTest';
        testAccountG1.RDM_Org_ID__c = 'test1';            
        testAccountG1.RecordTypeId = RGRecordType.Id; 
        testAccountG1.BillingCity = 'California';
        testAccountG1.BillingCountry = 'United States';
        testAccountG1.BillingStreet = '52nd Street' ;
        insert testAccountG1;    

        Account testAccountM1  = new Account(); 
        testAccountM1.Name = 'TestAccountM1';
        testAccountM1.RDM_Org_ID__c = 'test1';            
        testAccountM1.RecordTypeId = RMRecordType.Id;
        testAccountM1.ParentId = testAccountG1.Id;
        testAccountM1.BillingCity = 'California';
        testAccountM1.BillingCountry = 'United States';
        testAccountM1.BillingStreet = '52nd Street' ;
        insert testAccountM1;

        Contact newContact = new Contact();
        newContact.AccountId = testAccountM1.id;
        newContact.FirstName = 'vipin'; 
        newContact.LastName = 'pillai';    
        newContact.Active__c = true;
        newContact.Key_Person__c = true;
        newContact.Email = 'a@a.com';
        newContact.Phone = '(212) 333-4567'; 
        newContact.Salutation = 'Dear [FirstName]';  
        newContact.MailingStreet = '52nd Street';
        newContact.MailingCity = 'California';
        newContact.MailingCountry = 'United States';  
        Contacts.add(newContact);
        
        newContact = new Contact();
        newContact.AccountId = testAccountM1.Id;
        newContact.FirstName = 'Suren';
        newContact.LastName = 'pillai';       
        newContact.Active__c = true;
        newContact.Key_Person__c = true;    
        newContact.Email = 'b@b.com';
        newContact.Phone = '(212) 333-4567'; 
        newContact.Salutation = 'Dear [FirstName]';  
        newContact.MailingStreet = '52nd Street';
        newContact.MailingCity = 'California';
        newContact.MailingCountry = 'United States';    
        Contacts.add(newContact); 
          
        insert Contacts;
  
        Test.startTest(); 
        
            AccountRecentViewedContactsController testCont = new AccountRecentViewedContactsController(
                new ApexPages.StandardController
                ([
                    SELECT Id,Name,ParentId,RecordTypeId,RDM_ORG_ID__c 
                    FROM 
                    Account 
                    WHERE Name = 'Test-AccountRecentViewedContactsContTest'
                ])
            );
        
            //system.assertEquals(2, testCont.getContacts().size());

        Test.stopTest();
    }
	SHIELD - END :  */ 
}