({
	getTieringDetails: function(component){
        var action = component.get("c.getTieringDetails"); 
        var recordId = component.get("v.childRecordId");  
        action.setParams({
            recordId : recordId
        });
        
        action.setCallback(this, function(response){
            var state = response.getState(); 
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(!$A.util.isUndefined(result)){
                    component.set("v.tieringDetails", result); 
                }
            }
            else {
                alert('Error in calling server side action');
            }
        });
        
        $A.enqueueAction(action);
    }
})