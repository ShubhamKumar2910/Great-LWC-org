@isTest
public class ContactListFilter_Test {

     @testSetup
    public static void testDataSetup(){

		Id rgRecordType = null;        
        
        List<RecordType> recordTypeList = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName IN ('RG_Account', 'RM_Account', 'Mass_Activity')];
        
        for(RecordType recordTypeObj : recordTypeList){
            if('RG_Account'.equalsIgnoreCase(recordTypeObj.DeveloperName))
                rgRecordType = recordTypeObj.Id;           
        }
        
        Account newRGAccount = new Account();
        newRGAccount.Name = 'testAccount RG';
        newRGAccount.RDM_Org_ID__c = 'test1';
        newRGAccount.RecordTypeId = rgRecordType;
        newRGAccount.BillingCity = 'NY';
        newRGAccount.BillingCountry = 'United States';
        newRGAccount.BillingStreet = 'High Street';
        insert newRGAccount;
        
        Account newRMAccount = UtilityTesting.createRMAccount(
                'RM Test Account 2', newRGAccount.Id, 'Test4', '52nd Street', 'California', 'United States', true);
        insert newRMAccount;
        
        List<Contact> contacts = new List<Contact>();
        Contact c1 = UtilityTesting.createContact('James', 'Smith', 'jamessmith@test.com', '(212) 333-4567', 'Dear [FirstName]', newRMAccount.Id, true);
        contacts.add(c1);
      	insert contacts;
	
        Id phoneBookRecordTypeId = Schema.getGlobalDescribe().get('Campaign').getDescribe().getRecordTypeInfosByName().get('Phone Book').getRecordTypeId(); 
        //Insert Campaign of Type Phone Book
        Campaign phoneBookCampaignObj = new Campaign();
        phoneBookCampaignObj.Name = 'Test Contact List' ;
        phoneBookCampaignObj.RecordTypeId = phoneBookRecordTypeId;
        insert phoneBookCampaignObj;
        
    }
    
     static testMethod void testConstructor(){
    	ContactListFilter contactList = new ContactListFilter();
        List<Account> accountRGList = [SELECT Id, Name FROM Account WHERE NAME = 'testAccount RG'];
        List<Account> accountRMList = [SELECT Id, Name FROM Account WHERE NAME = 'RM Test Account 2'];
        List<Contact> contactsList = [SELECT Id, Name FROM Contact WHERE Email = 'jamessmith@test.com'];
        List<Campaign> campaignList = [SELECT Id, Name FROM Campaign WHERE Name = 'Test Contact List'] ;
        Boolean showNonCoveredContacts = false; 
    	
        ContactListFilter contactListFilter = new ContactListFilter(accountRGList[0].Id, accountRMList[0].Id, contactsList[0].Id, showNonCoveredContacts, campaignList[0].Id);
    }
}