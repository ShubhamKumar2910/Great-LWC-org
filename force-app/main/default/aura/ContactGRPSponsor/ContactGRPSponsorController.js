({
	doInit : function(component, event, helper) {
        ///apex call
        console.log(' Calling getContactInfo');
        console.log(component.find("lookup-contact"));
        console.log('Record Id: '+component.get('v.recordId'));
        helper.getContactInfo(component);  
	},
    
    getSponsorIdt
    : function(component, event, helper) {
        helper.getSponsorId(component);
    },
    
    doApplySponsor:  function(component, event, helper) { 
        console.log("Length of events parameter :: "+event.getParam("values").length);
         console.log(component.find("lookup-contact"));
        console.log("events parameter :: "+event.getParam("values"));
        if(event.getParam("values").length == 1)
        {
            component.set("v.selectedLookupId", event.getParam("values")[0]);
            console.log("Selected Id is :: "+event.getParam("values"));
            console.log('In child component');
            console.log('Selected Id is : '+component.get("v.selectedLookupId"));
            helper.doApplySponsor(component);
        }
        else
        {
             component.find("lookup-contact").reset();
            var a = component.get('c.doInit');
            $A.enqueueAction(a);
        }
        
	} ,
    
    doSaveContact: function (component, event, helper) { 
    	helper.doSaveContact(component);
    },

})