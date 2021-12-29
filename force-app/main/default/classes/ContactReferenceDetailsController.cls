public without sharing class ContactReferenceDetailsController {
    public ContactReferenceDetailsController(){
        
    }
    
    @AuraEnabled
    public static List<AccordionSectionWrapper> getAccordionSectionDetails(){
        List<AccordionSectionWrapper> accordionSectionList = new List<AccordionSectionWrapper>();

		/* Tiering Reference Section */
        accordionSectionList.add(new AccordionSectionWrapper(System.Label.Tiering_Reference_Section,
                                                      System.Label.Tiering_Reference_Section,
                                                      'contactTieringRefSection',
                                                      'contactTieringRefSection',
                                                      'c:Tiering'));
        
      	return accordionSectionList;
    }
}