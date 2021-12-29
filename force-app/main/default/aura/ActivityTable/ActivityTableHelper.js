({
    getCampaignMemberData : function(component, campaignId, myContactListSelectId, selectedContactIdsFromList, selectAllCheckboxValueFlag, filters){       

        var action = component.get("c.getCampaignMember");
        action.setParams({           
            "campaignId" : campaignId,            
            "myContactListSelect" : myContactListSelectId,
            "contactIds" : selectedContactIdsFromList,
            "selectAllCheckboxValue" : selectAllCheckboxValueFlag,
            "filters" : filters
        });
        
        component.showSpinner();
              
        action.setCallback(this,function(response){
           var state = response.getState();
           console.log(state);
           if(state === "SUCCESS"){                 
                var campaignData = response.getReturnValue();
                if(campaignData.length > 0){   
                    this.sortAndDisplay(component, campaignData);
                    //component.set("v.campaignMemberData", campaignData); 
                    component.set("v.totalClientAttendees", campaignData.length); 
                    this.differClients(component, campaignData);                    
                 }
               else
                    component.set("v.totalClientAttendees","0");
            }
            else{
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message)
                        console.log("Error message:" + errors[0].message);
                    else
                        console.log("Unknown Error");
                }
            }
            component.hideSpinner();
        });
        $A.enqueueAction(action);        
    },
    
    removeSelectedIds : function(component, contactDataTableMap, contactMap, campaignMap){
        
        var campaignId = component.get("v.campaignId");        
       // var contactIds = []; // For new Contact Ids which are returned from server Controller
        component.showSpinner();
        
        var action = component.get("c.removeSelectedData");
        action.setParams({
            "campaignId" : campaignId,            
            "contactDataTableMap" : contactDataTableMap,
            "contactMap" : contactMap,
            "campaignMap" : campaignMap
        });
        
        action.setCallback(this, function(response){
           var state = response.getState();
            component.hideSpinner();
            if(state ===  "SUCCESS"){
               component.set("v.campaignMemberData", "");
               console.log(response.getReturnValue());
               var campaignData =  response.getReturnValue();
               this.sortAndDisplay(component, campaignData);
               //component.set("v.campaignMemberData", campaignData);
               component.set("v.totalClientAttendees", campaignData.length);
               component.set("v.selectedContactCount", campaignData.length);
               this.differClients(component, campaignData);             
            }
        });
        $A.enqueueAction(action);
       
    },
    
    //For inserting/updating contacts into campaign.
     differClients : function(component, campaignData){
         console.log(campaignData);
        var contactIds = []; // For new Contact Ids which are returned from server Controller
        for(var i = 0; i < campaignData.length; i++){
                    if(campaignData[i].ContactSource == 'NEW'){
                    	contactIds.push(campaignData[i].Id);
                    }
                }				
                component.set("v.selectedContactData", contactIds);
    },
    
    sortAndDisplay : function(component, campaignData){
      //Sorts the records according to name 
      var sortRecords= campaignData;
           sortRecords.sort(function(a, b){
                var contactNameA = a.Name.toLowerCase(), contactNameB = b.Name.toLowerCase();
                if(contactNameA < contactNameB)
                    return -1;
                if(contactNameA > contactNameB)
                    return 1;
                
                return 0;
            }
           );
            //For RowId of dataTable
            for(var i = 0; i < sortRecords.length; i++)  {
                sortRecords[i].rowId = i + 1;
            }           
          component.set("v.campaignMemberData", sortRecords);  
    },
    
    sortData : function(component, fieldName, sortDirection){       
        var data = component.get("v.campaignMemberData");        
        var reverse = sortDirection !== 'asc';         
        data.sort(this.sortBy(fieldName, reverse));
        component.set("v.campaignMemberData", data);
    },
    
    sortBy : function(field, reverse, primer){
       	var key = primer ? function(x){return primer(x[field])} : function(x){return x[field]};
        reverse = !reverse ? 1 : -1;  
       	return function(a, b){
            //Working when we have both GlobalName and LocalName in same column
                if(reverse === -1)
            		return key(a) === undefined ? -1 : key(b) === null ? 1 : reverse * key(a).localeCompare(key(b));                    
                else 
                    return key(a) === undefined ? 1 : key(b) === null ? -1 : reverse * key(a).localeCompare(key(b));
            }       
    }
    
})