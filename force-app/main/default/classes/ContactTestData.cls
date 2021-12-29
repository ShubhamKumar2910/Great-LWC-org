/*
		Author 		: Developer Name
		Company 	: Nomura
		Date 		: 25/06/2018
		Description : Utility class to create Contact test data 
					  for test classes.
*/
@isTest
public class ContactTestData 
{
	public static Contact getContact(Id accountId)
	{
		// Return a single Contact
		
		Contact contact = new Contact();
		contact.AccountId = accountId;
		contact.Salutation = 'Mr';
		contact.FirstName = 'James';
		contact.LastName = 'Bond';
		contact.Email = 'jamesbond@mi6.com';
		contact.Active__c = true;
		return contact;
	}
	
	public static List<Contact> getContacts(Id accountId, Decimal numberOfContacts)
	{
		// Return the number of Contacts specified in 
    	// the numberOfContacts parameter
    	
    	List<Contact> contacts = new List<Contact>();
    	
    	for (Decimal decLoop = 0; decLoop < numberOfContacts; decLoop++)
    	{
    		Contact contact = new Contact();
			contact.AccountId = accountId;
			contact.Salutation = 'Mr';
			contact.FirstName = 'James';
			contact.LastName = 'Bond';
			contact.Email = String.ValueOf(decLoop) + 'jamesbond@mi6.com';
			contacts.add(contact);	
    	}
    	
    	return contacts;
	}
}