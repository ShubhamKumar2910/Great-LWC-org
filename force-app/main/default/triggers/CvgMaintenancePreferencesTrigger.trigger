trigger CvgMaintenancePreferencesTrigger on Coverage_Maintenance_Preferences__c (after insert, after update, after delete) {
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)){
        System.debug('Coverage Maintenance Trigger');
    	CvgMaintenancePreferencesTriggerHandler.onAfterInsert_Update_Delete(Trigger.new, Trigger.oldMap);
    }
}