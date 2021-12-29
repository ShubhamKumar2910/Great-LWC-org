@isTest
public class RGCvgReqUpdatesCRTest {
    
    @testSetup
    static void setupTestData(){
        //Insert Accounts
        RecordType recordTypeRG = [SELECT Id FROM RecordType WHERE Name = 'RG Account' LIMIT 1];
        RecordType recordTypeRM = [SELECT Id FROM RecordType WHERE Name = 'RM Account' LIMIT 1];
        
        Account oldAccountObj = new Account();
        oldAccountObj.Name = 'Old_Account';
        oldAccountObj.RDM_Org_Id__c = 'RG1';
        oldAccountObj.RecordTypeId = recordTypeRG.Id;
        oldAccountObj.Active__c = TRUE;   
        
        insert oldAccountObj;
        
        Account newAccountObj = new Account();
        newAccountObj.Name = 'New_Account';
        newAccountObj.RDM_Org_Id__c = 'RG2';
        newAccountObj.RecordTypeId = recordTypeRG.Id;
        newAccountObj.Active__c = TRUE;   
        
        insert newAccountObj;
        
        Account oldAccountRMObj  = new Account(); 
        oldAccountRMObj.Name = 'Old_Account_RM';
        oldAccountRMObj.RDM_Org_ID__c = 'RM1';            
        oldAccountRMObj.RecordTypeId = recordTypeRM.Id;
        oldAccountRMObj.BillingCity = 'California';
        oldAccountRMObj.BillingCountry = 'United States';
        oldAccountRMObj.BillingStreet = '52nd Street';
        oldAccountRMObj.ParentId = oldAccountObj.Id;
        oldAccountRMObj.Active__c = TRUE;    
        
        insert oldAccountRMObj; 
        
        Account newAccountRMObj  = new Account(); 
        newAccountRMObj.Name = 'New_Account_RM';
        newAccountRMObj.RDM_Org_ID__c = 'RM2';            
        newAccountRMObj.RecordTypeId = recordTypeRM.Id;
        newAccountRMObj.BillingCity = 'California';
        newAccountRMObj.BillingCountry = 'United States';
        newAccountRMObj.BillingStreet = '52nd Street';
        newAccountRMObj.ParentId = newAccountObj.Id;
        newAccountRMObj.Active__c = TRUE;    
        
        insert newAccountRMObj; 
       
    }
    
    static testMethod void testRGCvgReqUpdatesForClientRemediation() {
        
        //Fetch Accounts
            Account oldAccountObj = null;
            Account newAccountObj = null;
            List<Account> accountList = [SELECT Id, Name, RDM_Org_Id__c FROM Account 
                                         WHERE RDM_Org_Id__c IN ('RG1','RG2')];
            if(accountList != null && accountList.size() > 0){
                for(Account accountObj : accountList){
                    if('RG1'.equalsIgnoreCase(accountObj.RDM_Org_Id__c)){
                        oldAccountObj = accountObj;
                    }
                    else if('RG2'.equalsIgnoreCase(accountObj.RDM_Org_Id__c)){
                        newAccountObj = accountObj;
                    }
                }
            }
            
            
        
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
        userObj.ManagerId = userAsMgrObj.Id; 
        
        insert userObj;
        
        system.runas(userObj){
       
            //Create Sales Code
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
            
            //Insert Coverage Request
            if(oldAccountObj != null && newAccountObj != null){
                List<RG_Coverage_Request__c> coverageRequestForRGList = new List<RG_Coverage_Request__c>();
                
                RG_Coverage_Request__c coverageRequestForOldRGObj = new RG_Coverage_Request__c();
                    
                coverageRequestForOldRGObj.RG_Account__c = oldAccountObj.Id;
                coverageRequestForOldRGObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
                coverageRequestForOldRGObj.Type_of_Coverage__c = 'Add';
                coverageRequestForOldRGObj.Start_Date__c = Date.today();
                coverageRequestForOldRGObj.Role__c = 'Primary';
                //added for test class fix for failure JIRA SALES - 3082
                coverageRequestForOldRGObj.SourceUpload__c = 'Tool';
                
                coverageRequestForRGList.add(coverageRequestForOldRGObj);
                
                insert coverageRequestForRGList;
                
                
            }
                     
        }

        //Fetch 'sfadmin' User
        User sfadminUserObj  = [SELECT Id, Login_ID__c FROM User WHERE IsActive = TRUE AND Login_ID__c = 'sfadmin'];

        System.runas(sfadminUserObj){
                //Execute the Job
                Test.startTest();
                
                //Insert entry in Client_Remediation__c Obect
                Client_Remediation__c crObj = new Client_Remediation__c();
                
                crObj.OLD_RG__c = 'RG1';
                crObj.NEW_RG__c = 'RG2';
                crObj.RG_ACTION__c = 'MERGE';
                crObj.OLD_RG_Account__c = oldAccountObj.Id;
                crObj.NEW_RG_Account__c = newAccountObj.Id;
                
                insert crObj;
                
                //Update Old Account as Inactive
                oldAccountObj.Closing_Date__c = 'Fri May 18 00:00:00 EDT 2018';
                oldAccountObj.Active__c = FALSE;
                
                update  oldAccountObj;
                
                Database.executeBatch(new RGCvgReqUpdatesForClientRemediationBatch(), 1);
               
                Test.stopTest(); 
                
                //Test Results
                List<RG_Coverage_Request__c> cvgReqForRGListAfterUpdates = 
                    [
                        SELECT Id, Name
                        FROM RG_Coverage_Request__c
                        WHERE RG_Account__r.RDM_Org_Id__c = 'RG1' AND Status__c = 'Recalled'
                    ]; 
            
                System.assertEquals(1, cvgReqForRGListAfterUpdates.size()); 
        }

        
            
	}

}