public class ContactListFilter {
    
    @AuraEnabled
    public String rgAccount {get; set;}
    @AuraEnabled
    public String rmAccount {get; set;}
    @AuraEnabled
    public String contactId {get; set;}
    @AuraEnabled
    public Boolean showNonCoveredContacts {get; set;}
    @AuraEnabled
    public String campaignId {get; set;}
    
    public ContactListFilter(){}
    
    public ContactListFilter(String strRGAccount, String strRMAccount, String strContactId, Boolean bShowNonCoveredContacts, String strCampaignId){
        rgAccount = strRGAccount;
        rmAccount = strRMAccount;
        contactId = strContactId;
        showNonCoveredContacts =  bShowNonCoveredContacts;
        campaignId = strCampaignId;
    }
}