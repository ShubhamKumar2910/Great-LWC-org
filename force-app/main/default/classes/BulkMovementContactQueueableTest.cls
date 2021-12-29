@isTest
public class BulkMovementContactQueueableTest {
    
   public static final String BULK_MOVEMENT_CONTACT_NAME_PATTERN = 'BulkMovementContact';
   public static final String CAMPAIGN_RT_NAME_BULK_MOVEMENT_CONTACT = 'Bulk_Movement_Contact';

   @testSetUp
   public static void testSetupForBulkMovementContact() {
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

       Account newAccountRM1  = new Account();  
       newAccountRM1.Name = 'RM_Account_Dummy_New_1';
       newAccountRM1.RDM_Org_ID__c = 'RM444444';            
       newAccountRM1.RecordTypeId = recordTypeIdForRM;
       newAccountRM1.BillingStreet = 'Cynergy IT Park, 2nd floor,Prabhadevi, Mumbai 400025' ;
       newAccountRM1.BillingCity = 'Mumbai';
       newAccountRM1.BillingPostalCode = '400025';
       newAccountRM1.BillingCountry = 'India';
       newAccountRM1.Active__c = TRUE; 
       newAccountRM1.ParentId = newAccountRG.Id;
       newAccountRM1.MiFID_II_Research_In_Scope__c = TRUE;
       newAccountRM1.Default_New_Contact_MiFID_II_Entitlement__c = TRUE;
       newAccountRM1.MiFIDII_Sales_Commentary_Allowed__c = 'Allowed';
       newAccountRM1.MiFID_II_Product_Subscriptions__c = 'FIGL';
       newAccountRM1.Service_Type__c = 'Full Service';

       accountRMList.add(newAccountRM1);

       Account newAccountRM2  = new Account();  
       newAccountRM2.Name = 'RM_Account_Dummy_New_2';
       newAccountRM2.RDM_Org_ID__c = 'RM555555';            
       newAccountRM2.RecordTypeId = recordTypeIdForRM;
       newAccountRM2.BillingStreet = 'Cynergy IT Park, 2nd floor,Prabhadevi, Mumbai 400025' ;
       newAccountRM2.BillingCity = 'Mumbai';
       newAccountRM2.BillingPostalCode = '400025';
       newAccountRM2.BillingCountry = 'India';
       newAccountRM2.Active__c = TRUE; 
       newAccountRM2.ParentId = newAccountRG.Id;

       accountRMList.add(newAccountRM2);
       
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

   }

   public static String createBulkMovementContactDataJSON(Boolean includeActivityMovement, String destinationRGAccountId, String destinationRMAccountId){
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
        if(includeActivityMovement){
            bulkMovementContactDataWrapperObj.selectedOptionsList = new List<String>{'Move Historic Activities'};
        }
        else {
            bulkMovementContactDataWrapperObj.selectedOptionsList = null;
        }
        
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
   public static void performMoveWithNewRMAccount1Test(){

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
        
        String bulkMovementContactDataJSONStr = createBulkMovementContactDataJSON(TRUE, destinationRGAccountId, destinationRMAccountId);

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

      //Check Contacts Moved to new RG
      List<Contact> newAccountContactList = [SELECT Id, Name, Email, AccountId FROM Contact WHERE RG_Account__r.RDM_Org_ID__c = 'RG222222'];
      System.assert(newAccountContactList != null && newAccountContactList.size() == 2);        

      //Check No Contacts present for old RG
      List<Contact> oldAccountContactList = [SELECT Id, Name, Email, AccountId FROM Contact WHERE RG_Account__r.RDM_Org_ID__c = 'RG111111'];
      System.assert(oldAccountContactList == null || (oldAccountContactList != null && oldAccountContactList.size() == 0));                          
   }

   @isTest 
   public static void performDeactivationAndCloningWithNewRMAccount1Test(){
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
        
        String bulkMovementContactDataJSONStr = createBulkMovementContactDataJSON(FALSE, destinationRGAccountId, destinationRMAccountId);

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

      //Check Contacts Moved to new RG
      List<Contact> newAccountContactList = [SELECT Id, Name, Email, AccountId FROM Contact WHERE RG_Account__r.RDM_Org_ID__c = 'RG222222'];
      System.assert(newAccountContactList != null && newAccountContactList.size() == 2);        

      //Check only Inactive contacts present for old RG
      List<Contact> oldAccountContactList = [SELECT Id, Name, Email, AccountId FROM Contact WHERE RG_Account__r.RDM_Org_ID__c = 'RG111111' AND Active__c = FALSE];
      System.assert(oldAccountContactList != null && oldAccountContactList.size() == 2);                          
   }

   @isTest 
   public static void performMoveWithNewRMAccount2Test(){

       String destinationRGAccountId = null;
       String destinationRMAccountId = null;
       
        //Fetch Destination Account Details
        List<Account> destinationAccountList = [SELECT Id, RDM_Org_Id__c FROM Account WHERE RDM_Org_Id__c IN ('RG222222','RM555555')];
        if(destinationAccountList != null && destinationAccountList.size() > 0){
            for(Account accountObj : destinationAccountList){
                if('RG222222'.equalsIgnoreCase(accountObj.RDM_Org_Id__c)){
                    destinationRGAccountId = accountObj.Id;
                }
                else if('RM555555'.equalsIgnoreCase(accountObj.RDM_Org_Id__c)){
                    destinationRMAccountId = accountObj.Id;
                }
            }
        }
        
        String bulkMovementContactDataJSONStr = createBulkMovementContactDataJSON(TRUE, destinationRGAccountId, destinationRMAccountId);

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

      //Check Contacts Moved to new RG
      List<Contact> newAccountContactList = [SELECT Id, Name, Email, AccountId FROM Contact WHERE RG_Account__r.RDM_Org_ID__c = 'RG222222'];
      System.assert(newAccountContactList != null && newAccountContactList.size() == 2);        

      //Check No Contacts present for old RG
      List<Contact> oldAccountContactList = [SELECT Id, Name, Email, AccountId FROM Contact WHERE RG_Account__r.RDM_Org_ID__c = 'RG111111'];
      System.assert(oldAccountContactList == null || (oldAccountContactList != null && oldAccountContactList.size() == 0));                          
   }

   @isTest 
   public static void performDeactivationAndCloningWithNewRMAccount2Test(){
       String destinationRGAccountId = null;
       String destinationRMAccountId = null;
        
        //Fetch Destination Account Details
        List<Account> destinationAccountList = [SELECT Id, RDM_Org_Id__c FROM Account WHERE RDM_Org_Id__c IN ('RG222222','RM555555')];
        if(destinationAccountList != null && destinationAccountList.size() > 0){
            for(Account accountObj : destinationAccountList){
                if('RG222222'.equalsIgnoreCase(accountObj.RDM_Org_Id__c)){
                    destinationRGAccountId = accountObj.Id;
                }
                else if('RM555555'.equalsIgnoreCase(accountObj.RDM_Org_Id__c)){
                    destinationRMAccountId = accountObj.Id;
                }
            }
        }
        
        String bulkMovementContactDataJSONStr = createBulkMovementContactDataJSON(FALSE, destinationRGAccountId, destinationRMAccountId);

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

      //Check Contacts Moved to new RG
      List<Contact> newAccountContactList = [SELECT Id, Name, Email, AccountId FROM Contact WHERE RG_Account__r.RDM_Org_ID__c = 'RG222222'];
      System.assert(newAccountContactList != null && newAccountContactList.size() == 2);        

      //Check only Inactive contacts present for old RG
      List<Contact> oldAccountContactList = [SELECT Id, Name, Email, AccountId FROM Contact WHERE RG_Account__r.RDM_Org_ID__c = 'RG111111' AND Active__c = FALSE];
      System.assert(oldAccountContactList != null && oldAccountContactList.size() == 2);                          
   }


}