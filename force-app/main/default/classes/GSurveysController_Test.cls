@isTest
private class GSurveysController_Test {

    private static TestMethod void testGSurveysController(){
        
        Test.startTest();
        
        SurveyTestingUtil testingUtil = new SurveyTestingUtil();
        
        if(testingUtil.nomuraBusinessManagementUser != null && testingUtil.nomuraBusinessManagementUser.Id != null){
            System.runAs(testingUtil.nomuraBusinessManagementUser) {
                Date startDate = System.today();
                
                Survey__c surveyObj = new Survey__c(Name = 'Test Survey', Start_Date__c = startDate, End_Date__c = startDate.addDays(7));
                Apexpages.Standardcontroller standardController = new ApexPages.StandardController(surveyObj);
                GSurveysController surveyController = new GSurveysController(standardController);
                
                String saveURL = surveyController.save().getURL();
                String surveyURL = '/apex/SurveyManagerPage?id='+surveyController.survey.Id;
                
                System.assertEquals(surveyUrl, saveUrl);
                
                List<Survey__c> surveyList = [SELECT Id, Name, Start_Date__c, End_Date__c FROM Survey__c 
                                              WHERE Name = 'Test Survey'];
                
                System.assertEquals(surveyList.size(), 1);
                
                System.assertEquals(null, surveyController.pageMessage.message);
            }
        }
        
        Test.stopTest();
    }

}