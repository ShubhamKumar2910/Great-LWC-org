({
	getResearchDetails : function(component) {
		var action = component.get("c.getResearchDetails");
        var contactRecordId = component.get("v.recordId");  
        action.setParams({
            contactRecordId : contactRecordId
        });
        
        action.setCallback(this, function(response){
            var state = response.getState(); 
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(!$A.util.isUndefined(result)){
                    component.set("v.researchDetails",result);
                }
            }
            else {
                alert('Error in calling server side action');
            }
        });
        
        $A.enqueueAction(action);
	},
    
    initializeLabels : function(component) {
        var action = component.get("c.initializeLabels");
        
        action.setCallback(this, function(response){
            var state = response.getState(); 
            if (state === "SUCCESS") {
                var responseMap = response.getReturnValue();
                for(var keyStr in responseMap){
                    if(responseMap.hasOwnProperty(keyStr)){
                        var innerFieldMap = responseMap[keyStr];
                        for(var fieldStr in innerFieldMap){
                            if(keyStr == 'Contact' && fieldStr == 'GRP_Access__c'){
                                component.set("v.grpAccessLabel", innerFieldMap[fieldStr]);
                            }
                            if(keyStr == 'Contact' && fieldStr == 'Preferred_Language__c'){
                                component.set("v.preferredLanguageLabel", innerFieldMap[fieldStr]);
                            }
                            if(keyStr == 'Contact' && fieldStr == 'Region__c'){
                                component.set("v.regionLabel", innerFieldMap[fieldStr]);
                            }
                            if(keyStr == 'Contact' && fieldStr == 'Investor_Type__c'){
                                component.set("v.investorTypeLabel", innerFieldMap[fieldStr]);
                            }
                            if(keyStr == 'Contact' && fieldStr == 'Sales_Sponsor__c'){
                                component.set("v.salesSponsorLabel", innerFieldMap[fieldStr]);
                            }
                            if(keyStr == 'Contact' && fieldStr == 'Sponsor_Email_Text__c'){
                                component.set("v.sponsorEmailTextLabel", innerFieldMap[fieldStr]);
                            }
                            if(keyStr == 'Contact' && fieldStr == 'MiFIDII_in_Scope__c'){
                                component.set("v.miFIDIIInScopeLabel", innerFieldMap[fieldStr]);
                            }
                            if(keyStr == 'Contact' && fieldStr == 'MiFIDII_Sales_Commentary_Allowed__c'){
                                component.set("v.miFIDIISalesCommentaryAllowedLabel", innerFieldMap[fieldStr]);
                            }
                            
                        }
                    }
                }
                
            }
            else {
                alert('Error in calling server side action');
            }
        });
        
        $A.enqueueAction(action);
    },
    refresh : function(component, event, helper) {
        var action = component.get('c.ResearchDetailsController');
        action.setCallback(component, 
            function(response) { 
                var state = response.getState();
                if (state === 'SUCCESS'){ 
                    $A.get('e.force:refreshView').fire();  
                } else { 
    
                } 
            } 
        ); 
        $A.enqueueAction(action); 
    } 

})