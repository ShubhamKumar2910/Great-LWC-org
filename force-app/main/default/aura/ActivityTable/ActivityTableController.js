({
    doInit : function(component, event, helper){
        var campaignId = component.get("v.campaignId");       
        var selectedContactIdsFromList = component.get("v.selectedContactData");        
        var selectAllCheckboxValueFlag = component.get("v.selectAllCheckboxValue");
        var myContactListSelectId = component.get("v.myContactListSelect"); 
        var filters = component.get("v.filters");
        
        if(campaignId == null || campaignId == undefined)         	
            component.set("v.newActivity", "true");       
        else
            component.set("v.newActivity","false");
        
        if(campaignId !== null || (selectedContactIdsFromList!== null && selectedContactIdsFromList.length > 1)){
            var dataTableD = component.find("dataTableDiv");
            $A.util.removeClass(dataTableD, "slds-hide");
            //component.showSpinner();
            component.set("v.campaignMemberColumn", [                            
                            {label: component.get("v.ContactName"), fieldName:"Name", type:"text", sortable:true},
                            {label: component.get("v.Email"), fieldName:"Email", type:"email", sortable:true},
                            {label: component.get("v.AccountName"), fieldName:"AccountName", type:"text", sortable:true},
                			{label: component.get("v.LegalEntity"), fieldName:"LegalEntity", type:"text", sortable:true},
                            {label: component.get("v.Active"), fieldName:"Active", type:"text", sortable:true}
                        ]);
           
            helper.getCampaignMemberData(component, campaignId, myContactListSelectId, selectedContactIdsFromList, selectAllCheckboxValueFlag, filters);            
        }
        else{
            var dataTableD = component.find("dataTableDiv");
            $A.util.addClass(dataTableD, "slds-hide");
            component.set("v.totalClientAttendees","0");
        }
    },
    
    
    removeSelected : function(component, event, helper){
        var activityTab = component.find("activityTable");
        var selectedTableValues = activityTab.getSelectedRows();
        
        var contactDataTableMap= {}; //Create map of ContactId and and NEW records
        var campaignMap = {}; //Create map of ContactId and and EXISTING records
        var contactMap = {}; //Create map of Selected ContactId and and NEW records
        
        var campaignMemberTableData = component.get("v.campaignMemberData");
        if(campaignMemberTableData !== null && campaignMemberTableData.length > 0){
            for(var i = 0; i < campaignMemberTableData.length; i++){
                if(campaignMemberTableData[i].ContactSource === 'NEW')
                    contactDataTableMap[campaignMemberTableData[i].Id] = campaignMemberTableData[i];
            }
        }
        
        
        if(selectedTableValues !== null && selectedTableValues.length > 0){
            for(var i = 0; i < selectedTableValues.length; i++){                
                if(selectedTableValues[i].ContactSource === 'NEW')
                	contactMap[selectedTableValues[i].Id] = selectedTableValues[i];                
                else
                    campaignMap[selectedTableValues[i].Id] = selectedTableValues[i];                
            }                    
            helper.removeSelectedIds(component, contactDataTableMap, contactMap, campaignMap);
        }
        else{
             component.showToast();
        }
    },
    
     updateColumnSorting: function(component, event, helper){ 
        var dataTable = component.find("activityTable");
    	var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        dataTable.set("v.sortedBy", fieldName);
        dataTable.set("v.sortedDirection", sortDirection);        
        helper.sortData(component, fieldName, sortDirection);
    },
    
    showSpinner : function(component, event, helper){     
        var spinner = component.find("spinnerComponentDiv");
        $A.util.removeClass(component.find("spinnerComponentDiv"), "slds-hide");
        $A.util.addClass(component.find("spinnerComponentDiv"), "slds-show");
    },
    
    hideSpinner : function(component, event, helper){ 
        var spinner = component.find("spinnerComponentDiv");
        $A.util.addClass(component.find("spinnerComponentDiv"), "slds-hide");
        $A.util.removeClass(component.find("spinnerComponentDiv"), "slds-show");
    },
    
    showToast : function(component, event, helper){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({           
                message: "Please select atleast one contact to remove",
                type: "warning"
            });
            toastEvent.fire();
        },
    
   
    
})