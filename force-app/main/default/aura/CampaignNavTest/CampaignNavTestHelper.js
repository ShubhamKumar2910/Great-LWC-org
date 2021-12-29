({
    init : function(component, event, helper) {        
        let action = component.get("c.getReqDetails");
        // to server side function 
        action.setParams({"recordId":component.get("v.recordId")});
        //set callback   
        action.setCallback(this, function(response) {
            if(response.getState()==="SUCCESS") {
                let obReq = response.getReturnValue();
                if(!$A.util.isEmpty(obReq)) {
                    component.set("v.campaignId", obReq.Campaign__c);
                    let navService = component.find("navService");
                    // Get the output variables and iterate over them
                    let pageReference = {    
                        "type": "standard__recordRelationshipPage",
                        "attributes": {
                            "recordId": component.get("v.campaignId"),
                            "objectApiName": "Campaign",
                            "relationshipApiName":"CampaignMembers",
                            "actionName": "view"
                        }
                    };
                    navService.navigate(pageReference);
                } else {
                    $A.get("e.force:closeQuickAction").fire();
                    this.showToast("Cant Add or Update Contacts", 'To modify the Contact list the request must be in Draft stage', "error", "dismissible", null, 10000);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    showToast : function(title, message, type, mode, key, duration) {
        var toastEvent = $A.get("e.force:showToast");
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
})