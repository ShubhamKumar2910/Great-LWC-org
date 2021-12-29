@isTest
public  class CoverageApprovalReminderTest {
    static testMethod void testGetCurrentUserSalesCode(){
    }
    @testSetup static void setupTestData(){
        List<Account> lstAccount = new List<Account>();
        RecordType recordTypeRG = [SELECT Id FROM RecordType WHERE Name = 'RG Account' LIMIT 1];
        RecordType recordTypeRM = [SELECT Id FROM RecordType WHERE Name = 'RM Account' LIMIT 1];
        Account oldAccountObj = new Account();
        oldAccountObj.Name = 'Old_Account';
        oldAccountObj.RDM_Org_Id__c = 'RG1';
        oldAccountObj.RecordTypeId = recordTypeRG.Id;
        oldAccountObj.Active__c = TRUE;   
        
        lstAccount.add(oldAccountObj);
               
        Account oldAccountRMObj  = new Account(); 
        oldAccountRMObj.Name = 'Old_Account_RM';
        oldAccountRMObj.RDM_Org_ID__c = 'RM1';            
        oldAccountRMObj.RecordTypeId = recordTypeRM.Id;
        oldAccountRMObj.BillingCity = 'California';
        oldAccountRMObj.BillingCountry = 'United States';
        oldAccountRMObj.BillingStreet = '52nd Street';
        oldAccountRMObj.ParentId = oldAccountObj.Id;
        oldAccountRMObj.Active__c = TRUE;    
        
        lstAccount.add(oldAccountRMObj); 
        insert lstAccount;        
    }
    static testMethod void testMethodforReminders() {
        Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        Profile profileNomuraAdmin = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Integration' LIMIT 1];
        
        UserRole userRoleObj = [SELECT Id, Name  FROM UserRole WHERE Name LIKE 'Americas - FI - Sales%' LIMIT 1];
        UserRole userAdminRoleObj = [SELECT Id, Name  FROM UserRole WHERE Name LIKE 'Wholesale%' LIMIT 1];
        
        //Insert Manager
        User userAsMgrObj = new User();
        userAsMgrObj.Login_ID__c = 'testMgr';
        userAsMgrObj.Alias = 'testMgr';
        userAsMgrObj.LastName = 'TestMgr_LN';
        userAsMgrObj.FirstName = 'TestMgr_FN';
        userAsMgrObj.Email = 'TestMgr@testOrg.com';
        userAsMgrObj.UserName = 'TestMgr@testOrg.com';
        userAsMgrObj.ProfileId = profileNomuraSales.Id;
        userAsMgrObj.EmailEncodingKey = 'UTF-8';
        userAsMgrObj.LanguageLocaleKey = 'en_US';
        userAsMgrObj.LocaleSidKey = 'en_US';
        userAsMgrObj.TimeZoneSidKey = 'America/Los_Angeles';
        userAsMgrObj.Region__c = 'Americas';
        userAsMgrObj.UserRoleId = (userRoleObj != null ? userRoleObj.Id : null);
        userAsMgrObj.Notification_Preferences__c = 'Coverage Approval Reminder';
        insert userAsMgrObj;
        
        //Insert User
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
        userObj.Country = 'United States';
        userObj.UserRoleId = (userRoleObj != null ? userRoleObj.Id : null);
        userObj.Notification_Preferences__c = 'Coverage Approval Reminder';
        userObj.ManagerId = userAsMgrObj.Id;      
        insert userObj;
        List<Account> lstAccount = new List<Account>();
        
        Test.startTest();   
        
        system.runAs(userObj){
             /* Insert Sales_Team_for_Coverage__c */
            Sales_Team_for_Coverage__c salesTeamForCoverageObj = new Sales_Team_for_Coverage__c();
            salesTeamForCoverageObj.Name = 'TestTemp_FN TestTemp_LN';
            salesTeamForCoverageObj.Coverage_ID__c = '1234XX';
            salesTeamForCoverageObj.Sales_Team__c = 'Test Team';
            salesTeamForCoverageObj.Sales_Desk_Region__c = 'USA';
            salesTeamForCoverageObj.Sales_Desk_Division__c = 'Fixed Income';
            salesTeamForCoverageObj.Sales_Code_Login_ID__c = userObj.Login_Id__c;
            salesTeamForCoverageObj.Active__c = TRUE;
            
            insert salesTeamForCoverageObj;
            
            /* Insert Sales_Team_User__c */
            Sales_Team_User__c salesTeamUserObj = new Sales_Team_User__c();
            salesTeamUserObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
            salesTeamUserObj.User__c = userObj.Id;
            salesTeamUserObj.Source_Id__c = salesTeamForCoverageObj.Coverage_ID__c + '#' + userObj.Login_Id__c;
            
            insert salesTeamUserObj;
            //Fetch Accounts
            Account oldAccountObj = null;
            Account oldRMAccountObj = null;
            List<Account> accountList = [SELECT Id, Name, RDM_Org_Id__c FROM Account 
                                         WHERE RDM_Org_Id__c IN ('RG1','RM1')];
                                         system.debug('accountList the if loop :'+accountList);
            if(accountList != null && accountList.size() > 0){
                for(Account accountObj : accountList){
                    if('RG1'.equalsIgnoreCase(accountObj.RDM_Org_Id__c)){
                        oldAccountObj = accountObj;
                    }
                    else if('RM1'.equalsIgnoreCase(accountObj.RDM_Org_Id__c)){
                        oldRMAccountObj = accountObj;
                    }
                }
            }
            system.debug('outside the if loop');
            //Insert Coverage Request
            if(oldAccountObj != null){
                system.debug('in the if loop');
                List<RG_Coverage_Request__c> coverageRequestForRGList = new List<RG_Coverage_Request__c>();
                Date today = Date.today();
                RG_Coverage_Request__c coverageRequestForOldRGObj = new RG_Coverage_Request__c();
                    
                coverageRequestForOldRGObj.RG_Account__c = oldAccountObj.Id;
                coverageRequestForOldRGObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
                coverageRequestForOldRGObj.Type_of_Coverage__c = 'Add';
                coverageRequestForOldRGObj.Start_Date__c = today.addDays(-20);
                coverageRequestForOldRGObj.Role__c = 'Primary';
                coverageRequestForOldRGObj.CreatedDate = today.addDays(-20);
                coverageRequestForOldRGObj.SourceUpload__c = 'Tool';
                coverageRequestForRGList.add(coverageRequestForOldRGObj);                
                
                Coverage_Access_Request__c coverageRequestForOldRGObj1 = new Coverage_Access_Request__c();
                    
                coverageRequestForOldRGObj1.Account__c = oldRMAccountObj.Id;
                coverageRequestForOldRGObj1.Requested_for_User__c = userObj.Id;
                coverageRequestForOldRGObj1.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
                coverageRequestForOldRGObj1.Type_of_Coverage__c = 'Add';
                coverageRequestForOldRGObj1.CreatedDate = today.addDays(-20);
                coverageRequestForOldRGObj1.Start_Date__c = today.addDays(-20);
                coverageRequestForOldRGObj1.Role__c = 'Primary';
                coverageRequestForOldRGObj1.SourceUpload__c = 'Tool';  
                
                insert coverageRequestForRGList;       
                insert coverageRequestForOldRGObj1;
                List<ProcessInstanceWorkitem> item = [select ActorId, ElapsedTimeInDays,ProcessInstance.Status, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: coverageRequestForOldRGObj1.Id]; 
                system.debug('item :: '+item);
            }
        } 
        
        String CRON_EXP = '0 0 0 15 3 ? *';
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new NotificationScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        //Database.executeBatch(new NotificationBatch(), 200);               
        Test.stopTest();  
	}
}