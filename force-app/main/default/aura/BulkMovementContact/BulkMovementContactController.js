({
    doInit : function(component, event, helper) {
        console.log('***doInit Called');
        //Set Steps
        component.set("v.progressSteps", [
            { label: $A.get("$Label.c.Bulk_Movement_Contact_Select_Account"), value: "step1"},
            { label: $A.get("$Label.c.Bulk_Movement_Contact_PI_Change"), value: "step2"},
            { label: $A.get("$Label.c.Bulk_Movement_Contact_Additional_Entities_And_Reason"), value: "step3"}
        ])

        //Set Current Step
        component.set("v.currentProgressStep", "step1");

        //Get Previous Job Details
        helper.getJobDetails(
                component,
                null,
                function(){
                    helper.createBulkMovementJobDataTableRows(component);
                    helper.createBulkMovementJobDataTableColumns(component);
                    
                }
        );

        //Load Available Options
        helper.getAvailableOptionsData(component);

        //Load Transfer Reasons
        helper.getTransferReasonData(component);
        
        //Calculate Height
        component.set('v.uploadContactErrorTableHeight', ((window.innerHeight) - ((window.innerHeight) * 0.7)));
        component.set('v.bulkMovementJobStatusTableHeight', ((window.innerHeight) - ((window.innerHeight) * 0.8)));

    },

    reInit : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },

    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        //Once record is loaded
        if(eventParams.changeType === "LOADED"){
            
            //Fetch the value for logged in User's Language
            var userLanguage = component.get("v.simpleUserViewRecord.User_Language__c");
            if(!$A.util.isUndefined(userLanguage) && !$A.util.isEmpty(userLanguage)){
                component.set("v.loggedInUserLanguage", userLanguage); 
            }
            
        }
    },

    papaParseLoaded : function(component, event, helper) {
		console.log('PapaParse loaded.');
    },
    
    csvtojsonLoaded : function(component, event, helper) {
		console.log('csvtoJson loaded.');
	},

    handleTransferByClick : function(component, event, helper) {
        var target = event.getSource(); 
		var buttonName = target.get("v.name");
        var transferBy = component.get("v.transferBy");
        if(buttonName !== transferBy) {
            component.set("v.transferBy", buttonName);
        }

        //Reset Source Data
        component.find("lookupRMAccount").reset();
        component.find("lookupContact").reset();

        component.set("v.sourceRMAccountArr", []);
        component.set("v.sourceContactArr", []);

    },

    handleSourceRMAccountDataChange : function(component, event, helper) {
        var sourceRMAccounts = event.getParam("values");
        if(sourceRMAccounts != undefined && sourceRMAccounts != null && sourceRMAccounts.length >= 1){
            component.set("v.sourceRMAccountArr", sourceRMAccounts);
        }
        else{
            component.set("v.sourceRMAccountArr", []);
        }
    },

    handleSourceContactDataChange : function(component, event, helper) {
        var sourceContacts = event.getParam("values");
        if(sourceContacts != undefined && sourceContacts != null && sourceContacts.length >= 1){
            component.set("v.sourceContactArr", sourceContacts);
        }
        else{
            component.set("v.sourceContactArr", []);
        }
    },

    handleDestinationRGAccountChange : function(component, event, helper) {
        var newRGAccounts = event.getParam("values");
        if(newRGAccounts != undefined && newRGAccounts != null && newRGAccounts.length >= 1){
            var selectedNewRGAccount = newRGAccounts[0];
            component.set("v.relatedToRGAccount", selectedNewRGAccount);
            component.set("v.destinationRGAccountId", selectedNewRGAccount);
            
            helper.getNewRMAccounts(component, {
                'accountRGId' : selectedNewRGAccount
            });
        }
        else {
            component.set("v.relatedToRGAccount", '');
            component.set("v.destinationRGAccountId", '');
        }
    },

    handleRMComboboxReset : function(component, event, helper) {
        //Reset Combobox
        var combobox = component.find("comboboxDestinationRMAccount");
        combobox.clear();
        combobox.hideItems();
        $A.util.addClass(combobox.find('lookup-pill'),'slds-hide');

        //Reset Value
        component.set('v.destinationRMAccountId', '');
    },

    handleDestinationRMAccountChange : function(component, event, helper) {
        var destinationRMAccounts = event.getParam("values");
        if(destinationRMAccounts != undefined && destinationRMAccounts != null && destinationRMAccounts.length >= 1){
            component.set('v.destinationRMAccountId', destinationRMAccounts[0]);
        }
        else {
            component.set('v.destinationRMAccountId', '');
        }
    },

    clearDestinationRMAccount : function(component, event, helper) {
        var destinationRGAccountData = component.get("v.destinationRGAccountId");
        if(destinationRGAccountData != ''){
            component.set('v.destinationRMAccountId', '');
            var combobox = component.find("comboboxDestinationRMAccount");
            combobox.reinitialise();
        }


        var destinationRMAccounts = event.getParam("values");
        if(destinationRMAccounts != undefined && destinationRMAccounts != null && destinationRMAccounts.length >= 1){
            component.set('v.destinationRMAccountId', destinationRMAccounts[0]);
        }
        else {
            component.set('v.destinationRMAccountId', '');
        }
    },

    performValidationForAccountData : function (component, event, helper){
        var sourceRMAccountData = component.get("v.sourceRMAccountArr");
        var sourceContactData = component.get("v.sourceContactArr");
        var destinationRGAccountData = component.get("v.destinationRGAccountId");
        var destinationRMAccountData = component.get("v.destinationRMAccountId");

        if( ((sourceRMAccountData != undefined && sourceRMAccountData != null && sourceRMAccountData.length >= 1) || 
             (sourceContactData != undefined && sourceContactData != null && sourceContactData.length >= 1)
            ) && (destinationRGAccountData != undefined && destinationRGAccountData != null && destinationRGAccountData != '')
              && (destinationRMAccountData != undefined && destinationRMAccountData != null && destinationRMAccountData != ''))
        {
            component.set("v.sourceDataPresent", true);
        }
        else {
            component.set("v.sourceDataPresent", false);
        }

    },

    handleToggleForContactPIChange : function(component, event, helper) {
        var checkedValue = component.find("contactPIChangeToggle").get("v.checked");
        if(checkedValue == true){
            checkedValue = false;
            
            //Reset the JSON
            component.set("v.contactDataJSONString","");

            //Perform Campaign Members cleanup
            //It is possible that user first selected "Change Contact's PI" and then unselected and selected again 
            helper.performCleanup(component, {'campaignId' : component.get("v.campaignRecordId")});
        }
        else {
            checkedValue = true;
            //Hide Upload File Section
            component.set("v.uploadFileDisabler", true);

            //Hide Upload Error Table
            component.set("v.fileValidationErrors", false);
        }
        component.set("v.contactPIChangeDisabler",checkedValue);
    },
    
    downloadSourceContactDetails : function(component, event, helper) {
        //Show Spinner
        helper.showSpinner(component);

        helper.getSourceContactDetails(
            component,
            {
                'sourceRMAccountList' : component.get("v.sourceRMAccountArr"),
                'sourceContactList' : component.get("v.sourceContactArr")
            },
            function(){
                var csvString = helper.convertObjectRecordsToCSV(component);
                
                //Hide Spinner
                helper.hideSpinner(component);      

                if(csvString != null && csvString != ''){
                    var hiddenElement = document.createElement('a');
                    hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
                    hiddenElement.target = '_self'; 
                    hiddenElement.download = 'ExportContactData.csv';  
                    document.body.appendChild(hiddenElement); 
                    hiddenElement.click(); 


                    //Show Upload File Section
                    var contactPIChangeDisabler = component.get("v.contactPIChangeDisabler");
                    if(contactPIChangeDisabler == false){
                        component.set("v.uploadFileDisabler", false);
                    }
                }
                else {
                    component.showMessage($A.get("$Label.c.Error"), $A.get("$Label.c.No_Data_Found_Label"), "error");
                    //Hide Upload File Section
                    component.set("v.uploadFileDisabler", true);

                    return;
                }
            }
        );

    },

    handleUpload : function(component, event, helper){
        try{
            
            //Show Spinner
            helper.showSpinner(component);
            
            component.set("v.contactDataJSONString","");
            var uploadedFiles = event.getSource().get("v.files");
            var fileData = uploadedFiles[0];
            
            var data;
            
            Papa.parse(fileData, {
                complete: function(results) {
                    data = results.data;
                    var csvData = Papa.unparse(data); 
                    var csvToJSONConverter = new csvtojson.Converter(null);
                    csvToJSONConverter.fromString(csvData, function(err, result) {
                        if (err){
                            component.showMessage($A.get("$Label.c.Error"), err.toString(), "error");
                            return;
                        }

                        if(result.length === 0){
                            component.showMessage($A.get("$Label.c.Error"), $A.get("$Label.c.No_Data_Found_Label"), "error");
                        }
                        else{
                            component.set("v.contactDataJSONString",JSON.stringify(result, 2, 2));
                            
                            //Perform Validation
                            var contactDataJSONString = component.get("v.contactDataJSONString");
                            helper.performValidationForUploadedContactData(
                                component, 
                                {
                                    'contactDataJSONStr' : contactDataJSONString, 
                                    'campaignId' : component.get("v.campaignRecordId")
                                },
                                function(){
                                    helper.createUploadContactErrorDataTableRows(component);
                                    helper.createUploadContactErrorDataTableColumns(component);
                                    
                                    //Hide Spinner
                                    helper.hideSpinner(component); 
                                }
                            );
                        }
                        
                    }); 
                    
                    
                }
            });
        }
        catch(err)
        {
            component.showMessage($A.get("$Label.c.Error"), err.message.toString(), "error");
        }

    },

    handleAvailableOptionsChange : function(component, event, helper) {
        var selectedAvailableOptionsList = event.getParam("value");
        component.set("v.selectedAvailableOptionsList", selectedAvailableOptionsList);
    },

    handleTransferReasonChange : function(component, event, helper) {
        var selectedTransferReason = event.getParam("value");
        component.set("v.transferReason", selectedTransferReason);
    },

    performValidationForActivityMovementAndReason : function (component, event, helper){
        
        var selectedTransferReason = component.get("v.transferReason");

        //Perform validation for Transfer Reason
        if(selectedTransferReason == undefined || selectedTransferReason == null || selectedTransferReason == ''){
            component.set("v.validationPassed", false);
            component.showMessage($A.get("$Label.c.Error"), $A.get("$Label.c.Error_Message_Transfer_Reason_Selection"), "error");
            return;
        }
        else {
            //Perform Validation for Available Options and Transfer Reason
            var isMovementUnderSameRG = component.get("v.movementUnderSameRG");
            
            var activityMovementSelected = false;
            var selectedAvailableOptions = component.get("v.selectedAvailableOptionsList");
            
            if(selectedAvailableOptions != undefined && selectedAvailableOptions != null && selectedAvailableOptions.length > 0){
                for(var index = 0; index < selectedAvailableOptions.length; index++){
                    var selectedOption = selectedAvailableOptions[index];
                    if(selectedOption == "Move Historic Activities"){
                        activityMovementSelected = true;
                        break;
                    }
                }

                //If Move Historic Activities is selected then you cannot select 'Contact Moved Organisation' as Transfer Reason
                //If Move Historic Activities is not selected then you cannot select 'Contact Data Correction' as Transfer Reason
                if(activityMovementSelected == true && selectedTransferReason == 'Contact Moved Organisation' && isMovementUnderSameRG == false){
                    component.set("v.validationPassed", false);
                    component.showMessage($A.get("$Label.c.Error"), $A.get("$Label.c.Error_Message_Selected_Transfer_Reason_Not_Valid"), "error");
                    return;
                }

            }

            if(activityMovementSelected == false && (selectedTransferReason == 'Contact Data Correction' || selectedTransferReason == 'Contact Internal Movement') && isMovementUnderSameRG == false){
                component.set("v.validationPassed", false);
                component.showMessage($A.get("$Label.c.Error"), $A.get("$Label.c.Error_Message_Selected_Transfer_Reason_Needs_Actions"), "error");
                return;
            }

            component.set("v.validationPassed", true);

        }
    },

    handlePreviousButtonClick : function(component, event, helper) {
        var previousButton = component.find("previousButton");
        var nextButton = component.find("nextButton");

        if(component.get("v.currentProgressStep") === 'step1'){
            component.navigateToHomepage();
        }
        else if(component.get("v.currentProgressStep") === 'step2'){
            //Show Job Info Details Table
            component.set("v.showJobInfoDetails", true);

            component.set("v.currentProgressStep", "step1");

            previousButton.set("v.label", $A.get("$Label.c.Cancel"));
            previousButton.set("v.iconName", "utility:close");
        }
        else if(component.get("v.currentProgressStep") === 'step3'){
            component.set("v.currentProgressStep", "step2");

            previousButton.set("v.label", $A.get("$Label.c.Previous"));
            previousButton.set("v.iconName", "utility:back");

            nextButton.set("v.label", $A.get("$Label.c.Next"));
            nextButton.set("v.iconName", "utility:forward");
        }
        
    },

    handleNextButtonClick : function(component, event, helper) {
        if(component.get("v.currentProgressStep") === 'step1'){
            component.preStep2Tasks();
        }
        else if(component.get("v.currentProgressStep") === 'step2'){
            component.preStep3Tasks();
        }
        else if(component.get("v.currentProgressStep") === 'step3'){
            component.preFinalStepTasks();
        }
        
    },

    preStep2Tasks : function (component, event, helper){
        var previousButton = component.find("previousButton");
        var proceedToNext = true;
        
        component.performValidationForAccountData();
        var isAccountDataPresent = component.get("v.sourceDataPresent"); 
        
        //Check all required data entered
        if(isAccountDataPresent == true){

            helper.showSpinner(component);

            //Check whether campaign already exists
            var campaignId = component.get("v.campaignRecordId");

            if(campaignId == undefined || campaignId == null || campaignId == ''){
                helper.getCampaignDetails(component);
            }
            
            //Fetch Account Specific Details
            helper.getMovementAccountSpecificDetails(
                component,
                {
                    'sourceRMAccountList' : component.get("v.sourceRMAccountArr"),
                    'sourceContactList' : component.get("v.sourceContactArr"),
                    'destinationRGAccountId' : component.get("v.destinationRGAccountId"),
                    'destinationRMAccountId' : component.get("v.destinationRMAccountId")
                },
                function(){
                    helper.hideSpinner(component);

                    //Check Whether Source or Destination Account is Exceptional Account
                    var isExceptionalAccount = component.get("v.isExceptionalAccount");
                    if(isExceptionalAccount){
                        component.showMessage($A.get("$Label.c.Error"),$A.get("$Label.c.Error_Message_Internal_Accounts_Selection"),"error");
                        proceedToNext = false;
                    }
                    
                    
                    //Check Whether Source or Destination RM Account is same
                    var movementUnderSameRM = component.get("v.movementUnderSameRM");
                    if(movementUnderSameRM){
                        component.showMessage($A.get("$Label.c.Error"),$A.get("$Label.c.Error_Message_Destination_Address_Same_As_Current_Address"),"error");
                        proceedToNext = false;
                    }
                    
                    if(proceedToNext == true){
                        //Check Whether Account Region is different for Old and New Accounts
                        /*var accountRegionDifferent = component.get("v.accountRegionDifferent");

                        if(accountRegionDifferent){
                            component.showMessage("Warning", "The accounts which you have chosen have different regions hence GRP Access will be revoked for contacts ", "warning");
                        }*/
                        
                        //Hide Job Info Details Table
                        component.set("v.showJobInfoDetails", false);

                        component.set("v.currentProgressStep", "step2");

                        previousButton.set("v.label", $A.get("$Label.c.Previous"));
                        previousButton.set("v.iconName", "utility:back");
                    }
                   
                }
            );
        }
        else {
            component.showMessage($A.get("$Label.c.Error"),$A.get("$Label.c.Bulk_Movement_Contact_Data_Validation_Error"),"error");
        }
    },

    preStep3Tasks : function (component, event, helper){
        var previousButton = component.find("previousButton");
        var nextButton = component.find("nextButton");
        var isFileValidationFailed = component.get("v.fileValidationErrors");
        var contactPIChangeDisabler = component.get("v.contactPIChangeDisabler");
        
        if(isFileValidationFailed == false){

                //If Change Contact's PI is checked and user directly clicked Next
                helper.checkContactDataPresent(
                    component,
                    {
                        'campaignId' : component.get("v.campaignRecordId")
                    },
                    function(){
                        var changedContactPIDataPresent = component.get("v.changedContactPIDataPresentInCampaign");
                        if(changedContactPIDataPresent || (changedContactPIDataPresent == false && contactPIChangeDisabler == true)){

                            //Hide Job Info Details Table
                            component.set("v.showJobInfoDetails", false);

                            component.set("v.currentProgressStep", "step3");

                            previousButton.set("v.label", $A.get("$Label.c.Previous"));
                            previousButton.set("v.iconName", "utility:back");
            
                            nextButton.set("v.label", $A.get("$Label.c.Submit"));
                            nextButton.set("v.iconName", "utility:task");
                        }
                        else {
                            component.showMessage($A.get("$Label.c.Error"),$A.get("$Label.c.Bulk_Movement_Contact_File_Upload_Error"),"error");
                        }
                    }
                );

        }
        else {
            component.showMessage($A.get("$Label.c.Error"),$A.get("$Label.c.Bulk_Movement_Contact_File_Validation_Error"),"error");
        }
    },

    preFinalStepTasks : function (component, event, helper){
        component.performValidationForActivityMovementAndReason();
        var validationPassed = component.get("v.validationPassed"); 

        if(validationPassed == true){
            
            helper.showSpinner(component);

            var bulkMovementContactDataWrapperObj = helper.createBulkMovementContactDataWrapperObj(component);
            var jsonStr = JSON.stringify(bulkMovementContactDataWrapperObj);
            
            helper.saveBulkMovementContactData(
                component,
                {
                    'bulkMovementContactDataJSONStr' : jsonStr
                },
                function(){
                    helper.hideSpinner(component);

                    component.showMessage($A.get("$Label.c.Submitted"),$A.get("$Label.c.Bulk_Movement_Contact_Request_Submitted"),"success");

                    component.reInit();
                }
            );
        }
    },

    navigateToHomepage : function (component, event, helper){
        
        component.find("navigationService").navigate({
            "type": "standard__namedPage",
            "attributes": {
                "pageName": "home"
            }                
        });              
    },

    showMessage : function(component, event, helper){
        var params = event.getParam('arguments');
        if(params){
             var resultsToast = $A.get("e.force:showToast");
             resultsToast.setParams({
                 "title": params.title,
                 "message": params.message,
                 "type": params.type,
                 "duration":30000
             });
             resultsToast.fire();
        }
    }

    
})