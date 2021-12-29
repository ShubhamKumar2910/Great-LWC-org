@isTest
public class ContactListTest {
    
   @testSetUp
   public static void testSetupForContactList(){ 
   	   Id recordTypeIdForRG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();   
       Id recordTypeIdForRM = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();   
       Id phoneBookRecordTypeId = Schema.getGlobalDescribe().get('Campaign').getDescribe().getRecordTypeInfosByName().get('Phone Book').getRecordTypeId(); 
       Id coverageRecordTypeId = Schema.getGlobalDescribe().get('Campaign').getDescribe().getRecordTypeInfosByName().get('Coverage').getRecordTypeId();   
       Id standardEventRecordTypeId = Schema.getGlobalDescribe().get('Event').getDescribe().getRecordTypeInfosByName().get('Standard Event').getRecordTypeId();
       
       //Insert Accounts
       List<Account> accountList = new List<Account>();
       Account accountRG  = new Account(); 
       accountRG.Name = 'RG_Account_Dummy';
       accountRG.RDM_Org_ID__c = 'RGXXXXXX';            
       accountRG.RecordTypeId = recordTypeIdForRG;
       accountRG.Active__c = TRUE;  
       accountRG.EQ_Research_Americas_Tier__c = 'Gold';
       accountRG.EQ_Research_AsiaEx_Tier__c = 'Gold';
       accountRG.EQ_Research_Japan_Tier__c = 'Gold';
       accountRG.EQ_Research_Europe_Tier__c = 'Gold';
       accountRG.EQ_Research_Global_Tier__c = 'Gold';
       
       insert accountRG;
       
       Account accountRM  = new Account();  
       accountRM.Name = 'RM_Account_Dummy';
       accountRM.RDM_Org_ID__c = 'RMXXXXXX';            
       accountRM.RecordTypeId = recordTypeIdForRM;
       accountRM.BillingStreet = '52nd Street' ;
       accountRM.BillingCity = 'Los Angeles';
       accountRM.BillingPostalCode = '90001';
       accountRM.BillingCountry = 'United States';
       accountRM.Active__c = TRUE; 
       accountRM.ParentId = accountRG.Id;
       
       insert accountRM;
       
       /* Insert Contacts */
       List<Contact> contactList = new List<Contact>();
       
       Contact contactObj1 = new Contact();
       contactObj1.AccountId = accountRM.Id;
       contactObj1.FirstName = 'TestDummyFN_1'; 
       contactObj1.LastName = 'TestDummyLN_1';    
       contactObj1.Active__c = TRUE;
       contactObj1.Email = 'TestDummy1@testOrg.com';
       contactObj1.Phone = '+0000000000'; 
       contactObj1.Salutation = 'M.';    
       contactObj1.Mailing_Address_Same_As_Account_Address__c = TRUE;
       contactObj1.RG_Account__c = accountRG.Id;
       
       contactList.add(contactObj1);
       
       Contact contactObj2 = new Contact();
       contactObj2.AccountId = accountRM.Id;
       contactObj2.FirstName = 'TestDummyFN_2'; 
       contactObj2.LastName = 'TestDummyLN_2';    
       contactObj2.Active__c = TRUE;
       contactObj2.Email = 'TestDummy2@testOrg.com';
       contactObj2.Phone = '+0000000000'; 
       contactObj2.Salutation = 'M.';    
       contactObj2.Mailing_Address_Same_As_Account_Address__c = TRUE;
       contactObj2.RG_Account__c = accountRG.Id;
       
       
       contactList.add(contactObj2);
       
       insert contactList;
       
        /* Insert Event */
        Datetime startDateTime = Datetime.now();
        Datetime endDateTime = startDateTime.addHours(1);
        Datetime endDateTimeForDialer = startDateTime.addMinutes(1);
        
        Event eventObj = new Event();
        eventObj.WhatId = accountRG.Id;
        eventObj.WhoId = contactObj1.Id;
        eventObj.Subject = 'Test Event';
       	eventObj.Type = 'Meeting';
        eventObj.StartDateTime = startDateTime;
        eventObj.EndDateTime = endDateTime;
        eventObj.RecordTypeId = standardEventRecordTypeId;
        
        insert eventObj;
       
       	/* Insert Dialer Event */
        
        Event dialerEventObj = new Event();
        dialerEventObj.WhatId = accountRG.Id;
        dialerEventObj.WhoId = contactObj1.Id;
        dialerEventObj.Subject = 'Test Dialer Event';
       	dialerEventObj.Type = 'Dialer';
        dialerEventObj.StartDateTime = startDateTime;
        dialerEventObj.EndDateTime = endDateTimeForDialer;
        dialerEventObj.RecordTypeId = standardEventRecordTypeId;
        
        insert dialerEventObj;
       
       //Insert Campaign of Type Phone Book
       Campaign phoneBookCampaignObj = new Campaign();
       phoneBookCampaignObj.Name = 'Test Contact List' ;
       phoneBookCampaignObj.RecordTypeId = phoneBookRecordTypeId;
       
       insert phoneBookCampaignObj;
       
       //Insert CampaignMembers
       List<CampaignMember> campaignMemberList = new List<CampaignMember>();
       
       if(contactList != null && contactList.size() > 0){
           for(Contact contactObj : contactList){
               CampaignMember campaignMemberForPhoneBookObj = new CampaignMember(CampaignId = phoneBookCampaignObj.Id, ContactId = contactObj.Id);
               
               
               campaignMemberList.add(campaignMemberForPhoneBookObj);
           }
           
           if(campaignMemberList.size() > 0){
               insert campaignMemberList;
           }
       }
       
       
       //Insert Contact_List_Settings__c
       Contact_List_Settings__c userSetting = Contact_List_Settings__c.getInstance(UserInfo.getUserId());
       if(userSetting != null){
           userSetting.Default_Contact_List_Id__c = '1';
           upsert userSetting;
       }
        
   }
    
   @isTest 
   public static void getCampaignMembersTest() {
	  Test.startTest();
     
      campaign campaignObj = null; 
      //Fetch Campaign
      List<Campaign> campaignList = [SELECT Id, Name FROM Campaign WHERE Name = 'Test Contact List'] ;
      
      if(campaignList != null && campaignList.size() > 0){
      	  campaignObj =  campaignList.get(0);
          
          //Test
          ContactList contactListController = new ContactList();
          Integer pageNumber = 1;
          Integer pageSize = 50;
          String sortField = 'Id' ;
          String sortDirection = 'ASC' ; 
          String campaignId =  String.valueOf(campaignObj.Id);
          Integer renderedRows = 60; 
          String filters = createJSON();
          
          List<ContactList.ContactDetails> contactDetailsList = ContactList.getCampaignMembers(campaignId, pageNumber, pageSize, sortField, sortDirection, renderedRows, filters);
          System.assert(contactDetailsList != null && contactDetailsList.size() > 0);
      }
     
      
       
      Test.stopTest();  
	}

	@isTest 
   	public static void getCampaignMembersMobileTest() {
	  Test.startTest();
     
      campaign campaignObj = null; 
      //Fetch Campaign
      List<Campaign> campaignList = [SELECT Id, Name FROM Campaign WHERE Name = 'Test Contact List'] ;
      
      if(campaignList != null && campaignList.size() > 0){
      	  campaignObj =  campaignList.get(0);
          
          //Test
          ContactList contactListController = new ContactList();
          Integer pageNumber = 1;
          Integer pageSize = 50;
          String sortField = 'Id' ;
          String sortDirection = 'ASC' ; 
          String campaignId =  String.valueOf(campaignObj.Id);
          Integer renderedRows = 60; 
          String filters = createJSON();
          
          List<ContactList.ContactDetails> contactDetailsList = ContactList.getCampaignMemberForMobile(campaignId, pageNumber, pageSize, renderedRows, filters);
          System.assert(contactDetailsList != null && contactDetailsList.size() > 0);
      }
     
      
       
      Test.stopTest();  
	}
    
   @isTest 
   public static void getRecentlyViewedContactsTest() {
	  Test.startTest();
       
      //Test
      ContactList contactListController = new ContactList();
       
      List<ContactList.ContactDetails> contactDetailsList = ContactList.getRecentlyViewedContacts('DESKTOP');
      //System.assert(contactDetailsList != null && contactDetailsList.size() > 0);
       List<ContactList.ContactDetails> contactDetailsListMobile = ContactList.getRecentlyViewedContacts('PHONE');
      Test.stopTest();  
	}
    
   @isTest 
   public static void getMyContactListsTest() {
	  Test.startTest();
       
      //Test
      ContactList contactListController = new ContactList();
       
      List<CampaignShare> campaignShareList = ContactList.getMyContactLists('DESKTOP');
      System.assert(campaignShareList != null && campaignShareList.size() > 0);
       
      List<CampaignShare> campaignShareListMobile = ContactList.getMyContactLists('PHONE');
      System.assert(campaignShareListMobile != null && campaignShareListMobile.size() > 0);
      Test.stopTest();  
   }
    
   @isTest 
   public static void getCampaignMemberCountTest() {
	  Test.startTest();
     
      campaign campaignObj = null; 
      //Fetch Campaign
      List<Campaign> campaignList = [SELECT Id, Name FROM Campaign WHERE Name = 'Test Contact List'] ;
      
      if(campaignList != null && campaignList.size() > 0){
      	  campaignObj =  campaignList.get(0);
          
          //Test
          ContactList contactListController = new ContactList();
          String campaignId =  String.valueOf(campaignObj.Id);
          String filters = createJSON();
          
          Integer campaignMemberCount = ContactList.getCampaignMemberCount(campaignId, filters, 'DESKTOP');
          System.assert(campaignMemberCount > 0);
          
          Integer campaignMemberCountForRecentlyViewed = ContactList.getCampaignMemberCount('1', filters, 'PHONE');
          
          //Test for Non Covered Contacts Filter
          String contactListFilterJSONStr = JSON.serialize(new ContactListFilter(null, null, null, true, campaignId));
          Integer countForNonCoveredContact = ContactList.getCampaignMemberCount(campaignId, contactListFilterJSONStr, 'DESKTOP');
          System.assert(countForNonCoveredContact == 0);
          
          
      }
     
      Test.stopTest();  
	}
    
   @isTest 
   public static void getCampaignAccessLevelTest() {
	  Test.startTest();
     
      campaign campaignObj = null; 
      //Fetch Campaign
      List<Campaign> campaignList = [SELECT Id, Name FROM Campaign WHERE Name = 'Test Contact List'] ;
      
      if(campaignList != null && campaignList.size() > 0){
      	  campaignObj =  campaignList.get(0);
          
          //Test
          ContactList contactListController = new ContactList();
          String campaignId =  String.valueOf(campaignObj.Id);
           
          String campaignAccessLevel = ContactList.getCampaignAccessLevel(campaignId);
          System.assert('All'.equalsIgnoreCase(campaignAccessLevel));
      }
     
      Test.stopTest();  
	}
    
    @isTest 
    public static void getCampaignsTest() {
	  Test.startTest();
     
       campaign campaignObj = null; 
       String activityType  = 'Voicemail';
      //Fetch Campaign
      List<Campaign> campaignList = [SELECT Id, Name FROM Campaign WHERE Name = 'Test Contact List'] ;
      
      if(campaignList != null && campaignList.size() > 0){
      	  campaignObj =  campaignList.get(0);
          
          //Test
          ContactList contactListController = new ContactList();
          String campaignId =  String.valueOf(campaignObj.Id);
           
          //For PhoneBook
          List<Campaign> phoneBookCampaignList = ContactList.getCampaigns('Phone_Book', campaignId);
          System.assert(phoneBookCampaignList != null && phoneBookCampaignList.size() == 0);
          
          //For Coverage
          List<Campaign> coverageCampaignList = ContactList.getCampaigns('Coverage', campaignId);
          System.assert(coverageCampaignList != null && coverageCampaignList.size() == 0);
          
          //For Mass Email
          List<Campaign> massEmailCampaignList = ContactList.getCampaigns('Mass_Email', null);
          System.assert(massEmailCampaignList != null && massEmailCampaignList.size() == 0);
          
          //Mass Activity Details
          List<Event> massActivityEventList = ContactList.getMassActivityDetails(activityType);
          System.assert(massActivityEventList != null && massActivityEventList.size() == 0);
      }
     
      Test.stopTest();  
	}
    
   @isTest 
   public static void getContactListOtherDetailsTest() {
	  Test.startTest();
     
      ContactList contactListController = new ContactList();
      ContactList.ContactListOtherDetails otherDetails = ContactList.getContactListOtherDetails('DESKTOP');
       
      //Fetch Record Type Details
      Id phoneBookRecordTypeId = CommonTools.getRecordTypeId('Campaign','Phone Book');
      Id coverageRecordTypeId = CommonTools.getRecordTypeId('Campaign','Coverage');
      Id massEmailRecordTypeId = CommonTools.getRecordTypeId('Campaign','Mass Email');
      Id massActivityRecordTypeId = CommonTools.getRecordTypeId('Campaign','Mass Activity');
       
      //Fetch User Details
      User userObj = [SELECT Id, Login_Id__c, Is_Contact_Coverage_Present__c FROM User
                       WHERE Id = :UserInfo.getUserId()];
       
      if(otherDetails != null && userObj != null){
      	System.assertEquals(userObj.Is_Contact_Coverage_Present__c, otherDetails.contactCoverageRecordExists);   
        System.assertEquals(phoneBookRecordTypeId, otherDetails.phoneBookRecordTypeId);  
        System.assertEquals(coverageRecordTypeId, otherDetails.coverageRecordTypeId);  
        System.assertEquals(massEmailRecordTypeId, otherDetails.massEmailRecordTypeId);  
        System.assertEquals(massActivityRecordTypeId, otherDetails.massActivityRecordTypeId);    
      } 
     
      Test.stopTest();  
	}
    
    @isTest 
    public static void setDefaultListTest() {
	  Test.startTest();
        
      ContactList contactListController = new ContactList();  
     
      Id phoneBookRecordId = Schema.getGlobalDescribe().get('Campaign').getDescribe().getRecordTypeInfosByName().get('Phone Book').getRecordTypeId(); 
      String filters = createJSON();  
      campaign campaignObj = null; 
      
        //Fetch Campaign
      List<Campaign> campaignList = [SELECT Id, Name FROM Campaign WHERE Name = 'Test Contact List'] ;
        
      if(campaignList != null && campaignList.size() > 0){
      	  campaignObj =  campaignList.get(0);
          
          ContactList.setDefaultList(campaignObj.Id);
          
          //Fetch Contact List Default Settings
          String deafultContactListId = ContactList.getDefaultListId();
          
          System.assertEquals(campaignObj.Id, deafultContactListId);
      }
     
      Test.stopTest();  
	}

	@isTest 
    public static void addCampaignMembersTest() {
	  Test.startTest();
        
      ContactList contactListController = new ContactList();  
     
      Id phoneBookRecordId = Schema.getGlobalDescribe().get('Campaign').getDescribe().getRecordTypeInfosByName().get('Phone Book').getRecordTypeId(); 
      String filters = createJSON();  
      campaign campaignObj = null; 
      //Fetch Campaign
      List<Campaign> campaignList = [SELECT Id, Name FROM Campaign WHERE Name = 'Test Contact List'] ;
        
      if(campaignList != null && campaignList.size() > 0){
      	  campaignObj =  campaignList.get(0);
          
          //Fetch Campaign Member Count
          Integer campaignMemberCount = ContactList.getCampaignMemberCount(campaignObj.Id, filters, 'DESKTOP');
          
          //Insert Campaign of Type Phone Book
          Campaign newCampaignObj = new Campaign();
          newCampaignObj.Name = 'Test Contact List' ;
          newCampaignObj.RecordTypeId = phoneBookRecordId;
          
          insert newCampaignObj;
          
          List<String> targetCampaignList = new List<String>();
          targetCampaignList.add(newCampaignObj.Id);
          List<Id> failedCampaignMemberIdList = ContactList.addCampaignMembers(TRUE, 
                                                                               String.valueOf(campaignObj.Id), 
                                                                               targetCampaignList, 
                                                                               null,
                                                                              filters);
          
          System.assert(failedCampaignMemberIdList != null && failedCampaignMemberIdList.size() == 0);
         
          //Fetch Campaign Member Count for new Campaign
          Integer newCampaignMemberCount = ContactList.getCampaignMemberCount(newCampaignObj.Id, filters, 'DESKTOP');
          
          //Test Count
          System.assertEquals(campaignMemberCount, newCampaignMemberCount);
          
      }
     
      Test.stopTest();  
	}
    
    @isTest 
    public static void removeCampaignMembersTest() {
	  Test.startTest();
        
      ContactList contactListController = new ContactList();  
     
      Id phoneBookRecordId = Schema.getGlobalDescribe().get('Campaign').getDescribe().getRecordTypeInfosByName().get('Phone Book').getRecordTypeId(); 
      String filters = createJSON();
      campaign campaignObj = null; 
      //Fetch Campaign
      List<Campaign> campaignList = [SELECT Id, Name FROM Campaign WHERE Name = 'Test Contact List'] ;
        
      if(campaignList != null && campaignList.size() > 0){
      	  campaignObj =  campaignList.get(0);
          
          //Fetch Campaign Member Count
          Integer campaignMemberCount = ContactList.getCampaignMemberCount(campaignObj.Id, filters, 'DESKTOP');
          
          //Insert Campaign of Type Phone Book
          Campaign newCampaignObj = new Campaign();
          newCampaignObj.Name = 'Test Contact List' ;
          newCampaignObj.RecordTypeId = phoneBookRecordId;
          
          insert newCampaignObj;
          
          //Insert Campaign Members
          List<String> targetCampaignList = new List<String>();
          targetCampaignList.add(newCampaignObj.Id);
          List<Id> failedCampaignMemberIdList = ContactList.addCampaignMembers(TRUE, 
                                                                               String.valueOf(campaignObj.Id), 
                                                                               targetCampaignList, 
                                                                               null,
                                                                              filters);
          
          //Remove Campaign Members
          List<Id> failedCampaignMemberIdForRemoveList = ContactList.removeCampaignMembers(TRUE, 
                                                                               String.valueOf(newCampaignObj.Id), 
                                                                               null,
                                                                               filters);
          
          //Fetch Campaign Member Count for new Campaign after removing campaign Members
          Integer newCampaignMemberCount = ContactList.getCampaignMemberCount(newCampaignObj.Id, filters, 'DESKTOP');
          
          //Test Count
          System.assertEquals(0, newCampaignMemberCount);
          
      }
     
      Test.stopTest();  
	}
    
     @isTest 
    public static void deleteCampaignTest() {
	  Test.startTest();
        
      ContactList contactListController = new ContactList();  
      campaign campaignObj = null; 
      
      //Fetch Campaign
      List<Campaign> campaignList = [SELECT Id, Name FROM Campaign WHERE Name = 'Test Contact List'] ;
        
      if(campaignList != null && campaignList.size() > 0){
      	  campaignObj =  campaignList.get(0);
          
          ContactList.deleteCampaign(campaignObj.Id);
          
          //Fetch Campaign after deletion
          List<Campaign> campaignListAfterDelete = [SELECT Id, Name FROM Campaign WHERE Name = 'Test Contact List'] ;
         
          System.assert(campaignListAfterDelete == null || (campaignListAfterDelete != null && campaignListAfterDelete.size() == 0));
          
      }
     
      Test.stopTest();  
	}
    
     @isTest 
   	 public static void getCampaignMembersForCampaignIdTest() {
	  Test.startTest();
     
      campaign campaignObj = null;
      String filters = createJSON();
      //Fetch Campaign
      List<Campaign> campaignList = [SELECT Id, Name FROM Campaign WHERE Name = 'Test Contact List'] ;
      
      if(campaignList != null && campaignList.size() > 0){
      	  campaignObj =  campaignList.get(0);
          
          //Test
          ContactList contactListController = new ContactList();
          String campaignId =  String.valueOf(campaignObj.Id);
           
          List<Id> campaignMemberIdList = ContactList.getCampaignMembersForCampaignId(campaignId, filters);
          System.assertEquals(2, campaignMemberIdList.size());
      }
     
      Test.stopTest();  
	}
    
    public static String createJSON(){
       	List<Account> accountList = [SELECT Id, Name FROM Account WHERE RDM_Org_Id__c = 'RGXXXXXX' LIMIT 1];
        String account = accountList[0].Id;
        String jsonString = '';
        
        String query = 'SELECT Id, Name, RG_Account__c FROM Contact WHERE RG_Account__c = \'' + account +'\' LIMIT 1';
        List<Contact> contacts = (List<Contact>)Database.query(query); 
        
        if(contacts != null && contacts.size() > 0){
        	jsonString = JSON.serialize(new ContactListFilter(contacts[0].RG_Account__c, null, null, false, null));
        }    
        
        return jsonString;
		
    }
    
}