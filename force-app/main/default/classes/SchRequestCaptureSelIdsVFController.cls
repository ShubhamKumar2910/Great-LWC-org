/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : Controller class for VF Page SchRequestCaptureSelIdsVF
**/ 
public class SchRequestCaptureSelIdsVFController {
    public string[] SelectedSchReqIDs{get; set;}
    public String listViewDevName {get; set;}
    public System.PageReference finishLocation {get; set;}
    
    public SchRequestCaptureSelIdsVFController(ApexPages.StandardSetController listcontroller) {
        //finishLocation = new Pagereference('https://nomura--developer.lightning.force.com/lightning/o/SCH_Request__c/list?filterName=00B0p0000019mdVEAQ');
        System.debug(' System.URL.getSalesforceBaseUrl().toExternalForm() : '+System.URL.getSalesforceBaseUrl().toExternalForm());
        finishLocation = new Pagereference(System.URL.getOrgDomainUrl().toExternalForm()+
                            '/lightning/o/SCH_Request__c/list?filterName='+listcontroller.getFilterId());
        //System.debug('getSalesforceBaseUrl() : '+URL.getSalesforceBaseUrl().toExternalForm());
        //System.debug('getOrgDomainUrl() : '+URL.getOrgDomainUrl().toExternalForm());
        //System.debug('getCurrentRequestUrl() : '+URL.getCurrentRequestUrl().toExternalForm());

        System.debug('finishLocation.getUrl() : '+finishLocation.getUrl());
        if(!listcontroller.getSelected().isEmpty()) {
            List<ListView> ListViewList = [SELECT Id, DeveloperName 
                FROM ListView 
                WHERE Id = :listcontroller.getFilterId() AND SobjectType ='SCH_Request__c'];
            if(ListViewList.size()==1) {
                listViewDevName = ListViewList[0].DeveloperName;
            }
            System.debug('listViewDevName : '+listViewDevName);
            SelectedSchReqIDs = new String[]{};
            System.debug('getFilterId() : '+listcontroller.getFilterId());
            for(SCH_Request__c oSchReq : (SCH_Request__c[])listcontroller.getSelected()){
                System.debug('oSchReq.Id : '+oSchReq.Id);
                SelectedSchReqIDs.add(oSchReq.Id);
            }
        }
    }

    public String bulkAction {get; set;}
    public System.Pagereference initializeApproveAction() {
        bulkAction = SchRequestService.SCH_REQUEST_BULK_ACTION.SCH_REQ_APPROVE.name();
        return null;
    }

    public System.Pagereference initializeRejectAction() {
        bulkAction = SchRequestService.SCH_REQUEST_BULK_ACTION.SCH_REQ_REJECT.name();
        return null;
    }

     public System.Pagereference initAddCommentAction() {
        bulkAction = SchRequestService.SCH_REQUEST_BULK_ACTION.SCH_REQ_ADD_COMMENT.name();
        return null;
    }
    
    public System.Pagereference initializeCancelAction() {
        bulkAction = SchRequestService.SCH_REQUEST_BULK_ACTION.SCH_REQ_CANCEL.name();
        return null;
    }

    //public String getBulkAction() {
        //return SchRequestService.SCH_REQUEST_BULK_ACTION.SCH_REQ_APPROVE.name();
    //} 
}