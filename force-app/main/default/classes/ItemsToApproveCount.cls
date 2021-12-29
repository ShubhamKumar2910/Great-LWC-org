public without sharing class ItemsToApproveCount {
    
    //this class is created to send count individually to component as part of SALES-4207
    @AuraEnabled
    public Integer totalApprovalsCount {get; set;}
    @AuraEnabled
    public Integer coverageRequestCount {get; set;}
    @AuraEnabled
    public Integer etradingCount {get; set;}
    @AuraEnabled 
    public Integer crossSellCount{get; set;}
    @AuraEnabled
    public Integer schRequestCount {get; set;}
    @AuraEnabled
    public Integer onbRequestCount {get; set;}
    @AuraEnabled
    public Integer fenTaskCount {get; set;}
    
    public ItemsToApproveCount() {
        
    }
}