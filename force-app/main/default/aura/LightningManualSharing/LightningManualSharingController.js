({
	doInit : function(component, undefined, helper) {
        console.log('in doinit');
        var device = $A.get("$Browser.formFactor");
        if(device !== 'PHONE'){
            $A.util.removeClass(component.find('mainContainer'), 'slds-hide');
            helper.reload(component);
            $A.util.addClass(component.find('infoDiv'), 'slds-hide');
        }
        else{
            $A.util.addClass(component.find('mainContainer'), 'slds-hide');
            $A.util.removeClass(component.find('infoDiv'), 'slds-hide');
        }
            
	},

	stopProp : function(component, event) {
		event.stopPropagation();
	},

	delete : function(component, event, helper) {
		let action = component.get("c.deletePerm");
		action.setParams({
			"UserOrGroupID" : event.target.id,
			"recordId" : component.get("v.recordId")
		});
		action.setCallback(this, function(a){
			let state = a.getState();
			if (state === "SUCCESS") {
				helper.reload(component);
			} else if (state === "ERROR") {
				//console.log("error:");
				//console.log(a.getError());
				let appEvent = $A.get("e.c:manualSharingHandleCallbackError");
				appEvent.setParams({
					"errors" : a.getError()
				});
				appEvent.fire();
			}
		});
		$A.enqueueAction(action);
	},

	setRead : function(component, event, helper) {
		let id = event.target.id;
		helper.commonUpsert(component, id, "Read");
	},

	setReadWrite : function(component, event, helper) {
		let id = event.target.id;
		helper.commonUpsert(component, id, "Edit");
	},

	search : function(component, undefined, helper){
		let searchString = component.find("search").get("v.value");
		if (searchString.length<=2){
			component.set("v.results", []);
			return; //too short to search
		}
		let searchObject = component.find("searchPicklist").get("v.value");
		let action= component.get("c.doSOSL");
		action.setParams({
			"searchStringParameter" : searchString,
			"objectType" : searchObject
		});

		action.setCallback(this, function(a){
			let state = a.getState();
			if (state === "SUCCESS") {
				let result = JSON.parse(a.getReturnValue());
				//console.log(result);
				//cleanup for userTypes
				if (searchObject === 'User' || searchObject === 'user' ){
					let correctedResults = [];
					for (let u of result){
						u.Type = helper.translateTypes(u.UserType);
						correctedResults.push(u);
						//console.log(u);
						component.set("v.results", correctedResults);
					}
				} else {
					component.set("v.results", result);
				}
			}  else if (state === "ERROR") {
				let appEvent = $A.get("e.c:manualSharingHandleCallbackError");
				appEvent.setParams({
					"errors" : a.getError()
				});
				appEvent.fire();
			}
		});
		$A.enqueueAction(action);
	}
})