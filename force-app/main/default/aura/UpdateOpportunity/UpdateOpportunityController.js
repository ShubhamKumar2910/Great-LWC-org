({
	doInit : function(component, event, helper) { 
         //validate the stage
        component.showSpinner();
        var action = component.get("c.processapprovalrecords");
        action.setParams({"Ids" : component.get("v.recordId"), "StageName" : "Tenure Completed" });
       
        //configure action handler
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                console.log(' approvalData **'+ response.getReturnValue());
                var approvalData = JSON.parse(response.getReturnValue());
                console.log(' approvalData **'+ approvalData);
                if (approvalData.Error === false){
                   component.set('v.showConfirmBox',true);
                   component.hideSpinner();
                }
                else{
                     helper.displayErrorToast(approvalData.ErrorMessage);
                     $A.get('e.force:refreshView').fire();
                     $A.get("e.force:closeQuickAction").fire();
                     component.hideSpinner();
            	}
               
            }else{
                 helper.displayErrorToast(response.getError());
                 $A.get("e.force:refreshView").fire();
                 $A.get("e.force:closeQuickAction").fire(); 
                 component.hideSpinner();
            }             
        });
        $A.enqueueAction(action);
    },
    cancel:function(component,event,helper){
       $A.get("e.force:refreshView").fire();
       $A.get("e.force:closeQuickAction").fire(); 
    },
    update:function(component,event,helper){
         //update the stage
        var action = component.get("c.saveapprovalrecords");
        action.setParams({"Ids" : component.get("v.recordId"), "StageName" : "Tenure Completed"});
       
        //configure action handler
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                console.log(' approvalData **'+ response.getReturnValue());
                var approvalData = JSON.parse(response.getReturnValue());
                console.log(' approvalData **'+ approvalData);
                if (approvalData.Error === false){
                   helper.displayToast(approvalData.SuccessMessage);
                }
                else{
                    helper.displayErrorToast(approvalData.ErrorMessage);
            	}
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
               
            }else{
                 helper.displayErrorToast(response.getError());
                 $A.get("e.force:refreshView").fire();
                 $A.get("e.force:closeQuickAction").fire();              
            }             
        });
        $A.enqueueAction(action);
    },
    showSpinner : function(component,event) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },
    hideSpinner : function(component,event) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.addClass(cmpTarget, 'slds-hide');
    },
})