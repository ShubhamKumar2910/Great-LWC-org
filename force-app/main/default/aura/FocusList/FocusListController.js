({
	handleRecordUpdated: function(component, event, helper) {
    	var eventParams = event.getParams();
        //Once record is loaded
        if(eventParams.changeType === "LOADED"){
            
            var focusList = new Array();
            
            //Fetch the value for Focus List and Flag
            var strFocusList = component.get("v.simpleAccountViewRecord.Focus_List__c");
            
            if(!$A.util.isUndefined(strFocusList) && !$A.util.isEmpty(strFocusList)){
                focusList = strFocusList.split(',');
                if(!$A.util.isUndefined(focusList) && focusList.length > 0){
                    focusList.sort();
                    //Remove Duplicates
                	focusList = focusList.filter(function(elem, pos) {
    					return focusList.indexOf(elem) == pos;
					}); 
                }
            }
            
            component.set("v.focusList", focusList);
            
        }
    }
})