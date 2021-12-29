@isTest
public class SendEventController_Test {
    @testSetup 
    private static void setupTestData(){
        List<Account> RGAccountList =  new List<Account>();
        List<Account> RMAccountList =  new List<Account>();   
        List<Contact> contacts = new List<Contact>();
        List<Event> eventList = new List<Event>();
        List<EventRelation> eventRelationList = new List<EventRelation>();
        
        Id RGRecordTypeId = CommonTools.getRecordTypeId('Account', 'RG Account');
        Id RSRecordTypeId = CommonTools.getRecordTypeId('Account', 'RS Account');
        Id RMRecordTypeId = CommonTools.getRecordTypeId('Account', 'RM Account');
        Id NomuraRecordTypeId = CommonTools.getRecordTypeId('Account', 'NOMURA EMPLOYEES');
        
        List<User> users = UtilityTesting.CreateUsersWithManager(3);
        List<User> users1 = utilityTesting.CreateUsersWithManagerForAEJ(3);
        
        Account accountAdd = new Account();
        accountAdd.Name = 'TestAccount1';
        accountAdd.RDM_Org_ID__c = 'test1';            
        accountAdd.RecordTypeId = RSRecordTypeId; 
        accountAdd.BillingCity = 'California';
        accountAdd.BillingCountry = 'United States';
        accountAdd.BillingStreet = '52nd Street' ;
        insert accountAdd;
        
        Account nomuraAccG = new Account();
        nomuraAccG.Name = 'NOMURA EMPLOYEES (G)';
        nomuraAccG.RDM_Org_ID__c = 'CPG12345';            
        nomuraAccG.RecordTypeId = RGRecordTypeId; 
        nomuraAccG.BillingCity = 'California';
        nomuraAccG.BillingCountry = 'United States';
        nomuraAccG.BillingStreet = '52nd Street' ;
        RGAccountList.add(nomuraAccG);
        
        Account account2  = new Account(); 
        account2.Name = 'TestAccount2';
        account2.RDM_Org_ID__c = 'test2';            
        account2.RecordTypeId = RGRecordTypeId;
        account2.ParentId = accountAdd.Id;
        account2.BillingCity = 'California';
        account2.BillingCountry = 'United States';
        account2.BillingStreet = '52nd Street' ;
        account2.Symphony_Room_Id__c = '0UjLldk1Qj/18dYG2b1+O0H///o54eljCdA==';
        RGAccountList.add(account2);
        
        insert RGAccountList;
        
        Account nomuraAcc = new Account();
        nomuraAcc.Name = 'NOMURA EMPLOYEES';
        nomuraAcc.RDM_Org_ID__c = 'CP12345';            
        nomuraAcc.RecordTypeId = NomuraRecordTypeId;
        nomuraAcc.ParentId = nomuraAccG.Id;
        nomuraAcc.BillingCity = 'California';
        nomuraAcc.BillingCountry = 'United States';
        nomuraAcc.BillingStreet = '52nd Street' ;
        RMAccountList.add(nomuraAcc);
               
        Account account3  = new Account(); 
        account3.Name = 'TestAccount3';
        account3.RDM_Org_ID__c = 'test3';            
        account3.RecordTypeId = RMRecordTypeId;
        account3.ParentId = account2.Id;
        account3.Active__c = true; 
        account3.BillingCity = 'California';
        account3.BillingCountry = 'United States';
        account3.BillingStreet = '52nd Street' ;
        RMAccountList.add(account3);
        
        insert RMAccountList;
        
        Contact contactAdd = new Contact();
        contactAdd = new Contact();       
        contactAdd.AccountId = nomuraAcc.Id;
        contactAdd.RG_Account__c = nomuraAccG.Id;
        contactAdd.FirstName = 'SFNEWS';
        contactAdd.LastName = 'AEJSALES';
        contactAdd.Login_Id__c = 'SF_NEWS_AEJ_SALES_DL';
        contactAdd.Active__c = true;
        contactAdd.Key_Person__c = false;    
        contactAdd.Email = 'dummyxx@testxx.comx';
        contactAdd.Phone = '(212) 333-4567'; 
        contactAdd.Salutation = 'M.';  
        Contacts.add(contactAdd);
        
        contactAdd = new Contact(); 
        contactAdd.AccountId = account3.id;
        contactAdd.RG_Account__c = account2.Id;
        contactAdd.FirstName = 'vipin'; 
        contactAdd.LastName = 'pillai';    
        contactAdd.Active__c = true;
        contactAdd.Key_Person__c = true;
        contactAdd.Email = 'a@a.com';
        contactAdd.Phone = '(212) 333-4567'; 
        contactAdd.Salutation = 'Dear [FirstName]';    
        Contacts.add(contactAdd);

        contactAdd = new Contact();       
        contactAdd.AccountId = account3.Id;
        contactAdd.RG_Account__c = account2.Id;
        contactAdd.FirstName = 'Suren';
        contactAdd.LastName = 'pillai';       
        contactAdd.Active__c = true;
        contactAdd.Key_Person__c = true;    
        contactAdd.Email = 'b@b.com';
        contactAdd.Phone = '(212) 333-4567'; 
        contactAdd.Salutation = 'Dear [FirstName]';  
        Contacts.add(contactAdd); 
        
        contactAdd = new Contact();        
        contactAdd.AccountId = account3.Id;
        contactAdd.RG_Account__c = account2.Id;
        contactAdd.FirstName = 'Advait';
        contactAdd.LastName = 'pillai';       
        contactAdd.Active__c = true;
        contactAdd.Key_Person__c = true;    
        contactAdd.Email = 'advait@v.com';
        contactAdd.Phone = '(212) 333-4567'; 
        contactAdd.Salutation = 'Dear [FirstName]';  
        Contacts.add(contactAdd);        
        
        //SALES-3651
        //Role Manager Contact
        contactAdd = new Contact();        
        contactAdd.AccountId = account3.Id;
        contactAdd.RG_Account__c = account2.Id;
        contactAdd.FirstName = 'User';
        contactAdd.LastName = 'UserMgr1';       
        contactAdd.Active__c = true;
        contactAdd.Key_Person__c = true;    
        contactAdd.Email = 'event1UserMgr1123@nomtestorg.com';
        contactAdd.Phone = '(212) 333-4567'; 
        contactAdd.Salutation = 'Dear [FirstName]';  
        contactAdd.Login_id__c='UserMgr1';
        Contacts.add(contactAdd);
		
        //LDAP Manager Contact
        contactAdd = new Contact();        
        contactAdd.AccountId = account3.Id;
        contactAdd.RG_Account__c = account2.Id;
        contactAdd.FirstName = 'User';
        contactAdd.LastName = 'UserMgr2';       
        contactAdd.Active__c = true;
        contactAdd.Key_Person__c = true;    
        contactAdd.Email = 'event1UserMgr2123@nomtestorg.com';
        contactAdd.Phone = '(212) 333-4567'; 
        contactAdd.Salutation = 'Dear [FirstName]';  
        contactAdd.Login_id__c='UserMgr2';
        Contacts.add(contactAdd);
        insert Contacts; 
        
		//insert 2nd record for opportunity
		Opportunity opportunityObj = new Opportunity();
		opportunityObj.Name = 'Test Opportunity';
		opportunityObj.Account__c = account2.Id;
        opportunityObj.StageName = 'Prospecting';
        opportunityObj.CloseDate = System.today() + 5;
		insert opportunityObj;
        
        Event eventObj = new Event();
        eventObj.WhatId = account2.Id;
        eventObj.WhoId = Contacts[0].Id;
        eventObj.OwnerId = users[1].Id;
        eventObj.Subject = 'Test Event';
        //fix for test class failure JIRA 3410
        eventObj.L0_Type__c = 'Broker Review';
        eventObj.Type = 'Broker Review';
        eventObj.Description = 'This is a test event';
        eventObj.StartDateTime = Date.newInstance(2016, 11, 15);
        eventObj.EndDateTime = Date.newInstance(2016, 11, 17);
        eventObj.Ticker__c = 'AAPL,23HK';    
        eventObj.Sector__c = '';          
        eventList.add(eventObj);

		Event eventObj1 = new Event();
        eventObj1.WhatId = opportunityObj.Id;
        eventObj1.WhoId = Contacts[0].Id;
        eventObj1.OwnerId = users[1].Id;
        eventObj1.IsAllDayEvent = true;
        //fix for test class failure JIRA 3410
        eventObj1.L0_Type__c = 'Broker Review';
        eventObj1.Type = 'Broker Review';
        eventObj1.Subject = 'Test Event2';
        eventObj1.Sector__c = '10';
        eventObj1.StartDateTime = Date.newInstance(2016, 11, 15);
        eventObj1.EndDateTime = Date.newInstance(2016, 11, 17);                
        eventList.add(eventObj1);
        
        //SALES-3651
		Event eventObj2 = new Event();
        eventObj2.WhatId = account2.Id;
        eventObj2.WhoId = Contacts[0].Id;
        eventObj2.OwnerId = users1[1].Id;
        eventObj2.Subject = 'Test Event02';
        eventObj2.Sector__c = '10';
        eventObj2.L0_Type__c = 'Broker Review';
        eventObj2.Type = 'Broker Review';
        eventObj2.Description = 'This is a test event';
        eventObj2.StartDateTime = Date.newInstance(2016, 11, 15);
        eventObj2.EndDateTime = Date.newInstance(2016, 11, 17);
        eventList.add(eventObj2);
        insert eventList;
        
        Attachment attmnt = new Attachment();
        attmnt.ParentId = eventObj.id;
        attmnt.Name = 'Test Attachment';
        attmnt.OwnerId = users[1].Id;
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attmnt.body=bodyBlob;
        insert attmnt;
       
        Task_LTA__c taskltaObj = new Task_LTA__c();
        taskltaObj.Parent_Task__c = eventObj1.Id;
        taskltaObj.LTA_1__c = 'This is a test event22';
        insert taskltaObj;

        EventRelation eventRelationObj1 = new EventRelation();
        eventRelationObj1.EventId = eventObj.Id;
        eventRelationObj1.RelationId = Contacts[1].Id;
        eventRelationObj1.IsParent = TRUE;
        eventRelationObj1.IsInvitee = TRUE;        
        eventRelationList.add(eventRelationObj1);
        
        EventRelation eventRelationObj2 = new EventRelation();
        eventRelationObj2.EventId = eventObj.Id;
        eventRelationObj2.RelationId = Contacts[2].Id;
        eventRelationObj2.IsParent = TRUE;
        eventRelationObj2.IsInvitee = TRUE;        
        eventRelationList.add(eventRelationObj2);
                
        EventRelation eventRelationObj3 = new EventRelation();
        eventRelationObj3.EventId = eventObj1.Id;
        eventRelationObj3.RelationId = Contacts[1].Id;
        eventRelationObj3.IsParent = TRUE;
        eventRelationObj3.IsInvitee = TRUE;
        eventRelationList.add(eventRelationObj3);
        insert eventRelationList;
        
    }
    
    static testmethod void SendEventController_Test(){  
        
        Test.startTest();  
        List<User> users = [SELECT Id,Name,Email FROM USER WHERE Name = 'UserMgr'];
        List<Event> EventInAction =   [SELECT Id,WhatId,WhoId,Subject,Description,Type,Ticker__c,ActivityDate,OwnerId FROM EVENT WHERE Subject = 'Test Event'];     
        SendEventController.populateEventFields(EventInAction[0].Id); 
        SendEventController.FetchInvitees(EventInAction[0].Id);
        
        string FIDRegions = 'Global';
        string EQRegions = 'Global';
        String IBDRegions = 'Japan';
        string InstinetRegions = 'Asia';
        
        string RecipientList =  users[0].Id;
        List<UserDetails> usrdtlsList = new List<UserDetails>();
        UserDetails usrdtls = new UserDetails();
        usrdtls.Id  = users[0].Id;
        usrdtls.Name = users[0].Name;
        usrdtls.Email  = 'vipinkumar.pillai@nomura.com';
        usrdtls.UserType = 'User';
        usrdtls.Source = 'Desktop';
        usrdtlsList.add(usrdtls);
        
        SendEventController.FetchRecipients(FIDRegions,EQRegions,EventInAction[0].Id,true,IBDRegions,InstinetRegions);
        //SendEventController.sendCntrlEmailToSelf(EventInAction[0].Id, JSON.serialize(usrdtlsList));
        SendEventController.sendEmailCmp(EventInAction[0].Id, JSON.serialize(usrdtlsList));
        sendEventController.getUserName();
        
        
        List<Event> EventInAction1=   [SELECT Id,WhatId,WhoId,Subject,Description,Type,Ticker__c,ActivityDate,OwnerId FROM EVENT WHERE Subject = 'Test Event2'];     
        system.debug('Event what id*****************' + EventInAction1[0].WhatId);
        SendEventController.FetchRecipients(FIDRegions,EQRegions,EventInAction1[0].Id,true,IBDRegions, InstinetRegions);
        SendEventController.populateEventFields(EventInAction1[0].Id); 
        SendEventController.FetchInvitees(EventInAction1[0].Id);
        
        SendEventController.sendCntrlEmailToSelf(EventInAction1[0].Id, JSON.serialize(usrdtlsList));
        //SendEventController.sendEmailCmp(EventInAction1[0].Id, JSON.serialize(usrdtlsList));
        Test.stopTest();  
        
    } 
    
    // Active Role Manager
    static testmethod void SendEventController_TestAEJUser(){
        
        User integrationUserObj = [SELECT Id, Login_Id__c, Alias, LastName, Email, UserName, ProfileId 
                        		   FROM User WHERE Login_Id__c = 'sfadmin' LIMIT 1];
        System.runAs(integrationUserObj){
            test.startTest();
            List<User> users = [SELECT id,Name,UserRoleId FROM USER WHERE UserName='event1UserMgr4561@nomtestorg.com'];
            if(users != null){
                users[0].UserRoleId = [select id from UserRole where Name = 'AEJ - EQ - Sales - AEJ - Ideas Hub - AEJ' limit 1].Id;
                update users;
                
                List<Event> EventInAction =   [SELECT Id,WhatId,WhoId,Subject,Description,Type,Ticker__c,ActivityDate,OwnerId FROM EVENT WHERE Subject = 'Test Event02'];
                SendEventController.populateEventFields(EventInAction[0].Id); 
                SendEventController.FetchInvitees(EventInAction[0].Id);             
            }
            test.stopTest();
    }
}
    
    // Inactive Role Manager | Active Nomura Contact
    static testmethod void SendEventController_TestAEJInactiveManager(){
        
        User integrationUserObj = [SELECT Id, Login_Id__c, Alias, LastName, Email, UserName, ProfileId 
                        		   FROM User WHERE Login_Id__c = 'sfadmin' LIMIT 1];
        System.runAs(integrationUserObj){
            test.startTest();
            List<User> users = [SELECT id,Name,UserRoleId FROM USER WHERE UserName='event1UserMgr4561@nomtestorg.com'];
            List<User> manager = [SELECT id,Name,isActive FROM USER WHERE UserName='event1UserMgr1123@nomtestorg.com'];
            
            if(users != null && manager !=null){
                manager[0].isActive = false;
                update manager;
                
                users[0].UserRoleId = [select id from UserRole where Name = 'AEJ - EQ - Sales - AEJ - Ideas Hub - AEJ' limit 1].Id;
                update users;
                
                List<Event> EventInAction =   [SELECT Id,WhatId,WhoId,Subject,Description,Type,Ticker__c,ActivityDate,OwnerId FROM EVENT WHERE Subject = 'Test Event02'];
                SendEventController.populateEventFields(EventInAction[0].Id); 
                SendEventController.FetchInvitees(EventInAction[0].Id);
            }
            test.stopTest();
    	}
	}
    
    // Inactive Role Manager | Inactive Nomura Contact -> Active LDAP Manager
    static testmethod void SendEventController_TestAEJActiveLDAPManager(){
        
        User integrationUserObj = [SELECT Id, Login_Id__c, Alias, LastName, Email, UserName, ProfileId 
                        		   FROM User WHERE Login_Id__c = 'sfadmin' LIMIT 1];
        System.runAs(integrationUserObj){
            test.startTest();
            List<User> users = [SELECT id,Name,UserRoleId FROM USER WHERE UserName='event1UserMgr4561@nomtestorg.com'];
            List<User> manager = [SELECT id,Name,isActive FROM USER WHERE UserName='event1UserMgr1123@nomtestorg.com'];
            List<Contact> contact = [SELECT id,Name,Active__c FROM CONTACT WHERE Login_id__c='UserMgr1'];
            
            if(users != null && manager !=null && contact != null){
                manager[0].isActive = false;
                update manager;
                
                contact[0].Active__c = false;
                update contact;
                
                users[0].UserRoleId = [select id from UserRole where Name = 'AEJ - EQ - Sales - AEJ - Ideas Hub - AEJ' limit 1].Id;
                update users;
                
                List<Event> EventInAction =   [SELECT Id,WhatId,WhoId,Subject,Description,Type,Ticker__c,ActivityDate,OwnerId FROM EVENT WHERE Subject = 'Test Event02'];
                SendEventController.populateEventFields(EventInAction[0].Id); 
                SendEventController.FetchInvitees(EventInAction[0].Id);
            }
            test.stopTest();
    	}
	}
    
    // Inactive Role Manager | Inactive Nomura Contact -> Inactive LDAP Manager | Active LDAP Contact
    static testmethod void SendEventController_TestAEJInactiveLDAPManager(){
        
        User integrationUserObj = [SELECT Id, Login_Id__c, Alias, LastName, Email, UserName, ProfileId 
                        		   FROM User WHERE Login_Id__c = 'sfadmin' LIMIT 1];
        System.runAs(integrationUserObj){
            test.startTest();
            List<User> users = [SELECT id,Name,UserRoleId FROM USER WHERE UserName='event1UserMgr4561@nomtestorg.com'];
            List<User> manager = [SELECT id,Name,isActive FROM USER WHERE UserName='event1UserMgr1123@nomtestorg.com'];
            List<Contact> contact = [SELECT id,Name,Active__c FROM CONTACT WHERE Login_id__c='UserMgr1'];
            List<User> LDAPManager = [SELECT id,Name,isActive FROM USER WHERE UserName='event1UserMgr2123@nomtestorg.com'];
            
            if(users != null && manager !=null && contact != null && LDAPManager != null){
                manager[0].isActive = false;
                update manager;
                
                contact[0].Active__c = false;
                update contact;
                
                LDAPManager[0].isActive = false;
                update LDAPManager;
                
                users[0].UserRoleId = [select id from UserRole where Name = 'AEJ - EQ - Sales - AEJ - Ideas Hub - AEJ' limit 1].Id;
                update users;
                
                List<Event> EventInAction =   [SELECT Id,WhatId,WhoId,Subject,Description,Type,Ticker__c,ActivityDate,OwnerId FROM EVENT WHERE Subject = 'Test Event02'];
                SendEventController.populateEventFields(EventInAction[0].Id); 
                SendEventController.FetchInvitees(EventInAction[0].Id);
            }
            test.stopTest();
    	}
	}
    
	static testmethod void SendEventController_TestIncludeInvitee(){
        User integrationUserObj = [SELECT Id, Login_Id__c, Alias, LastName, Email, UserName, ProfileId 
                        		   FROM User WHERE Login_Id__c = 'sfadmin' LIMIT 1];
        System.runAs(integrationUserObj){
            test.startTest();
            List<User> users = [SELECT id,Name,UserRoleId FROM USER WHERE UserName='event1UserMgr4560@nomtestorg.com'];
            List<Event> EventInAction = [SELECT Id,WhatId,WhoId,Subject,Description,Type,Ticker__c,ActivityDate,OwnerId FROM EVENT WHERE Subject = 'Test Event02'];
            if(users != null){
                users[0].UserRoleId = [select id from UserRole where Name = 'AEJ - FI - Sales - Management' limit 1].Id;
                update users;
                
                EventRelation eventRelationObj = new EventRelation();
                eventRelationObj.EventId = EventInAction[0].Id;
                eventRelationObj.RelationId = users[0].Id;
                eventRelationObj.IsParent = FALSE;
                eventRelationObj.IsInvitee = TRUE;
                insert eventRelationObj;
                
                SendEventController.populateEventFields(EventInAction[0].Id); 
                SendEventController.FetchInvitees(EventInAction[0].Id);
            }
            test.stopTest();
        }
    }    
}