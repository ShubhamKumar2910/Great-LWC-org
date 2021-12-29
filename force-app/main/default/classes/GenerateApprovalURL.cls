public class GenerateApprovalURL {
   public static String generateApprovalURL(String recordID, string actorId){  
      String url='';  
        
      List<ProcessInstanceWorkitem> workItemLst =   
        [  SELECT id  
      FROM ProcessInstanceWorkitem  
      WHERE processInstance.TargetObjectId=:recordID AND OriginalActorId = :actorId];   
        
      if(workItemLst.size() > 0)  
      {  
         
        url='https://'+ System.URL.getSalesforceBaseUrl().getHost() + '/console#'+    
         '/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + workItemLst[0].id;      
     }  
     return url;  
   }  
}