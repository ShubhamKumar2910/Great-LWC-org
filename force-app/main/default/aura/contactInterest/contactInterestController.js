({
       scriptsLoaded : function(component, event, helper) {
		console.log('scripts load successfully');
          
       // active/call select2 plugin function after load jQuery and select2 plugin successfully    
		/*$("#flagsMultiSelect").select2({
            multiple : true,
            width : "100%",
            placeholder: "Please select",
            data : [
                    {
                      id: 'wont participate in deals with mkt cap < US$2bn',
                      text: 'won\'t participate in deals with mkt cap < US$2bn'
                    },
				   {
                      id: 'wont participate in deals with mkt cap < US$10bn',
                      text: 'won\'t participate in deals with mkt cap < US$10bn'
                    },
					  {
                      id: 'wont participate in deals with mkt cap < US$20bn',
                      text: 'won\'t participate in deals with mkt cap < US$20bn'
                    },
            ]
          }); */
        component.set("v.isHelperScriptLoaded",true);
        component.set("v.needToRenderHelperLogic",true);    
    }     ,
    
	doValidations : function(component, event, helper) {
		console.log('validate button clicked');
        helper.validate(component);        
	},
                
	doCreateCI : function(component, event, helper) {
		console.log('create button clicked');
        helper.createCI(component, event);        
	},                
    
    doInit : function(component, event, helper) {
            
        },
                
     defaultCloseAction : function(component, event, helper) { 
		//component.destroy(); 
		var dismissActionPanel = $A.get("e.force:closeQuickAction");
		dismissActionPanel.fire();
		$A.get('e.force:refreshView').fire();
	  },
                
     handleTreeListValueChanged : function(component, event, helper) {
            var compName = event.getParam("compName");   
	        console.log("treeListValueChangedEvent handler for " + event.getName() + " and comp name = " + compName);
            helper.enableDisableCreateButton(component, "true");
     }                
})