({
    fetchResults: function(component,isInit){
        component.set("v.coverageData", [{}]);
        component.set("v.coverageColumns", [{}]);
        if(!$A.util.isUndefinedOrNull(coverage_helper_util))
            coverage_helper_util.fetchSearchResults(component,isInit);
    },
    createBulkformat: function(component,tableAuraId,operation)
    {
        if(!$A.util.isUndefinedOrNull(coverage_helper_util))
        coverage_helper_util.createBulkformat(component,tableAuraId,operation);
    },
    validateCloneData : function(component,prevButton,nextButton,fromsalesPerson,tosalesPerson,dataObject){
        if(dataObject.length == 0)
        {
            component.showToast('','error','Please select coverage information to be cloned.');
            component.hideSpinner();
        }
        else
        {
            var dataSel = component.get('v.selectedData');
            
            if(!$A.util.isUndefinedOrNull(dataSel)){
                if(dataSel.length == 0){
                    component.showToast('','error','Please select a coverage record to proceed.');
                    return;
                }
            }
            else
            {
                component.showToast('','error','Please select a coverage record to proceed.');
                return;
            }
            
            console.log('Cloning coverage.....');
            console.log(component.get('v.fromsalesPersons'));
            component.showSpinner();
            // call the server side function  
            var action = component.get("c.cloneCoverage");
            
            var fromSalesCodes = new Array();
            
            var fromspersonIds = component.get('v.fromsalesPersonIDs');
            for(var i = 0; i < fromspersonIds.length; i++){
                fromSalesCodes.push(fromspersonIds[i].salesCode);
            }
            
            var tospersonIds = component.get('v.tosalesPersonIDs');
            var toSalesCodes = new Array();
            for(var i = 0; i < tospersonIds.length; i++){
                toSalesCodes.push(tospersonIds[i].salesCode);
            }
            
            console.log(fromSalesCodes);
            console.log(toSalesCodes);
            var wparams = {
                'jsonstring' : JSON.stringify(dataSel),
                'fromSalesCodes' :fromSalesCodes,
                'toSalesCodes' : toSalesCodes
            };
            action.setParams(wparams);
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    console.log('verify success');
                    var resultdata = response.getReturnValue();
                    console.log(resultdata);
                    var successRecords = resultdata.successRecords;
                    var rgRequestsToDelete = resultdata.rgRequestsToDelete;
                    var rmRequestsToDelete = resultdata.rmRequestsToDelete;
                    var allRecords = resultdata.coverageRecords;
                    var totalCount = resultdata.totalCount;
                    var guid = resultdata.guid;
                    if(resultdata.exceptionMsg != "")
                    {
                        component.showToast('','error',resultdata.exceptionMsg);
                        component.hideSpinner();
                    }
                    else
                    {
                        component.set("v.successList", successRecords);
                        console.log(rgRequestsToDelete);
                        component.set("v.rgDeleteList", rgRequestsToDelete);
                        console.log(rgRequestsToDelete);
                        component.set("v.rmDeleteList", rmRequestsToDelete);
                        component.set("v.totalFailed", resultdata.totalFailed);
                        component.set("v.totalCount", resultdata.totalCount);
                        component.set("v.totalWarning", resultdata.totalWarning);
                        component.set("v.totalSuccess", resultdata.totalSuccess);
                        component.set("v.guid",guid);
                        
                        var coverageData = new Object();
                        var wrapperList = new Array();
                        var rgwrapperList = new Array();
                        var rmwrapperList = new Array();
                        var counter = 0;
                        for(var i = 0; i < allRecords.length; i++)
                        {
                            
                            coverageData = new Object();
                            if(allRecords[i].IsRG)
                            {
                                coverageData.clientRG = allRecords[i].clientName;
                                
                                coverageData.clientRGId = allRecords[i].accountId;
                                coverageData.clientRM = '';
                                coverageData.clientRMId = '';
                                coverageData.rgOrgID = allRecords[i].clientRGKey;
                                coverageData.rmRestricted = false;
                            }
                            else
                            {
                                coverageData.clientRG = '';
                                coverageData.clientRGId = '';
                                coverageData.clientRM = allRecords[i].clientName;
                                coverageData.clientRMId = allRecords[i].accountId;
                                coverageData.rmOrgID = allRecords[i].clientKey;
                                coverageData.rmRestricted = true;
                            }
                            
                            if(allRecords[i].IsRG)
                                coverageData.accountName = allRecords[i].clientName;
                            else
                                coverageData.accountName='('+allRecords[i].BillingCountryCode+'-Restricted Jurisdiction) - '+allRecords[i].clientName;
                            
                            //coverageData.accountName = '(Restricted) - '+allRecords[i].clientName;
                            
                            coverageData.product = allRecords[i].productName;
                            coverageData.productGroup = allRecords[i].productGroup;
                            coverageData.productRegion = allRecords[i].productRegion;
                            coverageData.role = allRecords[i].role;
                            coverageData.salesCodeID =  allRecords[i].salesCodeID;
                            coverageData.salesPerson = allRecords[i].salesPerson;
                            coverageData.coverageID = allRecords[i].salesCode;
                            coverageData.startDate = allRecords[i].fromDate;
                            coverageData.team = allRecords[i].salesTeam;
                            coverageData.Comments = allRecords[i].errorMessage;
                            coverageData.errorType = allRecords[i].errorType;
                            if(allRecords[i].containsError)
                            {
                                coverageData.containsError = true;
                                
                                if(allRecords[i].errorType == 'error')
                                {
                                    coverageData.status = 'Pending'; // to make row unselectable
                                    coverageData.isChecked = false;
                                    
                                }
                                else if(allRecords[i].errorType == 'warning')
                                {
                                    coverageData.isChecked = false;
                                }
                                
                            }
                            else
                            {
                                coverageData.isChecked = true;
                                coverageData.containsError = false;
                            }
                            
                            if(allRecords[i].IsRG)
                            {
                                rgwrapperList.push(coverageData);
                            }
                            else
                            {
                                rmwrapperList.push(coverageData);
                            }
                            //wrapperList.push(customData);
                        }
                        
                        for(var i = 0; i < rmwrapperList.length; i++)
                        {
                            rmwrapperList[i].key = counter; 
                            wrapperList.push(rmwrapperList[i]);
                            counter++;
                        }
                        for(var i = 0; i < rgwrapperList.length; i++)
                        {
                            rgwrapperList[i].key = counter;
                            wrapperList.push(rgwrapperList[i]);
                            counter++;
                        }
                        
                        rgwrapperList.length = 0;
                        rmwrapperList.length = 0;
                        console.log('validationTable Rows:');
                        console.log(wrapperList);
                        if(wrapperList.length > 0)
                        {
                            var prevButton = component.find("prevButton");
                            var nextButton = component.find("nextButton");
                            prevButton.set("v.label",component.get("v.prevButton_label"));
                            prevButton.set("v.iconName","utility:back");
                            
                           
                                            component.set("v.validationCoverageColumns", [            		
                                                {label: component.get("v.account_label"), fieldName:"accountName", type:"text", initialWidth:211, sortable:true},
                                                {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:133, sortable:true},
                                                {label: component.get("v.product_label"), fieldName:"product", type:"text", initialWidth:133, sortable:true},
                                                {label: component.get("v.productRegion_label"), fieldName:"productRegion", type:"text", initialWidth:164, sortable:true},
                                                {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:111, sortable:true},
                                                {label: component.get("v.startdate_label"), fieldName:"startDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:120, sortable:true},
                                                {label: component.get("v.validationStatus_label"), fieldName:"Comments", type:"text", initialWidth:373, sortable:true}
                                            ]); 
                                            //}
                                            
                                            component.set('v.validationCoverageData',wrapperList);
                                            component.set("v.setWizardStep","Save");
                                            component.switchWizardStep("Save");
                                            
                                            if(successRecords.length>0)
                                            {
                                                nextButton.set("v.label",component.get("v.saveButton_label")); 
                                                nextButton.set("v.iconName","utility:save");
                                                
                                                $A.util.removeClass(nextButton,'slds-hide');
                                            }
                                            else
                                            {
                                                $A.util.addClass(nextButton,'slds-hide');
                                            }
                                            
                                            
                                            
                                            component.showValidationDatatable();
                                        }
                                        else
                                        {
                                            component.hideValidationDatatable();
                                            
                                        }
                                        
                                        component.hideSpinner();
                                    }
                                }
                                else if (response.getState() === "INCOMPLETE") {
                                    console.log('In incomplete');
                                    component.showToast('error','error','No response from server or client is offline.');
                                    component.hideDatatable();
                                }
                                    else if (response.getState() === "ERROR") {
                                        var errors = response.getError();
                                        console.log('ERRORS');
                                        console.log(errors);
                                        if(errors){
                                            if(errors[0] && errors[0].message){
                                                component.showToast('','error',errors[0].message);
                                                console.log("Error message:" + errors[0].message);
                                            }
                                        }
                                        else{
                                            console.log("Unknown error");
                                            component.showToast('','error','Unknown error');
                                        }                
                                    }
                                component.hideSpinner();
                            });
                            $A.enqueueAction(action);
         }
    },
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.coverageData");
        var validationdata = cmp.get("v.validationCoverageData");
        var reverse = sortDirection !== 'asc';
        if(cmp.get("v.setWizardStep") == 'Select')
        {
            //sorts the rows based on the column header that's clicked
            data.sort(this.sortBy(fieldName, reverse));
            cmp.set("v.coverageData", data);
        }
        else {
            validationdata.sort(this.sortBy(fieldName, reverse));
            cmp.set("v.validationCoverageData", validationdata);
        }
            
        
        
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    isUserFISales : function(component)
    {
        if(!$A.util.isUndefinedOrNull(coverage_helper_util))
            coverage_helper_util.isUserFISales(component);
    },
    submitData: function(component,successlist,rgDeleteList,rmDeleteList,totalCount,guid){
        if(!$A.util.isUndefinedOrNull(coverage_helper_util))
        coverage_helper_util.submitData(component,successlist,rgDeleteList,rmDeleteList,totalCount,guid);
    }
})