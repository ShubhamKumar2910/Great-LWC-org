@isTest
public class ContactGRPLinksController_Test {
    
     static testmethod void testContactGRPLinksController(){
         Test.startTest();
         
         Integer numTestUsers = 1;  
    	 List<User> users = UtilityTesting.CreateUsersWithManager(numTestUsers);
         
         RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account'];
         
         /* Insert Account */
         Account accountObj = new Account();
         accountObj.Name = 'Nomura Employees';
         accountObj.RDM_Org_Id__c = 'CP12345';
         accountObj.RecordTypeId = RMRecordType.Id;
         accountObj.Active__c = TRUE;   
         accountObj.BillingStreet = '**Not Entered**' ;
         accountObj.BillingCity = '**Not Entered**';
         accountObj.BillingCountry = 'United States';
         
         insert accountObj;
         
         System.debug('Account Id :'+accountObj.Id);
         
         /* Insert Contact */
         Contact contactObj = new Contact();
         
         contactObj.AccountId = accountObj.id;
         contactObj.FirstName = 'contact1FirstName'; 
         contactObj.LastName = 'contact1LastName';    
         contactObj.Active__c = TRUE;
         contactObj.Email = 'contact1FirstName.contact1LastName@dummy.com';
         contactObj.Research_Email__c = 'contact1FirstName.contact1LastName@dummy.com';
         contactObj.Phone = '+0 (000) 000-0000'; 
         contactObj.Salutation = 'M.';    
         contactObj.Mailing_Address_Same_As_Account_Address__c = TRUE;
         contactObj.Affiliation_Id__c = '0000';
         contactObj.Contact_ID__c = '1111';
         
         insert contactObj;
         
         System.debug('Contact Id :'+contactObj.Id);
         
         Test.setCurrentPageReference(new PageReference('Page.ContactGRPLinks')); 
    	 System.currentPageReference().getParameters().put('id', contactObj.id);
    	
    
    	 ContactGRPLinksController controllerObj = new ContactGRPLinksController(new ApexPages.StandardController(contactObj));
         
         Test.stopTest();
     }    

}