public with sharing class OutlookPluginController
{
    @AuraEnabled
    public static EventDetailsWrapper getExistingEventDetails(String globalAppointmentId)
    {
        EventDetailsWrapper eventDetailsWrapper;
        List<Contact> lstContact;
        List<User> lstUser;
        Set<Id> setContactIds = new Set<Id>();
        Set<Id> setUserIds = new Set<Id>();

        List<Event> lstEvent = [SELECT  L0_Type__c, Type, WhatId, OwnerId, CreatedById,Third_Party_Emails__c,
                                        (SELECT Id, RelationId, IsWhat, IsParent, IsInvitee, IsDeleted FROM EventRelations)
                                FROM    Event
                                WHERE   Outlook_Global_Appointment_Id__c = :globalAppointmentId
                                LIMIT   1];

        if(!lstEvent.isEmpty())
        {
            Event event = lstEvent.get(0);
            eventDetailsWrapper = new eventDetailsWrapper(event.L0_Type__c, event.Type, event.WhatId, event.OwnerId,event.CreatedById, event.Third_Party_Emails__c);

            System.debug('### Event rel size:: '+ event.EventRelations.size());
            for(EventRelation eventRel : event.EventRelations)
            {
                if(!eventRel.IsWhat && !eventRel.IsDeleted)
                {
                    if(eventRel.RelationId.getSobjectType() == Schema.Contact.SObjectType)
                    {
                        setContactIds.add(eventRel.RelationId);
                    }
                    if(eventRel.RelationId.getSobjectType() == Schema.User.SObjectType)
                    {
                        setUserIds.add(eventRel.RelationId);
                    }
                }
            }

            if(!setContactIds.isEmpty())
            {
                eventDetailsWrapper.lstContactAttendees = [SELECT Id, Name, Email, Account.Id, Account.ParentId, Account.Name, Account.RecordType.Name,Account.RDM_Org_Id__c FROM Contact WHERE Id IN :setContactIds];
            }
            if(!setUserIds.isEmpty())
            {
                eventDetailsWrapper.lstUserAttendees = [SELECT Id, Name, Email FROM User WHERE Id IN :setUserIds];
            }

        }
        System.debug('### eventDetailsWrapper:: '+ eventDetailsWrapper);
        return eventDetailsWrapper;
    }

    @AuraEnabled
    public static List<OptionWrapper> getRMAccountWrappersForParentRG(String rgAccountId)
    {
        List<OptionWrapper> lstRMWrappers = new List<OptionWrapper>();

        List<Account> lstAccount =  [SELECT Id, Name, BillingCity, BillingCountry, BillingStreet, Parent.Name FROM Account WHERE RecordType.Name = 'RM Account' AND Active__c = TRUE AND Parent.Id=:rgAccountId];

        for(Account rmAccount : lstAccount)
        {
            String label = rmAccount.BillingCountry + ' ' + rmAccount.BillingCity  + ' ' + rmAccount.BillingStreet;
            OptionWrapper wrapper = new OptionWrapper(label, rmAccount.Id, rmAccount.Name);
            lstRMWrappers.add(wrapper);
        }

        return lstRMWrappers;
    }

    public class OptionWrapper
    {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }
        @AuraEnabled
        public String description { get; set; }

        public OptionWrapper(String label, String value, String description)
        {
            this.label = label;
            this.value = value;
            this.description = description;
        }
    }

    public class EventDetailsWrapper
    {
        @AuraEnabled public String activityType;
        @AuraEnabled public String activitySubType;
        @AuraEnabled public String primaryRgAccountId;
        @AuraEnabled public String ownerId;
        @AuraEnabled public String createdById;
        @AuraEnabled public String thirdPartyEmails;
        @AuraEnabled public List<Contact> lstContactAttendees;
        @AuraEnabled public List<User> lstUserAttendees;

        public EventDetailsWrapper(String activityType, String activitySubType, String primaryRgAccountId, String ownerId, String createdById, String thirdPartyEmails)
        {
            this.activityType = activityType;
            this.activitySubType = activitySubType;
            this.primaryRgAccountId = primaryRgAccountId;
            this.ownerId = ownerId;
            this.createdById = createdById;
            this.thirdPartyEmails = thirdPartyEmails;
        }
    }
}