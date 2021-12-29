@isTest
private class TaskOutlookHandler_test {
   
    /*
    @testSetUp    
    private static void insertNewContacts() {
        /*
        RecordType recordTypeForRG = [SELECT Id, Name FROM RecordType WHERE Name = 'RG Account'];
        RecordType recordTypeForRM = [SELECT Id, Name FROM RecordType WHERE Name = 'RM Account'];
       
       Id recordTypeIdForRG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();   
       Id recordTypeIdIdForRM = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();   
       
        
        //Account ac = new Account(Name='Test',RecordTypeId = recordTypeForRG.Id,Active__c = true,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
        Account ac = new Account(Name='Test',RecordTypeId = recordTypeIdForRG,Active__c = true,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
		Account acNomEmp = new Account(Name='NOMURA EMPLOYEES',BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
        insert ac;
        insert acNomEmp;
        
        //Account accountRM = new Account(Name='Test_RM_Account',RecordTypeId = recordTypeForRM.Id, ParentId = ac.Id,Active__c = true,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
		Account accountRM = new Account(Name='Test_RM_Account',RecordTypeId = recordTypeIdIdForRM, ParentId = ac.Id,Active__c = true,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
        insert accountRM;
        
   
        string iNo= '1';
        Profile p  = [SELECT Id From Profile WHERE Name='System Administrator' limit 1];
        User u    = new User( Alias = 'newUser'+iNo,
                             Email ='newuser'+iNo+'@testorg.com',
                             EmailEncodingKey = 'UTF-8',
                             LastName = 'Testing'+iNo,
                             LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', 
                             UserName='event1newuser'+iNo+UtilityTesting.userDomain,
                             ProfileId=p.Id,
                             TimeZoneSidKey = 'America/Los_Angeles'
                            );
        
        insert u;
        
        Contact act = new Contact(FirstName='aTestFirstName', LastName='aTestLastName', Salutation='TestSalutation', Email='adummy@nomura.com.dummy',Phone='+1 (212) 456-7890',Active__C=true, AccountId = accountRM.Id );
        insert act;
        
        Contact ict = new Contact(FirstName='iTestFirstName', LastName='iTestLastName', Salutation='TestSalutation', Email='idummy@nomura.com.dummy',Phone='+1 (212) 456-7891',Inactive_Reason__c='No Longer a Client of Nomura' ,Active__c=false,AccountId = accountRM.Id );
        insert ict;
        
        
     /*   Event eventAdd = new Event();
        eventAdd.WhatId = acNomEmp.id;
        eventAdd.WhoId = act.id;
        eventAdd.OwnerId = u.id;
        eventAdd.Subject = 'Test Event';
        eventAdd.StartDateTime = Date.newInstance(2016, 08, 19);
        eventAdd.StartDateTime = Date.newInstance(2016, 08, 20); 
        
        
        //insert eventAdd;
    }
    */
    
    @testSetUp
    private static void insertTask() {
        String recordTypeIdForRGAccount = null;
        String recordTypeIdForCPEventIntegration = null;
        
        /*    
        RecordType RGRecordType = [SELECT Id FROM RecordType WHERE Name = 'RG Account' ];
        RecordType RSRecordType = [SELECT Id FROM RecordType WHERE Name = 'RS Account' ];
        RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account' ];
        */  
        
        //Id RSRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RS Account').getRecordTypeId();   
        //Id RGRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();   
        Id RMRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();   	
           
        
       
        /* Record Type */
        List<RecordType> recordTypeList = [Select Id, Name FROM RecordType 
                                           WHERE Name IN ('RG Account', 'CP Event Integration')  ];
        if(recordTypeList != null && recordTypeList.size() > 0){
            for(RecordType recordType : recordTypeList){
                if('RG Account'.equalsIgnoreCase(recordType.Name)){
                    recordTypeIdForRGAccount = recordType.Id;
                }
                else if('CP Event Integration'.equalsIgnoreCase(recordType.Name)){
                    recordTypeIdForCPEventIntegration = recordType.Id;
                }
            }
        }
        
        /* Account Insertion */
        Account testAccount = new Account(Name='Test_Account_For_Event_And_EventRelations', Active__c = true,
                                          RecordTypeId = recordTypeIdForRGAccount,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
        insert testAccount;
        /*
        Account testAccountRM= new Account(Name='Test_Account_RM_For_Event_And_EventRelations', Active__c = true,
                                          RecordTypeId = RMRecordType.id,ParentId =testAccount.id ,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
        */
        Account testAccountRM= new Account(Name='Test_Account_RM_For_Event_And_EventRelations', Active__c = true,
                                          RecordTypeId = RMRecordTypeId,ParentId =testAccount.id ,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
        
        
        insert testAccountRM;
        /* User Insertion */
        User testUser = null;
        List<User> testUserList = UtilityTesting.CreateUsers(1);
        if(testUserList != null && testUserList.size() > 0){
            testUser = testUserList[0];
        }
        
        /* Contact Insertion */
		Contact contactObj1 = new Contact(FirstName='contact1FirstName', LastName='contact1LastName', Salutation='Mr', Email='contact1FirstName.contact1LastName@dummy.com',Phone='+0 (000) 000-0000',Active__c=true,AccountId = testAccountRM.id );
        insert contactObj1;
        
        /*
        Contact contactObj2 = new Contact(FirstName='contact2FirstName', LastName='contact2LastName', Salutation='Mr', Email='contact2FirstName.contact2LastName@dummy.com',Phone='+0 (000) 000-0000',Active__c=true, AccountId =  testAccountRM.id);
        insert contactObj2;
        
        Contact contactObj3 = new Contact(FirstName='contact3FirstName', LastName='contact3LastName', Salutation='Mr', Email='contact3FirstName.contact3LastName@dummy.com',Phone='+0 (000) 000-0000',Active__c=true, AccountId =  testAccountRM.id);
        insert contactObj3;
        */
        Task taskObj = new Task();        
        taskObj.WhoId = contactObj1.Id;
        taskObj.OwnerId = testUser.Id;
        taskObj.Subject = 'Test Task TaskOutLook test';       
        insert taskObj;
        
    }

    private static testMethod void testpopulateWhatIdForTask(){
        Test.startTest();
        Account[] contactAccounts = [SELECT Id, Name FROM Account WHERE Name = 'Test_Account_RM_For_Event_And_EventRelations'];
        Contact[] contacs = [SELECT AccountId FROM Contact WHERE FirstName='contact1FirstName'];
        Task[] ev = [Select id, whoId, whatId, what.name from Task where subject = 'Test Task TaskOutLook test' LIMIT 1];
		
        System.debug('outlook inside testpopulateWhatId .....');
        System.debug(' outlook Accounts .....' + contactAccounts.size());
        System.debug(' outlook Contacts .....' + contacs.size()); 
        System.debug(' outlook Events .....' + ev.size());
        if(contactAccounts.size()>0&&contacs.size()>0&&ev.size()>0){
            System.debug('outlook who id is ' + ev[0].whoId);
            System.debug('outlook what id is ' + ev[0].whatId + '---name---' + ev[0].what.Name);
            
            List<id> evIdList = new List<id>();
            evIdList.add(ev[0].id);
                      
    		TaskOutlookHandler.populateWhatId(evIdList);
         }    
         Test.stopTest();
        
    } 

}