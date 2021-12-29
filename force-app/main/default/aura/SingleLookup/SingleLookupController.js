({
    
    scriptsLoaded : function(component, event, helper) {
		component.reset();
        helper.preSelectlookup(component,event);
        console.log('Lookup preselect initialised');
	},
    
    preSelectlookupValues : function(component, event, helper) {
        console.log('Lookup method call');
        helper.preSelectlookup(component,event);
        
    },
      
    /*
     * Search an SObject for a match
     */
    search : function(cmp, event, helper) {
        if(cmp.get("v.items").length == 0)
        helper.doSearch(cmp,event);
		        
    },
 
    /**
     * Select an SObject from a list
     */
    select: function(cmp, event, helper) {
        helper.handleSelection(cmp, event);
    },
     
    /**
     * Clear the currently selected SObject
     */
    clear: function(cmp, event, helper) {
        helper.clearSelection(cmp,event);    
    },
    /**
     * Get recently viewed
     */
    getRecentlyViewed : function(cmp,event,helper){
        if(cmp.get("v.items").length == 0 && cmp.get("v.showRecentlyView"))
            helper.searchrecentlyviewed(cmp);
    },
    
    hideLookupList : function(component, event, helper)
    {
    	console.log("c.SingleLookup.SingleLookupController.hideLookupList()");
    	helper.hideLookupRsltList(component, event, helper, false);
    
        //window.setTimeout($A.getCallback(function() {
        //    $A.util.removeClass(cmp.find('toggler'),'slds-is-open');
        //}), 150);
    },
    
    reset : function(cmp,event)
    {
        console.log('Reset called.');
        // Create the ClearLookupId event
        var clearEvent = cmp.getEvent("clearLookupIdEvent");
        
        // Fire the event
        clearEvent.fire();
		cmp.set("v.items",new Array());
        cmp.set("v.objectIds",new Array());
        cmp.set("v.emails",new Array());
        cmp.set("v.disabled",false);
        cmp.set("v.searchString","");
        $A.util.removeClass(cmp.find("lookup"), 'input--numberfield');
        if(!$A.util.isUndefinedOrNull(cmp.get("v.tempplaceholder")))
        { 
            if(cmp.get("v.tempplaceholder")!='')
            {
                cmp.set("v.placeholder",cmp.get("v.tempplaceholder"));
                cmp.set("v.tempplaceholder","");
            }
            
        }
        
    },
    
    onClickClose : function(component, event, helper) {
    	console.log("c.SingleLookup.SingleLookupController.onClickClose()");
    	helper.hideLookupRsltList(component, event, helper, true);
    }
})