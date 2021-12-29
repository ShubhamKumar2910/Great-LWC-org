global class CoverageDataWrapper {
    @AuraEnabled
    public Integer rowNumber{get;set;}
    @AuraEnabled
    public string rowDisabledClass{get;set;}
    @AuraEnabled
    public string salesCodeCompany{get;set;}
    @AuraEnabled
    public List<string> selectedKeys{get;set;} 
    @AuraEnabled
    public string origKey {get;set;}
    @AuraEnabled
    public Set<string> productRegionCombination{get;set;}
    @AuraEnabled
    public Integer numberOfRMs {get;set;}
    @AuraEnabled
    public string clientRGKey{get;set;}
    @AuraEnabled
    public string subType{get;set;}
    @AuraEnabled
    public string Type {get;set;}
    @AuraEnabled
    public boolean isChecked{get;set;}
    @AuraEnabled
    public string level{get;set;}
    @AuraEnabled
    public string coverageType{get;set;}
    @AuraEnabled
    public string Id{get;set;}
    @AuraEnabled
    public string desk{get;set;}
    @AuraEnabled
    public string region{get;set;}
    @AuraEnabled
    public string team{get;set;}
    @AuraEnabled
    public string salesPerson{get;set;}
    @AuraEnabled
    public string salesPersonId{get;set;}
    @AuraEnabled
    public string accountName{get;set;}
    @AuraEnabled
    public string clientRG{get;set;}
    @AuraEnabled
    public string clientRGId{get;set;}
    @AuraEnabled
    public string clientRM{get;set;}
    @AuraEnabled
    public boolean rmRestricted{get;set;}
    @AuraEnabled
    public string clientRMId{get;set;}
    @AuraEnabled
    public string rgOrgID{get;set;}
    @AuraEnabled
    public string rmOrgID{get;set;}
    @AuraEnabled
    public string salesCodeID{get;set;}
    @AuraEnabled
    public string coverageID{get;set;}
    @AuraEnabled
    public string productGroup{get;set;}
    @AuraEnabled
    public string productRegion{get;set;}
    @AuraEnabled
    public string product{get;set;}
    @AuraEnabled
    public string role{get;set;}
    @AuraEnabled
    public string productName{get;set;}
    @AuraEnabled
    public string action{get;set;}
    @AuraEnabled
    public string salesRefCodeID{get;set;}
    @AuraEnabled
    public string salesRefCode{get;set;}
    public string OpptId{get;set;}
    @AuraEnabled
    public string OpptStage{get;set;}
    @AuraEnabled
    public boolean isCreateupdate{get;set;}
    @AuraEnabled
    public decimal ytdRevenue{ 
        set {
            ytdRevenue = value;
        }
        get {
            if (ytdRevenue == null && !Test.isRunningTest()) {
                ytdRevenue = 0;
            }
            
            return ytdRevenue;
        }
    }
    @AuraEnabled
    public decimal wtdRevenue{ 
        set {
            wtdRevenue = value;
        }
        get {
            if (wtdRevenue == null && !Test.isRunningTest()) {
                wtdRevenue = 0;
            }
            
            return wtdRevenue;
        }
    }
    @AuraEnabled
    public decimal mtdRevenue{ 
        set {
            mtdRevenue = value;
        }
        get {
            if (mtdRevenue == null && !Test.isRunningTest()) {
                mtdRevenue = 0;
            }
            
            return mtdRevenue;
        }
    }
    @AuraEnabled
    public decimal ytdBudget{ 
        set {
            ytdBudget = value;
        }
        get {
            if (ytdBudget == null && !Test.isRunningTest()) {
                ytdBudget = 0;
            }
            
            return ytdBudget;
        }
    }
    @AuraEnabled
    public Date startDate{get;set;}
    @AuraEnabled
    public Date endDate{get;set;}
    @AuraEnabled
    public string transferTo{get;set;}
    @AuraEnabled
    public string transferToId{get;set;}
    @AuraEnabled
    public string transferToSalesCode{get;set;}
    @AuraEnabled
    public string transferToTo{get;set;}
    @AuraEnabled
    public Boolean disabled{get;set;}
    @AuraEnabled
    public string buttonVariant{get;set;}
    @AuraEnabled
    public string buttonIcon{get;set;}
    @AuraEnabled
    public Date transferDate{get;set;}
    @AuraEnabled
    public string status{get;set;}
    @AuraEnabled
    public string lastModifiedBy{get;set;}
    @AuraEnabled
    public string lastModifiedId{get;set;}
    @AuraEnabled
    public string newRole{get;set;}
    @AuraEnabled
    public Date newStartDate{get;set;}
    @AuraEnabled
    public string updateAction{get;set;}
    @AuraEnabled
    public string Comments{get;set;}
    @AuraEnabled
    public string errorResponse{get;set;}
    @AuraEnabled
    public string userComments{get;set;}
    @AuraEnabled
    public Boolean containsError{get;set;}
    @AuraEnabled
    public String includeRestrictedAccounts{get;set;}
    @AuraEnabled
    public boolean isAttested{get;set;}
    @AuraEnabled
    public string company{get;set;}
    @AuraEnabled
    public string salesDeskRegion{get;set;}
    @AuraEnabled
    public string clientLevel{get;set;}
    @AuraEnabled
    public string accountRMCountry {get; set;}
    @AuraEnabled
    public boolean isCoverageLevelRG {get; set;}
    @AuraEnabled
    public string requestedCovLevel {get; set;}
    @AuraEnabled
    public string salesDeskDiv {get; set;}
    @AuraEnabled
    public string salesDeskIsDummy {get; set;}
    @AuraEnabled
    public string clientPOD{get;set;}
    @AuraEnabled
    public string clientPODId{get;set;}
    @AuraEnabled
    public string salesPersonLoginId{get;set;}
}