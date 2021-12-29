({
	init : function(component) {
		var myPageRef = component.get("v.pageReference");
        
		if(myPageRef!=undefined && myPageRef!=null && !$A.util.isUndefinedOrNull(myPageRef.state.c__source)){
			var callingSource =  myPageRef.state.c__source;
        	console.log('--callingSource--' , callingSource);
            component.set('v.source', callingSource);
            component.set('v.isSourceAvai', true);
		}




        
		//component.set('v.source', source);
/*
		var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:BulkApproval",
            componentAttributes: {
                isApproval : "false",
				showCoverageRequestTab : "true",
				showETradingRequestTab : "false",
				showCrossSellRequestTab : "false",
				showPendingRequests : "true",
				source : callingSource            
            }
        });
        evt.fire();*/
	},
})