@isTest
public class ContactSearchServerController_Test {

    @testSetup
    public static void testDataSetup(){
        List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType WHERE Name IN('RG Account', 'RM Account')];
		Id rgRecordType = null;
        Id rmRecordType = null;
        
        if(recordTypeList != null && recordTypeList.size() > 0){
            for(RecordType recordTypeObj : recordTypeList){
                if('RG Account'.equals(recordTypeObj.Name)){
                	rgRecordType = recordTypeObj.Id;    
                }
                if('RM Account'.equals(recordTypeObj.Name)){
                    rmRecordType = recordTypeObj.Id;
                }                
            }    
        }
        
        Account newRGAccount = new Account();
        newRGAccount.Name = 'testAccount RG';
        newRGAccount.RDM_Org_ID__c = 'test1';
        newRGAccount.RecordTypeId = rgRecordType;
        newRGAccount.BillingCity = 'NY';
        newRGAccount.BillingCountry = 'United States';
        newRGAccount.BillingStreet = 'High Street';
        insert newRGAccount;
            
        Account newRMAccount = new Account();
        newRMAccount.Name = 'testAccount RM';
        newRMAccount.RDM_Org_ID__c = 'test1';
        newRMAccount.RecordTypeId = rmRecordType;
        newRMAccount.ParentId = newRGAccount.Id;
        newRMAccount.BillingCity = 'NY';
        newRMAccount.BillingCountry = 'United States';
        newRMAccount.BillingStreet = 'High Street';
        insert newRMAccount;
        
        Profile p = [SELECT Id FROM Profile WHERE Name ='System Administrator' LIMIT 1];
        
        User newUser = new User();
        newUser.Alias = 'newUser';
        newUser.Email = 'testemail@test.com';
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.LastName = 'sample';
        newUser.LanguageLocaleKey = 'en_US';
        newUser.LocaleSidKey = 'en_US';
        newUser.Username = 'ManmeetnewUser@test.com';
        newUser.ProfileId = p.Id;
        newUser.TimeZoneSidKey = 'America/Los_Angeles';
        insert newUser;
        
        Campaign newCampaign = new Campaign(Name='Manmeet Test Campaign',Type='Phone Book',Status='Planned',isActive = true,ownerId = newUser.Id,list_id__c = 'test list id');
        insert newCampaign;
        
        List<Contact> contactList = new List<Contact>();
        Contact newContact1 = new Contact();
        newContact1.Salutation = 'Mr.';
        newContact1.FirstName = 'ContactSearch';
        newContact1.LastName = 'Test';
        newContact1.AccountId = newRMAccount.Id;
        newContact1.Email = 'test@test.com';
        newContact1.Phone = '+44 20 7102 1264';
        newContact1.Active__c = true;
        //newContact.MailingCountryCode = 'United States';
        contactList.add(newContact1);
        
        Contact newContact2 = new Contact();
        newContact2.Salutation = 'Mr.';
        newContact2.FirstName = 'ContactSearch';
        newContact2.LastName = 'Test2';
        newContact2.AccountId = newRMAccount.Id;
        newContact2.Email = 'test2@test.com';
        newContact2.Sponsor_Email_Text__c = 'test3@test.com';
        newContact2.Research_Email__c = 'test4@test.com';
        newContact2.Secondary_Email__c = 'test5@test.com';
        newContact2.Phone = '+44 20 7102 1264';
        newContact2.Active__c = true;
        contactList.add(newContact2);
        
        insert contactList;
                       
        System.debug(LoggingLevel.INFO, 'newRMAccount-'+ newRMAccount.Id);
        /*List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        campaignMemberList.add(new CampaignMember(ContactId = newContact.Id, CampaignId= newCampaign.Id));
        insert campaignMemberList;*/
    }
      
    static testMethod void testContactSearchServerController(){
        
        Account accounts = [SELECT Id, Name, ParentId, RDM_Org_Id__c FROM Account WHERE Name LIKE 'testAccount RM'];
        System.assert(accounts != null);
        String RGAccountId = accounts.ParentId;
        
        List<String> RMAccountIdList = new List<String>();
        RMAccountIdList.add(accounts.Id);
        List<String> RMAccountIdBlankList = new List<String>();
        //Shield Changes. Change in where clause. To search by Account.RDM_Org_Id__c
        Contact[] contacts = [SELECT Id, FirstName, Email, Sponsor_Email_Text__c, Research_Email__c, Secondary_Email__c FROM Contact WHERE Account.RDM_Org_Id__c = :accounts.RDM_Org_ID__c];
        
       	System.assert(contacts != null);
        String contactName = contacts[0].FirstName;
        String contactEmail = contacts[0].Email;
        String researchEmail = contacts[0].Research_Email__c;
        String secondaryEmail = contacts[0].Secondary_Email__c;
        String sponsorEmail = contacts[0].Sponsor_Email_Text__c;
        String combinedContactEmail = contacts[0].Email + '\r\n' + contacts[1].Email;
        String commaSeperatedEmail = contacts[0].Email + ',' + contacts[1].Email;
        
        String contactNameNull = '';
        List<String> contactList = new List<String>();
        contactList.add(contacts[0].Id);
                      
        Campaign campaigns = [SELECT Id, Name FROM Campaign WHERE Name LIKE 'Manmeet Test Campaign'];
        System.assert(campaigns != null);
        String campaignId = campaigns.Id;        
        String incorrectCampaignId = campaigns.Id + 'invalid';
        
       
        //ComboboxListItemWrapper comboboxListObj = new ComboboxListItemWrapper();  
         ContactSearchServerController.getAddressesForAccount(RGAccountId);
        
        System.debug('contactName--' + contactName + '  RGAccountId--' + RGAccountId);        
        String contactData = ContactSearchServerController.getContactData(contactName, RGAccountId, RMAccountIdList);
        System.assert(contactData != NULL);

        String contactDataNull = ContactSearchServerController.getContactData(contactNameNull, RGAccountId, RMAccountIdList);
        System.assert(contactDataNull != NULL);
        
		String contactEmailData = ContactSearchServerController.getContactData(contactEmail, RGAccountId, RMAccountIdBlankList);
        System.assert(contactEmailData != NULL);
        
       	String contactEmailData2 = ContactSearchServerController.getContactData(combinedContactEmail, RGAccountId, RMAccountIdList);
       	System.assert(contactEmailData2 != NULL);
        
        String contactEmailData3 = ContactSearchServerController.getContactData(commaSeperatedEmail, RGAccountId, RMAccountIdList);
       	System.assert(contactEmailData3 != NULL);
        
        String contactEmailData4 = ContactSearchServerController.getContactData(researchEmail, RGAccountId, RMAccountIdList);
       	System.assert(contactEmailData4 != NULL);
        
        String contactEmailData5 = ContactSearchServerController.getContactData(secondaryEmail, RGAccountId, RMAccountIdList);
       	System.assert(contactEmailData5 != NULL);
        
        String contactEmailData6 = ContactSearchServerController.getContactData(sponsorEmail, RGAccountId, RMAccountIdList);
       	System.assert(contactEmailData6 != NULL);
        
       	String insertCampaignMember1 = ContactSearchServerController.insertCampaignMember(campaignId, contactList);
        System.assert(insertCampaignMember1 != NULL);
       
        String insertCampaignMember2 = ContactSearchServerController.insertCampaignMember(campaignId, contactList);
        System.assert(insertCampaignMember2 != NULL);
        
        //String insertIncorectCampaignMember = ContactSearchServerController.insertCampaignMember(incorrectCampaignId, contactList);
        //System.assert(insertIncorectCampaignMember != NULL);
    }
    
}