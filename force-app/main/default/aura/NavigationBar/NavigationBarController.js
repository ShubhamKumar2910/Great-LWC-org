({
    doInit: function(component, event, helper){
        helper.getCurrentUserDetails(component);

    },
    
    //for handling Default click of an button
    handleMenuSelect: function(component, event, helper){
        var menuURLValue = event.getParam("menuURL");
        var currentUserdetails = component.get('v.currentUserDetails'); 
        console.log(menuURLValue);
        if(menuURLValue.includes("/lightning/n/Coverage"))
        {
            console.log('In my coverage menu url');
             component.openTab("Coverage"); 
        } else if (menuURLValue.includes("/lightning/n/Contact_Locator")){
            component.openTab("Locate_Contact");             
        }
        else if(menuURLValue.includes("/lightning/n/Event_Call_Report") && !currentUserdetails.isJapanFIUser){
            //component.openPage("/lightning/n/Event_Call_Report");
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:EventCallReport",
                componentAttributes: {
                    isClientMemo : false
                    
                }
            });
            evt.fire();
        }
        else if(menuURLValue.includes("/lightning/n/Event_Call_Report") && currentUserdetails.isJapanFIUser){
            //component.openPage("/lightning/n/Event_Call_Report");
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:EventCallReport",
                componentAttributes: {
                    isClientMemo : true
                    
                }
            });
            evt.fire();
        }
        else
        {
			component.openPage(menuURLValue);            
        }

    },
    
    //for handling menu button click
    handleMenuItemSelect: function(component, event, helper){
        var itemindex = event.getParam("itemindex");
        var itemvalue = event.getParam("itemvalue");
        
        if(itemvalue == $A.get("$Label.c.Label_My_Coverage_Group_Level")){
        	component.openTab("Coverage");            
        }
        else if(itemvalue == $A.get("$Label.c.Label_All_Coverage_Group_Level")){
           component.openTab("Global_Coverage");            
        }
        else if(itemvalue == $A.get("$Label.c.Upload_Bulk_Coverages")){
			component.openPage("/apex/CoverageBulkUpload");
        }
        else if(itemvalue == $A.get("$Label.c.Home_Contact_Locator")){
            component.openTab("Locate_Contact"); 
		}
		else if(itemvalue == $A.get("$Label.c.Home_New_Contact")){
			component.openPage("/003/e?");
		}
        else if(itemvalue == $A.get("$Label.c.CVGTOOL_PENDING_APPROVALS")){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:BulkApproval",
                componentAttributes: {
                    isApproval : true
                    
                }
            });
            evt.fire();
       }
       else if(itemvalue == $A.get("$Label.c.CVGTOOL_PENDING_REQUEST")){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:BulkApproval",
                componentAttributes: {
                    isApproval : false
                    
                }
            });
            evt.fire();
       }
       else if(itemvalue === "Contact - "+$A.get("$Label.c.Desk_Commentary_Label")){
    	   var evt = $A.get("e.force:navigateToComponent");
    	   evt.setParams({
    		   componentDef : "c:BulkUpdateDeskCommentaryProhibited",
    		   componentAttributes: {
    			   isApproval : false
			   }
    	   });
    	   evt.fire();
       }
       else if(itemvalue == 'Contact - MiFID-II Flags'){
           var evt = $A.get("e.force:navigateToComponent");
    	   evt.setParams({
    		   componentDef : "c:Mifid2InScopeBulkUpdate",
    		   componentAttributes: {
    			   isApproval : false
			   }
    	   });
    	   evt.fire();	       
       }
        else if(itemvalue == 'Create Call Report'){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:EventCallReport",
                componentAttributes: {
                    isClientMemo : false
                    
                }
            });
            evt.fire();
        }
        else if(itemvalue == 'Create Client Memo'){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:EventCallReport",
                componentAttributes: {
                    isClientMemo : true
                    
                }
            });
            evt.fire();
        }
        else if(itemvalue === $A.get("$Label.c.Bulk_Movement_Contact")){
            component.openTab("Bulk_Contact_Movement"); 
        }
    },
    
    // openNewEvent : function(component, event, helper) {
    //     component.openPage("/lightning/n/Event_Call_Report");
    // },
    
    openEEnablement : function(component, event, helper) {
        component.openPage("/lightning/n/ETradingEnablementHome");
    },
    
    openPage : function(component, event){
        var params = event.getParam('arguments');
        if(params){
            var strURL = params.strURL;
            if(strURL != null){
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": strURL
                });
                urlEvent.fire();
            }             
        }
    },
    
    openTab : function(component, event){
        var params = event.getParam('arguments');
        if(params){
            var tabName = params.tabName;
            if(tabName == "Coverage"){
                component.find("navService").navigate({
                    "type": "standard__navItemPage",
                    "attributes": {
                        "apiName" : "Coverage" 
                    },
                    "state":{
                        "c__reset" : true
                    }
                }, false);
            }
            else if (tabName == "Global_Coverage"){
                component.find("navService").navigate({
                    "type": "standard__navItemPage",
                    "attributes": {
                        "apiName" : "Global_Coverage" 
                    },
                    "state":{
                        "c__reset" : true
                    }
                }, false);
            }
            else if(tabName == "Locate_Contact"){
               component.find("navService").navigate({
                    "type": "standard__navItemPage",
                    "attributes": {
                        "apiName" : "Locate_Contact" 
                    },
                    "state":{
                        "c__reset" : true
                    }
                }, false);
            }
            else if(tabName == "Bulk_Contact_Movement"){
               component.find("navService").navigate({
                    "type": "standard__navItemPage",
                    "attributes": {
                        "apiName" : "Bulk_Contact_Movement" 
                    },
                    "state":{
                        "c__reset" : true
                    }
                }, false);
            }              
        }
    }
    
})