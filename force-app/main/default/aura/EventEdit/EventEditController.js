({
	doInit : function(component, event, helper) {
		var recordId = component.get("v.recordId");
		console.log('Record Id Edit Event: ' + recordId);
		var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:EventCallReport",
            componentAttributes: {
                recordId : recordId
            }
        });
        evt.fire();
        $A.get("e.force:closeQuickAction").fire();
	}
})