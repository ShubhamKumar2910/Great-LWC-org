({
    rerender : function(component, helper){
        this.superRerender();

        
        var approvalCountJson = component.get('v.approvalCountJson');
        if(component.get('v.scriptsLoaded') && approvalCountJson != '' && component.get('v.refreshCount')){            
            console.log('--bulk rerender ', component.get('v.approvalCountJson'));
            component.displayApprovalsCount(component, helper);
            component.set('v.refreshCount', false); //to stop rerendering
            //$A.get('e.force:refreshView').fire();
        }
    },

    unrender: function (component) {     
        this.superUnrender();     
        const empApi = component.find('empApi');
        // Get the subscription that we saved when subscribing
        const subscription = component.get('v.subscription');

        // Unsubscribe from event
        empApi.unsubscribe(subscription, $A.getCallback(unsubscribed => {
          // Confirm that we have unsubscribed from the event channel
          console.log('Unsubscribed from channel '+ unsubscribed.subscription);
          component.set('v.subscription', null);
        }));
    } 
    
})