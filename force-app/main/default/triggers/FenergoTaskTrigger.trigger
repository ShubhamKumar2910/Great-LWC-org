/*
    Author      : Pravin Kundal
    Company     : Nomura
    Description : Trigger on the Fenergo_Task__c object   
                  that calls the FenergoTaskTriggerHandler. 
*/
trigger FenergoTaskTrigger on Fenergo_Task__c (before insert, before update, 
        after insert, after update) {
    System.debug('#### FenergoTaskTrigger : '+Trigger.operationType);
    FenergoTaskTriggerHandler.mainEntry(Trigger.operationType, Trigger.old, Trigger.new,
                                       Trigger.oldMap, Trigger.newMap);
}