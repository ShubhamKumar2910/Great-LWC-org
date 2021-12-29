({
    
    init: function(component,event, helper) {
        console.log('*****Initialise Start**** ');   
        helper.initialiseEventFields(component);
        helper.FetchInvitees(component);
        helper.FillRegionDropDowns(component);
    },
    sendEmailToSelf: function(component,event,helper){
        helper.sendmailToSelf(component);
    },
    
    checkContacts: function(component,event,helper){
      var includesInstinetContacts = false;
        helper.checkInstinetContacts(component, includesInstinetContacts);

      //helper.sendEmail(component, includesInstinetContacts); 
    },   
    
    sendEmailNotification: function(component,event,helper){
        helper.sendEmail(component); 
      },  
	 
    FetchRecipientsBasedOnSelection : function(component,event,helper){
        helper.FetchRecipients(component);
    },
    
    RemoveSelectedRecipients : function(component,event,helper){
       helper.RemoveSelectedRecipients(component,event)  
    },
    getUserDetailsFromLookup : function(component,event,helper){
         helper.getUserDetails(component,event);
    },
    
    cancel : function(component,event,helper){
        helper.cancelAndReturn(component,event);
    },
      showSpinner : function(component,event) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },
    /*-2.2--- HIDE SPINNER-------------------------------------*/
    hideSpinner : function(component,event) {
        var cmpTarget = component.find('spinnerblock');
        $A.util.addClass(cmpTarget, 'slds-hide');
    },
    
     OnCheck: function(component, event) {
         component.set('v.AddContactCoverage',event.getSource().get("v.checked"));
     },
     closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "False"  
        component.set("v.isOpen", false);
     },
    handleToastClose: function(component) {
        component.set("v.isSuccess",false);
        component.set("v.SuccessMessage",'');
        component.set("v.isError",false);
        component.set("v.ErrorMessage",'');
    }
})