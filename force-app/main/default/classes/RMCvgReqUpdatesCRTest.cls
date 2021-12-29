@isTest
public class RMCvgReqUpdatesCRTest {
    
    @testSetup
    static void setupTestData(){
        //Insert Restricted Country
        Restricted_Countries__c rCountry = new Restricted_Countries__c();
        rCountry.Name = 'Japan';
        rCountry.Restricted_Country_Name__c = 'Japan';
        rCountry.Country_Code__c = 'Japan-JP';
        insert rCountry;


        //Insert Accounts
        RecordType recordTypeRM = [SELECT Id FROM RecordType WHERE Name = 'RM Account' LIMIT 1];
        
        
        Account oldAccountObj  = new Account(); 
        oldAccountObj.Name = 'Old_Account_RM';
        oldAccountObj.RDM_Org_ID__c = 'RM1';            
        oldAccountObj.RecordTypeId = recordTypeRM.Id;
        oldAccountObj.BillingCity = 'Tokyo';
        oldAccountObj.BillingCountry = 'Japan';
        oldAccountObj.BillingStreet = '52nd Street';
        oldAccountObj.Active__c = TRUE; 
        oldAccountObj.Domicile_Country__c = 'JP';  
        
        insert oldAccountObj; 
        
        Account newAccountObj  = new Account(); 
        newAccountObj.Name = 'New_Account_RM';
        newAccountObj.RDM_Org_ID__c = 'RM2';            
        newAccountObj.RecordTypeId = recordTypeRM.Id;
        newAccountObj.BillingCity = 'Tokyo';
        newAccountObj.BillingCountry = 'Japan';
        newAccountObj.BillingStreet = '52nd Street';
        newAccountObj.Active__c = TRUE;  
        newAccountObj.Domicile_Country__c = 'JP';  
        
        insert newAccountObj; 
       
    }
    
    static testMethod void testRMCvgReqUpdatesForClientRemediation() {
        
        //Fetch Accounts
        Account oldAccountObj = null;
        Account newAccountObj = null;
        List<Account> accountList = [SELECT Id, Name, RDM_Org_Id__c FROM Account 
                                        WHERE RDM_Org_Id__c IN ('RM1','RM2')];
        if(accountList != null && accountList.size() > 0){
            for(Account accountObj : accountList){
                if('RM1'.equalsIgnoreCase(accountObj.RDM_Org_Id__c)){
                    oldAccountObj = accountObj;
                }
                else if('RM2'.equalsIgnoreCase(accountObj.RDM_Org_Id__c)){
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
            List<Coverage_Access_Request__c> coverageRequestForRMList = new List<Coverage_Access_Request__c>();
                
            Coverage_Access_Request__c coverageRequestForOldRMObj = new Coverage_Access_Request__c();
                
            coverageRequestForOldRMObj.Account__c = oldAccountObj.Id;
            coverageRequestForOldRMObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
            coverageRequestForOldRMObj.Type_of_Coverage__c = 'Add';
            coverageRequestForOldRMObj.Start_Date__c = Date.today();
            coverageRequestForOldRMObj.Role__c = 'Primary';
            coverageRequestForOldRMObj.Requested_for_User__c = userObj.Id;
            
            coverageRequestForRMList.add(coverageRequestForOldRMObj);
            
            insert coverageRequestForRMList;
        }

        //Fetch 'sfadmin' User
        User sfadminUserObj  = [SELECT Id, Login_ID__c FROM User WHERE IsActive = TRUE AND Login_ID__c = 'sfadmin'];

        System.runas(sfadminUserObj){
             //Insert entry in Client_Remediation__c Obect
            Client_Remediation__c crObj = new Client_Remediation__c();
            
            crObj.OLD_RM__c = 'RM1';
            crObj.NEW_RM__c = 'RM2';
            crObj.RM_ACTION__c = 'MERGE';
            crObj.OLD_RM_Account__c = oldAccountObj.Id;
            crObj.NEW_RM_Account__c = newAccountObj.Id;
            
            insert crObj;

            //Update Old Account as Inactive
            oldAccountObj.Closing_Date__c = 'Fri May 18 00:00:00 EDT 2018';
            oldAccountObj.Active__c = FALSE;
            
            update  oldAccountObj;
            
            //Execute the Job
            Test.startTest();
        
            Database.executeBatch(new RMCvgReqUpdatesForClientRemediationBatch(), 1);
            
            Test.stopTest();  
            
            //Test Results
            List<Coverage_Access_Request__c> cvgReqForRMListAfterUpdates = 
                [
                    SELECT Id, Name, Account__r.Restricted_Flag__c, Status__c
                    FROM Coverage_Access_Request__c
                    WHERE Account__r.RDM_Org_Id__c = 'RM1' AND Status__c = 'Recalled'
                ]; 

            System.assertEquals(1, cvgReqForRMListAfterUpdates.size());
        }
    }

}