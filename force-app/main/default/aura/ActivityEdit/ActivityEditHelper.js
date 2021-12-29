({
	checkForMassActivityEvent : function(component){
        console.log("--");
        var action = component.get("c.checkForEventType");
        var recordIdReceived = component.get("v.recordId");
        action.setParams({
            "recordId" : recordIdReceived
        });
        
        action.setCallback(this, function(response){
           var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.eventDetails", response.getReturnValue());
                var result = component.get("v.eventDetails");
                component.set("v.campaignId", result[0].What.Id);
                
                if(result[0].What.RecordType.Name !== 'Mass Activity')
                    component.set("v.massActivityFlag", false);
                else
                    component.set("v.massActivityFlag", true);
                 
                 var massActivityFlag = component.get("v.massActivityFlag");   
                 var campaignId = component.get("v.campaignId");
                 var calledFrom = component.get("v.calledFrom");
                
                var evt = $A.get("e.force:navigateToComponent");
                evt.setParams({
                    componentDef : "c:Activity",
                    componentAttributes: {
                        recordId : recordIdReceived,
                        massActivityFlag : massActivityFlag,
                        campaignId : campaignId,
                        calledFrom : calledFrom
                    }
                });
                evt.fire();
                $A.get("e.force:closeQuickAction").fire();
                
            }
            else{
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message)
                        console.log("Error message:" + errors[0].message);
                    else
                        console.log("Unknown error");
                }                
            }
            
        });
        $A.enqueueAction(action);
    }
})