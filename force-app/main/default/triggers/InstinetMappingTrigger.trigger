trigger InstinetMappingTrigger on Instinet_Mapping__c (before insert, before delete, before update, 
                                                    after delete, after insert, after undelete) {
    if(Trigger.isBefore && Trigger.isUpdate){
        System.debug('--inside trigger--');
		InstinetMappingTriggerHandler.handleBeforeUpdate(Trigger.New, Trigger.OldMap);
    }
}