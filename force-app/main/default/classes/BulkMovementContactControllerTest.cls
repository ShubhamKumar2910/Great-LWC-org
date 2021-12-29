@isTest
public class BulkMovementContactControllerTest {
   
   public static final String BULK_MOVEMENT_CONTACT_NAME_PATTERN = 'BulkMovementContact';
   public static final String CAMPAIGN_RT_NAME_BULK_MOVEMENT_CONTACT = 'Bulk_Movement_Contact';

   @testSetUp
   public static void testSetupForBulkMovementContact(){ 
   	   Id recordTypeIdForRG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();   
       Id recordTypeIdForRM = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();   
       Id coverageRecordTypeId = Schema.getGlobalDescribe().get('Campaign').getDescribe().getRecordTypeInfosByName().get('Bulk Movement Contact').getRecordTypeId();   
       
       //Insert RG Accounts
       List<Account> accountRGList = new List<Account>();
       List<Account> accountRMList = new List<Account>();
       
       //Old RG Account
       Account oldAccountRG  = new Account(); 
       oldAccountRG.Name = 'RG_Account_Dummy_Old';
       oldAccountRG.RDM_Org_ID__c = 'RG111111';            
       oldAccountRG.RecordTypeId = recordTypeIdForRG;
       oldAccountRG.Active__c = TRUE; 
       accountRGList.add(oldAccountRG);

       //New RG Account
       Account newAccountRG  = new Account(); 
       newAccountRG.Name = 'RG_Account_Dummy_New';
       newAccountRG.RDM_Org_ID__c = 'RG222222';            
       newAccountRG.RecordTypeId = recordTypeIdForRG;
       newAccountRG.Active__c = TRUE;   
       accountRGList.add(newAccountRG);

       insert accountRGList;

       //Insert RM Accounts
       Account oldAccountRM  = new Account();  
       oldAccountRM.Name = 'RM_Account_Dummy_Old';
       oldAccountRM.RDM_Org_ID__c = 'RM333333';            
       oldAccountRM.RecordTypeId = recordTypeIdForRM;
       oldAccountRM.BillingStreet = '52nd Street' ;
       oldAccountRM.BillingCity = 'Los Angeles';
       oldAccountRM.BillingPostalCode = '90001';
       oldAccountRM.BillingCountry = 'United States';
       oldAccountRM.Active__c = TRUE; 
       oldAccountRM.ParentId = oldAccountRG.Id;
       accountRMList.add(oldAccountRM);

       Account newAccountRM  = new Account();  
       newAccountRM.Name = 'RM_Account_Dummy_New';
       newAccountRM.RDM_Org_ID__c = 'RM444444';            
       newAccountRM.RecordTypeId = recordTypeIdForRM;
       newAccountRM.BillingStreet = 'Cynergy IT Park, 2nd floor,Prabhadevi, Mumbai 400025' ;
       newAccountRM.BillingCity = 'Mumbai';
       newAccountRM.BillingPostalCode = '400025';
       newAccountRM.BillingCountry = 'India';
       newAccountRM.Active__c = TRUE; 
       newAccountRM.ParentId = newAccountRG.Id;
       accountRMList.add(newAccountRM);
       
       insert accountRMList;
       
       /* Insert Contacts */
       List<Contact> contactList = new List<Contact>();
       
       Contact contactObj1 = new Contact();
       contactObj1.AccountId = oldAccountRM.Id;
       contactObj1.FirstName = 'TestDummyFN_1'; 
       contactObj1.LastName = 'TestDummyLN_1';    
       contactObj1.Active__c = TRUE;
       contactObj1.Email = 'TestDummy1@testOrg.com';
       contactObj1.Phone = '+0000000000'; 
       contactObj1.Salutation = 'M.';    
       contactObj1.Mailing_Address_Same_As_Account_Address__c = TRUE;
       contactObj1.RG_Account__c = oldAccountRG.Id;
       
       contactList.add(contactObj1);
       
       Contact contactObj2 = new Contact();
       contactObj2.AccountId = oldAccountRM.Id;
       contactObj2.FirstName = 'TestDummyFN_2'; 
       contactObj2.LastName = 'TestDummyLN_2';    
       contactObj2.Active__c = TRUE;
       contactObj2.Email = 'TestDummy2@testOrg.com';
       contactObj2.Phone = '+0000000000'; 
       contactObj2.Salutation = 'M.';    
       contactObj2.Mailing_Address_Same_As_Account_Address__c = TRUE;
       contactObj2.RG_Account__c = oldAccountRG.Id;
       
       
       contactList.add(contactObj2);
       
       insert contactList;

       //Get Campaign of Type Bulk Movement Contact
       String campaignId = CampaignService.getBulkUploadCampaignRec(null, CAMPAIGN_RT_NAME_BULK_MOVEMENT_CONTACT, BULK_MOVEMENT_CONTACT_NAME_PATTERN);

       Campaign campaignObj = new Campaign(Id = campaignId, Status = 'Submitted');
       update campaignObj;
       
   }

   @isTest 
   public static void getAvailableOptionsListTest() {
	  Test.startTest();

      //Test
      BulkMovementContactController bulkMovementContactCtrl = new BulkMovementContactController();
      List<BulkMovementContactController.ListOption> optionList = BulkMovementContactController.getAvailableOptionsList();

      System.assert(optionList != null && optionList.size() > 0);

      Test.stopTest();
   } 

   @isTest 
   public static void getTransferReasonListTest() {
	  Test.startTest();

      //Test
      BulkMovementContactController bulkMovementContactCtrl = new BulkMovementContactController();
      List<BulkMovementContactController.ListOption> transferReasonList = BulkMovementContactController.getTransferReasonList();

      System.assert(transferReasonList != null && transferReasonList.size() > 0);

      Test.stopTest();
   } 

   @isTest 
   public static void getRMAccountsTest() {
	  Test.startTest();

      Account accountRGObj = null;
      
      //Fetch RG Account
      List<Account> accountList = [SELECT Id, Name, RDM_Org_ID__c FROM Account WHERE RDM_Org_ID__c = 'RG111111'];

      if(accountList != null && accountList.size() > 0){
          accountRGObj = accountList.get(0);
      }

      //Test
      BulkMovementContactController bulkMovementContactCtrl = new BulkMovementContactController();
      List<Account> accountRMList = BulkMovementContactController.getRMAccounts(accountRGObj.Id);

      System.assert(accountRMList != null && accountRMList.size() == 1);

      Test.stopTest();
   }

   @isTest 
   public static void getSourceContactDetailsTest() {
	  Test.startTest();

      Account accountRMObj = null;
      List<Id> contactList = new List<Id>();
      
      //Fetch RM Accounts
      List<Id> accountList = fetchSourceAccountList();

      //Fetch Contacts
      Map<Id, Contact> contactMap = new Map<Id,Contact>([SELECT Id, Name, Email FROM Contact WHERE Active__c = TRUE AND Account.RDM_Org_Id__c = 'RM333333']);
      contactList.addAll(contactMap.keySet());
      

      //Test
      BulkMovementContactController bulkMovementContactCtrl = new BulkMovementContactController();
      

      BulkMovementContactController.SourceContactData contactDataForRMLevel = BulkMovementContactController.getSourceContactDetails(accountList, null);
      BulkMovementContactController.SourceContactData contactDataForContactLevel = BulkMovementContactController.getSourceContactDetails(null, contactList);
      BulkMovementContactController.SourceContactData contactDataForBoth = BulkMovementContactController.getSourceContactDetails(accountList, contactList);

      System.assert(contactDataForRMLevel != null && contactDataForRMLevel.rows != null && contactDataForRMLevel.rows.size() == 2);
      System.assert(contactDataForContactLevel != null && contactDataForContactLevel.rows != null && contactDataForContactLevel.rows.size() == 2);
      System.assert(contactDataForBoth != null && contactDataForBoth.rows != null && contactDataForBoth.rows.size() == 2);
      
      Test.stopTest();
   }

   @isTest 
   public static void getBulkMovementContactJobDetailsTest() {
	  Test.startTest();

      List<BulkMovementContactController.BulkMovementContactJobInfo> bulkMovementContactJobInfoList = new List<BulkMovementContactController.BulkMovementContactJobInfo>();

      //Test
      BulkMovementContactController bulkMovementContactCtrl = new BulkMovementContactController();
      bulkMovementContactJobInfoList = BulkMovementContactController.getBulkMovementContactJobDetails();

      System.assert(bulkMovementContactJobInfoList != null && bulkMovementContactJobInfoList.size() == 1);

      Test.stopTest();
   }

   @isTest 
   public static void getCampaignDetailsTest() {
	  Test.startTest();

      //Test
      BulkMovementContactController bulkMovementContactCtrl = new BulkMovementContactController();
      String campaignId = BulkMovementContactController.getCampaignDetails();

      System.assert(campaignId != null);

      Test.stopTest();
   }

   @isTest 
   public static void getMovementAccountSpecificDetailsTest() {
	  Test.startTest();

      Id destinationRGAccountId = null;
      Id destinationRMAccountId = null;
      
      //Fetch Source RM Accounts
      List<Id> sourceAccountList = fetchSourceAccountList();

      //Fetch Destination Account Details
      List<Account> destinationAccountList = [SELECT Id, RDM_Org_Id__c FROM Account WHERE RDM_Org_Id__c IN ('RG222222','RM444444')];
      if(destinationAccountList != null && destinationAccountList.size() > 0){
          for(Account accountObj : destinationAccountList){
              if('RG222222'.equalsIgnoreCase(accountObj.RDM_Org_Id__c)){
                  destinationRGAccountId = accountObj.Id;
              }
              else if('RM444444'.equalsIgnoreCase(accountObj.RDM_Org_Id__c)){
                  destinationRMAccountId = accountObj.Id;
              }
          }
      }

      //Test
      BulkMovementContactController bulkMovementContactCtrl = new BulkMovementContactController();
      Map<String,Boolean> accountSpecificMap = BulkMovementContactController.getMovementAccountSpecificDetails(sourceAccountList, null, destinationRGAccountId, destinationRMAccountId);
      
      if(accountSpecificMap != null){
          System.assertEquals(false, accountSpecificMap.get('movementUnderSameRG'));
          System.assertEquals(false, accountSpecificMap.get('movementUnderSameRM'));
          //System.assertEquals(true, accountSpecificMap.get('accountRegionDifferent'));
          System.assertEquals(false, accountSpecificMap.get('isExceptionalAccount'));
      }

      Test.stopTest();
   }

   @isTest 
   public static void checkContactDataPresentTest() {
	  Test.startTest();

      List<CampaignMember> campaignMemberList = new List<CampaignMember>();

      //Get Campaign of Type Bulk Movement Contact
      String campaignId = CampaignService.getBulkUploadCampaignRec(null, CAMPAIGN_RT_NAME_BULK_MOVEMENT_CONTACT, BULK_MOVEMENT_CONTACT_NAME_PATTERN);

      //Fetch Contacts
      Map<Id, Contact> contactMap = new Map<Id,Contact>([SELECT Id, Name, Email FROM Contact WHERE Active__c = TRUE AND Account.RDM_Org_Id__c = 'RM333333']);
      for(Id contactId : contactMap.keySet()){
          CampaignMember campaignMemberObj = new CampaignMember(ContactId = contactId, CampaignId = campaignId);
          campaignMemberList.add(campaignMemberObj);
      } 

      insert campaignMemberList;

      //Test
      BulkMovementContactController bulkMovementContactCtrl = new BulkMovementContactController();
      Boolean contactDataPresent = BulkMovementContactController.checkContactDataPresent(campaignId);

      System.assert(contactDataPresent == true);

      Test.stopTest();
   }

   @isTest 
   public static void performCleanupTest() {
	  Test.startTest();

      List<CampaignMember> campaignMemberList = new List<CampaignMember>();

      //Get Campaign of Type Bulk Movement Contact
      String campaignId = CampaignService.getBulkUploadCampaignRec(null, CAMPAIGN_RT_NAME_BULK_MOVEMENT_CONTACT, BULK_MOVEMENT_CONTACT_NAME_PATTERN);

      //Fetch Contacts
      Map<Id, Contact> contactMap = new Map<Id,Contact>([SELECT Id, Name, Email FROM Contact WHERE Active__c = TRUE AND Account.RDM_Org_Id__c = 'RM333333']);
      for(Id contactId : contactMap.keySet()){
          CampaignMember campaignMemberObj = new CampaignMember(ContactId = contactId, CampaignId = campaignId);
          campaignMemberList.add(campaignMemberObj);
      } 

      insert campaignMemberList;

      //Test
      BulkMovementContactController bulkMovementContactCtrl = new BulkMovementContactController();
      BulkMovementContactController.performCleanup(campaignId);

      //Fetch Campaign Members after performing clean up
      List<CampaignMember> memberList = [SELECT Id FROM CampaignMember WHERE CampaignId = :campaignId];
      
      System.assert(memberList == null || (memberList != null && memberList.size() == 0));

      Test.stopTest();
   }

   @isTest 
   public static void performValidation() {
	  Test.startTest();

      //Get Campaign of Type Bulk Movement Contact
      String campaignId = CampaignService.getBulkUploadCampaignRec(null, CAMPAIGN_RT_NAME_BULK_MOVEMENT_CONTACT, BULK_MOVEMENT_CONTACT_NAME_PATTERN);

      //Get Contact JSON
      String contactDataJSONString = createContactDataJSON();

      //Test
      BulkMovementContactController bulkMovementContactCtrl = new BulkMovementContactController();
      List<BulkMovementContactController.ContactWrapper> contactWrapperList = BulkMovementContactController.performValidation(campaignId, contactDataJSONString);

      System.assert(contactWrapperList == null || (contactWrapperList != null && contactWrapperList.size() == 0));

      Test.stopTest();
   }

   @isTest 
   public static void saveBulkMovementContactDataTest() {
	  Test.startTest();

      String bulkMovementContactDataJSONStr = createBulkMovementContactDataJSON();

      //Test
      BulkMovementContactController bulkMovementContactCtrl = new BulkMovementContactController();
      BulkMovementContactController.saveBulkMovementContactData(bulkMovementContactDataJSONStr);

      Test.stopTest();

      //Check the Status of Campaign
      BulkMovementContactController.BulkMovementContactDataWrapper bulkMovementContactDataWrapperObj = BulkMovementContactController.parseBulkMovementContactDataJSONString(bulkMovementContactDataJSONStr);
      if(bulkMovementContactDataWrapperObj != null){
        List<Campaign> campaignList = [SELECT Id, Name, Status FROm Campaign WHERE Id =: bulkMovementContactDataWrapperObj.campaignId];
        if(campaignList != null && campaignList.size() > 0){
            Campaign campaignObj = campaignList.get(0);
            System.assertEquals('Submitted', campaignObj.Status);
        }
      }

     
   }

   public static String createContactDataJSON(){
      String contactDataJSONString = '';
      List<BulkMovementContactController.ContactWrapper> contactWrapperList = new List<BulkMovementContactController.ContactWrapper>();

      //Fetch Contacts
      List<Contact> contactList = [SELECT Id, Name, Email FROM Contact WHERE Active__c = TRUE AND Account.RDM_Org_Id__c = 'RM333333'];
      
      if(contactList != null && contactList.size() > 0){
          for(Contact contactObj : contactList){
              contactWrapperList.add(new BulkMovementContactController.ContactWrapper(contactObj.Id, contactObj.Name, contactObj.Email, null));
          }
      }

      if(contactWrapperList != null && contactWrapperList.size() > 0){
          contactDataJSONString = JSON.serialize(contactWrapperList);
      }

      return contactDataJSONString;
   }

    public static String createBulkMovementContactDataJSON(){
        String bulkMovementContactDataJSONString = '';
        Id destinationRGAccountId = null;
        Id destinationRMAccountId = null;
        
        
        //Fetch Source RM Accounts
        List<Id> sourceAccountList = fetchSourceAccountList();

        //Fetch Destination Account Details
        List<Account> destinationAccountList = [SELECT Id, RDM_Org_Id__c FROM Account WHERE RDM_Org_Id__c IN ('RG222222','RM444444')];
        if(destinationAccountList != null && destinationAccountList.size() > 0){
            for(Account accountObj : destinationAccountList){
                if('RG222222'.equalsIgnoreCase(accountObj.RDM_Org_Id__c)){
                    destinationRGAccountId = accountObj.Id;
                }
                else if('RM444444'.equalsIgnoreCase(accountObj.RDM_Org_Id__c)){
                    destinationRMAccountId = accountObj.Id;
                }
            }
        }

        //Get Campaign of Type Bulk Movement Contact
        String campaignId = CampaignService.getBulkUploadCampaignRec(null, CAMPAIGN_RT_NAME_BULK_MOVEMENT_CONTACT, BULK_MOVEMENT_CONTACT_NAME_PATTERN);

        //Form data
        BulkMovementContactController.BulkMovementContactDataWrapper bulkMovementContactDataWrapperObj = new BulkMovementContactController.BulkMovementContactDataWrapper();
        bulkMovementContactDataWrapperObj.sourceRMAccountList = sourceAccountList;
        bulkMovementContactDataWrapperObj.sourceContactList = null;
        bulkMovementContactDataWrapperObj.destinationRGAccountId = destinationRGAccountId;
        bulkMovementContactDataWrapperObj.destinationRMAccountId = destinationRMAccountId;
        bulkMovementContactDataWrapperObj.transferReason = 'Account Merger and Acquisition';
        bulkMovementContactDataWrapperObj.selectedOptionsList = new List<String>{'Move Historic Activities'};
        bulkMovementContactDataWrapperObj.contactPIChangeChecked = FALSE;
        bulkMovementContactDataWrapperObj.movementUnderSameRG = FALSE;
        bulkMovementContactDataWrapperObj.campaignId = campaignId;


        if(bulkMovementContactDataWrapperObj != null){
            bulkMovementContactDataJSONString = JSON.serialize(bulkMovementContactDataWrapperObj);
        }

        return bulkMovementContactDataJSONString;
   }

   public static List<String> fetchSourceAccountList(){
      List<Id> sourceAccountList = new List<Id>();
      
      Map<Id, Account> accountMap = new Map<Id,Account>([SELECT Id, Name, RDM_Org_ID__c FROM Account WHERE RDM_Org_ID__c = 'RM333333']);
      sourceAccountList.addAll(accountMap.keySet());

      return sourceAccountList;
   }

}