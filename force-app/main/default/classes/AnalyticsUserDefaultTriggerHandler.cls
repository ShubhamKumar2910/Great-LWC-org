public with sharing class AnalyticsUserDefaultTriggerHandler {
    public static void onAfterInsert(Map<Id, Analytics_User_Default__c> newRecords ) {      
        AnalyticUserDefaultBL.CreateAUDShareRecords(newRecords);
    }
    public static void onAfterUpdate(Map<Id, Analytics_User_Default__c> newRecords) {
       AnalyticUserDefaultBL.CreateAUDShareRecords(newRecords);          
    }
}