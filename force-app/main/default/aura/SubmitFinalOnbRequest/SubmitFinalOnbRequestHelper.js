({
    init : function(component, event, helper) {
        this.validateRequest(component, event, helper);
        /*var action = component.get('c.checkForAttachmentRequired');
        action.setParams({
            onbRequestId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
            	var result = response.getReturnValue();
                console.log('------------------');
                console.log(result);
                if(result === true){
                    this.showToast("Error", "Please upload Proof of AUM or Audit Financial Statement", "error", "dismissible", null, 2000);
                	let navService = component.find("navService");
                    console.log("2");
                    // Get the output variables and iterate over them
                    let pageReference = {    
                        "type": "standard__recordPage",
                        "attributes": {
                            "recordId": component.get("v.recordId"),
                            "objectApiName": "Onboarding_Request__c",
                            "actionName": "view"
                        }
                    };
                    console.log("3");
                    navService.navigate(pageReference);
                }
                else{
                    helper.createPDF(component, helper, event);
                }
                
            }
        });
        $A.enqueueAction(action);*/
         
    },

    createPDF : function(component, event, helper){
    	let action = component.get("c.createFileAndSendEmail");
        // to server side function 
        action.setParams({"recordId":component.get("v.recordId")});
        //set callback   
        action.setCallback(this, function(response) {
            if(response.getState()==="SUCCESS") {
                var result = response.getReturnValue();
                console.log('----result---' + result);
                if(result === 'generateProspectFenergoAccPDF')
                    this.showToast("Success", "File Created", "success", "dismissible", null, 2000);
                else if(result === 'generateLegacyAccPDF')
                    this.showToast("Success", "Case PDF Generated and sent to Ops team", "success", "dismissible", null, 2000);
                else if(result == 'PDFGenerateFail')
                    this.showToast("Error", "PDF Generation Failed due to some error", "error", "dismissible", null, 2000);
                else if(result == 'MailSentFail')
                this.showToast("Error", "Mail was not sent to Ops team due to technical error", "error", "dismissible", null, 2000);
            }
            this.refreshPage(component, event);
        });
        $A.enqueueAction(action);
	},
    
    validateRequest : function (component, event, helper) {
        var action = component.get('c.validateOnboardingRequest');
        action.setParams({
            onbRequestId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.createPDF(component, helper, event);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showToast("Error", errors[0].message, "error", "dismissible", null, 5000);
                        console.log("Error message: " + errors[0].message);
                        this.refreshPage(component, event);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    showToast : function(title, message, type, mode, key, duration) {
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
    
    refreshPage : function(component, event) {
        let navService = component.find("navService");
        // Get the output variables and iterate over them
        let pageReference = {    
            "type": "standard__recordPage",
            "attributes": {
                "recordId": component.get("v.recordId"),
                "objectApiName": "Onboarding_Request__c",
                "actionName": "view"
            }
        };
        navService.navigate(pageReference);
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
})