@isTest
public class OpptyUpdatesCRTest {

    static testMethod void testManualOpptyUpdatesForClientRemediation() {
        Integer numTestUsers = 1;  
        List<User> users = UtilityTesting.CreateUsersWithManager(numTestUsers);
        
        RecordType recordTypeRG = [SELECT Id FROM RecordType WHERE Name = 'RG Account' LIMIT 1];
       
        system.runas(users[0]){
       
            //Insert Accounts
            Account oldAccountObj = new Account();
            oldAccountObj.Name = 'Old_Account';
            oldAccountObj.RDM_Org_Id__c = 'RG1';
            oldAccountObj.RecordTypeId = recordTypeRG.Id;
            oldAccountObj.Active__c = TRUE;   
           
            insert oldAccountObj;
            
            Account newAccountObj = new Account();
            newAccountObj.Name = 'New_Account';
            newAccountObj.RDM_Org_Id__c = 'RG2';
            newAccountObj.RecordTypeId = recordTypeRG.Id;
            newAccountObj.Active__c = TRUE;   
            
            insert newAccountObj;
            
            //Insert Opportunity
            List<Opportunity> opptyList = new List<Opportunity>();
            
            Opportunity opptyForOldAccountObj = new Opportunity();
            opptyForOldAccountObj.Name = 'Old Account Oppty';
            opptyForOldAccountObj.Account__c = oldAccountObj.Id;
            opptyForOldAccountObj.AccountId = oldAccountObj.Id;
            opptyForOldAccountObj.CloseDate = Date.today();
            opptyForOldAccountObj.StageName = 'Closed Lost';
            
            opptyList.add(opptyForOldAccountObj);
            
            Opportunity opptyForNewAccountObj = new Opportunity();
            opptyForNewAccountObj.Name = 'New Account Oppty';
            opptyForNewAccountObj.Account__c = newAccountObj.Id;
            opptyForNewAccountObj.AccountId = newAccountObj.Id;
            opptyForNewAccountObj.CloseDate = Date.today();
            opptyForNewAccountObj.StageName = 'Closed Lost';
            
            opptyList.add(opptyForNewAccountObj);
            
            insert opptyList;
            
            //Insert entry in Client_Remediation__c Obect
            Client_Remediation__c crObj = new Client_Remediation__c();
            
            crObj.OLD_RG__c = 'RG1';
            crObj.NEW_RG__c = 'RG2';
            crObj.RG_ACTION__c = 'MERGE';
            crObj.OLD_RG_Account__c = oldAccountObj.Id;
            crObj.NEW_RG_Account__c = newAccountObj.Id;
            
            insert crObj;
            
            //Execute the Job
            Test.startTest();
        
            Database.executeBatch(new OpptyUpdatesForClientRemediationBatch('RG'), 1);
           
            Test.stopTest(); 
            
            //Test Results
            List<Opportunity> opptyListAfterUpdates = 
                [
                    SELECT Id, Name
                    FROM Opportunity
                    WHERE Account.RDM_Org_Id__c = 'RG2'
                ]; 
            
            System.assertEquals(2, opptyListAfterUpdates.size());
        }
            
	}
    
    static testMethod void testAutomatedOpptyUpdatesForClientRemediation() {
        User sfadminUserObj = [SELECT Id, Name, Login_Id__c FROM User WHERE Login_Id__c = 'sfadmin' AND Profile.Name = 'Nomura - Integration' AND IsActive = TRUE LIMIT 1];
        
        //Insert User
        Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        UserRole userRole = [SELECT Id, Name FROM userRole WHERE Name = 'Japan - FI Sales - Region Head' LIMIT 1];
        
        User userObj = new User();
        userObj.Login_ID__c = 'crtest';
        userObj.Alias = 'crtest';
        userObj.LastName = 'crtest';
        userObj.Email = 'crtest@crtest.com';
        userObj.UserName = 'crtest@crtest.com';
        userObj.ProfileId = profileNomuraSales.Id;
        userObj.EmailEncodingKey = 'UTF-8';
        userObj.LanguageLocaleKey = 'en_US';
        userObj.LocaleSidKey = 'en_US';
        userObj.TimeZoneSidKey = 'America/Los_Angeles';
        userObj.Region__c = 'Americas';
        userObj.UserRoleId = (userRole != null) ? userRole.Id : null;
        
        insert userObj;
        
        User otherUserObj = new User();
        otherUserObj.Login_ID__c = 'crtest1';
        otherUserObj.Alias = 'crtest1';
        otherUserObj.LastName = 'crtest1';
        otherUserObj.Email = 'crtest2@crtest.com';
        otherUserObj.UserName = 'crtest2@crtest.com';
        otherUserObj.ProfileId = profileNomuraSales.Id;
        otherUserObj.EmailEncodingKey = 'UTF-8';
        otherUserObj.LanguageLocaleKey = 'en_US';
        otherUserObj.LocaleSidKey = 'en_US';
        otherUserObj.TimeZoneSidKey = 'America/Los_Angeles';
        otherUserObj.Region__c = 'Americas';
        otherUserObj.UserRoleId = (userRole != null) ? userRole.Id : null;
        
        insert otherUserObj;
        
        RecordType recordTypeRM = [SELECT Id FROM RecordType WHERE Name = 'RM Account' LIMIT 1];
       
        system.runas(sfadminUserObj){
       
            //Insert Accounts
            Account oldAccountObj = new Account();
            oldAccountObj.Name = 'Old_Account';
            oldAccountObj.RDM_Org_Id__c = 'RM1';
            oldAccountObj.RecordTypeId = recordTypeRM.Id;
            oldAccountObj.BillingCity = 'California';
        	oldAccountObj.BillingCountry = 'United States';
        	oldAccountObj.BillingStreet = '52nd Street';
            oldAccountObj.Active__c = TRUE;   
           
            insert oldAccountObj;
            
            Account newAccountObj = new Account();
            newAccountObj.Name = 'New_Account';
            newAccountObj.RDM_Org_Id__c = 'RM2';
            newAccountObj.RecordTypeId = recordTypeRM.Id;
            newAccountObj.BillingCity = 'California';
        	newAccountObj.BillingCountry = 'United States';
        	newAccountObj.BillingStreet = '52nd Street';
            newAccountObj.Active__c = TRUE;   
            
            insert newAccountObj;
            
            //Insert Contacts
            Contact contactForOldAccountObj = new Contact();
            contactForOldAccountObj.Salutation = 'M.';
            contactForOldAccountObj.FirstName = 'FN_Old';
            contactForOldAccountObj.LastName = 'LN_Old';
            contactForOldAccountObj.Email = 'FN_Old.LN_Old@test.com';
            contactForOldAccountObj.Research_Email__c = 'FN_Old.LN_Old@test.com';
            contactForOldAccountObj.Phone = '+0000000000';
            contactForOldAccountObj.Mailing_Address_Same_As_Account_Address__c = TRUE;
            contactForOldAccountObj.AccountId = oldAccountObj.Id;
            contactForOldAccountObj.Active__c = TRUE;
            
			insert contactForOldAccountObj;
            
            //Insert Opportunity
            Id recordTypeIdForAutomatedOppty = CommonTools.getRecordTypeId('Opportunity','Automated');
            List<Opportunity> opptyList = new List<Opportunity>();
            
            Opportunity opptyForOldAccountObj = new Opportunity();
            opptyForOldAccountObj.Name = 'Old Account Oppty';
            opptyForOldAccountObj.AccountId = oldAccountObj.Id;
            opptyForOldAccountObj.CloseDate = Date.today();
            opptyForOldAccountObj.StageName = 'Prospecting';
            opptyForOldAccountObj.SystemAuto_Type__c = 'For Person';
            opptyForOldAccountObj.SystemAuto_Target_ID__c = userObj.Id;
            opptyForOldAccountObj.SystemAuto_Person_Role_ID__c = (userRole != null) ? userRole.Id : null;
            opptyForOldAccountObj.RecordTypeId = recordTypeIdForAutomatedOppty;
            
            opptyList.add(opptyForOldAccountObj);
            
            Opportunity opptyForOldAccountObj2 = new Opportunity();
            opptyForOldAccountObj2.Name = 'Old Account Oppty 2';
            opptyForOldAccountObj2.AccountId = oldAccountObj.Id;
            opptyForOldAccountObj2.CloseDate = Date.today();
            opptyForOldAccountObj2.StageName = 'Prospecting';
            opptyForOldAccountObj2.SystemAuto_Type__c = 'For Person';
            opptyForOldAccountObj2.SystemAuto_Target_ID__c = otherUserObj.Id;
            opptyForOldAccountObj2.SystemAuto_Person_Role_ID__c = (userRole != null) ? userRole.Id : null;
            opptyForOldAccountObj2.RecordTypeId = recordTypeIdForAutomatedOppty;
            
            opptyList.add(opptyForOldAccountObj2);
            
            Opportunity opptyForNewAccountObj = new Opportunity();
            opptyForNewAccountObj.Name = 'New Account Oppty';
            opptyForNewAccountObj.AccountId = newAccountObj.Id;
            opptyForNewAccountObj.CloseDate = Date.today();
            opptyForNewAccountObj.StageName = 'Prospecting';
            opptyForNewAccountObj.SystemAuto_Type__c = 'For Person';
            opptyForNewAccountObj.SystemAuto_Target_ID__c = userObj.Id;
            opptyForNewAccountObj.SystemAuto_Person_Role_ID__c = (userRole != null) ? userRole.Id : null;
            opptyForNewAccountObj.RecordTypeId = recordTypeIdForAutomatedOppty;
            
            opptyList.add(opptyForNewAccountObj);
            
            insert opptyList;
            
            //Fetch Opportunities
            List<Opportunity> insertedOpptyList = [SELECT Id, Name, AccountId
                                                   FROM Opportunity 
                                                   WHERE Name IN ('Old Account Oppty','Old Account Oppty 2')];
            
            Opportunity opptyWithOldAccountObj = null;
            Opportunity opptyWithOldAccountObj2 = null;
            
            if(insertedOpptyList != null && insertedOpptyList.size() > 0){
                
                for(Opportunity oppty : insertedOpptyList){
                    if(oppty.Name.equalsIgnoreCase('Old Account Oppty')){
                        opptyWithOldAccountObj = oppty;
                    }
                    else if(oppty.Name.equalsIgnoreCase('Old Account Oppty 2')){
                        opptyWithOldAccountObj2 = oppty;
                    }
                }
                
                if(opptyWithOldAccountObj != null && opptyWithOldAccountObj2 != null){
                    //Insert Events
                    Id standardEventRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Standard Event').getRecordTypeId();
                    Datetime startDateTime = Datetime.now();
                    Datetime endDateTime = startDateTime.addHours(1);
                    List<Event> eventList = new List<Event>();
                    
                    Event eventForOldAccountObj = new Event();
                    eventForOldAccountObj.OwnerId = userObj.Id;
                    eventForOldAccountObj.Subject = 'Test Old Event';
                    eventForOldAccountObj.WhatId = opptyWithOldAccountObj.Id;
                    eventForOldAccountObj.WhoId = contactForOldAccountObj.Id;
                    eventForOldAccountObj.StartDateTime = startDateTime;
                    eventForOldAccountObj.EndDateTime = endDateTime;
                    eventForOldAccountObj.RecordTypeId = standardEventRecordTypeId;
                    
                    eventList.add(eventForOldAccountObj);
                    
                    Event eventForOldAccountObj2 = new Event();
                    eventForOldAccountObj2.OwnerId = userObj.Id;
                    eventForOldAccountObj2.Subject = 'Test Old Event 2';
                    eventForOldAccountObj2.WhatId = opptyWithOldAccountObj2.Id;
                    eventForOldAccountObj2.WhoId = contactForOldAccountObj.Id;
                    eventForOldAccountObj2.StartDateTime = startDateTime;
                    eventForOldAccountObj2.EndDateTime = endDateTime;
                    eventForOldAccountObj2.RecordTypeId = standardEventRecordTypeId;
                    
                    eventList.add(eventForOldAccountObj2);
                    
                    insert eventList;
                    
                    //Insert Tasks
                    Id standardTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Standard Task').getRecordTypeId();
                    List<Task> taskList = new List<Task>();
                    
                    Task taskForOldAccountObj = new Task();
                    taskForOldAccountObj.OwnerId = userObj.Id;
                    taskForOldAccountObj.Subject = 'Test Old';
                    taskForOldAccountObj.Region__c = 'Americas';
                    taskForOldAccountObj.Division__c = 'Equities';
                    taskForOldAccountObj.Type = 'Other';
                    taskForOldAccountObj.Priority = 'Medium';
                    taskForOldAccountObj.Status = 'Open';
                    taskForOldAccountObj.WhatId = opptyWithOldAccountObj.Id;
                    taskForOldAccountObj.WhoId = contactForOldAccountObj.Id;
                    taskForOldAccountObj.RecordTypeId = standardTaskRecordTypeId;
                    
                    taskList.add(taskForOldAccountObj);
                    
                    insert taskList;
                    
                }
                
                
            }
            
            //Insert entry in Client_Remediation__c Obect
            Client_Remediation__c crObj = new Client_Remediation__c();
            
            crObj.OLD_RM__c = 'RM1';
            crObj.NEW_RM__c = 'RM2';
            crObj.RM_ACTION__c = 'MERGE';
            crObj.OLD_RM_Account__c = oldAccountObj.Id;
            crObj.NEW_RM_Account__c = newAccountObj.Id;
            
            insert crObj;
            
            //Execute the Job
            Test.startTest();
        
            Database.executeBatch(new OpptyUpdatesForClientRemediationBatch('RM'), 1);
           
            Test.stopTest(); 
            
            //Test Results
            List<Opportunity> opptyListAfterUpdates = 
                [
                    SELECT Id, Name, AccountId, Account.RDM_Org_Id__c,
                    SystemAuto_Type__c, SystemAuto_Target_ID__c, SystemAuto_Person_Role_ID__c
                    FROM Opportunity
                    WHERE Account.RDM_Org_Id__c = 'RM2'
                ]; 
            
            System.assertEquals(2, opptyListAfterUpdates.size());
            
            List<Event> eventListAfterUpdates = [SELECT Id, WhatId, What.Name FROM Event 
                                                 WHERE WhatId IN (SELECT Id FROM Opportunity WHERE Account.RDM_Org_Id__c = 'RM1')];
            List<Task> taskListAfterUpdates = [SELECT Id, WhatId FROM Task 
                                               WHERE WhatId IN (SELECT Id FROM Opportunity WHERE Account.RDM_Org_Id__c = 'RM1')];
            
            System.assertEquals(0, eventListAfterUpdates.size());
            System.assertEquals(0, taskListAfterUpdates.size());
            
        }
            
	}
}