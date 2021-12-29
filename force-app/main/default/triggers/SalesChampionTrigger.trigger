trigger SalesChampionTrigger on Sales_Champion__c (before insert, before update, before delete, after insert, after delete,after update) {
    if(Trigger.isBefore && Trigger.isInsert){
        SalesChampionTriggerHandler.handleBeforeInsert(Trigger.new);
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        SalesChampionTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isBefore && Trigger.isDelete){
        SalesChampionTriggerHandler.handleBeforeDelete(Trigger.oldMap);
    }
    if(Trigger.isAfter && Trigger.isInsert){
        SalesChampionTriggerHandler.handleAfterInsert(Trigger.oldMap,Trigger.newMap);
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        SalesChampionTriggerHandler.handleAfterUpdate(Trigger.oldMap,Trigger.newMap);
    }
    if(Trigger.isAfter && Trigger.isDelete){
        SalesChampionTriggerHandler.handleAfterDelete(Trigger.oldMap,Trigger.newMap);
    }
    
}