public with sharing class ActivityFinder 
{
    private static String employeeAccountRecordTypeDevName = 'NOMURA_EMPLOYEES';
    private static String CALLFOR_EXPORT = 'Export';

    @AuraEnabled
    public static EventDetailsWrapper getActivites(String rsAccountId, String accountId, String rmAccountId, String podAccountId, String clientAttendee, String internalInvitee, Datetime startDate, 
            Datetime endDate, List<String> selectedActivityType, Integer offset, Integer queryLimit,List<Id> eventIdList,String calledFor) 
    {
        system.debug('### ' + startDate);
        system.debug('###PG queryLimit: ' + queryLimit + ' offset: '+ offset);
        system.debug('rsAccountId: '+rsAccountId + ' accoundId: '+accountId + 'rmAccountId: '+rmAccountId + 'podAccountId: '+podAccountId +  ' clientAttendee: '+clientAttendee +' internalInvitee: '+internalInvitee);

        // fetching the loggedIn user timezone
        TimeZone tz = UserInfo.getTimeZone();

        // Query Client Attendess with Attendeed/Event Filters
        String queryMain = 'SELECT EventId, DAY_ONLY(convertTimezone(Event.StartDateTime)) ' +
                        'FROM EventRelation ' +
                        'WHERE Event.IsChild = false ';

        String queryWithFilters = queryMain;

        if(startDate != null) 
        {
            // tz.getOffset(datetime) gives the offset value in miliseconds (India: +5.30 = 19800000 milisec)
            Integer startTimeSec = tz.getOffset(startDate)/(1000);
            // adding offset seconds to localdate as to make it in GMT for query comparison
            startDate = startdate.addSeconds(-startTimeSec);
            system.debug('New start datetime: '+startDate);
            queryWithFilters += 'AND Event.StartDateTime >=: startDate ';
        }       
        if(endDate != null)
        {
            Integer endTimeSec = tz.getOffset(endDate)/(1000);
            // as filter is on datetime, we add one day to the date minus one min to make 24 hours 
            // startDate: 01 Jan 2020 00:00 hrs EndDate: 01 Jan 2020 23:59 hrs
            endDate = endDate.addSeconds(-endTimeSec).addDays(1).addMinutes(-1);
            system.debug('New end datetime '+endDate);
            queryWithFilters += 'AND Event.StartDateTime <=: endDate ';
        }
        if(selectedActivityType != null && selectedActivityType.size() > 0)
        {
            queryWithFilters += 'AND Event.L0_Type__c in: selectedActivityType ';    
        }

        String queryEnd = 'GROUP BY EventId, DAY_ONLY(convertTimezone(Event.StartDateTime)) ORDER BY DAY_ONLY(convertTimezone(Event.StartDateTime)) DESC'; 
        String query = queryWithFilters;
        List<Id> internalEventIds = new List<Id>();
        List<Id> clientEventIds = new List<Id>();

        if(eventIdList.isEmpty()){
            if(internalInvitee != '')
            {   
                query = queryMain;
                String queryInternalInvitee = queryWithFilters;            
                queryInternalInvitee += 'AND (Event.OwnerId =: internalInvitee OR RelationId =: internalInvitee) '; 
                queryInternalInvitee += queryEnd;
                system.debug('Internal query: '+queryInternalInvitee);
                for(AggregateResult loopinternalInvitess : (List<AggregateResult>) Database.query(queryInternalInvitee))
                {
                    internalEventIds.add((Id)loopinternalInvitess.get('EventId'));        
                }
            }

            if(clientAttendee != '')
            {
                query = queryMain;
                String queryClientInvitee = queryWithFilters;
                queryClientInvitee += 'AND RelationId =: clientAttendee ';
                queryClientInvitee += queryEnd;
                system.debug('Client query: '+queryClientInvitee);
                for(AggregateResult loopclientInvitess : (List<AggregateResult>) Database.query(queryClientInvitee))
                {
                    clientEventIds.add((Id)loopclientInvitess.get('EventId'));        
                }
            }
        }

        if(eventIdList.size() != 0){
            //EventId List is not empty -> skips querying Internal and Client invitees
            query = queryMain;
            query += 'AND EventId in : eventIdList ';
        }else if((internalInvitee != '' && internalEventIds.size() == 0) || (clientAttendee != '' && clientEventIds.size() == 0)){
            //Internal or Client invitee does not fetch any match
            query += 'AND EventId = \'000000000000000000\' ';
        }else if(internalEventIds.size() != 0 && clientEventIds.size() != 0){
            //Common EventIds having Internal and Client invitees
            for(Id eventId: internalEventIds){
                if(clientEventIds.contains(eventId)){
                    eventIdList.add(eventId);
                }
            }
            query += 'AND EventId in : eventIdList ';
        }else if(internalEventIds.size() != 0){
            //Internal invitees EventId
            eventIdList = internalEventIds;
            query += 'AND EventId in : internalEventIds ';
        }else if(clientEventIds.size() != 0){
            //Client invitees EventId            
            eventIdList = clientEventIds;
            query += 'AND EventId in : clientEventIds ';
        }

        query += ActivityFinder.queryOnAccount(rsAccountId, accountId, rmAccountId, podAccountId);
 
        query += queryEnd + ' LIMIT: queryLimit OFFSET: offset';
        system.debug('Final query: '+query);
        List<EventWrapper> events = new List<EventWrapper>();
        Map<Id,EventWrapper> eventsMap = new Map<Id,EventWrapper>();
        for(AggregateResult loopClientAttendee : (List<AggregateResult>) Database.query(query))
        {
            if(!eventsMap.containsKey((Id)loopClientAttendee.get('EventId')))
            {
                EventWrapper eventWrapper = new  EventWrapper((Id)loopClientAttendee.get('EventId'));
                events.add(eventWrapper);
                eventsMap.put((Id)loopClientAttendee.get('EventId'),eventWrapper);
            }
        }

        // Query all event Client Attendee 
        List<Id> eventIds = new List<Id>(eventsMap.keySet());
        List<EventRelation> eventRelations = new List<EventRelation>();
        eventRelations = [
            SELECT EventId, Event.Subject, Event.Description, Event.StartDateTime, Event.L0_Type__c, Event.Type, Event.Owner.Name,
            Account.Parent.Name, RelationId, Relation.Name, Relation.Type, Account.RecordType.DeveloperName, IsWhat
            //,TYPEOF Relation WHEN Contact THEN Name, Title WHEN User Then Name END
            FROM EventRelation WHERE Event.IsChild = false AND EventId in : eventIds
        ];

        Map<Id,Task_LTA__c> tasksMap = new Map<Id,Task_LTA__c>();
        if(calledFor == CALLFOR_EXPORT){
            List<Task_LTA__c> tasks = [SELECT LTA_1__c,Parent_Task__c FROM Task_LTA__c WHERE Parent_Task__c IN : eventIds];            
            for(Task_LTA__c note : tasks){
                tasksMap.put(note.Parent_Task__c,note);
            }
        }

        Set<Id> contactIds = new Set<Id>();	// required to query
        Set<Id> userIds = new Set<Id>();	
        for(EventRelation loopEventRelation : eventRelations)
        {
                if(loopEventRelation.IsWhat) // user attendee - assignedTo
                {
                    userIds.add(loopEventRelation.Event.OwnerId);
                }                
                else if(loopEventRelation.Account.RecordType.DeveloperName == 'RM_Account') // if contact attendee
                {
                    contactIds.add(loopEventRelation.RelationId);  
                }                
                else if(loopEventRelation.AccountId == null && loopEventRelation.Relation.Type == 'Contact') // user attendee - Nomura Contact
                {
                    contactIds.add(loopEventRelation.RelationId);
                }                
                else // user attendee - Internal User
                {
                    userIds.add(loopEventRelation.RelationId);
                }
        }

        Map<Id,Contact> relatedContacts = new Map<Id,Contact>([SELECT Id, PositionPicklist__c, Division__c, Title, Account.Name, Pod_Account__r.Name FROM Contact Where Id in : contactIds]);
        Map<Id,User> relatedUsers = new Map<Id,User>([SELECT Id, Division_Role_Based__c FROM User WHERE Id IN : userIds]);

        for(EventRelation loopEventRelation : eventRelations)
        {
            if(loopEventRelation.IsWhat) // assignedTo User
            {
                eventsMap.get(loopEventRelation.EventId).addInternalAttendee(loopEventRelation, true, relatedUsers.get(loopEventRelation.Event.OwnerId).Division_Role_Based__c,(tasksMap.size() > 0) ? tasksMap.get(loopEventRelation.EventId): null);         
            }
            else if(loopEventRelation.Account.RecordType.DeveloperName == 'RM_Account') // is client attendess    
            {
                eventsMap.get(loopEventRelation.EventId).addClientAttendee(loopEventRelation, relatedContacts.get(loopEventRelation.RelationId));
                eventsMap.get(loopEventRelation.EventId).addRMAccounts(loopEventRelation, relatedContacts.get(loopEventRelation.RelationId));
                eventsMap.get(loopEventRelation.EventId).addPODAccounts(loopEventRelation, relatedContacts.get(loopEventRelation.RelationId));
            }
            else if(loopEventRelation.Account == null && loopEventRelation.Relation.Type == 'Contact') // is Nomura attendees (User)
            {
                eventsMap.get(loopEventRelation.EventId).addInternalAttendee(loopEventRelation, false, relatedContacts.get(loopEventRelation.RelationId).Division__c,null);
            }
            else // is internal attendee (User)
            {
                eventsMap.get(loopEventRelation.EventId).addInternalAttendee(loopEventRelation, false, relatedUsers.get(loopEventRelation.RelationId).Division_Role_Based__c,null);
            }
        }

        //Wrapper to return Events to display and eventIds (Internal and/or Client invitees) to skip querying again on scroll
        EventDetailsWrapper eventDetailsWrapperObj = new EventDetailsWrapper(events, eventIdList);
        return eventDetailsWrapperObj;
    }

    public static String queryOnAccount(String rsAccountId, String accountId, String rmAccountId, String podAccountId)
    {
        String query = '';
        //if POD is selected ignore RM, RG and RS
        if(podAccountId != '')
        {
            query = ' AND relationId in (select Id from Contact Where Pod_Account__c = :podAccountId ) ';
            return query;
        }

        //if RM is selected ignore RG and RS
        if(rmAccountId != '')
        {
            query = 'AND Account.Id =: rmAccountId ';
            return query;
        }
        
        //if RG is selected ignore RS
        if(accountId != '')
        {
            query = 'AND Account.ParentId =: accountId ';
            return query;
        }

        //if RS is selected
        if(rsAccountId != '')
        {
            query = 'AND Account.Parent.ParentId =: rsAccountId ';
            return query;
        }

        if(rsAccountId != '' || accountId != ''){
            query = 'AND Relation.Type=\'Contact\' ';
            return query;
        }

        return query;
    }

    public class EventDetailsWrapper {

        @AuraEnabled
        public List<EventWrapper> eventList {get; set;}
        @AuraEnabled
        public List<Id> eventIdList {get; set;}
                        
        EventDetailsWrapper(List<EventWrapper> eventWrapperList, List<Id> uniqueEventIdList) 
        {
            this.eventList = eventWrapperList;
            this.eventIdList = uniqueEventIdList;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,String> getEventTypes()
    {
        Map<String, String> typeOtions = new Map<String,String>();
        for(L1_Event_Type_Setting__mdt loopType:  CallReportController.getl1EventTypes('false')) 
        {
            typeOtions.put(loopType.L0_Type__c, loopType.L0_Type__c);     
        }
        return typeOtions;
    }
    
    
    public class EventWrapper {

        @AuraEnabled
        public String subject {get; set;}
        @AuraEnabled
        public String eventURL {get; set;}
        @AuraEnabled
        public String description {get; set;}
        @AuraEnabled
        public Datetime eventDate {get; set;}
        @AuraEnabled
        public String activityType {get; set;}
        @AuraEnabled
        public String activitySubType {get; set;}
        @AuraEnabled
        public String id{get; set;}
        @AuraEnabled
        public String detailedDesc{get; set;}

        private boolean isFirstClientAttendee;
        private boolean isFirstRMAccount;
        private boolean isFirstPODAccount;
        private boolean isFirstInternalAttendee;
        private boolean addedAssignedTo;
        @AuraEnabled
        public String clientAttendees {get; set;}

        @AuraEnabled
        public String rmAccounts {get; set;}
        @AuraEnabled
        public List<String> rmAccountList {get; set;}
        @AuraEnabled
        public String podAccounts {get; set;}
        @AuraEnabled
        public List<String> podAccountList {get; set;}

        @AuraEnabled
        public String internalAttendees {get; set;}

        EventWrapper(Id eventId) //String clientAttendeesParam
        {
            this.eventURL = '/' + eventId;
            this.id = eventId;
            this.isFirstClientAttendee = true;
            this.isFirstRMAccount = true;
            this.isFirstPODAccount = true;
            this.isFirstInternalAttendee = true;
            this.addedAssignedTo = false; 
            this.clientAttendees = ''; 
            this.rmAccounts = '';
            this.rmAccountList = new List<String>();
            this.podAccountList = new List<String>();
            this.podAccounts = '';
            this.internalAttendees = '';
        }

        public void addClientAttendee(EventRelation clientAttendee, Contact relatedContact)
        {
            if(this.isFirstClientAttendee)
            {
                isFirstClientAttendee = false;
            }
            else
            {
                this.clientAttendees += '; ';
                this.clientAttendees += '\n';
            }
            
            this.clientAttendees += clientAttendee.Relation.Name + ' @ ' + clientAttendee.Account.Parent.Name;   
            
            if(relatedContact != null)
            {
                if(relatedContact.Title == null || relatedContact.Title == '')
                {
                    //this.clientAttendees += ' - [UNKNOWN FUNCTIONAL TITLE]';
                }
                else 
                {
                    this.clientAttendees += ' - ' + relatedContact.Title;    
                }

                if(relatedContact.PositionPicklist__c == null || relatedContact.PositionPicklist__c == '')
                {
                    //this.clientAttendees += ' - [UNKNOWN ROLE]';  
                }
                else 
                {
                    this.clientAttendees += ' - ' + relatedContact.PositionPicklist__c;        
                }
            }
            
        } 

        public void addRMAccounts(EventRelation clientAttendee, Contact relatedContact)
        { 
            
            if(relatedContact != null )
            {
                String rmAccountName = relatedContact.Account.Name;

                if(rmAccountName != null || rmAccountName != '')
                {
                    if(!rmAccountList.contains(rmAccountName)) {
                        if(this.isFirstRMAccount)
                        {
                            isFirstRMAccount = false;
                            this.rmAccountList.clear();
                        }
                        else
                        {
                            this.rmAccounts += '; ';
                            this.rmAccounts += '\n';
                        }
                        this.rmAccounts +=  rmAccountName;   
                        rmAccountList.add(rmAccountName); 
                    }
                }
            }
        }

        public void addPODAccounts(EventRelation clientAttendee, Contact relatedContact)
        {
            
            if(relatedContact != null )
            {
                String podAccountName = relatedContact.Pod_Account__r.Name;

                if(podAccountName != null)
                {
                    if(!podAccountList.contains(podAccountName)) {
                        if(this.isFirstPODAccount)
                        {
                            isFirstPODAccount = false;
                            this.podAccountList.clear();
                        }
                        else
                        {
                            this.podAccounts += '; ';
                            this.podAccounts += '\n';
                        }
                        this.podAccounts +=  podAccountName;   
                        podAccountList.add(podAccountName); 
                    }
                }
                else {
                     this.podAccounts = '';
                }
            }       
        }
     
        public void addInternalAttendee(EventRelation clientAttendee, Boolean isAssignedTo, String division,Task_LTA__c note)
        {
            if(this.isFirstInternalAttendee)
            {
                isFirstInternalAttendee = false;
            }
            else
            {
                this.internalAttendees += '; ';
                this.internalAttendees += '\n';
            }
            
            if(isAssignedTo && !addedAssignedTo)
            {
                // set wrapper event details and add Assigned To to internal invitees (there should alway be one invitee on a call report)
                if(division != null && division != ''){
                    this.internalAttendees += clientAttendee.Event.Owner.Name + + ' (Assigned To) - ' + division;
                }else{
                    this.internalAttendees += clientAttendee.Event.Owner.Name + + ' (Assigned To)';
                }
                addedAssignedTo = true;
                this.subject = clientAttendee.Event.Subject;
                this.description = clientAttendee.Event.Description;//eventParam.Event.Description;
                this.eventDate = clientAttendee.Event.StartDateTime;
                this.activityType = clientAttendee.Event.L0_Type__c;
                this.activitySubType = clientAttendee.Event.Type;
                if(null != note && null != note.LTA_1__c){
                    this.detailedDesc = CommonTools.removeHTMLTags(note.LTA_1__c);
                }
                else{
                    this.detailedDesc = '';
                }
                
            }
            else
            {
                if(division != null && division != ''){
                    this.internalAttendees += clientAttendee.Relation.Name + ' - ' + division;   
                }else{
                    this.internalAttendees += clientAttendee.Relation.Name;
                }
            }
           
        }

    }
    
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchInternalInvitees(String searchTerm, Boolean excludeInactive, String excludeProfile) {
        
        // Prepare query paramters
        searchTerm += '*';

        String searchQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING ' +
                                'User (Id, Name, IsActive, CompanyName, Region__c WHERE Profile.Name !=: excludeProfile ';
                                
        if(excludeInactive)
        {
            searchQuery += 'AND IsActive =: excludeInactive'; 
        } 
        
        searchQuery += '), Contact (Id, Name, Account.Name WHERE Account.RecordType.DeveloperName =: employeeAccountRecordTypeDevName ';

        if(excludeInactive)
        {
            searchQuery += 'AND Active__c =: excludeInactive';
        }
        searchQuery += ')';

        // Execute search query
        List<List<SObject>> searchResults =search.query(searchQuery);


        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String userIcon = 'standard:user';
        User [] users = ((List<User>) searchResults[0]);
        for (User user : users) {
            String active = '';
            if(!user.IsActive){active = ' (INACTIVE)';}
            results.add(new LookupSearchResult(user.Id, 'User', userIcon, user.Name + active, 'User • ' + user.Region__c + ' | ' + user.CompanyName));
        }

        // Extract Opportunities & convert them into LookupSearchResult
        String coontactIcon = 'standard:contact';
        Contact [] contacts = ((List<Contact>) searchResults[1]);
        for (Contact contact : contacts) {
            results.add(new LookupSearchResult(contact.Id, 'Contact', coontactIcon, contact.Name, 'Contact • '+ contact.Account.Name));
        }

        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchClientAttendees(String searchTerm, Boolean excludeInactive) 
    {
        // Prepare query paramters
        searchTerm += '*';

        String searchQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING ' +
                                'Contact (Id, Name, Account.Name WHERE Account.RecordType.DeveloperName !=: employeeAccountRecordTypeDevName ';
                                
        if(excludeInactive)
        {
            searchQuery += 'AND Active__c =: excludeInactive'; 
        } 

        searchQuery += ')';

        // Execute search query
        List<List<SObject>> searchResults =search.query(searchQuery);


        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Opportunities & convert them into LookupSearchResult
        String coontactIcon = 'standard:contact';
        Contact [] contacts = ((List<Contact>) searchResults[0]);
        for (Contact contact : contacts) {
            results.add(new LookupSearchResult(contact.Id, 'Contact', coontactIcon, contact.Name, 'Contact • '+ contact.Account.Name));
        }

        return results;

    }

    @AuraEnabled
    public static List<LookupSearchResult> searchRSAccount(String searchTerm){
        // Prepare query paramters
        searchTerm += '*';

        String searchQuery = 'FIND :searchTerm IN NAME FIELDS RETURNING ' +
        'Account(Id, Name, RDM_Org_ID__c WHERE RecordType.DeveloperName = \'RS_Account\')';

        // Execute search query
        List<List<SObject>> searchResults =search.query(searchQuery);

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        String accountIcon = 'standard:account';
        Account [] accounts = ((List<Account>) searchResults[0]);
        for (Account account : accounts) {
            results.add(new LookupSearchResult(account.Id, 'Account', accountIcon, account.Name, 'Account '+ account.RDM_Org_ID__c));
        }

        return results;        
    }

    @AuraEnabled(Cacheable=true)
    public static Contact getContact(String contactId)
    {
        Contact theContact = [Select Name, Account.RecordType.DeveloperName From Contact Where Id =: contactId];
        return theContact;
    }

    @AuraEnabled(Cacheable=true)
    public static User getUser(String userId)
    {
        User theUser = [Select Name From User Where Id =: userId];
        return theUser;
    }

    @AuraEnabled(Cacheable=true)
    public static Account getAccount(String accountId){
        Account account = [SELECT Name, RecordType.DeveloperName FROM Account WHERE Id =: accountId];
        return account;
    }


}