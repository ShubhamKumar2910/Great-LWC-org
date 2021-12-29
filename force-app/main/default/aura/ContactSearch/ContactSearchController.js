({           
    getSelectedAccounts : function(component, event, helper){
        if(event.getParam("values").length >= 1){
            var accountIds = event.getParam("values");                
            component.set("v.accountId", accountIds[0]);
            //component.find("addressCombobox").reinitialise();
            helper.getAddresses(component);
            
        }else
            component.set("v.accountId", "");          
    },
    
    search : function(component, event, helper){       
        helper.searchRecords(component);
    },
    
    updateColumnSorting: function(component, event, helper){ 
        var dataTable = component.find("contactTable");
    	var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        dataTable.set("v.sortedBy", fieldName);
        dataTable.set("v.sortedDirection", sortDirection);        
        helper.sortData(component, fieldName, sortDirection);
    },
    
    addClicked : function(component, event, helper){
        helper.addData(component, "add");
    },
    
    backClicked : function(component, event, helper){         
        var navigateEvent = $A.get("e.force:navigateToComponent");
        navigateEvent.setParams({
            componentDef: "c:ContactList",
            componentAttributes:{
                myContactListSelect: component.get("v.campaignId")                           
            },
            isredirect: true
        });
        navigateEvent.fire();
    },
    
    showSpinner : function(component, event, helper){        
        var spinner = component.find("spinnerComponent");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinner : function(component, event, helper){        
        var spinner = component.find("spinnerComponent");
        $A.util.addClass(spinner, "slds-hide");
    },
    
    showDatatable : function(component, event, helper){        
        var dataTable = component.find("dataTableDiv");
        var footers = component.find("footerId");
        $A.util.removeClass(dataTable, "slds-hide");        
        $A.util.removeClass(footers, "slds-hide");
    },
    
    hideDatatable : function(component, event, helper){
        var dataTable = component.find("dataTableDiv");
        var footerDiv = component.find("footerId");
        $A.util.addClass(dataTable, "slds-hide");
        $A.util.addClass(footerDiv, "slds-hide");
    },
    
    reset : function(component, event, helper){      
        component.set("v.contact", "");
		component.set("v.accountId", "");         
        component.find("accounts").reset();       
        component.set("v.addDisabled", "true");      	       
       	helper.createTable(component, "reset");
        var dataTable = component.find("contactTable");		        
        component.hideDatatable();
        component.set("v.addCloseDisabled", "true"); 
        component.set("v.totalRecordCount", "0"); 
        component.set("v.selectedAddress", []);
        component.set("v.options", []);
        var addressCom = component.find("address");
        addressCom.set("v.disabled", true);
        component.find("address").reInit();
    },
    
    addCloseClicked : function(component, event, helper){
        helper.addData(component, "close");        
    },
    
    showToast : function(component, event, helper){
    	var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({           
            message: $A.get("$Label.c.Error_Message_Select_One"),
            type: "error"
        });
        toastEvent.fire();
	},
    
    displayError : function(component, event, helper){
        component.set("v.hasWarning", "true");                    
        component.hideDatatable();
        component.set("v.addDisabled", "true");
        component.set("v.addCloseDisabled", "true");  
        component.set("v.totalRecordCount", "0");
    },
    
    addressChanged : function(component, event, helper){    	
        if(event.getParam("values").length >= 1){           
            component.set("v.selectedAddress", event.getParam("values"));
        }
        else
            component.set("v.selectedAddress", []);
        
    },
})