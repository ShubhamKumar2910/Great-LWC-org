public without sharing class AccountReferenceDetailsController {
    
    public AccountReferenceDetailsController(){
        
    }
    
    @AuraEnabled
    public static List<AccordionSectionWrapper> getAccordionSectionDetails(){
        List<AccordionSectionWrapper> accordionSectionList = new List<AccordionSectionWrapper>();

		/* Tiering Reference Section */
        accordionSectionList.add(new AccordionSectionWrapper(System.Label.Tiering_Reference_Section,
                                                      System.Label.Tiering_Reference_Section,
                                                      'accTieringRefSection',
                                                      'accTieringRefSection',
                                                      'c:Tiering'));
        
        /* Focus List Section */
        accordionSectionList.add(new AccordionSectionWrapper(System.Label.Focus_List_Section,
                                                      System.Label.Focus_List_Section,
                                                      'accFocusListSection',
                                                      'accFocusListSection',
                                                      'c:FocusList'));
            
        return accordionSectionList;
    }
    
}