({
    init : function(component, event, helper){
        
        //Initialise Column Headers
        helper.checkColumnVisibilityRestrictions(component);
        helper.initialiseTableHeaders(component);
        helper.initialiseBaseURL(component);
        console.log('----init---');
        var myPageRef = component.get("v.pageReference");    
        //updated for critical update
        component.set("v.reset", myPageRef.state.c__reset);
        console.log("reset: " + component.get("v.reset"));
    },
    
    reInit : function(component, event, helper){
        console.log('----reInit---');
        var myPageRef = component.get("v.pageReference");  
        
        console.log(myPageRef.attributes.componentName);
         //updated for critical update
        component.set("v.reset", myPageRef.state.c__reset);
        console.log("reset: " + component.get("v.reset"));
        
        
        
        if(component.get("v.reset") || (component.get("v.reset") === undefined && myPageRef.attributes.componentName == undefined)){
            component.resetPage(component, event, helper);
        }
        
    },
    
    resetPage : function(component, event, helper){
        console.log('----resetPage---');
       	var searchInput = component.find("seachBox");
        searchInput.set("v.value","");
        component.set("v.contactWrapper", null);
    },
    
    search : function(component, event, helper) {
        
        helper.searchContacts(component);
        
    },
    
    redirectToDetail : function(component, event, helper) { 
        var url_id = event.srcElement.dataset.url;
        var tab_name = event.srcElement.dataset.name;
        sforce.console.openConsoleUrl(null,url_id, true, [tab_name, '', 'Salesforce', ''], ['', '', 'externalUrl', '']); 
    },
    
    onSearchStringChange : function(component, event, helper) { 
        //When Enter is pressed
        if(event.getParams().keyCode == 13){
            
            helper.searchContacts(component);
            
        }
    },
    
    /*
    New Coverage Tool Navigation

    navigateToAddCoverage : function(component, event, helper){
         var target = event.getSource(); 
        var accountRecordId = target.get("v.value") ;
        console.log(accountRecordId);
        
        
        
        
        var pageReference = {
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'coverageView'
            },
            state: {
                "c__operation": 'add',
                "c__accountLookupId": accountRecordId,
            }
        };
        
        component.set("v.pageReference", pageReference);
        
        var navService = component.find("navService");
        var pageReference = component.get("v.pageReference");
        navService.navigate(pageReference)
        
    }*/
    
    navigateToAddCoverage : function(component, event, helper){
        var target = event.getSource(); 
       var accountRecordId = target.get("v.value") ;
       console.log(accountRecordId);
       
       
       
       
       var pageReference = {
           type: 'standard__component',
           attributes: {
               componentName: 'c__coverageToolAdd'                                
           },
           state : {
               "c__source" : "ContactLocator",
               "c__reset" : true,
               "c__accountLookupId": accountRecordId
               
           }
       };
       /*var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__ToolUnderMaintenance'                                
            },
            state : {
                "c__source" : "ContactLocator",
                "c__reset" : true,
                "c__accountLookupId": accountRecordId
                
            }
        };*/
       component.set("v.pageReference", pageReference);
       
       var navService = component.find("navService");
       var pageReference = component.get("v.pageReference");
       navService.navigate(pageReference)
       
   }

    
})