({
    fetchAccId: function(component, event, helper) {
        var AccId = component.get("v.simpleRecord.RG_Account__c");        
        helper.createWaveComponent(component,AccId);
}
})