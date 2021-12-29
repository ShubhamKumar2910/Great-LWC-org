({
	init : function(component, event, helper) {
		console.log("#### c:ClientPrioritySetupHelper.init()");
		helper.showSpinner(component, event, helper);
		component.set("v.tableData", null);
        component.set("v.tableColumns", null);
		component.set("v.tableErrors", null);
		// call the server side function  
        var action = component.get("c.initialize");
        // to server side function 
        action.setParams({
        	"isInit":true
        });
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState()==="SUCCESS") {
                var initInfo = response.getReturnValue();
                if(!$A.util.isEmpty(initInfo)) {
                	console.log("initInfo : ",initInfo);
                	
                	helper.initializePLOptions(component, event, helper, initInfo.CoalitionPickListLabValMap, 
                			"v.coalitionLabelList", "v.coalitionLabelByActionNameMap");
                	helper.initializePLOptions(component, event, helper, initInfo.GreenwichPickListLabValMap, 
                			"v.greenwichLabelList", "v.greenwichLabelByActionNameMap");
                	
                	// create table columns
                	helper.createDataTableColumn(component, event, helper);
                	
                	// create table rows
                			
                	helper.createDataTableRows(component, event, helper, initInfo);
                }
            } else if(response.getState()==="ERROR") {
            	var errMsg="";
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        errMsg+=errors[0].message;
                    }
                } else {
                    errMsg+="Unknown error";
                }
                
                helper.showToast(component, event, helper, "Error", errMsg, "error", "sticky", null, 10000);
            }
            
            helper.hideSpinner(component, event, helper);
        });
        
        $A.enqueueAction(action);
        
    },

    handleSave : function (component, event, helper) {
    	console.log("#### c:ClientPrioritySetupHelper.handleSave()");
    	
    	helper.showSpinner(component, event, helper);
    	component.set("v.tableErrors", {});
    	var rows = component.get("v.tableData");
    	if(!$A.util.isEmpty(rows)) {
    		var PriorityClientsToUpsert = [], PriorityClientsToDelete = [];
    		for(var i=0; i<rows.length; ++i) {
    			var row = rows[i];
    			if(row.isClientSurvey===false && row.isPrioirtyClient===false && !$A.util.isEmpty(row.priorityClientId)) {
    				// if Client Survey checkbox has been set to false of a existing records, then delete it
    				PriorityClientsToDelete.push({ 
    					"priorityClientId":row.priorityClientId,
    					"rgAccId" : row.rgAccId 
    				});
    			} else if(row.isClientSurvey===true || row.isPrioirtyClient===true) {
    				var rec = {
    					"isClientSurvey" : row.isClientSurvey,
    					"coalitionPLvals" : row.coalitionPLvals,
    					"greenwichPLvals" : row.greenwichPLvals,
    					"isPrioirtyClient" : row.isPrioirtyClient,
    					"rgAccId" : row.rgAccId
    				};
    				if(!$A.util.isEmpty(row.priorityClientId)) {
    					rec["priorityClientId"] = row.priorityClientId;
    				}
    				if(!$A.util.isEmpty(row.contId)) {
    					rec["contId"] = row.contId;
    				}
    				PriorityClientsToUpsert.push(rec);
    			}
    		}
    		
    		if(!$A.util.isEmpty(PriorityClientsToUpsert) || !$A.util.isEmpty(PriorityClientsToDelete)) {
   		    	// call the server side function  
		        var action = component.get("c.save");
		        // to server side function 
		        action.setParams({
		        	"PriorityClientsToUpsert":JSON.stringify(PriorityClientsToUpsert),
		        	"PriorityClientsToDelete":JSON.stringify(PriorityClientsToDelete)
		        });
		        //set callback   
		        action.setCallback(this, function(response) {
		        	if (response.getState()==="SUCCESS") {
		                var saveResults = response.getReturnValue();
		                console.log("saveResults : ",saveResults);
		                var noOfErr=0; 
		                var noOfSucc=0;
		                var rowsModified = false;
		                if(!$A.util.isEmpty(saveResults)) {
		                	var rowErrors={};
		                	var tableRows = component.get("v.tableData");
		                	// loop through delete results
		                	if(!$A.util.isEmpty(saveResults.DeleteResultList) && !$A.util.isEmpty(tableRows)) {
		                		for(var i=0; i<saveResults.DeleteResultList.length; ++i) {
		                			var delRslt = saveResults.DeleteResultList[i];
		                			if(delRslt.hasErrors===true) {
		                				rowErrors[delRslt.rgAccId]={
		                					"title":"Error",
		                					"messages":delRslt.error,
		                					"fieldNames":["coalitionPLvals", "greenwichPLvals"]	
		                				};
		                				++noOfErr;
		                			} else {
		                				rowsModified=true;
		                				// reset the fields to null for successfully deleted records
		                				for(var j=0; j<tableRows.length; ++j) {
		                					if(tableRows[j].rgAccId === delRslt.rgAccId) {
		                						tableRows[j].priorityClientId="";
		                						tableRows[j].isClientSurvey=false;
		                						tableRows[j].clntSurvButtonIcon="";
		                						tableRows[j].coalitionPLvals="";
		                						tableRows[j].greenwichPLvals="";
		                						tableRows[j].isPrioirtyClient=false;
		                						tableRows[j].priClntButtonIcon="";
		                						
		                						tableRows[j].contId = null;
		                						tableRows[j].contName = null;
		                						tableRows[j].contURL = null;
		                						
		                						break;
		                					}
		                				}
		                				++noOfSucc;
		                			}
		                		}
		                	}
		                	
		                	if(!$A.util.isEmpty(saveResults.UpsertResultList) && !$A.util.isEmpty(tableRows)) {
		                		for(var i=0; i<saveResults.UpsertResultList.length; ++i) {
		                			var upRslt = saveResults.UpsertResultList[i];
		                			if(upRslt.hasErrors===true) {
		                				var errFields = [];
		                				if(!$A.util.isEmpty(upRslt.error)) {
		                					if(upRslt.error.includes("Greenwich Client Survey")) {
		                						errFields.push("emptyErrHandling");
	                						}
	                						
	                						if(upRslt.error.includes("Desk / Product")) {
	                							errFields.push("emptyErrHandling");
	                						}
		                				} 
		                				
		                				rowErrors[upRslt.rgAccId]={
		                					"title":"Error",
		                					"messages":upRslt.error,
		                					"fieldNames":errFields	
		                				}; 
		                				++noOfErr;
		                			} else {
		                				rowsModified=true;
		                				++noOfSucc;
		                				// reset the fields to null for successfully deleted records
		                				for(var j=0; j<tableRows.length; ++j) {
		                					if(tableRows[j].rgAccId === upRslt.rgAccId) {
		                						tableRows[j].priorityClientId=upRslt.priorityClientId;
		                						/*if(tableRows[j].isClientSurvey===false) {
		                							tableRows[j].greenwichPLvals="";
		                						}
		                						if(tableRows[j].isPrioirtyClient===false) {
		                							tableRows[j].coalitionPLvals="";
		                						}*/
		                						break;
		                					}
		                				}
		                			}
		                		}
		                	}
		                	
		                	if(!$A.util.isEmpty(rowErrors)) {
	                            var errorss = {};
	                            errorss["rows"]=rowErrors;
	                            component.set("v.tableErrors", {
	                                rows:rowErrors
	                                //table:{
	                                //    title:"The statuses marked in red cannot be updated, please click icon to for more details.",
	                                //    messages: [
	                                //        "Row 2 amount must be number",
	                    			//		"Row 2 email is invalid"
	                				//	]
	                                //}
	                            });
		                	}
		                	
		                	if(rowsModified===true) {
		                		component.set("v.tableData", tableRows);
		                	}

		                	var title="", message="", type="";
		                	if(noOfErr>0 && noOfSucc===0) {
		                		title="Error";
		                		message="Prioriy Clients update operation completed with errors"; 
		                		type="error";
		                	} else if(noOfErr===0 && noOfSucc>0) {
		                		title="Success";
		                		message="Prioriy Clients update operation completed successfull."; 
		                		type="success";
		                	} else if(noOfErr>0 && noOfSucc>0) {
		                		title="Warning";
		                		message="Prioriy Clients update operation partially completed with errors "; 
		                		type="warning";
		                	}
		                	helper.showToast(component, event, helper, title, message, type, "dismissible", null, 10000);
		                }
		            } else if(response.getState()==="ERROR") {
		            	var errMsg="";
		                var errors = response.getError();
		                if (errors) {
		                    if (errors[0] && errors[0].message) {
		                        errMsg+=errors[0].message;
		                    }
		                } else {
		                    errMsg+="Unknown error";
		                }
		                
		                helper.showToast(component, event, helper, "Error", errMsg, "error", "sticky", null, 10000);
		            }
		        	helper.hideSpinner(component, event, helper);
		        });
		        $A.enqueueAction(action);
	        } else {
	        	helper.hideSpinner(component, event, helper);
	        }
    	}
    },
    
    
    initializePLOptions : function(component, event, helper, pickListLabValMap, attrLabelList, attrLabelByActionNameMap) {
    	console.log("#### c:ClientPrioritySetupHelper.initializePLOptions()");
    	var LabelList = [];
    	if(!$A.util.isEmpty(pickListLabValMap)) {
    		var actionName;
			var LabelByActionName={};
    		Object.entries(pickListLabValMap).forEach(([key, value]) => {
    			if(!$A.util.isEmpty(value)) {
    				LabelList.push(value);
    				actionName = value.replace(/[^A-Z0-9]+/ig, "_");
    				LabelByActionName['add_'+actionName]=value;
    				LabelByActionName['remove_'+actionName]=value;
				}
            });
    	}
    	
    	component.set(attrLabelList, LabelList);
    	component.set(attrLabelByActionNameMap, LabelByActionName);
    },
    
    handleRowAction: function (component, event, helper) {
    	console.log("#### c:ClientPrioritySetupHelper.handleRowAction()");
        var action = event.getParam('action');
        var row = event.getParam('row');
        var rows = component.get("v.tableData");
        var rowIndex = rows.indexOf(row);
        
        console.log("ACTION : ",action);
        console.log("name : ",action.name);
        console.log("action.label : ",action.label);
        console.log("rowIndex : ",rowIndex);
        
        switch(action.name) {
        	case "toggle_client_survey":
        		row.isClientSurvey = !row.isClientSurvey;
        		var iconName = (row.isClientSurvey===true) ? "utility:check" : "";
        		row.clntSurvButtonIcon = iconName;
        		row.greenwichPLvals = null;
        		helper.updateRows(component, event, helper, rowIndex, row); 
        		break;
        	case "toggle_priority_client":
        		row.isPrioirtyClient = !row.isPrioirtyClient;
        		var iconName = (row.isPrioirtyClient===true) ? "utility:check" : "";
        		row.priClntButtonIcon = iconName;
        		row.coalitionPLvals = null;
        		helper.updateRows(component, event, helper, rowIndex, row); 
        		break;
        	case "addCont":
        		helper.openBrowseContactScreen(component, event, helper, row);
        		console.log("Added Contact");
        		break;
        	case "updateCont":
        		helper.openBrowseContactScreen(component, event, helper, row);
        		console.log("Updated Contact");
        		break;
        	case "clearCont":
        		helper.clearContact(component, event, helper, row);
        		console.log("Cleared Contact");
        		break;
        	default:
        		var coalitionLabelByActionNameMap = component.get("v.coalitionLabelByActionNameMap");
		        var greenwichLabelByActionNameMap = component.get("v.greenwichLabelByActionNameMap");
		        
		        // by default its undefined
		        var isAdd;
		        if(action.name.startsWith("add_")) {
		    		isAdd=true;
		    	} else if(action.name.startsWith("remove_")) {
		    		isAdd=false;
		    	}
		        
		        var label;
		        if(action.name in greenwichLabelByActionNameMap) { 
		        	label = greenwichLabelByActionNameMap[action.name];
		        	row.greenwichPLvals = helper.modifyOptions(component, event, helper, isAdd, label, row.greenwichPLvals);
		        	helper.updateRows(component, event, helper, rowIndex, row);
		        } else if(action.name in coalitionLabelByActionNameMap) {
		        	label = coalitionLabelByActionNameMap[action.name];
		        	row.coalitionPLvals = helper.modifyOptions(component, event, helper, isAdd, label, row.coalitionPLvals);
		        	helper.updateRows(component, event, helper, rowIndex, row);
		        }
        }
    },
    
    openBrowseContactScreen : function(component, event, helper, row) {
    	console.log("#### c:ClientPrioritySetupHelper.openBrowseContactScreen()");
        
        var array = [];
        if(!$A.util.isEmpty(row.rgAccId)){
            array.push(row.rgAccId);
            component.set("v.seectedRowAccId", row.rgAccId);
        }
        component.set("v.relatedToAccountSelected", array);
        
        if(array.length > 0){
            /*
             * Since modal box is preloaded, during intialization the value of preselected is null
             * Always re-call again to reload with updated value.
            */
            var contactReportSearch = component.find("contactReportSearch");
            var lookupReference  = contactReportSearch.find("accounts");
            lookupReference.callPreSelect();
            contactReportSearch.init();
        }
        

        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
    }, 
    
    closeBrowseContactScreen : function(component, event, helper) {
    	console.log("#### c:ClientPrioritySetupHelper.closeBrowseContactScreen()");
    	var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        component.set("v.seectedRowAccId", null); 
    },
    
    clearContact : function(component, event, helper, row) {
    	console.log("#### c:ClientPrioritySetupHelper.clearContact()");
		var rows = component.get("v.tableData");
        if(!$A.util.isEmpty(rows) && !$A.util.isEmpty(row) && !$A.util.isEmpty(row.contId)) {
	        for(var i=0; i<rows.length; ++i) {
	        	if(row.rgAccId===rows[i].rgAccId) {
	        		rows[i].contId = null;
	        		rows[i].contName = null;
	        		rows[i].contURL = null;
	        		component.set("v.tableData", rows);
	        		break;
	        	}
	        }
        }
    },
    
    updateContact : function(component, event, helper) {
    	console.log("#### c:ClientPrioritySetupHelper.updateContact()");
    	var contactList = event.getParam("contactList");
    	var closeModal = event.getParam("closeBrowseContacts");
    	var seectedRowAccId = component.get("v.seectedRowAccId");
    	var rows = component.get("v.tableData");
        if(!$A.util.isEmpty(seectedRowAccId) && !$A.util.isEmpty(contactList) && !$A.util.isEmpty(rows)) {
	        if(!$A.util.isEmpty(contactList) && contactList.length===1) { 
		        for(var i=0; i<rows.length; ++i) {
		        	if(seectedRowAccId===rows[i].rgAccId) {
		        		rows[i].contId = contactList[0].Id;
		        		rows[i].contName = contactList[0].Name;
		        		rows[i].contURL = "/"+contactList[0].Id;
		        		component.set("v.tableData", rows);
		        		break;
		        	}
		        }
	        }
        }
        
        if(closeModal == true){
           var cmpTarget = component.find('Modalbox');
           var cmpBack = component.find('Modalbackdrop');
           $A.util.removeClass(cmpBack,'slds-backdrop--open');
           $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
           component.set("v.seectedRowAccId", null);
        }
    },
    
    modifyOptions : function (component, event, helper, isAdd, label, plVals) {
    	console.log("#### c:ClientPrioritySetupHelper.modifyOptions()");
    	if(isAdd===true) {
    		if(!$A.util.isEmpty(plVals)) {
    			plVals = plVals + ";" + label; 
    		} else {
    			plVals = label;
    		}
    	} else if(isAdd===false) {
    		if(!$A.util.isEmpty(plVals)) {
    			if(plVals.includes(label+";")) {
    				plVals = plVals.replace(label+";", "");
    			} else if(plVals.includes(";"+label)) {
    				plVals = plVals.replace(";"+label, "");
    			} else {
    				plVals = plVals.replace(label, "");
    			} 
    		}
    	}
    	
    	return plVals;
    },
    
    updateRows : function (component, event, helper, rowIndex, row) {
    	console.log("#### c:ClientPrioritySetupHelper.updateRows()");
        var rows = component.get("v.tableData");
        if(!$A.util.isEmpty(rows)) {
        	rows.splice(rowIndex, 1, row);
        	component.set("v.tableData", rows);
        }
    },
    
    createDataTableRows : function(component, event, helper, initInfo) {
		console.log("#### c:ClientPrioritySetupHelper.createDataTableRows()");
		if(!$A.util.isEmpty(initInfo.PriorityClientWrapperList)) {
			if(initInfo.PriorityClientWrapperList.length!=null && initInfo.PriorityClientWrapperList.length!=undefined) {
				var tableData = [];
				for(var i=0; i<initInfo.PriorityClientWrapperList.length; ++i) {
					var rcvRowData = initInfo.PriorityClientWrapperList[i];
					if(rcvRowData.isClientSurvey===true) {
						rcvRowData.clntSurvButtonIcon = 'utility:check';
					}
					if(rcvRowData.isPrioirtyClient===true) {
						rcvRowData.priClntButtonIcon = 'utility:check';
					}
					
					rcvRowData.coalitionLabelList = component.get("v.coalitionLabelList");
					rcvRowData.greenwichLabelList = component.get("v.greenwichLabelList");

					tableData.push(rcvRowData);
				}
				component.set("v.tableData", tableData);
			}
		}
	},
	
	createDataTableColumn: function(component, event, helper) { 
    	console.log("#### c:ClientPrioritySetupHelper.createDataTableColumn()");
        var coalitionRowActions = helper.getCoalitionRowActions.bind(this, component);
        var contactActions = helper.getContactActions.bind(this, component);
        var greenwichRowActions = helper.getGreenwichRowActions.bind(this, component);
        
    	component.set("v.tableColumns", [
    		{label: '', fieldName: 'emptyErrHandling', fixedWidth: 3, type: 'text', editable:"true"},
			{label: 'RG Account', fieldName: 'rgAccURL', type: 'url', typeAttributes: { label: {fieldName: 'rgAccName' }}},
            
            {label: 'Client Survey', type: 'button', initialWidth: 140, typeAttributes:
                { label: { fieldName: 'clntSurvActLabel'}, title: 'Check or Un-check ', name: 'toggle_client_survey', iconName: {fieldName: 'clntSurvButtonIcon'}, disabled: {fieldName: 'clntSurActionDisabled'}, class: 'btn_next'}},
            {label: 'Greenwich Client Survey', fieldName:'greenwichPLvals', type:'text'},
            { type: 'action', typeAttributes: { rowActions: greenwichRowActions } },
            
            {label: 'Contact', fieldName: 'contURL', type: 'url', typeAttributes: { label: {fieldName: 'contName' }}},
            { type: 'action', typeAttributes: { rowActions: contactActions } },
            
            {label: 'Priority Client ', type: 'button', initialWidth: 140, typeAttributes:
                { label: { fieldName: 'priorityClntLabel'}, title: 'Check or Un-check ', name: 'toggle_priority_client', iconName: {fieldName: 'priClntButtonIcon'}, disabled: {fieldName: 'priClntActionDisabled'}, class: 'btn_next'}},
            {label: 'Desk / Product - (Priority)', fieldName:'coalitionPLvals', type:'text'},
            { type: 'action', typeAttributes: { rowActions: coalitionRowActions } },
		]);
    },
	
	
	
    getCoalitionRowActions: function (component, row, doneCallback) {
    	console.log("#### c:ClientPrioritySetupHelper.getCoalitionRowActions()");
    	
    	var actions=[];
    	if(!$A.util.isEmpty(row.coalitionLabelList)) {
    		var coalitionPLvals = ($A.util.isEmpty(row.coalitionPLvals)) ? "" : row.coalitionPLvals; 
    		for(var i=0; i<row.coalitionLabelList.length; ++i) {
    			var iconName; 
    			var actionName = row.coalitionLabelList[i].replace(/[^A-Z0-9]+/ig, "_");
    			if(coalitionPLvals.includes(row.coalitionLabelList[i])) {
    				// Picklist option already selected, so add Negative action for this option
    				iconName = 'utility:ban';
    				actionName = 'remove_'+actionName; 
    			} else {
    				// Picklist option not selected, so add Positive action for this option
    				iconName = 'utility:new';
    				actionName = 'add_'+actionName;
    			}
    			
    			actions.push({
    				'label': row.coalitionLabelList[i],
					'iconName': iconName,
    				'name': actionName 
    			});
    		}
    	}

        // simulate a trip to the server
        setTimeout($A.getCallback(function () {
            doneCallback(actions);
        }), 100);
    },
    
    getContactActions : function (component, row, doneCallback) {
    	console.log("#### c:ClientPrioritySetupHelper.getContactActions()");
    	
    	var actions = []; 
    	if(!$A.util.isEmpty(row.contId)) {
    		actions.push({
    				'label': 'Update',
					'iconName': 'utility:record_update',
    				'name': 'updateCont'
    		});
    	} else {
    		actions.push({
    				'label': 'Add',
					'iconName': 'utility:new',
    				'name': 'addCont'
    		});
    	}
    	actions.push({
    		'label': 'Clear',
					'iconName': 'utility:ban',
    				'name': 'clearCont'
    	});

        // simulate a trip to the server
        setTimeout($A.getCallback(function () {
            doneCallback(actions);
        }), 100);
    },
	
	
	getGreenwichRowActions: function (component, row, doneCallback) {
    	console.log("#### c:ClientPrioritySetupHelper.getGreenwichRowActions()");
    	var actions=[];
    	if(!$A.util.isEmpty(row.greenwichLabelList)) {
    		var greenwichPLvals = ($A.util.isEmpty(row.greenwichPLvals)) ? "" : row.greenwichPLvals; 
    		for(var i=0; i<row.greenwichLabelList.length; ++i) {
    			var iconName; 
    			var actionName = row.greenwichLabelList[i].replace(/[^A-Z0-9]+/ig, "_");
    			if(greenwichPLvals.includes(row.greenwichLabelList[i])) {
    				// Picklist option already selected, so add Negative action for this option
    				iconName = 'utility:ban';
    				actionName = 'remove_'+actionName; 
    			} else {
    				// Picklist option not selected, so add Positive action for this option
    				iconName = 'utility:new';
    				actionName = 'add_'+actionName;
    			}
    			
    			actions.push({
    				'label': row.greenwichLabelList[i],
					'iconName': iconName,
    				'name': actionName 
    			});
    		}
    	}

        // simulate a trip to the server
        setTimeout($A.getCallback(function () {
            doneCallback(actions);
        }), 100);
    },
    
    showSpinner : function(component, event, helper) {
    	console.log("#### c:ClientPrioritySetupHelper.showSpinner()");
        var spinner = component.find('pageSpinnerDivId');
        $A.util.removeClass(spinner, 'slds-hide');
    },
    
    hideSpinner : function(component,event, helper) {
    	console.log("#### c:ClientPrioritySetupHelper.hideSpinner()");
    	var spinner = component.find('pageSpinnerDivId');
        $A.util.addClass(spinner, 'slds-hide');
    },
    
    showToast : function(component, event, helper, title, message, type, mode, key, duration) {
    	console.log("#### c:BulkUpdateDeskCommentaryProhibitedHelper.showToast()");
        var toastEvent = $A.get("e.force:showToast");
        if(duration) {
            duration=2000;
        }
        if(!$A.util.isEmpty(toastEvent)) {
	        toastEvent.setParams({
	            "title":title,
	            "message":message,
	            "type":type,
	            "mode":mode,
	            "key":key,
	            "duration":duration
	        });
	        toastEvent.fire();
        }
    }
})