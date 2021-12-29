({
    loadData : function(component, objName, picklistfieldName, customMethod) {
        var minimumlength = component.get("v.minimumLength");
        if(!component.get("v.isCustom")) 
        {
            var action = component.get("c.getSourceOptionsJSON");
            action.setStorable();
            
            action.setParams({
                'objApiName': objName,
                'picklistfieldName': picklistfieldName
            });
            //set callback   
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    //store the return response from server (map<string,List<string>>)  
                    var StoreResponse = response.getReturnValue();
                    var jsondata = JSON.parse(StoreResponse);
                     
                    $("#"+component.get("v.parentID")+"_"+component.get("v.IDT")).select2({
                        minimumInputLength: minimumlength,
                        multiple : component.get("v.multiselect"),
                        width : "100%",
                        placeholder: "Please select",
                        data : jsondata
                    }).on("change", 
                          function(e) {
                              component.set('v.values',e.val);
                              var compEvent = component.getEvent("picklistValueChanged");
                              compEvent.fire();
                          });
                    
                }
            });
            $A.enqueueAction(action);
        }
        else
        {
            var action = component.get("c."+customMethod);
            action.setStorable();
            
            //set callback   
            action.setCallback(this, function(response) {
                console.log(response.getState());
                if (response.getState() == "SUCCESS") {
                    //store the return response from server (map<string,List<string>>)  
                    var StoreResponse = response.getReturnValue();
                    var jsondata = JSON.parse(StoreResponse);
                    component.set("v.JSONData",jsondata);
                    console.log(jsondata);
                    try
                    {
                        console.log('Parent Id: (helper) ' +component.get("v.parentID"));
                        console.log('IDT Id: (helper)' +component.get("v.IDT"));
                        
                        $("#"+component.get("v.parentID")+"_"+component.get("v.IDT")).select2({
                            minimumInputLength: minimumlength,
                            multiple : component.get("v.multiselect"),
                            width : "100%",
                            placeholder: "Please select",
                            data : jsondata
                        }).on("change", 
                              function(e) {
                                  component.set('v.values',e.val);
                                  var compEvent = component.getEvent("picklistValueChanged");
                                  compEvent.fire();
                              });
                    }
                    catch(err)
                    {
                        console.log('Piclist Rendering Error');
                        console.log(err);
                    }
                    
                    
                    // component.set("v.needToRenderHelperLogic",false); // this will not fire rerender again
                }
                else if (response.getState() === "INCOMPLETE") {
                    component.showToast('error','error','No response from server or client is offline.');
                   }
                    else if (response.getState() === "ERROR") {
                        var errors = response.getError();
                        console.log('ERRORS');
                        console.log(errors);
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
                
            });
            $A.enqueueAction(action);
        }
    }
})