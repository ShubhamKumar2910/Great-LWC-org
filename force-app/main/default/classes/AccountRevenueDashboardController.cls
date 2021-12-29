public with sharing class AccountRevenueDashboardController {
    @AuraEnabled
    public static String getUserProfileName() {
        String profileName = [Select Id,Name from Profile where Id= : UserInfo.getProfileId()].Name;
        return profileName;
    }
}