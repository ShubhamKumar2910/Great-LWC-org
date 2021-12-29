public class LegalAgreementTriggerHandler {

	public static void handleBeforeInsert(List<Legal_Agreement__c> newLegalAgreementList){
        LegalAgreementTriggerBL.populateLastSuccessfulLoadDateLookup(newLegalAgreementList);  
    }

}