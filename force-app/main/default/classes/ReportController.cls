public without sharing class ReportController {
    public ReportController() {

    }

    @AuraEnabled
    public static String getReportId(String reportDeveloperName){
      String strReportId = null;

      if(String.isNotEmpty(reportDeveloperName)){
        Report reportObj = [SELECT Id, Name, DeveloperName, FolderName FROM Report
                            WHERE DeveloperName = :reportDeveloperName
                            LIMIT 1
                           ];

        if(reportObj != null){
            strReportId = reportObj.Id;
        }
      }

      return strReportId;
    }
}