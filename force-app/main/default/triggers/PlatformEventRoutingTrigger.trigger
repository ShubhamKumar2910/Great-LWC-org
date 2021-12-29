trigger PlatformEventRoutingTrigger on Platform_Event_Routing__c (before update) {
    for (Platform_Event_Routing__c oldRouting : Trigger.old) {
        Platform_Event_Routing__c newRouting = Trigger.newMap.get(oldRouting.Id);
        
        System.debug('prior old replayId=' + oldRouting.Prior_Last_Event_Processed__c);
        System.debug('old replayId=' + oldRouting.Last_Event_Processed__c);
        System.debug('new replayId=' + newRouting.Last_Event_Processed__c);
        
        if (newRouting.Last_Event_Processed__c > oldRouting.Last_Event_Processed__c
        	|| newRouting.Last_Event_Processed__c == null || oldRouting.Last_Event_Processed__c == null
            || newRouting.Last_Event_Processed__c <= 0) {
            
        	if (newRouting.Last_Event_Processed__c != oldRouting.Last_Event_Processed__c) {
                // The gateway is updating this record to indicate the next event has been processed.
                // We let the update store the new replayId value, so that the gateway can
                // pick up from this point when it re-subscribes to the event.
                // We also store the prior value into a separate field, as an aid in case any
                // manual intervention is required to fix a bad replayId or message.
                // We also store the time that the event was processed, so that we can detect
                // the case that a stored replayId doesn't exist because it's more than 24 hours old.
                System.debug('Saving old replayId to prior last replayId');
        		newRouting.Prior_Last_Event_Processed__c = oldRouting.Last_Event_Processed__c;
                newRouting.Last_Event_Timestamp__c = DateTime.now();
            } else {
                System.debug('Not saving old replayId to prior replayId');
            }
        } else {
            // We don't want the gateway to store a value smaller than the previous event processed,
            // as that could lead to the previous message being processed more than once when
            // the gateway shuts down and restarts.  So, we revert the change in this case.
            // (This could possibly happen due to multithreading in the gateway client.)
            System.debug('reverting the update');
            newRouting.Last_Event_Processed__c = oldRouting.Last_Event_Processed__c;
        }
    }
}