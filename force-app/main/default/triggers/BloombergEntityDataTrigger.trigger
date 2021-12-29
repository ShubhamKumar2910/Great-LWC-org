trigger BloombergEntityDataTrigger on Bloomberg_Entity_Data__c (before insert, before update, after insert, after update) {

    System.debug('#### BloombergEntityDataTrigger : ' + Trigger.operationType);

    BloombergEntityDataTriggerHandler.mainEntry(Trigger.operationType, Trigger.old, Trigger.new,
                                       Trigger.oldMap, Trigger.newMap);
}