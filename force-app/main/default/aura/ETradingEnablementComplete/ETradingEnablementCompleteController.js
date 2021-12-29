({
    init: function(component, event, helper) {
    	console.log("#### c:ETradingEnablementCompleteController.init()");
        helper.initialize(component, event, helper);
    },
    
    reInit : function(component, event, helper) {
    	console.log("#### c:ETradingEnablementCompleteController.reInit()");
        helper.initialize(component, event, helper);
    },
    
    handleRowAction : function (component, event, helper) {
    	console.log("#### c:ETradingEnablementCompleteController.handleRowAction()");
        helper.handleRowAction(component, event, helper); 
    },
    
    onAddReqRowSelection : function (component, event, helper) {
        console.log("#### c:ETradingEnablementCompleteController.onAddReqRowSelection()");
        let selectedRows = event.getParam("selectedRows");
        component.set("v.disableAddCovBtn", $A.util.isEmpty(selectedRows));
    },
    
    onRevReqRowSelection : function (component, event, helper) {
        console.log("#### c:ETradingEnablementCompleteController.onRevReqRowSelection()");
        let selectedRows = event.getParam("selectedRows");
        component.set("v.disableRevCovBtn", $A.util.isEmpty(selectedRows));
    },

    handleAddNewCoverage : function (component, event, helper) {
    	console.log("#### c:ETradingEnablementCompleteController.handleAddNewCoverage()");
        helper.handleSave(component, event, helper, "Add"); 
    },

    handleRevokeCoverage : function (component, event, helper) {
    	console.log("#### c:ETradingEnablementCompleteController.handleRevokeCoverage()");
        helper.handleSave(component, event, helper, "Revoke");
    },
    
    handleBack : function (component, event, helper) {
    	console.log("#### c:ETradingEnablementCompleteController.handleBack()");
        helper.handleBack(component, event, helper); 
    },
    
    handleCancel : function (component, event, helper) {
    	console.log("#### c:ETradingEnablementCompleteController.handleCancel()");
    	component.set("v.platfromIDForNewContPlat", null);
    	component.set("v.contIdForNewContPlat", "");
		component.set("v.platfromForNewContPlat", "");
    	component.set("v.openCreateNewContPlatDialog", false);
    },
    
    handleSaveContPlat : function (component, event, helper) {
    	console.log("#### c:ETradingEnablementCompleteController.handleSaveContPlat()");
    	component.set("v.keepCreateNewContPlatDialogOpen", false);
    	helper.handleSaveContPlat(component, event, helper);
    },
    
    handleSaveAndNewContPlat : function (component, event, helper) {
    	console.log("#### c:ETradingEnablementCompleteController.handleSaveAndNewContPlat()");
    	component.set("v.keepCreateNewContPlatDialogOpen", true);
    	helper.handleSaveContPlat(component, event, helper);
    },
    
    handleError : function(component, event, helper) {
    	console.log("#### c:ETradingEnablementCompleteController.handleError()");
        helper.handleNewContPlatError(component, event, helper);
    }, 
    
    handleSuccess : function(component, event, helper) {
    	console.log("#### c:ETradingEnablementCompleteController.handleSuccess()");
        helper.handleNewContPlatSuccess(component, event, helper);
    },

    handleSectionToggle: function (component, event, helper) {
        console.log("#### c:ETradingEnablementCompleteController.handleSectionToggle()");
        let openSections = event.getParam('openSections');
        console.log("openSections : ",openSections);
        
        component.set("v.showAddReqBtn", (openSections.indexOf("newReqSec") > -1));
        component.set("v.showRevokeReqBtn", (openSections.indexOf("revokeReqSec") > -1));
        component.set("v.showTransferReqBtn", (openSections.indexOf("transferReqSec") > -1));
    }
})