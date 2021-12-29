@isTest
public class InstinetFlagComputationBatchJobTest {
    @testSetUp
    public static void testSetupForInstinetFlagComputationBatchJob(){

        //Insert RG and RM Accounts

        Id accountRMRecordTypeId = CommonTools.getRecordTypeId('Account','RM Account');
        Id accountRGRecordTypeId = CommonTools.getRecordTypeId('Account','RG Account');

        //RG Accounts
        List<Account> accountRGList = new List<Account>();

        Account accountRGObj1  = new Account();  
        accountRGObj1.Name = 'RG_Account_Dummy_1';
        accountRGObj1.RDM_Org_ID__c = 'RG111111';            
        accountRGObj1.RecordTypeId = accountRGRecordTypeId;
        accountRGObj1.Active__c = TRUE; 

        accountRGList.add(accountRGObj1);

        Account accountRGObj2  = new Account();  
        accountRGObj2.Name = 'RG_Account_Dummy_2';
        accountRGObj2.RDM_Org_ID__c = 'RG222222';            
        accountRGObj2.RecordTypeId = accountRGRecordTypeId;
        accountRGObj2.Active__c = TRUE; 
        accountRGObj2.Instinet_Coverage__c = TRUE;

        accountRGList.add(accountRGObj2);

        Account accountRGObj3  = new Account();  
        accountRGObj3.Name = 'RG_Account_Dummy_3';
        accountRGObj3.RDM_Org_ID__c = 'RG333333';            
        accountRGObj3.RecordTypeId = accountRGRecordTypeId;
        accountRGObj3.Active__c = TRUE; 
        accountRGObj3.Instinet_Coverage__c = TRUE;

        accountRGList.add(accountRGObj3);

        insert accountRGList;

        //RM Accounts
        List<Account> accountRMList = new List<Account>();

        Account accountRMObj1  = new Account();  
        accountRMObj1.Name = 'RM_Account_Dummy_1';
        accountRMObj1.RDM_Org_ID__c = 'RM444444';            
        accountRMObj1.RecordTypeId = accountRMRecordTypeId;
        accountRMObj1.BillingStreet = '52nd Street' ;
        accountRMObj1.BillingCity = 'Los Angeles';
        accountRMObj1.BillingPostalCode = '90001';
        accountRMObj1.BillingCountry = 'United States';
        accountRMObj1.Active__c = TRUE; 
        accountRMObj1.ParentId = accountRGObj1.Id;

        accountRMList.add(accountRMObj1);

        Account accountRMObj2  = new Account();  
        accountRMObj2.Name = 'RM_Account_Dummy_2';
        accountRMObj2.RDM_Org_ID__c = 'RM555555';            
        accountRMObj2.RecordTypeId = accountRMRecordTypeId;
        accountRMObj2.BillingStreet = '52nd Street' ;
        accountRMObj2.BillingCity = 'Los Angeles';
        accountRMObj2.BillingPostalCode = '90001';
        accountRMObj2.BillingCountry = 'United States';
        accountRMObj2.Active__c = TRUE; 
        accountRMObj2.ParentId = accountRGObj1.Id;

        accountRMList.add(accountRMObj2);

        Account accountRMObj3  = new Account();  
        accountRMObj3.Name = 'RM_Account_Dummy_3';
        accountRMObj3.RDM_Org_ID__c = 'RM666666';            
        accountRMObj3.RecordTypeId = accountRMRecordTypeId;
        accountRMObj3.BillingStreet = '52nd Street';
        accountRMObj3.BillingCity = 'Los Angeles';
        accountRMObj3.BillingPostalCode = '90001';
        accountRMObj3.BillingCountry = 'United States';
        accountRMObj3.Active__c = TRUE; 
        accountRMObj3.ParentId = accountRGObj2.Id;

        accountRMList.add(accountRMObj3);
        
        insert accountRMList;

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

        //Insert Coverage_Team_Member__c Records
        Id activeCoverageRecordTypeId =  CommonTools.getRecordTypeId('Coverage_Team_Member__c','Active Coverage');
        Id inactiveCoverageRecordTypeId =  CommonTools.getRecordTypeId('Coverage_Team_Member__c','Inactive Coverage');

        List<Coverage_Team_Member__c> coverageTeamMemberList = new List<Coverage_Team_Member__c>();

        Coverage_Team_Member__c coverageTeamMemberInactiveRecord = new Coverage_Team_Member__c();
        coverageTeamMemberInactiveRecord.UniqueId__c = 'RM444444#testtmpX#1234XX#Equity#Instinet - Cash - Asia#TRUE' ;
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
        coverageTeamMemberActiveRecord.UniqueId__c = 'RM555555#testtmpX#1234XX#Equity#Instinet - Cash - Asia#FALSE' ;
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

        Coverage_Team_Member__c coverageTeamMemberActiveRecord2 = new Coverage_Team_Member__c();
        coverageTeamMemberActiveRecord2.UniqueId__c = 'RM666666#testtmpX#1234XX#Equity#Instinet - Cash - Asia#FALSE' ;
        coverageTeamMemberActiveRecord2.RecordTypeId = activeCoverageRecordTypeId;
        coverageTeamMemberActiveRecord2.Start_Date__c =Date.newInstance(2017, 1, 1);
        coverageTeamMemberActiveRecord2.Is_Deleted__c = FALSE;
        coverageTeamMemberActiveRecord2.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
        coverageTeamMemberActiveRecord2.Account__c = accountRMObj3.Id;
        coverageTeamMemberActiveRecord2.Team_Role__c = 'Primary';
        coverageTeamMemberActiveRecord2.Product_Group__c = 'Equity';
        coverageTeamMemberActiveRecord2.Product_Region__c = 'Asia';
        coverageTeamMemberActiveRecord2.Product__c = 'Instinet - Cash';
        coverageTeamMemberActiveRecord2.Product2__c = 'Instinet - Cash';
        coverageTeamMemberActiveRecord2.Account_Access__c = 'Read/Write';
        coverageTeamMemberActiveRecord2.Contact_Access__c = 'Read/Write';
        coverageTeamMemberActiveRecord2.Opportunity_Access__c = 'Private';
        coverageTeamMemberActiveRecord2.Case_Access__c = 'Private';

        coverageTeamMemberList.add(coverageTeamMemberActiveRecord2);

        insert coverageTeamMemberList;

        //Insert entry in Configuration__c Object
        CommonTools.getParameterValueFromConfiguration('ExporterJob_INSTINET_Contact','NewRGAccount', true);

    }

    @isTest
    public static void testBatch(){

        User sfadminUserObj = [SELECT Id, Login_Id__c FROM User WHERE IsActive = TRUE AND Login_Id__c = 'sfadmin' AND Profile.Name = 'Nomura - Integration' LIMIT 1];

        System.runas(sfadminUserObj){
            //Execute the Job
            Test.startTest();
        
            Database.executeBatch(new InstinetFlagComputationOnAccountBatchJob(), 100);
           
            Test.stopTest();  

            //Check the update on RG Account Object
            List<Account> accountRGList = 
                    [SELECT Id, RDM_Org_ID__C, Name, Instinet_Coverage__c FROM Account WHERE RDM_Org_ID__C = 'RG111111' AND RecordType.DeveloperName = 'RG_Account'];

            if(accountRGList != null && !accountRGList.isEmpty()){
                Account accountRGObj = accountRGList.get(0);
                System.assertEquals(true, (accountRGObj != null ? accountRGObj.Instinet_Coverage__c : false)) ;  

                //Check for value in Configuration__c Object
                String parameterValue = CommonTools.getParameterValueFromConfiguration('ExporterJob_INSTINET_Contact','NewRGAccount', false);
                System.assert(parameterValue != null && !String.isEmpty(parameterValue) && parameterValue.contains(accountRGObj.RDM_Org_ID__C));
            }

            
        }
    }

}