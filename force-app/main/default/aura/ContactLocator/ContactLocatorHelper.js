({
    initialiseTableHeaders : function(component){
        var action = component.get("c.initialiseColumns");
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseMap = response.getReturnValue();
                
                for (var key in responseMap) {
                    if (responseMap.hasOwnProperty(key)) {                    
                        var innerMap = responseMap[key];
                        
                        for(var f in innerMap){
                            
                            
                            if(key == 'Contact' && f == 'Email'){
                                component.set("v.contactEmailColumnHeader", innerMap[f]);
                            }
                            if(key == 'Account' && f == 'BillingCity'){
                                component.set("v.billingCityColumnHeader", innerMap[f]);
                            }
                            if(key == 'Account' && f == 'BillingCountry'){
                                component.set("v.billingCountryColumnHeader", innerMap[f]);
                            }
                            if(key == 'Account' && f == 'Name'){
                                component.set("v.accountNameColumnHeader", innerMap[f]);
                            }
                        }
                    }
                }
                
                
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    
    checkColumnVisibilityRestrictions : function(component){
        var action = component.get("c.checkCoverageStatusColumnView");
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseMap = response.getReturnValue();
                
                component.set("v.showCoverageStatusColumn", responseMap);
                
                
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    initialiseBaseURL : function(component){
        var action = component.get("c.getBaseURL");
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var responseMap = response.getReturnValue();
                //Console Action
                if (typeof sforce != 'undefined' && sforce != null && sforce.console.isInConsole()){
                    responseMap += '/console#%2F';
                    component.set("v.classicConsoleMode", true);
                }
                
                component.set("v.baseURL", responseMap);
                
                
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    searchContacts : function(component){
        var searchInput = component.find("seachBox");
        var skyHighValue = searchInput.get("v.value");
        console.log(skyHighValue);
        if(skyHighValue == null || skyHighValue == '')
        {
            component.set("{!v.showNoInputMessage}", true);
            /* var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "INFO",
                "type": "info",
                "message": "Please Enter String",
            });
            toastEvent.fire(); 
             searchInput.set("v.errors", [{message:"Enter an String."}]); */
        }
        else
        {
            this.stringAvailable(component);
        }
    },
    
    stringAvailable : function(component)
    {
        var searchInput = component.find("seachBox");
        component.set("{!v.showSpinner}", true);
        component.set("{!v.showNoInputMessage}", false);
        component.set("{!v.showNoResultsMessage}", false);
        component.set("{!v.showExtendedSearchResultsMessage}", false);
        
        var skyHighValue = searchInput.get("v.value");
        var contact = component.get("v.contact");
        var action = component.get("c.getContacts2");
        
        action.setParams({ 
            "t": skyHighValue,
            "c" : contact
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                
                
                if(response.getReturnValue() == null || response.getReturnValue() == ''){
                    component.set("{!v.showNoResultsMessage}", true);
                }else{
                    component.set("{!v.showNoResultsMessage}", false);
                }
                
                var actualContactList = response.getReturnValue();
                if(actualContactList == null || actualContactList == undefined){
                    component.set("{!v.hasErrors}", true);
                }
                else{
                	component.set("v.contactWrapper", actualContactList);
                	if(actualContactList.length > 300){
                		component.set("{!v.showExtendedSearchResultsMessage}", true); 
                    }
                    /* SHIELD
                    if(contact.Description.includes("@")){
                        component.set("v.contactWrapper", actualContactList);
                    }
                    else {
                        var contactList = new Array();
                        
                        var srchString = (contact.Description != null && contact.Description != undefined) ? contact.Description.toLowerCase() : contact.Description
                        console.log("srchString :　",srchString);
                        var searchString = srchString.replace(/[\\*]/gi,''); 
                        console.log("searchString :　",searchString);
                        
                        for(var i=0; i<actualContactList.length; i++){  
                            var recordToBeConsidered = true;
                            var nameString = actualContactList[i].contact.Name.toLowerCase();
                            var localNameString = (actualContactList[i].contact.Local_Language_Full_Name__c != null && actualContactList[i].contact.Local_Language_Full_Name__c != undefined) ? actualContactList[i].contact.Local_Language_Full_Name__c.toLowerCase() : actualContactList[i].contact.Local_Language_Full_Name__c;
                            console.log("localNameString　:　",localNameString);
                            
                            if(!nameString.includes(searchString) &&
                               (localNameString == null || 
                                localNameString == undefined ||
                                (localNameString != null && 
                                 localNameString != undefined &&
                                 !localNameString.includes(searchString))
                               )
                              ) 
                            {
                                recordToBeConsidered = false;
                                console.log("Record will not be considered");
                            }
                            
                            if(recordToBeConsidered == true){
                                contactList.push(actualContactList[i]);
                            } 
                        }
                        
                        if(contactList.length > 300){
                            component.set("{!v.showExtendedSearchResultsMessage}", true); 
                        }
                        
                        component.set("v.contactWrapper", contactList); 
                    }
					SHIELD */	
                }
                
                /*
              //Old Code - No Support for Local Name Search
              var contactList = response.getReturnValue();
              component.set("v.contactWrapper", contactList);
              
              if(contactList == null || contactList == undefined){
                component.set("{!v.hasErrors}", true);
              }
              if(contactList.length >300){
                component.set("{!v.showExtendedSearchResultsMessage}", true);
              }
              */  
                    
                    component.set("{!v.showSpinner}", false);
                    
                }else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        },
})