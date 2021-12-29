({
    readTemplateId : function(component)
    {
        var action = component.get("c.getSampleTemplateDownloadID");
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                var result = actionResult.getReturnValue();
                if(!$A.util.isUndefined(result)){
                    
                    for(var key in result){
                        if(key == 'coverageSampleTemplateBM'){
                            component.set("v.downloadTemplateId",'/servlet/servlet.FileDownload?file='+result[key]);
                            component.set("v.isCommentAccessible", true);
                        }
                        else if(key == 'coverageSampleTemplate'){
                            component.set("v.downloadTemplateId",'/servlet/servlet.FileDownload?file='+result[key]);
                        }
                        else if(key == 'coverageWithoutProductSampleTemplate'){
                            component.set("v.downloadCoverageWithoutProductTemplateId",'/servlet/servlet.FileDownload?file='+result[key]);
                        }
                        
                    }
                }

                
            }
            else if (state === "ERROR") {
                var errors = actionResult.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                        component.showAlert("error",errors[0].message);
                        component.hideSpinner();
                    }
                } else {
                    console.log("Unknown error");
                    component.showAlert("error","Unknown Error");
                    component.hideSpinner();
                }
            }
        });
        $A.enqueueAction(action); 
    },
    beginValidations : function(component) {
        var validate = component.get("c.processImportFromCSV");
        validate.setParams({
            "jsonStr" : component.get("v.JSONString")
        });
        validate.setCallback(this, function(actionResult) {
            
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                component.set("v.ErrorList", actionResult.getReturnValue());
                                component.set("v.errorMessageApex", component.get("v.ErrorList.exceptionMsg"));
                console.log('***: '+component.get("v.ErrorList.exceptionMsg"));
                if(component.get("v.ErrorList.exceptionMsg") != "")
                {
                    console.log(component.get("v.ErrorList.exceptionMsg"));
                    component.showAlert("error",component.get("v.ErrorList.exceptionMsg"));
                    component.hideValidateButton();
                    component.hideSpinner();
                }
                else
                {
                    component.set("v.successList", component.get("v.ErrorList.successRecords"));
                    component.set("v.rgDeleteList", component.get("v.ErrorList.rgRequestsToDelete"));
                    component.set("v.rmDeleteList", component.get("v.ErrorList.rmRequestsToDelete"));
                    component.set("v.totalFailed", component.get("v.ErrorList.totalFailed"));
                    component.set("v.totalCount", component.get("v.ErrorList.totalCount"));
                    component.set("v.totalWarning", component.get("v.ErrorList.totalWarning"));
                    console.log('Total Warning '+component.get("v.ErrorList.totalWarning"))
                    component.set("v.totalSuccess", component.get("v.ErrorList.totalSuccess"));
                    component.set("v.guid", component.get("v.ErrorList.guid"));
                    component.set("v.csvString", component.get("v.ErrorList.csvString"));
                    console.log('Total Failed: '+ component.get("v.ErrorList.totalFailed"));
                    console.log('Total Count: '+ component.get("v.ErrorList.totalCount"));
                    console.log('Total Success: '+ component.get("v.ErrorList.totalSuccess"));
                    console.log('CSV String: '+ component.get("v.csvString"));
                    console.log('Success List: '+ component.get("v.successList.length"));
                    component.OnNext();  
                    component.hideValidateButton();
                    component.hideMain();
                    component.showResult();
                    component.showActionButtons();
                    component.hideSpinner();
                }
                
            }
            else if (state === "ERROR") {
                var errors = actionResult.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                        component.showAlert("error",errors[0].message);
                        component.hideSpinner();
                    }
                } else {
                    console.log("Unknown error");
                    component.showAlert("error","Unknown Error");
                    component.hideSpinner();
                }
            }
        });
        $A.enqueueAction(validate); 
    },
    getPrevious : function(component) {
        console.log('On Prev Called');
        var requestedList=new Array();
        var wrapperList =  component.get("v.ErrorList");
        var coverageList = wrapperList.coverageRecords;
        var size = coverageList.length;
        var index = component.get("v.index");
        var setPageSize = component.get("v.pageSize");
        console.log('Index: '+index);
        console.log('coverageList lengtn: '+size);
        
        if(index == size)
        {
            var modValue = size % setPageSize;
            if(modValue > 0)
            {    
                index = size - modValue;
            }
            else
            {
                index = (size - setPageSize);
            } 
        }
        else
        {
            index = (index - setPageSize);
        }
        console.log('From Number: '+(index - setPageSize));
        component.set("v.fNumber",(index - setPageSize)+1);
        component.set("v.TNumber",index);
        component.set("v.index",index);
        
        for(var start = (index - setPageSize); start < index; ++start)
        {
            requestedList.push(coverageList[start]);
        } 
        if(requestedList.length>=1)
            component.set("v.displayErrorList", requestedList);
        
        
        component.hideSpinner();
    },
    getNext : function(component) {
        console.log('On Next Called');
        var requestedList=new Array();
        var startNumber = 0;
        var wrapperList =  component.get("v.ErrorList");
        var coverageList = wrapperList.coverageRecords;
        var size = coverageList.length;
        var index = component.get("v.index");
        var setPageSize = component.get("v.pageSize");
        var fromNumber = component.get("v.fNumber");
        var ToNumber = component.get("v.TNumber");
        console.log('index component' + index);
        console.log('wrapperList component' + coverageList.length);
        if(index <= coverageList.length)
        {
            if(size <= (index + setPageSize))
            {
                startNumber = index;
                index = size;
            }
            else
            {
                index = (index + setPageSize);
                startNumber = (index - setPageSize);
            }
            
            console.log('i value is =====' + index);
            console.log('i value is 2==== ' + (index - setPageSize));
            
            
            component.set("v.fNumber",startNumber+1);
            component.set("v.TNumber",index);
            component.set("v.index",index);
            
            for(var start = startNumber; start < index; start++)
            {
                requestedList.push(coverageList[start]);
            }
            console.log('Requested length: '+requestedList.length);
            if(requestedList.length>=1)
                component.set("v.displayErrorList", requestedList);
        }
        component.hideSpinner();
    },
    stageData : function(component) {
        var successList = component.get("v.successList");
        for(var i = 0; i < successList.length; i++)
        {
            successList[i].sobjectType = 'Coverage_Temp__c';
        }
       console.log(successList);
       var action = component.get("c.submitPartialData");
         action.setParams({
            "successList" : successList,
             "rgRequestsToDelete":component.get('v.rgDeleteList'),
             "rmRequestsToDelete":component.get('v.rmDeleteList'),
             "totalCount" : component.get("v.totalCount"),
             "guid1" : component.get("v.guid")
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                var resultString = actionResult.getReturnValue();
                if(resultString.search("submitted")!=-1)
                {
                    component.showAlert("success",resultString);
                    //component.hideSpinner();
                }
                else
                {
                    component.showAlert("error",resultString);
                    //component.hideSpinner();
                }
            }
            else if (state === "ERROR") {
                var errors = actionResult.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                        component.showAlert("error",errors[0].message);
                        //component.hideSpinner();
                    }
                } else {
                    console.log("Unknown error");
                    component.showAlert("error","Unknown Error");
                    //component.hideSpinner();
                }
            }
            var cmpPartial = component.find('partialBtn');
            $A.util.addClass(cmpPartial, 'slds-hide');
            var cmpSubmit = component.find('SuccessBtn');
            $A.util.addClass(cmpSubmit, 'slds-hide');
            component.hideSpinner();
        });
         $A.enqueueAction(action);
    }
})