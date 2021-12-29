trigger RevenueKPITrigger on Revenue_KPI__c (after insert) {

	if (Trigger.isAfter)  { 
		//insert event
      	if (Trigger.isInsert) {
        	RevenueKPITriggerHandler.onAfterInsert(Trigger.newMap);
      	}
    }
}