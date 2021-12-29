/*
	Author 		: Pravin Kundal
	Company 	: Nomura
	Description : Trigger on the SCH_Request__c object   
				  that calls the SchRequestTriggerHandler. 
*/ 
trigger SchRequestTrigger on SCH_Request__c (before insert, before update, after insert, after update) {
    System.debug('#### SchRequestTrigger : '+Trigger.operationType);

    SchRequestTriggerHandler.mainEntry(Trigger.operationType, Trigger.old, Trigger.new,
                                       Trigger.oldMap, Trigger.newMap);
}