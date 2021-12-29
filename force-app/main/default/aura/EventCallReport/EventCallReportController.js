({
    init: function(component, event, helper) {
    helper.isCapIntroUser(component) ;  

        //code need to change to get the parameter from contactlist. just an sample
        var callingComponent = component.get("v.calledFrom");
        console.log('callingComponent **'+callingComponent);
        

        if(callingComponent !== "ContactList"){
            component.callReportView(component, event, helper);
            component.set("v.massActivityFlag", false);            
        }
        else{
           component.massActivityView(component, event, helper); 
           component.set("v.massActivityFlag", true);
        }
        
        helper.hideSpinner(component);       
        helper.initialiseEventLabels(component);
        helper.initialiseNewCallReport(component,event,helper,'');
        helper.initialiseEventTypes(component,helper);
        helper.initialiseSectors(component);
        //helper.checkCurrentUserSettings(component);
        helper.initialiseInternalInvitees(component);
        //helper.initialiseClientAttendees(component);
        helper.initialiseDetailedDescription(component);   
        //Added for JIRA SALES-3521
        helper.initialisePositionValues(component); 
        //Calling Activity Flag Statuses
        helper.initialiseActivityStatus(component); 
        
           
   },

  l0EventTypeChanged: function(component,event,helper){
      var availableEventTypes = component.get("v.availableEventTypes");
      component.set('v.l1Changed', false);
       var selectedValue = component.find('l0eventType').get('v.value');
       if(selectedValue!=undefined && selectedValue!=null && selectedValue!=''){
           helper.setL1TypeDefaultValue(component,selectedValue);  
           helper.loadActivityValues(component,selectedValue);
           
           var eventTypeChanged = true;
           var startChanged = false;
           helper.updateEndDate(component, event, eventTypeChanged, startChanged);
           
       }
   }, 
   
   sectorChanged: function(component,event,helper){
     var selectedValue = component.find('Sector').get('v.value');
     if(selectedValue!=undefined && selectedValue!=null && selectedValue!=''){
         helper.setSectorValue(component,selectedValue);   
     }
 }, 
 activityFlagChanged: function(component,event,helper){
    var resetValues = false;
    var activityFlagStatusDiv = component.find("activityFlagStatusDiv");
    if(event.getParam("values").length >= 1){
           var selectlist = event.getParam("values");
           var finalstr = "";
           var activityFlagStatusList = []; 

           console.log(selectlist);
           for(var i = 0; i<selectlist.length; i++){
               var selectedActivityFlag = selectlist[i];
               if(i>0){
                   finalstr += ";" + selectedActivityFlag;
               }
               else
                   finalstr = selectedActivityFlag;

               //Populate Activity Flag Status Values
               var actyFlagDependentStatusMap = component.get("v.activityFlagDependentStatusMap");
               if(actyFlagDependentStatusMap != undefined && actyFlagDependentStatusMap != null && actyFlagDependentStatusMap.hasOwnProperty(selectedActivityFlag)){
                    var tempActivityFlagStatusList = actyFlagDependentStatusMap[selectedActivityFlag];
                    if(tempActivityFlagStatusList != undefined && tempActivityFlagStatusList != null){
                        for(var index = 0; index < tempActivityFlagStatusList.length; index++){
                            activityFlagStatusList.push(tempActivityFlagStatusList[index]);
                        }
                    }
               }
           }
           component.set("v.newCallReport.Activity_Flag__c", finalstr);   
           component.set("v.activityStatuses", activityFlagStatusList);  
           
           if(activityFlagStatusList != undefined && activityFlagStatusList != null && activityFlagStatusList.length > 0){
                //Show the Activity Flag Status
                $A.util.removeClass(activityFlagStatusDiv, "slds-hide"); 
           }
           else {
                resetValues = true;
           }
           
    }
    else {
        resetValues = true;

        component.set("v.newCallReport.Activity_Flag__c", "");
    }
        
    //Reset
    if(resetValues == true){
        
        component.set("v.activityStatuses", {}); 
        component.set("v.selectedActivityStatus", "");
        component.set("v.newCallReport.IBOR_Status__c", "");
        
        //Hide the Activity Flag Status
        $A.util.addClass(activityFlagStatusDiv, "slds-hide");
    }
},

activityStatusChanged : function(component, event, helper){
    var activityStatus = component.find("activityStatus").get("v.value");
    if(activityStatus != undefined && activityStatus != null){
        component.set("v.newCallReport.IBOR_Status__c", activityStatus);
    }
    else {
        component.set("v.newCallReport.IBOR_Status__c", "");
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
    setScriptLoaded : function(component){
       component.set("v.areJSScriptsLoaded",true);
       component.set("v.needToProcessReRenderLogic",true);
   },    
   toggleClick : function(component,event, helper){ 
    
       var splitval = event.getSource().get('v.value');
       component.set('v.SaveEventType', event.getSource().get('v.value'));
       var relatedD = component.find("relatedToDiv");
       var relatedSD = component.find("relatedToSearchDiv");
       var relatedED = component.find("privateEventDiv");
       if(splitval == 'No'){
          $A.util.removeClass(relatedD, "slds-hide");
          $A.util.removeClass(relatedSD, "slds-hide");           
       }
       else{
          $A.util.addClass(relatedD, "slds-hide");
          $A.util.addClass(relatedSD, "slds-hide");
       }
       
   },
   updateInvitees : function(component, event, helper){
       var contacts = event.getParam("selectedContacts");
       var closeModal = event.getParam("closeBrowseContacts");
       
       var selectedAttendees = component.get("v.clientAttendeesSelected");
       
       if(selectedAttendees.length > 0){
           for(var k in contacts){
               console.log('k ' + contacts[k]);
               console.log('index: ' + selectedAttendees.indexOf(contacts[k]));
               if(selectedAttendees.indexOf(contacts[k]) == -1){
                   selectedAttendees.push(contacts[k]);
               }else{
                   console.log('In Else not found');
               }
               
           }       
           var ClientAttendees = component.get("v.ClientAttendees");
           
           console.log('ClientAttendees: ' + ClientAttendees);
           component.set("v.ClientAttendees", selectedAttendees);
       }else{
       }
       

       component.find("lookup-external-contact").callPreSelect();
       if(closeModal == true){
          var cmpTarget = component.find('Modalbox');
       var cmpBack = component.find('Modalbackdrop');
       $A.util.removeClass(cmpBack,'slds-backdrop--open');
       $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
       }
   },
   
    cancel: function(component, event, helper) {
        
        var recordId = component.get("v.recordId");
        var campaignId = component.get("v.campaignId");
        var parentId = component.get("v.relatedToId");            
        var myContactListSelect = component.get("v.myContactListSelect");
        var calledFrom = component.get("v.calledFrom");
        
        console.log('parentId: ' + parentId);
        console.log('campaignId: ' + campaignId);
        console.log('recordId: ' + recordId);
        console.log('myContactListSelect: ' + myContactListSelect);
        console.log('calledFrom: ' + calledFrom);           
            
        if($A.get("$Browser.formFactor") === "DESKTOP" && calledFrom == 'ContactList' 
           && (((campaignId == '' || campaignId == undefined) && (myContactListSelect == '' || myContactListSelect == undefined))
               || (myContactListSelect.startsWith("701"))
              //|| ((campaignId == '' || campaignId == undefined) && (myContactListSelect.startsWith("701")))
              //|| (campaignId.startsWith("701") && myContactListSelect.startsWith("701"))
              )){
                helper.navigateToContactList(component);
        }
        else if((recordId != undefined && recordId !== '') && (parentId == '' || parentId == undefined)){
            helper.navigateToRecord(component, recordId); 
        }                
        else if((parentId != '' && parentId != undefined) && (recordId == undefined || recordId == '')){
            helper.navigateToRecord(component, parentId);
        }
        else if($A.get("$Browser.formFactor") === "DESKTOP"){
            helper.navigateToHomepage(component); 
        }
        else{
            component.find("navigationService").navigate({
                "type": "standard__navItemPage",
                "attributes": {
                    "apiName":"Home_Mobile" }
            }, true);
        }
   },
   
   save: function(component, event, helper) {        
        var saveButton = component.find("saveButton");

        saveButton.set("v.disabled", true);
        component.set("v.saveNewCheck", false);
        var recordId = component.get("v.recordId");
        console.log(recordId);
        if(recordId == undefined || recordId == ''){
            helper.saveEvent(component);
        }else{
            if(recordId.startsWith("00U")){
                helper.updateEvent(component);
            }
        }
               
   },
   
   saveNew: function(component, event, helper) {        
        var saveNewButton = component.find("saveNewButton");

        saveNewButton.set("v.disabled", true);
        component.set("v.saveNewCheck", true);
        var recordId = component.get("v.recordId");
        console.log(recordId);
        if(recordId == undefined || recordId == ''){
            helper.saveEvent(component);
        
        }else{
            if(recordId.startsWith("00U")){
                console.log('updateEvent');
                helper.updateEvent(component);
            }
        }
            
    },
    
   assignedToChanged : function(component, event, helper) {
       helper.updateAssignedTo(component, event);
   },

   eventTypeChanged : function(component, event, helper) {
       component.set('v.l1Changed', true);
       helper.updateEventType(component, event);
       var eventTypeChanged = true;
       var startChanged = false;
       helper.updateEndDate(component, event, eventTypeChanged, startChanged);
       //added for JIRA SALES 3510
       helper.getObjectiveMandatory(component,helper); 
   },
   
    stageTypeChanged : function(component, event, helper) {
        component.set('v.l1Changed', true);
       helper.updateEventType(component, event);
   },
   createTypeChanged : function(component,event,helper){ 
       component.set("v.isCallFromTypeChange",true);
        component.set('v.createTypeChange', true);
       helper.updateEventType(component,event);
       helper.hideShowControls(component,event,helper);        
   },
   
   relatedToOpportunityChanged : function(component, event, helper){
       console.log('relatedToOpportunityChanged');
       if(event.getParam("values").length >= 1){
           var accountIds = event.getParam("values");          
                    
           component.set("v.newCallReport.WhatId", accountIds[0]);
       }else{
           component.set("v.newCallReport.WhatId", "");
       }
   },
   
    relatedToFundChanged : function(component, event, helper){       
       if(event.getParam("values").length >= 1){
           var accountIds = event.getParam("values");          
           console.log(accountIds[0]);             
           component.set("v.newCallReport.Fund__c", accountIds[0]);
       }else{
           component.set("v.newCallReport.Fund__c", "");
       }
   },
   
   relatedToAccountChanged : function(component, event, helper){
       if(event.getParam("values").length >= 1){
           var accountIds = event.getParam("values");          
           component.set("v.newCallReport.WhatId", accountIds[0]);
       }else
           component.set("v.newCallReport.WhatId", "");
   },

   relatedToCampaignChanged : function(component, event, helper){
       if(event.getParam("values").length >= 1){
           var accountIds = event.getParam("values");          
           component.set("v.newCallReport.WhatId", accountIds[0]);
       }else
           component.set("v.newCallReport.WhatId", "");
   },

   startDateChanged : function(component, event, helper){
       var eventTypeChanged = false;
       var startChanged = component.get('v.startChanged');
       helper.updateEndDate(component, event, eventTypeChanged, startChanged);
       component.set('v.startChanged', true);
   },

   endDateChanged : function(component, event, helper){
        helper.updateDuration(component);
        
   },

   privateFlagChanged :function(component, event, helper){
       helper.updatePrivacyFlag(component, event);
   },

   allDayFlagChanged :function(component, event, helper){
       helper.updateAllDayEventFlag(component, event);
   },

   internalInviteesChanged :function(component, event, helper){
       helper.updateInternalInvitees(component, event);
   } ,

   externalInviteesChanged :function(component, event, helper){
       helper.updateExternalInvitees(component, event);
   } ,

   ricCodeChanged :function(component, event, helper){
    helper.updateRicCode(component, event);
    } ,
    
   relatedToObjectChanged : function(component, event) {
                
        var inputBox = component.find("recordLabelName");
        var objSelect = component.find("objectSelect").get("v.value");
        var recordId = component.get("v.recordId");
        var accountLabel = $A.get("$Label.c.Event_Account");
        var opportunityLabel = $A.get("$Label.c.Event_Opportunity");
        var campaignLabel = $A.get("$Label.c.Event_Campaign");
        var isJapanFIUser = component.get("v.isJapanFIUser");

       if(objSelect == accountLabel){
           component.set("v.relatedToObject", accountLabel);
           component.set("v.newCallReport.Private_Flag__c", false); 
           //show the section if the account is selected again 
           //added section for SALES-2779
           if((recordId == undefined || recordId == '') && !isJapanFIUser){
               var splitDiv = component.find("splitDiv");
               $A.util.removeClass(splitDiv,'slds-hide'); 
           }                
       }
       else if(objSelect == opportunityLabel){
           component.set("v.relatedToObject", opportunityLabel);
           component.set("v.newCallReport.Private_Flag__c", true);
           //added section for SALES-2779
           if(recordId == undefined || recordId == ''){
           var splitDiv = component.find("splitDiv");
               $A.util.addClass(splitDiv,'slds-hide'); 
           }          
       }
       else if(objSelect == campaignLabel){
           component.set("v.relatedToObject", campaignLabel);
           component.set("v.newCallReport.Private_Flag__c", false);  
           //added section for SALES-2779
           if(recordId == undefined || recordId == ''){
               var splitDiv = component.find("splitDiv");
               $A.util.addClass(splitDiv,'slds-hide'); 
           }
       }
   },

   closeErrorMessages : function(component, event, helper){
       component.set("v.hasErrors", false);
   },    

   toggleShowHide : function(component, event, helper){
       helper.toggleShowHideClass(component, event, "richTextDescription");
       helper.toggleShowHideClass(component, event, "openDescSecId");
       helper.toggleShowHideClass(component, event, "closeDescSecId");
   }, 
  
   createNewContact : function(component, event, helper){

       component.set("v.showNewContactPopup", true);
   }, 

   closeNewContactPopup: function(component, event, helper){
       component.set("v.showNewContactPopup", false);
   }, 

   saveNewContact :function(component, event, helper){
       helper.showSpinner(component);
       helper.saveContact(component);
       component.set("v.showNewContactPopup", false);

       
   },

   closeContactLookupPopup :function(component, event, helper){
       helper.closeContactLookup(component);
   }, 

   closeContactErrorMessages : function(component, event, helper){
       component.set("v.hasContactErrors", false);
   },

   closeModal:function(component,event,helper){    
       var cmpTarget = component.find('Modalbox');
       var cmpBack = component.find('Modalbackdrop');
       $A.util.removeClass(cmpBack,'slds-backdrop--open');
       $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
   },
   openmodal: function(component,event,helper) {

       var related = component.get("v.relatedToAccountSelected");
       var newReport = component.get("v.newCallReport");
       newReport.sobjectType = 'Event';
       var array = [];
       var accountLookupIdSelected = component.get('v.accountLookupIdSelected');
       if(accountLookupIdSelected != undefined && accountLookupIdSelected.startsWith("001") == true){
           array.push(accountLookupIdSelected);
       }
       else if(newReport.WhatId != undefined && newReport.WhatId.startsWith("001") == true){
           array.push(newReport.WhatId);
           
       }      

       component.set("v.relatedToAccountSelected", array);
       
       if(array.length > 0){
           /*
            * Since modal box is preloaded, during intialization the value of preselected is null
            * Always re-call again to reload with updated value.
           */
           var contactReportSearch = component.find("contactReportSearch");
           var lookupReference  = contactReportSearch.find("accounts");
           lookupReference.callPreSelect();
           contactReportSearch.init();
       }
       

       var cmpTarget = component.find('Modalbox');
       var cmpBack = component.find('Modalbackdrop');
       $A.util.addClass(cmpTarget, 'slds-fade-in-open');
       $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
   }, 

    massActivityView : function(component, event, helper){
        var relatedToD = component.find("relatedToDiv");
        var relatedToSearchD = component.find("relatedToSearchDiv");
        var attendeesButtonD = component.find("attendeesButtonDiv");
        var clientAttendeesD = component.find("clientAttendeesDiv");
        var internalAttendeesD = component.find("internalAttendeesDiv");
        var privateEventD = component.find("privateEventDiv");
        var typeD = component.find("typeDiv");
        var l0typeD = component.find("l0typeDiv");
        var bluefireEventInp = component.find("bluefireEventInput");
        var stageD = component.find("stageDiv");
        var createD = component.find("createDiv");
        var massActivityTypeDiv = component.find("massActivityTypeDiv");
        var massActivitySubTypeDiv = component.find("massActivitySubTypeDiv");
        var saveNewButtonD = component.find("saveNewButton");
        var splitD = component.find("splitDiv");

        $A.util.addClass(relatedToD, "slds-hide");
        $A.util.addClass(relatedToSearchD, "slds-hide");
        $A.util.addClass(attendeesButtonD, "slds-hide");
        $A.util.addClass(privateEventD, "slds-hide");
        $A.util.addClass(clientAttendeesD, "slds-hide");
        $A.util.removeClass(internalAttendeesD, "slds-hide");
        $A.util.addClass(typeD, "slds-hide");
        $A.util.addClass(l0typeD, "slds-hide");
        $A.util.addClass(bluefireEventInp, "slds-hide"); 
        $A.util.addClass(saveNewButtonD, "slds-hide"); 
        $A.util.addClass(splitD, "slds-hide"); 

        if(!component.get('v.isEQUser')){    
            $A.util.removeClass(massActivityTypeDiv, "slds-hide"); 
            $A.util.removeClass(massActivitySubTypeDiv, "slds-hide"); 
        }
        else
            $A.util.removeClass(massActivitySubTypeDiv, "slds-hide"); 
            
        if(component.get("v.isCapIntro")){
           $A.util.removeClass(createD, "slds-hide");
           console.log('createVal');
           console.log(component.get("v.createVal"));
           if(component.get("v.createVal")=="CI Interactions") { 
           $A.util.removeClass(stageD, "slds-hide"); 
           }
           else
           {
              $A.util.addClass(stageD, "slds-hide"); 
           }
       }
       else
       {
          $A.util.addClass(stageD, "slds-hide");  
          $A.util.addClass(createD, "slds-hide");  
       }
        
    },
   
   callReportView : function(component, event, helper){
       helper.isCapIntroUser(component);
       
       var relatedToD = component.find("relatedToDiv");
       var relatedToSearchD = component.find("relatedToSearchDiv");
       var attendeesButtonD = component.find("attendeesButtonDiv");
       var clientAttendeesD = component.find("clientAttendeesDiv");
       var internalAttendeesD = component.find("internalAttendeesDiv");
       var privateEventD = component.find("privateEventDiv");
       var typeD = component.find("typeDiv");
       var l0typeD = component.find("l0typeDiv");
       var bluefireEventInp = component.find("bluefireEventInput");        
       var stageD = component.find("stageDiv");
       var createD = component.find("createDiv");
       var activityFlagD = component.find("activityFlagDiv");
       var accountLookupD = component.find("accountLookupDiv");
       
        $A.util.removeClass(relatedToD, "slds-hide");
        $A.util.removeClass(relatedToSearchD, "slds-hide");
        $A.util.removeClass(attendeesButtonD, "slds-hide");
        $A.util.removeClass(privateEventD, "slds-hide");
        $A.util.removeClass(clientAttendeesD, "slds-hide");
        $A.util.removeClass(internalAttendeesD, "slds-hide");
        $A.util.removeClass(accountLookupD, "slds-hide");

       //show Type and L1 for Equity User
       if(component.get('v.isEQUser'))
       {
           $A.util.removeClass(l0typeD, "slds-hide");
           $A.util.removeClass(typeD, "slds-hide");
           $A.util.removeClass(activityFlagD, "slds-hide");
           
       }
       else
       {
           $A.util.removeClass(l0typeD, "slds-hide");
           $A.util.addClass(typeD, "slds-hide");
           $A.util.removeClass(activityFlagD, "slds-hide");
       }
        $A.util.removeClass(bluefireEventInp, "slds-hide");
                
        
       if(component.get("v.isCapIntro")){        
           $A.util.removeClass(createD, "slds-hide");
           
           if(component.get("v.createVal")=="CI Interactions") { 
                $A.util.removeClass(stageD, "slds-hide"); 
                $A.util.addClass(accountLookupD, "slds-hide");
           }
           else
           {
              $A.util.addClass(stageD, "slds-hide");
              $A.util.removeClass(accountLookupD, "slds-hide"); 
           }
       }
       else
       {
          $A.util.addClass(stageD, "slds-hide");  
          $A.util.addClass(createD, "slds-hide");  
       }
       
    },
   
   contactAccountchanged : function(component, event, helper){
       
       var accountIds = event.getParam("values");
       console.log(accountIds);       
       console.log(event.getParam("values").length);
       if(event.getParam("values").length >= 1){
           //used for Address change on creation
           component.getAddressData(accountIds[0]);
       }
   }, 

   OnReset : function(component,event,helper){
       var combobox = component.find("addressCombobox");
       combobox.clear();
       combobox.hideItems();
       component.set('v.selectedAddress','');
       $A.util.addClass(combobox.find('lookup-pill'),'slds-hide');
   },
    addressChanged : function(component, event, helper){
       if(event.getParam("values").length >= 1){
           console.log('values');
           console.log(event.getParam("values"));
           component.set('v.selectedAddress',event.getParam("values")[0]);
           console.log('data');
           console.log(event.getParam("data"));
         
       }
       var selectedAddress = component.get("v.selectedAddress");
       console.log('selected Address :'+selectedAddress)
   },
   
   addressCleared : function(component, event, helper){
       if(component.get('v.rgAccountSelected')!=''){ 
           component.getAddressData(component.get("v.relatedToAccount"));
       }
   },
   
   getAddressData : function(component, event, helper){
       var params = event.getParam('arguments');
       
       if(params){
           var account = params.relatedAccount;
           
           var validationResult = [];
           var action = component.get("c.getAccountAddresses");
           action.setParams({
                   "accountId" : account
               });

               action.setCallback(this, function(response) {
                   var state = response.getState();
                   if (state === "SUCCESS") {
                       var result = response.getReturnValue();
                       console.log(result);

                       var addresses = [];
                       for(var k in result){
                           var labelText = result[k].BillingStreet + ' ' + result[k].BillingCity + ' ' + result[k].BillingCountry;
                           addresses.push({label:labelText, value: result[k].Id});
                       }
                        var array = [];

                       array.push(account);
                       component.set("v.relatedToAccount", account);
                       component.set("v.relatedToAccountSelected1", array);
                       component.set("v.addressOptions", addresses);
                       component.find("addressCombobox").reinitialise();

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
                           } else {
                               console.log("Unknown error");
                           }
                           }
                       });

               $A.enqueueAction(action);
       }        
   },
    // Update for JIRA SALES-3644
    /*updateEventTypeByUser : function(component, event, helper){
        var recordId = component.get("v.recordId");
        if(recordId == undefined){            
        var userIsAnalyst = component.get('v.assignedToUserField.Is_Analyst__c');
            var massActivityFlag = component.get("v.massActivityFlag");
            if(!userIsAnalyst && massActivityFlag != true){
                component.set('v.selectedEventType', 'Sales Meeting');
                component.set("v.newCallReport.Type",'Sales Meeting');
            }
            else if(userIsAnalyst && massActivityFlag != true){
                component.set('v.selectedEventType', 'Analyst Meeting');
                component.set("v.newCallReport.Type",'Analyst Meeting');
            }                
        }        
    },*/
    positionvalueChanged : function(component, event, helper) {
        console.log('event val'+ event.getSource().get('v.value'));
        console.log('event val'+ event.getParam("values"));
        if(event.getSource().get('v.value') != 'undefined'){
            var positionval = event.getSource().get('v.value');          
            console.log('position val :: ' + positionval);             
            component.set("v.newContact.PositionPicklist__c", positionval);
        }else{
            component.set("v.newContact.PositionPicklist__c", "");
        }
    },
    
    accountLookupChanged : function(component, event, helper){        
        if(event.getParam("values").length >= 1){
            component.set("v.showCoveredAccountDetails", true);
            var accountId = event.getParam("values");        
            component.set("v.accountLookupIdSelected", accountId[0]);
            var eventWhatId = component.get("v.newCallReport.WhatId");
            var opportunityLabel = $A.get("$Label.c.Event_Opportunity");
            var accountLabel = $A.get("$Label.c.Event_Account");
            var campaignLabel = $A.get("$Label.c.Event_Campaign");

            var isJapanFIUser = component.get("v.isJapanFIUser");
            if(isJapanFIUser && (eventWhatId == undefined || eventWhatId == null || eventWhatId == "")){               
                //for JapanFI user, WhatId will be OpportunityId which is set in helper               
                
                component.set("v.relatedToObject", opportunityLabel); 
                helper.showOnlyCoveredAccountOppo(component);                                
            }
            else{
                if(eventWhatId == undefined || eventWhatId == null || eventWhatId == ""){
                    var getRelatedToSelected = component.get("v.relatedToObject");
                    if(getRelatedToSelected == accountLabel){
                        //for normal user, WhatId will be AccountId
                        var accountId = event.getParam("values"); 
                        var array = [];
                        array.push(accountId[0]);        
                        component.set("v.newCallReport.WhatId", accountId[0]);               
                        component.set("v.relatedToAccountSelected", array);    
                        component.set("v.relatedToObject", accountLabel);
                        component.find("related-to-account").callPreSelect();
                    }
                    
                }  
                              
            }            
        }else{            
            component.set("v.showCoveredAccountDetails", false);            
            component.set('v.accountLookupIdSelected', "");
        }        
    },

    coveredAccountCheckChange : function(component, event){
        var isChecked = event.getSource().get("v.value");        
        
        if(isChecked == true){
            //component.set("v.showCoveredAccountDetails", true);
            component.set("v.coveredAccountCheck", true);
        }
        else{
            //component.set("v.showCoveredAccountDetails", false);
            component.set("v.coveredAccountCheck", false);
        }
            
    },

})