trigger ExternalCodeMappingTrigger on External_Code_Mapping__c (before insert, after insert, before delete, after delete) {
    
    System.debug('--ExternalCodeMappingTrigger--');
    Nomura_Trigger_Activation__c triggerSettings = Nomura_Trigger_Activation__c.getInstance('ExternalCodeMappingTrigger');
    
    if(triggerSettings != null && triggerSettings.Active__c == true){
        ExternalCodeMappingTriggerHandler.mainEntry(Trigger.operationType, Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
    }
}