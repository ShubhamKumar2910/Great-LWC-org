window.approvalsCount = (function() {
   
    return { 
       
        getPendingApprovals : function(component){
           var action = component.get("c.pendingApprovals");
            if(action !== undefined){
                action.setCallback(this,function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    var responseMap = response.getReturnValue();
                    component.set('v.approvalCountJson', responseMap);
                    component.set('v.refreshCount', true);
					console.log('---pendingApprovals--', responseMap);
                }
            });
            $A.enqueueAction(action); 
            }
                       
        }
	};
}());
	