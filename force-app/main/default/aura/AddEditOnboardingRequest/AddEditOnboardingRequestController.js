({
    init : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        //check from where  record is initiated
        if(recordId == null || recordId == 'unassigned'){
            //initiated from home page. Start Onboarding Flow
            component.getOnbReqDetails(function(result) {
                component.set('v.isEdit', false);
                helper.startOnboardingFlow(component, '', result.dummyRequestId, false);
            });
        }
        else if(recordId.startsWith('001')){
            //initiated from Account page
            component.getOnbReqDetails(function(result) {
                component.set('v.isEdit', false);
                if (result.draftRequestExistsForRM) {
                    component.set("v.accountName", result.accountName);
                    helper.hideOrShowExistingReqNotification(component, true);
                } else {
                    helper.hideOrShowExistingReqNotification(component, false);
                    helper.startOnboardingFlow(component, recordId, result.dummyRequestId, false);
                }
            });  
        }
        else{
            //initiated from Onboarding Request page
            component.set('v.isEdit', true);
            helper.checkOnboardingStatus(component, recordId);
        }
    },

    handleStatusChange : function(component, event, helper){
  		var isEdit = component.get('v.isEdit');
        if(event.getParam("status") === "FINISHED" || event.getParam("status") === "WAITING") {          
            /*if(!isEdit){
                helper.getNewlyCreatedOnboardingRecordIdbyUser(component, event, helper);
            }
            else*/
            component.navigateToRecord(component, event, helper);
        }
    },

    navigateToRecord : function(component, event, helper){
        var urlEvent = $A.get("e.force:navigateToSObject");
            urlEvent.setParams({
                "recordId": component.get("v.navigateToRecordId"),
                "isredirect": "true"
            });
            urlEvent.fire();
    },
    
    getOnbReqDetails : function(component, event, helper) {
        var params = event.getParam('arguments');
        var callback;
        if (params) {
            callback = params.callback;
        }
        var action = component.get('c.getOnboardingRequestDetails');
        action.setParams({
            "recordId" : component.get('v.recordId')
        });  
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS") {
                let data = response.getReturnValue();
                if (callback && data && data !== null && data !== undefined && data.dummyRequestId) {
                    component.set('v.navigateToRecordId', data.dummyRequestId);
                    callback(data);
                }
            }                 
        });
        $A.enqueueAction(action);
    },
    
    handleExistingObReqNotificationEvent : function(component, event, helper) {
        let continueButtonClicked = event.getParam("continueBtnClicked");
        let cancelButtonClicked = event.getParam("cancelBtnClicked");  
        
        let accId = component.get('v.recordId');
        
        if (cancelButtonClicked === true) {
            component.set('v.navigateToRecordId', accId);
            component.navigateToRecord(component, event, helper);
        } else if (continueButtonClicked === true) { 
            helper.startOnboardingFlow(component, accId, component.get('v.navigateToRecordId'), true);
        }
        
        helper.hideOrShowExistingReqNotification(component, false);
    },
})