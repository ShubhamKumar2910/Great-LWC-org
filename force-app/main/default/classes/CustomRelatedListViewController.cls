public with sharing class CustomRelatedListViewController {

    @AuraEnabled
    public static Boolean captureLastViewedRecord( String recordId, String customSettingsFieldName ) {
        Last_Viewed_Record__c lva = Last_Viewed_Record__c.getInstance( UserInfo.getUserId() );
    
        if( lva.get(customSettingsFieldName) != recordId ) {

            lva.SetupOwnerId = UserInfo.getUserId();
            lva.put(customSettingsFieldName, recordId);
            UPSERT lva Id;
            
            return true;
        }
        else {
            return false;
        }
    }

    @AuraEnabled
    public static Boolean checkUserPermission() {

        String profileName = '';
        List<String> nonRestrictedProfiles = new List<String>{'System Administrator', 'Nomura - Integration', 'Nomura - Production Services'};
        String PermissionSetApiName = 'Legal_Agreement_Access';

        String userId = UserInfo.getUserId();
        List<AggregateResult> result = [SELECT count(Id) FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSet.Name = :PermissionSetApiName];
        String countOfId = String.valueOf(result[0].get('expr0'));

        Id profileId=userinfo.getProfileId();
        profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        
        if( '1'.equalsIgnoreCase(countOfId) || nonRestrictedProfiles.contains(profileName)) {
            return true;
        }
        else {
            return false;
        }
    }

}