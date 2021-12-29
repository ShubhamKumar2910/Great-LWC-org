({
	doInit: function(component, event, helper){
        console.log('in doInit @@@@@@@@@@ ');
        helper.initializeLabels(component);
        helper.getResearchDetails(component);
    },
    
    openLink : function(component, event){
        var params = event.getParam('arguments');
        if(params){
            var strURL = params.strURL;
            if(strURL != null){
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": strURL
                });
                urlEvent.fire();
            }
        }
    },
    
    openRschReadership : function(component,event,helper){
        component.openLink(component.get("v.researchDetails.researchReadershipLink"));
	},
    
    openRschSubscription : function(component,event,helper){
        component.openLink(component.get("v.researchDetails.researchSubscriptionLink"));
	},
    
    openResendGRPIdAndPassword : function(component,event,helper){
        component.openLink(component.get("v.researchDetails.resendGRPIdAndPasswordLink"));
	},
    
    
})