({
    initialize : function(component, event, helper) {
        
        var now = new Date();
        component.set("v.now",$A.localizationService.formatDate(now, "MMM dd yyyy, hh:mm:ss a"));
        
        var recordId = 'none';
        var objectApiName = 'none';

        var pageRef = component.get("v.pageReference");
        if(!$A.util.isEmpty(pageRef))
        {
            if(pageRef.state.c__recordId)
            {
                recordId = pageRef.state.c__recordId;
            }
            if(pageRef.state.c__objectApiName)
            {
                objectApiName = pageRef.state.c__objectApiName;
                //Workaround to call @api set ObjectApiNameParam when same Object is called back to back
                component.set("v.objectApiName", "none");
            }
        }

        component.set("v.recordId", recordId);
        component.set("v.objectApiName", objectApiName);
    }
})