trigger AnalyticsUserDefaultTrigger on Analytics_User_Default__c (after delete, after insert, after update, before insert, before update) {
    if (Trigger.isAfter)  {
      //insert event
      if (Trigger.isInsert) {
        AnalyticsUserDefaultTriggerHandler.onAfterInsert(Trigger.newMap);
        //update event
      } else if (Trigger.isUpdate) {
          AnalyticsUserDefaultTriggerHandler.onAfterUpdate(Trigger.newMap);
      }
    } 
}