({
    init : function(component, event, helper) {
        //added function for JIRA SALES 1588
       
        helper.loadOpportunityRequestData(component);
        component.set("v.show", false);
        component.loadBulkCoverage(component, event, helper);
        helper.initialiseETradingEnablementRequest(component);
        //added function for JIRA SALES 3422
        var myPageRef = component.get("v.pageReference");
        //console.log("From Link" + myPageRef);
        if(myPageRef!=undefined && myPageRef!=null && !$A.util.isUndefinedOrNull(myPageRef.state.c__FromLink)){
            //console.log("From Link" + myPageRef.state.c__FromLink);
            if(myPageRef.state.c__FromLink !=undefined &&　myPageRef.state.c__FromLink=="CrossSellEmailApproval"){
                component.find("tabs").set("v.selectedTabId",'OpportunityTab');
            }//added for JIRA 3190
            if(myPageRef.state.c__FromLink !=undefined &&　myPageRef.state.c__FromLink=="CoverageApproval"){
                component.find("tabs").set("v.selectedTabId",'coverageTab');
            }
        }       
    },
    reInit : function(component, event, helper){
        component.showSpinner();
        
        const empApi = component.find('empApi');
        // Get the channel from the input box
        const channel = '/event/Request_Notification__e';
        // Replay option to get new events
        const replayId = -1;

        // Subscribe to an event
        empApi.subscribe(channel, replayId, $A.getCallback(eventReceived => {
            // Process event (this is called each time we receive an event)
            console.log('---Received event ', JSON.stringify(eventReceived)); 

            if(!$A.util.isUndefinedOrNull(approvalsCount)){
                //Re-Render will be called after scripts are loaded and displayUtilityBar is called to display total count            
                approvalsCount.getPendingApprovals(component);
                component.set('v.scriptsLoaded', true);
            }

        }))
        .then(subscription => {
            // Subscription response received.           
            component.set('v.subscription', subscription);         
        });

        helper.loadOpportunityRequestData(component);
        var myPageRef = component.get("v.pageReference");
        if(myPageRef!=undefined && myPageRef!=null && !$A.util.isUndefinedOrNull(myPageRef.state.c__isApproval))
        {
            //Called from CoverageTool - View Pending Request button
            console.log('1.');
            if(myPageRef.state.c__isApproval=='showRequestStatus'){
                component.set('v.isApproval',myPageRef.state.c__isApproval);
                component.set('v.RGIDList',myPageRef.state.c__RGIDList);
                component.set('v.RMIDList', myPageRef.state.c__RMIDList);
                component.set('v.PODIDList', myPageRef.state.c__PODIDList);
                component.set('v.scode',myPageRef.state.c__scode);
                component.set('v.source',myPageRef.state.c__source);
                component.find("tabs").set("v.selectedTabId",'coverageTab');
                helper.loadCoverageRequestData(component); 
            }
            else
            {
                console.log('2.');
                component.get("v.approvalList",new Array());
                component.set('v.isApproval',myPageRef.state.c__isApproval);
                component.set('v.RGIDList','');
                component.set('v.RMIDList','');
                component.set('v.PODIDList','');
                component.set('v.scode','');
                component.find("tabs").set("v.selectedTabId",'eTradingEnablementTab');
                component.find("tabs").set("v.selectedTabId",'coverageTab');     
                if(myPageRef.state.c__isApproval=='false')
                {
                    console.log('2.1');
                    helper.loadCoverageRequestData(component); 
                }
            }            
        }
        else{
             //helper.loadCoverageRequestData(component); 
             console.log('3');
             component.find("tabs").set("v.selectedTabId",'eTradingEnablementTab');
             component.find("tabs").set("v.selectedTabId",'coverageTab');             
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
        component.set('v.refreshSCHTab', false);
        component.set('v.refreshOnbTab', false);
        component.set('v.refreshFenTaskTab', false);

    	helper.loadETradingEnablementRequestData(component);
    },
    
    coverageRequestsSelected :  function(component, event, helper)
    {
        component.showSpinner();
        component.set('v.refreshSCHTab', false);
        component.set('v.refreshOnbTab', false);
        component.set('v.refreshFenTaskTab', false);

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

    onApprovalsCountScriptLoaded : function(component, event, helper){        
        if(!$A.util.isUndefinedOrNull(approvalsCount)){
            approvalsCount.getPendingApprovals(component);
            component.set('v.scriptsLoaded', true);
        }
        
    },

    displayApprovalsCount : function(component,event, helper){
        component.showSpinner();
       
        
        var eTradingCount = JSON.parse(component.get('v.approvalCountJson')).etradingCount;
        var crossSellCount = JSON.parse(component.get('v.approvalCountJson')).crossSellCount;
        
		// Display correct counts for Pending Requests
        if (!component.get('v.showPendingRequests')) {
            debugger;
            var onbReqCount = JSON.parse(component.get('v.approvalCountJson')).onbRequestCount;
            var schReqCount = JSON.parse(component.get('v.approvalCountJson')).schRequestCount;
            var coverageReqCount = JSON.parse(component.get('v.approvalCountJson')).coverageRequestCount;
            var fenergoTaskCount = JSON.parse(component.get('v.approvalCountJson')).fenTaskCount;

            component.set('v.onbReqCount', onbReqCount);
            component.set('v.schReqCount', schReqCount);
            component.set('v.coverageReqCount', coverageReqCount);
            component.set('v.fenTaskCount', fenergoTaskCount);
        } else {
            //helper.getObPendingRequestsCount(component); 
            helper.getPendingRequestsCount(component);
        }
        
        component.set('v.eTradingCount', eTradingCount);
        component.set('v.crossSellCount', crossSellCount);
         
        component.hideSpinner();
    },

    //as we have used OOO list view for SCH and Onb, we need to refresh it to display correct no. of records. so refreshTabs flags handles refreshes
    crossSellReqSelected : function(component){
        component.set('v.refreshSCHTab', false);
        component.set('v.refreshOnbTab', false);
        component.set('v.refreshFenTaskTab', false);
    },

    schRequestSelected : function(component){
        component.set('v.refreshSCHTab', true);
        component.set('v.refreshOnbTab', false);
        component.set('v.refreshFenTaskTab', false);
    },

    onbRequestSelected : function(component){
        component.set('v.refreshOnbTab', true);
        component.set('v.refreshSCHTab', false);
        component.set('v.refreshFenTaskTab', false);
    },

    fenTaskTabSelected : function(component){
        component.set('v.refreshFenTaskTab', true);
        component.set('v.refreshSCHTab', false);
        component.set('v.refreshOnbTab', false);
    },
})