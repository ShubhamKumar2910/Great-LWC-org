public class AnalyticsAccountControllerExtension {
  private final Analytics_User_Default__c userDefault;
    private final Account acct;
    
    public AnalyticsAccountControllerExtension(ApexPages.StandardController stdController) {
        Account a = (Account) stdController.getRecord();
        userDefault = [SELECT id from Analytics_User_Default__c where User__c = : UserInfo.getUserId()];
        acct = [SELECT RDM_Org_ID__c from Account where id=:a.id];
    }
    
    public String getClientScorecard() {
        //return userDefault.Default_Client_Scorecard__c;
        return '';
    }
    
    public String getRdmOrgId() {
        return acct.RDM_Org_ID__c;
    }

}