trigger SalesTeamUserTrigger on Sales_Team_User__c (before insert, before update, after insert, after update) {
    if (Trigger.isAfter){
        //insert event
        if (Trigger.isInsert){
            SalesTeamUserTriggerHandler.onAfterInsert(Trigger.newMap);
        }
        else if (Trigger.isUpdate){
            SalesTeamUserTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
        }  

    }

}