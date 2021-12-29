@isTest
private class SurveyManagerController_Test {
    @isTest
    private static void doTest(){
        Test.startTest();
        
        SurveyTestingUtil testingUtil = new SurveyTestingUtil();
        
        if(testingUtil.nomuraBusinessManagementUser != null && testingUtil.nomuraBusinessManagementUser.Id != null){
            System.runAs(testingUtil.nomuraBusinessManagementUser) {
                Date startDate = System.today();
                
                PageReference pageReference = Page.SurveyManagerPage;
                Test.setCurrentPage(pageReference);
                
                Survey__c surveyObj = new Survey__c();
                surveyObj.Name = 'Test Survey';
                surveyObj.Start_Date__c = startDate;
                surveyObj.End_Date__c = startDate.addDays(7);
                
                insert surveyObj;
                
                ApexPages.StandardController standardController = new ApexPages.StandardController(surveyObj);
                SurveyManagerController surveyManagerController = new SurveyManagerController(standardController);
                
                System.assertEquals(surveyManagerController.surveyId, surveyObj.Id);
                
                /* Update surveyObj */
                surveyObj.Start_date__c = startDate.addDays(1);
                
                surveyManagerController.save();
                
                /* Fetch Survey Details */
                List<Survey__c> surveyList = [SELECT Id, Name, Start_Date__c, End_Date__c FROM Survey__c 
                                              WHERE Name = 'Test Survey'];
                if(surveyList != null && surveyList.size() == 1){
                    Survey__c updatedSurveyObj = surveyList.get(0);
                    System.assertEquals(updatedSurveyObj.Start_Date__c, startDate.addDays(1));
                }
                
                /* Again Update surveyObj with Start Date greater than End Date*/
                try {
                    surveyObj.Start_date__c = surveyObj.End_Date__c.addDays(1);
                    surveyManagerController.save();
                }
                catch(Exception exObj){
                    System.assert(exObj.getMessage().contains('End Date Should be later than Start Date'));
                }
            }
        }
        
        Test.stopTest();
    }
}