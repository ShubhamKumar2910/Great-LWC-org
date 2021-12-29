({
    scriptsLoaded : function(cmp, event, helper) {
            cmp.set("v.isHelperPicklistLoaded",true);
            cmp.set("v.nTRPicklistHelperLogic",true);
        console.log('Parent Id: ' +cmp.get("v.parentID"));
        console.log('IDT Id: ' +cmp.get("v.IDT"));
    },
        /*8----------------------TOAST MESSAGES--------------*/
    showToast : function(component, event, helper) {
        var params = event.getParam('arguments');
        if(params)
        {
            var title = params.title;
            var type = params.type;
            var message = params.message;
            var mode = params.mode;
            var key = params.key;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "type": type,
                "message": message,
                "mode": mode,
                "key": key
            });
            toastEvent.fire();
        }  
    },
  
    clear : function(component, event, helper) {
        //$('#'+component.get("v.IDT")).val('').trigger('change');
    },
    onChangeCall : function(component){
        
    },
    reset: function(component,event,helper)
    {
        var objName = component.get("v.objName"); 
        var picklistfieldName = component.get("v.picklistfieldName"); 
        
        component.set('v.values',new Array());
        
        if(!component.get("v.isCustom")) 
            helper.loadData(component,objName,picklistfieldName,null); 
        else
        { helper.loadData(component,objName,picklistfieldName,component.get("v.customMethod"));} 
        $("#"+component.get("v.parentID")+"_"+component.get("v.IDT")).select2('val',null);
       	
        
    }
})