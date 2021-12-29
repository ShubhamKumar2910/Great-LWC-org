({
    initialise : function(component, event)
    {
        var columns = [
            {
                "label": "Sales Code",
                "fieldName": "salesCode",
                "type": "text"
              },
            {
              "label": "Platform",
              "fieldName": "platform",
              "type": "text"
            },
            
            {
            "label": "Product",
            "fieldName": "product",
            "type": "text"
            }
          ];

        component.set("v.cloneColumns", columns);
        component.set("v.sourceContactId", "");
        component.set("v.targetContactIds", "");
        component.set("v.comments", "");
        component.set("v.cloneData", "");
        component.set("v.displayCloneData", false);

        var sourceContact = component.find("lookupsourcecontact");
        sourceContact.reset();

        var targetContacts = component.find("lookupnewcontact");
        targetContacts.reset();
    },

    getETradingEnablements : function(component) 
    {
        component.set("v.displayCloneData", false);
        
        var sourceContactId = String(component.get("v.sourceContactId"));

        if (!$A.util.isEmpty(sourceContactId))
        {
            this.showSpinner(component);
            
            var action = component.get("c.getETradingEnablements");
            action.setAbortable();

            action.setParams
            ({
                'sourceContactId' : sourceContactId
            });

            action.setCallback(this, function(response)
            {
                this.hideSpinner(component);
                
                if (response.getState() == "SUCCESS")
                {
                    var eTradingEnablementData = JSON.parse(response.getReturnValue());

                    if (!eTradingEnablementData.error)
                    {
                        var cloneData = eTradingEnablementData.eTradingEnablements;

                        if (cloneData.length > 0)
                        {
                            component.set("v.displayCloneData", true);
                        }
                        else
                        {
                            component.set("v.displayNoCloneData", true);
                        }
                        
                        component.set("v.cloneData", cloneData);
                    }
                    else
                    {
                        this.displayErrorToast(eTradingEnablementData.errorMessage);
                    }
                }
                else
                {
                    this.displayErrorToast('Unable to read eTrading Enablements');
                }
            });

            $A.enqueueAction(action);
        }
    }, 

    resetETradingEnablements : function(component, event)
    {
        component.set("v.sourceContactId", "");
        component.set("v.cloneData", "");
        component.set("v.displayCloneData", false);
        component.set("v.displayNoCloneData", false);
    },

    setSourceContactId : function(component, event)
    {
        if(event.getParam("values").length >= 1)
        {
            component.set("v.sourceContactId", event.getParam("values"));
        }
        else
        {
            component.set("v.sourceContactId", "");
        } 
    },

    setTargetContactIds : function(component, event)
    {
        if(event.getParam("values").length >= 1)
        {
           component.set("v.targetContactIds", event.getParam("values"));
        }
        else
        {
            component.set("v.targetContactIds", []);
        } 
    },

    cancel : function(component, event)
    {
        var navigationService = component.find("navigationService");

        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__ETradingEnablementHome'
            }, 
            state: {

            }
        }

        component.set("v.pageReference", pageReference);
        event.preventDefault();
        navigationService.navigate(pageReference);
    },

    addNewContact : function(component, event)
    {
    	var contactId = event.getParam("contactId");
    	
    	if (!$A.util.isEmpty(contactId))
    	{
    		var targetContactIds = component.get("v.targetContactIds");
    		
    		if ($A.util.isEmpty(targetContactIds))
    		{
    			component.set("v.targetContactIds", contactId);
    		}
    		else
    		{
    			contactIds.push(contactId);
    			component.set("v.targetContactIds", targetContactIds);
    		}
    		
    		var lookup = component.find("lookupnewcontact");
			lookup.callPreSelect();
    	} 
    }, 

    cloneETradingEnablement : function(component)
    {
        var sourceContactId = String(component.get("v.sourceContactId"));
        var targetContactIds = component.get("v.targetContactIds");
        var comments = component.get("v.comments");
        var cloneData = component.get("v.cloneData");

        if (!$A.util.isEmpty(sourceContactId) && !$A.util.isEmpty(targetContactIds))
        {
            this.showSpinner(component);
            
            var action = component.get("c.cloneETradingEnablements");

            action.setParams
            ({
                'sourceContactId' : sourceContactId, 
                'targetContactIds' : targetContactIds, 
                'comments' : comments, 
                'cloneData' : JSON.stringify(cloneData)
            });

            action.setCallback(this, function(response)
            {
                this.hideSpinner(component);
                
                if (response.getState() == "SUCCESS")
                {
                    var eTradingEnablementClone = JSON.parse(response.getReturnValue());

                    if (!eTradingEnablementClone.error)
                    {
                        var navigationService = component.find("navigationService");

                        var pageReference = {
                            type: 'standard__component',
                            attributes: {
                                componentName: 'c__ETradingEnablementHome'
                            }, 
                            state: {

                            }
                        }

                        component.set("v.pageReference", pageReference);
                        navigationService.navigate(pageReference);
                    }
                    else
                    {
                        this.displayErrorToast(eTradingEnablementClone.errorMessage);   
                    }
                }
                else
                {
                    this.displayErrorToast('Unable to clone eTradingEnablement(s)');
                }
            });

            $A.enqueueAction(action);
        }
        else
        {
            this.displayErrorToast("Source Contact and Target Contact(s) must be set");            
        }
    },

    showSpinner : function(component)
    {   
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinner : function(component)
    {  
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
    },

    displayErrorToast : function(errorMessage)
    {
    	var toastEvent = $A.get("e.force:showToast");
    	
    	toastEvent.setParams({
    		title: "Error",
            message: errorMessage,
            type: "error", 
            mode: "sticky"
        });
            
        toastEvent.fire();
    }
})