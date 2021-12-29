@isTest
public class EventUpdatesCRTest {
    
    static testMethod void testEventUpdatesRGForClientRemediation() {
        User userObj = [SELECT Id, Name, Login_Id__c FROM User WHERE Login_Id__c = 'sfadmin' 
                        and Profile.Name = 'Nomura - Integration' AND IsActive = TRUE LIMIT 1];
        
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
        
        system.runAs(userObj){
            
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
            contactForOldAccountObj.Active__c = TRUE;
            
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
            contactForNewAccountObj.Active__c = TRUE;
            
			insert contactForNewAccountObj;
            
            /* Testing for RG - Start */
            
            //Insert Event
            Id standardEventRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Standard Event').getRecordTypeId();
            Datetime startDateTime = Datetime.now();
        	Datetime endDateTime = startDateTime.addHours(1);
            List<Event> eventList = new List<Event>();
            
            Event eventForOldAccountObj = new Event();
            eventForOldAccountObj.OwnerId = userObj.Id;
            eventForOldAccountObj.Subject = 'Test Old Event';
            eventForOldAccountObj.WhoId = contactForOldAccountObj.Id;
            eventForOldAccountObj.WhatId = oldRGAccountObj.Id;
            eventForOldAccountObj.StartDateTime = startDateTime;
            eventForOldAccountObj.EndDateTime = endDateTime;
            eventForOldAccountObj.RecordTypeId = standardEventRecordTypeId;
            
            eventList.add(eventForOldAccountObj);
            
            Event eventForNewAccountObj = new Event();
            eventForNewAccountObj.OwnerId = userObj.Id;
            eventForNewAccountObj.Subject = 'Test New Event';
            eventForNewAccountObj.WhoId = contactForNewAccountObj.Id;
            eventForNewAccountObj.WhatId = newRGAccountObj.Id;
            eventForNewAccountObj.StartDateTime = startDateTime;
            eventForNewAccountObj.EndDateTime = endDateTime;
            eventForNewAccountObj.RecordTypeId = standardEventRecordTypeId;
            
            eventList.add(eventForNewAccountObj);
            
            insert eventList;
            
            
            
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
        
            Database.executeBatch(new EventUpdatesForClientRemediationBatch('RG'), 1);
           
            Test.stopTest(); 
            
            //Test Results
            List<Event> eventListAfterUpdates = 
                [
                    SELECT Id, Subject FROM Event
                    WHERE WhatId = :newRGAccountObj.Id
                ]; 
            
            System.assertEquals(2, eventListAfterUpdates.size());
            /* Testing for RG - End */
        }
            
	}
    
    static testMethod void testEventUpdatesRMForClientRemediation() {
        User userObj = [SELECT Id, Name, Login_Id__c FROM User WHERE Login_Id__c = 'sfadmin' 
                        and Profile.Name = 'Nomura - Integration' AND IsActive = TRUE LIMIT 1];
        
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
        
        system.runas(userObj){
            
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
            contactForOldAccountObj.Active__c = TRUE;
            
			insert contactForOldAccountObj;

            //Testing for RM - Start
            
            //Insert Event
            Id standardEventRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Standard Event').getRecordTypeId();
            Datetime startDateTime = Datetime.now();
        	Datetime endDateTime = startDateTime.addHours(1);
            List<Event> eventList = new List<Event>();
            
            Event eventForOldAccountObj = new Event();
            eventForOldAccountObj.OwnerId = userObj.Id;
            eventForOldAccountObj.Subject = 'Test Old';
            eventForOldAccountObj.WhoId = contactForOldAccountObj.Id;
            eventForOldAccountObj.WhatId = accountRGObj.Id;
            eventForOldAccountObj.StartDateTime = startDateTime;
            eventForOldAccountObj.EndDateTime = endDateTime;
            eventForOldAccountObj.RecordTypeId = standardEventRecordTypeId;
            
            eventList.add(eventForOldAccountObj);
            
            insert eventList;
            
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
        
            Database.executeBatch(new EventUpdatesForClientRemediationBatch('RM'), 1);
           
            Test.stopTest(); 
            
            //Test Results
            List<Event> eventListAfterUpdates = 
                [
                    SELECT Id, Subject FROM Event
                    WHERE WhatId = :accountRGObj.Id
                ]; 
            
            System.assertEquals(1, eventListAfterUpdates.size());
            //Testing for RM - End
        }
            
	}

}