({
	doInit : function(component, event, helper) {
		var recordId = component.get("v.recordId");
        console.log('--------in activity edit');
        // To find update record is of type massActivity or other       
        var recordId = component.get("v.recordId");
        var saveNewCheck = component.get("v.saveNewCheck");
        var isClientMemo = component.get("v.isClientMemo");

        if( (recordId != null || recordId != undefined) && recordId.startsWith("00U")){
            helper.checkForMassActivityEvent(component);
        }
        else{
            var evt = $A.get("e.force:navigateToComponent");
                evt.setParams({
                    componentDef : "c:EventCallReport",
                    componentAttributes: {  
                        saveNewCheck : saveNewCheck,
                        isClientMemo : isClientMemo
                    }
                });
                evt.fire();
        }
        
    }
})