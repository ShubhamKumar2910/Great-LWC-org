({
	navigateToRecord : function(component, event, helper) {
		var actualRecordId = component.get("v.recordId");
        var navigationEvent = $A.get("e.force:navigateToSObject");
        navigationEvent.setParams({
              recordId: actualRecordId,
              slideDevName: "detail"
         });
         navigationEvent.fire(); 
	}
})