({
    init: function(component, event, helper) {
        component.set('v.maxHeight',"390");
        helper.fetchSearchResults(component, event, helper, true);
    },
    
    /*--------------------------------------- TOGGLE SECTIONS ----------------------------*/
    toggleFilters : function(component, event, helper) {
        var acc = component.find('filter');
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        } 
            var expandedSection = document.getElementById('filterRef');
            if(!expandedSection.classList.contains('slds-hide'))
            {
            	component.set('v.maxHeight',"550");
            }
            else
            {
            	component.set('v.maxHeight',"450");
            }
    },
    
    /*-2.3--- INCLUDE-------------------------------------*/

    
    /*hideTable : function(component, event, helper) {
        consle.log("#### hideTable()");
        var dataTableDiv = component.find("dataTableDiv");
        //var footerDiv = component.find("footerId");
        $A.util.addClass(dataTableDiv, "slds-hide");
        A.util.removeClass(dataTableDiv,'slds-show');
        //$A.util.addClass(footerDiv, "slds-hide");
    },*/
	/*2------------FILTER ACTIONS - CHANGED ----------------------------*/
    /*-2.1--- ACCOUNTS-------------------------------------*/
    accountsChanged : function(component,event,helper){
        if(event.getParam("values").length >= 1) {
            component.set("v.accountIDs",event.getParam("values"));
        }
        else {
            component.set("v.accountIDs", []);
        }
    },
    
    contactChange : function(component, event, helper){
        if(event.getParam("values").length >= 1){
           component.set("v.contactIDs", event.getParam("values"));
        }
        else{
            component.set("v.contactIDs", []);
        } 
    },

    salesCodeChanged : function(cmp,event,helper){
        if(event.getParam("values").length >= 1){
            cmp.set("v.salesTeamForCoverageIDs",event.getParam("values"));
        }
        else {
            cmp.set("v.salesTeamForCoverageIDs", []);
        }
    },
    
    /*--------------------------------------- HELPER JS ----------------------------*/
    helperScriptsLoaded: function (cmp, event,helper) {
        cmp.set("v.isHelperScriptLoaded",true);
        cmp.set("v.needToRenderHelperLogic",true);
    }, 
    toggleScriptsLoaded: function (cmp, event,helper) {
        cmp.set("v.istoggleScriptLoaded",true);
        cmp.set("v.needToRenderToggleLogic",true);
    },
    
    getSelectedData: function (cmp, event) {
        var selectedRows = event.getParam("selectedRows");
        cmp.set("v.selectedData",selectedRows);
        cmp.set("v.selectedDataList" ,event.getParam('selectedRows'));
    },
    
    handleRevoke : function (component, event, helper) {
        component.set("v.comment",'');
    	component.set("v.revokeClicked",true); 
    },
    
    handleRevokeSave : function (component, event, helper) {
    	helper.revokeETEnablements(component, event, helper);
    	component.set("v.revokeClicked",false);
    },
    
    handleRevokeCancel : function (component, event, helper) {
        component.set("v.revokeClicked",false);
    },
     
    /*handleCompleted : function (component, event, helper) {
        // contruct the fields to be updated parameter, follow the naming convention as it is de-serialize by apex-controller
        var eTEnablementFieldsToUpdateList = [];
        eTEnablementFieldsToUpdateList.push({"colFieldName":"status", "fieldApiName":"Status__c", "fieldVal":"Complete"});
        var fieldParameters={};
        fieldParameters["ETEnablementUpdateParamsList"]=eTEnablementFieldsToUpdateList;
        helper.updateETEnablements(component, event, helper,component.get("v.currentUserId"), fieldParameters, ["status"]);
    },*/
    
    handleAssignSalesCodeCancel: function (component, event, helper)
    {
        component.set("v.comment", "");
        component.set("v.assignedSalesCodeIds", []);
        component.set("v.displayAssignSalesCode", false);
    },

    handleAssignSalesCodeChanged : function(component, event, helper)
    {
        helper.setAssignedSalesCodeIds(component, event);
    },

    handleAssignSalesCodeSave : function (component, event, helper) 
    {
        //helper.assignSalesCodeSave(component, event);

        let comment = component.get("v.comment");
        let selectedRows = component.get("v.selectedDataList");
        var assignedSalesCodeIds = component.get("v.assignedSalesCodeIds");
        if(!$A.util.isEmpty(comment) && !$A.util.isEmpty(assignedSalesCodeIds)) {
    		let today = new Date();
            let currentDate = today.getDate()+"-"+(today.getMonth()+1)+"-"+today.getFullYear(); 
            let newCommentFormatted = component.get("v.currentUserName") +", "+currentDate+" - "+comment;

            let eTEnablementFieldsToUpdateList = [];
            eTEnablementFieldsToUpdateList.push({"colFieldName":"comments", "fieldApiName":"Comments__c", "fieldVal":newCommentFormatted});
            eTEnablementFieldsToUpdateList.push({"colFieldName":"salesPersonId", "fieldApiName":"Sales_Team_for_Coverage__c", "fieldVal":assignedSalesCodeIds[0]});
            let fieldParameters={};
            fieldParameters["ETEnablementUpdateParamsList"]=eTEnablementFieldsToUpdateList;
            
            let eTEnabPostUpdateFldList = [];
            eTEnabPostUpdateFldList.push({"colFieldName":"salesPersonName", "fieldApiName":"Sales_Team_for_Coverage__r.Name"});
            eTEnabPostUpdateFldList.push({"colFieldName":"status", "fieldApiName":"Status__c"});
            let fieldPostUpdParameters={};
            fieldPostUpdParameters["ETEnablementUpdateParamsList"]=eTEnabPostUpdateFldList;

            console.log("NEW Comment : ",newCommentFormatted);
            helper.updateETEnablements(component, event, helper,component.get("v.currentUserId"), fieldParameters, ["salesPersonName"], fieldPostUpdParameters);
            component.set("v.comment", "");
            component.set("v.assignedSalesCodeIds", []);
    	} else {
    		helper.showToast(component, event, helper, "Error", "Sales-Code and Comment is required.", "error", "dismissible", null, 5000);
        }
        component.set("v.displayAssignSalesCode",false);
    },

    handleAssignSave : function(component, event, helper) {
    	var assignedUserId = component.get("v.assignedUserId");
    	if(!$A.util.isEmpty(assignedUserId) && assignedUserId.length>0 && !$A.util.isEmpty(assignedUserId[0])) {
    		//helper.updateETEnablements(component, event, helper, "actionedById", "Actioned_By__c", assignedUserId[0], ["actionedBy"])
    		component.set("v.eTEnablementFieldsToUpdateList", []);
            helper.updateETEnablements(component, event, helper, assignedUserId[0], ["status"]);
            helper.updateETEnablements(component, event, helper,assignedUserId[0], null, ["status"]);
    	} else {
    		helper.showToast(component, event, helper, "Error", "No User selected", "error", "dismissible", null, 5000);
    	}
    	component.set("v.assignClicked",false);
    },
    
    handleAssignCancel : function (component, event, helper) {
    	component.set("v.assignClicked",false);
    },

    handleCommentCancel : function (component, event, helper) {
        component.set("v.commentClicked",false);
        component.set("v.onHoldClicked",false); 
        component.set("v.comment", null);
    },

    
    /*handleCommentSave : function (component, event, helper) {
    	var comment = component.get("v.comment");
    	if(!$A.util.isEmpty(comment)) {
    		helper.addComments(component, event, helper);
    	} else {
    		helper.showToast(component, event, helper, "Error", "No comment was provided", "error", "dismissible", null, 5000);
    	}
    	component.set("v.commentClicked",false);
    },*/

    handleCommentSave : function (component, event, helper) {
        helper.commentSave(component, event, helper);
    },
    
    userChanged : function(component,event,helper){
        var userId = [];
        var values = event.getParam("values"); 
        if(!$A.util.isEmpty(values))
        {
        	userId = values;
        }
        component.set("v.assignedUserId", userId);
    },
    
    /*9---------------------SORTING -----------------------------*/
    // Client-side controller called by the onsort event handler
    updateColumnSorting: function (cmp, event, helper) {
        var dataTable = cmp.find("coverageTable");
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        dataTable.set("v.sortedBy", fieldName);
        dataTable.set("v.sortedDirection", sortDirection);        
        helper.sortData(cmp, fieldName, sortDirection);
    },
    
    sortData:function (cmp, event, helper) {
        var params = event.getParam('arguments');
        if(params)
        {
            var field = params.field;
            var dir = params.dir;
            helper.sortData(cmp, field, dir);
        }
    },
    
    handleAdd: function(cmp,event,helper){
        var addevt = $A.get("e.force:navigateToComponent");
        addevt.setParams({
            componentDef : "c:ETradingEnablementRequest",
            componentAttributes: {
                withoutSharing : false
            }
        });
        addevt.fire(); 
    }, 
    
    /*3------------BUTTON EVENTS ----------------------------*/
    /*3.1------------SEARCH ------------------------------*/
    doSearch: function(component, event, helper){
        helper.fetchSearchResults(component, event, helper, false); //HELPER CALL
        component.set("v.isLoadInit", false);
    },
    
    doToggleSearch : function(component, event, helper){
        helper.fetchSearchResults(component, event, helper, false);
        component.set('v.isLoadInit',false);
    },
    
    handleTypeClick : function(component, event, helper) {
        var target = event.getSource(); 
		var btnName = target.get("v.name");
        var recType = component.get("v.recType");
        if(btnName!==recType) {
            helper.hideDataTable(component, event, helper);
            component.set("v.recType", btnName);
            helper.fetchSearchResults(component, event, helper, false);
        }
    },
    
    handleSelectChangeEvent : function(component, event, helper){
        if(event.getParam("values").length >= 1) {
            component.set("v.selectedRequestStatus",event.getParam("values"));
        } else {
            component.set("v.selectedRequestStatus",[]);
        } 
    },
    
    handlePlatformsChangeEvent : function(component, event, helper){
        if(event.getParam("values").length >= 1) {
            component.set("v.selectedPlatforms",event.getParam("values"));
        } else {
            component.set("v.selectedPlatforms",[]);
        } 
    },
    
    handleProductsChangeEvent : function(component, event, helper){
        if(event.getParam("values").length >= 1) {
            component.set("v.selectedProducts",event.getParam("values"));
        } else {
            component.set("v.selectedProducts",[]);
        } 
    },

    handleStatusUpdate : function (component, event, helper) {

        var selectedMenuItemValue = event.getParam("value");

        if(selectedMenuItemValue == 'Process')
        {
            helper.handleProcess(component, event, helper);    
        }
        else if(selectedMenuItemValue == 'On Hold')
        {
            helper.handleOnHold(component, event, helper);     
        }
        else if(selectedMenuItemValue == 'Cancel')
        {
            helper.handleCancel(component, event, helper); 
        }
        else if(selectedMenuItemValue == 'Complete')
        {
            helper.handleCompleted(component, event, helper); 
        }

    },

    handleAssign : function (component, event, helper) {

        var selectedMenuItemValue = event.getParam("value");    
        
        if(selectedMenuItemValue == 'Contact Assignment')
        {
            helper.handleAssignContact(component, event, helper);    
        }
        else if(selectedMenuItemValue == 'Update Sales Code')
        {
            helper.handleAssignSalesCode(component, event, helper);     
        }
        else if(selectedMenuItemValue == 'Assign Responsility')
        {
            helper.handleAssignResponsility(component, event, helper);     
        }
    },

    handleActions : function (component, event, helper) {
        
        var selectedMenuItemValue = event.getParam("value");    
        
        if(selectedMenuItemValue == 'Comment')
        {
            helper.handleComment(component, event, helper);    
        }
        else if(selectedMenuItemValue == 'Attach File')
        {
            helper.handleAttachFile(component, event, helper);     
        }
        else if(selectedMenuItemValue == 'Export')
        {
            helper.handleExport(component, event, helper);     
        }
    },

    handleUploadFinished : function (component, event, helper){
        var uploadedFiles = event.getParam("files");
        component.set("v.fileUploadId", uploadedFiles[0].documentId);  
    },

    handleAttachFileSave : function (component, event, helper)
    {
        helper.showSpinner(component, event, helper);
        
        var fileId = component.get("v.fileUploadId");
        var fileParentId = component.get("v.attachFilePrimaryRecId"); 
        var selectedRows = component.get("v.selectedDataList");
        var newComment = component.get("v.comment")

        // call the server side function  
        var action = component.get("c.attachFile");
        action.setParams({
            "fileId": fileId, "fileParentId": fileParentId, "comment":newComment,
            "eTradingEnablementListString":JSON.stringify(selectedRows)
        });

        //set callback  
        action.setCallback(this, function(response) {
            if (response.getState()==="SUCCESS") {}    
            else if (response.getState()==="ERROR") 
            {
                var errMsg="";
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        errMsg+=errors[0].message;
                    }
                } else {
                    errMsg+="Unknown error";
                }
            }
            

            // show the right toast message based on results
            var title="";
            var message="";
            var type="";
            // there was error in perfoming the server action
            if(!$A.util.isEmpty(errMsg)) {
                title="Error";
                message=errMsg;
                type="error";
            } 
            else
            {
                title="Success";
                message="File Attached";
                type="success";

                helper.commentSave(component, event, helper);

            }
            helper.hideSpinner(component, event, helper);
        });
        $A.enqueueAction(action);
        component.set("v.attachFileClicked",false);
        component.set("v.fileUploadId", null);
        component.set("v.attachFilePrimaryRecId", null);
    },

    handleAttachFileCancel : function (component, event, helper) {
        helper.showSpinner(component, event, helper);
        // if file upload then delete
        var fileId = component.get("v.fileUploadId");
        if(!$A.util.isEmpty(fileId))
        {
             // call the server side function  
            var action = component.get("c.deleteAttachFile");
            action.setParams({
                "fileId": fileId
            });

             //set callback  
            action.setCallback(this, function(response) {
                if (response.getState()==="SUCCESS") {}    
                else if (response.getState()==="ERROR") 
                {
                    var errMsg="";
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            errMsg+=errors[0].message;
                        }
                    } else {
                        errMsg+="Unknown error";
                    }
                }
                helper.hideSpinner(component, event, helper);
            });
            $A.enqueueAction(action);
        }
        component.set("v.attachFileClicked",false);
        component.set("v.fileUploadId", null);
        component.set("v.attachFilePrimaryRecId", null);
        component.set("v.comment", null);
    },

})