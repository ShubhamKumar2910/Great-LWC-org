@isTest
public class Daily_RMFeed_Job_InstinetChampion_Test {
    @testSetUp
    public static void testSetupForDailyRMFeedInstinetChampion(){
        
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

        List<Account> accountRMList = new List<Account>();

        Account accountRMObj1  = new Account();  
        accountRMObj1.Name = 'RM_Account_Dummy_3';
        accountRMObj1.RDM_Org_ID__c = 'RM333333';            
        accountRMObj1.RecordTypeId = accountRMRecordTypeId;
        accountRMObj1.BillingStreet = '52nd Street' ;
        accountRMObj1.BillingCity = 'Los Angeles';
        accountRMObj1.BillingPostalCode = '90001';
        accountRMObj1.BillingCountry = 'United States';
        accountRMObj1.Active__c = TRUE; 
        accountRMObj1.ParentId = (accountRGList != null && accountRGList.size() > 0) ? accountRGList.get(0).Id : null;

        accountRMList.add(accountRMObj1);

        Account accountRMObj2  = new Account();  
        accountRMObj2.Name = 'RM_Account_Dummy_4';
        accountRMObj2.RDM_Org_ID__c = 'RM444444';            
        accountRMObj2.RecordTypeId = accountRMRecordTypeId;
        accountRMObj2.BillingStreet = '52nd Street' ;
        accountRMObj2.BillingCity = 'Los Angeles';
        accountRMObj2.BillingPostalCode = '90001';
        accountRMObj2.BillingCountry = 'United States';
        accountRMObj2.Active__c = TRUE; 
        accountRMObj2.ParentId = (accountRGList != null && accountRGList.size() > 0) ? accountRGList.get(0).Id : null;

        accountRMList.add(accountRMObj2);
        
        insert accountRMList;

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

        //Insert Instinet_Coverage_Champion_Aggregated__c Champion Records
        List<Instinet_Coverage_Champion_Aggregated__c> instinetChampionAggregatedList = new List<Instinet_Coverage_Champion_Aggregated__c>();
        
        Id instinetChampionAggregatedRecordTypeId = CommonTools.getRecordTypeId('Instinet_Coverage_Champion_Aggregated__c','Instinet Champion');

        Account championAccountRMObj1 = (accountRMList != null && accountRMList.size() > 0) ? accountRMList.get(0) : null;
        Account championAccountRMObj2 = (accountRMList != null && accountRMList.size() > 0) ? accountRMList.get(1) : null;

        Instinet_Coverage_Champion_Aggregated__c instinetChampionAggregatedRecordObj1 = new Instinet_Coverage_Champion_Aggregated__c();
        instinetChampionAggregatedRecordObj1.Champion_Login_ID_Detail__c = instinetEmployeeRecord.Id;
        instinetChampionAggregatedRecordObj1.Account__c = championAccountRMObj1.Id;
        instinetChampionAggregatedRecordObj1.Product_Region__c = 'Japan';
        instinetChampionAggregatedRecordObj1.Product__c = 'Instinet Champion';
        instinetChampionAggregatedRecordObj1.RecordTypeId = instinetChampionAggregatedRecordTypeId;
        instinetChampionAggregatedRecordObj1.Active__c = true;
        instinetChampionAggregatedRecordObj1.Start_Date__c = Date.newInstance(2018, 1, 1);
        String uniqueIdPartForObj1 = championAccountRMObj1.RDM_Org_ID__c + '#' + instinetEmployeeRecord.Login_Id__c + '#' + 'Japan';
        instinetChampionAggregatedRecordObj1.Subset_Unique_ID__c = uniqueIdPartForObj1;
        instinetChampionAggregatedRecordObj1.Unique_ID__c = uniqueIdPartForObj1 + '#2018-01-01 00:00:00#null';

        instinetChampionAggregatedList.add(instinetChampionAggregatedRecordObj1);

        Instinet_Coverage_Champion_Aggregated__c instinetChampionAggregatedRecordObj2 = new Instinet_Coverage_Champion_Aggregated__c();
        instinetChampionAggregatedRecordObj2.Champion_Login_ID_Detail__c = instinetEmployeeRecord.Id;
        instinetChampionAggregatedRecordObj2.Account__c = championAccountRMObj2.Id;
        instinetChampionAggregatedRecordObj2.Product_Region__c = 'USA';
        instinetChampionAggregatedRecordObj2.Product__c = 'Instinet Champion';
        instinetChampionAggregatedRecordObj2.RecordTypeId = instinetChampionAggregatedRecordTypeId;
        instinetChampionAggregatedRecordObj2.Active__c = true;
        instinetChampionAggregatedRecordObj2.Start_Date__c = Date.newInstance(2018, 1, 1);
        String uniqueIdPartForObj2 = championAccountRMObj2.RDM_Org_ID__c + '#' + instinetEmployeeRecord.Login_Id__c + '#' + 'Japan';
        instinetChampionAggregatedRecordObj2.Subset_Unique_ID__c = uniqueIdPartForObj2;
        instinetChampionAggregatedRecordObj2.Unique_ID__c = uniqueIdPartForObj2 + '#2018-01-01 00:00:00#null';

        instinetChampionAggregatedList.add(instinetChampionAggregatedRecordObj2);

        insert instinetChampionAggregatedList;

        //Insert Champion Records
        List<Sales_Champion__c> salesChampionList = new List<Sales_Champion__c>();

        Account accountRGObj = (accountRGList != null && accountRGList.size() > 0) ? accountRGList.get(0) : null;
        Id instinetChampionRecordTypeId = CommonTools.getRecordTypeId('Sales_Champion__c','Instinet Champion');

        Sales_Champion__c salesChampionObj1 = new Sales_Champion__c();

        salesChampionObj1.Account__c = accountRGObj.Id;
        salesChampionObj1.Instinet_Champion__c = instinetEmployeeRecord.Id;
        salesChampionObj1.Region__c = 'Japan';
        salesChampionObj1.Champion_Type__c = 'EQ - Execution Champion';
        salesChampionObj1.RecordTypeId = instinetChampionRecordTypeId;

        salesChampionList.add(salesChampionObj1);

        Sales_Champion__c salesChampionObj2 = new Sales_Champion__c();

        salesChampionObj2.Account__c = accountRGObj.Id;
        salesChampionObj2.Instinet_Champion__c = instinetEmployeeRecord.Id;
        salesChampionObj2.Region__c = 'Americas';
        salesChampionObj2.Champion_Type__c = 'EQ - Execution Champion';
        salesChampionObj2.RecordTypeId = instinetChampionRecordTypeId;

        salesChampionList.add(salesChampionObj2);

        insert salesChampionList;

    }

    public static void moveRM(){
        //Fetch RG Account
        Account accountRG = [SELECT Id, RDM_Org_ID__c FROM Account WHERE RDM_Org_ID__c = 'RG222222' LIMIT 1];
        
        if(accountRG != null){

            //Fetch RM Account
            List<Account> accountRMList = [SELECT Id, RDM_Org_ID__c FROM Account WHERE RDM_Org_ID__c = 'RM333333'];

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
            Database.executeBatch(new Daily_RMFeed_Job_InstinetChampion(hasFeedError),1);
           
            Test.stopTest();  

            //Check the entry in Sales_Champion__c table with old RG. The entry should be present corresponding to old RG
            List<Sales_Champion__c> salesChampionList = 
                    [SELECT Id, Instinet_Champion__c, Account__r.RDM_Org_ID__c FROM Sales_Champion__C
                     WHERE RecordType.DeveloperName = 'Instinet_Champion' AND Account__r.RDM_Org_ID__c = 'RG111111' AND Region__c = 'Americas'];


            System.assert(salesChampionList != null && salesChampionList.size() == 1);  

    
        }
    }

}