({
    doInit : function(component, event, helper) {
        helper.loadCoverageNContact(component);
    },
    addContact : function(component, event, helper){
        helper.addContactToCoverageNContact(component); 
    },
     Cancel : function(component, event, helper){
        var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
    	dismissActionPanel.fire(); 
    }
    
})