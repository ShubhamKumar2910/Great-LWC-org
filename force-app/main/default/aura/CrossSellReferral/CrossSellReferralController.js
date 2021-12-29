({
    doInit : function (component, event, helper) {

        var myPageRef = component.get("v.pageReference");
        if(myPageRef != undefined && myPageRef != null){
            var entityName = myPageRef.state.c__entityApiName;
            var recordName = myPageRef.state.c__recordTypeName;
            var defaultVal = myPageRef.state.c__defaultValueStr;
            if(entityName != undefined && entityName != null && recordName != undefined && recordName != null){
                component.set("v.entityApiName",entityName);
                component.set("v.recordTypeName",recordName);
                if(defaultVal != undefined && defaultVal != null){
                    component.set("v.defaultValueStr",defaultVal);
                }
            }
        }

        helper.fetchRecordTypeId(component);        
    }
})