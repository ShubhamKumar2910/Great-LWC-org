@isTest
public class RMMergeEntityHandlingBatchTest {
    
    @testSetUp
    public static void testSetupForRMMergeEntityHandlingBatch() {
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

        //Insert entry in Client_Remediation__c Obect
        Client_Remediation__c crObj = new Client_Remediation__c();
        
        crObj.OLD_RG__c = 'RG111111';
        crObj.NEW_RG__c = 'RG222222';
        crObj.OLD_RG_Account__c = oldAccountRG.Id;
        crObj.NEW_RG_Account__c = newAccountRG.Id;
        crObj.OLD_RM__c = 'RM333333';
        crObj.NEW_RM__c = 'RM444444';
        crObj.OLD_RM_Account__c = oldAccountRM.Id;
        crObj.NEW_RM_Account__c = newAccountRM.Id;
        crObj.RM_ACTION__c = 'MERGE';
        
        insert crObj;

    }

    @isTest 
    public static void TestRMMergeEntityHandlingBatch(){
       
       Test.startTest();

       Id batchProcessId = Database.executeBatch(new RMMergeEntityHandlingBatch(), 1);

       Test.stopTest();

       //Test Whether Campaign and CampaignMember Created

       List<Campaign> campaignList = [SELECT Id FROM Campaign 
                                     WHERE Status IN ('Submitted') AND 
                                     RecordType.DeveloperName = 'Bulk_Movement_Contact' AND
                                    Name LIKE 'QuantexaBulkMovementContact%'];

       System.assert(campaignList != null && !campaignList.isEmpty() && campaignList.size() == 1);

       List<CampaignMember> campaignMemberList = [SELECT Id FROM CampaignMember 
                                     WHERE Campaign.Status IN ('Submitted') AND 
                                     Campaign.RecordType.DeveloperName = 'Bulk_Movement_Contact' AND 
                                     Campaign.Name LIKE 'QuantexaBulkMovementContact%'];

        System.assert(campaignMemberList != null && !campaignMemberList.isEmpty() && campaignMemberList.size() == 2);

   }

    
}