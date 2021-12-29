window.lookup_util = (function() {
    var value = 0; // private
    var multiple = false;
    var lookupList;    
    
    return { 
        //
        preSelectlookup: function(cmp,event,isMultiple){
            var preSelectedIds = cmp.get("v.preSelectedIds");
            var sObjectAPIName = cmp.get("v.sObjectAPIName");
            var singlelookup = cmp.find('toggler');
            var multiplelookup = cmp.find('lookuplist');
            
            var action = cmp.get('c.preSelectlookup');
            action.setParams({"lookupids" : preSelectedIds,"sObjectAPIName" : sObjectAPIName,"uniqueSalesCode": cmp.get('v.uniqueCoverages'),
                              "allRecords": cmp.get('v.allRecords')});
            action.setCallback(this, function(response) {
                var state = response.getState();
                // Callback succeeded
                if (cmp.isValid() && state === "SUCCESS")
                {
                    console.log('')
                    // Get the search matches
                    var matches = response.getReturnValue();
                    // If we have no matches, return nothing
                    if (matches.length == 0)
                    {
                        cmp.set('v.matches', null);
                        if (!(typeof singlelookup === 'undefined'))
                        {
                            $A.util.removeClass(singlelookup, 'slds-is-open');
                        }
                        
                        if (!(typeof multiplelookup === 'undefined'))
                        {
                            $A.util.removeClass(multiplelookup, 'slds-show');
                        } 
                        return;
                    }
                    
                    // Store the results
                    cmp.set('v.matches', matches);
                  
                    var lookupPill = cmp.find("lookup-pill");
                    var itemsList = new Array();
                    var emailList = new Array();
                    var objectIds = new Array();
                    var selMatches = cmp.get("v.selmatches");
            		var preSelectedItems = new Array(); 
                    
                    for(var i=0;i<matches.length;i++)
                    {
                        if(!$A.util.isUndefinedOrNull(matches[i].SObjectLabel))
                        {
                            if(matches[i].SObjectLabel!='')
                            itemsList.push(matches[i].SObjectLabel);
                        }
                        
                        if(!$A.util.isUndefinedOrNull(matches[i].SObjectId))
                        {
                            if(matches[i].SObjectId!='')
	                        objectIds.push(matches[i].SObjectId);
                        }
                        
                        if(!$A.util.isUndefinedOrNull(matches[i].emailAddress))
                        {
                            if(matches[i].emailAddress!='')
	                        emailList.push(matches[i].emailAddress);
                        }
                        selMatches.push(matches[i]);
                        preSelectedItems.push(matches[i]);
                    }
                    
                    if(itemsList.length > 0)
                    {
                        cmp.set("v.items",itemsList);
                        if(!isMultiple && itemsList.length == 1)
                    	{
                            cmp.set("v.searchString",itemsList[0]);
                            cmp.set("v.disabled",true);
                        }
                        
                    }
                    
                    if(emailList.length > 0)
                    {
                        cmp.set("v.emails",emailList);
                    }
                    
                    if(selMatches.length > 0)
                    {
                        cmp.set("v.selMatches",preSelectedItems);
                    }
                    
                    if(objectIds.length > 0)
                    {
                        cmp.set("v.objectIds",objectIds);
                        var compEvent = cmp.getEvent("itemChange");
                        compEvent.setParams({ "values": cmp.get("v.objectIds") });
                        compEvent.setParams({ "data": preSelectedItems });
                        compEvent.fire();
                    }

                    
                    
                    
                    // Show the Lookup pill
                    $A.util.removeClass(lookupPill, 'slds-hide');
                    if (!(typeof singlelookup === 'undefined'))
                    {
                        $A.util.removeClass(singlelookup, 'slds-is-open');
                        $A.util.addClass(cmp.find("lookup"), 'input--numberfield');
                        
                        if(!$A.util.isUndefinedOrNull(cmp.get("v.placeholder")))
                        {
                            cmp.set("v.tempplaceholder",cmp.get("v.placeholder"));
                            cmp.set("v.placeholder","");
                        }
                        
                    }
                    
                    if (!(typeof multiplelookup === 'undefined'))
                    {
                        $A.util.removeClass(multiplelookup, 'slds-show');
                    }
                    
                }
                else if (state === "ERROR") // Handle any error by reporting it
                {
                    var errors = response.getError();
                    
                    if (errors) 
                    {
                        if (errors[0] && errors[0].message) 
                        {
                            console.log('Error: '+errors[0].message);
                        }
                    }
                    else
                    {
                        console.log('Error occured. ');
                    }
                }
            });
            
            $A.enqueueAction(action); 
            
            
        },
        
        //search string
        doSearch: function(cmp,event,isMultiple) {
            var singlelookup = cmp.find('toggler');
            var multiplelookup = cmp.find('lookuplist');
            
            var waitingId = null;
            var searchString = cmp.get('v.searchString');
            var inputElement = cmp.find('lookup');
            
            
            var charlimit = cmp.get('v.charLimit');
            
            if(searchString === '' && typeof searchString != 'undefined')
            {
                cmp.set('v.matches', null);
                
                if (!(typeof singlelookup === 'undefined'))
                {
                    $A.util.removeClass(singlelookup, 'slds-is-open');
                }
                
                if (!(typeof multiplelookup === 'undefined'))
                {
                    $A.util.removeClass(multiplelookup, 'slds-show');
                }
                if(cmp.get("v.sObjectAPIName")!='Sales_Team_for_Coverage__c')
                    this.getRecentlyViewed(cmp,isMultiple);
                
                return;
            }
            
            inputElement.set('v.errors', null);
            // We need at least 2 characters for an effective search
            if (typeof searchString === 'undefined' || searchString.length < charlimit)
            {
                // Hide the lookuplist
                if (!(typeof singlelookup === 'undefined'))
                {
                    $A.util.removeClass(singlelookup, 'slds-is-open');
                }
                
                if (!(typeof multiplelookup === 'undefined'))
                {
                    $A.util.removeClass(multiplelookup, 'slds-show');
                }
                
                return;
            }
            
            searchString = searchString.concat('*');
            
            // Create an Apex action
            var action = cmp.get('c.lookup');
            
            // Get the API Name
            var sObjectAPIName = cmp.get('v.sObjectAPIName');
            var showNomuraContact = cmp.get("v.showNomuraEmployee");
            var allRecords = cmp.get("v.allRecords");
            var accountType;
            
            if($A.util.isUndefinedOrNull(cmp.get("v.accountType")))
                accountType = new Array();
            else
                accountType = cmp.get("v.accountType");
           
            // Added param JIRA SALES - 2607 --includeRGWithRMOnly
            action.setParams({ "searchString" : searchString, "sObjectAPIName" : sObjectAPIName, 
                              "includeNomuraContact" : showNomuraContact, "allRecords" : allRecords, 
                              "accountRecordType" : accountType, "uniqueSalesCode" : cmp.get("v.uniqueCoverages"), 
                              "inactiveSalesCode" : cmp.get("v.inactiveCoverages"),
                              "isSplitSalesCode":cmp.get("v.splitSalesCode"),"withSharing":cmp.get("v.withSharing"),
                              "baseString":cmp.get('v.searchString'), "singleLookupJSON":cmp.get("v.singleLookupJSON"),
                              "accountCompany":cmp.get("v.accountCompany"),
                              "includeRGWithRMOnly": cmp.get("v.includeRGWithRMOnly"), 
                              "filterDeskCode": cmp.get("v.filterDeskCode"),
                              "includeInstinetContact": cmp.get("v.includeInstinetContact"),
                              "showCoveredAccountDetails" : cmp.get("v.showCoveredAccountDetails"), 
                              "accountId" : cmp.get("v.accountId")});
            // Mark the action as abortable, this is to prevent multiple events from the keyup executing
            action.setAbortable();
            // Set the parameters
            // Define the callback
            action.setCallback(this, function(response) {
                var state = response.getState();
                // Callback succeeded
                if (cmp.isValid() && state === "SUCCESS")
                {
                    // Get the search matches
                    var matches = response.getReturnValue();
                    
                    // If we have no matches, return nothing
                    if (matches.length == 0)
                    {
                        cmp.set('v.matches', null);
                        if (!(typeof singlelookup === 'undefined'))
                        {
                            $A.util.removeClass(singlelookup, 'slds-is-open');
                        }
                        
                        if (!(typeof multiplelookup === 'undefined'))
                        {
                            $A.util.removeClass(multiplelookup, 'slds-show');
                        }
                        
                        return;
                    }
                    
                    // Store the results
                    cmp.set('v.matches', matches);
                    
                    if(matches.length > 0)
                    {
                        if (!(typeof singlelookup === 'undefined'))
                        {
                            $A.util.addClass(singlelookup, 'slds-is-open');
                        }
                        
                        if (!(typeof multiplelookup === 'undefined'))
                        {
                            $A.util.addClass(multiplelookup, 'slds-show');
                        }
                    }
                    
                }
                else if (state === "ERROR") // Handle any error by reporting it
                {
                    var errors = response.getError();
                    
                    if (errors) 
                    {
                        if (errors[0] && errors[0].message) 
                        {
                            console.log('Error: '+errors[0].message);
                        }
                    }
                    else
                    {
                        console.log('Error occured. ');
                    }
                }
            });
            
            window.clearTimeout(this.waitingId);
            
            this.waitingId = window.setTimeout($A.getCallback(function() {
                if (cmp.isValid()) {
                    $A.enqueueAction(action); 
                }
            }), 250);
        },
        
        //handle selection
        handleSelection: function(cmp,event,isMultiple){
            var singlelookup = cmp.find('toggler');
            var multiplelookup = cmp.find('lookuplist');
            
            var objectId = this.resolveId(event.currentTarget.id); //objectId
            
            var item = event.currentTarget;
            
            var emailAddress = '';
            var selectedIndex = -1;
            if (item && item.dataset) {
                emailAddress = item.dataset.label;  // email Address if exist
                selectedIndex = item.dataset.index;
            }    
            
            var showMetadata = cmp.get("v.showMetadata");
            if(showMetadata == true){
                
                /*var y = event.currentTarget;
                console.log(y);
                console.log(y.innerHTML);*/
                if (item && item.dataset) {
                    
                    //For displaying email address of Users/ Nomura employees.
                    var sObjectAPIName = cmp.get("v.sObjectAPIName");       
                    
                    
                    if(sObjectAPIName == 'User'){
                        var selectedItem = item.dataset.value;
                        var selectedItemIndex = selectedItem.indexOf('[');
                        var objectLabel = selectedItem.substring(0, selectedItemIndex - 1);
                    }
                    else
                    	var objectLabel = item.dataset.value;  // email Address if exist
                    
                    
                }  
                /*var parser = new DOMParser();
                var x = parser.parseFromString(y, "text/html");
                var objectLabel = x.getElementsByClassName("my-classname")[0].innerText;
                console.log('objectLabel1:' + objectLabel);*/
            }else{
                // The Object label is the inner text)
                //For displaying email address of Users/ Nomura employees.
                var sObjectAPIName = cmp.get("v.sObjectAPIName"); 
                
                if(sObjectAPIName == 'User'){
                    var selectedItem = event.currentTarget.innerText; //object label 
                    var selectedItemIndex = selectedItem.indexOf('[');
                    var objectLabel = selectedItem.substring(0, selectedItemIndex - 1);                    
                }
                else
                	var objectLabel = event.currentTarget.innerText; //object label   
                
                
            }
            
            var itemsList = cmp.get("v.items");
            var emailList = cmp.get("v.emails");
			var matches = cmp.get("v.matches");
             
            var selMatches = cmp.get("v.selmatches");
            
            
            var lookupPill = cmp.find("lookup-pill");
            if( !$A.util.hasClass(lookupPill, 'wrapLookupPills'))
                $A.util.addClass(lookupPill, 'wrapLookupPills');
            
            var objectIds = cmp.get("v.objectIds");
            if(selectedIndex!=-1 && objectIds.indexOf(objectId) == -1)
                selMatches.push(matches[selectedIndex]);
            
            if(selMatches.length > 0)
            cmp.set("v.selmatches",selMatches);
            
            if(itemsList.length === 0)
            {
                itemsList.push(objectLabel);
                objectIds.push(objectId);
                
                if(emailAddress!='')
                    emailList.push(emailAddress);
                
            } 
            else if(itemsList.length >= 1)
            {
                if(objectIds.indexOf(objectId) == -1)
                {
                    itemsList.push(objectLabel);
                    emailList.push(emailAddress);
                    objectIds.push(objectId);
                }
            }
            
            if(itemsList.length > 0)
            {
                cmp.set("v.items",itemsList);
            }
            
            if(emailList.length > 0)
            {
                cmp.set("v.emails",emailList);
            }
            
            if(objectIds.length > 0)
            {
                cmp.set("v.objectIds",objectIds);
            }
            
            // Create the UpdateLookupId event
            var updateEvent = $A.get("e.c:LookupUpdateEvent");
            updateEvent.setParams({ "sObjectId": objectId});
            updateEvent.setParams({ "Name": objectLabel});
            updateEvent.setParams({ "objectAPIName": cmp.get("v.sObjectAPIName")});
            updateEvent.setParams({ "Email": emailAddress});
            updateEvent.setParams({ "action": "add"});
            updateEvent.fire();
            
            var compEvent = cmp.getEvent("itemChange");
            compEvent.setParams({ "values": cmp.get("v.objectIds") });
            compEvent.setParams({ "data": cmp.get("v.selmatches") });
            compEvent.fire();
            
            // Update the Searchstring with the Label
           
            if (!(typeof singlelookup === 'undefined'))
            {
                if(itemsList.length > 0)
                {
                   cmp.set("v.disabled",true);
                }
                $A.util.removeClass(singlelookup, 'slds-is-open');
                cmp.set("v.searchString",objectLabel);
                $A.util.addClass(cmp.find("lookup"), 'input--numberfield');
                if(!$A.util.isUndefinedOrNull(cmp.get("v.placeholder")))
                {
                    cmp.set("v.tempplaceholder",cmp.get("v.placeholder"));
                    cmp.set("v.placeholder","");
                }
            }
            
            if (!(typeof multiplelookup === 'undefined'))
            {
                cmp.set("v.searchString", "");
                $A.util.removeClass(multiplelookup, 'slds-show');
                $A.util.removeClass(multiplelookup, 'slds-hide');
            }
            
            
            // Show the Lookup pill
            $A.util.removeClass(lookupPill, 'slds-hide');
            
            cmp.find("lookup").focus();
            
         },
        
        //clear selection
        clearSelection: function(cmp,event,isMultiple){
            var singlelookup = cmp.find('toggler');
            var multiplelookup = cmp.find('lookuplist');
            
            var item = event.currentTarget;
            var itemsList = cmp.get("v.items");
            var emailList = cmp.get("v.emails");

            if (item && item.dataset) {
                var itemvalue = item.dataset.value;
                var itemindex = item.dataset.index;
                
                               
                if(itemsList.length >= 1)
                {
                    
                    if(itemsList.indexOf(itemvalue)!=-1)
                    {
                        
                        var index = itemsList.indexOf(itemvalue);
                        
                        if (index > -1) {
                            itemsList.splice(index, 1);
                            var objectIds = cmp.get("v.objectIds");
                            var emailList = cmp.get("v.emails");
                            var selmatches = cmp.get("v.selmatches");
                            var objectId = objectIds[index];
                            var emailId = emailList[index];
                            objectIds.splice(index, 1);
                            emailList.splice(index, 1);
                            selmatches.splice(index,1);
                            // Create the UpdateLookupId event
                            var updateEvent = $A.get("e.c:LookupUpdateEvent");
                            updateEvent.setParams({ "action": "delete"});
                            updateEvent.setParams({ "Name": itemvalue});
                            updateEvent.setParams({ "objectAPIName": cmp.get("v.sObjectAPIName")});
                            updateEvent.setParams({ "sObjectId": objectId});
                            updateEvent.setParams({ "Email": emailId});
                            updateEvent.fire();
                        }
                        cmp.set("v.items",itemsList);
                        cmp.set("v.emails",emailList);
                        cmp.set("v.objectIds",objectIds);
                        cmp.set("v.selmatches",selmatches);
                        var compEvent = cmp.getEvent("itemChange");
                        compEvent.setParams({ "values": cmp.get("v.objectIds") });
                        compEvent.setParams({ "data": cmp.get("v.selmatches") });
                        compEvent.fire();
                        if(!isMultiple){
                            var resetEvent = cmp.getEvent("onReset");
                            resetEvent.fire();
                        }
                        
                    }
                    
                }
            }   
            
            // Create the ClearLookupId event
            var clearEvent = cmp.getEvent("clearLookupIdEvent");
            
            // Fire the event
            clearEvent.fire();
            
            // Clear the Searchstring
            cmp.set("v.searchString", '');
             if(!isMultiple)
                cmp.set("v.disabled",false);
            
            // Hide the Lookup pill
            if(itemsList.length == 0)
            {
                var lookupPill = cmp.find("lookup-pill");
                $A.util.addClass(lookupPill, 'slds-hide');
                cmp.find("lookup").set("v.errors",null);
                cmp.set('v.matches', null);
                
                if (!(typeof singlelookup === 'undefined'))
                {
                    $A.util.removeClass(singlelookup, 'slds-is-open');
                }
                
                if (!(typeof multiplelookup === 'undefined'))
                {
                    $A.util.removeClass(multiplelookup, 'slds-show');
                }
                
                $A.util.removeClass(lookupPill, 'wrapLookupPills');
                
                if(!isMultiple)
                {
                    $A.util.removeClass(cmp.find("lookup"), 'input--numberfield');
                    if(!$A.util.isUndefinedOrNull(cmp.get("v.tempplaceholder")))
                    { 
                        cmp.set("v.placeholder",cmp.get("v.tempplaceholder"))
                        cmp.set("v.tempplaceholder","");
                    }
                }
            }        
            
        },
        
        getRecentlyViewed: function(cmp,isMultiple){
            var waitingId = null;
            var singlelookup = cmp.find('toggler');
            var multiplelookup = cmp.find('lookuplist');
            cmp.set('v.matches', null);
            var showNomuraContact = cmp.get("v.showNomuraEmployee");
            var searchString = cmp.get('v.searchString');
            var allRecords = cmp.get("v.allRecords");
            
            if (typeof searchString === 'undefined' || searchString.length == 0)
            {
                // Get the API Name
                var sObjectAPIName = cmp.get('v.sObjectAPIName');
                // Create an Apex action
                var action = cmp.get('c.recentlyViewed');
      
                var accountType;
                if($A.util.isUndefinedOrNull(cmp.get("v.accountType")))
                    accountType = new Array();
                else
                    accountType = cmp.get("v.accountType");
                
                // Added param JIRA SALES - 2607 --includeRGWithRMOnly
                action.setParams({"sObjectAPIName" : sObjectAPIName, "includeNomuraContact" : showNomuraContact, 
                                  "allRecords" : allRecords, "accountRecordType" : accountType, 
                                  "includeRGWithRMOnly": cmp.get("v.includeRGWithRMOnly"), 
                                  "includeInstinetContact": cmp.get("v.includeInstinetContact"),
                                  "withSharing":cmp.get("v.withSharing"),
                                  "showCoveredAccountDetails" : cmp.get("v.showCoveredAccountDetails") ,"accountId" : cmp.get("v.accountId") });
                //action.setParams({"sObjectAPIName" : sObjectAPIName, "includeNomuraContact" : showNomuraContact, "allRecords" : allRecords, "accountRecordType" : accountType});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    // Callback succeeded
                    if (cmp.isValid() && state === "SUCCESS")
                    {
                        // Get the search matches
                        var matches = response.getReturnValue();
                        // If we have no matches, return nothing
                        if (matches.length == 0)
                        {
                            cmp.set('v.matches', null);
                            return;
                        }
                        
                        if(matches.length > 0)
                        {
                            // Store the results
                            cmp.set('v.matches', matches);
                            
                            if (!(typeof singlelookup === 'undefined'))
                            {
                                $A.util.addClass(singlelookup, 'slds-is-open');
                            }
                            
                            if (!(typeof multiplelookup === 'undefined'))
                            {
                                $A.util.addClass(multiplelookup, 'slds-show');
                            }
                        }
                        
                    }
                    else if (state === "ERROR") // Handle any error by reporting it
                    {
                        var errors = response.getError();
                        
                        if (errors) 
                        {
                            if (errors[0] && errors[0].message) 
                            {
                            }
                        }
                        else
                        {
                        }
                    }
                });
                
                window.clearTimeout(this.waitingId);
                
                this.waitingId = window.setTimeout($A.getCallback(function() {
                    if (cmp.isValid()) {
                        $A.enqueueAction(action); 
                    }
                }), 250);    
            }
        },
        
        resolveId : function(elmId)
        {
            var i = elmId.lastIndexOf('_');
            return elmId.substr(i+1);
        }   
    };
}());
