({
    doInit: function(component, event, helper) {
		helper.showSpinner(component);
        //For detecting device				
        component.set('v.device', $A.get("$Browser.formFactor"));    
        var device = component.get('v.device');
        var accounts = component.get('v.accounts');
       
        component.set("v.listChanged", false);
        //if( accounts !== "")
        component.createFilterJSON(component);
        
        //Fetch Details
		helper.getContactListOtherDetails(component,{
            'device' : device   
        });
        var selectedContactListId = component.get("v.myContactListSelect");
        if(selectedContactListId != undefined && selectedContactListId != null && selectedContactListId != '1' ){
            helper.getMyContactLists(component, selectedContactListId, {
                'device' : device
            }, function(){
                 component.showMembers();
             });
        }
        else {            
            helper.getRecentList(component, {
                'device' : device
            });
            helper.getMyContactLists(component,null, {
                'device' : device
			});          
        }
        helper.hideSpinner(component);
        var sorter = component.find("sortComponent");
        sorter.sortDefaults();       
       
    },
        
    resetFilters : function(component, event, helper){                        
        component.set("v.accounts", null); 
      	component.set('v.selectedAddress', null);
    },
    
    showMembers: function(component,event,helper) {
    	var campaignId = component.find("myContactListSelect").get("v.value");
        var listChanged = component.get("v.listChanged");
        if(listChanged === true){
            component.resetFilters();                                
        }
        component.set("v.listChanged", true);
        
        if(campaignId == '1') {
            //recently viewed
            helper.getRecentList(component);
        } 
        else{
            
            //Reset Values for pageNumber
            component.set('v.pageNumber', 1);
            
            component.set('v.loading', false);
            
            //Blank out the listMembers data
        	component.emptyTableData();
            
            //Fetch Data
            component.getPageDataForMobile();        	
            
            //sam ,commented out to fix a bug , 3/4/2020
            //reset the sort arrow
            //component.sortArrow('name');

            
            //Unselect the header checkbox            
            component.find("selectAll").set("v.value", false);
            component.set("v.selectAllCheckboxValue", false);
           
           
		}           
	},
    
    emptyTableData : function(component, event, helper) {
        //Blank out the listMembers data
        component.set('v.listMembers', []);
    },
    
    getPageDataForMobile : function(component, event, helper){
        
       var renderedRows;
       if(component.get('v.pageNumber') === 1){      
            component.set('v.pageSize', 50); 
           	renderedRows = 50;
        }
        else{
           	component.set('v.pageSize', 50);
            renderedRows = component.get('v.listMembers').length;
        }
        
        helper.showSpinner(component);
        
        var campaignId = component.find("myContactListSelect").get("v.value");            
        
        //Fetch the Count of Campaign Members
        helper.getMemberCount(component, {
            'campaignId' : campaignId,            
            'filters' : component.get('v.filterJSON'),
            'device' : component.get('v.device')            
        });  
        
        
        component.createFilterJSON();        
        if(campaignId !== '1'){
            helper.getCampaignMemberForMobile(component,
                                     {
                                         'campaignId' : campaignId,
                                         'pageNumber' : component.get('v.pageNumber'),
                                         'pageSize' : component.get('v.pageSize'),                                         
                                         'renderedRows' : renderedRows,                                         
                                         'filters' : component.get("v.filterJSON")
                                     },
                                    function(resultData){
                                        var rows = component.get('v.listMembers');
                                        
                                        var resultArray = resultData;
                                        if(resultArray.length !== 0){
                                            for(var i = 0; i <resultArray.length; i++){
                                                var contactName = resultArray[i].name;                                               
                                                if(contactName.length > 40)
                                                    resultArray[i].name = contactName.substring(0,40);                                                    
                                            }      
                                            var loadDataFlag = component.get('v.loadDataFlag');
                                            
                                            if(loadDataFlag === false)
                                            	component.set('v.listMembers', resultArray);
                                            else
                                                component.set('v.listMembers', rows.concat(resultArray));
                                            
                                            component.set('v.loadDataFlag', false);
                                            
											var noRecordDiv = component.find('noRecordDiv');
                                            $A.util.addClass(noRecordDiv, 'slds-hide'); 
                                            helper.hideSpinner(component);
                                        }
                                        else{
                                            var noRecordDiv = component.find('noRecordDiv');
                                            $A.util.removeClass(noRecordDiv, 'slds-hide');
                                             helper.hideSpinner(component);
                                        }
                                    }
                                 );
        }
       
    },
    
    addCallReport : function(component, event, helper){
        var selectedContactIds = [];
        
        //If source list is Recently Viewed contacts then selectAllCheckboxValue should be false
        if(component.find("myContactListSelect").get("v.value") == '1'){
            component.set("v.selectAllCheckboxValue", false);
        }
        
        //Check whether SelectAll is Selected
        var isSelectedCheckBoxChecked = component.get("v.selectAllCheckboxValue");
        
        if(isSelectedCheckBoxChecked == true){
            //Check whether no. of selected contacts greater than 50 then do not allow user to create
            helper.getCampaignMembersForCampaignId(component,
                                                   {
                                                       'campaignId' : component.find("myContactListSelect").get("v.value")
                                                   },
                                                   function(resultData){                                                                                                           
                                                        var selectedContactId = resultData;
                                                         
                                                        component.seperateIdsForCallReport(selectedContactId);
                                                        var clientAttendees = component.get('v.clientAttendees');
            											var internalAttendees = component.get('v.internalAttendees');
                                                       
                                                       
                                                       if(resultData != null){
                                                           if(resultData.length > 50){                                                               
                                                               component.showMessage("Error",$A.get("$Label.c.Error_Message_for_Call_Report_from_Contact_List"),"error");                                                           	   
                                                           }
                                                           else if(resultData.length <= 50 && internalAttendees.length < 50){
                                                               var errorD = component.find('errorDiv');
                                                               $A.util.addClass('errorD', 'slds-hide');
                                                               
                                                               var navigationEvent = $A.get("e.force:navigateToComponent");
                                                               navigationEvent.setParams({
                                                                    componentDef : "c:EventCallReport",
                                                                    componentAttributes: {
                                                                        ClientAttendees : clientAttendees,
                                                                        InternalInviteesPreloaded : internalAttendees
                                                                    }
                                                               });
                                                               navigationEvent.fire();
                                                           }
                                                       }
                                                   })
        }
        else {
            //Get Selected Data
            var selectedContactData = [];
            component.getSelectedContacts(selectedContactData);
            var selectedData = selectedContactData['selectedContacts'];
           
            var clientAttendees = component.get('v.clientAttendees');
            var internalAttendees = component.get('v.internalAttendees');
           
            if(selectedData != null){
                if(selectedData.length > 50 ){
                    component.showMessage("Error",$A.get("$Label.c.Error_Message_for_Call_Report_from_Contact_List"),"error");
                }
                else if(selectedData.length <= 50 && internalAttendees.length < 50){                   
                    var navigationEvent = $A.get("e.force:navigateToComponent");
                    navigationEvent.setParams({
                        componentDef : "c:EventCallReport",
                        componentAttributes: {
                            ClientAttendees : clientAttendees,
                            InternalInviteesPreloaded : internalAttendees
                        }
                    });
                    navigationEvent.fire();
                }
                //error message if internal invitees are <= 50
            }
           
        }
        
    },
    
    loadData : function(component, event, helper){  
       	component.set('v.loadDataFlag', true);
        var pageNumber  = component.get('v.pageNumber');
        pageNumber++;
        component.set('v.pageNumber', pageNumber);
        component.getPageDataForMobile(component);               
    },
    
    
    
    showfilter : function(component, event, helper){
        var myContactListSelect = component.get('v.myContactListSelect');
        var navigationEvent = $A.get("e.force:navigateToComponent");
      
        navigationEvent.setParams({
            componentDef : "c:ContactListMobileFilters",
            componentAttributes : {
                'myContactListSelect' : myContactListSelect,                
                'rgAccountPreSelected' : component.get('v.accounts'),
                'adressesPreSelected' : component.get('v.selectedAddress')
            }
        });
        
        navigationEvent.fire();
    },
    
    hideShowMore : function(component, event, helper)    {
        var showMore = component.find("showMore");
        $A.util.addClass(showMore, "slds-hide");
    },
    
    showShowMore : function(component, event, helper)    {
        var showMore = component.find("showMore");
        $A.util.removeClass(showMore, "slds-hide");
    },    
        
    //----Start Select functions ----//
    rowSelectDeselect : function(component, event) {
        if(!event.getSource().get("v.value")){
            //If SelectAll is Checked then deselect it
            var isAllSelected = component.find("selectAll").get("v.value");
            if(isAllSelected){
                component.find("selectAll").set("v.value", false);
            }
        }
    },
    
    selectAll : function(component, event) {
    	var selectedHeaderCheck = event.getSource().get("v.value");
       	//Set the value of Select All
        component.set("v.selectAllCheckboxValue", selectedHeaderCheck);
        
        //Select or Deselect Rows
        component.setDataTableCheckboxValues(selectedHeaderCheck);
        
    },
    
    hideSelectAllCheckbox : function(component, event, helper)    {
        var selectAll = component.find("selectAll");
        $A.util.addClass(selectAll, "slds-hide");
    },
    
    showSelectAllCheckbox : function(component, event, helper)    {
        var selectAll = component.find("selectAll");
        $A.util.removeClass(selectAll, "slds-hide");
    },
    
    
    setDataTableCheckboxValues : function(component, event, helper){
        var headerCheckboxValue = false;
        var params = event.getParam('arguments');
        if(params){
            headerCheckboxValue = params.headerCheckboxValue;
        }
        
        var selectedItems = component.find("selectedContacts"); 
        
        if(selectedItems != undefined) {
            if(Array.isArray(selectedItems) && selectedItems.length != undefined){
                for (var i = 0; i < selectedItems.length; i++) 
                {
                    if (headerCheckboxValue === true) {
                        selectedItems[i].set("v.value",true);
                    }
                    else{
                        selectedItems[i].set("v.value",false);
                    }
                }
            }
            else {
                if (headerCheckboxValue === true) {
                    selectedItems.set("v.value",true);
                }
                else{
                    selectedItems.set("v.value",false);
                }
            }
        }
    },
    
    getSelectedContacts : function(component, event, helper){
        //Get Selected Contacts
        var selectedContactId = [];
        var getAllContactIds = component.find("selectedContacts");
        
        if(getAllContactIds != undefined && Array.isArray(getAllContactIds) && getAllContactIds.length != undefined){
            for(var i=0; i< getAllContactIds.length; i++){
                 if(getAllContactIds[i].get("v.value") == true){                   
                    selectedContactId.push(getAllContactIds[i].get("v.text"))
                 }
        	}
        }
        else if(getAllContactIds != undefined && !Array.isArray(getAllContactIds)){            
            selectedContactId.push(getAllContactIds.get("v.text"))
        }
        
        //to seperate client attendees and internal invitees
        component.seperateIdsForCallReport(selectedContactId);
        
        //Set Selected Contacts
        var params = event.getParam('arguments');
        if(params){
            params.selectedContacts['selectedContacts'] = selectedContactId;
        }
    },
    
    seperateIdsForCallReport : function(component, event, helper){
        var params = event.getParam('arguments');
        var selectedContactId;
        if(params){          
            selectedContactId = params.selectedContactId;
        }
        var listMembers = component.get("v.listMembers");
        var nomuraEmpIds = [];
        var internalAttendees = [];
        var clientAttendees = [];
     
        for(var i = 0; i < listMembers.length; i++){            
            if(listMembers[i].accountName === 'NOMURA EMPLOYEES (G)')
                nomuraEmpIds.push(listMembers[i].contactId);                
        }
        
        for(var j = 0; j < selectedContactId.length; j++){                    
            if(nomuraEmpIds.includes(selectedContactId[j]))
                internalAttendees.push(selectedContactId[j]);
            else
                clientAttendees.push(selectedContactId[j]);
        }
        if(internalAttendees.length > 0 && internalAttendees != null)
        	component.set('v.internalAttendees', internalAttendees);
        
        if(clientAttendees.length > 0  && clientAttendees != null)
        	component.set('v.clientAttendees', clientAttendees);
    },    
    //----End Select functions ----//
    
   //----Start Add functions ----//
    add : function(component,event) {
        var addItems = component.find("addItems");      
        $A.util.toggleClass(addItems, 'slds-is-open');
        
    },
    
    hideAddItems : function(component,event)
    {
        window.setTimeout($A.getCallback(function() {
            var addItems = component.find("addItems");
            $A.util.removeClass(addItems, 'slds-is-open');
        }), 150);   
    },
     //----End Add functions ----//
    
    
    //----Start Sorting functions ----//
    onCustomSort :function(component,event,helper) {        
        if(event.getParam("itemdata").length >= 1)
        {
            component.set("v.listMembers",event.getParam("itemdata"));
        }
    },

   //----End Sorting functions ----//    
    
    
    createFilterJSON : function(component, event, helper){
        var filters = new Object();   
        if(component.get("v.accounts") !== ''){
        	filters.rgAccount = component.get("v.accounts"); 
            if(component.get("v.selectedAddress")!== null && component.get("v.selectedAddress").length > 0)
				filters.rmAccount = component.get("v.selectedAddress");
            else
                filters.rmAccount = '';
        }
        else
            filters.rgAccount = ''; 
        filters.showNonCoveredContacts = false;
        console.log(JSON.stringify(filters));
        component.set("v.filterJSON", JSON.stringify(filters));
    },
    
   
})