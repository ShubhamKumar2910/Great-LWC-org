({       
    init:function(component, event, helper){
        var selectedAccount = component.get("v.selectedAccount");
        
        var maxRowSelect = component.get("v.maxRowSelect");
        if(!isNaN(maxRowSelect) && maxRowSelect > 0) {
        	var dataTable = component.find("contactTable");
        	dataTable.set("v.maxRowSelection", maxRowSelect);
        }
        
        if(selectedAccount[0]!= undefined && selectedAccount.length > 0){
            component.set("v.accountId", selectedAccount[0]);
            component.resetDatatable();			
            helper.searchRecentRecords(component);
            component.set("v.showRecentContactsTitle", true);
            
        }
    }
    ,
    getSelectedAccounts : function(component, event, helper){
        if(event.getParam("values").length >= 1){
            var accountIds = event.getParam("values");                       
            component.set("v.accountId", accountIds[0]);
        }else
            component.set("v.accountId", []);          
    },
    
    onSelectedContactsChange : function (component, event, helper) {
        //helper.searchRecentRecords(component);
    },
    
    search : function(component, event, helper){       
        helper.searchRecords(component);
        component.set("v.showRecentContactsTitle", false);
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
    },
    
    addCloseClicked : function(component, event, helper){
        helper.addData(component, "close");   
    },
    
    showToast : function(component, event, helper){
    	var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({           
            message: "Please select atleast one contact to add",
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
    
    updateLookupIdEvent : function(component, event, helper){                       
        component.set("v.accountId", "");                
    },
    
    resetDatatable : function(component, event, helper){
        component.set("v.contactData", [{}]);
		component.set("v.contact", "");        
    },        
})