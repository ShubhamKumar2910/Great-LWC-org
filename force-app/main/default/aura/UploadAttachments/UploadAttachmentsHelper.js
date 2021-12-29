({

    sendMessage: function(component, helper, message){
        //Send message to VF
        message.origin = window.location.hostname;
        var vfWindow = component.find("vfFrame").getElement().contentWindow;
        vfWindow.postMessage(message, component.get("v.vfHost"));
    },
    
    checkUserRecordAccess: function(component){
        var action = component.get("c.doesUserHaveEditPermission"); 
        var accountRecordId = component.get("v.recordId");  
        action.setParams({
            recordId : accountRecordId
        });
        
        action.setCallback(this, function(response){
            var state = response.getState(); 
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(!$A.util.isUndefined(result)){
                    component.set("v.hasEditAccess", result); 
                }
            }
            else {
                alert('Error in calling server side action');
            }
        });
        
        $A.enqueueAction(action);
    }
})