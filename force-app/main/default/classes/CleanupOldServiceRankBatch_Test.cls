@isTest
public class CleanupOldServiceRankBatch_Test {

    @testSetup 
    private static void setupData(){
        setupTotalModelAndOldServiceRanksRecords();
    }

    private static void setupTotalModelAndOldServiceRanksRecords(){
        //Account data setup
        RecordType RGRecordType = [SELECT Id FROM RecordType WHERE Name = 'RG Account' ];
        system.debug('RGRecordType : ' + RGRecordType.Id);
            
        Account account2  = new Account(); 
        account2.Name = 'TestAccount2';
        account2.RDM_Org_ID__c = 'test1';            
        account2.RecordTypeId = RGRecordType.Id;
        account2.BillingCity = 'California';
        account2.BillingCountry = 'United States';
        account2.BillingStreet = '52nd Street' ;
        insert account2;

        //Model data
        Account_Service_Model__c equityCoreserviceModel = new Account_Service_Model__c();
        RecordType TotalRecordType = [SELECT Id FROM RecordType WHERE Name = 'Total' ];
        equityCoreserviceModel.Name = 'Equity Core (value)';
        equityCoreserviceModel.RecordTypeId = TotalRecordType.Id;
        equityCoreserviceModel.Is_Contact_Count__c = 'NO';
        equityCoreserviceModel.Item_Name__c = 'Total';
        equityCoreserviceModel.Order__c = 0;
        equityCoreserviceModel.stable_version__c=2;     
        insert equityCoreserviceModel;
        
       //service rank data
        //Service rank data setup: Just for total so that ROI is populated
        //TODO
        Account_Service_Rank__c eqCoreServiceRank = new Account_Service_Rank__c();
        eqCoreServiceRank.Account__c   = account2.id; 
        eqCoreServiceRank.Model__c = equityCoreserviceModel.id;
        eqCoreServiceRank.version__c=1;
        eqCoreServiceRank.Current_FY_JAPAN_COUNT__C = 1;
        eqCoreServiceRank.Current_FY_ASIAEX_COUNT__C = 1;
        eqCoreServiceRank.Current_FY_EUROPE_COUNT__C = 1;
        eqCoreServiceRank.Current_FY_US_COUNT__C = 1;
        eqCoreServiceRank.Current_FY_GLOBAL_COUNT__C = 1;       
        insert eqCoreServiceRank;
        
        Account_Service_Rank__c aejServiceRank = new Account_Service_Rank__c();
        aejServiceRank.Account__c   = account2.id; 
        aejServiceRank.Model__c = equityCoreserviceModel.id;
        aejServiceRank.version__c=1;
        aejServiceRank.Current_FY_JAPAN_COUNT__C = 1;
        aejServiceRank.Current_FY_ASIAEX_COUNT__C = 1;
        aejServiceRank.Current_FY_EUROPE_COUNT__C = 1;
        aejServiceRank.Current_FY_US_COUNT__C = 1;
        aejServiceRank.Current_FY_GLOBAL_COUNT__C = 1;      
        insert aejServiceRank;

        Account_Service_Rank__c japanServiceRank = new Account_Service_Rank__c();
        japanServiceRank.Account__c   = account2.id; 
        japanServiceRank.Model__c = equityCoreserviceModel.id;
        japanServiceRank.version__c=1;
        japanServiceRank.Current_FY_JAPAN_COUNT__C = 1;
        japanServiceRank.Current_FY_ASIAEX_COUNT__C = 1;
        japanServiceRank.Current_FY_EUROPE_COUNT__C = 1;
        japanServiceRank.Current_FY_US_COUNT__C = 1;
        japanServiceRank.Current_FY_GLOBAL_COUNT__C = 1;
        insert japanServiceRank;            
        
        NomuraSettings__c setting = new NomuraSettings__c();
        setting.To_Email_Addr_NomuraEmpReplacement_Batch__c='gaurav.jain.4@nomura.com';
        insert setting;
    } 
    
    static testMethod void testCleanupOldServiceRankBatch() {
        Test.startTest(); 
        CleanupOldServiceRankBatch batch = new CleanupOldServiceRankBatch ();
        batch.errorMessageList = new String[] {'error1', 'error2'};
        Database.executeBatch(batch, 3000);
        Test.stopTest();    
    }
}