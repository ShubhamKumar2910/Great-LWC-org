public class A1Flows_LookupSearchResult {
    @AuraEnabled 
    public String id;
    @AuraEnabled 
    public String sObjectType;
    @AuraEnabled 
    public String icon;
    @AuraEnabled 
    public String title;
    @AuraEnabled 
    public String subtitle;
    @AuraEnabled 
    public Boolean isGMOrig;
    @AuraEnabled 
    public Boolean isInstinetOrig;
    @AuraEnabled 
    public Boolean isIBDOrig;
    @AuraEnabled 
    public String country;
    @AuraEnabled
    public Boolean isProspectFenergoManaged;
    @AuraEnabled
    public String accountParentId;
    @AuraEnabled
    public String onboardingContactType;

    public A1Flows_LookupSearchResult() {}
    public A1Flows_LookupSearchResult(String id, String sObjectType, String icon, String title, String subtitle, String onboardingContactType) {
        this.id = id;
        this.sObjectType = sObjectType;
        this.icon = icon;
        this.title = title;
        this.subtitle = subtitle;
        this.onboardingContactType = onboardingContactType;
    }

    public A1Flows_LookupSearchResult (String id, String sObjectType, String icon, String title, String subtitle, 
            Boolean isGMOrig, Boolean isInstinetOrig, Boolean isIBDOrig, String country, Boolean isProspectFenergoManaged, 
            String accountParentId) {
        this.id = id;
        this.sObjectType = sObjectType;
        this.icon = icon;
        this.title = title;
        this.subtitle = subtitle;
        this.isGMOrig = isGMOrig;
        this.isInstinetOrig = isInstinetOrig; 
        this.isIBDOrig = isIBDOrig;
        this.country = country;
        this.isProspectFenergoManaged = isProspectFenergoManaged;
        this.accountParentId = accountParentId;
        
    }
}