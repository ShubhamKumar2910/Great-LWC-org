({
    doInit : function(component, event, helper) {
        helper.loadData(component);
    },
    approve : function(component, event, helper) {
        var ctarget = event.currentTarget;
        var selectedId = ctarget.dataset.value;
        helper.ApproveSelectedRequests(component,event,selectedId);
    },
    reject : function(component, event, helper) {
        var ctarget = event.currentTarget;
        var selectedId = ctarget.dataset.value;
        helper.RejectSelectedRequests(component,event,selectedId);
    },
    showSpinner : function(component,event) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },
    hideSpinner : function(component,event) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.addClass(cmpTarget, 'slds-hide');
    },
    showToast : function(component, event, helper) {
        var params = event.getParam('arguments');
        if(params)
        {
            var title = params.title;
            var type = params.type;
            var message = params.message;
            var mode = params.mode;
            var key = params.key;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "type": type,
                "message": message,
                "mode": mode,
                "key": key
            });
            toastEvent.fire();
        }
    },
    onCustomSort :function(component,event,helper) {
        if(event.getParam("itemdata").length >= 1)
        {
            console.log('sorted data (parent): ');
            console.log(event.getParam("itemdata"));
            component.set("v.items",event.getParam("itemdata"));
        }
    },
    sort : function(component,event) {
        var sortItems = component.find("sortItems");
        console.log(sortItems);
        $A.util.toggleClass(sortItems, 'slds-is-open');
        //helper.sortData(component, fieldName, sortDirection)
        //var cmpTarget = event.getSource();
        //$A.util.addClass(cmpTarget, 'slds-is-selected');
    },
    hideSortItems : function(component,event)
    {
        window.setTimeout($A.getCallback(function() {
            var sortItems = component.find("sortItems");
            $A.util.removeClass(sortItems, 'slds-is-open');
        }), 150);   
    },
    showfilter : function(component,event) {
        var sortItems = component.find("sortItems");
        $A.util.removeClass(sortItems, 'slds-is-open');
        //var cmpTarget = event.getSource();
        //$A.util.addClass(cmpTarget, 'slds-is-selected');
    },
    
})