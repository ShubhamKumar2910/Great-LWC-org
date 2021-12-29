({
    openPendingApprovals : function(component,event,helper){
        /*var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:BulkApproval",
            componentAttributes: {
                isApproval : 'true'
                
            }
        });
        evt.fire();
        */
        component.find("navService").navigate({
            "type": "standard__navItemPage",
            "attributes": {
                "apiName" : "Items_to_ApproveDesktop" 
            },
            "state":{
                "c__isApproval" : 'true'
            }
        }, false);
        var utilityAPI = component.find("utilitybar");
        utilityAPI.minimizeUtility();
    }, 
    
    onCometdLoaded : function(component, event, helper) {
        var cometd = new org.cometd.CometD();
        component.set('v.cometd', cometd);
    },
    
    init : function(component,event,helper){
        var action = component.get('c.getSessionAndSubscriptionDtls');
        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                component.set('v.UsrAndSubscriptionDtls', response.getReturnValue());
                if(component.get('v.UsrAndSubscriptionDtls').OrgEventSubscriptionEnabled){
                    if(component.get('v.UsrAndSubscriptionDtls').UserEventSubscriptionEnabled){
                        component.set('v.sessionId',component.get('v.UsrAndSubscriptionDtls').SessionId);
                        if (component.get('v.cometd') != null){
                            helper.connectCometd(component);
                        }
                    }
                }
                
            }
            else
                console.error(response);
        });
        $A.enqueueAction(action);        
    },

    onApprovalsCountScriptLoaded : function(component){        
        if(!$A.util.isUndefinedOrNull(approvalsCount)){
            //Re-Render will be called after scripts are loaded and displayUtilityBar is called to display total count
            approvalsCount.getPendingApprovals(component);
            component.set('v.scriptsLoaded', true);
            
        }
        
    },

    displayUtilityBar : function(component){
        
        var approvalJson = component.get('v.approvalCountJson');     
        var totalApprovalsCount = JSON.parse(approvalJson).totalApprovalsCount;
       
        if(totalApprovalsCount == 0){
            component.set('v.messageText','Nothing to Approve for now.');
            component.set('v.showApprovalButton',false);
            component.set('v.ApprovalCount','0');
            var utilityAPI = component.find("utilitybar");                    
            utilityAPI.getAllUtilityInfo().then(function(response) {   
                var myUtilityInfo = response[0];                        
                utilityAPI.setUtilityHighlighted({highlighted : false, utilityId : myUtilityInfo.id});
                utilityAPI.setUtilityLabel({label : $A.get("$Label.c.APPROVAL_Message") + totalApprovalsCount , utilityId : myUtilityInfo.id});
                
            });
        }        
        else
        {
            component.set('v.messageText',  $A.get("$Label.c.APPROVAL_Message") + totalApprovalsCount ); 
            component.set('v.showApprovalButton',true);                    
            var utilityAPI = component.find("utilitybar");                    
            utilityAPI.getAllUtilityInfo().then(function(response) {                        
                var myUtilityInfo = response[0];                        
                utilityAPI.setUtilityHighlighted({highlighted : true, utilityId : myUtilityInfo.id});
                utilityAPI.setUtilityLabel({label : $A.get("$Label.c.APPROVAL_Message") + totalApprovalsCount , utilityId : myUtilityInfo.id});
                
            });
            
        }
    },
})