@isTest
public class AccountReferenceDetailsControllerTest {
    
    @isTest 
    public static void getAccordionSectionDetailsTest() {
		
        Test.StartTest();
        
        AccountReferenceDetailsController accountRefDetailsControllerObj = new AccountReferenceDetailsController();
        List<AccordionSectionWrapper> accordionSectionList = AccountReferenceDetailsController.getAccordionSectionDetails();
        
		Test.StopTest();
        
        System.assert(accordionSectionList != null && accordionSectionList.size() > 0);
		
    }

}