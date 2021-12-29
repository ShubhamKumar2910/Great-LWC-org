@istest
private class SurveyAndQuestionController_Test {

    @isTest
    private static void testCreateQuestionController(){
        Test.startTest();
        
        SurveyTestingUtil testingUtil = new SurveyTestingUtil();
        
        if(testingUtil.nomuraBusinessManagementUser != null && testingUtil.nomuraBusinessManagementUser.Id != null){
            System.runAs(testingUtil.nomuraBusinessManagementUser) {
                
                testingUtil.createTestSurvey();
                
                Apexpages.currentPage().getParameters().put('id',testingUtil.surveyId);
                Apexpages.Standardcontroller standardController;
                SurveyAndQuestionController surveyAndQuestionController = new SurveyAndQuestionController(standardController);
                surveyAndQuestionController.addQuestion();
                surveyAndQuestionController.getNewQuestionNum();
                surveyAndQuestionController.makeNewQuestionLink();
                surveyAndQuestionController.startUpload();
                System.assert(surveyAndQuestionController.surveyId == testingUtil.surveyId);
            }
        }
        
        Test.stopTest();
    }

    @isTest
    private static void testEditQuestion(){
        Test.startTest();
        
        SurveyTestingUtil testingUtil = new SurveyTestingUtil();
        
         if(testingUtil.nomuraBusinessManagementUser != null && testingUtil.nomuraBusinessManagementUser.Id != null){
            System.runAs(testingUtil.nomuraBusinessManagementUser) {
                
                testingUtil.createTestSurvey();
        		testingUtil.createTestQuestions();
                
                Apexpages.currentPage().getParameters().put('id',testingUtil.surveyId);
                Apexpages.Standardcontroller standardController;
                SurveyAndQuestionController surveyAndQuestionController = new SurveyAndQuestionController(standardController);
                
                surveyAndQuestionController.editQuestion();
                surveyAndQuestionController.questionReference = testingUtil.questionIds[0];
                surveyAndQuestionController.editQuestion();
                surveyAndQuestionController.questionReference = testingUtil.questionIds[1];
                surveyAndQuestionController.editQuestion();
                surveyAndQuestionController.questionReference = testingUtil.questionIds[2];
                surveyAndQuestionController.editQuestion();
                surveyAndQuestionController.questionReference = testingUtil.questionIds[3];
                surveyAndQuestionController.editQuestion();
                surveyAndQuestionController.questionReference = testingUtil.questionIds[4];
                
                System.assert(surveyAndQuestionController.editQuestion() == null);
            }
         }
        
         Test.stopTest();

    }

    @isTest
    private static void testSaveAndNewQuestion(){
        Test.startTest();
        
        SurveyTestingUtil testingUtil = new SurveyTestingUtil();
       
        if(testingUtil.nomuraBusinessManagementUser != null && testingUtil.nomuraBusinessManagementUser.Id != null){
            System.runAs(testingUtil.nomuraBusinessManagementUser) {
                
                testingUtil.createTestSurvey();
        		testingUtil.createTestQuestions();
                
                Apexpages.currentPage().getParameters().put('id',testingUtil.surveyId);
                Apexpages.Standardcontroller standardController;
                SurveyAndQuestionController surveyAndQuestionCtrlForAdd = new SurveyAndQuestionController(standardController);
                //test saving new question
                surveyAndQuestionCtrlForAdd.qChoices = 'Yes' + '\r\n' + 'No' + '\r\n' + 'Not Applicable' + '\r\n' + 'None';
                surveyAndQuestionCtrlForAdd.questionType='Single Select--Horizontal';
                surveyAndQuestionCtrlForAdd.qCategory = 'Aerospace and Defense';
                surveyAndQuestionCtrlForAdd.surveyQuestionObj.Member__c = testingUtil.nomuraResearchUser.Id;
                surveyAndQuestionCtrlForAdd.saveAndNewQuestion();
                System.assertEquals(6, surveyAndQuestionCtrlForAdd.getNewQuestionNum());
        
                //edit existing question
                SurveyAndQuestionController surveyAndQuestionCtrlForEdit = new SurveyAndQuestionController(standardController);
                surveyAndQuestionCtrlForEdit.questionReference = testingUtil.questionIds[0];
                surveyAndQuestionCtrlForEdit.editQuestion();
                surveyAndQuestionCtrlForEdit.qChoices = 'Yes' + '\r\n' + 'No' + '\r\n' + 'Not Applicable' + '\r\n' + 'None';
                surveyAndQuestionCtrlForEdit.questionType='Single Select--Horizontal';
                surveyAndQuestionCtrlForEdit.qCategory = 'Banking';
                surveyAndQuestionCtrlForEdit.surveyQuestionObj.Member__c = testingUtil.nomuraResearchUser.Id;
                surveyAndQuestionCtrlForEdit.saveAndNewQuestion();
                System.assertEquals(6, surveyAndQuestionCtrlForEdit.getNewQuestionNum());
            }
       }
        
       Test.stopTest(); 
    }

    @isTest
    private static void testSaveSaveQuestion(){
        Test.startTest();
        
        SurveyTestingUtil testingUtil = new SurveyTestingUtil();
        
         if(testingUtil.nomuraBusinessManagementUser != null && testingUtil.nomuraBusinessManagementUser.Id != null){
            System.runAs(testingUtil.nomuraBusinessManagementUser) {
                
                testingUtil.createTestSurvey();
        		testingUtil.createTestQuestions();
                
                Apexpages.currentPage().getParameters().put('id',testingUtil.surveyId);
                Apexpages.Standardcontroller standardController;
                SurveyAndQuestionController surveyAndQuestionCtrlForAdd = new SurveyAndQuestionController(standardController);
                //test saving new question
                surveyAndQuestionCtrlForAdd.qChoices = 'Yes' + '\r\n' + 'No' + '\r\n' + 'Not Applicable' + '\r\n' + 'None';
                surveyAndQuestionCtrlForAdd.questionType='Single Select--Horizontal';
                surveyAndQuestionCtrlForAdd.qCategory = 'Aerospace and Defense';
                surveyAndQuestionCtrlForAdd.surveyQuestionObj.Member__c = testingUtil.nomuraResearchUser.Id;
                surveyAndQuestionCtrlForAdd.controllerSavQuestion();
                System.assertEquals(6, surveyAndQuestionCtrlForAdd.getNewQuestionNum());
                
                //edit existing question
                SurveyAndQuestionController surveyAndQuestionCtrlForEdit = new SurveyAndQuestionController(standardController);
                surveyAndQuestionCtrlForEdit.questionReference = testingUtil.questionIds[0];
                surveyAndQuestionCtrlForEdit.editQuestion();
                surveyAndQuestionCtrlForEdit.qChoices = 'Yes' + '\r\n' + 'No' + '\r\n' + 'Not Applicable' + '\r\n' + 'None';
                surveyAndQuestionCtrlForEdit.questionType='Single Select--Horizontal';
                surveyAndQuestionCtrlForEdit.qCategory = 'Banking';
                surveyAndQuestionCtrlForEdit.surveyQuestionObj.Member__c = testingUtil.nomuraResearchUser.Id;
                surveyAndQuestionCtrlForEdit.controllerSavQuestion();
                System.assertEquals(6, surveyAndQuestionCtrlForEdit.getNewQuestionNum());
            }
         }
    	
        Test.stopTest();
    }

    @isTest
    private static void testPreviewQuestion(){
        Test.startTest();
        
        SurveyTestingUtil testingUtil = new SurveyTestingUtil();
        
        if(testingUtil.nomuraBusinessManagementUser != null && testingUtil.nomuraBusinessManagementUser.Id != null){
            System.runAs(testingUtil.nomuraBusinessManagementUser) {
                
                testingUtil.createTestSurvey();
        		testingUtil.createTestQuestions();
                
                Apexpages.currentPage().getParameters().put('id',testingUtil.surveyId);
                Apexpages.Standardcontroller standardController;
                SurveyAndQuestionController surveyAndQuestionController = new SurveyAndQuestionController(standardController);
        
                surveyAndQuestionController.questionReference = testingUtil.questionIds[0];
                surveyAndQuestionController.editQuestion();
                surveyAndQuestionController.previewQuestion();
        
                surveyAndQuestionController.questionReference = testingUtil.questionIds[1];
                surveyAndQuestionController.editQuestion();
                surveyAndQuestionController.previewQuestion();
        
                surveyAndQuestionController.questionReference = testingUtil.questionIds[2];
                surveyAndQuestionController.editQuestion();
                surveyAndQuestionController.previewQuestion();
        
                surveyAndQuestionController.questionReference = testingUtil.questionIds[3];
                surveyAndQuestionController.editQuestion();
                surveyAndQuestionController.previewQuestion();
                
                surveyAndQuestionController.questionReference = testingUtil.questionIds[4];
                surveyAndQuestionController.editQuestion();
                surveyAndQuestionController.previewQuestion();
            }
        }
		Test.stopTest();
    }


    @isTest
    private static void testUpdateSurveyDetails() {
        Test.startTest();
        
        SurveyTestingUtil testingUtil = new SurveyTestingUtil();
        
        if(testingUtil.nomuraBusinessManagementUser != null && testingUtil.nomuraBusinessManagementUser.Id != null){
            System.runAs(testingUtil.nomuraBusinessManagementUser) {
                
                testingUtil.createTestSurvey();
                
                Apexpages.currentPage().getParameters().put('id',testingUtil.surveyId);
                Apexpages.Standardcontroller standardController;
                SurveyAndQuestionController surveyAndQuestionController = new SurveyAndQuestionController(standardController);
                surveyAndQuestionController.surveyName = 'Test Survey Updated';
                
                System.assert(surveyAndQuestionController.updateSurveyName() == null);
                
                List<Survey__c> surveyList = [SELECT Id, Name, Start_Date__c, End_Date__c FROM Survey__c 
                                              WHERE Name = 'Test Survey Updated'];
                
                if(surveyList != null && surveyList.size() == 1){
                    Survey__c surveyObj = surveyList.get(0);
                    System.assertEquals(surveyAndQuestionController.surveyName, surveyObj.Name);
                }
            }
        }
        
        Test.stopTest();
    }


    @isTest
    private static void testupdateSurveyThankYouAndLink() {
        Test.startTest();
        
        SurveyTestingUtil testingUtil = new SurveyTestingUtil();
        
        if(testingUtil.nomuraBusinessManagementUser != null && testingUtil.nomuraBusinessManagementUser.Id != null){
            System.runAs(testingUtil.nomuraBusinessManagementUser) {
               
                testingUtil.createTestSurvey();
                
                Apexpages.currentPage().getParameters().put('id',testingUtil.surveyId);
                Apexpages.Standardcontroller standardController;
                SurveyAndQuestionController surveyAndQuestionController = new SurveyAndQuestionController(standardController);
                surveyAndQuestionController.surveyThankYouText = 'Test';
                surveyAndQuestionController.surveyThankYouURL = 'Test';
                
                System.assert(surveyAndQuestionController.updateSurveyThankYouAndLink() == null);
                
                List<Survey__c> surveyList = [SELECT Id, Name, Start_Date__c, End_Date__c, thankYouText__c, thankYouLink__c  
                                              FROM Survey__c 
                                              WHERE Name = 'Test Survey'];
                
                if(surveyList != null && surveyList.size() == 1){
                    Survey__c surveyObj = surveyList.get(0);
                    System.assertEquals(surveyAndQuestionController.surveyThankYouText, surveyObj.thankYouText__c);
                    System.assertEquals(surveyAndQuestionController.surveyThankYouURL, surveyObj.thankYouLink__c);
                }
            }
        }
        
        Test.stopTest();
    }

    //------------------------------------------------------------------------------//

    @isTest
    private static void testRefreshQuestionList() {
        Test.startTest();
        
        SurveyTestingUtil testingUtil = new SurveyTestingUtil();
       
         if(testingUtil.nomuraBusinessManagementUser != null && testingUtil.nomuraBusinessManagementUser.Id != null){
            System.runAs(testingUtil.nomuraBusinessManagementUser) {
                
                testingUtil.createTestSurvey();
        		testingUtil.createTestQuestions();
                
                Apexpages.currentPage().getParameters().put('id',testingUtil.surveyId);
                Apexpages.Standardcontroller standardController;
                SurveyAndQuestionController surveyAndQuestionController = new SurveyAndQuestionController(standardController);
                surveyAndQuestionController.getAQuestion();
        
                // Retrieve questions for this survey
                List<Survey_Question__c> surveyQuestionList = new List<Survey_Question__c>();
                surveyQuestionList = [SELECT Id, orderNumber__c FROM Survey_Question__c 
                                      WHERE Survey__c = :testingUtil.surveyId];
        
                // get question with orderNumber 1
                Survey_Question__c firstQuestion = [SELECT Id, orderNumber__c FROM Survey_Question__c 
                                                    WHERE orderNumber__c = 1 AND Survey__c =:testingUtil.surveyId];
                System.assert(firstQuestion.orderNumber__c == 1 );
                
                // Specify the new order
                surveyAndQuestionController.newOrderW = surveyAndQuestionController.allQuestions[2].Id + ',' +
                        surveyAndQuestionController.allQuestions[0].Id + ',' +
                        surveyAndQuestionController.allQuestions[1].Id + ',' +
                        surveyAndQuestionController.allQuestions[3].Id + ',' +
                        surveyAndQuestionController.allQuestions[4].Id + ',';
        
                surveyAndQuestionController.updateOrderList();
        
                // Verify that the question with order 1 is not the same as the one retrieved previously
                Survey_Question__c secondQuestion = [SELECT Id, orderNumber__c FROM Survey_Question__c 
                                                     WHERE orderNumber__c = 1 AND Survey__c =:testingUtil.surveyId];
                System.assert(secondQuestion.Id != firstQuestion.Id);
        
                // update the question list, and make sure it has been modified as well
                surveyAndQuestionController.refreshQuestionList();
                System.assert(surveyAndQuestionController.allQuestions[1].Id != firstQuestion.Id);
            }
        }
        
        Test.stopTest();
    }

//------------------------------------------------------------------------------//

    @isTest
    private static void testDeleteQuestion() {
        Test.startTest();
        
        SurveyTestingUtil testingUtil = new SurveyTestingUtil();
       
        if(testingUtil.nomuraBusinessManagementUser != null && testingUtil.nomuraBusinessManagementUser.Id != null){
            System.runAs(testingUtil.nomuraBusinessManagementUser) {
                
                testingUtil.createTestSurvey();
        		testingUtil.createTestQuestions();
                
                Apexpages.currentPage().getParameters().put('id',testingUtil.surveyId);
                Apexpages.Standardcontroller standardController;
                SurveyAndQuestionController surveyAndQuestionController = new SurveyAndQuestionController(standardController);
        
        
                // Get a question to delete
                Survey_Question__c surveyQuestionFirst = [SELECT Id, orderNumber__c FROM Survey_Question__c 
                                                          WHERE orderNumber__c = 1 and Survey__c = :testingUtil.surveyId];
                surveyAndQuestionController.questionReference = surveyQuestionFirst.Id;
                surveyAndQuestionController.deleteRefresh();
        
                Survey_Question__c surveyQuestionSecond = [SELECT Id, orderNumber__c FROM Survey_Question__c 
                                                           WHERE orderNumber__c = 1 and Survey__c =:testingUtil.surveyId];
                System.assert(surveyQuestionFirst.Id != surveyQuestionSecond.Id);
            }
        }

		Test.stopTest();
    }
//------------------------------------------------------------------------------//


/**/
}