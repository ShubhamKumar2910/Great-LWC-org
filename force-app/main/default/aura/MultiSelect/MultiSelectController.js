({
    init: function(component, event, helper) {
        
        //note, we get options and set options_
        //options_ is the private version and we use this from now on.
        //this is to allow us to sort the options array before rendering
        var options = component.get("v.options");
        console.log(options);
        var extraFieldsFlag = component.get("v.extraFieldsToShow");
        if(!extraFieldsFlag){
            options.sort(function compare(a,b) {
                if (a.value == 'All'){
                    return -1;
                }
                else if (a.value < b.value){
                    return -1;
                }
                if (a.value > b.value){
                    return 1;
                }
                return 0;
            });
        }
        else{
            options.sort(function compare(a,b) {                
                if (a.label < b.label){
                    return -1;
                }
                if (a.label > b.label){
                    return 1;
                }
                return 0;
            });
        }
        component.set("v.options_",options);
        var values = helper.getSelectedValues(component);
        helper.setInfoText(component,values);
    },
    
    handleClick: function(component, event, helper) {
        if(component.get("v.options_").length >=1)
        {
            var mainDiv = component.find('main-div');
            $A.util.addClass(mainDiv, 'slds-is-open');
        }
    },
    
    handleSelection: function(component, event, helper) {
        var item = event.currentTarget;
        if (item && item.dataset) {
            var value = item.dataset.value;
            console.log('Value: '+value);
            
            var selected = item.dataset.selected;
            console.log('selected: '+selected);
            
            var options = component.get("v.options_");
            
            
            if(value == 'All')
            {
                console.log('A');
                var d =false;
                options.forEach(function(element) {
                    if (element.value == 'All' && element) {
                        d = selected == "true" ? false : true;
                        console.log(d);
                        element.selected = selected == "true" ? false : true;
                    }
                    
                    if(d)
                    {
                        element.selected = true;
                    }
                    else
                    {
                        element.selected = false;
                    }
                });
            }
            else
            {
                if (event.shiftKey) {
                    options.forEach(function(element) {
                        if (element.value == value) {
                            element.selected = selected == "true" ? false : true;
                        }
                    });
                } else
                {
                    options.forEach(function(element) {
                        if (element.value != value)
                            element.selected = false;
                        else
                            element.selected = true;
                    });
                    
                    console.log('C');
                    options.forEach(function(element) {
                        if (element.value == value && element) {
                            element.selected = selected == "true" ? false : true;
                        }
                    });
                    
                }
            }
            
            
            component.set("v.options_", options);
            var values = helper.getSelectedValues(component);
            var labels = helper.getSelectedLabels(component);
            console.log('labels:' + labels);
            console.log('values:' + values);
            helper.setInfoText(component,labels);
            helper.despatchSelectChangeEvent(component,values);
            
        }
    },
    
    handleMouseLeave: function(component, event, helper) {
        component.set("v.dropdownOver",false);
        var mainDiv = component.find('main-div');
        $A.util.removeClass(mainDiv, 'slds-is-open');
    },
    
    handleMouseEnter: function(component, event, helper) {
        component.set("v.dropdownOver",true);
    },
    
    handleMouseOutButton: function(component, event, helper) {
        window.setTimeout(
            $A.getCallback(function() {
                if (component.isValid()) {
                    //if dropdown over, user has hovered over the dropdown, so don't close.
                    if (component.get("v.dropdownOver")) {
                        return;
                    }
                    var mainDiv = component.find('main-div');
                    $A.util.removeClass(mainDiv, 'slds-is-open');
                }
            }), 200
        );
    }

 })