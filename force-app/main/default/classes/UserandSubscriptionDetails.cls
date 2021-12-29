public class UserandSubscriptionDetails {
    
        @AuraEnabled public string SessionId {get;set;}
        @AuraEnabled public boolean UserEventSubscriptionEnabled {get;set;}
        @AuraEnabled public boolean OrgEventSubscriptionEnabled {get;set;}
     
}