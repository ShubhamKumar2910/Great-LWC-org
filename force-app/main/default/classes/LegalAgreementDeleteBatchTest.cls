@isTest
public class LegalAgreementDeleteBatchTest {

    @TestSetup
    public static void testSetup(){
       
        Account accountRG  = new Account();  
        accountRG.Name = 'RG_Account_Dummy';
        accountRG.RDM_Org_ID__c = 'RGXXXXXX';
        accountRG.BillingStreet = 'Street' ;
        accountRG.BillingCity = 'City';
        accountRG.BillingPostalCode = '200';
        accountRG.BillingCountry = 'United States';
        accountRG.Active__c = true;

        insert accountRG;
        
        Legal_Agreement__c dlObj  = new Legal_Agreement__c(); 
        dlObj.Nomura_Entity__c = 'Fundname1';
        dlObj.Agreement_Id__c = 78001;
        dlObj.Agreement_Type__c = 'Type1';
        dlObj.Fund_Id__c = 595457;
        dlObj.Fund_Name__c = 'Fundname1';
        dlObj.RG_Account__c = accountRG.Id;
        dlObj.RG_Name__c = 'RG Test Name1';
        dlObj.Is_Deleted__c = false;
        dlObj.Linked_TA__c = true;
        dlObj.Unique_Id__c = 'key1';
        Datetime yDate = Datetime.valueOf(Datetime.now().addDays(-1));
        dlObj.createdDate = yDate;
        dlObj.lastModifiedDate = yDate;

        insert dlObj;

        Legal_Agreement__c dlObj1  = new Legal_Agreement__c(); 
        dlObj1.Nomura_Entity__c = 'Fundname2';
        dlObj1.Agreement_Id__c = 78002;
        dlObj1.Agreement_Type__c = 'Type2';
        dlObj1.Fund_Id__c = 595458;
        dlObj1.Fund_Name__c = 'Fundname2';
        dlObj1.RG_Account__c = accountRG.Id;
        dlObj1.RG_Name__c = 'RG Test Name2';
        dlObj1.Is_Deleted__c = false;
        dlObj1.Linked_TA__c = true;
        dlObj1.Unique_Id__c = 'key2';

        insert dlObj1;

        Datetime startDateTime = Datetime.now();
        Datetime endDateTime = startDateTime.addHours(1);

        Configuration__c config = new Configuration__c();
        config.Name = 'Importerjob_Legal_Agreement__c';
        config.Param_Name__c = 'LastUpdatedTimeStamp';
        config.Parameter_Value__c = Datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');

        insert config;
    }
    @isTest
    public static void testBatch(){
        User integrationUserObj = [SELECT Id, Login_Id__c, Alias, LastName, Email, UserName, ProfileId 
                        		   FROM User WHERE Login_Id__c = 'sfadmin' LIMIT 1];
        System.runAs(integrationUserObj){
            test.startTest();
            Database.executeBatch(new LegalAgreementDeleteBatch(), 10);           
            Test.stopTest();  
        }        
    }

    @isTest
    public static void testScheduler(){
        Test.startTest();
        
        String CRON_EXP = '0 0 0 20 1 ? 2050';
        
        String jobId = System.schedule('LegalAgreementDeleteBatchScheduler', CRON_EXP, new LegalAgreementDeleteBatchScheduler());
        
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