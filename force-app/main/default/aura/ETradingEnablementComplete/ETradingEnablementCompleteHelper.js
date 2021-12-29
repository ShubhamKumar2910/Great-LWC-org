({
    initialize: function(component, event, helper) {
    	console.log("#### c:ETradingEnablementCompleteHelper.initialize()");
        helper.showSpinner(component, event, helper);
		//component.set('v.maxETReqTableHeight',650);
		component.set('v.maxETReqTableHeight',200);
		component.set('v.maxETCovTableHeight',200);
		component.set("v.tableAddReqRows", [{}]);
        component.set("v.{!v.tableAddReqColumns", [{}]);
        component.set("v.completedTableRows", []);
		component.set("v.tableAddReqErrors", {});
		let eTradinRecsIdList = [];
        var pageRef = component.get("v.pageReference");
        if(!$A.util.isEmpty(pageRef) && !$A.util.isEmpty(pageRef.state) && !$A.util.isEmpty(pageRef.state.c__csvETradingId)) {
        	eTradinRecsIdList = pageRef.state.c__csvETradingId.split(",");
        }
        component.set("v.eTradinRecsIdList", eTradinRecsIdList);
        eTradinRecsIdList = component.get("v.eTradinRecsIdList");
        //eTradinRecsIdList.push("a0f0p0000009NY2AAM");
        helper.createDataTableColumn(component, event, helper);
        if(!$A.util.isEmpty(eTradinRecsIdList)) {
        	// call the server side function  
	        let action = component.get("c.getEtradingEnablementToCompleteData");
	        // to server side function 
	        action.setParams({"ETradingIdList":eTradinRecsIdList});
	        //set callback   
	        action.setCallback(this, function(response) {
	            if(response.getState()==="SUCCESS") {
	                let eTEnablementData = response.getReturnValue();
	                console.log('eTEnablementData : ',eTEnablementData);
	                if(!$A.util.isUndefinedOrNull(eTEnablementData)) { 
						if(!$A.util.isEmpty(eTEnablementData.ETReqToAddList)) {
							let selectedAddETIdRows = [];
							for(let i=0; i<eTEnablementData.ETReqToAddList.length; ++i) {
								helper.initializeRowDynamicActions(component, event, helper, eTEnablementData.ETReqToAddList[i]);
								selectedAddETIdRows.push(eTEnablementData.ETReqToAddList[i].eTradId);
							}
							component.set("v.tableAddReqRows", eTEnablementData.ETReqToAddList);
							component.set("v.selectedAddETIdRows", selectedAddETIdRows);
							component.set("v.showNewReqSec", true);
							component.set("v.disableAddCovBtn", false);
						} else {
							component.set("v.showNewReqSec", false);
						}
						
						if(!$A.util.isEmpty(eTEnablementData.ETReqToRevokeList) && 
								eTEnablementData.ETReqToRevokeList.length>0) {
							let selectedRevETIdRows = [];
							for(let i=0; i<eTEnablementData.ETReqToRevokeList.length; ++i) {
								selectedRevETIdRows.push(eTEnablementData.ETReqToRevokeList[i].eTradId);
							}		
							component.set("v.tableRevokeReqRows", eTEnablementData.ETReqToRevokeList);
							component.set("v.selectedRevETIdRows", selectedRevETIdRows);
							component.set("v.showRevokeReqSec", true);
							component.set("v.disableRevCovBtn", false);
						} else {
							component.set("v.showRevokeReqSec", false);
						}
	                }
                }
                helper.hideSpinner(component, event, helper);
            });
            $A.enqueueAction(action);
        } else {
        	helper.hideSpinner(component, event, helper);
        }
    },
    
    initializeRowDynamicActions: function(component, event, helper, row) {
    	console.log("#### c:ETradingEnablementCompleteHelper.initializeRowDynamicActions()");
    	if(!$A.util.isEmpty(row) && !$A.util.isEmpty(row.contPlaformIDLabelList)) {
    		row.labelByActionName={};
    		for(let i=0; i<row.contPlaformIDLabelList.length; ++i) {
    			let pfId = row.contPlaformIDLabelList[i];
    			let actionName = pfId.replace(/[^A-Z0-9]+/ig, "_");
    			actionName = actionName+"ACT";
    			row.labelByActionName['add__'+actionName]=pfId;
				row.labelByActionName['remove__'+actionName]=pfId;
    		}
    	}
    },
    
    handleBack : function (component, event, helper) {
    	console.log("#### c:ETradingEnablementCompleteHelper.handleBack()");
    	event.preventDefault();
    	component.find("navigationService").navigate({
	            "type": 'standard__component',
	            "attributes": {
	              	componentName: 'c__ETradingEnablementHome'
	            },
	            "state": {}
			}, true);
    },
    
    handleSave : function (component, event, helper, requestType) {
    	console.log("#### c:ETradingEnablementCompleteHelper.handleSave()");
		let rows; 
		let tableId = requestType.toLowerCase()+"CoverageTableId"; 
		let tableCmp = component.find(tableId);
    	if(!$A.util.isEmpty(tableCmp)) {
			console.log("found table");
    		rows = tableCmp.getSelectedRows();
    	}
    	if(!$A.util.isEmpty(rows)) {
    		helper.showSpinner(component, event, helper);
    		component.set("v.tableAddReqErrors", {});
    		let eTradingDataObj = {};
			//eTradingDataObj.ETReqToAddList = rows;
			eTradingDataObj["ETReqTo"+requestType+"List"] = rows;
			let eTradingDataStr = JSON.stringify(eTradingDataObj);
    		// call the server side function  
	        let action = component.get("c.completeEtradingEnablements");
	        // to server side function 
			action.setParams({"eTradingDataStr":eTradingDataStr,
							  "requestType":requestType});
	        //set callback   
	        action.setCallback(this, function(response) {
	            if(response.getState()==="SUCCESS") {
	            	// get the update status result list
                    let returnResult = response.getReturnValue();
					let tableRowsAttr = "v.table"+requestType+"ReqRows";
					let tableReqRows = component.get(tableRowsAttr);
					let eTReqWithErrCount=0, eTReqSuccCount=0, eTCoveRecCount=0, noOfeTReqToComplete=0;
                    let rowErrors={};
                    let eTReqRowsIndxToRem = [];
                    if(!$A.util.isEmpty(returnResult) && !$A.util.isEmpty(returnResult.ETEnablementUpdateResultList) && !$A.util.isEmpty(tableReqRows)) {
                    	noOfeTReqToComplete = returnResult.ETEnablementUpdateResultList.length;
                    	let coverageRows = component.get("v.completedTableRows");
                    	if($A.util.isEmpty(coverageRows)) {
                    		coverageRows=[];
                    	}
                    	for(let i=0, j=0; i<tableReqRows.length; ++i) {
                    		if(j < returnResult.ETEnablementUpdateResultList.length && tableReqRows[i].eTradId===returnResult.ETEnablementUpdateResultList[j].eTId) {
                    			let updETRslt = returnResult.ETEnablementUpdateResultList[j];
                    			tableReqRows[i].resultIcon=updETRslt.resultIcon;
                    			if(updETRslt.hasErrors===false) {
                    				++eTReqSuccCount;
                    				if(returnResult.hasErrors===false && !$A.util.isEmpty(updETRslt.ETradingCoverageList)) {
	                    				// add the row to successful result
	                    				eTCoveRecCount += updETRslt.ETradingCoverageList.length;
	                    				coverageRows = coverageRows.concat(updETRslt.ETradingCoverageList);
	                    				eTReqRowsIndxToRem.push(i-eTReqRowsIndxToRem.length);
                    				}
                    			} else if(updETRslt.hasErrors===true) {
                    				++eTReqWithErrCount; 
                    				rowErrors[updETRslt.eTId]={
                                        "title":"Error",
                                        "messages":[updETRslt.errors],
                                        "fieldNames":"emptyErrHandling"
                                    };
                    			}
                    			++j;
                    		} else {
                    			tableReqRows[i].resultIcon="";
                    		}
                    	}
                    	
                    	if(returnResult.hasErrors===false) {
                    		for(let i=0; i<eTReqRowsIndxToRem.length; ++i) {
                    			tableReqRows.splice(eTReqRowsIndxToRem[i], 1);
                    		}
                    		//component.set("v.maxETReqTableHeight", 425);
							//component.set("v.maxETCovTableHeight", 225);
							//component.set("v.maxETReqTableHeight", 250);
							//component.set("v.maxETCovTableHeight", 250);
							component.set("v.completedTableRows", coverageRows);
							component.set("v.showResultReqSec", true);
						}
						console.log("tableReqRows after splice : ",tableReqRows);
                    	component.set(tableRowsAttr, tableReqRows);
                    }
                    if(!$A.util.isEmpty(rowErrors)) {
                    	component.set("v.table"+requestType+"ReqErrors", {
                            rows:rowErrors,
                            table:{
                                title:"There are errors in completing the eTrading Requests",
                                messages: [
                                    "Check Errors"
            					]
                           }
                        });
                    }
                    
                    let title="", type="", message="";
                    if(returnResult.hasErrors) {
                    	title="Error";
                    	type="error";
                    	message="There are errors in creating the coverage for "+eTReqWithErrCount+" record/s from "+noOfeTReqToComplete+" selected records.\n"+
                    			" Note: No Coverage is created until all errors are fixed."
                    } else {
                    	title="Success";
                    	type="success";
                    	//message="All "+noOfeTReqToComplete+" selected eTrading Requests were completed successfully and "+eTCoveRecCount+" eTrading Coverage recrds were created successfully.";
                    	message="Successfully created coverage for selected eTrading Requests.";
                    }
                    helper.showToast(component, event, helper, title, message, type, "sticky", null, 10000);
                    
            	} else {
            		let errMsg="";
                    let errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            errMsg+=errors[0].message;
                        }
                    } else {
                        errMsg+="Unknown error";
                    }
                    helper.showToast(component, event, helper, "Error", errMsg, "error", "dismissible", null, 10000);
            	}
            	helper.hideSpinner(component, event, helper);
        	});
        	$A.enqueueAction(action);
    	}
    },
    
    createDataTableColumn: function(component, event, helper) {
		console.log("#### c:ETradingEnablementCompleteHelper.createDataTableColumn()");
		// Add Coverage Table
    	var getPlatformIdActions = helper.getPlatformIdActions.bind(this, component);
        component.set("v.tableAddReqColumns", [
        	{label: "", fieldName: "completeResult", type: "text", initialWidth:3, sortable:false,
        		cellAttributes:{iconName:{ fieldName: "resultIcon" }, iconPosition: "right"} },
            {label: 'Ref', fieldName: 'eTradURL', type: 'url', initialWidth:75, sortable:true,
                typeAttributes: { label: { fieldName: 'eTradName' }, target: '_blank' }},
            {label: '', fieldName: 'emptyErrHandling', fixedWidth: 1, type: "text", editable:"true", sortable:false},
            {label:"Contact", fieldName:"contactName", type:"text", initialWidth:150, sortable:true},
            {label:"Account", fieldName:"conAccName", type:"text", initialWidth:175, sortable:true},
            {label:"Sales Code", fieldName:"salesPersonName", type:"text", initialWidth:130, sortable:true},
            {label:"Product", fieldName:"product", type:"text", initialWidth:185, sortable:true},
            {label:"Platform", fieldName:"platform", type:"text", initialWidth:110, sortable:true},
            {label:"Platform-IDs To Enable", fieldName:"contPlaformIDs", type:"text", initialWidth:220, sortable:false},
            { type: 'action', typeAttributes: { rowActions: getPlatformIdActions } },
            {label: "Status", fieldName:"status", type:"text", initialWidth:200, sortable:true}
		]);
		
		// Revoke Coverage Table
    	component.set("v.tableRevReqColumns", [
        	{label: "", fieldName: "completeResult", type: "text", initialWidth:3, sortable:false,
        		cellAttributes:{iconName:{ fieldName: "resultIcon" }, iconPosition: "right"} },
            {label: 'Ref', fieldName: 'eTradURL', type: 'url', initialWidth:75, sortable:true,
                typeAttributes: { label: { fieldName: 'eTradName' }, target: '_blank' }},
            {label: '', fieldName: 'emptyErrHandling', fixedWidth: 1, type: "text", editable:"true", sortable:false},
            {label:"Contact", fieldName:"contactName", type:"text", initialWidth:150, sortable:true},
            {label:"Account", fieldName:"conAccName", type:"text", initialWidth:175, sortable:true},
            {label:"Sales Code", fieldName:"salesPersonName", type:"text", initialWidth:130, sortable:true},
            {label:"Product", fieldName:"product", type:"text", initialWidth:185, sortable:true},
            {label:"Platform", fieldName:"platform", type:"text", initialWidth:110, sortable:true},
            {label:"Platform-ID Enabled ", fieldName:"platformId", type:"text", initialWidth:220, sortable:false},
            {label: "Status", fieldName:"status", type:"text", initialWidth:200, sortable:true}
		]);

		component.set("v.completedTableColumns", [
        	{label: "", fieldName: "completeResult", type: "text", initialWidth:5, sortable:false,
        		cellAttributes:{iconName:{ fieldName: "resultIcon" }, iconPosition: "right"} },
            {label: 'Ref', fieldName: 'eTradURL', type: 'url', initialWidth:75, sortable:true,
                typeAttributes: { label: { fieldName: 'eTradName' }, target: '_blank' }},
            {label: '', fieldName: 'emptyErrHandling', fixedWidth: 1, type: "text", editable:"true", sortable:false},
            {label:"Contact", fieldName:"contactName", type:"text", initialWidth:150, sortable:true},
            {label:"Account", fieldName:"conAccName", type:"text", initialWidth:175, sortable:true},
            {label:"Sales Code", fieldName:"salesPersonName", type:"text", initialWidth:130, sortable:true},
            {label:"Product", fieldName:"product", type:"text", initialWidth:250, sortable:true},
            {label:"Platform", fieldName:"platform", type:"text", initialWidth:110, sortable:true},
            {label:"Platform-ID Enabled", fieldName:"platformId", type:"text", initialWidth:200, sortable:true}
		]);
    },
    
    handleNewContPlatError : function(component, event, helper) {
    	console.log("#### c:ETradingEnablementCompleteHelper.handleNewContPlatError()");
    	component.set("v.newPlatIdDialogHeight", "360");
    	helper.hideSpinner(component, event, helper);
    }, 
    
    handleNewContPlatSuccess : function(component, event, helper) {
    	console.log("#### c:ETradingEnablementCompleteHelper.handleNewContPlatSuccess()");
        let payload = event.getParams().response;
        let contPlatName;
        if(!$A.util.isEmpty(payload)) {
        	let newContPlat = {};
        	newContPlat.contactId = payload.fields.Contact__c.value;
			newContPlat.contPlatRecId = payload.id;
	        newContPlat.contPlatIdName = payload.fields.Name.value;
	        contPlatName = payload.fields.Name.value;
	        newContPlat.externalId = payload.fields.External_Id__c.value;
	    	newContPlat.platform = payload.fields.Platform__c.value;
	        newContPlat.email = payload.fields.Email__c.value;
	        newContPlat.isNew = false;
	        newContPlat.isFromPlatfrom = false;
	        newContPlat.displayContPlatIdName = payload.fields.Name.value;
	        helper.addNewContPlatToETradingReqs(component, event, helper, newContPlat);
        }
        component.set("v.newPlatIdDialogHeight", "280");
        component.set("v.platfromIDForNewContPlat", null);
        component.set("v.contIdForNewContPlat", "");
		component.set("v.platfromForNewContPlat", "");
		let keepCreateNewContPlatDialogOpen = component.get("v.keepCreateNewContPlatDialogOpen");
        component.set("v.openCreateNewContPlatDialog", keepCreateNewContPlatDialogOpen);
        helper.showToast(component, event, helper, "Success", "Contact Platform "+contPlatName+" was created.", "success", "dismissible", null, 10000);
        helper.hideSpinner(component, event, helper);
    }, 
    
    addNewContPlatToETradingReqs: function (component, event, helper, newContPlat) {
    	console.log("#### c:ETradingEnablementCompleteHelper.addNewContPlatToETradingReqs()");
    	if(!$A.util.isEmpty(newContPlat)) {
    		let rowsChanged = false;
    		let tableAddReqRows = component.get("v.tableAddReqRows");
    		if(!$A.util.isEmpty(tableAddReqRows)) {
	    		for(let i=0; i<tableAddReqRows.length; ++i) {
	    			let row = tableAddReqRows[i];
	    			if(row.contactId===newContPlat.contactId && row.platform===newContPlat.platform) {
	    				row.contPlaformIDs += ($A.util.isEmpty(row.contPlaformIDs) ? "": "\n") + newContPlat.displayContPlatIdName;
	    				row.contPlaformIDLabelList.push(newContPlat.displayContPlatIdName);
	    				row.ContPlaformIDWrapperMap[newContPlat.displayContPlatIdName] = newContPlat;
	    				rowsChanged = true;
	    				helper.initializeRowDynamicActions(component, event, helper, row);
	    			}
	    		}
	    		if(rowsChanged===true) {
	    			component.set("v.tableAddReqRows", tableAddReqRows);
	    		}
    		}
    	}
    },
    
    handleSaveContPlat : function (component, event, helper) {
    	console.log("#### c:ETradingEnablementCompleteHelper.handleSaveContPlat()");
    	helper.showSpinner(component, event, helper);
    	let recordEditForm = component.find("recordEditForm");
    	if(recordEditForm!==undefined && recordEditForm!==null) {
    		recordEditForm.submit();
    	}
    },
    
    handleRowAction: function (component, event, helper) {
    	console.log("#### c:ETradingEnablementCompleteHelper.handleRowAction()");
        let action = event.getParam('action');
        let row = event.getParam('row');
        let rows = component.get("v.tableAddReqRows");
        let rowIndex = rows.indexOf(row);
        
        console.log("ACTION : ",action);
        console.log("name : ",action.name);
        console.log("action.label : ",action.label);
        console.log("rowIndex : ",rowIndex);
        console.log("row : ",row);

        switch(action.name) {
        	case "CREATE_NEW_PFID_REC":
        		if(!$A.util.isEmpty(row)) {
        			component.set("v.contIdForNewContPlat", row.contactId);
        			component.set("v.platfromForNewContPlat", row.platform);
        		}
        		component.set("v.openCreateNewContPlatDialog", true);
        		break;
        	case "CANNOT_CREATE_NEW_PFID":
        		alert('New Contact Platform-ID cannot be created before Contact Assignment');
        		break;
        	default:
        		if(!$A.util.isEmpty(row) && !$A.util.isEmpty(row.contPlaformIDLabelList) && !$A.util.isEmpty(row.labelByActionName)) {
        			let label = row.labelByActionName[action.name];
        			if(!$A.util.isEmpty(label)) {
	        			let contPlaformIDs = row.contPlaformIDs;
				        if(action.name.startsWith("add__")) {
				        	if($A.util.isEmpty(contPlaformIDs)) {
				        		contPlaformIDs = label;
				        	} else {
				        		let existingContPlaformIDs = contPlaformIDs.split("\n");
				        		let j=0;
				        		for(let i=0; i<row.contPlaformIDLabelList.length && j<existingContPlaformIDs.length; ++i) {
				        			if(existingContPlaformIDs[j]===row.contPlaformIDLabelList[i]) {
				        				++j;
				        			} else if(label===row.contPlaformIDLabelList[i]) {
				        				break;
				        			}
				        		}
				        		existingContPlaformIDs.splice(j, 0, label);
				        		contPlaformIDs = "";
				        		for(let i=0; i<existingContPlaformIDs.length; ++i) {
				        			contPlaformIDs += existingContPlaformIDs[i]+"\n";
				        		}
				        		contPlaformIDs = contPlaformIDs.slice(0, contPlaformIDs.length-1);
				        	}
				    	} else if(action.name.startsWith("remove__")) {
				    		if(!$A.util.isEmpty(contPlaformIDs)) {
				    			if(contPlaformIDs.includes(label+"\n")) {
				    				contPlaformIDs = contPlaformIDs.replace(label+"\n", "");
				    			} else if(contPlaformIDs.includes("\n"+label)) {
				    				contPlaformIDs = contPlaformIDs.replace("\n"+label, "");
				    			} else {
				    				contPlaformIDs = "";
				    			} 
				    		}
				    	}
				    	
				    	row.contPlaformIDs = contPlaformIDs;
				    	if(!$A.util.isEmpty(rows)) {
				        	rows.splice(rowIndex, 1, row);
				        	component.set("v.tableAddReqRows", rows);
				        }
			    	}
        		}
	    } // end of switch
    },
    
    getPlatformIdActions: function (component, row, doneCallback) {
    	console.log("#### c:ETradingEnablementCompleteHelper.getPlatformIdActions()");
    	let actions=[];
    	if(!$A.util.isEmpty(row) && !$A.util.isEmpty(row.contPlaformIDLabelList)) {
    		let contPlaformIDs = ($A.util.isEmpty(row.contPlaformIDs)) ? "" : row.contPlaformIDs;
    		let contPlaformIDList = contPlaformIDs.split('\n');
    		for(let i=0; i<row.contPlaformIDLabelList.length; ++i) {
    			let pfId = row.contPlaformIDLabelList[i];
    			let iconName;
    			let actionName = pfId.replace(/[^A-Z0-9]+/ig, "_");
    			actionName = actionName+"ACT";
    			if(contPlaformIDList.includes(pfId)) {
    				iconName = 'utility:ban';
    				actionName = 'remove__'+actionName;
    			} else {
    				iconName = 'utility:new';
    				actionName = 'add__'+actionName;
    			}
    			actions.push({
					'label': pfId,
					'iconName': iconName,
					'name': actionName 
				});
    		}
    	}

		if(row.isUnassignedContact===false) {
    		actions.push({
				'label': 'Create New',
				'iconName': 'utility:add',
				'name': 'CREATE_NEW_PFID_REC' 
			});
		} else {
			actions.push({
				'label': 'Unavailable',
				'iconName': 'utility:error',
				'name': 'CANNOT_CREATE_NEW_PFID' 
			});
		}
    	// simulate a trip to the server
        setTimeout($A.getCallback(function () {
            doneCallback(actions);
        }), 100);
    },

    showSpinner : function(component, event, helper) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },
    
    hideSpinner : function(component,event, helper) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.addClass(cmpTarget, 'slds-hide');
    },
    
    showToast : function(component, event, helper, title, message, type, mode, key, duration) {
        var toastEvent = $A.get("e.force:showToast");
        if(duration) {
            duration=2000;
        }
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
})