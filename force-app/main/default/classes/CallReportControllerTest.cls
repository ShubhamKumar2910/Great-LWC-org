@isTest
private class CallReportControllerTest {
/*
     private testMethod static void checkCurrentUserPrivacyFlagTest(){
        List<User> japanFIUsers = UtilityTesting.createUsersWithProfileAndRole(1, 'Nomura - Sales', 'Japan - FI - Sales', 'Japan_FI_Sales');
        List<User> emeaFIUsers = UtilityTesting.createUsersWithProfileAndRole(1, 'Nomura - Sales', 'EMEA - FI - Sales', 'EMEA_FI_Sales');
        Test.startTest();
        if(japanFIUsers.size() > 0){
            User japanUser = japanFIUsers[0];
            System.runAs(japanUser){
                Boolean isUserJapanFISales = CallReportController.checkCurrentUserPrivacyFlag();
                System.assertEquals(true, isUserJapanFISales);
            }
        }
        
        if(emeaFIUsers.size() > 0){
            User emeaUser = emeaFIUsers[0];
            System.runAs(emeaUser){
                Boolean isUserJapanFISales = CallReportController.checkCurrentUserPrivacyFlag();
                System.assertEquals(false, isUserJapanFISales);
            }
        }
        
        Test.stopTest();
        
    }
*/
    
    private testMethod static void getUserDetailsTest(){
    	List<User> japanFIUsers = UtilityTesting.createUsersWithProfileAndRole(1, 'Nomura - Sales', 'Japan - FI - Sales', 'Japan_FI_Sales');
        List<User> emeaFIUsers = UtilityTesting.createUsersWithProfileAndRole(1, 'Nomura - Sales', 'EMEA - FI - Sales', 'EMEA_FI_Sales');
        List<CallReportController.UserDetails> userDetailsList = new List<CallReportController.UserDetails>();
        Test.startTest();
        if(japanFIUsers.size() > 0){
            User japanUser = japanFIUsers[0];
            System.runAs(japanUser){
                String userDetailString = CallReportController.getUserDetails();
                userDetailsList = (List<CallReportController.UserDetails>) JSON.deserialize(userDetailString, List<CallReportController.UserDetails>.class);
                System.debug('---udL---' +  userDetailsList);
                System.debug('---udL---' +  userDetailsList[0].isJapanFIUserDetail );
                System.assertEquals(true, userDetailsList[0].isJapanFIUserDetail);
                
            }
        }
        
        if(emeaFIUsers.size() > 0){
            User emeaUser = emeaFIUsers[0];
            System.runAs(emeaUser){
                String userDetailString = CallReportController.getUserDetails();               
                userDetailsList = (List<CallReportController.UserDetails>) JSON.deserialize(userDetailString, List<CallReportController.UserDetails>.class);
                System.debug('---udL---' +  userDetailsList);
                System.debug('---udL---' +  userDetailsList[0].isJapanFIUserDetail );
                System.assertEquals(false, userDetailsList[0].isJapanFIUserDetail);
                
            }
        }
        
    }
    
    private testMethod static void getAccountContactsTest(){
        Account sLevel = UtilityTesting.createRSAccount(
                'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        insert sLevel;
            
        Account rg1 = UtilityTesting.createRGAccount(
                'G Test Account', sLevel.Id, 'Test2', '52nd Street', 'California', 'United States', true);
        insert rg1;
            
        Account rg1rm1 = UtilityTesting.createRMAccount(
                'RM Test Account 1', rg1.Id, 'Test3', '52nd Street', 'California', 'United States', true);
        insert rg1rm1;


        Contact c = UtilityTesting.createContact('John', 'Smith', 'johnnysmith@test.com', '(212) 333-4567', 'Dear [FirstName]', rg1rm1.Id, true);
        insert c;
        Test.startTest();
        Contact[] contacts = CallReportController.getAccountContacts(rg1rm1.Id);
        List<PicklistAttributes> pickattr = CallReportController.getPositionPicklistValues();
        Test.stopTest();
        System.assertEquals(contacts.size(), 1);
    }

    private testMethod static void initialiseLabelsTest(){
        Map<String, Map<String, String>> labelsMap = new Map<String, Map<String, String>>();

        labelsMap = CallReportController.initialiseLabels();

        System.assertNotEquals(labelsMap, null);
    }
    
    private testMethod static void getAllSectorsTest(){
        Map<String,String> valueMap = CallReportController.getAllSectors();
        System.assert(valueMap.size() > 0);
    }
    
    private testMethod static void initialiseNewCallReportTest(){
        Test.startTest();
        Event newCallReport = CallReportController.initialiseNewCallReport(null, false, false);

        System.assertEquals(newCallReport.OwnerId, UserInfo.getUserId());
        System.assertEquals(newCallReport.Type, 'Sales Meeting');
        //System.assertEquals(newCallReport.StartDateTime, Datetime.now());
        Test.stopTest();
    }

    private testMethod static void createContactTest(){
        Account sLevel = UtilityTesting.createRSAccount(
                'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        insert sLevel;
            
        Account rg1 = UtilityTesting.createRGAccount(
                'G Test Account', sLevel.Id, 'Test2', '52nd Street', 'California', 'United States', true);
        insert rg1;
            
        Account rg1rm1 = UtilityTesting.createRMAccount(
                'RM Test Account 1', rg1.Id, 'Test3', '52nd Street', 'California', 'United States', true);
        insert rg1rm1;


        Contact c = UtilityTesting.createContact('John', 'Smith', 'johnnysmith@test.com', '(212) 333-4567', 'Dear [FirstName]', rg1rm1.Id, true);
             
        Test.startTest();
        Map<String, String> result = CallReportController.createContact(c, rg1rm1.Id);
        Test.stopTest();
        System.assertNotEquals(result, null);
    }

    private testMethod static void populateWhatIdTest(){
        Account sLevel = UtilityTesting.createRSAccount(
                'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        insert sLevel;
            
        Account rg1 = UtilityTesting.createRGAccount(
                'G Test Account', sLevel.Id, 'Test2', '52nd Street', 'California', 'United States', true);
        insert rg1;
            
        Account rg1rm1 = UtilityTesting.createRMAccount(
                'RM Test Account 1', rg1.Id, 'Test3', '52nd Street', 'California', 'United States', true);
        insert rg1rm1;


        Contact c = UtilityTesting.createContact('John', 'Smith', 'johnnysmith@test.com', '(212) 333-4567', 'Dear [FirstName]', rg1rm1.Id, true);
             
        insert c;
        Test.startTest();
        String result = CallReportController.populateWhatId(c.Id);
        Test.stopTest();
        System.assertEquals(result, rg1.Id);

    }

    private testMethod static void saveNewEventTest(){

        Account sLevel = UtilityTesting.createRSAccount(
                'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        insert sLevel;
            
        Account rg1 = UtilityTesting.createRGAccount(
                'G Test Account', sLevel.Id, 'Test2', '52nd Street', 'California', 'United States', true);
        insert rg1;
            
        Account rg1rm1 = UtilityTesting.createRMAccount(
                'RM Test Account 1', rg1.Id, 'Test3', '52nd Street', 'California', 'United States', true);
        insert rg1rm1;

        Account rg1rm2 = UtilityTesting.createRMAccount(
                'RM Test Account 2', rg1.Id, 'Test4', '52nd Street', 'California', 'United States', true);
        insert rg1rm2;
            
        List<Contact> contacts = new List<Contact>();

        Contact c = UtilityTesting.createContact('John', 'Smith', 'johnnysmith@test.com', '(212) 333-4567', 'Dear [FirstName]', rg1rm1.Id, true);
        contacts.add(c);

        Contact c1 = UtilityTesting.createContact('James', 'Smith', 'jamessmith@test.com', '(212) 333-4567', 'Dear [FirstName]', rg1rm2.Id, true);
        contacts.add(c1);
      
        insert contacts;
	System.debug('---1contacts---' + contacts);
        Id phoneBookRecordTypeId = Schema.getGlobalDescribe().get('Campaign').getDescribe().getRecordTypeInfosByName().get('Phone Book').getRecordTypeId(); 
        //Insert Campaign of Type Phone Book
       Campaign phoneBookCampaignObj = new Campaign();
       phoneBookCampaignObj.Name = 'Test Contact List' ;
       phoneBookCampaignObj.RecordTypeId = phoneBookRecordTypeId;
       
       insert phoneBookCampaignObj;
        
       campaign campaignObj = null; 
       List<Campaign> campaignList = [SELECT Id, Name FROM Campaign WHERE Name = 'Test Contact List'] ;
      
        if(campaignList != null && campaignList.size() > 0){
      	  campaignObj =  campaignList.get(0);
        }
        
        List<String> internalInvitees = new List<String>();
        internalInvitees.add(UserInfo.getUserId());
        List<String> externalInvitees = new List<String>();
        externalInvitees.add(c1.Id);
		String activityType = 'Voicemail';
		String filters = createJSON();
        List<PicklistAttributes> ciStages = CallReportController.getCIStages();
        System.assert(ciStages.size() > 0);


        Event e = UtilityTesting.createEvent('Standard_Event', c.Id, 'Analyst Meeting');
        Event eventToUpdate = UtilityTesting.createEvent('Standard_Event', c.Id, 'Bespoke Work');
        Event e1 = UtilityTesting.createEvent('Standard_Event', c.Id, 'Analyst Meeting');
        Test.startTest();
        CallReportController.getl1EventTypes('false');
        Map<String, String> eResultMap = CallReportController.saveNewEvent(e,internalInvitees, externalInvitees, 'Some Details Here', UserInfo.getUserId(), null,  false, activityType, false, '', filters);
        Map<String, String> e1ResultMap = CallReportController.saveNewEvent(e1,internalInvitees, externalInvitees, 'Some Details Here', UserInfo.getUserId(), null, true, activityType, true, String.valueOf(campaignObj.Id), filters);
        Task_LTA__c detailedDescription = CallReportController.initialiseDetailedDescription(eResultMap.get('Event ID'));
        eventToUpdate.Id = eResultMap.get('Event ID');
        Map<String, String> eventToUpdateResultMap = CallReportController.updateEvent(eventToUpdate,internalInvitees, externalInvitees, 'Some Details Here', UserInfo.getUserId(),  null , true, false, '', filters);
		Event reinitialisedEvent = CallReportController.initialiseNewCallReport(eventToUpdate.Id, false, false);
         
    	System.debug('---e.Id----' + eResultMap.get('Event ID'));
        List<SObject> loadInternalInviteesList = CallReportController.loadInternalInvitees(eResultMap.get('Event ID'));
        System.debug('---loadInternalInviteesList----' + loadInternalInviteesList);
        
        List<Contact> loadClientAttendeesList =  CallReportController.loadClientAttendees(eResultMap.get('Event ID'));
        System.debug('---rg1.Id-' + rg1.Id);
        
        List<Account>  getAccountAddressesList = CallReportController.getAccountAddresses(rg1.Id);
            
        Test.stopTest();
    } 
    
    private testMethod static void saveNewEventTest1(){

        Account sLevel = UtilityTesting.createRSAccount(
                'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        insert sLevel;
            
        Account rg1 = UtilityTesting.createRGAccount(
                'G Test Account', sLevel.Id, 'Test2', '52nd Street', 'California', 'United States', true);
        insert rg1;
            
        Account rg1rm1 = UtilityTesting.createRMAccount(
                'RM Test Account 1', rg1.Id, 'Test3', '52nd Street', 'California', 'United States', true);
        insert rg1rm1;

        Account rg1rm2 = UtilityTesting.createRMAccount(
                'RM Test Account 2', rg1.Id, 'Test4', '52nd Street', 'California', 'United States', true);
        insert rg1rm2;
            
        List<Contact> contacts = new List<Contact>();

        Contact c = UtilityTesting.createContact('John', 'Smith', 'johnnysmith@test.com', '(212) 333-4567', 'Dear [FirstName]', rg1rm1.Id, true);
        contacts.add(c);

        Contact c1 = UtilityTesting.createContact('James', 'Smith', 'jamessmith@test.com', '(212) 333-4567', 'Dear [FirstName]', rg1rm2.Id, true);
        contacts.add(c1); 
      
        insert contacts;
	
        Id phoneBookRecordTypeId = Schema.getGlobalDescribe().get('Campaign').getDescribe().getRecordTypeInfosByName().get('Phone Book').getRecordTypeId(); 
        //Insert Campaign of Type Phone Book
       Campaign phoneBookCampaignObj = new Campaign();
       phoneBookCampaignObj.Name = 'Test Contact List' ;
       phoneBookCampaignObj.RecordTypeId = phoneBookRecordTypeId;
       
       insert phoneBookCampaignObj;
        
       campaign campaignObj = null; 
       List<Campaign> campaignList = [SELECT Id, Name FROM Campaign WHERE Name = 'Test Contact List'] ;
      
        if(campaignList != null && campaignList.size() > 0){
      	  campaignObj =  campaignList.get(0);
        }
        
        List<String> internalInvitees = new List<String>();
        internalInvitees.add(UserInfo.getUserId());
        List<String> externalInvitees = new List<String>();
        externalInvitees.add(c1.Id);
        String activityType = 'Voicemail';
        String filters = createJSON();
        List<PicklistAttributes> ciStages = CallReportController.getCIStages();
        System.assert(ciStages.size() > 0);


        Event e = UtilityTesting.createEvent('Standard_Event', c.Id, 'Analyst Meeting');
        Event eventToUpdate = UtilityTesting.createEvent('Standard_Event', c.Id, 'Bespoke Work');
        Event e1 = UtilityTesting.createEvent('Standard_Event', c.Id, 'Analyst Meeting');
        Test.startTest();
        CallReportController.getl1EventTypes('false');
        Map<String, String> eResultMap = CallReportController.saveNewEventBulk(e,internalInvitees, externalInvitees, 'Some Details Here', UserInfo.getUserId(), 'By Contact');
        Map<String, String> e1ResultMap = CallReportController.saveNewEventBulk(e1,internalInvitees, externalInvitees, 'Some Details Here', UserInfo.getUserId(), 'By Account');
           
        Test.stopTest();
    } 
    public static String createJSON(){
       	List<Account> accountList = [SELECT Id, Name, RDM_Org_Id__c FROM Account WHERE NAME = 'G Test Account' LIMIT 1];
        String accountRDM = accountList[0].RDM_Org_Id__c;
        
        String query = 'SELECT Id, Name, RG_Account__c FROM Contact WHERE Account.Parent.RDM_Org_Id__c = \'' + accountRDM +'\' LIMIT 1';
        List<Contact> contacts = (List<Contact>)Database.query(query); 
        System.debug('--contacts--' + contacts);
        String jsonString = '{"rgAccount":"' + contacts[0].RG_Account__c + '", "contactId": "' + contacts[0].Id + '"}';
        
        return jsonString;		
    }

    private testMethod static void getActivityFlagStatusValuesTest(){
        Map<String,List<String>> actyFlagStatusMap = new Map<String,List<String>>();
        
        actyFlagStatusMap = CallReportController.getActivityFlagStatusValues();

        System.assertNotEquals(actyFlagStatusMap, null);
    }
    
}