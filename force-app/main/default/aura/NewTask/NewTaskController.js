({
	init : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        console.log('recordId: ' + recordId);
        var action = component.get("c.getRecTypeId");
        var object = "Task";
        action.setParams({
            "obj": object, 
            "recordTypeName" : "Standard_Task"
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
                var createRecordEvent = $A.get("e.force:createRecord");
                var result = response.getReturnValue();
                console.log('result' + result);
                console.log('recordId' + recordId);
                if(recordId != undefined && recordId.startsWith("003") == true){
                            createRecordEvent.setParams({
                            "entityApiName": object, 
                            "recordTypeId" : result,
                            'defaultFieldValues': {
                                'WhoId': recordId
                                }
                            });
                }else if(recordId != undefined && recordId.startsWith("001") == true){
                            createRecordEvent.setParams({
                            "entityApiName": object, 
                            "recordTypeId" : result,
                            'defaultFieldValues': {
                                'WhatId': recordId,
                                'AccountId' :  recordId
                              } 
                          });
                }else if(recordId != undefined && recordId.startsWith("701") == true){
                            createRecordEvent.setParams({
                            "entityApiName": object, 
                            "recordTypeId" : result,
                            'defaultFieldValues': {
                                'WhatId': recordId,
                            } 
                          });
                }else if(recordId != undefined && recordId.startsWith("006") == true){
                            createRecordEvent.setParams({
                            "entityApiName": object, 
                            "recordTypeId" : result,
                            'defaultFieldValues': {
                                'WhatId': recordId,
                              } 
                          });
                          }
                          else{
                            createRecordEvent.setParams({
                            "entityApiName": object, 
                            "recordTypeId" : result,
                            'defaultFieldValues': {

                              } 
                          });
                          }


             
            createRecordEvent.fire();
          }
        });
        
        $A.enqueueAction(action);    
        
       
        
    }
})