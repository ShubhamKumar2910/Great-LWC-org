({
    init : function(cmp, helper, evt){
        console.log('--in init--');
        var acctId = cmp.get('v.recordId');  
        
        var myPageRef = cmp.get("v.pageReference");
        
        if(myPageRef!=undefined && myPageRef!=null && !$A.util.isUndefinedOrNull(myPageRef.state.c__recordId)){
        	var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef: "sfa:hierarchyFullView",
                componentAttributes: {
                    recordId: myPageRef.state.c__recordId,
                    sObjectName: "Account"
                }
            });
            evt.fire();
        }
        
    }
    
});