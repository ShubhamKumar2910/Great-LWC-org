({
	doInit : function(component, event, helper) {
		var recordId = component.get("v.recordId");
        var standardRecordType;
        var action = component.get("c.getStandardRecordType");

        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                standardRecordType = result.Id;
            }
        });
        $A.enqueueAction(action);
        $A.get("e.force:closeQuickAction").fire();
        helper.getEvent(component, standardRecordType);
        
	}
})