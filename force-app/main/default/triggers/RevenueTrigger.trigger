trigger RevenueTrigger on Revenue__c (after delete, after insert, after update, before insert, before update) {
    if (Trigger.isAfter)
    {
      //insert event
      if (Trigger.isInsert)
      {
        RevenueTriggerHandler.onAfterInsert(Trigger.newMap);
        //update event
      } else if (Trigger.isUpdate)
      {
          RevenueTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
         //}

        //delete event    
      } else if(Trigger.isDelete)
      {   
        RevenueTriggerHandler.onAfterDelete(Trigger.old);
      }
    } else if (Trigger.isBefore)
    {
      //insert event
      if (Trigger.isInsert)
      {
          RevenueTriggerHandler.onBeforeInsert(Trigger.new);    
        //update event
      } else if (Trigger.isUpdate)
      { 
        RevenueTriggerHandler.onBeforeUpdate(Trigger.newMap, Trigger.oldMap);
      }

    }
  
}