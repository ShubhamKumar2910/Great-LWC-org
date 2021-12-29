trigger TopicTrigger on Topic (after insert, after update, before delete) {

    System.debug('--TopicTrigger--');
    TopicTriggerHandler.mainEntry(Trigger.operationType, Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);

}