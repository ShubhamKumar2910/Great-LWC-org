({
    searchRecentRecords: function (component) {
        var account = component.get("v.accountId");
        if (account !== null && account !== undefined && account !== "") {
            component.showSpinner();
            component.hideDatatable();

            var action = component.get("c.getRecentContactData");
            action.setParams({
                "accountId": account
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                
                if (state === "SUCCESS") {
                    var newRecords = JSON.parse(response.getReturnValue());
                    
                    if (newRecords.length === 0) {
                        //No result found for the search so display warning message
                        component.set("v.hasWarning", "true");
                        component.hideDatatable();
                        component.set("v.addDisabled", "true");
                        component.set("v.addCloseDisabled", "true");
                        component.hideSpinner();

                    } else {
                        //result found. display records in datatable
                        component.set("v.addDisabled", "false");
                        component.set("v.addCloseDisabled", "false");
                        component.hideSpinner();
                        component.set("v.hasWarning", "false");
                        component.showDatatable();
                        this.createTable(component, newRecords);
                    }
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message:" + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }

                }
            });
            $A.enqueueAction(action);
        }
        else
            component.reset();
    },

    searchRecords: function (component) {
        component.showSpinner();
        var contactSearch = component.get("v.contact");
        var account = component.get("v.accountId");
        var action = component.get("c.getContactData");
        action.setParams({
            "contactName": contactSearch,
            "accountId": account
        });
        
        console.log("-- in EventBrowseContact");
        action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            component.hideSpinner();
            if (state === "SUCCESS") {
                var jsonString = JSON.parse(response.getReturnValue());
                if (jsonString.length === 0) {
                    //No result found for the search so display warninng message                    
                    component.displayError();
                } else {
                    //result found. display records in datatable
                    component.set("v.addDisabled", "false");
                    component.set("v.addCloseDisabled", "false");
                    component.set("v.hasWarning", "false");

                    this.filterRecords(component, jsonString, contactSearch);
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message:" + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    //Below Method is used because we return 'All' contacts from server controller. but we need to display only records related to search string.
    filterRecords: function (component, jsonString, contactSearch) {
        var newRecords = [];
        newRecords = jsonString;
        this.createTable(component, newRecords);
        /* SHIELD
		if (contactSearch) {
            var jsonObj = jsonString;
            var upperLocalName;
            var upperContactName;
            var upperContactEmail;
            var rows = 0;

            var filtered = jsonObj.filter(function (jsonObj) {
                var conName = jsonObj.contactName;
                var localName = jsonObj.localLanguageName;
                var searchName = contactSearch.toUpperCase();
                var email = jsonObj.contactEmail;

                upperContactName = conName ? conName.toUpperCase() : '';
                upperContactEmail = email ? email.toUpperCase() : '';
                upperLocalName = localName ? localName.toUpperCase() : '';

                //Remove * when used in search string.
                if (contactSearch.includes('*'))
                    searchName = searchName.replace(/[\\*]/g, '');

                if (!searchName.includes('@')) {
                    //User searches by name or local language name
                    if (searchName.includes("\r\n"))
                        searchName = searchName.replace("\r\n", "");

                    //Split the search string and then use it to check whether it's include in name or localLanguageName
                    var splitName = searchName.split(" ");
                    var searchFlag = true;
                    for (var i = 0; i < splitName.length; i++) {
                        if (!upperContactName.includes(splitName[i]) && (upperLocalName && !upperLocalName.includes(splitName[i]))) {
                            searchFlag = false;
                            break;
                        } else if (!upperContactName.includes(splitName[i]) && !upperLocalName) {
                            searchFlag = false;
                            break;
                        }
                    }
                    if (searchFlag) {
                        newRecords.push(jsonObj);
                    }
                }
                else {
                    //User searches by emailId                  
                    newRecords.push(jsonObj);
                }
            });
            this.createTable(component, newRecords);
        }
        else {
            //Searched directly by account
            newRecords = jsonString;
            this.createTable(component, newRecords);
        }
		SHIELD
		*/
    },

    addData: function (component, closeClicked) {
        var tableCmp = component.find("contactTable");
        var selectedTableValues = tableCmp.getSelectedRows();
        
        var selectedIds = [];
        var closeString = closeClicked;
        
        var selectedRows = component.get('v.selectedRows');
        
        var selectedContacts = component.get('v.selectedContacts');
        var contactList = component.get("v.contactList");

        if (selectedContacts && selectedContacts.length > 0) {
            var maxRowSelect = component.get("v.maxRowSelect");
            if (!isNaN(maxRowSelect) && maxRowSelect === 1) {
                selectedContacts = [];
                contactList = [];
            }
        }

        var sendContactObjectsInEvent = component.get("v.sendContactObjectsInEvent");
        
        for (var i = 0; i < selectedTableValues.length; i++) {
            //Will ignore does not exist contact. JIRA 3361
            if(selectedTableValues[i].contactId){
                selectedIds.push(selectedTableValues[i].contactId);
            	selectedContacts.push(selectedTableValues[i].contactId);
            }
            
            if (sendContactObjectsInEvent === true) {
                
                contactList.push({
                    "Id": selectedTableValues[i].contactId, "Name": selectedTableValues[i].contactName,
                    "sobjectType": "Contact"
                });
            }
        }
        
        if (selectedIds.length > 0) {
            component.set("v.selectedRows", selectedIds);


            //var contacts = component.get("v.selectedContacts");

            //contacts.push(selectedIds);


            component.set("v.selectedContacts", selectedContacts);
            
            component.set("v.contactList", contactList);
            // Contact Ids selected by the user
            component.showSpinner();
            var selectedContacts = component.get("v.selectedContacts");
            component.hideSpinner();

            var displaySuccessToast = component.get("v.displaySuccessToast");

            if (displaySuccessToast) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Success",
                    message: "Successfully added contacts to list.",
                    type: "success"
                });
                toastEvent.fire();
            }

            if (closeString == 'add') {
                var parametersEvent = component.getEvent("EventCallReportUpdateContactsEvent");
                parametersEvent.setParams({
                    "selectedContacts": selectedContacts,
                    "closeBrowseContacts": false,
                    "contactList": contactList
                });
                // Fire the event
                parametersEvent.fire();
                component.reset();
                component.resetDatatable();
                component.set("v.totalRecordCount", "0");
            } else if (closeString == 'close') {
                var parametersEvent = component.getEvent("EventCallReportUpdateContactsEvent");
                parametersEvent.setParams({
                    "selectedContacts": selectedContacts,
                    "closeBrowseContacts": true,
                    "contactList": contactList
                });
                // Fire the event
                parametersEvent.fire();
                component.reset();
                component.resetDatatable();
                component.set("v.totalRecordCount", "0");
            }
        }
        else {
            component.showToast();
        }
        //component.resetDatatable();    
        //component.set("v.totalRecordCount", "0");
        //this.searchRecentRecords(component);

    },

    createTable: function (component, newRecords) {
        if (newRecords !== "reset") {
            if (newRecords.length > 0) {
                component.showDatatable();
                component.set("v.contactColumn", [
                    { label: component.get("v.ContactName"), fieldName: "contactName", type: "text", initialWidth: 165, sortable: true },
                    { label: component.get("v.LocalLanguageName"), fieldName: "localLanguageName", type: "text", initialWidth: 165, sortable: true },
                    { label: component.get("v.Email"), fieldName: "contactEmail", type: "email", initialWidth: 200, sortable: true },
                    { label: component.get("v.AccountName"), fieldName: "contactAccountName", type: "text", initialWidth: 180, sortable: true },
                    { label: component.get("v.LegalEntity"), fieldName: "contactLegalEntity", type: "text", initialWidth: 195, sortable: true },
                    { label: component.get("v.Comment"), fieldName: "comment", type: "text", initialWidth: 100, sortable: true }
                ]);
                component.set("v.totalRecordCount", newRecords.length);

                //Sorts the records according to name 
                var sortRecords = newRecords;
                sortRecords.sort(function (a, b) {
                    if (a.contactName != '' && a.contactName != null && b.contactName != '' && b.contactName != null) {
                        var contactNameA = a.contactName.toLowerCase(), contactNameB = b.contactName.toLowerCase();
                        if (contactNameA < contactNameB)
                            return -1;
                        if (contactNameA > contactNameB)
                            return 1;

                        return 0;
                    }
                });
                /* For RowID
                for(var i = 0; i < sortRecords.length; i++)  {
                     sortRecords[i].rowId = i + 1;
                 }
                 */
                component.set("v.contactData", sortRecords);
            }
            else {
                component.displayError();
            }
        }
        else {
            component.set("v.contactColumn", [{}]);
            component.set("v.contactData", [{}]);
        }
    },

    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.contactData");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse));
        component.set("v.contactData", data);
    },

    sortBy: function (field, reverse, primer) {
        var key = primer ? function (x) { return primer(x[field]) } : function (x) { return x[field] };
        reverse = !reverse ? 1 : -1;
        if (field !== 'localLanguageName') {
            return function (a, b) {
                return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
            }
        }
        else {
            return function (a, b) {
                if (reverse === -1)
                    return key(a) === null ? 1 : key(b) === null ? -1 : reverse * key(a).localeCompare(key(b));
                else
                    return key(a) === null ? -1 : key(b) === null ? 1 : reverse * key(a).localeCompare(key(b));
            }
        }
    }
})