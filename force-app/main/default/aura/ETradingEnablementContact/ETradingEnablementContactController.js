({
	open : function(component, event, helper) 
	{
		helper.initialise(component); 
	},
	
	close : function(component, event, helper) 
	{
		component.set("v.display", false);
		helper.clearForm(component);
	}, 
	
	resetAccount : function(component, event, helper)
	{
        helper.resetAccount(component);
	},
	
	accountChanged : function(component, event, helper)
	{
        helper.accountChanged(component, event);
    }, 
	
	addressChanged : function(component, event, helper)
	{
        if(event.getParam("values").length >= 1)
        {
            component.set('v.selectedAddress', event.getParam("values")[0]);
        }
        
        var selectedAddress = component.get("v.selectedAddress");
    },
    
    addressCleared : function(component, event, helper)
    {
    	helper.addressCleared(component);
    },
	
	save : function(component, event, helper) 
	{
		helper.saveContact(component);
		helper.clearForm(component);
	},
})