({
    showSpinner : function(component) { 
        $A.util.removeClass(component.find('spinner'), 'slds-hide'); 
    }, 
  
    hideSpinner : function(component) { 
        $A.util.addClass(component.find('spinner'), 'slds-hide'); 
    }, 

    getJobDetails : function(component, params, successCallback, failureCallback){
        var action = component.get("c.getBulkMovementContactJobDetails"); 
        if(params)
            action.setParams(params);

        action.setCallback(this, function(response){
            var state = response.getState(); 
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(!$A.util.isUndefined(result) && !$A.util.isEmpty(result)){
                    
                    component.set("v.previousJobList", result);

                    if (successCallback) { 
                        successCallback(); 
                    }
                }
            }
            else {
                alert('Error in calling server side action');
            }
        });
        
        $A.enqueueAction(action);    
    },

    getAvailableOptionsData : function(component, params, successCallback, failureCallback){
        var action = component.get("c.getAvailableOptionsList"); 
        if(params)
            action.setParams(params);

        action.setCallback(this, function(response){
            var state = response.getState(); 
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(!$A.util.isUndefined(result) && !$A.util.isEmpty(result)){
                    component.set("v.availableOptionsList", result);
                    if (successCallback) { 
                        successCallback(); 
                    }
                }
            }
            else {
                alert('Error in calling server side action');
            }
        });
        
        $A.enqueueAction(action);    
    },

    getTransferReasonData : function(component, params, successCallback, failureCallback){
        var action = component.get("c.getTransferReasonList"); 
        if(params)
            action.setParams(params);

        action.setCallback(this, function(response){
            var state = response.getState(); 
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(!$A.util.isUndefined(result) && !$A.util.isEmpty(result)){
                    component.set("v.transferReasonList", result);
                    if (successCallback) { 
                        successCallback(); 
                    }
                }
            }
            else {
                alert('Error in calling server side action');
            }
        });
        
        $A.enqueueAction(action);    
    },
    
    getNewRMAccounts : function(component, params) {
        var action = component.get("c.getRMAccounts"); 
        if(params){
            action.setParams(params);
        }
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result != null){
                    var addresses = [];
                    for(var index = 0; index < result.length; index++){
                        //test
                        var labelText = result[index].BillingCountry + ' ' + result[index].BillingStreet + ' ' + result[index].BillingCity;
                        addresses.push({label:labelText, value: result[index].Id});
                    }
                }
                component.set("v.addressOptions", addresses);

                //ReInitialize
                component.find("comboboxDestinationRMAccount").reinitialise();
            }
            else {
                alert('Error calling action with state: ' + response.getState());
            }
        })
        $A.enqueueAction(action);
    },

    getSourceContactDetails : function(component, params, successCallback, failureCallback){
        var action = component.get("c.getSourceContactDetails"); 
        if(params)
            action.setParams(params);

        action.setCallback(this, function(response){
            var state = response.getState(); 
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(!$A.util.isUndefined(result)){
                    component.set("v.sourceContactData", result); 
                    if (successCallback) { 
                        successCallback(); 
                    }
                }
            }
            else {
                alert('Error in calling server side action');
            }
        });
        
        $A.enqueueAction(action);    
    },

    getCampaignDetails : function(component, params, successCallback, failureCallback){
        var action = component.get("c.getCampaignDetails"); 
        if(params)
            action.setParams(params);

        action.setCallback(this, function(response){
            var state = response.getState(); 
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(!$A.util.isUndefined(result)){
                    component.set("v.campaignRecordId", result); 
                    if (successCallback) { 
                        successCallback(); 
                    }
                }
            }
            else {
                alert('Error in calling server side action');
            }
        });
        
        $A.enqueueAction(action);    
    },

    getMovementAccountSpecificDetails : function(component, params, successCallback, failureCallback){
        var action = component.get("c.getMovementAccountSpecificDetails"); 
        if(params)
            action.setParams(params);

        action.setCallback(this, function(response){
            var state = response.getState(); 
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(!$A.util.isUndefined(result)){
                    
                    for(var key in result){
                        if(key == 'movementUnderSameRG'){
                            component.set("v.movementUnderSameRG", result[key]); 
                        }
                        else if(key == 'movementUnderSameRM'){
                            component.set("v.movementUnderSameRM", result[key]); 
                        }
                        /*else if(key == 'accountRegionDifferent'){
                            component.set("v.accountRegionDifferent", result[key]); 
                        }*/
                        else if(key == 'isExceptionalAccount'){
                            component.set("v.isExceptionalAccount", result[key]); 
                        }
                    }
                    
                    if (successCallback) { 
                        successCallback(); 
                    }
                }
            }
            else {
                alert('Error in calling server side action');
            }
        });
        
        $A.enqueueAction(action);    
    },

    performCleanup : function(component, params, successCallback, failureCallback){
        var action = component.get("c.performCleanup"); 
        if(params)
            action.setParams(params);

        action.setCallback(this, function(response){
            var state = response.getState(); 
            if (state === "SUCCESS") {
                if (successCallback) { 
                    successCallback(); 
                }
            }
            else {
                alert('Error in calling server side action');
            }
        });
        
        $A.enqueueAction(action);    
    },

    checkContactDataPresent : function(component, params, successCallback, failureCallback){
        var action = component.get("c.checkContactDataPresent"); 
        if(params)
            action.setParams(params);

        action.setCallback(this, function(response){
            var state = response.getState(); 
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(!$A.util.isUndefined(result)){
                    component.set("v.changedContactPIDataPresentInCampaign", result); 
                    if (successCallback) { 
                        successCallback(); 
                    }
                }
            }
            else {
                alert('Error in calling server side action');
            }
        });
        
        $A.enqueueAction(action);    
    },


    performValidationForUploadedContactData : function(component, params, successCallback, failureCallback){
        console.log('***** Inside validateContactDetails');
        /*var todayBefore = new Date();
        var timeBefore = todayBefore.getHours() + ":" + todayBefore.getMinutes() + ":" + todayBefore.getSeconds();
        console.log('***Timebefore:'+timeBefore);*/
        var action = component.get("c.performValidation"); 
        if(params)
            action.setParams(params);

        action.setCallback(this, function(response){
            var state = response.getState(); 
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                /*var todayAfter = new Date();
                var timeAfter = todayAfter.getHours() + ":" + todayAfter.getMinutes() + ":" + todayAfter.getSeconds();
                console.log('***timeAfter:'+timeAfter);*/
                if(!$A.util.isUndefined(result) && result != null && result.length > 0){
                    
                    component.set("v.fileValidationErrorData", result);
                    component.set("v.fileValidationErrors", true);

                    if (successCallback) { 
                        successCallback(); 
                    }
                }
                else {
                    component.set("v.fileValidationErrorData", null);
                    component.set("v.fileValidationErrors", false);

                    //Hide Spinner
                    this.hideSpinner(component); 

                    component.showMessage("",$A.get("$Label.c.No_Errors_Or_Warnings_Found"),"success");
                }
            }
            else {
                alert('Error in calling server side action while validating');
            }
        });
        
        $A.enqueueAction(action);    
    },

    saveBulkMovementContactData : function(component, params, successCallback, failureCallback){
        var action = component.get("c.saveBulkMovementContactData"); 
        if(params)
            action.setParams(params);

        action.setCallback(this, function(response){
            var state = response.getState(); 
            if (state === "SUCCESS") {
                if (successCallback) { 
                    successCallback(); 
                }
            }
            else {
                alert('Error in calling server side action while validating');
            }

        });
        
        $A.enqueueAction(action);    
    },

    createBulkMovementContactDataWrapperObj : function(component, event, helper){
        var bulkMovementContactDataWrapperObj = new Object();
        bulkMovementContactDataWrapperObj.sourceRMAccountList = component.get("v.sourceRMAccountArr");
        bulkMovementContactDataWrapperObj.sourceContactList = component.get("v.sourceContactArr");
        bulkMovementContactDataWrapperObj.destinationRGAccountId = component.get("v.destinationRGAccountId");
        bulkMovementContactDataWrapperObj.destinationRMAccountId = component.get("v.destinationRMAccountId");
        bulkMovementContactDataWrapperObj.transferReason = component.get("v.transferReason");
        bulkMovementContactDataWrapperObj.selectedOptionsList = component.get("v.selectedAvailableOptionsList");

        var contactPIChangeChecked = component.get("v.contactPIChangeDisabler");
        if(contactPIChangeChecked == true){
            contactPIChangeChecked = false;
        }
        else {
            contactPIChangeChecked = true;
        }
        bulkMovementContactDataWrapperObj.contactPIChangeChecked = contactPIChangeChecked;

        bulkMovementContactDataWrapperObj.movementUnderSameRG = component.get("v.movementUnderSameRG");
        bulkMovementContactDataWrapperObj.campaignId = component.get("v.campaignRecordId");

        return bulkMovementContactDataWrapperObj;
    },

    createUploadContactErrorDataTableRows : function(component, event, helper){
        var fileValidationErrorData = component.get("v.fileValidationErrorData");
        var fileValidationErrors = component.get("v.fileValidationErrors");

        if(fileValidationErrors == true && !$A.util.isEmpty(fileValidationErrorData)){
            var rows = [];

            for(var index = 0; index < fileValidationErrorData.length; index++){
                var rowData = {};
                var errorRecord = fileValidationErrorData[index];

                rowData.id = errorRecord.id;
                rowData.name = errorRecord.name;
                rowData.email = errorRecord.email;
                rowData.errorMsg = errorRecord.errorMsg;

                rows.push(rowData);
            }

            component.set("v.uploadContactErrorRows", rows);
        }
    },

    createUploadContactErrorDataTableColumns : function(component, event, helper){
        component.set("v.uploadContactErrorColumns", [
            {label: $A.get("$Label.c.Contact_Id"), fieldName:'id', type:'text', initialWidth:200, sortable:true }, 
            {label: $A.get("$Label.c.Name"), fieldName:'name', type:'text', initialWidth:200, sortable:true }, 
            {label: $A.get("$Label.c.Email"), fieldName:'email', type:'text', initialWidth:200, sortable:true }, 
            {label: $A.get("$Label.c.Error_Message"), fieldName:'errorMsg', type:'text', initialWidth:200, sortable:true }
		]);
    },

    createBulkMovementJobDataTableRows : function(component, event, helper){
        var bulkMovementJobData = component.get("v.previousJobList");
        
        if(!$A.util.isEmpty(bulkMovementJobData)){
            var rows = [];

            for(var index = 0; index < bulkMovementJobData.length; index++){
                var rowData = {};
                var jobStatusRecord = bulkMovementJobData[index];

                rowData.jobCreated = jobStatusRecord.campaignCreatedDate;
                rowData.completedProcesses = jobStatusRecord.completedProcesses;
                rowData.pendingProcesses = jobStatusRecord.pendingProcesses;
                rowData.viewReport = jobStatusRecord.reportURL;

                rows.push(rowData);
            }

            component.set("v.bulkMovementJobStatusRows", rows);
        }
    },

    createBulkMovementJobDataTableColumns : function(component, event, helper){
        component.set("v.bulkMovementJobStatusColumns", [
            {label: $A.get("$Label.c.Job_Started_On"), fieldName:'jobCreated', type:'text', initialWidth:300 }, 
            {label: $A.get("$Label.c.Completed_Processes"), fieldName:'completedProcesses', type:'text', initialWidth:300 }, 
            {label: $A.get("$Label.c.Pending_Processes"), fieldName:'pendingProcesses', type:'text', initialWidth:300 },
            {label: $A.get("$Label.c.View_Report"), fieldName:'viewReport', type:'url', initialWidth:300, typeAttributes: { label:$A.get("$Label.c.View_Report"), target:'_blank'} }
		]);
    },

    convertObjectRecordsToCSV : function(component) {
        var objectData = component.get("v.sourceContactData");
        var columnDivider = ',';
        var lineDivider = '\n';
        var csvString = '';
        var counter = 0; 

        if(objectData != null){
            var objectDataKeys = objectData["fieldAPINameList"];
            var objectDataRows = objectData["rows"];
            var objectDataHeaderRow = objectData["headerRow"];
        

            if(objectDataRows == null || !objectDataRows.length){
                return csvString;
            }

            //Add Header Row
            csvString += objectDataHeaderRow;
            csvString += lineDivider;

            for(var index = 0; index < objectDataRows.length; index++){
                counter = 0;
                for(var tempColumnKey in objectDataKeys){
                    var columnKey = objectDataKeys[tempColumnKey];
                    if(counter > 0){
                        csvString += columnDivider;
                    }
                    var columnData = objectDataRows[index][columnKey];
                    
                    csvString += (columnData != undefined && columnData != null ) ? ('"' + columnData + '"') : '';

                    counter++;
                }
                csvString += lineDivider;
            }
        }

        return csvString;

    }

    
})