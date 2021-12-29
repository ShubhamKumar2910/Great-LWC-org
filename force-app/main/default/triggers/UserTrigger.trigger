trigger UserTrigger on User (before insert, before update, after insert, after update) {

   Nomura_Trigger_Activation__c triggerSettings = Nomura_Trigger_Activation__c.getInstance('UserTrigger');
    system.debug('triggerSettings :'+ triggerSettings);
    if((triggerSettings != null && triggerSettings.Active__c == true) || Test.isRunningTest()){
    
    if (Trigger.isAfter)
    {
        //insert event
        if (Trigger.isInsert)
        {
            UserTriggerHandler.onAfterInsert(Trigger.new, Trigger.oldMap, Trigger.newMap);

            //update event
        } else if (Trigger.isUpdate)
        { 
            UserTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap, Trigger.newMap);
        }

    }
    
    if(Trigger.isBefore && Trigger.isInsert){
        UserTriggerHandler.onBeforeInsert(Trigger.new);
    }
    else if(Trigger.isBefore && Trigger.isUpdate){
        UserTriggerHandler.onBeforeUpdate(Trigger.newMap, Trigger.oldMap);
    }
    }
}