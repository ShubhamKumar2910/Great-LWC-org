({
	doInit: function(component, event, helper) {
    	
        helper.isCapIntroUser(component);
    },
    navigateToReport : function(component, event,helper){
        
       component.set("v.whichCall","Contact");        
       component.set("v.reportAccessed",component.get("v.ContactReportName"));         
       helper.getReportDetails(component);    
        
          
    },
    navigateToCIReport : function(component, event,helper){     
        
       component.set("v.whichCall","Interactions");        
       component.set("v.reportAccessed",component.get("v.CIReportName"));         
       helper.getReportDetails(component);      
      
    },
    
    navigateToCIActivityReport : function(component, event,helper){       
       
       component.set("v.whichCall","CallReport");        
       component.set("v.reportAccessed",component.get("v.ActivityReportName"));        
       helper.getReportDetails(component);       
      
    },
    
})