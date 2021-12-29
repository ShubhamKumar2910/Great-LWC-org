/*
	Author 		: Simon Foden
	Company 	: Nomura
	Date 		: 05/09/2018
	Description : Controller for the ETradingEnablementContact 
				  Lightning component.
	
*/  
public with sharing class ETradingEnablementContactController 
{
 	@AuraEnabled 
 	public static String initialise()
 	{
		ETradingEnablementData eTradingEnablementData = new ETradingEnablementData();
		
		if (!checkFieldLevelSecurity())
        {
            eTradingEnablementData.error = true;
            eTradingEnablementData.errorMessage = 'Field Level Security Error : User does not have permission to view the data';
            
            return JSON.serialize(eTradingEnablementData);
        }
		
		eTradingEnablementData.salutations = getSalutations();
		
		return JSON.serialize(eTradingEnablementData); 		
 	}
 	
 	public static Boolean checkFieldLevelSecurity()
    {
        String [] accessFields = new String [] 
        {
        	'AccountId',
        	'Salutation',
        	'FirstName',
        	'LastName',
        	'Email',
        	'Phone'
        };
    	
        Map<String, Schema.SObjectField> contactFields = Schema.SObjectType.Contact.fields.getMap();
    
        for (String fieldToCheck : accessFields)
        {
            if ((!contactFields.get(fieldToCheck).getDescribe().isAccessible()) 
            	|| (!contactFields.get(fieldToCheck).getDescribe().isCreateable()))
            {
                return false;
            }
        }
            
        return true;
    }
 	
 	public static Map<String, String> getSalutations()
    {
        Map<String, String> picklistValues = new Map<String, String>();
        picklistValues = CommonTools.GetFieldPicklistValuesMap('Contact', 'Salutation', true);
        
        return picklistValues;
    }
 	
 	@AuraEnabled 
 	public static List<Account> getAccountAddresses(String accountId)
	{
		List<Account> addresses = [SELECT Id, ParentId, 
								   BillingStreet, BillingCity, BillingState,
								   BillingCountry, BillingPostalCode 
								   FROM Account 
								   WHERE ParentId = :accountId
								   AND Active__c = true 
								   ORDER BY  
								   BillingStreet, BillingCity, BillingState, 
								   BillingPostalCode, BillingCountry 
								   ASC];
								   
		return addresses;
	}
	
	@AuraEnabled 
	public static String saveContact(Contact contact, String rmAccountId)
	{
		Contact newContact = new Contact();
		newContact.AccountId = rmAccountId;
        newContact.Salutation = contact.Salutation;
        newContact.FirstName = contact.FirstName;
        newContact.LastName = contact.LastName;
        newContact.Email = contact.Email;
        newContact.Phone = contact.Phone;
        
		ETradingEnablementContactData eTradingEnablementContactData = new ETradingEnablementContactData();
		
        Database.SaveResult saveResult = Database.insert(newContact, false);
        
        if (saveResult.isSuccess())
        {
        	eTradingEnablementContactData.contactId = saveResult.getId();
        }
        else
        {
        	eTradingEnablementContactData.error = true;
        	eTradingEnablementContactData.errorMessage = 'Unable to create contact';
        	
        	for (Database.Error error : saveResult.getErrors())
        	{
        		eTradingEnablementContactData.errorMessage += ' : ' + error.getStatusCode() + ' - ' + error.getMessage();
        	}
        	
        	return JSON.serialize(eTradingEnablementContactData);
        }
        
        return JSON.serialize(eTradingEnablementContactData);
	}
	
	public class ETradingEnablementData 
    {
        public ETradingEnablementData() 
        {
        	error = false;
            errorMessage = '';
        }   
        
        public Boolean error;
		public String errorMessage;
        
        public Map<String, String> salutations;
        
	}
	
	public class ETradingEnablementContactData 
    {
        public ETradingEnablementContactData() 
        {
        	error = false;
            errorMessage = '';
        }   
        
        public Boolean error;
		public String errorMessage;
        
        public String contactId;
	}   
}