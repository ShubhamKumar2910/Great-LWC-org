({
    initialiseAVRLabels : function(component){        
    	var action = component.get("c.initialiseLabels");    
        action.setCallback(this, function(response){
            var state = response.getState();
        	if(state === "SUCCESS"){
            	var responseMap = response.getReturnValue();
                for(var key in responseMap){
                    var innerMap = responseMap[key];                   
                    for(var f in innerMap){
                        if(key == 'Account_Vote_Ranks__c' && f == 'Account__c')
                            component.set("v.accountLabel", innerMap[f]);
                        if(key == 'Account_Vote_Ranks__c' && f == 'Account_Note__c')
                            component.set("v.accountNoteLabel", innerMap[f]);
                        if(key == 'Account_Vote_Ranks__c' && f == 'Period__c')
                            component.set("v.periodLabel", innerMap[f]);
                        if(key == 'Account_Vote_Ranks__c' && f == 'Year__c')
                            component.set("v.yearLabel", innerMap[f]);
                        if(key == 'Account_Vote_Ranks__c' && f == 'Received__c')
                            component.set("v.receivedLabel", innerMap[f]);
                        if(key == 'Account_Vote_Ranks__c' && f == 'Product__c')
                            component.set("v.productLabel", innerMap[f]);
                        if(key == 'Account_Vote_Ranks__c' && f == 'Country__c')
                            component.set("v.countryLabel", innerMap[f]);
                        if(key == 'Account_Vote_Ranks__c' && f == 'Service__c')
                            component.set("v.serviceLabel", innerMap[f]);
                        if(key == 'Account_Vote_Ranks__c' && f == 'Rank__c')
                            component.set("v.rankLabel", innerMap[f]);
                        if(key == 'Account_Vote_Ranks__c' && f == 'Score__c')
                            component.set("v.scoreLabel", innerMap[f]);
                        if(key == 'Account_Vote_Ranks__c' && f == 'Regions__c')
                            component.set("v.regionsLabel", innerMap[f]);
                        if(key == 'Account_Vote_Ranks__c' && f == 'Latest_Vote__c')
                            component.set("v.latestVoteLabel", innerMap[f]);
                        if(key == 'Account_Vote_Ranks__c' && f == 'Vote_Note__c')
                            component.set("v.voteNoteLabel", innerMap[f]);                         
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
            this.getData(component);
        });
        $A.enqueueAction(action);               
	},            
    
    getData : function(component){
        //Chaining of actions sequence as inner function gets value from other functions
        var action = component.get("c.getAccountVoteRankOptions");        
        action.setCallback(this, function(response){
           var state =  response.getState();           
           if(state == "SUCCESS"){
                var avrOptions = response.getReturnValue();                
                component.set("v.accountVoteRankOptions", avrOptions); 
                
               var action = component.get("c.getProductDependencyList");
               action.setCallback(this, function(response){
                    var state = response.getState();                    
                    if(state == "SUCCESS"){                       
                        var dependentValues = response.getReturnValue();               			
                        var productArray = [];
                        productArray.push({"value" : dependentValues});                       
                       	component.set("v.productDependentValues", productArray);
                        
                        var action = component.get("c.getAccountVoteRankData");
                        action.setParams({
                            "avrId": component.get("v.recordId")
                        });
                        action.setCallback(this, function(response){
                        	var state = response.getState();                            
                            if(state == "SUCCESS"){                                                              
                                var avrValues = response.getReturnValue();                               
                                component.set("v.newAVR", avrValues);                              
                                if((avrValues.Country__c == null || avrValues.Country__c == undefined) ){
                                    component.set("v.disableCountry", true);
                                }
                                else{
                                    component.set("v.disableCountry", false);                    
                                }                                
                            }                           
                        });
                        $A.enqueueAction(action);                       
                    }                    
                });            
                $A.enqueueAction(action);
            }           
        });      
        $A.enqueueAction(action);        
    },
    
    saveData : function(component){
       
        var newAccountVoteRank = component.get("v.newAVR");                                
        newAccountVoteRank.sObjectType = 'Account_Vote_Ranks__c';
        if(newAccountVoteRank.Country__c == '--None--')
            newAccountVoteRank.Country__c = '';
        
        var action = component.get("c.saveAccountVoteRank");
        action.setParams({
            "newAVRRecord" : newAccountVoteRank 
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var recordId = response.getReturnValue();
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId" : recordId
                });
                navEvt.fire();                   
            } else if (state === "ERROR") {
                var errors = response.getError();                  
                component.set("v.hasErrors", "true");              
                if(errors[0] && errors[0].message){// To show other type of exceptions
                    console.log(errors[0].message);
                    component.set("v.errorMessages", errors[0]);
                }                
                if(errors[0] && errors[0].pageErrors){ // To show DML exceptions                   
                    if(errors[0].pageErrors[0] )
                    	component.set("v.errorMessages", errors[0].pageErrors[0].message);                   
                }
                
            }
        });
        $A.enqueueAction(action);       
    },
    
   
})