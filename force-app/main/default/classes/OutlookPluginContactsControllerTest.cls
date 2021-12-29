@IsTest
public with sharing class OutlookPluginContactsControllerTest
{
    @IsTest
    private static void testReturningContactsAndUsersWithMatchingEmails()
    {
        List<String> lstEmails = new List<String>();
        List<Contact> lstContactInsert = new List<Contact>();
        Integer random = UtilityTesting.getRandomInteger(1,10000);

        Account rgAccount = UtilityTesting.createRGAccount('Test RG account',null,'RG000000','Test billing street', 'London', 'United Kingdom',true);
        insert rgAccount;
        Account rmAccount = UtilityTesting.createRMAccount('Test RM Account',rgAccount.Id,'RM000000','Test RM billing str', 'London', 'United Kingdom',true);
        insert rmAccount;

        for(integer i=0; i<5; i++)
        {
            Contact contact = UtilityTesting.createContact('firstname'+random+i,'lastname'+random+i,'fnamelname'+random+i+'@test.com','44208000000','Mr',rmAccount.Id,true);
            contact.RG_Account__c = rgAccount.Id;
            lstContactInsert.add((contact));
            lstEmails.add(contact.Email);
        }
        insert lstContactInsert;

        List<User> lstUsers = UtilityTesting.createUsersWithProfile(2,'Nomura - Sales');
        LstUsers = [SELECT Id, Email FROM User WHERE Id in :lstUsers];
        for(User Usr : lstUsers)
        {
            lstEmails.add(Usr.Email);
        }

        Test.startTest();
        Map<String,List<SObject>> mapContactsAndUser = OutlookPluginContactsController.getContactsAndUsersByEmail(lstEmails);
        Test.stopTest();
        System.assert(mapContactsAndUser!=null && !mapContactsAndUser.isEmpty(),'Contacts and users map cannot be null or empty');

        List<Contact> lstContact = mapContactsAndUser.get('contacts');
        System.assert(lstContact!=null && !lstContact.isEmpty(),'Email matched contacts list cannot be null or empty');
        List<User> lstQueryUsers = mapContactsAndUser.get('users');
        System.assert(lstQueryUsers!=null && !lstQueryUsers.isEmpty(),'Email matched users list cannot be null or empty');
    }

    @IsTest
    private static void testReturningContactsAndUsersWithNoMatchingEmails()
    {
        List<String> lstEmails = new List<String>{'random_email55@randomtest.com, random_email99@randomtest.com, random_email88@randomtest.com'};

        Test.startTest();
        Map<String,List<SObject>> mapContactsAndUser = OutlookPluginContactsController.getContactsAndUsersByEmail(lstEmails);
        Test.stopTest();
        System.assert(mapContactsAndUser!=null && !mapContactsAndUser.isEmpty(),'Contacts and users map cannot be null or empty');

        List<Contact> lstContact = mapContactsAndUser.get('contacts');
        System.assert(lstContact!=null && lstContact.isEmpty(),'List of contacts when searching of random emails must be non-null and empty');
        List<User> lstQueryUsers = mapContactsAndUser.get('users');
        System.assert(lstQueryUsers!=null && lstQueryUsers.isEmpty(),'List of users when searching of random emails must be non-null and empty');
    }

}