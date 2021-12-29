public with sharing class OnbReqSingleApprovalController {
    
    public List<String> selectedOnbReqIds{get; set;}
    public String source {get; set;}
    public String action {get; set;}
    public System.PageReference finishLocation {get; set;}
    
    public OnbReqSingleApprovalController(ApexPages.StandardController stdController) {
        source = 'Detail_Page';
        String selectedOnbReqId = stdController?.getRecord()?.Id;
        
        if(String.isNotBlank(selectedOnbReqId)) {
            Map<String, ProcessInstanceWorkitem> procInstWorkItemList = new Map<String, ProcessInstanceWorkitem>([SELECT Id, ProcessInstanceId, ActorId, OriginalActorId, 
                                                                                                                  ProcessInstance.ProcessDefinitionId, ProcessInstance.ProcessDefinition.DeveloperName , ProcessInstance.Status, ProcessInstance.TargetObjectId  
                                                                                                                  FROM ProcessInstanceWorkitem 
                                                                                                                  WHERE ProcessInstanceId IN 
                                                                                                                  (SELECT Id FROM ProcessInstance 
                                                                                                                   WHERE TargetObjectId = :selectedOnbReqId AND Status IN ('Pending'))]);
            
            finishLocation = new Pagereference(System.URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/Onboarding_Request__c/' + selectedOnbReqId + '/view');
            
            if (!procInstWorkItemList.isEmpty()) {
                selectedOnbReqIds = new List<String> {selectedOnbReqId};
            }
        }
    }
    
    public void initializeApproveAction() {
        action = OnboardingReqAndProdService.ONB_REQUEST_BULK_ACTION.ONB_REQ_APPROVE.name();
    }
    
    public void initializeRejectAction() {
        action = OnboardingReqAndProdService.ONB_REQUEST_BULK_ACTION.ONB_REQ_REJECT.name();
        
    }
}