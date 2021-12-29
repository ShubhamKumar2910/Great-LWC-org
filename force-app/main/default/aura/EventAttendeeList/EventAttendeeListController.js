({
	doInit : function(component, event) {
          
        var action = component.get("c.getAttendees");
        var recordId = component.get("v.recordId");
        
        action.setParams({"recordId": recordId});      
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Data array:" +response.getReturnValue());
                component.set("v.lineitems", response.getReturnValue());
            }
        }); 
        
        $A.enqueueAction(action);
        
    },
    navigateToRecord : function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": event.target.getAttribute('data-recordId'),
          "slideDevName": "related"
        });
        navEvt.fire();
    },    
})