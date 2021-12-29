@isTest
private with sharing class ActivityFinderTest 
{    
    static testmethod void ActivityFinderTest()
    {
        Account sLevel = UtilityTesting.createRSAccount(
                'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        insert sLevel;
            
        Account rg1 = UtilityTesting.createRGAccount(
                'G Test Account', sLevel.Id, 'Test2', '52nd Street', 'California', 'United States', true);
        insert rg1;
            
        Account rg1rm1 = UtilityTesting.createRMAccount(
                'RM Test Account 1', rg1.Id, 'Test3', '52nd Street', 'California', 'United States', true);
        insert rg1rm1;
        
        Account pod1 = UtilityTesting.createPODAccount(
                'POD Test Account 1', rg1.Id, 'Test4', '52nd Street', 'California', 'United States', true);
        insert pod1;
       
        Contact c = UtilityTesting.createContact('John', 'Smith', 'johnnysmith@test.com', '(212) 333-4567', 'Dear [FirstName]', rg1rm1.Id, true);
        c.POD_Account__c = pod1.Id;
        insert c;

        Event testEvent = UtilityTesting.createEvent('Standard_Event', c.id, 'Analyst Meeting');
        testEvent.whatId = rg1.id;
        testEvent.ownerId = UserInfo.getUserId();
        testEvent.StartDateTime = system.now();
        testEvent.EndDateTime = system.now()+1;
        insert testEvent;
        test.startTest();   
			List<Id> eventIds = new List<Id>();
        	Datetime today = system.now();

            ActivityFinder.EventDetailsWrapper eventObj1 = ActivityFinder.getActivites('', '', '', '', '', '', null, 
                null, null, 0, 30, eventIds,null);
            System.assertEquals(1, eventObj1.eventList.size());    

            ActivityFinder.EventDetailsWrapper eventObj2 = ActivityFinder.getActivites(sLevel.id, rg1.id, '', '', c.id, UserInfo.getUserId(), today-1, 
                today+1, null, 0, 30, eventIds,'Export');
            System.assertEquals(1, eventObj2.eventList.size());

            ActivityFinder.EventDetailsWrapper eventObj3 = ActivityFinder.getActivites(sLevel.id, rg1.id, rg1rm1.id,'', c.id, UserInfo.getUserId(), today-1, 
                today+1, null, 0, 30, eventIds,'Export');
            System.assertEquals(1, eventObj3.eventList.size());

            ActivityFinder.EventDetailsWrapper eventObj4 = ActivityFinder.getActivites(sLevel.id, rg1.id, rg1rm1.id, pod1.id, c.id, UserInfo.getUserId(), today-1, 
                today+1, null, 0, 30, eventIds,'Export');
            System.assertEquals(1, eventObj4.eventList.size());
        
            Map<String,String> options = ActivityFinder.getEventTypes();

            List<LookupSearchResult> testSearchInternal = ActivityFinder.searchInternalInvitees(UserInfo.getFirstName(), true, null);

            List<LookupSearchResult> testSearchClient = ActivityFinder.searchClientAttendees('John', true);
        
        	List<LookupSearchResult> testSearchAccount = ActivityFinder.searchRSAccount('Account');
            
            Contact testGetContact = ActivityFinder.getContact(c.id);
            System.assertEquals('John Smith', testGetContact.Name);

            User testGetUser = ActivityFinder.getUser(UserInfo.getUserId()); 
        
        	Account testGetAccount = ActivityFinder.getAccount(sLevel.Id);
            System.assertEquals('RS_Account', testGetAccount.RecordType.DeveloperName);

        test.stopTest();


    }
}