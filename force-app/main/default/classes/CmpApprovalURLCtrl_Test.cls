@istest(SeeAllData = true)
public class CmpApprovalURLCtrl_Test {
    public static testMethod void TestURL(){
        /* For RG */ 
        List<ProcessInstanceWorkItem> processInstanceWorkItemForRGList = [
            SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId, OriginalActorId  
            FROM ProcessInstanceWorkItem
			WHERE OriginalActorId <> '' AND ProcessInstance.TargetObject.Type = 'RG_Coverage_Request__c' LIMIT 1];
        
        if(processInstanceWorkItemForRGList != null && processInstanceWorkItemForRGList.size() > 0)
        {
            ProcessInstanceWorkItem processInstanceWorkItemForRG = processInstanceWorkItemForRGList.get(0);    
            System.debug('processInstanceWorkItem.ProcessInstance.TargetObjectId for RG:'+processInstanceWorkItemForRG.ProcessInstance.TargetObjectId);
            System.debug('processInstanceWorkItem.OriginalActorId for RG:'+processInstanceWorkItemForRG.OriginalActorId);
            
            CmpApprovalURLCtrl.ApprovalID = processInstanceWorkItemForRG.ProcessInstance.TargetObjectId;
            CmpApprovalURLCtrl.ActorId = processInstanceWorkItemForRG.OriginalActorId;
        }
        
        String urlForRGCoverageRequest = CmpApprovalURLCtrl.urlStr;
        System.debug('url :'+ urlForRGCoverageRequest);
        
        /* For RM */
         List<ProcessInstanceWorkItem> processInstanceWorkItemForRMList = [
            SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId, OriginalActorId  
            FROM ProcessInstanceWorkItem
			WHERE OriginalActorId <> '' AND ProcessInstance.TargetObject.Type = 'Coverage_Access_Request__c' LIMIT 1];
        
        if(processInstanceWorkItemForRMList != null && processInstanceWorkItemForRMList.size() > 0)
        {
            ProcessInstanceWorkItem processInstanceWorkItemForRM = processInstanceWorkItemForRMList.get(0);    
            System.debug('processInstanceWorkItem.ProcessInstance.TargetObjectId for RM:'+processInstanceWorkItemForRM.ProcessInstance.TargetObjectId);
            System.debug('processInstanceWorkItem.OriginalActorId for RM:'+processInstanceWorkItemForRM.OriginalActorId);
            
            CmpApprovalURLCtrl.ApprovalID = processInstanceWorkItemForRM.ProcessInstance.TargetObjectId;
            CmpApprovalURLCtrl.ActorId = processInstanceWorkItemForRM.OriginalActorId;
        }
        
        String urlForRMCoverageRequest = CmpApprovalURLCtrl.urlStr;
        System.debug('url :'+ urlForRMCoverageRequest);
        
        
    }
    
}