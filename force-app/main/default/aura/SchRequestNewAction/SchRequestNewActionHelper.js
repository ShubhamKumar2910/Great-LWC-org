({
    init : function(component, event, helper) {
        console.log('#### SchRequestEditActionHelper.init()');
        let navService = component.find("navService");
        let pageReference = {
            type: "standard__navItemPage",
            attributes: {
                apiName: "SCH_Request"
            }
        };

        navService.navigate(pageReference);
	}
})