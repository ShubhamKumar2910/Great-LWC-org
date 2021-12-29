//Trigger is called to update Opportunity topics when TopicAssignment is updated
trigger TopicAssignmentTrigger on TopicAssignment (before insert, before update, before delete, after insert, after update, after delete) {
    
    if(Trigger.isBefore && Trigger.isInsert){
        TopicAssignmentTriggerHandler.handleBeforeInsert(Trigger.new);
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        TopicAssignmentTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isBefore && Trigger.isDelete){
        TopicAssignmentTriggerHandler.handleBeforeDelete(Trigger.Old);    
    }
    if(Trigger.isAfter && Trigger.isInsert){
        TopicAssignmentTriggerHandler.handleAfterInsert(Trigger.New);
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        TopicAssignmentTriggerHandler.handleAfterUpdate(Trigger.oldMap,Trigger.newMap);
    }
    if(Trigger.isAfter && Trigger.isDelete){
        TopicAssignmentTriggerHandler.handleAfterDelete(Trigger.Old);
    }
    
}