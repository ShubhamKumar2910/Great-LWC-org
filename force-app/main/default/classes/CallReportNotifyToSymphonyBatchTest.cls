@isTest
public class CallReportNotifyToSymphonyBatchTest {

    @TestSetup
    public static void testSetup(){
        Id RGRecordTypeId = CommonTools.getRecordTypeId('Account', 'RG Account');
        Id RMRecordTypeId = CommonTools.getRecordTypeId('Account', 'RM Account');
        Id StdEventRecordTypeId = CommonTools.getRecordTypeId('Event', 'Standard Event');

        Account accountRG  = new Account(); 
        accountRG.Name = 'RG_Account_Dummy';
        accountRG.RDM_Org_ID__c = 'RGXXXXXX';            
        accountRG.RecordTypeId = RGRecordTypeId;
        accountRG.Active__c = TRUE;
        accountRG.Symphony_Room_Id__c = '0UjLldk1Qj/18dYG2b1+O0H///o54eljCdA==';  
        
        insert accountRG;

        Account accountRM  = new Account();  
        accountRM.Name = 'RM_Account_Dummy';
        accountRM.RDM_Org_ID__c = 'RMXXXXXX';
        accountRM.RecordTypeId = RMRecordTypeId;
        accountRM.BillingStreet = 'XXX' ;
        accountRM.BillingCity = 'XXX';
        accountRM.BillingPostalCode = 'XXX';
        accountRM.BillingCountry = 'United States';
        accountRM.Active__c = TRUE; 
        accountRM.ParentId = accountRG.Id;

        insert accountRM;

        Contact contactObj = new Contact();
        contactObj.AccountId = accountRM.Id;
        contactObj.FirstName = 'TestFN'; 
        contactObj.LastName = 'TestLN';    
        contactObj.Active__c = TRUE;
        contactObj.Email = 'TestFN_TestLN@test.com';
        contactObj.Phone = '+0000000000'; 
        contactObj.Salutation = 'M.';
        
        insert contactObj;

        Datetime startDateTime = Datetime.now();
        Datetime endDateTime = startDateTime.addHours(1);

        Event eventObj = new Event();
        eventObj.WhatId = accountRG.Id;
        eventObj.WhoId = contactObj.Id;
        eventObj.Subject = 'Test Event';
        eventObj.StartDateTime = startDateTime;
        eventObj.EndDateTime = endDateTime;
        eventObj.RecordTypeId = StdEventRecordTypeId;
        eventObj.Type = 'Broker Review';
        eventObj.L0_Type__c = 'Broker Review';
        eventObj.CreatedDate = Datetime.now().addHours(-3);
        
        insert eventObj;

        Configuration__c config = new Configuration__c();
        config.Name = 'Call_Report_Notification_To_Symphony';
        config.Param_Name__c = 'LastUpdatedTimeStamp';
        config.Parameter_Value__c = Datetime.now().addDays(-1).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');

        insert config;
    }
    @isTest
    public static void testBatch(){
        User integrationUserObj = [SELECT Id, Login_Id__c, Alias, LastName, Email, UserName, ProfileId 
                        		   FROM User WHERE Login_Id__c = 'sfadmin' LIMIT 1];
        System.runAs(integrationUserObj){
            test.startTest();
            Database.executeBatch(new CallReportNotifyToSymphonyBatch(), 1);           
            Test.stopTest();  
        }        
    }

    @isTest
    public static void testScheduler(){
        Test.startTest();
        
        String CRON_EXP = '0 0 0 20 1 ? 2050';
        
        String jobId = System.schedule('CallReportNotifyToSymphonyBatch', CRON_EXP, new CallReportNotifyToSymphonyBatchScheduler());
        
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