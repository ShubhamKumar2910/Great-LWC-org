({
    init : function(component, event, helper) 
    {
        helper.loadData(component);
    }, 
    
    clone : function(component, event, helper)
    {
        helper.cloneETradingEnablement(component, event);
    },

    contactChange : function(component, event, helper)
    {
        if(event.getParam("values").length >= 1)
        {
           component.set("v.contactIds", event.getParam("values"));
        }
        else
        {
            component.set("v.contactIds", []);
        } 
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
  
    platformChange : function(component, event, helper)
    {
        if(event.getParam("values").length >= 1)
        {
            component.set("v.platformIds",event.getParam("values"));
        }
        else
        {
            component.set("v.platformIds",[]);
        } 
    },
    
    handleSalesCodeProducts : function(component, event, helper)
    {
		helper.updateSalesCodeProducts(component, event);
    },

    handleSalesCodeRemove : function (component, event, helper)
    {
        helper.removeSalesCode(component, event);
    },
    
    apply : function(component, event, helper)
    {
        helper.showSpinner(component);
         
        var validationResult = helper.validateRequest(component);
        
        if (validationResult.length == 0)
        {
        	helper.createRequest(component);
        }
        else
        {
        	component.set("v.errors", true);
            component.set("v.errorMessages", validationResult);
            document.body.scrollTop = document.documentElement.scrollTop = 0; 	   
        }
        
        helper.hideSpinner(component); ;
    },
    
    cancel : function(component, event, helper)
    {
        helper.cancel(component, event);
    },
    
    addSalesRequest : function(component, event, helper)
    {
        helper.createSalesRequestComponent(component);
    },
     
    closeErrorMessages : function(component, event, helper)
    {
        component.set("v.errors", false);
    },
})