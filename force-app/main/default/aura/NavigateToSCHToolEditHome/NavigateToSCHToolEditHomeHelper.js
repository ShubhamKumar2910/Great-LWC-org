({
    initializeComponent : function(component) {

        var entityId = '';
        var entityName = '';
        var searchStr = '';
        
        var pageRef = component.get("v.pageReference");
        if(!$A.util.isEmpty(pageRef))
        {
            if(pageRef.state.c__selectedEntityId){
                entityId = pageRef.state.c__selectedEntityId;
            }

            if(pageRef.state.c__selectedEntityName){
                entityName = pageRef.state.c__selectedEntityName;
            }

            if(pageRef.state.c__searchStr){
                searchStr = pageRef.state.c__searchStr;
            }            
        }

        component.set('v.selectedEntityId', entityId);
        component.set('v.selectedEntityName', entityName);
        component.set('v.searchStr', searchStr);

        
        component.find('schToolEditHome').setDefaultValues();
        
    }
})