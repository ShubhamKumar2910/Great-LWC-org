({
    clearSelection: function(component,event){
        var item = event.currentTarget;
        console.log(item);
        var itemsList = component.get("v.items");
        console.log(itemsList);
        
        if (item && item.dataset) {
            component.set("v.preSelectedId", '');
            var itemvalue = item.dataset.value;
            var itemindex = item.dataset.index;
            console.log('itemvalue under clear');
            console.log(itemvalue);
            console.log('itemindex under clear');
            console.log(itemindex);
            var selectedIds = new Array();
            var selectedItems = component.get("v.selectedItems");
            selectedItems.length = 0;
            
            // Create the ClearLookupId event
            var clearEvent = component.getEvent("clearIdEvent");
            // Fire the event
            clearEvent.fire();
            
            // Clear the Searchstring
            component.set("v.searchText", '');
            component.set("v.disabled",false);
            
            component.showItems();
            
            
            var compEvent = component.getEvent("selectedEvent");
            compEvent.setParams({ "values": selectedIds });
            compEvent.setParams({ "data": selectedItems });
            compEvent.fire();
            var lookupPill = component.find("lookup-pill");
            $A.util.addClass(lookupPill, 'slds-hide');
            //component.set("v.disabled", true);
        }   
        else{
            // Clear the Searchstring
            component.set("v.searchText", '');
            component.set("v.items", null);
            component.set("v.placeholder", 'Search Addresses');
            component.set("v.disabled", true);
        }
        
    },
    
    //handle selection
    handleSelection: function(cmp,event){
        var selectedValue;
        var selectedIndex = -1;
        var selectedIds = new Array();
        var selectedItems = cmp.get("v.selectedItems");
        selectedItems.length = 0;
        
        var items = cmp.get("v.items");
        
        var item = event.currentTarget;
        console.log("**Item**");
        console.log(item);

        if (item && item.dataset) {
            selectedValue = item.dataset.value;
            selectedIds.push(selectedValue);
            selectedIndex = item.dataset.index;
            if(selectedIndex!=-1)
                selectedItems.push(items[selectedIndex]);
            
            
            
            cmp.set("v.items",selectedItems);
            var compEvent = cmp.getEvent("selectedEvent");
            console.log("**compEvent**");
            console.log(compEvent);
            compEvent.setParams({ "values": selectedIds });
            compEvent.setParams({ "data": selectedItems });
            compEvent.fire();
            
            
            var comboList = cmp.find('comboBox');
            cmp.set("v.searchText",selectedItems[0].label);
            $A.util.removeClass(comboList, 'slds-is-open');
            cmp.set("v.disabled",true);
            // Show the Lookup pill
            var lookupPill = cmp.find("lookup-pill");
            $A.util.removeClass(lookupPill, 'slds-hide');
            
        }    
            
    },
    
    resolveId : function(elmId)
    {
        var i = elmId.lastIndexOf('_');
        return elmId.substr(i+1);
    } ,
    
    initialiseComponent : function(component){
        var items = component.get("v.items");
        console.log(component.get("v.items"));
        var showFilterData = component.get('v.showFilterData');
        var comboList = component.find('comboBox');
        
            if(showFilterData === false){
                var query = component.get("v.query");
                console.log(query);
                //component.set("v.disabled", true); 
                var recordId = component.get("v.recordId");
                console.log('recordId: ' + recordId);
                var object = component.get("v.sObjectAPIName");
                console.log('object: ' + object);
                var withSharingOption = component.get("v.withSharing");
                var validationResult = [];
                var action = component.get("c.performQuery");
                var isPodAccount = component.get("v.isPodAccount");
                console.log('isPodAccount : ' + isPodAccount);
                action.setParams({
                    "query" : query,
                    "sObjectAPIName" :　object, 
                    "recordId" : recordId,
                    "withSharing" : withSharingOption,
                    "isPodAccount" : isPodAccount
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var results = [];
                        results =  response.getReturnValue();
                        console.log(results);
                        console.log('results.length: ' + results.length);
                        component.set("v.items", results);
                        
                        var listItems = component.find('combolist-items');
                        
                        if(results.length == 0)
                        {
                            $A.util.removeClass(comboList, 'slds-is-open');
                             component.hideItems();
                        }
                        
                        if(results.length >= 1)
                        {
                            /*$A.util.addClass(comboList, 'slds-is-open');
                            if( !$A.util.hasClass(listItems, 'overflowScrollbar')){
                                $A.util.addClass(listItems, 'overflowScrollbar');
                            }*/
                            console.log('set focus');
                             component.showItems();
                            //component.find("tmt").focus();
                            setTimeout(function(){ component.find("lookup").focus(); }, 200);        
                            component.set("v.disabled",false);
                        }
                        
                           
                            /*var listItems = component.find('combolist-items');
                            if( !$A.util.hasClass(listItems, 'slds-listbox')){
                                $A.util.addClass(listItems, 'slds-listbox');
                            }
                            if( !$A.util.hasClass(listItems, 'slds-listbox_vertical')){
                                $A.util.addClass(listItems, 'slds-listbox_vertical');
                            }
                            if( !$A.util.hasClass(listItems, 'slds-dropdown')){
                                $A.util.addClass(listItems, 'slds-dropdown');
                            }
                            if( !$A.util.hasClass(listItems, 'slds-dropdown_fluid')){
                                $A.util.addClass(listItems, 'slds-dropdown_fluid');
                            }
                            if( !$A.util.hasClass(listItems, 'overflowScrollbar')){
                                $A.util.addClass(listItems, 'overflowScrollbar');
                            }
        
                        if(results.length == 0){
                           
                                $A.util.removeClass(listItems, 'slds-listbox');
                                $A.util.removeClass(listItems, 'slds-listbox_vertical');
                                $A.util.removeClass(listItems, 'slds-dropdown');
                                $A.util.removeClass(listItems, 'slds-dropdown_fluid');
                               // $A.util.removeClass(listItems, 'overflowScrollbar');
                                $A.util.addClass(listItems, 'slds-hide');
        
                        }
                        else if(results.length >= 1){
                             $A.util.removeClass(listItems, 'slds-hide');
                        }*/
                        
                        
                    }else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                validationResult.push({
                                    message :  errors[0].message
                                });
                                component.set("v.hasErrors", true);
                                component.set("v.errorMessages", validationResult);
                                document.body.scrollTop = document.documentElement.scrollTop = 0;
                            }
                        } else {console.log("Unknown error");}
                    }
                });
                 $A.enqueueAction(action);  
                }
            else{
                if(items != null){
        
                //data coming from ContactListMobileFilters.cmp of mobile using showFilterData attribute to show addresses.                
                var combolistItems = component.find('combolist-items');
                $A.util.removeClass(combolistItems, 'hideComboboxListItems');
                
                component.set("v.items", items);
                if(items.length == 0)
                    {
                        $A.util.removeClass(comboList, 'slds-is-open');
                         component.hideItems();
                    }
                    
                    if(items.length >= 1)
                    {
                        component.showItems();
                        component.set("v.disabled",true);
                    }
                }
            }
        
    }, 
      
    search : function(component){
        var query = component.get("v.query");
        var textValue = component.get("v.searchText");
        console.log(textValue);
        var recordId = component.get("v.recordId");
        console.log(recordId);
        var object = component.get("v.sObjectAPIName");
        console.log(object);
        var validationResult = [];
        var action = component.get("c.search_text");
        var isPodAccount = component.get("v.isPodAccount");
        console.log('isPodAccount : ', isPodAccount);
        
        action.setParams({
            "searchString" : textValue,
            "sObjectAPIName" :　object, 
            "recordId" : recordId,
            "addressValue": component.get("v.searchText"),
            "isPodAccount": isPodAccount
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var results = [];
                results =  response.getReturnValue();
                console.log(results);
                component.set("v.items", results);
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        validationResult.push({
                            message :  errors[0].message
                        });
                        component.set("v.hasErrors", true);
                        component.set("v.errorMessages", validationResult);
                        document.body.scrollTop = document.documentElement.scrollTop = 0;
                    }
                } else {console.log("Unknown error");}
            }
        });
        
        $A.enqueueAction(action);
    },

    preselectLookup : function(component){
        console.log('preselectLookup');

        var query = component.get("v.query");
        
        var preSelectedId = component.get("v.preSelectedId");
        console.log('preSelectedId: ' + preSelectedId);
        var object = component.get("v.sObjectAPIName");
        console.log('object: ' + object);
        var isPodAccount = component.get("v.isPodAccount");
        console.log('isPodAccount : ' + isPodAccount);
        
        var validationResult = [];
        var action = component.get("c.preSelectedLookup");
        
        action.setParams({
            "query" : query,
            "sObjectAPIName" :　object, 
            "recordId" : preSelectedId,
            "isPodAccount" : isPodAccount
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var results = [];
                results =  response.getReturnValue();
                console.log('results: ' + results);
                console.log('results.length: ' + results.length);
                component.set("v.items", results);

                if(results.length == 1){
                    var selectedIds = new Array();
                    var selectedItems = component.get("v.selectedItems");
                    selectedIds.push(results[0].value);
                    console.log(selectedIds);
                    selectedItems.push(results[0]);
                    console.log(selectedItems);
                    

                    var compEvent = component.getEvent("selectedEvent");
                    compEvent.setParams({ "values": selectedIds });
                    compEvent.setParams({ "data": results });
                    compEvent.fire();
                    
                    
                    var comboList = component.find('comboBox');
                    component.set("v.searchText",selectedItems[0].label);
                    $A.util.removeClass(comboList, 'slds-is-open');
                    component.set("v.disabled",true);
                    // Show the Lookup pill
                    var lookupPill = component.find("lookup-pill");
                    $A.util.removeClass(lookupPill, 'slds-hide');
                    
                }

                if(results.length == 0){
                    var listItems = component.find('combolist-items');

                        $A.util.removeClass(listItems, 'slds-listbox');
                        $A.util.removeClass(listItems, 'slds-listbox_vertical');
                        $A.util.removeClass(listItems, 'slds-dropdown');
                        $A.util.removeClass(listItems, 'slds-dropdown_fluid');
                        $A.util.removeClass(listItems, 'overflowScrollbar');
                        $A.util.addClass(listItems, 'slds-hide');

                }
                
                
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        validationResult.push({
                            message :  errors[0].message
                        });
                        component.set("v.hasErrors", true);
                        component.set("v.errorMessages", validationResult);
                        document.body.scrollTop = document.documentElement.scrollTop = 0;
                    }
                } else {console.log("Unknown error");}
            }
        });
        
        $A.enqueueAction(action);


    }
    
    
    
    
})