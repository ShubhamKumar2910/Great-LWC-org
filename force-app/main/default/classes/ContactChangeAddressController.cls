public without sharing class ContactChangeAddressController {

    @AuraEnabled
    public static List<Account>  getAccountAddresses(String accountId){
        
        List<Account> addresses = [Select Id, ParentId, BillingStreet, BillingCity, BillingState,BillingCountry, BillingPostalCode
                                   From Account
                                   Where ParentId = :accountId
                                   and Active__c = true
                                   Order By BillingCountry, BillingCity, BillingStreet ASC];
        if(addresses.size() > 0){
            for(Account a : addresses){
                if(a.BillingStreet.contains('**Not Entered**')){
                    a.BillingStreet = '**UNDISCLOSED**';
                }
            }
        }
        return addresses;
    }

    @AuraEnabled
    public static Contact  getContactDetails(String contactId){
        
        Contact contact = [Select Id,AccountId, RG_Account__c
        				   From Contact
        				   Where Id = :contactId
                           Limit 1];

        return contact;
    }

    @AuraEnabled
    public static Map<String, String> saveContact(Contact c, String rmAccountId, String contactId){
    	Map<String, String> resultsMap = new Map<String, String>();
        c.AccountId = rmAccountId;
        c.Id = contactId;

        Account rmAccount = [Select Id, ParentId From Account Where Id = :rmAccountId Limit 1];

        if(rmAccount != null){
            c.RG_Account__c = rmAccount.ParentId;
        }
    	System.debug('New Contact: ' + c);

    	Database.SaveResult contactSaveResult = Database.update(c, false);

    	if (contactSaveResult.isSuccess()) {
            resultsMap.put('Contact ID', contactSaveResult.getId());
        }else{              
            for(Database.Error err : contactSaveResult.getErrors()) {

                resultsMap.put('Error', err.getMessage()); 
                resultsMap.put('Error', err.getStatusCode() + ': ' + err.getMessage()  + ' ' +  'Fields that affected this error: ' + err.getFields());               
           
            }
        }
        
    	return resultsMap;
    }

}