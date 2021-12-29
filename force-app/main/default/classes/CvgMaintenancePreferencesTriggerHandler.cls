public class CvgMaintenancePreferencesTriggerHandler {
    public static void onAfterInsert_Update_Delete(List<Coverage_Maintenance_Preferences__c> newRecords, Map<Id,Coverage_Maintenance_Preferences__c> oldRecordsMap) {
        System.debug('Coverage Maintenance Trigger Handler');
        Database.executeBatch(new PopulateCvgMaintenanceForSalescodeBatch(null),2000);
    }
}