({
    handleRecordUpdatedProfile: function(component, event, helper) {
        var eventParams = event.getParams();
        console.log("In handleRecordUpdatedProfile with event param "+ eventParams.changeType);
        if(eventParams.changeType === "LOADED") {
           // record is loaded (render other component which needs record data value)
            // console.log("You loaded a record in " + component.get("v.accountRecord.RDM_Org_ID__c"));
            var action = component.get("c.getUserProfileName");
            var rdmOrgId = component.get("v.accountRecord.RDM_Org_ID__c");
            // console.log("rdmOrgId "+ rdmOrgId);
            var dashboardFilter ="{'datasets':{'ClientRevenue':[{'fields':['RG_Id__c'], 'filter':{'operator': 'matches', 'values':['" + rdmOrgId + "']}}],'ClientRevenueTrending':[{'fields':['RG_Id__c'],'filter':{'operator':'matches','values':['" + rdmOrgId + "']}}],'AccountGroupRevenue':[{'fields':['RDM_Org_ID__c'],'filter':{'operator':'matches','values':['" + rdmOrgId + "']}}]}}";
            component.set("v.dashboardFilter", dashboardFilter);
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "ERROR") {
                    var errors = response.getError();
                    helper.handleErrors(errors);
                } else if (state === "SUCCESS") {
                    var profileName =  response.getReturnValue();
                    var dash = "Top_Line_Revenue";
                    console.log("profileName "+ profileName);
                    component.set("v.showDashboard",false);
                    //if the default hasn't been set on the analytic user default object, our client will provide a default value.
                    if ("Nomura - Corporate Access" !== profileName && "Nomura - Research" !== profileName) {
                        dash="Client_Scorecard";
                        component.set("v.showDashboard",true);
                    }
                    component.set("v.dashboardName", dash);
                    if("Client_Scorecard" === dash) {
                        component.set("v.dashboardHeight", 820);
                    } else {
                        component.set("v.dashboardHeight", 450);
                    }

                    if ("Top_Line_Revenue" === dash ) {
                        var context = {apiVersion: "46.0"};
                        var method = 'listFolders';
                        var methodParameters = {
                            'pageSize' : 200};
                        var sdk = component.find("sdk");
                        var folders = [];
                        console.log("invoking sdk method listFolders with sdk "+ sdk);
                        sdk.invokeMethod(context, method, methodParameters,
                            $A.getCallback(function (err, data) {
                                console.log("In callback for sdk");
                                if (err !== null) {
                                    //DO THIS IF THE METHOD FAILS
                                    console.error("SDK Error",err);
                                    var errorPayload = JSON.parse(JSON.stringify(err));
                                    var errors = [ errorPayload[0]];
                                    helper.handleErrors(errors);
                                } else {
                                    //DO THIS IF THE METHOD SUCCEEDS
                                    var payload = JSON.parse(JSON.stringify(data.folders));
                                    for (var i = 0; i < payload.length; i++) {
                                        // console.log("dashboard "+ i + ": "+ payload[i].name);
                                        if ("Account_Revenue_Summary" === payload[i].name) {
                                            component.set("v.showDashboard",true);
                                            // console.log("Account_Revenue_Summary found");
                                            break;
                                        }
                                    }
                                }
                                // console.log("after checking data and err object");
                            }));
                
                    }
               } else {
                   console.log("did not return a record from getDefaultClientScorecard.  state "+ state);
               }
            });
            $A.enqueueAction(action);
        }  else {
            console.log("eventParam was in state of "+ eventParams.changeType);
        }
    },
})