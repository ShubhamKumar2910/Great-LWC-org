({
	// component init event handler
	init: function(component, event, helper) {
		console.log("#### c:AccountMiFIDIIMesageHelper.init()");
		component.set("v.runningJobPercent", 0);
		// make an initialize call to the apex controller to find out whether to show or hide this component for a user 
		var actionFunc = component.get("c.initialize");
    	// set parameters
    	var visibleTo = component.get("v.visibleTo");
        console.log('***visibleTo in start:'+visibleTo);
    	if(!$A.util.isEmpty(visibleTo)) {
	    	actionFunc.setParams({"csvProfileAndPSList":visibleTo});
			//set callback
			actionFunc.setCallback(this, function(response) {
				console.log("51");
				if (response.getState()==="SUCCESS") {
					console.log("52");
	                var isVisible = response.getReturnValue();
	                component.set("v.isVisible", isVisible);
                    console.log('****value of isVisible:'+isVisible);
	            } else if(response.getState()==="ERROR") {
	            	console.log("7");
	            	var errMsg="";
	                var errors = response.getError();
	                if (errors) {
	                    if (errors[0] && errors[0].message) {
	                        errMsg+=errors[0].message;
	                    }
	                } else {
	                    errMsg+="Unknown error";
	                }
	                
	                console.log('Error Occured initialization');
	            }
			});
			// enque server action
			$A.enqueueAction(actionFunc);
		}
    },
    
    handleRecordUpdated : function(component, event, helper) {
    	console.log("#### c:handleRecordUpdatedHelper.handleRecordUpdated()");
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
        	// record is loaded (render other component which needs record data value)
            console.log("Record is loaded successfully.");
            var recLoader = component.find("recordLoader");
            var targetFields = recLoader.get("v.targetFields");
            console.log("targetFields : ",targetFields);
            console.log("1");
            // if campaign Id is present then find the status of corresponding Job
            component.set("v.bulkUploadCampaignId", targetFields.Bulk_Upload_Campaign__c);
            component.set("v.previousInProgress", targetFields.Is_MiFIDII_Entitlements_In_Progress__c);
            //component.set("v.previousBulkUploadCampaignId", targetFields.Bulk_Upload_Campaign__c);
            console.log("2");
            
            if(!$A.util.isEmpty(targetFields.Bulk_Upload_Campaign__c)) {
            	console.log("3");
            	var actionFunc = component.get("c.getJobStatus");
            	// set parameters
            	actionFunc.setParams({"accRecId":targetFields.Id, 
            						"campaignId":targetFields.Bulk_Upload_Campaign__c});
        		//set callback
        		actionFunc.setCallback(this, function(response) {
        			console.log("4");
        			if (response.getState()==="SUCCESS") {
        				console.log("5");
		                var jobInfo = response.getReturnValue();
		                console.log("jobInfo : ",jobInfo);
		                if(!$A.util.isEmpty(jobInfo)) {
		                	console.log("6");
		                	// now update the running job id
		                	//component.set("v.isUploadJobRunning", jobInfo.isUploadJobRunning);
		                	component.set("v.reportURL", jobInfo.reportURL);
		                	//component.get("v.previousBulkUploadCampaignId", jobInfo.reportURL);
		                	if(targetFields.Is_MiFIDII_Entitlements_In_Progress__c===true && !isNaN(jobInfo.percentProg)) {
		                		component.set("v.runningJobPercent", jobInfo.percentProg);
		                	}
		                }
		            } else if(response.getState()==="ERROR") {
		            	console.log("7");
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
        		});
        		// enque server action
        		$A.enqueueAction(actionFunc);
            }
            component.set("v.isUploadJobRunning", targetFields.Is_MiFIDII_Entitlements_In_Progress__c);
            console.log("Is_MiFIDII_Entitlements_In_Progress__c : ",targetFields.Is_MiFIDII_Entitlements_In_Progress__c);
        } else if(eventParams.changeType === "CHANGED") {
           // record is loaded (render other component which needs record data value)
        	console.log("8");
            console.log("Record changed 1.");
            var recLoader = component.find("recordLoader");
            var targetFields = recLoader.get("v.targetFields");
            console.log("targetFields.Is_MiFIDII_Entitlements_In_Progress__c : ",targetFields);
            console.log("targetFields.Bulk_Upload_Campaign__c : ",targetFields.Bulk_Upload_Campaign__c);
            component.set("v.bulkUploadCampaignId", targetFields.Bulk_Upload_Campaign__c);
            //if(targetFields.Bulk_Upload_Campaign__c != component.get("v.previousBulkUploadCampaignId") &&
            //		targetFields.Is_MiFIDII_Entitlements_In_Progress__c === true)
            if(targetFields.Is_MiFIDII_Entitlements_In_Progress__c === true &&
            		component.get("v.previousInProgress")===false)  
            {
            	console.log("9");
            	// new job has started
           		component.set("v.isUploadJobRunning", true);
           		//component.set("v.bulkUploadCampaignId", targetFields.Bulk_Upload_Campaign__c);
           		component.set("v.previousInProgress", true);
           		//component.set("v.previousBulkUploadCampaignId", targetFields.Bulk_Upload_Campaign__c);
            } else if(targetFields.Is_MiFIDII_Entitlements_In_Progress__c === false) {
            	console.log("10");
            	if(component.get("v.previousInProgress")===true) {
            		helper.showToast(component, event, helper, "Success", "Applying MiFID-II Entitlement Job completed, please check the results for individual Contact records.", "success", "dismissible", null, 20000);
            	}
            	component.set("v.isUploadJobRunning", false);
           		component.set("v.runningJobPercent", 0);
           		component.set("v.previousInProgress", false);
            }
            console.log("handleRecordUpdated -> Is_MiFIDII_Entitlements_In_Progress__c : ",targetFields.Is_MiFIDII_Entitlements_In_Progress__c); 
        }
    },
	
	runningJobPolling : function(component, event, helper) {
    	console.log('c:AccountMiFIDIIMesageHelper.runningJobPolling()');
    	var isUploadJobRunning = component.get("v.isUploadJobRunning");
    	if(isUploadJobRunning===true) {
    		// Job is still running, so set a callback after XX seconds to refresh the status
    		var pollingFunction = function() {
    			console.log("17");
    			component.set("v.uploadStatus", $A.get("$Label.c.Refreshing_Job_Status_Message"));
    			var bulkUploadCampaignId = component.get("v.bulkUploadCampaignId");
    			console.log("bulkUploadCampaignId : ",bulkUploadCampaignId);
    			//if(!$A.util.isEmpty(bulkUploadCampaignId)) {
    				console.log("18");
	    			var actionFunc = component.get("c.getJobStatus");
	            	// set parameters
	            	//actionFunc.setParams({"campaignId":component.get("v.bulkUploadCampaignId")});
	            	actionFunc.setParams({"accRecId":component.get("v.recordId"), 
            						"campaignId":component.get("v.bulkUploadCampaignId")});
	        		//set callback
	        		actionFunc.setCallback(this, function(response) {
	        			if (response.getState()==="SUCCESS") {
			                var jobInfo = response.getReturnValue();
			                console.log("jobInfo : ",jobInfo);
			                console.log("jobInfo.reportURL ",jobInfo.reportURL);
			                console.log("jobInfo.isUploadJobRunning ",jobInfo.isUploadJobRunning);
			                console.log("jobInfo.percentProg ",jobInfo.percentProg);
			                if(!$A.util.isEmpty(jobInfo)) {
			                	if(!$A.util.isEmpty(jobInfo.campaignId)) {
				                	console.log("31");
				                	// now update the running job id
				                	component.set("v.reportURL", jobInfo.reportURL);
				                	if(!isNaN(jobInfo.percentProg)) {
				                		component.set("v.runningJobPercent", jobInfo.percentProg);
				                	} 
				                	// check whether the currently runningJobId is null or not 
				                	if(jobInfo.isUploadJobRunning===true || $A.util.isEmpty(component.get("v.bulkUploadCampaignId"))) {
				                		// running-jobId is not null, so current upload job is still running
				                		// set the recursive-polling
				                		console.log("41");	
				                		window.setTimeout(
				                			// arg 1
				                			$A.getCallback(pollingFunction), 
				                			// arg 2
				                			component.get("v.refreshStatusUpdPeriod")
				                		);
				                	} else if(jobInfo.isUploadJobRunning===false) {
				                		console.log("42");
				                		component.set("v.isUploadJobRunning", jobInfo.isUploadJobRunning);
				                		component.set("v.previousInProgress", false);
				                		var message = "Applying MiFID-II Entitlement Job completed, please check the results for individual Contact records.";
				                		helper.showToast(component, event, helper, "Success", $A.get("$Label.c.MiFID_II_Entitlement_Job_Completed_Message"), "success", "dismissible", null, 10000);
				                	}
				                	if($A.util.isEmpty(component.get("v.bulkUploadCampaignId"))) {
				                		component.set("v.bulkUploadCampaignId", jobInfo.campaignId);
				                	}
			                	} else {
			                		console.log("32");
			                		window.setTimeout(
			                			// arg 1
			                			$A.getCallback(pollingFunction), 
			                			// arg 2
			                			5000
			                		);
			                	}
			                }
			            } else if(response.getState()==="ERROR") {
			            	console.log("21");
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
			            component.set("v.uploadStatus", "");
	        		});
	        		// enque server action
	        		$A.enqueueAction(actionFunc);
	        	//} else {
	        	//	console.log("15");
	        	//	window.setTimeout(
            			// arg 1
            	//		$A.getCallback(pollingFunction), 
            			// arg 2
            	//		component.get("v.refreshStatusUpdPeriod")
            	//	);
            	//	component.set("v.uploadStatus", "");
	        	//}	
            }
            console.log("16");
            // set the polling first time, and first time call it within a second
            window.setTimeout(
        		   // arg 1
        		   $A.getCallback(pollingFunction), 
        		   // arg 2
        		   1000
            );
            console.log("11 -> Polling after 1 sec");
    	} else {
    		// Previous job is completed - with / without errors and a new upload campaign record is initialized
    		console.log("12 -> No Polling Required");
    	}
    },
    
    showToast : function(component, event, helper, title, message, type, mode, key, duration) {
    	console.log("#### c:AccountMiFIDIIMesageHelper.showToast()");
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