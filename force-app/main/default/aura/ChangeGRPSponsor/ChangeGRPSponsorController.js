({
	doInit : function(component, event, helper) {
        ///apex call
        console.log(' Calling getContactInfo');
        console.log(component.find("lookup-sponsor"));
        console.log('Record Id: '+component.get('v.recordId'));
        helper.getContactInfo(component);  
    },
    
    getSponsorIdt
    : function(component, event, helper) {
        helper.getSponsorId(component);
    },
    
    doApplySponsor:  function(component, event, helper) { 
        console.log("Length of events parameter :: "+event.getParam("values").length);
         console.log(component.find("lookup-sponsor"));
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
            component.find("lookup-sponsor").reset();
            component.set("v.selectedLookupId", '');
            var a = component.get('c.doInit');
            $A.enqueueAction(a);
        }
        
	},
    
    doSaveContact: function (component, event, helper) { 
        var grpAccess = component.get("v.isGRPAccess");
        var selectedContactSponsor = component.get("v.selectedLookupId");

        //If GRP Access is present then sponsor should be mandatory
        if(grpAccess == true && (selectedContactSponsor == undefined || selectedContactSponsor == null || selectedContactSponsor == '')){
            component.showMessage("Error", "Sponsor is required if GRP Access is granted" , "error");
        }
        else {
            helper.doSaveContact(component);
        }
        
    },

    cancel : function(component, event, helper){
        helper.dismissComponent();
    },

    showMessage : function(component, event, helper){
        var params = event.getParam('arguments');
        if(params){
             var resultsToast = $A.get("e.force:showToast");
             resultsToast.setParams({
                 "title": params.title,
                 "message": params.message,
                 "type": params.type
             });
             resultsToast.fire();
        }
    }
})