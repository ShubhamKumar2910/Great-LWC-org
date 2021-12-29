({
	displayToast : function(message)
    {
    	var toastEvent = $A.get("e.force:showToast");
    	
    	toastEvent.setParams({
    		title: "Success",
            message: message,
            type: "success", 
        });
            
        toastEvent.fire();
    }, 
     displayErrorToast : function(errorMessage)
    {
    	var toastEvent = $A.get("e.force:showToast");
    	
    	toastEvent.setParams({
    		title: "Error",
            message: errorMessage,
            type: "error", 
            mode: "sticky"
        });
            
        toastEvent.fire();
    },
})