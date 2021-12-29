({
	navigateToHomepage : function (component){
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/one/one.app#/home",
          "isredirect" : false
        });
        urlEvent.fire();
   
    },
    
    navigateToRecord : function(component, recordId){
        var navEvt = $A.get("e.force:navigateToSObject");
                
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "related"
        });
        navEvt.fire();
    },

    initialistProductSubscriptions : function(component){

    	var action = component.get("c.getProductSubscriptionPicklistValues");
	        

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var results =  response.getReturnValue();
                console.log('results: ' + results);
                component.set("v.productSubscriptions", results);
                

            }});

        $A.enqueueAction(action);

    }, 

    saveContact : function(component){
    	var _self = this;
        var validationResult = [];
		var selectedAddress = component.get("v.selectedAddress");
		console.log(selectedAddress);
		var contact = component.get("v.contact");
    	var action = component.get("c.saveContact");
	        action.setParams({
	                "c" : contact, 
	                "rmAccountId" : selectedAddress
	            });

	            action.setCallback(this, function(response) {
	                var state = response.getState();
	                if (state === "SUCCESS") {
	                    var results = {};
	                    results =  response.getReturnValue();
	                    console.log('results: ' + results);
	                    
	                    Object.entries(results).forEach(([key, value]) => {
	                            console.log(key + ' ' + value); 
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
    		
    },
})