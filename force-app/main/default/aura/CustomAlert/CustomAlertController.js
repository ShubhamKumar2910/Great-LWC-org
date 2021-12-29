({
    closeAlert : function(component, event, helper) {
        
        var cmpSuccess = component.find('successMsg');
        var cmpError = component.find('errorMsg');
        var cmpWarning = component.find('warningMsg');
        var cmpInfo = component.find('infoMsg');
        
        var ctarget = event.currentTarget;
        var messageType = ctarget.dataset.value;
        if(messageType == "success")
            $A.util.addClass(cmpSuccess, 'slds-hide');
        else if(messageType == "error")
            $A.util.addClass(cmpError, 'slds-hide');
            else if(messageType == "info")
                $A.util.addClass(cmpWarning, 'slds-hide');
                else if(messageType == "warning")
                    $A.util.addClass(cmpInfo, 'slds-hide');
        
    }
})