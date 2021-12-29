({
    
    init : function(component, event, helper) {
		helper.initialiseAccountDropdown(component);
	},

	save : function(component, event, helper) {
		helper.saveContact(component);
	},
    OnReset : function(component,event,helper){
        console.log('On reset called lookup')  ;
        var combobox = component.find("addressCombobox");
        combobox.clear();
        combobox.hideItems();
        component.set('v.selectedAddress','');
        $A.util.addClass(combobox.find('lookup-pill'),'slds-hide');
    },
    addressCleared : function(component,event,helper){
        if(component.get('v.relatedToAccount')!='')
        {
            component.set('v.selectedAddress','');
            component.find("addressCombobox").reinitialise();
        }
    },
    addressChanged : function(component, event, helper){
        if(event.getParam("values").length >= 1){
            console.log('values');
            console.log(event.getParam("values"));
            component.set('v.selectedAddress',event.getParam("values")[0]);
            console.log('data');
            console.log(event.getParam("data"));
          
        }
    	var selectedAddress = component.get("v.selectedAddress");
        console.log('selected Address :'+selectedAddress)
    },

    contactAccountchanged : function(component, event, helper){
    	
        var accountIds = event.getParam("values");
      
        if(event.getParam("values").length >= 1){
            var validationResult = [];
	        var action = component.get("c.getAccountAddresses");
	        action.setParams({
	                "accountId" : accountIds[0]
	            });

	            action.setCallback(this, function(response) {
	                var state = response.getState();
	                if (state === "SUCCESS") {
	                    var result = response.getReturnValue();
	                    console.log(result);

	                    var addresses = [];
	                    for(var k in result){
	                    	var labelText = result[k].BillingCountry + ' ' + result[k].BillingStreet + ' ' + result[k].BillingCity;
	                    	addresses.push({label:labelText, value: result[k].Id});
	                    }
	                    component.set("v.addressOptions", addresses);
	                }else if (state === "ERROR") {
	                        var errors = response.getError();
	                        if (errors) {
	                            if (errors[0] && errors[0].message) {
	                                validationResult.push({
	                                            message :  errors[0].message
	                                        });
	                                component.set("v.hasErrors", true);
	                                component.set("v.errorMessages", validationResult);
	                                document.body.scrollTop = document.documentElement.scrollTop = 0;
	                            }
	                        } else {
	                            console.log("Unknown error");
	                        }
	                        }
	                    });

	            $A.enqueueAction(action); 
        }
    }

   
})