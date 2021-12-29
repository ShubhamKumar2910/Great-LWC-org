@isTest
public class SurveyDynamicCustomLinkController_Test {

    static testmethod void testSurveyDynamicCustomLinkController(){
    	Test.startTest();
        
        SurveyTestingUtil testingUtil = new SurveyTestingUtil();
        Contact contactObj = null;
        
         if(testingUtil.nomuraBusinessManagementUser != null && testingUtil.nomuraBusinessManagementUser.Id != null){
            System.runAs(testingUtil.nomuraBusinessManagementUser) {
            	testingUtil.createTestSurvey();
                testingUtil.createTestQuestions();
            }
        }
        
        if(testingUtil.nomuraSalesUser != null && testingUtil.nomuraSalesUser.Id != null){
            System.runAs(testingUtil.nomuraSalesUser) {
                
                testingUtil.createAccountAndContacts();
                
                List<Contact> contactList = testingUtil.contactList;
                
                if(contactList != null && contactList.size() > 0){
                    if(contactList.get(0) != null && contactList.get(0).Id != null){
                        contactObj = contactList.get(0);
                    }
                }
            	
                Test.setCurrentPageReference(new PageReference('Page.SurveyDynamicCustomLink')); 
    	 		System.currentPageReference().getParameters().put('id', contactObj.Id);
    	
    	 		SurveyDynamicCustomLinkController controllerObj = new SurveyDynamicCustomLinkController(new ApexPages.StandardController(contactObj));
                controllerObj.getSurveyDynamicCustomLinks();
            }
        }
        
        Test.stopTest();
    }
    
    static testmethod void testSurveyDynamicCustomLinkControllerWithNoSurvey(){
    	Test.startTest();
        
        SurveyTestingUtil testingUtil = new SurveyTestingUtil();
        Contact contactObj = null;
        
        if(testingUtil.nomuraSalesUser != null && testingUtil.nomuraSalesUser.Id != null){
            System.runAs(testingUtil.nomuraSalesUser) {
                
                testingUtil.createAccountAndContacts();
                
                List<Contact> contactList = testingUtil.contactList;
                
                if(contactList != null && contactList.size() > 0){
                    if(contactList.get(0) != null && contactList.get(0).Id != null){
                        contactObj = contactList.get(0);
                    }
                }
            	
                Test.setCurrentPageReference(new PageReference('Page.SurveyDynamicCustomLink')); 
    	 		System.currentPageReference().getParameters().put('id', contactObj.Id);
    	
    	 		SurveyDynamicCustomLinkController controllerObj = new SurveyDynamicCustomLinkController(new ApexPages.StandardController(contactObj));
                controllerObj.getSurveyDynamicCustomLinks();
            }
        }
        
        Test.stopTest();
    }
        
}