({
    query: function(component, callback, searchString) { 
        var action = component.get("c.searchSalesTeam");
        action.setStorable();
        
        console.log('SEARCH TEXT: '+component.get("v.searchText"));         
        action.setParams({
            "searchStringForTree": component.get("v.searchText")
        });
        action.setCallback(this, function(response) {
            var data = {}
            var results = [];
            if (response.getState() == "SUCCESS") {
                var json_string = response.getReturnValue();
                console.log(json_string);
                var results = JSON.parse( json_string );
                if (results == null)
                    results = {};
                callback(results);
            }        
        });
        $A.enqueueAction(action);
    }  
    
})