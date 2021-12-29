public with sharing class MobileAnalyticsHomePageController {
    @AuraEnabled
    public static String getDefaultDashboardName() {
        String userId = UserInfo.getUserId();
        System.debug('>>>>getAnalyticUserDefaults for userId '+ userId);
        Analytics_User_Default__c aud = [SELECT Default_Revenue_Dashboard__c from Analytics_User_Default__c where User__c=:userId LIMIT 1];
        return aud.Default_Revenue_Dashboard__c;
    }
}