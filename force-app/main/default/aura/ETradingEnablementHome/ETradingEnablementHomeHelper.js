({
	sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.coverageData");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.coverageData", data);
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
    
    // isInit=true, only when called first time when the component is initialized 
    fetchSearchResults : function(component, event, helper, isInit){
        helper.showSpinner(component, event, helper);
        
        component.set("v.coverageData", [{}]);
        component.set("v.coverageColumns", [{}]);
        component.set("v.converageErrors", {});
        component.set("v.selectedData",{});
        //Record Type
        var recType = component.get("v.recType");
        // Status
        var eTEstatus = [];
        if(recType==="Request") {
            eTEstatus = component.get("v.selectedRequestStatus");
        } else if(recType==="Coverage") {
            eTEstatus.push(component.get("v.coverageStatus"));
        }
        
        var eTEplatforms = component.get("v.selectedPlatforms");
        var eTEproducts = component.get("v.selectedProducts");
        
		//Account IDs
        var clientIDS = component.get("v.accountIDs");
        //Include
        //var include = component.get("v.Include");
        //Sales Team
        var salesTeamForCoverageIDs = component.get("v.salesTeamForCoverageIDs");
        //Contacts
        var contactIDS = component.get("v.contactIDs");
        var softLimit = component.get("v.softLimit");
        
        var wparams = {
            "isInit"		  : isInit,
            "StatusList" 	  : eTEstatus,
            "PlatformList"	  : eTEplatforms, 
            "ProductList"	  : eTEproducts,
            "ClientIDList" 	  : clientIDS,
            "recType" 		  : recType,
            "SalesCodeIDList" : salesTeamForCoverageIDs,
            "ContactIDList"	  : contactIDS,
            "softLimit"		  : softLimit
        };
        
        // call the server side function  
        var action = component.get("c.getEtradingEnablementCoverage");
        // to server side function 
        action.setParams(wparams);
        //set callback   
        action.setCallback(this, function(response) {
            
            if (response.getState()==="SUCCESS") {
                var eTEnablementData = response.getReturnValue();
                if(!$A.util.isUndefinedOrNull(eTEnablementData)) {
                    if(!$A.util.isUndefinedOrNull(eTEnablementData.Error)) {
                        //Error Handling
                        helper.showToast(component, event, helper, eTEnablementData.Error.errTitle, 
                                         eTEnablementData.Error.errMessage, eTEnablementData.Error.errType, 
                                         eTEnablementData.Error.errMode, null, 2000);
                    } else {
                    	if(isInit===true && !$A.util.isUndefinedOrNull(eTEnablementData.isETradingAdmin)) {
                    		component.set("v.isETradingAdmin",eTEnablementData.isETradingAdmin);
                    	}
                    	if(isInit===true && !$A.util.isUndefinedOrNull(eTEnablementData.reportId)) {
                    		component.set("v.reportId",eTEnablementData.reportId);
                    	}
                        if(isInit===true && !$A.util.isUndefinedOrNull(eTEnablementData.loggedInUsedId)) {
                            component.set("v.currentUserId",eTEnablementData.loggedInUsedId);
                        }
                        if(isInit===true && !$A.util.isUndefinedOrNull(eTEnablementData.loggedInUserName)) {
                            component.set("v.currentUserName",eTEnablementData.loggedInUserName);
                        }
                        if(isInit===true && !$A.util.isEmpty(eTEnablementData.loggedInUserSalesCode)) {
                            var salesTeamForCoverageIDs = [];
                            salesTeamForCoverageIDs.push(eTEnablementData.loggedInUserSalesCode);
                            component.set("v.salesTeamForCoverageIDs",salesTeamForCoverageIDs);
                            var salesCodeLookup = component.find("salesCodeAddId");
                            salesCodeLookup.callPreSelect();
                        }
                        if(isInit) {
                            helper.initializeAllOptsSelectedPickList(component, event, helper, eTEnablementData.PlatformsPicklistLabValMap, 
                                                                     true, "v.platformsOptions", "v.selectedPlatforms", "platformsId");
                            
                            helper.initializeAllOptsSelectedPickList(component, event, helper, eTEnablementData.ProductsPicklistLabValMap,
                                                                     true, "v.productsOptions", "v.selectedProducts", "productsId");
                            /*var picklistValues=[];
                            var selectedPlatforms=[];
                            picklistValues.push({'label': 'All', 'value': 'All'});
                            Object.entries(eTEnablementData.PlatformsPicklistLabValMap).forEach(([key, value]) => {
								picklistValues.push({'label': value, 'value': key});
                            	selectedPlatforms.push(value);
                        	});
                        	component.set("v.platformsOptions", picklistValues); 
                        	component.set("v.selectedPlatforms", selectedPlatforms);
                        	var platformsSelect = component.find("platformsId");
                        	if(platformsSelect!==null && platformsSelect!==undefined) {
	                            platformsSelect.reInit();            	    
    	                    }*/
        	            }
                        var eTEnablementList = eTEnablementData.ETadingEnablementWrapperList;
                        helper.createTable(component, event, helper, eTEnablementList);
                    }
                }
            }
            helper.hideSpinner(component, event, helper);
        });
        
        $A.enqueueAction(action);

    },
    
    handleAssignSave : function(component,event,helper) {
    	var selectedRows = component.get("v.selectedData");
    	var asignToUserId = component.get("v.assignedUserId");
    	// check if some rows are selected
        if(!$A.util.isEmpty(selectedRows) && !$A.util.isEmpty(asignToUserId) && !$A.util.isEmpty(asignToUserId[0])) {
        	helper.showSpinner(component, event, helper);
            // reset any previous errors
            component.set("v.converageErrors", {});
            // create the list of eTEnablement records selected to be update
            var eTEnablementToUpdate=[];
            for(var i=0; i<selectedRows.length; ++i) {
                eTEnablementToUpdate.push({"Id":selectedRows[i].eTEnablementId, "Actioned_By__c":asignToUserId[0],
                                           "sObjectType":"ETradingEnablement__c"});
           }
            var action = component.get("c.updateEtradingEnablementStatus");
        	// to server side function 
            action.setParams({"EtradingEnablementList":eTEnablementToUpdate});
        	//set callback   
        	action.setCallback(this, function(response) {
        		
            });
            // enque action
            $A.enqueueAction(action);
        }
    },
    
    setAssignedSalesCodeIds : function(component, event)
    {
        if (event.getParam("values").length >= 1) 
        {
            component.set("v.assignedSalesCodeIds", event.getParam("values"));
            var eventDataArray = event.getParam("data");
            var salesCodeLabel = eventDataArray[0].SObjectLabel;
            component.set("v.assignedSalesCodeLabel", salesCodeLabel);
        }
        else 
        {
            component.set("v.assignedSalesCodeIds", []);
            component.set("v.assignedSalesCodeLabel", "");
        }
    },

    /*
    // By Simon - Now not required as we can use the same update functions which updates te table dynamically
    assignSalesCodeSave : function(component, event)
    {
        var selectedRows = component.get("v.selectedDataList");
        var assignedSalesCodeIds = component.get("v.assignedSalesCodeIds");
        var eTradingEnablementIds = [];

		for (var varLoop = 0; varLoop < selectedRows.length; varLoop++)
		{
            eTradingEnablementIds.push(selectedRows[varLoop].eTEnablementId);
		}

        if (!$A.util.isEmpty(eTradingEnablementIds) && !$A.util.isEmpty(assignedSalesCodeIds))
        {
            this.showSpinner(component);

            var action = component.get("c.updateETradingEnablementSalesCodes");

            action.setParams
            ({
                'eTradingEnablementIds': eTradingEnablementIds,
                'assignedSalesCodeId': assignedSalesCodeIds
            });

            action.setCallback(this, function (response) 
            {
                this.hideSpinner(component);
                component.set("v.displayAssignSalesCode", false);

                if (response.getState() == "SUCCESS") 
                {
                    var eTradingAssignSalesCodeData = response.getReturnValue();

                    if (!eTradingAssignSalesCodeData.error) 
                    {
                        this.fetchSearchResults(component, event, this, false); 
                        var title = "Success";
                        var message = "Sales Code successfully assigned";
                        var type = "success";
                        this.showToast(component, event, this, title, message, type, "sticky", null, 10000);
                    }
                    else 
                    {
                        var title = "Error";
                        var message = eTradingAssignSalesCodeData.eTEnablementError.errMessage;
                        var type = "error";
                        this.showToast(component, event, this, title, message, type, "sticky", null, 10000);
                    }
                }
                else 
                {
                    var title = "Error";
                    var message = "Unable to update Sales Code";
                    var type = "error";
                    this.showToast(component, event, this, title, message, type, "sticky", null, 10000);
                }

                component.set("v.assignedSalesCodeIds", []);
                component.set("v.assignedSalesCodeLabel", "");
            });

            $A.enqueueAction(action);
        }
    },*/

    revokeETEnablements : function(component, event, helper) {
    	var selectedRows = component.get("v.selectedDataList");

    	// check if some rows are selected, 
    	if(!$A.util.isEmpty(selectedRows)) {
    		helper.showSpinner(component, event, helper);
    		var newComment = component.get("v.comment")
    		// reset any previous errors
            component.set("v.converageErrors", {});
            // call the server side function  
        	var action = component.get("c.revokeETradingCoverage");
            action.setParams({"eTradingEnablementListString":JSON.stringify(selectedRows),
            					"comment":newComment});
          	//set callback   
            action.setCallback(this, function(response) {
            	if (response.getState()==="SUCCESS") {
            	
            	}
            	else if (response.getState()==="ERROR") {
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
	            	message="Revoke request successfully raised";
	            	type="success";
	            }
	            
	        	helper.showToast(component, event, helper, title, message, type, "sticky", null, 10000);
        	});
        }
        $A.enqueueAction(action);
    },
    
    /*addComments : function(component, event, helper) {
    	let selectedRows = component.get("v.selectedDataList");
        let newComment = component.get("v.comment");
        
        // check if some rows are selected, 
    	if(!$A.util.isEmpty(selectedRows)) {
    		helper.showSpinner(component, event, helper);
    		// reset any previous errors
            component.set("v.converageErrors", {});
            // call the server side function  
        	var action = component.get("c.addComment");
            action.setParams(  {"eTradingEnablementListString":JSON.stringify(selectedRows),
                                "comment":newComment
                                }
                            );
          	//set callback   
            action.setCallback(this, function(response) {
            	if (response.getState()==="SUCCESS") {
            	
            	}
            	else if (response.getState()==="ERROR") {
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
	            	message="Comment added successfully";
	            	type="success";
	            }
	        	helper.showToast(component, event, helper, title, message, type, "sticky", null, 10000);
        	});
        }
        $A.enqueueAction(action);
    },*/
    
    handleCompleted : function (component, event, helper) {
    	let selectedRows = component.get("v.selectedData");
    	if(!$A.util.isEmpty(selectedRows)) {
	    	let csvETradingId = "";
	    	for(let i=0; i<selectedRows.length; ++i) {
	    		csvETradingId += selectedRows[i].eTEnablementId+",";
	    	}
	    	csvETradingId = csvETradingId.slice(0, csvETradingId.length-1);
	    	
	    	event.preventDefault();
	    	component.find("navigationService").navigate({
	            "type": 'standard__component',
	            "attributes": {
	              	componentName: 'c__ETradingEnablementComplete'
	            },
	            "state": {
	            	"c__csvETradingId" : csvETradingId 
	            }
	    	}, false);
    	}
    },
    
    updateETEnablements : function(component, event, helper, actionByUserId, fieldParameters, errFieldNames, fieldPostUpdateParameter) {
       
        var selectedRows = component.get("v.selectedData");
        
        // check if some rows are selected, 
        if(!$A.util.isEmpty(selectedRows) && ( (!$A.util.isEmpty(fieldParameters) && !$A.util.isEmpty(fieldParameters.ETEnablementUpdateParamsList)) || !$A.util.isEmpty(actionByUserId))) {
            helper.showSpinner(component, event, helper);
            // reset any previous errors
            component.set("v.converageErrors", {});
            // create the list of eTEnablement records selected to be update
            var eTEnablementToUpdate=[];
            var fieldListParam=[];
            var ETEnablementUpdateParamsList=[];
            for(var i=0; i<selectedRows.length; ++i) {
            	var params = {"Id":selectedRows[i].eTEnablementId, "sObjectType":"ETradingEnablement__c"};
                params["Actioned_By__c"]=actionByUserId;
                if(!$A.util.isEmpty(fieldParameters) && !$A.util.isEmpty(fieldParameters.ETEnablementUpdateParamsList)) {
                    for(var j=0; j<fieldParameters.ETEnablementUpdateParamsList.length; ++j) {
                        if(fieldParameters.ETEnablementUpdateParamsList[j]["fieldApiName"]==="Comments__c") {
                            let newFormattedComment = fieldParameters.ETEnablementUpdateParamsList[j]["fieldVal"];
                            if(!$A.util.isEmpty(selectedRows[i].comments)) {
                                newFormattedComment+="\n"+selectedRows[i].comments;
                            }
                            params[fieldParameters.ETEnablementUpdateParamsList[j]["fieldApiName"]]=newFormattedComment;
                        } else {
                            params[fieldParameters.ETEnablementUpdateParamsList[j]["fieldApiName"]]=fieldParameters.ETEnablementUpdateParamsList[j]["fieldVal"];
                        }
                    }
                }
            	eTEnablementToUpdate.push(params);
            }
            // call the server side function  
        	var action = component.get("c.updateEtradingEnablement");
        	// to server side function 
        	let fieldParametersStr ="";
            if(!$A.util.isEmpty(fieldParameters) && !$A.util.isEmpty(fieldParameters.ETEnablementUpdateParamsList)) {
            	fieldParametersStr = JSON.stringify(fieldParameters);
            }
            let fieldPostUpdateParameterStr = "";
            if(!$A.util.isEmpty(fieldPostUpdateParameter) && !$A.util.isEmpty(fieldPostUpdateParameter.ETEnablementUpdateParamsList)) {
            	fieldPostUpdateParameterStr = JSON.stringify(fieldPostUpdateParameter);
            }

            console.log("fieldParametersStr : "+fieldParametersStr);
            console.log("actionByUserId : "+actionByUserId);
            console.log("eTEnablementToUpdate : "+eTEnablementToUpdate);
            action.setParams({"fieldUpdateListParam":fieldParametersStr,
                			  "actionByUserId":actionByUserId,
                              "EtradingEnablementList":eTEnablementToUpdate,
                              "fieldPostUpdateListParam" : fieldPostUpdateParameterStr});
        	//set callback   
        	action.setCallback(this, function(response) {
                // count the number of records updated successfully and records that failed to udate
                var recsWithErr=0;
                var recsUpdSuccessfully=0;
                // on success response
            	if (response.getState()==="SUCCESS") {
                    // get the update status result list
                    console.log("successfully updated records");
                    var updateStatusResult = response.getReturnValue();
                    console.log("updateStatusResult : ",updateStatusResult);
                    var coverageData = component.get("v.coverageData");
					// errors found
                    var rowErrors={};
                    if(updateStatusResult!==null && updateStatusResult!==undefined) {
                        if(!$A.util.isEmpty(updateStatusResult.ETEnablementStatusUpdateResultList)) {
                            var updateStatusResultList = updateStatusResult.ETEnablementStatusUpdateResultList;
                            // loop through the update results
                            var i=0;
                            for(var i=0; i<updateStatusResultList.length; ++i) {
                                // if there is error in updating the record
                                if (updateStatusResultList[i].hasErrors === true) {
                                    ++recsWithErr;
                                    rowErrors[updateStatusResultList[i].eTEnablementId]={
                                        "title":"Error",
                                        "messages":[updateStatusResultList[i].error],
                                        "fieldNames":errFieldNames
                                    };
                                } else {
                                    // else if record was updated successfully, then update the status on UI
                                    for(var j=0; j<coverageData.length; ++j) {
                                        if(coverageData[j].eTEnablementId===updateStatusResultList[i].eTEnablementId) {
                                            // update assigned by info
                                            coverageData[j]["actionedByName"]=updateStatusResultList[i].actionedByName;
                                            coverageData[j]["actionedById"]=updateStatusResultList[i].actionedById;
                                            // update any additional fields updated
                                            if(!$A.util.isEmpty(updateStatusResultList[i].ETEnablementUpdateOutputParamsList)) {
                                                for(var indxFldVals=0; indxFldVals<updateStatusResultList[i].ETEnablementUpdateOutputParamsList.length; ++indxFldVals) {
													var updtFieldVal=updateStatusResultList[i].ETEnablementUpdateOutputParamsList[indxFldVals];
                                                    if(!$A.util.isEmpty(updtFieldVal.colFieldName)) {
                                                    	coverageData[j][updtFieldVal.colFieldName] = updtFieldVal.fieldVal;
                                                    }
                                                }
                                            }
                                            ++recsUpdSuccessfully;
                                            break;
                                        }
                                    }
                                }
                            }
                        } // end of - if(!$A.util.isEmpty(updateStatusResult.ETEnablementStatusUpdateResultList)) 

						// if errors are found in updating the records
                        if(!$A.util.isEmpty(rowErrors)) {
                            var errorss = {};
                            errorss["rows"]=rowErrors;
                            component.set("v.converageErrors", {
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

						// update the rows in table if records were updated successfully
                        if(recsUpdSuccessfully>0) {
							component.set("v.coverageData",coverageData);                            
                        }
                    }
                } else if (response.getState()==="ERROR") {
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
                // show the right toast message based on results
                var title="";
                var message="";
                var type="";
                // there was error in perfoming the server action
                if(!$A.util.isEmpty(errMsg)) {
                    title="Error";
                    message="Error occured in updating the records and no records were updated";
                    type="error";
                } 
                // else if all the records failed to update with error
                else if(recsWithErr>0 && recsUpdSuccessfully===0) {
                    title="Error";
                    message="All "+recsWithErr+" record/s failed to update, please check the error for each record by clicking the error icon";
                    type="error";
                } 
                // else if all the records successfully updated
                else if(recsWithErr===0 && recsUpdSuccessfully>0) {
                    title="Success";
                    message="All "+recsUpdSuccessfully+" record/s updated successfully";
                    type="success";
                } 
                // else if few records failed to update and few were updaed successfully
                else if(recsWithErr>0 && recsUpdSuccessfully>0) {
                    title="Warning";
                    message=recsUpdSuccessfully+" record/s updated successfully and "+recsWithErr+" record/s failed to update, please check the error for each record by clicking the error icon";
                    type="warning";
                }
                helper.showToast(component, event, helper, title, message, type, "sticky", null, 10000);
            });
            // enque action
            $A.enqueueAction(action);
            component.set("v.comment", null);
        }
	},
	
    initializeAllOptsSelectedPickList: function(component, event, helper, picklistLabValMap, 
                                                 isAddAll, optionsAttr, selectedAttr, selectCompId) {

		if(!$A.util.isEmpty(picklistLabValMap)) {
            var picklistValues=[];
            var selectedPlatforms=[];
            if(isAddAll===true) {
                picklistValues.push({'label': 'All', 'value': 'All'});
            }
            Object.entries(picklistLabValMap).forEach(([key, value]) => {
                picklistValues.push({'label': value, 'value': key});
                selectedPlatforms.push(key);
            });
            component.set(optionsAttr, picklistValues); 
            component.set(selectedAttr, selectedPlatforms);
            var platformsSelect = component.find(selectCompId);
            if(platformsSelect!==null && platformsSelect!==undefined) {
                platformsSelect.reInit();            	    
            }
     	}
    },
 
    createTable: function(component, event, helper, eTEnablementList) {
        var dataTableDiv = component.find("dataTableDiv");
        if(dataTableDiv!==null && dataTableDiv!==undefined) {
        	$A.util.removeClass(dataTableDiv,'slds-hide');
            $A.util.addClass(dataTableDiv,'slds-show');
        }
        helper.createDataTableColumn(component, event, helper);
        helper.createTableData(component, event, helper, eTEnablementList);
    }, 
     
    createDataTableColumn: function(component, event, helper) { 
        component.set("v.coverageColumns", [
            //{label: "", fieldName: "requestType", type: "button", initialWidth:10, sortable:false,
            // cellAttributes:{iconName:{ fieldName: "requestIcon" }, disabled:"true", variant:"brand"}},
            {label: "", fieldName: "requestType", type: "text", initialWidth:10, sortable:false,
             cellAttributes:{iconName:{ fieldName: "requestIcon" }, iconPosition: "right"} },
            {label: 'Ref', fieldName: 'recordURL', type: 'url', initialWidth:75, sortable:true,
             typeAttributes: { label: { fieldName: 'ref' }, target: '_blank' }},
            {label:"Contact", fieldName:"contactName", type:"text", initialWidth:175, sortable:true},
            {label:"Account", fieldName:"conRGAccountName", type:"text", initialWidth:150, sortable:true},
            {label:"Platform", fieldName:"ePlatforms", type:"text", initialWidth:100, sortable:true},
            {label:"Product", fieldName:"products", type:"text", initialWidth:200, sortable:true},
            {label:"Sales Code", fieldName:"salesPersonName", type:"text", editable:"true", initialWidth:150, sortable:true},
            {label:"Platform ID Enabled", fieldName:"contPlaformID", type:"text", initialWidth:100, sortable:false},
            {label: "Status", editable:"true", fieldName:"status", type:"text", initialWidth:150, sortable:true},
            {label: "Responsible", fieldName:"actionedByName", type:"text", initialWidth:150, sortable:true},
            {label: "Last Modified", fieldName:"lastModified", type:"text", initialWidth:200, sortable:true},
            {label: "Created By", fieldName:"createdBy", type:"text", initialWidth:150, sortable:true},
            {label: "Comments", fieldName:"comments", type:"text", initialWidth:400, sortable:false}
		]);
    
    },
    
    createTableData : function(component, event, helper, eTEnablementList) {
        var dataTable = component.find("coverageTable");
        if(dataTable!==null && dataTable!==undefined) {
            if(!$A.util.isEmpty(eTEnablementList)) {
                dataTable.set('v.data',eTEnablementList);    
            } else {
                dataTable.set('v.data',[]);
            }
		}
    	
    },

    hideDataTable : function(component, event, helper) {
        var dataTableDiv = component.find("dataTableDiv");
        //var footerDiv = component.find("footerId");
        $A.util.addClass(dataTableDiv, "slds-hide");
        $A.util.removeClass(dataTableDiv,'slds-show')
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
    },

    handleProcess : function (component, event, helper) {
        // contruct the fields to be updated parameter, follow the naming convention as it is de-serialize by apex-controller
        var eTEnablementFieldsToUpdateList = [];
        eTEnablementFieldsToUpdateList.push({"colFieldName":"status", "fieldApiName":"Status__c", "fieldVal":"Being Processed"});
        var fieldParameters={};
        fieldParameters["ETEnablementUpdateParamsList"]=eTEnablementFieldsToUpdateList;
        helper.updateETEnablements(component, event, helper,component.get("v.currentUserId"), fieldParameters, ["status"]);
    },

    handleOnHold : function (component, event, helper) {
    	component.set("v.comment","");
        component.set("v.onHoldClicked",true); 
        component.set("v.commentDialogBoxTitle", "Comment on Request(s) - On Hold");
    },
    
    handleCancel : function (component, event, helper) {
        // contruct the fields to be updated parameter, follow the naming convention as it is de-serialize by apex-controller
        var eTEnablementFieldsToUpdateList = [];
        eTEnablementFieldsToUpdateList.push({"colFieldName":"status", "fieldApiName":"Status__c", "fieldVal":"Canceled"});
        var fieldParameters={};
        fieldParameters["ETEnablementUpdateParamsList"]=eTEnablementFieldsToUpdateList;
        helper.updateETEnablements(component, event, helper,component.get("v.currentUserId"), fieldParameters, ["status"]);
    },

    handleAssignContact : function(component, event)
    {
        var navigationService = component.find("navigationService");

        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__ETradingEnablementAssignContact'
            }
        }

        component.set("v.pageReference", pageReference);
        event.preventDefault();
        navigationService.navigate(pageReference);
    },
    
    handleAssignSalesCode : function (component, event, helper)
    {
        component.set("v.displayAssignSalesCode", true);
    },

    handleAssignResponsility : function(component, event, helper) {
    	component.set("v.assignClicked",true);
    },

    handleComment : function(component, event, helper){
    	component.set("v.comment",'');
        component.set("v.commentClicked",true); 
        component.set("v.commentDialogBoxTitle", "Comment on Request(s)");
    }, 

    handleExport: function(cmp,event,helper){
        var reportId = cmp.get("v.reportId");
        var strURL = "/one/one.app#/sObject/" + reportId;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": strURL,
            "isredirect ":true
        });
        urlEvent.fire();
    },

    handleAttachFile : function(component, event, helper){
        component.set("v.attachFileClicked",true); 
        var selectedRows = component.get("v.selectedData");
        component.set("v.attachFilePrimaryRecId", selectedRows[0].eTEnablementId); 
    },

    commentSave : function (component, event, helper)
    {
        // contruct the fields to be updated parameter, follow the naming convention as it is de-serialize by apex-controller
        let comment = component.get("v.comment");
    	if(!$A.util.isEmpty(comment)) {
    		let today = new Date();
            let currentDate = today.getDate()+"-"+(today.getMonth()+1)+"-"+today.getFullYear(); 
            let newCommentFormatted = component.get("v.currentUserName") +", "+currentDate+" - "+comment;
            let eTEnablementFieldsToUpdateList = [];
            eTEnablementFieldsToUpdateList.push({"colFieldName":"comments", "fieldApiName":"Comments__c", "fieldVal":newCommentFormatted});
            if(component.get("v.onHoldClicked")===true) {
                eTEnablementFieldsToUpdateList.push({"colFieldName":"status", "fieldApiName":"Status__c", "fieldVal":"On Hold"});
            }
            let fieldParameters={};
            fieldParameters["ETEnablementUpdateParamsList"]=eTEnablementFieldsToUpdateList;
            console.log("NEW Comment : ",newCommentFormatted);
            helper.updateETEnablements(component, event, helper,component.get("v.currentUserId"), fieldParameters, ["status"]);
    	} else {
    		helper.showToast(component, event, helper, "Error", "No comment was provided", "error", "dismissible", null, 5000);
        }
        component.set("v.commentClicked",false);
        component.set("v.onHoldClicked",false); 
    }

 
})