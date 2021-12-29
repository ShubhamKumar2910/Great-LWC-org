({
	navigateToMifidIIDetail : function(component, event){
        var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:AccountMifidIIDetail",
                componentAttributes: {
                    parentAccountId : component.get("v.recordId")
                }
            });
            evt.fire();
    },

    navigateToBulkUpdate : function(component, event){
        var strURL = "/lightning/n/MiFID_II_Flags_Bulk_Update";
            if(strURL != null){
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": strURL,
                    "isredirect	":true
                });
                urlEvent.fire();
        }
    },

    navigateToMifidContactsWithSubs : function(component, event){
        var reportId = component.get("v.contactsWithSubsReportId");
        var accountName = component.get("v.URIEncodedAccountName");
        var strURL = "/one/one.app#/sObject/" + reportId + "/view?fv0=\"" + accountName + "\"&fv4=\"" + accountName + "\"";

        console.log('navigateToMifidContactsWithSubs' + strURL);
            if(strURL != null){
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": strURL,
                    "isredirect ":true
                });
                urlEvent.fire();
        }
    } ,

    navigateToMifidContactsWithoutSubs : function(component, event){
        var reportId = component.get("v.contactsWithoutSubsReportId");

        var accountName = component.get("v.URIEncodedAccountName");
        var strURL = "/one/one.app#/sObject/" + reportId + "/view?fv0=\"" + accountName + "\"&fv4=\"" + accountName + "\"";

        console.log('navigateToMifidContactsWithoutSubs' + strURL);
            if(strURL != null){
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": strURL,
                    "isredirect ":true
                });
                urlEvent.fire();
        }
    } ,

    navigateToNonMiFIDIIContactsWithRestrProdENT : function(component, event){
        var reportId = component.get("v.nonMiFIDIIContactsWithRestrProdENT");
        var accountId = component.get("v.recordId");
        var strURL = "/one/one.app#/sObject/" + reportId + "/view?fv0=" + accountId + "&fv1=" + accountId;

        console.log('navigateToNonMiFIDIIContactsWithRestrProdENT' + strURL);
        if(strURL != null){
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": strURL,
                "isredirect ":true
            });
            urlEvent.fire();
        }
    } ,

    navigateToNonMiFIDIIContactsWithGRPAndProdENT : function(component, event){
        var reportId = component.get("v.nonMiFIDIIContactsWithGRPAndProdENT");
        var accountId = component.get("v.recordId");
        var strURL = "/one/one.app#/sObject/" + reportId + "/view?fv0=" + accountId + "&fv1=" + accountId;

        console.log('navigateToNonMiFIDIIContactsWithGRPAndProdENT' + strURL);
        if(strURL != null){
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": strURL,
                "isredirect ":true
            });
            urlEvent.fire();
        }
    } ,
    //Changes for JIRA -3698
    navigatetoNFPEChampion : function(component){
        var reportId = component.get("v.NFPEChampionReportId");
        var accountName = component.get("v.URIEncodedAccountName");
        console.log('accountName ::'+accountName);
        //var accountId = component.get("v.recordId");
        var strURL = "/one/one.app#/sObject/" + reportId + "/view?fv1=\"" + accountName + "\"";

        console.log('NFPEChampionReportId' + strURL);
        if(strURL != null){
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": strURL,
                "isredirect ":true
            });
            urlEvent.fire();
        }
    },
    initialiseReportIdLinks : function(component){
        var validationResult = [];
        var action = component.get("c.getAccountReportInformation");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
                if (state === "SUCCESS") {
                    var results = {};
                    results =  response.getReturnValue();
                    //console.log(results);
                    Object.entries(results).forEach(([key, value]) => {
                            //console.log('Key: ' + key);
                            //console.log('value: ' + value);
                            if(key.startsWith("MiFID_II_Contacts_with_Research_Subs")){
                                component.set("v.contactsWithSubsReportId", value);
                            }
                            if(key.startsWith("MiFID_II_Contacts_w_o_Research_Subs")){
                                component.set("v.contactsWithoutSubsReportId", value);
                            }
                            if(key.startsWith("NonMiFIDII_Contacts_with_Restricted_PE")){
                                component.set("v.nonMiFIDIIContactsWithRestrProdENT", value);
                            }
                            if(key.startsWith("NonMiFIDII_Contacts_with_GRP_and_PE")){
                                component.set("v.nonMiFIDIIContactsWithGRPAndProdENT", value);
                            } 
                             //Changes for JIRA -3698
                            if(key.startsWith("Accounts_with_Sales_Champions")){
                                component.set("v.NFPEChampionReportId", value);
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
                } else {console.log("Unknown error");}
                }
            });

                $A.enqueueAction(action);
            
    }, 

    initialiseAccountInformation : function(component){
        var validationResult = [];
        var action = component.get("c.getAccountInformation");
        
        action.setParams({
            "accountId" :  component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
                if (state === "SUCCESS") {
                   
                    var result =  response.getReturnValue();
                    result.sobjectType = 'Account'; 
 
                    //var accountName = encodeURI(result.Name);
                    var accountName = encodeURIComponent(result.Name.trim());
                    var recTypeAPIName = result.RecordType.DeveloperName;

                    component.set("v.URIEncodedAccountName", accountName);
                    component.set("v.recordTypeAPIName", recTypeAPIName);

                    var cautionClientInfoAndInputDate = '';
                    var cautionClientInfoValue = '';
                    var cautionClientInputDate = '';

                    if(recTypeAPIName == 'RM_Account') {
                        component.set("v.isCautionClient", result.Parent.Caution_Client__c);
                        cautionClientInfoValue = result.Parent.Caution_Client_Info__c;
                        cautionClientInputDate = result.Parent.CautionClientInputDate__c;
                        
                    }
                    else {
                        component.set("v.isCautionClient", result.Caution_Client__c);
                        cautionClientInfoValue = result.Caution_Client_Info__c;
                        cautionClientInputDate = result.CautionClientInputDate__c;
                    }

                    //Merging Caution Client Info and Caution Client Input Date
                    var appendCautionClientInputDate = false;
                    var cautionClientInputDatePresent = (cautionClientInputDate != null && cautionClientInputDate != '') ? true : false;
                    
                    if(cautionClientInfoValue != null && cautionClientInfoValue != ''){
                        cautionClientInfoAndInputDate = cautionClientInfoValue;
                        if(cautionClientInputDatePresent == true){
                            appendCautionClientInputDate = true;
                        }
                    }
                    else {
                        if(cautionClientInputDatePresent == true){
                            appendCautionClientInputDate = true;
                        }
                    }

                    if(appendCautionClientInputDate == true){
                        cautionClientInfoAndInputDate = cautionClientInfoAndInputDate + '\n\n ' + 'Caution Client Input Date : ' + cautionClientInputDate;
                    }

                    component.set("v.CautionClientInfo", cautionClientInfoAndInputDate);

                    console.log("result.MiFIDII_in_Scope__c : ",result.MiFIDII_in_Scope__c);
                    if(result.MiFIDII_in_Scope__c===true) {
                    	component.set("v.rollupMiFIDIIInScope", "Yes");	
                    } else {
                    	component.set("v.rollupMiFIDIIInScope", "No");
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
                } else {console.log("Unknown error");}
                }
            });

                $A.enqueueAction(action);
            
    },
        
	getNFPEDetails : function(component){
        var validationResult = [];
        var accountId = component.get("v.recordId");
        var action = component.get("c.getAccountNFPEDetails");
            action.setParams({
                    "accountId" : accountId
                });

                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var result =  response.getReturnValue();
                        console.log("---nfpe start---"); 
                        var jsonResult = JSON.parse(result);
                        console.log(jsonResult.accountChampions);
                        console.log(jsonResult.isNFPE);
                        console.log("---nfpe end---");
                        component.set("v.NFPEAccountChampion", jsonResult.accountChampions);
                        component.set("v.isNFPE", jsonResult.isNFPE);
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

    getProductSubscriptions : function(component){
        var validationResult = [];
        var accountId = component.get("v.recordId");
        var action = component.get("c.getAccountProductSubscriptions");
            action.setParams({
                    "accountId" : accountId
                });

                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var result =  response.getReturnValue();
                        component.set("v.productSubscriptions", result);
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

    isUserEligibleForBulkUpdate : function(component){
        var validationResult = [];
        var action = component.get("c.getUserEligibilityForBulkUpdate");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result =  response.getReturnValue();
                component.set("v.showBulkUpdateButton", result);
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

    setShowCautionClientInfo : function(component)
    {
        console.log("setShowCautionClientInfo start");
        var accountId = component.get("v.recordId");
        var action = component.get("c.isUserOnCoverageForAccount");   
            action.setParams({
                "accountId" : accountId
            }); 
        action.setCallback(this, function(response) {
            console.log("setShowCautionClientInfo setCallback" + state);
            var state = response.getState();
            if (state === "SUCCESS") {
                var result =  response.getReturnValue();
                console.log("setShowCautionClientInfo result:" + result);
                component.set("v.ShowCautionClientInfo", result);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log("setShowCautionClientInfo error:" + result);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        validationResult.push({
                                    message :  errors[0].message
                                });
                        component.set("v.hasErrors", true);
                        component.set("v.errorMessages", validationResult);
                        document.body.scrollTop = document.documentElement.scrollTop = 0;
                        
                    }
                } 
                else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
        console.log("setShowCautionClientInfo end");
    }

})