@isTest
public class Daily_RMFeed_Job_Tasks_Test {

    @testSetup
    static void testDataSetup(){
    
    	Id RSRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RS Account').getRecordTypeId();
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
        
        Account newRGAccount2 = new Account();
        newRGAccount2.Name = 'Changed RG';
        newRGAccount2.RDM_Org_ID__c = 'ChangedRG';
        newRGAccount2.RecordTypeId = RGRecordType;
        newRGAccount2.BillingCity = 'Mumbai';
        newRGAccount2.BillingStreet = 'ABC Street';
        newRGAccount2.BillingCountry = 'India';        
        newRGAccount2.Active__c = true;
        //newRGAccount.Current_RG__c = 'CurrentRG';
        insert newRGAccount2;
        System.debug('-------newRGAccount2-------' + newRGAccount2);
        
                
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
    
        /*
    	List<Contact> contactList = new List<Contact>();
        for(integer i = 0; i< 10; i++){
            Contact newContact = UtilityTesting.createContact('Test', 'Contact'+i, 'test'+ i +'@mail.com', '+123456789', 'Mr.', newRmAccount.Id, true);
            contactList.add(newContact);            
        }
        insert contactList;
        */
        
    	
        Contact newContact = new Contact();
        newContact.FirstName = 'Test';
        newContact.LastName = 'Contact1';
        newContact.Salutation = 'Mr.';
        newContact.Email = 'test@mail.com';
        newContact.Phone = '+123456789';
        newContact.AccountId = newRMAccount.Id;
        newContact.Active__c = true;
        newContact.RG_Account__c = newRGAccount1.Id;
        insert newContact;
        System.debug('-------newContact-------' + newContact);
       
        Task newTask  = new Task();
        newTask.Subject = 'Test Task';
        newTask.WhoId = newContact.Id;
        newTask.Type = 'Internal account review';
        newTask.WhatId = newRGAccount1.Id;
        insert newTask;
        System.debug('-------newTask-------' + newTask);
        
        
        Account updateRM = [SELECT Id, Name FROM Account WHERE Name LIKE 'Test RM' LIMIT 1];       
        updateRM.ParentId =  newRGAccount2.Id;
        update updateRM;
        System.debug('-------updateRM-------' + updateRM);
		
    }
    
    static testMethod void runTestMethods(){
        Test.startTest();
        
        Boolean hasFeedError = false;        
        List<Contact> contactList = [SELECT Id, AccountId, RG_Account__c, Account.Previous_RG__c, Account.Current_RG__c FROM Contact WHERE Account.RDM_Org_ID__c = 'TestRM' LIMIT 1]; 
        Map<Id, String> contactMap = new Map<Id, String>();
        
        if(contactList != null && contactList.size() > 0){
            String accountString = contactList[0].AccountId + '~' + contactList[0].Account.Current_RG__c + '~' + contactList[0].RG_Account__c;
        	contactMap.put(contactList.get(0).Id, accountString);
        
        }
         
        Daily_RMFeed_Job_Tasks jobTask = new Daily_RMFeed_Job_Tasks(contactMap, hasFeedError);
        Id batchJob = Database.executeBatch(jobTask);
        
        Test.stopTest();
        
        List<Task> taskList = [SELECT Id, Subject, WhoId, WhatId FROM Task WHERE Subject LIKE 'Test Task'];
        if(taskList != null && taskList.size() > 0 && contactList != null && contactList.size() > 0){
            System.assertEquals(1, taskList.size());
            
            System.assertEquals(taskList[0].WhoId, contactList[0].Id);
            
            System.assertEquals(taskList[0].WhatId, contactList[0].Account.Current_RG__c);
        }
    }
}