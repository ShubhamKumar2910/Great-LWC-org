@isTest
public class NomuraContactDependentDataBatchTest {

    @TestSetup
    public static void testSetup(){
        User integrationUserObj = [SELECT Id, Login_Id__c, Alias, LastName, Email, UserName, ProfileId 
                                    FROM User WHERE Login_Id__c = 'sfadmin' LIMIT 1];
        System.runAs(integrationUserObj){

            Id RGRecordTypeId = CommonTools.getRecordTypeId('Account', 'RG Account');
            Id RMRecordTypeId = CommonTools.getRecordTypeId('Account', 'RM Account');
            Id instinetChampionRecordTypeId = CommonTools.getRecordTypeId('Sales_Champion__c','Instinet Champion');

            Account accountRG1  = new Account(); 
            accountRG1.Name = 'RG_Account_Dummy';
            accountRG1.RDM_Org_ID__c = 'RGXXXXXX';            
            accountRG1.RecordTypeId = RGRecordTypeId;
            accountRG1.Active__c = True;
            insert accountRG1;

            Account accountRG2  = new Account(); 
            accountRG2.Name = 'RG_Account_Dummy';
            accountRG2.RDM_Org_ID__c = 'RGXXXXXY';            
            accountRG2.RecordTypeId = RGRecordTypeId;
            accountRG2.Active__c = True;        
            insert accountRG2;

            Account accountRM  = new Account();  
            accountRM.Name = 'RM_InstinetAccount_Dummy';
            accountRM.RDM_Org_ID__c = 'IN12345';
            accountRM.RecordTypeId = RMRecordTypeId;
            accountRM.BillingStreet = 'XXX' ;
            accountRM.BillingCity = 'XXX';
            accountRM.BillingPostalCode = 'XXX';
            accountRM.BillingCountry = 'United States';
            accountRM.Active__c = TRUE; 
            accountRM.ParentId = accountRG1.Id;
            insert accountRM;

            Contact contactObj = new Contact();
            contactObj.AccountId = accountRM.Id;
            contactObj.FirstName = 'TestFN';
            contactObj.LastName = 'TestLN';
            contactObj.Active__c = False;
            contactObj.Inactive_Reason__c = 'Other';
            contactObj.Other_Inactive_Reason__c = 'Other';
            contactObj.Email = 'TestFN_TestLN@test.com';
            contactObj.Phone = '+0000000000'; 
            contactObj.Salutation = 'M.';        
            insert contactObj;

            Sales_Champion__c salesChampionObj = new Sales_Champion__c();
            salesChampionObj.Account__c = accountRG2.Id;
            salesChampionObj.Instinet_Champion__c = contactObj.Id;
            salesChampionObj.Region__c = 'Japan';
            salesChampionObj.Champion_Type__c = 'EQ - Execution Champion';
            salesChampionObj.RecordTypeId = instinetChampionRecordTypeId;
            insert salesChampionObj;
        }
    }

    static testMethod void testBatch(){
        User integrationUserObj = [SELECT Id, Login_Id__c, Alias, LastName, Email, UserName, ProfileId 
                        		   FROM User WHERE Login_Id__c = 'sfadmin' LIMIT 1];
        System.runAs(integrationUserObj){
            test.startTest();
            Database.executeBatch(new NomuraContactDependentDataBatchJob(), 1);           
            Test.stopTest();  
        }
        List<Sales_Champion__c> result = [SELECT Id FROM Sales_Champion__c];
        /* Deleted records assertion */
        System.assertEquals(0, result.size());
    }

    static testMethod void testScheduler(){
        Test.startTest();
        
        String CRON_EXP = '0 0 0 20 1 ? 2050';
        
        String jobId = System.schedule('NomuraContactDependentDataBatchJob', CRON_EXP, new NomuraContactDependentDataBatchScheduler());
        
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