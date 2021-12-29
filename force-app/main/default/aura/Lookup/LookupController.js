({
    scriptsLoaded : function(component, event, helper) {
        helper.preSelectlookup(component,event);
        var c = component.get("v.showMetadata");
        
    },
    preSelectlookupValues : function(component, event, helper) {
        helper.preSelectlookup(component,event);
        var c = component.get("v.showMetadata");
        
    },
    
    /**
     * Search an SObject for a match
     */
    search : function(cmp, event, helper) {
        helper.doSearch(cmp,event);
       
       /* if(event.getParams().keyCode == 13)
        {
        }*/
    },
    
    focusList:function(cmp, event, helper) {
        /* if(event.getParams().keyCode == 40)
         {
         }*/
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
        helper.searchrecentlyviewed(cmp);
    },
    
    /**
     * hide popup on blur or lost focus
     */
    hideLookupList : function(cmp,event)
    {
        var isUserScrolled = cmp.get("v.isUserScrolled");
        if(!isUserScrolled){
            window.setTimeout($A.getCallback(function() {
                var lookupList = cmp.find('lookuplist');
                $A.util.removeClass(lookupList, 'slds-show');
            }), 150); 
        }        
    },
    
    /**
     * Reset Lookup
     */
    reset : function(cmp,event)
    {
        // Create the ClearLookupId event
        var clearEvent = cmp.getEvent("clearLookupIdEvent");
        // Fire the event
        clearEvent.fire();
        if(!$A.util.isUndefinedOrNull(cmp.get("v.items")))
        cmp.get("v.items").length = 0;
        if(!$A.util.isUndefinedOrNull(cmp.get("v.emails")))
        cmp.get("v.emails").length = 0;
        if(!$A.util.isUndefinedOrNull(cmp.get("v.objectIds")))
        cmp.get("v.objectIds").length = 0;
        if(!$A.util.isUndefinedOrNull(cmp.get("v.matches")))
        cmp.get('v.matches').length = 0;
        if(!$A.util.isUndefinedOrNull(cmp.get("v.selmatches")))
        cmp.get('v.selmatches').length = 0;
        var lookupPill = cmp.find("lookup-pill");
        var lookupList = cmp.find('lookuplist');
        $A.util.addClass(lookupPill, 'slds-hide');
        cmp.find("lookup").set("v.errors",null);
        $A.util.removeClass(lookupList, 'slds-show');
        $A.util.removeClass(lookupPill, 'wrapLookupPills');
    }, 

    OnDivEnter : function(cmp, event, helper) {
        cmp.set("v.isUserScrolled", true);
        console.log('div mouse entered');       
    },
    OnDivleave : function(cmp, event, helper) {
        cmp.set("v.isUserScrolled", false);
        console.log('div mouse left');             
    },
    
    
})