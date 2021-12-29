({    
    doInit : function(component, event, helper){
        helper.showSpinner(component);
     	var rgAccountPreSelected = component.get("v.rgAccountPreSelected");
        var adressesPreSelected = component.get("v.adressesPreSelected");
        
        var myContactListSelect = component.get("v.myContactListSelect");
        component.set("v.myContactListSelect", myContactListSelect);
        
        helper.getRGAccounts(component);
       
    },
    
    rgAccountSelection : function(component, event, helper){        
        var rgAccountSelected = component.find("rgAccountSelected").get("v.value");
        component.set("v.accountId", rgAccountSelected);
        component.set("v.addressId", null);
        component.set('v.relatedToAccount', rgAccountSelected);
 
        var rgAccountSelected =  component.get('v.relatedToAccount');
        helper.getAddresses(component);
        
    },
    	 
    addressChanged : function(component, event, helper){    	
        if(event.getParam("values").length >= 1){           
            component.set("v.selectedAddress", event.getParam("values"));
            component.set('v.addressId',event.getParam("values")[0]);            
        }        
    },
	  
 	addressCleared : function(component, event, helper) {
        if(component.get('v.rgAccountSelected')!=''){            
            helper.getAddresses(component);        	
        }
    },    
    
    applyClicked : function(component, event, helper){       
        var account = component.get('v.accountId');   
        var addressId = component.get('v.addressId');
        var myContactListSelect = component.get('v.myContactListSelect');
       
        if(addressId === "1"){
            addressId = null;
            component.set("v.addressId", null);            
        }      
         
        var navigationEvent = $A.get('e.force:navigateToComponent');
        navigationEvent.setParams({
            componentDef: 'c:ContactListMobile',
            componentAttributes :{
                accounts : account,
                selectedAddress : addressId,
                myContactListSelect : myContactListSelect
            }
        });        
        navigationEvent.fire();
    },
    
    resetClicked : function(component, event, helper){
        helper.showSpinner(component);
       	component.find("rgAccountSelected").set("v.value", null);
       
        component.find("selectedAddress").set("v.value", null);
		component.find("selectedAddress").clear();
        helper.hideSpinner(component);
	},
    
})