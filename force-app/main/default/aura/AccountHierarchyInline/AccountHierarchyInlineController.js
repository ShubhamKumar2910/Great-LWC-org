({
    doInit: function(component, event, helper) {
		var action = component.get("c.getObjectStructure");
        action.setParams({
	        currentId : component.get("v.recordId")
    	});
        // Register the callback function
        action.setCallback(this, function(response) {
            component.set("v.objectStructureMaps", response.getReturnValue());
            if( response.getReturnValue().length == 1) { component.set("v.orphanRecord", true)};
        });
        // Invoke the service
        $A.enqueueAction(action);
    }
})