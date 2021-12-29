public without sharing class ManageEventAttendees implements Queueable
{
    private Event newEvent;
    private CallReportDataWrapper.CallReportData callReportData;

    public ManageEventAttendees(Event newEvent,CallReportDataWrapper.CallReportData callReportData)
    {
        this.newEvent = newEvent;
        this.callReportData = callReportData;
    }

    public void execute(QueueableContext context)
    {
        system.debug('####### In ManageEventAttendees.execute method ');
        List<EventRelation> lstExistingEventRelations;
        Set<Id> setNewAttendeeIds = new Set<Id>();
        Set<Id> setExistingAttendeeIds = new Set<Id>();
        Map<Id,EventRelation> mapContactToEventRelation = new Map<Id,EventRelation>();

        List<EventRelation> lstEventRelationToAdd = new List<EventRelation>();
        List<EventRelation> lstEventRelationToDelete = new List<EventRelation>();
        EventRelation eventRelation;

        if(String.isNotBlank(this.newEvent.Id))
        {
            lstExistingEventRelations = getEventExistingAttendees(this.newEvent.Id);
            system.debug('####### lstExistingEventRelations :: '+ lstExistingEventRelations);
            for(EventRelation existingEventRelation : lstExistingEventRelations)
            {
                if(existingEventRelation.RelationId.getSobjectType() == Schema.Contact.SObjectType || existingEventRelation.RelationId.getSobjectType() == Schema.User.SObjectType)
                {
                    // get a set of attendees in relation and a map of existing attendees => attendee relation
                    setExistingAttendeeIds.add(existingEventRelation.RelationId);
                    mapContactToEventRelation.put(existingEventRelation.RelationId,existingEventRelation);
                }
            }

            for(String clientContactId : callReportData.ClientContactIds)
            {
                if(!setExistingAttendeeIds.contains(clientContactId))
                {
                    if(!setNewAttendeeIds.contains(clientContactId))
                    {
                        setNewAttendeeIds.add(clientContactId);
                        eventRelation = new EventRelation(EventId = this.newEvent.Id, RelationId = clientContactId, isParent = true, isInvitee = false);
                        lstEventRelationToAdd.add(eventRelation);
                    }
                }
                else
                {
                    // remove, so any left overs in the end could be deemed as marked for deletion as they are no longer marked as attendees
                    setExistingAttendeeIds.remove(clientContactId);
                }
            }

            for(String nomuraContactOrUserId : callReportData.InternalContactIds)
            {
                if(!setExistingAttendeeIds.contains(nomuraContactOrUserId))
                {
                    // Cannot add the owner of the event as an invitee
                    if(!setNewAttendeeIds.contains(nomuraContactOrUserId) && nomuraContactOrUserId != this.newEvent.OwnerId)
                    {
                        setNewAttendeeIds.add(nomuraContactOrUserId);
                        eventRelation = new EventRelation(EventId = this.newEvent.Id, RelationId = nomuraContactOrUserId, isParent = false, isInvitee = true);
                        lstEventRelationToAdd.add(eventRelation);
                    }
                }
                else
                {
                    // remove, so any left overs in the end could be deemed as marked for deletion as they are no longer marked as attendees
                    setExistingAttendeeIds.remove(nomuraContactOrUserId);
                }
            }

            if(!setExistingAttendeeIds.isEmpty())
            {
                lstEventRelationToDelete = getEventRelationsForContacts(setExistingAttendeeIds,mapContactToEventRelation);
            }
        }

        system.debug('####### lstEventRelation before insert:: '+ lstEventRelationToAdd);
        if(!lstEventRelationToAdd.isEmpty())
        {
            insert lstEventRelationToAdd;
        }
        system.debug('####### lstEventRelationToDelete before delete:: '+ lstEventRelationToDelete);
        if(!lstEventRelationToDelete.isEmpty())
        {
            delete lstEventRelationToDelete;
        }
    }

    public static List<EventRelation> getEventRelationsForContacts(Set<Id> setAttendeeContactIds, Map<Id,EventRelation> mapContactToEventRelation)
    {
        List<EventRelation> lstEventRelations = new List<EventRelation>();
        for(Id contactId : setAttendeeContactIds)
        {
            if(mapContactToEventRelation.containsKey(contactId))
            {
                lstEventRelations.add(mapContactToEventRelation.get(contactId));
            }
        }
        return lstEventRelations;
    }

    public static List<EventRelation> getEventExistingAttendees(String eventId)
    {
        return [SELECT  Id, RelationId, IsInvitee FROM EventRelation
                WHERE   EventId = :eventId AND IsDeleted = false AND IsWhat = false
        ];
    }

}