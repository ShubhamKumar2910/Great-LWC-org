global class BulkUploaderCoverageWrapper {
    @AuraEnabled
    public String guid { get;set; }
    
	@AuraEnabled
    public Integer fromNumber { get;set; }

    @AuraEnabled
    public Integer toNumber { get;set; }
    
	@AuraEnabled
    public Integer totalFailed { get;set; }
    
    @AuraEnabled
    public Integer totalCount { get;set; }
    
    @AuraEnabled
    public Integer totalSuccess { get;set; }
    
    @AuraEnabled
    public Integer totalWarning { get;set; }
    
    @AuraEnabled
    public string exceptionMsg { get;set; }
    
    @AuraEnabled
    public string csvString { get;set; }
    
    @AuraEnabled
    public List<CoverageWrapper> coverageRecords { get;set; }
    
    @AuraEnabled
    public List<Coverage_Temp__c> successRecords { get;set; }
    //commented as no longer required and moved to process staging JIRA 1588
  /*  
    @AuraEnabled
    public List<RG_Coverage_Request__c> rgRequestsToDelete { get;set; }
    
    @AuraEnabled
    public List<Coverage_Access_Request__c> rmRequestsToDelete { get;set; }
*/
   
      
}