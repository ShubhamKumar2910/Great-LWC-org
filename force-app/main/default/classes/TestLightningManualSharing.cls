@isTest
private class TestLightningManualSharing {

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
       
       //Insert Champion
       Sales_Champion__c salesChampionObj = new Sales_Champion__c();
       salesChampionObj.Account__c = accountRG.Id;
       salesChampionObj.Sales_Champion__c = UserInfo.getUserId();
       salesChampionObj.Champion_Type__c = 'Client Champion';
       salesChampionObj.Region__c = 'Americas';
       
       insert salesChampionObj;
       
        
  }  
    
  static testMethod void testSOSL() {
  	LightningManualSharing.doSOSL('Test Contact List', 'Campaign');
    String userName = userInfo.getName();
    LightningManualSharing.doSOSL(userName, 'Sales_Champion__c');
  }

  static testMethod void testReturning() {

    string uq = LightningManualSharing.getReturning('User');
    system.assertEquals(uq, 'User(Id, Name, UserType WHERE UserType in (\'Standard\', \'PowerCustomerSuccess\', \'PowerPartner\'))');

    uq = LightningManualSharing.getReturning('Group');
    system.assertEquals(uq, 'Group(Id, Name, Type)');

    uq = LightningManualSharing.getReturning('Campaign');
    system.assertEquals(uq, 'Campaign(Id, Name)');

  }

  
  static testMethod void testInnerClass(){
  	LightningManualSharing.sharingHolder sh = new LightningManualSharing.sharingHolder();
  	sh.UserOrGroupName = 'test';
  	sh.SubType = 'test';
  	sh.UserOrGroupType = 'test';
  	sh.UserOrGroupID = 'test';
  	sh.AccessLevel = 'test';
  	sh.RowCause = 'test';

    system.assertEquals(sh.UserOrGroupName, 'test');
    system.assertEquals(sh.SubType, 'test');
    system.assertEquals(sh.UserOrGroupType, 'test');
    system.assertEquals(sh.UserOrGroupID, 'test');
    system.assertEquals(sh.AccessLevel, 'test');
    system.assertEquals(sh.RowCause, 'test');
  }

  static testMethod void testGetSharings() {
  	List<Campaign> campaignList = [SELECT Id FROM Campaign];
  	LightningManualSharing.getSharings(campaignList[0].Id);
  }

  static testMethod void testcanIEditPermsAdmin() {
  	List<Campaign> campaignList = [SELECT Id FROM Campaign];
  	LightningManualSharing.canIEditPerms(campaignList[0].Id);
  }


  static testMethod void testUpsertAndDeletePerm() {
  	  List<Campaign> campaignList = [select Id from Campaign];
      
  	
  	  //Insert User
      Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
      
      User userObj = new User();
      userObj.Login_ID__c = 'testtmp';
      userObj.Alias = 'testtmp';
      userObj.LastName = 'TestTemp_LN';
      userObj.FirstName = 'TestTemp_FN';
      userObj.Email = 'TestTemp@testOrg.com';
      userObj.UserName = 'TestTemp@testOrg.com';
      userObj.ProfileId = profileNomuraSales.Id;
      userObj.EmailEncodingKey = 'UTF-8';
      userObj.LanguageLocaleKey = 'en_US';
      userObj.LocaleSidKey = 'en_US';
      userObj.TimeZoneSidKey = 'America/Los_Angeles';
      userObj.Region__c = 'Americas';
      
      insert userObj;

      User currentUser = [ select Id from User where Id = :UserInfo.getUserId() ]; 
         
      System.runAs(currentUser){
          try {
                LightningManualSharing.upsertPerm(userObj.Id, campaignList[0].Id, 'Edit');
              	LightningManualSharing.upsertPerm(userObj.Id, campaignList[0].Id, 'Read');
                LightningManualSharing.deletePerm(userObj.Id, campaignList[0].Id);
          } catch (exception e){
                system.debug(e);
          }
      }  
      
  }

  static testMethod void testStringStuff(){
  	LightningManualSharing.getLookupField('Account');
  	LightningManualSharing.getAccessLevelField('Account');
  	LightningManualSharing.getSharingTableName('Account');

  }


  static testMethod void testBuildQuery(){
  	List<Campaign> campaignList = [select Id from Campaign];
  	LightningManualSharing.buildQuery(campaignList[0].id);
  }

  
  
}