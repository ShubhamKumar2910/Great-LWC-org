({
	rerender : function(component, helper){
        this.superRerender();

        console.log('inrerender ' +component.get("v.needToProcessReRenderLogic"));
        console.log(component.get("v.isClientMemo"));
        
        if(component.get("v.areJSScriptsLoaded") && component.get("v.needToProcessReRenderLogic")) {
            //your logics

            helper.isCapIntroUser(component) ;  
            var callingComponent = component.get("v.calledFrom");
            var myContactListSelect = component.get("v.myContactListSelect");
             console.log('ClientAttendees 1 **'+ component.get("v.ClientAttendees"));
	         console.log('callingComponent **'+ callingComponent);
             console.log('myContactListSelect **'+ myContactListSelect);             
	         console.log(event);
	         if(callingComponent == 'Home' || (myContactListSelect == undefined || myContactListSelect == '')){
	             component.callReportView(component, event, helper);
	             component.set("v.massActivityFlag", false);  
                 
	         }
	         else{
	            component.massActivityView(component, event, helper); 
	            component.set("v.massActivityFlag", true);
	         }
	        helper.hideSpinner(component);
            //helper.initialiseUserType(component,helper);
            helper.getUserDetails(component, helper);
	        helper.initialiseEventLabels(component);	        
            helper.initialiseCIStages(component);
            //helper.checkCurrentUserSettings(component);
	        helper.initialiseInternalInvitees(component);
            helper.initialiseDetailedDescription(component);  
            //Added for JIRA SALES-3521
            helper.initialisePositionValues(component);  
            console.log('myContactListSelect 2 **'+ component.get("v.myContactListSelect"));
            console.log('ClientAttendees 2 **'+ component.get("v.ClientAttendees"));
            component.set("v.needToProcessReRenderLogic",false); // this will not fire rerender again   
            console.log(component.get('v.profile'));
            //Added for JIRA SALES-3510
            helper.getObjectiveMandatory(component,helper); 
            //Calling Activity Flag Statuses
            helper.initialiseActivityStatus(component); 
        }
    },
    afterRender: function (component, helper) {
        var afterRend = this.superAfterRender();
    
        
        return afterRend;
	}
})