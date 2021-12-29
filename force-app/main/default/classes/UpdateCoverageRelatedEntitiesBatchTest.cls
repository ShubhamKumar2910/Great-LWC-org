@isTest
public class UpdateCoverageRelatedEntitiesBatchTest {
    
    @testSetUp
    public static void testSetupForUpdateCoverageRelatedEntitiesBatch(){
    	Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        
        /* Insert Users*/
        List<User> userList = new List<User>();
        User userObj1 = new User();
        userObj1.Login_ID__c = 'testdum1';
        userObj1.Alias = 'testdum1';
        userObj1.LastName = 'TestDummy1LN';
        userObj1.Email = 'TestDummy1@testOrg.com';
        userObj1.UserName = 'TestDummy1@testOrg.com';
        userObj1.ProfileId = profileNomuraSales.Id;
        userObj1.EmailEncodingKey = 'UTF-8';
        userObj1.LanguageLocaleKey = 'en_US';
        userObj1.LocaleSidKey = 'en_US';
        userObj1.TimeZoneSidKey = 'America/Los_Angeles';
        userObj1.Region__c = 'Americas';
        userObj1.IsActive = TRUE;
        
        userList.add(userObj1);
        
        User userObj2 = new User();
        userObj2.Login_ID__c = 'testdum2';
        userObj2.Alias = 'testdum2';
        userObj2.LastName = 'TestDummy2LN';
        userObj2.Email = 'TestDummy2@testOrg.com';
        userObj2.UserName = 'TestDummy2@testOrg.com';
        userObj2.ProfileId = profileNomuraSales.Id;
        userObj2.EmailEncodingKey = 'UTF-8';
        userObj2.LanguageLocaleKey = 'en_US';
        userObj2.LocaleSidKey = 'en_US';
        userObj2.TimeZoneSidKey = 'America/Los_Angeles';
        userObj2.Region__c = 'Americas';
        userObj2.IsActive = TRUE;
        
        userList.add(userObj2);
        
        insert userList;
        
        //Fetching Users
        List<User> insertedUserList = [SELECT Id, Login_Id__c, isActive FROM User WHERE Login_Id__c IN ('testdum1','testdum2')];
        
        /* Insert Accounts */
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
        
        /* Insert Sales_Team_for_Coverage__c */
        Sales_Team_for_Coverage__c salesTeamForCoverageObj = new Sales_Team_for_Coverage__c();
        salesTeamForCoverageObj.Coverage_ID__c = '1234XX';
        salesTeamForCoverageObj.Name = 'TestDummy1/TestDummy2';
        salesTeamForCoverageObj.Sales_Team__c = 'Test Team';
        salesTeamForCoverageObj.Sales_Desk_Region__c = 'USA';
        salesTeamForCoverageObj.Sales_Desk_Division__c = 'Fixed Income';
        salesTeamForCoverageObj.Sales_Code_Login_ID__c = 'dummy';
        salesTeamForCoverageObj.Is_Split_Sales_Code__c = TRUE;
        salesTeamForCoverageObj.Active__c = TRUE;
        
        insert salesTeamForCoverageObj;
            
        /* Insert Sales_Team_User__c for User 1*/
        User userObj = null;
        if(insertedUserList != null && insertedUserList.size() > 0){
            for(User insertedUserObj : insertedUserList){
                if('testdum1'.equalsIgnoreCase(insertedUserObj.Login_Id__c)){
                    userObj = insertedUserObj;
                    break;
                }
            }
        }
        if(userObj != null){
            Sales_Team_User__c salesTeamUserObj = new Sales_Team_User__c();
            salesTeamUserObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
            salesTeamUserObj.User__c = userObj.Id;
            salesTeamUserObj.Source_Id__c = salesTeamForCoverageObj.Coverage_ID__c + '#' + userObj.Login_Id__c;
            
            insert salesTeamUserObj;
        }
        
        /* Insert Revenue_KPI__c */
        Revenue_KPI__c revenueKPIObj = TestRevenueKPIDataFactory.createKPI(accountRG, userObj);
        
        /* Insert Revenue_Rollup__c */
        Revenue_Rollup__c revRollup = new Revenue_Rollup__c();
        revRollup.region__c = 'MSP';
        revRollup.RM__c = accountRM.Id;
        
        insert revRollup;
        
        /* Insert Coverage_Team_Member__c */
        Coverage_Team_Member__c coverageTeamMemberObj = new Coverage_Team_Member__c(); 
        coverageTeamMemberObj.Account__c = accountRM.Id;
        coverageTeamMemberObj.Team_Member__c = userObj.Id; 
        coverageTeamMemberObj.Team_Role__c = 'Primary';
        coverageTeamMemberObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
        coverageTeamMemberObj.Start_Date__c = Date.today();          
        
        insert coverageTeamMemberObj;
        
    }
    
    @isTest
    public static void testBatch(){
    	Integer numTestUsers = 1;  
        List<User> users = UtilityTesting.CreateUsersWithManager(numTestUsers);
        
        System.runas(users[0]){
            //Insert the Sales_Team_User__c for User 2
            User userObj;
            List<User> userList = [SELECT Id, Login_Id__c, IsActive FROM User WHERE Login_Id__c = 'testdum2' LIMIT 1];
            
            List<Sales_Team_for_Coverage__c> salesCodeList = [SELECT Id, Coverage_ID__c, Is_Split_Sales_Code__c
                                                              FROM Sales_Team_for_Coverage__c
                                                              WHERE Coverage_ID__c = '1234XX'];
            
            if(userList != null && userList.size() == 1 &&
               salesCodeList != null && salesCodeList.size() > 0){
                
                userObj = userList.get(0); 
                   
				Sales_Team_User__c salesTeamUserObj = new Sales_Team_User__c();
                salesTeamUserObj.Sales_Team_for_Coverage__c = salesCodeList.get(0).Id;
                salesTeamUserObj.User__c = userObj.Id;
                salesTeamUserObj.Source_Id__c = salesCodeList.get(0).Coverage_ID__c + '#' + userObj.Login_Id__c;
                
                insert salesTeamUserObj;                   
                   
            }
            
            //Fetch Account Details
            Account accountRG, accountRM;
            List<Account> accountList = [SELECT Id, RDM_Org_Id__c, Name FROM Account WHERE RDM_Org_Id__c IN ('RGXXXXXX','RMXXXXXX')];
            if(accountList != null && accountList.size() > 0){
                for(Account acctObj : accountList){
                    if('RGXXXXXX'.equalsIgnoreCase(acctObj.RDM_Org_Id__c)){
                        accountRG = acctObj;
                    }
                    else if('RMXXXXXX'.equalsIgnoreCase(acctObj.RDM_Org_Id__c)){
                        accountRM = acctObj;
                    }
                }
            }
            
            
            //Execute the Job
            Test.startTest();
        	
            Set<Id> salesTeamForCoverageIdSet = new set<Id>();
            salesTeamForCoverageIdSet.add(salesCodeList.get(0).Id);
            Database.executeBatch(new UpdateCoverageRelatedEntitiesBatch(salesTeamForCoverageIdSet), 10);
           
            Test.stopTest();  
            
            //Test Results
            if(userObj != null && accountRG != null && accountRM != null){
                //AccountTeamMember
                List<AccountTeamMember> accountTeamMemberList = [SELECT Id, AccountId, UserId FROM AccountTeamMember
                                                                 WHERE UserId = :userObj.Id AND AccountId = :accountRM.Id];
                if(accountTeamMemberList != null && accountTeamMemberList.size() > 0){
                	System.debug('******accountTeamMemberList.size():'+accountTeamMemberList.size());
                    System.assertEquals(1, accountTeamMemberList.size());    
                }
                
                //AccountShare
                List<AccountShare> accountShareList = [SELECT Id, AccountId, UserOrGroupId FROM AccountShare
                                                       WHERE UserOrGroupId = :userObj.Id AND AccountId = :accountRM.Id];
                if(accountShareList != null && accountShareList.size() > 0){
                	System.debug('******accountShareList.size():'+accountShareList.size());
                    System.assertEquals(1, accountShareList.size());    
                }
                
                //Revenue_Rollup__Share
                Map<Id,Revenue_Rollup__c> revenueRollupMap = new Map<Id,Revenue_Rollup__c>(
                    [SELECT Id, RM__c FROM Revenue_Rollup__c 
                     WHERE RM__c = :accountRM.Id]);
                if(revenueRollupMap != null && revenueRollupMap.size() > 0){
                    List<Revenue_Rollup__Share> revRollupShareList = 
                        	[SELECT Id, ParentId, UserOrGroupId FROM Revenue_Rollup__Share
                             WHERE UserOrGroupId = :userObj.Id AND ParentId IN :revenueRollupMap.keySet()];
                    
                    if(revRollupShareList != null && revRollupShareList.size() > 0){
                		System.debug('******revRollupShareList.size():'+revRollupShareList.size());
                        System.assertEquals(1, revRollupShareList.size());    
                	}
                }
                
                //Revenue_KPI__Share
                Map<Id,Revenue_KPI__c> revenueKPIMap = new Map<Id,Revenue_KPI__c>(
                    [SELECT Id, RG__c FROM Revenue_KPI__c 
                     WHERE RG__c = :accountRG.Id]);
                if(revenueKPIMap != null && revenueKPIMap.size() > 0){
                    List<Revenue_KPI__Share> revKPIShareList = 
                        	[SELECT Id, ParentId, UserOrGroupId FROM Revenue_KPI__Share
                             WHERE UserOrGroupId = :userObj.Id AND ParentId IN :revenueKPIMap.keySet()];
                    
                    if(revKPIShareList != null && revKPIShareList.size() > 0){
                		System.debug('******revKPIShareList.size():'+revKPIShareList.size());
                        System.assertEquals(1, revKPIShareList.size());    
                	}
                }
                
                // Process_Coverage_Related_Entities__c field should be FALSE after successful job execution
                List<Sales_Team_for_Coverage__c> salesTeamForCoverageList = 
                    [SELECT Id, Coverage_ID__c, Is_Split_Sales_Code__c, Process_Coverage_Related_Entities__c
                     FROM Sales_Team_for_Coverage__c WHERE Coverage_ID__c = '1234XX'];
                
                if(salesTeamForCoverageList != null && salesTeamForCoverageList.size() == 1){
                    System.assertEquals(FALSE, salesTeamForCoverageList.get(0).Process_Coverage_Related_Entities__c);
                }
                
            }
        }    
    }
}