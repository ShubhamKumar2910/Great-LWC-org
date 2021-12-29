{
fetchPickListVal: function(component, fieldName) {
      /* call the apex getselectOptions method which is returns picklist values
         set the picklist values on "picklistOptsList" attribute [String list].
         which attribute used for iterate the select options in component.
       */ 
        var action = component.get("c.getselectOptions");
        action.setParams({
             "sourceEntity": "market"
        });
        var opts = [];
        action.setCallback(this, function(response) {
            console.log('(response.getState(): '+response.getState());
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                for (var i = 0; i < allValues.length; i++) {
                    opts.push(allValues[i]);
                }
                //component.set("v.picklistOptsList" , opts);
            }
        });
        //$A.enqueueAction(action);
    },
    
query: function(component, callback, searchString) {
        var action = component.get("c.query");
        action.setParams({
             "searchStringForTree": searchString,
            "sourceEntity" : component.get("v.sourceEntity"),
            "idField" : component.get("v.idField"),
            "textField" : component.get("v.textField"),
            "parentIdsField" : component.get("v.parentIdsField")
        });
        action.setCallback(this, function(response) {
            var data = {}
            var results = [];
            if (response.getState() == "SUCCESS") {
                var json_string = response.getReturnValue();
                var results = JSON.parse( json_string );
                if (results == null)
                    results = {};
                callback(results);
            }        
        });
        $A.enqueueAction(action);
    }  

      
})