@isTest
public class CoverageRequestSharingTest {
    public static testMethod void testManualShareEdit(){
        
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
        userObj.UserRoleId = (userRoleObj != null ? userRoleObj.Id : null);
        userObj.ManagerId = userAsMgrObj.Id; 
        
        insert userObj;
        
            
        /* Insert Accounts */
        User nomuraIntegrationUser = [SELECT Id, Name FROM User WHERE Login_Id__c = 'sfadmin' 
                                      AND Profile.Name = 'Nomura - Integration'];
        
        System.runas(nomuraIntegrationUser){
            List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType WHERE Name IN ('RM Account', 'RG Account')];
            Id recordTypeIdForRM = null;
            Id recordTypeIdForRG = null;
            
            if(recordTypeList != null && recordTypeList.size() > 0){
                for(RecordType recordTypeObj : recordTypeList){
                    if('RM Account'.equalsIgnoreCase(recordTypeObj.Name)){
                        recordTypeIdForRM = recordTypeObj.Id; 
                    }
                    else if('RG Account'.equalsIgnoreCase(recordTypeObj.Name)){
                        recordTypeIdForRG = recordTypeObj.Id; 
                    }
                }
            }
            
            Account accountRG  = new Account(); 
            accountRG.Name = 'RG_Account_Dummy';
            accountRG.RDM_Org_ID__c = 'RGXXXXXX';            
            accountRG.RecordTypeId = recordTypeIdForRG;
            accountRG.Active__c = TRUE;  
            
            insert accountRG;
            
            Account accountRM1  = new Account();  
            accountRM1.Name = 'RM_Account_Dummy_1';
            accountRM1.RDM_Org_ID__c = 'RMXXXXXX';            
            accountRM1.RecordTypeId = recordTypeIdForRM;
            accountRM1.BillingStreet = '52nd Street' ;
            accountRM1.BillingCity = 'Los Angeles';
            accountRM1.BillingPostalCode = '90001';
            accountRM1.BillingCountry = 'United States';
            accountRM1.Active__c = TRUE;
            accountRM1.ParentId = accountRG.Id; 
            
            insert accountRM1;
            
            Account accountRM2  = new Account();  
            accountRM2.Name = 'RM_Account_Dummy_2';
            accountRM2.RDM_Org_ID__c = 'RMYYYYYY';            
            accountRM2.RecordTypeId = recordTypeIdForRM;
            accountRM2.BillingStreet = '52nd Street' ;
            accountRM2.BillingCity = 'Los Angeles';
            accountRM2.BillingPostalCode = '90001';
            accountRM2.BillingCountry = 'United States';
            accountRM2.Active__c = TRUE;
            accountRM2.ParentId = accountRG.Id; 
            
            insert accountRM2;
            
             /* Insert Sales_Team_for_Coverage__c */
            Sales_Team_for_Coverage__c salesTeamForCoverageObj = new Sales_Team_for_Coverage__c();
            salesTeamForCoverageObj.Coverage_ID__c = '1234XX';
            salesTeamForCoverageObj.Sales_Desk_Region__c = 'USA';
            salesTeamForCoverageObj.Sales_Desk_Division__c = 'Fixed Income';
            salesTeamForCoverageObj.Sales_Team__c = 'Test Team';
            salesTeamForCoverageObj.Name = 'TestTemp_FN TestTemp_LN';
            salesTeamForCoverageObj.Active__c = TRUE;
            salesTeamForCoverageObj.OwnerId = nomuraIntegrationUser.Id;
			salesTeamForCoverageObj.Is_Dummy__c = false;             
            insert salesTeamForCoverageObj;
            
            /* Insert Sales_Team_User__c */
    		Sales_Team_User__c salesTeamUserObj = new Sales_Team_User__c();
            salesTeamUserObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
            salesTeamUserObj.User__c = userObj.Id;
            salesTeamUserObj.Source_Id__c = salesTeamForCoverageObj.Id + '#' + userObj.Id;
            
            insert salesTeamUserObj;   
        }
        
        
        System.runas(nomuraIntegrationUser){
            
            List<Sales_Team_for_Coverage__c> salesTeamForCoverageObj = [SELECT Id, Coverage_Id__c FROM Sales_Team_for_Coverage__c
                                                                  WHERE Coverage_Id__c = '1234XX'];
            
            /* Insert Coverage_Access_Request__c */
            Account accountObj = [SELECT Id, RDM_Org_Id__c, Name FROM Account WHERE RDM_Org_Id__c = 'RMXXXXXX'];
            
            if(accountObj != null && salesTeamForCoverageObj != null){
                Coverage_Access_Request__c coverageAccessRequestObj = new Coverage_Access_Request__c();
                coverageAccessRequestObj.Account__c = accountObj.Id;
                coverageAccessRequestObj.Type__c = 'Standard';
                coverageAccessRequestObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj[0].Id;
                coverageAccessRequestObj.Type_of_Coverage__c = 'Add';
                coverageAccessRequestObj.Start_Date__c = Date.today();
                coverageAccessRequestObj.Role__c = 'Primary';
                coverageAccessRequestObj.Requested_for_User__c=userObj.Id;
                insert coverageAccessRequestObj;
                
                /* Check Whether Access is prsent for Manager or not*/
                List<Sales_Team_For_Coverage__Share> coverageAccessRequestShareList = 
                    [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Sales_Team_For_Coverage__Share
                     WHERE ParentId = :coverageAccessRequestObj.Id AND RowCause = 'Manual' AND AccessLevel = 'Edit'];
                
                if(coverageAccessRequestShareList != null && coverageAccessRequestShareList.size() > 0){
                    boolean recordForManagerPresent = FALSE;
                    for(Sales_Team_For_Coverage__Share covAccessRequestShare : coverageAccessRequestShareList){
                        if(covAccessRequestShare.UserOrGroupId == userAsMgrObj.Id){
                            recordForManagerPresent = TRUE;
                            break;
                        }
                    }
                    
                    System.assertEquals(TRUE, recordForManagerPresent);
                }
                
            }
            
            /* Insert RG_Coverage_Request__c */
            Account accountRGObj = [SELECT Id, RDM_Org_Id__c, Name FROM Account WHERE RDM_Org_Id__c = 'RGXXXXXX'];
            
            if(accountRGObj != null && salesTeamForCoverageObj != null){
                RG_Coverage_Request__c coverageRequestForRGObj = new RG_Coverage_Request__c();
                
                coverageRequestForRGObj.RG_Account__c = accountRGObj.Id;
                coverageRequestForRGObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj[0].Id;
                coverageRequestForRGObj.Type_of_Coverage__c = 'Add';
                coverageRequestForRGObj.Start_Date__c = Date.today();
                coverageRequestForRGObj.Role__c = 'Primary';
                coverageRequestForRGObj.Requested_for_User__c=userObj.Id;
                 Test.startTest();
       
                insert coverageRequestForRGObj;
                 Test.stopTest();
       
                /* Check Whether Access is prsent for Manager or not*/
                List<Sales_Team_For_Coverage__Share> coverageRequestForRGShareList = 
                    [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Sales_Team_For_Coverage__Share
                     WHERE ParentId = :coverageRequestForRGObj.Id AND RowCause = 'Manual' AND AccessLevel = 'Edit'];
                
                if(coverageRequestForRGShareList != null && coverageRequestForRGShareList.size() > 0){
                    boolean recordForManagerPresent = FALSE;
                    for(Sales_Team_For_Coverage__Share coverageRequestForRGShare : coverageRequestForRGShareList){
                        if(coverageRequestForRGShare.UserOrGroupId == userAsMgrObj.Id){
                            recordForManagerPresent = TRUE;
                            break;
                        }
                    }
                    
                    System.assertEquals(TRUE, recordForManagerPresent);
                }
            }
        }
        
      
    }
}