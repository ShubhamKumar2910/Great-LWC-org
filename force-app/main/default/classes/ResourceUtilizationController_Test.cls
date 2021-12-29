@isTest
public class ResourceUtilizationController_Test {

    @testSetup 
    public static void setupTestData(){
        
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
        
        // Model data setup: Just for Total
        //TODO
        Account_Service_Model__c equityCoreserviceModel = new Account_Service_Model__c();
        RecordType TotalRecordType = [SELECT Id FROM RecordType WHERE Name = 'Total' ];
        equityCoreserviceModel.Name = 'Equity Core (value)';
        equityCoreserviceModel.RecordTypeId = TotalRecordType.Id;
        equityCoreserviceModel.Is_Contact_Count__c = 'NO';
        equityCoreserviceModel.Item_Name__c = 'Total';
        equityCoreserviceModel.Order__c = 0;
		equityCoreserviceModel.stable_version__c=1;
        insert equityCoreserviceModel;
        
        Account_Service_Model__c aejserviceModel = new Account_Service_Model__c();
        aejserviceModel.Name = 'AEJ-Weighted';
        aejserviceModel.RecordTypeId = TotalRecordType.Id;
        aejserviceModel.Is_Contact_Count__c = 'NO';
        aejserviceModel.Item_Name__c = 'Total';
        aejserviceModel.Order__c = 0;
		aejserviceModel.stable_version__c=1;
        insert aejserviceModel;

        Account_Service_Model__c japanserviceModel = new Account_Service_Model__c();
        japanserviceModel.Name = 'Japan-Weighted';
        japanserviceModel.RecordTypeId = TotalRecordType.Id;
        japanserviceModel.Is_Contact_Count__c = 'NO';
        japanserviceModel.Item_Name__c = 'Total';
        japanserviceModel.Order__c = 0;
		japanserviceModel.stable_version__c=1;
        insert japanserviceModel;       
        
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
        aejServiceRank.Model__c = aejserviceModel.id;
		aejServiceRank.version__c=1;
		aejServiceRank.Current_FY_JAPAN_COUNT__C = 1;
		aejServiceRank.Current_FY_ASIAEX_COUNT__C = 1;
		aejServiceRank.Current_FY_EUROPE_COUNT__C = 1;
		aejServiceRank.Current_FY_US_COUNT__C = 1;
		aejServiceRank.Current_FY_GLOBAL_COUNT__C = 1;		
        insert aejServiceRank;

        Account_Service_Rank__c japanServiceRank = new Account_Service_Rank__c();
        japanServiceRank.Account__c   = account2.id; 
        japanServiceRank.Model__c = japanserviceModel.id;
		japanServiceRank.version__c=1;
		japanServiceRank.Current_FY_JAPAN_COUNT__C = 1;
		japanServiceRank.Current_FY_ASIAEX_COUNT__C = 1;
		japanServiceRank.Current_FY_EUROPE_COUNT__C = 1;
		japanServiceRank.Current_FY_US_COUNT__C = 1;
		japanServiceRank.Current_FY_GLOBAL_COUNT__C = 1;
        insert japanServiceRank;        
        

        //Revenue rank data setup: Just for total so that ROI is populated
        //TODO
        Account_Revenue_Rank__c revenueRank = new Account_Revenue_Rank__c();
        revenueRank.Account__c   = account2.id;
        revenueRank.Product__c   = 'Equity';
        insert revenueRank;
    
        Account_Revenue_Rank__c revenueRank1 = new Account_Revenue_Rank__c();
        revenueRank1.Account__c   = account2.id;
        revenueRank1.Product__c  = 'ChiX';
        insert revenueRank1;
        
        system.debug('RG Account  :'+ account2.id) ;
      
    }  
    
    static testMethod void testResourceUtilizationController(){
        Test.startTest(); 
          
        Account act = [SELECT Id,Name,ParentId,RecordTypeId,RDM_ORG_ID__c FROM Account WHERE Name = 'TestAccount2'];  
          
        ResourceUtilizationController controller = new ResourceUtilizationController(new ApexPages.StandardController([SELECT Id,Name,ParentId,RecordTypeId,RDM_ORG_ID__c FROM Account WHERE NAme = 'TestAccount2']));
        controller.getPeriodOptions();
        controller.populateModelOptions();
        controller.loadDefaultReport();
        
        // Search for EQUITY_CORE_VALUE
        controller.model='Equity Core (value)';//ResourceUtilizationController.EQUITY_CORE_VALUE;
        controller.period='Current_CY_';
        controller.search();
        
        controller.period='Previous_FY_';
        controller.search();
        
        controller.period='Previous_CY_';
        controller.search();
        
        // Search for JAPAN_WEIGHTED
        controller.model='Japan-Weighted';//ResourceUtilizationController.JAPAN_WEIGHTED;
        controller.period='Current_CY_';
        controller.search();
        
        controller.period='Previous_FY_';
        controller.search();
        
        controller.period='Previous_CY_';
        controller.search();
        
        // Search for AEJ_WEIGHTED
        controller.model='AEJ-Weighted';//ResourceUtilizationController.AEJ_WEIGHTED;
        controller.period='Current_CY_';
        controller.search();
        
        controller.period='Previous_FY_';
        controller.search();
        
        controller.period='Previous_CY_';
        controller.search();        
        
        Test.stopTest();  
    }

}