@isTest
public class BulkMovementContactBatchJobTest {
    
    public static final String BULK_MOVEMENT_CONTACT_NAME_PATTERN = 'BulkMovementContact';
    public static final String CAMPAIGN_RT_NAME_BULK_MOVEMENT_CONTACT = 'Bulk_Movement_Contact';

    @testSetUp
    public static void testSetupForBulkMovementContact() {
        Id recordTypeIdForRG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();   
        Id recordTypeIdForRM = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();   
        Id standardEventRecordTypeId = Schema.getGlobalDescribe().get('Event').getDescribe().getRecordTypeInfosByName().get('Standard Event').getRecordTypeId();
        Id standardTaskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByName().get('Standard Task').getRecordTypeId();

        User userObj = [SELECT Id, Name, Login_Id__c FROM User 
                        WHERE Login_Id__c = 'sfadmin' AND Profile.Name = 'Nomura - Integration' AND IsActive = TRUE LIMIT 1];
        Integer numTestUsers = 1;  
        List<User> users = UtilityTesting.CreateUsersWithManager(numTestUsers);

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

        /* Insert Events */
        Datetime startDateTime = Datetime.now();
        Datetime endDateTime = startDateTime.addHours(1);
        
        Event eventForOldAccountObj = new Event();
        eventForOldAccountObj.OwnerId = userObj.Id;
        eventForOldAccountObj.Subject = 'Test Old Event';
        eventForOldAccountObj.WhoId = contactObj1.Id;
        eventForOldAccountObj.WhatId = oldAccountRG.Id;
        eventForOldAccountObj.StartDateTime = startDateTime;
        eventForOldAccountObj.EndDateTime = endDateTime;
        eventForOldAccountObj.RecordTypeId = standardEventRecordTypeId;
        
        insert eventForOldAccountObj;

        /* Insert Tasks */
        Task taskForOldAccountObj = new Task();
        taskForOldAccountObj.OwnerId = users[0].Id;
        taskForOldAccountObj.Subject = 'Test Old Task';
        taskForOldAccountObj.WhoId = contactObj1.Id;
        taskForOldAccountObj.WhatId = oldAccountRG.Id;
        taskForOldAccountObj.Status = 'Open';
        taskForOldAccountObj.Priority = 'Low';
        taskForOldAccountObj.Type = 'Other';
        taskForOldAccountObj.Private__c = 'False';
        taskForOldAccountObj.RecordTypeId = standardTaskRecordTypeId;
        
        insert taskForOldAccountObj;

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
   public static void TestMoveHistoricActivities(){
       Account accountRGObj;
       
       Test.startTest();

       Id batchProcessId = Database.executeBatch(new BulkMovementContactBatchJob(),1);

       Test.stopTest();

       //Test Whether Event and Task data changed

       List<Account> accountList = [SELECT Id, Name, RDM_Org_ID__c FROM Account WHERE RDM_Org_ID__c = 'RG222222'];
       if(accountList != null && !accountList.isEmpty()){
           accountRGObj = accountList.get(0);
       }

       List<Event> eventList = [SELECT Id, Subject FROM Event WHERE Subject = 'Test Old Event' AND WhatId =:accountRGObj.Id];
       System.assert(eventList != null && !eventList.isEmpty() && eventList.size() == 1);

       List<Task> taskList = [SELECT Id, Subject, WhatId FROM Task WHERE Subject = 'Test Old Task' AND WhatId =:accountRGObj.Id];
       System.assert(taskList != null && !taskList.isEmpty() && taskList.size() == 1);

   }

}