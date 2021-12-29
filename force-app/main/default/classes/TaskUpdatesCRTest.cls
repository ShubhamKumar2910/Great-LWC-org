@isTest
public class TaskUpdatesCRTest {
    
    static testMethod void testTaskUpdatesRGForClientRemediation() {
        Integer numTestUsers = 1;  
        List<User> users = UtilityTesting.CreateUsersWithManager(numTestUsers);
        
        Id recordTypeForRMId = null;
        Id recordTypeForRGId = null;
         
        List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType 
                                           WHERE Name IN ('RM Account', 'RG Account')];
         
        if(recordTypeList != null && recordTypeList.size() > 0){
            for(RecordType recordTypeObj : recordTypeList){
                if('RM Account'.equalsIgnoreCase(recordTypeObj.Name)){
                    recordTypeForRMId = recordTypeObj.Id;
                }
                if('RG Account'.equalsIgnoreCase(recordTypeObj.Name)){
                    recordTypeForRGId = recordTypeObj.Id;
                }
            } 
        }
        
        system.runas(users[0]){
            
             //Insert RG Accounts
            Account oldRGAccountObj = new Account();
            oldRGAccountObj.Name = 'Old_Account_RG';
            oldRGAccountObj.RDM_Org_Id__c = 'RG1';
            oldRGAccountObj.RecordTypeId = recordTypeForRGId;
            oldRGAccountObj.Active__c = TRUE;   
           
            insert oldRGAccountObj;
            
            Account newRGAccountObj = new Account();
            newRGAccountObj.Name = 'New_Account_RG';
            newRGAccountObj.RDM_Org_Id__c = 'RG2';
            newRGAccountObj.RecordTypeId = recordTypeForRGId;
            newRGAccountObj.Active__c = TRUE;   
            
            insert newRGAccountObj;
       
            //Insert RM Accounts
            Account oldAccountObj = new Account();
            oldAccountObj.Name = 'Old_Account';
            oldAccountObj.RDM_Org_Id__c = 'RM1';
            oldAccountObj.RecordTypeId = recordTypeForRMId;
            oldAccountObj.ParentId = oldRGAccountObj.Id;
            oldAccountObj.BillingCity = 'California';
        	oldAccountObj.BillingCountry = 'United States';
        	oldAccountObj.BillingStreet = '52nd Street';
            oldAccountObj.Active__c = TRUE;   
           
            insert oldAccountObj;
            
            Account newAccountObj = new Account();
            newAccountObj.Name = 'New_Account';
            newAccountObj.RDM_Org_Id__c = 'RM2';
            newAccountObj.RecordTypeId = recordTypeForRMId;
            newAccountObj.ParentId = newRGAccountObj.Id;
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
            
			insert contactForOldAccountObj;

            Contact contactForNewAccountObj = new Contact();
            contactForNewAccountObj.Salutation = 'M.';
            contactForNewAccountObj.FirstName = 'FN_New';
            contactForNewAccountObj.LastName = 'LN_New';
            contactForNewAccountObj.Email = 'FN_New.LN_New@test.com';
            contactForNewAccountObj.Research_Email__c = 'FN_New.LN_New@test.com';
            contactForNewAccountObj.Phone = '+0000000000';
            contactForNewAccountObj.Mailing_Address_Same_As_Account_Address__c = TRUE;
            contactForNewAccountObj.AccountId = newAccountObj.Id;
            
			insert contactForNewAccountObj;
            
            /* Testing for RG - Start */
            
            //Insert Task
            Id standardTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Standard Task').getRecordTypeId();
            List<Task> taskList = new List<Task>();
            
            Task taskForOldAccountObj = new Task();
            taskForOldAccountObj.OwnerId = users[0].Id;
            taskForOldAccountObj.Subject = 'Test Old';
            taskForOldAccountObj.Region__c = 'Americas';
            taskForOldAccountObj.Division__c = 'Equities';
            taskForOldAccountObj.Type = 'Other';
            taskForOldAccountObj.Priority = 'Medium';
            taskForOldAccountObj.Status = 'Open';
            taskForOldAccountObj.WhoId = contactForOldAccountObj.Id;
            taskForOldAccountObj.WhatId = oldRGAccountObj.Id;
            taskForOldAccountObj.RecordTypeId = standardTaskRecordTypeId;
            
            taskList.add(taskForOldAccountObj);
            
            Task taskForNewAccountObj = new Task();
            taskForNewAccountObj.OwnerId = users[0].Id;
            taskForNewAccountObj.Subject = 'Test New';
            taskForNewAccountObj.Region__c = 'Americas';
            taskForNewAccountObj.Division__c = 'Equities';
            taskForNewAccountObj.Type = 'Other';
            taskForNewAccountObj.Priority = 'Medium';
            taskForNewAccountObj.Status = 'Open';
            taskForNewAccountObj.WhoId = contactForNewAccountObj.Id;
            taskForNewAccountObj.WhatId = newRGAccountObj.Id;
            taskForNewAccountObj.RecordTypeId = standardTaskRecordTypeId;
            
            taskList.add(taskForNewAccountObj);
            
            insert taskList;
            
            //Insert entry in Client_Remediation__c Obect
            Client_Remediation__c crObj = new Client_Remediation__c();
            
            crObj.OLD_RG__c = 'RG1';
            crObj.NEW_RG__c = 'RG2';
            crObj.RG_ACTION__c = 'MERGE';
            crObj.OLD_RG_Account__c = oldRGAccountObj.Id;
            crObj.NEW_RG_Account__c = newRGAccountObj.Id;
            
            insert crObj;
            
            //Execute the Job for RG
            Test.startTest();
        
            Database.executeBatch(new TaskUpdatesForClientRemediationBatch('RG'), 1);
           
            Test.stopTest(); 
            
            //Test Results
            List<Task> taskListAfterUpdates = 
                [
                    SELECT Id, Subject FROM Task
                    WHERE WhatId = :newRGAccountObj.Id
                ]; 
            
            System.assertEquals(2, taskListAfterUpdates.size());
            /* Testing for RG - End */
        }
            
	}
    
    static testMethod void testTaskUpdatesRMForClientRemediation() {
        Integer numTestUsers = 1;  
        List<User> users = UtilityTesting.CreateUsersWithManager(numTestUsers);
        
        Id recordTypeForRMId = null;
        Id recordTypeForRGId = null;
         
        List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType 
                                           WHERE Name IN ('RM Account', 'RG Account')];
         
        if(recordTypeList != null && recordTypeList.size() > 0){
            for(RecordType recordTypeObj : recordTypeList){
                if('RM Account'.equalsIgnoreCase(recordTypeObj.Name)){
                    recordTypeForRMId = recordTypeObj.Id;
                }
                if('RG Account'.equalsIgnoreCase(recordTypeObj.Name)){
                    recordTypeForRGId = recordTypeObj.Id;
                }
            } 
        }
        
        system.runas(users[0]){
            
             //Insert RG Accounts
            Account accountRGObj = new Account();
            accountRGObj.Name = 'Old_Account_RG';
            accountRGObj.RDM_Org_Id__c = 'RG1';
            accountRGObj.RecordTypeId = recordTypeForRGId;
            accountRGObj.Active__c = TRUE;   
           
            insert accountRGObj;
            
            //Insert RM Accounts
            Account oldAccountObj = new Account();
            oldAccountObj.Name = 'Old_Account';
            oldAccountObj.RDM_Org_Id__c = 'RM1';
            oldAccountObj.RecordTypeId = recordTypeForRMId;
            oldAccountObj.ParentId = accountRGObj.Id;
            oldAccountObj.BillingCity = 'California';
        	oldAccountObj.BillingCountry = 'United States';
        	oldAccountObj.BillingStreet = '52nd Street';
            oldAccountObj.Active__c = TRUE;   
           
            insert oldAccountObj;
            
            Account newAccountObj = new Account();
            newAccountObj.Name = 'New_Account';
            newAccountObj.RDM_Org_Id__c = 'RM2';
            newAccountObj.RecordTypeId = recordTypeForRMId;
            newAccountObj.ParentId = accountRGObj.Id;
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
            
			insert contactForOldAccountObj;

            /* Testing for RM - Start */
            
            //Insert Task
            Id standardTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Standard Task').getRecordTypeId();
            List<Task> taskList = new List<Task>();
            
            Task taskForOldAccountObj = new Task();
            taskForOldAccountObj.OwnerId = users[0].Id;
            taskForOldAccountObj.Subject = 'Test Old';
            taskForOldAccountObj.Region__c = 'Americas';
            taskForOldAccountObj.Division__c = 'Equities';
            taskForOldAccountObj.Type = 'Other';
            taskForOldAccountObj.Priority = 'Medium';
            taskForOldAccountObj.Status = 'Open';
            taskForOldAccountObj.WhoId = contactForOldAccountObj.Id;
            taskForOldAccountObj.WhatId = accountRGObj.Id;
            taskForOldAccountObj.RecordTypeId = standardTaskRecordTypeId;
            
            taskList.add(taskForOldAccountObj);
            
            insert taskList;
            
            //Insert entry in Client_Remediation__c Obect
            Client_Remediation__c crObj = new Client_Remediation__c();
            
            crObj.OLD_RM__c = 'RM1';
            crObj.NEW_RM__c = 'RM2';
            crObj.RM_ACTION__c = 'MERGE';
            crObj.OLD_RM_Account__c = oldAccountObj.Id;
            crObj.NEW_RM_Account__c = newAccountObj.Id;
            
            insert crObj;
            
            //Execute the Job for RM
            Test.startTest();
        
            Database.executeBatch(new TaskUpdatesForClientRemediationBatch('RM'), 1);
           
            Test.stopTest(); 
            
            //Test Results
            List<Task> taskListAfterUpdates = 
                [
                    SELECT Id, Subject FROM Task
                    WHERE WhatId = :accountRGObj.Id
                ]; 
            
            System.assertEquals(1, taskListAfterUpdates.size());
            /* Testing for RM - End */
        }
            
	}


}