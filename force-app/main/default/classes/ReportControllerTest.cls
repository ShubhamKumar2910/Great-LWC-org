@isTest
public class ReportControllerTest {
  
  @isTest(SeeAllData=true)
  public static void getReportIdTest() {
      Test.startTest();
       
      ReportController reportControllerObj = new ReportController();
      String strReportName = 'RG_Account_History_Report_wvt';
      String strReportId = ReportController.getReportId(strReportName);

      if(strReportId != null){
      	  
          //Fetch Already Existing Report
          List<Report> reportList = [SELECT Id, Name, DeveloperName FROM Report
                               	     WHERE DeveloperName =:strReportName];
          
          if(reportList != null && reportList.size() > 0){
              String strActualReportId = reportList.get(0).Id;
              System.assertEquals(strReportId, strActualReportId);
          }
      
      }
      
      Test.stopTest();  
	}
}