window.coverage_helper_util = (function() {
    
    
    return { 
        //1. Search
        mandatoryPrimaryAttestRegion : ["Europe"],
        company : ["N"],
        userRole : ["Primary","Primary + Secondary Team"],
        fetchSearchResults: function(component,isInit){
            component.showSpinner();
            //Client ID
            var clientIDS = component.get("v.accountIDs");
            if($A.util.isUndefinedOrNull(clientIDS))
            {
                clientIDS = new Array();   
            }
            
            //Include
            var include = component.get("v.Include");
            
            //Client Type
            var clientType = component.get("v.clientType");
            if(!$A.util.isUndefinedOrNull(clientType))
            {
                if(clientType.length == 1)
                {
                    if(clientType[0] == 'None')
                        clientType = new Array();
                }
            }
            else
            {
                clientType = new Array();
            }
            
            //Product Groups
            var pGroups = component.get("v.productGroups");
            
            //Product Regions
            var pRegions = component.get("v.productRegions");
            
            //Product
            var products = component.get("v.products");
            
            //Role
            var role = component.get("v.role");
            if(!$A.util.isUndefinedOrNull(role))
            {
                if(role.length == 1)
                {
                    if(role[0] == 'None')
                        role = new Array();
                }
            }
            else
            {
                role = new Array();
            }
            var isClone = false;
            //Sales Person
            var salesPersonIDS = component.get("v.salesPersonIDs");
            if(!$A.util.isUndefinedOrNull(component.get("v.Source")))
            {
                if(component.get("v.Source") == 'clone')
                {
                    salesPersonIDS = component.get("v.fromsalesPersons");
                    //role= null;
                    include = 'Active';
                    isClone = true;
                }
                else
                salesPersonIDS = component.get("v.salesPersonIDs");    
            }
            else
            {
                salesPersonIDS = component.get("v.salesPersonIDs");    
            }
            
            //Sales Team
            var salesTeamIDs = component.get("v.teamValues");
            var salesTeamList = component.get("v.teamObjects");
            
            //isAndOR
            var andOR = component.get("v.isANDOR");
            
            /*console.log('clientIDS length: '+clientIDS.length);
            console.log('clientType length: '+clientType.length);
            console.log('pGroups length: '+pGroups.length);
            console.log('pRegions length: '+pRegions.length);
            console.log('products length: '+products.length);
            console.log('role length: '+role.length);
            console.log('salesPersonIDS length: '+salesPersonIDS.length);
            console.log('salesPersonUserLoginIds length: '+component.get("v.salesPersonLoginIds").length);
            console.log('salesTeamIDs length: '+salesTeamIDs.length);
            console.log('Include: '+include);
            console.log('andOR: '+andOR);*/
            
            console.log('Init Value Beffore: '+isInit);
            var initialiseTable = false;
            if(component.get("v.level") == 'Product')
            {
                console.log('Level : Product');
                if(clientIDS.length == 0 && clientType.length==0 && pGroups.length==0 && pRegions.length==0
                   && products.length==0 && role.length==0 && salesPersonIDS.length == 0 && salesTeamIDs.length == 0 && !isInit)
                {
                    if(component.get("v.withoutSharing"))
                    {
                        if(!isInit)
                            isInit = false;
                    }
                    else
                    {isInit = true;}
                    initialiseTable = true; 
                }
                else
                {
                    initialiseTable = true;
                }
            }
            else if(component.get("v.level") == 'Client')
            {
                console.log('Level : Client');
                if(clientIDS.length == 0 && salesPersonIDS.length == 0  && clientType.length==0 && salesTeamIDs.length == 0 && !isInit)
                {
                    if(component.get("v.withoutSharing"))
                    {
                        if(!isInit)
                            isInit = false;
                    }
                    else
                    {isInit = true;}
                    initialiseTable = true; 
                }
                else
                {
                    initialiseTable = true
                }
                
            }
            
            console.log('Init Value After: '+isInit);
            
            
            if(initialiseTable)    
            {
                var softlimit = component.get("v.softLimit");
                var startdate = '';
                //'types':component.get('v.types'),
                if( component.get('v.CoverageStartDate')!=undefined &&  component.get('v.CoverageStartDate')!=null &&  component.get('v.CoverageStartDate')!='')
                    startdate = component.get('v.CoverageStartDate');
                   console.log('SALESPERSON: '+salesPersonIDS);
                var wparams = {
                    'clientIDS' : clientIDS,
                    'include' : include,
                    'clientType' : clientType,
                    'pGroups' : pGroups,
                    'pRegions' : pRegions,
                    'products' : products,
                    'role' : role,
                    'salesPersonIDS' : salesPersonIDS,
                    'isAndOR' : andOR,
                    'salesTeam' : salesTeamIDs,
                    'level': component.get("v.level"),
                    'softLimit':softlimit,
                    'isInit':isInit,
                    'allCoverages':component.get("v.withoutSharing"),
                    'salesPersonUserLoginIds':component.get("v.salesPersonLoginIds"),
                    'salesTeamTree':JSON.stringify(salesTeamList),
                    'isClone':isClone,
                    'types':'standard',
                    'startdate_clone':startdate,
                    'isAttested':component.get("v.attestFlag")
                };
                
                var showcheck = true;
                if(component.get("v.withoutSharing") == true)
                {
                    showcheck = false;
                }
                
                var allCoverage = component.get("v.withoutSharing");
                
                if(component.get("v.level") == 'Client')
                {
                    console.log(component.get('v.tosalesPersonIds'));
                  	this.createDataColumn(component,'Client','',allCoverage,include,true);
                  	this.createTable(component,isInit,wparams,showcheck,'','','','','clientRG','asc','getCoverageDataSearch','coverageData','332','Client');
                    //var collinks = 'clientRG:clientRGId,salesPerson:salesPersonId';
                }
                else
                {
                    this.createDataColumn(component,'Product','',allCoverage,include,false);
                    this.createTable(component,isInit,wparams,showcheck,'','','','','clientRG','asc','getCoverageDataSearch','coverageData','271','Product');
                    //var collinks = 'clientRG:clientRGId,salesPerson:salesPersonId';
                }
                
            }
        },
        
        
        //2. fetch dependant values
        fetchDepValues: function(component, productRegions, productGrps) {
            console.log('called');
            // create a empty array var for store dependent picklist values for controller field)  
            var dependentFields = [];
            var newDependantFields = [];
            newDependantFields.push({
                selected: false,
                value: "All",
                label: "All"
            });
            
            var Map = component.get("v.depnedentFieldMap");
            var Map_Request = component.get("v.depnedentFieldMapRequest");
            var regionProductMap =  component.get("v.regionProductMap");
            var productRegionSet =  component.get("v.productRegionSet");
            var ListOfDependentFields;
            var ListOfDependentFieldsRequest;
            for(var k = 0; k < productGrps.length; k++)
            {
               
                var group = productGrps[k];
                ListOfDependentFields = Map[group];
                if (ListOfDependentFields != undefined && ListOfDependentFields.length > 0) {
                    for (var i = 0; i < ListOfDependentFields.length; i++) {
                        for(var m = 0; m<productRegions.length; m++ )
            			{
                            var region = productRegions[m].trim().toLowerCase();
                            if(regionProductMap[region]!=null && regionProductMap[region].includes(ListOfDependentFields[i].toLowerCase())){
                                dependentFields.push({
                                    selected: false,
                                    value: ListOfDependentFields[i],
                                    label: ListOfDependentFields[i]
                                }); 
                            }
                        }
                    }
                }
            }
            
            var productArray = new Array();
            var source = 'search';
            if(!$A.util.isUndefinedOrNull(component.get('v.sourceUI')))
            {
                source = 'add';
            }
            for(var i = 0; i<productRegions.length; i++ )
            {
                for(var k = 0; k < dependentFields.length; k++)
                {
                    var addTolist = true;
                    var keycheck = dependentFields[k].value.toLowerCase() + ' - ' +productRegions[i].toLowerCase();
                    
                    var instinetList = [];
                    
                    instinetList.push('content - usa');
                    instinetList.push('content - europe');
                    
                    instinetList.push('futures - usa');
                    instinetList.push('futures - europe');
                    instinetList.push('instinet - futures - japan');
                    
                    instinetList.push('instinet - cash - europe');
                    instinetList.push('instinet - cash - japan');
                    instinetList.push('instinet - cash - usa');
                    instinetList.push('instinet - cash - asia');
                    
                    instinetList.push('instinet - ets - europe');
                    instinetList.push('instinet - ets - japan');
                    instinetList.push('instinet - ets - usa');
                    instinetList.push('instinet - ets - asia');

                    instinetList.push('instinet - pt - europe');
                    instinetList.push('instinet - pt - japan');
                    instinetList.push('instinet - pt - usa');
                    instinetList.push('instinet - pt - asia');

                    instinetList.push('instinet - lset - europe');
                    instinetList.push('instinet - lset - japan');
                    instinetList.push('instinet - lset - usa');
                    instinetList.push('instinet - lset - asia');

                    instinetList.push('instinet - other - europe');
                    instinetList.push('instinet - other - japan');
                    instinetList.push('instinet - other - usa');
                    instinetList.push('instinet - other - asia');

                    if(source == 'add' && (keycheck=='flow derivatives - usa' || instinetList.includes(keycheck)) ){
                        addTolist = false;
                    }
                    
                    if(productRegionSet.indexOf(keycheck) != -1 
                       && productArray.indexOf(dependentFields[k].value.toLowerCase())==-1
                      && addTolist)
                    {
                        newDependantFields.push(dependentFields[k]);    
                        productArray.push(dependentFields[k].value.toLowerCase());
                    }
                    
                }
            }
            
            
            
            // set the dependentFields variable values to State(dependent picklist field) on ui:inputselect    
            component.find('product').set("v.options", newDependantFields);
            component.find('product').reInit();
            component.set("v.isProductRegionsDisable", false);
        },
        
        //3. fetch productGroup Dependant Values
        fetchProductGroupDependantValues: function(component,objName, controllerField, dependentField) {
            // call the server side function  
            var action = component.get("c.getDependentOptionsImpl");
            //action.setStorable();
            
            // pass paramerters [object name , contrller field name ,dependent field name] -
            // to server side function 
            action.setParams({
                'objApiName': objName,
                'contrfieldApiName': controllerField,
                'depfieldApiName': dependentField
            });
            //set callback   
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    //store the return response from server (map<string,List<string>>)  
                    var StoreResponse = response.getReturnValue();
                    if(objName == 'Coverage_Team_Member__c' && controllerField == 'Product_Group__c' && dependentField == 'Product2__c')
                    {
                        console.log('DEPENDENT MAP TM:');
                        console.log(StoreResponse);
                        component.set("v.depnedentFieldMap", StoreResponse);
                        this.fetchProductGroupDependantValues(component,'Coverage_Access_Request__c', 'Product_Group__c', 'Product__c');
                    }
                    else if(objName == 'Coverage_Access_Request__c' && controllerField == 'Product_Group__c' && dependentField == 'Product__c'){
                        console.log('DEPENDENT MAP RQ:');
                        console.log(StoreResponse);
                        var value;
                        var productArray = new Array();
                        var regionProductMap = component.get('v.regionProductMap');
                        Object.keys(StoreResponse).forEach(function(key) {
                            value = StoreResponse[key];
                           
                                     
                             for (var j = 0; j < value.length; j++) {
                                 var segments = value[j].split("-");
                                 var region = segments[segments.length - 1].trim();
                                 region = region.toLowerCase();
                                 var product = value[j].substring(0,value[j].lastIndexOf('-'));
                                 
                                 if(regionProductMap[region]!==null && regionProductMap[region]!=undefined && regionProductMap[region]!==''){
                                     var productCloneArray = new Array();
                                     var existingArray = regionProductMap[region];
                                     if(!existingArray.includes(product.trim().toLowerCase()))
                                     {
                                         existingArray.push(product.trim().toLowerCase());
                                         regionProductMap[region] = existingArray;
                                     } 
                                 }
                                 else
                                 {
                                     var productCloneArray = new Array();
                                     productCloneArray.push(product.trim().toLowerCase());
                                     regionProductMap[region] = productCloneArray;
                                 }       
                             }
                         
                        });
                        component.set("v.depnedentFieldMapRequest", StoreResponse);                 
                    }
                    else
                        component.set("v.depnedentFieldMap", StoreResponse);
                    
                    this.fetchProductRegionSetValues(component);
                    
                }
            });
            $A.enqueueAction(action);
        },
        
        //4. fetch productRegion Set
        fetchProductRegionSetValues: function(component) {
            console.log('In product region set');
            // call the server side function  
            var action = component.get("c.getProductRegionsSetfromCoverageAccessObject");
            action.setStorable();
            
            //set callback   
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    //store the return response from server (map<string,List<string>>)  
                    var StoreResponse = response.getReturnValue();
                    // once set #StoreResponse to depnedentFieldMap attribute 
                    component.set("v.productRegionSet", StoreResponse);
                    this.fetchCurrentUserSalesCodeId(component);
                }
            });
            $A.enqueueAction(action);
        },
        
        //5. fetch picklist values
        fetchNFPEType: function(component) {
            // call the server side function  
            var action = component.get("c.getNFPEPicklistValues");
            action.setStorable();
            
            //set callback   
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    //store the return response from server (map<string,List<string>>)  
                    var result = response.getReturnValue();
                    console.log('NFPEPicklistValues');
                    console.log(result);
                    var newOptions = [];
                    for(var k in result){
                        if(result[k].label!='Standard')
                            newOptions.push(result[k]);
                    }
                    if(component.get('v.sourceUI')!='Add')
                        component.find('coverageType').set("v.options", newOptions);
                    else
                        component.find('coverageType').set("v.options", result);
                    component.find('coverageType').reInit();
                }
            });
            $A.enqueueAction(action);
        },
        
        /*************************************** UTIL METHODS**************************************************************/
        createTable: function(component,isInit,wparams,showcheck,label,width,api,collinks,sortColumnName,sortDirection,wrapperMethod,wrapperProperty,maxHeight,level)
        {
            component.showSpinner();
            var allCoverage = false;
            var typeofCoverage = '';
            if(component.get('v.withoutSharing')==false)
            {
                allCoverage = false;
                typeofCoverage='my';
            } 
            else
            {
                typeofCoverage='all';
                allCoverage = true;
            }
            
            // call the server side function  
            var action = component.get("c.getCoverageDataSearch");
            //action.setStorable();
            // pass paramerters [object name , contrller field name ,dependent field name] -
            // to server side function 
            console.log(wparams);
            action.setParams(wparams);
            //set callback   
            action.setCallback(this, function(response) {
                
                if (response.getState() == "SUCCESS") {
                    //store the return response from server (map<string,List<string>>)  
                    var resultdata = response.getReturnValue();
                    if(!$A.util.isUndefinedOrNull(resultdata))
                    {
                        console.log('resultdata');
                        console.log(resultdata);
                        
                        if(resultdata.exceptionMsg!='')
                        {
                            console.log('In exception message');
                            if(resultdata.exceptionMsg.includes("Aggregate query does not support queryMore()"))
                            {
                                component.showToast('info','info','Search results are more than allowed. Please refine your search criteria.');
                                
                            }
                            else if(resultdata.exceptionMsg.includes("NoMessage"))
                            {
                                component.hideSpinner();
                            }
                                else if(resultdata.exceptionMsg.includes("Search results"))
                                {
                                    component.showToast('info','info',resultdata.exceptionMsg);
                                }
                                    else if(resultdata.exceptionMsg.includes("Coverage data not found"))
                                    {
                                        component.showToast('info','info',resultdata.exceptionMsg);
                                    }
                                        else
                                        {
                                            component.showToast('','error',resultdata.exceptionMsg);
                                        }
                            component.hideDatatable();
                            component.set("v.showYTDBudgetStats",false);
                            component.set("v.buttonDisabled",true);
                            component.set("v.totalRecords",0);
                        }
                        else
                        {
                            var dataBody = resultdata.dataBody;
                            console.log('DATA BODY');
                            console.log(dataBody);
                            component.set("v.csvString",resultdata.csvString);
                            if(!$A.util.isUndefinedOrNull(resultdata.csvKeys))
                            component.set("v.keys",resultdata.csvKeys);
                            if(!$A.util.isUndefinedOrNull(resultdata.doNotShowRevenueColumns))
                            {
                                if(resultdata.doNotShowRevenueColumns)
                                {component.set("v.doNotShowRevenueColumns",true);
                                component.set("v.showYTDBudgetStats",false);}
                                else
                                {
                                    component.set("v.doNotShowRevenueColumns",false);
                                    component.set("v.showYTDBudgetStats",true);
                                }
                            }
                            else
                            {
                                component.set("v.doNotShowRevenueColumns",false);
                                component.set("v.showYTDBudgetStats",true);
                            }
                            console.log( component.get("v.doNotShowRevenueColumns"));
                            console.log( component.get("v.showYTDBudgetStats"));
                            
                            if(level == 'Client' && component.get("v.withoutSharing")==false)
                            {
                                if(!$A.util.isUndefinedOrNull(resultdata.YTDBudgetSummary))
                                    component.set("v.budgetamount",resultdata.YTDBudgetSummary);
                                
                                if(!$A.util.isUndefinedOrNull(resultdata.YTDSummary))
                                    component.set("v.ytdamount",resultdata.YTDSummary);
                                
                                if(!$A.util.isUndefinedOrNull(resultdata.WTDSummary))
                                    component.set("v.wtdamount",resultdata.WTDSummary);
                                
                                if(!$A.util.isUndefinedOrNull(resultdata.MTDSummary))
                                    component.set("v.mtdamount",resultdata.MTDSummary);
                                
                                if(!$A.util.isUndefinedOrNull(resultdata.userRegion))
                                {
                                    this.createDataColumn(component,'Client',resultdata.userRegion,allCoverage,wparams.include,resultdata.doNotShowRevenueColumns);
                                }
                                else
                                {
                                    this.createDataColumn(component,'Client','',allCoverage,wparams.include,resultdata.doNotShowRevenueColumns);
                                }
                                
                                if(dataBody.length > 0)
                                {
                                    component.set("v.totalRecords",dataBody.length);
                                             
                                }
                                
                                
                            }
                            
                            
                            if(level == 'Product' && component.get("v.withoutSharing")==false)
                            {  
                                this.createDataColumn(component,'Product','',allCoverage,wparams.include,false);
                                if(dataBody.length > 0)
                                {
                                    component.set("v.totalRecords",dataBody.length);
                                      component.set('v.showYTDBudgetStats',false);
                                }
                            }
                            
                            if(wparams.include == 'InActive')
                            {
                                if(dataBody.length > 0)
                                {
                                    component.set("v.transferButtonDisabled",false);
                                    component.set("v.showDeleteUpdateAction",false);
                                }
                                else
                                {
                                    component.set("v.transferButtonDisabled",true);
                                }
                            }
                            else
                            {
                                component.set("v.transferButtonDisabled",true);
                                component.set("v.showDeleteUpdateAction",true);
                            }
                             var rows = [];
                            if(dataBody.length > 0)
                            {
                                var dataTable = component.find("coverageTable");
                                console.log(component.get('v.coverageColumns'));
                                
                             	console.log(wparams.isClone);
                                if(wparams.isClone){
                                    var data = new Array();
                                    var clone_counter = 0;
                                    var tosalespersons = component.get('v.tosalesPersonIDs');
                                    var attestFlag = component.get('v.attestFlag');
                                    
                                    console.log(component.get('v.tosalesPersonIds'));
                                   	
                                    for(var i = 0 ; i < tosalespersons.length; i++){
                                        var salescode = '';
                                        salescode = tosalespersons[i].salesCode;
                                        var target = {};
                                        for (var prop in dataBody) {
                                            target = this.jsonCopy(dataBody[prop]);
                                            target.counter = ""+clone_counter;
                                            target.salesPerson = tosalespersons[i].SObjectLabel;
                                            target.coverageID = salescode;
                                            target.salesCodeID = tosalespersons[i].SObjectId;
                                            target.isChecked = true;
                                            target.disabled = false;
                                           	target.isAttested = (this.company).indexOf(tosalespersons[i].company)>-1 && (this.mandatoryPrimaryAttestRegion).indexOf(tosalespersons[i].salesDeskRegion)>-1 && (this.userRole).indexOf(target.role)>-1 ? wparams.isAttested : false;
                                            data.push(target); 
                                            rows.push(""+clone_counter);
                                            clone_counter++;
                                        }
                                    }
                                    
                                    console.log(rows);
                                    
                                   
                                }
                                
                                
                                
                                if(data!=undefined)
                                {
                                    if(data.length > 0)
                                    {console.log(data);
                                     console.log(rows);
                                     dataTable.set('v.data',data);
                                     component.set('v.selectedData',data);
                                     dataTable.set('v.selectedRows', rows);
                                     console.log(dataTable.get('v.selectedRows'));
                                    }
                                    else
                                        dataTable.set('v.data',dataBody);
                                }
                                else
                                {
                                    dataTable.set('v.data',dataBody);
                                }
                                dataTable.set('v.columns',component.get('v.coverageColumns'));
                                
                                if(!wparams.isClone){
                                    var field = dataTable.get('v.sortedBy');
                                    console.log(field);
                                    var dir = dataTable.get('v.sortedDirection');
                                    console.log(dir);
                                    component.sortData(field,dir);
                                }
                                component.showDatatable();
                                component.set("v.buttonDisabled",false);
                                if(component.get("v.withoutSharing")==true)//All Coverage
                                {
                                    if(dataBody.length > 0)
                                    {
                                        component.set("v.totalRecords",dataBody.length);
                                    }
                                    component.set("v.showYTDBudgetStats",false);
                                    component.set("v.doNotShowRevenueColumns",true);
                                    if(!$A.util.isUndefinedOrNull(component.get("v.Source")))
                                    {
                                        if(component.get("v.Source") == 'clone')
                                        {
                                            dataTable.set('v.hideCheckboxColumn',false);
                                        }
                                        else
                                        {
                                             dataTable.set('v.hideCheckboxColumn',true);
                                        }
                                    }else
                                    {
                                         dataTable.set('v.hideCheckboxColumn',true);
                                    }
                                   
                                }
								else {
                                    dataTable.set('v.hideCheckboxColumn',false);
                                }
                            }
                            else
                            {
                                component.hideDatatable();
                                component.set("v.buttonDisabled",true);
                                             
                            }
                            
                        }
                    }
                    
                }
                else if (response.getState() === "INCOMPLETE") {
                    console.log('In incomplete');
                    component.showToast('error','error','No response from server or client is offline.');
                    component.hideDatatable();
                    component.set("v.showYTDBudgetStats",false);
                    component.set("v.buttonDisabled",true);
                    component.set("v.totalRecords",0);
                }
                    else if (response.getState() === "ERROR") {
                        var errors = response.getError();
                        console.log('ERRORS');
                        console.log(errors);
                        if(errors){
                            if(errors[0] && errors[0].message){
                                if(errors[0].message.includes("server") || errors[0].message.includes("Aggregate query does not support queryMore()"))
                                {
                                    component.showToast('info','info','Search results are more than allowed. Please refine your search criteria.');
                                }
                                else
                                {
                                    component.showToast('','error',errors[0].message);
                                }
                                component.hideDatatable();
                                component.set("v.showYTDBudgetStats",false);
                                component.set("v.buttonDisabled",true);
                                component.set("v.totalRecords",0);
                                console.log("Error message:" + errors[0].message);
                            }
                        }else{
                            console.log("Unknown error");
                            component.showToast('','error','Unknown error');
                        }                
                    }
                component.hideSpinner();
                
            });
            $A.enqueueAction(action);
            
        },
        jsonCopy: function(src) {
            return JSON.parse(JSON.stringify(src));
        },
        createDataColumn : function(component,level,userRegion,allCoverage,include,doNotShowRevenueColumns)
        {
            console.log('createDataColumn');
            console.log('level:'+level);
            console.log('userRegion:'+userRegion);
            console.log('allCoverage:'+allCoverage);
            console.log('include:'+include);
            var commentAccessible = component.get("v.isCommentAccessible");
            
            if(commentAccessible=='true' || commentAccessible=='true:rw')
                commentAccessible = 'true';
            
              console.log('commentAccessible:'+commentAccessible);
            
            component.set("v.coverageColumns", [{}]); 
            if($A.util.isUndefinedOrNull(doNotShowRevenueColumns))
            {
                doNotShowRevenueColumns = false;
            }
            console.log('doNotShowRevenueColumns:'+doNotShowRevenueColumns);
            
          
          	console.log('flag-1');  
            if(level == 'Client')
            {
                component.set('v.maxHeight',"350");
                if(!$A.util.isUndefinedOrNull(component.get("v.Source")))
                {
                    // clone coverage section
                    if(component.get("v.Source") == 'clone')
                    {
                        console.log('flag-2');
                        allCoverage = false;
                        component.set("v.coverageColumns", [            		
                            {label: component.get("v.account_label"), fieldName:"accountName", type:"text", initialWidth:212, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            {label: "To Salesperson", fieldName:"salesPerson", type:"text", initialWidth:279, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            {label: component.get("v.productGroup_label"), fieldName:"productGroup", type:"text", initialWidth:162, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            {label: component.get("v.product_label"), fieldName:"product", type:"text", initialWidth:164, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            {label: component.get("v.productRegion_label"), fieldName:"productRegion", type:"text", initialWidth:168, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:91, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                          	{label: component.get("v.attestation_label"), fieldName:"isAttested", type:"boolean", initialWidth:120, sortable:true},
                            {label: component.get("v.startdate_label"), fieldName:"startDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:123, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                        ]);    
                    }
                }
                else
                {
                    if(allCoverage)
                    {
                        console.log('flag-3');
                        console.log('in all coverage - client');
                        if(commentAccessible=='true')
                        {
                            console.log('flag-4');
                            //commented for SALES-3698
                            component.set("v.coverageColumns", [            		
                            {label: component.get("v.region_label"), fieldName:"region", type:"text", initialWidth:133, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            {label: component.get("v.desk_label"), fieldName:"desk", type:"text", initialWidth:181, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            {label: component.get("v.team_label"), fieldName:"team", type:"text", initialWidth:200, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:200, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:74, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            {label: component.get("v.account_label"), fieldName:"clientRG", type:"text", initialWidth:196, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            ///////{label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:104, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            {label: component.get("v.comment_label"), fieldName:"userComments", type:"text", initialWidth:250, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}}
                        ]);  
                        }
                        else
                        {
                            console.log('flag-5');
                            //commented for SALES-3698
                            component.set("v.coverageColumns", [            		
                                {label: component.get("v.region_label"), fieldName:"region", type:"text", initialWidth:133, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                {label: component.get("v.desk_label"), fieldName:"desk", type:"text", initialWidth:221, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                {label: component.get("v.team_label"), fieldName:"team", type:"text", initialWidth:235, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:248, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:94, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                {label: component.get("v.account_label"), fieldName:"clientRG", type:"text", initialWidth:299, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}}
                                //////////////{label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:92, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}}
                               
                            ]);  
                        }
                        
                    }
                    else
                    {
                        console.log('flag-6');
                        console.log('in my coverage - client');
                        
                        if(userRegion == 'Japan')
                        {
                            component.set("v.currencyCode","YEN");
                            if(doNotShowRevenueColumns)
                            {
                                if(include=='InActive')
                                {
                                    if(commentAccessible=='true')
                                    {
                                        //commented for SALES-3698
                                        component.set("v.coverageColumns", [            		
                                            {label: component.get("v.account_label"), fieldName:"clientRG", type:"text", initialWidth:184, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            ////////////{label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:92, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.team_label"), fieldName:"team", type:"text", initialWidth:232, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:182, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:94, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.startdate_label"), fieldName:"startDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:162, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.enddate_label"), fieldName:"endDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:112, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.comment_label"), fieldName:"userComments", type:"text", initialWidth:253, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}}
                                        ]); 
                                    }
                                    else
                                    {
                                        //commented for SALES-3698
                                        component.set("v.coverageColumns", [            		
                                            {label: component.get("v.account_label"), fieldName:"clientRG", type:"text", initialWidth:340, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                           /////////////////// {label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:92, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.team_label"), fieldName:"team", type:"text", initialWidth:253, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:192, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:74, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.startdate_label"), fieldName:"startDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:182, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.enddate_label"), fieldName:"endDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth: 125, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}}
                                            
                                        ]); 
                                    }
                                }
                                else
                                {
                                    if(commentAccessible=='true')
                                    {
                                        //commented for SALES-3698
                                        component.set("v.coverageColumns", [            		
                                            {label: component.get("v.account_label"), fieldName:"clientRG", type:"text", initialWidth:262, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                           ///////////// {label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:92, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.team_label"), fieldName:"team", type:"text", initialWidth:190, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:195, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:94, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.startdate_label"), fieldName:"startDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:144, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.status_label"), fieldName:"status",initialWidth:131, sortable:true,type: 'button',typeAttributes: {label: { fieldName: 'status' }, disabled:{ fieldName: 'disabled'}, variant:{fieldName: 'buttonVariant'} ,name: 'view_status'},cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.comment_label"), fieldName:"userComments", type:"text", initialWidth:200, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}}
                                        ]); 
                                    }
                                    else
                                    {
                                        //commented for SALES-3698
                                        component.set("v.coverageColumns", [            		
                                            {label: component.get("v.account_label"), fieldName:"clientRG", type:"text", initialWidth:340, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                           ///////////////// {label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:92, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.team_label"), fieldName:"team", type:"text", initialWidth:233, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:192, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:74, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.startdate_label"), fieldName:"startDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:182, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {
                                                label: component.get("v.status_label"), 
                                                fieldName:"status", sortable:true,type: 'button',
                                                typeAttributes: {
                                                    label: { fieldName: 'status' }, 
                                                    disabled:{ fieldName: 'disabled'}, 
                                                    variant:{fieldName: 'buttonVariant'} ,
                                                    name: 'view_status'
                                                },cellAttributes:{class:{fieldName:"rowDisabledClass"}}} 
                                        ]); 
                                    }
                                    
                                    
                                }
                                
                                
                            }
                            else
                            {
                                console.log('flag-7');
                                console.log('Out Japan:'+commentAccessible);
                                
                                if(include=='InActive')
                                {
                                    if(commentAccessible=='true')
                                    {
                                        //commented for SALES-3698
                                        component.set("v.coverageColumns", [            		
                                            {label: component.get("v.account_label"), fieldName:"clientRG", type:"text", initialWidth:130, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                           ////////////////// {label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:92, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.team_label"), fieldName:"team", type:"text", initialWidth:130, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:137, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.ytd_yen_label"), fieldName:"ytdRevenue", type:"number",typeAttributes: { maximumFractionDigits : 0,minimumFractionDigits : 0  }, initialWidth:100, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.budget_yen_label"), fieldName:"ytdBudget", type:"number",typeAttributes: { maximumFractionDigits : 0,minimumFractionDigits : 0  }, initialWidth:124, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.mtd_yen_label"), fieldName:"mtdRevenue", type:"number",typeAttributes: { maximumFractionDigits : 0,minimumFractionDigits : 0  }, initialWidth:120, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.wtd_yen_label"), fieldName:"wtdRevenue", type:"number",typeAttributes: { maximumFractionDigits : 0,minimumFractionDigits : 0  }, initialWidth:123, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:70, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.startdate_label"), fieldName:"startDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:97, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.enddate_label"), fieldName:"endDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:90, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.comment_label"), fieldName:"userComments", type:"text", initialWidth:95, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}}
                                        ]); 
                                    }
                                    else
                                    {
                                        //commented for SALES-3698
                                        component.set("v.coverageColumns", [            		
                                            {label: component.get("v.account_label"), fieldName:"clientRG", type:"text", initialWidth:130, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                           ///////////////// {label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:92, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.team_label"), fieldName:"team", type:"text", initialWidth:150, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:137, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.ytd_yen_label"), fieldName:"ytdRevenue", type:"number",typeAttributes: { maximumFractionDigits : 0,minimumFractionDigits : 0  }, initialWidth:110, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.budget_yen_label"), fieldName:"ytdBudget", type:"number",typeAttributes: { maximumFractionDigits : 0,minimumFractionDigits : 0  }, initialWidth:124, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.mtd_yen_label"), fieldName:"mtdRevenue", type:"number",typeAttributes: { maximumFractionDigits : 0,minimumFractionDigits : 0  }, initialWidth:120, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.wtd_yen_label"), fieldName:"wtdRevenue", type:"number",typeAttributes: { maximumFractionDigits : 0,minimumFractionDigits : 0  }, initialWidth:123, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:77, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.startdate_label"), fieldName:"startDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:97, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.enddate_label"), fieldName:"endDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:90, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}}
                                            
                                        ]); 
                                    }
                                    
                                }
                                else
                                {
                                    //commented for SALES-3698
                                    console.log('Out Japan commentAccessible: '+commentAccessible);
                                    if(commentAccessible=='true')
                                    {
                                        component.set("v.coverageColumns", [            		
                                            {label: component.get("v.account_label"), fieldName:"clientRG", type:"text", initialWidth:130, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                           ///////////////// {label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:92, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.team_label"), fieldName:"team", type:"text", initialWidth:110, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:117, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.ytd_yen_label"), fieldName:"ytdRevenue", type:"number",typeAttributes: { maximumFractionDigits : 0,minimumFractionDigits : 0  }, initialWidth:120, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.budget_yen_label"), fieldName:"ytdBudget", type:"number",typeAttributes: { maximumFractionDigits : 0,minimumFractionDigits : 0  }, initialWidth:114, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.mtd_yen_label"), fieldName:"mtdRevenue", type:"number",typeAttributes: { maximumFractionDigits : 0,minimumFractionDigits : 0  }, initialWidth:110, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.wtd_yen_label"), fieldName:"wtdRevenue", type:"number",typeAttributes: { maximumFractionDigits : 0,minimumFractionDigits : 0  }, initialWidth:113, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:77, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.startdate_label"), fieldName:"startDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:107, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.status_label"),initialWidth:104, fieldName:"status", sortable:true,type: 'button',typeAttributes: {label: { fieldName: 'status' }, disabled:{ fieldName: 'disabled'}, variant:{fieldName: 'buttonVariant'} ,name: 'view_status'},cellAttributes:{class:{fieldName:"rowDisabledClass"}}}, 
                                            {label: component.get("v.comment_label"), fieldName:"userComments", type:"text", initialWidth:115, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}}
                                        ]); 
                                    }
                                    else
                                    {
                                        //commented for SALES-3698
                                        component.set("v.coverageColumns", [            		
                                            {label: component.get("v.account_label"), fieldName:"clientRG", type:"text", initialWidth:130, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                           //////////////// {label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:92, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.team_label"), fieldName:"team", type:"text", initialWidth:130, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:137, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.ytd_yen_label"), fieldName:"ytdRevenue", type:"number",typeAttributes: { maximumFractionDigits : 0,minimumFractionDigits : 0  }, initialWidth:130, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.budget_yen_label"), fieldName:"ytdBudget", type:"number",typeAttributes: { maximumFractionDigits : 0,minimumFractionDigits : 0  }, initialWidth:124, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.mtd_yen_label"), fieldName:"mtdRevenue", type:"number",typeAttributes: { maximumFractionDigits : 0,minimumFractionDigits : 0  }, initialWidth:120, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.wtd_yen_label"), fieldName:"wtdRevenue", type:"number",typeAttributes: { maximumFractionDigits : 0,minimumFractionDigits : 0  }, initialWidth:123, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:77, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.startdate_label"), fieldName:"startDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:97, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                            {label: component.get("v.status_label"), fieldName:"status", sortable:true,initialWidth:137,type: 'button',typeAttributes: {label: { fieldName: 'status' }, disabled:{ fieldName: 'disabled'}, variant:{fieldName: 'buttonVariant'},name: 'view_status'},cellAttributes:{class:{fieldName:"rowDisabledClass"}}} 
                                        ]); 
                                    }
                                    
                                }
                            }
                            
                        }
                        else
                        {
                            console.log('flag-8');
                            component.set("v.currencyCode","USD");
                            console.log('in my coverage - client');
                            console.log('in my coverage - include: '+include);
                            if(doNotShowRevenueColumns)
                            {
                                if(include=='InActive')
                                {
                                    //commented for SALES-3698
                                    component.set("v.coverageColumns", [            		
                                        {label: component.get("v.account_label"), fieldName:"clientRG", type:"text", initialWidth:243, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                      /////////////////  {label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:92, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                        {label: component.get("v.team_label"), fieldName:"team", type:"text", initialWidth:263, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                        {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:192, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                        {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:74, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                        {label: component.get("v.startdate_label"), fieldName:"startDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:172, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                        {label: component.get("v.enddate_label"), fieldName:"endDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:235, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}}
                                        
                                    ]); 
                                }
                                else
                                {
                                    //commented for SALES-3698
                                    component.set("v.coverageColumns", [            		
                                        {label: component.get("v.account_label"), fieldName:"clientRG", type:"text", initialWidth:243, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                       ///////////////// {label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:92, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                        {label: component.get("v.team_label"), fieldName:"team", type:"text", initialWidth:263, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                        {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:192, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                        {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:74, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                        {label: component.get("v.startdate_label"), fieldName:"startDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:172, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                        {label: component.get("v.status_label"), fieldName:"status", sortable:true,type: 'button',typeAttributes: {label: { fieldName: 'status' }, disabled:{ fieldName: 'disabled'}, variant:{fieldName: 'buttonVariant'},name: 'view_status'},cellAttributes:{class:{fieldName:"rowDisabledClass"}}} 
                                    ]); 
                                }
                                
                                
                            }
                            else  
                            {  if(include=='InActive')
                            {
                                console.log('flag-9');
                                //commented for SALES-3698
                                component.set("v.coverageColumns", [            		
                                    {label: component.get("v.account_label"), fieldName:"clientRG", type:"text", initialWidth:130, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                   //////////////////////////// {label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:92, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                    {label: component.get("v.team_label"), fieldName:"team", type:"text", initialWidth:150, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                    {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:127, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                    {label: component.get("v.ytd_usd_label"), fieldName:"ytdRevenue", type:"number",typeAttributes: { maximumFractionDigits : 0,minimumFractionDigits : 0  }, initialWidth:120, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                    {label: component.get("v.budget_usd_label"), fieldName:"ytdBudget", type:"number",typeAttributes: { maximumFractionDigits : 0,minimumFractionDigits : 0  }, initialWidth:124, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                    {label: component.get("v.mtd_usd_label"), fieldName:"mtdRevenue", type:"number",typeAttributes: { maximumFractionDigits : 0,minimumFractionDigits : 0  }, initialWidth:120, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                    {label: component.get("v.wtd_usd_label"), fieldName:"wtdRevenue", type:"number",typeAttributes: { maximumFractionDigits : 0,minimumFractionDigits : 0 }, initialWidth:123, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                    {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:87, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                    {label: component.get("v.startdate_label"), fieldName:"startDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:93, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                    {label: component.get("v.enddate_label"), fieldName:"endDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:130, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}}
                                ]);
                            }
                             else
                             {
                                 console.log('flag-10');
                                 //commented for SALES-3698
                                 console.log('***');
                                 component.set("v.coverageColumns", [            		
                                     {label: component.get("v.account_label"), fieldName:"clientRG", type:"text", initialWidth:130, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                     ////////////////////////////{label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:92, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                     {label: component.get("v.team_label"), fieldName:"team", type:"text", initialWidth:130, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                     {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:147, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                     {label: component.get("v.ytd_usd_label"), fieldName:"ytdRevenue", type:"number",typeAttributes: { maximumFractionDigits : 0,minimumFractionDigits : 0 }, initialWidth:120, cellAttributes:{class:{fieldName:"rowDisabledClass"}},sortable:true},
                                     {label: component.get("v.budget_usd_label"), fieldName:"ytdBudget", type:"number",typeAttributes: { maximumFractionDigits : 0,minimumFractionDigits : 0 }, initialWidth:124, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                     {label: component.get("v.mtd_usd_label"), fieldName:"mtdRevenue", type:"number",typeAttributes: { maximumFractionDigits : 0,minimumFractionDigits : 0 }, initialWidth:120, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                     {label: component.get("v.wtd_usd_label"), fieldName:"wtdRevenue", type:"number",typeAttributes: { maximumFractionDigits : 0,minimumFractionDigits : 0 }, initialWidth:123, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                     {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:97, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                     {label: component.get("v.startdate_label"), fieldName:"startDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:93, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                     {label: component.get("v.status_label"),initialWidth:117, fieldName:"status", sortable:true,type: 'button', typeAttributes: {label: { fieldName: 'status' }, disabled:{ fieldName: 'disabled'}, variant:{fieldName: 'buttonVariant'} ,name: 'view_status'},cellAttributes:{class:{fieldName:"rowDisabledClass"}}} 
                                 ]);   
                                 
                                 
                                 //     {label: component.get("v.status_label"), fieldName:"status", type:"text", initialWidth:114, sortable:true},
                                 
                                 console.log('in my coverage - complete column assignment');
                                 
                             } 
                            }
                        }
                        
                    }
                }
                
            }
            else
            {
        		console.log('flag-11');
                component.set('v.maxHeight',"283");
                if(allCoverage)
                {
                    if(commentAccessible=='true')
                    {
                            //commented for SALES-3698
                            component.set("v.coverageColumns", [            		
                            {label: component.get("v.region_label"), fieldName:"region", type:"text", initialWidth:87, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            {label: component.get("v.desk_label"), fieldName:"desk", type:"text", initialWidth:171, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            {label: component.get("v.team_label"), fieldName:"team", type:"text", initialWidth:190, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:153, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            {label: component.get("v.product_label"), fieldName:"product", type:"text", initialWidth:114, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            {label: component.get("v.productRegion_label"), fieldName:"productRegion", type:"text", initialWidth:102, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:94, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            {label: component.get("v.account_label"), fieldName:"clientRG", type:"text", initialWidth:182, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                           //////////////////// {label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:92, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            {label: component.get("v.comment_label"), fieldName:"userComments", type:"text", initialWidth:136, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}}
                            
                        ]);
                    }
                    else
                    {
                        //commented for SALES-3698
                        component.set("v.coverageColumns", [            		
                            {label: component.get("v.region_label"), fieldName:"region", type:"text", initialWidth:123, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            {label: component.get("v.desk_label"), fieldName:"desk", type:"text", initialWidth:196, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            {label: component.get("v.team_label"), fieldName:"team", type:"text", initialWidth:190, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:197, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            {label: component.get("v.product_label"), fieldName:"product", type:"text", initialWidth:134, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            {label: component.get("v.productRegion_label"), fieldName:"productRegion", type:"text", initialWidth:159, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:85, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                            {label: component.get("v.account_label"), fieldName:"clientRG", type:"text", initialWidth:154, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}}
                           ////////////////// {label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:92, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}}

                        ]);
                    }
                     
                }
                else
                {
                    
                    if(include=='InActive')
                    {
                         if(commentAccessible=='true')
                         {
                             //commented for SALES-3698
                             component.set("v.coverageColumns", [            		
                                 {label: component.get("v.account_label"), fieldName:"clientRG", type:"text", initialWidth:215, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                 ////////////////////{label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:92, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                 {label: component.get("v.team_label"), fieldName:"team", type:"text", initialWidth:158, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                 {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:156, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                 {label: component.get("v.product_label"), fieldName:"product", type:"text", initialWidth:139, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                 {label: component.get("v.productRegion_label"), fieldName:"productRegion", type:"text", initialWidth:91, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                 {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:87, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                 {label: component.get("v.startdate_label"), fieldName:"startDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:109, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                 {label: component.get("v.enddate_label"), fieldName:"endDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:100, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                 {label: component.get("v.comment_label"), fieldName:"userComments", type:"text", initialWidth:163, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}}
                                
                             ]); 
                         }
                        else
                        {
                            //commented for SALES-3698
                             component.set("v.coverageColumns", [            		
                                 {label: component.get("v.account_label"), fieldName:"clientRG", type:"text", initialWidth:210, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                 ////////////////////{label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:92, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                 {label: component.get("v.team_label"), fieldName:"team", type:"text", initialWidth:197, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                 {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:195, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                 {label: component.get("v.product_label"), fieldName:"product", type:"text", initialWidth:180, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                 {label: component.get("v.productRegion_label"), fieldName:"productRegion", type:"text", initialWidth:97, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                 {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:91, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                 {label: component.get("v.startdate_label"), fieldName:"startDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:127, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                 {label: component.get("v.enddate_label"), fieldName:"endDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:110, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}}
                             ]); 
                        }
                    }
                    else
                    {
                        if(commentAccessible=='true')
                        {
                            component.set("v.coverageColumns", [            		
                                {label: component.get("v.account_label"), fieldName:"clientRG", type:"text", initialWidth:147, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                //////////////////////{label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:92, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                {label: component.get("v.team_label"), fieldName:"team", type:"text", initialWidth:193, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:156, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                {label: component.get("v.product_label"), fieldName:"product", type:"text", initialWidth:108, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                {label: component.get("v.productRegion_label"), fieldName:"productRegion", type:"text", initialWidth:106, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:87, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                {label: component.get("v.startdate_label"), fieldName:"startDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:123, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                {label: component.get("v.status_label"),initialWidth:117, fieldName:"status", sortable:true,type: 'button',typeAttributes: {label: { fieldName: 'status' }, disabled:{ fieldName: 'disabled'}, variant:{fieldName: 'buttonVariant'},name: 'view_status'},cellAttributes:{class:{fieldName:"rowDisabledClass"}}}, 
                                {label: component.get("v.comment_label"), fieldName:"userComments", type:"text", initialWidth:181, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}}
                            ]);    
                        }
                        else
                        {
                            //commented for SALES-3698                            
                            component.set("v.coverageColumns", [            		
                                {label: component.get("v.account_label"), fieldName:"clientRG", type:"text", initialWidth:130, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                ////////////////////{label: component.get("v.type_label"), fieldName:"Type", type:"text", initialWidth:92, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                {label: component.get("v.team_label"), fieldName:"team", type:"text", initialWidth:187, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:195, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                {label: component.get("v.product_label"), fieldName:"product", type:"text", initialWidth:170, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                {label: component.get("v.productRegion_label"), fieldName:"productRegion", type:"text", initialWidth:155, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:80, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                {label: component.get("v.startdate_label"), fieldName:"startDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:138, sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
                                {label: component.get("v.status_label"), fieldName:"status", initialWidth:145,sortable:true,type: 'button',typeAttributes: {label: { fieldName: 'status' }, disabled:{ fieldName: 'disabled'}, variant:{fieldName: 'buttonVariant'} ,name: 'view_status'},cellAttributes:{class:{fieldName:"rowDisabledClass"}}}
                            ]); 
                        }
                       
                    }
                    
                }
            }
            
        },
        
        fetchCurrentUserSalesCodeId: function(component) {
            // call the server side function  
            //component.showSpinner();
            var action = component.get("c.getCurrentUserSalesCode");
            //set callback   
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    //store the return response from server (map<string,List<string>>)  
                    var salesCodeId = response.getReturnValue();
                    console.log('salesCodeId: '+salesCodeId);
                    if(salesCodeId!='')
                    {
                        var salescodedata = salesCodeId.split('#');
                        var salespersonLookup = component.find("salesPersonsAdd");
                        if(salespersonLookup!=undefined){
                            salespersonLookup.set("v.preSelectedIds",new Array(salescodedata[0]));
                            salespersonLookup.callPreSelect();
                        }
                        
                        var salespersonLookupTool = component.find("salesPersons");
                        if(salespersonLookupTool!=undefined){
                            salespersonLookupTool.set("v.preSelectedIds",new Array(salescodedata[0]));
                            salespersonLookupTool.callPreSelect();
                        }
						
						var productGroup = salescodedata[1];
                        var productRegion = salescodedata[2];
                        var cmp =component;
                        if(cmp.find('proGroupAdd')!=undefined && $!=undefined){
                            var a = $('#'+cmp.find('proRegionAdd').get("v.parentID")+'_'+cmp.find('proRegionAdd').get("v.IDT"));
                            console.log(a);
                            a.val(productRegion).trigger('change.select2');
                            
                            var b = $('#'+cmp.find('proGroupAdd').get("v.parentID")+'_'+cmp.find('proGroupAdd').get("v.IDT"));
                            console.log(b);
                            b.val(productGroup).trigger('change');
                                               
                            
                            /*$('#'+cmp.find('proGroupAdd').get("v.parentID")+'_'+cmp.find('proGroupAdd').get("v.IDT")).val(productGroup); // Select the option with a value of '1'
                            $('#'+cmp.find('proGroupAdd').get("v.parentID")+'_'+cmp.find('proGroupAdd').get("v.IDT")).trigger('change');
                            cmp.set("v.productGroups", new Array(productGroup)); 
                            cmp.find('proGroupAdd').set('v.values',new Array(productGroup));
                            
                            $('#'+cmp.find('proRegionAdd').get("v.parentID")+'_'+cmp.find('proRegionAdd').get("v.IDT")).val(productRegion); // Select the option with a value of '1'
                            $('#'+cmp.find('proRegionAdd').get("v.parentID")+'_'+cmp.find('proRegionAdd').get("v.IDT")).trigger('change');
                            cmp.set("v.productRegion", new Array(productRegion)); 
                            cmp.find('proRegionAdd').set('v.values',new Array(productRegion));
                            cmp.set('v.isProductRegionsDisable',false);*/
                        }
                        
                        /*if(cmp.find('proGroup')!=undefined && $!=undefined){
                            $('#'+cmp.find('proGroup').get("v.parentID")+'_'+cmp.find('proGroup').get("v.IDT")).val(productGroup); // Select the option with a value of '1'
                            $('#'+cmp.find('proGroup').get("v.parentID")+'_'+cmp.find('proGroup').get("v.IDT")).trigger('change');
                            cmp.set("v.productGroups", new Array(productGroup)); 
                            cmp.find('proGroup').set('v.values',new Array(productGroup));
                            
                            
                            $('#'+cmp.find('proRegion').get("v.parentID")+'_'+cmp.find('proRegion').get("v.IDT")).val(productRegion); // Select the option with a value of '1'
                            $('#'+cmp.find('proRegion').get("v.parentID")+'_'+cmp.find('proRegion').get("v.IDT")).trigger('change');
                            cmp.set("v.productRegions", new Array(productRegion)); 
                            cmp.find('proRegion').set('v.values',new Array(productRegion));
                            cmp.set('v.isProductRegionsDisable',false);
                        }*/
                        
                        
                        
                    }
                    
                    var accountId = component.get("v.accountLookupId");
                    if(!$A.util.isUndefinedOrNull(accountId))
                    {
                        if(accountId!='')
                        {
                            var accountLookup = component.find("lookup-accountAdd");
                            accountLookup.set("v.preSelectedIds",new Array(accountId));
                            accountLookup.callPreSelect();
                        }
                    }
                    //component.hideSpinner();
                }
            });
            $A.enqueueAction(action);
        },
        
        isUploadButtonSeen: function(component) {
            var action = component.get("c.isUploadButtonSeen");
            //set callback   
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    if(!$A.util.isUndefinedOrNull(response.getReturnValue()))
                    {
                        this.fetchProductGroupDependantValues(component,'Coverage_Team_Member__c', 'Product_Group__c', 'Product2__c');
                        
                        component.set("v.isUploadButtonSeen",response.getReturnValue()); 
                        console.log('Is Upload Seen: '+component.get("v.isUploadButtonSeen"));
                        
                    }
                }
            });
            $A.enqueueAction(action);
        },
        isUserFISales: function(component) {
            var action = component.get("c.isUserRoleAEJResearch");
            //set callback   
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    component.set("v.isUserFISales",response.getReturnValue()); 
                    console.log('Is User FI Sales: '+component.get("v.isUserFISales"));
                }
            });
            $A.enqueueAction(action);
        },
        isCommentAccessible: function(component) {
            var action = component.get("c.isCommentAccessible");
            //set callback   
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    if(!$A.util.isUndefinedOrNull(response.getReturnValue()))
                    {
                        component.set("v.isCommentAccessible",response.getReturnValue()); 
                        
                        if(component.get("v.isCommentAccessible")=='true' || component.get("v.isCommentAccessible")=='true:rw')
                            component.set("v.height","352");
                        else
                            component.set("v.height","400");
                        
                        console.log('Is CommentAccessible Seen: '+component.get("v.isCommentAccessible"));
                    }
                }
            });
            $A.enqueueAction(action);
        },
      
        /***************************************B.ADD SCREEN**************************************************************/
        //5. create dummy add coverages
        createAddCoverages: function(component)
        {
            //Client ID
            var clientIDS = component.get("v.accountIDs");
            if($A.util.isUndefinedOrNull(clientIDS))
            {
                clientIDS = new Array();   
            }
            
            //Sales Person
            var salesPersonIDS = component.get("v.salesPersonIDs");
			console.log(salesPersonIDS);
            //Product Groups
            var pGroups = component.get("v.productGroups");
            
            //Product Regions
            var pRegions = component.get("v.productRegions");
            
            //Product
            var products = component.get("v.products");
            
            //Role
            var role = component.get("v.role");
            console.log('Role:'+role);
            if(!$A.util.isUndefinedOrNull(role))
            {
                if(role.length == 1)
                {
                    if(role[0] == 'None')
                        role = new Array();
                    else
                        role = role[0];
                }
            }
            else
            {
                role = new Array();
            }
            
            //Is Primary Attested?
            var isPrimaryAttested = component.get("v.attestFlag");
            
            console.log('clientIDS length: '+clientIDS.length);
            console.log('pGroups length: '+pGroups.length);
            console.log('pRegions length: '+pRegions.length);
            console.log('products length: '+products);
            console.log('role length: '+role);
            console.log('salesPersonIDS length: '+salesPersonIDS.length);
            console.log('start Date: '+component.get("v.CoverageStartDate"));
            console.log('role: ' + role);
            console.log('isAttested: '+isPrimaryAttested);
            
            component.showSpinner();
            var cTypes = new Array();
            cTypes = component.get('v.types');
            
            var dataset = new Array();
            if(pGroups.includes('Equity') && (pRegions.includes('Global') || pRegions.includes('HeadQuarter') ) && products!=undefined && products!=null && products.length >= 1){
                component.showToast('','info','Region is not valid for Equity Product Group.');
                component.hideSpinner();
            }
            else if(cTypes.length > 0 && role == 'Primary' && salesPersonIDS.length > 1){
                var type = '';
                /*for(var k = 0;k < cTypes.length;k++){
                 console.log(cTypes[k]);
                    if(cTypes[k] == 'NFPE')
                    {
                        type = cTypes[k];
                        break;
                    }
                }
                console.log(type);
                if(type!='')
                {*/
                    component.showToast('','info','Only one salesperson is allowed for NFPE as primary.');
                    
                //}
                component.hideSpinner();
            }
            else if(clientIDS.length == 0  || salesPersonIDS.length == 0 || role == '')
            {
                component.showToast('','error','Account and salesperson are mandatory.');
                component.hideSpinner();
                
            }
            else if (component.get("v.companyRegionCheck") &&  (this.userRole).indexOf(role)>-1 && !isPrimaryAttested) {
                 component.showToast('','error','Please attest primary coverage.');
                 component.hideSpinner();
           }
            else
            {
                var rgIds = clientIDS;
                var salescodeteamcoverageIds = salesPersonIDS;
                var cproductGrp = '';
                if(pGroups.length == 1)
                    cproductGrp = pGroups[0];
                
                var cproductRegion = '';
                if(pRegions.length == 1)
                    cproductRegion = pRegions[0];
                
                var cproducts = products;
                
                var crole = '';
                crole = role;
                console.log('calling Action');
                try{
                // call the server side function  
                console.log("ROLE "+role);
                    
                var action = component.get("c.getSelectedAddCoverages");
                action.setParams({
                    'clientIDS': rgIds,
                    'salesTeamCoverageIds': salesPersonIDS,
                    'pGroup': cproductGrp,
                    'pRegion': cproductRegion,
                    'products': cproducts,
                    'role': role,
                    'startdate':component.get("v.CoverageStartDate"),
                    'comments':component.get("v.comments"),
                    'coverageTypes':component.get('v.types'),
                    'isAttested': isPrimaryAttested
                });
                action.setCallback(this, function(response) {
                    if (response.getState() == "SUCCESS") {
                        //result from server
                        var resultdata = response.getReturnValue();
                        console.log(resultdata);
                        if(resultdata.length == 0)
                        {
                            component.showToast('','error','No data found.');
                            component.hideSpinner();
                        }
                        else if(resultdata.length == 1 && resultdata[0].errorResponse!=undefined && resultdata[0].errorResponse!=''){
                            component.showToast('','info',resultdata[0].errorResponse);
                            component.hideSpinner();
                        }
                            else
                            {
                                //Map
                                var dataMap = component.get("v.addSelectionDataMap");
                                
                                
                                var rows  = [];
                                var wrapperArray = new Array();
                               
                                var coverageTypes = new Array();
                                coverageTypes = component.get('v.types');
                                var j = 0;
                                var rgsWithoutRM = [];
                                resultdata.forEach(function(element) {
                                   
                                    var key = '';
                                    var rgKey = '';
                                    var rmKey = '';
                                    var salesCodeKey = '';
                                    var productKey = '';
                                    var productGrpKey = '';
                                    var productRegionKey = '';
                                    var roleKey = '';
                                    var rgKey = '';
                                    var dateKey = '';
                                    var isAttested = false;
                                    var comments = '';
                                    var coverageType = '';
                                    var subType = '';
                                    var rmRestricted = false;
                                    var numberOfRMs = '> 0';
                                    if(!$A.util.isUndefinedOrNull(element.numberOfRMs)){
                                        numberOfRMs = '= '+element.numberOfRMs;
                                    }
                                    if(!$A.util.isUndefinedOrNull(element.rmRestricted)){
                                        if(element.rmRestricted)
                                            rmRestricted = true;
                                        else
                                            rmRestricted = false;
                                    }
                                    else
                                    {
                                        rmRestricted = false;
                                    }
                                    if(!$A.util.isUndefinedOrNull(element.coverageType)){
                                        coverageType = element.coverageType;
                                    }
                                    if(!$A.util.isUndefinedOrNull(element.subType)){
                                        subType = element.subType;
                                    }
                                    if(!$A.util.isUndefinedOrNull(element.isAttested))
                                        isAttested = element.isAttested;
                                    if(!$A.util.isUndefinedOrNull(element.userComments))
                                        comments = element.userComments;
                                    if(!$A.util.isUndefinedOrNull(element.clientRGId))
                                        rgKey = element.clientRGId;
                                    if(!$A.util.isUndefinedOrNull(element.clientRMId))
                                        rmKey = element.clientRMId;
                                    if(!$A.util.isUndefinedOrNull(element.salesCodeID))
                                        salesCodeKey = element.salesCodeID;
                                    if(!$A.util.isUndefinedOrNull(element.product))
                                        productKey = element.product;
                                    if(!$A.util.isUndefinedOrNull(element.productGroup))
                                        productGrpKey = element.productGroup;
                                    if(!$A.util.isUndefinedOrNull(element.productRegion))
                                        productRegionKey = element.productRegion;
                                    if(!$A.util.isUndefinedOrNull(element.role))
                                        roleKey = element.role;
                                    if(!$A.util.isUndefinedOrNull(element.startDate))
                                        dateKey = element.startDate;
                                    var keyClone =  '';
                                    if(productKey == '')
                                    {
                                        if(coverageType != 'Standard')
                                        	key = rgKey+salesCodeKey+coverageType+subType;
                                        else
                                            key = rgKey+rmKey+salesCodeKey+coverageType+subType;
                                        
                                        keyClone = rgKey+salesCodeKey;
                                    }
                                    else
                                    {
                                        if(coverageType != 'Standard')
                                            key = rgKey+salesCodeKey+productKey+productGrpKey+productRegionKey+salesCodeKey+coverageType+subType;
                                        else
                                            key = rgKey+rmKey+salesCodeKey+productKey+productGrpKey+productRegionKey+salesCodeKey+coverageType+subType;
                                        keyClone = rgKey+salesCodeKey+productKey+productGrpKey+productRegionKey+salesCodeKey;
                                        
                                    }
                                                                 
                                     if(coverageType == 'Standard' && cTypes.includes('Standard') && !rmRestricted){
                                         keyClone = keyClone.replace(/\s/g,'');
                                        for(var k in dataMap){	
                                           	if(k.includes(keyClone) && dataMap[k].coverageType!=undefined 
                                               && dataMap[k].coverageType!=null && dataMap[k].coverageType!='Standard')
                                            {
                                                delete dataMap[k];
                                            }
                                        }
                                    }
                                    
                                    if(numberOfRMs == '= 1' && coverageType!='Standard' && !rmRestricted){
                                        var newKey = '';
                                        if(productKey == '')
                                            newKey = rgKey+salesCodeKey+'Standard';
                                        else
                                            newKey = rgKey+salesCodeKey+productKey+productGrpKey+productRegionKey+salesCodeKey+'Standard';
                                        newKey = newKey.replace(/\s/g,'');
                                        rgsWithoutRM.push(newKey);
                                    }
                              
                                    key = key.replace(/\s/g,'');
                                    if(dataMap[key]!==null && dataMap[key]!=undefined && dataMap[key]!==''){ console.log('In IF');
                                        element.key = ''+j; 
                                       
                                        if(dateKey!='' && dataMap[key].startDate!=undefined && dataMap[key].startDate!=null && dataMap[key].startDate!='')
                                        {
                                            if(dateKey!=dataMap[key].startDate)
                                                dataMap[key].startDate = dateKey;
                                        }
                                        if(roleKey!='' && dataMap[key].role!=undefined && dataMap[key].role!=null && dataMap[key].role!='')
                                        {
                                            if(roleKey!=dataMap[key].role)
                                                dataMap[key].role = roleKey;
                                        }
                                        if(dataMap[key].isAttested!=undefined && dataMap[key].isAttested!=null)
                                        {
                                            if(isAttested!=dataMap[key].isAttested)
                                                dataMap[key].isAttested = isAttested;
                                        }
                                    }
                                    else{ 
                                        dataMap[key] = JSON.stringify(element);
                                        element.key = ''+j; 
                                        dataMap[key] = element;
                                    }
                                    j++;
                                });
                                var i = 0;
                                
                                for (var key1 in dataMap) {
                                    dataMap[key1].key = ''+i; 
                                    rows.push(''+i);
                                    if(rgsWithoutRM.includes(key1))
                                    {
                                        delete dataMap[key1];
                                    }
                                    else
                                    {
                                    wrapperArray.push(dataMap[key1]);
                                    }
                                    
                                    i++;
                                }
                                if(wrapperArray.length > 0){
                                     var actions = [
                                    { label: 'View Existing Coverage', name: 'view_existing', iconName: 'utility:groups' }
                                ];
                                
                                if(component.get("v.isUserFISales")){
                                    console.log('flag-4');
                                    component.set("v.addCoverageColumns", [            		
                                        {label: component.get("v.account_label"), fieldName:"accountName", type:"text", initialWidth:216, sortable:true},
                                        {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:140, sortable:true},
                                        {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:125, sortable:true},
                                        {label: component.get("v.startdate_label"), fieldName:"startDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:121, sortable:true},
                                        {label: component.get("v.attestation_label"), fieldName:"isAttested", type:"boolean", initialWidth:120, sortable:true},
                                        {label: component.get("v.comment_label"), fieldName:"userComments", type:"text", initialWidth:275, sortable:true},
                                        { type: 'action', typeAttributes: { rowActions: actions } }
                                    ]); 
                                }   
                                else
                                {
                                    console.log('flag-5');
                                    component.set("v.addCoverageColumns", [            		
                                        {label: component.get("v.account_label"), fieldName:"accountName", type:"text", initialWidth:216, sortable:true},
                                        {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:140, sortable:true},
                                        {label: component.get("v.product_label"), fieldName:"product", type:"text", initialWidth:131, sortable:true},
                                        {label: component.get("v.productRegion_label"), fieldName:"productRegion", type:"text", initialWidth:165, sortable:true},
                                        {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:125, sortable:true},
                                        {label: component.get("v.startdate_label"), fieldName:"startDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:121, sortable:true},
                                        {label: component.get("v.attestation_label"), fieldName:"isAttested", type:"boolean", initialWidth:120, sortable:true},
                                        {label: component.get("v.comment_label"), fieldName:"userComments", type:"text", initialWidth:275, sortable:true},
                                        { type: 'action', typeAttributes: { rowActions: actions } }
                                    ]); 
                                }
                                
                                var table = component.find('addCoverageTable1');
                                component.set('v.addCoverageData',wrapperArray);
                                component.set('v.selectedRows', rows);
                                component.set("v.addSelectionDataMap",dataMap);
                                component.showDatatable();
                                component.set('v.selectedData', wrapperArray);
                                component.set("v.showRemoveButton",true);    
                                component.hideSpinner();
                                    console.log(component.get('v.addCoverageData'));
                                    console.log(component.get('v.selectedData'));
                                    
                                }
                            }
                                              
                    }
                });
                $A.enqueueAction(action);
                }
                catch(error)
                {
                    console.log(error);
                }
                
            }
            
        },
        
        //2. create bulk upload format data //addCoverageTable
        createBulkformat: function(component,tableAuraId,operation)
        {
            component.showSpinner();
            var Data = new Array();
            var childData = new Object();
            var dataselected = false;
            component.set('v.duplicateDataMap',{});
            var uniqueMap = component.get('v.duplicateDataMap');
            //try{
            var selectedData = component.get('v.selectedData');
            console.log(selectedData);
            for (var i = 0; i <selectedData.length; i++) 
            { 
                var key = '';
                var clientRDMId = '';
                if(selectedData[i].rgOrgID != null && selectedData[i].rgOrgID!='')
                {
                    clientRDMId = selectedData[i].rgOrgID;
                }   
                else
                    clientRDMId = selectedData[i].rmOrgID;
                
                var product = '';
                if(selectedData[i].product != undefined)
                    product = selectedData[i].product;
                
                key = clientRDMId + selectedData[i].coverageID;
                key = key.replace(/\s/g,'');
                console.log('********************: '+key);
                
                if(operation.toLowerCase() == 'add'){
                    var hasProduct = "false";
                    if(product!=='')
                        hasProduct = "true";
                    else
                        hasProduct = "false";
                    
                    if(uniqueMap!=undefined){
                        if(uniqueMap[key]!=null && uniqueMap[key]!='')
                        {  
                            uniqueMap[key].push(hasProduct);  
                        }
                        else
                        {
                            uniqueMap[key] = [];
                            uniqueMap[key].push(hasProduct);  
                        }
                    }
                    
                }
                dataselected = true;
                childData = new Object();
                childData.clientRGKey = selectedData[i].rgOrgID;
                childData.clientKey = selectedData[i].rmOrgID;
                childData.coverageType = selectedData[i].coverageType;
                if(selectedData[i].subType!=undefined && selectedData[i].subType!=null && selectedData[i].subType!='')
                    childData.subType = selectedData[i].subType;
                if(operation == "transferAdd")
                {
                    childData.salesCode = selectedData[i].transferToSalesCode;
                    childData.transferFromId = selectedData[i].salesCodeID;
                    childData.transferFrom = selectedData[i].salesPerson;
                    childData.transferTo = selectedData[i].transferTo;
                }
                else
                {
                    childData.salesCode = selectedData[i].coverageID;
                }
                childData.productGroup = selectedData[i].productGroup;
                childData.productRegion = selectedData[i].productRegion;
                childData.productName = selectedData[i].product;
                childData.role = selectedData[i].role;
                childData.isAttested = selectedData[i].isAttested;
                childData.rmRestricted = selectedData[i].rmRestricted;
                console.log(selectedData);
                
                if(selectedData[i].userComments!=undefined && selectedData[i].userComments!=null)
                    childData.userComments = selectedData[i].userComments;
                
                if(operation.toLowerCase() == 'delete')
                {
                    childData.action = 'delete';
                    if(!$A.util.isUndefinedOrNull(selectedData[i].endDate))
                    {
                        var dateString = selectedData[i].endDate;
                        var splitDate = dateString.split("-");
                        if(splitDate.length==3)
                            childData.fromDate = splitDate[1]+'/'+splitDate[2]+'/'+splitDate[0];
                        else
                            childData.fromDate = '';
                    }
                }
                else if(operation.toLowerCase() == 'add')
                {
                    childData.action = 'add';
                    if(!$A.util.isUndefinedOrNull(selectedData[i].startDate))
                    {
                        var dateString = selectedData[i].startDate;
                        var splitDate = dateString.split("-");
                        if(splitDate.length==3)
                            childData.fromDate = splitDate[1]+'/'+splitDate[2]+'/'+splitDate[0];
                        else
                            childData.fromDate = '';
                    }
                }
                
                    else if(operation.toLowerCase() == 'transferadd')
                    {
                        childData.action = 'add';
                        if(!$A.util.isUndefinedOrNull(selectedData[i].newStartDate))
                        {
                            var dateString = selectedData[i].newStartDate;
                            var splitDate = dateString.split("-");
                            if(splitDate.length==3)
                                childData.fromDate = splitDate[1]+'/'+splitDate[2]+'/'+splitDate[0];
                            else
                                childData.fromDate = '';
                        }
                    }
                var donottransfer = false;
                
                if(operation.toLowerCase() == 'transferadd')
                {
                    console.log('Comments: ----: '+selectedData[i].Comments);    
                    
                    if(selectedData[i].Comments !='')
                    {
                        donottransfer = true;    
                    }
                    console.log('donottransfer: ----: '+donottransfer);    
                }
                if(!donottransfer)
                    Data.push(childData);
            }
            
            console.log(childData);
            component.set('v.duplicateDataMap',uniqueMap);
            
            var cleanedData = [];
            if(operation.toLowerCase() == 'add'){
                for(var i = 0; i < Data.length; i++)
                {
                    var key = '';
                    var clientRDMId = '';
                    if(Data[i].clientRGKey != null && Data[i].clientRGKey!='')
                    {
                        clientRDMId = Data[i].clientRGKey;
                    }   
                    else
                        clientRDMId = Data[i].clientKey;
                    
                    var product = '';
                    if(Data[i].productName != undefined)
                        product = Data[i].productName;
                    
                    
                    key = clientRDMId + Data[i].salesCode;
                    key = key.replace(/\s/g,'');
                    
                    if(uniqueMap===undefined){
                       cleanedData.push(Data[i]); 
                    }
                    else
                    {
                        if(uniqueMap[key]!=null && uniqueMap[key]!='' && product=='')
                        {  
                            if((!!uniqueMap[key].reduce(function(a, b){ return (a === b) ? a : NaN})) == false)
                            {
                                //remove that element from list
                                
                            }
                            else
                            {
                                cleanedData.push(Data[i]);
                            }
                        }
                        else
                        {
                            cleanedData.push(Data[i]);
                        }
                    }
                    
                } 
            }
            
            
            if(!dataselected)
            {
                component.showToast('','error','Please select coverage.');
                component.hideSpinner();
            }
            else
            {
                var jsonData = '';
                if(operation.toLowerCase() == 'add')
                {
                    console.log('JSON');
                    jsonData = JSON.stringify(cleanedData);
                    console.log(jsonData);
                    
                }
                else
                {
                    console.log('JSON');
                    jsonData = JSON.stringify(Data);
                    console.log(jsonData);
                }
                
                cleanedData = [];
                Data = [];
                // call the server side function  
                var action = component.get("c.validateCoverageData");
                action.setParams({
                    'jsonData': jsonData
                });
                action.setCallback(this, function(response) {
                    
                    if (response.getState() == "SUCCESS") {
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
                            console.log('Validation loaded Coverage Data: '+allRecords.length);
                            console.log(allRecords);
                            console.log(successRecords);
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
                            component.set("v.csvString", resultdata.csvString);
                            
                            var coverageData = new Object();
                            var wrapperList = new Array();
                            var rgwrapperList = new Array();
                            var rmwrapperList = new Array();
                            var counter = 0;
                            for(var i = 0; i < allRecords.length; i++)
                            {
                                coverageData = new Object();
                                if(allRecords[i].coverageType!=undefined && allRecords[i].coverageType!='')
                                {
                                    coverageData.coverageType = allRecords[i].coverageType;
                                    
                                    if(allRecords[i].coverageType!='Standard')
                                    allRecords[i].IsRG = false;
                                }
                                                                 
                                console.log('allRecords[i].IsRG: '+allRecords[i].IsRG);
                                
                                
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
                                    console.log('in 2nd block');
                                    if(allRecords[i].coverageType=='Standard')
                                    {
                                        coverageData.rmRestricted = true;
                                        allRecords[i].rmRestricted = true;
                                    }
                                }
                                console.log(coverageData.rmRestricted);
                                console.log(coverageData);
                                if(allRecords[i].IsRG)
                                    coverageData.accountName = allRecords[i].clientName;
                                else
                                {
                                    if(allRecords[i].coverageType=='Standard' && allRecords[i].rmRestricted)
                                    coverageData.accountName='('+allRecords[i].BillingCountryCode+'-Restricted Jurisdiction) - '+allRecords[i].clientName;  
                                    else if(allRecords[i].coverageType!='Standard' && !allRecords[i].rmRestricted)
                                    {
                                        if(allRecords[i].subType!=undefined && allRecords[i].subType!=null && allRecords[i].subType!='')
                                        {
                                            coverageData.accountName='('+allRecords[i].subType+') - '+allRecords[i].clientName;      
                                            coverageData.subType = allRecords[i].subType;
                                        }
                                        else
                                        coverageData.accountName='('+allRecords[i].coverageType+') - '+allRecords[i].clientName;      
                                            
                                    }
                                }
                                  
								if(coverageData.accountName!=undefined && coverageData.accountName!='')
                                coverageData.accountName = coverageData.accountName.toUpperCase();
                                
                                coverageData.product = allRecords[i].productName;
                                coverageData.productGroup = allRecords[i].productGroup;
                                coverageData.productRegion = allRecords[i].productRegion;
                                coverageData.role = allRecords[i].role;
                                if(operation == "transferAdd"){
                                    coverageData.salesCodeID = allRecords[i].salesCodeID;
                                    coverageData.salesPerson = allRecords[i].salesPerson;
                                    coverageData.transferFrom = allRecords[i].transferFrom;
                                    coverageData.transferTo = allRecords[i].transferTo;
                                    coverageData.transferToId = allRecords[i].transferToId;
                                    coverageData.coverageID = allRecords[i].coverageID;
                                }
                                else
                                {
                                    coverageData.salesCodeID =  allRecords[i].salesCodeID;
                                    coverageData.salesPerson = allRecords[i].salesPerson;
                                    coverageData.coverageID = allRecords[i].salesCode;
                                }
                                
                                coverageData.startDate = allRecords[i].fromDate;
                                coverageData.team = allRecords[i].salesTeam;
                                coverageData.Comments = allRecords[i].errorMessage;
                                coverageData.isAttested = allRecords[i].isAttested;
                                coverageData.errorType = allRecords[i].errorType;
                                console.log(coverageData);
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
                                
                                if(operation == "transferAdd")
                                {
                                    console.log('***********1*************');
                                    component.set("v.validationCoverageColumns", [
                                        {label: component.get("v.accountName"), fieldName:"accountName", type:"text", initialWidth:150, sortable:true},
                                        {label: component.get("v.transferFrom"), fieldName:"transferFrom", type:"text", initialWidth:150, sortable:true},                
                                        {label: component.get("v.transferTo"), fieldName:"transferTo", type:"text", initialWidth:150, sortable:true},                                            
                                        {label: component.get("v.productRegion"), fieldName:"productRegion", type:"text", initialWidth:150, sortable:true},
                                        {label: component.get("v.product"), fieldName:"product", type:"text", initialWidth:200, sortable:true},
                                        {label: component.get("v.role"), fieldName:"role", type:"text", initialWidth:125, sortable:true},
                                        {label: component.get("v.startDate"), fieldName:"startDate", type:"text", initialWidth:125, sortable:true},
                                        {label: component.get("v.attestation_label"), fieldName:"isAttested", type:"boolean", initialWidth:120, sortable:true},
                                        {label: component.get("v.validationStatus_label"), fieldName:"Comments", type:"text", initialWidth:125, sortable:true},
                                    ]);
                                }
                                else
                                {
                                    if(component.get("v.isUserFISales")){
                                        console.log('***********2*************');
                                        component.set("v.validationCoverageColumns", [            		
                                            {label: component.get("v.account_label"), fieldName:"accountName", type:"text", initialWidth:211, sortable:true},
                                            {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:133, sortable:true},
                                            {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:111, sortable:true},
                                            {label: component.get("v.startdate_label"), fieldName:"startDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:120, sortable:true},
                                        	{label: component.get("v.attestation_label"), fieldName:"isAttested", type:"boolean", initialWidth:120, sortable:true},    
                                        	{label: component.get("v.validationStatus_label"), fieldName:"Comments", type:"text", initialWidth:373, sortable:true}
                                        ]); 
                                    }
                                    else
                                    {
                                        console.log('***********3*************')
                                        component.set("v.validationCoverageColumns", [            		
                                            {label: component.get("v.account_label"), fieldName:"accountName", type:"text", initialWidth:211, sortable:true},
                                            {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:133, sortable:true},
                                            {label: component.get("v.product_label"), fieldName:"product", type:"text", initialWidth:133, sortable:true},
                                            {label: component.get("v.productRegion_label"), fieldName:"productRegion", type:"text", initialWidth:164, sortable:true},
                                            {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:111, sortable:true},
                                            {label: component.get("v.startdate_label"), fieldName:"startDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:120, sortable:true},
                                            {label: component.get("v.attestation_label"), fieldName:"isAttested",  type:"boolean", initialWidth:120, sortable:true},
                                            {label: component.get("v.validationStatus_label"), fieldName:"Comments", type:"text", initialWidth:373, sortable:true}
                                        ]); 
                                    }
                                   
                                }
                                
                                component.set('v.validationCoverageData',wrapperList);
                                /**/
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
                            /*var validationTable = component.find("validationTable");
                            validationTable.set('v.showRowNo',false);
                            validationTable.set('v.pageNumber',0);
                            validationTable.set('v.tableSortable',false);
                            var wrapperdata = validationTable.get('v.wrapperList');
                            validationTable.set("v.dataList",new Array());
                            validationTable.set('v.wrapperList',wrapperList);
                            validationTable.set('v.pageSize',50);
                            validationTable.set('v.maxHeight',580);
                            validationTable.set("v.showCheck",true);
                            validationTable.OnNext(false); 
                            validationTable.showTable();
                            validationTable.set("v.showCheck",false);*/
                            
                            component.hideSpinner();
                        }
                        
                        
                    }
                    else if (response.getState() === "INCOMPLETE") {
                        console.log('In incomplete');
                        component.showToast('error','error','No response from server or client is offline.');
                        component.hideValidationDatatable();
                    }
                        else if (response.getState() === "ERROR") {
                            var errors = response.getError();
                             if(errors){
                                if(errors[0] && errors[0].message){
                                        component.showToast('','error',errors[0].message);
                                    component.hideValidationDatatable();
                                    console.log("Error message:" + errors[0].message);
                                }
                            }else{
                                console.log("Unknown error");
                                component.showToast('','error','Unknown error');
                            }                
                        }
                    component.hideSpinner();
                    
                });
                $A.enqueueAction(action);
                
            }
        },
        
        submitData : function(component,successList,rgDeleteList,rmDeleteList,totalCount,guid)
        {
            console.log(successList);
            component.showSpinner();
            for(var i = 0; i < successList.length; i++)
            {
                successList[i].sobjectType = 'Coverage_Temp__c';
            }
            var action = component.get("c.submitCoverageData");
            action.setParams({
                "successList" : successList,
                "rgDeleteList" : rgDeleteList,
                "rmDeleteList" : rmDeleteList,
                "totalCount" : totalCount,
                "guid" : guid
            });
            action.setCallback(this, function(actionResult) {
                var state = actionResult.getState();
                if (state === "SUCCESS") {
                    var resultString = actionResult.getReturnValue();
                    console.log(resultString);
                    if(resultString.search("submitted")!=-1)
                    {
                        component.showToast('','success',resultString);
                        component.switchWizardStep("Select");
                        var prevButton = component.find("prevButton");
                        var nextButton = component.find("nextButton");
                        component.set("v.setWizardStep","Select");
                        prevButton.set("v.label",component.get("v.cancelButton_label"));
                        prevButton.set("v.iconName","utility:close");
                        component.set('v.showRemoveButton',true);
                        nextButton.set("v.label",component.get("v.validateButton_label"));
                        nextButton.set("v.iconName","utility:task");
                        $A.util.removeClass(nextButton,'slds-hide');
                        component.set('v.showRemoveButton',false);
                        //component.hideSpinner();
                    }
                    else
                    {
                        component.showToast('','error',resultString);
                        //component.hideSpinner();
                    }
                    /*var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef : "c:MyCoverageTool"
                    });
                    evt.fire(); */
                    window.history.back();
                    
                }
                else if (state === "ERROR") {
                    var errors = actionResult.getError();
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
        
        viewExistingCoverage : function(component,product, productRegion,
                                        productGroup,salesCodeId, 
                                        clientId,isRM ,isRG,salesteam,coverageType,subType)
        {
            try{
            component.showSpinner();
            console.log('Product: '+product);
            console.log('productRegion: '+productRegion);
            console.log('productGroup: '+productGroup);
            console.log('salesCodeId: '+salesCodeId);
            console.log('clientId: '+clientId);
            console.log('isRM: '+isRM);
            console.log('isRG: '+isRG);
            console.log('salesteam: '+salesteam);
            console.log('coverageType: '+coverageType);    
            
            var wparams = {
                'product': product,
                'productRegion': productRegion,
                'productGroup': productGroup,
                'salesCodeId': salesCodeId,
                'clientId': clientId,
                'isRM': isRM,
                'isRG':isRG,
                'salesteam':salesteam,
                'coverageType':coverageType,
                'subType':subType
            };
            
            var action = component.get("c.getExistingCoveragesExcludingSalesCode");
            action.setParams(wparams);
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    //store the return response from server (map<string,List<string>>)  
                    var resultdata = response.getReturnValue();
                    if(!$A.util.isUndefinedOrNull(resultdata))
                    {
                        var userRegion = '';
                        if(!$A.util.isUndefinedOrNull(resultdata.userRegion))
                            userRegion = resultdata.userRegion;
                        console.log('userRegion');
                        console.log(userRegion);
                        if(userRegion == 'Japan')
                        {
                            if(resultdata.doNotShowRevenueColumns)
                            {
                                component.set("v.teamCoverageColumns", [            		
                                    {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:250, sortable:true},
                                    {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:200, sortable:true}
                                ]);    
                            }
                            else
                            {
                                component.set("v.teamCoverageColumns", [            		
                                    {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:250, sortable:true},
                                    {label: component.get("v.ytd_label"), fieldName:"ytdRevenue", type:"currency",typeAttributes: { currencyCode: 'YEN',currencyDisplayAs : 'symbol',maximumFractionDigits : 0,minimumFractionDigits : 0  }, initialWidth:100, sortable:true},
                                    {label: component.get("v.budget_label"), fieldName:"ytdBudget", type:"currency",typeAttributes: { currencyCode: 'YEN',currencyDisplayAs : 'symbol',maximumFractionDigits : 0,minimumFractionDigits : 0  }, initialWidth:140, sortable:true},
                                    {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:200, sortable:true}
                                ]);
                            }
                            
                        }
                        else
                        {
                            if(resultdata.doNotShowRevenueColumns)
                            {
                                component.set("v.teamCoverageColumns", [            		
                                    {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:250, sortable:true},
                                    {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:200, sortable:true}
                                ]); 
                            }
                            else
                            {
                                component.set("v.teamCoverageColumns", [            		
                                    {label: component.get("v.salesperson_label"), fieldName:"salesPerson", type:"text", initialWidth:250, sortable:true},
                                    {label: component.get("v.ytd_label"), fieldName:"ytdRevenue", type:"currency",typeAttributes: { currencyCode: 'USD',currencyDisplayAs : 'symbol',maximumFractionDigits : 0,minimumFractionDigits : 0  }, initialWidth:100, sortable:true},
                                    {label: component.get("v.budget_label"), fieldName:"ytdBudget", type:"currency",typeAttributes: { currencyCode: 'USD',currencyDisplayAs : 'symbol',maximumFractionDigits : 0,minimumFractionDigits : 0  }, initialWidth:140, sortable:true},
                                    {label: component.get("v.productrole_label"), fieldName:"role", type:"text", initialWidth:200, sortable:true}
                                ]); 
                            }
                        }
                        var dataBody = resultdata.dataBody;
                        console.log('TEAM COVERAGE');
                        console.log(dataBody);
                        if(dataBody.length > 0)
                        {
                            component.set('v.teamCoverageData',dataBody);
                            component.showViewModal('viewCoverageModal','viewCoverageModalBackdrop'); 
                        }                       
                    }
                    else
                    {
                        component.showToast('','info','No Team Coverage found.');
                    }                    
                }
                else if (response.getState() === "INCOMPLETE") {
                    console.log('In incomplete');
                    component.showToast('error','error','No response from server or client is offline.');
                }
                    else if (response.getState() === "ERROR") {
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
                    }
                component.hideSpinner();
                
            });
            $A.enqueueAction(action);
            }
            catch(error)
            {
                console.log(error);
            }
        },
            setLoggedUserDetails : function(component)
			{
                var region = ["EMEA"];
                var division = ["Fixed Income"];
                var userRegion =  component.get("v.currentUser.Role_Based_Region__c");
                var userDivision = component.get("v.currentUser.Division_Role_Based__c");
                console.log(userRegion+'#'+userDivision);
             	 if(region.indexOf(userRegion)>-1 && division.indexOf(userDivision)>-1) {
                   var a = $('#' + component.find('proroleAdd').get("v.parentID") + '_' + component.find('proroleAdd').get("v.IDT"));
                   a.val('Primary + Secondary Team').trigger('change');
                   component.set("v.role", "Primary + Secondary Team");
                }
                else {
                    var b = $('#'+component.find('proroleAdd').get("v.parentID")+'_'+component.find('proroleAdd').get("v.IDT")); // Select the option with a value of '1'
                    b.val('Primary').trigger('change');
                } 
               $('#'+component.find('proroleAdd').get("v.parentID")+'_'+component.find('proroleAdd').get("v.IDT")+' option[value="None"]').remove(); 
                component.set("v.needToRenderHelperLogic",false); // this will not fire rerender again 
            } 

    };
    
}());