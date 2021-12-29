@isTest
public class ContactServiceTest {

    @testSetup
    static void testData() {
        Account rgAccount = UtilityTesting.createRGAccount('RG Account', null, '12345', 'Biling street', 'Billing City', 'United Kingdom', true);
        insert rgAccount;
        
        Account rmAccount = UtilityTesting.createRMAccount('RM Test Account 1', rgAccount.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        insert rmAccount; 
        
        Contact cont =  UtilityTesting.createContact('firstname', 'lastname', 'test@test.com', '020204040404', 'Mr', rmAccount.Id, true);
        insert cont;
    }
    
    @isTest
    static void testGetUnassignedContact() {
        Contact con = [SELECT Id FROM Contact WHERE Email = 'test@test.com' LIMIT 1];
        con.Developer_Reference__c = 'Unassigned eTrading';
        update con;
        
        Test.startTest();
        String contactId = ContactService.getUnassignedContactId();
        Test.stopTest();
        
        System.assertEquals(true, String.isNotBlank(contactId));
        System.assertEquals(con.Id, contactId);
    }
    
    @isTest
    static void testFindContactsUsingId() {
        Contact con = [SELECT Id FROM Contact WHERE Email = 'test@test.com' LIMIT 1];
        
        Test.startTest();
        List<Contact> contacts = ContactService.findContacts(null, null, null, null, null, null, con.Id);
        Test.stopTest();
        
        System.assertEquals(false, contacts.isEmpty());
        System.assertEquals(con.Id, contacts[0].Id);
    }
    
    @isTest
    static void testFindContactsUsingSearchString() {
        Account rgAcc = [SELECT Id, RDM_Org_Id__c FROM Account WHERE Name = 'RG Account' LIMIT 1];
        rgAcc.RDM_Org_Id__c = '1234567890';
        update rgAcc;
        
        Contact con = [SELECT Id, Name, Account.ParentId, RG_Account__r.RDM_Org_Id__c FROM Contact WHERE FirstName = 'firstname' LIMIT 1];

        Test.setFixedSearchResults(new List<String> {con.Id});
        
        Test.startTest();
        List<Contact> contacts = ContactService.findContacts('firstname lastname', new List<String>{con.Account.ParentId}, false, true, 1000, 0, null);
        Test.stopTest();
        
        System.assertEquals(false, contacts.isEmpty());
        System.assertEquals(con.Id, contacts[0].Id);
    }
    
     @isTest
    static void testqueryContact(){

        Contact con = [SELECT Id FROM Contact WHERE Email = 'test@test.com' LIMIT 1];
        
        Test.startTest();
        contact obj = ContactService.queryContact(con.Id);
        Test.stopTest();

        System.assertEquals(con.Id, obj.Id);
    }
}