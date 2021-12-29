@isTest
public class AccordionSectionWrapperTest {
    
    @isTest 
    public static void AccordionSectionWithParamsTest() {
		
        Test.StartTest();
        
		AccordionSectionWrapper accordionSection = new AccordionSectionWrapper('Tiering Reference',
                                                                              'Tiering Reference',
                                                                              'contactTieringRefSection',
                                                                              'contactTieringRefSection',
                                                                              'c:Tiering');
		Test.StopTest();
		
        System.assertNotEquals(accordionSection, null);
        System.assertEquals('Tiering Reference', accordionSection.label);
        System.assertEquals('Tiering Reference', accordionSection.title);
        System.assertEquals('contactTieringRefSection', accordionSection.name);
        System.assertEquals('contactTieringRefSection', accordionSection.auraId);
        System.assertEquals('c:Tiering', accordionSection.cmpName);
	}
    
    @isTest 
    public static void AccordionSectionWithoutParamsTest() {
		
        Test.StartTest();
        
		AccordionSectionWrapper accordionSection = new AccordionSectionWrapper();
        
		Test.StopTest();
		
        System.assertNotEquals(accordionSection, null);
        
	}

}