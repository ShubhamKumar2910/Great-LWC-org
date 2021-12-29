({
    onRender: function(component, event, helper) {
        var navigationEvent = $A.get("e.force:navigateToComponent");
        navigationEvent.setParams({
            componentDef : "c:EventCallReport",
            componentAttributes: {
                isClientMemo : true
            }
        });
        navigationEvent.fire();
    }
})