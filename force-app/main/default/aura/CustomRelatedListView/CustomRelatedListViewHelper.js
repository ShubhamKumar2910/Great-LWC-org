({
    captureLastViewedRecord : function(component) {
        let action = component.get( "c.captureLastViewedRecord" );
        
        action.setParams( { recordId : component.get( "v.recordId" ), customSettingsFieldName : component.get( "v.customSettingsFieldName") } );
        
        action.setCallback( this, ( response ) => { 
            if( response.getState() === "SUCCESS" && 
            	response.getReturnValue() ) {
            	//$A.get( "e.force:refreshView" ).fire();
        	}
        } );

        $A.enqueueAction(action);
    },

    checkUserPermission : function(component) {
        let action = component.get( "c.checkUserPermission" );
                
        action.setCallback( this, function( response ) {
            console.log('response value: ' +  response.getReturnValue());
            if( response.getState() === "SUCCESS" )
            	component.set("v.nonRestrictedUser", response.getReturnValue())
        });

        $A.enqueueAction(action);
    }
})