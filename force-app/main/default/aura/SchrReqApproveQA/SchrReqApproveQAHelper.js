({
    init : function(component, event, helper) {
        console.log('#### SchrReqApproveQAHelper::init()');
        // Find the component whose aura:id is "flowData"
        let flow = component.find("flowData");
        // In that component, start your flow. Reference the flow's API Name.
        let inputVariables = [ 
            { name : "recordId", type : "String", value: component.get("v.recordId")},
            { name : "actionPerformed", type : "String", value: "SCH_REQ_APPROVE"}
        ]; 
        flow.startFlow("SCH_Request_Bulk_Update_Flow", inputVariables);
    },

    handleStatusChange : function(component, event, helper) {
        console.log('#### SchrReqApproveQAHelper::handleStatusChange()');
        if(event.getParam("status") === "FINISHED") {
            console.log("1");
            let navService = component.find("navService");
            console.log("2");
            // Get the output variables and iterate over them
            let pageReference = {    
                "type": "standard__recordPage",
                "attributes": {
                    "recordId": component.get("v.recordId"),
                    "objectApiName": "SCH_Request__c",
                    "actionName": "view"
                }
            };
            navService.navigate(pageReference);
        }
    },
})