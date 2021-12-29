({
    init : function(component, event, helper) {
        console.log('Combobox init');
        var preSelectedId = component.get("v.preSelectedId");
        console.log('preSelectedId: ' + preSelectedId);
	
        helper.initialiseComponent(component); 
        component.set("v.disabled", true); 
    }, 
    OnDivEnter : function(component, event, helper) {
        component.set("v.isUserScrolled", true);
        console.log('div mouse entered');       
    },
    OnDivleave : function(component, event, helper) {
        component.set("v.isUserScrolled", false);
        console.log('div mouse left');        
    },
    reinitialise : function(component, event, helper) {
        console.log('Combobox reinitialise');
        var preSelectedId = component.get("v.preSelectedId");
        console.log('reinitialise preSelectedId: ' + preSelectedId);
        if(preSelectedId != undefined && preSelectedId.length > 0){
            helper.preselectLookup(component);
        }else{
            helper.initialiseComponent(component); 
        }        
    },
  
    
    /**
     * Search an SObject for a match
     */
    search : function(component, event, helper) {
       // alert('searching');
        helper.search(component);
    },
 
    /**
     * Select an SObject from a list
     */
    select: function(component, event, helper) {
        helper.handleSelection(component, event);
    },
     
    /**
     * Clear the currently selected SObject
     */
    clear: function(component, event, helper) {
        
        helper.clearSelection(component, event);
        var showFilterData = component.get('v.showFilterData');
        
        // Basically used for mobile
        var combolistItems = component.find('combolist-items');
        if($A.get("$Browser.formFactor") == 'PHONE' && showFilterData === true)
            $A.util.addClass(combolistItems, 'hideComboboxListItems');
           //$A.util.removeClass(combolistItems, 'hideComboboxListItems');
        //else
           //$A.util.addClass(combolistItems, 'hideComboboxListItems');
            
    },
    
    /**
     * hide popup on blur or lost focus
     */
    hideItems : function(component,event){
        if(!component.get('v.isUserScrolled'))
        {
            window.setTimeout($A.getCallback(function() {
                var lookupList = component.find('comboBox');
                $A.util.removeClass(lookupList, 'slds-is-open');
                
            }), 150); 
        }
    },
    showItems : function(component,event){
        window.setTimeout($A.getCallback(function() {
            component.set("v.showDiv", true);
           var lookupList = component.find('comboBox');
            $A.util.addClass(lookupList, 'slds-is-open');
            var listItems = component.find('combolist-items');
            if( !$A.util.hasClass(listItems, 'overflowScrollbar')){
                $A.util.addClass(listItems, 'overflowScrollbar');
            }
        }), 150); 
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
    }
    
})