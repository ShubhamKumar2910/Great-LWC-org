/*
	Author 		: Pravin Kundal
	Company 	: Nomura
	Description : Trigger on the Onboarding_Product__c object   
				  that calls the OnboardingProductTriggerHandler. 
*/
trigger OnboardingProductTrigger on Onboarding_Product__c (before insert, before update, after delete, after insert) {
    System.debug('#### OnboardingProductTrigger : '+Trigger.operationType);
    OnboardingProductTriggerHandler.mainEntry(Trigger.operationType, Trigger.old, Trigger.new,
                                       Trigger.oldMap, Trigger.newMap);

}