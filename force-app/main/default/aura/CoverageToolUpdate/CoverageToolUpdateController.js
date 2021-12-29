({
    doInit : function(component, event, helper) {
        
        console.log(component.get('v.isCommentAccessible'));
        
        component.set('v.tableColumn',new Array());
        
        if(component.get('v.isCommentAccessible') == 'true:rw'){        
            component.set("v.tableColumn", [
                /*{label: component.get("v.ApprovalRequest"), fieldName:"ApprovalRequest", type:"text", initialWidth:150},*/
                {label: component.get("v.salesPerson"), fieldName:"salesPerson", type:"text", initialWidth:150, sortable:true},
                {label: component.get("v.accountName"), fieldName:"clientRG", type:"text", initialWidth:150, sortable:true},
                {label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:100, sortable:true},
                {label: component.get("v.productRegion"), fieldName:"productRegion", type:"text", initialWidth:150, sortable:true},
                {label: component.get("v.product"), fieldName:"product", type:"text", initialWidth:200, sortable:true},
                {label: component.get("v.role"), fieldName:"role", type:"text", initialWidth:125, sortable:true},
                {label: component.get("v.newRole"), fieldName:"newRole", type:"text", initialWidth:150, sortable:true},
                {label: component.get("v.startDate"), fieldName:"startDate", type:"text", initialWidth:125, sortable:true},
                {label: component.get("v.newStartDate"), fieldName:"newStartDate", type:"text", initialWidth:125, sortable:true},
                {label: component.get("v.usercomments"), fieldName:"Comments", type:"text", initialWidth:125, sortable:true},
                {label: component.get("v.new_comment_label"), fieldName:"NewComments", type:"text", initialWidth:125, sortable:true}
            ]);
        } 
        
        else if (component.get('v.isCommentAccessible') == 'true')  {
            component.set("v.tableColumn", [
                /*{label: component.get("v.ApprovalRequest"), fieldName:"ApprovalRequest", type:"text", initialWidth:150},*/
                {label: component.get("v.salesPerson"), fieldName:"salesPerson", type:"text", initialWidth:150, sortable:true},
                {label: component.get("v.accountName"), fieldName:"clientRG", type:"text", initialWidth:150, sortable:true},
                {label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:100, sortable:true},
                {label: component.get("v.productRegion"), fieldName:"productRegion", type:"text", initialWidth:150, sortable:true},
                {label: component.get("v.product"), fieldName:"product", type:"text", initialWidth:200, sortable:true},
                {label: component.get("v.role"), fieldName:"role", type:"text", initialWidth:125, sortable:true},
                {label: component.get("v.newRole"), fieldName:"newRole", type:"text", initialWidth:150, sortable:true},
                {label: component.get("v.startDate"), fieldName:"startDate", type:"text", initialWidth:125, sortable:true},
                {label: component.get("v.newStartDate"), fieldName:"newStartDate", type:"text", initialWidth:125, sortable:true},
                {label: component.get("v.usercomments"), fieldName:"Comments", type:"text", initialWidth:125, sortable:true}
                
            ]);
        }      
            else
            {
                component.set("v.tableColumn", [
                    /*{label: component.get("v.ApprovalRequest"), fieldName:"ApprovalRequest", type:"text", initialWidth:150},*/
                    {label: component.get("v.salesPerson"), fieldName:"salesPerson", type:"text", initialWidth:150, sortable:true},
                    {label: component.get("v.accountName"), fieldName:"clientRG", type:"text", initialWidth:150, sortable:true},
                    {label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:100, sortable:true},
                	{label: component.get("v.productRegion"), fieldName:"productRegion", type:"text", initialWidth:150, sortable:true},
                    {label: component.get("v.product"), fieldName:"product", type:"text", initialWidth:200, sortable:true},
                    {label: component.get("v.role"), fieldName:"role", type:"text", initialWidth:125, sortable:true},
                    {label: component.get("v.newRole"), fieldName:"newRole", type:"text", initialWidth:150, sortable:true},
                    {label: component.get("v.startDate"), fieldName:"startDate", type:"text", initialWidth:125, sortable:true},
                    {label: component.get("v.newStartDate"), fieldName:"newStartDate", type:"text", initialWidth:125, sortable:true}
                    
                ]); 
            }
        
        
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
        
        //component.set('v.CoverageStartDate', today.getFullYear() + "-" + monthDigit + "-" + dayDigit);
        var filter = [];
        var filterproperty = new Object();
        var dataObject = component.get('v.updateData');
        console.log('updateData');
        console.log(component.get('v.updateData'));
        component.set('v.modifiedCvgData',new Array());
        
        var dtValue = component.get('v.CoverageStartDate');
        var rows = [];
        
        if(dataObject.length == 1){
            dataObject[0].isChecked = true;
            dataObject[0].rowNumber = 0;
            dataObject[0].newStartDate = '';           
            filterproperty.coverageID = dataObject[0].coverageID;
            filterproperty.rgOrgID = dataObject[0].rgOrgID;
            filterproperty.product = dataObject[0].product;
            filterproperty.productGroup = dataObject[0].productGroup;
            filterproperty.productRegion = dataObject[0].productRegion;
            
            if(dataObject[0].Type!=undefined && dataObject[0].Type!=null && dataObject[0].Type!='')
                filterproperty.Type = dataObject[0].Type;
            filter.push(filterproperty);
            rows.push(dataObject[0].Id);
            
        }
        else
        {
            
            for (var i = 0 ; i < dataObject.length; i++){
                
                dataObject[i].isChecked = true;
                dataObject[i].rowNumber = i;
                dataObject[i].newStartDate = '';               
                filterproperty.coverageID = dataObject[i].coverageID;
                filterproperty.rgOrgID = dataObject[i].rgOrgID;
                filterproperty.product = dataObject[i].product;
                filterproperty.productGroup = dataObject[i].productGroup;
                filterproperty.productRegion = dataObject[i].productRegion;
                if(dataObject[i].Type!=undefined && dataObject[i].Type!=null && dataObject[i].Type!='')
                    filterproperty.Type = dataObject[i].Type;
                
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
        action.setParams({"cmpfilter" : JSON.stringify(filter),"level":component.get('v.level')}); 
        action.setCallback(this,function(response){
            var state = response.getState();            
            if(state === "SUCCESS"){
                var responseMap = response.getReturnValue(); 
                
                console.log('hi in action');
                component.set('v.modifiedCvgData',new Array());
                component.set('v.modifiedCvgData',responseMap); 
                var dataServer = component.get('v.modifiedCvgData');
                console.log('dataServer');
                console.log(dataServer);
                if(component.get('v.level') == 'Client'){
                    
                    var selRows = [];
                    selRows = dataServer[dataServer.length-1].selectedKeys;
                    console.log('selRows');
                    console.log(selRows);
                    component.set('v.selectedRows', selRows);
                    component.set('v.selectedData',dataServer);
                    //component.set('v.updateData',dataServer);
                    
                }
                else
                {
                    console.log('dataObject');
                    console.log(dataObject);
                    component.set('v.selectedRows',new Array());
                    component.set('v.selectedRows', rows);
                    component.set('v.modifiedCvgData',dataObject)
                    component.set('v.selectedData',dataObject);
                }
                //component.tableDataAssignment();
            }
            component.hideSpinner();
            
        });
        $A.enqueueAction(action);
    }, 
    ApplySelection : function(component,event,helper){
        var dataObject = component.get('v.modifiedCvgData');
        var dtValue = component.get('v.CoverageStartDate');
        var productRoles = component.get('v.roleSelected');
        var dataSel = component.get('v.selectedData');
        var updateSalesPerson = Object.values(component.get('v.updateData'));
        var regionMap = new Map();
        var companyMap = new Map();
        var salesDeskRegions = [];
        var companies = [];
        var companyRegionCheck = false;

        for(var i = 0; i < updateSalesPerson.length; i++) {
            var salePersonId = updateSalesPerson[i]['salesPersonId'];
            var region = updateSalesPerson[i]['region'];
            var company = updateSalesPerson[i]['salesCodeCompany']
            regionMap.set(salePersonId,region);
            companyMap.set(salePersonId,company);    
        }
        component.set("v.regionMap", regionMap);
        console.log(regionMap);
        console.log(companies);
        console.log('dataObject : '+dataObject.length);
        console.log('dtValue : '+dtValue);
        console.log('productRoles : '+productRoles);
        console.log(dataSel);

        for(var i = 0; i<dataSel.length;i++) {
            if((coverage_helper_util.mandatoryPrimaryAttestRegion).indexOf(regionMap.get(dataSel[i].salesPersonId))>-1 && (coverage_helper_util.company).indexOf(companyMap.get(dataSel[i].salesPersonId))>-1)
            {
                companyRegionCheck = true;
            }
        }
        console.log(salesDeskRegions);

        if(companyRegionCheck && (coverage_helper_util.userRole).indexOf(productRoles)>-1 && !component.get("v.attestFlag"))
        {
                    component.set('v.isButtonEnabled',true);
                    component.showToast('','error','Please attest primary coverage.');
        }

        else
        {

        if($A.util.isUndefinedOrNull(dtValue) && ($A.util.isUndefinedOrNull(productRoles) || productRoles ==="None" || productRoles == '')){
            component.set('v.isButtonEnabled',true);
            component.showToast('','error','Please select either the Start Date or a role to proceed.');
        }
        
        else
        {   
            console.log('dataSel : '+dataSel.length);
            if(dataSel.length == 0){
                component.showToast('','error','Please select a coverage record to proceed.');
                return;
            }
            
            if(dataObject.length == 1){
                if(dataObject[0].isChecked == true){
                    dataObject[0].newStartDate = dtValue;
                    dataObject[0].newRole = productRoles;
                    dataObject[0].NewComments = component.get('v.comments');
                    dataObject[0].updateAction= 'UPDATE';
                }  
            }
            
            else
            {           
                
                for (var i = 0 ; i < dataObject.length; i++){
                    if(dataObject[i].isChecked == true){
                        dataObject[i].newStartDate = dtValue;
                        dataObject[i].newRole = productRoles;
                        dataObject[i].NewComments = component.get('v.comments');
                        dataObject[i].updateAction= 'UPDATE';
                    }
                }
            } 
        }
        console.log('dataObject');
        console.log(dataObject); 
        
        component.showSpinner();
        var action = component.get("c.validateddataOnApply");  
        var updateData = new Array();
        var delDataind = new Object();
        if(dataSel.length == 1)
        {
            if(dataSel[0].isChecked)
            {
                //dataObject[0].isChecked =false;
                delDataind.salesCode = dataSel[0].coverageID;
                delDataind.productGroup = dataSel[0].productGroup;
                delDataind.productRegion = dataSel[0].productRegion;
                delDataind.productName = dataSel[0].product;
                delDataind.role = dataSel[0].newRole;
                if((coverage_helper_util.mandatoryPrimaryAttestRegion).indexOf(regionMap.get(dataSel[0].salesPersonId))>-1 && (coverage_helper_util.userRole).indexOf(dataSel[0].newRole)>-1 && (coverage_helper_util.company).indexOf(dataSel[0].company)>-1)
                {
                    dataSel[0].isAttested = component.get("v.attestFlag");
                    delDataind.isAttested = component.get("v.attestFlag");
                }    
                else
                {
                    dataSel[0].isAttested = false;
                    delDataind.isAttested = false;
                }
                delDataind.action = "Update";
                delDataind.updateIndex = dataSel[0].rowNumber;
                if(dataSel[0].rgOrgID != undefined && dataSel[0].rgOrgID != '')
                {
                    delDataind.clientRGKey = dataSel[0].rgOrgID;
                }
                if( dataSel[0].rmOrgID != undefined && dataSel[0].rmOrgID != '')
                {
                    delDataind.clientRMKey = dataSel[0].rmOrgID;
                }
                
                if(dataSel[0].coverageType!=undefined && dataSel[0].coverageType!=null && dataSel[0].coverageType!='')
                    delDataind.coverageType = dataSel[0].coverageType;
                else
                    delDataind.coverageType = 'Standard';
                
                if(dataSel[0].subType!=undefined && dataSel[0].subType!=null && dataSel[0].subType!='')
                    delDataind.subType = dataSel[0].subType;
                else
                    delDataind.subType = '';
                
                if(!$A.util.isUndefinedOrNull(dataSel[0].newStartDate))
                {
                    var dateString = dataSel[0].newStartDate;
                    var splitDate = dateString.split("-");
                    
                    console.log(dateString);
                    console.log(splitDate);
                    if(splitDate.length==3)
                        delDataind.fromDate  = splitDate[1]+'/'+splitDate[2]+'/'+splitDate[0];
                    else
                        delDataind.fromDate  = '';
                }
                
                else
                {
                    if(!$A.util.isUndefinedOrNull(dataSel[0].startDate))
                    {
                        var dateString = dataSel[0].startDate;
                        var splitDate = dateString.split("-");
                        
                        console.log(dateString);
                        console.log(splitDate);
                        if(splitDate.length==3)
                            delDataind.fromDate  = splitDate[1]+'/'+splitDate[2]+'/'+splitDate[0];
                        else
                            delDataind.fromDate  = '';
                    }
                }
                
                if(!$A.util.isUndefinedOrNull(dataSel[0].NewComments))
                {
                    delDataind.Comments = dataSel[0].NewComments;
                }
                else
                {
                    delDataind.Comments = dataSel[0].Comments;
                }
                
                
                updateData.push(delDataind);
                delDataind = new Object();
            }
        }
        else if(dataSel.length >1){
            
            for (var i = 0; i < dataSel.length; i++) { 
                if(dataSel[i].isChecked)
                {
                    //dataObject[i].isChecked =false;
                    delDataind.salesCode = dataSel[i].coverageID;
                    delDataind.productGroup = dataSel[i].productGroup;
                    delDataind.productRegion = dataSel[i].productRegion;
                    delDataind.productName = dataSel[i].product;
                    delDataind.role = dataSel[i].newRole;
                    if((coverage_helper_util.mandatoryPrimaryAttestRegion).indexOf(regionMap.get(dataSel[i].salesPersonId))>-1 && (coverage_helper_util.userRole).indexOf(dataSel[i].newRole)>-1 && (coverage_helper_util.company).indexOf(dataSel[i].company)>-1)
                    {
                        dataSel[i].isAttested = component.get("v.attestFlag");
                        delDataind.isAttested = component.get("v.attestFlag");
                    }    
                    else
                    {
                        dataSel[i].isAttested = false;
                        delDataind.isAttested = false;
                    }
                    delDataind.action = "Update";
                    delDataind.updateIndex = dataSel[i].rowNumber;
                    if(dataSel[i].coverageType!=undefined && dataSel[i].coverageType!=null && dataSel[i].coverageType!='')
                        delDataind.coverageType = dataSel[i].coverageType;
                    else
                        delDataind.coverageType = 'Standard';
                    
                    if(dataSel[i].subType!=undefined && dataSel[i].subType!=null && dataSel[i].subType!='')
                        delDataind.subType = dataSel[i].subType;
                    else
                        delDataind.subType = '';
                    
                    if(!$A.util.isUndefinedOrNull(dataSel[i].newStartDate))
                    {
                        var dateString = dataSel[i].newStartDate;
                        var splitDate = dateString.split("-");
                        
                        console.log(dateString);
                        console.log(splitDate);
                        if(splitDate.length==3)
                            delDataind.fromDate  = splitDate[1]+'/'+splitDate[2]+'/'+splitDate[0];
                        else
                            delDataind.fromDate  = '';
                    }
                    
                    else
                    {
                        if(!$A.util.isUndefinedOrNull(dataSel[i].startDate))
                        {
                            var dateString = dataSel[i].startDate;
                            var splitDate = dateString.split("-");
                            
                            console.log(dateString);
                            console.log(splitDate);
                            if(splitDate.length==3)
                                delDataind.fromDate  = splitDate[1]+'/'+splitDate[2]+'/'+splitDate[0];
                            else
                                delDataind.fromDate  = '';
                        }
                    }
                    
                    if(!$A.util.isUndefinedOrNull(dataSel[i].NewComments))
                    {
                        delDataind.Comments = dataSel[i].NewComments;
                    }
                    else
                    {
                        delDataind.Comments = dataSel[i].Comments;
                    }
                    /*if(dataSel[i].rmOrgID!=undefined && dataSel[i].rmOrgID!=null && dataSel[i].rmOrgID!='')
                    {
                        delDataind.clientKey = dataSel[i].rmOrgID;
                        delDataind.clientRGKey = '';
                    }
                    else
                    {
                        delDataind.clientRGKey = dataSel[i].rgOrgID;
                    }*/
                    if(dataSel[i].rgOrgID != undefined && dataSel[i].rgOrgID != '')
                    {
                        delDataind.clientRGKey = dataSel[i].rgOrgID;
                    }
                    if( dataSel[i].rmOrgID != undefined && dataSel[i].rmOrgID != '')
                    {
                        delDataind.clientRMKey = dataSel[i].rmOrgID;
                    }
                    updateData.push(delDataind);
                    delDataind = new Object();
                }
            }
        }
        component.set("v.selectedData", dataSel);

        var jsondata = JSON.stringify(updateData);
        console.log(jsondata);
        action.setParams({"cmpupdateData" : jsondata}); 
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var result = response.getReturnValue();
                console.log('Validate result : ');
                component.set('v.result',result);
                
                if(result.totalSuccess >= 1){
                    component.set('v.guid',result.guid);
                    
                    component.set('v.isButtonEnabled',false);  
                }
                else
                {
                    component.set('v.isButtonEnabled',true);  
                }
                
                var resultdata = result.coverageRecords;
                console.log(dataObject);
                
                var indexOb = new Array();
                for(var i = 0; i<resultdata.length; i++){
                    var updateIndex =resultdata[i].updateIndex;
                    
                    if(resultdata[i].errorMessage!=undefined &&
                       resultdata[i].errorMessage!='No Validation Errors')
                    {
                        
                        dataObject[updateIndex].errorMessage = resultdata[i].errorMessage; 
                        indexOb.push(updateIndex);
                    }
                    else
                    {
                        dataObject[updateIndex].errorMessage = '';
                    }
                    
                    for(var k = 0; k<dataObject.length; k++){
                        if(!indexOb.includes(updateIndex) && k!=updateIndex)
                        {
                            dataObject[k].errorMessage = ''  ;
                        }
                        else
                        {
                        }
                    }
                    
                    
                }
                
                console.log(indexOb);
                component.set('v.tableColumn',new Array());
                
                if(component.get('v.isCommentAccessible') == 'true:rw'){        
                    component.set("v.tableColumn", [
                        /*{label: component.get("v.ApprovalRequest"), fieldName:"ApprovalRequest", type:"text", initialWidth:150},*/
                        {label: component.get("v.salesPerson"), fieldName:"salesPerson", type:"text", initialWidth:126, sortable:true},
                        {label: component.get("v.accountName"), fieldName:"clientRG", type:"text", initialWidth:239, sortable:true},
                        {label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:100, sortable:true},
                		{label: component.get("v.productRegion"), fieldName:"productRegion", type:"text", initialWidth:124, sortable:true},
                        {label: component.get("v.product"), fieldName:"product", type:"text", initialWidth:127, sortable:true},
                        {label: component.get("v.role"), fieldName:"role", type:"text", initialWidth:74, sortable:true},
                        {label: component.get("v.newRole"), fieldName:"newRole", type:"text", initialWidth:102, sortable:true},
                        {label: component.get("v.startDate"), fieldName:"startDate", type:"text", initialWidth:125, sortable:true},
                        {label: component.get("v.newStartDate"), fieldName:"newStartDate", type:"text", initialWidth:126, sortable:true},
                        {label: component.get("v.usercomments"), fieldName:"Comments", type:"text", initialWidth:90, sortable:true},
                        {label: component.get("v.new_comment_label"), fieldName:"NewComments", type:"text", initialWidth:90, sortable:true},
                        {label: component.get("v.status_label"), fieldName:"errorMessage", type:"text", initialWidth:90, sortable:true}
                    ]);
                }
                
                else if (component.get('v.isCommentAccessible') == 'true')  {
                    component.set("v.tableColumn", [
                        /*{label: component.get("v.ApprovalRequest"), fieldName:"ApprovalRequest", type:"text", initialWidth:150},*/
                        {label: component.get("v.salesPerson"), fieldName:"salesPerson", type:"text", initialWidth:126, sortable:true},
                        {label: component.get("v.accountName"), fieldName:"clientRG", type:"text", initialWidth:239, sortable:true},
                        {label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:100, sortable:true},
                		{label: component.get("v.productRegion"), fieldName:"productRegion", type:"text", initialWidth:124, sortable:true},
                        {label: component.get("v.product"), fieldName:"product", type:"text", initialWidth:127, sortable:true},
                        {label: component.get("v.role"), fieldName:"role", type:"text", initialWidth:74, sortable:true},
                        {label: component.get("v.newRole"), fieldName:"newRole", type:"text", initialWidth:102, sortable:true},
                        {label: component.get("v.startDate"), fieldName:"startDate", type:"text", initialWidth:125, sortable:true},
                        {label: component.get("v.newStartDate"), fieldName:"newStartDate", type:"text", initialWidth:126, sortable:true},
                        {label: component.get("v.usercomments"), fieldName:"Comments", type:"text", initialWidth:90, sortable:true},
                        {label: component.get("v.status_label"), fieldName:"errorMessage", type:"text", initialWidth:90, sortable:true}
                        
                    ]);
                }      
                    else
                    {
                        component.set("v.tableColumn", [
                            /*{label: component.get("v.ApprovalRequest"), fieldName:"ApprovalRequest", type:"text", initialWidth:150},*/
                            {label: component.get("v.salesPerson"), fieldName:"salesPerson", type:"text", initialWidth:126, sortable:true},
                            {label: component.get("v.accountName"), fieldName:"clientRG", type:"text", initialWidth:239, sortable:true},
                            {label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:100, sortable:true},
                			{label: component.get("v.productRegion"), fieldName:"productRegion", type:"text", initialWidth:124, sortable:true},
                            {label: component.get("v.product"), fieldName:"product", type:"text", initialWidth:147, sortable:true},
                            {label: component.get("v.role"), fieldName:"role", type:"text", initialWidth:74, sortable:true},
                            {label: component.get("v.newRole"), fieldName:"newRole", type:"text", initialWidth:102, sortable:true},
                            {label: component.get("v.startDate"), fieldName:"startDate", type:"text", initialWidth:125, sortable:true},
                            {label: component.get("v.newStartDate"), fieldName:"newStartDate", type:"text", initialWidth:146, sortable:true},
                            {label: component.get("v.status_label"), fieldName:"errorMessage", type:"text", initialWidth:141, sortable:true}
                        ]); 
                    }
                component.set('v.modifiedCvgData',dataObject);
                console.log(result);
                component.hideSpinner(); 
            }
        });
        $A.enqueueAction(action);
    }   
    },
    
    
    
    
    updateCoverage:function(component,event,helper){         
        
        try{
            var dataSel = component.get('v.selectedData');
            console.log(dataSel);
            console.log('DATASEL LENGTH: '+dataSel.length);
            var regionMap = component.get("v.regionMap");
            if(dataSel.length == 0){
                component.showToast('','error','Please select a coverage record to proceed.');
                return;
            }
            component.showSpinner();
            
            var updateData = new Array();
            var delDataind = new Object();
            if(dataSel.length == 1)
            {
                if(dataSel[0].isChecked)
                {
                    //dataObject[0].isChecked =false;
                    delDataind.salesCode = dataSel[0].coverageID;
                    delDataind.productGroup = dataSel[0].productGroup;
                    delDataind.productRegion = dataSel[0].productRegion;
                    delDataind.productName = dataSel[0].product;
                    delDataind.role = dataSel[0].newRole;
                    delDataind.action = "Update";
                    delDataind.isAttested = dataSel[0].isAttested;
                    delDataind.updateIndex = dataSel[0].rowNumber;
                    if(dataSel[0].rgOrgID != undefined && dataSel[0].rgOrgID != '')
                    {
                        delDataind.clientRGKey = dataSel[0].rgOrgID;
                    }
                    if( dataSel[0].rmOrgID != undefined && dataSel[0].rmOrgID != '')
                    {
                        delDataind.clientRMKey = dataSel[0].rmOrgID;
                    }
                    
                    if(dataSel[0].coverageType!=undefined && dataSel[0].coverageType!=null && dataSel[0].coverageType!='')
                        delDataind.coverageType = dataSel[0].coverageType;
                    else
                        delDataind.coverageType = 'Standard';
                    
                    if(dataSel[0].subType!=undefined && dataSel[0].subType!=null && dataSel[0].subType!='')
                        delDataind.subType = dataSel[0].subType;
                    else
                        delDataind.subType = '';
                    
                    if(!$A.util.isUndefinedOrNull(dataSel[0].newStartDate))
                    {
                        var dateString = dataSel[0].newStartDate;
                        var splitDate = dateString.split("-");
                        
                        console.log(dateString);
                        console.log(splitDate);
                        if(splitDate.length==3)
                            delDataind.fromDate  = splitDate[1]+'/'+splitDate[2]+'/'+splitDate[0];
                        else
                            delDataind.fromDate  = '';
                    }
                    
                    else
                    {
                        if(!$A.util.isUndefinedOrNull(dataSel[0].startDate))
                        {
                            var dateString = dataSel[0].startDate;
                            var splitDate = dateString.split("-");
                            
                            console.log(dateString);
                            console.log(splitDate);
                            if(splitDate.length==3)
                                delDataind.fromDate  = splitDate[1]+'/'+splitDate[2]+'/'+splitDate[0];
                            else
                                delDataind.fromDate  = '';
                        }
                    }
                    
                    if(!$A.util.isUndefinedOrNull(dataSel[0].NewComments))
                    {
                        delDataind.Comments = dataSel[0].NewComments;
                    }
                    else
                    {
                        delDataind.Comments = dataSel[0].Comments;
                    }
                    
                    console.log(delDataind);
                    updateData.push(delDataind);
                    delDataind = new Object();
                }
            }
            else if(dataSel.length >1){
                
                for (var i = 0; i < dataSel.length; i++) { 
                    if(dataSel[i].isChecked)
                    {
                        //dataObject[i].isChecked =false;
                        delDataind.salesCode = dataSel[i].coverageID;
                        delDataind.productGroup = dataSel[i].productGroup;
                        delDataind.productRegion = dataSel[i].productRegion;
                        delDataind.productName = dataSel[i].product;
                        delDataind.role = dataSel[i].newRole;
                        delDataind.action = "Update";
                        delDataind.isAttested = dataSel[i].isAttested;
                        delDataind.updateIndex = dataSel[i].rowNumber;
                        console.log(dataSel[i]);
                        if(dataSel[i].coverageType!=undefined && dataSel[i].coverageType!=null && dataSel[i].coverageType!='')
                            delDataind.coverageType = dataSel[i].coverageType;
                        else
                            delDataind.coverageType = 'Standard';
                        
                        if(dataSel[i].subType!=undefined && dataSel[i].subType!=null && dataSel[i].subType!='')
                            delDataind.subType = dataSel[i].subType;
                        else
                            delDataind.subType = '';
                        
                        if(!$A.util.isUndefinedOrNull(dataSel[i].newStartDate))
                        {
                            var dateString = dataSel[i].newStartDate;
                            var splitDate = dateString.split("-");
                            
                            console.log(dateString);
                            console.log(splitDate);
                            if(splitDate.length==3)
                                delDataind.fromDate  = splitDate[1]+'/'+splitDate[2]+'/'+splitDate[0];
                            else
                                delDataind.fromDate  = '';
                        }
                        
                        else
                        {
                            if(!$A.util.isUndefinedOrNull(dataSel[i].startDate))
                            {
                                var dateString = dataSel[i].startDate;
                                var splitDate = dateString.split("-");
                                
                                console.log(dateString);
                                console.log(splitDate);
                                if(splitDate.length==3)
                                    delDataind.fromDate  = splitDate[1]+'/'+splitDate[2]+'/'+splitDate[0];
                                else
                                    delDataind.fromDate  = '';
                            }
                        }
                        
                        if(!$A.util.isUndefinedOrNull(dataSel[i].NewComments))
                        {
                            delDataind.Comments = dataSel[i].NewComments;
                        }
                        else
                        {
                            delDataind.Comments = dataSel[i].Comments;
                        }
                        /*if(dataSel[i].rmOrgID!=undefined && dataSel[i].rmOrgID!=null && dataSel[i].rmOrgID!='')
                    {
                        delDataind.clientKey = dataSel[i].rmOrgID;
                        delDataind.clientRGKey = '';
                    }
                    else
                    {
                        delDataind.clientRGKey = dataSel[i].rgOrgID;
                    }*/
                        if(dataSel[i].rgOrgID != undefined && dataSel[i].rgOrgID != '')
                        {
                            delDataind.clientRGKey = dataSel[i].rgOrgID;
                        }
                        if( dataSel[i].rmOrgID != undefined && dataSel[i].rmOrgID != '')
                        {
                            delDataind.clientRMKey = dataSel[i].rmOrgID;
                        }
                        console.log(delDataind);
                        updateData.push(delDataind);
                        delDataind = new Object();
                    }
                }
            }

            
            console.log(updateData);
            var jsondata = JSON.stringify(updateData);
            var parent_action = component.get("c.validateddataOnApply");
            parent_action.setParams({"cmpupdateData" : jsondata}); 
            parent_action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    //store the return response from server (map<string,List<string>>) 
                   
                    var result = response.getReturnValue();
                    var jsondata1 = JSON.stringify(result);
                    console.log(jsondata1);
                    var action = component.get("c.submitData");             
                    action.setParams({"uploadData" : jsondata1}); 
                    action.setCallback(this,function(response){
                        var state = response.getState();
                        console.log('state :' + state);
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
                            
                        }
                        else if (state === "ERROR") {
                            var errors = response.getError();
                            if(errors){
                                if(errors[0] && errors[0].message){
                                    component.showToast('','error',errors[0].message);
                                    console.log("Error message:" + errors[0].message);
                                }
                            }else{
                                console.log("Unknown error");
                                component.showToast('','error','Unknown error');
                            } 
                            component.hideSpinner();
                        }
                        
                        
                    });
                    $A.enqueueAction(action);
                }
            });
            $A.enqueueAction(parent_action);
                    
            
            
            
            
            /*console.log('updateCoverage');
            var dataObject = component.get('v.modifiedCvgData');
            
            var updateData = new Array();
            var delDataind = new Object();
            var action = component.get("c.createUpdateDataAndSubmit");             
            if(dataObject.length == 1)
            {
                if(dataObject[0].isChecked)
                {
                    dataObject[0].isChecked =false;
                    delDataind.salesCode = dataObject[0].coverageID;
                    delDataind.productGroup = dataObject[0].productGroup;
                    delDataind.productRegion = dataObject[0].productRegion;
                    delDataind.productName = dataObject[0].product;
                    delDataind.role = dataObject[0].newRole;
                    delDataind.action = "Update";
                    
                    if(!$A.util.isUndefinedOrNull(dataObject[0].newStartDate))
                    {
                        var dateString = dataObject[0].newStartDate;
                        var splitDate = dateString.split("-");
                        
                        console.log(dateString);
                        console.log(splitDate);
                        if(splitDate.length==3)
                            delDataind.fromDate  = splitDate[1]+'/'+splitDate[2]+'/'+splitDate[0];
                        else
                            delDataind.fromDate  = '';
                    }
                    
                    else
                    {
                        if(!$A.util.isUndefinedOrNull(dataObject[0].startDate))
                        {
                            var dateString = dataObject[0].startDate;
                            var splitDate = dateString.split("-");
                            
                            console.log(dateString);
                            console.log(splitDate);
                            if(splitDate.length==3)
                                delDataind.fromDate  = splitDate[1]+'/'+splitDate[2]+'/'+splitDate[0];
                            else
                                delDataind.fromDate  = '';
                        }
                    }
                    
                    if(!$A.util.isUndefinedOrNull(dataObject[0].NewComments))
                    {
                        delDataind.Comments = dataObject[0].NewComments;
                    }
                    else
                    {
                        delDataind.Comments = dataObject[0].Comments;
                    }
                    
                    delDataind.clientRGKey = dataObject[0].rgOrgID;
                    updateData.push(delDataind);
                    delDataind = new Object();
                }
            }
            
            else if(dataObject.length >1){
                
                for (var i = 0; i < dataObject.length; i++) { 
                    if(dataObject[i].isChecked)
                    {
                        dataObject[i].isChecked =false;
                        delDataind.salesCode = dataObject[i].coverageID;
                        delDataind.productGroup = dataObject[i].productGroup;
                        delDataind.productRegion = dataObject[i].productRegion;
                        delDataind.productName = dataObject[i].product;
                        delDataind.role = dataObject[i].newRole;
                        delDataind.action = "Update";
                        
                        if(!$A.util.isUndefinedOrNull(dataObject[i].newStartDate))
                        {
                            var dateString = dataObject[i].newStartDate;
                            var splitDate = dateString.split("-");
                            
                            console.log(dateString);
                            console.log(splitDate);
                            if(splitDate.length==3)
                                delDataind.fromDate  = splitDate[1]+'/'+splitDate[2]+'/'+splitDate[0];
                            else
                                delDataind.fromDate  = '';
                        }
                        
                        else
                        {
                            if(!$A.util.isUndefinedOrNull(dataObject[i].startDate))
                            {
                                var dateString = dataObject[i].startDate;
                                var splitDate = dateString.split("-");
                                
                                console.log(dateString);
                                console.log(splitDate);
                                if(splitDate.length==3)
                                    delDataind.fromDate  = splitDate[1]+'/'+splitDate[2]+'/'+splitDate[0];
                                else
                                    delDataind.fromDate  = '';
                            }
                        }
                        
                        if(!$A.util.isUndefinedOrNull(dataObject[i].NewComments))
                        {
                            delDataind.Comments = dataObject[i].NewComments;
                        }
                        else
                        {
                            delDataind.Comments = dataObject[i].Comments;
                        }
                        
                        delDataind.clientRGKey = dataObject[i].rgOrgID;
                        updateData.push(delDataind);
                        delDataind = new Object();
                    }
                }
            }
            
            console.log('updateData :');
            console.log(updateData);
            action.setParams({"cmpupdateData" : JSON.stringify(updateData)}); 
            action.setCallback(this,function(response){
                var state = response.getState();
                console.log('state :' + state);
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
                    
                }
                
            });
            $A.enqueueAction(action);*/
        }
        catch(ex){
            component.showToast('','error',ex);
            component.hideSpinner();    }
    },
    
    Cancel:function(component,event,helper){
        //  window.history.back();
        component.find("navService").navigate({
            "type": "standard__navItemPage",
            "attributes": {
                "apiName" : "Coverage" 
            }
        }, true);
        //
        /* var evt = $A.get("e.force:navigateToComponent");
                evt.setParams({
                    componentDef : "c:CoverageTool"
                });
                evt.fire();*/
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
        var cmpTarget = component.find('spinnerblock');
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },
    /*-2.2--- HIDE SPINNER-------------------------------------*/
    hideSpinner : function(component,event) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.addClass(cmpTarget, 'slds-hide');
    },
    
    onSelectChange : function(component,event,helper){
        var selectedRole = component.find("roleUpd").get("v.value");
        component.set('v.roleSelected',selectedRole);
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
            
            else if(dataObject.length == 1)
            {
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
        
        
        
    },
    
    updateColumnSorting: function (cmp, event, helper) {
        var dataTable = cmp.find("productTable");
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