@isTest(SeeAllData = true)
public class CoverageToolTrsferController_Test {
    
    
    
    
    public class SalesPerson 
    {
        @AuraEnabled public String SObjectLabel {get;set;}
        @AuraEnabled public String SObjectId {get;set;}
        @AuraEnabled public String salesCode {get;set;}
    }
    
    public class filterCriteria
    {
        @AuraEnabled public String rgOrgID {get;set;}
        @AuraEnabled public String coverageID {get;set;}
        @AuraEnabled public ID RGId {get;set;}
        @AuraEnabled public String product {get;set;}
        @AuraEnabled public String productGroup {get;set;}
        @AuraEnabled public String productRegion {get;set;}
        
    }
    
    public class jsonData
    {
        public String salesCode {get;set;}
        public String productGroup {get;set;}
        public String productRegion {get;set;}
        public String productName {get;set;}
        public String role {get;set;}
        public String action {get;set;}
        public String fromDate {get;set;}
        public string clientRGKey {get;set;}
    }
    
    
    
    static testMethod void testControllerFunctions(){ 
        
        List<Account> RGAccount = [SELECT Id from Account where Name = 'PIMCO (G)']; 
        
        List<Coverage_Team_Member__c> cvgTest = new List<Coverage_Team_Member__c>();
        if(RGAccount.size() > 0){
         cvgTest = [SELECT Account__r.Parent.RDM_ORG_ID__c,Sales_Team_for_Coverage__r.Coverage_ID__c,Product2__c,Product_Region__c,Product_Group__c from Coverage_Team_Member__C
                                                 WHERE Account__r.ParentId = : RGAccount[0].Id];
        }
        List<filterCriteria> ftcrts = new List<filterCriteria>();
        
        
        CoverageToolTrsferController cvgcntrl = new CoverageToolTrsferController();   
        
        for(Coverage_Team_Member__c cvg : cvgTest){
            filterCriteria ftcrt = new  filterCriteria();
            ftcrt.rgOrgID = cvg.Account__r.Parent.RDM_ORG_ID__c;
            ftcrt.coverageID = cvg.Sales_Team_for_Coverage__r.Coverage_ID__c;
            ftcrt.RGId = cvg.Account__r.ParentId;
            ftcrt.product= cvg.Product2__c;
            ftcrt.productGroup = cvg.Product_Group__c;
            ftcrt.productRegion = cvg.Product_Region__c;
            ftcrts.add(ftcrt);
        }
        
        
        
        List<CoverageDataWrapper> ActivewrapperList =    CoverageToolTrsferController.getProductLevelData(JSON.serialize(ftcrts),'active','Client',false,false);
        List<CoverageDataWrapper> ActivewrapperList1 =    CoverageToolTrsferController.getProductLevelData(JSON.serialize(ftcrts),'active','Product',false,false);
        List<CoverageDataWrapper> InactivewrapperList =    CoverageToolTrsferController.getProductLevelData(JSON.serialize(ftcrts),'inactive','Client',false,false);
        List<CoverageDataWrapper> InactivewrapperList1 =    CoverageToolTrsferController.getProductLevelData(JSON.serialize(ftcrts),'inactive','Product',false,false);
        
        List<SalesPerson> sPersons = new List<SalesPerson>();
        
        for(CoverageDataWrapper cvgdt : ActivewrapperList){
            cvgdt.isChecked = true;
        }
        
        
        List<Sales_Team_for_Coverage__c> sPerson = [select id,Name,Coverage_ID__c,Sales_Code_Login_ID__c from Sales_Team_for_Coverage__c LIMIT 1];   
        
        
        if(sPerson.size()> 0){
        salesPerson sp = new SalesPerson();
        sp.SObjectLabel = sPerson[0].Name;
        sp.SObjectId = sPerson[0].Id;
        sp.salesCode = sPerson[0].Coverage_ID__c;
        
        sPersons.add(sp);
        }
        
        DateTime dt = DateTime.now();
        string endDate = dt.format('yyyy-MM-dd');
        
        List<CoverageDataWrapper> updatedData =  CoverageToolTrsferController.getUpdatedData(JSON.serialize(sPersons), JSON.serialize(ActivewrapperList),endDate, true);
        List<CoverageDataWrapper> updatedData1 =  CoverageToolTrsferController.getUpdatedData(JSON.serialize(sPersons), JSON.serialize(ActivewrapperList),endDate, false); 

         
        
    }
    
    
    
    
}