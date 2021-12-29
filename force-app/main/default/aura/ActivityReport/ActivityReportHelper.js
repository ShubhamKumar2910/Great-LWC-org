({
    getReportDetails: function(component){
        var action = component.get("c.getActivityReportIdRecordName");
        
        console.log('in getReportDetails');
        console.log(component.get("v.reportAccessed"));
        console.log(component.get("v.recordId"));
        
        action.setParams({"reportName" : component.get("v.reportAccessed"),
                          "recordId" : component.get("v.recordId"),
                          "whichCall" : component.get("v.whichCall")});
        
        
        action.setCallback(this, function(response){
            var state = response.getState(); 
            console.log(state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(!$A.util.isUndefined(result)){
                    console.log('result');
                    console.log(result);
                    component.set("v.reportId", result);
                    
                    var reportId = component.get("v.reportId");
                    var selectedId = component.get("v.recordId");
                    var selectedAccountName  = reportId.split('##')[1];                
                    
                    if(selectedId != undefined && selectedId != null &&
                       reportId != undefined && reportId != null)
                    {
                        var customizedAccountId = selectedId
                        var reportIdActual = reportId.split('##')[0];
                        
                        var reportType;
                        var reportURL;
                        
                        
                        if(component.get("v.whichCall")==="Interactions"){
                          reportType = "CI Interactions";
                          reportURL = "/one/one.app#/sObject/" +reportIdActual+ "/view?fv0=" + reportType + "&fv1=" + selectedAccountName + "&fv2=" + reportId.split('##')[2]  ;
                        }
                        else if(component.get("v.whichCall")==="CallReport"){
                          reportType = "Call Report/Notes";
                          reportURL = "/one/one.app#/sObject/" +reportIdActual+ "/view?fv0=" + reportType + "&fv1=" + selectedAccountName  ;
                        }
                        
                       else if(component.get("v.whichCall")==="Contact"){
                          var customizedContactId = selectedId.substring(0,15);
                           reportURL = "/one/one.app#/sObject/" + reportIdActual + "/view?fv0=" + customizedContactId;
                        }
                        
                        
                        
                        console.log('reportURL');
                        console.log(reportURL);
                        
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": reportURL,
                            "isredirect ":true
                        });
                        urlEvent.fire();
                    }
                }
            }
            else {
                alert('Error in calling server side action');
            }
        });
        
        $A.enqueueAction(action);
    },
    
    isCapIntroUser :  function(component){
        console.log('in cap intro use function');
        var action = component.get("c.isCapIntro");
        
        
        action.setParams({"recordId" : component.get("v.recordId")});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var responseMap = response.getReturnValue();
                component.set("v.isCapIntro",responseMap);
                console.log('isCapIntro');
                console.log(component.get("v.isCapIntro"));              
                
            }
        });
        $A.enqueueAction(action);
    } 
})