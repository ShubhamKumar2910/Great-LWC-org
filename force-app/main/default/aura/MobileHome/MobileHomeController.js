({
    // component init method
	init : function(component, event, helper) {
		console.log("#### c.MobileHomeController.init()");
        helper.initialize(component, event, helper);
	},
    
    performAction : function(component, event, helper) {
        console.log("#### c.MobileHomeController.performAction()");
        helper.performAction(component, event, helper);
	}
})