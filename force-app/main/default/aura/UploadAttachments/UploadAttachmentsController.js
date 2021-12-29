({
    doInit : function(component, event, helper) {
        
        //Check for chatter permission
        /*var action = component.get("c.doesUserHaveChatterPermission");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue()
                console.log('Result : ' + result );

                if(result == true){
                    var cmpTarget = component.find('parentDiv');
                    $A.util.addClass(cmpTarget, 'slds-hide');
                }
                
            }else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
                });

        $A.enqueueAction(action);
*/
		//Check Whether User Has Edit Access 
		helper.checkUserRecordAccess(component);
        
        //Send LC Host as parameter to VF page so VF page can send message to LC; make it all dynamic
        component.set('v.lcHost', window.location.hostname);

        var frameSrc = '/apex/UploadFilePage?id=' + component.get('v.recordId') + '&lcHost=' + component.get('v.lcHost');
        console.log('frameSrc:' , frameSrc);
        component.set('v.frameSrc', frameSrc);

        //Add message listener
        window.addEventListener("message", function(event) {

            console.log('event.data:', event.data);

            // Handle the message
            if(event.data.state == 'LOADED'){
                //Set vfHost which will be used later to send message
                component.set('v.vfHost', event.data.vfHost);
               
            }

            if(event.data.state == 'uploadFileSelected'){
                var uploadFileButton = component.find("uploadFileButton");
				console.log(event.data.Name);
                if(uploadFileButton != undefined){
                    uploadFileButton.set('v.disabled', false);
                }
                
            }

            if(event.data.state == 'fileUploadprocessed'){

                var uiMessage = component.find('uiMessage');

                //Disable Upload button until file is selected again
                var uploadFileButton = component.find("uploadFileButton");
                if(uploadFileButton != undefined){
                    uploadFileButton.set('v.disabled', true);
                }

                 

                $A.createComponents([
                        ["markup://ui:message",{
                            "body" : event.data.message,
                            "severity" : event.data.messageType,
                        }]
                    ],
                    function(components, status, errorMessage){
                        if (status === "SUCCESS") {
                            var message = components[0];
				          console.log(event.data.messageType+" "+event.data.message)
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: event.data.messageType,
                                 message: event.data.message,
                                 type: event.data.messageType
                             });
                            toastEvent.fire();

	                        $A.get("e.force:refreshView").fire();
                        }
                        else if (status === "INCOMPLETE") {
                            console.log("No response from server or client is offline.")
                            // Show offline error
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: "Error",
                                 message: "No response from server or client is offline.",
                                 type: "error"
                             });
                            toastEvent.fire();
                        }
                        else if (status === "ERROR") {
                            console.log("Error: " + errorMessage);
                            // Show error message
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: "Error",
                                 message: errorMessage,
                                 type: "error"
                             });
                            toastEvent.fire();
                        }
                    }
                );
            }
        }, false);
    },
    
    sendMessage: function(component, event, helper) {
        //Clear UI message before trying for file upload again
        component.find('uiMessage').set("v.body",[]);

        //Prepare message in the format required in VF page
        var message = {
            "uploadFile" : true
        } ;
        //Send message to VF
        helper.sendMessage(component, helper, message);
    }
})