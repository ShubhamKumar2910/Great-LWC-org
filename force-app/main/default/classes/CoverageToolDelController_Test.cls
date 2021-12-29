@isTest(SeeAllData = true)
public class CoverageToolDelController_Test {
     
    
    public class filterCriteria
    {
         public String rgOrgID {get;set;}
        public String coverageID {get;set;}
        
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
    
    static testMethod void testgetProductLevelData(){    
List<Coverage_Team_Member__c> cvgTest = [SELECT Account__r.Parent.RDM_ORG_ID__c,Sales_Team_for_Coverage__r.Coverage_ID__c from Coverage_Team_Member__C LIMIT 20];
    List<filterCriteria> ftcrts = new List<filterCriteria>();
        
     CoverageToolDelController cvgcntrl = new CoverageToolDelController();   
       
    for(Coverage_Team_Member__c cvg : cvgTest){
           filterCriteria ftcrt = new  filterCriteria();
            ftcrt.rgOrgID = cvg.Account__r.PArent.RDM_ORG_ID__c;
            ftcrt.coverageID = cvg.Sales_Team_for_Coverage__r.Coverage_ID__c;
        ftcrts.add(ftcrt);
        }
    
   
 List<CoverageDataWrapper> wrapperList =    CoverageToolDelController.getProductLevelData(JSON.serialize(ftcrts));
        
 List<jsonData> jsonDt = new List<jsonData>();      
        
        
        
        for(CoverageDataWrapper wrapper:wrapperList){
            jsonData jdt = new jsonData();
             jdt.salesCode = wrapper.coverageID;
             jdt.productGroup = wrapper.productGroup;
             jdt.productRegion = wrapper.productRegion;
             jdt.productName = wrapper.product;
             jdt.role = 'Primary';
             jdt.action = 'Update';
             DateTime newStartDate = wrapper.startDate;            
             jdt.fromDate = newStartDate.format('yyyy/MM/dd');
            jdt.clientRGKey = wrapper.rgOrgID;
            jsonDt.add(jdt);
                                            
        }
        
        CoverageToolDelController.createDeleteDataAndSubmit(JSON.serialize(jsonDt));
        
    
}

  
    
    
}