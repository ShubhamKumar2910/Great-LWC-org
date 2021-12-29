({
    createWaveComponent: function(component, AccId) {
        var filterString = "{'datasets':{'ClientRevenue':[{'fields':['RG__c'],'filter':{'operator':'matches','values':['"+AccId+"']}}]}}";
        $A.createComponent(
            "wave:waveDashboard",{
                "recordId" : component.get("v.recordId"),
                "developerName": "Topline_Client_Scorecard",
                "height": "84",
                "hideOnError" : true,
                "showHeader": false,
                "showTitle": false,
                "showSharing":false,
                "openLinksInNewWindow":false,
                "filter":filterString
            },
            function(newcomponent){
                if (component.isValid()) {            
                    component.set("v.body", newcomponent);      
                }
            } 
        );
    }
})