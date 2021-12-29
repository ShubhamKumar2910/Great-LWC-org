public without sharing class ActivityReportController {
    
    public ActivityReportController(){
        
    }
    
    @AuraEnabled
    public static String getActivityReportIdRecordName(string reportName, string recordId,String whichCall){
        String strReportId = null;
        String strReportName = reportName; 
        
        system.debug('reportName :'+ reportName);
        
        List<Report> reportList = [SELECT Id, Name, DeveloperName, FolderName FROM Report
                               	   WHERE DeveloperName = :strReportName];
        
        system.debug('reportList :'+ reportList);
        List<Account> record = [SELECT Id, Name, RDM_ORG_ID__c,Company_Type__c from Account WHERE Id=:recordId];
                               	   
        
        if(reportList != null && reportList.size() > 0){
            
            if(whichCall == 'Interactions'){
            strReportId = reportList.get(0).Id + '##' + record[0].RDM_ORG_ID__c + '##' + record[0].Company_Type__c;
            }
            
            if(whichCall == 'Contact'){
                strReportId = reportList.get(0).Id;
            }
            if(whichCall == 'CallReport'){
                strReportId = reportList.get(0).Id + '##' + record[0].RDM_ORG_ID__c;
            }
        }           
        
        return strReportId;
    }
    
    
     @AuraEnabled
    public static boolean isCapIntro(string recordId){
   String contactKeyPrefix = Contact.sObjectType.getDescribe().getKeyPrefix();
   String accountKeyPrefix = Account.sObjectType.getDescribe().getKeyPrefix(); 
        List<PermissionSetAssignment> lstcurrentUserSet = [SELECT PermissionSet.Name from PermissionSetAssignment WHERE AssigneeId=:UserInfo.getUserId()];
        
        boolean isCapIntro = false;        
        for(PermissionSetAssignment psa: lstcurrentUserSet){
            if(psa.PermissionSet.Name.equals('Cap_Intro') && String.valueOf(recordId).startsWith(accountKeyPrefix)){
                isCapIntro = true;
            }   
        }
        
        return isCapIntro;
        
        
    }

}