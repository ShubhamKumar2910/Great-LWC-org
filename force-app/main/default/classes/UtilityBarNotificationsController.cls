public without sharing class UtilityBarNotificationsController {


	@AuraEnabled
	public static UserandSubscriptionDetails getSessionAndSubscriptionDtls() {    
   		UserandSubscriptionDetails usrDtls = new UserandSubscriptionDetails();
    	usrDtls.SessionId = UserInfo.getSessionId();
    	usrDtls.UserEventSubscriptionEnabled = [SELECT Id,Event_Subscription_Enabled__c FROM User WHERE Id=:UserInfo.getUserId()].Event_Subscription_Enabled__c;
    	usrDtls.OrgEventSubscriptionEnabled =  [SELECT Event_Subscribed__c from EventSubscription__c WHERE Name = 'SubscribeEvent' ].Event_Subscribed__c;
    	
  		return usrDtls;
	}
    
    @AuraEnabled
    public static String pendingApprovals(){
        String approvalsCount = BulkApprovalController.pendingApprovals();
        
        return approvalsCount;
    }

	


}