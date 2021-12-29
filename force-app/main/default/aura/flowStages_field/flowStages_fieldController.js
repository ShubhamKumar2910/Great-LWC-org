({
    init : function(component, event, helper) {
        console.log('---in flow stage init');
        console.log(component.get("v.CurrentStage"));
        
       var progressIndicator = component.find('progressIndicator');
       for (let step of component.get('v.ActiveStages')) {
          $A.createComponent(
             "lightning:progressStep",
             {
                "aura:id": "step_" + step,
                "label": step,
                "value": step
              },
              function(newProgressStep, status, errorMessage){
                 // Add the new step to the progress array
                 if (status === "SUCCESS") {
                    var body = progressIndicator.get("v.body");
                    body.push(newProgressStep);
                    progressIndicator.set("v.body", body);
                  }
                  else if (status === "INCOMPLETE") {
                     // Show offline error
                     console.log("No response from server, or client is offline.")
                   }
                   else if (status === "ERROR") {
                      // Show error message
                      console.log("Error: " + errorMessage);
                   }
               }
            );
        }
    }
 })