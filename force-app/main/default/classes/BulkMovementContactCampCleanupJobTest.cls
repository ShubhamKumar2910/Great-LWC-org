@isTest
public class BulkMovementContactCampCleanupJobTest {
    
    public static final String BULK_MOVEMENT_CONTACT_NAME_PATTERN = 'BulkMovementContact';
    public static final String CAMPAIGN_RT_NAME_BULK_MOVEMENT_CONTACT = 'Bulk_Movement_Contact';

    @testSetUp
    public static void testSetupForBulkMovementContactCampaignCleanupJob() {
        Id recordTypeIdForRG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();   
        Id recordTypeIdForRM = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();   
    

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
       newAccountRM.Name = 'RM_Account_Dummy_New_1';
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
       contactObj1.GRP_Access__c = TRUE;
       contactObj1.Investor_Type__c = 'Americas- Qualified Institutional Buyer';
       contactObj1.Region__c = 'Americas';
       contactObj1.Preferred_Language__c = 'English';
       contactObj1.Sales_Sponsor__c = 'Sankarkartik Raman';
       contactObj1.Sponsor_Email_Text__c = 'sankarkartik.raman@nomura.com';
       
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

       //Camapign 1
       String campaignId = CampaignService.getBulkUploadCampaignRec(null, CAMPAIGN_RT_NAME_BULK_MOVEMENT_CONTACT, BULK_MOVEMENT_CONTACT_NAME_PATTERN);
       Campaign campaignObj1 = new Campaign();
       campaignObj1.Id = campaignId;
       Test.setCreatedDate(campaignObj1.Id, DateTime.newInstance(2018,12,12));


       //Campaign 2
       String bulkMovementContactDataJSONStr = createBulkMovementContactDataJSON();

       BulkMovementContactController bulkMovementContactCtrl = new BulkMovementContactController();
       BulkMovementContactController.saveBulkMovementContactData(bulkMovementContactDataJSONStr);

       BulkMovementContactController.BulkMovementContactDataWrapper bulkMovementContactDataWrapperObj = BulkMovementContactController.parseBulkMovementContactDataJSONString(bulkMovementContactDataJSONStr);
       Campaign campaignObj2 = new Campaign();
       campaignObj2.Id = bulkMovementContactDataWrapperObj.campaignId;
       Test.setCreatedDate(campaignObj2.Id, DateTime.newInstance(2018,12,12));

    }

   @isTest 
   public static void TestMoveHistoricActivities(){
       Test.startTest();

       Id batchProcessId = Database.executeBatch(new BulkMovementContactCampaignCleanupJob(new Set<String>{'Draft','Submitted','Planned','Failed','Contact Movement Failed','Move Historic Activity Failed','Copy Contact Interests Failed'},'Bulk_Movement_Contact', 180), 2);

       Test.stopTest();

       //Test Whether Campaigns are present or not
       List<Campaign> campaignList = [SELECT Id, Name FROM Campaign WHERE RecordType.DeveloperName = :CAMPAIGN_RT_NAME_BULK_MOVEMENT_CONTACT];
       System.assert(campaignList == null  || (campaignList != null && campaignList.size() == 0));
   }

   @isTest
   public static void testScheduler(){
        Test.startTest();
        
        String CRON_EXP = '0 0 0 20 1 ? 2050';
        
        String jobId = System.schedule('BulkMovementContactCleanupScheduler', CRON_EXP, new BulkMovementContactCleanupScheduler());
        
        CronTrigger cronTriggerObj = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                                      FROM CronTrigger
                                      WHERE Id = :jobId
                                     ];
        
        System.assertEquals(CRON_EXP, cronTriggerObj.CronExpression);
        System.assertEquals(0, cronTriggerObj.TimesTriggered);
        System.assertEquals('2050-01-20 00:00:00', String.valueOf(cronTriggerObj.NextFireTime));
        
        Test.stopTest();
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