({
	getEvent : function(component, recordType){
        var recordId = component.get("v.recordId");
        var action = component.get("c.getEventDetails");
        
        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                component.set("v.parentEvent", result);
                var parentEvent = component.get("v.parentEvent");
                parentEvent.sobjectType = 'Event';
                console.log('recordType ' + recordType);
                console.log('whoid' + parentEvent.WhoId);   
                var subject = "Follow Up Task:" + parentEvent.Subject;

                var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams({
                    "entityApiName": "Task", 
                    "recordTypeId" : recordType,
                    "defaultFieldValues" : {
                        "Subject" : subject,
                        "WhoId" : parentEvent.WhoId,
                        "WhatId" : parentEvent.WhatId,
                        "Description" : parentEvent.Description,
                        "Parent_Event_Id__c" : parentEvent.Id,
                        "Parent_Event_Subject__c" : parentEvent.Subject
                    }
                });
                createRecordEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

})