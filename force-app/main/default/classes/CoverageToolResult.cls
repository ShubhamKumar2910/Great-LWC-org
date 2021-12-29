global class CoverageToolResult {
    @AuraEnabled
    public List<CoverageDataWrapper> dataBody{get;set;}
     
    @AuraEnabled
    public Map<Integer,Integer> dataFooter{get;set;}
    
    @AuraEnabled
    public List<string> csvKeys{get;set;}
    
    @AuraEnabled
    public Decimal YTDSummary{get;set;}
    
    @AuraEnabled
    public Decimal YTDBudgetSummary{get;set;}
    
    @AuraEnabled
    public Decimal WTDSummary{get;set;}
    
    @AuraEnabled
    public Decimal MTDSummary{get;set;}
    
    @AuraEnabled
    public string userRegion{get;set;}
    
    @AuraEnabled
    public string csvString{get;set;} 
    
    @AuraEnabled
    public string exceptionMsg='';
    
    @AuraEnabled
    public Boolean doNotShowRevenueColumns{get;set;}
}