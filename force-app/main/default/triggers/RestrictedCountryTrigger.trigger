trigger RestrictedCountryTrigger on Restricted_Countries__c (after insert, after delete) {
    if(Trigger.isInsert){
        RestrictedCountryTriggerHandler.MarkRMAccountsAsRestricted(Trigger.new);
    }
    
    if(Trigger.isDelete){
        RestrictedCountryTriggerHandler.MarkRMAccountsAsUnrestricted(Trigger.old);
    }

}