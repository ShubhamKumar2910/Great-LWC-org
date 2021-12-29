@IsTest
private class OutlookPluginWebServiceTest
{
    @IsTest
    static void testCreatingNewOutlookPluginCallReportValidRequestData()
    {
        List<String> lstAttendeeEmails = new List<String>();
        List<String> lstAttendeeContactIds = new List<String>();
        List<String> lstInternalAttendeeIds = new List<String>();

        Account rgAccount = [SELECT Id FROM Account WHERE Name = 'Test RG account' AND RDM_Org_ID__c = 'RG000000'];
        List<Contact> lstContact = [SELECT Id, Email FROM Contact WHERE FirstName = 'outlook_firstname' AND LastName = 'outlook_lastname' And Active__c = TRUE];
        System.assert(!lstContact.isEmpty(),'List of created contacts must not be empty. These will be used to create attendees');

        for(Contact contact : lstContact)
        {
            lstAttendeeEmails.add(contact.Email);
            lstAttendeeContactIds.add(contact.Id);
        }

        List<User> lstUser = [SELECT Id,Email FROM User WHERE Email LIKE 'newuser%@testorg.com' AND LastName LIKE 'Testing%'];
        System.assert(!lstUser.isEmpty(),'List of created users must not be empty. These will be used to create attendees');
        for(User user : lstUser)
        {
            lstAttendeeEmails.add(user.Email);
            lstInternalAttendeeIds.add(user.Id);
        }

        CallReportDataWrapper.CallReportData callReportData = prepareCallReportData('040000008200E00999999','Test call report subject', 'Test call report location', 'Test call report long meeting description',
                Datetime.now(), Datetime.now()+1, '(UTC+00:00) Dublin, Edinburgh, Lisbon, London', lstAttendeeEmails, lstAttendeeEmails, 'General Meeting', 'Sales Meeting', '', rgAccount.Id, lstAttendeeContactIds,
                lstInternalAttendeeIds, 'test3rdparty1@test.com,test3rdparty2@test.com', false, UserInfo.getUserEmail());

        RestRequest request = new RestRequest();
        request.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/callreport/';
        request.httpMethod = 'PUT';
        request.requestBody = Blob.valueOf(JSON.serialize(callReportData));
        RestContext.request = request;

        Test.startTest();
        CallReportDataWrapper.CallReportResponse response = OutlookPluginWebService.upsertCallReport();
        Test.stopTest();
        system.debug('############## response:: '+ response);

        OutlookPluginController.EventDetailsWrapper eventDetailsWrapper = OutlookPluginController.getExistingEventDetails(callReportData.GlobalAppointmentId);
        System.assert(eventDetailsWrapper.activityType == callReportData.Type,'eventDetailsWrapper.activityType must be equal to call report data type');
        System.assert(eventDetailsWrapper.activitySubType == callReportData.SubType,'eventDetailsWrapper.activityType must be equal to call report data sub type');
        System.assert(eventDetailsWrapper.primaryRgAccountId == callReportData.PrimaryClientId,'eventDetailsWrapper.primaryRgAccountId must be equal to call report data RG account id');
        System.assert(eventDetailsWrapper.lstUserAttendees != null && eventDetailsWrapper.lstUserAttendees.size() == callReportData.InternalContactIds.size(),'eventDetailsWrapper.lstUserAttendees list size must be equal to InternalContactIds');
        System.assert(eventDetailsWrapper.lstContactAttendees != null && eventDetailsWrapper.lstContactAttendees.size() == callReportData.ClientContactIds.size(),'eventDetailsWrapper.lstContactAttendees list size must be equal to ClientContactIds');
    }

    @IsTest
    static void testUpdatingExistingOutlookPluginCallReportValidRequestData()
    {
        List<EventRelation> lstEventRelation = new List<EventRelation>();
        EventRelation eventRelation;
        List<String> lstInternalContactIds = new List<String>();
        List<String> lstClientContactIds = new List<String>();
        List<String> lstAttendeeEmails = new List<String>();
        Account rgAccount = [SELECT Id FROM Account WHERE Name = 'Test RG account' AND RDM_Org_ID__c = 'RG000000'];

        // create new call report
        Event outlookEvent = UtilityTesting.createEvent('Standard_Event',null,'Pre-meeting Notification');
        outlookEvent.Source__c = 'Outlook Plugin';
        outlookEvent.Outlook_Global_Appointment_Id__c = '000111222333444555';
        outlookEvent.L0_Type__c = 'Pre-meeting Notification';
        outlookEvent.WhatId = rgAccount.Id;
        outlookEvent.Third_Party_Emails__c = 'test999@test.com,test9999@test.com';
        outlookEvent.Subject = 'test meeting subject';
        outlookEvent.Location = 'test meeting location';
        outlookEvent.Description = 'test meeting long description and agenda';
        outlookEvent.StartDateTime = DateTime.now();
        outlookEvent.EndDateTime = Datetime.now()+1;
        upsert outlookEvent Outlook_Global_Appointment_Id__c;
        system.debug('############ event:: '+ outlookEvent);

        System.assert(String.isNotBlank(outlookEvent.Id),'Event record must have a record Id before event relations can be created for it');

        List<Contact> lstContact = [SELECT Id, Email FROM Contact WHERE FirstName = 'outlook_firstname' AND LastName = 'outlook_lastname' And Active__c = TRUE];
        System.assert(!lstContact.isEmpty(),'List of created contacts must not be empty. These will be used to create attendees');
        for(Contact contact : lstContact)
        {
            eventRelation = UtilityTesting.createEventRelation(outlookEvent.Id,contact.Id,true,false);
            lstEventRelation.add(eventRelation);
            lstClientContactIds.add(contact.Id);
            lstAttendeeEmails.add(contact.Email);
        }

        List<User> lstUser = [SELECT Id, Email FROM User WHERE Email LIKE 'newuser%@testorg.com' AND LastName LIKE 'Testing%'];
        System.assert(!lstUser.isEmpty(),'List of created users must not be empty. These will be used to create attendees');
        for(User user : lstUser)
        {
            eventRelation = UtilityTesting.createEventRelation(outlookEvent.Id,user.Id,false,true);
            lstEventRelation.add(eventRelation);
            lstInternalContactIds.add(user.Id);
            lstAttendeeEmails.add(user.Email);
        }

        insert lstEventRelation;

        // prepare call report API data object from the above existing event and make additions to subject
        CallReportDataWrapper.CallReportData callReportData = prepareCallReportData(outlookEvent.Outlook_Global_Appointment_Id__c,outlookEvent.Subject, outlookEvent.Location, outlookEvent.Description,
                outlookEvent.StartDateTime, outlookEvent.EndDateTime, '(UTC+00:00) Dublin, Edinburgh, Lisbon, London', lstAttendeeEmails, lstAttendeeEmails, 'General Meeting', 'Sales Meeting', '', rgAccount.Id, lstClientContactIds,
                lstInternalContactIds, 'test3rdparty1@test.com,test3rdparty2@test.com', false, UserInfo.getUserEmail());

        // remove one attendee in call report data and
        callReportData.ClientContactIds.remove(callReportData.ClientContactIds.size()-1);
        RestRequest request = new RestRequest();
        request.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/callreport/';
        request.httpMethod = 'PUT';
        request.requestBody = Blob.valueOf(JSON.serialize(callReportData));
        RestContext.request = request;

        Test.startTest();
        CallReportDataWrapper.CallReportResponse response = OutlookPluginWebService.upsertCallReport();
        Test.stopTest();
        system.debug('############## response:: '+ response);
        OutlookPluginController.EventDetailsWrapper eventDetailsWrapper = OutlookPluginController.getExistingEventDetails(callReportData.GlobalAppointmentId);
        System.assert(eventDetailsWrapper.lstContactAttendees != null && eventDetailsWrapper.lstContactAttendees.size() < lstContact.size(),'eventDetailsWrapper.lstContactAttendees list size must be less than the total contacts list lstContact');
        System.assert(eventDetailsWrapper.thirdPartyEmails != null && eventDetailsWrapper.thirdPartyEmails == callReportData.ThirdPartyEmails,'eventDetailsWrapper.thirdPartyEmails must be the same as in the passed data callReportData.ThirdPartyEmails');
    }

    @IsTest
    static void testCreatingNewOutlookPluginCallReportInvalidRequestData()
    {
        Account rgAccount = [SELECT Id FROM Account WHERE Name = 'Test RG account' AND RDM_Org_ID__c = 'RG000000'];

        CallReportDataWrapper.CallReportData callReportData = prepareCallReportData('','', 'Test call report location', 'Test call report long meeting description',
                Datetime.now(), Datetime.now()+1, '(UTC+00:00) Dublin, Edinburgh, Lisbon, London', null, null, 'General Meeting', 'Sales Meeting', '', rgAccount.Id, null,
                null, 'test3rdparty1@test.com,test3rdparty2@test.com', false, UserInfo.getUserEmail());

        RestRequest request = new RestRequest();
        request.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/callreport/';
        request.httpMethod = 'PUT';
        request.requestBody = Blob.valueOf(JSON.serialize(callReportData));
        RestContext.request = request;

        Test.startTest();
        CallReportDataWrapper.CallReportResponse response = OutlookPluginWebService.upsertCallReport();
        Test.stopTest();
        system.debug('############## response:: '+ response);
        System.assert(String.isNotBlank(response.ErrorMessage), 'Call report data with missing subject and outlook global id must get an error message in response');
    }

    @IsTest
    static void testCreatingNewOutlookPluginCallReportEmptyRequestData()
    {
        RestRequest request = new RestRequest();
        request.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/callreport/';
        request.httpMethod = 'PUT';
        // empty request body
        request.requestBody = Blob.valueOf('');
        RestContext.request = request;

        Test.startTest();
        CallReportDataWrapper.CallReportResponse response = OutlookPluginWebService.upsertCallReport();
        Test.stopTest();
        system.debug('############## response:: '+ response);
        System.assert(String.isNotBlank(response.ErrorMessage), 'Empty call report data request must get an error message in response');
    }

    @IsTest
    static void testDeletingExistingCallReport()
    {
        List<EventRelation> lstEventRelation = new List<EventRelation>();
        EventRelation eventRelation;
        Account rgAccount = [SELECT Id FROM Account WHERE Name = 'Test RG account' AND RDM_Org_ID__c = 'RG000000'];

        Event outlookEvent = UtilityTesting.createEvent('Standard_Event',null,'Pre-meeting Notification');
        outlookEvent.Source__c = 'Outlook Plugin';
        outlookEvent.Outlook_Global_Appointment_Id__c = '000999888777666555';
        outlookEvent.L0_Type__c = 'Pre-meeting Notification';
        outlookEvent.WhatId = rgAccount.Id;
        outlookEvent.Third_Party_Emails__c = 'test999@test.com,test9999@test.com';
        outlookEvent.Subject = 'test meeting subject';
        outlookEvent.Location = 'test meeting location';
        outlookEvent.Description = 'test meeting long description and agenda';
        upsert outlookEvent Outlook_Global_Appointment_Id__c;
        system.debug('############ event:: '+ outlookEvent);

        System.assert(String.isNotBlank(outlookEvent.Id),'Event record must have a record Id before event relations can be created for it');

        List<Contact> lstContact = [SELECT Id FROM Contact WHERE FirstName = 'outlook_firstname' AND LastName = 'outlook_lastname' And Active__c = TRUE];
        System.assert(!lstContact.isEmpty(),'List of created contacts must not be empty. These will be used to create attendees');
        for(Contact contact : lstContact)
        {
            eventRelation = UtilityTesting.createEventRelation(outlookEvent.Id,contact.Id,true,false);
            lstEventRelation.add(eventRelation);
        }

        List<User> lstUser = [SELECT  Id FROM User WHERE Email LIKE 'newuser%@testorg.com' AND LastName LIKE 'Testing%'];
        System.assert(!lstUser.isEmpty(),'List of created users must not be empty. These will be used to create attendees');
        for(User user : lstUser)
        {
            eventRelation = UtilityTesting.createEventRelation(outlookEvent.Id,user.Id,false,true);
            lstEventRelation.add(eventRelation);
        }

        insert lstEventRelation;

        CallReportDataWrapper.CallReportData callReportData = new CallReportDataWrapper.CallReportData();
        callReportData.GlobalAppointmentId = outlookEvent.Outlook_Global_Appointment_Id__c;
        callReportData.MeetingId = outlookEvent.Id;

        RestRequest request = new RestRequest();
        request.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/callreport/';
        request.httpMethod = 'PATCH';
        request.requestBody = Blob.valueOf(JSON.serialize(callReportData));
        RestContext.request = request;

        Test.startTest();
        OutlookPluginWebService.deleteCallReport();
        Test.stopTest();

        List<Event> lstEvent = [SELECT Id FROM Event WHERE Outlook_Global_Appointment_Id__c = :outlookEvent.Outlook_Global_Appointment_Id__c];
        System.assert(lstEvent.isEmpty(),'The list returned following the event deletion must be empty');
    }

    @IsTest
    static void testDeletingNonExistingCallReport()
    {
        CallReportDataWrapper.CallReportData callReportData = new CallReportDataWrapper.CallReportData();
        callReportData.GlobalAppointmentId = 'do_not_match_anything_000';
        callReportData.MeetingId = '';

        RestRequest request = new RestRequest();
        request.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/callreport/';
        request.httpMethod = 'PATCH';
        request.requestBody = Blob.valueOf(JSON.serialize(callReportData));
        RestContext.request = request;

        Test.startTest();
        String outcome = OutlookPluginWebService.deleteCallReport();
        Test.stopTest();

        System.assert(String.isNotBlank(outcome) && outcome.containsIgnoreCase('error'),'Deleting an event with a non-existent outlook global appointment id must return an error message');
    }

    @IsTest
    static void testDeletingCallReportWithEmptyGlobalAppId()
    {
        CallReportDataWrapper.CallReportData callReportData = new CallReportDataWrapper.CallReportData();
        callReportData.GlobalAppointmentId = '';
        callReportData.MeetingId = '';

        RestRequest request = new RestRequest();
        request.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/callreport/';
        request.httpMethod = 'PATCH';
        request.requestBody = Blob.valueOf(JSON.serialize(callReportData));
        RestContext.request = request;

        Test.startTest();
        String outcome = OutlookPluginWebService.deleteCallReport();
        Test.stopTest();

        System.assert(String.isNotBlank(outcome) && outcome.containsIgnoreCase('error'),'Deleting an event with empty value of outlook global appointment id must return an error message');
    }

    @IsTest
    static void testTruncatingEmailString()
    {
        String concatenatedEmails = 'test@test.com';

        for(integer i=0; i<20 ; i++)
        {
            concatenatedEmails += ',test'+i+'test.com';
        }

        System.assert(concatenatedEmails.length() > 255, 'Input test string of concatenated emails must be a length greater than 255');
        String truncatedResult = OutlookPluginWebService.truncateStringWithinMaxLength(concatenatedEmails);
        System.assert(String.isNotBlank(truncatedResult) && truncatedResult.length() <= 255, 'Truncated result string of concatenated emails must not be empty and have a length less than 255');
    }

    static CallReportDataWrapper.CallReportData prepareCallReportData(String GlobalAppointmentId, String Subject, String Location, String MeetingDescription,
            DateTime StartTime, Datetime EndTime, String TimeZone, String[] DelimitedToList, String[] ActualToAddressList, String Type, String SubType,
            String TypeFlag, String PrimaryClientId, String[] ClientContactIds, String[] InternalContactIds, String ThirdPartyEmails, Boolean Cancelled,
            String DelimitedOrganiserEmailId)
    {
        CallReportDataWrapper.CallReportData callReportData = new CallReportDataWrapper.CallReportData();
        callReportData.GlobalAppointmentId = GlobalAppointmentId;
        callReportData.Subject = Subject;
        callReportData.Location = Location;
        callReportData.MeetingDescription = MeetingDescription;
        callReportData.StartTime = StartTime;
        callReportData.EndTime = EndTime;
        callReportData.TimeZone = TimeZone;
        callReportData.DelimitedToList = DelimitedToList;
        callReportData.ActualToAddressList = ActualToAddressList;
        callReportData.Type = Type;
        callReportData.SubType = SubType;
        callReportData.TypeFlag = TypeFlag;
        callReportData.PrimaryClientId = PrimaryClientId;
        callReportData.ClientContactIds = ClientContactIds;
        callReportData.InternalContactIds = InternalContactIds;
        callReportData.ThirdPartyEmails = ThirdPartyEmails;
        callReportData.Cancelled = Cancelled;
        callReportData.DelimitedOrganiserEmailId = DelimitedOrganiserEmailId;

        return callReportData;
    }

    @TestSetup
    private static void testDataSetup()
    {
        Integer count = 0;
        List<Account> lstAccountsInsert =  new List<Account>();
        List<Contact> lstContactInsert = new List<Contact>();
        Integer random = UtilityTesting.getRandomInteger(1,10000);

        Account rgAccount = UtilityTesting.createRGAccount('Test RG account',null,'RG000000','Test billing street', 'London', 'United Kingdom',true);
        insert rgAccount;

        for(integer i=0; i<5; i++)
        {
            Account rmAccount = UtilityTesting.createRMAccount('Test RM Account'+i,rgAccount.Id,'RM00000'+i,'Test RM billing str'+i, 'London', 'United Kingdom',true);
            lstAccountsInsert.add(rmAccount);
        }
        insert lstAccountsInsert;

        for(integer i=0; i<5; i++)
        {
            Contact contact = UtilityTesting.createContact('outlook_firstname','outlook_lastname','fn_outlook'+random+i+'@test.com','44208000000','Mr',lstAccountsInsert.get(0).Id,true);
            contact.RG_Account__c = rgAccount.Id;
            lstContactInsert.add((contact));
        }
        insert lstContactInsert;

        List<User> lstUser = UtilityTesting.createUsersWithProfile(2,'Nomura - Sales');
    }
}