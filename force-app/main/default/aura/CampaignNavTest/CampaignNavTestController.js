({
    init : function(component, event, helper) {
        
        helper.init(component, event, helper);
    }

    /*addContacts : function(component, event, helper) {
        console.log('addContacts');
        let navService = component.find("navService");
        console.log("2");
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
        console.log("3");
        navService.navigate(pageReference);
    }*/
})