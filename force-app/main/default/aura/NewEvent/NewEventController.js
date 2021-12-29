({
	init:function(component, event){
        var recordId = component.get("v.recordId");
        console.log('---in NewEvent --');
        
		var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:EventCallReport",
            componentAttributes: {
                relatedToId : recordId,
                isClientMemo : false
            }
        });
        evt.fire();
	}
})