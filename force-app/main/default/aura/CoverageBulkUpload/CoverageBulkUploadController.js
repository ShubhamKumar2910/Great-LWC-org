({
    doInit : function(component, event, helper) {
        console.log('Initialisation.');
        var cmpPartial = component.find('partialBtn');
        $A.util.removeClass(cmpPartial, 'slds-hide');
        var cmpSubmit = component.find('SuccessBtn');
        $A.util.removeClass(cmpSubmit, 'slds-hide');
        helper.readTemplateId(component);
        //component.showAlert("success","test message");
	},
	jqueryMinLoaded : function(component, event, helper) {
		console.log('jquery min loaded.');
	},
    jsZipLoaded : function(component, event, helper) {
		console.log('jsZip loaded.');
	},
    papaParseLoaded : function(component, event, helper) {
		console.log('papaParse loaded.');
	},
    csvtojsonLoaded : function(component, event, helper) {
		console.log('csvtoJson loaded.');
	},
    displayMessage : function(component, event, helper) {
        /*var params = event.getParam('arguments');
        console.log(params);
        if (params) {
            var toastEvent = event.get("showToast");
            console.log(toastEvent);
            toastEvent.setParams({
                "title": "",
                "message": params.message,
                "type": params.messagetype
            });
        }
        toastEvent.fire();*/
    },
    showSpinner : function(component,event) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },
    hideSpinner : function(component,event) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.addClass(cmpTarget, 'slds-hide');
    },
    showResult : function(component,event) {
        var cmpTarget = component.find('mainResult');
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },
    hideResult : function(component,event) {
        var cmpTarget = component.find('mainResult');
        $A.util.addClass(cmpTarget, 'slds-hide');
    },
    showMain : function(component,event) {
        var cmpTarget = component.find('mainInput');
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },
    hideMain : function(component,event) {
        var cmpTarget = component.find('mainInput');
        $A.util.addClass(cmpTarget, 'slds-hide');
    },
    showValidateButton : function(component,event) {
        var cmpTarget = component.find('validateButton');
         console.log('*************************************');
        console.log($A.util);
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },
    hideValidateButton : function(component,event) {
        var cmpTarget = component.find('validateButton');
        $A.util.addClass(cmpTarget, 'slds-hide');
    },
    loadFile : function(component,event) {
        try
        {
            console.log('file changed');
            var files = event.target.files;
            var f = files[0];
            if(f.type != 'application/vnd.ms-excel')
            {
                component.showAlert("error",'The input file is either not valid or file contains invalid data.');
                console.log('The input file is either not valid or file contains invalid data.');
            }
            else
            {
                var data;
                var displayCallBackFunction = $A.getCallback(function displaybutton() {
                    component.showValidateButton();
                });
                Papa.parse(f, {
                    complete: function(results) {
                        data = results.data;
                        var csvdata = Papa.unparse(data); 
                        console.log('csv data');
                        console.log(csvdata);
                        var conv = new csvtojson.Converter(null);
                        conv.fromString(csvdata, function(err, result) {
                            if (err){
                                component.showAlert("error",err.toString());  
                                return;
                            }
                            console.log('result: ');
                            console.log(result);
                            
                            if(result.length === 0)
                            {
                                console.log('No data found.');
                                component.showAlert("error",'No data found!!');  
                            }
                            else
                            {
                                component.hideAlert();
                                component.set("v.JSONString",JSON.stringify(result, 2, 2));
                                console.log(component.get("{!v.JSONString}"));
                                displayCallBackFunction();
                            }
                            
                        }); 
                        
                        
                    }
                });
            }
        }
        catch(e)
        {
            component.showAlert("error",e.message.toString());  
        }
       
    },
    OnValidate : function(component,event,helper) {
        console.log("ValidateClicked");
        component.showSpinner();
     	helper.beginValidations(component);   
    },
    showActionButtons : function(component,event) {
        var cmpTarget = component.find('mainButtons');
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },
    hideActionButtons : function(component,event) {
        var cmpTarget = component.find('mainButtons');
        $A.util.addClass(cmpTarget, 'slds-hide');
    },
    pageChange: function(component, event, helper) {
        component.showSpinner();
        var direction = event.getParam("direction");
        console.log('Direction: '+direction);
        direction === "previous" ? component.OnPrev() : component.OnNext();
    },
    OnNext : function(component,event,helper) {
        component.showSpinner();
        helper.getNext(component);
    },
    OnPrev : function(component,event,helper) {
        component.showSpinner();
        helper.getPrevious(component);
    },
    showAlert : function(component, event, helper) {
        var params = event.getParam('arguments');
        console.log('params');
        console.log(params);
        
        if(params)
        {
            var messagetype = params.type;
            var messagetext = params.text;
            if(messagetype=="success")
            {
                $A.createComponent(
                    "c:CustomAlert",
                    {
                        "success": "true",
                        "text":messagetext
                    },
                    function(alertbox, status, errorMessage){
                        console.log('alertbox');
                        console.log(status);
                        console.log(errorMessage);
                        console.log(alertbox);
                        
                        
                        //Add the new button to the body array
                        if (status === "SUCCESS") {
                            component.set("v.alertDiv", alertbox);
                        }
                        else if (status === "INCOMPLETE") {
                            console.log("No response from server or client is offline.")
                            // Show offline error
                        }
                            else if (status === "ERROR") {
                                console.log("Error: " + errorMessage);
                                // Show error message
                            }
                    }
                );
            }
            else if(messagetype == "error")
            {
                $A.createComponent(
                    "c:CustomAlert",
                    {
                        "aura:id": "customAlert",
                        "error": "true",
                        "text":messagetext
                    },
                    function(alertbox, status, errorMessage){
                        //Add the new button to the body array
                        if (status === "SUCCESS") {
                            component.set("v.alertDiv", alertbox);
                        }
                        else if (status === "INCOMPLETE") {
                            console.log("No response from server or client is offline.")
                            // Show offline error
                        }
                            else if (status === "ERROR") {
                                console.log("Error: " + errorMessage);
                                // Show error message
                            }
                    }
                );
            }
                else if(messagetype == "warning")
                {
                    $A.createComponent(
                        "c:CustomAlert",
                        {
                            "aura:id": "customAlert",
                            "warning": "true",
                            "text":messagetext
                        },
                        function(alertbox, status, errorMessage){
                            //Add the new button to the body array
                            if (status === "SUCCESS") {
                                component.set("v.alertDiv", alertbox);
                            }
                            else if (status === "INCOMPLETE") {
                                console.log("No response from server or client is offline.")
                                // Show offline error
                            }
                                else if (status === "ERROR") {
                                    console.log("Error: " + errorMessage);
                                    // Show error message
                                }
                        }
                    );
                }
                    else
                    {
                        //info
                        $A.createComponent(
                            "c:CustomAlert",
                            {
                                "aura:id": "customAlert",
                                "info": "true",
                                "text":messagetext
                            },
                            function(alertbox, status, errorMessage){
                                //Add the new button to the body array
                                if (status === "SUCCESS") {
                                    component.set("v.alertDiv", alertbox);
                                }
                                else if (status === "INCOMPLETE") {
                                    console.log("No response from server or client is offline.")
                                    // Show offline error
                                }
                                    else if (status === "ERROR") {
                                        console.log("Error: " + errorMessage);
                                        // Show error message
                                    }
                            }
                        );
                    }
        }
        
        
       
    },
    showPossibleValues : function(component, event, helper) {
        var params = event.getParam('arguments');
        if(params)
        {
            var recordtype = params.recordtype;
            var fieldName = params.fieldName;
            var sourceObject = 'Coverage_Team_Member__c';
            var myWindow;
            if(recordtype != null)
            {
                if(fieldName == 'Product2__c')
                    myWindow = window.open('/apex/BulkUploadPopup?objectName='+sourceObject+'&fieldName='+fieldName+'&type='+recordtype,'','width=350,height=800,scrollbars=no,resizable=no');
                else
                    myWindow = window.open('/apex/BulkUploadPopup?objectName='+sourceObject+'&fieldName='+fieldName+'&type='+recordtype,'','width=500,height=300,scrollbars=no,resizable=no');
            }
            else
            {
                if(fieldName == 'Product2__c')
                    myWindow = window.open('/apex/BulkUploadPopup?objectName='+sourceObject+'&fieldName='+fieldName,'','width=350,height=800,scrollbars=no,resizable=no');    
                else
                    myWindow = window.open('/apex/BulkUploadPopup?objectName='+sourceObject+'&fieldName='+fieldName,'','width=500,height=300,scrollbars=no,resizable=no');    
            }
            return false;
        }
        
    },
    showProductGroup : function(component,event)
    {
        component.showPossibleValues("","Product_Group__c");
    },
    showProductRegions : function(component,event)
    {
        component.showPossibleValues("","Product_Region__c");
    },
    showProductNames : function(component,event)
    {
        component.showPossibleValues("","Product2__c");
    },
    showRoles : function(component,event)
    {
        component.showPossibleValues("","Team_Role__c");
    },
    hideAlert : function(component,event, helper){
        component.set("v.alertDiv", '');
    },
    downloadCSV : function(component,event){
        component.showSpinner();
        var csvdata = component.get("v.csvString");
        csvdata = csvdata.split(":").join("\n");
        csvdata = csvdata.split("null").join("");
        console.log('CSVData');
        console.log(csvdata);
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:attachment/xlsx,' + encodeURI(csvdata);
        hiddenElement.target = '_blank';
        hiddenElement.download = 'error.csv';
        hiddenElement.click();
        component.hideSpinner();
    },
    refresh : function(component, event, helper) {
        window.location.reload();
    },
    submitData: function(component,event,helper)
    {
        component.showSpinner();
        helper.stageData(component);
    }
})