@IsTest
private class OutlookPluginControllerTest
{
    @IsTest
    private static void testReturningAllRMAddressesForaRGAccount()
    {
        List<OutlookPluginController.OptionWrapper> lstOptionWrapper;
        Account rgAccount = [SELECT Id FROM Account WHERE Name = 'Test RG account' and RDM_Org_ID__c = 'RG000000'];

        Test.startTest();
        lstOptionWrapper = OutlookPluginController.getRMAccountWrappersForParentRG(rgAccount.Id);
        Test.stopTest();

        System.assert(lstOptionWrapper!=null && !lstOptionWrapper.isEmpty(),'OptionWrapper address list of RM accounts for the given RG Id cannot be null or empty');

        for(OutlookPluginController.OptionWrapper wrapper : lstOptionWrapper)
        {
            System.assert(String.isNotBlank(wrapper.label),'OptionWrapper label for any RM account cannot be null or empty. Wrapper data as received: '+ wrapper);
            System.assert(String.isNotBlank(wrapper.value),'OptionWrapper value for any RM account cannot be null or empty. Wrapper data as received: '+ wrapper);
        }
    }

    @IsTest
    private static void testReturningRMAddressesForNotMatchingRGAccount()
    {
        List<OutlookPluginController.OptionWrapper> lstOptionWrapper;
        Test.startTest();
        lstOptionWrapper = OutlookPluginController.getRMAccountWrappersForParentRG('do_not_match_me');
        Test.stopTest();

        System.assert(lstOptionWrapper!=null && lstOptionWrapper.isEmpty(),'OptionWrapper address list of RM accounts where no RG Account matches must not be null but should be empty');
    }


    @IsTest
    private static void testGetExistingOutlookEventWithAttendees()
    {
        List<EventRelation> lstEventRelation = new List<EventRelation>();
        EventRelation eventRelation;
        Account rgAccount = [SELECT Id FROM Account WHERE Name = 'Test RG account' AND RDM_Org_ID__c = 'RG000000'];

        Event outlookEvent = UtilityTesting.createEvent('Standard_Event',null,'Pre-meeting Notification');
        outlookEvent.Source__c = 'Outlook Plugin';
        outlookEvent.Outlook_Global_Appointment_Id__c = '000111222333444555';
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

        Test.startTest();
        OutlookPluginController.EventDetailsWrapper eventDetailsWrapper = OutlookPluginController.getExistingEventDetails(outlookEvent.Outlook_Global_Appointment_Id__c);
        Test.stopTest();

        System.assert(eventDetailsWrapper.activityType == outlookEvent.L0_Type__c,'eventDetailsWrapper.activityType must be equal to event L0_Type__c');
        System.assert(eventDetailsWrapper.activitySubType == outlookEvent.L0_Type__c,'eventDetailsWrapper.activityType must be equal to event Type');
        System.assert(eventDetailsWrapper.primaryRgAccountId == outlookEvent.WhatId,'eventDetailsWrapper.primaryRgAccountId must be equal to event WhatId');
        System.assert(eventDetailsWrapper.lstUserAttendees != null && !eventDetailsWrapper.lstUserAttendees.isEmpty(),'eventDetailsWrapper.lstUserAttendees list cannot be null or empty');
        System.assert(eventDetailsWrapper.lstContactAttendees != null && !eventDetailsWrapper.lstContactAttendees.isEmpty(),'eventDetailsWrapper.lstContactAttendees list cannot be null or empty');
    }

    @TestSetup
    private static void setupTestData()
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