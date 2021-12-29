({
    intialiseApprovalComponentData : function(component) { 
        var isApproval = component.get('v.isApproval');
         console.log('3.1');
         var source = component.get("v.source");
         
         if(source == 'Coverage')
         {
             //hide Onb & SCH tabs
             component.set('v.showSCHApprovalTab', false);
             component.set('v.showOnbReqApprovalTab', false);
         }

        component.set("v.approvalList",new Array());
        var showRequestStatus = false;    
        if(isApproval == "false"){
            console.log('3.1.1');
        	component.set('v.HeaderText',$A.get("$Label.c.Pending_Approvals"));
        	component.set('v.showApprovalButtons',false);
        	component.set('v.showSalesButton',true);
            component.set('v.showCoverageRequestTab',true);
            component.set('v.showETradingRequestTab',false);
            component.set('v.showCrossSellRequestTab',false);
            //component.set('v.showSCHApprovalTab',false);
            //component.set('v.showOnbReqApprovalTab',false);
        }
        else if(isApproval == "showRequestStatus"){
            console.log('3.1.2');
            component.set('v.HeaderText',$A.get("$Label.c.Pending_Approvals"));
            component.set('v.showApprovalButtons',false);
            component.set('v.showSalesButton',false);
            component.set('v.showCoverageRequestTab',true);
            component.set('v.showETradingRequestTab',false);
            component.set('v.showCrossSellRequestTab',false);
            //component.set('v.showSCHApprovalTab',false);
            //component.set('v.showOnbReqApprovalTab',false);
            showRequestStatus = true;
        }
            else {
                console.log('3.1.3');
                component.set('v.HeaderText',$A.get("$Label.c.Items_To_Approve"));
                component.set('v.showSalesButton',false);
                component.set('v.showApprovalButtons',true);
                component.set('v.showCoverageRequestTab',true);
                component.set('v.showETradingRequestTab',true);
                component.set('v.showCrossSellRequestTab',true);
                //this.hideShowSCHApprovalTab(component);
                //this.hideShowOnbReqApprovalTab(component);
            }
        
        if(showRequestStatus){
            console.log('4.1');
            //Called from CoverageTool - GM Coverage, gets pending approval request by selected RG
            if(!$A.util.isUndefinedOrNull(component.get('v.RGIDList')))
            {
                if(component.get("v.approvalList").length == 0 || component.get("v.approvalList") == undefined){
                    var action = component.get("c.getApprovalRequestsByRG");
                    var rgId = component.get('v.RGIDList');
                    var scode = component.get('v.scode');
                    if(rgId!=''){
                        action.setParams({"rgId":rgId,"scode":scode}); 
                        action.setCallback(this,function(response){
                            var state = response.getState()
                            var responseData = response.getReturnValue();
                            if(state === "SUCCESS"){   
                                component.set("v.approvalList",responseData);
                                component.set('v.coverageReqCount', responseData.length); //not setting properly
                                this.sortData(component,"CreatedDate","desc");
                                component.find("approvalTable").set('v.hideCheckboxColumn',true);
                                component.hideSpinner();

                                //hide Onb & SCH tabs
                                // component.set('v.showSCHApprovalTab', false);
                                // component.set('v.showOnbReqApprovalTab', false);
                            }
                        });
                    }
                    $A.enqueueAction(action);
                }
            }else if(!$A.util.isUndefinedOrNull(component.get('v.RMIDList'))){
                if (component.get("v.approvalList").length == 0 || component.get("v.approvalList") == undefined) {
                    var action = component.get("c.getApprovalRequestsByRM");
                    var rmId = component.get('v.RMIDList');
                    var scode = component.get('v.scode');
                    if (rmId != '') {
                        action.setParams({ "rmId": rmId, "scode": scode });
                        action.setCallback(this, function (response) {
                            var state = response.getState()
                            var responseData = response.getReturnValue();
                            if (state === "SUCCESS") {
                                component.set("v.approvalList", responseData);
                                component.set('v.coverageReqCount', responseData.length); //not setting properly
                                this.sortData(component, "CreatedDate", "desc");
                                component.find("approvalTable").set('v.hideCheckboxColumn', true);
                                component.hideSpinner();
                            }
                        });
                    }
                    $A.enqueueAction(action);
                }
            }else if(!$A.util.isUndefinedOrNull(component.get('v.PODIDList'))){
                if (component.get("v.approvalList").length == 0 || component.get("v.approvalList") == undefined) {
                    var action = component.get("c.getApprovalRequestsByPOD");
                    var podId = component.get('v.PODIDList');
                    var scode = component.get('v.scode');
                    if (podId != '') {
                        action.setParams({ "podId": podId, "scode": scode });
                        action.setCallback(this, function (response) {
                            var state = response.getState()
                            var responseData = response.getReturnValue();
                            if (state === "SUCCESS") {
                                component.set("v.approvalList", responseData);
                                component.set('v.coverageReqCount', responseData.length); //not setting properly
                                this.sortData(component, "CreatedDate", "desc");
                                component.find("approvalTable").set('v.hideCheckboxColumn', true);
                                component.hideSpinner();
                            }
                        });
                    }
                    $A.enqueueAction(action);
                }
            }
        }
        else
        {
            //Called when Pending Request tab is active | or Items to Approve
            console.log('4.2');
            if(component.get("v.approvalList").length == 0 || component.get("v.approvalList") == undefined){
                            console.log('4.3');
                var action = component.get("c.getApprovalRequests");
                action.setParams({"cmpisApproval":component.get("v.isApproval")}); 
                action.setCallback(this,function(response){
                                console.log('4.4');
                    var state = response.getState()
                    var responseData = response.getReturnValue();
                    console.log('state: '+state);
                    console.log(responseData);
                    if(state === "SUCCESS"){  
                        component.set("v.approvalList",responseData);
                        
                        component.set('v.coverageReqCount', responseData.length);
                        this.sortData(component,"CreatedDate","desc");
                        component.find("approvalTable").set('v.hideCheckboxColumn',false);
                        if(component.get('v.isApproval')=='false')
                        {
                            //Called from CoverageTool Cancel Request button.
                            component.find("tabs").set("v.selectedTabId",'coverageTab');  
                            console.log('4.7');
                            //hide Onb & SCH tabs
                            // component.set('v.showSCHApprovalTab', false);
                            // component.set('v.showOnbReqApprovalTab', false);
                        }
                        
                        
                        component.hideSpinner();
                    }
                });
                
                $A.enqueueAction(action);
            }
        }
    },
    
   sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.approvalList");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.approvalList", data);
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
    }, 
    
    
    /*getObPendingRequestsCount: function (component) {
        var action = component.get("c.getCountOfObPendingRequests");
        action.setCallback(this,function(response){ 
            var state = response.getState();
            var responseData = response.getReturnValue();
            if(state === "SUCCESS" && !$A.util.isUndefinedOrNull(responseData)) {
            	component.set('v.onbReqCount', responseData);
            } else if(state === "ERROR") {
                var errors = response.getError();
                if (errors[0] && errors[0].message) {
           			this.displayErrorToast(errors[0].message);            
                }
            }
        });    
        $A.enqueueAction(action);
    }, */
    
    getPendingRequestsCount: function (component) {
        debugger;
        var action = component.get("c.getCountOfPendingRequests");
        action.setParams({"cmpisApproval":component.get("v.isApproval")}); 
        action.setCallback(this,function(response){
            var state = response.getState();
            var responseData = response.getReturnValue();
            if(state === "SUCCESS" && !$A.util.isUndefinedOrNull(responseData)) {
                component.set('v.pendingRequestsWrapper', responseData);
                //count of CoverageRequest is calulated from no of return records in intialiseApprovalComponentData method 
                component.set('v.coverageReqCount', component.get('v.coverageReqCount'));
                component.set('v.onbReqCount', responseData.onBoardingPendingRequestsCount);
                component.set('v.schReqCount', responseData.schPendingReqeuestsCount);
            } else if(state === "ERROR") {
                var errors = response.getError();
                if (errors[0] && errors[0].message) {
                    this.displayErrorToast(errors[0].message);            
                }
            }
        });
        $A.enqueueAction(action);
    }, 

    loadCoverageRequestData : function(component, selectedView)
    {
        if(component.get('v.isApproval') == 'true')
        {
            //change for SALES-3698
            component.set("v.tableColumn", [               
                {label: component.get("v.RequestedFor"), fieldName:"RequestedFor", type:"text", initialWidth:129, sortable:true},
                {label: component.get("v.AccountName"), fieldName:"AccountName", type:"text", initialWidth:220, sortable:true},
                {label:"Functional Level", fieldName:"FunctionalLevel", type:"text", initialWidth:100, sortable:true},
                {label: "Parent Account", fieldName:"ParentAccountName",type:"text", initialWidth:200, sortable:true},
                {label: "Related RM Account", fieldName: "RelatedRMAccountName", type: "text", initialWidth: 200, sortable: true},
                {label: "Error Message", fieldName: "ErrorMessage", type: "text", initialWidth: 200, sortable: true},
                //////////////////{label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:86, sortable:true},
                {label: component.get("v.Product"), fieldName:"Product", type:"text", initialWidth:129, sortable:true},
                {label: component.get("v.ProductRegion"), fieldName:"ProductRegion", type:"text", initialWidth:100, sortable:true},
                {label: component.get("v.FromDate"), fieldName:"FromDate", type:"text", initialWidth:109, sortable:true},
                {label: component.get("v.RequestType"), fieldName:"RequestType", type:"text", initialWidth:128, sortable:true},
                {label: component.get("v.Role"), fieldName:"Role", type:"text", initialWidth:80, sortable:true},
                {label: component.get("v.RequestedBy"), fieldName:"RequestedBy", type:"text", initialWidth:142, sortable:true},
                {label: component.get("v.CreatedDate"), fieldName:"CreatedDate", type:"date", initialWidth:166, sortable:true},
            ]); 
        }
        else
        {
            //change for SALES-3698
            component.set("v.tableColumn", [                
                {label: component.get("v.RequestedFor"), fieldName:"RequestedFor", type:"text", initialWidth:126, sortable:true},
                {label: component.get("v.AccountName"), fieldName:"AccountName", type:"text", initialWidth:181, sortable:true},
                {label:"Functional Level", fieldName:"FunctionalLevel", type:"text", initialWidth:100, sortable:true},
                {label: "Parent Account", fieldName:"ParentAccountName",type:"text", initialWidth:200, sortable:true},
                {label: "Related RM Account", fieldName: "RelatedRMAccountName", type: "text", initialWidth: 200, sortable: true},
               ///////////////////// {label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:70, sortable:true},
                {label: component.get("v.Product"), fieldName:"Product", type:"text", initialWidth:111, sortable:true},
                {label: component.get("v.ProductRegion"), fieldName:"ProductRegion", type:"text", initialWidth:105, sortable:true},
                {label: component.get("v.FromDate"), fieldName:"FromDate", type:"text", initialWidth:112, sortable:true},
                {label: component.get("v.RequestType"), fieldName:"RequestType", type:"text", initialWidth:122, sortable:true},
                {label: component.get("v.Role"), fieldName:"Role", type:"text", initialWidth:70, sortable:true},
                {label: component.get("v.Approvers"), fieldName:"Approvers", type:"text", initialWidth:143, sortable:true},
                {label: component.get("v.RequestedBy"), fieldName:"RequestedBy", type:"text", initialWidth:128, sortable:true},
                {label: component.get("v.CreatedDate"), fieldName:"CreatedDate", type:"date", initialWidth:150, sortable:true},
            ]);
        }

        this.intialiseApprovalComponentData(component);
    },
    
    initialiseETradingEnablementRequest : function(component)
    {
        component.set("v.eTradingSelectedView", "myApprovals");
        
        var options = [
            { value: "myApprovals", label: "My Approvals" },
            { value: "reporteeApprovals", label: "Reportee Approvals" }
        ];
        
        component.set("v.eTradingOptions", options);

        var noCoverageActions = [
            { label: 'Add Coverage', 'iconName': 'action:change_owner', name: 'addCoverage'}
        ];

        component.set('v.eTradingNoCoverageTableColumns', [
            {label: "", fieldName: "requestType", type: "text", initialWidth:5, sortable:false,
             cellAttributes:{iconName:{ fieldName: "requestTypeIcon" }, iconPosition: "right"} },
            {label: $A.get("$Label.c.Reference"), fieldName: 'nameLink', type: 'url', 
            typeAttributes: { 
                label: { fieldName: 'name' }, target: '_blank'  
            }, 
            initialWidth:75, sortable:true},
    		{label: $A.get("$Label.c.RequestedFor"), fieldName: 'salesTeamForCoverageOwnerName', type: 'text', initialWidth:140, sortable:true},
            {label: 'Contact', fieldName: 'contact', type: 'text', initialWidth:130, sortable:true},
    		{label: $A.get("$Label.c.Account"), fieldName: 'accountLink', type: 'url', 
    			typeAttributes: { 
    				label: { fieldName: 'accountName' }, target: '_blank' 
    			}, 
    			initialWidth:150, sortable:true},
            {label: $A.get("$Label.c.ElectronicPlatform"), fieldName: 'electronicPlatform', type: 'text', initialWidth:110, sortable:true},
    		{label: $A.get("$Label.c.Product"), fieldName: 'product', type: 'text', initialWidth:150, sortable:true},
    		{label: $A.get("$Label.c.RequestedBy"), fieldName: 'createdBy', type: 'text', initialWidth:130, sortable:true},
    		{label: $A.get("$Label.c.RequestComments"), fieldName: 'comments', type: 'text', initialWidth:110, sortable:true}, 
            {label: $A.get("$Label.c.SubmittedDate"), fieldName:"createdDate", type:"date", initialWidth:100, sortable:true}, 
            {type: 'action', typeAttributes: { rowActions: noCoverageActions } }
    	]);

        var actions = [
            { label: 'View Coverage', 'iconName': 'action:record', name: 'viewCoverage'}
        ];
        
        component.set('v.eTradingTableColumns', [
            {label: "", fieldName: "requestType", type: "text", initialWidth:5, sortable:false,
             cellAttributes:{iconName:{ fieldName: "requestTypeIcon" }, iconPosition: "right"} },
            {label: $A.get("$Label.c.Reference"), fieldName: 'nameLink', type: 'url', 
            typeAttributes: { 
                label: { fieldName: 'name' }, target: '_blank'  
            }, 
            initialWidth:75, sortable:true}, 
    		{label: $A.get("$Label.c.RequestedFor"), fieldName: 'salesTeamForCoverageOwnerName', type: 'text', initialWidth:140, sortable:true},
            {label: 'Contact', fieldName: 'contact', type: 'text', initialWidth:130, sortable:true},
    		{label: $A.get("$Label.c.Account"), fieldName: 'accountLink', type: 'url', 
    			typeAttributes: { 
    				label: { fieldName: 'accountName' }, target: '_blank'  
    			}, 
    			initialWidth:150, sortable:true},
            {label: $A.get("$Label.c.ElectronicPlatform"), fieldName: 'electronicPlatform', type: 'text', initialWidth:110, sortable:true},
    		{label: $A.get("$Label.c.Product"), fieldName: 'product', type: 'text', initialWidth:150, sortable:true},
    		{label: $A.get("$Label.c.RequestedBy"), fieldName: 'createdBy', type: 'text', initialWidth:130, sortable:true},
    		{label: $A.get("$Label.c.RequestComments"), fieldName: 'comments', type: 'text', initialWidth:110, sortable:true}, 
            {label: $A.get("$Label.c.SubmittedDate"), fieldName:"createdDate", type:"date", initialWidth:100, sortable:true}, 
            {type: 'action', typeAttributes: { rowActions: actions } }
    	]);
        
    },
    
    loadETradingEnablementRequestData : function(component)
    {
        var selectedView = component.get("v.eTradingSelectedView");
        
		var action = component.get("c.getETradingEnablementApprovalRequests");
    	action.setStorable();
    	action.setAbortable();
    	
    	action.setParams
        ({
            'selectedView' : selectedView
        });    
        
        action.setCallback(this, function(response) 
        {
            var state = response.getState();
            
            if (state == "SUCCESS") 
            {
            	var requestData = JSON.parse(response.getReturnValue());
            	
                component.set("v.displayETradingNoCoverageList", requestData.displayETradingNoCoverageList);
                component.set("v.displayETradingApprovalList", requestData.displayETradingApprovalList);
                component.set("v.eTradingNoCoverageList", requestData.eTradingEnablementNoCoverageRequestData); 
                component.set("v.eTradingApprovalList", requestData.eTradingEnablementRequestData);
        		component.set("v.eTradingLoaded", true); 
            }
            else
            {
            	this.displayErrorToast('Unable to read Approval Requests');
            }

        });

		$A.enqueueAction(action);
    }, 

    eTradingEnablementSelected : function(component, event)
    {
		var selectedRows = event.getParam('selectedRows');
        var selectedIds = [];
		
		for (var varLoop = 0; varLoop < selectedRows.length; varLoop++)
		{
            selectedIds.push(selectedRows[varLoop].id);
		}

		component.set('v.eTradingSelectedIds', selectedIds);
    }, 
  
    updateETradingColumnSorting : function(component, event, table)
    {
        var fieldName = event.getParam("fieldName");
        var sortDirection = event.getParam("sortDirection");

        if (table == "Coverage")
        {
            component.set("v.eTradingApprovalListSortedBy", fieldName);
            component.set("v.eTradingApprovalListSortedDirection", sortDirection);
        }
        else if (table == "NoCoverage")
        {
            component.set("v.eTradingNoCoverageListSortedBy", fieldName);
            component.set("v.eTradingNoCoverageListSortedDirection", sortDirection);
        }

        this.sortETradingData(component, fieldName, sortDirection, table);
    },

    sortETradingData: function (component, fieldName, sortDirection, table) 
    {
        if (table == "Coverage")
        {
            var data = component.get("v.eTradingApprovalList");
            var reverse = sortDirection !== 'asc';

            data.sort(this.sortBy(fieldName, reverse))
            component.set("v.eTradingApprovalList", data);
        }
        else if (table == "NoCoverage")
        {
            var data = component.get("v.eTradingNoCoverageList");
            var reverse = sortDirection !== 'asc';

            data.sort(this.sortBy(fieldName, reverse))
            component.set("v.eTradingNoCoverageList", data);
        }
    },

    eTradingEnablementViewSelected : function(component, event)
    {
    	var selectedView = event.getParam("value");
        component.set("v.approvalList",new Array());
        component.set("v.eTradingSelectedView", selectedView);
    	this.loadETradingEnablementRequestData(component, selectedView);
    },
    
    processETradingRequests : function(component, approvalAction)
    {
    	var action = component.get("c.processRequests");
    	var eTradingEnablementIds = component.get('v.eTradingSelectedIds');
        
        action.setParams
        ({
            'eTradingEnablementIds' : eTradingEnablementIds,
            'approvalAction': approvalAction
        });
        
        this.showSpinner(component);

    	action.setCallback(this, function(response)
    	{
            this.hideSpinner(component);
            
            var state = response.getState();
    		
    		if (state == "SUCCESS")
    		{
    			var approvalData = JSON.parse(response.getReturnValue());
	            	
            	if (!approvalData.error)
            	{
            		var message;
            		
            		if (approvalAction == 'Approve')
            		{
            			message = 'Items Approved';
            		}
            		else if (approvalAction == 'Reject')
            		{
            			message = 'Items Rejected';
            		}
            		else
            		{
            			message = 'Processing complete';
            		}
            		
            		this.removeProccessedItems(component, eTradingEnablementIds);
            		this.displayToast(message);
            	}
            	else
            	{
            		this.displayErrorToast(approvalData.errorMessage);
            	}
    		}
    		else
    		{
    			this.displayErrorToast('Error approving requests');
            }
            
            component.hideSpinner();
    	});
    	
    	$A.enqueueAction(action);
    },
    
    removeProccessedItems : function(component, eTradingEnablementIds)
    {
        var rows = component.get("v.eTradingApprovalList");
    	
		for (var varLoop = 0; varLoop < eTradingEnablementIds.length; varLoop++)
		{
            for (var rowLoop = 0; rowLoop < rows.length; rowLoop++)
            {
                var row = rows[rowLoop];

                if (row.id == eTradingEnablementIds[varLoop])
                {
                    rows.splice(rowLoop, 1);
                }

                component.set("v.eTradingApprovalList", rows);
           }
        }
    },

    coverageRequest : function(component, event)
    {
        var action = event.getParam("action");
        var row = event.getParam("row");

        switch (action.name)
        {
            case "addCoverage" : 
                var accountId = row.accountId;
                
                component.find("navigationService").navigate({
                    "type": "standard__component",
                    "attributes": {
                        "componentName" : "c__coverageToolAdd" 
                    },
                    "state":{
                        "c__source" : "CoverageTool",
                        "c__reset" : true, 
                        "c__accountLookupId" : accountId
                    }
                }, false);
                
                break;

            case "viewCoverage" : 
                component.find("navigationService").navigate({
                    "type": "standard__navItemPage",
                    "attributes": {
                        "apiName" : "Coverage" 
                    },
                    "state":{
                        "c__reset" : true
                    }
                }, false);
                
                break;
        }
    },

    displayToast : function(message)
    {
    	var toastEvent = $A.get("e.force:showToast");
    	
    	toastEvent.setParams({
    		title: "Success",
            message: message,
            type: "success", 
        });
            
        toastEvent.fire();
    }, 
    
    displayErrorToast : function(errorMessage)
    {
    	var toastEvent = $A.get("e.force:showToast");
    	
    	toastEvent.setParams({
    		title: "Error",
            message: errorMessage,
            type: "error", 
            mode: "sticky"
        });
            
        toastEvent.fire();
    },

    showSpinner : function(component)
    {   
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinner : function(component)
    {  
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
    },
        
    //added for JIRA SALES 1588 
    //Added amount for jira 3525  
    loadOpportunityRequestData : function(component){
        component.set("v.oppttableColumn", [                
            {label: $A.get("$Label.c.CrossSell_Opportunity"), fieldName:"ApprovalRequest", type:"text", initialWidth:180, sortable:true},
            {label: $A.get("$Label.c.Cross_Sell_Account_Name"), fieldName:"AccountName", type:"text", initialWidth:180, sortable:true},
            {label: $A.get("$Label.c.Cross_Sell_Region"), fieldName:"ProductRegion", type:"text", initialWidth:113, sortable:true},
            {label: $A.get("$Label.c.Cross_Sell_Product"), fieldName:"Product", type:"text", initialWidth:114, sortable:true},
            {label: $A.get("$Label.c.Cross_Sell_Amount"), fieldName:"Amount", type:"currency", initialWidth:136, sortable:true},              
            {label: $A.get("$Label.c.Cross_Sell_Referred_Person"), fieldName:"RequestedFor", type:"text", initialWidth:150, sortable:true},
            {label: $A.get("$Label.c.Cross_Sell_Referrer"), fieldName:"RequestedBy", type:"text", initialWidth:129, sortable:true}, 
            {label: $A.get("$Label.c.Cross_Sell_Start_Date"), fieldName:"FromDate", type:"text", initialWidth:100, sortable:true},  
            {label: $A.get("$Label.c.Cross_Sell_Stage"), fieldName:"Stage", type:"text", initialWidth:120, sortable:true},  
            {label: $A.get("$Label.c.Cross_Sell_Submitted_Date"), fieldName:"CreatedDate", type:"text", initialWidth:100, sortable:true}
        ]);         

        var action = component.get("c.getItemstoApprove");
           action.setCallback(this,function(response){
            var state = response.getState();
            var responseData = response.getReturnValue();
            console.log('data ::'+ response.getReturnValue());
            console.log('state ::'+ state);
            if(state === "SUCCESS"){   
               component.set("v.opptapprovalList",responseData);
               component.hideSpinner();
            }
          });      
       $A.enqueueAction(action);    
    },
    processOpptRequests: function(component,event, helper, strAction){
        var action = component.get("c.processOpptRequests");
        component.showSpinner();
        if(strAction == 'Approve')
            action.setParams({"ProcessingIds" : JSON.stringify(component.get('v.selectedOppIDList')),
                          "Comments": "",
                          "strAction":strAction}); 
        else
           action.setParams({"ProcessingIds" : JSON.stringify(component.get('v.selectedOppIDList')),
                          "Comments":component.get("v.RejectComments"),
                          "strAction":strAction});  
           
        action.setCallback(this,function(response){            
            var state = response.getState()
            if(state === "SUCCESS"){
                component.showToast('','success','Records Processed.');    
                var responseData = response.getReturnValue();
                component.set("v.opptapprovalList",responseData);  
                this.sortOpptData(component,"CreatedDate","desc");
                component.hideSpinner();
                $A.get('e.force:refreshView').fire();                
            }            
        });
        
        $A.enqueueAction(action);   
    },
    sortOpptData: function (component, fieldName, sortDirection) {
        var data = component.get("v.opptapprovalList");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.opptapprovalList", data);
    },  
           

    /*
    hideShowSCHApprovalTab : function(component){
        var action = component.get('c.isCurrentSchApprover');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                
                if(result)
                    component.set('v.showSCHApprovalTab', true);
                else
                    component.set('v.showSCHApprovalTab', false);
                }
            });
            $A.enqueueAction(action);
    },

    hideShowOnbReqApprovalTab : function(component){
        var action = component.get('c.isCurrentPreOnboardingApprover');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                if(result)
                    component.set('v.showOnbReqApprovalTab', true);
                else
                    component.set('v.showOnbReqApprovalTab', false);
                }
            });
            $A.enqueueAction(action);
    },
    */
})