({
    // helper funtion for controller action init()
	initialize : function(component, event, helper) {
		console.log("#### c.MobileHomeHelper.initialize()");
        helper.showSpinner(component, event, helper);
        // call the server side function  
        var action = component.get("c.getMobileHomeMetadata");
        // to server side function 
        action.setParams({});
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState()==="SUCCESS") {
                console.log("c.MobileHomeHelper.initialize() : SUCCESS: "+response.getReturnValue());
                var mobHomePageMdt = response.getReturnValue()
                if(!$A.util.isUndefinedOrNull (mobHomePageMdt)) {
                    if(!$A.util.isEmpty(mobHomePageMdt.MobileHomePageMdtWrapperList)) {
                        component.set("v.metadataList", mobHomePageMdt.MobileHomePageMdtWrapperList);
                    } else {
                        component.set("v.metadataList", []);
                    }
                }
                console.log("v.metadataList : ",component.get("v.metadataList"));
                /*var metadataList = response.getReturnValue();
                console.log("metadataList : ",metadataList);
                if(!$A.util.isEmpty(metadataList)) {
					component.set("v.metadataList", metadataList);
                } else {
                    component.set("v.metadataList", []);
                }
                console.log("v.metadataList : ",component.get("v.metadataList"));*/
            } else if(response.getState()==="ERROR") {
                var errMsg="Unknown error";
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        errMsg=errors[0].message;
                    }
                } 
                console.log("c.MobileHomeHelper.initialize() : Error: "+errMsg);
                helper.showToast(component, event, helper, "Error", errMsg, "error", "sticky", null, 2000);
            }
            helper.hideSpinner(component, event, helper);
        });
        // fire controller action
        $A.enqueueAction(action);
	},

    performAction : function(component, event, helper) {
        console.log("#### c.MobileHomeHelper.performAction()");
        var target = event.getSource(); 
		var btnInfo = target.get("v.name");
        if(!$A.util.isEmpty(btnInfo)) {
            var infoList = btnInfo.split("::::");    
            console.log("infoList ",infoList );
            // Item 0 -> index of button in the list
			// Item 1 -> button developerName in Metadata Type
			// Item 2 -> Navigate_To_Component__c from Metadata Type, and if not null then 
			// 			 fire the event -> NavigateToComponent
			// Item 3 -> Navigate_To_URL__c from Metadata Type, and if not null then 
			// 			 fire the event -> NavigateToURL
            if(!$A.util.isEmpty(infoList) && !$A.util.isEmpty(infoList[2]) && 
               		!$A.util.isEmpty(infoList[3])) {
                var attributes = JSON.parse(infoList[3]);
                var state = {};
                if(infoList.length>=5 && !$A.util.isEmpty(infoList[4])) {
					state=JSON.parse(infoList[4]);
                }
                component.find("navigationService").navigate({
                    "type": infoList[2],
                    "attributes": attributes,
                    "state": state
            	}, false);
            } 
        }
	},
    
    showToast : function(component, event, helper, title, message, type, mode, key, duration) {
        var toastEvent = $A.get("e.force:showToast");
        if(duration) {
            duration=2000;
        }
        toastEvent.setParams({
            "title":title,
            "message":message,
            "type":type,
            "mode":mode,
            "key":key,
            "duration":duration
        });
        toastEvent.fire();
    },
    
    showSpinner : function(component, event, helper) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },
    
    hideSpinner : function(component,event, helper) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.addClass(cmpTarget, 'slds-hide');
    }
})