public class CoverageWrapperLWC {

    @AuraEnabled
    public Boolean isRG {get;set;}
    @AuraEnabled
    public String coverageType {get;set;}
    @AuraEnabled
    public String action {get;set;}
    @AuraEnabled
    public String productGroup {get;set;}
    @AuraEnabled
    public String productRegion {get;set;}
    @AuraEnabled
    public String product {get;set;}
    @AuraEnabled
    public String role {get;set;}
    @AuraEnabled
    public Boolean isAttest {get;set;}
    @AuraEnabled
    public String source {get;set;}
    @AuraEnabled
    public String startDate {get;set;}
    @AuraEnabled
    public Account accountRecord {get;set;}
    @AuraEnabled
    public Sales_Team_for_Coverage__c salesTeamForCvgRecord {get;set;}
    @AuraEnabled
    public String groupBy {get;set;}
    @AuraEnabled
    public Boolean isPODCoverageError {get; set;}

    public CoverageWrapperLWC() {}

    public CoverageWrapperLWC(CoverageWrapperLWC wrapper){
        this.isRG = wrapper.isRG;
        this.coverageType = wrapper.coverageType;
        this.action = wrapper.action;
        this.productGroup = wrapper.productGroup;
        this.productRegion = wrapper.productRegion;
        this.product = wrapper.product;
        this.role = wrapper.role;
        this.isAttest = wrapper.isAttest;
        this.source = wrapper.source;
        this.startDate = wrapper.startDate;
        this.accountRecord = wrapper.accountRecord;
        this.salesTeamForCvgRecord = wrapper.salesTeamForCvgRecord;
        this.groupBy = wrapper.groupBy;
        this.isPODCoverageError = wrapper.isPODCoverageError;
    }
}