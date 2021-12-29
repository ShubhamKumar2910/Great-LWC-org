({
    // helper function to get get the initialize information for this component.
    // It gets the 
    getComponentInitializationInfo :  function (component, event, helper){
        console.log('#### helper.getComponentInitializationInfo()');
        var _self = this;
        _self.showSpinner(component);
        // apex controller action
        var action = component.get("c.getInitializeInfo");
        // set the apex funtion parameters 
        var cloneFromContId = component.get("v.cloneFrom");
        var editContId = component.get("v.editContId");
        component.set("v.deriveMiFIDIIEntFromRMAccMsg", ""); 
        // This component is used to create a new contact or clone or edit the existing contact, and its behaviour 
        // is different depending for each scenarios and in case of clone or edit, the contact-id is passed in 
        // different attributes
        var isClone = false;
        var isEdit = false;
        var contactId = null;
        if(cloneFromContId !== null && cloneFromContId !== undefined && cloneFromContId.startsWith('003')) {
            isClone = true;
            contactId = cloneFromContId;
        } else if(editContId !== null && editContId !== undefined && editContId.startsWith('003')) {
            isEdit = true;
            contactId = editContId;
        }
		// set action parameters
        action.setParams({
	    	"contactId" : contactId
	    });
        
        // set the action callback
   		action.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Apex controller action getInitializeInfo() completed Successfully.")
                // the result is comprised of following three parts and returned in single call
                //{
				//	ProductSubsPicklistValuesMap: {FIGL: "Global FI", …}
				//	isCurrentUserMifidAdmin: true
				//	oContact: {Id: "0035D000001PN5wQAG", FirstName: "James", …}
                //}
            	var result =  response.getReturnValue();
                if(result!==null && result!==undefined) {
                    helper.initializeMiFIdResults(component, event, helper, result.isCurrentUserMifidAdmin);
                    helper.initializeProdSubsResults(component, event, helper, result.ProductSubsPicklistValuesMap);
                    helper.initializeContact(component, event, helper, isClone, isEdit, result.oContact);
                }
            }  else if (state === "ERROR") {
                component.set("v.disableSaveButton", false);
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
            _self.hideSpinner(component);
        });
		// enque the apex controller action        
        $A.enqueueAction(action);
    },

    initializeMiFIdResults : function(component, event, helper, isMiFID) {
        console.log('#### helper.initializeMiFIdResults()');
        component.set("v.showMifid", isMiFID);
        if(isMiFID === true) {
            component.set("v.mifidCheckboxDisabled", false);
        } else {
            component.set("v.mifidCheckboxDisabled", true);
            var cmpTarget = component.find('MifidInScope');
            $A.util.addClass(cmpTarget, 'disabledCheckbox');
        }
    },
    
    initializeProdSubsResults : function(component, event, helper, proSubsPickListVals) {
        console.log('#### helper.initializeProdSubsResults()');
        if(proSubsPickListVals!==null && proSubsPickListVals!==undefined) {
            var picklistValues = [];
            Object.entries(proSubsPickListVals).forEach(([key, value]) => {
                picklistValues.push({
                	'label': value,
                	'value': key,
                });
        	});
        	component.set("v.productSubscriptions", picklistValues);  
        	var prodSubsOpts = component.find("my-multi-select");
            if(prodSubsOpts!==null && prodSubsOpts!==undefined) {
				prodSubsOpts.reInit();            	    
            }
    	}
    },
    	
    initializeContact : function(component, event, helper, isClone, isEdit, oContact) {
    	console.log('#### helper.initializeContact()');
    	if(oContact!==null && oContact!==undefined && (isClone===true || isEdit===true)) {
    		oContact.sobjectType = 'Contact';
            var account  = [];
            account.push(oContact.RG_Account__c);
            component.set("v.selectedAccount", account);
            component.find("newcontact-account").callPreSelect();
            component.set("v.relatedToAccount", oContact.AccountId);
            component.set("v.preSelectedAddressId", oContact.AccountId);
             
            if(isClone===true) {
                //component.set("v.contact.Id", null);
                oContact.Id=null;
            } else if(isEdit===true) {
                var addressComboBoxCmp = component.find("addressCombobox");
                if(addressComboBoxCmp!==null && addressComboBoxCmp!==undefined) {
                    addressComboBoxCmp.set("v.preSelectedId", oContact.AccountId);
                }
                
                var podAddressComboBoxCmp = component.find("podAddressCombobox");
                console.log(podAddressComboBoxCmp);
                if(podAddressComboBoxCmp!==null && podAddressComboBoxCmp!==undefined) {
                    console.log('POD ID: ' + oContact.POD_Account__c);
                    podAddressComboBoxCmp.set("v.preSelectedId", oContact.POD_Account__c);
                    component.set("v.preSelectedAddressId", oContact.AccountId);
                    component.set("v.isPodAccount", true);

                }
            }
            
            // Set MiFID related attributes
            var selectedVals = [];
            if(!$A.util.isEmpty(oContact.MiFID_II_Product_Subscriptions__c)) {
                selectedVals = oContact.MiFID_II_Product_Subscriptions__c.split(";");
                component.set("v.selectedSubscriptions", selectedVals);
            }
            component.set("v.selectedSalesCommentary", oContact.MiFIDII_Sales_Commentary_Allowed__c);
            component.set("v.selectedServiceType", oContact.Service_Type__c);
            
            
            // Set GRP Access related attributes
            component.set("v.selectedRegion", oContact.Region__c);

            var regionInvestorArr = [];
            var atrrName;
            switch(oContact.Region__c) {
				case "Americas":
					regionInvestorArr = component.get("v.AmericaInvestorOptions");
                    atrrName = "v.AmericaInvestorOptions";
                    break;
                case "AEJ":
					regionInvestorArr = component.get("v.AEJInvestorOptions");
                    atrrName = "v.AEJInvestorOptions";
                    break;
                case "EMEA":
					regionInvestorArr = component.get("v.EMEAInvestorOptions");
                    atrrName = "v.EMEAInvestorOptions";
                    break;
                case "Japan":
					regionInvestorArr = component.get("v.JapanInvestorOptions");
                    atrrName = "v.JapanInvestorOptions";
                    break;
            }

            for (var i = 0; i < regionInvestorArr.length ; i++) {
                if(oContact.Investor_Type__c===regionInvestorArr[i].value) {
                	regionInvestorArr[i].selected="selected";
                }
            }
            component.set(atrrName, regionInvestorArr);
            component.set("v.selectedInvestorType", oContact.Investor_Type__c);
            component.set("v.selectedLanguage", oContact.Preferred_Language__c);
            component.set("v.contact", oContact); 
            //added fields for JIRA 3521
            component.set('v.selectedPosition',oContact.PositionPicklist__c);
            console.log('selected pos : '+ oContact); 
            console.log('selected pos : '+ oContact.PositionPicklist__c); 
            console.log('selected pos : '+ component.get('v.selectedPosition'));           
		}
	},

	navigateToHomepage : function (component){
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/lightning/page/home",
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

    navigatetopage : function(component, url){
       var urlEvent = $A.get("e.force:navigateToURL");
                
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    },

    updateMifidInScope : function(component){
    	var action = component.get("c.getDefaultMiFIDIIEntitlementFromRMAccont");
	     
	    action.setParams({
	    	"rmAccountId" : component.get("v.selectedAddress")
	    });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var miFIDIIEntitlement =  response.getReturnValue();
                console.log("miFIDIIEntitlement : ",miFIDIIEntitlement);
                if(miFIDIIEntitlement!=null && miFIDIIEntitlement!=undefined) {
	                if(miFIDIIEntitlement.applyMiFIDIIEntitlementFromRMAccount===true) {
	                	component.set("v.mifidCheckboxDisabled", true);
	                	component.set("v.deriveMiFIDIIEntFromRMAccMsg", $A.get("$Label.c.MiFIII_Entitlement_Derived_From_Legal_Entity"));
	                	component.set("v.contact.MiFIDII_in_Scope__c", miFIDIIEntitlement.rmAccMiFIDIIResearchInScope);
	                	component.set("v.selectedSalesCommentary", miFIDIIEntitlement.rmAccMiFIDIISalesCommentaryAllowed);
	                	component.set("v.selectedServiceType", miFIDIIEntitlement.rmAccServiceType);
	                	if(!$A.util.isEmpty(miFIDIIEntitlement.rmAccMiFIDIIProductSubscriptions)) {
	                		var selectedVals = miFIDIIEntitlement.rmAccMiFIDIIProductSubscriptions.split(";");
	                		console.log("selectedVals : ",selectedVals);
	                		component.set("v.selectedSubscriptions", selectedVals);
	                	} else {
	                		component.set("v.selectedSubscriptions", []);
	                	}
	                	var prodSubsOpts = component.find("my-multi-select");
	                	if(prodSubsOpts!==null && prodSubsOpts!==undefined) {
	                		prodSubsOpts.reInit();            	    
	                	}
	                } else {
	                	component.set("v.contact.MiFIDII_in_Scope__c", miFIDIIEntitlement.rmAccMiFIDIIInScope);
	                }
                }
            }
        });
        $A.enqueueAction(action);
    
    	/*var action = component.get("c.defaultMifidScopeBasedOnRM");
	     
	    action.setParams({
	    	"rmAccountId" : component.get("v.selectedAddress")
	    });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var results =  response.getReturnValue();
                
                component.set("v.contact.MiFIDII_in_Scope__c", results);
                

            }});

        $A.enqueueAction(action);*/
    },

     resetMiFIDIIDerivedFromRMAcc : function(component, event, helper) {
        component.set("v.deriveMiFIDIIEntFromRMAccMsg", "");
        component.set("v.mifidCheckboxDisabled", !component.get("v.showMifid"));
        component.set("v.contact.MiFIDII_in_Scope__c", false);
        component.set("v.selectedSalesCommentary", "Allowed");
	    component.set("v.selectedServiceType", "");
        component.set("v.selectedSubscriptions", []);
    	var prodSubsOpts = component.find("my-multi-select");
    	if(prodSubsOpts!==null && prodSubsOpts!==undefined) {
    		console.log("resetMiFIDIIDerivedFromRMAcc -> reset");
    		prodSubsOpts.reInit();            	    
    	}
     },

    resetMifidInScope : function(component){
        component.set("v.contact.MiFIDII_in_Scope__c", false);
     },

    /*initialistProductSubscriptions : function(component){

    	var action = component.get("c.getProductSubscriptionPicklistValues");
	        

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var results =  response.getReturnValue();
                var picklistValues = [];
                 Object.entries(results).forEach(([key, value]) => {
                 	picklistValues.push({
								        'label': value,
								        'value': key,
								        
								    });
                });

                component.set("v.productSubscriptions", picklistValues);
                

            }});

        $A.enqueueAction(action);

    },*/

    saveContact : function(component,event){
        var _self = this;
        var validationResult = [];
        // following is the AccountId of the Address Account
        var selectedAddress = component.get("v.selectedAddress");
        console.log("selectedAddress",selectedAddress);

        // following is the AccountId of the POD Account
        var selectedPodAddress = component.get("v.selectedPodAddress");
        console.log("selectedPodAddress",selectedPodAddress);

        var contact = component.get("v.contact");
        var serviceType = component.get("v.selectedServiceType");
        var productsToAdd = component.get("v.selectedSubscriptions");
        console.log('productsToAdd: ' + productsToAdd);
        var preferredLanguage = component.get("v.selectedLanguage");
        var region = component.get("v.selectedRegion");
        console.log("Region : ",region);
        var investorType = component.get("v.selectedInvestorType");
        
        var buttonType = event.getSource().get("v.name");
        console.log('buttonType : '+buttonType);
        if(buttonType=='mobileSave') {
        	component.set("v.selectedSalesCommentary", "Allowed");
        }
        var salesCommentary = component.get("v.selectedSalesCommentary");
        
        _self.showSpinner(component);
        var action = component.get("c.saveContact");
            
        action.setParams({
                    "c" : contact, 
                    "rmAccountId" : selectedAddress,
                    "salesCommentary": salesCommentary, 
                    "serviceType" : serviceType,
                    "productsToAdd" : productsToAdd, 
                    "preferredLanguage" : preferredLanguage,
                    "region" : region,
                    "investorType" : investorType,
                    "podAccountId" : selectedPodAddress,
                });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var results = {};
                results =  response.getReturnValue();
                console.log('results: ' + results);
                        
                Object.entries(results).forEach(([key, value]) => {
                    console.log(key + ' ' + value); 
                    if(key.startsWith("Contact ID")) {
                    	_self.showSpinner(component);
                    	_self.navigateToRecord(component, value);
                	}
                    if(key.startsWith("Error")){
                        _self.hideSpinner(component);
                        validationResult.push({
                            message :  value
                        });
                        component.set("v.hasErrors", true);
                        component.set("v.errorMessages", validationResult);
                        component.set("v.disableSaveButton", false);
                        document.body.scrollTop = document.documentElement.scrollTop = 0;
                    }
        		});
    		}else if (state === "ERROR") {
                _self.hideSpinner(component);
                component.set("v.disableSaveButton", false);
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

    cheackAndClearMiFIDIIFields: function(component, event, helper) {
    	let miFIDIIInScope = component.get("v.contact.MiFIDII_in_Scope__c");
    	if(miFIDIIInScope===false) {
    		component.set("v.selectedSubscriptions", []);
    		var prodSubsOpts = component.find("my-multi-select");
	    	if(prodSubsOpts!==null && prodSubsOpts!==undefined) {
	    		prodSubsOpts.reInit();            	    
	    	}
    		component.set("v.selectedSalesCommentary", "");
    		component.set("v.selectedServiceType", "");
    	} else if(miFIDIIInScope===true) {
    		console.log("Setting Sales Commetary default to Allowed");
    		component.set("v.selectedSalesCommentary", "Allowed");
    	}
    },
    /*checkMifidPermissions : function(component){
    	var _self = this;
        var validationResult = [];
		
    	var action = component.get("c.isCurrentUserMifidAdmin");
	            action.setCallback(this, function(response) {
	                var state = response.getState();
	                if (state === "SUCCESS") {
	                    var result = response.getReturnValue();
	                    console.log('result: ' + result);
	                    component.set("v.showMifid", result);
                        if(result == true){
                            component.set("v.mifidCheckboxDisabled", false);
                        }else{
                            component.set("v.mifidCheckboxDisabled", true);
                            var cmpTarget = component.find('MifidInScope');
                            $A.util.addClass(cmpTarget, 'disabledCheckbox');
                        }

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
    		
    },*/

    /*checkForClone : function(component){
    	var _self = this;
        var validationResult = [];
		
		var cloneFrom = component.get("v.cloneFrom");
		console.log('cloneFrom: ' + cloneFrom);
		if(cloneFrom != null && cloneFrom != undefined && cloneFrom.startsWith('003')){
			var action = component.get("c.getContactDetails");

			action.setParams({
				'contactId' : cloneFrom
			});
	            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    result.sobjectType = 'Contact';
                    console.log('result: ' + result);
                    component.set("v.contact", result);
                    component.set("v.contact.Id", null);
                    console.log('RG_Account__c: ' + result.RG_Account__c);
                    var account  = [];
                    account.push(result.RG_Account__c);
                    console.log('RG: ' + account);
                    component.set("v.selectedAccount", account);
                    
                    component.find("newcontact-account").callPreSelect();
                    component.set("v.relatedToAccount", result.AccountId);
                    component.set("v.preSelectedAddressId", result.AccountId);
                    //component.find("addressCombobox").reinitialise();
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
    	
    		
    },*/

    showSpinner : function(component){   
        var spinner = component.find("pageSpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinner : function(component){  
        var spinner = component.find("pageSpinner");
        $A.util.addClass(spinner, "slds-hide");
    },

    doApplySponsor: function(component){
        var chosenId = component.get('v.selectedLookupId');
        var action = component.get("c.applySponsor");
        action.setParams({ "chosenId" : chosenId}); 
        action.setCallback(this,function(a){    
            var state = a.getState(); 
            if (state === "SUCCESS") { 
            	var result = a.getReturnValue();
	           	result.sobjectType = 'Contact';
                component.set("v.contact.Sponsor_Email_Text__c", result.Sponsor_Email_Text__c);
                component.set("v.contact.Sales_Sponsor__c", result.Sales_Sponsor__c);
            }
            else if (state === "INCOMPLETE") { 
                console.log("Response is not complete");
            } 
            else if (state === "ERROR") { 
            	var errors = a.getError(); 
                if(errors){ 
                    if (errors[0] && errors[0].message) { 
                    	console.log("Error message: " + errors[0].message);   
                    }  
                } 
                else{ 
                	console.log("Unknown error"); 
                } 
            } 
        }); 
        $A.enqueueAction(action);
    },

    defaultSponsor : function(component){
    	var _self = this;
        var validationResult = [];
		
		console.log('defaultSponsor');
		var action = component.get("c.getCurrentUserDetails");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    result.sobjectType = 'User';
                    console.log('result: ' + result.Email);
                    var userFullName = result.FirstName + ' ' + result.LastName;
                    component.set("v.contact.Sponsor_Email_Text__c", result.Email);
                	component.set("v.contact.Sales_Sponsor__c", userFullName);
                    
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

    toggleShowHideClass : function(component,event,secId) {
        var acc = component.find(secId);
        $A.util.toggleClass(acc, "slds-show");  
        $A.util.toggleClass(acc, "slds-hide"); 
    },
    //Added for JIRA SALES-3521 
    initialisePositionValues : function(component){
    	var action = component.get("c.getPositionPicklistValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            var types = [];
            if (state === "SUCCESS") {
                var results =  response.getReturnValue();
                console.log('results: ' + results);
                for(var k in results){
                    types.push(results[k].textVal);
                }
                console.log('results: ' + types);
                component.set("v.avaliableposition", types);              
            }});
        $A.enqueueAction(action);
    },

})