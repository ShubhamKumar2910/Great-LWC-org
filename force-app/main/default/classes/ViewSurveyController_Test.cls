@istest
private class ViewSurveyController_Test{
    private static Testmethod void testViewSurveyController() {
        Test.startTest();
        
        SurveyTestingUtil testingUtil = new SurveyTestingUtil();
        String contactId = null;
        
        if(testingUtil.nomuraBusinessManagementUser != null && testingUtil.nomuraBusinessManagementUser.Id != null){
            System.runAs(testingUtil.nomuraBusinessManagementUser) {
                testingUtil.createTestSurvey();
                testingUtil.createTestQuestions();
                testingUtil.createAccountAndContacts();
                
                List<Contact> contactList = testingUtil.contactList;
                
                if(contactList != null && contactList.size() > 0){
                    if(contactList.get(0) != null && contactList.get(0).Id != null){
                        contactId = contactList.get(0).Id;
                    }
                }
                
                Apexpages.currentPage().getParameters().put('id',testingUtil.surveyId);
                Apexpages.currentPage().getParameters().put('cId',contactId); 
                Apexpages.Standardcontroller standardController;
                ViewSurveyController viewSurveyController = new ViewSurveyController(standardController); 
                viewSurveyController.init();
                System.assert(viewSurveyController.allQuestionsSize == 5);
                System.assert(testingUtil.surveyId != null);
        
        
                viewSurveyController.submitResults();
                for (SFQuestion questionObj : viewSurveyController.allQuestions)
                {
                    questionObj.selectedOption = 'Not Applicable';
                    questionObj.choices = 'Not Applicable';
                    questionObj.selectedOptions = new List<String>();
                    questionObj.selectedOptions.add('Not Applicable');
                    
                    questionObj.notes = 'Test';
                    
                    viewSurveyController.submitResults();
                }
                
                System.assertEquals(true, viewSurveyController.thankYouRendered);
                
                /* Updating Response */
                viewSurveyController.init();
                
                for (SFQuestion questionObj : viewSurveyController.allQuestions)
                {
                    questionObj.selectedOption = 'No';
                    questionObj.choices = 'No';
                    questionObj.selectedOptions = new List<String>();
                    questionObj.selectedOptions.add('No');
                    
                    questionObj.notes = 'Test Notes Updated';
                    
                    viewSurveyController.submitResults();
                }
                
                System.assertEquals(true, viewSurveyController.thankYouRendered);
            }
        }
        
		Test.stopTest();
        
    }


    private static Testmethod void testUpdateSurveyName() {
        Test.startTest();
        
        SurveyTestingUtil testingUtil = new SurveyTestingUtil();
        
        if(testingUtil.nomuraBusinessManagementUser != null && testingUtil.nomuraBusinessManagementUser.Id != null){
            System.runAs(testingUtil.nomuraBusinessManagementUser) {
                
                testingUtil.createTestSurvey();
                
                Apexpages.currentPage().getParameters().put('id',testingUtil.surveyId);
                Apexpages.Standardcontroller standardController;
                ViewSurveyController viewSurveyController = new ViewSurveyController(standardController);
                
                viewSurveyController.surveyName = 'Test Survey Updated';
                
                System.assert(viewSurveyController.updateSurveyName() == null);
                
                /* Fetch Survey Details */
                List<Survey__c> surveyList = [SELECT Id, Name, Start_Date__c, End_Date__c FROM Survey__c 
                                              WHERE Name = 'Test Survey Updated'];
                if(surveyList != null && surveyList.size() == 1){
                    Survey__c updatedSurveyObj = surveyList.get(0);
                    System.assertEquals(updatedSurveyObj.Name, viewSurveyController.surveyName);
                }
            }
        }
		
        Test.stopTest();
    }


    private static Testmethod void testupdateSurveyThankYouAndLink() {
        Test.startTest();
        
        SurveyTestingUtil testingUtil = new SurveyTestingUtil();
        
        if(testingUtil.nomuraBusinessManagementUser != null && testingUtil.nomuraBusinessManagementUser.Id != null){
            System.runAs(testingUtil.nomuraBusinessManagementUser) {
                
                testingUtil.createTestSurvey();
                
                Apexpages.currentPage().getParameters().put('id',testingUtil.surveyId);
                Apexpages.Standardcontroller standardController;
                ViewSurveyController viewSurveyController = new ViewSurveyController(standardController);
                viewSurveyController.surveyThankYouText = 'Test';
                viewSurveyController.surveyThankYouURL = 'Test';
                
                system.assert(viewSurveyController.updateSurveyThankYouAndLink() == null);
                
                List<Survey__c> surveyList = [SELECT Id, Name, Start_Date__c, End_Date__c, thankYouText__c, thankYouLink__c  
                                              FROM Survey__c 
                                              WHERE Name = 'Test Survey'];
                
                if(surveyList != null && surveyList.size() == 1){
                    Survey__c surveyObj = surveyList.get(0);
                    System.assertEquals(viewSurveyController.surveyThankYouText, surveyObj.thankYouText__c);
                    System.assertEquals(viewSurveyController.surveyThankYouURL, surveyObj.thankYouLink__c);
                }
            }
        }
        Test.stopTest();
    }


}