({	   
    searchRecords : function(component){    
        component.showSpinner();  
          
        var  windowHeight = window.innerHeight;      
        var dataHeight = windowHeight * 0.6;
        component.set('v.heightAttr', windowHeight - dataHeight);        
       
        var contactSearch = component.get("v.contact");
        var account = component.get("v.accountId");
        var selectedAddress = component.get("v.selectedAddress");       
       	var action = component.get("c.getContactData");
        action.setParams({
            "contactName" : contactSearch,
            "accountId" : account ,
            "selectedAddress" : selectedAddress
        });
        action.setStorable();
        action.setCallback(this, function(response){
            var state = response.getState();      
            component.hideSpinner();
            if(state === "SUCCESS"){                
            	var jsonString = JSON.parse(response.getReturnValue());               
                if(jsonString.length === 0){
                    //No result found for the search so display warninng message                    
                    component.displayError();                   
                }else{
                    //result found. display records in datatable
                    component.set("v.addDisabled", "false");
                    component.set("v.addCloseDisabled", "false");        			
                    component.set("v.hasWarning", "false"); 
                                        
                	this.filterRecords(component, jsonString, contactSearch);
                }
        	}
            else if(state === "ERROR"){
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log("Error message:" + errors[0].message);
                    }
                }else{
                    console.log("Unknown error");
                }                
            }   
        });           
        $A.enqueueAction(action);
    },
    
    //Below Method is used because we return 'All' contacts from server controller. but we need to display only records related to search string.
    filterRecords : function(component, jsonString, contactSearch){
        var newRecords = [];
        newRecords = jsonString;
        this.createTable(component, newRecords);
        
        /*Shield
        if(contactSearch){
            var jsonObj = jsonString;        
            var upperLocalName;
            var upperContactName;
            var upperContactEmail;
            var rows = 0;
            
            console.log(jsonString);            
            
            var filtered = jsonObj.filter(function(jsonObj){            
                var conName = jsonObj.contactName;                       
                var localName = jsonObj.localLanguageName;
                var searchName = contactSearch.toUpperCase();  
                var email = jsonObj.contactEmail;
                                
                upperContactName = conName ? conName.toUpperCase() : '';
                upperContactEmail = email ? email.toUpperCase() : '';
                upperLocalName = localName ? localName.toUpperCase() : '';           
                                              
                //Remove * when used in search string.
                if(contactSearch.includes('*'))
                    searchName = searchName.replace(/[\\*]/g,'');
                               
                if( !searchName.includes('@') ){
                    //User searches by name or local language name
                    if(searchName.includes("\r\n"))
                        searchName = searchName.replace("\r\n", "");
                   
                    //Split the search string and then use it to check whether it's include in name or localLanguageName
                    var splitName = searchName.split(" ");                                        
                   	var searchFlag = true; 
                    for(var i = 0; i<splitName.length; i++){
                        if(!upperContactName.includes(splitName[i]) && (upperLocalName && !upperLocalName.includes(splitName[i]))){
                            searchFlag = false;
                        	break;
                        } else if (!upperContactName.includes(splitName[i]) && !upperLocalName){
                            searchFlag = false;
                        	break;
                        }                    	
                    }
                    if(searchFlag){                        
                        newRecords.push(jsonObj);  
                    }                                        
                }
                else{
                    //User searches by emailId                  
                    newRecords.push(jsonObj);
                }                
            });                
            this.createTable(component, newRecords); 
    	}
        else{
            //Searched directly by account
            newRecords = jsonString;
            this.createTable(component, newRecords);
		}
        Shield*/
    },
    
    addData : function(component, closeClicked){        
        var tableCmp = component.find("contactTable");
        var selectedTableValues = tableCmp.getSelectedRows();
       	var selectedIds = []; 
        var closeString = closeClicked;
        
        for(var i=0; i<selectedTableValues.length; i++){
            if(selectedTableValues[i].contactId)
            	selectedIds.push(selectedTableValues[i].contactId);
        }                 
        if(selectedIds.length > 0){
            // Contact Ids selected by the user
            component.showSpinner();
            var action = component.get("c.insertCampaignMember");
            action.setParams({
                "campaignId" : component.get("v.campaignId"),               
                "contactList" : selectedIds            
            });            
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    component.hideSpinner();
                    var returnList = response.getReturnValue();
                    if(returnList === ''){                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: $A.get("$Label.c.Added"),
                            message: $A.get("$Label.c.Success_Message_Contact_Added_To_Contact_List"),
                            type: "success"
                        });
                        toastEvent.fire(); 
                        if(closeString === "close")
                            component.backClicked();
                        component.reset();
                    }
                    else{
                        // Some Error occurred while inserting records. so rerender the datatable with that records.
                        component.set("v.hasErrors", "true");                        
                        component.hideSpinner();
                        component.showDatatable();
                        var jsonString = JSON.parse(response.getReturnValue());
                        this.createTable(component, jsonString);                                               
                    }                    
                }
            });
            $A.enqueueAction(action);
        }
        else{
            component.showToast();
        }
    },
    
    createTable : function(component, newRecords){ 
        if(newRecords !== "reset"){
            if(newRecords.length > 0){                               
                component.showDatatable();                   
                console.log(newRecords);
                
                component.set("v.contactColumn", [            		
                            //{label: "", fieldName:"rowId", type:"number", initialWidth:10},
                            {label: component.get("v.ContactName"), fieldName:"contactName", type:"text",  sortable:true},
                            {label: component.get("v.LocalLanguageName"), fieldName:"localLanguageName", type:"text",  sortable:true},
                            {label: component.get("v.Email"), fieldName:"contactEmail", type:"email",  sortable:true},
                            {label: component.get("v.AccountName"), fieldName:"contactAccountName", type:"text",  sortable:true},
                    		{label: component.get("v.LegalEntity"), fieldName:"contactLegalEntity", type:"text", sortable:true},
                            {label: component.get("v.Comment"), fieldName:"comment", type:"text", sortable:true}                    
                        ]);     
               component.set("v.totalRecordCount", newRecords.length);
                
               //Sorts the records according to name 
               var sortRecords= newRecords;
               sortRecords.sort(function(a, b){
                   if(a.contactName != '' && a.contactName != null && b.contactName != '' && b.contactName != null){
                        var contactNameA = a.contactName.toLowerCase(), contactNameB = b.contactName.toLowerCase();
                        if(contactNameA < contactNameB)
                            return -1;
                        if(contactNameA > contactNameB)
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
            else{
                component.displayError();
            }
        }
        else{                       
            component.set("v.contactColumn", [{}]);
            component.set("v.contactData", [{}]);
        }
    },

    getAddresses : function(component){
        var accountIdSelected = component.get("v.accountId");       
        var action = component.get("c.getAddressesForAccount");         	
        action.setParams({
            "accountId" : accountIdSelected
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var responseData = response.getReturnValue();               
                var options = [];
                if(responseData.length > 0){
                    //generate address according to multiselect attributes
                    for(var i = 0; i < responseData.length; i++ )
                        options.push({ "value": responseData[i].value , "label" : responseData[i].label, 
                                       "icon" : responseData[i].icon, "metalabel" : responseData[i].metaLabel,
                                     	"selected" : false});
                	var addressCom = component.find("address");
                    addressCom.set("v.disabled", false);
                                       	
                }
                component.set("v.options", options);
                component.find("address").reInit();
                
            }else{
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message)
                        console.log("Error message-" + errors[0].message);                    
                }else
                        console.log("Unknown error");
            }
        });  
        $A.enqueueAction(action);
    },
    
    sortData : function(component, fieldName, sortDirection){       
        var data = component.get("v.contactData");        
        var reverse = sortDirection !== 'asc';         
        data.sort(this.sortBy(fieldName, reverse));
        component.set("v.contactData", data);
    },
    
    sortBy : function(field, reverse, primer){
       	var key = primer ? function(x){return primer(x[field])} : function(x){return x[field]};
        reverse = !reverse ? 1 : -1;  
        if(field !== 'localLanguageName' && field !== 'contactAccountName'){
            return function(a, b){
                return a =key(a), b = key(b), reverse * ((a > b) - (b > a));
            }
        }        
        else{
            return function(a, b){    
                if(reverse === -1)
            		return key(a) === null ? 1 : key(b) === null ? -1 : reverse * key(a).localeCompare(key(b));
                else 
                    return key(a) === null ? -1 : key(b) === null ? 1 : reverse * key(a).localeCompare(key(b));
            }           
        }
    }
})