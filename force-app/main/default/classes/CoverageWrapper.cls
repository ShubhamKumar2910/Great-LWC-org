global class CoverageWrapper
{
    @AuraEnabled
    public Integer rowNumber{get;set;}
    @AuraEnabled
    public string rowDisabledClass{get;set;}
    @AuraEnabled
    public string deskCode{get;set;}
    @AuraEnabled
    public string readOnlyDeskCodes{get;set;}
    @AuraEnabled
    public Integer updateIndex{get;set;}
    @AuraEnabled
    public boolean IsRG{get;set;}
    @AuraEnabled
    public string coverageType{get;set;}
    @AuraEnabled
    public string subType{get;set;}
    @AuraEnabled
    public string Type {get;set;}
    @AuraEnabled
    public string clientRGKey{get;set;}
    @AuraEnabled
    public string BillingCountryCode{get;set;}
    @AuraEnabled
    public string clientKey{get;set;}
    @AuraEnabled
    public string clientRMKey{get;set;}
    @AuraEnabled
    public string accountId{get;set;}
    @AuraEnabled
    public string salesPerson{get;set;}
    @AuraEnabled
    public string salesTeam{get;set;}
    @AuraEnabled
    public string salesTeamDetails{get;set;}
    @AuraEnabled
    public string clientName{get;set;}
    @AuraEnabled
    public string salesCodeID{get;set;}
    @AuraEnabled
    public string salesRefCodeName{get;set;}
    @AuraEnabled
    public string salesCode{get;set;}
    @AuraEnabled
    public string transferFromId{get;set;}
    @AuraEnabled
    public string transferFrom{get;set;}
    @AuraEnabled
    public string transferTo{get;set;}
    @AuraEnabled
    public string productGroup{get;set;}
    @AuraEnabled
    public string productRegion{get;set;}
    @AuraEnabled
    public string productName{get;set;}
    @AuraEnabled
    public Set<string> productRegionCombination{get;set;}
    @AuraEnabled
    public string role{get;set;}
    @AuraEnabled
    public string action{get;set;}
    @AuraEnabled
    public string fromDate{get;set;}
    @AuraEnabled
    public string errorMessage{get;set;}
    @AuraEnabled
    public boolean containsError{get;set;}
    @AuraEnabled
    public string errorType{get;set;}
    @AuraEnabled
    public string Comments{get;set;}
    @AuraEnabled
    public boolean isAttested{
        get { 
                if(attest == 'YES' || attest == 'Y')
                {
                    return true;
                }
                return isAttested; 
            }
        set{isAttested = value;}
        }
    @AuraEnabled
    public string userComments{get;set;}
    // added for JIRA 1588
    @AuraEnabled
    public string salesRefCodeID{get;set;}
    @AuraEnabled
    public string salesRefCode{get;set;}
    public string OpptId{get;set;}
    @AuraEnabled
    public string OpptStage{get;set;}
    @AuraEnabled
    public boolean isCreateupdate{get;set;}
    // added for JIRA 3862
    @AuraEnabled
    public String company{get;set;}
    //added for JIRA SALES-3920
    @AuraEnabled
    public String includeRestrictedAccounts{get;set;}
    @AuraEnabled
    public string salesDeskRegion{get;set;}
    @AuraEnabled
    public boolean flagVal{get;set;}
	@AuraEnabled    
     public string attest {
     get{return attest;}
     set{attest = value;
         if('YES'.equalsIgnoreCase(attest) || 'Y'.equalsIgnoreCase(attest)){
                    isAttested = true;
                }
                else {
                    isAttested = false;
                }
        }
    }
        
    public CoverageWrapper(){
        
    }
    public CoverageWrapper(CoverageWrapper wrapper) {
        this.userComments = wrapper.userComments;
        this.Comments = wrapper.Comments;
        this.isAttested = wrapper.isAttested;
        this.errorType = wrapper.errorType;
        this.containsError = wrapper.containsError;
        this.errorMessage = wrapper.errorMessage;
        this.fromDate = wrapper.fromDate;
        this.action = wrapper.action;
        this.role = wrapper.role;
        this.productRegionCombination = wrapper.productRegionCombination;
        this.productName = wrapper.productName;
        this.productGroup = wrapper.productGroup;
        this.productRegion = wrapper.productRegion;
        this.rowNumber = wrapper.rowNumber;
        this.IsRG = wrapper.IsRG;
        this.clientRGKey = wrapper.clientRGKey;
        this.BillingCountryCode = wrapper.BillingCountryCode;
        this.clientKey = wrapper.clientKey;
        this.accountId = wrapper.accountId;
        this.salesPerson = wrapper.salesPerson;
        this.salesTeam = wrapper.salesTeam;
        this.clientName = wrapper.clientName;
        this.salesCodeID = wrapper.salesCodeID;
        this.salesCode = wrapper.salesCode;
        this.transferFromId = wrapper.transferFromId;
        this.transferFrom = wrapper.transferFrom;
        this.transferTo = wrapper.transferTo;
        // added for JIRA 1588
        this.salesRefCodeID = wrapper.salesRefCodeID;
        this.salesRefCode = wrapper.salesRefCode;
        this.isCreateupdate = wrapper.isCreateupdate;
        this.OpptId = wrapper.OpptId;
        this.OpptStage = wrapper.OpptStage;
        // added for JIRA 3862
        this.company = wrapper.company;    
        //added for JIRA SALES-3920
        this.includeRestrictedAccounts = wrapper.includeRestrictedAccounts;
        this.salesDeskRegion = wrapper.salesDeskRegion;
        this.attest = wrapper.attest;
        this.readOnlyDeskCodes = wrapper.readOnlyDeskCodes;
    }
    
}