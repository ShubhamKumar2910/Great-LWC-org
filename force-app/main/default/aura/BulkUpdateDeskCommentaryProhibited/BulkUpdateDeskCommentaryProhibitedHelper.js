({
	init: function(component, event, helper) {
		console.log("#### c:BulkUpdateDeskCommentaryProhibitedHelper.init()");
		
		helper.showSpinner(component, event, helper);
		component.set("v.uploadedDocId", null);
		component.set("v.fileBodyTxt", null);
		component.set("v.fileValidationErrs", true);
				
		// call the server side function  
        var action = component.get("c.initialize");
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState()==="SUCCESS") {
                var initInfo = response.getReturnValue();
                console.log("initInfo : ",initInfo);
                if(initInfo!==null) {
                	if(!$A.util.isEmpty(initInfo.campaignId)) {
                		component.set("v.recId", initInfo.campaignId);
            		}
            		if(initInfo!==null && !$A.util.isEmpty(initInfo.runningJobId)) {
            			component.set("v.runningJobId", initInfo.runningJobId);
            		}
            		if(!$A.util.isEmpty(initInfo.PreviousJobRunList)) {
            			helper.buildPrevJobRunInfo(component, event, helper, false, initInfo.PreviousJobRunList);
            		}
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
        // enque server action
        $A.enqueueAction(action);
        helper.createDataTableColumn(component, event, helper);
    },
    
    handleRunningJobIdChange: function(component, event, helper) { 
    	console.log("#### c:BulkUpdateDeskCommentaryProhibitedHelper.handleRunningJobIdChange()");
    	var runningJobId = component.get("v.runningJobId");
    	var isUpldJobRunning = component.get("v.isUpldJobRunning");
    	if(!$A.util.isEmpty(runningJobId) && isUpldJobRunning===false) {
    		component.set("v.isUpldJobRunning", true);
   		} else if ($A.util.isEmpty(runningJobId) && isUpldJobRunning===true) {
   			component.set("v.isUpldJobRunning", false);
   		}
	},
    
    
    runningJobPolling : function(component, event, helper) {
    	console.log('c:BulkUpdateDeskCommentaryProhibitedHelper.runningJobPolling()');
    	var isUpldJobRunning = component.get("v.isUpldJobRunning");
    	if(isUpldJobRunning===true) {
    		// Job is still running, so set a callback after XX seconds to refresh the status
    		var pollingFunction = function() {
    			//helper.showSpinner(component, event, helper);
    			component.set("v.uploadStatus", "Refreshing Job status...");
            	var actionFunc = component.get("c.getJobStatus");
            	// set parameters
            	actionFunc.setParams({"campaignId":component.get("v.recId")});
        		//set callback
        		actionFunc.setCallback(this, function(response) {
        			if (response.getState()==="SUCCESS") {
		                var initInfo = response.getReturnValue();
		                console.log("initInfo : ",initInfo);
		                if(initInfo!==null) {
		                	if(!$A.util.isEmpty(initInfo.PreviousJobRunList)) {
		                		var prevJobId = component.get("v.runningJobId");
		                		helper.updateCurrJobRunInfo(component, event, helper, prevJobId, initInfo.PreviousJobRunList[0]);
		                	}
		                	
		                	// now update the running job id
		                	component.set("v.runningJobId", initInfo.runningJobId);
		                	 
		                	// check whether the currently runningJobId is null or not 
		                	if(!$A.util.isEmpty(initInfo.runningJobId)) {
		                		// running-jobId is not null, so current upload job is still running
		                		// set the recursive-polling
		                		window.setTimeout(
		                			// arg 1
		                			$A.getCallback(pollingFunction), 
		                			// arg 2
		                			component.get("v.refreshStatusUpdPeriod")
		                		);
		                	} else {
		                		// current upload job is now completed, so set the new 
		                		if(!$A.util.isEmpty(initInfo.campaignId)) {
		                			component.set("v.recId", initInfo.campaignId);
	                			}
		            		}
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
		                
		                console.log('Error Occured in Polling action');
		            }
		            //helper.hideSpinner(component, event, helper);
		            component.set("v.uploadStatus", "");
        		});
        		// enque server action
        		$A.enqueueAction(actionFunc);
            }
            
            // set the polling first time, and first time call it within a second
            window.setTimeout(
        		   // arg 1
        		   $A.getCallback(pollingFunction), 
        		   // arg 2
        		   1000
            );
    	} else {
    		// Previous job is completed - with / without errors and a new upload campaign record is initialized
    		console.log("No Polling Required");
    	}
    },
    
    updateCurrJobRunInfo: function(component, event, helper, prevJobId, currJobRun) {
    	console.log("#### c:BulkUpdateDeskCommentaryProhibitedHelper.updateCurrJobRunInfo()");
    	if(!$A.util.isEmpty(currJobRun)) {
    		var runningJobId = component.get("v.runningJobId");
    		var rows=component.get("v.uploadJobData");
    		if(!$A.util.isEmpty(rows)) {
	    		for(var i=0; i<rows.length; ++i) {
	    			var rowData=rows[i];
		    		if(prevJobId===rowData.apexJobId) {
		    			rowData.apexJobId = currJobRun.jobId;
		    			rowData.loadByIcon = currJobRun.uploadTypeIcon;
		    			rowData.jobRubDate = currJobRun.jobRunDate;
		    			rowData.jobStatus = currJobRun.jobStatus;
		    			rowData.jobPercentComplete = currJobRun.percentProg+' %'; 
		    			rowData.reportURL = currJobRun.reportURL;
		    			rowData.jobDetailInfo = 'Job Status: '+currJobRun.jobStatus+'\n';
		    			if(!$A.util.isEmpty(currJobRun.totalNoOfRecsToProc) && currJobRun.totalNoOfRecsToProc!='0') {  
		    				rowData.jobDetailInfo+='Rows in CSV to Process: '+currJobRun.totalNoOfRecsToProc+'\n';
		    			}
		    			if(!$A.util.isEmpty(currJobRun.totalNoOfRecsProc) && currJobRun.totalNoOfRecsProc!='0') {
		    				rowData.jobDetailInfo+='Contacts Processed: '+currJobRun.totalNoOfRecsProc+'\n';
		    			}
		    			if(!$A.util.isEmpty(currJobRun.noOfSucc) && currJobRun.noOfSucc!='0') {
		    				rowData.jobDetailInfo+='Contacts updated succesfully: '+currJobRun.noOfSucc+'\n';
		    			}
		    			if(!$A.util.isEmpty(currJobRun.noOfErrs) && currJobRun.noOfErrs!='0') {
		    				rowData.jobDetailInfo+='Contact failures (click view report for details): '+currJobRun.noOfErrs+'\n';
		    			}
		    			if(!$A.util.isEmpty(currJobRun.noOfErrsNoInCamp) && currJobRun.noOfErrsNoInCamp!='0') {
		    				rowData.jobDetailInfo+='Contact failures (reported in email): '+currJobRun.noOfErrsNoInCamp+'\n';
		    			}
		    			
		    			rows.splice(i, 1, rowData);
		    			break;
		    		}
	    		}
	    		component.set("v.uploadJobData", rows);
    		}
	    	
	    	var percent = parseInt(currJobRun.percentProg);
			console.log('percent : ',percent);
			if(!isNaN(percent)) {
				component.set("v.runningJobPercent", percent);
			}	
    		// update the running job attributes
    		component.set("v.runJobStatus", currJobRun.jobStatus);
			component.set("v.runJobTotalNoOfRecsToProc", currJobRun.totalNoOfRecsToProc);
			component.set("v.runJobTotalNoOfRecsProc", currJobRun.totalNoOfRecsProc);
			component.set("v.runJobEmailSent", currJobRun.emailSent);
    	}
    },
    
    buildPrevJobRunInfo: function(component, event, helper, addToExisting, PreviousJobRunList) {
    	console.log("#### c:BulkUpdateDeskCommentaryProhibitedHelper.buildPrevJobRunInfo()");
    	if(!$A.util.isEmpty(PreviousJobRunList)) {
    		var runningJobId = component.get("v.runningJobId");
    		console.log('runningJobId : '+runningJobId);
    		var rows=[];
    		if(addToExisting===true) {
    			console.log('Adding to existing list...');
    			rows=component.get("v.uploadJobData");
    			if($A.util.isEmpty(rows)) {
    				rows=[];
    			}
    		}
    		for(var i=0; i<PreviousJobRunList.length; ++i) {
    			var prevJobRun = PreviousJobRunList[i];
    			console.log('prevJobRun : ',prevJobRun);
    			var rowData={};
    			rowData.apexJobId = prevJobRun.jobId;
    			rowData.loadByIcon = prevJobRun.uploadTypeIcon;
    			rowData.uploadBy = prevJobRun.uploadType;
    			rowData.jobRubDate = prevJobRun.jobRunDate;
    			rowData.jobStatus = prevJobRun.jobStatus;
    			rowData.jobPercentComplete = prevJobRun.percentProg+' %'; 
    			rowData.reportURL = prevJobRun.reportURL;
    			rowData.jobDetailInfo = 'Job Status: '+prevJobRun.jobStatus+'\n';
    			if(!$A.util.isEmpty(prevJobRun.totalNoOfRecsToProc) && prevJobRun.totalNoOfRecsToProc!='0') {  
    				rowData.jobDetailInfo+='Rows in CSV to Process: '+prevJobRun.totalNoOfRecsToProc+'\n';
    			}
    			if(!$A.util.isEmpty(prevJobRun.totalNoOfRecsProc) && prevJobRun.totalNoOfRecsProc!='0') {
    				rowData.jobDetailInfo+='Contacts Processed: '+prevJobRun.totalNoOfRecsProc+'\n';
    			}
    			if(!$A.util.isEmpty(prevJobRun.noOfSucc) && prevJobRun.noOfSucc!='0') {
    				rowData.jobDetailInfo+='Contacts updated succesfully: '+prevJobRun.noOfSucc+'\n';
    			}
    			if(!$A.util.isEmpty(prevJobRun.noOfErrs) && prevJobRun.noOfErrs!='0') {
    				rowData.jobDetailInfo+='Contact failures (click view report for details): '+prevJobRun.noOfErrs+'\n';
    			}
    			if(!$A.util.isEmpty(prevJobRun.noOfErrsNoInCamp) && prevJobRun.noOfErrsNoInCamp!='0') {
    				rowData.jobDetailInfo+='Contact failures (reported in email): '+prevJobRun.noOfErrsNoInCamp+'\n';
    			}
    			
    			if(addToExisting===true || runningJobId===prevJobRun.jobId) {
    				console.log('prevJobRun : ',prevJobRun);
    				component.set("v.currentJobInfo", rowData);
    				var percent = parseInt(prevJobRun.percentProg);
    				if(!isNaN(percent)) {
    					console.log('percent : ',percent);
    					component.set("v.runningJobPercent", percent);
    				}
    				
					component.set("v.runJobStatus", prevJobRun.jobStatus);
					component.set("v.runJobTotalNoOfRecsToProc", prevJobRun.totalNoOfRecsToProc);
					component.set("v.runJobTotalNoOfRecsProc", prevJobRun.totalNoOfRecsProc);
					component.set("v.runJobEmailSent", prevJobRun.emailSent);
    			}
    			
    			if(addToExisting===true) {
    				rows.unshift(rowData);
    			} else {
    				rows.push(rowData);
    			}
    		}
    		component.set("v.uploadJobData", rows);
    	}
    },
    
    createDataTableColumn: function(component, event, helper) { 
    	console.log("#### c:BulkUpdateDeskCommentaryProhibitedHelper.createDataTableColumn()");
        component.set("v.uplodJobColumns", [
            {label: "", fieldName: "uploadTypeIcon", type: "text", initialWidth:10, sortable:false,
             cellAttributes:{iconName:{ fieldName: "loadByIcon" }, iconPosition: "right"} },
            {label: "Upload By", fieldName:"uploadBy", type:"text", initialWidth:120, sortable:true}, 
            {label: "Job Started On", fieldName:"jobRubDate", type:"text", initialWidth:180, sortable:true}, 
            {label:"Status", fieldName:"jobStatus", type:"text", initialWidth:200, sortable:true},
            {label:"Percentage", fieldName:"jobPercentComplete", type:"text", initialWidth:150},
            {label:"Detail Info", fieldName:"jobDetailInfo", type:"text", initialWidth:380},
            {label: 'View Report', fieldName: 'reportURL', type: 'url', initialWidth:140, 
             typeAttributes: { label:  'View Report' , target: '_blank' }}
		]);
    
    },
    
    handleUploadFinished: function (component, event, helper) {
    	console.log("#### c:BulkUpdateDeskCommentaryProhibitedHelper.handleUploadFinished()");
    	helper.showSpinner(component, event, helper);
    	component.set("v.uploadStatus", "Validating file...");
    	component.set("v.fileValidationErrs", true);
    	
        // This will contain the List of File uploaded data and status
        var uploadedFiles = event.getParam("files");
        if(!$A.util.isEmpty(uploadedFiles)) {
        	component.set("v.uploadedDocId", uploadedFiles[0].documentId);
        	console.log("Uploaded Document Id : ",component.get("v.uploadedDocId"));
        	
        	// call the server side function  
	        var action = component.get("c.verifyUploadedFile");
	        
	        // set parameters
	        // instead of passing the uploadBy string, pass Booleans so that Apex cpde is not dependent on Strings in Lightning component 
	        //var isLoadByEmail = (component.get("v.uploadBy")===component.get("v.upLoadByContEmail")) ? true : false;
	        action.setParams({"uploadedDocId":component.get("v.uploadedDocId"),
	        				  "isLoadByRGAcc":((component.get("v.uploadBy")===component.get("v.upLoadByRGAcc")) ? true : false),
	        				  "isLoadByRMAcc":((component.get("v.uploadBy")===component.get("v.upLoadByRMAcc")) ? true : false),
	        				  "isLoadByEmail":((component.get("v.uploadBy")===component.get("v.upLoadByContEmail")) ? true : false)});
	        
	        //set callback
	        action.setCallback(this, function(response) {
	            if (response.getState()==="SUCCESS") {
	            	var validateFileResp = response.getReturnValue();
	            	if(!$A.util.isEmpty(validateFileResp)) {
	            		if(!$A.util.isEmpty(validateFileResp.errors)) {
	            			helper.showToast(component, event, helper, "Error", validateFileResp.errors, "error", "sticky", null, 10000);
	            		} else {
            				if(!$A.util.isEmpty(validateFileResp.fileBodyTxt)) {
            					component.set("v.fileBodyTxt", validateFileResp.fileBodyTxt);
            					component.set("v.fileValidationErrs", false);
            					component.set("v.uploadedDocId", null);
            					helper.showToast(component, event, helper, "Success", "File validated successfully and ready for upload", "success", "dismissible", null, 10000);
            				} else {
            					helper.showToast(component, event, helper, "Error", "File body is empty", "error", "sticky", null, 10000);
            				}	
	            		}
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
	            component.set("v.uploadStatus", "");
	            helper.hideSpinner(component, event, helper);
	        });
	
	        // enque server action
	        $A.enqueueAction(action);
        }
    },
    
    
    bulkUpload: function (component, event, helper) {
    	console.log("#### c:BulkUpdateDeskCommentaryProhibitedHelper.bulkUpload");
    	helper.showSpinner(component, event, helper);
    	// call the server side function  
        var action = component.get("c.startBulkUpload");
        // set parameters
        action.setParams({"campaignId":component.get("v.recId"), 
        				  //"uploadedDocId":component.get("v.uploadedDocId"),
        				  "fileBodyTxt":component.get("v.fileBodyTxt"),
        				  "isLoadByRGAcc":((component.get("v.uploadBy")===component.get("v.upLoadByRGAcc")) ? true : false),
        				  "isLoadByRMAcc":((component.get("v.uploadBy")===component.get("v.upLoadByRMAcc")) ? true : false),
        				  "isLoadByEmail":((component.get("v.uploadBy")===component.get("v.upLoadByContEmail")) ? true : false)});
        //set callback
        action.setCallback(this, function(response) {
            if (response.getState()==="SUCCESS") {
                console.log("FILE UPLOAD STARTED:");
                var initInfo = response.getReturnValue();
                console.log("initInfo : ",initInfo);
                if(initInfo!==null) {
                	if(!$A.util.isEmpty(initInfo.campaignId)) {
                		component.set("v.recId", initInfo.campaignId);
            		}
            		if(initInfo!==null && !$A.util.isEmpty(initInfo.runningJobId)) {
            			component.set("v.runningJobId", initInfo.runningJobId);
            		}
            		if(!$A.util.isEmpty(initInfo.PreviousJobRunList)) {
            			helper.buildPrevJobRunInfo(component, event, helper, true, initInfo.PreviousJobRunList);
            		}
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
                if(errMsg.includes("An upload job is already started by another user")) {
                	helper.init(component, event, helper);
                }
            }
            
            component.set("v.uploadedDocId", null);
            component.set("v.fileBodyTxt", null);
            component.set("v.fileValidationErrs", true);
            helper.hideSpinner(component, event, helper);
        });

        // enque server action
        $A.enqueueAction(action);
    },
    
    dwnLdFileTempl :  function(component, event, helper) {
    	console.log("#### c:BulkUpdateDeskCommentaryProhibitedHelper.dwnLdFileTempl()");
    	helper.showSpinner(component, event, helper);
    	// call the server side function  
        var action = component.get("c.downloadFileTempl");
        // set parameters
        action.setParams({"campaignId":component.get("v.recId"), 
        		"isLoadByRGAcc":((component.get("v.uploadBy")===component.get("v.upLoadByRGAcc")) ? true : false),
	        	"isLoadByRMAcc":((component.get("v.uploadBy")===component.get("v.upLoadByRMAcc")) ? true : false),
	        	"isLoadByEmail":((component.get("v.uploadBy")===component.get("v.upLoadByContEmail")) ? true : false)});

        //set callback
        action.setCallback(this, function(response) {
            if (response.getState()==="SUCCESS") {
                 var templateDocId = response.getReturnValue();
                 if(!$A.util.isEmpty(templateDocId)) {
                	 component.set("v.templDocId", templateDocId);
                	 component.set("v.showDownLoadTempl", true);
                 } else {
                	 helper.showToast(component, event, helper, "Error", 'Error in creating template file.', "error", "sticky", null, 10000);
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

        // enque server action
        $A.enqueueAction(action);
    },
    
    showSpinner : function(component, event, helper) {
    	console.log("#### c:BulkUpdateDeskCommentaryProhibitedHelper.showSpinner()");
        var spinner = component.find('pageSpinnerId');
        $A.util.removeClass(spinner, 'slds-hide');
    },
    
    hideSpinner : function(component,event, helper) {
    	console.log("#### c:BulkUpdateDeskCommentaryProhibitedHelper.hideSpinner()");
    	var spinner = component.find('pageSpinnerId');
        $A.util.addClass(spinner, 'slds-hide');
    },
    
    showToast : function(component, event, helper, title, message, type, mode, key, duration) {
    	console.log("#### c:BulkUpdateDeskCommentaryProhibitedHelper.showToast()");
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