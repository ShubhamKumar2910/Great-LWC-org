({
	init : function(component, event, helper) {
		var recordId = component.get("v.recordId");

		var navigationEvent = $A.get("e.force:navigateToComponent");
           navigationEvent.setParams({
                componentDef : "c:NewContact",
                componentAttributes: {
                    //origin : 'Contact',
                    editContId : recordId
                }
        });
        navigationEvent.fire();

	}
})