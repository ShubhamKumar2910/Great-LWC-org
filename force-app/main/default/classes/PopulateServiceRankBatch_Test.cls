@isTest
public class PopulateServiceRankBatch_Test {

    @testSetup 
    private static void setupData(){
    }

    private static void setupDataForTotalModelRanking(User testUser){
    
        //total model
        Account_Service_Model__c equityCoreserviceModel = new Account_Service_Model__c();
        RecordType TotalRecordType = [SELECT Id FROM RecordType WHERE Name = 'Total' ];
        equityCoreserviceModel.Name = 'Equity Core (value)';
        equityCoreserviceModel.RecordTypeId = TotalRecordType.Id;
        equityCoreserviceModel.Is_Contact_Count__c = 'NO';
        equityCoreserviceModel.Item_Name__c = 'Total';
        equityCoreserviceModel.Order__c = 0;
        equityCoreserviceModel.stable_version__c=1;        
        equityCoreserviceModel.inprogress_version__c=2;
        insert equityCoreserviceModel;
        
        //Actual model
        RecordType actualType = [SELECT Id FROM RecordType WHERE Name = 'Actual' ];
        
        Account_Service_Model__c equityCoreserviceModel1 = new Account_Service_Model__c();
        equityCoreserviceModel1.Name = 'Equity Core (value)';
        equityCoreserviceModel1.RecordTypeId = actualType.Id;
        equityCoreserviceModel1.Is_Contact_Count__c = 'NO';
        equityCoreserviceModel1.Item_Name__c = 'Analyst : calls';
        equityCoreserviceModel1.Order__c = 3;
        equityCoreserviceModel1.stable_version__c=2;        
        equityCoreserviceModel1.CALL_REPORT_TYPE__C='Dialer';
        equityCoreserviceModel1.WEIGHT__C= 5;
        insert equityCoreserviceModel1;         
        
        Account_Service_Model__c equityCoreserviceModel2 = new Account_Service_Model__c();
        equityCoreserviceModel2.Name = 'Equity Core (value)';
        equityCoreserviceModel2.RecordTypeId = actualType.Id;
        equityCoreserviceModel2.Is_Contact_Count__c = 'NO';
        equityCoreserviceModel2.Item_Name__c = 'Analyst : Voicemail';
        equityCoreserviceModel2.Order__c = 3;
        equityCoreserviceModel2.stable_version__c=2;        
        equityCoreserviceModel2.CALL_REPORT_TYPE__C='Voicemail';
        equityCoreserviceModel2.WEIGHT__C= 5;
        insert equityCoreserviceModel2;     

        //account 
        RecordType RGRecordType = [SELECT Id FROM RecordType WHERE Name = 'RG Account' ];
        
        Account account1  = new Account(); 
        account1.Name = 'TestAccount1';
        account1.RDM_Org_ID__c = 'test1';            
        account1.RecordTypeId = RGRecordType.Id;
        account1.BillingCity = 'California';
        account1.BillingCountry = 'United States';
        account1.BillingStreet = '52nd Street' ;
        insert account1;        
            
        Account account2  = new Account(); 
        account2.Name = 'TestAccount2';
        account2.RDM_Org_ID__c = 'test2';            
        account2.RecordTypeId = RGRecordType.Id;
        account2.BillingCity = 'California';
        account2.BillingCountry = 'United States';
        account2.BillingStreet = '52nd Street' ;
        insert account2;        

        //service ranks
        Account_Service_Rank__c eqCoreServiceRank = new Account_Service_Rank__c();
        eqCoreServiceRank.Account__c   = account1.id; 
        eqCoreServiceRank.Model__c = equityCoreserviceModel1.id;
        eqCoreServiceRank.version__c=2;
        eqCoreServiceRank.Current_FY_JAPAN_COUNT__C = 1;
        eqCoreServiceRank.Current_FY_ASIAEX_COUNT__C = 1;
        eqCoreServiceRank.Current_FY_EUROPE_COUNT__C = 1;
        eqCoreServiceRank.Current_FY_US_COUNT__C = 1;
        eqCoreServiceRank.Current_FY_GLOBAL_COUNT__C = 1;       
        insert eqCoreServiceRank;       
        
        Account_Service_Rank__c eqCoreServiceRank1 = new Account_Service_Rank__c();
        eqCoreServiceRank1.Account__c   = account2.id; 
        eqCoreServiceRank1.Model__c = equityCoreserviceModel2.id;
        eqCoreServiceRank1.version__c=2;
        eqCoreServiceRank1.Current_FY_JAPAN_COUNT__C = 2;
        eqCoreServiceRank1.Current_FY_ASIAEX_COUNT__C = 2;
        eqCoreServiceRank1.Current_FY_EUROPE_COUNT__C = 2;
        eqCoreServiceRank1.Current_FY_US_COUNT__C = 2;
        eqCoreServiceRank1.Current_FY_GLOBAL_COUNT__C = 2;      
        insert eqCoreServiceRank1;      
		
        List<Account_Service_Rank__c> lst = new List<Account_Service_Rank__c>();
        lst.add(eqCoreServiceRank1);
        lst.add(eqCoreServiceRank);
        PopulateServiceCountBatch btch = new PopulateServiceCountBatch();
        //btch.mergeDuplicates(lst);

    } 
    
    private static void setupDataForActualModelRanking(User testUser) {
    
        //Total model
        Account_Service_Model__c equityCoreserviceModel = new Account_Service_Model__c();
        RecordType TotalRecordType = [SELECT Id FROM RecordType WHERE Name = 'Total' ];
        equityCoreserviceModel.Name = 'Equity Core (value)';
        equityCoreserviceModel.RecordTypeId = TotalRecordType.Id;
        equityCoreserviceModel.Is_Contact_Count__c = 'NO';
        equityCoreserviceModel.Item_Name__c = 'Total';
        equityCoreserviceModel.Order__c = 0;
        equityCoreserviceModel.stable_version__c=1;     
        insert equityCoreserviceModel;      
    
        //service actual model
        RecordType actualType = [SELECT Id FROM RecordType WHERE Name = 'Actual' ];
        
        Account_Service_Model__c equityCoreserviceModel2 = new Account_Service_Model__c();
        equityCoreserviceModel2.Name = 'Equity Core (value)';
        equityCoreserviceModel2.RecordTypeId = actualType.Id;
        equityCoreserviceModel2.Is_Contact_Count__c = 'NO';
        equityCoreserviceModel2.Item_Name__c = 'Analyst : calls';
        equityCoreserviceModel2.Order__c = 3;
        equityCoreserviceModel2.stable_version__c=1;        
        equityCoreserviceModel2.inprogress_version__c=2;
        equityCoreserviceModel2.CALL_REPORT_TYPE__C='Dialer;Voicemail';
        equityCoreserviceModel2.WEIGHT__C= 5;
        insert equityCoreserviceModel2;  
        
        //Account
        RecordType RGRecordType = [SELECT Id FROM RecordType WHERE Name = 'RG Account' ];
        
        Account account1  = new Account(); 
        account1.Name = 'TestAccount1';
        account1.RDM_Org_ID__c = 'test1';            
        account1.RecordTypeId = RGRecordType.Id;
        account1.BillingCity = 'California';
        account1.BillingCountry = 'United States';
        account1.BillingStreet = '52nd Street' ;
        insert account1;        
            
        Account account2  = new Account(); 
        account2.Name = 'TestAccount2';
        account2.RDM_Org_ID__c = 'test2';            
        account2.RecordTypeId = RGRecordType.Id;
        account2.BillingCity = 'California';
        account2.BillingCountry = 'United States';
        account2.BillingStreet = '52nd Street' ;
        insert account2;
        
        //service ranks
        Account_Service_Rank__c eqCoreServiceRank = new Account_Service_Rank__c();
        eqCoreServiceRank.Account__c   = account1.id; 
        eqCoreServiceRank.Model__c = equityCoreserviceModel2.id;
        eqCoreServiceRank.version__c=2;
        eqCoreServiceRank.Current_FY_JAPAN_COUNT__C = 1;
        eqCoreServiceRank.Current_FY_ASIAEX_COUNT__C = 1;
        eqCoreServiceRank.Current_FY_EUROPE_COUNT__C = 1;
        eqCoreServiceRank.Current_FY_US_COUNT__C = 1;
        eqCoreServiceRank.Current_FY_GLOBAL_COUNT__C = 1;  
        eqCoreServiceRank.external_id__c='23232323';        
        insert eqCoreServiceRank;       
        
        Account_Service_Rank__c eqCoreServiceRank1 = new Account_Service_Rank__c();
        eqCoreServiceRank1.Account__c   = account2.id; 
        eqCoreServiceRank1.Model__c = equityCoreserviceModel2.id;
        eqCoreServiceRank1.version__c=2;
        eqCoreServiceRank1.Current_FY_JAPAN_COUNT__C = 2;
        eqCoreServiceRank1.Current_FY_ASIAEX_COUNT__C = 2;
        eqCoreServiceRank1.Current_FY_EUROPE_COUNT__C = 2;
        eqCoreServiceRank1.Current_FY_US_COUNT__C = 2;
        eqCoreServiceRank1.Current_FY_GLOBAL_COUNT__C = 2;    
        eqCoreServiceRank1.external_id__c='7894789';            
        insert eqCoreServiceRank1;      


    }   
    
    static testMethod void testPopulateServiceRankForTotalModel() {
        Test.startTest(); 
        setupDataForTotalModelRanking(null);
        Database.executeBatch(new PopulateServiceRankBatch(), 5);       
        Test.stopTest();    
    }
    static testMethod void testPopulateServiceRankForActualModel() {
        Test.startTest(); 
        setupDataForActualModelRanking(null);
        Database.executeBatch(new PopulateServiceRankBatch(), 5);       
        Test.stopTest();    
    }   
}