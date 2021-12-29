@isTest
public class ReplaceNomuraEmpWithUserBatchTest {
    
    @testSetUp
    public static void testSetupForReplaceNomuraEmpWithUserBatch(){
        
        /* Insert User Record*/
        Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        
        User userObj = new User();
        userObj.Login_ID__c = 'testdummy';
        userObj.Alias = 'testdum';
        userObj.LastName = 'TestDummyLN';
        userObj.Email = 'TestDummy@testOrg.com';
        userObj.UserName = 'TestDummy@testOrg.com';
        userObj.ProfileId = profileNomuraSales.Id;
        userObj.EmailEncodingKey = 'UTF-8';
        userObj.LanguageLocaleKey = 'en_US';
        userObj.LocaleSidKey = 'en_US';
        userObj.TimeZoneSidKey = 'America/Los_Angeles';
        userObj.Region__c = 'Americas';
        
        insert userObj;
            
        /* Insert Accounts */
        List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType WHERE Name IN ('RM Account', 'RG Account', 'Standard Event')];
        Id recordTypeIdForRM = null;
        Id recordTypeIdForRG = null;
        Id recordTypeIdForStandardEvent = null;
        
        if(recordTypeList != null && recordTypeList.size() > 0){
            for(RecordType recordTypeObj : recordTypeList){
                if('RM Account'.equalsIgnoreCase(recordTypeObj.Name)){
                    recordTypeIdForRM = recordTypeObj.Id; 
                }
                else if('RG Account'.equalsIgnoreCase(recordTypeObj.Name)){
                    recordTypeIdForRG = recordTypeObj.Id; 
                }
                else if('Standard Event'.equalsIgnoreCase(recordTypeObj.Name)){
                    recordTypeIdForStandardEvent = recordTypeObj.Id; 
                }
            }
        }
            
        List<Account> accountList = new List<Account>();
        Account accountRG  = new Account(); 
        accountRG.Name = 'RG_Account_Dummy';
        accountRG.RDM_Org_ID__c = 'RGXXXXXX';            
        accountRG.RecordTypeId = recordTypeIdForRG;
        accountRG.Active__c = TRUE;  
        
        insert accountRG;
        
        Account accountRM  = new Account();  
        accountRM.Name = 'RM_Account_Dummy';
        accountRM.RDM_Org_ID__c = 'RMXXXXXX';            
        accountRM.RecordTypeId = recordTypeIdForRM;
        accountRM.BillingStreet = '52nd Street' ;
        accountRM.BillingCity = 'Los Angeles';
        accountRM.BillingPostalCode = '90001';
        accountRM.BillingCountry = 'United States';
        accountRM.Active__c = TRUE; 
        accountRM.ParentId = accountRG.Id;
        
        accountList.add(accountRM);
        
        Account nomuraEmployeeAccount  = new Account();  
        nomuraEmployeeAccount.Name = 'Nomura Employees';
        nomuraEmployeeAccount.RDM_Org_ID__c = 'CP12345';            
        nomuraEmployeeAccount.RecordTypeId = recordTypeIdForRM;
        nomuraEmployeeAccount.BillingStreet = 'XXX' ;
        nomuraEmployeeAccount.BillingCity = 'XXX';
        nomuraEmployeeAccount.BillingPostalCode = 'XXX';
        nomuraEmployeeAccount.BillingCountry = 'United States';
        nomuraEmployeeAccount.Active__c = TRUE; 
        
        accountList.add(nomuraEmployeeAccount);
        
        insert accountList;
        
        /* Insert Contacts */
        List<Contact> contactList = new List<Contact>();
        
        Contact contactObj1 = new Contact();
        contactObj1.AccountId = accountRM.Id;
        contactObj1.FirstName = 'TestFN'; 
        contactObj1.LastName = 'TestLN';    
        contactObj1.Active__c = TRUE;
        contactObj1.Email = 'TestFN_TestLN@test.com';
        contactObj1.Phone = '+0000000000'; 
        contactObj1.Salutation = 'M.';    
        contactObj1.Mailing_Address_Same_As_Account_Address__c = TRUE;
        
        contactList.add(contactObj1);
        
        Contact contactObj2 = new Contact();
        contactObj2.AccountId = nomuraEmployeeAccount.Id;
        contactObj2.FirstName = 'TestDummyFN'; 
        contactObj2.LastName = 'TestDummyLN';    
        contactObj2.Active__c = TRUE;
        contactObj2.Login_Id__c = 'testdummy';
        contactObj2.Email = 'TestDummy@testOrg.com';
        contactObj2.Phone = '+0000000000'; 
        contactObj2.Salutation = 'M.';    
        contactObj2.Mailing_Address_Same_As_Account_Address__c = TRUE;
        
        contactList.add(contactObj2);
        
        insert contactList;
        
        /* Insert Event */
        Datetime startDateTime = Datetime.now();
        Datetime endDateTime = startDateTime.addHours(1);
        
        Event eventObj = new Event();
        eventObj.WhatId = accountRG.Id;
        eventObj.WhoId = contactObj1.Id;
        eventObj.Subject = 'Test Event';
        eventObj.StartDateTime = startDateTime;
        eventObj.EndDateTime = endDateTime;
        eventObj.RecordTypeId = recordTypeIdForStandardEvent;
        
        insert eventObj;
        
        /* Insert Event Relation for Nomura Employee Contact*/
        EventRelation eventRelationObj = new EventRelation();
        eventRelationObj.EventId = eventObj.Id;
        eventRelationObj.RelationId = contactObj2.Id;
        
        insert eventRelationObj;

        /* Insert Sales Rep Data */
        DA_CorpClient_Attendee__c salesrep = new DA_CorpClient_Attendee__c();
        salesrep.Nomura_Employee_Contact__c = contactObj2.Id;
        insert salesrep;
    }
    
    @isTest
    public static void testBatch(){
        List<Contact> contactList = new List<Contact>();
        
        Integer numTestUsers = 1;  
        List<User> users = UtilityTesting.CreateUsersWithManager(numTestUsers);
        
        System.runas(users[0]){
            //Execute the Job
            Test.startTest();
        
            Database.executeBatch(new ReplaceNomuraEmployeeWithUserBatch(), 1);
           
            Test.stopTest();  
            
            contactList = [SELECT Id, Name, Email, Account.RDM_Org_Id__c, Login_Id__c, Active__c
                                  		FROM Contact
                                  		WHERE Active__c = TRUE AND Login_Id__c IN ('testdummy')];
            
            System.assertEquals(0, contactList.size());
            
            User userObj = [SELECT Id, Name, Email, Login_Id__c, IsActive
                            FROM User
                            WHERE IsActive = TRUE AND Login_Id__c = 'testdummy' LIMIT 1];
            
            List<EventRelation> eventRelationList = [SELECT Id, EventId, RelationId, Relation.Name, IsWhat, IsParent, IsInvitee, 
                                                 	Status, Response, RespondedDate
                                                 	FROM EventRelation
                                                 	WHERE IsDeleted = FALSE AND Event.Subject = 'Test Event' 
                                                     AND Relation.Type = 'User'];
            
            if(eventRelationList != null && eventRelationList.size() > 0 && userObj != null){
                EventRelation eventRelationObj = eventRelationList.get(0);
                System.assertEquals(eventRelationObj.RelationId, userObj.Id);
            }


            List<DA_CorpClient_Attendee__c> salesrepList1 = [SELECT Id, Nomura_Employee_Contact__c, Sales_Rep__c 
                                                              FROM DA_CorpClient_Attendee__c 
                                                              WHERE Record_Type__c='Sales Rep' AND Nomura_Employee_Contact__r.Login_Id__c='testdummy'];
            List<DA_CorpClient_Attendee__c> salesrepList2 = [SELECT Id, Nomura_Employee_Contact__c, Sales_Rep__c 
                                                              FROM DA_CorpClient_Attendee__c 
                                                              WHERE Record_Type__c='Sales Rep' AND Sales_Rep__r.Login_Id__c='testdummy'];

            System.assert(salesrepList1!=null, 'list1 should not be null');
            System.assert(salesrepList2!=null, 'list2 should not be null');
            // check whether testdummy user got successfully assigned
            if(salesrepList1 != null && salesrepList2 != null && userObj != null){
                System.assertEquals(salesRepList1.size(),0);
                System.assertNotEquals(salesRepList2.size(),0);
            }

        }    
    }
    
    @isTest
    public static void testScheduler(){
        Test.startTest();
        
        String CRON_EXP = '0 0 0 20 1 ? 2050';
        
        String jobId = System.schedule('ReplaceNomuraEmpWithUserBatchX', CRON_EXP, new ReplaceNomuraEmpWithUserBatchScheduler());
        
        CronTrigger cronTriggerObj = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                                      FROM CronTrigger
                                      WHERE Id = :jobId
                                     ];
        
        System.assertEquals(CRON_EXP, cronTriggerObj.CronExpression);
        System.assertEquals(0, cronTriggerObj.TimesTriggered);
        System.assertEquals('2050-01-20 00:00:00', String.valueOf(cronTriggerObj.NextFireTime));
        
        Test.stopTest();
    }

}