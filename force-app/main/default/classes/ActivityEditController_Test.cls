@isTest
public class ActivityEditController_Test {

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
        
        Campaign newCampaign = new Campaign(Name='Manmeet Test Campaign',Type='Mass Activity',Status='Planned',isActive = true,ownerId = newUser.Id,list_id__c = 'test list id');
        insert newCampaign;
        
        List<Contact> contactList = new List<Contact>();
        for(integer i = 0; i< 5 ; i++){
            Contact newContact = new Contact();
            newContact.FirstName = 'Test' + i; 
            newContact.LastName = 'Contact';
            newContact.AccountId = newRMAccount.Id;
            //newContact.RG_Account__c = newRgAccount.Id;
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
        
        Campaign campaignObj = [SELECT Id, Name FROM Campaign WHERE Name = 'Manmeet Test Campaign'];
        String campaignObjId = campaignObj.Id;
        
        Event eventObj = [SELECT Id, Subject FROM Event WHERE What.Id = :campaignObjId];
        String eventObjId = eventObj.Id;
      
        List<Event> checkEvent = ActivityEditController.checkForEventType(eventObjId);
       	System.assert(checkEvent.size() > 0);
        Test.stopTest();
    }
    
}