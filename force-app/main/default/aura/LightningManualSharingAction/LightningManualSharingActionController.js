({
	doInit : function(component) {
		let evt = $A.get("e.force:navigateToComponent");
		evt.setParams({
			componentDef : "c:LightningManualSharing",
			componentAttributes: {
					recordId : component.get("v.recordId")
			}
		});
		evt.fire();
	}
})