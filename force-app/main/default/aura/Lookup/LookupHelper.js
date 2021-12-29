({
    
    preSelectlookup: function(cmp,event) {
        if(!$A.util.isUndefinedOrNull(lookup_util))
        lookup_util.preSelectlookup(cmp,event,true);
        var c = cmp.get("v.showMetadata");
        },
    
    /**
     * Perform the SObject search via an Apex Controller
     */
    doSearch : function(cmp,event) {
        if(!$A.util.isUndefinedOrNull(lookup_util))
            lookup_util.doSearch(cmp,event,true);
    },
    
    /**
     * Handle the Selection of an Item
     */
    handleSelection : function(cmp, event) {
        if(!$A.util.isUndefinedOrNull(lookup_util))
       lookup_util.handleSelection(cmp,event,true);
    },
    
    /**
     * Clear the Selection
     */
    clearSelection : function(cmp,event) {
        if(!$A.util.isUndefinedOrNull(lookup_util))
        lookup_util.clearSelection(cmp,event,true);
    },
    
    
    searchrecentlyviewed : function(cmp){
        if(!$A.util.isUndefinedOrNull(lookup_util))
        {
            console.log(cmp.get("v.sObjectAPIName"));
            if(cmp.get("v.sObjectAPIName")!='Sales_Team_for_Coverage__c')
            lookup_util.getRecentlyViewed(cmp,true);
            var lookupList = cmp.find("lookuplist");
            $A.util.removeClass(lookupList, 'slds-hide');
        }
        var c = cmp.get("v.showMetadata");
    }
})