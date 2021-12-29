({
	initialiseFields : function(component) {
		var fieldNames = component.get("v.apiFieldNames");
		var numberOfFields = component.get("v.numberOfFieldsPerColumn");
		var fields = parseInt(numberOfFields);
		
		var numberOfColumns = component.get("v.numberOfColumns");
		var columns = parseInt(numberOfColumns);
		
		var columnList = [];

		for(var i = 0; i < columns; i++){
			columnList.push(String(i));
		}

		var res = fieldNames.split(",");
		var result = [];

		res.forEach(function(current_value) {
            
            current_value = current_value.trim();
            
            result.push(current_value);
        });
		
		component.set("v.listOfFields", result);

		var chunk_size = fields;
		var arr = result;
		var objects = [];
		var groups = arr.map( function(e,i){ 
				
		    return i%chunk_size===0 ? arr.slice(i,i+chunk_size) : null; 
		})
		.filter(function(e){ return e; });

		for (var key in groups) {
		    if (groups.hasOwnProperty(key)) {
		       // console.log(key + " -> " + groups[key]);
		        var strings = groups[key];
		        var ReadOnlyWrapper = new Object();
				ReadOnlyWrapper.columnNumber = String.valueOf(key);
				var f = [];

				for(var field in strings){
						f.push(strings[field]);
				}
        		ReadOnlyWrapper.fields = f;

        		objects.push(ReadOnlyWrapper);


		    }
		}
		component.set("v.results", objects);
		component.set("v.columns", columnList);

	}
 
})