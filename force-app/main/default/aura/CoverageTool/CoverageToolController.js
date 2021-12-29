({ 
	/*--------------------------------------- INIT-LOAD ----------------------------*/
    init: function (cmp, event,helper) {
      console.log('In my coverage tool init');
        var myPageRef = cmp.get("v.pageReference");   
        if(!$A.util.isUndefinedOrNull(myPageRef))
        {
            console.log(myPageRef.attributes.componentName);
            cmp.set("v.reset", myPageRef.state.c__reset);
            console.log(cmp.get("v.reset"));
            if((cmp.get("v.reset") && !(myPageRef.attributes.componentName == 'c__coverageToolAdd')) || (cmp.get("v.reset") === undefined && myPageRef.attributes.componentName == undefined)){
                cmp.resetPage(cmp, event, helper);
            } 
        }
    },
    handleClone: function(cmp,event,helper){
        var commentAccessible = cmp.get("v.isCommentAccessible");
        console.log('Clone: ');
        console.log(commentAccessible);
        if(cmp.get("v.isCommentAccessible")=='true' || cmp.get("v.isCommentAccessible")=='true:rw')
            commentAccessible = 'true';
        else
            commentAccessible = 'false';
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:CoverageToolClone",
            componentAttributes: {
                isCommentAccessible : commentAccessible
            }
        });
        evt.fire(); 
        
    },
    clearTableReferences : function (cmp, event,helper) {
        component.set("v.coverageData", [{}]);
        component.set("v.coverageColumns", [{}]); 
    },
    logTime:function(cmp,event,helper){
        
        var params = event.getParam('arguments');
        if(params)
        {
            var text = params.text;
            var currentdate = new Date(); 
            var datetime = text+": " + currentdate.getDate() + "/"
            + (currentdate.getMonth()+1)  + "/" 
            + currentdate.getFullYear() + " @ "  
            + currentdate.getHours() + ":"  
            + currentdate.getMinutes() + ":" 
            + currentdate.getSeconds();  
            console.log(datetime);
        }
    },
    reInit : function(cmp, event, helper){
        console.log('--reInit CoverageTool');
        var myPageRef = cmp.get("v.pageReference");   
        console.log(myPageRef.attributes.componentName);
       console.log("v.reset"+myPageRef.state.c__reset);
        cmp.set("v.reset", myPageRef.state.c__reset);
        console.log(cmp.get("v.reset"));
        if((cmp.get("v.reset") && !(myPageRef.attributes.componentName == 'c__coverageToolAdd')) || (cmp.get("v.reset") === undefined && myPageRef.attributes.componentName == undefined)){
            cmp.resetPage(cmp, event, helper);
        }        
    },
    resetPage : function(cmp, event, helper){
        cmp.set("v.coverageData", [{}]);
        cmp.set("v.coverageColumns", [{}]); 
        helper.fetchCurrentUserSalesCodeId(cmp);
        cmp.hideDatatable();
        cmp.doLevelReset();
    },
    /*1------------SPINNNER ----------------------------*/
    /*-1.1--- SHOW SPINNER-------------------------------------*/
    showSpinner : function(component,event) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },
    /*-1.2--- HIDE SPINNER-------------------------------------*/
    hideSpinner : function(component,event) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.addClass(cmpTarget, 'slds-hide');
    },
    
    /*2------------FILTER ACTIONS - CHANGED ----------------------------*/
    /*-2.1--- ACCOUNTS-------------------------------------*/
    accountsChanged : function(cmp,event,helper){
        if(event.getParam("values").length >= 1)
        {
            cmp.set("v.accountIDs",event.getParam("values"));
            console.log(event.getParam("values"));
            
            console.log(event.getParam("data"));
        }
        else
            cmp.set("v.accountIDs", []);
    },
    /*-2.2--- CLIENT TYPE-------------------------------------*/
    clientTypeChanged: function(cmp,event,helper){
        var clientType = cmp.find('clientType').get('v.values');
        if(clientType.length ==  1)
            cmp.set("v.clientType",clientType);
        else
            cmp.set("v.clientType", []);    
    },
    /*-2.3--- INCLUDE-------------------------------------*/
    onIncludeChange: function(cmp,event,helper){
        var selected = cmp.find("includes").get("v.value");
        cmp.set("v.Include",selected);
    },
    /*-2.4--- PRODUCT GROUP-------------------------------------*/
    groupChanged: function(cmp,event,helper){
        var productGrps = cmp.find('proGroup').get('v.values');
        if(productGrps.length >= 1)
        {   
            cmp.set('v.isProductRegionsDisable',false);
            var productRegions = cmp.find('proRegion').get('v.values');
            if(productRegions.length >= 1)
                helper.fetchDepValues(cmp, productRegions, productGrps); //HELPER CALL
            cmp.set("v.productGroups", productGrps);  
        }
        else
        {
            $("#"+cmp.find('proRegion').get("v.IDT")).select2('val',null);
            cmp.set('v.isProductRegionsDisable',true);
            
            var product = cmp.find('product');
            product.set("v.options",[]);
            product.set("v.options_",[]);
            product.reInit();
            cmp.set("v.productGroups", []);
            cmp.set("v.products",[]);
        }
        
    },    
    /*-2.5--- REGION GROUP-------------------------------------*/
    regionChanged: function(cmp,event,helper){
        var productRegions = cmp.find('proRegion').get('v.values');
        var productGrps = cmp.find('proGroup').get('v.values');
        if(productRegions.length >= 1 && productGrps.length >= 1)
        { 
            helper.fetchDepValues(cmp, productRegions, productGrps);   
            cmp.set("v.productRegions", productRegions);  
        }
        if(productRegions.length == 0)
        {
            var product = cmp.find('product');
            product.set("v.options",[]);
            product.set("v.options_",[]);
            product.reInit();
            cmp.set("v.productRegions", []); 
            cmp.set("v.products",[]);
        }
    },
    /*-2.6--- Product-------------------------------------*/
    productChanged : function(component, event, helper) 
    {
        if(event.getParam("values").length >= 1)
            component.set("v.products",event.getParam("values"));
        else
        {component.set("v.products",[]);}    
    },
    /*-2.7--- ROLE -------------------------------------*/
    roleChanged: function(cmp,event,helper){
        var productRoles = cmp.find('prorole').get('v.values');
        if(productRoles.length ==  1)
            cmp.set("v.role",productRoles);
        else
            cmp.set("v.role", []);     
    },
    /*-2.8--- SALES PERSONS-------------------------------------*/
    salesPersonChanged : function(cmp,event,helper){
        if(event.getParam("values").length >= 1)
        {
            cmp.set("v.salesPersonIDs",event.getParam("values"));
           
            var data = event.getParam("data");
            console.log(data);
            var splitIds = new Array();
            for(var i = 0; i < data.length; i++)
            { 
                splitIds.push(data[i].salesCodeUserLoginId);
            }
            
            if(splitIds.length > 0)
                cmp.set("v.salesPersonLoginIds",splitIds);
        }
        else
        {
            cmp.set("v.salesPersonIDs", []);
            cmp.set("v.salesPersonLoginIds",[]);
        }
    },
    /*-2.9--- AND / OR-------------------------------------*/
    isAndOR : function(component, event, helper){
        if(component.find("toggleCheckbox").get("v.value")==true)
        {
            component.set("v.isANDOR",'AND');
        }
        else
        {
            component.set("v.isANDOR",'OR');
        }
    },
    /*-2.10--- SALES TEAM-------------------------------------*/
    salesTeamChanged: function(cmp,event,helper)
    {
        if(event.getParam("values").length >= 1)
        {
            cmp.set("v.teamValues",event.getParam("values"));
            cmp.set("v.teamObjects",event.getParam("objects"));
        }
        else
        {
            cmp.set("v.teamValues", []);
            cmp.set("v.teamObjects",[]);
        }
    },
    fetchNFPEType: function(cmp,event,helper){
        helper.fetchNFPEType(component);
    },
    
    /*3------------BUTTON EVENTS ----------------------------*/
    /*3.1------------SEARCH ------------------------------*/
    doSearch: function(cmp,event,helper){
        ////console.log(cmp.get('v.types'));
        
        helper.fetchResults(cmp,false); //HELPER CALL
        cmp.set('v.isLoadInit',false);
    },
    doLevelReset: function(cmp,event,helper){
        cmp.showSpinner();
        //Reset Client
        cmp.set("v.accountIDs", []);
        cmp.find("lookup-account").reset();
        
        //Reset Include
        cmp.find("includes").set("v.value","Active");
        cmp.set("v.Include","Active");
        
        //Reset Client Type
        cmp.set("v.clientType", []); 
        cmp.find("clientType").reset();
        
        //Reset Product Group
        cmp.set("v.productGroups", []); 
        cmp.find("proGroup").reset();
        
        
        $("#"+cmp.find('proRegion').get("v.parentID")+'_'+cmp.find('proRegion').get("v.IDT")).select2('val',null);
        cmp.set("v.productRegions", []);
        cmp.set('v.isProductRegionsDisable',true);
        
        //Reset Products
        var product = cmp.find('product');
        product.set("v.options",[]);
        product.set("v.options_",[]);
        product.reInit();
        cmp.set("v.products",[]);
        
        //Reset Role
        cmp.set("v.role", []);    
        cmp.find("prorole").reset();
        
        var types = cmp.get('v.types');
        if(types!=undefined && types.length > 0){
            var coverageType = cmp.find('coverageType');
             coverageType.reInit();
            cmp.set("v.types",[]);
        }
        
        //Reset Sales Person
        cmp.set("v.salesPersonIDs", []);
        cmp.set("v.salesPersonLoginIds",[]);
        cmp.find("salesPersons").reset();
        
        //Reset Sales Team
        cmp.set("v.teamValues", []);
        cmp.set("v.teamObjects",[]);
        cmp.find("salesTeam").reset();
        
        //Reset AND/OR
        cmp.find("toggleCheckbox").set("v.value",false);
        cmp.set("v.isANDOR",'OR');
        cmp.hideSpinner();
    },
    /*3.2------------HIDE PRODUCT FILTER ------------------------------*/
    hideProductFilters : function(component, event, helper) {
        var product = component.find('productSet');
        $A.util.addClass(product, 'slds-hide');  
    },
    doProductFilterReset: function(cmp,event,helper){
        cmp.showSpinner();
        //Reset Product Group
        cmp.set("v.productGroups", []); 
        cmp.find("proGroup").reset();
        
        
        $("#"+cmp.find('proRegion').get("v.parentID")+'_'+cmp.find('proRegion').get("v.IDT")).select2('val',null);
        cmp.set("v.productRegions", []);
        cmp.set('v.isProductRegionsDisable',true);
        
        //Reset Products
        var product = cmp.find('product');
        product.set("v.options",[]);
        product.set("v.options_",[]);
        product.reInit();
        cmp.set("v.products",[]);
        
        
        var types = cmp.get('v.types');
        if(types!=undefined && types.length > 0){
            var coverageType = cmp.find('coverageType');
             coverageType.reInit();
            cmp.set("v.types",[]);
        }
        
        
        //Reset Role
        //cmp.set("v.role", []);    
        //cmp.find("prorole").reset();
        
        cmp.hideSpinner();
    },
    showProductFilters : function(component, event, helper) {
        var product = component.find('productSet');
        $A.util.removeClass(product, 'slds-hide');  
    },
    /*--------------------------------------- TOGGLE SECTIONS ----------------------------*/
    toggleFilters : function(component, event, helper) {
        var acc = component.find('filter');
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        } 
            var expandedSection = document.getElementById('filterRef');
            if(!expandedSection.classList.contains('slds-hide'))
            {
                    if(component.get("v.level")=='Product')
                    {
                        component.set('v.maxHeight',"576");
                        console.log('Page Size: '+component.get("v.pageSize"));
                    }
                    else
                    {
                        component.set('v.maxHeight',"576");
                        console.log('Page Size: '+component.get("v.pageSize"));
                    }
                console.log('Section Minimized');
            }
            else
            {
                    if(component.get("v.level")=='Product')
                    {
                        component.set('v.maxHeight',"283");
                        console.log('Page Size: '+component.get("v.pageSize"));
                    }
                    else
                    {
                        component.set('v.maxHeight',"350");
                        console.log('Page Size: '+component.get("v.pageSize"));
                    }
                
                console.log('Section Maximized');
            }
    },
    
    /*--------------------------------------- HELPER JS ----------------------------*/
    helperScriptsLoaded: function (cmp, event,helper) {
        cmp.set("v.isHelperScriptLoaded",true);
        cmp.set("v.needToRenderHelperLogic",true);
    }, 
    toggleScriptsLoaded: function (cmp, event,helper) {
        cmp.set("v.istoggleScriptLoaded",true);
        cmp.set("v.needToRenderToggleLogic",true);
    },
    
    /****************************************** TABLE ***************************************/
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
    
    doToggleSearch: function(cmp,event,helper){
        //cmp.showSpinner();
        helper.fetchResults(cmp,false);
         cmp.set('v.isLoadInit',false);
    },
    //changes for JIRA SALES-3698
    /*typeChangedAdd: function(cmp,event,helper){
        if(event.getParam("values").length >= 1)
            cmp.set("v.types",event.getParam("values"));
        else
        {cmp.set("v.types",[]);}    
        
    },*/
    downloadCSV : function(component,event,helper){
        component.showSpinner();
        var coverageData = component.get('v.coverageData');
        if(coverageData!=undefined && coverageData!=null && coverageData.length > 0)
        {
            var csv = helper.convertArrayOfObjectsToCSV(component,coverageData);           
            var hiddenElement = document.createElement('a');
            hiddenElement.href = 'data:attachment/xlsx,' + encodeURI(csv);
            hiddenElement.target = '_self';
            var today = new Date();
            var monthDigit = today.getMonth() + 1;
            if (monthDigit <= 9) {
                monthDigit = '0' + monthDigit;
            }
            var dayDigit = today.getDate();
            if(dayDigit <= 9){
                dayDigit = '0' + dayDigit;
            }
            
            var dateString =  today.getFullYear() + "-" + monthDigit + "-" + dayDigit
            var fileName = '';
            if(component.get('v.withoutSharing')==false){
                if(component.get('v.level')=='Client')
                    fileName = 'MyCoverage-Account-Data';
                else
                    fileName = 'MyCoverage-Product-Data';
                
            }
            else //All Coverage
            {
                if(component.get('v.level')=='Client')
                    fileName = 'AllCoverage-Account-Data';
                else
                    fileName = 'AllCoverage-Product-Data';
                
            }
            hiddenElement.download = fileName+'.csv';
            hiddenElement.click();
        }
        /*var csvdata = component.get("v.csvString");
        console.log(csvdata);
        
        if(!$A.util.isUndefinedOrNull(csvdata))
        {
            csvdata = csvdata.split(":").join("\n");
            csvdata = csvdata.split("null").join("");
            var hiddenElement = document.createElement('a');
            hiddenElement.href = 'data:attachment/xlsx,' + encodeURI(csvdata);
            hiddenElement.target = '_self';
            var fileName = '';
            if(component.get('v.withoutSharing')==false){
                if(component.get('v.level')=='Client')
                    fileName = 'MyCoverage-Account-Data';
                else
                    fileName = 'MyCoverage-Product-Data';
                
            }
            else //All Coverage
            {
                if(component.get('v.level')=='Client')
                    fileName = 'AllCoverage-Account-Data';
                else
                    fileName = 'AllCoverage-Product-Data';
                
            }
            hiddenElement.download = fileName+'.csv';
            hiddenElement.click();
            
        }
        else
        {
             component.showToast('info','info','No data found.');
        }*/
        component.hideSpinner();
    },
     /*8----------------------TOAST MESSAGES--------------*/
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
    
    /*9---------------------SORTING -----------------------------*/
    // Client-side controller called by the onsort event handler
    updateColumnSorting: function (cmp, event, helper) {
        var dataTable = cmp.find("coverageTable");
        var fieldName = event.getParam('fieldName');
        console.log('********** FIELDNAME: '+fieldName);
        var sortDirection = event.getParam('sortDirection');
        console.log('********** sortDirection: '+sortDirection);
        dataTable.set("v.sortedBy", fieldName);
        dataTable.set("v.sortedDirection", sortDirection);        
        helper.sortData(cmp, fieldName, sortDirection);
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
    
    getSelectedData: function (cmp, event) {
        var selectedRows = event.getParam('selectedRows');
        var finalRows = new Array();
        var deskRows = new Array();
        var pendingRows = new Array();
        var selRows = [];
        var push = true;
        for(var i = selectedRows.length-1;i >= 0;i--)
        {
            push = true;
            if(selectedRows[i].salesCodeCompany!=undefined && selectedRows[i].salesCodeCompany!=null
              && selectedRows[i].salesCodeCompany=='I')
            {
                push = false;
            }
            
            if(selectedRows[i].status != 'Pending' && push)
            {
                finalRows.push(selectedRows[i]);
                selRows.push(''+selectedRows[i].Id) ;
            }
            else
            {
                if(!push)
                    deskRows.push(i);
                else
                    pendingRows.push(i);
                
                delete selectedRows[i];
            }
        }
        
        var table = cmp.find("coverageTable");
        if(selRows.length > 0 && finalRows.length > 0)
        	table.set('v.selectedRows',selRows);
        else
            table.set('v.selectedRows',[]);
        cmp.set('v.selectedData',finalRows);
        finalRows.length = 0;
    },
    
        /*7.2---------Transfer-------------*/
    handleTransfer: function(cmp,event,helper){
        var transferlist =  cmp.get('v.selectedData');
        var commentAccessible = cmp.get("v.isCommentAccessible");
        console.log('Transfer: ');
        console.log(commentAccessible);
         if(cmp.get("v.isCommentAccessible")=='true' || cmp.get("v.isCommentAccessible")=='true:rw')
            commentAccessible = 'true';
        else
            commentAccessible = 'false';
        if(!$A.util.isUndefinedOrNull(transferlist))
        {
            if(transferlist.length == 0)
                cmp.showToast('','info','Please select the coverage to transfer.');
            else
            {  
                var evt = $A.get("e.force:navigateToComponent");
                evt.setParams({
                    componentDef : "c:CoverageToolTransfer",
                    componentAttributes: {
                        transferData : transferlist,
                        level : cmp.get('v.level'),
                        recordType : cmp.get('v.Include'),
                        isCommentAccessible : commentAccessible
                    }
                });
                evt.fire(); 
            }
        }
        else
            cmp.showToast('','info','Please select the coverage to transfer.');
        
       
    },
    /*7.3---------Delete-------------*/
    handleDelete: function(cmp,event,helper){
        var deletelist =  cmp.get('v.selectedData');
        if(!$A.util.isUndefinedOrNull(deletelist))
        {
            if(deletelist.length == 0)
                cmp.showToast('','info','Please select the coverage to delete.');
            else
            {  var evt = $A.get("e.force:navigateToComponent");
             evt.setParams({
                 componentDef : "c:CoverageToolDelete",
                 componentAttributes: {
                     deleteData : deletelist,
                     level : cmp.get('v.level')
                 }
             });
             evt.fire(); 
            }
        }
        else
            cmp.showToast('','info','Please select the coverage to delete.');
        
        
    },
    /*7.4---------Update-------------*/
    handleUpdate: function(cmp,event,helper){
        var updatelist =  cmp.get('v.selectedData');
        var commentAccessible = cmp.get("v.isCommentAccessible");
        /*if(cmp.get("v.isCommentAccessible")=='true:rw')
            commentAccessible = 'true';
        else
            commentAccessible = 'false';*/
        
        if(!$A.util.isUndefinedOrNull(updatelist))
        {
            if(updatelist.length == 0)
                cmp.showToast('','info','Please select the coverage to update.');
            else
            {  var evt = $A.get("e.force:navigateToComponent");
             evt.setParams({
                 componentDef : "c:CoverageToolUpdate",
                 componentAttributes: {
                     updateData : updatelist,
                     level : cmp.get('v.level'),
                     isCommentAccessible : commentAccessible
                 }
             });
             evt.fire(); 
            }
        }
        else
            cmp.showToast('','info','Please select the coverage to update.');
        
    },
     /*7.1---------ADD-------------*/
    handleAdd: function(cmp,event,helper){
       /* var addevt = $A.get("e.force:navigateToComponent");
        addevt.setParams({
            componentDef : "c:coverageToolAdd",
            componentAttributes: {
                withoutSharing : false
            }
        });
        addevt.fire(); */
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__coverageToolAdd',
            },
            state : {
                'c__source' : "CoverageTool",
                'c__reset' : true
            }
        };
        cmp.set("v.pageReference", pageReference);
        
        var navService = cmp.find("navService");
        var pageReference = cmp.get("v.pageReference");
        navService.navigate(pageReference)
        // cmp.showToast('','success','Add Clicked');
    },
    
    openCancelRequest : function(cmp,event,helper){
        /* var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:BulkApproval",
            componentAttributes: {
                isApproval : 'false'
                
            }
        });
        evt.fire();*/
         cmp.find("navService").navigate({
            "type": "standard__navItemPage",
            "attributes": {
                "apiName" : "Pending_Requests" 
            },
            "state":{
                "c__isApproval" : 'false',
                "c__source" : 'Coverage'
            }
        }, false);
    },
    
    openBulkUpload : function(component,event,helper){
        component.openPage("/apex/CoverageBulkUpload");
    },
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        
        switch (action.name) {
            case 'view_status':
                helper.actionChange(cmp,row);
                break;
        }
    },
     openPage : function(component, event){
        var params = event.getParam('arguments');
        if(params){
            var strURL = params.strURL;
            if(strURL != null){
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": strURL
                });
                urlEvent.fire();
            }
        }
    },

    

})