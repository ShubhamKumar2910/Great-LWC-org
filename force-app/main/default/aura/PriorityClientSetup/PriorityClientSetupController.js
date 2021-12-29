({
	// component init event handler
	init: function(component, event, helper) {
		console.log("#### c:PK_Test.init()");
		helper.init(component, event, helper);
    },
    
    handleRowAction : function (component, event, helper) {
        helper.handleRowAction(component, event, helper); 
    }, 
    
    handleSave : function (component, event, helper) {
    	helper.handleSave(component, event, helper);
    }, 
    
    closeModal : function(component, event, helper) {
    	helper.closeBrowseContactScreen(component, event, helper);
    },
    
    updateContact : function(component, event, helper) {
    	helper.updateContact(component, event, helper);
    }
})