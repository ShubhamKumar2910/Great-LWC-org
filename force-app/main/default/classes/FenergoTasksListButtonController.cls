public without sharing class FenergoTasksListButtonController {
    public List<Id> selectedFenTaskIds {get; set;}
    public String actionName {get; set;}
    public System.PageReference finishLocation {get; set;}
    
    public FenergoTasksListButtonController(ApexPages.StandardSetController standardController) {
        List<Fenergo_Task__c> fenergoTasks = (List<Fenergo_Task__c>) standardController.getSelected();
        selectedFenTaskIds = new List<Id> ();
        
        for(Fenergo_Task__c fenergoTask : fenergoTasks) {
            selectedFenTaskIds.add(fenergoTask.Id);
        }        

        finishLocation = new PageReference(System.URL.getOrgDomainUrl().toExternalForm()+
                                           '/lightning/o/Fenergo_Task__c/list?filterName='+standardController.getFilterId());    
    }

    public void setApproveAction() {
        actionName = 'Approve';
    }
    
    public void setReferAction() {
        actionName = 'Refer';
    }
    
    public void setCancelAction() {
        actionName = 'Cancel';
    }
}