@isTest
public class ContactReferenceDetailsControllerTest {
    
    @isTest 
    public static void getAccordionSectionDetailsTest() {
		
        Test.StartTest();
        
        ContactReferenceDetailsController contactRefDetailsControllerObj = new ContactReferenceDetailsController();
        List<AccordionSectionWrapper> accordionSectionList = ContactReferenceDetailsController.getAccordionSectionDetails();
        
		Test.StopTest();
        
        System.assert(accordionSectionList != null && accordionSectionList.size() > 0);
		
    }

}