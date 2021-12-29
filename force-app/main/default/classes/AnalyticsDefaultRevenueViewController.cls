public without sharing class AnalyticsDefaultRevenueViewController {
	private final Analytics_User_Default__c userDefault;
    public AnalyticsDefaultRevenueViewController() {
        System.debug('User hitting AnalyticsDefaultRevenueViewController');
        System.debug('User value: ' + UserInfo.getUserId());
        userDefault = [SELECT Default_Revenue_Dashboard__c from Analytics_User_Default__c 
                        where User__c = : UserInfo.getUserId()];
        System.debug('User default dashboard for user ' + UserInfo.getName() + ' is '+ userDefault.Default_Revenue_Dashboard__c);
    }
    
    public String getDashboard() {
        return userDefault.Default_Revenue_Dashboard__c;
    }
}