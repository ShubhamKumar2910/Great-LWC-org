({
    doInit : function(component, event, helper) {        
        component.set('v.tableColumn',new Array());
        component.set("v.tableColumn", [
            {label: component.get("v.salesPerson"), fieldName:"Name", type:"text", initialWidth:150, sortable:true},
            //{label: component.get("v.division"), fieldName:"Division", type:"text", initialWidth:100, sortable:true},
            // {label: component.get("v.salesDesk"), fieldName:"SalesDesk", type:"text", initialWidth:175, sortable:true},
            {label: component.get("v.salesDeskRegion"), fieldName:"SalesDeskRegion", type:"text", initialWidth:91, sortable:true},
            {label: component.get("v.coverageRole"), fieldName:"CoverageRole", type:"text", initialWidth:91, sortable:true},
            //{label: component.get("v.coverageStartDate"), fieldName:"CoverageStartDate", type:"date", initialWidth:114, sortable:true},
        ]);
        component.reloadData();  
    }, 
    reloadData : function(component,event,helper){
         component.set('v.cvgData',new Array());
        component.showSpinner();
        var action = component.get("c.getCoverageData");
        action.setParams({
            "AccountId" : component.get('v.recordId'),
            "regions" : component.get('v.regions'),
            "products" : component.get('v.products'),
            "entities" : 'standard'
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
            }
            component.hideSpinner();
        });
        $A.enqueueAction(action);  
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
    }
    
})