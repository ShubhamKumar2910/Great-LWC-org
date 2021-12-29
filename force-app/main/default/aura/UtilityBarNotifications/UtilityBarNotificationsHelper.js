({
    connectCometd : function(component) {
        var helper = this;
        
        // Configure CometD
        var cometdUrl = window.location.protocol+'//'+window.location.hostname+'/cometd/40.0/';
        var cometd = component.get('v.cometd');
        cometd.configure({
            url: cometdUrl,
            requestHeaders: { Authorization: 'OAuth '+ component.get('v.sessionId')},
            appendMessageTypeToURL : false
        });
        cometd.websocketEnabled = false;
        
        // Establish CometD connection
        cometd.handshake(function(handshakeReply) {
            if (handshakeReply.successful) {
                var cometd = component.get("v.cometd");
                cometd.addListener('/meta/connect',$A.getCallback(function(message) {
                    if(!message.successful) {
                        // helper.log('--- streamer meta/connect..xxx isDisconnected?' + cometd.isDisconnected() + '... message.error..'+message.error + 'advice=' + JSON.stringify(message.advice) + '..  message='+JSON.stringify(message),'warn',message);
                        var advice = message.advice;
                        
                        //if(reconnect && reconnect!==undefined && reconnect != null) {
                        if(message.error.includes('403')) {
                            //helper.log('--- streamer.. cometd will attempt to rehandshake on its own according to spec but always fails after the next handshake !! im forcing an entire reinit of the component doing a handledestroy here doesnot seem necessary as unsubscribe always fails.', 'warn');
                            //helper.doReInit(component, event, helper);
                            helper.disconnectCometd(component);
                            var cometd = new org.cometd.CometD();
                            component.set('v.cometd', cometd);
                            helper.connectCometd(component);
                        }
                        //------------------------helper.handshake(component,event.helper);
                        //}
                    }
                }));
                // Subscribe to platform event
                var newSubscription = cometd.subscribe('/event/Request_Notification__e',
                                                       function(platformEvent) {
                                                           helper.onReceiveNotification(component, platformEvent);
                                                       }
                                                      );
                
                // Save subscription for later
                var subscriptions = component.get('v.cometdSubscriptions');
                subscriptions.push(newSubscription);
                component.set('v.cometdSubscriptions', subscriptions);
            }
            else
                console.error('Failed to connected to CometD.');
        });
    },
    
    disconnectCometd : function(component) {
        var cometd = component.get('v.cometd');
        
        // Unsuscribe all CometD subscriptions
        cometd.batch(function() {
            var subscriptions = component.get('v.cometdSubscriptions');
            subscriptions.forEach(function (subscription) {
                cometd.unsubscribe(subscription);
            });
        });
        component.set('v.cometdSubscriptions', []);
        
        // Disconnect CometD
        cometd.disconnect();
    },
      
    onReceiveNotification : function(component, platformEvent) {
        var helper = this;
        // Extract notification from platform event
        
        var newNotification = {
            time : $A.localizationService.formatDateTime(
                platformEvent.data.payload.CreatedDate, 'HH:mm'),
            message : platformEvent.data.payload.Message__c
        };
        
        if(!$A.util.isEmpty(newNotification)){
            if(!$A.util.isUndefinedOrNull(approvalsCount)){
                //as Event will be recieved, we need to refresh count in utility bar
                component.set('v.scriptsLoaded', true);
                approvalsCount.getPendingApprovals(component);
                
            }
            
        }
       
    },
    
    displayToast : function(component, type, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message
        });
        toastEvent.fire();
    },

})