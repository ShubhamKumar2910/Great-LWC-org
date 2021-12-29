trigger LegalAgreementTrigger on Legal_Agreement__c (before insert) {
if(Trigger.isBefore && Trigger.isInsert){
        LegalAgreementTriggerHandler.handleBeforeInsert(Trigger.new);
    }
}