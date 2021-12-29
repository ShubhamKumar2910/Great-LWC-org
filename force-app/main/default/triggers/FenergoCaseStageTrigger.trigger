trigger FenergoCaseStageTrigger on Fenergo_Case_Stage__c (before insert, before update, after insert, after update) {
    
    FenergoCaseStageTriggerHandler.mainEntry(Trigger.operationType, Trigger.old, Trigger.new,
                                        Trigger.oldMap, Trigger.newMap);
}