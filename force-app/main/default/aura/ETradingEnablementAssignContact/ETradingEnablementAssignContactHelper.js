({
    initialise : function(component, event)
    {
        var pageReference = component.get("v.pageReference");

        var actions = [
            { label: 'Select Contact', 'iconName': 'utility:change_owner', name: 'selectContact'}, 
            { label: 'New Contact', 'iconName': 'utility:adduser', name: 'newContact'}
        ];

        component.set("v.eTradingColumns", [
            {label: $A.get("$Label.c.PlatformId"), fieldName: 'platformId', type: 'text', initialWidth:130, sortable:true}, 
            {label: $A.get("$Label.c.PlatformUser"), fieldName: 'platformUser', type: 'text', initialWidth:200, sortable:true}, 
            {label: $A.get("$Label.c.PlatformEmail"), fieldName: 'platformEmail', type: 'text', initialWidth: 200, sortable: true }, 
            {label: $A.get("$Label.c.PlatformAccount"), fieldName: 'platformAccount', type: 'text', initialWidth: 200, sortable: true }, 
            {label: $A.get("$Label.c.Contact"), fieldName: 'contact', type: 'text', initialWidth:200, sortable:true},
            {label: $A.get("$Label.c.ElectronicPlatform"), fieldName: 'platform', type: 'text', initialWidth: 110, sortable: true },
            {type: 'action', typeAttributes: { rowActions: actions } }
        ]);

        this.getETradingEnablementData(component);
    },

    getETradingEnablementData : function(component)
    {
        var action = component.get("c.getETradingData");

        action.setCallback(this, function(response)
        {
            var state = response.getState();

            if (state == "SUCCESS")
            {
                var data = JSON.parse(response.getReturnValue());

                if (!data.error)
                {
                    component.set("v.eTradingData", data.eTradingData);
                }
                else
                {
                    this.displayErrorToast(data.errorMessage);
                }
            }
            else
            {
                this.displayErrorToast("Unable to read eTrading Enablement Data");
            }
        });

        $A.enqueueAction(action);
    },

    cancel : function(component, event)
    {
        var navigationService = component.find("navigationService");

        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__ETradingEnablementHome'
            }, 
            state: {

            }
        }

        component.set("v.pageReference", pageReference);
        event.preventDefault();
        navigationService.navigate(pageReference);
    }, 

    save : function(component, event)
    {
        var eTradingPlatformIdContactId = component.get("v.eTradingPlatformIdContactId");
        var eTradingPlatformIdContactIdArray = [];

        if (!$A.util.isEmpty(eTradingPlatformIdContactId))
        {
            this.showSpinner(component);

            for (var [key, value] of eTradingPlatformIdContactId) 
            {
                var eTradingPlatformIdContactIdValues = {
                                                            platformId : key, 
                                                            contactId : value
                                                        };

                eTradingPlatformIdContactIdArray.push(eTradingPlatformIdContactIdValues);
            }

            var eTradingPlatformIdContactIdObject = {
                                                        eTradingPlatformIdContactIds : eTradingPlatformIdContactIdArray
                                                    }

            var eTradingPlatformIdContactIdParameter = JSON.stringify(eTradingPlatformIdContactIdObject);

            var action = component.get("c.saveETradingPlatformContactData");

            action.setParams
            ({
                'eTradingPlatformIdContactId': eTradingPlatformIdContactIdParameter
            });

            action.setCallback(this, function(response) 
            {
                this.hideSpinner(component);

                if (response.getState() == "SUCCESS")
                {
                    var eTradingAssignContact = JSON.parse(response.getReturnValue())

                    if (!eTradingAssignContact.error)
                    {
                        component.set("v.eTradingData", "[]");

                        var navigationService = component.find("navigationService");

                        var pageReference = {
                            type: 'standard__component',
                            attributes: {
                                componentName: 'c__ETradingEnablementHome'
                            },
                            state: {

                            }
                        }

                        component.set("v.pageReference", pageReference);
                        navigationService.navigate(pageReference);
                    }
                    else
                    {
                        this.displayErrorToast(eTradingAssignContact.errorMessage);   
                    }
                }
                else
                {
                    this.displayErrorToast('Unable to save');
                }
            });

            $A.enqueueAction(action);
        }
        else
        {
            this.displayErrorToast("Contact(s) must be set");            
        }

    },

    updateColumnSorting : function(component, event)
    {
        var fieldName = event.getParam("fieldName");
        var sortDirection = event.getParam("sortDirection");

        component.set("v.sortETradingEnablementSortBy", fieldName);
        component.set("v.eTradingEnablementSortDirection", sortDirection);

        this.sortETradingData(component, fieldName, sortDirection, table);
    },

    sortETradingData: function (component, fieldName, sortDirection) 
    {
        var data = component.get("v.eTradingData");
        var reverse = sortDirection !== 'asc';

        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.eTradingData", data);
    },

    sortBy: function (field, reverse, primer) 
    {
        var key = primer ?
            function (x) { return primer(x[field]) } :
            function (x) { return x[field] };
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;

        return function (a, b) 
        {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }, 

    contactAction : function(component, event, headerAction)
    {
        var action = event.getParam("action");
        var row = event.getParam("row");

        component.set("v.eTradingSelectedPlatformId", row.platformId);

        switch (action.name)
        {
            case "selectContact" : 

                component.set("v.displaySearchContact", true);                
                
                var contactSearch = component.find("contactSearch");
                contactSearch.init();

                break;

            case "newContact" : 

                var newContact = component.find("newContact");
                newContact.open();

                break;

        }
    }, 

    close : function(component, event)
    {
        switch(event.getSource().getLocalId())
        {
            case "searchContactButtonIconClose" : 
            case "searchContactButtonClose" : 
                component.set("v.displaySearchContact", false);

                break;
        }
    },

    setContact: function (component, event) 
    {
        var eTradingSelectedPlatformId = component.get("v.eTradingSelectedPlatformId");
        var contactList = event.getParam("contactList");
        
        if (!$A.util.isEmpty(contactList) && contactList.length === 1 && !$A.util.isEmpty(eTradingSelectedPlatformId)) 
        {
            var eTradingData = component.get("v.eTradingData");
            var eTradingPlatformIdContactId = component.get("v.eTradingPlatformIdContactId");
            var eTradingPlatformIdContactIdMap;

            if ($A.util.isEmpty(eTradingPlatformIdContactId))
            {
                eTradingPlatformIdContactIdMap = new Map();
            }
            else
            {
                eTradingPlatformIdContactIdMap = eTradingPlatformIdContactId;
            }
            
            for (var rowLoop = 0; rowLoop < eTradingData.length; rowLoop++)
            {
                if (eTradingSelectedPlatformId == eTradingData[rowLoop].platformId)
                {
                    eTradingPlatformIdContactIdMap.set(eTradingSelectedPlatformId, contactList[0].Id);
                    eTradingData[rowLoop].contact = contactList[0].Name;
                    component.set("v.enableSave", true);
                }
            }

            component.set("v.eTradingData", eTradingData);
            component.set("v.eTradingPlatformIdContactId", eTradingPlatformIdContactIdMap);
        }
        
        component.set("v.displaySearchContact", false);
    },

    addNewContact: function (component, event) 
    {
        var eTradingSelectedPlatformId = component.get("v.eTradingSelectedPlatformId");
        var contactId = event.getParam("contactId");
        var contactName = event.getParam("contactName");

        if (!$A.util.isEmpty(contactId) && !$A.util.isEmpty(eTradingSelectedPlatformId)) 
        {
            var eTradingData = component.get("v.eTradingData");
            var eTradingPlatformIdContactId = component.get("v.eTradingPlatformIdContactId");
            var eTradingPlatformIdContactIdMap;

            if ($A.util.isEmpty(eTradingPlatformIdContactId)) 
            {
                eTradingPlatformIdContactIdMap = new Map();
            }
            else 
            {
                eTradingPlatformIdContactIdMap = eTradingPlatformIdContactId;
            }

            for (var rowLoop = 0; rowLoop < eTradingData.length; rowLoop++) 
            {
                if (eTradingSelectedPlatformId == eTradingData[rowLoop].platformId) 
                {
                    eTradingPlatformIdContactIdMap.set(eTradingSelectedPlatformId, contactId);
                    eTradingData[rowLoop].contact = contactName; 
                    component.set("v.enableSave", true);
                }
            }

            component.set("v.eTradingData", eTradingData);
            component.set("v.eTradingPlatformIdContactId", eTradingPlatformIdContactIdMap);
        }
    }, 

    displayErrorToast : function(errorMessage)
    {
    	var toastEvent = $A.get("e.force:showToast");
    	
    	toastEvent.setParams({
    		title: "Error",
            message: errorMessage,
            type: "error", 
            mode: "sticky"
        });
            
        toastEvent.fire();
    },

    showSpinner : function(component)
    {   
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinner : function(component)
    {  
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
    }  
})