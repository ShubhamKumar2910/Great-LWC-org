({
    getReportDetails : function(component) {
        var action = component.get("c.getReportId");
        
        action.setParams({"reportDeveloperName" : component.get("v.reportDeveloperName")});
        
        action.setCallback(this, function(response){
            var state = response.getState(); 
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(!$A.util.isUndefined(result)){
                    component.set("v.reportId", result);
                }
            }
            else {
                alert('Error in calling server side action');
            }
        });
        
        $A.enqueueAction(action);
    }
})