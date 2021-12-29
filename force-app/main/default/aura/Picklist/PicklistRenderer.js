({
	 rerender : function(cmp, helper){
        this.superRerender();
         console.log('Parent Id: (renderer) ' +cmp.get("v.parentID"));
         console.log('IDT Id: (renderer)' +cmp.get("v.IDT"));
         console.log('Parent Id: (nTRPicklistHelperLogic) ' +cmp.get("v.nTRPicklistHelperLogic"));
         console.log('IDT Id: (isHelperPicklistLoaded)' +cmp.get("v.isHelperPicklistLoaded"));
         
        if(cmp.get("v.isHelperPicklistLoaded") && cmp.get("v.nTRPicklistHelperLogic")) {
            try {
                console.log('Parent Id: (renderer If) ' +cmp.get("v.parentID"));
                console.log('IDT Id: (renderer If)' +cmp.get("v.IDT"));
                
                var objName = cmp.get("v.objName"); 
                console.log('objName: (renderer If)' +objName);
                var picklistfieldName = cmp.get("v.picklistfieldName");
                console.log('picklistfieldName: (renderer If)' +picklistfieldName);
                console.log('isCustom: (renderer If)' +cmp.get("v.isCustom"));
                if(!cmp.get("v.isCustom")) 
                {
                    console.log('Is not custm');
                    helper.loadData(cmp,objName,picklistfieldName,null); 
                }
                else
                { 
                    console.log('Is custm: '+cmp.get("v.customMethod"));
                    helper.loadData(cmp,objName,picklistfieldName,cmp.get("v.customMethod"));
                }   
                cmp.set("v.nTRPicklistHelperLogic",false);
            }
            catch(err) {
                console.log('Error during Picklist renderer logic. Please find below:')   ;
                console.log(err);
            }
            
        }
    },
    unrender: function () {
       /* this.superUnrender();
        // do custom unrendering here
        console.log('unrenderer multiselect tree');
        $("#"+component.get("v.IDT")).unload();
        cmp.set("v.needToRenderHelperLogic",false); // this will not fire rerender again
        cmp.set("v.isHelperScriptLoaded",false);*/
    }

})