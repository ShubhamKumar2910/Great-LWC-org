({
    updateContacts : function(component) {
        var _self = this;
        var mifid2scope = component.get("v.selectedScope");
        var salesCommentary = component.get("v.selectedSalesCommentary");
        var batch = component.get("v.batchSize");
        console.log('batch: ' + batch);
        var emailList = [];
        var grpAccess = component.get("v.selectedGRPAccess");
        var qdiiAccess = component.get("v.selectedQDIIAccess");
        var serviceType = component.get("v.selectedServiceType");
        var productsToAdd = component.get("v.productsToAddItems");
        var productsToRemove = component.get("v.productsToRemoveItems");
        var preferredLanguage = component.get("v.selectedLanguage");
        var region = component.get("v.selectedRegion");
        var investorType = component.get("v.selectedInvestorType");
        var sponsor = component.get("v.setSponsor");
        var sponsorEmail = component.get("v.setSponsorEmail");
        var updateSponsor = component.get("v.updateSponsor");

        emailList = _self.convertEmailListToArray(component);
        console.log('region: ' + region);
        _self.showSpinner(component);
        var overBatchSize = _self.checkBatchUpdateSize(component, emailList, mifid2scope);
        component.set("v.errorResults", overBatchSize);
        //console.log(overBatchSize);
        _self.getContacts(component, emailList, mifid2scope, salesCommentary, batch, grpAccess, qdiiAccess, serviceType, productsToAdd, preferredLanguage, region, investorType, sponsor, sponsorEmail, updateSponsor);
        component.set("v.emailAddressInput", "");
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
                component.set("v.setSponsorEmail", result.Sponsor_Email_Text__c);
                component.set("v.setSponsor", result.Sales_Sponsor__c);
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
    showResultsTable:function(component){
        component.set("v.showResults", true);
    },

    hideResultsTable:function(component){
        component.set("v.showResults", false);
    },

    showSpinner:function(component){
        component.set("v.showSpinner", true);
    },

    hideSpinner:function(component){
        component.set("v.showSpinner", false);
    }, 

    escapeRegExp: function(str) {
        return str.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1");
    },

    replaceAll : function(str, find, replace) {
        var _self = this;
        return str.replace(new RegExp(_self.escapeRegExp(find), 'g'), replace);
    }, 

    checkBatchUpdateSize : function(component, emailList, mifid2scope){
        var batch = component.get("v.batchSize");
        var action = component.get("c.checkBatchSize");

        action.setParams({
            "emails": emailList, 
            "mifid2scope": mifid2scope, 
            "batchSize": batch
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();

                console.log(result);
                
                component.set("v.errorResults", result);
                //console.log(result.length);
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

    getContacts: function (component, emailList, mifid2scope, salesCommentary, batchSize, grpAccess, qdiiAccess, serviceType, productsToAdd, preferredLanguage, region, investorType, sponsor, sponsorEmail, updateSponsor){
        var _self = this;
        var action = component.get("c.getContactsFromEmails");
        console.log('region:' + region);
        console.log(serviceType);
        action.setParams({
            "emails": emailList, 
            "mifid2scope": mifid2scope, 
            "salesCommentary": salesCommentary, 
            "batchSize" : 300,
            "grpAccess" : grpAccess,
            "qdiiAccess": qdiiAccess,
            "serviceType" : serviceType,
            "productsToAdd" : productsToAdd, 
            "preferredLanguage" : preferredLanguage,
            "region" : region,
            "investorType" : investorType,
            "sponsor" : sponsor,
            "sponsorEmail" : sponsorEmail,
            "updateSponsor" : updateSponsor
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();

                //console.log(result);
                var successes = [];

                for (let [key, value] of Object.entries(result)) {  
                  //console.log(key + ':' + value);

                  if(key == 'Success'){
                    component.set("v.successfullResults", value);
                  }else{
                    if(key == 'Errors'){
                        component.set("v.errorResults", value);
                    }
                  }
                }
                

                _self.hideSpinner(component);
                _self.showResultsTable(component);
                
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

    convertEmailListToArray : function(component){
        var emails = component.get("v.emailAddressInput");
        var emailList = [];

        if(emails.length > 0){
            
            emails = emails.trim();  
            emails = emails.replace(" ", "");    
            emails = emails.replace("\r\n\r\n", "\r\n");
            emails = emails.replace(/[\n\r]/g, ',');
            emails = emails.replace('^\\s*\\n', ''); 

            // get list of contact from search box (by ',' or line break)
            if(emails.includes(',')){
                emailList = emails.split(',');  
            }
            else{
                emailList = emails.split('\r\n');   
            }
        }

        //console.log(emailList);

        return emailList;
    }

    ,

    retryfailures : function(component){
        var _self = this;
        var errors = [];
        console.log('Before');
        errors = component.get("v.errorResults");
        console.log(errors);
        console.log('After');
        var emailArray = [];

        for(var key in errors){
            if(errors[key].contactEmail != undefined && (errors[key].contactEmail != null || errors[key].contactEmail != '' || errors[key].contactEmail != "" )){
                emailArray.push(errors[key].contactEmail);
            }
        }
        //console.log(emailArray);

        component.set("v.emailAddressInput", emailArray.toString());

        _self.hideResultsTable(component);
    }, 

    initialistProductSubscriptions : function(component){

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

    }, 

})