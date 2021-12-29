trigger RevenueRollupTrigger on Revenue_Rollup__c (after delete, after insert, after update, before insert, before update) {
    if (Trigger.isAfter)
    {
      //insert event
      if (Trigger.isInsert)
      {
        RevenueRollUpTriggerHandler.onAfterInsert(Trigger.newMap);
        //update event
      } else if (Trigger.isUpdate)
      {
          RevenueRollUpTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
         //}

        //delete event    
      } else if(Trigger.isDelete)
      {   
        RevenueRollUpTriggerHandler.onAfterDelete(Trigger.old);
      }
    } else if (Trigger.isBefore)
    {
      //insert event
      if (Trigger.isInsert)
      {
          RevenueRollUpTriggerHandler.onBeforeInsert(Trigger.new);    
        //update event
      } else if (Trigger.isUpdate)
      { 
        RevenueRollUpTriggerHandler.onBeforeUpdate(Trigger.newMap, Trigger.oldMap);
      }

    }
  
}