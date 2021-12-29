@isTest
public class ActivityReportControllerTest {

   @isTest(SeeAllData=true) 
  public static void getActivityReportIdTest() {
	  Test.startTest();
       string RMRecordType = [SELECT Id from RecordType where Name = 'RM Account'][0].Id;
       string recordId = [SELECT Id, Name from Account where recordTypeId = :  RMRecordType][0].Id;
       string whichCall = 'Interactions';
     
      ActivityReportController actyRptController = new ActivityReportController();
      String ReportName = 'All_Events_for_a_Contact';
      String strReportId = ActivityReportController.getActivityReportIdRecordName(ReportName,recordId,whichCall);
      if(strReportId != null){
      	  
          //Fetch Already Existing Report
          List<Report> reportList = [SELECT Id, Name, DeveloperName FROM Report
                               	     WHERE DeveloperName = 'All_Events_for_a_Contact'];
          
          if(reportList != null && reportList.size() > 0){
              String strActualReportId = reportList.get(0).Name;
              //System.assertEquals(strReportId, strActualReportId);
          }
      
      }
      
      Test.stopTest();  
	}
}