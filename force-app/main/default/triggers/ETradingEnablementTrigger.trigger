/*
	Author 		: Simon Foden
	Company 	: Nomura
	Date 		: 02/07/2018
	Description : Trigger on the ETradingEnablement object   
				  that calls the ETradingEnablementTriggerHandler. 
	
*/  
trigger ETradingEnablementTrigger on ETradingEnablement__c (before insert, after insert, before update, after update, after delete, after undelete) 
{
	System.debug('ETradingEnablementTrigger Trigger.operationType : '+Trigger.operationType);
	switch on Trigger.operationType  
	{
		when BEFORE_INSERT 
		{
			ETradingEnablementTriggerHandler.handleBeforeInsert(Trigger.new);
		}
		when AFTER_INSERT 
		{
			ETradingEnablementTriggerHandler.handleAfterInsert(Trigger.newMap);  
		}
		when BEFORE_UPDATE 
		{
			ETradingEnablementTriggerHandler.handleBeforeUpdate(Trigger.oldMap, Trigger.newMap); 
		}
		when AFTER_UPDATE 
		{
			ETradingEnablementTriggerHandler.handleAfterUpdate(Trigger.oldMap, Trigger.newMap); 
		}
	}
}