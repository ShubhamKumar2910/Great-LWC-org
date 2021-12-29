({
    doInit : function(component, event, helper) {
        
        component.set('v.tableColumn',new Array());
        component.set("v.tableColumn", [
            /*{label: component.get("v.ApprovalRequest"), fieldName:"ApprovalRequest", type:"text", initialWidth:150},*/
            {label: component.get("v.salesPerson"), fieldName:"salesPerson", type:"text", initialWidth:129, sortable:true},
            {label: component.get("v.accountName"), fieldName:"clientRG", type:"text", initialWidth:211, sortable:true},
            {label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:92, sortable:true},
            {label: component.get("v.productRegion"), fieldName:"productRegion", type:"text", initialWidth:150, sortable:true},
            {label: component.get("v.product"), fieldName:"product", type:"text", initialWidth:133, sortable:true},
            {label: component.get("v.role"), fieldName:"role", type:"text", initialWidth:125, sortable:true},
            
            {label: component.get("v.startDate"), fieldName:"startDate", type:"text", initialWidth:125, sortable:true},
            {label: component.get("v.endDate"), fieldName:"endDate", type:"text", initialWidth:125, sortable:true},
       {label: component.get("v.Comment"), fieldName:"Comments", type:"text", initialWidth:125, sortable:true}
        ]);
        
        component.showSpinner();
        var today = new Date();
        var monthDigit = today.getMonth() + 1;
        if (monthDigit <= 9) {
            monthDigit = '0' + monthDigit;
        }
        var dayDigit = today.getDate();
        if(dayDigit <= 9){
            dayDigit = '0' + dayDigit;
        }
        component.set('v.CoverageEndDate', today.getFullYear() + "-" + monthDigit + "-" + dayDigit);
        var filter = [];
        var filterproperty = new Object();
        var dataObject = component.get('v.deleteData');
        console.log(component.get('v.deleteData'));
        var dtValue = component.get('v.CoverageEndDate');
        var rows = [];
        if(dataObject.length ==1){
            dataObject[0].isChecked = true;
            dataObject[0].endDate = dtValue;
            filterproperty.coverageID = dataObject[0].coverageID;
            filterproperty.rgOrgID = dataObject[0].rgOrgID;
            filter.push(filterproperty);
            rows.push(dataObject[0].Id);
        }
        
        else
        {
            for (var i = 0 ; i < dataObject.length; i++){
                dataObject[i].isChecked = true;
                dataObject[i].endDate = dtValue;
                filterproperty.coverageID = dataObject[i].coverageID;
                filterproperty.rgOrgID = dataObject[i].rgOrgID;
                filter.push(filterproperty);
                filterproperty = new Object();
                rows.push(dataObject[i].Id);
                
                
            }
        }
        var action = component.get("c.getProductLevelData");
        
        console.log(component.get('v.level'));
        console.log('filter');
        console.log(filter);
        
       /* if(component.get('v.level') == 'Client'){*/
            action.setParams({"cmpfilter" : JSON.stringify(filter)}); 
            action.setCallback(this,function(response){
                var state = response.getState();            
                if(state === "SUCCESS"){
                    var responseMap = response.getReturnValue(); 
                    
                    console.log('hi in action');
                    component.set('v.modifiedCvgData',new Array()); 
                    component.set('v.modifiedCvgData',responseMap); 
                    console.log(responseMap);
                    var data = component.get('v.deleteData');
                    var dataServer = component.get('v.modifiedCvgData');
                    
                    
                    if(component.get('v.level') == 'Client'){
                        component.set('v.modifiedCvgData',dataServer);
                        var selRows = [];
                        selRows = dataServer[dataServer.length-1].selectedKeys;
                        console.log('selRows');
                        console.log(selRows); 
                        console.log(dataServer);
                        component.set('v.selectedRows', new Array());
                        component.set('v.selectedData',new Array());
                        component.set('v.selectedRows', selRows);
                        component.set('v.selectedData',dataServer);
                    }
                    else{
                        console.log('dataObject');
            console.log(dataObject);
                console.log('rows');
                console.log(rows);
            component.set('v.modifiedCvgData',new Array()); 
            component.set('v.modifiedCvgData',dataObject); 
            component.set('v.selectedRows', new Array());
            component.set('v.selectedData',new Array());
            component.set('v.selectedRows', rows);
            component.set('v.selectedData',dataObject);
           
                    }
                    //component.tableDataAssignment();
                    
                }
                component.hideSpinner();
            });
            $A.enqueueAction(action);
      /*  }*/
        
       /* else
        {
           try{
             
            console.log('dataObject');
            console.log(dataObject);
                console.log('rows');
                console.log(rows);
           
            component.set('v.selectedRows', new Array());
            component.set('v.selectedData',new Array());
            component.set('v.selectedRows', rows);
            component.set('v.selectedData',dataObject);
            component.set('v.modifiedCvgData',new Array()); 
            component.set('v.modifiedCvgData',dataObject);
            component.hideSpinner();
            }
            catch (ex){
                console.log(ex);
            } 
        } */
        
        
    },
    
    ApplyEndDate : function(component,event,helper){
        var dataObject = component.get('v.modifiedCvgData');
        var dtValue = component.get('v.CoverageEndDate');
        
        if($A.util.isUndefinedOrNull(dtValue) || dtValue===''){
            component.set('v.isButtonEnabled',true);
            component.showToast('','error','Please select the End Date to proceed.');
            
        }
        
        else
        {
            var dataSel = component.get('v.selectedData');
            
            if(dataSel.length == 0){
                component.showToast('','error','Please select a coverage record to proceed.');
                return;
            }
            
            component.set('v.isButtonEnabled',false);
            
            if(dataObject.length == 1){
                if(dataObject[0].isChecked == true){
                    dataObject[0].endDate = dtValue;
                    if(dtValue < dataObject[0].startDate){
                        dataObject[0].Comments ='End Date cannot be less than start date'; 
                    }
                    else
                    {
                      dataObject[0].Comments = '';  
                    }
                }
            }
            
            else
            {
                
                for (var i = 0 ; i < dataObject.length; i++){
                    if(dataObject[i].isChecked == true){
                        dataObject[i].endDate = dtValue;
                         if(dtValue < dataObject[i].startDate){
                        dataObject[i].Comments ='End Date cannot be less than start date'; 
                    }
                         else
                    {
                      dataObject[i].Comments = '';  
                    }
                    }
                }
            }
        }
        console.log(dataObject); 
        component.set('v.modifiedCvgData',dataObject);
        
        
    },
    
    
    
    deleteCoverage: function(component,event,helper){
        var dataSel = component.get('v.selectedData');  
        if(dataSel.length == 0){
                component.showToast('','error','Please select a coverage record to proceed.');
                return;
            }
        
        
       else if(!confirm('You are about to delete coverage. Are you sure?')){
            console.log('in confirm fail');
            return;
        }    
        
        else
        {
                      
            
            component.showSpinner();
            var deleteData = new Array();
            var delDataind = new Object();
            var dataObject = component.get('v.modifiedCvgData');
            var action = component.get("c.createDeleteDataAndSubmit");     
            
            console.log('dataObject');
            console.log(dataObject);
            
            if (dataObject.length == 1) { 
                console.log('dataObject');
                console.log(dataObject);
                
                if(dataObject[0].isChecked && ($A.util.isUndefinedOrNull(dataObject[0].Comments) || dataObject[0].Comments === '' || dataObject[0].Comments != 'End Date cannot be less than start date'))
                {
                    dataObject[0].isChecked =false;
                    delDataind.salesCode = dataObject[0].coverageID;
                    
                    delDataind.productGroup = dataObject[0].productGroup;
                    delDataind.productRegion = dataObject[0].productRegion;
                    delDataind.productName = dataObject[0].product;
                    
                    delDataind.role = dataObject[0].role;
                    
                    delDataind.salesCodeID = dataObject[0].salesCodeID;
                    
                    delDataind.action = 'delete';
                    if(!$A.util.isUndefinedOrNull(dataObject[0].endDate))
                    {
                        var dateString = dataObject[0].endDate;
                        var splitDate = dateString.split("-");
                        
                        console.log(dateString);
                        console.log(splitDate);
                        if(splitDate.length==3)
                            delDataind.fromDate  = splitDate[1]+'/'+splitDate[2]+'/'+splitDate[0];
                        else
                            delDataind.fromDate  = '';
                    }
                    
                    
                    if(dataObject[0].rgOrgID != '' && dataObject[0].rgOrgID != 'undefined')
                    {
                        delDataind.clientRGKey = dataObject[0].rgOrgID;
                    }
                    if(dataObject[0].rgOrgID != '' && dataObject[0].rmOrgID != 'undefined')
                    {
                        delDataind.clientRMKey = dataObject[0].rmOrgID;
                    }
                    deleteData.push(delDataind);
                    delDataind = new Object();
                }
            }
            
            else
            {
              if (dataObject.length > 1) { 
                  for (var n=0; n < dataObject.length; n++){
                    console.log( $A.util.isUndefinedOrNull(dataObject[n].Comments));
                      console.log(dataObject[n].isChecked);
                
                if(dataObject[n].isChecked && ($A.util.isUndefinedOrNull(dataObject[n].Comments) || dataObject[n].Comments === '' || dataObject[n].Comments != 'End Date cannot be less than start date'))
                {
                    dataObject[n].isChecked =false;
                    delDataind.salesCode = dataObject[n].coverageID;
                    
                    delDataind.productGroup = dataObject[n].productGroup;
                    delDataind.productRegion = dataObject[n].productRegion;
                    delDataind.productName = dataObject[n].product;
                    
                    delDataind.role = dataObject[n].role;
                    
                    delDataind.salesCodeID = dataObject[n].salesCodeID;
                    
                    delDataind.action = 'delete';
                    if(!$A.util.isUndefinedOrNull(dataObject[n].endDate))
                    {
                        var dateString = dataObject[n].endDate;
                        var splitDate = dateString.split("-");
                        
                        console.log(dateString);
                        console.log(splitDate);
                        if(splitDate.length==3)
                            delDataind.fromDate  = splitDate[1]+'/'+splitDate[2]+'/'+splitDate[0];
                        else
                            delDataind.fromDate  = '';
                    }
                    
                    
                    if(dataObject[0].rgOrgID != '' && dataObject[n].rgOrgID != 'undefined')
                    {
                        delDataind.clientRGKey = dataObject[n].rgOrgID;
                    }
                    if(dataObject[0].rgOrgID != '' && dataObject[n].rmOrgID != 'undefined')
                    {
                        delDataind.clientRMKey = dataObject[n].rmOrgID;
                    }
                    deleteData.push(delDataind);
                    delDataind = new Object();
                }
            }
        }
            }
            console.log('deleteData');
            console.log(JSON.stringify(deleteData));
            
            if(deleteData.length == 0){
               component.showToast('','error','Please select valid coverage records to proceed'); 
                component.hideSpinner();
                return;
            }
            
            action.setParams({"cmpdeleteData" : JSON.stringify(deleteData)}); 
            action.setCallback(this,function(response){
                var state = response.getState();
                
                if(state === "SUCCESS"){
                    var resultString = response.getReturnValue();
                    console.log('resultString: '+resultString);
                    if(resultString.search("submitted")!=-1)
                    {
                       component.showToast('','success','Your requested Coverage are submitted for processing.');
                        component.hideSpinner();
                        window.history.back();
                    }
                    else
                    {
                        component.showToast('','error',resultString);
                        component.hideSpinner();
                    }
                    // 
                   /* var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef : "c:MyCoverageTool"
                    });
                    evt.fire();*/
                    
                }
                
            });
            $A.enqueueAction(action);
            
        }   
    },
    Cancel:function(component,event,helper){
        component.find("navService").navigate({
            "type": "standard__navItemPage",
            "attributes": {
                "apiName" : "Coverage" 
            }
        }, true);
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
    showSpinner : function(component,event) {
        var cmpTarget = component.find('spinnerblockDel');
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },
    /*-2.2--- HIDE SPINNER-------------------------------------*/
    hideSpinner : function(component,event) {
        var cmpTarget = component.find('spinnerblockDel');
        $A.util.addClass(cmpTarget, 'slds-hide');
    },
    
    getSelectedId : function(component, event, helper){  
        var selectedRows = event.getParam('selectedRows'); 
        component.set('v.selectedData',selectedRows);
        
        var dataObject = component.get('v.modifiedCvgData');
        var selArray = new Array();
        
        for(var m=0; m < selectedRows.length; m++){
            selArray.push(selectedRows[m].Id);
        }
        
        console.log('selectedRows');
        console.log(selectedRows);
        console.log('in ltd row selection');
        
        if(selArray.length == 1){           
            if(dataObject.length > 1){
                for (var j = 0; j < dataObject.length; j++){
                    if(!selArray.includes(dataObject[j].Id)){
                        dataObject[j].isChecked = false;
                    }
                    else
                    {
                        dataObject[j].isChecked = true;
                    }
                }
            }
            
            else if(dataObject.length ==1){
                 if(!selArray.includes(dataObject[0].Id)){
                        dataObject[0].isChecked = false;
                    }
                    else
                    {
                        dataObject[0].isChecked = true;
                    }
            }
            
        }
        
        else if(selArray.length > 1)        
        {
            for (var j = 0; j < dataObject.length; j++){
                if(!selArray.includes(dataObject[j].Id)){
                    dataObject[j].isChecked = false;
                    
                }
                else
                {
                    dataObject[j].isChecked = true;
                }
            }            
        }
        
        if(selectedRows.length > 0){
       component.set('v.modifiedCvgData',dataObject); 
        }
        
    },
    
})