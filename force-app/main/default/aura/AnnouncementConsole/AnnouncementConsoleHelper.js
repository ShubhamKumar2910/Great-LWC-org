({
	init : function(component, event, helper) {
		console.log("#### AnnouncementConsoleHelper.init()");
		component.set("v.subscription", null);
		component.set("v.notificationMessageList", []);
		// Register error listener for the empApi component.
		const empApi = component.find("empApiId");
		// Error handler function that prints the error to the console.
        const errorHandler = function (message) {
            console.error("Received error ", JSON.stringify(message));
            helper.onReceiveNotification(component, message);
        };
        // Register error listener and pass in the error handler function.
        empApi.onError(errorHandler);
        helper.subscribe(component, event, helper);
	},
	
	toggleMute : function(component, event, helper) {
    	console.log("#### AnnouncementConsoleHelper.toggleMute()");
    	var isMuted = !(component.get('v.isMuted'));
		component.set('v.isMuted', isMuted);
		if (isMuted===true) {
			helper.unsubscribe(component, event, helper);
		} else {
			helper.subscribe(component, event, helper);
		}
		
		helper.showToast(component, "success",((isMuted) ? 'Muted' : 'Unmuted'), "success","dismissible");
	},
	
	// Client-side function that invokes the subscribe method on the
    // empApi component.
	subscribe: function (component, event, helper) {
		console.log("#### AnnouncementConsoleHelper.subscribe()");
		// Get the empApi component.
		const empApi = component.find('empApiId');
		// Get the channel from the attribute.
		const channel = component.get('v.channel');
		// Subscription option to get only new events.
		const replayId = -1;
		// Callback function to be passed in the subscribe call.
		// After an event is received, this callback prints the event
		// payload to the console. A helper method displays the message
		// in the console app.
		const callback = function (message) {
		  helper.onReceiveNotification(component, helper, message);
		};
		// Subscribe to the channel and save the returned subscription object.
		empApi.subscribe(channel, replayId, callback).then(function (newSubscription) {
			console.log('Subscribed to channel ' + channel);
			component.set('v.subscription', newSubscription);
	    });
	},
	
	// Client-side function that invokes the unsubscribe method on the
    // empApi component.
    unsubscribe : function(component, event, helper) {
    	console.log("#### AnnouncementConsoleHelper.unsubscribe()");
        // Get the empApi component.
        const empApi = component.find("empApiId");
        // Get the channel from the subscription object.
        const subscription = component.get("v.subscription");
        if(!$A.util.isEmpty(subscription) && !$A.util.isEmpty(subscription.channel)) {
        	// Callback function to be passed in the subscribe call.
	        const callback = function (message) {
	            console.log("Unsubscribed from channel " + subscription.channel);
	        };
	
	        // Unsubscribe from the channel using the sub object.
	        empApi.unsubscribe(component.get("v.subscription"), callback);
        }
    },
    
    // Client-side function that displays the platform event message
    // in the console app and displays a toast if not muted.
    onReceiveNotification: function (component, helper, message) {
    	console.log("#### AnnouncementConsoleHelper.onReceiveNotification()");
    	if(!$A.util.isEmpty(message) && !$A.util.isEmpty(message.data) && 
    			!$A.util.isEmpty(message.data.payload) && !$A.util.isEmpty(message.data.payload.Chatter_Group__c)) {
    		// make a call to apex controller to find the currently logged in users groups
			// call the server side function  
			var action = component.get("c.getGroupURL");
			action.setParams({"groupName":message.data.payload.Chatter_Group__c});
			//set callback   
			action.setCallback(this, function(response) {
			    if (response.getState()==="SUCCESS") {
			    	var resp = response.getReturnValue();
			    	if(!$A.util.isEmpty(resp)) {
			    		// Extract notification from platform event
			    		
			    		var abbrGrpName = message.data.payload.Chatter_Group__c;
			    		if(!$A.util.isEmpty(abbrGrpName) && abbrGrpName.length > component.get("v.numOfcharsToShowForGrpName")) {
			    			abbrGrpName = abbrGrpName.substring(0, component.get("v.numOfcharsToShowForGrpName")-3)+"...";
			    		}
			    		
			    		var msg = message.data.payload.Message__c;
			    		if(!$A.util.isEmpty(msg) && msg.length > component.get("v.numOfcharsToShowForMsg")) {
			    			msg = msg.substring(0, component.get("v.numOfcharsToShowForMsg")-3)+"...";
			    		}
			    		var notifications = component.get("v.notificationMessageList");
			    		var newNotification = {
			    				"time" : $A.localizationService.formatDateTime(message.data.payload.CreatedDate, 'HH:mm'),
			    				"abbrgroupName" : abbrGrpName,
			    				"groupName" : message.data.payload.Chatter_Group__c,
			    				"abbrMessage" : msg,
			    				"message" : message.data.payload.Message__c,
			    				"grpURL" : resp
			    		};
			    		// Save notification in history
			    		var notifications = component.get("v.notificationMessageList");
			    		notifications.push(newNotification);
			    		component.set("v.notificationMessageList", notifications);
			    		// show the toast message 
			    		helper.showToast(component, "New Group Announcement", "success","sticky", newNotification);
			    		//helper.showToast(component, "New Group Announcement", newNotification.message, "success","sticky");
			    	}
			    } else if(response.getState()==="ERROR") {
			    	console.log('Error');
			    	var errMsg="";
			    	var errors = response.getError();
			    	if (errors) {
			    		if (errors[0] && errors[0].message) {
			    			errMsg+=errors[0].message;
			    		}
			    	} else {
			    		errMsg+="Unknown error";
			    	}
			    	console.log("Error Occcured : ")
			    	//helper.displayToast(component, "Error", "sticky", errMsg);
			    }
			});  
			// enque server action
			$A.enqueueAction(action);
		}
    },
    
    showToast : function(component, title, type, mode, newNotification) {
    	console.log("#### c:AnnouncementConsoleHelper.showToast()");
    	var toastEvent = $A.get("e.force:showToast");
        if(!$A.util.isEmpty(toastEvent)) {
	        toastEvent.setParams({
	            "title":title,
	            "message":newNotification.abbrMessage,
	            "type":type,
	            "mode":mode,
	            messageTemplate: '{0} : {1}',
	            messageTemplateData: [{
	            	url: newNotification.grpURL,
	            	label: newNotification.abbrgroupName
	            	},
	            	newNotification.abbrMessage
	            ]
	        });
	        toastEvent.fire();
        }
    }
})