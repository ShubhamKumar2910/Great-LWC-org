({
    init : function(component, event, helper) {
        //added function for JIRA SALES 1588
        helper.loadOpportunityRequestData(component);
        component.set("v.show", false);
        component.loadBulkCoverage(component, event, helper);
        helper.initialiseETradingEnablementRequest(component);
        //added function for JIRA SALES 3422
        var myPageRef = component.get("v.pageReference");
        console.log("From Link" + myPageRef);
        if(myPageRef!=undefined && myPageRef!=null && !$A.util.isUndefinedOrNull(myPageRef.state.c__FromLink)){
            console.log("From Link" + myPageRef.state.c__FromLink);
            if(myPageRef.state.c__FromLink !=undefined &&　myPageRef.state.c__FromLink=="CrossSellEmailApproval"){
                component.find("tabs").set("v.selectedTabId",'OpportunityTab');
            }//added for JIRA 3190
            if(myPageRef.state.c__FromLink !=undefined &&　myPageRef.state.c__FromLink=="CoverageApproval"){
                component.find("tabs").set("v.selectedTabId",'coverageTab');
            }
        }       
    },
    reInit : function(cmp, event, helper){
        cmp.showSpinner();
        helper.loadOpportunityRequestData(cmp);
        var myPageRef = cmp.get("v.pageReference");
        if(myPageRef!=undefined && myPageRef!=null && !$A.util.isUndefinedOrNull(myPageRef.state.c__isApproval))
        {
            console.log('1.');
            if(myPageRef.state.c__isApproval=='showRequestStatus'){
                cmp.set('v.isApproval',myPageRef.state.c__isApproval);
                cmp.set('v.RGIDList',myPageRef.state.c__RGIDList);
                cmp.set('v.scode',myPageRef.state.c__scode);
                cmp.find("tabs").set("v.selectedTabId",'coverageTab');
                helper.loadCoverageRequestData(cmp); 
            }
            else
            {
                console.log('2.');
                cmp.get("v.approvalList",new Array());
                cmp.set('v.isApproval',myPageRef.state.c__isApproval);
                cmp.set('v.RGIDList','');
                cmp.set('v.scode','');
                cmp.find("tabs").set("v.selectedTabId",'eTradingEnablementTab');
                cmp.find("tabs").set("v.selectedTabId",'coverageTab');     
                if(myPageRef.state.c__isApproval=='false')
                {
                    console.log('2.1');
                    helper.loadCoverageRequestData(cmp); 
                }
            }            
        }
        else{
             helper.loadCoverageRequestData(cmp); 
             console.log('3');
             cmp.find("tabs").set("v.selectedTabId",'eTradingEnablementTab');
             cmp.find("tabs").set("v.selectedTabId",'coverageTab');             
        }
        
      
    },
   
    getSelectedId : function(component, event, helper){
        var selectedRows = event.getParam('selectedRows');        
        var selectedIds = [];
        if(component.get('v.approvalList').length > 1){
            for(var i =0; i < selectedRows.length; i++){
                selectedIds.push(selectedRows[i].processInstanceWorkItemID);
            }
        }
        
        if(component.get('v.approvalList').length == 1){
            selectedIds.push(component.get('v.approvalList')[0].processInstanceWorkItemID);
        }
        
        component.set('v.IDList',selectedIds);
        
    },
    
    ApproveSelectedRequests : function(component, event, helper){
        component.showSpinner();
        var action = component.get("c.submitApprovedRequests");
        action.setParams({"cmpApprovedIds" : JSON.stringify(component.get('v.IDList')),
                          "cmpisApproval":component.get("v.isApproval")}); 
        
        action.setCallback(this,function(response){            
            var state = response.getState()
            if(state === "SUCCESS"){
                component.showToast('','success','Approvals are in process');               
                var responseData = response.getReturnValue();
                component.set("v.approvalList",responseData);  
                helper.sortData(component,"CreatedDate","desc");
                component.hideSpinner();
            }
            
        });
        
        $A.enqueueAction(action);
    },
    
    RejectSelectedRequests : function(component, event, helper){
        component.showSpinner();
        var buttonType = event.getSource().get("v.name");
        var action = component.get("c.submitRejectedRequests");        
        action.setParams({"cmpRejectedIds" : JSON.stringify(component.get('v.IDList')),
                          "cmpisApproval":component.get("v.isApproval"),
                          "cancelorReject":buttonType}); 
        
        action.setCallback(this,function(response){
            var state = response.getState()
            if(state === "SUCCESS"){
                if(buttonType=='cancel')
                    component.showToast('','success','Cancellations are in process');                
                else
                    component.showToast('','success','Rejections are in process');                    
                var responseData = response.getReturnValue();
                component.set("v.approvalList",responseData);
               helper.sortData(component,"CreatedDate","desc");
                component.hideSpinner();
            }
        });
        
        $A.enqueueAction(action);
    },
    
    updateColumnSorting: function(component, event, helper){ 
        var dataTable = component.find("approvalTable");
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        dataTable.set("v.sortedBy", fieldName);
        dataTable.set("v.sortedDirection", sortDirection);        
        helper.sortBy(component, fieldName, sortDirection);
    },
    
    showToast : function(component, event, helper) {
        var params = event.getParam('arguments');
        if(params)
        {
            var title = params.title;
            var type = params.type;
            var message = params.message;
            var mode = params.mode;
            var key = params.key;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "type": type,
                "message": message,
                "mode": mode,
                "key": key
            });
            toastEvent.fire();
        }
        
        
    },
    
    Cancel:function(component,event,helper){
        window.history.back();
    },
    
    showSpinner : function(component,event) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },
    hideSpinner : function(component,event) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.addClass(cmpTarget, 'slds-hide');
    },
    updateColumnSorting: function (cmp, event, helper) {
        var dataTable = cmp.find("approvalTable");
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        dataTable.set("v.sortedBy", fieldName);
        dataTable.set("v.sortedDirection", sortDirection);        
        helper.sortData(cmp, fieldName, sortDirection);
    },
    
    setETradingSelectedId : function(component, event, helper)
    {
    	helper.eTradingEnablementSelected(component, event);
    },
    
    setETradingView : function(component, event, helper)
    {
    	helper.eTradingEnablementViewSelected(component, event); 
    },

    eTradingNoCoverageUpdateColumnSorting : function(component, event, helper)
    {
        helper.updateETradingColumnSorting(component, event, "NoCoverage");
    },

    eTradingUpdateColumnSorting : function(component, event, helper)
    {
        helper.updateETradingColumnSorting(component, event, "Coverage");
    },

    approve : function(component, event, helper)
    {
    	helper.processETradingRequests(component, 'To Be Processed');
    },
    
    reject : function(component, event, helper)
    {
    	helper.processETradingRequests(component, 'Rejected');
    }, 
    
    cancel : function(component, event, helper)
    {
    	window.history.back();
    },
    
    eTradingEnablementRequestsSelected : function(component, event, helper)
    {
    	helper.loadETradingEnablementRequestData(component);
    },
    
    coverageRequestsSelected :  function(component, event, helper)
    {
        component.showSpinner();
        helper.loadCoverageRequestData(component);
    }, 

    coverageRowAction : function(component, event, helper)
    {
        helper.coverageRequest(component, event);
    },
    //added for JIRA SALES !588
    getOppSelectedId : function(component, event, helper){
        var selectedRows = event.getParam('selectedRows');        
        var selectedIds = [];
        if(component.get('v.opptapprovalList').length > 1){
            for(var i =0; i < selectedRows.length; i++){
                selectedIds.push(selectedRows[i].processInstanceWorkItemID);
            }
        }        
        if(component.get('v.opptapprovalList').length == 1){
            selectedIds.push(component.get('v.opptapprovalList')[0].processInstanceWorkItemID);
        }        
        component.set('v.selectedOppIDList',selectedIds);
        console.log('selectedIds **'+ selectedIds);
    },
    updateOpptColumnSorting: function(component, event, helper){ 
        var dataTable = component.find("oppapprovalTable");
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        dataTable.set("v.sortedBy", fieldName);
        dataTable.set("v.sortedDirection", sortDirection);        
        helper.sortOpptData(component, fieldName, sortDirection);
    },
    approveRequest : function(component, event, helper){
       var selectedids =  component.get('v.selectedOppIDList');
       if(selectedids != null && selectedids != ""){
           helper.processOpptRequests(component, event, helper, 'Approve');             
       }
      else{
         console.log('Selected Id **' + selectedids);
         helper.displayErrorToast('Select atleast one row to approve.');  
       }
    },    
    rejectRequest : function(component, event, helper){
       var comment = component.get("v.RejectComments");
       console.log('comment **'+ comment);
       if(comment != null && comment != ""){
           helper.processOpptRequests(component, event, helper, 'Reject');
           component.set("v.show", false);
        }    	
        else{
            var errormsg = $A.get("$Label.c.RejectionCommentsmandatory");
           helper.displayErrorToast(errormsg);            
        }      
    }, 
    showpopup : function(component, event, helper){
       var selectedids =  component.get('v.selectedOppIDList');
       if(selectedids != null && selectedids != ""){
         component.set("v.show", true);
         console.log('comment in show **');
       }
       else{
          helper.displayErrorToast('Select atleast one row to reject.');     	    
       } 
    },
    hidepopup : function(component, event, helper){
        component.set("v.show", false);
        console.log('comment in hide **');
    },
    // SALES-4136
    handleCovCBSelection : function(component,event,helper){
        var cbChecked = event.getSource().get("v.checked");
        var cbVal = event.getSource().get("v.value");
        
        var selectedIds = component.get('v.IDList');
        
        if(cbChecked === true){
            selectedIds.push(cbVal);
        }
        else{
            selectedIds.splice(selectedIds.indexOf(cbVal),1)
        }
        component.set('v.IDList',selectedIds);
    }

})