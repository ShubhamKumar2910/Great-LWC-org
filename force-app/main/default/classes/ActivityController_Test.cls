@isTest
public class ActivityController_Test {

    @testSetup
    public static void testDataSetup(){

		Id rgRecordType = null;
        Id rmRecordType = null;
        Id massActivityRecordType = null;        
        
        List<RecordType> recordTypeList = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName IN ('RG_Account', 'RM_Account', 'Mass_Activity')];
        
        for(RecordType recordTypeObj : recordTypeList){
            if('RG_Account'.equalsIgnoreCase(recordTypeObj.DeveloperName))
                rgRecordType = recordTypeObj.Id;
            else if('RM_Account'.equalsIgnoreCase(recordTypeObj.DeveloperName))
                rmRecordType = recordTypeObj.Id;
            else
               massActivityRecordType = recordTypeObj.Id; 
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
        newRMAccount.RDM_Org_ID__c = 'test12';
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
        
        Campaign newCampaign = new Campaign(Name='Manmeet Test Campaign',Type='Mass Activity',Status='Planned',isActive = true,ownerId = newUser.Id,list_id__c = 'test list id');
        insert newCampaign;
        
        List<Contact> contactList = new List<Contact>();
        for(integer i = 0; i< 5 ; i++){
            Contact newContact = new Contact();
            newContact.FirstName = 'Test' + i; 
            newContact.LastName = 'Contact'; 
            newContact.AccountId = newRMAccount.Id;
            newContact.RG_Account__c = newRgAccount.Id;
            newContact.Active__c = true;
            newContact.Key_Person__c = true;
            newContact.Email = 'a@a' + i + '.com';
            newContact.Phone = '(212) 33' + i + '-4567'; 
            newContact.Salutation = 'Dear [FirstName]';    
            
            contactList.add(newContact);            
        }
        insert contactList;
        
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        campaignMemberList.add(new CampaignMember(ContactId = contactList[0].Id, CampaignId = newCampaign.Id));
        campaignMemberList.add(new CampaignMember(ContactId = contactList[1].Id, CampaignId = newCampaign.Id));
        insert campaignMemberList;
        
        
        Datetime startDateTime = DateTime.now();
        Datetime endDateTime = startDateTime.addHours(1);
        
        Event newEvent = new Event();
        newEvent.WhatId = newCampaign.Id;
        newEvent.OwnerId = newUser.Id;
        newEvent.Subject = newCampaign.Subject__c;
        newEvent.StartDateTime = startDateTime;
        newEvent.EndDateTime = endDateTime;
        insert newEvent;

    }
    
    static testMethod void testMethods(){
        
        Test.startTest();
        String myContactListSelect = '1';
        Boolean selectAllCheckboxValue = false;
                
        Boolean selectAllCheckboxValueTrue = true;
        
        Map<Id, String> dataTableMap = new Map<Id, String>();
        Map<Id, String> selectedDataMap = new Map<Id, String>();
        String filters = createJSON();
        
        Campaign campaignObj = [SELECT Id, Name FROM Campaign WHERE Name = 'Manmeet Test Campaign'];
        String campaignObjId = campaignObj.Id;
        
        CampaignMember campaignMemberObj = [SELECT Id, Name FROM CampaignMember WHERE campaignId = :campaignObjId LIMIT 1];
        
        Event eventObj = [SELECT Id, Subject FROM Event WHERE What.Id = :campaignObjId];
        String eventObjId = eventObj.Id;
        //Shield Changes. Change in where clause. To search by Account.RDM_Org_Id__c
        Account accounts = [SELECT Id, Name, ParentId, RDM_Org_Id__c FROM Account WHERE RDM_Org_Id__c = 'test12'];
        System.assert(accounts != null);
        
        List<Contact> contactList = [SELECT Id, FirstName, Email FROM Contact WHERE Account.RDM_Org_Id__c = :accounts.RDM_Org_ID__c];
        System.debug('contactList' + contactList);
        
        List<String> contactListIds = new List<String>();
        if(contactList.size() > 0){
            for(Contact contactObj : contactList){
                contactListIds.add(contactObj.Id);
                
            }
        }
        //Shield Changes. Change in where clause. To search by Account.RDM_Org_Id__c
        Map<Id, Contact> contactDataTableMap = new Map<Id, Contact>([SELECT Id, FirstName, LastName FROM Contact WHERE Account.RDM_Org_Id__c = :accounts.RDM_Org_ID__c]);
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, FirstName, LastName FROM Contact WHERE Account.RDM_Org_Id__c = :accounts.RDM_Org_ID__c LIMIT 2]);
        Map<Id, Contact> campaignMap = new Map<Id, Contact>();
        Map<Id, Contact> campaignMap2 = new Map<Id, Contact>([SELECT Id, Name, Local_Language_Full_Name__c, Email, Account.Name, Active__c FROM Contact WHERE Account.RDM_Org_Id__c = :accounts.RDM_Org_ID__c AND Active__c = true LIMIT 1]);
        
        ActivityController.getCampaignMember(campaignObjId, myContactListSelect, contactListIds, selectAllCheckboxValue, filters);
        ActivityController.getCampaignMember(campaignObjId, myContactListSelect, contactListIds, selectAllCheckboxValueTrue, filters);        
        ActivityController.removeSelectedData(campaignObjId, contactDataTableMap, contactMap, campaignMap);
        ActivityController.removeSelectedData(campaignObjId, contactDataTableMap, contactMap, campaignMap2);
        
        Test.stopTest();
    }
    
    public static String createJSON(){
       	List<Account> accountList = [SELECT Id, Name FROM Account WHERE RDM_Org_Id__c = 'test1' LIMIT 1];
        String account = accountList[0].Id;
        String jsonString = '';
        
        String query = 'SELECT Id, Name, RG_Account__c FROM Contact WHERE RG_Account__c = \'' + account +'\' LIMIT 1';
        List<Contact> contacts = (List<Contact>)Database.query(query); 
        if(contacts != null && contacts.size() > 0){
        	jsonString = JSON.serialize(new ContactListFilter(contacts[0].RG_Account__c, null, contacts[0].Id, false, null));
        }    
        
        return jsonString;		
    }
}