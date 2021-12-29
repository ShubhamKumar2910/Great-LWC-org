public without sharing class PicklistLightningController {
    
    @AuraEnabled
    public static List<String> getFlowPicklistValues(String picklistApiName) {
        List<String> options = new List<String>();
        if(String.isNotBlank(picklistApiName)) {
            Schema.DescribeSObjectResult onbReqDescribe = Onboarding_Request__c.sObjectType.getDescribe();
            Map<String,Schema.SObjectField> fieldMap = onbReqDescribe.fields.getMap();
            if (fieldMap != null && fieldMap.containsKey(picklistApiName)) {
                List<Schema.PicklistEntry> picklistEntries = fieldMap.get(picklistApiName).getDescribe().getPicklistValues();
                for (Schema.PicklistEntry ple : picklistEntries) {
                    options.add(ple.getValue());
                }
            } else {
                throw new AuraHandledException('Can not find Picklist on Onboarding Request - PicklistLightningController.getFlowPicklistValues() ');
            }
        } else {
            throw new AuraHandledException('Picklist API Name is Blank - PicklistLightningController.getFlowPicklistValues() ');
        }
        return options;
    }
}