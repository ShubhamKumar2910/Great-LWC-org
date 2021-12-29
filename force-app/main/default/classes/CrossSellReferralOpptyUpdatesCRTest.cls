@isTest
public class CrossSellReferralOpptyUpdatesCRTest {

    @testSetUp
    public static void testSetupForCrossSellReferralOppty(){
        Sales_Team_for_Coverage__c referrerSalesCode, referredPersonSalesCode;
        Account oldAccountObj, newAccountObj;
        Opportunity opptyForOldAccountObj, opptyForNewAccountObj;
        Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        UserRole userRoleObj = [SELECT Id, Name  FROM UserRole WHERE Name LIKE 'Americas - FI - Sales%' LIMIT 1];
        
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
        
        insert userAsMgrObj;
        
        
        /* Insert User Records*/
        List<User> userList = new List<User>();
        User referrerUser = new User();
        referrerUser.Login_ID__c = 'testdum1';
        referrerUser.Alias = 'testdum1';
        referrerUser.LastName = 'TestDummy1LN';
        referrerUser.Email = 'TestDummy1@testOrg.com';
        referrerUser.UserName = 'TestDummy1@testOrg.com';
        referrerUser.ProfileId = profileNomuraSales.Id;
        referrerUser.EmailEncodingKey = 'UTF-8';
        referrerUser.LanguageLocaleKey = 'en_US';
        referrerUser.LocaleSidKey = 'en_US';
        referrerUser.TimeZoneSidKey = 'America/Los_Angeles';
        referrerUser.Region__c = 'Americas';
        referrerUser.IsActive = TRUE;
        referrerUser.ManagerId = userAsMgrObj.Id; 
        
        
        userList.add(referrerUser);
         
        User referredUser = new User();
        referredUser.Login_ID__c = 'testdum2';
        referredUser.Alias = 'testdum2';
        referredUser.LastName = 'TestDummy2LN';
        referredUser.Email = 'TestDummy2@testOrg.com';
        referredUser.UserName = 'TestDummy2@testOrg.com';
        referredUser.ProfileId = profileNomuraSales.Id;
        referredUser.EmailEncodingKey = 'UTF-8';
        referredUser.LanguageLocaleKey = 'en_US';
        referredUser.LocaleSidKey = 'en_US';
        referredUser.TimeZoneSidKey = 'America/Los_Angeles';
        referredUser.Region__c = 'Americas';
        referredUser.IsActive = TRUE;
        referredUser.ManagerId = userAsMgrObj.Id; 
        
        userList.add(referredUser); 
         
        insert userList;
        
        
        User nomuraIntegrationUser = [SELECT Id, Name FROM User WHERE Login_Id__c = 'sfadmin' 
                                      AND Profile.Name = 'Nomura - Integration' LIMIT 1];
        
        system.runas(nomuraIntegrationUser){
       
            /* Insert RG Accounts */
            List<Account> accountRGList = new List<Account>();
            oldAccountObj = new Account();
            oldAccountObj.Name = 'Old_Account';
            oldAccountObj.RDM_Org_Id__c = 'RG111';
            oldAccountObj.RecordTypeId = CommonTools.getRecordTypeId('Account','RG Account');
            oldAccountObj.Active__c = TRUE;   
           
            accountRGList.add(oldAccountObj);
            
            newAccountObj = new Account();
            newAccountObj.Name = 'New_Account';
            newAccountObj.RDM_Org_Id__c = 'RG222';
            newAccountObj.RecordTypeId = CommonTools.getRecordTypeId('Account','RG Account');
            newAccountObj.Active__c = TRUE;   
            
            accountRGList.add(newAccountObj);
            
            insert accountRGList;
            
            /* Insert RM Accounts */
            List<Account> accountRMList = new List<Account>();
            
            Account oldRMAccountObj = new Account();
            oldRMAccountObj.Name = 'Old_RM_Account';
            oldRMAccountObj.RDM_Org_Id__c = 'RM111';
            oldRMAccountObj.RecordTypeId = CommonTools.getRecordTypeId('Account','RM Account');
            oldRMAccountObj.Active__c = TRUE; 
            oldRMAccountObj.ParentId = oldAccountObj.Id;
            
            accountRMList.add(oldRMAccountObj);
            
            Account newRMAccountObj = new Account();
            newRMAccountObj.Name = 'New_RM_Account';
            newRMAccountObj.RDM_Org_Id__c = 'RM222';
            newRMAccountObj.RecordTypeId = CommonTools.getRecordTypeId('Account','RM Account');
            newRMAccountObj.Active__c = TRUE; 
            newRMAccountObj.ParentId = newAccountObj.Id;
            
            accountRMList.add(newRMAccountObj);
            
            insert accountRMList;
            
            /* Insert Sales_Team_for_Coverage__c  and Sales_Team_User__c Records */
            List<Sales_Team_for_Coverage__c> salesCodeList = new List<Sales_Team_for_Coverage__c>();
            
            referrerSalesCode = new Sales_Team_for_Coverage__c();
            referrerSalesCode.Coverage_ID__c = '1234';
            referrerSalesCode.Name = 'TestDummy1LN';
            referrerSalesCode.Sales_Team__c = 'Test Team';
            referrerSalesCode.Sales_Desk_Region__c = 'USA';
            referrerSalesCode.Sales_Desk_Division__c = 'Fixed Income';
            referrerSalesCode.Sales_Code_Login_ID__c = 'testdum1';
            referrerSalesCode.Active__c = TRUE;
            //Fix for JIRA 3862
            referrerSalesCode.Company__c = 'N';
            
            salesCodeList.add(referrerSalesCode);
            
            referredPersonSalesCode = new Sales_Team_for_Coverage__c();
            referredPersonSalesCode.Coverage_ID__c = '5678';
            referredPersonSalesCode.Name = 'TestDummy2LN';
            referredPersonSalesCode.Sales_Team__c = 'Test Team';
            referredPersonSalesCode.Sales_Desk_Region__c = 'USA';
            referredPersonSalesCode.Sales_Desk_Division__c = 'Fixed Income';
            referredPersonSalesCode.Sales_Code_Login_ID__c = 'testdum2';
            referredPersonSalesCode.Active__c = TRUE;
            //Fix for JIRA 3862
            referredPersonSalesCode.Company__c = 'N';
            
            salesCodeList.add(referredPersonSalesCode);
            
            insert salesCodeList;
            
            List<Sales_Team_User__c> salesTeamUserList = new List<Sales_Team_User__c>();
            
            Sales_Team_User__c referrerSalesTeamUserObj = new Sales_Team_User__c();
            referrerSalesTeamUserObj.Sales_Team_for_Coverage__c = referrerSalesCode.Id;
            referrerSalesTeamUserObj.User__c = referrerUser.Id;
            referrerSalesTeamUserObj.Source_Id__c = referrerSalesCode.Coverage_ID__c + '#' + referrerUser.Login_ID__c;
            
            salesTeamUserList.add(referrerSalesTeamUserObj);
            
            
            Sales_Team_User__c referredPersonSalesTeamUserObj = new Sales_Team_User__c();
            referredPersonSalesTeamUserObj.Sales_Team_for_Coverage__c = referredPersonSalesCode.Id;
            referredPersonSalesTeamUserObj.User__c = referredUser.Id;
            referredPersonSalesTeamUserObj.Source_Id__c = referredPersonSalesCode.Coverage_ID__c + '#' + referredUser.Login_ID__c;
            
            salesTeamUserList.add(referredPersonSalesTeamUserObj);
            
            insert salesTeamUserList;
         }
         
		 Test.startTest();	         
        
         system.runas(userAsMgrObj){
            
             
             //Insert Opportunity
            List<Opportunity> opptyList = new List<Opportunity>();
            
            opptyForOldAccountObj = new Opportunity();
            opptyForOldAccountObj.Name = 'Old Account Oppty';
            opptyForOldAccountObj.Account__c = oldAccountObj.Id;
            //opptyForOldAccountObj.AccountId = oldAccountObj.Id;
            opptyForOldAccountObj.CloseDate = Date.today();
            opptyForOldAccountObj.StageName = 'Referral Requested';
             //Fix for Test class JIRA 3410
            // opptyForOldAccountObj.Referre_Sales_Code__c = referrerSalesCode.Id;
            opptyForOldAccountObj.Referee__c = referrerUser.Id;
            // opptyForOldAccountObj.Referral_Sales_Code__c = referredPersonSalesCode.Id;
            opptyForOldAccountObj.Referral__c = referredUser.Id;
            opptyForOldAccountObj.ProductVal__c ='AGENCY MORTGAGES';
            opptyForOldAccountObj.Product_Region__c = 'Fixed Income - USA';   
			opptyForOldAccountObj.RecordTypeId = CommonTools.getRecordTypeId('Opportunity','Cross Sell Referral');
            
            opptyList.add(opptyForOldAccountObj);
            
            opptyForNewAccountObj = new Opportunity();
            opptyForNewAccountObj.Name = 'New Account Oppty';
            opptyForNewAccountObj.Account__c = newAccountObj.Id;
            //opptyForNewAccountObj.AccountId = newAccountObj.Id;
            opptyForNewAccountObj.CloseDate = Date.today();
            opptyForNewAccountObj.StageName = 'Referral Requested';
            //Fix for Test class JIRA 3410
            //opptyForNewAccountObj.Referre_Sales_Code__c = referrerSalesCode.Id;
            opptyForNewAccountObj.Referee__c = referrerUser.Id;
            //opptyForNewAccountObj.Referral_Sales_Code__c = referredPersonSalesCode.Id;
            opptyForNewAccountObj.Referral__c = referredUser.Id;
            opptyForNewAccountObj.ProductVal__c ='AGENCY MORTGAGES';
            opptyForNewAccountObj.Product_Region__c = 'Fixed Income - USA';   
			opptyForNewAccountObj.RecordTypeId = CommonTools.getRecordTypeId('Opportunity','Cross Sell Referral');
            
            opptyList.add(opptyForNewAccountObj);
            
            insert opptyList;
             
         }
        
        
        
         system.runas(referredUser){     
             List<ProcessInstanceWorkitem> processInstanceWorkitemList = [SELECT Id FROM ProcessInstanceWorkitem 
                                                                           WHERE ProcessInstance.TargetObjectId =:opptyForOldAccountObj.Id /*OR 
                                                                           ProcessInstance.TargetObjectId =:opptyForNewAccountObj.Id*/];
             if(processInstanceWorkitemList.size() > 0)
             {
                 for(ProcessInstanceWorkitem processInstanceWorkitemObj : processInstanceWorkitemList){
                 	Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
              		request.setComments('Approving request for Opportunity');             
              		request.setAction('Approve');
                    request.setWorkitemId(processInstanceWorkitemObj.Id); 
                    Approval.ProcessResult result = Approval.process(request);
                 }
             }
         }
        
         system.runas(userAsMgrObj){
             List<ProcessInstanceWorkitem> processInstanceWorkitemList = [SELECT Id FROM ProcessInstanceWorkitem 
                                                                           WHERE ProcessInstance.TargetObjectId =:opptyForOldAccountObj.Id /*OR 
                                                                           ProcessInstance.TargetObjectId =:opptyForNewAccountObj.Id*/];
             if(processInstanceWorkitemList.size() > 0)
             {
                 for(ProcessInstanceWorkitem processInstanceWorkitemObj : processInstanceWorkitemList){
                 	 Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
              		 request.setComments('Approving request for Opportunity');             
              		 request.setAction('Approve');
                     request.setWorkitemId(processInstanceWorkitemObj.Id); 
              	 	
                     Approval.ProcessResult result = Approval.process(request);
                 }
             }
         }
        
         
        
         system.runas(referredUser){     
             List<ProcessInstanceWorkitem> processInstanceWorkitemList = [SELECT Id FROM ProcessInstanceWorkitem 
                                                                          WHERE ProcessInstance.TargetObjectId =:opptyForNewAccountObj.Id];
             if(processInstanceWorkitemList.size() > 0)
             {
                 for(ProcessInstanceWorkitem processInstanceWorkitemObj : processInstanceWorkitemList){
                 	Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
              		request.setComments('Approving request for Opportunity');             
              		request.setAction('Approve');
                    request.setWorkitemId(processInstanceWorkitemObj.Id); 
                    Approval.ProcessResult result = Approval.process(request);
                 }
             }
         }
        
        
         system.runas(userAsMgrObj){
             List<ProcessInstanceWorkitem> processInstanceWorkitemList = [SELECT Id FROM ProcessInstanceWorkitem 
                                                                           WHERE ProcessInstance.TargetObjectId =:opptyForNewAccountObj.Id];
             if(processInstanceWorkitemList.size() > 0)
             {
                 for(ProcessInstanceWorkitem processInstanceWorkitemObj : processInstanceWorkitemList){
                 	 Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
              		 request.setComments('Approving request for Opportunity');             
              		 request.setAction('Approve');
                     request.setWorkitemId(processInstanceWorkitemObj.Id); 
              	 	
                     Approval.ProcessResult result = Approval.process(request);
                 }
             }
         }
        
         
        Test.stopTest();
        
    }
    
    @isTest
    public static void testCrossSellReferralOpptyUpdatesForClientRemediation() {
       	Account oldAccountObj, newAccountObj;
        
         //Fetch Accounts
         List<Account> accountList = [SELECT Id, RDM_Org_Id__c FROM Account WHERE RDM_Org_Id__c IN ('RG111','RG222')];
            
            if(accountList != null && accountList.size() > 0){
                for(Account accountObj : accountList){
                    if('RG111'.equalsIgnoreCase(accountObj.RDM_Org_Id__c)){
                        oldAccountObj = accountObj;
                    }
                    else if('RG222'.equalsIgnoreCase(accountObj.RDM_Org_Id__c)){
                        newAccountObj = accountObj;
                    }
                } 
         }
        
         User nomuraIntegrationUser = [SELECT Id, Name FROM User WHERE Login_Id__c = 'sfadmin' 
                                      AND Profile.Name = 'Nomura - Integration' LIMIT 1];
         
         system.runas(nomuraIntegrationUser){
            //Insert entry in Client_Remediation__c Obect
            Client_Remediation__c crObj = new Client_Remediation__c();
            
            crObj.OLD_RG__c = 'RG111';
            crObj.NEW_RG__c = 'RG222';
            crObj.RG_ACTION__c = 'MERGE';
            crObj.OLD_RG_Account__c = oldAccountObj.Id;
            crObj.NEW_RG_Account__c = newAccountObj.Id;
            
            insert crObj;
            
            //Execute the Job
            
        	Test.startTest();
             
            Database.executeBatch(new CrossSellReferralOpptyUpdatesForCRBatch('RG'), 1);
           
            Test.stopTest(); 
            
            //Test Results
            List<Opportunity> opptyListAfterUpdates = 
                [
                    SELECT Id, Name, StageName
                    FROM Opportunity
                    WHERE Account.RDM_Org_Id__c = 'RG222'
                ]; 
            
            System.assertEquals(2, opptyListAfterUpdates.size());
            
            Integer invalidatedCount = 0;
            if(opptyListAfterUpdates != null && opptyListAfterUpdates.size() > 0){
            	for(Opportunity oppty : opptyListAfterUpdates){
                    if('Invalidated'.equalsIgnoreCase(oppty.StageName)){
                        invalidatedCount = invalidatedCount + 1;
                    }
                }
                System.assert(invalidatedCount > 0);
            } 
        
         }     
	}
}