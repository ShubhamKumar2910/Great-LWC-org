public with sharing class OnbReqCaptureIdsVFController {
    
    public string[] selectedOnbReqIds{get; set;}
    public String source {get; set;}
    public System.PageReference finishLocation {get; set;}
    public String bulkAction {get; set;}

    public OnbReqCaptureIdsVFController(ApexPages.StandardSetController listcontroller) {
        finishLocation = new Pagereference(System.URL.getOrgDomainUrl().toExternalForm()+
                                           '/lightning/o/Onboarding_Request__c/list?filterName='+listcontroller.getFilterId());
        
        if(!listcontroller.getSelected().isEmpty()) {
            List<ListView> ListViewList = [SELECT Id, DeveloperName 
                FROM ListView 
                WHERE Id = :listcontroller.getFilterId() AND SobjectType ='Onboarding_Request__c'];
            if(ListViewList.size()==1) {
                source = ListViewList[0].DeveloperName;
            }
            selectedOnbReqIds = new String[]{};
            for(Onboarding_Request__c onbReq : (Onboarding_Request__c[])listcontroller.getSelected()){
                selectedOnbReqIds.add(onbReq.Id);
            }
            // String str = processRecords(SelectedReqIDs, 'Approve');
            // System.debug('---str--' + str);
        }
    }
    
    
    public System.Pagereference initializeApproveAction() {
        bulkAction = OnboardingReqAndProdService.ONB_REQUEST_BULK_ACTION.ONB_REQ_APPROVE.name();
        return null;
    }

    public System.Pagereference initializeRejectAction() {
        bulkAction = OnboardingReqAndProdService.ONB_REQUEST_BULK_ACTION.ONB_REQ_REJECT.name();
        return null;
    }

}