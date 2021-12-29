({
    loadCoverageNContact : function(component) {
        var action = component.get("c.getMyContactLists");
        action.setCallback(this,function(response) {
            var state = response.getState(); 
            if (state === "SUCCESS")  {  
                var custs = [];
                var coverageNContactList = response.getReturnValue();
                for(var key in coverageNContactList){
                    custs.push({value:coverageNContactList[key], key:key});
                }
                console.log(coverageNContactList);
                component.set("v.checkList",custs);
            }
        });
        $A.enqueueAction(action);
    },
    
    
    
    addContactToCoverageNContact : function(component) {
        var campaignIds = (component.find("select").get("v.value")).split(";");
        console.log(campaignIds);
        var action = component.get("c.addContactToCoverageNContact");
        var contactRecordId =component.get("v.recordId");
        
        
        
        action.setParams({
            contactRecordId : contactRecordId ,
            campaignIdList :  campaignIds 
        });
        
        
        
        action.setCallback(this,function(response) {
            var state = response.getState(); 
            if(state ==="SUCCESS"){
                var result = response.getReturnValue();
                //If there is no error toast success message
                if(result == null){
                    this.toastMessage("Contact Added","Contact Added To List(s)","Success"); 
                    this.dismissComponent();
                }
                else {
                    //If there is an error toast Error result message
                    if(result == "isInstinetEmployee")
                        this.toastMessage("Error", "Cannot add Instinet Contact to List","error");
                    else
                        this.toastMessage("Error",result,"error");
                    this.dismissComponent(); 
                }
                
            }
            else{
                this.toastMessage("Error","Please Select Atleast One","error"); 
            }
        });    
        
        $A.enqueueAction(action);
    },
    toastMessage : function( title, message, type)   {
        var showToast = $A.get("e.force:showToast"); 
        showToast.setParams({ 
            'title' : title, 
            'message' : message,
            "type": type,
            "duration": 3000 
        });
        showToast.fire();
    },
    dismissComponent : function(){
        var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
        dismissActionPanel.fire(); 
    }
})