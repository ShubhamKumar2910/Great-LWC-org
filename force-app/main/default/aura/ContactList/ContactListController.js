({
	doInit: function(component, event, helper) {
        
        //Set device         
        //component.set('v.device', 'PHONE'); //for testing
        component.set('v.device', $A.get("$Browser.formFactor"));
        var device = component.get('v.device');        
        console.log(component.get('v.device'));
        
		//Fetch Details	
		component.createFilterJSON();
        component.createSingleLookupJSON();
        
        helper.getContactListOtherDetails(
            component,
            {
            'device' : device   
            },
            function(){
                var selectedContactListId = component.get("v.myContactListSelect");
                
                if(selectedContactListId != undefined && selectedContactListId != null && selectedContactListId != '1'){
                    helper.getMyContactLists(
                        component, selectedContactListId, 
                        {
                            'device' : device
                        }, 
                        function(){
                            component.showMembers();
                        }
                    );
                }
                else {
                    helper.getMyContactLists(component,null, {
                        'device' : device
                    });  
                    helper.getRecentList(component, {
                        'device' : device
                    });  
                }
        
                //Fetch the Count of Campaign Members
                helper.getMemberCount(component, {
                    'campaignId' : selectedContactListId,
                    'filters' : component.get("v.filterJSON"),
                    'device' : device
                });
            }
        );
        
    },
    
    formRecordTemplates: function(component, event, helper){
        // Prepare a new record from template for Phone Book Campaign
        component.find("contactListCreator").getNewRecord(
            "Campaign", // sObject type (entityApiName)
            component.get("v.contactListOtherDetails.phoneBookRecordTypeId"),      // recordTypeId
            false,     // skip cache?
            $A.getCallback(function() {
                var rec = component.get("v.newContactList");
                var error = component.get("v.recordErrorForContactList");
                if(error || (rec === null)) {
                    console.log("Error initializing record template for Phone Book: " + error);
                    return;
                }
            })
        ); 
        
        // Prepare a new record from template for Contact Coverage Campaign
        component.find("contactCoverageListCreator").getNewRecord(
            "Campaign", 
            component.get("v.contactListOtherDetails.coverageRecordTypeId"),      
            false,     
            $A.getCallback(function() {
                var rec = component.get("v.newContactCoverageList");
                var error = component.get("v.recordErrorForContactCoverageList");
                if(error || (rec === null)) {
                    console.log("Error initializing record template for Contact Coverage: " + error);
                    return;
                }
            })
        ); 
        
        // Prepare a new record from template for Mass Email Campaign
        component.find("massEmailCreator").getNewRecord(
            "Campaign",
            component.get("v.contactListOtherDetails.massEmailRecordTypeId"),
            false,
            $A.getCallback(function() {
                var rec = component.get("v.newMassEmail");
                var error = component.get("v.recordErrorForMassEmail");
                if(error || (rec === null)) {
                    console.log("Error initializing record template for Mass Email: " + error);
                    return;
                }
            })
        ); 
        
    },
    
    handleMenuSelect : function(component, event, helper){

      var selectedMenuItemValue = event.getParam("value");  
      window.globalSelectedMenu = selectedMenuItemValue;
      
      if(selectedMenuItemValue == "newContactMenuItem"){
         //var strURL = '/003/e?';
         //component.openPage(strURL);
         component.handleCreateButtonClick();
      }
      else if(selectedMenuItemValue == "newContactListMenuItem"){
         component.openDialogForNewContactList();
      }
      else if(selectedMenuItemValue == "newContactCoverageMenuItem"){
      	 component.saveList();
      }
      else if(selectedMenuItemValue == "newMassEmailMenuItem"){
      	 component.openDialogForNewMassEmailWithValidation();
      }
      else if(selectedMenuItemValue == "newMassActivityMenuItem"){
         component.set("v.activityType", "Voicemail");
         component.openDialogForNewMassActivity();           
      }
      else if(selectedMenuItemValue == "newModelRequestMenuItem"){         
         component.set("v.activityType", "Model Request");
         component.openDialogForNewMassActivity(); 	        
      } 
        
      else if(selectedMenuItemValue == "newCallReportMenuItem"){
     	 component.navigateToPageForCallReport();
      }
      else if(selectedMenuItemValue == "addToContactListMenuItem"){
         component.openDialogForAddToList("Phone_Book");
      }
      else if(selectedMenuItemValue  == "addToContactCoverageListMenuItem"){
         component.openDialogForAddToList("Coverage");
      }
      else if(selectedMenuItemValue  == "addToMyContactCoverageListMenuItem"){
        helper.addContactToMyCoverageNContact(component);
      } 
      else if(selectedMenuItemValue == "addToMassEmailMenuItem"){
         component.openDialogForAddToList("Mass_Email");     
      }
      else if(selectedMenuItemValue == "addToMassActivityMenuItem"){
         component.set("v.activityType", "Voicemail");
         component.openDialogForAddToList("Voicemail");    
      }
      else if(selectedMenuItemValue == "addToModelRequestMenuItem"){         
         component.set("v.activityType", "Model Request") 
         component.openDialogForAddToList("Model_Request");        
      }          
      else if(selectedMenuItemValue == "searchAndAddContactsMenuItem"){
         component.navigateToPageForContactAddition();
      }
      else if(selectedMenuItemValue == "removeFromListMenuItem"){
         component.removeFromList();
      }
      else if(selectedMenuItemValue == "editListMenuItem"){
         component.openDialogForEditContactList();
      }
      else if(selectedMenuItemValue == "removeListMenuItem"){
         component.openDialogForDeleteContactList();
      } 
      else if(selectedMenuItemValue == "shareListMenuItem"){
         component.navigateToShareRecordPage();
      }   
    },
    handleCreateButtonClick : function(component, event, helper){
        //Open Contact Creation Page 
        var navigationEvent = $A.get("e.force:navigateToComponent");
           navigationEvent.setParams({
                componentDef : "c:NewContact",
                componentAttributes: {
                    origin : 'ContactList'
                }
        });
        navigationEvent.fire();
    },
    handleAddToButtonClick : function(component, event, helper){
        component.openDialogForAddToList("Phone_Book");
    },
    openDialogForNewContactList : function(component, event, helper){
        var modalTitle = $A.get("$Label.c.Contact_List"); 
        var confirmLabel = $A.get("$Label.c.Save"); 
        var closeLabel = $A.get("$Label.c.Cancel"); 
        var contactListNameLabel = $A.get("$Label.c.Contact_List_Name");
        
        //Reset the Name
        component.set("v.simpleNewContactList.Name",'');
        
        $A.createComponents([
            ["c:ModalDialog",{
                "aura:id" : "newContactListModal",
                "title" : modalTitle,
                "confirmLabel" : confirmLabel,
                "onConfirm" : component.getReference("c.saveList"),
                "confirmId" : "contactListCreator",
                "closeLabel" : closeLabel
            }],
            ["lightning:input",{
                "aura:id" : "contactListName",
                "name" : "contactListName",
                "label" : contactListNameLabel,
                "value" : component.getReference("v.simpleNewContactList.Name"),
                "maxlength" : 80,
                "placeholder" : "List Name",
                "required" : "true"
            }]
            ],
            function(components, status, errorMessage){
                if (status === "SUCCESS") {
                    var targetComponent = component.find("modalDialogPlaceHolder")
                    var body = targetComponent.get("v.body");
                    
                    var modalDialog = components[0];
                    var modalDialogBody = components[1];
                    modalDialog.set("v.body",modalDialogBody);
                    
                    body.push(modalDialog);
                    targetComponent.set("v.body",body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
		);
    },
    openDialogForNewMassEmailWithValidation : function(component, event, helper) {
		var params = event.getParam('arguments');
		if(params) {
			//get the campaign type
			var campaignRecordTypeName = params.campaignType;
            var strModalTitle;
            var strElementLabel;
			
			if(campaignRecordTypeName == "Mass_Email"){
                strModalTitle = $A.get("$Label.c.Contact_List_Mass_Email");
                strElementLabel = $A.get("$Label.c.Contact_List_Campaign_Name");    
            }
			
			//check if any of the records are selected from Contact List
			//Get Selected Data
            var selectedContactData = [];
            component.getSelectedContacts(selectedContactData);
            var selectedData = selectedContactData['selectedContacts'];
            
            if(selectedData != undefined && selectedData.length > 0){
				// open dialog for adding name and then save
				var modalTitle = $A.get("$Label.c.Contact_List_Mass_Email"); 
				var confirmLabel = $A.get("$Label.c.Next"); 
				var closeLabel = $A.get("$Label.c.Cancel"); 
				var campaignNameLabel = $A.get("$Label.c.Contact_List_Mass_Email_Subject");
				
				component.set("v.simpleNewMassEmail.Name",'');
				$A.createComponents([
				["c:ModalDialog",{
					"aura:id" : "newMassEmailModal",
					"title" : modalTitle,
					"confirmLabel" : confirmLabel,
					"onConfirm" : component.getReference("c.saveList"),
					"confirmId" : "massEmailCreator",
					"closeLabel" : closeLabel
				}],
				["lightning:input",{
					"aura:id" : "campaignNameForMassEmail",
					"name" : "campaignNameForMassEmail",
					"label" : campaignNameLabel,
					"value" : component.getReference("v.simpleNewMassEmail.Name"),
					"maxlength" : 80,
					"placeholder" : "Subject",
					"required" : "true"
				}]
				],
				function(components, status, errorMessage){
					if (status === "SUCCESS") {
						var targetComponent = component.find("modalDialogPlaceHolder")
						var body = targetComponent.get("v.body");
						
						var modalDialog = components[0];
						var modalDialogBody = components[1];
						modalDialog.set("v.body",modalDialogBody);
						
						body.push(modalDialog);
						targetComponent.set("v.body",body);
					}
					else if (status === "INCOMPLETE") {
						console.log("No response from server or client is offline.")
					}
					else if (status === "ERROR") {
						console.log("Error: " + errorMessage);
					}
				}
			);

			}
			else {
				component.showMessage($A.get("$Label.c.Error"),$A.get("$Label.c.Error_Message_Select_Contact"),"error");
			}
		}
	},
    openDialogForNewMassEmail : function(component, event, helper){
        var modalTitle = $A.get("$Label.c.Contact_List_Mass_Email"); 
        var confirmLabel = $A.get("$Label.c.Save"); 
        var closeLabel = $A.get("$Label.c.Cancel"); 
        var campaignNameLabel = $A.get("$Label.c.Contact_List_Campaign_Name");
        
        //Reset the Name
        component.set("v.simpleNewMassEmail.Name",'');
        
        $A.createComponents([
            ["c:ModalDialog",{
                "aura:id" : "newMassEmailModal",
                "title" : modalTitle,
                "confirmLabel" : confirmLabel,
                "onConfirm" : component.getReference("c.saveList"),
                "confirmId" : "massEmailCreator",
                "closeLabel" : closeLabel
            }],
            ["lightning:input",{
                "aura:id" : "campaignNameForMassEmail",
                "name" : "campaignNameForMassEmail",
                "label" : campaignNameLabel,
                "value" : component.getReference("v.simpleNewMassEmail.Name"),
                "maxlength" : 80,
                "placeholder" : "Name",
                "required" : "true"
            }]
            ],
            function(components, status, errorMessage){
                if (status === "SUCCESS") {
                    var targetComponent = component.find("modalDialogPlaceHolder")
                    var body = targetComponent.get("v.body");
                    
                    var modalDialog = components[0];
                    var modalDialogBody = components[1];
                    modalDialog.set("v.body",modalDialogBody);
                    
                    body.push(modalDialog);
                    targetComponent.set("v.body",body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
		);
    },
    openDialogForNewMassActivity : function(component, event, helper){
       
        var selectedMassActivityId = component.get("v.selectedListsForAddToList");
        
        
        //If source list is Recently Viewed contacts then selectAllCheckboxValue should be false
        if(component.find("myContactListSelect").get("v.value") == '1'){
            component.set("v.selectAllCheckboxValue", false);
        }
        
        //Check whether SelectAll is Selected
        var isSelectedCheckBoxChecked = component.get("v.selectAllCheckboxValue");
                                                
        //Get Selected Contact Data
        var selectedContactData = [];
        component.getSelectedContacts(selectedContactData);
        var selectedData = selectedContactData['selectedContacts'];
        
        //For Already Existing Mass Activity
        if(selectedMassActivityId != undefined && selectedMassActivityId != null && selectedMassActivityId != ''){
            component.navigateToActivity(selectedData);           
        }
        else { //For New Mass Activity
            if(isSelectedCheckBoxChecked == true){
                //Check whether no. of selected contacts less than 50 then do not allow user to create
                helper.getCampaignMembersForCampaignId(
                    component,
                    {
                        'campaignId' : component.find("myContactListSelect").get("v.value"),
                        'filters' : component.get("v.filterJSON")
                    },
                    function(resultData){
                        if(resultData != null){
                            if(resultData.length < 50){
                                if(component.get("v.activityType") === "Voicemail")
                                	component.showMessage($A.get("$Label.c.Error"),$A.get("$Label.c.Error_Message_for_Mass_Activity_from_Contact_List"),"error");
                                else
                                    component.showMessage($A.get("$Label.c.Error"),$A.get("$Label.c.Error_Message_for_Model_Request_from_Contact_List"),"error");
                            }
                            else if(resultData.length >= 50){
                                component.navigateToActivity(selectedData);                               
                            }
                        }
                    })
            }
            else {
                
                if(selectedData != null){
                    if(selectedData.length < 50){
                        if(component.get("v.activityType") === "Voicemail")
                            component.showMessage($A.get("$Label.c.Error"),$A.get("$Label.c.Error_Message_for_Mass_Activity_from_Contact_List"),"error");
                        else
                            component.showMessage($A.get("$Label.c.Error"),$A.get("$Label.c.Error_Message_for_Model_Request_from_Contact_List"),"error");
                    }
                    else if(selectedData.length >= 50){
                        component.navigateToActivity(selectedData);                        
                    }
                }
            }
        }
    },

    navigateToActivity : function(component, event, helper){
        
        var params = event.getParam('arguments');
        var selectedData;
        if(params){
            selectedData = params.selectedData;
        }
        var selectedContactListId = component.find("myContactListSelect").get("v.value");
        var selectedMassActivityId = component.get("v.selectedListsForAddToList");
        var selectedCampaignId = component.get("v.campaignId");
        var callingComponent = 'ContactList';
        component.createFilterJSON();		
        var activityType = component.get("v.activityType");
        //Check whether SelectAll is Selected
        var isSelectedCheckBoxChecked = component.get("v.selectAllCheckboxValue");
        
        //Navigation Event
        var navigationEvent = $A.get("e.force:navigateToComponent");
        
        navigationEvent.setParams({
                            componentDef : "c:Activity",
                            componentAttributes: {
                                campaignId : selectedCampaignId,
                                activityId : selectedMassActivityId,
                                selectedContactData : selectedData,                
                                myContactListSelect : selectedContactListId,
                                selectAllCheckboxValue : isSelectedCheckBoxChecked,
                                calledFrom : callingComponent,
                                activityType : activityType,
                                filters : component.get("v.filterJSON")
                            },
                            isredirect : true
                        });
                        
                        navigationEvent.fire();		
    },
    
    
    openDialogForAddToList : function(component, event, helper){
        var params = event.getParam('arguments');
        if(params){
            //Fetch Campaign Type
            var campaignTypeName = params.campaignType;
            var strModalTitle;
            var strElementLabel;
            
            if(campaignTypeName == "Phone_Book"){
                strModalTitle = $A.get("$Label.c.Contact_List");
                strElementLabel = $A.get("$Label.c.Contact_List_Name");    
            }
            else if(campaignTypeName == "Coverage"){
                strModalTitle = $A.get("$Label.c.Contact_List_Add_Contact_Coverage_for");
                strElementLabel = $A.get("$Label.c.Contact_List_Name");    
            }
            else if(campaignTypeName == "Mass_Email"){
                strModalTitle = $A.get("$Label.c.Contact_List_Mass_Email");
                strElementLabel = $A.get("$Label.c.Contact_List_Campaign_Name");    
            }
            else if(campaignTypeName == "Voicemail"){
                strModalTitle = $A.get("$Label.c.Contact_List_Mass_Activity");
                strElementLabel = $A.get("$Label.c.Contact_List_Campaign_Name");     
            }
            else if(campaignTypeName == "Model_Request"){
				strModalTitle = $A.get("$Label.c.Contact_List_Model_Request");
                strElementLabel = $A.get("$Label.c.Contact_List_Model_Request");  
            }
            
            //Get Selected Data
            var selectedContactData = [];
            component.getSelectedContacts(selectedContactData);
            var selectedData = selectedContactData['selectedContacts'];
            
            if((selectedData != undefined && selectedData.length > 0) || (campaignTypeName == "Mass_Email")){
                //Fetch Contact Lists
                if(campaignTypeName != 'Voicemail' && campaignTypeName != 'Model_Request'){
                    console.log('campaignTypeName : '+campaignTypeName);
                    console.log('campaignId : '+component.find("myContactListSelect").get("v.value"));
                    console.log(selectedData);
                    helper.getLists(
                        component,
                        {
                            'campaignTypeName' : campaignTypeName,
                            'campaignId' : component.find("myContactListSelect").get("v.value")
                        },
                        function(resultData){
                           console.log(resultData); 
                            if(!$A.util.isUndefined(resultData)){                               
                                //Set Options
                                var optionsArray = [];
                                for(var i=0; i<resultData.length; i++){
                                    optionsArray.push({"class": "optionClass", "label": resultData[i].Name, "value": resultData[i].Id})
                                }
                                component.set("v.listOptions",optionsArray); 
                                //Form Dialog
                                if(campaignTypeName == "Voicemail"){
                                    component.formDialogForEditMassActivity(strModalTitle);
                                }
                                else if(campaignTypeName != "Mass_Email" || selectedData.length > 0) {
                                    component.formDialogForAddToCampaign(strModalTitle);
                                }
                                else {                                   
                                    component.formDialogForAddToCampaign(strModalTitle);
                                }
                                
                            }
                        }
                    );
                }
                else
                    component.massActivityDetails(strModalTitle);
            }
             else {
                 //will get executed when no contact is selected from ContactList
                if(campaignTypeName == "Voicemail"){                   
                    component.massActivityDetails(strModalTitle);
                }
                else if(campaignTypeName == "Model_Request"){                     
                    component.massActivityDetails(strModalTitle);                   
                }
                else{
                   component.showMessage($A.get("$Label.c.Error"),$A.get("$Label.c.Error_Message_Select_Contact"),"error");                   
                }
            }
        }
    },
    
    
    massActivityDetails : function(component, event, helper){
        var params = event.getParam('arguments');
        if(params){
            //Reset the selected lists
            component.set("v.selectedListsForAddToList", null);
            //Form Dialog
            var strModalTitle = params.modalTitleLabel;
            var campaignRecordTypeName = params.campaignRecordTypeName;           
            var activityType = component.get("v.activityType");
            
            //for mass voicemail
            helper.getMassActivityList(
                component,
                {                   
                    'activityType' : activityType
                },
                function(resultData){
                    if(!$A.util.isUndefined(resultData)){
                        //Set Options
                        var optionsArray = [];
                        
                        for(var i=0; i<resultData.length; i++){                                
                            optionsArray.push({"eventId": resultData[i].Id , "campaignId" : resultData[i].What.Id ,"campaignName": resultData[i].What.Name, "startDate": resultData[i].StartDateTime})
                        }
                        if(optionsArray.length === 0)
                            component.set("v.massActivityCount", "0");
                        else
                            component.set("v.massActivityCount", optionsArray.length);
                        
                        component.set("v.listOptions",optionsArray); 
                        //Form Dialog                           		
                        component.formDialogForEditMassActivity(strModalTitle);
                    }
                }
            );                       
        }
    },
    
    navigateToEditListMassActivity : function(component, event, helper) {
        var massActivityObj =component.get("v.tableComponent");
        var selectedEventRow = massActivityObj.getSelectedRows();
        
        if(selectedEventRow.length === 1){
            component.set("v.selectedListsForAddToList", selectedEventRow[0].eventId);
            component.set("v.campaignId", selectedEventRow[0].campaignId);
            component.openDialogForNewMassActivity(component.get("v.selectedListsForAddToList"));
        }
        
    },
    
    
    formDialogForEditMassActivity: function(component, event, helper) {
        var params = event.getParam('arguments');
        if(params){
            //Reset the selected lists
            component.set("v.selectedListsForAddToList", null);
            //Form Dialog
            var modalTitle = params.modalTitleLabel;
            var elementLabel = params.elementLabel;
            
            var confirmLabel = $A.get("$Label.c.Edit"); 
            var closeLabel = $A.get("$Label.c.Cancel"); 
             
            
            
            component.set("v.massActivityColumn", [
    			{label:"Name", fieldName:"campaignName", type:"text", initialWidth:415},
                {label:"Start Date", fieldName:"startDate", type:"date", typeAttributes: { day : "2-digit", month : "2-digit", year : "numeric" }, initialWidth:158}
            ]);
                
            $A.createComponents([
                ["c:ModalDialog",{
                    "aura:id" : "addToListModal",
                    "title" : modalTitle,
                    "confirmLabel" : confirmLabel,
                    "onConfirm" : component.getReference("c.navigateToEditListMassActivity"),
                    "closeLabel" : closeLabel
                }],
                ["ui:outputText",{
                    "aura:id" : "countLabelForMassVoicemail",
                    "value" : "Recent " + component.get("v.activityType") + " : "
                }],
                ["ui:outputText",{
                    "aura:id" : "countForMassVoicemail",
                    "value" : component.get("v.massActivityCount")
                }],  
                ["lightning:datatable",{
                    "aura:id" : "campaignTable",
                    "data" : component.get("v.listOptions"),
                    "columns" : component.get("v.massActivityColumn"),
                    "keyField" : "id",
                    "minColumnWidth" : "100px",
                    "maxColumnWidth" : "800px",
                    "maxRowSelection" : "1"
                }]                        
                ],
                function(components, status, errorMessage){
                        if (status === "SUCCESS") {
                        
                        component.set("v.massActivityData", component.get("v.listOptions"));
           			 	component.set("v.massActivityColumn", component.get("v.massActivityColumn"));            
                            
                        var targetComponent = component.find("modalDialogPlaceHolder")
                        var body = targetComponent.get("v.body");
                        
                        var modalDialog = components[0];
                            
                        var modalDialogBody = [];
                        for(var i = 1; i < components.length; i++)    
                            modalDialogBody.push(components[i]);
                            
                        modalDialog.set("v.body",modalDialogBody);
                        
                        body.push(modalDialog);
                        targetComponent.set("v.body",body);  
                            
                        
                        component.set("v.tableComponent", components[3]);
                    }
                    else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.")
                    }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                    }           
                }
            	);
        }
    },
    
    navigateToEditListCampaign : function(component, event, helper) {
        //Remove Modal Dialog
        component.find("modalDialogPlaceHolder").set("v.body",[]);
        
        var selectedTargetList = component.get("v.selectedListsForAddToList");
        if(selectedTargetList != undefined && selectedTargetList != null){
        	//Selected Target Lists
            var selectedCampaignArr = selectedTargetList.split(";");
            if(selectedCampaignArr.length > 1){
                component.showMessage($A.get("$Label.c.Error"),$A.get("$Label.c.Error_Message_More_Than_One_Selection"),"error");
            }
            else if(selectedCampaignArr.length == 0 || (selectedCampaignArr.length == 1 && selectedCampaignArr == '')){
                component.showMessage($A.get("$Label.c.Error"),$A.get("$Label.c.Error_Message_Select_Mass_Email"),"error");
            }
            else {
                component.navigateToRecord(selectedTargetList);
            }
        }
        
        
    },
    
    formDialogForEditCampaign: function(component, event, helper) {
        var params = event.getParam('arguments');
        if(params){
            //Reset the selected lists
            component.set("v.selectedListsForAddToList", null);
            
            //Form Dialog
            var modalTitle = params.modalTitleLabel;
            var elementLabel = params.elementLabel;
            
            var confirmLabel = $A.get("$Label.c.Edit"); 
            var closeLabel = $A.get("$Label.c.Cancel"); 
            
            $A.createComponents([
                ["c:ModalDialog",{
                    "aura:id" : "addToListModal",
                    "title" : modalTitle,
                    "confirmLabel" : confirmLabel,
                    "onConfirm" : component.getReference("c.navigateToEditListCampaign"),
                    "closeLabel" : closeLabel
                }],
                ["ui:inputSelect",{
                    "aura:id" : "addToCampaign",
                    "name" : "addToCampaign",
                    "label" : elementLabel,
                    "multiple" : true,
                    "size" : 8,
                    "required" : "true",
                    "class" : "dynamic selectInputElementClass",
                    "value" : component.getReference("v.selectedListsForAddToList")
                }]
                ],
                function(components, status, errorMessage){
                    if (status === "SUCCESS") {
                        var targetComponent = component.find("modalDialogPlaceHolder")
                        var body = targetComponent.get("v.body");
                        
                        var modalDialog = components[0];
                        var modalDialogBody = components[1];
                        
                        //Setting Options
                        components[1].set("v.options", component.get("v.listOptions"));
                        
                        modalDialog.set("v.body",modalDialogBody);
                        
                        body.push(modalDialog);
                        targetComponent.set("v.body",body);
                    }
                    else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.")
                    }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                    }
                }
            );
        }
    },
    formDialogForAddToCampaign: function(component, event, helper) {
        var params = event.getParam('arguments');
        if(params){
            //Reset the selected lists
            component.set("v.selectedListsForAddToList", null);
            
            //Form Dialog
            var modalTitle = params.modalTitleLabel;
            var elementLabel = params.elementLabel;
            
            var confirmLabel = $A.get("$Label.c.Add"); 
            var closeLabel = $A.get("$Label.c.Cancel"); 
            
            $A.createComponents([
                ["c:ModalDialog",{
                    "aura:id" : "addToListModal",
                    "title" : modalTitle,
                    "confirmLabel" : confirmLabel,
                    "onConfirm" : component.getReference("c.addToList"),
                    "closeLabel" : closeLabel
                }],
                ["ui:inputSelect",{
                    "aura:id" : "addToCampaign",
                    "name" : "addToCampaign",
                    "label" : elementLabel,
                    "multiple" : true,
                    "size" : "8",
                    "required" : "true",
                    "class" : "dynamic selectInputElementClass ",
                    "value" : component.getReference("v.selectedListsForAddToList")
                }]
                ],
                function(components, status, errorMessage){
                    if (status === "SUCCESS") {
                        var targetComponent = component.find("modalDialogPlaceHolder")
                        var body = targetComponent.get("v.body");
                        
                        var modalDialog = components[0];
                        var modalDialogBody = components[1];
                        
                        //Setting Options
                        components[1].set("v.options", component.get("v.listOptions"));
                        
                        modalDialog.set("v.body",modalDialogBody);
                        
                        body.push(modalDialog);
                        targetComponent.set("v.body",body);
                    }
                    else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.")
                    }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                    }
                }
            );
        }
    },
    openDialogForEditContactList : function(component, event, helper){
        var modalTitle = $A.get("$Label.c.Contact_List_Edit_List"); 
        var confirmLabel = $A.get("$Label.c.Save"); 
        var closeLabel = $A.get("$Label.c.Cancel"); 
        var contactListNameLabel = $A.get("$Label.c.Contact_List_Name");
        
        //Reload the record for Edit
        var tempRecord = component.find("contactListEdit"); 
        tempRecord.set("v.recordId", component.get("v.editContactListRecordId")); 
        tempRecord.reloadRecord(); 
        
        $A.createComponents([
            ["c:ModalDialog",{
                "aura:id" : "editContactListModal",
                "title" : modalTitle,
                "confirmLabel" : confirmLabel,
                "onConfirm" : component.getReference("c.saveList"),
                "confirmId" : "contactListEdit",
                "closeLabel" : closeLabel
            }],
            ["lightning:input",{
                "aura:id" : "contactListName",
                "name" : "contactListName",
                "label" : contactListNameLabel,
                "value" : component.getReference("v.simpleEditContactList.Name"),
                "maxlength" : 80,
                "required" : "true"
            }]
            ],
            function(components, status, errorMessage){
                if (status === "SUCCESS") {
                    var targetComponent = component.find("modalDialogPlaceHolder")
                    var body = targetComponent.get("v.body");
                    
                    var modalDialog = components[0];
                    var modalDialogBody = components[1];
                    modalDialog.set("v.body",modalDialogBody);
                    
                    body.push(modalDialog);
                    targetComponent.set("v.body",body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
		);
    },
    openDialogForDeleteContactList : function(component, event, helper){
        var modalTitle = $A.get("$Label.c.Contact_List_Remove_List"); 
        var confirmLabel = $A.get("$Label.c.Confirmation_Yes"); 
        var closeLabel = $A.get("$Label.c.Cancel"); 
        var warningMsg = $A.get("$Label.c.Delete_Confirmation");
        $A.createComponents([
            ["c:ModalDialog",{
                "aura:id" : "deleteContactListModal",
                "title" : modalTitle,
                "confirmLabel" : confirmLabel,
                "onConfirm" : component.getReference("c.deleteList"),
                "confirmId" : "contactListDelete",
                "closeLabel" : closeLabel
            }],
            ["ui:outputText",{
                "aura:id" : "deleteConfirmationLabel",
                "value" : warningMsg,
                "class" : "slds-form-element__label"
            }]
            ],
            function(components, status, errorMessage){
                if (status === "SUCCESS") {
                    var targetComponent = component.find("modalDialogPlaceHolder")
                    var body = targetComponent.get("v.body");
                    
                    var modalDialog = components[0];
                    var modalDialogBody = components[1];
                    modalDialog.set("v.body",modalDialogBody);
                    
                    body.push(modalDialog);
                    targetComponent.set("v.body",body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
		);
    },
    
    addToList: function(component, event, helper){
        //For New Lists
        var campaignId = null;
        var campaignType = null;
        if(typeof event.getParam != 'undefined'){
            var params = event.getParam('arguments');
            if(params){
                if(params.campaignId != undefined){
                    campaignId = params.campaignId;
                }
                if(params.campaignType != undefined){
                    campaignType = params.campaignType;
                }
            }
        }
       
        //Remove Modal Dialog
        component.find("modalDialogPlaceHolder").set("v.body",[]);
        
        var selectedTargetList = component.get("v.selectedListsForAddToList");
        if(selectedTargetList != undefined && selectedTargetList != null){
            //Selected Target Lists
            var selectedCampaignArr = selectedTargetList.split(";");
            if(selectedCampaignArr.length == 0 || (selectedCampaignArr.length == 1 && selectedCampaignArr == '')){
                component.showMessage($A.get("$Label.c.Error"),$A.get("$Label.c.Error_Message_Select_Add_To"),"error");
            }
            else {
                //If source list is Recently Viewed contacts then selectAllCheckboxValue should be false
                if(component.find("myContactListSelect").get("v.value") == '1'){
                    component.set("v.selectAllCheckboxValue", false);
                }
                
                //Selected List Members - Used only when isAllSelected is false
                var selectedContactData = [];
                component.getSelectedContacts(selectedContactData);
                var selectedContacts = selectedContactData['selectedContacts'];
                
                
                //Show Spinner
                helper.showSpinner(component);
                component.createFilterJSON();
                
                //Call Helper to save members
                helper.addCampaignMembersToList(
                    component,
                    {
                        'completeListSelected' : component.get("v.selectAllCheckboxValue"),
                        'sourceCampaignId' : component.find("myContactListSelect").get("v.value"),
                        'targetCampaignList' : selectedCampaignArr,
                        'selectedContacts' : selectedContacts,
                        'filters' : component.get("v.filterJSON")
                    },
                    function(resultData){
                        //Reset the selected lists
                        component.set("v.selectedListsForAddToList", null);
                        helper.hideSpinner(component);
                        //Success
                        if(resultData != undefined && resultData.length == 0){
                            //Hide Spinner
                            helper.hideSpinner(component);                            
                            console.log(resultData);                            
                            //Unselect the header checkbox
                            component.set("v.selectAllCheckboxValue", false);
                            component.setDataTableCheckboxValues(false);
                            
                            //If Called from New Button Menu
                            if(campaignId != null){
                                helper.getContactListOtherDetails(component,{
                                    'device' : component.get('v.device')   
                                });
                                
                                //Load Contact Lists or redirect to Campaign Page
                                if(campaignType == "contactListCreator" || campaignType == "contactCoverageListCreator"){ 
                                    helper.getMyContactLists(component, campaignId, {
                                            'device' : component.get('v.device')
                                        }, function(){
                                             component.showMembers();
                                     });
                                }
                                else if(campaignType == "massEmailCreator"){ 
                                    component.navigateToRecord(campaignId);
                                }
                                
                                //Show Success Message
                                if(campaignType != "massEmailCreator"){
                                    component.showMessage($A.get("$Label.c.Created"),$A.get("$Label.c.Create_Success_Message"),"success");
                                }
                            }
                            else if(globalSelectedMenu == "addToMassEmailMenuItem") {
                                component.navigateToRecord(selectedTargetList);
                            }
                                else {
                                    //Show Success Message
                                    component.showMessage($A.get("$Label.c.Created"),$A.get("$Label.c.Create_Success_Message"),"success");
                                }
                            
                            
                        }                        
                    },
                    function(resultData){                       
                        //Reset the selected lists
                        component.set("v.selectedListsForAddToList", null);
                        helper.hideSpinner(component);
                        //Failure
                        if(resultData != undefined){                           
                            console.log(resultData);
                            
                            var error = resultData;                             
                            if(error[0].message.includes('server error')){
                                component.showMessage($A.get("$Label.c.Error"),$A.get("$Label.c.Error_Message_Contact_List_Limit_Exceeded"),"error");
                            }
                    	}
                    }
                );                
            }
            
            
        }
    },
    
    resetFilters : function(component, event, helper){                
        component.find("accounts").reset();
        component.set("v.rgAccount", "");     
        
        component.find("contact").reset();
        component.set("v.contactIdFiltered", ""); 
        
        component.set("v.notCoveredContactFilter", false);
    },
    
    
    showMembers: function(component,event,helper) {        
        var listChanged = component.get("v.listChanged");
        var device = component.get('v.device');
        
        if(listChanged === true){
            component.resetFilters();                                
        }
        component.set("v.listChanged", true);
        
    	var campaignId = component.find("myContactListSelect").get("v.value");
        component.createFilterJSON();
        component.createSingleLookupJSON();
        
        //Fetch the Count of Campaign Members
        helper.getMemberCount(component, {
            'campaignId' : campaignId,
            'filters' : component.get("v.filterJSON"),
            'device' : device
        });
        
        //Set the Default Contact List Settings
        helper.setDefaultContactListSettings(component, {
            'campaignId' : campaignId
        });
        
        if(campaignId == '1') {
            //recently viewed
            helper.getRecentList(component, {
                'device' : device
            });  
        } 
        else{
            //Fetch the CampaignAccessLevel
            helper.getCampaignAccessLevel(component, {
                'campaignId' : campaignId
            });
            
           	
            
        	//Blank out the listMembers data
            component.emptyTableData();
            
            //Reset Values for pageNumber
            component.set('v.pageNumber', 1);
            
            component.set('v.loading', false);            
            
            //Fetch Data
            component.getPageData('pagination');        	
           
            //Unselect the header checkbox
            component.find("selectAll").set("v.value", false);
            component.set("v.selectAllCheckboxValue", false);
            
            //Set the recordId for Edit and Delete
        	component.set("v.editContactListRecordId", campaignId);
            //component.set("v.deleteContactListRecordId", campaignId);
            
            //Reload the record for Edit
        	var tempRecord = component.find("contactListEdit"); 
        	tempRecord.set("v.recordId", component.get("v.editContactListRecordId")); 
        	tempRecord.reloadRecord(); 
            
            //Reload the record for Delete
        	/*var tempRecordForDeletion = component.find("contactListDelete"); 
        	tempRecordForDeletion.set("v.recordId", component.get("v.deleteContactListRecordId")); 
            tempRecordForDeletion.reloadRecord();*/
            
            
        }
	},
    
    goToEdit: function(component,event) {        
        var target = event.getSource(); 
		var recordId = target.get("v.value") ;
        var editRecordEvent = $A.get("e.force:editRecord");
    	editRecordEvent.setParams({
         		"recordId": recordId
   		});
    	editRecordEvent.fire();
    },
    goToRecord: function(component,event) {        
        var target = event.getSource(); 
		var recordId = target.get("v.value") ;
        var navigationEvent = $A.get("e.force:navigateToSObject");
    	navigationEvent.setParams({
         		"recordId": recordId
   		});
    	navigationEvent.fire();
    },
    redirectToRecord: function(component,event) {        
        var recordId = event.target.getAttribute('data-index');
		var navigationEvent = $A.get("e.force:navigateToSObject");
    	navigationEvent.setParams({
         		"recordId": recordId
   		});
    	navigationEvent.fire();
    },
    selectAll : function(component, event) {
    	var selectedHeaderCheck = event.getSource().get("v.value");
        
        //Set the value of Select All
        component.set("v.selectAllCheckboxValue", selectedHeaderCheck);
        
        //Select or Deselect Rows
        component.setDataTableCheckboxValues(selectedHeaderCheck);
        
    },
    rowSelectDeselect : function(component, event) {
        if(!event.getSource().get("v.value")){
            //If SelectAll is Checked then deselect it
            var isAllSelected = component.find("selectAll").get("v.value");
            if(isAllSelected){
                component.find("selectAll").set("v.value", false);
            }
        }
    },
    saveList : function(component, event, helper) {
		var creatorType = ""
        var device = component.get('v.device');
        var item = event.currentTarget;
        if(item && item.dataset){
            creatorType =  item.dataset.index;
        }
        //For Contact Coverage as we are not opening modal window for this
        if(creatorType == ""){
            if(event.getEventType() != undefined && event.getEventType() == "COMPONENT"){
                creatorType = "contactCoverageListCreator";
            }
        }
        //For Contact Coverage, set the name and IsActive parameters
        if(creatorType === "contactCoverageListCreator"){
            var contactCoverageListName = component.get("v.contactListOtherDetails.userName") + " Coverage";
            component.set("v.simpleNewContactCoverageList.Name", contactCoverageListName);
            component.set("v.simpleNewContactCoverageList.IsActive", true);
        }
        
        // save list
        component.find(creatorType).saveRecord(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                // record is saved successfully
                var savedResultId = saveResult.recordId;
                console.log('saveResult.recordId:'+savedResultId);
                
                //Remove Modal Dialog
                component.find("modalDialogPlaceHolder").set("v.body",[]);
                
                //For Adding Members
                if(creatorType != "contactListEdit"){
                    component.set("v.selectedListsForAddToList", savedResultId);
                	component.addToList(savedResultId, creatorType);
                }
                else { //In case of Edit List Name
                    component.showMessage($A.get("$Label.c.Saved_Successfully"),$A.get("$Label.c.Saved_Successfully"),"success");
                    
                    //Load Details
                    helper.getContactListOtherDetails(component,{
                        'device' : device   
                    });
                    helper.getMyContactLists(component, savedResultId, {
                        'device' : device
                    });          
                    
                }
                
            } else if (saveResult.state === "INCOMPLETE") {
                // handle the incomplete state
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                // handle the error state
                console.log('Problem saving contact, error: ' + JSON.stringify(saveResult.error));
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        });
        
    },
    /*deleteList : function(component, event, helper) {
        var item = event.currentTarget;
        var device = component.get('v.device');
        
        component.createFilterJSON();
        
        if(item && item.dataset){
            
            //Show Spinner
            helper.showSpinner(component);
            
            //Remove Modal Dialog
            component.find("modalDialogPlaceHolder").set("v.body",[]);
            
            // delete list
            component.find(item.dataset.index).deleteRecord($A.getCallback(function(deleteResult) {
                if (deleteResult.state === "SUCCESS" || deleteResult.state === "DRAFT") {
                    // record is deleted successfully
                    component.showMessage("Deleted","List deleted successfully","success");
                    
                    helper.getContactListOtherDetails(component,{
                        'device' : device   
                    });
                     helper.getMyContactLists(component,null, {
                        'device' : device
                    });
                    helper.getRecentList(component, {
                        'device' : device
                    }); 
                    
                    //Set the Default Contact List Settings
                    helper.setDefaultContactListSettings(component, {
                        'campaignId' : '1'
                    });
                    
                    //Fetch the Count of Campaign Members
                    helper.getMemberCount(component, {
                        'campaignId' : '1',
                        'filters' : component.get("v.filterJSON"),
                        'device' : device
                    });
                    
                    //Hide Spinner
            		helper.hideSpinner(component);
                    
				} else if (deleteResult.state === "INCOMPLETE") {
                    // handle the incomplete state
                    console.log("User is offline, device doesn't support drafts.");
                } else if (deleteResult.state === "ERROR") {
                    //Hide Spinner
            		helper.hideSpinner(component);
                    // handle the error state
                    //console.log('Problem saving contact, error: ' + JSON.stringify(saveResult.error));
                } else {
                    //console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                }
            }));
        }
    },*/
    deleteList : function(component, event, helper) {
        var selectedCampaignId = component.find("myContactListSelect").get("v.value");
        var device = component.get('v.device');
       
        if(selectedCampaignId != undefined){
            
            //Show Spinner
            helper.showSpinner(component);
            
            //Remove Modal Dialog
            component.find("modalDialogPlaceHolder").set("v.body",[]);
            
            // delete list
            helper.deleteCampaign(
                component, 
                {
                    'campaignId' : selectedCampaignId
                },
                function(resultData){
                    //Success
                    if(resultData){
                        // record is deleted successfully
                   		component.showMessage($A.get("$Label.c.Deleted_Successfully"),$A.get("$Label.c.Deleted_Successfully"),"success");
                    
                        helper.getContactListOtherDetails(component,{
                            'device' : device   
                        });
                         helper.getMyContactLists(component,null, {
                            'device' : device
                        });
                        helper.getRecentList(component, {
                            'device' : device
                        }); 
                    
                        //Set the Default Contact List Settings
                        helper.setDefaultContactListSettings(component, {
                            'campaignId' : '1'
                        });
                    
                        //Fetch the Count of Campaign Members
                        helper.getMemberCount(component, {
                            'campaignId' : '1',
                            'filters' : component.get("v.filterJSON"),
                            'device' : device
                        });
                    
                        //Hide Spinner
                        helper.hideSpinner(component);
                    }
                    else {
                        //Hide Spinner
            			helper.hideSpinner(component);
                    }
                }
            );
        }
    },
    removeFromList : function(component, event, helper){
        var selectedCampaignId = component.find("myContactListSelect").get("v.value");
        
        component.createFilterJSON();
        
        if(selectedCampaignId != undefined){
            
            //Selected List Members - Used only when isAllSected is false
            var selectedContactData = [];
        	component.getSelectedContacts(selectedContactData);
        	var selectedContacts = selectedContactData['selectedContacts'];
            
            if(selectedContacts != undefined && selectedContacts.length > 0){
                //Show Spinner
        		helper.showSpinner(component);
                
               
                //Call Helper to remove members
                helper.removeCampaignMembersFromList(
                    component,
                    {
                        'completeListSelected' : component.get("v.selectAllCheckboxValue"),
                        'selectedCampaignId' : selectedCampaignId,
                        'selectedContacts' : selectedContacts,
                        'filters' : component.get("v.filterJSON")
                    },
                    function(resultData){
                        //Success
                        if(resultData != undefined && resultData.length >= 0){
                            
                            //Hide Spinner
                        	helper.hideSpinner(component);
                            
                            //Show Message
                            if(resultData.length == 0){
                            	component.showMessage($A.get("$Label.c.Removed_Successfully"),$A.get("$Label.c.Removed_Successfully"),"success");
                            }
                            else {
                                component.showMessage($A.get("$Label.c.Alert"),$A.get("$Label.c.Error_Message_Not_Allowed_To_Modify"),"warning");
                            }
                            
                            component.showMembers();
                        }
                        
                       
                    }
                );
            }
            else {
                //Show Error Message
                component.showMessage("Error!",$A.get("$Label.c.Error_Message_Select_Contact"),"error");
            }
        }
    },
    
    navigateToPageForContactAddition : function(component, event, helper){
        var selectedContactListId = component.find("myContactListSelect").get("v.value");
        var selectedContactListName;
        
        //Fetching List Name
        var contactLists = component.get("v.contactLists");
        for(var index = 0; index <contactLists.length; index++){
            if(selectedContactListId == contactLists[index].Campaign.Id){
                selectedContactListName = contactLists[index].Campaign.Name;
                break;
            }
        }
        
        var navigationEvent = $A.get("e.force:navigateToComponent");
        navigationEvent.setParams({
            componentDef : "c:ContactSearch",
            componentAttributes: {
                campaignId : selectedContactListId,
                campaignName : selectedContactListName
            },
            isredirect : true
        });
        navigationEvent.fire();
    },
    
    navigateToPageForCallReport : function(component, event, helper){
        var processSelectedContactBlock = false;
        
        var selectedContactIds = [];
        component.createFilterJSON();
        //If source list is Recently Viewed contacts then selectAllCheckboxValue should be false
        if(component.find("myContactListSelect").get("v.value") == '1'){
            component.set("v.selectAllCheckboxValue", false);
        }
        
        //Check whether SelectAll is Selected
        var isSelectedCheckBoxChecked = component.get("v.selectAllCheckboxValue");
        
        if(isSelectedCheckBoxChecked == true){
            
            //Check whether Non Covered Contacts Filter Selected
            var isNonCoveredContactFilterSelected = component.get("v.notCoveredContactFilter");
            
            if(isNonCoveredContactFilterSelected == true){
                processSelectedContactBlock = true;
            }
            else {
                //Check whether no. of selected contacts greater than 50 then do not allow user to create
                helper.getCampaignMembersForCampaignId(component,
                                                       {
                                                           'campaignId' : component.find("myContactListSelect").get("v.value"),
                                                           'filters' : component.get("v.filterJSON")
                                                       },
                                                       function(resultData){
                                                          
                                                           if(resultData != null){
                                                               if(resultData.length > 50){
                                                                  component.showMessage($A.get("$Label.c.Error"),$A.get("$Label.c.Error_Message_for_Call_Report_from_Contact_List"),"error");
                                                               }
                                                               else if(resultData.length <= 50 ){
                                                                   var selectedContactIds = resultData;
                                                                   component.seperateIdsForCallReport(selectedContactIds);
                                                                    
                                                                   var clientAttendees = component.get('v.clientAttendees');
                                                                   console.log('clientAttendees in contactlist ; '+clientAttendees);
                                                                   var internalAttendees = component.get('v.internalAttendees');
                                                                   if(internalAttendees.length < 50){
                                                                       var navigationEvent = $A.get("e.force:navigateToComponent");
                                                                       navigationEvent.setParams({
                                                                           componentDef : "c:EventCallReport",
                                                                           componentAttributes: {
                                                                               calledFrom : 'ContactList',
                                                                               ClientAttendees : clientAttendees,
                                                                               InternalInviteesPreloaded : internalAttendees
                                                                           }
                                                                       });
                                                                       navigationEvent.fire();
                                                                   }
                                                                   else{                                                                 
                                                                      component.showMessage($A.get("$Label.c.Error"),$A.get("$Label.c.Error_Message_for_Nomura_Employee_Call_Report_from_Contact_List"),"error");
                                                                   }
                                                               }
                                                           }
                                                       })
            }
        }
        else {
            processSelectedContactBlock = true;
        }
        
        if(processSelectedContactBlock) {            
            //Get Selected Data
            var selectedContactData = [];
            component.getSelectedContacts(selectedContactData);
            var selectedContactIds = selectedContactData['selectedContacts']; 
			console.log('Selected value **'+selectedContactIds);			
           
            if(selectedContactIds != null){
                if(selectedContactIds.length > 50 ){
                    component.showMessage($A.get("$Label.c.Error"),$A.get("$Label.c.Error_Message_for_Call_Report_from_Contact_List"),"error");
                }
                else if(selectedContactIds.length <= 50 ){   
                    //to seperate client attendees and internal invitees
        			component.seperateIdsForCallReport(selectedContactIds); 
                   
                    var clientAttendees = component.get('v.clientAttendees');
                     
					console.log('clientAttendees in contactlist ; '+clientAttendees);
                    var internalAttendees = component.get('v.internalAttendees');
                    
                    if(internalAttendees.length < 50){                    
                        var navigationEvent = $A.get("e.force:navigateToComponent");
                        navigationEvent.setParams({
                            componentDef : "c:EventCallReport",
                            componentAttributes: {
                                calledFrom : 'ContactList',
                                ClientAttendees : clientAttendees,
                                InternalInviteesPreloaded : internalAttendees
                            }
                        });
                        navigationEvent.fire();
                    }
                    else{
                        //change error message.. 
                        component.showMessage($A.get("$Label.c.Error"),$A.get("$Label.c.Error_Message_for_Nomura_Employee_Call_Report_from_Contact_List"),"error");
                    }
                }
                
            }
           
        }
        
    },     
    
    getNextPage : function(component) { 
    	var pageNumber = component.get('v.pageNumber'); 
        var pageSize = component.get('v.pageSize'); 
 
        pageNumber++; 
 
        component.set('v.pageNumber', pageNumber); 
        component.set('v.pageSize', pageSize); 
 
        component.getPageData('pagination');
    },
    
    getPageData : function(component, event, helper) {
       var renderedRows;
       if(component.get('v.pageNumber') === 1){      
            component.set('v.pageSize', 60); 
           	renderedRows = 60;
        }
        else{
           	component.set('v.pageSize', 100);
            renderedRows = component.get('v.listMembers').length;
            
            //If Non Covered Contacts Filter is selected then complete data gets loaded when pageNumber is 1
            var notCoveredContactFilterSelected = component.get("v.notCoveredContactFilter");
            if(notCoveredContactFilterSelected != undefined && notCoveredContactFilterSelected == true){
                component.set('v.loading', true); 
            }
        }
              
        console.log('***PageNumber:'+component.get('v.pageNumber'));
        console.log('***pageSize:'+component.get('v.pageSize'));
        console.log('***sortField:'+component.get('v.sortField'));
        console.log('***sortDirection:'+component.get('v.sortDirection'));
       
        var params = event.getParam('arguments');
        if(params){
            var sourceMethod = params.strSource;
        }
        
        var loading = component.get('v.loading');
        var campaignId = component.find("myContactListSelect").get("v.value");       
       
        component.createFilterJSON();
       
        if(campaignId != '1'){
            //should call helper when loading is false
            if(loading === false){                 
                component.set('v.loading', true); 
                    
                helper.getCampaignMembers(
                component,
                {
                    'campaignId' : component.find("myContactListSelect").get("v.value"),
                    'pageNumber' : component.get('v.pageNumber'),
                    'pageSize' : component.get('v.pageSize'),
                    'sortField' : component.get('v.sortField'),
                    'sortDirection' : component.get('v.sortDirection'),
                    'renderedRows' : renderedRows,
                    'filters' : component.get("v.filterJSON")
                },
                function(resultData){                   
                    var rows = component.get('v.listMembers');
                    
                    if(sourceMethod == 'sorting'){
                        component.set('v.listMembers', resultData);                       
                    }
                    else {
                        component.set('v.listMembers', rows.concat(resultData));                        
                    }
                    
              		component.set('v.loading', false);  
                    
                    //Check Whether SelectAll is Selected
                    var isSelectedCheckBoxChecked = component.get("v.selectAllCheckboxValue");
                    
                    if(isSelectedCheckBoxChecked == true){
                        component.setDataTableCheckboxValues(true);
                    }                  
                }
            	);               
        	}   
        }
    },        
    
    getSortedData : function(component, event, helper) {
        var sortDirection = component.get('v.sortDirection'); 
        var sortField = component.get('v.sortField'); 
        
        if(sortDirection == 'ASC'){
            component.set('v.sortDirection', 'DESC'); 
        }
        else {
            component.set('v.sortDirection', 'ASC'); 
        }
        
        //Set Page Number
        component.set('v.pageNumber', 1);
        
        component.getPageData("sorting");
    },
    /*
     *Shield changes as sorting isn't provided on Name
    sortContactName : function(component, event, helper){
        component.set('v.sortField', 'Contact.Localized_Name__c');
		component.getSortedData();	
    },
    */
    sortRGAccountName : function(component, event, helper){
        component.set('v.sortField', 'Contact.RG_Account__r.Name');
		component.getSortedData();	
    },
    
    sortRMAccountName : function(component, event, helper){
        component.set('v.sortField', 'Contact.Account.Localized_Name__c');
		component.getSortedData();	
    },
    
    sortCountry : function(component, event, helper){
        component.set('v.sortField', 'Contact.MailingCountryCode');
		component.getSortedData();	
    },
    
    emptyTableData : function(component, event, helper) {
        //Blank out the listMembers data
        component.set('v.listMembers', []);
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
            if(getAllContactIds.get("v.value") === true)
            	selectedContactId.push(getAllContactIds.get("v.text"))    
           
        }               
        
        //Set Selected Contacts
        var params = event.getParam('arguments');        
        if(params){
            params.selectedContacts['selectedContacts'] = selectedContactId;
        }
    },
    
    seperateIdsForCallReport : function(component, event, helper){
        var params = event.getParam('arguments');
        var selectedContactIds;
        if(params){           
            selectedContactIds = params.selectedContactIds;
        }
        var listMembers = component.get("v.listMembers");
        var nomuraEmpIds = [];
        var internalAttendees = [];
        var clientAttendees = [];
        
        for(var j = 0; j < selectedContactIds.length; j++){
        	for(var i = 0; i < listMembers.length; i++){
                if(selectedContactIds[j] == listMembers[i].contactId &&
                   listMembers[i].accountRDMOrgId === 'CPG12345') {
                   internalAttendees.push(selectedContactIds[j]);
                   break;
               }
                else if(selectedContactIds[j] == listMembers[i].contactId){
                   clientAttendees.push(selectedContactIds[j]);
                   break;
                }
            }
        }
        
        console.log(' in seperateIdsForCallReport' + clientAttendees.length);
        console.log(' in seperateIdsForCallReport' + internalAttendees.length);
        
        if(internalAttendees != null && internalAttendees.length > 0)
        	component.set('v.internalAttendees', internalAttendees);
        else if(internalAttendees == null || internalAttendees.length == 0){
           	component.set('v.internalAttendees', "");
            console.log(' in seperateIdsForCallReport');
        }
        
        if(clientAttendees != null && clientAttendees.length > 0 )
        	component.set('v.clientAttendees', clientAttendees);
        else if(clientAttendees == null || clientAttendees.length == 0){
           component.set('v.clientAttendees', "");
            console.log(' in seperateIdsForCallReport');
        }
        //added else for JIRA SALES--2251
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
    
    showMessage : function(component, event, helper){
        var params = event.getParam('arguments');
        if(params){
             var resultsToast = $A.get("e.force:showToast");
             resultsToast.setParams({
                 "title": params.title,
                 "message": params.message,
                 "type": params.type
             });
             resultsToast.fire();
        }
    },
    navigateToVfURL : function(component, event, helper) {
        var params = event.getParam('arguments');
        var campaignId = params.strRecordId;
        if(campaignId != null){
            var strURL = '/apex/EmailEdit?id=' + campaignId;
            component.openPage(strURL);
        }
       
        
    },
    navigateToRecord : function(component, event, helper){
         var params = event.getParam('arguments');
         if(params){
             var navigationEvent = $A.get("e.force:navigateToSObject");
             navigationEvent.setParams({
                    recordId: params.strRecordId,
                    slideDevName: "detail"
                });
             navigationEvent.fire(); 
        }
    },
    navigateToShareRecordPage : function(component, event, helper) {
    	/*var campaignId = component.find("myContactListSelect").get("v.value");
        if(campaignId != null){
            var pageURL = window.location.origin + '/p/share/CampaignSharingDetail?parentId=' + campaignId;
        	window.open(pageURL, '_blank');
            //component.openPage(pageURL);
        }*/
        
        var selectedContactListId = component.find("myContactListSelect").get("v.value");
        
        var navigationEvent = $A.get("e.force:navigateToComponent");
        navigationEvent.setParams({
            componentDef : "c:LightningManualSharing",
            componentAttributes: {
                recordId : selectedContactListId
            },
            isredirect : true
        });
        
        navigationEvent.fire(); 
    },
    navigateToContactListReport : function(component, event, helper){
        var contactListReportId = component.get("v.contactListOtherDetails.contactListReportId");
        var selectedContactListId = component.get("v.myContactListSelect");
        if( selectedContactListId != undefined && selectedContactListId != null && selectedContactListId != '1' &&
            contactListReportId != undefined && contactListReportId != null)
        {
        	
            var customizedContactListId = selectedContactListId.substring(0,15);
            var reportURL = window.location.origin + '/' + contactListReportId + '?pv0=' + customizedContactListId + '&isdtp=vw';
            
            window.open(reportURL, '_blank','toolbar=0,location=0,menubar=0,resizable=yes,scrollbars=yes');
        }
    },
    openPage : function(component, event){
        var params = event.getParam('arguments');
        if(params){
            var strURL = params.strURL;
            if(strURL != null){
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": strURL
                });
                urlEvent.fire();
            }
        }
    }, 
	getSelectedAccounts : function(component, event, helper){
        if(event.getParam("values").length >= 1){
            var rgAccountId = event.getParam("values");                           
            component.set("v.rgAccount", rgAccountId[0]);
            component.set("v.listChanged", false);
            component.createSingleLookupJSON();
            component.showMembers();              
            
        }else
            component.set("v.rgAccount", "");          
    },
    
    getSelectedContactFilter : function(component, event, helper){
        if(event.getParam("values").length >= 1){
            var contactId = event.getParam("values");                           
            component.set("v.contactIdFiltered", contactId[0]);
            component.set("v.listChanged", false);          
            component.showMembers();                                 
        }else
            component.set("v.contactIdFiltered", "");          
    },
    
    notCoveredContactFilterSelector : function(component, event) {
    	var notCoveredContactFilter = event.getSource().get("v.value");
        component.set("v.notCoveredContactFilter", notCoveredContactFilter);
        component.set("v.listChanged", false);          
        component.showMembers();              
    },
    
    updateLookupIdEvent : function(component, event, helper){        
        component.set("v.listChanged", false);
        component.showMembers(); 
        
    },
    
    createFilterJSON : function(component, event, helper){
        var filter = new Object();
        filter.rgAccount = component.get("v.rgAccount");
        filter.contactId = component.get("v.contactIdFiltered");
        filter.showNonCoveredContacts = component.get("v.notCoveredContactFilter");
        component.set("v.filterJSON", JSON.stringify(filter));
    },
     
    createSingleLookupJSON : function(component, event, helper){
        var lookupFilters = new Object();
        lookupFilters.campaignId = component.get("v.myContactListSelect");
        lookupFilters.rgAccount = component.get("v.rgAccount");
        component.set("v.singleLookupJSON", JSON.stringify(lookupFilters));
    }
})