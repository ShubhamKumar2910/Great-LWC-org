({
	// Your renderer method overrides go here
	 rerender : function(cmp, helper){
        this.superRerender();
        
        if(cmp.get("v.isHelperScriptLoaded") && cmp.get("v.needToRenderHelperLogic")) {
            try {
               	cmp.set("v.needToRenderHelperLogic",false); // this will not fire rerender again
                $('#'+cmp.find('proroleAdd').get("v.parentID")+'_'+cmp.find('proroleAdd').get("v.IDT")).val('Primary'); // Select the option with a value of '1'
                $('#'+cmp.find('proroleAdd').get("v.parentID")+'_'+cmp.find('proroleAdd').get("v.IDT")).trigger('change');
                $('#'+cmp.find('proroleAdd').get("v.parentID")+'_'+cmp.find('proroleAdd').get("v.IDT")+' option[value="None"]').remove();
                
            }
            catch(err) {
                console.log('Error during Helper renderer logic. Please find below:')   ;
                console.log(err);
            }
        }
    },
    afterRender: function(component, helper) {
        this.superAfterRender();
    }
})