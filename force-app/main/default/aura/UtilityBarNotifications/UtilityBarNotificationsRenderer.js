({
	rerender : function(component, helper){
        this.superRerender();
        
        var approvalCountJson = component.get('v.approvalCountJson');
        if(component.get('v.scriptsLoaded') && approvalCountJson != '' && component.get('v.refreshCount')){ 
            console.log('--utility rerender ', component.get('v.approvalCountJson'));
            component.displayUtilityBar(component);
            component.set('v.refreshCount', false); //to stop rerendering
        }
    }


})