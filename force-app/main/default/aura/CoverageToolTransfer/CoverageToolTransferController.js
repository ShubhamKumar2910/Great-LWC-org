({
    doInit : function(component, event, helper) { 
        
        console.log(component.get('v.isCommentAccessible'));
        
        component.set('v.addCoverageColumns',new Array());
        if(component.get('v.isCommentAccessible') == 'true' || component.get('v.isCommentAccessible') == 'true:rw'){
            component.set("v.addCoverageColumns", [
                /*{label: component.get("v.ApprovalRequest"), fieldName:"ApprovalRequest", type:"text", initialWidth:150},*/
                {label: component.get("v.salesPerson"), fieldName:"salesPerson", type:"text", initialWidth:150, sortable:true},
                {label: component.get("v.accountName"), fieldName:"accountName", type:"text", initialWidth:150, sortable:true},
                {label: component.get("v.productRegion"), fieldName:"productRegion", type:"text", initialWidth:125, sortable:true},
                {label: component.get("v.product"), fieldName:"product", type:"text", initialWidth:150, sortable:true},
                {label: component.get("v.UserComments"), fieldName:"userComments", type:"text", initialWidth:150, sortable:true},  
                {label: component.get("v.role"), fieldName:"role", type:"text", initialWidth:125, sortable:true},
                {label: component.get("v.startDate"), fieldName:"startDate", type:"text", initialWidth:125, sortable:true},
                {label: component.get("v.transferTo"), fieldName:"transferTo", type:"text", initialWidth:150, sortable:true},                            
                {label: component.get("v.newStartDate"), fieldName:"newStartDate", type:"text", initialWidth:125, sortable:true},
                {label: component.get("v.Comment"), fieldName:"Comments", type:"text", initialWidth:125, sortable:true}
                
            ]); 
        }
        else
        {
            
            
            component.set("v.addCoverageColumns", [
                /*{label: component.get("v.ApprovalRequest"), fieldName:"ApprovalRequest", type:"text", initialWidth:150},*/
                {label: component.get("v.salesPerson"), fieldName:"salesPerson", type:"text", initialWidth:150, sortable:true},
                {label: component.get("v.accountName"), fieldName:"accountName", type:"text", initialWidth:150, sortable:true},
                {label: component.get("v.productRegion"), fieldName:"productRegion", type:"text", initialWidth:125, sortable:true},
                {label: component.get("v.product"), fieldName:"product", type:"text", initialWidth:150, sortable:true},
                {label: component.get("v.role"), fieldName:"role", type:"text", initialWidth:125, sortable:true},
                {label: component.get("v.startDate"), fieldName:"startDate", type:"text", initialWidth:125, sortable:true},
                {label: component.get("v.transferTo"), fieldName:"transferTo", type:"text", initialWidth:150, sortable:true},                            
                {label: component.get("v.newStartDate"), fieldName:"newStartDate", type:"text", initialWidth:125, sortable:true},
                {label: component.get("v.Comment"), fieldName:"Comments", type:"text", initialWidth:125, sortable:true}
                
            ]);
        }
        
        component.set('v.validationCoverageColumns',new Array());
        component.set("v.validationCoverageColumns", [
            /*{label: component.get("v.ApprovalRequest"), fieldName:"ApprovalRequest", type:"text", initialWidth:150},*/
            
            {label: component.get("v.accountName"), fieldName:"accountName", type:"text", initialWidth:150, sortable:false},
            {label: component.get("v.transferFrom"), fieldName:"transferFrom", type:"text", initialWidth:150, sortable:false},                
            {label: component.get("v.transferTo"), fieldName:"transfer", type:"text", initialWidth:150, sortable:false},                                            
            {label: component.get("v.productRegion"), fieldName:"productRegion", type:"text", initialWidth:150, sortable:false},
            {label: component.get("v.product"), fieldName:"product", type:"text", initialWidth:200, sortable:false},
            {label: component.get("v.role"), fieldName:"role", type:"text", initialWidth:125, sortable:false},
            {label: component.get("v.startDate"), fieldName:"startDate", type:"text", initialWidth:125, sortable:false},
            {label: component.get("v.validationStatus_label"), fieldName:"Comments", type:"text", initialWidth:125, sortable:false}
            
        ]);
        
        
        component.showSpinner();
        
        console.log(component.get("v.transferData"));
        //component.set('v.level','Client');
        var today = new Date();
        var monthDigit = today.getMonth() + 1;
        if (monthDigit <= 9) {
            monthDigit = '0' + monthDigit;
        }
        var dayDigit = today.getDate();
        if(dayDigit <= 9){
            dayDigit = '0' + dayDigit;
        }
        component.set('v.CoverageStartDate', today.getFullYear() + "-" + monthDigit + "-" + dayDigit);
        var filter = [];
        var filterproperty = new Object();
        var dataObject = component.get('v.transferData');
        console.log(component.get('v.transferData'));
        var dtValue = component.get('v.CoverageStartDate');
        var rows = [];
        if(dataObject.length == 1){
            dataObject[0].endDate = dtValue;
            dataObject[0].isChecked = true;
            filterproperty.coverageID = dataObject[0].coverageID;
            filterproperty.rgOrgID = dataObject[0].rgOrgID;
            filterproperty.RGId = dataObject[0].clientRGId;
            filterproperty.Type = dataObject[0].Type;
            if(component.get('v.level') == 'Product'){
                filterproperty.product = dataObject[0].product;
                filterproperty.productGroup = dataObject[0].productGroup;
                filterproperty.productRegion = dataObject[0].productRegion;
            }
            filter.push(filterproperty);
            rows.push(dataObject[0].Id);
        }
        
        else
        {
            for (var i = 0 ; i < dataObject.length; i++){
                dataObject[i].isChecked == true
                dataObject[i].endDate = dtValue;
                filterproperty.coverageID = dataObject[i].coverageID;
                filterproperty.rgOrgID = dataObject[i].rgOrgID;
                filterproperty.RGId = dataObject[i].clientRGId;
                filterproperty.Type = dataObject[i].Type;
                if(component.get('v.level') == 'Product'){
                    filterproperty.product = dataObject[i].product;
                    filterproperty.productGroup = dataObject[i].productGroup;
                    filterproperty.productRegion = dataObject[i].productRegion;
                }
                filter.push(filterproperty);
                filterproperty = new Object();
                rows.push(dataObject[i].Id);
                
            }
        }
        var action = component.get("c.getProductLevelData");
        var recordType = component.get("v.recordType");
        action.setParams({"cmpfilter" : JSON.stringify(filter),
                          "cmpRecordType" : recordType,
                          "level": component.get('v.level'),
                          "isClone":false,
                          "isUpdate" : false}); 
        action.setCallback(this,function(response){
            var state = response.getState();    
            console.log(response.getReturnValue());
            if(state === "SUCCESS"){
                var responseMap = response.getReturnValue(); 
                component.set('v.addCoverageData',new Array());
                component.set('v.addCoverageData',responseMap); 
                var data = component.get('v.transferData');
                var dataServer = component.get('v.addCoverageData');
                component.set('v.addCoverageData',dataServer);
                component.set('v.transferData',dataServer);
                component.set('v.selectedData',new Array());
                var selRows = [];
                selRows = dataServer[0].selectedKeys;  
                console.log('selRows 1');
                console.log(selRows);
                component.set('v.selectedRows', new Array());
                component.set('v.selectedRows', selRows);
                component.set('v.selectedData',dataServer);
                component.showDatatable();
            }
            component.hideSpinner();
        });
        $A.enqueueAction(action);
    },
    ApplyDateAndSalesPerson : function(component,event,helper){
        
        var salesPerson = component.get('v.salesPersonIDs');
        var dtValue = component.get('v.CoverageStartDate');
        var attestFlagValue = component.get("v.attestFlag");
        console.log(attestFlagValue);
        var dataObject = component.get('v.transferData');
        var companyRegionCheck = false;
        console.log(dataObject);
        if(salesPerson.length == 0){
            console.log('in if condition');
            component.showToast('','error','Please select salesperson(s) and then apply');
            component.set('v.isButtonEnabled',true);
        }
        else
        { 
            var dataSel = component.get('v.selectedData');
            var toSalesPersons = Object.values(salesPerson);
            for(var i = 0; i < toSalesPersons.length; i++) {
                if((coverage_helper_util.mandatoryPrimaryAttestRegion).indexOf(toSalesPersons[i]['salesDeskRegion'])>-1 && (coverage_helper_util.company).indexOf(toSalesPersons[i]['company'])>-1)
                   companyRegionCheck = true;
            }

            if(!$A.util.isUndefinedOrNull(dataSel)){
                if(dataSel.length == 0){
                    component.showToast('','error','Please select a coverage record to proceed.');
                    return;
                }
                else
                {                      
                if(companyRegionCheck && !component.get("v.attestFlag")) {                
                for(var index = 0; index < dataSel.length; index++)
                {
                        if((coverage_helper_util.userRole).indexOf(dataSel[index].role)>-1) {
                            component.showToast('','error','Please attest primary coverage.');
                            return;
                        }
                }
                }
                }    
            }
        else
        {
            component.showToast('','error','Please select a coverage record to proceed.');
            return;
        }
         
         component.showSpinner();
         console.log(salesPerson);            
         dataObject.forEach(function (v){delete v.selectedKeys});
         console.log('modifiedData');
         console.log(dataObject);
         console.log('JSON');
         console.log(JSON.stringify(dataObject));
         var action = component.get("c.getUpdatedData");
         action.setParams({"cmpSalesPerson" : JSON.stringify(salesPerson),
                           "cmpdataObject" : JSON.stringify(dataObject) ,
                           "cmpEndDate" : dtValue,
                           "cmpIsAttested" : attestFlagValue}); 
         
         action.setCallback(this,function(response){ 
             var state = response.getState();            
             if(state === "SUCCESS"){
                 var responseMap = response.getReturnValue(); 
                 
                 console.log('hi in getUpdatedData');
                 console.log(responseMap);
                 component.set('v.addCoverageData',new Array());
                 
                 component.set('v.selectedData',new Array());
                 component.set('v.addCoverageData',responseMap); 
                 
                 var dataServer = component.get('v.addCoverageData');
                 console.log('in get updated data');
                 console.log(dataServer);
                 var selRows = [];
                 var flSelectedData = [];
                 
                 if(dataServer.length == 1){
                     if(!$A.util.isUndefinedOrNull(dataServer[0].selectedKeys)){
                         selRows = dataServer[0].selectedKeys;
                     }
                     
                     if(dataServer[0].isChecked == true){
                         flSelectedData.push(dataServer[0]);
                     }
                 }
                 
                 else if (dataServer.length > 1){
                     for(var g  = 0; g < dataServer.length ; g ++){
                         if(!$A.util.isUndefinedOrNull(dataServer[g].selectedKeys)){
                             selRows = dataServer[g].selectedKeys;
                             break;
                         }
                     }
                     for(var k  = 0; k < dataServer.length ; k ++){
                         if(dataServer[k].isChecked == true){
                             flSelectedData.push(dataServer[k]);
                         }
                     }
                     
                 }
                 component.set('v.selectedRows', new Array());
                 component.set('v.selectedRows', selRows);
                 component.set('v.selectedData', new Array());
                 component.set('v.selectedData',flSelectedData); 
                 component.set('v.isButtonEnabled',false);
                 component.hideSpinner();
             }
             component.hideSpinner();
         });
         $A.enqueueAction(action);
        }
        
        
        
    },
    
    
    salesPersonChanged : function(component,event,helper){
        
        var spersonIds = component.get('v.salesPersonIDs');
        spersonIds.push( event.getParam("data"));
        component.set("v.salesPersonIDs", event.getParam("data"));
        
    },
    
    
    Previous : function(cmp,event,helper){
        var prevButton = cmp.find("prevButton");
        var nextButton = cmp.find("nextButton");
        if(cmp.get("v.setWizardStep")=='Save')
        {
            cmp.switchWizardStep("Select");
            cmp.set("v.setWizardStep","Select");
            prevButton.set("v.label",cmp.get("v.cancelButton_label"));
            prevButton.set("v.iconName","utility:close");
            nextButton.set("v.label",cmp.get("v.validateButton_label"));
            nextButton.set("v.iconName","utility:task");
            $A.util.removeClass(nextButton,'slds-hide');
        }
        else
        {
             cmp.find("navService").navigate({
                 "type": "standard__navItemPage",
                 "attributes": {
                     "apiName" : "Coverage" 
                 }
             }, true);
        }
    },
    
    
    Next : function(cmp,event,helper){
        console.log('hi in next function');
        var prevButton = cmp.find("prevButton");
        var nextButton = cmp.find("nextButton");
        var salesPerson = cmp.get('v.salesPersonIDs');
        var dataObject = cmp.get('v.selectedData');
        
        console.log('salesPerson :'+ salesPerson.length);
        
        if(cmp.get("v.setWizardStep")=='Select' && nextButton.get("v.label") == "Next")
        {
            if(dataObject.length == 0)
            {
                cmp.showToast('','error','Please select coverage information to be added.');
                cmp.hideSpinner();
            }            
            
            else  if(salesPerson.length == 0){
                
                cmp.showToast('','error','Please select salesperson(s) and then apply and then proceed with Next');
            }
                else
                {
                    var dataSel = cmp.get('v.selectedData');
                    
                    if(!$A.util.isUndefinedOrNull(dataSel)){
                        if(dataSel.length == 0){
                            cmp.showToast('','error','Please select a coverage record to proceed.');
                            return;
                        }
                    }
                    
                    else
                    {cmp.showToast('','error','Please select a coverage record to proceed.');
                     return;}
                    helper.createBulkformat(cmp,'addCoverageTable1','transferAdd');
                }
        }
        else if(cmp.get("v.setWizardStep")=='Save' && nextButton.get("v.label") == "Save")
        {
            cmp.SubmitDataForTransfer();
            cmp.switchWizardStep("Save");
            cmp.set("v.setWizardStep","Save");
            
        }
        
    },
    
    /*6----------------------TOAST MESSAGES--------------*/
    showToast : function(component, event, helper) {
        var params = event.getParam('arguments');
        if(params)
        {
            var title = params.title;
            var type = params.type;
            var message = params.message;
            var mode = params.mode;
            var key = params.key;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "type": type,
                "message": message,
                "mode": mode,
                "key": key
            });
            toastEvent.fire();
        }
        
        
    },
    
    showSpinner : function(component,event) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },
    /*-2.2--- HIDE SPINNER-------------------------------------*/
    hideSpinner : function(component,event) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.addClass(cmpTarget, 'slds-hide');
    },
    
    SubmitDataForTransfer : function(component,event,helper){
        component.showSpinner();
        var deleteData = new Array();
        var delDataind = new Object();
        var addData = new Array();
        var addDataind = new Array();
        var dataObject = component.get('v.validationCoverageData');
        var action = component.get("c.createTransferDataAndSubmit");	
        console.log('in SubmitDataForTransfer')  ;      
        console.log(dataObject);
        if (dataObject.length == 1) { 
            delDataind.salesCode =dataObject[0].coverageID;
            delDataind.productGroup = dataObject[0].productGroup;
            delDataind.productRegion = dataObject[0].productRegion;
            delDataind.productName = dataObject[0].product;
            delDataind.role = dataObject[0].Role;
            delDataind.action = 'delete';
            delDataind.fromDate = dataObject[0].newStartDate;
            delDataind.clientRGKey = dataObject[0].rgOrgID;
            delDataind.clientRMKey = dataObject[0].rmOrgID; 
            delDataind.salesCodeId = dataObject[0].salesCodeID;
            delDataind.transferSalesCode = dataObject[0].transferToSalesCode;
            delDataind.isAttested = dataObject[0].isAttested;
            deleteData.push(delDataind);
            delDataind = new Object();     
        }
        
        else
        {
            for (var g=0; g< dataObject.length; g++){
                delDataind.salesCode =dataObject[g].coverageID;
                delDataind.productGroup = dataObject[g].productGroup;
                delDataind.productRegion = dataObject[g].productRegion;
                delDataind.productName = dataObject[g].product;
                delDataind.role = dataObject[g].Role;
                delDataind.action = 'delete';
                delDataind.fromDate = dataObject[g].newStartDate;
                delDataind.clientRGKey = dataObject[g].rgOrgID;
                delDataind.clientRMKey = dataObject[g].rmOrgID; 
                delDataind.salesCodeId = dataObject[g].salesCodeID;
                delDataind.transferSalesCode = dataObject[g].transferToSalesCode;
                delDataind.isAttested = dataObject[g].isAttested;
                deleteData.push(delDataind);
                delDataind = new Object();
            }
        }
        
        console.log('Delete data');
        console.log(deleteData); 
        
        console.log('successlist');
        console.log(component.get("v.successList"));
        for(var i = 0; i < component.get("v.successList").length; i++)
        {
            component.get("v.successList")[i].sobjectType = 'Coverage_Temp__c';
        }
        
        action.setParams({"cmpdeleteData" : JSON.stringify(deleteData),
                          "cmpAddData" : component.get("v.successList"),
                          "rgDeleteList": component.get("v.rgDeleteList"),
                          "rmDeleteList": component.get("v.rmDeleteList")}); 
        action.setCallback(this,function(response){
            console.log('in callback');
            var state = response.getState();
            console.log(state);
            if(state === "SUCCESS"){
                var resultString = response.getReturnValue();
                console.log('resultString: '+resultString);
                if(resultString.search("submitted")!=-1)
                {
                    component.showToast('','success','Your requested Coverage are submitted for processing.');
                    window.history.back();
                }
                else
                {
                    component.showToast('','error',resultString);
                }
                
                
                
                /* var evt = $A.get("e.force:navigateToComponent");
                evt.setParams({
                    componentDef : "c:MyCoverageTool"
                });
                evt.fire();*/
                
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                        component.showToast('','error',errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                    component.showToast('','error',"Unknown Error");
                }
            }
            component.hideSpinner();
            
        });
        $A.enqueueAction(action);
    },
    
    
    switchWizardStep : function(component, event, helper) {
        var params = event.getParam('arguments');
        if(params)
        {
            var stepName = params.stepName;
            var selectSection = component.find('Select');
            var verifySection = component.find('Verify');
            var saveSection = component.find('Save');
            if(stepName=='Select')
            {
                $A.util.removeClass(selectSection, 'slds-hide');
                $A.util.addClass(verifySection, 'slds-hide');
                $A.util.addClass(saveSection, 'slds-hide');
            }
            else if(stepName=='Verify')
            {
                console.log('in verify on transfer tab');
                $A.util.addClass(selectSection, 'slds-hide');
                $A.util.removeClass(verifySection, 'slds-hide');
                $A.util.addClass(saveSection, 'slds-hide');
            }
                else
                {
                    $A.util.addClass(selectSection, 'slds-hide');
                    $A.util.addClass(verifySection, 'slds-hide');
                    $A.util.removeClass(saveSection, 'slds-hide');
                }
        }
        
    },
    
    showSpinner : function(component,event) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },
    /*-2.2--- HIDE SPINNER-------------------------------------*/
    hideSpinner : function(component,event) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.addClass(cmpTarget, 'slds-hide');
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
    showValidationDatatable : function(component, event, helper){        
        var dataTable = component.find("dataTableValidation");
        var footers = component.find("footerId");
        $A.util.removeClass(dataTable, "slds-hide");        
        $A.util.removeClass(footers, "slds-hide");
    },    
    hideValidationDatatable : function(component, event, helper){
        var dataTable = component.find("dataTableValidation");
        var footerDiv = component.find("footerId");
        $A.util.addClass(dataTable, "slds-hide");
        $A.util.addClass(footerDiv, "slds-hide");
    }, 
    updateColumnSorting: function (cmp, event, helper) {
        var dataTable = cmp.find("addCoverageTable1");
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        dataTable.set("v.sortedBy", fieldName);
        dataTable.set("v.sortedDirection", sortDirection);        
        helper.sortData(cmp, fieldName, sortDirection);
    },
    getSelectedId : function(component, event, helper){  
        var selectedRows = event.getParam('selectedRows'); 
        component.set('v.selectedData',selectedRows);
        
        var dataObject = component.get('v.transferData');
        var selArray = new Array();
        
        for(var m=0; m < selectedRows.length; m++){
            selArray.push(selectedRows[m].origKey);
        }
        
        console.log('selectedRows');
        console.log(selectedRows);
        console.log('in ltd row selection');
        
        if(selArray.length == 1){           
            if(dataObject.length == 1){
                
                if(!selArray.includes(dataObject[0].origKey)){
                    dataObject[0].isChecked = false;
                }
                else
                {
                    dataObject[0].isChecked = true;
                }
            }
            
            
            else
            {
                for (var j = 0; j < dataObject.length; j++){
                    if(!selArray.includes(dataObject[j].origKey)){
                        dataObject[j].isChecked = false;
                    }
                    else
                    {
                        dataObject[j].isChecked = true;
                    }
                } 
            }
            
        }
        
        else if(selArray.length > 1)        
        {
            for (var j = 0; j < dataObject.length; j++){
                if(!selArray.includes(dataObject[j].origKey)){
                    dataObject[j].isChecked = false;
                    
                }
                else
                {
                    dataObject[j].isChecked = true;
                }
            }            
        }
        
        component.set('v.transferData',dataObject);
        
    },
    
    updateColumnSorting: function (cmp, event, helper) {
        var dataTable = cmp.find("addCoverageTable1");
        var fieldName = event.getParam('fieldName');
        console.log('********** FIELDNAME: '+fieldName);
        var sortDirection = event.getParam('sortDirection');
        console.log('********** sortDirection: '+sortDirection);
        dataTable.set("v.sortedBy", fieldName);
        dataTable.set("v.sortedDirection", sortDirection);        
        helper.sortData(cmp, fieldName, sortDirection);
    },

    onCheck: function (cmp) {
        var isAttested = cmp.find("attestCheckbox");
        cmp.set("v.attestFlag", isAttested.get("v.value"));
    }

    
    
})