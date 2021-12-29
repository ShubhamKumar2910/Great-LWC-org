({
	// component init event handler
	init: function(component, event, helper) {
		console.log("#### c:BulkUpdateDeskCommentaryProhibitedController.init()");
		helper.init(component, event, helper);
    },

    handleUploadFinished: function (component, event, helper) {
        // call the corresponding helper function
        helper.handleUploadFinished(component, event, helper);
    },
    
    handleUpdateClick: function (component, event, helper) {
        // call the corresponding helper function
        console.log("#### c:BulkUpdateDeskCommentaryProhibitedController.handleUpdateClick");
        helper.bulkUpload(component, event, helper);
    },
    
    handleUpdateByContClick: function (component, event, helper) {
    	console.log("#### c:BulkUpdateDeskCommentaryProhibitedController.handleUpdateByContClick");
    	helper.bulkUploadByCont(component, event, helper);
    },
    
    /*readFile: function (cmp, event) {
    	alert("readFile");
    	var fileInput = component.find("file-input").getElement();
    	var file = fileInput.files[0];
    },*/
  
    toggleFilterSec:  function (component, event, helper) {
    	console.log("#### c:BulkUpdateDeskCommentaryProhibitedController.toggleFilterSec");
    	var uploadSecIcon = component.find("uploadSecIcon");
    	if(!$A.util.isEmpty(uploadSecIcon)) {
	    	for(var iconCmp in uploadSecIcon) {
	            $A.util.toggleClass(uploadSecIcon[iconCmp], "slds-show");  
	            $A.util.toggleClass(uploadSecIcon[iconCmp], "slds-hide");  
	        }
        }
        
        var uploadDetailSec = component.find("uploadDetailSecId");
        if(!$A.util.isEmpty(uploadDetailSec)) {
        	$A.util.toggleClass(uploadDetailSec, "slds-show");  
            $A.util.toggleClass(uploadDetailSec, "slds-hide");
        }
    },
    
    handleTypeClick:  function (component, event, helper) {
    	console.log("#### c:BulkUpdateDeskCommentaryProhibitedController.handleTypeClick");
    	var target = event.getSource(); 
		var btnName = target.get("v.name");
        var uploadBy = component.get("v.uploadBy");
        if(btnName!==uploadBy) {
            component.set("v.uploadBy", btnName);
        }
        
        // finally reset the attributes required to upload a file
        component.set("v.uploadedDocId", null);
        component.set("v.fileValidationErrs", true);
    },
    
    handleDwnLdFileTemp: function (component, event, helper) {
    	console.log("#### c:BulkUpdateDeskCommentaryProhibitedController.handleDwnLdFileTemp");
    	helper.dwnLdFileTempl(component, event, helper);
    },
    
    handleAssignCancel : function (component, event, helper) {
    	console.log("#### c:BulkUpdateDeskCommentaryProhibitedController.handleAssignCancel");
    	component.set("v.showDownLoadTempl", false);
    },
    
    handleIsUpldJobRunningChange : function (component, event, helper) {
    	console.log("#### c:BulkUpdateDeskCommentaryProhibitedController.handleIsUpldJobRunningChange");
    	helper.runningJobPolling(component, event, helper);
    }, 
    
    handleRunningJobIdChange : function (component, event, helper) {
    	console.log("#### c:BulkUpdateDeskCommentaryProhibitedController.handleRunningJobIdChange");
    	helper.handleRunningJobIdChange(component, event, helper); 
    }
})