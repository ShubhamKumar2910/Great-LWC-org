({
    getCurrentUserDetails : function(component) {
        var action = component.get("c.getCurrentUserDetails");
        
        action.setCallback(this, function(response){
            var state = response.getState(); 
          
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(!$A.util.isUndefined(result)){
                    component.set("v.currentUserDetails",result);
                    this.getCoverageSubMenuValues(component);
                }
            }
            else {
                alert('Error in calling server side action');
            }
        });
        
        $A.enqueueAction(action);
    },
    
    getCoverageSubMenuValues : function(component) {
                
        var action = component.get("c.getCoverageOptionvisibility");        
        action.setCallback(this,function(response){
        	var state = response.getState(); 
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(!$A.util.isUndefined(result)){
                    if(!$A.util.isUndefined(result.profileViewSetting)){
                        var profileSetup = result.profileViewSetting;
                        var coveragebuttonsRolesVisibilityList = result.coveragebuttonsRolesVisibilityList;
                        var roleName = result.roleName;
                        
                        var arrVal = profileSetup.split('#');
                        const coverageSubMenuValues = [];
                        for(var s=0; s< arrVal.length; s++){
                            var push = true;
                            if(coveragebuttonsRolesVisibilityList.includes(roleName) && $A.get(arrVal[s])=='Coverage')
                                push = false;
                            
                            if(push)
                                coverageSubMenuValues.push($A.get(arrVal[s]));                         
                        }
                        if(!coverageSubMenuValues.includes('Coverage')){
                            component.find("coveragedropDown").set('v.menuURL','/lightning/n/Global_Coverage');
                        }
                        component.set('v.coverageSubMenuValues', coverageSubMenuValues);
                    }
                }
                this.getContactSubMenuValues(component);
             }
        });
        $A.enqueueAction(action);   
    },
    
    getContactSubMenuValues : function(component) {
        const contactSubMenuValues = [
            $A.get("$Label.c.Home_Contact_Locator"),
            $A.get("$Label.c.Home_New_Contact")
        ];
        component.set('v.contactSubMenuValues', contactSubMenuValues);
        this.getBulkUpdateSubMenuValues(component);
    },
      
    getBulkUpdateSubMenuValues : function(component) {
        /*//Commented
        const bulkUpdateSubMenuValues = [
        	"Contact - MiFID-II Flags", "Contact - "+$A.get("$Label.c.Desk_Commentary_Label")];
        component.set('v.bulkUpdateSubMenuValues', bulkUpdateSubMenuValues);
        */
        
        //Adding upload bulk csv button as sub menu item - sagar
        //Change - JIRA 2960 Start
        var currentUserdetails = component.get('v.currentUserDetails');
        if(!$A.util.isUndefinedOrNull(currentUserdetails.showUploadBulkMenuButton))
        {
            if(currentUserdetails.isMiFID_ResearchAdmin)
            {
                const bulkUpdateSubMenuValues = [
                    "Contact - MiFID-II Flags", "Contact - "+$A.get("$Label.c.Desk_Commentary_Label")];
                component.set('v.bulkUpdateSubMenuValues', bulkUpdateSubMenuValues);
            }
            if(currentUserdetails.showUploadBulkMenuButton)
            {
                
                console.log($A.get("$Label.c.Upload_Bulk_Coverages"));
                var submenus =  component.get('v.bulkUpdateSubMenuValues');
                submenus.push($A.get("$Label.c.Upload_Bulk_Coverages"));
                component.set('v.bulkUpdateSubMenuValues',submenus);
                var bulkuploadComponent = component.find('bulkupload');
                console.log(bulkuploadComponent);
        		if(!currentUserdetails.isMiFID_ResearchAdmin){
                    bulkuploadComponent.set('v.menuURL','/apex/CoverageBulkUpload');
                }
            }

            //Adding for Bulk Movement Contact
            var submenus =  component.get('v.bulkUpdateSubMenuValues');
            submenus.push($A.get("$Label.c.Bulk_Movement_Contact"));
            component.set('v.bulkUpdateSubMenuValues',submenus);                
        }   
        //Change - JIRA 2960 End

        this.getCallReportMenuValues(component);
    },

    getCallReportMenuValues : function(component){
        const callReportMenuValues = [
            "Create Call Report",
            "Create Client Memo"
        ];
        component.set('v.callReportMenuValues', callReportMenuValues);
    }
})