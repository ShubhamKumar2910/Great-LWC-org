({
	init : function(component, event, helper) {
		helper.initialistProductSubscriptions(component);
	},

	save : function(component, event, helper) {
		helper.saveContact(component);
	},
    
    addressChanged : function(component, event, helper){
    	var selectedAddress = component.get("v.selectedAddress");
    	console.log('selectedAddress value: ' +selectedAddress);
    },

    contactAccountchanged : function(component, event, helper){
    	console.log('contactAccountchanged');
        var accountIds = event.getParam("values");
        console.log(accountIds[0]);
        console.log(event.getParam("values").length);
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
	                    	var labelText = result[k].BillingStreet + ' ' + result[k].BillingCity + ' ' + result[k].BillingCountry;
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
    }, 

    cancel : function(component, event, helper){
    	helper.navigateToHomepage(component);
    }
})