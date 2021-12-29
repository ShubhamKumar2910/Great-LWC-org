({
	initialise : function(component) 
	{
		component.set("v.display", true);
		
		var initialised = component.get("v.initialised");
		
		if (!initialised)
		{
			var action = component.get("c.initialise");
			action.setStorable();  
			action.setAbortable();
		
	        action.setCallback(this, function(response)
	        {
	            if (response.getState() == "SUCCESS")
	        	{
					var requestData = JSON.parse(response.getReturnValue());
	                
	                if (requestData.error == false)
	                {
	                	var salutations = requestData.salutations;
	                    var salutationsPicklistValues = [];
	                    
	                    Object.entries(salutations).sort().forEach(([key, value]) => 
	                    {
	                        salutationsPicklistValues.push({
	                        	'value': key, 
	                            'label': value
	                    	});
	                    });
	                    
	                    salutationsPicklistValues.unshift({
	                        	'value': "None", 
	                            'label': "--None--"
	                    	});
	                    
	                	component.set("v.salutationOptions", salutationsPicklistValues);
						component.set("v.initialised", true);
					}
					else
					{
						this.displayErrorToast(requestData.errorMessage);
					}
	            }
	            else if (state === "ERROR") 
                {
	            	this.displayErrorToast("Error reading salutation");
                }
	        });
	    
	    	$A.enqueueAction(action);
		}
	},

	clearForm : function(component)
	{
	    var newContactAccount = component.find("newcontact-account");
	    newContactAccount.clearMethod();
	    
	    component.set("v.contact", "{ 'sobjectType': 'Contact' }");
	    component.set("v.relatedToAccount", "");
	    component.set("v.selectedAddress", "");
	    
	    var combobox = component.find("addressCombobox");
        combobox.clear();
        combobox.hideItems();
        
        $A.util.addClass(combobox.find('lookup-pill'),'slds-hide');
	}, 
	 
	resetAccount : function(component) 
	{
		var combobox = component.find("addressCombobox");
        combobox.clear();
        combobox.hideItems();
        component.set("v.relatedToAccount", ""); 
        component.set("v.selectedAddress","");
        
	},
	
	accountChanged : function(component, event)
	{
        var accountIds = event.getParam("values");
        
        if(event.getParam("values").length >= 1)
        {
            this.getAddressData(component, accountIds[0]);
        }
	},
	
	addressCleared : function(component)
	{
        if(component.get('v.rgAccountSelected') != '')
    	{ 
            this.getAddressData(component, component.get("v.relatedToAccount"));
        }
	},
	
	getAddressData : function(component, relatedAccount)
	{
        if(relatedAccount)
        {
            var account = relatedAccount;
            
            var validationResult = [];
            
            var action = component.get("c.getAccountAddresses");
            
            action.setParams({
            		"accountId" : account
            	});

            action.setCallback(this, function(response) 
            {
                var state = response.getState();
                
                if (state === "SUCCESS") 
                {
                    var result = response.getReturnValue();

                    var addresses = [];
                    
                    for(var k in result)
                    {
                        var labelText = result[k].BillingStreet + ' ' + result[k].BillingCity + ' ' + result[k].BillingCountry;
                        addresses.push({label:labelText, value: result[k].Id});
                    }
                    
                    var array = [];

                    array.push(account);
                    component.set("v.relatedToAccount", account);
                    component.set("v.addressOptions", addresses);
                    component.find("addressCombobox").reinitialise();
                }
                else  
                {
                    var errors = response.getError();
                    
                    if (errors) 
                    {
                        if (errors[0] && errors[0].message) 
                        {
                            validationResult.push({
                                        message :  errors[0].message
                                    });
                                    
                            component.set("v.hasErrors", true);
                            component.set("v.errorMessages", validationResult);
                            document.body.scrollTop = document.documentElement.scrollTop = 0;
                        }
                    } 
                    else 
                    {
                        this.displayErrorToast("Error reading address data");
                    }
                }
            });

            $A.enqueueAction(action);
        }        
    },

	saveContact : function(component) 
	{
		var contact = component.get("v.contact");
		var accountId = component.get("v.selectedAddress");
		
		var action = component.get("c.saveContact");
		action.setStorable();  
    	action.setAbortable();
		
		action.setParams
		({
            'contact' : contact,
            'rmAccountId' : accountId
        }); 
        
        action.setCallback(this, function(response)
        {
            if (response.getState() == "SUCCESS")
        	{
				var requestData = JSON.parse(response.getReturnValue());
                
                if (requestData.error == false)
                {
					var contactId = requestData.contactId;
					var contactName = requestData.contactName;
					
			        if (!$A.util.isEmpty(contactId))
			        {
			            var contactEvent = component.getEvent("newContact");
			        
			            contactEvent.setParams 
			            ({
							"contactId" : contactId,  
							"contactName": contactName 
			            });
			        
			            contactEvent.fire();
			        }
					
					component.set("v.display", false);
				}
				else
				{
					this.displayErrorToast(requestData.errorMessage);
				}
            }
        });
    
    	$A.enqueueAction(action);
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
    }
})