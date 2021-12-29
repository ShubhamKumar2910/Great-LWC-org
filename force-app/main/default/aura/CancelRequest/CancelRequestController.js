({
	doInit : function(component, event, helper) {
       //validate the stage
       
       component.showSpinner();
        var action = component.get("c.processapprovalrecords");
        action.setParams({"Ids" : component.get("v.recordId"), "StageName" : "Invalidated" });
       
        //configure action handler
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                console.log(' approvalData **'+ response.getReturnValue());
                var approvalData = JSON.parse(response.getReturnValue());
                console.log(' approvalData **'+ approvalData);
                if (approvalData.Error === false){
                   var msg = approvalData.SuccessMessage;
                   console.log('msg **'+msg);
                    if(msg.includes('Referral Approved')){
                        component.set('v.showConfirmBox',true);
                        var cmpPrecancel = component.find('PreclosureCancel');                       
                        var cmpPostCancel = component.find('PostclosureCancel');
                        $A.util.removeClass(cmpPostCancel, 'slds-hide');
                        $A.util.addClass(cmpPrecancel, 'slds-hide');
                    }
                    else{
                        component.set('v.showConfirmBox',true);
                        var cmpPrecancel = component.find('PreclosureCancel');                        
                        var cmpPostCancel = component.find('PostclosureCancel');
                        $A.util.removeClass(cmpPrecancel, 'slds-hide');  
                        $A.util.addClass(cmpPostCancel, 'slds-hide');
                    } 
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
        //save the record
        var action = component.get("c.saveapprovalrecords");
        action.setParams({"Ids" : component.get("v.recordId"), "StageName" : "Invalidated"});
       
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