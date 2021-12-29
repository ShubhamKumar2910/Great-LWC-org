({
    
    init: function(component,event, helper) {
        console.log('*****Initialise Start**** ');   
        helper.initialiseEventFields(component);
       
    },
    
sendEmailNotification: function(component,event,helper){
      helper.sendEmail(component,event); 
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
    AddSelectedUsers : function(component,event,helper){
        helper.displaySelectedUsers(component,event);
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
    
    
   
})