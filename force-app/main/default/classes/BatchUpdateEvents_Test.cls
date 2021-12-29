@isTest
public class BatchUpdateEvents_Test {

    @testSetup
    static void setup(){
        
        Id RGRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();
        Id RMRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
        
        Account newRGAccount1 = new Account();
        newRGAccount1.Name = 'Test RG';
        newRGAccount1.RDM_Org_ID__c = 'TestRG';
        newRGAccount1.RecordTypeId = RGRecordType;
        newRGAccount1.BillingCity = 'Mumbai';
        newRGAccount1.BillingStreet = 'ABC Street';
        newRGAccount1.BillingCountry = 'India';        
        newRGAccount1.Active__c = true;
        //newRGAccount.Current_RG__c = 'CurrentRG';
        insert newRGAccount1;
        System.debug('-------newRGAccount1-------' + newRGAccount1);
                
        Account newRMAccount = new Account();
        newRMAccount.Name = 'Test RM';
        newRMAccount.RDM_Org_ID__c = 'TestRM';
        newRMAccount.RecordTypeId = RMRecordType;
        newRMAccount.ParentId = newRGAccount1.Id;       
        newRMAccount.BillingCity = 'Mumbai';
        newRMAccount.BillingStreet = 'ABC Street';
        newRMAccount.BillingCountry = 'India';           
        newRMAccount.Active__c = true;
        //newRGAccount.Current_RG__c = 'CurrentRG';
        insert newRMAccount;
        System.debug('-------newRMAccount-------' + newRMAccount);
    

        Contact newContact = new Contact();
        newContact.FirstName = 'Test';
        newContact.LastName = 'Contact1';
        newContact.Salutation = 'Mr.';
        newContact.Email = 'test@mail.com';
        newContact.Phone = '+123456789';
        newContact.AccountId = newRMAccount.Id;
        newContact.Active__c = true;
        insert newContact;
        System.debug('-------newContact-------' + newContact);
      
        
        List<User> userList = UtilityTesting.CreateUsers(1);
        User newUser = userList[0];
        
        Datetime startDateTime = Datetime.now();
		Datetime endDateTime = startDateTime.addHours(1);
        
        Event newEvent = new Event();  
        newEvent.Type = 'Meeting';
        newEvent.WhatId = newRGAccount1.Id;
        newEvent.WhoId = newContact.Id;
        newEvent.OwnerId = newUser.Id;
        newEvent.Subject = 'Test Event';
        newEvent.StartDateTime = startDateTime;
        newEvent.EndDateTime = endDateTime;        
       	insert newEvent;
        System.debug('-------newEvent-------' + newEvent);
        
    }
    
	@isTest    
    static void runTestMethod(){
        
        Test.startTest();
        
        BatchUpdateEvents batchEvent = new BatchUpdateEvents();
        Id batchId = Database.executeBatch(batchEvent, 100);
        
        Test.stopTest();
       	Event eventObj = [SELECT Id, Subject, Type FROM Event WHERE Subject = 'Test Event' LIMIT 1];
        System.assertNotEquals(null, eventObj);
        System.assertEquals('Meeting',eventObj.Type);
        
    }
}