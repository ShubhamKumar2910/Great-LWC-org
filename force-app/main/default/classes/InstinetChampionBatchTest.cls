@isTest
public class InstinetChampionBatchTest {
    @testSetUp
    public static void testSetupForInstinetChampionBatch(){

        //Create Configuration entries for Staging and Aggregated
        List<Configuration__c> configurationList = new List<Configuration__c>();
        Configuration__c stagingConfigurationObj = new Configuration__c();
        stagingConfigurationObj.Name = 'Instinet_Champion_Staging';
        stagingConfigurationObj.Param_Name__c = 'LastUpdatedTimeStamp';

        configurationList.add(stagingConfigurationObj);
        
        Configuration__c aggregatedConfigurationObj = new Configuration__c();
        aggregatedConfigurationObj.Name = 'Instinet_Champion_Aggregated';
        aggregatedConfigurationObj.Param_Name__c = 'LastUpdatedTimeStamp';

        configurationList.add(aggregatedConfigurationObj);

        insert configurationList;

        DateTime lastModifiedDate = Date.today();

        String strLastModifiedDateForStaging = lastModifiedDate.formatGMT('yyyy-MM-dd HH:mm:ss');
        if(String.isNotEmpty(strLastModifiedDateForStaging)){
            CommonTools.updateParameterValueInConfiguration('Instinet_Champion_Staging','LastUpdatedTimeStamp', strLastModifiedDateForStaging);
        }

        String strLastModifiedDateForAggregated = lastModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        if(String.isNotEmpty(strLastModifiedDateForAggregated)){
            CommonTools.updateParameterValueInConfiguration('Instinet_Champion_Aggregated','LastUpdatedTimeStamp', strLastModifiedDateForAggregated);
        }

        //Insert RM and RG Account

        Id accountRMRecordTypeId = CommonTools.getRecordTypeId('Account','RM Account');
        Id accountRGRecordTypeId = CommonTools.getRecordTypeId('Account','RG Account');

        Account accountRG  = new Account();  
        accountRG.Name = 'RG_Account_Dummy';
        accountRG.RDM_Org_ID__c = 'RGYYYYYY';            
        accountRG.RecordTypeId = accountRGRecordTypeId;
        accountRG.Active__c = TRUE; 

        insert accountRG;

        Account accountRM  = new Account();  
        accountRM.Name = 'RM_Account_Dummy';
        accountRM.RDM_Org_ID__c = 'RMXXXXXX';            
        accountRM.RecordTypeId = accountRMRecordTypeId;
        accountRM.BillingStreet = '52nd Street' ;
        accountRM.BillingCity = 'Los Angeles';
        accountRM.BillingPostalCode = '90001';
        accountRM.BillingCountry = 'United States';
        accountRM.Active__c = TRUE; 
        accountRM.ParentId = accountRG.Id;
        
        insert accountRM;

        //Insert Instinet_Mapping__c

        Instinet_Mapping__c instinetMapping = new Instinet_Mapping__c();
        instinetMapping.CDB_Id__c = '1';
        instinetMapping.RM_Id__c = accountRM.Id;

        insert instinetMapping;

        //Insert Instinet Employees Account IN12345

        Id nomuraEmployeesRecordTypeId = CommonTools.getRecordTypeId('Account','NOMURA EMPLOYEES');

        Account instinetEmployeesAccount  = new Account();  
        instinetEmployeesAccount.Name = 'INSTINET EMPLOYEES';
        instinetEmployeesAccount.RDM_Org_ID__c = 'IN12345';            
        instinetEmployeesAccount.RecordTypeId = nomuraEmployeesRecordTypeId;
        instinetEmployeesAccount.Active__c = TRUE; 
        
        insert instinetEmployeesAccount;

        //Insert Instinet Employee Contact
        Contact instinetEmployeeRecord = new Contact();
        instinetEmployeeRecord.Salutation = 'M.';
        instinetEmployeeRecord.FirstName = 'Instinet_Emp_FN';
        instinetEmployeeRecord.LastName = 'Instinet_Emp_LN';
        instinetEmployeeRecord.Email = 'instinet_emp@test.comx';
        instinetEmployeeRecord.AccountId = instinetEmployeesAccount.Id;
        instinetEmployeeRecord.Active__c = TRUE;
        instinetEmployeeRecord.Login_Id__c = 'testtmpX';

        insert instinetEmployeeRecord;
        
        //Insert Instinet_Coverage_Champion_Staging__c Records
        List<Instinet_Coverage_Champion_Staging__c> instinetChampionRecordList = new List<Instinet_Coverage_Champion_Staging__c>();

        Id instinetChampionRecordTypeId = CommonTools.getRecordTypeId('Instinet_Coverage_Champion_Staging__c','Instinet Champion');

        Instinet_Coverage_Champion_Staging__c instinetChampionStagingActiveRecord = new Instinet_Coverage_Champion_Staging__c();
        instinetChampionStagingActiveRecord.CDB_ID__c = '1';
        instinetChampionStagingActiveRecord.Instinet_CDB_ID__c = instinetMapping.Id;
        instinetChampionStagingActiveRecord.Login_ID__c = 'testtmpX';
        instinetChampionStagingActiveRecord.Champion_Login_ID_Detail__c = instinetEmployeeRecord.Id;
        instinetChampionStagingActiveRecord.Start_Date__c = Date.today();
        instinetChampionStagingActiveRecord.Product_Region__c = 'Japan';
        instinetChampionStagingActiveRecord.Product__c = 'Instinet Champion';
        instinetChampionStagingActiveRecord.RecordTypeId = instinetChampionRecordTypeId;

        instinetChampionRecordList.add(instinetChampionStagingActiveRecord);

        Instinet_Coverage_Champion_Staging__c instinetChampionStagingInactiveRecord = new Instinet_Coverage_Champion_Staging__c();
        instinetChampionStagingInactiveRecord.CDB_ID__c = '1';
        instinetChampionStagingInactiveRecord.Instinet_CDB_ID__c = instinetMapping.Id;
        instinetChampionStagingInactiveRecord.Login_ID__c = 'testtmpX';
        instinetChampionStagingInactiveRecord.Champion_Login_ID_Detail__c = instinetEmployeeRecord.Id;
        instinetChampionStagingInactiveRecord.Start_Date__c = Date.newInstance(2018, 1, 1);
        instinetChampionStagingInactiveRecord.End_Date__c = Date.today();
        instinetChampionStagingInactiveRecord.Product_Region__c = 'USA';
        instinetChampionStagingInactiveRecord.Product__c = 'Instinet Champion';
        instinetChampionStagingInactiveRecord.RecordTypeId = instinetChampionRecordTypeId;

        instinetChampionRecordList.add(instinetChampionStagingInactiveRecord);

        insert instinetChampionRecordList;
            

    }

    @isTest
    public static void testBatch(){

        User sfadminUserObj = [SELECT Id, Login_Id__c FROM User WHERE IsActive = TRUE AND Login_Id__c = 'sfadmin' AND Profile.Name = 'Nomura - Integration' LIMIT 1];

        System.runas(sfadminUserObj){
            //Execute the Job
            Test.startTest();
        
            Database.executeBatch(new InstinetChampionStagingBatchJob(),200);
           
            Test.stopTest();  

            //Check the entry in Instinet_Coverage_Champion_Aggregated__c 
            List<Instinet_Coverage_Champion_Aggregated__c> instinetChampionAggregatedList = 
                    [SELECT Id, Unique_ID__c FROM Instinet_Coverage_Champion_Aggregated__c 
                     WHERE RecordType.DeveloperName = 'Instinet_Champion' AND Unique_ID__c LIKE 'RMXXXXXX#testtmpX%'];

            System.assertEquals(2, (instinetChampionAggregatedList != null ? instinetChampionAggregatedList.size() : 0)) ;     

            //Check the entry in Sales_Champion__c
            List<Sales_Champion__c> instinetChampionList = 
                [SELECT Id FROM Sales_Champion__c
                 WHERE RecordType.DeveloperName = 'Instinet_Champion'] ;
                 
             System.assertEquals(1, (instinetChampionList != null ? instinetChampionList.size() : 0)) ;        
        }
    }

    @isTest
    public static void testScheduler(){
        Test.startTest();
        
        String CRON_EXP = '0 0 0 20 1 ? 2050';
        
        String jobId = System.schedule('InstinetChampionStagingBatchJob', CRON_EXP, new InstinetChampionStagingBatchScheduler());
        
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