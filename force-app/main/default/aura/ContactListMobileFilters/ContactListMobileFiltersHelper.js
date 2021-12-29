({
    showSpinner : function(component) {   
       $A.util.removeClass(component.find('spinner'), 'slds-hide'); 
    }, 
    
    hideSpinner : function(component) {     
        $A.util.addClass(component.find('spinner'), 'slds-hide'); 
    }, 
    
    
    getRGAccounts : function(component, event, helper){      
      var rgAccountPreSelected = component.get("v.rgAccountPreSelected");
      var action = component.get("c.getRGAccounts");         	
        action.setParams({
            "campaignId" : component.get("v.myContactListSelect")
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
              
                var result = response.getReturnValue();               
                component.set("v.rgAccounts", result);
               
                if(rgAccountPreSelected != ""){
                    component.set("v.accountId", rgAccountPreSelected);                   	
                    this.getAddresses(component);
                }
                this.hideSpinner(component);
                 
            }
        });
        
		$A.enqueueAction(action);  
    },
    
	getAddresses : function(component){      
       
        var accountIdSelected = component.get("v.accountId");  
        if(accountIdSelected !== null){
            this.showSpinner(component);
            var action = component.get("c.getAddressesForAccount");         	
            action.setParams({
                "accountId" : accountIdSelected,
                "campaignId": component.get("v.myContactListSelect")
            });
            
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                  
                    var result = response.getReturnValue();
                    component.set("v.relatedToAccount", accountIdSelected);
                   
                    component.set("v.adresses", result);
                    if(result.length > 0)
                        component.find("selectedAddress").reinitialise();                
                    this.hideSpinner(component);          
                }else{                
                    var errors = response.getError();
                    if(errors){
                        if(errors[0] && errors[0].message)
                            console.log("Error message-" + errors[0].message);                    
                    }else
                            console.log("Unknown error");
                     this.hideSpinner(component);
                }
            });  
       
        	$A.enqueueAction(action);
        }
        
    },
  
    
})