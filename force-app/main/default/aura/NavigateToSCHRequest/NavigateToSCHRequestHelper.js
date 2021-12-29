({
    initialize : function(component, event, helper) {
        
        var recordId = null;
        var selectedEntityExternalId = null;
        var selectedEntityUltimateParentExternalId = null;
        var inputEntityName = null;
        var inputEntityLocation = null;

        var pageRef = component.get("v.pageReference");
        if(!$A.util.isEmpty(pageRef))
        {
            if(pageRef.state.c__recordId){
                recordId = pageRef.state.c__recordId;
            }
            

            if(pageRef.state.c__selectedEntityExternalId) {
                selectedEntityExternalId = pageRef.state.c__selectedEntityExternalId;
            }

            
            if(pageRef.state.c__inputEntityName){
                inputEntityName = pageRef.state.c__inputEntityName;
            }
            

            if(pageRef.state.c__inputEntityLocation){
                inputEntityLocation = pageRef.state.c__inputEntityLocation;
            }
            
        }

        component.set("v.recordId", recordId);
        component.set("v.selectedEntityExternalId", selectedEntityExternalId);
        component.set("v.inputEntityName", inputEntityName);
        component.set("v.inputEntityLocation", inputEntityLocation);

        if(recordId !== undefined && recordId !== null && recordId !== ''){
            component.find('schRequestSubmission').refreshSCHRequestDetails();
        }
        else {
            component.find('schRequestSubmission').refreshInputtedDetails();
        }
    }
})