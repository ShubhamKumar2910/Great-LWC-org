({

    init: function(component, event, helper) {
		        
        //Find if it's new activity or not
        var recordId = component.get("v.recordId");
        var massActivityFlag = component.get("v.massActivityFlag");
        var activityId = component.get("v.activityId");
        var callingComponent = component.get("v.calledFrom");
        console.log(massActivityFlag);
        
        //For creating/updating activity            
        if(massActivityFlag === false && callingComponent !== 'ContactList'){
            //Activity.cmp is not called from Contact List and it is not of type Mass Activity
            component.set("v.activityId", recordId);
            component.set("v.massActivityFlag", false);
        }
        else if(massActivityFlag === true && callingComponent !== 'ContactList'){
            //Activity.cmp is not called from Contact List. Used for updating an MassActivity
            component.set("v.activityId", recordId);
            component.set("v.massActivityFlag", true);
        }            
            else{
               	//Activity.cmp is called from Contact List and it is of type Mass Activity    
                component.set("v.activityId", activityId);
                component.set("v.massActivityFlag", true);
            }        
       
    },
    
})