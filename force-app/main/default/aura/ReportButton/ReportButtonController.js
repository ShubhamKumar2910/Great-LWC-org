({
    doInit : function(component, event, helper) {
        helper.getReportDetails(component);
    },

    navigateToReport : function(component, event, helper) {
        var reportId = component.get("v.reportId");
        var selectedRecordId = component.get("v.recordId");
                    
        if(selectedRecordId != undefined && selectedRecordId != null &&
           reportId != undefined && reportId != null)
        {
            var customizedRecordId = selectedRecordId.substring(0,15);
            var reportURL = "/one/one.app#/sObject/" + reportId + "/view?fv0=" + customizedRecordId;
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": reportURL,
                "isredirect ":true
            });
            urlEvent.fire();
        }
    }
})