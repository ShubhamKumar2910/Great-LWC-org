({
    doInit : function(component, event, helper) {
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
        
    },
    showValidationDatatable : function(component, event, helper){        
        var dataTable = component.find("dataTableValidation");
        var footers = component.find("footerId");
        $A.util.removeClass(dataTable, "slds-hide");        
        
    },    
    hideValidationDatatable : function(component, event, helper){
        var dataTable = component.find("dataTableValidation");
        var footerDiv = component.find("footerId");
        $A.util.addClass(dataTable, "slds-hide");
        
    },
    roleChangedAdd: function(cmp,event,helper){
        var productRoles = cmp.find('proroleAdd').get('v.values');
        if(!$A.util.isUndefinedOrNull(productRoles))
        {
            if(productRoles.length ==  1)
                cmp.set("v.role",productRoles);
            else
                cmp.set("v.role", []);
        }
       else
            cmp.set("v.role", new Array("Primary")); 

    },
    helperScriptsLoaded: function (cmp, event,helper) {
        cmp.set("v.isHelperScriptLoaded",true);
        cmp.set("v.needToRenderHelperLogic",true);
    }, 
    searchCoverage : function(cmp, event, helper) {
        var fromsalesPerson = cmp.get('v.fromsalesPersons');
        var tosalesPerson = cmp.get('v.tosalesPersons');
        var dataObject = cmp.get('v.selectedData');
        var fromspersonIds = cmp.get('v.fromsalesPersonIDs');
        var tospersonIds = cmp.get('v.tosalesPersonIDs');
        var sameSalesCode = false;
        var companyRegionCheck = false;
        var toSalesPersons = Object.values(cmp.get('v.tosalesPersonIDs'));

        for(var i = 0; i < toSalesPersons.length; i++) {
            if((coverage_helper_util.mandatoryPrimaryAttestRegion).indexOf(toSalesPersons[i]['salesDeskRegion'])>-1 && (coverage_helper_util.company).indexOf(toSalesPersons[i]['company'])>-1)
            {
                companyRegionCheck = true;
            }  
        }
        var userRole = cmp.get("v.role");
        console.log('Role: ' + userRole);
        console.log('IsAttested: '+ cmp.get("v.attestFlag"));
        if(companyRegionCheck && (coverage_helper_util.userRole).indexOf(String(userRole))>-1 && !cmp.get("v.attestFlag")){
            cmp.showToast('','error','Please attest primary coverage.'); 
        }
        
       else if(fromsalesPerson.length == 0 && tosalesPerson.length == 0 ){
            
            cmp.showToast('','error','Please select From and To salesperson(s) and then apply and then proceed with Next');
        }
        else if(fromsalesPerson.length > 2 || tosalesPerson.length > 2){
            
            cmp.showToast('','error','Maximum 2 salesperson(s) are allowed for coverage clone.');
        }
        else  if(fromsalesPerson.length == 0 && tosalesPerson.length > 0 ){
            
            cmp.showToast('','error','Please select From salesperson(s) and then apply and then and then proceed with Next');
        }
        else  if(fromsalesPerson.length > 0 && tosalesPerson.length == 0 ){
                
                cmp.showToast('','error','Please select To salesperson(s) and then apply and then and then proceed with Next');
        }
        else
        {
                for(var i = 0; i < fromspersonIds.length; i++){
                for(var j = 0; j < tospersonIds.length; j++){
                    if(tospersonIds[j].salesCode == fromspersonIds[i].salesCode)
                        {
                            sameSalesCode = true;
                            break;
                        }
                        }
                    }
                
                    if(sameSalesCode){
                        cmp.showToast('','info','Clone coverage is not valid for same salesperson. Please enter valid filter.');
                    }
                    else
                    {
                        console.log('ready to prepare data');
                        helper.fetchResults(cmp,false);
                    }
        }
    },
    from_salesPersonChanged : function(component,event,helper){
        if(event.getParam("values").length >= 1)
        { 
            component.set("v.fromsalesPersons",event.getParam("values"));
            var data = event.getParam("data");
            console.log(data);
            var splitIds = new Array();
            for(var i = 0; i < data.length; i++)
            { 
                splitIds.push(data[i].salesCodeUserLoginId);
            }
            
            if(splitIds.length > 0)
                component.set("v.salesPersonLoginIds",splitIds);
            
            var spersonIds = component.get('v.fromsalesPersonIDs');
            spersonIds.push( event.getParam("data"));
            component.set("v.fromsalesPersonIDs", event.getParam("data"));
            console.log(component.get("v.fromsalesPersonIDs"));
        }
        else
        {
            component.set("v.fromsalesPersons", []);
            component.set("v.fromsalesPersonIDs", []);
            component.set("v.salesPersonLoginIds",[]);
        }
    },
    to_salesPersonChanged : function(component,event,helper){
        if(event.getParam("values").length >= 1)
        {
            component.set("v.tosalesPersons",event.getParam("values"));
            var spersonIds = component.get('v.tosalesPersonIDs');
            spersonIds.push( event.getParam("data"));
            component.set("v.tosalesPersonIDs", event.getParam("data"));
            console.log(component.get("v.tosalesPersonIDs"));
        }
        else
        {
            component.set("v.tosalesPersons", []);
            component.set("v.tosalesPersonIDs", []);
            component.set("v.salesPersonLoginIds",[]);
        }
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
    Next : function(component,event,helper){
        console.log('hi in next function');
        var prevButton = component.find("prevButton");
        var nextButton = component.find("nextButton");
        var fromsalesPerson = component.get('v.fromsalesPersons');
        var tosalesPerson = component.get('v.tosalesPersons');
        var dataObject = component.get('v.selectedData');
        
        console.log('fromsalesPerson :'+ fromsalesPerson.length);
        console.log('tosalesPerson :'+ tosalesPerson.length);
        
        if(component.get("v.setWizardStep")=='Select' && nextButton.get("v.label") == "Next")
        {
            if(fromsalesPerson.length == 0 && tosalesPerson.length == 0 ){
                
                component.showToast('','error','Please select From and To salesperson(s) and apply and then proceed with Next');
            }
            else  if(fromsalesPerson.length == 0 && tosalesPerson.length > 0 ){
                
                component.showToast('','error','Please select From salesperson(s) and then apply and then proceed with Next');
            }
                else  if(fromsalesPerson.length > 0 && tosalesPerson.length == 0 ){
                    
                    component.showToast('','error','Please select To salesperson(s) and then apply and then proceed with Next');
                }
                    else
                    {
                       // helper.validateCloneData(component,prevButton,nextButton,fromsalesPerson,tosalesPerson,dataObject);
                        helper.createBulkformat(component,'coverageTable','add');
                    }
                            
                    
        }                                      
        else if(component.get("v.setWizardStep")=='Save' && nextButton.get("v.label") == "Save")
        {
            console.log(component.get("v.successList"));
            console.log(component.get("v.rgDeleteList"));
            console.log(component.get("v.rmDeleteList"));
            
            helper.submitData(component,component.get("v.successList"),component.get("v.rgDeleteList"),component.get("v.rmDeleteList"),component.get("v.totalCount"),component.get("v.guid"));
            component.switchWizardStep("Save");
            component.set("v.setWizardStep","Save");
            
        }
    },
    showSpinner : function(component,event) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },
    hideSpinner : function(component,event) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.addClass(cmpTarget, 'slds-hide');
    },
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
    updateColumnSorting: function (cmp, event, helper) {
        var dataTable = cmp.find("coverageTable");
        var validationdata = cmp.find("validationTable1");
        
        var fieldName = event.getParam('fieldName');
        console.log('********** FIELDNAME: '+fieldName);
        var sortDirection = event.getParam('sortDirection');
        console.log('********** sortDirection: '+sortDirection);
        console.log($A.util.isUndefinedOrNull(validationdata));
        if(cmp.get("v.setWizardStep") == 'Select')
        {
            dataTable.set("v.sortedBy", fieldName);
            dataTable.set("v.sortedDirection", sortDirection);        
        }
        else
        {
            validationdata.set("v.sortedBy", fieldName);
            validationdata.set("v.sortedDirection", sortDirection);  
        }
        helper.sortData(cmp, fieldName, sortDirection);
    },
    getSelectedData: function (cmp, event) {
        var selectedRows = event.getParam('selectedRows');
        console.log('Selected Rows length: '+selectedRows.length);
        var finalRows = new Array();
        for(var i = 0;i<selectedRows.length;i++)
        {
            if(selectedRows[i].status != 'Pending')
                finalRows.push(selectedRows[i]);
        }
        console.log('Actual Rows length: '+finalRows.length);
        cmp.set('v.selectedData',finalRows);
        finalRows.length = 0;
    },
    showDatatable : function(component, event, helper){        
        var dataTable = component.find("dataTableDiv");
        $A.util.removeClass(dataTable, "slds-hide");        
        
    },
    hideDatatable : function(component, event, helper){
        var dataTable = component.find("dataTableDiv");
        $A.util.addClass(dataTable, "slds-hide");
        
    },
    sortData:function (cmp, event, helper) {
        var params = event.getParam('arguments');
        if(params)
        {
            var field = params.field;
            console.log(field);
            
            var dir = params.dir;
            console.log(field);
            helper.sortData(cmp, field, dir);
        }
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

    onCheck: function (cmp) {
        var isAttested = cmp.find("attestCheckbox");
        cmp.set("v.attestFlag", isAttested.get("v.value"));
    }       
})