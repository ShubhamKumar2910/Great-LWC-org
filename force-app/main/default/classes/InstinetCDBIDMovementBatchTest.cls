@isTest
public class InstinetCDBIDMovementBatchTest {

    @testSetUp
    public static void testSetupForInstinetCDBIDMovementBatch(){
        
        //Create Configuration entries for Staging and Aggregated
        List<Configuration__c> configurationList = new List<Configuration__c>();
        
        Configuration__c championStagingConfigurationObj = new Configuration__c();
        championStagingConfigurationObj.Name = 'Instinet_Champion_Staging';
        championStagingConfigurationObj.Param_Name__c = 'LastUpdatedTimeStamp';

        configurationList.add(championStagingConfigurationObj);
        
        Configuration__c championAggregatedConfigurationObj = new Configuration__c();
        championAggregatedConfigurationObj.Name = 'Instinet_Champion_Aggregated';
        championAggregatedConfigurationObj.Param_Name__c = 'LastUpdatedTimeStamp';

        configurationList.add(championAggregatedConfigurationObj);

        Configuration__c coverageStagingConfigurationObj = new Configuration__c();
        coverageStagingConfigurationObj.Name = 'Instinet_Coverage_Staging';
        coverageStagingConfigurationObj.Param_Name__c = 'LastUpdatedTimeStamp';

        configurationList.add(coverageStagingConfigurationObj);
        
        Configuration__c coverageAggregatedConfigurationObj = new Configuration__c();
        coverageAggregatedConfigurationObj.Name = 'Instinet_Coverage_Aggregated';
        coverageAggregatedConfigurationObj.Param_Name__c = 'LastUpdatedTimeStamp';

        configurationList.add(coverageAggregatedConfigurationObj);

        insert configurationList;

        DateTime lastModifiedDate = Date.today();

        String strLastModifiedDateForStaging = lastModifiedDate.formatGMT('yyyy-MM-dd HH:mm:ss');
        if(String.isNotEmpty(strLastModifiedDateForStaging)){
            CommonTools.updateParameterValueInConfiguration('Instinet_Champion_Staging','LastUpdatedTimeStamp', strLastModifiedDateForStaging);
            CommonTools.updateParameterValueInConfiguration('Instinet_Coverage_Staging','LastUpdatedTimeStamp', strLastModifiedDateForStaging);
        }

        String strLastModifiedDateForAggregated = lastModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        if(String.isNotEmpty(strLastModifiedDateForAggregated)){
            CommonTools.updateParameterValueInConfiguration('Instinet_Champion_Aggregated','LastUpdatedTimeStamp', strLastModifiedDateForAggregated);
            CommonTools.updateParameterValueInConfiguration('Instinet_Coverage_Aggregated','LastUpdatedTimeStamp', strLastModifiedDateForAggregated);
        }
        
        //Insert RM and RG Accounts

        Id accountRMRecordTypeId = CommonTools.getRecordTypeId('Account','RM Account');
        Id accountRGRecordTypeId = CommonTools.getRecordTypeId('Account','RG Account');

        Account accountRG  = new Account();  
        accountRG.Name = 'RG_Account_Dummy';
        accountRG.RDM_Org_ID__c = 'RG333333';            
        accountRG.RecordTypeId = accountRGRecordTypeId;
        accountRG.Active__c = TRUE; 

        insert accountRG;

        Account accountRM  = new Account();  
        accountRM.Name = 'RM_Account_Dummy_1';
        accountRM.RDM_Org_ID__c = 'RM111111';            
        accountRM.RecordTypeId = accountRMRecordTypeId;
        accountRM.BillingStreet = '52nd Street' ;
        accountRM.BillingCity = 'Los Angeles';
        accountRM.BillingPostalCode = '90001';
        accountRM.BillingCountry = 'United States';
        accountRM.Active__c = TRUE; 
        accountRM.ParentId = accountRG.Id;
        
        insert accountRM;


        //Insert Instinet_Mapping__c Records
        List<Instinet_Mapping__c> instinetMappingList = new List<Instinet_Mapping__c>();

        Instinet_Mapping__c instinetMappingObj1 = new Instinet_Mapping__c();
        instinetMappingObj1.CDB_Id__c = '1';
        instinetMappingObj1.RM_Id__c = accountRM.Id;

        instinetMappingList.add(instinetMappingObj1);

        Instinet_Mapping__c instinetMappingObj2 = new Instinet_Mapping__c();
        instinetMappingObj2.CDB_Id__c = '2';
        instinetMappingObj2.RM_Id__c = accountRM.Id;

        instinetMappingList.add(instinetMappingObj2);

        insert instinetMappingList;

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
        
        //Insert Instinet_Coverage_Champion_Staging__c Champion Records
        List<Instinet_Coverage_Champion_Staging__c> instinetChampionRecordList = new List<Instinet_Coverage_Champion_Staging__c>();

        Id instinetChampionRecordTypeId = CommonTools.getRecordTypeId('Instinet_Coverage_Champion_Staging__c','Instinet Champion');

        Instinet_Coverage_Champion_Staging__c instinetChampionStagingRecordObj1 = new Instinet_Coverage_Champion_Staging__c();
        instinetChampionStagingRecordObj1.CDB_ID__c = '1';
        instinetChampionStagingRecordObj1.Login_ID__c = 'testtmpX';
        instinetChampionStagingRecordObj1.Champion_Login_ID_Detail__c = instinetEmployeeRecord.Id;
        instinetChampionStagingRecordObj1.Start_Date__c = Date.today();
        instinetChampionStagingRecordObj1.Product_Region__c = 'Japan';
        instinetChampionStagingRecordObj1.Product__c = 'Instinet Champion';
        instinetChampionStagingRecordObj1.RecordTypeId = instinetChampionRecordTypeId;

        instinetChampionRecordList.add(instinetChampionStagingRecordObj1);

        Instinet_Coverage_Champion_Staging__c instinetChampionStagingRecordObj2 = new Instinet_Coverage_Champion_Staging__c();
        instinetChampionStagingRecordObj2.CDB_ID__c = '2';
        instinetChampionStagingRecordObj2.Login_ID__c = 'testtmpX';
        instinetChampionStagingRecordObj2.Champion_Login_ID_Detail__c = instinetEmployeeRecord.Id;
        instinetChampionStagingRecordObj2.Start_Date__c = Date.newInstance(2018, 1, 1);
        instinetChampionStagingRecordObj2.Product_Region__c = 'Japan';
        instinetChampionStagingRecordObj2.Product__c = 'Instinet Champion';
        instinetChampionStagingRecordObj2.RecordTypeId = instinetChampionRecordTypeId;

        instinetChampionRecordList.add(instinetChampionStagingRecordObj2);

        insert instinetChampionRecordList;


        //Insert Instinet_Coverage_Champion_Aggregated__c Champion Records
        
        Id instinetChampionAggregatedRecordTypeId = CommonTools.getRecordTypeId('Instinet_Coverage_Champion_Aggregated__c','Instinet Champion');

        Instinet_Coverage_Champion_Aggregated__c instinetChampionAggregatedRecordObj = new Instinet_Coverage_Champion_Aggregated__c();
        instinetChampionAggregatedRecordObj.Champion_Login_ID_Detail__c = instinetEmployeeRecord.Id;
        instinetChampionAggregatedRecordObj.Account__c = accountRM.Id;
        instinetChampionAggregatedRecordObj.Product_Region__c = 'Japan';
        instinetChampionAggregatedRecordObj.Product__c = 'Instinet Champion';
        instinetChampionAggregatedRecordObj.RecordTypeId = instinetChampionAggregatedRecordTypeId;
        instinetChampionAggregatedRecordObj.Active__c = true;
        instinetChampionAggregatedRecordObj.Start_Date__c = Date.newInstance(2018, 1, 1);
        String uniqueIdPart = accountRM.RDM_Org_ID__c + '#' + instinetEmployeeRecord.Login_Id__c + '#' + 'Japan';
        instinetChampionAggregatedRecordObj.Subset_Unique_ID__c = uniqueIdPart;
        instinetChampionAggregatedRecordObj.Unique_ID__c = uniqueIdPart + '#2018-01-01 00:00:00#null';

        insert instinetChampionAggregatedRecordObj;
        
        //Insert User
        Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];

        User userObj = new User();
        userObj.Login_ID__c = 'testtmpX';
        userObj.Alias = 'testtmpX';
        userObj.LastName = 'TestTemp_LN';
        userObj.FirstName = 'TestTemp_FN';
        userObj.Email = 'TestTempX@testOrg.com';
        userObj.UserName = 'TestTempX@testOrg.com';
        userObj.ProfileId = profileNomuraSales.Id;
        userObj.EmailEncodingKey = 'UTF-8';
        userObj.LanguageLocaleKey = 'en_US';
        userObj.LocaleSidKey = 'en_US';
        userObj.TimeZoneSidKey = 'America/Los_Angeles';
        userObj.Region__c = 'Americas';

        insert userObj;

        //Insert Sales_Team_for_Coverage__c
        Sales_Team_for_Coverage__c salesTeamForCoverageObj = new Sales_Team_for_Coverage__c();
        salesTeamForCoverageObj.Name = 'TestTemp_FN TestTemp_LN';
        salesTeamForCoverageObj.Coverage_ID__c = '1234XX';
        salesTeamForCoverageObj.Sales_Team__c = 'Test Team';
        salesTeamForCoverageObj.Sales_Desk_Region__c = 'USA';
        salesTeamForCoverageObj.Sales_Desk_Division__c = 'Fixed Income';
        salesTeamForCoverageObj.Sales_Code_Login_ID__c = userObj.Login_Id__c;
        salesTeamForCoverageObj.Active__c = TRUE;
        salesTeamForCoverageObj.Company__c = 'I';
        
        insert salesTeamForCoverageObj;
        
        //Insert Sales_Team_User__c
        Sales_Team_User__c salesTeamUserObj = new Sales_Team_User__c();
        salesTeamUserObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
        salesTeamUserObj.User__c = userObj.Id;
        salesTeamUserObj.Source_Id__c = salesTeamForCoverageObj.Coverage_ID__c + '#' + userObj.Login_Id__c;
        
        insert salesTeamUserObj;

        //Insert Instinet_Coverage_Champion_Staging__c Coverage Records

        List<Instinet_Coverage_Champion_Staging__c> instinetCoverageRecordList = new List<Instinet_Coverage_Champion_Staging__c>();

        Id instinetCoverageRecordTypeId =  CommonTools.getRecordTypeId('Instinet_Coverage_Champion_Staging__c','Instinet Coverage');

        Instinet_Coverage_Champion_Staging__c instinetCoverageStagingRecordObj1 = new Instinet_Coverage_Champion_Staging__c();
        instinetCoverageStagingRecordObj1.CDB_ID__c = '1';
        instinetCoverageStagingRecordObj1.Login_ID__c = 'testtmpX';
        instinetCoverageStagingRecordObj1.Coverage_Login_ID_Detail__c = salesTeamForCoverageObj.Id;
        instinetCoverageStagingRecordObj1.Start_Date__c = Date.today();
        instinetCoverageStagingRecordObj1.Product_Region__c = 'Asia';
        instinetCoverageStagingRecordObj1.Product__c = 'Cash';
        instinetCoverageStagingRecordObj1.RecordTypeId = instinetCoverageRecordTypeId;

        instinetCoverageRecordList.add(instinetCoverageStagingRecordObj1);

        Instinet_Coverage_Champion_Staging__c instinetCoverageStagingRecordObj2 = new Instinet_Coverage_Champion_Staging__c();
        instinetCoverageStagingRecordObj2.CDB_ID__c = '2';
        instinetCoverageStagingRecordObj2.Login_ID__c = 'testtmpX';
        instinetCoverageStagingRecordObj2.Coverage_Login_ID_Detail__c = salesTeamForCoverageObj.Id;
        instinetCoverageStagingRecordObj2.Start_Date__c = Date.newInstance(2018, 1, 1);
        instinetCoverageStagingRecordObj2.Product_Region__c = 'Asia';
        instinetCoverageStagingRecordObj2.Product__c = 'Cash';
        instinetCoverageStagingRecordObj2.RecordTypeId = instinetCoverageRecordTypeId;

        instinetCoverageRecordList.add(instinetCoverageStagingRecordObj2);

        insert instinetCoverageRecordList;
        
        //Insert Instinet_Coverage_Champion_Aggregated__c Coverage Records
        
        Id instinetCoverageAggregatedRecordTypeId = CommonTools.getRecordTypeId('Instinet_Coverage_Champion_Aggregated__c','Instinet Coverage');

        Instinet_Coverage_Champion_Aggregated__c instinetCoverageAggregatedRecordObj = new Instinet_Coverage_Champion_Aggregated__c();
        instinetCoverageAggregatedRecordObj.Coverage_Login_ID_Detail__c = salesTeamForCoverageObj.Id;
        instinetCoverageAggregatedRecordObj.Account__c = accountRM.Id;
        instinetCoverageAggregatedRecordObj.Product_Region__c = 'Asia';
        instinetCoverageAggregatedRecordObj.Product__c = 'Instinet - Cash';
        instinetCoverageAggregatedRecordObj.RecordTypeId = instinetCoverageAggregatedRecordTypeId;
        instinetCoverageAggregatedRecordObj.Active__c = true;
        instinetCoverageAggregatedRecordObj.Start_Date__c = Date.newInstance(2018, 1, 1);
        String uniqueIdPartForCoverage = accountRM.RDM_Org_ID__c + '#' + salesTeamForCoverageObj.Sales_Code_Login_ID__c + '#Asia#Instinet - Cash';
        instinetCoverageAggregatedRecordObj.Subset_Unique_ID__c = uniqueIdPartForCoverage;
        instinetCoverageAggregatedRecordObj.Unique_ID__c = uniqueIdPartForCoverage + '#2018-01-01 00:00:00#null';
        
        

        insert instinetCoverageAggregatedRecordObj;

    }

    public static void moveCDBID(){
        //Fetch RG Account
        Account accountRG = [SELECT Id, RDM_Org_ID__c FROM Account WHERE RDM_Org_ID__c = 'RG333333' LIMIT 1];
        
        if(accountRG != null){

            Id accountRMRecordTypeId = CommonTools.getRecordTypeId('Account','RM Account');

            //Insert RM Account
            
            Account accountRM  = new Account();  
            accountRM.Name = 'RM_Account_Dummy_1';
            accountRM.RDM_Org_ID__c = 'RM222222';            
            accountRM.RecordTypeId = accountRMRecordTypeId;
            accountRM.BillingStreet = '52nd Street' ;
            accountRM.BillingCity = 'Los Angeles';
            accountRM.BillingPostalCode = '90001';
            accountRM.BillingCountry = 'United States';
            accountRM.Active__c = TRUE; 
            accountRM.ParentId = accountRG.Id;
            
            insert accountRM;


            //Fetch Instinet_Mapping__c 
            List<Instinet_Mapping__c> instinetMappingList = [SELECT Id, CDB_Id__c, RM_Id__c FROM Instinet_Mapping__c WHERE CDB_Id__c = '1'];

           //Move CDB_Id__c to another RM
           if(instinetMappingList != null && instinetMappingList.size() > 0){
               for(Instinet_Mapping__c instinetMappingObj : instinetMappingList){
                   instinetMappingObj.RM_Id__c = accountRM.Id;
               }

               update instinetMappingList;
           }
        }
    }


    @isTest
    public static void testBatch(){

        User sfadminUserObj = [SELECT Id, Login_Id__c FROM User WHERE IsActive = TRUE AND Login_Id__c = 'sfadmin' AND Profile.Name = 'Nomura - Integration' LIMIT 1];

        System.runas(sfadminUserObj){
            //Execute the Job
            Test.startTest();
            
            moveCDBID();
        
            Database.executeBatch(new InstinetCDBIDMovementBatchJob('Champion'),1);
           
            Test.stopTest();  

            //Check the entry in Instinet_Mapping__c
            List<Instinet_Mapping__c> instinetMappingList = 
                    [SELECT Id, CDB_Id__c, Previous_RM__c, RM_Id__c FROM Instinet_Mapping__c 
                     WHERE CDB_Id__c = '1'];

            if(instinetMappingList != null && instinetMappingList.size() > 0){
                Instinet_Mapping__c instinetMappingRecord = instinetMappingList.get(0);
                System.assert(instinetMappingRecord.Previous_RM__c == null || String.isEmpty(instinetMappingRecord.Previous_RM__c)) ;  
            }
            

        }
    }

    @isTest
    public static void testScheduler(){
        Test.startTest();
        
        String CRON_EXP = '0 0 0 20 1 ? 2050';

        moveCDBID();
        
        String jobId = System.schedule('InstinetCDBIDMovementBatchJob', CRON_EXP, new InstinetCDBIDMovementBatchScheduler());
        
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