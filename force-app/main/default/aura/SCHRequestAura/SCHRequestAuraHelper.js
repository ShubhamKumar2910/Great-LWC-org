({
    initialize : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var selectedEntityExternalId = null;
        var inputEntityName = null;
        var inputEntityLocation = null;
        var callingSource = null;

        var pageRef = component.get("v.pageReference");
        if(!$A.util.isEmpty(pageRef))
        {
            if(pageRef.state.c__selectedEntityExternalId){
                selectedEntityExternalId = pageRef.state.c__selectedEntityExternalId;
            }
            

            if(pageRef.state.c__rmEntitySearchStr) {
                inputEntityName = pageRef.state.c__rmEntitySearchStr;
            }
            

            if(pageRef.state.c__rmEntityLocationSearch) {
                inputEntityLocation = pageRef.state.c__rmEntityLocationSearch;
            }
            

            if(pageRef.state.c__callingSource) {
                callingSource = pageRef.state.c__callingSource;
            }
            
            if(pageRef.state.hasOwnProperty('c__recordId')) {
                recordId = pageRef.state.c__recordId;
            }
            else {
                recordId = component.get("v.recordId");
            }
                
            

        }
        
        component.set("v.recordId", recordId);
        component.set("v.selectedEntityExternalId", selectedEntityExternalId);
        component.set("v.inputEntityName", inputEntityName);
        component.set("v.inputEntityLocation", inputEntityLocation);
        component.set("v.callingSource", callingSource);
        
        component.find('schTool').refreshSearchedAccountsDetails();
        
        if(component.get("v.callingSource") !== 'SCHRequest'){
            component.find('schTool').setDefaultValues();
        }

        
    }
})