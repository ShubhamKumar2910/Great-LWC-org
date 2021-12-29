({
	onInit : function(component, event, helper) {
		console.log("#### AnnouncementConsoleController.onInit()");
		helper.init(component, event, helper); 
	},
	
	// Clear notifications in console app.
	onClear: function (component, event, helper) {
		console.log("#### AnnouncementConsoleController.onClear()");
		component.set("v.notificationMessageList", []);
	},
	
	// Mute toast messages and unsubscribe/resubscribe to channel.
	onToggleMute: function (component, event, helper) {
		console.log("#### AnnouncementConsoleController.onToggleMute()");
		helper.toggleMute(component, event, helper);
	},
	
	OpenUrl: function (component, event, helper) {
		console.log("#### AnnouncementConsoleController.OpenUrl()", event);
		var target = event.currentTarget;
		console.log("val : "+target.getAttribute("data-group-id"));
	},
})