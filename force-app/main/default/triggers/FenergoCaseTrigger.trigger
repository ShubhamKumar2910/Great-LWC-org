/*
    Author      : Pravin Kundal
    Company     : Nomura
    Description : Trigger on the Fenergo_Case__c object   
                  that calls the FenergoCaseTriggerHandler. 
*/ 
trigger FenergoCaseTrigger on Fenergo_Case__c (before insert, before update, 
        after insert, after update) {
    System.debug('#### FenergoCaseTrigger : '+Trigger.operationType);

    FenergoCaseTriggerHandler.mainEntry(Trigger.operationType, Trigger.old, Trigger.new,
                                       Trigger.oldMap, Trigger.newMap);
}