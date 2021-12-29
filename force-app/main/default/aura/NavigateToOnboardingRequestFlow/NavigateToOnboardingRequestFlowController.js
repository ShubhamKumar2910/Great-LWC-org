({
	init:function(component, event){
        var recordId = component.get("v.recordId");
        
        console.log('navigate recordId-' + recordId);
		var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:AddEditOnboardingRequest",
            componentAttributes: {
                recordId : recordId                
            }
        });
        evt.fire();
	}
})