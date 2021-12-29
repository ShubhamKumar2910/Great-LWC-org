({
    scriptsLoaded : function(component, event, helper) {
        component.set("v.isHelperTreeScriptLoaded",true);
        component.set("v.nTRTreeHelperLogic",true);
    },
    
    doInit: function(component, event, helper) { 
        
    },
    
    highlightErrorMethod: function(cmp, event) {
        var params = event.getParam('arguments');
        var hightLight= params.highlightErrorParam;
        var hightLightMsg= params.highlightErrorMessageParam;
        cmp.set("v.highlightError" , hightLight);  
        cmp.set("v.highlightErrorMessage" , hightLightMsg);
        var treePickListId = cmp.get("v.sourceEntity") + '_treePickList_span';
        var cmpTarget = $A.getComponent(treePickListId);
        console.log('cmpTarget = ' + cmpTarget);
        if (hightLight == "true") {
            $A.util.addClass(cmpTarget, 'input-error');
            document.getElementById(treePickListId).style.border = "1px solid rgb(194, 57, 52)"; 
        }
        else {
            $A.util.removeClass(cmpTarget, 'input-error');
            document.getElementById(treePickListId).style.border="0px" ;
        }
    },
    
    reset: function(cmp,event){
        $("#"+cmp.get('v.parentID')+"_team_treePickList").select2('val',null);
    }
})