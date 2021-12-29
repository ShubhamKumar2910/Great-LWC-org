({
    getContactInfo : function(component) {
        var recordId  = component.get('v.recordId');
        console.log('Record Id: '+recordId);
        var action = component.get("c.getContactInfo");
        
        
        action.setParams({ rec : recordId }); 
        
        action.setCallback(this,function(a){  
            var state = a.getState(); 
            if (state === "SUCCESS") { 
                console.log("SearchResult returned from server.")
                component.set("v.contactInfo", a.getReturnValue());
                var contactObj = component.get("v.contactInfo");
                var grpFlag = contactObj.GRP_Access__c;
                if(grpFlag){
                    component.set("v.isGRPAccess", true);
                    //console.log("Preselected Id to be set :: "+ component.get("v.contactInfo").Id);
                    
                    //console.log("Set Id in lookup component :: "+ component.find("lookup-sponsor").get("v.preSelectedIds"));
                    console.log( "flag value set as :: "+component.get("v.isGRPAccess"));
                }
                else
                {
                    component.set("v.isGRPAccess", false);
                }
            }
            
            else if (state === "INCOMPLETE") { 
                console.log("Response is not complete");
            } 
                else if (state === "ERROR") { 
                    var errors = a.getError(); 
                    if (errors) { 
                        if (errors[0] && errors[0].message) { 
                            console.log("Error message: " +  
                                        errors[0].message);   
                        } 
                        
                    } else { 
                        console.log("Unknown error"); 
                    } 
                } 
        }); 
        $A.enqueueAction(action);
    },

    getSponsorId : function(component){
        
		var contObj = Component.get('v.contactInfo');        
        var action = Component.get("c.setSponsorId");
        action.setParams({ "contact" : Component.get('v.contactInfo') }); 
        console.log("get sponsor Id");
        	action.setCallback(this,function(a){ 
                console.log("fetching sponsor Id");
                console.log("getSponsorId Status:: "+a.getState())
            var state = a.getState(); 
            if (state === "SUCCESS") { 
                console.log("Sponsor Id fetchedk")
                component.set("v.existingSponsorId", a.getReturnValue());
                //component.find("lookup-sponsor").set("v.preSelectedIds" , a.getReturnValue()/*component.get("v.contactInfo").Id till here);
                console.log( "getSponsorId --> Sponsor Id is :: "+Component.get("v.existingSponsorId"));
            }
            
            else if (state === "INCOMPLETE") { 
                console.log("Response is not complete");
            } 
                else if (state === "ERROR") { 
                    var errors = a.getError(); 
                    if (errors) { 
                        if (errors[0] && errors[0].message) { 
                            console.log("Error message: " +  
                                        errors[0].message);   
                        } 
                        
                    } else { 
                        console.log("Unknown error"); 
                    } 
                } 
        }); 
        $A.enqueueAction(action);
    },
    
    doApplySponsor: function(component){
        var chosenId = component.get('v.selectedLookupId');
        var recId = component.get('v.recordId');
        console.log('Helper :: chosenId : '+chosenId);
        console.log('Helper :: RecId  : '+recId);

        var action = component.get("c.applySponsor");
        action.setParams({ "chosenId" : chosenId , "recId" : recId }); 
        //action.setParams({ recId : recId }); 
 
        	action.setCallback(this,function(a){ 
                console.log("applySponsor method is called.");
                console.log("applySponsor Status:: "+a.getState())
            var state = a.getState(); 
            if (state === "SUCCESS") { 
                console.log("applySponsor performed on server.")
                component.set("v.contactInfo", a.getReturnValue());
                console.log( component.get("v.contactInfo"));
            }
            
            else if (state === "INCOMPLETE") { 
                console.log("Response is not complete");
            } 
                else if (state === "ERROR") { 
                    var errors = a.getError(); 
                    if (errors) { 
                        if (errors[0] && errors[0].message) { 
                            console.log("Error message: " +  
                                        errors[0].message);   
                        } 
                        
                    } else { 
                        console.log("Unknown error"); 
                    } 
                } 
        }); 
        $A.enqueueAction(action);
    },
    
    doSaveContact : function(Component){
      
        var contObj = Component.get('v.contactInfo');
        console.log('Helper :: contact Object : '+contObj);
        
        var action = Component.get("c.saveContact");
        action.setParams({ "contact" : Component.get('v.contactInfo') }); 
        
            action.setCallback(this,function(a){ 
                console.log("Saved Contact details");
                console.log("doSaveContact Status:: "+a.getState())
            var state = a.getState(); 
            if (state === "SUCCESS") { 
                console.log("Contact is saved");
                this.navigateToRecord(Component, Component.get("v.recordId"));
            }
            
            else if (state === "INCOMPLETE") { 
                console.log("Response is not complete");
            } 
            else if (state === "ERROR") { 
                var errors = a.getError(); 
                if (errors) { 
                    if (errors[0] && errors[0].message) { 
                        console.log("Error message: " +  
                                    errors[0].message);   
                    } 
                    
                } else { 
                    console.log("Unknown error"); 
                } 
            } 
                $A.get('e.force:refreshView').fire();    
        }); 
        $A.enqueueAction(action);
        
    },

    dismissComponent : function(){
        var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
        dismissActionPanel.fire(); 
    },

    navigateToRecord : function(component, recordId){
        var navEvt = $A.get("e.force:navigateToSObject");
                
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "related"
        });
        navEvt.fire();
    },

    
})