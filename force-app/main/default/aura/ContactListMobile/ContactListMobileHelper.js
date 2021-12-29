({
     showSpinner : function(component) {   
       $A.util.removeClass(component.find('spinner'), 'slds-hide'); 
    }, 
    
    hideSpinner : function(component) {    
        $A.util.addClass(component.find('spinner'), 'slds-hide'); 
    }, 
    
	getContactListOtherDetails: function(component){
        var action = component.get("c.getContactListOtherDetails"); 
        
        action.setCallback(this, function(response){
            var state = response.getState(); 
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(!$A.util.isUndefined(result)){
                    component.set("v.contactListOtherDetails", result);                     
                }
            }
            else {
                alert('Error in calling server side action');
            }
        });
        
        $A.enqueueAction(action);
    },
    
    getMyContactLists: function(component, selectedId, params, successCallback){
        
        var action = component.get("c.getMyContactLists");
        if(params){
            action.setParams(params);
        }
        action.setCallback(this,function(a){
            component.set("v.contactLists", a.getReturnValue());         
            // set selected my contact list
            if(selectedId != null)
            {
                window.setTimeout(
                    $A.getCallback( function() {
                        component.find("myContactListSelect").set("v.value", selectedId);
                        component.set("v.myContactListSelect", selectedId);                       
                        //Fetch Data
                        if (successCallback) { 
                     		successCallback();
                 		} 
                    })
                );    
            }
            else {
                //to display "My Coverage" as initial list
                var contactLists = a.getReturnValue();
                for(var i = 0; i < contactLists.length; i++){                   
                    if(contactLists[i].Campaign.Name === 'My Coverage'){
                        component.find("myContactListSelect").set("v.value", contactLists[i].Campaign.Id);
                        component.getPageDataForMobile(); 
                        break;
                    }
                    else
                        component.find("myContactListSelect").set("v.value", "1");
                }
            }             
        });
        
        $A.enqueueAction(action);
    },
    
    getRecentList: function(component, params){
    	//Show Spinner
        this.showSpinner(component);
        
        var action = component.get("c.getRecentlyViewedContacts"); 
        if(params){
            action.setParams(params);
        }
        action.setCallback(this, function(a) {
            var resultArray = a.getReturnValue();
            for(var i = 0; i <resultArray.length; i++){
                var contactName = resultArray[i].name;               
                if(contactName.length > 40)
                    resultArray[i].name = contactName.substring(0,40);               
            }
            
            component.set('v.listMembers', resultArray);	
            component.hideSelectAllCheckbox(component);
         	//           
            //Hide Spinner
        	this.hideSpinner(component);
        })
        $A.enqueueAction(action);
    },      
    
    getCampaignMemberForMobile : function(component, params, successCallback, failureCallback){		
        var action = component.get('c.getCampaignMemberForMobile');
        if(params){
            action.setParams(params);
        }
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS" && component.isValid()){
                if(successCallback){
                    successCallback(response.getReturnValue());
                }
            }
            else{
                alert('Error calling action with state: ' + response.getState());
            }
        });       
        $A.enqueueAction(action);
    },
    
      getMemberCount: function(component, params){
        var action = component.get("c.getCampaignMemberCount");
        if(params){
            action.setParams(params);
        }
        
        action.setCallback(this, function(response){
            var state = response.getState(); 
            if (component.isValid() && state === "SUCCESS") {
                if(response.getReturnValue() <= 50){
                    component.showSelectAllCheckbox();   
                    component.hideShowMore();
                }
                else{
                    component.hideSelectAllCheckbox();  
                    component.showShowMore();
                }
            }
            else {
                alert('Error calling action with state: ' + response.getState());
            }
        });
        
        $A.enqueueAction(action);
    },
        
    getCampaignMembersForCampaignId : function(component, params, successCallback, failureCallback){
        var action = component.get("c.getCampaignMembersForCampaignId");
        if(params){
            action.setParams(params);
        }
        
        action.setCallback(this, function(response){
            var state = response.getState(); 
            if (component.isValid() && state === "SUCCESS") {
                 if (successCallback) { 
                     successCallback(response.getReturnValue()); 
                 } 
           }
            else {
                alert('Error calling action with state: ' + response.getState());
            }
        });
        
        $A.enqueueAction(action);
    },
    
})