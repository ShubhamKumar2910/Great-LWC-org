({ 
    init : function (component, event, helper) 
    {
        helper.loadData(component);
    },
    
    setProductData : function (component, event, helper) 
    {
        helper.loadProductData(component, event);
    },
    
    setSelectedRows : function (component, event, helper) 
    {
        helper.setProducts(component, event);
    }
});