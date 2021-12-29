({
    fetchCurrentUserSalesCodeId: function(component){
        if(!$A.util.isUndefinedOrNull(coverage_helper_util))
            coverage_helper_util.fetchCurrentUserSalesCodeId(component);
    }, 
    convertArrayOfObjectsToCSV: function(component,objectRecords){
        // declare variables
        var csvStringResult, counter, columnDivider, lineDivider;
        
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';
        
        // in the keys valirable store fields API Names as a key 
        // this labels use in CSV file header 
        // 
        //keys = ['Name','Division','SalesTeam','SalesDeskRegion','CoverageStartDate','Comment','Role','Region','Product','Type' ];
        var keys = component.get('v.keys');
        var csvMap = component.get('v.csvMap');
        csvMap[component.get("v.RGID_label")] = "rgOrgID";
        csvMap[component.get("v.account_label")]= "clientRG"; 
        //changes for JIRA SALES-3698
        //////////////csvMap[component.get("v.type_label")]= "Type";
        csvMap[component.get("v.team_label")]= "team";
        csvMap[component.get("v.salesperson_label")]= "salesPerson";
        csvMap[component.get("v.SalesCode_label")]= "coverageID";
        csvMap[component.get("v.ytd_usd_label")]= "ytdRevenue";
        csvMap[component.get("v.budget_usd_label")]= "ytdBudget";
        csvMap[component.get("v.mtd_usd_label")]= "mtdRevenue";
        csvMap[component.get("v.wtd_usd_label")]= "wtdRevenue";
        csvMap[component.get("v.ytd_yen_label")]= "ytdRevenue";
        csvMap[component.get("v.budget_yen_label")]= "ytdBudget";
        csvMap[component.get("v.mtd_yen_label")]= "mtdRevenue";
        csvMap[component.get("v.wtd_yen_label")]= "wtdRevenue";
        csvMap[component.get("v.productrole_label")]= "role";
        csvMap[component.get("v.startdate_label")]= "startDate";
        csvMap[component.get("v.status_label")]= "status";
        csvMap[component.get("v.product_label")]= "product";
        csvMap[component.get("v.productRegion_label")]= "productRegion";
        csvMap[component.get("v.region_label")]= "region";
        csvMap[component.get("v.desk_label")]= "desk";
        csvMap[component.get("v.enddate_label")]= "endDate";
        csvMap[component.get("v.comment_label")]= "userComments";
        
        
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
        
        
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
            
            for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
                console.log(skey);
                
                if(csvMap!=null && csvMap[skey]!=undefined && skey!=undefined && skey!=null){
                    
                    var apiName = csvMap[skey];
                    if(apiName!=undefined && apiName!=null && apiName!=''){
                        // add , [comma] after every String value,. [except first]
                        if(counter > 0){ 
                            csvStringResult += columnDivider; 
                        }   
                        
                        if(!$A.util.isUndefinedOrNull(objectRecords[i][apiName])){
                            csvStringResult += '"'+ objectRecords[i][apiName]+'"'; 
                        }
                    }
                }
               
                counter++;
                
            } // inner for loop close 
            csvStringResult += lineDivider;
        }// outer main for loop close 
        
        // return the CSV formate String 
        return csvStringResult;        
    },
    //changes for Sales-3698
    /*fetchNFPEType : function(component)
    {
        if(!$A.util.isUndefinedOrNull(coverage_helper_util))
            coverage_helper_util.fetchNFPEType(component);
    },*/
    isUploadButtonSeen : function(component)
    {
        if(!$A.util.isUndefinedOrNull(coverage_helper_util))
            coverage_helper_util.isUploadButtonSeen(component);
    },
    isUserFISales : function(component)
    {
        if(!$A.util.isUndefinedOrNull(coverage_helper_util))
            coverage_helper_util.isUserFISales(component);
    },
    isCommentAccessible : function(component)
    {
        if(!$A.util.isUndefinedOrNull(coverage_helper_util))
            coverage_helper_util.isCommentAccessible(component);
    },
    fetchResults: function(component,isInit){
        component.set("v.coverageData", [{}]);
        component.set("v.coverageColumns", [{}]);
        if(!$A.util.isUndefinedOrNull(coverage_helper_util))
            coverage_helper_util.fetchSearchResults(component,isInit);
    },
    fetchDepValues: function(component, productRegions, productGrps) {
        if(!$A.util.isUndefinedOrNull(coverage_helper_util))
            coverage_helper_util.fetchDepValues(component, productRegions, productGrps); 
    },
    fetchProductGroupDependantValues: function(component,objName, controllerField, dependentField) {
        if(!$A.util.isUndefinedOrNull(coverage_helper_util))
            coverage_helper_util.fetchProductGroupDependantValues(component,objName, controllerField, dependentField);
    },
    fetchProductRegionSetValues: function(component){
        if(!$A.util.isUndefinedOrNull(coverage_helper_util))
            coverage_helper_util.fetchProductRegionSetValues(component);
    },
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.coverageData");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.coverageData", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    actionChange:function(cmp,row){
        var RGIDList = cmp.get('v.RGIDList');
        RGIDList = new Array();
        var clientId=row.clientRGId;
        if(!$A.util.isUndefinedOrNull(clientId))
        {
            if(clientId!='')
            {
                RGIDList.push(clientId);
                if(RGIDList.length>0){
                    cmp.find("navService").navigate({
                        "type": "standard__component",
                        "attributes": {
                            "componentName": "c__BulkApproval"    
                        },    
                        "state": {
                            "c__RGIDList": clientId,
                            "c__isApproval" : "showRequestStatus",
                            "c__scode": row.coverageID,
                            "c__source" : 'Coverage'
                        }
                    }, false);
                }
                
            }    
        }
    }
        
        
    
})