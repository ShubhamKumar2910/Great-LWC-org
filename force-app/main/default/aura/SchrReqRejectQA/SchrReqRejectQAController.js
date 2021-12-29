({
    init : function(component, event, helper) {
        console.log('#### SchrReqApproveQAController::init()');
        helper.init(component, event, helper);
    },

    handleStatusChange : function(component, event, helper) {
        console.log('#### SchrReqApproveQAController::handleStatusChange()');
        helper.handleStatusChange(component, event, helper);
    }
})