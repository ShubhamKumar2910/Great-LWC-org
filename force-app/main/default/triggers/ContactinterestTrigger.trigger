trigger ContactinterestTrigger on Contact_Interest__c ( before delete, before insert, before update,
                             after delete, after insert, after update, after undelete) {
    if (Trigger.isbefore && (Trigger.isUpdate)) {
			System.debug('After update trigger');
        	ContactInterestController.validateForDuplicates(Trigger.new);
    }  
    if (Trigger.isbefore && (Trigger.isInsert)) {
        System.debug('After insert trigger');
        List<Contact_Interest__c> cisToBeValidated = new List<Contact_Interest__c>();
        for (Contact_Interest__c ci: Trigger.new) {
            System.debug(ci.Market_Picklist__c);
            System.debug(ci);
            if (ci.Market_Picklist__c == null && ci.Asset_Picklist__c == null && ci.Sectort_Picklist__c ==null) {
                cisToBeValidated.add(ci);
            }
        }
        System.debug('No of cis to be validated = ' + cisToBeValidated.size());
        if (cisToBeValidated.size() > 0) {
            ContactInterestController.validateForDuplicates(cisToBeValidated);
        }
    }                                  
                                 
}