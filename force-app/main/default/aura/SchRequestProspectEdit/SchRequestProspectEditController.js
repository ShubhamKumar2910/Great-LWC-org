({
	doInit : function(component, event, helper) {
        var recordIdForSCHRequest = component.get("v.recordId");
        console.log(recordIdForSCHRequest);
        var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:SCHRequestAura",
                componentAttributes: {
                	recordId : recordIdForSCHRequest
                }
            });
        evt.fire();
        $A.get("e.force:closeQuickAction").fire();	
    }
     
})