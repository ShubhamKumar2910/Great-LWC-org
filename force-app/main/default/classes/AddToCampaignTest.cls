@isTest
public class AddToCampaignTest {
    
    
    @testSetUp
    public static void testSetupForaddToCampaign(){ 
        Id recordTypeIdForRG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();   
        Id recordTypeIdForRM = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();    
        
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
        
    }
    
    
    @isTest 
    public static void getMyContactListsTest() {
        Test.startTest();
        
        //Test
        AddToCampaign addToCampaignController = new AddToCampaign();
        
        Map<String,String> campaignShareList = AddToCampaign.getMyContactLists();
        System.assert(campaignShareList != null && campaignShareList.size() > 0);
        
        Test.stopTest();  
    }
    
    @isTest 
    public static void addToContactNCoverageTest()
    {
        Account accountRM = null, accountRG = null;
        Map<String,String> campaignShareList = null;
        
        Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        /* Insert User Record*/
        User userObj = new User();
        userObj.Login_ID__c = 'testdum1';
        userObj.Alias = 'testdum1';
        userObj.LastName = 'TestDummy1LN';
        userObj.Email = 'TestDummy1@testOrg.com';
        userObj.UserName = 'TestDummy1@testOrg.com';
        userObj.ProfileId = profileNomuraSales.Id;
        userObj.EmailEncodingKey = 'UTF-8';
        userObj.LanguageLocaleKey = 'en_US';
        userObj.LocaleSidKey = 'en_US';
        userObj.TimeZoneSidKey = 'America/Los_Angeles';
        userObj.Region__c = 'Americas';
        userObj.IsActive = TRUE;
        
        insert userObj;
        
        System.runAs(userObj){
            Test.startTest(); 
            List<Account> accountList = [SELECT Id, RDM_Org_Id__c, RecordType.Name, Name FROM Account WHERE RDM_Org_Id__c IN ('RMXXXXXX','RGXXXXXX')];
            
            if(accountList != null){
                for(Account accountObj : accountList){
                    if(accountObj.RecordType.Name.equalsIgnoreCase('RM Account')){
                        accountRM = accountObj;
                    }
                    else {
                        accountRG = accountObj;
                    }
                }
                //Insert Contacts
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
                
                insert contactObj1;
                
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
                
                
                insert contactObj2;
                
                //Insert Campaign of Type Phone Book
                Campaign phoneBookCampaignObj = new Campaign();
                Id phoneBookRecordTypeId = Schema.getGlobalDescribe().get('Campaign').getDescribe().getRecordTypeInfosByName().get('Phone Book').getRecordTypeId(); 
                Id coverageRecordTypeId = Schema.getGlobalDescribe().get('Campaign').getDescribe().getRecordTypeInfosByName().get('Coverage').getRecordTypeId();   
                phoneBookCampaignObj.Name = 'Test Contact List' ;
                phoneBookCampaignObj.RecordTypeId = phoneBookRecordTypeId;
                
                insert phoneBookCampaignObj;
                
                AddToCampaign addToCampaignController = new AddToCampaign();
                
                //Retrieve again
                campaignShareList = AddToCampaign.getMyContactLists();
                
                List <String> testCampaignIds = new List<String>();
                testCampaignIds.add(phoneBookCampaignObj.Id);
               
                
                //Add To Contact List for Contact 1
                AddToCampaign.addContactToCoverageNContact(contactObj1.Id,testCampaignIds);
                CampaignMember campaignMemberForContact1 = [SELECT Id, ContactId FROM CampaignMember 
                                                            WHERE Campaign.Id = :phoneBookCampaignObj.Id AND ContactId = :contactObj1.Id
                                                            LIMIT 1];
                System.assert(campaignMemberForContact1 != null);
                
                //Add To Contact List for Contact 2
                AddToCampaign.addContactToCoverageNContact(contactObj2.Id,testCampaignIds);
                CampaignMember campaignMemberForContact2 = [SELECT Id, ContactId FROM CampaignMember 
                                                            WHERE Campaign.Id = :phoneBookCampaignObj.Id AND ContactId = :contactObj2.Id
                                                            LIMIT 1];
                System.assert(campaignMemberForContact2 != null);
                
                //Add To My Coverage for Contact 2
                testCampaignIds.clear();
                testCampaignIds.add('-1');
                AddToCampaign.addContactToCoverageNContact(contactObj2.Id,testCampaignIds);
                CampaignMember memberForContact2InMyCoverage = [SELECT Id, ContactId FROM CampaignMember 
                                                            WHERE ContactId = :contactObj2.Id AND Campaign.RecordType.DeveloperName = 'Coverage'
                                                            LIMIT 1];
                System.assert(memberForContact2InMyCoverage != null);
                
                //Retrieve again after adding My Coverage
                campaignShareList = AddToCampaign.getMyContactLists();
                
                //Make Contact2 as Inactive
                contactObj2.Active__c = FALSE;
                contactObj2.Inactive_Reason__c = 'Other';
                contactObj2.Other_Inactive_Reason__c = 'Other';
                
                update contactObj2;
                
                //Again Add To coverage for Contact 2
                testCampaignIds.clear();
                testCampaignIds.add(phoneBookCampaignObj.Id);
                String errorMessage =  AddToCampaign.addContactToCoverageNContact(contactObj2.Id,testCampaignIds);
                
                
                Test.stopTest();
                
            }
        }
    }
}