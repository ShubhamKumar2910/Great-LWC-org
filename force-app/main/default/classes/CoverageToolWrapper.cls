global class CoverageToolWrapper
{
    
	@AuraEnabled
    public string Id{get;set;}
    
    @AuraEnabled
    public string teamName{get;set;}
    
	@AuraEnabled
    public string salesPerson{get;set;}
    
	@AuraEnabled
    public string accountType{get;set;}
    
	@AuraEnabled
    public string accountName{get;set;}
    
	@AuraEnabled
    public ID accountID{get;set;}
    
	@AuraEnabled
    public string productGroup{get;set;}
    
	@AuraEnabled
    public string productRegion{get;set;}
    @AuraEnabled
    
	public string productName{get;set;}

	@AuraEnabled
    public string role{get;set;}
    
	@AuraEnabled
    public string Status{get;set;}

	@AuraEnabled
    public Decimal YTDRevenue{get;set;}

    @AuraEnabled
    public Decimal Budget{get;set;}

    @AuraEnabled
    public string action{get;set;}
    
	@AuraEnabled
    public string startDate{get;set;}
    
    @AuraEnabled
    public string LastUpdatedBy{get;set;}
}