({
	initialiseAccountDropdown: function(component){
		
		var recordId = component.get("v.recordId");
      
        if(recordId != undefined && recordId != null){
            var validationResult = [];
	        var action = component.get("c.getContactDetails");
	        action.setParams({
	                "contactId" : recordId
	            });

	            action.setCallback(this, function(response) {
	                var state = response.getState();
	                if (state === "SUCCESS") {
	                    var result = response.getReturnValue();
	                    console.log(result);

	                    var array = [];

                    	array.push(result.RG_Account__c);
                    	component.set("v.relatedToAccount", result.RG_Account__c);
	                    component.set("v.relatedToAccountSelected", array);
                        
                        var accountLookupRef  = component.find("newcontact-account");
                        accountLookupRef.callPreSelect();
                        
	                    component.find("addressCombobox").reinitialise();
                        var accountLookupRef  = component.find("newcontact-account");
                        $A.util.addClass(accountLookupRef.find('lookup-pill'), 'slds-hide');
                        accountLookupRef.callPreSelect();

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


	saveContact : function(component){
    	var _self = this;
        var validationResult = [];
		var selectedAddress = component.get("v.selectedAddress");
		var contact = component.get("v.contact");
		if(selectedAddress == '')
        {
            var item = [];
            item.push({
                message :  'Please select Address'
            });
             component.set("v.hasErrors", true);
             component.set("v.errorMessages", item);
        }
        else
        {
            	var action = component.get("c.saveContact");
	        action.setParams({
	                "c" : contact, 
	                "rmAccountId" : selectedAddress,
	                "contactId" : component.get("v.recordId")
	            });

	            action.setCallback(this, function(response) {
	                var state = response.getState();
	                if (state === "SUCCESS") {
	                    var results = {};
	                    results =  response.getReturnValue();

	                    Object.entries(results).forEach(([key, value]) => {
	                            if(key.startsWith("Contact ID")){
	                                _self.navigateToRecord(component, value);
	                            }
	                            if(key.startsWith("Error")){
	                                validationResult.push({
	                                        message :  value
	                                    });
	                                component.set("v.hasErrors", true);
	                                component.set("v.errorMessages", validationResult);
	                                document.body.scrollTop = document.documentElement.scrollTop = 0;
	                            }
	                    });
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
 
   navigateToRecord : function(component, recordId){
        var navEvt = $A.get("e.force:navigateToSObject");
                
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "related"
        });
        navEvt.fire();
    },
})