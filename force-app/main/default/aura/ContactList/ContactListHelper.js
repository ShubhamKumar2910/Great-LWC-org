({
    showSpinner : function(component) { 
           console.log('show spinner');
        $A.util.removeClass(component.find('spinner'), 'slds-hide'); 
     }, 
     
     hideSpinner : function(component) { 
         console.log('hide spinner');
         $A.util.addClass(component.find('spinner'), 'slds-hide'); 
     }, 
     
     addContactToMyCoverageNContact : function(component) {
         var selectedContactData = [];
         component.getSelectedContacts(selectedContactData);
         this.showSpinner(component);
         var selectedData = selectedContactData['selectedContacts'];
         if(selectedData != undefined && selectedData.length > 0){
             var myContactListAction = component.get("c.findMyCoverage");
             myContactListAction.setCallback(this,function(response) {
                 var state = response.getState(); 
                 if (state === "SUCCESS")  {  
                     var cvalue = '';
                     var ckey = '';
                     var coverageNContactList = response.getReturnValue();
                     for(var key in coverageNContactList){
                         cvalue = coverageNContactList[key];
                         if(cvalue == 'My Coverage')
                         {
                             ckey = key;
                             break;
                         }
                     }
                     console.log('ckey: '+ckey);
                     console.log('cvalue: '+cvalue);
                     
                     var saveCampaignMembers = component.get("c.addContactToCoverageNContact");
                     saveCampaignMembers.setParams({
                         contactRecordIds : selectedData ,
                         campaignId :  ckey,
                         sourceCampaignId : component.find("myContactListSelect").get("v.value"),
                         completeListSelected : component.get("v.selectAllCheckboxValue"),
                         filters : component.get("v.filterJSON")
                     });
                     saveCampaignMembers.setCallback(this,function(response) {
                             var state = response.getState(); 
                             if(state ==="SUCCESS"){
                                 var result = response.getReturnValue();
                                 //If there is no error toast success message
                                 if(result == null || result == '' || result == undefined){
                                     this.toastMessage($A.get("$Label.c.Added"),$A.get("$Label.c.Success_Message_Contact_Added_To_Contact_List"),"Success"); 
                                 }
                                 else {
                                     //If there is an error toast Error result message
                                     if(result == "isInstinetEmployee")
                                         this.toastMessage($A.get("$Label.c.Error"), $A.get("$Label.c.Error_Message_Cannot_Add_Instinet_Contact"),"error");
                                     else
                                         this.toastMessage($A.get("$Label.c.Error"),result,"error");
                                 }
                                 this.hideSpinner(component);
                             }
                             else{
                                 this.toastMessage($A.get("$Label.c.Error"),$A.get("$Label.c.Error_Message_Select_One"),"error"); 
                             }
                         });
                     $A.enqueueAction(saveCampaignMembers);     
                     
                 }
             });
             $A.enqueueAction(myContactListAction);    
         } 
         else{
             component.showMessage($A.get("$Label.c.Error"),$A.get("$Label.c.Error_Message_Select_Contact"),"error");                   
         }
     },
     toastMessage : function( title, message, type)   {
         var showToast = $A.get("e.force:showToast"); 
         showToast.setParams({ 
             'title' : title, 
             'message' : message,
             "type": type,
             "duration": 3000 
         });
         showToast.fire();
     },
     dismissComponent : function(){
         var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
         dismissActionPanel.fire(); 
     },
     getContactListOtherDetails: function(component, params, successCallback, failureCallback){
         var action = component.get("c.getContactListOtherDetails"); 
         if(params)
             action.setParams(params);
         
         action.setCallback(this, function(response){
             var state = response.getState(); 
             if (state === "SUCCESS") {
                 var result = response.getReturnValue();
                 if(!$A.util.isUndefined(result)){
                     component.set("v.contactListOtherDetails", result); 
                     component.set("v.myContactListSelect", component.get("v.contactListOtherDetails.defaultListId")); 
                     component.formRecordTemplates();
                     if (successCallback) { 
                          successCallback(); 
                      }
                 }
             }
             else {
                 alert('Error in calling server side action');
             }
         });
         
         $A.enqueueAction(action);
     },
 
     getMyContactLists: function(component, selectedId, params, successCallback){
         var action = component.get("c.getMyContactLists");
         if(params){
             action.setParams(params);
         }
         action.setCallback(this,function(a){
             component.set("v.contactLists", a.getReturnValue());
             
             // set selected my contact list
             if(selectedId != null)
             {
                 window.setTimeout(
                     $A.getCallback( function() {
                         
                         /*
                          * Checking whether given selectedId is present in output. If not present then set it to Recently Viewed.
                          */
                         var recordPresent = false;
                         var contactLists = component.get("v.contactLists");
                         for(var index = 0; index <contactLists.length; index++){
                             if(selectedId == contactLists[index].Campaign.Id){
                                 recordPresent = true;
                                 break;
                             }
                         }
                         
                         if(!recordPresent){
                             component.find("myContactListSelect").set("v.value", "1");
                         }
                         else {
                             component.find("myContactListSelect").set("v.value", selectedId);
                         }
                         //Fetch Data
                         if (successCallback) { 
                             successCallback();
                         } 
                         
                         
                     })
                 );    
             }
             else {
                 component.find("myContactListSelect").set("v.value", "1");
             }
              
         });
         $A.enqueueAction(action);
     },
     
     getRecentList: function(component, params){
         //Show Spinner
         this.showSpinner(component);
         
         var action = component.get("c.getRecentlyViewedContacts"); 
         if(params){
             action.setParams(params);
         }
         action.setCallback(this, function(a) {
              component.set("v.listMembers", a.getReturnValue()); 
             
             //Hide Spinner
             this.hideSpinner(component);
         })
         $A.enqueueAction(action);
     },
     
     getMemberCount: function(component, params){
         var action = component.get("c.getCampaignMemberCount");
         if(params){
             action.setParams(params);
         }
         
         action.setCallback(this, function(response){
             var state = response.getState(); 
             if (component.isValid() && state === "SUCCESS") {
                  component.set("v.campaignMemberCount", response.getReturnValue());
             }
             else {
                 alert('Error calling action with state: ' + response.getState());
             }
         });
         
         $A.enqueueAction(action);
     },
     
     getCampaignAccessLevel: function(component, params){
         var action = component.get("c.getCampaignAccessLevel");
         if(params){
             action.setParams(params);
         }
         
         action.setCallback(this, function(response){
             var state = response.getState(); 
             if (component.isValid() && state === "SUCCESS") {
                  component.set("v.campaignAccessLevel", response.getReturnValue());
             }
             else {
                 alert('Error calling action with state: ' + response.getState());
             }
         });
         
         $A.enqueueAction(action);
     },
     
     getCampaignMembers : function(component, params, successCallback, failureCallback){        
         this.showSpinner(component);        
        
         
         var action = component.get("c.getCampaignMembers");
         if(params){
             action.setParams(params);
         }       
         action.setCallback(this, function(response){
             this.hideSpinner(component);
             
             var state = response.getState(); 
             if (component.isValid() && state === "SUCCESS") {
                  if (successCallback) { 
                      successCallback(response.getReturnValue()); 
                  } 
            }
             else {
                 alert('Error calling action with state: ' + response.getState());
             }
         });
         
         $A.enqueueAction(action);
     },
     
     setDefaultContactListSettings : function(component, params, successCallback, failureCallback){
         var action = component.get("c.setDefaultList");
         if(params){
             action.setParams(params);
         }
         
         action.setCallback(this, function(response){
             var state = response.getState(); 
             if (component.isValid() && state === "SUCCESS") {
                  if (successCallback) { 
                      successCallback(response.getReturnValue()); 
                  } 
             }
             else if(state === "ERROR"){
                 if(failureCallback){
                     failureCallback(response.getError());
                 }                               
             }
         });
         
         $A.enqueueAction(action);
     },
     
     addCampaignMembersToList : function(component, params, successCallback, failureCallback){
         
         var action = component.get("c.addCampaignMembers");
         if(params){
             action.setParams(params);
         }
         
         action.setCallback(this, function(response){
             var state = response.getState(); 
             if (component.isValid() && state === "SUCCESS") {
                  if (successCallback) { 
                      successCallback(response.getReturnValue()); 
                  } 
             }
             else if(state === "ERROR"){
                 if(failureCallback){
                     failureCallback(response.getError());
                 }                               
             }
         });
         
         $A.enqueueAction(action);
     },
     
     removeCampaignMembersFromList : function(component, params, successCallback, failureCallback){
         var action = component.get("c.removeCampaignMembers");
         if(params){
             action.setParams(params);
         }
         
         action.setCallback(this, function(response){
             var state = response.getState(); 
             if (component.isValid() && state === "SUCCESS") {
                  if (successCallback) { 
                      successCallback(response.getReturnValue()); 
                  } 
            }
             else {
                 alert('Error calling action with state: ' + response.getState());
             }
         });
         
         $A.enqueueAction(action);
     },
     
     deleteCampaign : function(component, params, successCallback, failureCallback){
         var action = component.get("c.deleteCampaign");
         if(params){
             action.setParams(params);
         }
         
         action.setCallback(this, function(response){
             var state = response.getState(); 
             if (component.isValid() && state === "SUCCESS") {
                  if (successCallback) { 
                      successCallback(response.getReturnValue()); 
                  } 
            }
             else {
                 alert('Error calling action with state: ' + response.getState());
             }
         });
         
         $A.enqueueAction(action);
     },
     
     getCampaignMembersForCampaignId : function(component, params, successCallback, failureCallback){
         var action = component.get("c.getCampaignMembersForCampaignId");
         if(params){
             action.setParams(params);
         }
         
         action.setCallback(this, function(response){
             var state = response.getState(); 
             if (component.isValid() && state === "SUCCESS") {
                  if (successCallback) { 
                      successCallback(response.getReturnValue()); 
                  } 
            }
             else {
                 alert('Error calling action with state: ' + response.getState());
             }
         });
         
         $A.enqueueAction(action);
     },
     
     getLists : function(component, params, successCallback){
         var action = component.get("c.getCampaigns");
         if(params){
             action.setParams(params);
         }
         
         action.setCallback(this, function(response){
             var state = response.getState(); 
             if (component.isValid() && state === "SUCCESS") {
                 if (successCallback) { 
                      successCallback(response.getReturnValue()); 
                 } 
             }
             else {
                 alert('Error calling action with state: ' + response.getState());
             }
         });
         
         $A.enqueueAction(action);
     },
     
     getMassActivityList : function(component, params, successCallback){
         var action = component.get("c.getMassActivityDetails");
         if(params){
             action.setParams(params);
         }
         
         action.setCallback(this, function(response){
             var state = response.getState(); 
             if (component.isValid() && state === "SUCCESS") {
                 if (successCallback) { 
                      successCallback(response.getReturnValue()); 
                 } 
             }
             else {
                 alert('Error calling action with state: ' + response.getState());
             }
         });
         
         $A.enqueueAction(action);
     },
     
   
 })