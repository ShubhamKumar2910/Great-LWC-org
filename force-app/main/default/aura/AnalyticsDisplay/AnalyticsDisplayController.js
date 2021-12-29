({
	onPageReferenceChange : function(cmp, event, helper) {
		var myPageRef = cmp.get("v.pageReference");
		var dashboardName = myPageRef.state.c__DashboardName;
        if(!$A.util.isUndefinedOrNull(dashboardName)) {
			cmp.set("v.dashboardName",dashboardName);
		} else {
			console.log("Error. Dashboard name is not defined!");
		}
	}
})