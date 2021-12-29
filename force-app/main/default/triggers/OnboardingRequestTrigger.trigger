/*
	Author 		: Pravin Kundal
	Company 	: Nomura
	Description : Trigger on the Onboarding_Request__c object   
				  that calls the OnboardingRequestTriggerHandler. 
*/
trigger OnboardingRequestTrigger on Onboarding_Request__c (before insert, before update, after insert, after update, before delete) {
    System.debug('#### OnboardingRequestTrigger : '+Trigger.operationType);
    OnboardingRequestTriggerHandler.mainEntry(Trigger.operationType, Trigger.old, Trigger.new,
                                       Trigger.oldMap, Trigger.newMap);

}