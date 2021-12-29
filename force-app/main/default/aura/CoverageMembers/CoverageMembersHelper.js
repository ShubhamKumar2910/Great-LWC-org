({
    fetchNFPEType: function(component) {
        // call the server side function  
        var action = component.get("c.getNFPEPicklistValues");
        action.setStorable();
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var result = response.getReturnValue();
                var newOptions = [];
                for(var k in result){
                    if(result[k].label!='Standard')
                        newOptions.push(result[k]);
                }
                console.log(result);
                component.find('entity').set("v.options", newOptions);
                component.find('entity').reInit();
            }
        });
        $A.enqueueAction(action);
    },
    fetchProductList: function(component) {
        // call the server side function  
        var action = component.get("c.getSourceOptionsJSON");
        action.setParams({
            'objApiName': 'Coverage_Team_Member__c',
            'picklistfieldName': 'Product2__c'
        });
        action.setStorable();
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var result = response.getReturnValue();
                
                component.find('product').set("v.options", result);
                component.find('product').reInit();
            }
        });
        $A.enqueueAction(action);
    },
	sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.cvgData");
        console.log( cmp.get("v.cvgData"));
        var reverse = sortDirection !== 'asc';
        console.log(' in helper ');
        console.log(fieldName);
        
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.cvgData", data);
    },
    sortBy: function (field, reverse, primer) {
        console.log(' in sortBy ');
        console.log(field);
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
            
     convertArrayOfObjectsToCSV: function(component,objectRecords){
        // declare variables
        console.log('helper');
        var csvStringResult, counter, keys, columnDivider, lineDivider;
         console.log('in helper');
       
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
        // commented type for SALES 3698
         if(component.get('v.visibility') == 'true:rw' || component.get('v.visibility') == 'true'){
        //keys = ['Name','Division','SalesDesk','SalesDeskRegion','CoverageStartDate','Comment','Role','Region','Product','Type' ];
            keys = ['Name','Division','SalesDesk','SalesDeskRegion','Role','CoverageStartDate','Comment','Region','Product'];
         }
         else
         {
            //keys = ['Name','Division','SalesDesk','SalesDeskRegion','CoverageStartDate','Role','Region','Product','Type' ]; 
            keys = ['Name','Division','SalesDesk','SalesDeskRegion','Role','CoverageStartDate','Region','Product']; 
         }
        
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
         console.log('csvStringResult :');
         console.log(csvStringResult);
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
           
             for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
 
              // add , [comma] after every String value,. [except first]
                  if(counter > 0){ 
                      csvStringResult += columnDivider; 
                   }   
               
                 if(!$A.util.isUndefinedOrNull(objectRecords[i][skey])){
               csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                 }
               
               counter++;
 
            } // inner for loop close 
             csvStringResult += lineDivider;
          }// outer main for loop close 
       
       // return the CSV formate String 
        return csvStringResult;        
    }
            
    })