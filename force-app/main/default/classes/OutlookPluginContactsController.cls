// Without sharing as the email search should find within all contacts without requiring to create duplicates
public without sharing class OutlookPluginContactsController
{
    @AuraEnabled
    public static Map<String,List<SObject>> getContactsAndUsersByEmail(List<String> lstEmails)
    {
        Map<String,List<SObject>> mapContactsAndUsers = new Map<String,List<SObject>>();

        mapContactsAndUsers.put('contacts', [SELECT    Id, Name, Email, Account.Id, Account.ParentId, Account.Name, Account.RecordType.Name,Account.RDM_Org_Id__c
                                            FROM    Contact
                                            WHERE   (Email IN :lstEmails OR Secondary_Email__c IN :lstEmails) AND Active__c = true
        LIMIT   50]);

        mapContactsAndUsers.put('users',[SELECT    Id, Name, Email
                                        FROM      User
                                        WHERE     (Email IN :lstEmails) AND isActive = true]);

        system.debug('### mapContactsAndUser:: '+mapContactsAndUsers);
        return mapContactsAndUsers;
    }
}