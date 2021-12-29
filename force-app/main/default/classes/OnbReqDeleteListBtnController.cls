public without sharing class OnbReqDeleteListBtnController {
    public List<Onboarding_Request__c> selectedObRequests {get; set;}
    public Map<Id,Onboarding_Request__c> onbReqIdToOnbReq {get; set;}
    public Boolean displayErrorToUser {get; set;}
    public Integer numberOfFailedRecords {get;set;}
    public Integer totalNumOfSelectedRecords {get; set;} 
    public String errorMessageToDisplay {get; set;}
    public String introMessage {get; set;}
    public Boolean displayContinueButton {get;set;}
    
    public String success {
        get {
            return '<b>Successfully deleted requests. Please click the Finish button to return.</b>';
        } 
        set;
    }
    
    public void initFail() {
        errorMessageToDisplay = '<b>No Client Onboarding Requests Selected. </br> Please select at least one Request before clicking delete</b>';
        totalNumOfSelectedRecords = 0;
        displayErrorToUser = true;
        displayContinueButton = false;
    }
    
    public void initSuccess() {
        for (Onboarding_Request__c obRequest : [SELECT Id, Name, Campaign__c FROM Onboarding_Request__c WHERE Id IN :selectedObRequests]) {
            onbReqIdToOnbReq.put(obRequest.Id, obRequest);
        }
        errorMessageToDisplay = '';
        totalNumOfSelectedRecords = selectedObRequests.size();
        displayErrorToUser = false;
        displayContinueButton = true;
        introMessage = 'You have selected ' + totalNumOfSelectedRecords + ' Client Onboarding Requests.<br/><br/>';
        introMessage += '<b>Please Note:</b> You can only delete requests which are in Draft state and where you are the Requestor / Sales Requestor.<br/>';
    }
    
    public OnbReqDeleteListBtnController(ApexPages.StandardSetController standardController) {
       	selectedObRequests = (List<Onboarding_Request__c>) standardController.getSelected();
        onbReqIdToOnbReq = new Map<Id,Onboarding_Request__c>();
        numberOfFailedRecords = 0;
                
        if (selectedObRequests == null || selectedObRequests.isEmpty()) {
            initFail();
        } else {
			initSuccess();
        }
    } 
    
    public void deleteOnbRequests() {
        if(onbReqIdToOnbReq != null && !onbReqIdToOnbReq.isEmpty() && !displayErrorToUser) {
            Set<Id> deletedOnbRequests = new Set<Id> ();
            
            // Set savepoint incase campaign delete fails
            SavePoint sp = Database.setSavepoint();
            
            // Delete Onboarding Requests (Allow Partial Success)
            List<Database.DeleteResult> deleteResults = Database.delete(onbReqIdToOnbReq.values(), false);
            
            // Loop over delete results to create error messages for failures and to get Ids of successfully deleted ob request 
            for (Database.DeleteResult deleteResult : deleteResults) {
                String obReqId = deleteResult.getId();
                if (deleteResult.isSuccess()) {
                    deletedOnbRequests.add(deleteResult.getId()); // Store successfully deleted Onb Request Ids so we delete their campaigns later
                } else if (!deleteResult.isSuccess() && deleteResult.getErrors() != null) { 
                    numberOfFailedRecords++;
                   	System.debug(deleteResult.getErrors()[0]);
                }
            } // End of For loop
            
            // Delete campaigns related to sucessfully deleted Onboarding Requests
            if (!deletedOnbRequests.isEmpty()){
                try {
                    deleteRelatedCampaigns(deletedOnbRequests);
                    // Display error message for remaining failed onboarding requests 
                    if (numberOfFailedRecords > 0) {
                        displayOnbRequestErrorMessage(deletedOnbRequests);
                    }
                } catch (Exception e) {
                    numberOfFailedRecords = totalNumOfSelectedRecords;
                    displayCampaignErrorMessage();
                    System.debug('Error Deleting Campaigns ' + e.getMessage());
                    Database.rollback(sp);
                }
            } else {
                displayOnbRequestErrorMessage(deletedOnbRequests); //No Successfully deleted onb requests - show error
            }
        }
    }
    
    private void deleteRelatedCampaigns(Set<Id> deletedOnbRequests) {
        List<Campaign> campaignsToDelete = new List<Campaign> ();
        for(Id deletedObReq : deletedOnbRequests) {
            if (onbReqIdToOnbReq.get(deletedObReq).Campaign__c != null) {
                campaignsToDelete.add(
                    new Campaign(Id = onbReqIdToOnbReq.get(deletedObReq).Campaign__c)
                );
            }
        }
        
        delete campaignsToDelete;
    }
    
    public PageReference returnToObReq(){
        List<ListView> allListView = [SELECT Id from ListView WHERE SObjectType = 'Onboarding_Request__c' AND Name = 'All' LIMIT 1];
        String objectListView = !allListView.isEmpty() ? 'list?filterName='+allListView[0].Id : 'home';
        PageReference finishLocation = new PageReference(System.URL.getOrgDomainUrl().toExternalForm()+'/lightning/o/Onboarding_Request__c/'+objectListView);

        finishLocation.setRedirect(true);
        return finishLocation;    
    }
    
    public void displayOnbRequestErrorMessage(Set<Id> deletedOnbRequests) {
        if(!deletedOnbRequests.isEmpty()) {
            errorMessageToDisplay = '<b>Successfully deleted ' + deletedOnbRequests.size() + ' out of ' + totalNumOfSelectedRecords + ' of the selected Onboarding Requests.</b></br></br>';
        } else {
            errorMessageToDisplay = '<b>No Onboarding Requests Deleted.</b></br></br>';
        }
        errorMessageToDisplay += 'Please ensure the selected requests are in the Draft Stage and that you are a Requestor or Sales Requestor on the selected requests.</br>';

        displayErrorToUser = true;
    }
    
    public void displayCampaignErrorMessage() {
        errorMessageToDisplay = '<b>No Onboarding Requests Deleted.</b></br></br>';
        errorMessageToDisplay += 'The selected Onboarding Requests were not deleted due to an error when deleting Campaigns. Please contact an administrator.</br>';
        displayErrorToUser = true;
    }
    
    public void continueToDelete() {
        displayContinueButton = false;
        deleteOnbRequests();
    }
}