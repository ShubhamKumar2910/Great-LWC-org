({
    startOnboardingFlow : function(component, accountId, obReqId, notificationViewedByUser){
        var isEdit = component.get('v.isEdit');
        var flow = component.find("onboardingFlow");
        var notificationViewed = notificationViewedByUser === true ? notificationViewedByUser : false;
        // In that component, start your flow. Reference the flow's Unique Name.
        var inputVars = [
                {
                    name : 'AccountRecordId',
                    type : 'String',
                    value : accountId
                },
                {
                    name : 'isEdit',
                    type : 'Boolean',
                    value : isEdit
                },
            	{
                    name : 'CurrentOnboardingRequestId',
                    type : 'String',
                    value : obReqId
                },
            	{
                    name : 'ExistingReqNotificationViewedByUser', 
                    type : 'Boolean',
                    value : notificationViewed
                }
            ]; 
            flow.startFlow("Client_Onboarding", inputVars);
    },
    
    resumeOnboardingFlow : function(component, pausedInterviewID) {
        var flow = component.find("onboardingFlow");
        flow.resumeFlow(pausedInterviewID);
    },


    /*startEnrichmentFlow : function(component, recordId){
        var isEdit = component.get('v.isEdit');
        var flow = component.find("onboardingFlow");
        // In that component, start your flow. Reference the flow's Unique Name.       
        var inputVars = [
                {
                    name : 'OnboardingRequestId',
                    type : 'String',
                    value : recordId
                },
                {
                    name : 'isEdit',
                    type : 'Boolean',
                    value : isEdit
                }
            ]; 
            flow.startFlow("Enrichment_Flow", inputVars);
    },*/

    checkOnboardingStatus : function(component, obReqId){
        var isEdit = component.get('v.isEdit');
        var action = component.get('c.getOnboardingStatus');
            action.setParams({
                "recordId" : obReqId
            });

            action.setCallback(this, function(response){
                
                if(response.getState() === "SUCCESS"){
                    var result = response.getReturnValue();
                    
                    component.set("v.RequestDetails", result);
                    var requestD = component.get("v.RequestDetails");
                    //console.log(requestD);
                    //console.log(requestD.status);
                    var status = requestD.status;
                    var subStatus = requestD.subStatus;
                    
                    if(status == 'Draft') {
                        this.resumeOrStartOnboardingFlow(component, obReqId);
                    }
                    
                    /*if( (status == 'Enrichment' && (subStatus == 'Enrichment' || subStatus == 'Regional TopUp' || subStatus == 'Success')) 
                        || (status == 'Sent' || status == 'Submitted')) {
                        this.startEnrichmentFlow(component, obReqId, isEdit);
                    }
                    else if(status == 'Draft' || status == 'Desk Head Approval' || status == 'Sales CAO Approval'){
                        this.startOnboardingFlow(component, '', obReqId);
                    }  */
                }
            });
        	component.set('v.navigateToRecordId', obReqId);
            $A.enqueueAction(action);
    },

    getNewlyCreatedOnboardingRecordIdbyUser : function(component, event, helper){
        var action = component.get('c.getNewlyCreatedOnboardingRecordIdbyUser');
        action.setCallback(this, function(response){
             if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                console.log('--result--', result);
             	component.set('v.navigateToRecordId', result);
                component.navigateToRecord(component, event, helper);
             }
        });
         $A.enqueueAction(action);
    },
    
    resumeOrStartOnboardingFlow : function(component, obReqId) {
        var action = component.get('c.getInterviewsForRecord');
        action.setParams({
            "recordId" : obReqId
        });        
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS") {
                var pausedInterviewId = response.getReturnValue();
                if (pausedInterviewId && pausedInterviewId !== null && pausedInterviewId !== undefined && pausedInterviewId !== '') {
                    this.resumeOnboardingFlow(component, pausedInterviewId);
                } else {
                    this.startOnboardingFlow(component, '', obReqId, true);
                }
            } else if (response.getState() === "ERROR") {                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("ERROR Retrieving Paused Flow Interview ID : ", errors[0].message);
                    }
                } else {
                    console.log("Unknown error occured when retrieving Paused Flow Interview ID");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    hideOrShowExistingReqNotification : function(component, displayNotification) {
        if (displayNotification === true) {
            component.set("v.displayExistingDraftNotification", true);
            component.set("v.displayNotificationButtons", true);        
        } else {
            component.set("v.displayExistingDraftNotification", false);
            component.set("v.displayNotificationButtons", false);  
        }
    }
    
})