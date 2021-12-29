@isTest
public class InstinetCoverageBatchTest {
    @testSetUp
    public static void testSetupForInstinetCoverageStagingBatch(){

         //Create Configuration entries for Staging and Aggregated
        List<Configuration__c> configurationList = new List<Configuration__c>();
        Configuration__c stagingConfigurationObj = new Configuration__c();
        stagingConfigurationObj.Name = 'Instinet_Coverage_Staging';
        stagingConfigurationObj.Param_Name__c = 'LastUpdatedTimeStamp';

        configurationList.add(stagingConfigurationObj);
        
        Configuration__c aggregatedConfigurationObj = new Configuration__c();
        aggregatedConfigurationObj.Name = 'Instinet_Coverage_Aggregated';
        aggregatedConfigurationObj.Param_Name__c = 'LastUpdatedTimeStamp';

        configurationList.add(aggregatedConfigurationObj);

        insert configurationList;

        DateTime lastModifiedDate = Date.today();

        String strLastModifiedDateForStaging = lastModifiedDate.formatGMT('yyyy-MM-dd HH:mm:ss');
        if(String.isNotEmpty(strLastModifiedDateForStaging)){
            CommonTools.updateParameterValueInConfiguration('Instinet_Coverage_Staging','LastUpdatedTimeStamp', strLastModifiedDateForStaging);
        }

        String strLastModifiedDateForAggregated = lastModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        if(String.isNotEmpty(strLastModifiedDateForAggregated)){
            CommonTools.updateParameterValueInConfiguration('Instinet_Coverage_Aggregated','LastUpdatedTimeStamp', strLastModifiedDateForAggregated);
        }


        //Insert RM Account

        Id accountRMRecordTypeId = CommonTools.getRecordTypeId('Account','RM Account');

        List<Account> accountRMList = new List<Account>();

        Account accountRMObj1  = new Account();  
        accountRMObj1.Name = 'RM_Account_Dummy_1';
        accountRMObj1.RDM_Org_ID__c = 'RMXXXXXX';            
        accountRMObj1.RecordTypeId = accountRMRecordTypeId;
        accountRMObj1.BillingStreet = '52nd Street' ;
        accountRMObj1.BillingCity = 'Los Angeles';
        accountRMObj1.BillingPostalCode = '90001';
        accountRMObj1.BillingCountry = 'United States';
        accountRMObj1.Active__c = TRUE; 

        accountRMList.add(accountRMObj1);

        Account accountRMObj2  = new Account();  
        accountRMObj2.Name = 'RM_Account_Dummy_2';
        accountRMObj2.RDM_Org_ID__c = 'RMYYYYYY';            
        accountRMObj2.RecordTypeId = accountRMRecordTypeId;
        accountRMObj2.BillingStreet = '52nd Street' ;
        accountRMObj2.BillingCity = 'Los Angeles';
        accountRMObj2.BillingPostalCode = '90001';
        accountRMObj2.BillingCountry = 'United States';
        accountRMObj2.Active__c = TRUE; 

        accountRMList.add(accountRMObj2);
        
        insert accountRMList;

        //Insert Instinet_Mapping__c Records
        List<Instinet_Mapping__c> instinetMappingList = new List<Instinet_Mapping__c>();

        Instinet_Mapping__c instinetMappingObj1 = new Instinet_Mapping__c();
        instinetMappingObj1.CDB_Id__c = '1';
        instinetMappingObj1.RM_Id__c = (accountRMList.get(0) != null ? accountRMList.get(0).Id : null);

        instinetMappingList.add(instinetMappingObj1);

        Instinet_Mapping__c instinetMappingObj2 = new Instinet_Mapping__c();
        instinetMappingObj2.CDB_Id__c = '2';
        instinetMappingObj2.RM_Id__c = (accountRMList.get(1) != null ? accountRMList.get(1).Id : null);

        instinetMappingList.add(instinetMappingObj2);

        insert instinetMappingList;

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

        //Insert Instinet_Coverage_Champion_Staging__c Records

        List<Instinet_Coverage_Champion_Staging__c> instinetCoverageRecordList = new List<Instinet_Coverage_Champion_Staging__c>();

        Id instinetCoverageRecordTypeId =  CommonTools.getRecordTypeId('Instinet_Coverage_Champion_Staging__c','Instinet Coverage');

        Instinet_Coverage_Champion_Staging__c instinetCoverageStagingActiveRecord = new Instinet_Coverage_Champion_Staging__c();
        instinetCoverageStagingActiveRecord.CDB_ID__c = '1';
        instinetCoverageStagingActiveRecord.Login_ID__c = 'testtmpX';
        instinetCoverageStagingActiveRecord.Coverage_Login_ID_Detail__c = salesTeamForCoverageObj.Id;
        instinetCoverageStagingActiveRecord.Start_Date__c = Date.today();
        instinetCoverageStagingActiveRecord.Product_Region__c = 'Asia';
        instinetCoverageStagingActiveRecord.Product__c = 'Cash';
        instinetCoverageStagingActiveRecord.RecordTypeId = instinetCoverageRecordTypeId;

        instinetCoverageRecordList.add(instinetCoverageStagingActiveRecord);

        Instinet_Coverage_Champion_Staging__c instinetCoverageStagingInactiveRecord = new Instinet_Coverage_Champion_Staging__c();
        instinetCoverageStagingInactiveRecord.CDB_ID__c = '2';
        instinetCoverageStagingInactiveRecord.Login_ID__c = 'testtmpX';
        instinetCoverageStagingInactiveRecord.Coverage_Login_ID_Detail__c = salesTeamForCoverageObj.Id;
        instinetCoverageStagingInactiveRecord.Start_Date__c = Date.newInstance(2018, 1, 1);
        instinetCoverageStagingInactiveRecord.End_Date__c = Date.newInstance(2018, 12, 31);
        instinetCoverageStagingInactiveRecord.Product_Region__c = 'Asia';
        instinetCoverageStagingInactiveRecord.Product__c = 'Cash';
        instinetCoverageStagingInactiveRecord.RecordTypeId = instinetCoverageRecordTypeId;

        instinetCoverageRecordList.add(instinetCoverageStagingInactiveRecord);

        insert instinetCoverageRecordList;
        System.debug('***instinetCoverageRecordList:'+instinetCoverageRecordList);

        //Insert Coverage_Team_Member__c Records
        Id activeCoverageRecordTypeId =  CommonTools.getRecordTypeId('Coverage_Team_Member__c','Active Coverage');
        Id inactiveCoverageRecordTypeId =  CommonTools.getRecordTypeId('Coverage_Team_Member__c','Inactive Coverage');

        List<Coverage_Team_Member__c> coverageTeamMemberList = new List<Coverage_Team_Member__c>();

        Coverage_Team_Member__c coverageTeamMemberInactiveRecord = new Coverage_Team_Member__c();
        coverageTeamMemberInactiveRecord.UniqueId__c = 'RMXXXXXX#testtmpX#1234XX#Equity#Instinet - Cash - Asia#TRUE' ;
        coverageTeamMemberInactiveRecord.RecordTypeId = inactiveCoverageRecordTypeId;
        coverageTeamMemberInactiveRecord.Start_Date__c =Date.newInstance(2018, 1, 1);
        coverageTeamMemberInactiveRecord.End_Date__c = Date.newInstance(2018, 12, 31);
        coverageTeamMemberInactiveRecord.Is_Deleted__c = TRUE;
        coverageTeamMemberInactiveRecord.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
        coverageTeamMemberInactiveRecord.Account__c = accountRMList.get(0).Id;
        coverageTeamMemberInactiveRecord.Team_Role__c = 'Primary';
        coverageTeamMemberInactiveRecord.Product_Group__c = 'Equity';
        coverageTeamMemberInactiveRecord.Product_Region__c = 'Asia';
        coverageTeamMemberInactiveRecord.Product__c = 'Instinet - Cash';
        coverageTeamMemberInactiveRecord.Product2__c = 'Instinet - Cash';
        coverageTeamMemberInactiveRecord.Account_Access__c = 'Read/Write';
        coverageTeamMemberInactiveRecord.Contact_Access__c = 'Read/Write';
        coverageTeamMemberInactiveRecord.Opportunity_Access__c = 'Private';
        coverageTeamMemberInactiveRecord.Case_Access__c = 'Private';
        
        coverageTeamMemberList.add(coverageTeamMemberInactiveRecord);

        Coverage_Team_Member__c coverageTeamMemberActiveRecord = new Coverage_Team_Member__c();
        coverageTeamMemberActiveRecord.UniqueId__c = 'RMYYYYYY#testtmpX#1234XX#Equity#Instinet - Cash - Asia#FALSE' ;
        coverageTeamMemberActiveRecord.RecordTypeId = activeCoverageRecordTypeId;
        coverageTeamMemberActiveRecord.Start_Date__c =Date.newInstance(2017, 1, 1);
        coverageTeamMemberActiveRecord.Is_Deleted__c = FALSE;
        coverageTeamMemberActiveRecord.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
        coverageTeamMemberActiveRecord.Account__c = accountRMList.get(1).Id;
        coverageTeamMemberActiveRecord.Team_Role__c = 'Primary';
        coverageTeamMemberActiveRecord.Product_Group__c = 'Equity';
        coverageTeamMemberActiveRecord.Product_Region__c = 'Asia';
        coverageTeamMemberActiveRecord.Product__c = 'Instinet - Cash';
        coverageTeamMemberActiveRecord.Product2__c = 'Instinet - Cash';
        coverageTeamMemberActiveRecord.Account_Access__c = 'Read/Write';
        coverageTeamMemberActiveRecord.Contact_Access__c = 'Read/Write';
        coverageTeamMemberActiveRecord.Opportunity_Access__c = 'Private';
        coverageTeamMemberActiveRecord.Case_Access__c = 'Private';

        coverageTeamMemberList.add(coverageTeamMemberActiveRecord);

        insert coverageTeamMemberList;
            

    }

    @isTest
    public static void testBatch(){

        User sfadminUserObj = [SELECT Id, Login_Id__c FROM User WHERE IsActive = TRUE AND Login_Id__c = 'sfadmin' AND Profile.Name = 'Nomura - Integration' LIMIT 1];

        System.runas(sfadminUserObj){
            //Execute the Job
            Test.startTest();
        
            Database.executeBatch(new InstinetCoverageStagingBatchJob(),1);
           
            Test.stopTest();  

            //Check the entry in Instinet_Coverage_Champion_Aggregated__c 
            List<Instinet_Coverage_Champion_Aggregated__c> instinetCoverageAggregatedList = 
                    [SELECT Id, Unique_ID__c FROM Instinet_Coverage_Champion_Aggregated__c 
                     WHERE RecordType.DeveloperName = 'Instinet_Coverage' AND (Unique_ID__c LIKE 'RMXXXXXX#testtmpX%' OR Unique_ID__c LIKE 'RMYYYYYY#testtmpX%')];

            System.assertEquals(2, (instinetCoverageAggregatedList != null ? instinetCoverageAggregatedList.size() : 0)) ;  

            //Check the entry in Coverage_Team_Member__c
            List<Coverage_Team_Member__c> instinetCoverageList =
                [SELECT Id, UniqueId__c FROM Coverage_Team_Member__c
                 WHERE ((UniqueId__c LIKE 'RMXXXXXX#testtmpX%' AND RecordType.DeveloperName = 'Active_Coverage') OR 
                 (UniqueId__c LIKE 'RMYYYYYY#testtmpX%' AND RecordType.DeveloperName = 'Inactive_Coverage' ))];

            System.assertEquals(2, (instinetCoverageList != null ? instinetCoverageList.size() : 0)) ;             
        }
    }

    @isTest
    public static void testScheduler(){
        Test.startTest();
        
        String CRON_EXP = '0 0 0 20 1 ? 2050';
        
        String jobId = System.schedule('InstinetCoverageStagingBatchJob', CRON_EXP, new InstinetCoverageStagingBatchScheduler());
        
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