({
	getContactAccordionSectionDetails: function(component, successCallback){
        var action = component.get("c.getAccordionSectionDetails"); 
                
        action.setCallback(this, function(response){
            var state = response.getState(); 
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(!$A.util.isUndefined(result)){
                    //Set Details
                    component.set("v.accordionSections", result); 
                    
                    if (successCallback) { 
                    	successCallback();
                    } 
                }
            }
            else {
                alert('Error in calling server side action');
            }
        });
        
        $A.enqueueAction(action);
    }
})