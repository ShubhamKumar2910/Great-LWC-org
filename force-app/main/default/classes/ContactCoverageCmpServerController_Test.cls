@isTest
public class ContactCoverageCmpServerController_Test {

 	 @isTest(SeeAllData=true)
     static void testContactCoverageController() {
        //Test.startTest();
        
        //RecordTypes
        List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType WHERE Name IN ('RM Account', 'RG Account', 'Coverage') AND SObjectType IN ('Account','Campaign')];
        Id recordTypeIdForRM = null;
        Id recordTypeIdForRG = null;
        Id recordTypeIdForCoverageCampaignType = null;
        
        if(recordTypeList != null && recordTypeList.size() > 0){
            for(RecordType recordTypeObj : recordTypeList){
                if('RM Account'.equalsIgnoreCase(recordTypeObj.Name)){
                    recordTypeIdForRM = recordTypeObj.Id; 
                }
                else if('RG Account'.equalsIgnoreCase(recordTypeObj.Name)){
                    recordTypeIdForRG = recordTypeObj.Id; 
                }
                else if('Coverage'.equalsIgnoreCase(recordTypeObj.Name)){
                    recordTypeIdForCoverageCampaignType = recordTypeObj.Id; 
                }
            }
        }
         
        //Inserting Accounts
        Account accountRG  = new Account(); 
        accountRG.Name = 'RG_Account_Dummy';
        accountRG.RDM_Org_ID__c = 'RGXXXXXX';            
        accountRG.RecordTypeId = recordTypeIdForRG;
        accountRG.Active__c = TRUE;         
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
                
        //Inserting Users
        List<User> userList = new List<User>();
        Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        
        User userObj1 = new User();
        userObj1.Login_ID__c = 'test1tmp';
        userObj1.Alias = 'test1tmp';
        userObj1.FirstName = 'Test1TempFN';
        userObj1.LastName = 'Test1TempLN';
        userObj1.Email = 'Test1Temp@testOrg.com';
        userObj1.UserName = 'Test1Temp@testOrg.com';
        userObj1.ProfileId = profileNomuraSales.Id;
        userObj1.EmailEncodingKey = 'UTF-8';
        userObj1.LanguageLocaleKey = 'en_US';
        userObj1.LocaleSidKey = 'en_US';
        userObj1.TimeZoneSidKey = 'America/Los_Angeles';
        userObj1.Region__c = 'Americas';        
       
        insert userObj1;
         
        User sfAdminUser = [SELECT Id, Name, Login_Id__c FROM User WHERE Login_Id__c = 'sfadmin' LIMIT 1] ;
        
        Test.startTest();
         
         if(sfAdminUser != null){
              System.runas(sfAdminUser){
                    //Insert Sales_Team_for_Coverage__c
                    Sales_Team_for_Coverage__c salesTeamForCoverageObj = new Sales_Team_for_Coverage__c();
                    salesTeamForCoverageObj.Coverage_ID__c = '1234XX';
                    salesTeamForCoverageObj.Sales_Desk_Region__c = 'USA';
                    salesTeamForCoverageObj.Sales_Desk_Division__c = 'Fixed Income';
                    salesTeamForCoverageObj.Sales_Team__c = 'Test Team';
                    salesTeamForCoverageObj.Name = 'Test1TempFN Test1TempLN';
                    salesTeamForCoverageObj.Active__c = TRUE;                     
                    
                  	insert salesTeamForCoverageObj; 
                     
                     /* Insert Sales_Team_User__c */
                    Sales_Team_User__c salesTeamUserObj = new Sales_Team_User__c();
                    salesTeamUserObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
                    salesTeamUserObj.User__c = userObj1.Id;
                    salesTeamUserObj.Source_Id__c = salesTeamForCoverageObj.Id + '#' + userObj1.Id;
                
                    insert salesTeamUserObj;    
                    
              }
         }
         
        System.runas(userObj1){
            
            //Inserting Contacts
            List<Contact> contactList = new List<Contact>();        
            Integer counter = 30;
            for(Integer i = 1; i<= counter; i++){
                Contact contactObj = new Contact();
                contactObj.AccountId = accountRM.Id;
                contactObj.FirstName = 'TestFN'+ i; 
                contactObj.LastName = 'TestLN' + i;    
                contactObj.Active__c = TRUE;
                contactObj.Email = 'TestFN' + i + '_TestLN' + i +'@testxxx.com';
                contactObj.Phone = '+0000000000'; 
                contactObj.Salutation = 'M.';    
                contactObj.Mailing_Address_Same_As_Account_Address__c = TRUE;
                
                contactList.add(contactObj);
            }        
            insert contactList; 
            
            //Inserting Campaign
            Campaign campaignObj1 = new Campaign();
            campaignObj1.Name =  userObj1.FirstName + ' ' + userObj1.LastName + ' Coverage';
            campaignObj1.RecordTypeId = recordTypeIdForCoverageCampaignType;
            campaignObj1.OwnerId = userObj1.Id;
            
            insert campaignObj1;
            
             //Inserting Campaign Members
        	 List<CampaignMember> campaignMemberList = new List<CampaignMember>();
            
             for(Contact contactObj : contactList){
                CampaignMember campaignMemberObj = new CampaignMember();
                campaignMemberObj.CampaignId = campaignObj1.Id;
                campaignMemberObj.ContactId = contactObj.Id;
                
                campaignMemberList.add(campaignMemberObj);
             }            
             insert campaignMemberList;
        }
                
         List<Contact> checkContactList = [SELECT Id, Name, Active__c FROM Contact WHERE Account.RDM_Org_Id__c = 'RMXXXXXX' LIMIT 1];
         for(Contact contactObj : checkContactList) {
             Id contactId = contactObj.Id;
             system.debug('contactId--' + contactId);
             System.assertNotEquals(null, ContactCoverageCmpServerController.getCampaignMemberData(contactId,false,500,0)); 
             ContactCoverageCmpServerController.fetchCampaignMemberCount(contactId,false);
         }
         List<Account> checkAccountList = [SELECT Id, Name FROM Account WHERE RDM_Org_ID__c = 'RGXXXXXX' LIMIT 1];
         for(Account AcccObj : checkAccountList) {
             Id accId = AcccObj.Id;
             system.debug('accountid--' + accId);
             System.assertNotEquals(null, ContactCoverageCmpServerController.getCampaignMemberData(accId,true,500,0));
             ContactCoverageCmpServerController.fetchCampaignMemberCount(accId,true);
         }
        Test.stopTest(); 
     }
}