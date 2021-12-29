({
   scriptsLoaded : function(component, event, helper) {
		console.log('scripts load successfully');
		// Define query callback function
		var queryCallBackFunction = $A.getCallback(function queryDataFromServer(comp, succ, searchString) {
                             console.log('Quering......'); 
            				helper.query(comp, succ, searchString);
                         });    
       
       var placeHolder = component.get("v.placeHolder");
		
       // active/call select2 plugin function after load jQuery and select2 plugin successfully    
       	var treePickListId = '#' + component.get("v.sourceEntity") + '_treePickList';
		$(treePickListId).select2({
            minimumInputLength : 2,
            //quietMillis : 400,
            placeholder: placeHolder,
            multiple : true,
            width : "100%",
           ajax: {
               		url : function(term) {
                          	return term;
                    },
               		transport: function (params) {
                   	queryCallBackFunction(component, params.success, params.url);
	                 },
                    results : function(data, page) {
                        console.log(data);
                        return {
                            results : data
                            
                        };
                    }
   				 }
          }).on("change", 
                function(e) {
                                var selectedValues = e.val;
                    			console.log('Selected values = ' + selectedValues);
                    		    component.set("v.selectedValues" , selectedValues);
                    			var selectedObjects = $(treePickListId).select2("data");
                    			console.log('selectedObjects = ' + selectedObjects);
                    			component.set("v.selectedObjects" , selectedObjects);
                    			// Fire value change event
                    			var compEvent = component.getEvent("treeListValueChanged");
                    			var compName = component.get("v.sourceEntity");
								compEvent.setParams({"compName" : compName });
								compEvent.fire();
                             }
	          );  
   }   
    ,
    
    doInit: function(component, event, helper) {
       /*On the component load call the fetchPickListVal helper method
         pass the Picklist[multi-select] API name in parameter  
       */ 
        console.log('doInit load successfully');
        helper.fetchPickListVal(component, 'skills__c');
    },
    
    highlightErrorMethod: function(cmp, event) {
        var params = event.getParam('arguments');
        var hightLight= params.highlightErrorParam;
        var hightLightMsg= params.highlightErrorMessageParam;
		cmp.set("v.highlightError" , hightLight);  
        cmp.set("v.highlightErrorMessage" , hightLightMsg);
        var treePickListId = cmp.get("v.sourceEntity") + '_treePickList_span';
        //var cmpTarget = cmp.find(treePickListId);
        var cmpTarget = $A.getComponent(treePickListId);
        console.log('cmpTarget = ' + cmpTarget);
        if (hightLight == "true") {
           $A.util.addClass(cmpTarget, 'input-error');
            document.getElementById(treePickListId).style.border = "1px solid rgb(194, 57, 52)"; 
        }
        else {
          $A.util.removeClass(cmpTarget, 'input-error');
          document.getElementById(treePickListId).style.border="0px" ;
        }
    }
})