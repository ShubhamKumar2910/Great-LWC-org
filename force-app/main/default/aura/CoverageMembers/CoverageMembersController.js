({
    doInit : function(component, event, helper) {
        
        component.set('v.tableColumn',new Array());
        var visibilityaction = component.get("c.getVisibilityCriteria");
        //commented for JIRA 3698
        //helper.fetchNFPEType(component);
        helper.fetchProductList(component);
        visibilityaction.setCallback(this,function(response){
            if(response.getState()=='SUCCESS'){
                //commented type for SALES -3698
                var responseMapVisibility = response.getReturnValue(); 
                component.set('v.visibility',responseMapVisibility);
                if(component.get('v.visibility') == 'true:rw' || component.get('v.visibility') == 'true'){
                    component.set("v.tableColumn", [
                        {label: component.get("v.salesPerson"), fieldName:"Name", type:"text", initialWidth:150, sortable:true},
                        {label: component.get("v.division"), fieldName:"Division", type:"text", initialWidth:100, sortable:true},
                        {label: component.get("v.salesDesk"), fieldName:"SalesDesk", type:"text", initialWidth:175, sortable:true},
                        {label: component.get("v.salesDeskRegion"), fieldName:"SalesDeskRegion", type:"text", initialWidth:91, sortable:true},
                        {label: component.get("v.coverageRole"), fieldName:"CoverageRole", type:"text", initialWidth:91, sortable:true},
                        {label: component.get("v.coverageStartDate"), fieldName:"CoverageStartDate", type:"date", initialWidth:114, sortable:true},
                        //{label: component.get("v.Entity"), fieldName:"Type", type:"Entity", initialWidth:125, sortable:true},
                        {label: component.get("v.comment"), fieldName:"Comment", type:"string", initialWidth:106, sortable:true}
                         
                    ]); 
                }
                else
                {
                    component.set("v.tableColumn", [
                        {label: component.get("v.salesPerson"), fieldName:"Name", type:"text", initialWidth:150, sortable:true},
                        {label: component.get("v.division"), fieldName:"Division", type:"text", initialWidth:100, sortable:true},
                        {label: component.get("v.salesDesk"), fieldName:"SalesDesk", type:"text", initialWidth:225, sortable:true},
                        {label: component.get("v.salesDeskRegion"), fieldName:"SalesDeskRegion", type:"text", initialWidth:91, sortable:true},
                        {label: component.get("v.coverageRole"), fieldName:"CoverageRole", type:"text", initialWidth:91, sortable:true},
                        {label: component.get("v.coverageStartDate"), fieldName:"CoverageStartDate", type:"date", initialWidth:114, sortable:true}
                        //{label: component.get("v.Entity"), fieldName:"Type", type:"string", initialWidth:81, sortable:true}
                    ]);
                }
                component.reloadData();
            }
        });
        $A.enqueueAction(visibilityaction);
        
    }, 

    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        //Once record is loaded
        if(eventParams.changeType === "LOADED"){
            //Fetch the value for RecordType.DeveloperName
            var recordTypeDeveloperName = component.get("v.simpleAcctViewRecord.RecordType.DeveloperName");
            component.set("v.recordTypeDeveloperName", recordTypeDeveloperName);
            
        }
    },

    /*
    New Coverage Tool Navigation

    handleAdd : function(component, event, helper) {
        var accountRecordId = component.get('v.recordId');
        var pageReference = {
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'coverageView'
            },
            state: {
                "c__operation": 'add',
                "c__accountLookupId": accountRecordId,
            }
        };
        // var pageReference = {
        //     type: 'standard__component',
        //     attributes: {
        //         componentName: 'c__coverageToolAdd'                                
        //     },
        //     state : {
        //         "c__source" : "AccountPage",
        //         "c__reset" : true,
        //         "c__accountLookupId": accountRecordId
                
        //     }
        // };
        
        // var pageReference = {
        //     type: 'standard__component',
        //     attributes: {
        //         componentName: 'c__ToolUnderMaintenance'                                
        //     },
        //     state : {
        //         "c__source" : "AccountPage",
        //         "c__reset" : true,
        //         "c__accountLookupId": accountRecordId
                
        //     }
        // };
        component.set("v.pageReference", pageReference);
        
        var navService = component.find("navService");
        var pageReference = component.get("v.pageReference");
        navService.navigate(pageReference)
    }, 
    */

   handleAdd : function(component, event, helper) {
        var accountRecordId = component.get('v.recordId');
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__coverageToolAdd'                                
            },
            state : {
                "c__source" : "AccountPage",
                "c__reset" : true,
                "c__accountLookupId": accountRecordId
                
            }
        };
        component.set("v.pageReference", pageReference);
        
        var navService = component.find("navService");
        var pageReference = component.get("v.pageReference");
        navService.navigate(pageReference)
    },

    reloadData : function(component,event,helper){
         component.set('v.cvgData',new Array());
        component.showSpinner();
        var action = component.get("c.getCoverageData");
        action.setParams({
            "AccountId" : component.get('v.recordId'),
            "regions" : component.get('v.regions'),
            "products" : component.get('v.products'),
            "entities" : 'standard'//component.get('v.entities')
        }); 
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var mainResponse =  response;   
                var responseMap = mainResponse.getReturnValue();
                console.log('response map');
                console.log(responseMap);
                component.set('v.cvgData',responseMap);
                helper.sortData(component,"Name","asc");
                component.set('v.displayFilters',true);
            }
            component.hideSpinner();
        });
        $A.enqueueAction(action);  
    },
    regionChanged: function(component,event,helper){
        var productRegions = component.find('proRegion').get('v.values');
        component.showSpinner();
        if(productRegions.length >= 1)
            component.set("v.regions", productRegions);  
        else
            component.set("v.regions", []);  
        component.reloadData();
        
    }, 
    //commented for JIRA SALES -3698
    /*entityChanged: function(component,event,helper){
        if(event.getParam("values").length >= 1)
            component.set("v.entities",event.getParam("values"));
        else
        {component.set("v.entities",[]);}   
        component.reloadData();
    },*/
    productChanged: function(component,event,helper){
        if(event.getParam("values").length >= 1)
            component.set("v.products",event.getParam("values"));
        else
        {component.set("v.products",[]);}  
        component.reloadData();
        
    },  
    showSpinner : function(component,event) {
        var cmpTarget = component.find('spinnerblockDel');
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },
    
    hideSpinner : function(component,event) {
        var cmpTarget = component.find('spinnerblockDel');
        $A.util.addClass(cmpTarget, 'slds-hide');
    },
    
    
    
    updateColumnSorting: function (cmp, event, helper) {
        var dataTable = cmp.find("cvgTable");
        var fieldName = event.getParam('fieldName');
        console.log('********** FIELDNAME: '+fieldName);
        var sortDirection = event.getParam('sortDirection');
        console.log('********** sortDirection: '+sortDirection);
        dataTable.set("v.sortedBy", fieldName);
        dataTable.set("v.sortedDirection", sortDirection);        
        helper.sortData(cmp, fieldName, sortDirection);
    }, 
    
    sortData:function (cmp, event, helper) {
        cmp.get("v.cvgData");
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
    
    downloadCSV : function(component,event,helper){
        component.showSpinner();
        component.set("v.csvData",new Array());
        var action = component.get("c.getCoverageCsvData");
        action.setParams({
            "AccountId" : component.get('v.recordId'),
            "regions" : component.get('v.regions'),
            "products" : component.get('v.products'),
            "entities" : 'standard'//component.get('v.entities')
        }); 
        
        action.setCallback(this,function(response){
            var state = response.getState();            
            if(state === "SUCCESS"){
                var responseData = response.getReturnValue(); 
                component.set("v.csvData",responseData);
                var csvdataObject = component.get("v.csvData");
                console.log(!$A.util.isUndefinedOrNull(csvdataObject));
                if(!$A.util.isUndefinedOrNull(csvdataObject))
                {console.log('csv');
                 var csv = helper.convertArrayOfObjectsToCSV(component,csvdataObject);           
                 console.log(csv);
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
                 
                 var fileName = 'Coverage_Members_'+ dateString;
                 console.log(fileName);
                 hiddenElement.download = fileName+'.csv';
                 hiddenElement.click();
                 
                }
                else
                {
                    component.showToast('info','info','No data found.');
                }
            }
        });
        $A.enqueueAction(action);
        
        
        component.hideSpinner();
    },
    
})