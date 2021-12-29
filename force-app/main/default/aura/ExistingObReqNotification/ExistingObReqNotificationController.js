({
    handleButtonClick : function(component, event, helper) {
        let buttonClicked = event.getSource().getLocalId();
        
        if (buttonClicked) {
            let cmpEvent = component.getEvent("existingObReqNotificationEvent");
            if (buttonClicked === 'cancelBtn') {
                cmpEvent.setParams({
                    "continueBtnClicked" : false,
                    "cancelBtnClicked" : true
                });
                cmpEvent.fire();
            } else if (buttonClicked === 'continueBtn') {
                cmpEvent.setParams({
                    "continueBtnClicked" : true,
                    "cancelBtnClicked" : false
                });
                cmpEvent.fire();
            }
        }
    },
})