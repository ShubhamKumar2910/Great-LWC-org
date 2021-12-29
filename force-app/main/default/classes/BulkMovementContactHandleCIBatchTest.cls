@isTest
public class BulkMovementContactHandleCIBatchTest {

   public static final String BULK_MOVEMENT_CONTACT_NAME_PATTERN = 'BulkMovementContact';
   public static final String CAMPAIGN_RT_NAME_BULK_MOVEMENT_CONTACT = 'Bulk_Movement_Contact';

   @testSetUp
   public static void testSetupForBulkMovementContact() {
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

        //Insert Asset Data
        AssetClass__c objAsset = new AssetClass__c();
        objAsset.name = 'All Asset Classes';
        objAsset.code__c = '1';
        objAsset.lvl__c = 1;
        insert objAsset;
        
        
        //Insert Market Data
        Market__c objMarket = new Market__c();
        objMarket.name = 'Global';
        objMarket.code__c = 1000.00;
        objMarket.lvl__c = 1;
        insert objMarket;
        
        
        //Insert Sector Data
        Sector__c objSector = new Sector__c();
        objSector.name = 'All';
        objSector.code__c = '001';
        objSector.lvl__c = 1;
        insert objSector;
        
        

       /* Insert Contact Interest */
       List<Contact_Interest__c> contactInterestList = new List<Contact_Interest__c>();

       Contact_Interest__c contactInterestObj1 = new Contact_Interest__c();
       contactInterestObj1.Contact__c = contactObj1.Id;
       contactInterestObj1.Asset_Lookup__c = objAsset.Id;
       contactInterestObj1.Asset_Picklist__c = 'All Asset Classes';
       contactInterestObj1.Market_lookup__c = objMarket.Id;
       contactInterestObj1.Market_Picklist__c = 'Global';
       contactInterestObj1.Sector_Lookup__c = objSector.Id;
       contactInterestObj1.Sectort_Picklist__c = 'All';
       contactInterestObj1.flags__c = 'wont participate in deals with mkt cap < US$2bn';

       contactInterestList.add(contactInterestObj1);

       Contact_Interest__c contactInterestObj2 = new Contact_Interest__c();
       contactInterestObj2.Contact__c = contactObj2.Id;
       contactInterestObj2.Asset_Lookup__c = objAsset.Id;
       contactInterestObj2.Asset_Picklist__c = 'All Asset Classes';
       contactInterestObj2.Market_lookup__c = objMarket.Id;
       contactInterestObj2.Market_Picklist__c = 'Global';
       contactInterestObj2.Sector_Lookup__c = objSector.Id;
       contactInterestObj2.Sectort_Picklist__c = 'All';
       contactInterestObj2.flags__c = 'wont participate in deals with mkt cap < US$2bn';

       contactInterestList.add(contactInterestObj2);

       insert contactInterestList;

       //Perform the movement
       String destinationRGAccountId = null;
       String destinationRMAccountId = null;
        
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
        
        String bulkMovementContactDataJSONStr = createBulkMovementContactDataJSON(destinationRGAccountId, destinationRMAccountId);

        BulkMovementContactController bulkMovementContactCtrl = new BulkMovementContactController();
        BulkMovementContactController.saveBulkMovementContactData(bulkMovementContactDataJSONStr);
       
       Test.startTest();
       //Fetch Campaigns where Satus is Submitted
       List<Campaign> campaignList = [SELECT Id, Name, Status FROM Campaign
                                      WHERE RecordType.DeveloperName = 'Bulk_Movement_Contact' AND Status = 'Submitted'];

       if(campaignList != null && campaignList.size() > 0){
           Campaign campaignObj = campaignList.get(0);

           //Call the Queueable
           BulkMovementContactQueueable bulkMovmentContactJob = new BulkMovementContactQueueable(campaignObj.Id);
           String jobId = System.enqueueJob(bulkMovmentContactJob);
       }

       Test.stopTest(); 


   }

   public static String createBulkMovementContactDataJSON(String destinationRGAccountId, String destinationRMAccountId){
        String bulkMovementContactDataJSONString = '';
        
        //Fetch Source RM Accounts
        List<Id> sourceAccountList = fetchSourceAccountList();

        
        //Get Campaign of Type Bulk Movement Contact
        String campaignId = CampaignService.getBulkUploadCampaignRec(null, CAMPAIGN_RT_NAME_BULK_MOVEMENT_CONTACT, BULK_MOVEMENT_CONTACT_NAME_PATTERN);

        //Form data
        BulkMovementContactController.BulkMovementContactDataWrapper bulkMovementContactDataWrapperObj = new BulkMovementContactController.BulkMovementContactDataWrapper();
        bulkMovementContactDataWrapperObj.sourceRMAccountList = sourceAccountList;
        bulkMovementContactDataWrapperObj.sourceContactList = null;
        bulkMovementContactDataWrapperObj.destinationRGAccountId = destinationRGAccountId;
        bulkMovementContactDataWrapperObj.destinationRMAccountId = destinationRMAccountId;
        bulkMovementContactDataWrapperObj.transferReason = 'Account Merger and Acquisition';
        bulkMovementContactDataWrapperObj.selectedOptionsList = new List<String>{'Copy Contact Interests'};
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

   @isTest 
   public static void TestcontactInterestHandling(){
       Test.startTest();

       Id batchProcessId = Database.executeBatch(new BulkMovementContactHandleCIBatch(),10);

       Test.stopTest();

       //Test Whether contact Interest is present for new contacts
       List<Contact_Interest__c> contactInterestList = [SELECT Id, Name, Contact__r.Account.RDM_Org_ID__c FROM Contact_Interest__c WHERE Contact__r.Account.RDM_Org_ID__c = 'RM444444'];
       System.assert(contactInterestList != null && contactInterestList.size() == 2);
   }
    
}