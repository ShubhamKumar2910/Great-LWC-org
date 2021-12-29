trigger SalesTeamForCoverageTrigger on Sales_Team_for_Coverage__c (before insert, before update, after insert, after update) {
    if(Trigger.isBefore && Trigger.isInsert){
        SalesTeamForCoverageTriggerHandler.onBeforeInsert(Trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        SalesTeamForCoverageTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
    
    if (Trigger.isAfter && Trigger.isInsert){
    	SalesTeamForCoverageTriggerHandler.onAfterInsert(Trigger.new, Trigger.oldMap);
    }
    
    if (Trigger.isAfter && Trigger.isUpdate){
    	SalesTeamForCoverageTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
    }
}