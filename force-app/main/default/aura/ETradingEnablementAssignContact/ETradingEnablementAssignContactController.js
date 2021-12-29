({
    init : function(component, event, helper) 
    {
        helper.initialise(component, event);
    },
     
    cancel : function(component, event, helper)
    {
        helper.cancel(component, event);
    },

    close : function(component, event, helper) 
	{
        helper.close(component, event);
    },

    save : function(component, event, helper)
    {
        helper.save(component, event);
    },

    eTradingEnablementUpdateSorting : function(component, event, helper)
    {
        helper.updateColumnSorting(component, event);
    },

    eTradingEnablementRowAction : function(component, event, helper)
    {
        helper.contactAction(component, event, false);
    },

    selectContact : function(component, event, helper)
    {
        helper.setContact(component, event);
    }, 

    handleETradingEnablementContact : function(component, event, helper)
    {
        helper.addNewContact(component, event);
    }
})