({
    init : function(component, event, helper)
    {
        helper.initialise(component, event);
    }, 

    sourceContactChanged : function(component, event, helper) 
	{
        helper.setSourceContactId(component, event);
        helper.getETradingEnablements(component);
    },

    targetContactChange : function(component, event, helper)
    {
        helper.setTargetContactIds(component, event);
    },

    resetContact : function(component, event, helper)
    {
    	helper.resetETradingEnablements(component, event);
    },

    createNewContact : function(component, event, helper)
    {
    	var newContact = component.find("newContact");
    	newContact.open();
    },
    
    handleETradingEnablementContact : function(component, event, helper)
    {
    	helper.addNewContact(component, event);
    },

    cancel : function(component, event, helper)
    {
        helper.cancel(component, event);
    },

    clone : function(component, event, helper)
    {
        helper.cloneETradingEnablement(component);
    }
})