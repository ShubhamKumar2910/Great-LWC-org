({
	init : function(component, event, helper) {

        helper.captureLastViewedRecord(component);
        helper.checkUserPermission(component);
		
	}
})