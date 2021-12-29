({
    doInit : function(component, event, helper) {
        var newDependantFields = [];
        var values =  component.get("v.labels");
        var apiNames =  component.get("v.apiNames");
        for (var i = 0; i < values.length; i++) {
            newDependantFields.push({
                selected: false,
                sortOrder: 'none',
                api:apiNames[i],
                value: values[i],
                label: values[i]
            });
        }
        if(newDependantFields.length > 0)
            component.set("v.items", newDependantFields);
        component.set("v.items_",newDependantFields);
        
    },
    sortDefaultParams: function(component,event,helper) {
        var sortedBy =  component.get("v.sortedBy");
        var sortedDirection =  component.get("v.sortedDirection");
        if(!$A.util.isUndefinedOrNull(sortedBy))
        {
            console.log('sorted by: '+sortedBy);
            console.log('sorted order: '+sortedDirection);
            if(sortedBy!='')
            helper.sortData(component, sortedBy, sortedDirection);
            var newDependantFields = [];
            var values =  component.get("v.labels");
            var apiNames =  component.get("v.apiNames");
            for (var i = 0; i < values.length; i++) {
                if(apiNames[i] == sortedBy){
                    newDependantFields.push({
                        selected: true,
                        sortOrder: sortedDirection,
                        api:apiNames[i],
                        value: values[i],
                        label: values[i]
                    });
                }
                else
                {
                     newDependantFields.push({
                         selected: false,
                         sortOrder: 'none',
                         api:apiNames[i],
                         value: values[i],
                         label: values[i]
                     });
                }
            }
            if(newDependantFields.length > 0)
                component.set("v.items", newDependantFields);
            component.set("v.items_",newDependantFields);
        }
    },
    sort : function(component,event) {
        var sortItems = component.find("sortItems");
        $A.util.toggleClass(sortItems, 'slds-is-open');
    },
    hideSortItems : function(component,event)
    {
        window.setTimeout($A.getCallback(function() {
            var sortItems = component.find("sortItems");
            $A.util.removeClass(sortItems, 'slds-is-open');
        }), 150);   
    },
    handleSelection: function(component, event, helper) {
        var item = event.currentTarget;
        if (item && item.dataset) {
            console.log('----------- BEFORE SELECTION START--------------------');
            var value = item.dataset.value;
            console.log('Value: '+value);
            
            var selected = item.dataset.selected;
            console.log('selected: '+selected);
            
            var sortOrder = item.dataset.label;
            console.log('sortOrder: '+sortOrder);
            console.log('----------- BEFORE SELECTION END--------------------');
         
            
            var options = component.get("v.items");
            options.forEach(function(element) {
                if(element.value == value)
                {
                    element.selected = true;
                    if(sortOrder == 'none')
                        element.sortOrder = 'asc';
                    else if(sortOrder == 'asc')
                        element.sortOrder = 'desc';
                        else if(sortOrder == 'desc')
                            element.sortOrder = 'asc';
                            else
                                element.sortOrder = 'none';
                    
                    console.log('Sort on - api: '+element.api+' sort order: '+element.sortOrder);
                    helper.sortData(component, element.api, element.sortOrder);
                }else
                {
                    element.selected = false;
                    element.sortOrder = 'none'
                }
                console.log(element);
            });
            
           
            
            
            
            console.log('----------- AFTER SELECTION START--------------------');
            console.log(options);
            component.set("v.items", options);
            component.set("v.items_", options);
            console.log('----------- AFTER SELECTION END--------------------');
            //helper.setInfoText(component,labels);
            //helper.despatchSelectChangeEvent(component,values);
            
        }
    },
   
})