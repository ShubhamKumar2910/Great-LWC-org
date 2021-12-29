({
    getCampaignMemCount : function(component){       
        var action = component.get("c.fetchCampaignMemberCount");
        var recordId = component.get("v.recordId");
        var res = recordId.substring(0, 3);
       	console.log('res **' +res);
        console.log('recordId **' +recordId);
        var isAccount;
        
        if(res == "001")
             isAccount = true;
        else
            isAccount = false;
        component.set("v.isAccount",isAccount);
        console.log('isAccount **'+ isAccount);
        action.setParams({
            "recordId" : recordId,
            "isAccount" : isAccount            
        });
        action.setCallback(this, function(response){
           var state = response.getState();
            if(state === "SUCCESS"){
                var icount = response.getReturnValue(); 
                console.log('icount ***'+ icount);
                //component.set("v.totalNumberOfRows",icount);
                component.set("v.totalRecordCount",icount);
            }
            else{
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message)
                        console.log("Error occured-"+ errors[0].message);
                }
                else
                    console.log("Unknown Error");
            }
        });
        $A.enqueueAction(action);
    },
    getCampaignMemData : function(component){       
        var action = component.get("c.getCampaignMemberData");
        var recordId = component.get("v.recordId");
        var res = recordId.substring(0, 3);
        console.log('res **' +res);
        console.log('recordId **' +recordId);
        var isAccount = component.get("v.isAccount");
             
        console.log('isAccount **'+ isAccount);
        console.log('inital rows **'+ component.get("v.initialRows"));
        action.setParams({
            "recordId" : recordId,
            "isAccount" : isAccount,
            "initialRows" : component.get("v.initialRows"),
            "rowsToLoad" : 0 
        });
        
        action.setCallback(this, function(response){
           var state = response.getState();
            if(state === "SUCCESS"){
                var jsonString = response.getReturnValue();                
                if(jsonString.length > 0){
                    this.showDatatable(component, jsonString);
                    //SALES-3695
                    this.loadEmailAddrAndShowSendEmailBtn(component,jsonString);
                }
                else
                    this.hideDatatable(component); 
            }
            else{
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message)
                        console.log("Error occured-"+ errors[0].message);
                }
                else
                    console.log("Unknown Error");
            }
        });
        $A.enqueueAction(action);
    },
    
    showDatatable : function(component, jsonString){  
        var tableDiv = component.find("dataTableDiv");
        $A.util.removeClass(tableDiv, "slds-hide"); 
        var isAccount = component.get("v.isAccount",isAccount);
        if(isAccount == true){
            component.set("v.datatableColumn",[
                {label: component.get("v.contactNameField"), fieldName: "contactLink", type: "url", sortable:false, 
            typeAttributes: {label: { fieldName: "contactNameField" }, target: "_blank"}},
                {label: component.get("v.ownerName"), fieldName: "ownerName", type:"text", sortable:true},
                //SALES-3701
                {label: component.get("v.ownerDivision"), fieldName: "ownerDivision", type:"text", sortable:true},
                {label: component.get("v.ownerRegion"), fieldName: "ownerRegion", type:"text", sortable:true},
                
                {label: component.get("v.team"), fieldName: "team", type:"text", sortable:true},
                {label: component.get("v.ownerActive"), fieldName: "ownerActive", type:"text", sortable:false}
                ]);
        }
        else{
           component.set("v.datatableColumn",[
                {label: component.get("v.ownerName"), fieldName: "ownerName", type:"text", sortable:true},
                //SALES-3701
                {label: component.get("v.ownerDivision"), fieldName: "ownerDivision", type:"text", sortable:true},
                {label: component.get("v.ownerRegion"), fieldName: "ownerRegion", type:"text", sortable:true},

                {label: component.get("v.team"), fieldName: "team", type:"text", sortable:true},
                {label: component.get("v.ownerActive"), fieldName: "ownerActive", type:"text",  sortable:false}
                ]); 
        }
		component.set("v.contactCoverageData", jsonString);
        //component.set("v.totalRecordCount", jsonString.length);
        component.set("v.totalNumberOfRows", jsonString.length);
        component.set("v.currentCount", component.get("v.initialRows"));       
    },
    
    hideDatatable : function(component){
        var tableDiv = component.find("dataTableDiv");
        $A.util.addClass(tableDiv, "slds-hide");
        component.set("v.datatableColumn", "");
        component.set("v.contactCoverageData", "");
        component.set("v.totalRecordCount", "0");
    },
    
    sortData : function(component, fieldName, sortDirection){       
        var data = component.get("v.contactCoverageData");        
        var reverse = sortDirection !== 'asc';         
        data.sort(this.sortBy(fieldName, reverse));
        component.set("v.contactCoverageData", data);
    },
    
    sortBy : function(field, reverse, primer){
       	var key = primer ? function(x){return primer(x[field])} : function(x){return x[field]};
        reverse = !reverse ? 1 : -1;         
            return function(a, b){
                return a =key(a), b = key(b), reverse * ((a > b) - (b > a));
            }
        },
    fetchData : function(component, rows){    	
    	return new Promise(function (resolve, reject){
    		var action = component.get("c.getCampaignMemberData");          
            var recordOffset = component.get("v.currentCount");
            action.setParams({
                "recordId" :  component.get("v.recordId"),
                "isAccount" : component.get("v.isAccount"),
                "initialRows" : component.get("v.initialRows"),
                "rowsToLoad" : recordOffset 
            });
            
        	action.setCallback(this, function(response){
                var state = response.getState();
                console.log('state ***'+ state);
                if(response.getState() === 'SUCCESS'){                    
                    resolve(response.getReturnValue());
                    var countstemps = component.get("v.rowsToLoad");
                    countstemps = countstemps+component.get("v.initialRows");
                    console.log('countstemps **'+ countstemps);
                    component.set("v.currentCount",countstemps);
                    //var totalrecords = component.get("v.totalRecordCount");
                    //var totalrows = component.get("v.totalNumberOfRows");
                    //if(totalrows < totalrecords)
                       // component.set('v.totalNumberOfRows', newData.length); 
                    
                }
                else if(response.getState() === 'ERROR') {
                    console.log("in error");
                    reject(response.getError());
            	}            
			});
            $A.enqueueAction(action);
            
        });//promise end
            
    },
    
    //SALES-3695
    loadEmailAddrAndShowSendEmailBtn: function(component,jsonString){
        var emailSet = new Set();
        var emailList='';
        var record;
        
        for(var i = 0; i< jsonString.length; i++){
            record = jsonString[i];
            if(record["ownerActive"] == "Yes"){
                emailSet.add(record["ownerEmail"]);
            }            
        }

        emailSet.forEach((email) => {
            emailList = emailList + email + ";"
        });

        emailList = emailList.substring(0, emailList.lastIndexOf(';'));
        component.set("v.sendContactCoverageEmail",emailList);
        
        var sendEmailBtn = component.find('sendEmailBtn');
        $A.util.removeClass(sendEmailBtn, "slds-hide");
    }
})