({
    doInit : function(component, event, helper) {
    	
        component.set('v.device', $A.get("$Browser.formFactor"));
        console.log(component.get('v.device'));
        
        var recordId = component.get("v.recordId");
        console.log('recordId + ' + recordId);
        //Fetch Account Record
        var action = component.get("c.getTaskByEventId");

        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.tasks", response.getReturnValue());
            }
        });
	 	$A.enqueueAction(action);

        helper.initialiseBaseURL(component);
    },
    
    createTask : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var standardRecordType;
        var action = component.get("c.getStandardRecordType");

        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                standardRecordType = result.Id;
            }
        });
        $A.enqueueAction(action);
        
        helper.getEvent(component, standardRecordType);

              
    },

    createFollowUpReferralTask : function(component, event, helper){
        var recordId = component.get("v.recordId");
        var referralRecordType;
        var action = component.get("c.getReferralRecordType");

        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                referralRecordType = result.Id;
                console.log('referral: ' + referralRecordType);

                helper.getEvent(component, referralRecordType);'';
            }
        });
        $A.enqueueAction(action);

        
    },
    
     editTask : function(component, event) {
     
        var btnClicked = event.getSource();
        var lineItemId = btnClicked.get("v.buttonTitle");
		
        //If SF1, go to standard edit screen
        var navEvt = $A.get("e.force:editRecord ");
        navEvt.setParams({
            "recordId": lineItemId
        });
        navEvt.fire();    
    },

    viewTask : function(component, event, helper) {
        var url = event.srcElement.dataset.url; 
        console.log(url);
        
        
        
        if(component.get('v.device') === "DESKTOP"){
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
              "url": '/' + url
            });  
            console.log(urlEvent.getParams("v.value"));
            urlEvent.fire();        
        }
        else
       		sforce.one.navigateToSObject(url);
       
        
     }




    
    
})