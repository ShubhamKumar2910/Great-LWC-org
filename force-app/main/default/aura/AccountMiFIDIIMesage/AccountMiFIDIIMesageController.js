({
	// component init event handler
	init: function(component, event, helper) {
		console.log("#### c:AccountMiFIDIIMesageController.init()");
		helper.init(component, event, helper);
    },
    
	handleRecordUpdated : function(component, event, helper) {
		console.log("#### c:AccountMiFIDIIMesageController.handleRecordUpdated()");
        helper.handleRecordUpdated(component, event, helper);
    },
    
    handleIsUploadJobRunning : function(component, event, helper) {
    	console.log("#### c:AccountMiFIDIIMesageController.handleIsUploadJobRunning");
    	helper.runningJobPolling(component, event, helper);
    }
})