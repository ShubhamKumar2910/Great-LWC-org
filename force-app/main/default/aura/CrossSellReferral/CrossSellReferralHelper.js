({
    fetchRecordTypeId: function(component){
        var action = component.get("c.getRecordTypeId");
        action.setParams({
            "objectName":component.get('v.entityApiName'),
            "recordTypeName":component.get('v.recordTypeName')
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var recordTypeId = response.getReturnValue();                
                var defaultValueJson = JSON.parse(component.get('v.defaultValueStr'))
                var createRecordEvent = $A.get("e.force:createRecord");

                createRecordEvent.setParams({
                    "entityApiName": component.get('v.entityApiName'),
                    "recordTypeId": recordTypeId,
                    "defaultFieldValues": defaultValueJson
                });
                createRecordEvent.fire();        
            }
        });

        component.find("navService").navigate({
            "type": "standard__namedPage",
            "attributes": {
                "pageName": "home"
            }                
        });

        $A.enqueueAction(action);
    }
})