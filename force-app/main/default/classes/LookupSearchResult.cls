// Reference: https://github.com/pozil/sfdc-ui-lookup-lwc
/**
* Class used to serialize a single Lookup search result item
* The Lookup controller returns a List<LookupSearchResult> when sending search result back to Lightning
*/
public class LookupSearchResult {

    //common
    private Id id;
    private String sObjectType;
    private String icon;
    private String title;
    private String subtitle;
    private String titleWithSubtitle;
    //for Saving complete Sobject
    private SObject resultData; 

    public LookupSearchResult(Id id, String sObjectType, String icon, String title, String subtitle) {
        this.id = id;
        this.sObjectType = sObjectType;
        this.icon = icon;
        this.title = title;
        this.subtitle = subtitle;
    }

    // for Sales Person Lookup
    public LookupSearchResult(Id id, String sObjectType, String icon, String title, String subtitle, SObject resultData) {
        this.id = id;
        this.sObjectType = sObjectType;
        this.icon = icon;
        this.title = title;
        this.subtitle = subtitle;
        this.titleWithSubtitle = title + ' ' + subtitle;
        this.resultData = resultData;
    }

    @AuraEnabled
    public Id getId() {
        return id;
    }

    @AuraEnabled
    public String getSObjectType() {
        return sObjectType;
    }

    @AuraEnabled
    public String getIcon() {
        return icon;
    }

    @AuraEnabled
    public String getTitle() {
        return title;
    }

    @AuraEnabled
    public String getSubtitle() {
        return subtitle;
    }

    @AuraEnabled
    public String getTitleWithSubtitle(){
        return titleWithSubtitle;
    }

    @AuraEnabled
    public SObject getResultData() {
        return resultData;
    }
}