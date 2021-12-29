({
    initialiseASMLabels : function(component){
    	var action = component.get("c.initialiseLabels");    
        action.setCallback(this, function(response){
            var state = response.getState();
        	if(state === "SUCCESS"){
            	var responseMap = response.getReturnValue();
                for(var key in responseMap){
                    var innerMap = responseMap[key];                   
                    for(var f in innerMap){
                        if(key == 'Account_Service_Model__c' && f == 'Name')
                            component.set("v.modelLabel", innerMap[f]);
                        if(key == 'Account_Service_Model__c' && f == 'Item_Name__c')
                            component.set("v.itemNameLabel", innerMap[f]);
                        if(key == 'Account_Service_Model__c' && f == 'Call_Report_Type__c')
                            component.set("v.callReportTypeLabel", innerMap[f]);
                        if(key == 'Account_Service_Model__c' && f == 'DealAxis_Event_Type__c')
                            component.set("v.dealAxisEventTypeLabel", innerMap[f]);
                        if(key == 'Account_Service_Model__c' && f == 'DealAxis_Event_Meeting_Type__c')
                            component.set("v.dealAxisEventMeetingTypeLabel", innerMap[f]);
                        if(key == 'Account_Service_Model__c' && f == 'Is_Contact_Count__c')
                            component.set("v.contactCountLabel", innerMap[f]);
                        if(key == 'Account_Service_Model__c' && f == 'Weight__c')
                            component.set("v.weightLabel", innerMap[f]);
                        if(key == 'Account_Service_Model__c' && f == 'Order__c')
                            component.set("v.orderLabel", innerMap[f]);
                    }
                }
        	}else if(state === "ERROR"){
                var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
		      }
        });
        $A.enqueueAction(action);
	},
    
    populateModels : function(component, event){           
        var action = component.get("c.getAccountModels");
        var modelOpts = [];
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var allmodelOpts = response.getReturnValue();
                
                for(var i = 0; i < allmodelOpts.length; i++)
                    modelOpts.push(allmodelOpts[i]);
                
                component.set("v.modelOptions", modelOpts);                        
            	}else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
         $A.enqueueAction(action);
	},
    
    populateCallReportType : function(component, event){
        var action = component.get("c.getCallReportType");
        var callReportTypeOpts = [];
        action.setCallback(this, function(response){
           var state = response.getState();
            if(state === "SUCCESS"){
                var allCallReportTypeOpts = response.getReturnValue();
                
                for(var i = 0 ; i < allCallReportTypeOpts.length; i++)
                    callReportTypeOpts.push(allCallReportTypeOpts[i]);
                
                component.set("v.callReportTypeOptions", callReportTypeOpts);
            }else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
        $A.enqueueAction(action);
    },
    
    populateContactCount : function(component, event){
        var action = component.get("c.getContactCount");
        var contactCountOpts = [];
        action.setCallback(this, function(response){
           var state = response.getState();
            if(state === "SUCCESS"){
                var allContactCountOpts = response.getReturnValue();
                
                for(var i = 0; i < allContactCountOpts.length; i++)
                    contactCountOpts.push(allContactCountOpts[i]);
                
                component.set("v.contactCountOptions", contactCountOpts);
            }else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
        $A.enqueueAction(action);
    },
       
    populateDealAxisEventType : function(component, event){
        var action = component.get("c.getDealAxisEventType");
        var dealAxisEventTypeOpts = [];
        action.setCallback(this, function(response){
           var state = response.getState();
            if(state === "SUCCESS"){
                var allDealAxisEventTypeOpts = response.getReturnValue();
                
                for(var i = 0 ; i < allDealAxisEventTypeOpts.length; i++)
                    dealAxisEventTypeOpts.push(allDealAxisEventTypeOpts[i]);
                
                component.set("v.dealAxisEventTypeOptions", dealAxisEventTypeOpts);
            }else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
        $A.enqueueAction(action);
    },
    
    /* populateDealAxisEventMeetingType : function(component, event){
        var action = component.get("c.getDealAxisEventMeetingType");
        var dealAxisEventMeetingTypeOpts = [];
        action.setCallback(this, function(response){
           var state = response.getState();
            if(state === "SUCCESS"){
                var allDealAxisEventMeetingTypeOpts = response.getReturnValue();
                
                for(var i = 0 ; i < allDealAxisEventMeetingTypeOpts.length; i++)
                    dealAxisEventMeetingTypeOpts.push(allDealAxisEventMeetingTypeOpts[i]);
                
                component.set("v.dealAxisEventMeetingTypeOptions", dealAxisEventMeetingTypeOpts);
            }else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
        $A.enqueueAction(action);
    },*/
    
    
   saveRecords : function(component){
       
       var validateData = [];
       var newAccountServiceModel = component.get("v.newASM");
       var recordId = component.get("v.recordId");
       validateData = this.validateCall(newAccountServiceModel);
       if(validateData.length == 0){                  
           newAccountServiceModel.sObjectType = 'Account_Service_Model__c';          
           var action = component.get("c.saveAccountServiceModel");
           action.setParams({
               "newASMRecord" : newAccountServiceModel
           });
           
           action.setCallback(this, function(response){
              var state = response.getState();
              if(state === "SUCCESS"){
                	var recordId =  response.getReturnValue();   
					var navEvt = $A.get("e.force:navigateToSObject");                  
                navEvt.setParams({                    
                    "recordId": recordId  
                });
                navEvt.fire();               
                  
              }else if (state === "ERROR") {
                   var errors = response.getError();                  
                   component.set("v.hasErrors", "true");              
                   if(errors[0] && errors[0].message)// To show other type of exceptions
                        component.set("v.errorMessages", errors[0].message);
                   if(errors[0] && errors[0].pageErrors) // To show DML exceptions
                        component.set("v.errorMessages", errors[0].pageErrors[0].message);
              }
            });
       $A.enqueueAction(action);
       }else{          
           component.set("v.hasErrors", "true");          
           component.set("v.errorMessages", validateData);
       }      
    },
    
    validateCall : function(newRecord){
        var validationResult = [];
        var names = newRecord.Name;
        var itemN = newRecord.Item_Name__c;
        
        if(names == undefined || names == '' || names.length == 0 || names == '--Select--'){
            validationResult.push({
                    message :  ' Please select Model. '
                });
            }
        if(itemN == undefined || itemN == '' || itemN.length == 0){
             validationResult.push({
                    message :  ' Please enter Item Name.'
                });
        }        
        return validationResult;       
	},     
    
    cancelClicked : function(component){
        var action = component.get("c.getListViews");
        action.setCallback(this, function(response){
           var state = response.getState();            
            if(state === "SUCCESS"){                      
                var navEvent = $A.get("e.force:navigateToList");               
                var listViewId = response.getReturnValue();                           
               navEvent.setParams({
                    "listViewId" : listViewId,
                    "listViewName" : null,
                    "scope" : "Account_Service_Model__c"
                });
                navEvent.fire();               
            }
        });
        $A.enqueueAction(action);
    }
    
})