({
    setInfoText: function(component, values) {
        
        if (values.length == 0) {
            component.set("v.infoText", "-- None --");
        }
        if (values.length == 1) {
            component.set("v.infoText", values[0]);
        }
        else if (values.length > 1) {
            component.set("v.infoText", values.length + " options selected");
        }
    },
    
    getSelectedValues: function(component){
        var options = component.get("v.options_");
         var values = [];
        options.forEach(function(element) {
            if (element.selected && element.value!='All') {
                values.push(element.value);
            }
        });
        return values;
    },
    
    getSelectedLabels: function(component){
        var options = component.get("v.options_");
        var labels = [];
        options.forEach(function(element) {
            if (element.selected  && element.label!='All') {
                labels.push(element.label);
            }
        });
        return labels;
    },
    
    despatchSelectChangeEvent: function(component,values){
        var compEvent = component.getEvent("selectChange");
        console.log('values: ' + values);
        compEvent.setParams({ "values": values });
        compEvent.fire();
    }
})