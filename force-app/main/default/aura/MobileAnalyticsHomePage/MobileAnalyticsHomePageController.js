({
    onInit : function(component) {
        console.log("In init event for mobile analytics homepage");
        var action = component.get("c.getDefaultDashboardName");
        console.log("action");
        console.log(action);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var dashboard = response.getReturnValue();
                console.log(dashboard);
                var dashboard_developer_name = "unknown";
                //translate the home page dashboard to the mobile version.  
                if ("My_Scorecard" === dashboard) {
                    dashboard_developer_name="My_Sales_Mobile";
                } else if ("Team_Scorecard" === dashboard || "Summary" === dashboard) {
                    dashboard_developer_name="Team_Sales_Mobile";
                } else if ("Team_Scorecard_Team_Only" === dashboard) {
                    dashboard_developer_name = "Team_Without_Salesperson_Revenue_Mobile2";
                } else if ("Covered_Client_Scorecard" === dashboard || "Equity_Scorecard_Details"=== dashboard) {
                    dashboard_developer_name = "Mobile_Equity_Scorecard";
                } else {
                    console.log("Error message: default mobile scorecard for home page not set for users desktop version of " + dashboard);
                }
                console.log('using dashboard ' + dashboard_developer_name);
                component.set("v.dashboardDeveloperName", dashboard_developer_name);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
        // var readyToPrintDbrdEvent = $A.get("e.c:ReadyToPrintDbrdEvent");
        // console.log("got event "+ readyToPrintDbrdEvent);
        // readyToPrintDbrdEvent.fire();
        // console.log("Print button fired ready event");
        
    }
})