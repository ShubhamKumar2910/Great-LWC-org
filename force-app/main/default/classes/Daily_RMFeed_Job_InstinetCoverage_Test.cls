@isTest
public class Daily_RMFeed_Job_InstinetCoverage_Test {
	@testSetUp
    public static void testSetupForDailyRMFeedInstinetCoverage(){
    	//Insert RM and RG Accounts

        Id accountRMRecordTypeId = CommonTools.getRecordTypeId('Account','RM Account');
        Id accountRGRecordTypeId = CommonTools.getRecordTypeId('Account','RG Account');

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

        accountRGList.add(accountRGObj2);

        insert accountRGList;
        Account accountRM  = new Account();  
        accountRM.Name = 'RM_Account_Dummy_3';
        accountRM.RDM_Org_ID__c = 'RM333333';            
        accountRM.RecordTypeId = accountRMRecordTypeId;
        accountRM.BillingStreet = '52nd Street' ;
        accountRM.BillingCity = 'Los Angeles';
        accountRM.BillingPostalCode = '90001';
        accountRM.BillingCountry = 'United States';
        accountRM.Active__c = TRUE; 
        accountRM.ParentId = (accountRGList != null && accountRGList.size() > 0) ? accountRGList.get(0).Id : null;
        
        insert accountRM;
        
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
        
         Coverage_Team_Member__c coverageTeamMemberActiveRecord = new Coverage_Team_Member__c();
        coverageTeamMemberActiveRecord.UniqueId__c = 'RM333333#testtmpX#1234XX#Equity#Instinet - Cash - Asia#FALSE' ;
        coverageTeamMemberActiveRecord.RecordTypeId = activeCoverageRecordTypeId;
        coverageTeamMemberActiveRecord.Start_Date__c =Date.newInstance(2017, 1, 1);
        coverageTeamMemberActiveRecord.Is_Deleted__c = FALSE;
        coverageTeamMemberActiveRecord.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
        coverageTeamMemberActiveRecord.Account__c = accountRM.Id;
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
    
    public static void moveRM(){
        //Fetch RG Account
        Account accountRG = [SELECT Id, RDM_Org_ID__c FROM Account WHERE RDM_Org_ID__c = 'RG222222' LIMIT 1];
        
        if(accountRG != null){

           //Fetch RM Account
           List<Account> accountRMList = [SELECT Id, RDM_Org_ID__c,ParentId, Parent.RDM_Org_Id__c FROM Account WHERE RDM_Org_ID__c = 'RM333333'];
           
           //Move RM to another RG
           if(accountRMList != null && accountRMList.size() > 0){
               for(Account accountObj : accountRMList){
                   accountObj.ParentId = accountRG.Id;
               }

               update accountRMList;
           }
        }
    }
    
    @isTest
    public static void testBatch(){

        User sfadminUserObj = [SELECT Id, Login_Id__c FROM User WHERE IsActive = TRUE AND Login_Id__c = 'sfadmin' AND Profile.Name = 'Nomura - Integration' LIMIT 1];

        System.runas(sfadminUserObj){
            //Execute the Job
            Test.startTest();
            
            moveRM();
        
            Boolean hasFeedError = FALSE;
            Database.executeBatch(new Daily_RMFeed_Job_InstinetCoverage(hasFeedError),5);
           
            Test.stopTest();  

            //Check the entry in Coverage_Team_Member__c with old RG. The entry should not be present corresponding to old RG
            List<Coverage_Team_Member__c> coverageList = 
                    [SELECT Id, UniqueId__c, RG_Account__c FROM Coverage_Team_Member__c
                     WHERE RecordType.DeveloperName = 'Active_Coverage' AND RG_Account__r.RDM_Org_ID__c = 'RG111111'];


            System.assert(coverageList == null || (coverageList != null && coverageList.size() == 0));  

    
        }
    }
}