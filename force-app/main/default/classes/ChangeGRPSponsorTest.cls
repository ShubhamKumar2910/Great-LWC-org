@isTest
public class ChangeGRPSponsorTest {

    @testSetup
    public static void changeGRPSponsor(){
        List<Contact> contacts = new List<Contact>(); 
         
    RecordType RMRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'RM_Account'];
         
         /* Insert Account */
         Account accountObj = new Account();
         accountObj.Name = 'cP Test Account';
         accountObj.RDM_Org_Id__c = 'CPXXXXX';
         accountObj.RecordTypeId = RMRecordType.Id;
         accountObj.Active__c = TRUE;   
         accountObj.BillingStreet = '**Not Entered**' ;
         accountObj.BillingCity = '**Not Entered**';
         accountObj.BillingCountry = 'United States';
         
         insert accountObj;
         
     /* Insert Contact #1 */
        List<Contact> contactList = new List<Contact>();
        Contact newContact1 = new Contact();
        newContact1.Salutation = 'Mr.';
        newContact1.FirstName = 'ContactSearch';
        newContact1.LastName = 'Test';
        newContact1.AccountId = accountObj.Id;
        newContact1.Email = 'test@test.com';
        newContact1.Phone = '+44 20 7102 1264';
        newContact1.Active__c = true;
        //newContact.MailingCountryCode = 'United States';
        contacts.add(newContact1);
        //insert newContact1;
        
         /* Insert Contact #2 */
         Contact contactObj1 = new Contact();
         
         contactObj1.AccountId = accountObj.id;
         contactObj1.FirstName = 'contact2FirstName'; 
         contactObj1.LastName = 'contact2LastName';    
         contactObj1.Active__c = TRUE;
         contactObj1.Email = 'contact2firstname.contact2lastname@dummy.com';
         contactObj1.Research_Email__c = 'contact1FirstName.contact1LastName@dummy.com';
         contactObj1.Phone = '+0 (000) 000-0000'; 
         contactObj1.Salutation = 'M.';    
         contactObj1.Mailing_Address_Same_As_Account_Address__c = TRUE;
         contactObj1.Affiliation_Id__c = '0000';
         contactObj1.Contact_ID__c = '2222';
         
        contacts.add(contactObj1);
        
        insert contacts;

		Contact newContact2 = new Contact();
        newContact2.Salutation = 'Mr.';
        newContact2.FirstName = 'ContactSearch';
        newContact2.LastName = 'Test2';
        newContact2.AccountId = accountObj.Id;
        newContact2.Email = 'test2@test.com';
        newContact2.Phone = '+44 20 7102 1264';
        newContact2.Active__c = true;
        Contact newCon = ChangeGRPSponsor.saveContact(newContact2);
        
        
        ChangeGRPSponsor cntlrObj = new ChangeGRPSponsor();
    }
    
    @isTest
    public static void testMethodAll(){
        
        //Contact con = [SELECT Id, Name FROM Contact];
        
        String Idquery = 'select Id, Sponsor_Email_Text__c from Contact where'+
             ' Email = \'test@test.com\'';
         
         system.debug('Query '+ Idquery);
        //system.debug('Email in query '+ contactObj.Email );
        String rec = '';
        List<Contact> contactInfo = (List<Contact>)Database.query(Idquery);
        if(contactInfo.size() > 0){
                for (Contact c : contactInfo){
                    system.debug(LoggingLevel.Info,' sponsor SFID contact '+c.Id);
                    rec = c.Id;
                }
            
        }
        String newRecIdQuery = 'select Id, Sponsor_Email_Text__c, Email from Contact where'+
             ' Email = \'contact2firstname.contact2lastname@dummy.com\'';
         
         system.debug('Query '+ newRecIdQuery);
        //system.debug('Email in query '+ contactObj.Email );
        String newRec = '';
        List<Contact> newContactInfo = (List<Contact>)Database.query(newRecIdQuery);
        if(newContactInfo.size() > 0){
                for (Contact c : newContactInfo){
                    //system.debug(LoggingLevel.Info,' sponsor SFID contact '+c.Id);
                    newRec = c.Id;
                }
            
        }
        
        system.debug('rec Id retrieved '+ rec);
        Contact testContactInfo = ChangeGRPSponsor.getContactInfo(rec);
        String currentSponsorId = ChangeGRPSponsor.setSponsorId(contactInfo[0]);
        system.debug('currentSponsorId '+ currentSponsorId);
        system.assertEquals(null, currentSponsorId);
        Contact newSponsor = ChangeGRPSponsor.applySponsor(newRec, rec);
        String newGRPSponsor = newSponsor.Sponsor_Email_Text__c;
        
        system.assertEquals(newContactInfo[0].Email, newGRPSponsor);
        
        
	}
}