@isTest
private class ContactBannerControllerTest {


  static testmethod void createContact() {
   RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account' ];   
      
       Account account3  = new Account(); 
    account3.Name = 'TestAccount3';
    account3.RDM_Org_ID__c = 'test1';            
    account3.RecordTypeId = RMRecordType.Id;
    account3.ShippingStreet = 'ShippingStreet';
    account3.ShippingCity = 'ShippingCity';
    account3.ShippingCountry = 'United States';  
    account3.ShippingState = 'Alaska';
    account3.ShippingPostalCode = 'ShippingPostalCode';
       account3.BillingCity = 'California';
    account3.BillingCountry = 'United States';
    account3.BillingStreet = '52nd Street' ;
   
    account3.Active__c = true;    
    insert account3; 
      
    Contact c = new Contact();
     c.AccountId = account3.id; 
    c.firstname= 'Test';
    c.Salutation = 'Mr';
    c.lastname = 'test';
    c.active__c = true;
    c.email = 'test@test.com';
    c.phone='+1 (123) 456-7891';
    
    insert c;
    
    Test.setCurrentPageReference(new PageReference('Page.ContactBannerPage')); 
    System.currentPageReference().getParameters().put('id', c.id);
    contact ct = [select id,name,active__c from contact where id=:c.id];
    
    ContactBannerController ctrl = new ContactBannerController(new ApexPages.StandardController(c));
    
    ct.active__c = false;
    ct.Inactive_Reason__c = 'Left the Firm';
    update ct;
    ContactBannerController ctrl1 = new ContactBannerController(new ApexPages.StandardController(c));

 }
 
 }