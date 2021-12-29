public class RestrictedCountryTriggerHandler {
    
    public static void MarkRMAccountsAsRestricted(List<Restricted_Countries__c> newRecords){
        RestrictedCountryBL.setUnsetRestrictedAccounts(newRecords, true);
        
    }
    
     public static void MarkRMAccountsAsUnrestricted(List<Restricted_Countries__c> oldRecords){
        RestrictedCountryBL.setUnsetRestrictedAccounts(oldRecords, false);
    }

}