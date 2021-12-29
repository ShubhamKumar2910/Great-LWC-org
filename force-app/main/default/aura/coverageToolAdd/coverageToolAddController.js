({

    /*--------------------------------------- INIT ----------------------------*/
    doInit: function (cmp, event, helper) {
        //console.log('Inside rerender ***');
        var myPageRef = cmp.get("v.pageReference");
        //console.log(myPageRef);
        //console.log(myPageRef.state.c__accountLookupId);
        var accountId = myPageRef.state.c__accountLookupId;
        if (!$A.util.isUndefinedOrNull(accountId))
            cmp.set("v.accountLookupId", accountId);
        cmp.set("v.source", myPageRef.state.c__source);
        cmp.set("v.reset", myPageRef.state.c__reset);
        console.log('doInit');
    },

    reInit: function (cmp, event, helper) {
        //console.log('--reInit CoverageToolAdd');
        var myPageRef = cmp.get("v.pageReference");
        cmp.set("v.source", myPageRef.state.c__source);
        cmp.set("v.reset", myPageRef.state.c__reset);
        var reset = cmp.get("v.reset");
        if (reset || reset == undefined) {
            cmp.resetPage(cmp, event, helper);
        }
        console.log('reInit');
    },

    resetPage: function (cmp, event, helper) {
        //console.log('--resetPage CoverageToolAdd');        
        cmp.doFilterReset();
        cmp.flushItems();
        cmp.set("v.addCoverageData", [{}]);
        cmp.set("v.addCoverageColumns", [{}]);
        helper.fetchCurrentUserSalesCodeId(cmp);
        cmp.hideDatatable();
        cmp.switchWizardStep("Select");
        var prevButton = cmp.find("prevButton");
        var nextButton = cmp.find("nextButton");
        cmp.set("v.setWizardStep", "Select");
        prevButton.set("v.label", cmp.get("v.cancelButton_label"));
        prevButton.set("v.iconName", "utility:close");
        cmp.set('v.showRemoveButton', true);
        nextButton.set("v.label", cmp.get("v.validateButton_label"));
        nextButton.set("v.iconName", "utility:task");
        $A.util.removeClass(nextButton, 'slds-hide');
        cmp.set('v.showRemoveButton', false);
        cmp.set("v.addSelectionDataMap", {});
        var accountLookup = cmp.find("lookup-accountAdd");
        accountLookup.set("v.preSelectedIds", null);
        cmp.set("v.accountLookupId", null);
        cmp.set("v.attestFlag",false);
        cmp.find("attestCheckbox").set("v.value", false);
        coverage_helper_util.setLoggedUserDetails(cmp);
    },

    helperScriptsLoaded: function (cmp, event, helper) {
        cmp.set("v.isHelperScriptLoaded", true);
        cmp.set("v.needToRenderHelperLogic", true);
    },
    showSpinner: function (component, event) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },
    hideSpinner: function (component, event) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.addClass(cmpTarget, 'slds-hide');
    },
    doReset: function (cmp, event, helper) {
        cmp.showSpinner();
        //Reset Client
        cmp.set("v.accountIDs", []);
        cmp.find("lookup-accountAdd").reset();

        //Reset Start Date
        var today = new Date();
        cmp.set('v.CoverageStartDate', today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate());


        //Reset Sales Person
        cmp.set("v.salesPersonIDs", []);
        cmp.find("salesPersonsAdd").reset();

        /*//Reset Product Group
        cmp.set("v.productGroups", []); 
        $("#"+cmp.find('proGroupAdd').get("v.IDT")).select2('val',null); 
        $('#'+cmp.find('proGroupAdd').get("v.parentID")+'_'+cmp.find('proGroupAdd').get("v.IDT")).val('Equity'); // Select the option with a value of '1'
        $('#'+cmp.find('proGroupAdd').get("v.parentID")+'_'+cmp.find('proGroupAdd').get("v.IDT")).trigger('change');*/
        $("#" + cmp.find('proGroupAdd').get("v.parentID") + '_' + cmp.find('proGroupAdd').get("v.IDT")).select2('val', null);
        helper.fetchCurrentUserSalesCodeId(cmp);
        //Reset Product Region
        //console.log('**** : '+cmp.find('proRegionAdd').get("v.IDT"));
        $("#" + cmp.find('proRegionAdd').get("v.parentID") + '_' + cmp.find('proRegionAdd').get("v.IDT")).select2('val', null);
        cmp.set("v.productRegions", []);

        //Reset Products
        var product = cmp.find('product');
        product.set("v.options", []);
        product.set("v.options_", []);
        product.reInit();
        cmp.set("v.products", []);

        //SALES-3698 removed the check for CoverageType
        //var coverageType = cmp.find('coverageType');
        //coverageType.reInit();
        cmp.set("v.types", []);

        cmp.set("v.comments", "");
        cmp.set("v.attestFlag",false);
        cmp.find("attestCheckbox").set("v.value", false);
        coverage_helper_util.setLoggedUserDetails(cmp);
        cmp.hideSpinner();
    },
    doTableDataReset: function (component, event, helper) {
        var ctable = component.find("addCoverageTable");
        ctable.set("v.wrapperMethod", null);
        ctable.set("v.wrapperParams", null);
        component.set("v.requestedAddData", new Array());
        ctable.set("v.wrapperList", new Array());
        ctable.set("v.dataList", new Array());
        ctable.hideTable();
        component.set("v.addSelectionDataMap", {});
    },
    doApplySelection: function (cmp, event, helper) {
        console.log(cmp.get('v.types'));
        helper.createAddCoverages(cmp);
    },
    loggedInUserDetailsCallback :function (cmp,event, helper) {
        console.log('***** DS CALLED*****');
        cmp.set("v.loggedInUserDetailsLoaded",true);
    },
    groupChangedAdd: function (cmp, event, helper) {
        var b = $('#' + cmp.find('proGroupAdd').get("v.parentID") + '_' + cmp.find('proGroupAdd').get("v.IDT"));
        console.log('Group Values selected');
        console.log(b.val());
        var productGrps = b.val();
        if (!$A.util.isUndefinedOrNull(productGrps)) {
            if (productGrps != undefined && productGrps != null && productGrps != '') {
                cmp.set('v.isProductRegionsDisable', false);
                var a = $('#' + cmp.find('proRegionAdd').get("v.parentID") + '_' + cmp.find('proRegionAdd').get("v.IDT"));
                var productRegions = a.val();
                if (productRegions != undefined && productRegions != null && productRegions != '') {
                    cmp.set("v.productRegions", new Array(productRegions));
                    helper.fetchDepValues(cmp, new Array(productRegions), new Array(productGrps));
                    cmp.set("v.products", []);
                }
                cmp.set("v.productGroups", new Array(productGrps));
            }


        }
    },
    //commented for JIRA SALES-3698
    /*-------------------typeChangedAdd: function(cmp,event,helper){
        if(event.getParam("values").length >= 1)
            cmp.set("v.types",event.getParam("values"));
        else
        {cmp.set("v.types",[]);}    
      
    },
    -----------------fetchNFPEType: function(cmp,event,helper){
        helper.fetchNFPEType(component);
    },*/
    regionChangedAdd: function (cmp, event, helper) {
        console.log('Region values');
        var a = $('#' + cmp.find('proRegionAdd').get("v.parentID") + '_' + cmp.find('proRegionAdd').get("v.IDT"));
        var productRegions = a.val();
        var b = $('#' + cmp.find('proGroupAdd').get("v.parentID") + '_' + cmp.find('proGroupAdd').get("v.IDT"));
        var productGrps = b.val();
        if (!$A.util.isUndefinedOrNull(productRegions) || productRegions == '') {
            if (productRegions != undefined && productRegions != null && productRegions != '') {
                helper.fetchDepValues(cmp, new Array(productRegions), new Array(productGrps));
                cmp.set("v.productRegions", new Array(productRegions));
                cmp.set("v.products", []);
            }
        }
        else {
            var product = cmp.find('product');
            product.set("v.options", []);
            product.set("v.options_", []);
            product.reInit();
            cmp.set("v.productRegions", []);
            cmp.set("v.products", []);
        }
    },
    roleChangedAdd: function (cmp, event, helper) {
        var productRoles = cmp.find('proroleAdd').get('v.values');
        if (!$A.util.isUndefinedOrNull(productRoles)) {
            if (productRoles.length == 1)
                cmp.set("v.role", productRoles);
            else
                cmp.set("v.role", []);
        }
        else
            cmp.set("v.role", new Array("Primary"));

            console.log(cmp.get("v.role"));
    },
    accountsChangedAdd: function (cmp, event, helper) {
        if (event.getParam("values").length >= 1) {
            cmp.set("v.accountIDs", event.getParam("values"));
            //console.log(event.getParam("values"));
        }
        else
            cmp.set("v.accountIDs", []);
    },
    salesPersonChangedAdd: function (cmp, event, helper) {
        if (event.getParam("values").length >= 1) {
            cmp.set("v.salesPersonIDs", event.getParam("values"));
            cmp.set("v.salesPersonData", event.getParam("data"));

            var salesDeskRegions = [];
            var companies = [];
            var toSalesPersons = Object.values(cmp.get('v.salesPersonData'));
            cmp.set("v.companyRegionCheck", false);
            for(var i = 0; i < toSalesPersons.length; i++) {
                salesDeskRegions.push(toSalesPersons[i]['salesDeskRegion']);
                companies.push(toSalesPersons[i]['company']);
                if((coverage_helper_util.mandatoryPrimaryAttestRegion).indexOf(toSalesPersons[i]['salesDeskRegion'])>-1 && toSalesPersons[i]['company'] == 'N')
                {
                    cmp.set("v.companyRegionCheck", true);
                }               
            }
            console.log(salesDeskRegions);
            console.log(companies);
            console.log(cmp.get("v.salesPersonData"));
        }
        else
            cmp.set("v.salesPersonIDs", []);
    },
    productChangedAdd: function (component, event, helper) {
        if (event.getParam("values").length >= 1)
            component.set("v.products", event.getParam("values"));
        else { component.set("v.products", []); }
    },
    Previous: function (cmp, event, helper) {
        var prevButton = cmp.find("prevButton");
        var nextButton = cmp.find("nextButton");
        //console.log(cmp.get("v.setWizardStep"));
        if (cmp.get("v.setWizardStep") == 'Save') {
            cmp.switchWizardStep("Select");
            cmp.set("v.setWizardStep", "Select");
            prevButton.set("v.label", cmp.get("v.cancelButton_label"));
            prevButton.set("v.iconName", "utility:close");
            cmp.set('v.showRemoveButton', true);
            nextButton.set("v.label", cmp.get("v.validateButton_label"));
            nextButton.set("v.iconName", "utility:task");
            $A.util.removeClass(nextButton, 'slds-hide');
            //cmp.doFilterReset();
            //cmp.doTableDataReset();
        }
        else {
            //changes for Sales-3044              
            //console.log(cmp.get("v.source"));
            if (cmp.get("v.source") === "ContactLocator") {
                //updated __reset for critical update
                cmp.find("navService").navigate({
                    "type": "standard__navItemPage",
                    "attributes": {
                        "apiName": "Locate_Contact"
                    },
                    "state": {
                        "c__reset": false
                    }
                }, false);

            }
            else if (cmp.get("v.source") === "AccountPage") {
                //updated __reset for critical update
                cmp.find("navService").navigate({
                    "type": "standard__recordPage",
                    "attributes": {
                        "recordId": cmp.get("v.accountLookupId"),
                        "objectApiName": "Account",
                        "actionName": "view"
                    }
                }, false);

            }
            else if (cmp.get("v.source") === "CoverageTool") {
                cmp.find("navService").navigate({
                    "type": "standard__navItemPage",
                    "attributes": {
                        "apiName": "Coverage"
                    },
                    "state": {
                        "c__reset": false
                    }
                }, false);
            } else {
                cmp.find("navService").navigate({
                    "type": "standard__namedPage",
                    "attributes": {
                        "pageName": "home"
                    }
                });
            }
        }
    },
    Next: function (cmp, event, helper) {
        var prevButton = cmp.find("prevButton");
        var nextButton = cmp.find("nextButton");

        if (cmp.get("v.setWizardStep") == 'Select' && nextButton.get("v.label") == "Next") {
            if (cmp.get("v.selectedData").length == 0) {
                cmp.showToast('', 'error', 'Please select coverage information and proceed with Next.');
                cmp.hideSpinner();
                cmp.set('v.showRemoveButton', false);
            }
            else {
                helper.createBulkformat(cmp, 'addCoverageTable1', 'add');
                cmp.set('v.showRemoveButton', false);

            }
        }
        else if (cmp.get("v.setWizardStep") == 'Save' && nextButton.get("v.label") == "Save") {
            //console.log("Do Save");
            helper.submitData(cmp, cmp.get("v.successList"), cmp.get("v.rgDeleteList"), cmp.get("v.rmDeleteList"), cmp.get("v.totalCount"), cmp.get("v.guid"));
        }
    },
    showToast: function (component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
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
    removeItems: function (component, event, helper) {
        var itemChecked = false;
        var itemNotChecked = false;
        var flush_source = false;
        var params = event.getParam('arguments');
        if (params) {
            flush_source = params.flush_source;
        }

        // selectedddata
        var selectedData = component.get('v.selectedData');
        //add coverage data
        var rows = component.get('v.addCoverageData');
        var rgkeys = new Array();
        var selectedRowIndex = [];

        for (var i = 0; i < selectedData.length; i++) {
            var rgKey = '';
            var rmKey = '';
            var salesCodeKey = '';
            var productKey = '';
            var productGrpKey = '';
            var productRegionKey = '';
            var coverageType = '';
            var key = '';
            var data = selectedData[i];
            var rmRestricted = false;
            if (!$A.util.isUndefinedOrNull(data.clientRGId))
                rgKey = data.clientRGId;
            if (!$A.util.isUndefinedOrNull(data.clientRMId))
                rmKey = data.clientRMId;
            if (!$A.util.isUndefinedOrNull(data.salesCodeID))
                salesCodeKey = data.salesCodeID;
            if (!$A.util.isUndefinedOrNull(data.product))
                productKey = data.product;
            if (!$A.util.isUndefinedOrNull(data.productGroup))
                productGrpKey = data.productGroup;
            if (!$A.util.isUndefinedOrNull(data.productRegion))
                productRegionKey = data.productRegion;
            if (!$A.util.isUndefinedOrNull(data.coverageType))
                coverageType = data.coverageType;
            if (!$A.util.isUndefinedOrNull(data.rmRestricted)) {
                if (data.rmRestricted)
                    rmRestricted = true;
                else
                    rmRestricted = false;
            }
            else {
                rmRestricted = false;
            }

            key = rgKey + salesCodeKey + productKey + productGrpKey + productRegionKey;
            if (coverageType != '' && coverageType == 'Standard' && !rmRestricted)
                rgkeys.push(key);
            selectedRowIndex.push(rows.indexOf(selectedData[i]));
        }




        for (var k = 0; k < rgkeys.length; k++) {
            var key = rgkeys[k];
            for (var j = 0; j < rows.length; j++) {
                var rgKey = '';
                var rmKey = '';
                var salesCodeKey = '';
                var productKey = '';
                var productGrpKey = '';
                var productRegionKey = '';
                var coverageType = '';
                var keydata = '';
                var data = rows[j];
                var rmRestricted = false;
                if (!$A.util.isUndefinedOrNull(data.clientRGId))
                    rgKey = data.clientRGId;
                if (!$A.util.isUndefinedOrNull(data.clientRMId))
                    rmKey = data.clientRMId;
                if (!$A.util.isUndefinedOrNull(data.salesCodeID))
                    salesCodeKey = data.salesCodeID;
                if (!$A.util.isUndefinedOrNull(data.product))
                    productKey = data.product;
                if (!$A.util.isUndefinedOrNull(data.productGroup))
                    productGrpKey = data.productGroup;
                if (!$A.util.isUndefinedOrNull(data.productRegion))
                    productRegionKey = data.productRegion;
                if (!$A.util.isUndefinedOrNull(data.coverageType))
                    coverageType = data.coverageType;
                if (!$A.util.isUndefinedOrNull(data.rmRestricted)) {
                    if (data.rmRestricted)
                        rmRestricted = true;
                    else
                        rmRestricted = false;
                }
                else {
                    rmRestricted = false;
                }
                keydata = rgKey + salesCodeKey + productKey + productGrpKey + productRegionKey;
                if (key === keydata && !selectedRowIndex.includes(j))
                    selectedRowIndex.push(j);
            }
        }


        selectedRowIndex = selectedRowIndex.sort(function (a, b) { return a - b; });
        console.log(selectedRowIndex);

        var mainMap = component.get("v.addSelectionDataMap");
        for (var k in mainMap)
            console.log(k);

        if (selectedRowIndex.length > 0) {
            for (var i = selectedRowIndex.length - 1; i >= 0; i--) {
                var rgKey = '';
                var rmKey = '';
                var salesCodeKey = '';
                var productKey = '';
                var productGrpKey = '';
                var productRegionKey = '';
                var roleKey = '';
                var rgKey = '';
                var dateKey = '';
                var coverageType = '';
                var subType = '';
                var coverageTypes = new Array();
                var rmRestricted = false;
                var numberOfRMs = '> 0';
                var row = rows[selectedRowIndex[i]];
                if (!$A.util.isUndefinedOrNull(row.rmRestricted)) {
                    if (row.rmRestricted)
                        rmRestricted = true;
                    else
                        rmRestricted = false;
                }
                else {
                    rmRestricted = false;
                }
                if (!$A.util.isUndefinedOrNull(row.numberOfRMs)) {
                    numberOfRMs = '= ' + row.numberOfRMs;
                }
                coverageTypes = component.get('v.types');
                var key = '';

                if (!$A.util.isUndefinedOrNull(row.coverageType)) {
                    coverageType = row.coverageType;
                }
                if (!$A.util.isUndefinedOrNull(row.subType)) {
                    subType = row.subType;
                }


                if (!$A.util.isUndefinedOrNull(row.clientRGId))
                    rgKey = row.clientRGId;
                if (!$A.util.isUndefinedOrNull(row.clientRMId))
                    rmKey = row.clientRMId;
                if (!$A.util.isUndefinedOrNull(row.salesCodeID))
                    salesCodeKey = row.salesCodeID;
                if (!$A.util.isUndefinedOrNull(row.product))
                    productKey = row.product;
                if (!$A.util.isUndefinedOrNull(row.productGroup))
                    productGrpKey = row.productGroup;
                if (!$A.util.isUndefinedOrNull(row.productRegion))
                    productRegionKey = row.productRegion;
                if (!$A.util.isUndefinedOrNull(row.role))
                    roleKey = row.role;
                if (!$A.util.isUndefinedOrNull(row.startDate))
                    dateKey = row.startDate;

                if (productKey == '') {
                    console.log('inside a: ' + coverageType);
                    console.log('inside rm: ' + rmKey);

                    if (coverageType != 'Standard')
                        key = rgKey + salesCodeKey + coverageType + subType;
                    else
                        key = rgKey + rmKey + salesCodeKey + coverageType + subType;
                }
                else {
                    console.log('inside b: ');
                    if (coverageType != 'Standard')
                        key = rgKey + salesCodeKey + productKey + productGrpKey + productRegionKey + salesCodeKey + coverageType + subType;
                    else
                        key = rgKey + rmKey + salesCodeKey + productKey + productGrpKey + productRegionKey + salesCodeKey + coverageType + subType;
                }
                console.log('Key before: ' + key);
                /*if(numberOfRMs == '= 1' && coverageType!='Standard' && !rmRestricted){
                    console.log('inside replacement: ');
                    if(productKey == '')
                        key = rgKey+salesCodeKey+'Standard';
                    else
                        key = rgKey+salesCodeKey+productKey+productGrpKey+productRegionKey+salesCodeKey+'Standard';
                }*/

                key = key.replace(/\s/g, '');
                console.log(key);
                console.log(mainMap[key]);
                if (mainMap[key] != null)
                    delete mainMap[key];
            }
            component.set("v.addSelectionDataMap", mainMap);
            if (rows.length == 0) {
                component.set('v.showRemoveButton', false);
                component.set('v.setWizardStep', 'Select');
                component.hideDatatable();
            }
            else {
                console.log(selectedRowIndex);

                for (var i = selectedRowIndex.length - 1; i >= 0; i--) {
                    rows.splice(selectedRowIndex[i], 1);
                }
                component.set('v.addCoverageData', rows);
                component.set('v.showRemoveButton', true);
                component.showDatatable();
            }
        }
        else if (selectedRowIndex.length == 0 && flush_source == false) {
            component.showToast('', 'info', 'Please select item to remove.');
            component.hideSpinner();
        }


    },
    switchWizardStep: function (component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            var stepName = params.stepName;
            var selectSection = component.find('Select');
            var verifySection = component.find('Verify');
            var saveSection = component.find('Save');
            if (stepName == 'Select') {
                $A.util.removeClass(selectSection, 'slds-hide');
                $A.util.addClass(verifySection, 'slds-hide');
                $A.util.addClass(saveSection, 'slds-hide');
            }
            else if (stepName == 'Verify') {

                $A.util.addClass(selectSection, 'slds-hide');
                $A.util.removeClass(verifySection, 'slds-hide');
                $A.util.addClass(saveSection, 'slds-hide');
            }
            else {
                $A.util.addClass(selectSection, 'slds-hide');
                $A.util.addClass(verifySection, 'slds-hide');
                $A.util.removeClass(saveSection, 'slds-hide');
            }
        }

    },
    showViewModal: function (component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            var mainModalId = params.mainModalId;
            var backdropModalId = params.backdropModalId;
            var mainmodal = component.find(mainModalId);
            var backdropmodal = component.find(backdropModalId);
            $A.util.addClass(mainmodal, 'slds-fade-in-open');
            $A.util.addClass(backdropmodal, 'slds-backdrop_open');
        }

    },
    hideViewModal: function (component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            var mainModalId = params.mainModalId;
            var backdropModalId = params.backdropModalId;
            var mainmodal = component.find(mainModalId);
            var backdropmodal = component.find(backdropModalId);
            $A.util.removeClass(mainmodal, 'slds-fade-in-open');
            $A.util.removeClass(backdropmodal, 'slds-backdrop_open');
        }
    },
    closeModal: function (component, event, helper) {
        component.hideViewModal('viewCoverageModal', 'viewCoverageModalBackdrop');
    },
    updateColumnSorting: function (cmp, event, helper) {
        var dataTable = cmp.find("addCoverageTable1");
        var validationdata = cmp.find("validationTable1");

        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');


        if (cmp.get("v.setWizardStep") == 'Select') {
            dataTable.set("v.sortedBy", fieldName);
            dataTable.set("v.sortedDirection", sortDirection);
        }
        else {
            validationdata.set("v.sortedBy", fieldName);
            validationdata.set("v.sortedDirection", sortDirection);
        }

        helper.sortData(cmp, fieldName, sortDirection);
    },
    getSelectedData: function (cmp, event) {
        //console.log('selected Data called');
        var selectedRows = event.getParam('selectedRows');
        //console.log(selectedRows);
        cmp.set('v.selectedData', selectedRows);
    },
    showDatatable: function (component, event, helper) {
        var dataTable = component.find("dataTableDiv");
        var footers = component.find("footerId");
        $A.util.removeClass(dataTable, "slds-hide");
        $A.util.removeClass(footers, "slds-hide");
    },
    hideDatatable: function (component, event, helper) {
        var dataTable = component.find("dataTableDiv");
        var footerDiv = component.find("footerId");
        $A.util.addClass(dataTable, "slds-hide");
        $A.util.addClass(footerDiv, "slds-hide");
    },
    showValidationDatatable: function (component, event, helper) {
        var dataTable = component.find("dataTableValidation");
        var footers = component.find("footerId");
        $A.util.removeClass(dataTable, "slds-hide");
        $A.util.removeClass(footers, "slds-hide");
    },
    hideValidationDatatable: function (component, event, helper) {
        var dataTable = component.find("dataTableValidation");
        var footerDiv = component.find("footerId");
        $A.util.addClass(dataTable, "slds-hide");
        $A.util.addClass(footerDiv, "slds-hide");
    },
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'view_existing':
                helper.actionChange(cmp, row);
                break;
        }
    },

    onCheck: function (cmp) {
        var isAttested = cmp.find("attestCheckbox");
        cmp.set("v.attestFlag", isAttested.get("v.value"));
    }

})