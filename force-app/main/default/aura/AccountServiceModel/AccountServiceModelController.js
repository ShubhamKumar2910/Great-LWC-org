({
    doInit : function(component, event, helper){
        console.log("in doInit");
         
        helper.initialiseASMLabels(component);
        helper.populateModels(component);
    	helper.populateCallReportType(component);
        helper.populateContactCount(component);
        helper.populateDealAxisEventType(component);
       // helper.populateDealAxisEventMeetingType(component);
                
        console.log("doInit finished");
    },
    
    saveButton : function(component, event, helper){
        helper.saveRecords(component);
    },
    
    cancelButton : function(component, event, helper){
       helper.cancelClicked(component);
    }   
})