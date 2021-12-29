({
    
    preSelectlookup: function(cmp,event) {
       if(!$A.util.isUndefinedOrNull(lookup_util))
        lookup_util.preSelectlookup(cmp,event,false);
    },
    
    /**
     * Perform the SObject search via an Apex Controller
     */
    doSearch : function(cmp,event) {
       if(!$A.util.isUndefinedOrNull(lookup_util))
        lookup_util.doSearch(cmp,event,false);
    },
    
    /**
     * Handle the Selection of an Item
     */
    handleSelection : function(cmp, event) {
       if(!$A.util.isUndefinedOrNull(lookup_util))
        lookup_util.handleSelection(cmp,event,false);
    },
    
    /**
     * Clear the Selection
     */
    clearSelection : function(cmp,event) {
        if(!$A.util.isUndefinedOrNull(lookup_util))
        lookup_util.clearSelection(cmp,event,false);
    },
    
    
    searchrecentlyviewed : function(cmp){
        console.log("c.SingleLookup.SingleLookupHelper.searchrecentlyviewed()");
        //if(!$A.util.isUndefinedOrNull(lookup_util))
        //lookup_util.getRecentlyViewed(cmp,false);
        
        if(!$A.util.isUndefinedOrNull(lookup_util))
        {
            if(cmp.get("v.sObjectAPIName")!='Sales_Team_for_Coverage__c')
            {
            	var doSearch = true;
            	if($A.get("$Browser.formFactor") === "PHONE" && cmp.get("v.handleHideListOnMobile")===true) {
            		var singlelookup = cmp.find("toggler");
            		if(!$A.util.isEmpty(singlelookup) && $A.util.hasClass(singlelookup, "slds-is-open")) {
            			doSearch=false;
            		}
            	}
            	if(doSearch===true) {
	                lookup_util.getRecentlyViewed(cmp,false);
	                var lookupList = cmp.find("lookuplist");
	                $A.util.removeClass(lookupList, 'slds-hide');
                }
            }
        }
    },
    
    hideLookupRsltList : function(component, event, helper, isCloseClicked) {
    	console.log("c.SingleLookup.SingleLookupHelper.hideLookupRsltList()");
    	if($A.get("$Browser.formFactor")==="PHONE" && component.get("v.handleHideListOnMobile")===true) {
    		if(isCloseClicked===true) {
    			var singlelookup = component.find("toggler");
        		if(!$A.util.isEmpty(singlelookup) && $A.util.hasClass(singlelookup, "slds-is-open")) {
        			console.log("Removing Class");
        			$A.util.removeClass(component.find('toggler'),'slds-is-open');
        		} else {
        			console.log("Empty String");
        			component.set("v.searchString", "");
        		}
    		} /*else if($A.util.isEmpty(component.get("v.searchString"))) {
    			window.setTimeout($A.getCallback(function() {
		            $A.util.removeClass(component.find('toggler'),'slds-is-open');
		        }), 150);
    		}*/
    	} else {
    		if(isCloseClicked===true) {
    			var singlelookup = component.find("toggler");
        		if(!$A.util.isEmpty(singlelookup) && $A.util.hasClass(singlelookup, "slds-is-open")) {
        			$A.util.removeClass(component.find('toggler'),'slds-is-open');
        		} else {
        			component.set("v.searchString", "");
        		}
    		} else {
	    		window.setTimeout($A.getCallback(function() {
		            $A.util.removeClass(component.find('toggler'),'slds-is-open');
		        }), 150);
	        }
        }
    }
})