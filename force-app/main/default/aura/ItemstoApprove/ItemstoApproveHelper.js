({
    loadData : function(component) {
        // call the server side function  
        var action = component.get("c.getApprovalRequests");
        action.setParams({"cmpisApproval":"true"}); 
        action.setCallback(this,function(response){
            if (response.getState() == "SUCCESS") {
                if(!$A.util.isUndefinedOrNull(response.getReturnValue()))
                {
                    component.set("v.items",response.getReturnValue());
                    console.log(component.get('v.items'));
                    //var sorter = component.find("sortComponent");
                    //sorter.sortDefaults();
                }
            }
            else if (response.getState() === "INCOMPLETE") {
                component.showToast('error','error','No response from server or client is offline.');
            }
                else if (response.getState() === "ERROR") {
                    if(errors){
                        if(errors[0] && errors[0].message){
                            component.showToast('','error',errors[0].message);
                            console.log("Error message:" + errors[0].message);
                        }
                        }else{
                            console.log("Unknown error");
                            component.showToast('','error','Unknown error');
                        }         
                }
        });
        $A.enqueueAction(action);
    },
    ApproveSelectedRequests : function(component, event, selectedId){
        component.showSpinner();
        var action = component.get("c.submitApprovedRequests");
        var Ids = new Array();
        Ids.push(selectedId);
        action.setParams({"cmpApprovedIds" : JSON.stringify(Ids),
                          "cmpisApproval":"true"}); 
        
        action.setCallback(this,function(response){            
            var state = response.getState()
            if(state === "SUCCESS"){
                component.showToast('','success','Approvals are in process');  
                if(!$A.util.isUndefinedOrNull(response.getReturnValue()))
                {
                    component.set("v.items",response.getReturnValue());
                    console.log(component.get('v.items'));
                }
                component.hideSpinner();
            }
            else if (response.getState() === "INCOMPLETE") {
                component.showToast('error','error','No response from server or client is offline.');
            }
                else if (response.getState() === "ERROR") {
                    if(errors){
                        if(errors[0] && errors[0].message){
                            component.showToast('','error',errors[0].message);
                            console.log("Error message:" + errors[0].message);
                        }
                    }else{
                        console.log("Unknown error");
                        component.showToast('','error','Unknown error');
                    }   
                }
            component.hideSpinner();
            
        });
        
        $A.enqueueAction(action);
    },    
    RejectSelectedRequests : function(component, event, selectedId){
        component.showSpinner();
        var action = component.get("c.submitRejectedRequests");        
        var Ids = new Array();
        Ids.push(selectedId);
        action.setParams({"cmpRejectedIds" : JSON.stringify(Ids),
                          "cmpisApproval":"true"}); 
        
        action.setCallback(this,function(response){
            var state = response.getState()
            if(state === "SUCCESS"){
                component.showToast('','success','Rejections are in process'); 
                if(!$A.util.isUndefinedOrNull(response.getReturnValue()))
                {
                    component.set("v.items",response.getReturnValue());
                }
            }
            else if (response.getState() === "INCOMPLETE") {
                component.showToast('error','error','No response from server or client is offline.');
            }
                else if (response.getState() === "ERROR") {
                    if(errors){
                        if(errors[0] && errors[0].message){
                            component.showToast('','error',errors[0].message);
                            console.log("Error message:" + errors[0].message);
                        }
                    }else{
                        console.log("Unknown error");
                        component.showToast('','error','Unknown error');
                    }   
                }
            component.hideSpinner();
            
        });
        
        $A.enqueueAction(action);
    },
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.items");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        console.log('sorted data');
        console.log(data);
        cmp.set("v.items", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }
    
})