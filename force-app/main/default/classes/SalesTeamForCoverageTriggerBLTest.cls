@isTest
public class SalesTeamForCoverageTriggerBLTest {
	static testMethod void testProcessBatchForSplitSalesCodes() {
    	Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        
        /* Insert User Records*/
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
        
        Integer numTestUsers = 1;  
        List<User> users = UtilityTesting.CreateUsersWithManager(numTestUsers); 
        
        System.runAs(users[0]){
            Test.startTest();
            
            //Fetch Users
        	List<User> insertedUserList = [SELECT Id, Name, Login_Id__c, IsActive FROM User 
                                       	   WHERE Login_Id__c IN ('testdum1','testdum2') ] ;
         
        	//(2, insertedUserList.size());
            
            /* Insert Sales_Team_for_Coverage__c */
            Sales_Team_for_Coverage__c salesTeamForCoverageObj = new Sales_Team_for_Coverage__c();
            salesTeamForCoverageObj.Coverage_ID__c = '1234XX';
            salesTeamForCoverageObj.Name = 'TestDummy1LN/TestDummy2LN';
            salesTeamForCoverageObj.Sales_Team__c = 'Test Team';
            salesTeamForCoverageObj.Sales_Desk_Region__c = 'USA';
            salesTeamForCoverageObj.Sales_Desk_Division__c = 'Fixed Income';
            salesTeamForCoverageObj.Sales_Code_Login_ID__c = 'dummy';
            salesTeamForCoverageObj.Is_Split_Sales_Code__c = TRUE;
            salesTeamForCoverageObj.Active__c = TRUE;
            salesTeamForCoverageObj.Process_Coverage_Related_Entities__c = FALSE;
             
            insert salesTeamForCoverageObj;
            
            /* Update Sales_Team_for_Coverage__c */
            salesTeamForCoverageObj.Process_Coverage_Related_Entities__c = TRUE;
            
            update salesTeamForCoverageObj;
            
            
			Test.stopTest();
            
            //Check the results
            // Process_Coverage_Related_Entities__c field should be FALSE after successful job execution
            List<Sales_Team_for_Coverage__c> salesTeamForCoverageList = 
                [SELECT Id, Coverage_ID__c, Is_Split_Sales_Code__c, Process_Coverage_Related_Entities__c
                 FROM Sales_Team_for_Coverage__c WHERE Coverage_ID__c = '1234XX'];
            if(salesTeamForCoverageList != null && salesTeamForCoverageList.size() == 1){
               // System.assertEquals(FALSE, salesTeamForCoverageList.get(0).Process_Coverage_Related_Entities__c);
            }
            
        }
    }
    
    static testMethod void testChangeOwner() {
    	Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        
        /* Insert User Records*/
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
        
        User integrationUserObj = [SELECT Id, Login_Id__c, Alias, LastName, Email, UserName, ProfileId 
                        FROM User WHERE Login_Id__c = 'sfadmin' LIMIT 1];
        
        System.runAs(integrationUserObj){
            Test.startTest();
            
            /* Insert Sales_Team_for_Coverage__c */
            Sales_Team_for_Coverage__c salesTeamForCoverageObj = new Sales_Team_for_Coverage__c();
            salesTeamForCoverageObj.Coverage_ID__c = '1234XX';
            salesTeamForCoverageObj.Name = 'TestDummy1LN';
            salesTeamForCoverageObj.Sales_Team__c = 'Test Team';
            salesTeamForCoverageObj.Sales_Desk_Region__c = 'USA';
            salesTeamForCoverageObj.Sales_Desk_Division__c = 'Fixed Income';
            salesTeamForCoverageObj.Sales_Code_Login_ID__c = 'testdum1';
            salesTeamForCoverageObj.Is_Split_Sales_Code__c = FALSE;
            salesTeamForCoverageObj.Active__c = TRUE;
            salesTeamForCoverageObj.Process_Coverage_Related_Entities__c = FALSE;
             
            insert salesTeamForCoverageObj;
            
            //Check the owner of inserted Sales Team For Coverage Object
            Sales_Team_for_Coverage__c insertedSalesCodeObj = [ SELECT Id, Coverage_Id__c, OwnerId 
                                                               FROM Sales_Team_for_Coverage__c 
                                                               WHERE Coverage_ID__c = '1234XX' LIMIT 1];
            if(insertedSalesCodeObj != null){
               // System.assertEquals(userObj.Id, insertedSalesCodeObj.OwnerId);
            }
            
            /* Update Sales_Team_for_Coverage__c */
            salesTeamForCoverageObj.Sales_Team__c = 'Test Team Changed';
            
            update salesTeamForCoverageObj;
            
            //Check the owner of updated Sales Team For Coverage Object
            Sales_Team_for_Coverage__c updatedSalesCodeObj = [ SELECT Id, Coverage_Id__c, OwnerId 
                                                               FROM Sales_Team_for_Coverage__c 
                                                               WHERE Coverage_ID__c = '1234XX' LIMIT 1];
            if(insertedSalesCodeObj != null){
                //System.assertEquals(userObj.Id, updatedSalesCodeObj.OwnerId);
            }
            
            
			Test.stopTest();
            
        }
    }
    
    static testMethod void testChangeOwnerForJointSalesCode() {
    	Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        
        /* Insert User Records*/
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
        
        insert userObj1;
        
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
        
        insert userObj2;
        
        User integrationUserObj = [SELECT Id, Login_Id__c, Alias, LastName, Email, UserName, ProfileId 
                        FROM User WHERE Login_Id__c = 'sfadmin' LIMIT 1];
        
        System.runAs(integrationUserObj){
            Test.startTest();
            
            /* Insert Sales_Team_for_Coverage__c */
            Sales_Team_for_Coverage__c salesTeamForCoverageObj = new Sales_Team_for_Coverage__c();
            salesTeamForCoverageObj.Coverage_ID__c = '1234XX';
            salesTeamForCoverageObj.Name = 'TestDummy1LN/TestDummy2LN';
            salesTeamForCoverageObj.Sales_Team__c = 'Test Team';
            salesTeamForCoverageObj.Sales_Desk_Region__c = 'USA';
            salesTeamForCoverageObj.Sales_Desk_Division__c = 'Fixed Income';
            salesTeamForCoverageObj.Sales_Code_Login_ID__c = 'testdumx';
            salesTeamForCoverageObj.Is_Split_Sales_Code__c = TRUE;
            salesTeamForCoverageObj.Active__c = TRUE;
            salesTeamForCoverageObj.Process_Coverage_Related_Entities__c = FALSE;
             
            insert salesTeamForCoverageObj;
            
            //Check the owner of inserted Sales Team For Coverage Object
            Sales_Team_for_Coverage__c insertedSalesCodeObj = [ SELECT Id, Coverage_Id__c, OwnerId 
                                                               FROM Sales_Team_for_Coverage__c 
                                                               WHERE Coverage_ID__c = '1234XX' LIMIT 1];
            if(insertedSalesCodeObj != null){
                //System.assertEquals(integrationUserObj.Id, insertedSalesCodeObj.OwnerId);
            }
            
            /* Insert Sales_Team_User__c */
            List<Sales_Team_User__c> salesTeamUserList = new List<Sales_Team_User__c>();
            Sales_Team_User__c salesTeamUserObj1 = new Sales_Team_User__c();
            salesTeamUserObj1.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
            salesTeamUserObj1.User__c = userObj1.Id;
            salesTeamUserObj1.Source_Id__c = salesTeamForCoverageObj.Coverage_ID__c + '#' + userObj1.Login_ID__c;
            salesTeamUserList.add(salesTeamUserObj1);
            
            Sales_Team_User__c salesTeamUserObj2 = new Sales_Team_User__c();
            salesTeamUserObj2.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
            salesTeamUserObj2.User__c = userObj2.Id;
            salesTeamUserObj2.Source_Id__c = salesTeamForCoverageObj.Coverage_ID__c + '#' + userObj2.Login_ID__c;
            salesTeamUserList.add(salesTeamUserObj2);
            
            insert salesTeamUserList;
            
            /* Update Sales_Team_for_Coverage__c */
            salesTeamForCoverageObj.Sales_Team__c = 'Test Team Changed';
            
            update salesTeamForCoverageObj;
            
            //Check the owner of updated Sales Team For Coverage Object
            Sales_Team_for_Coverage__c updatedSalesCodeObj = [ SELECT Id, Coverage_Id__c, OwnerId 
                                                               FROM Sales_Team_for_Coverage__c 
                                                               WHERE Coverage_ID__c = '1234XX' LIMIT 1];
            if(insertedSalesCodeObj != null){
               // System.assertEquals(userObj1.Id, updatedSalesCodeObj.OwnerId); //Picks the first owner
            }
            
            Test.stopTest();
            
        }
    }
    
    static testMethod void testCreateSharing() {
    	Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        
        /* Insert User Records*/
        
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
        userAsMgrObj.IsActive = TRUE;
        
        insert userAsMgrObj;
        
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
        userObj.ManagerId = userAsMgrObj.Id; 
        
        insert userObj;
        
        User integrationUserObj = [SELECT Id, Login_Id__c, Alias, LastName, Email, UserName, ProfileId 
                        FROM User WHERE Login_Id__c = 'sfadmin' LIMIT 1];
        
        System.runAs(integrationUserObj){
            Test.startTest();
            
            /* Insert Sales_Team_for_Coverage__c */
            Sales_Team_for_Coverage__c salesTeamForCoverageObj = new Sales_Team_for_Coverage__c();
            salesTeamForCoverageObj.Coverage_ID__c = '1234XX';
            salesTeamForCoverageObj.Name = 'TestDummy1LN/TestDummy2LN';
            salesTeamForCoverageObj.Sales_Team__c = 'Test Team';
            salesTeamForCoverageObj.Sales_Desk_Region__c = 'USA';
            salesTeamForCoverageObj.Sales_Desk_Division__c = 'Fixed Income';
            salesTeamForCoverageObj.Sales_Code_Login_ID__c = 'testdum1';
            salesTeamForCoverageObj.Is_Split_Sales_Code__c = FALSE;
            salesTeamForCoverageObj.Active__c = TRUE;
            salesTeamForCoverageObj.Process_Coverage_Related_Entities__c = FALSE;
             
            insert salesTeamForCoverageObj;
            
            /* Update Sales_Team_for_Coverage__c */
            salesTeamForCoverageObj.Sales_Team__c = 'Test Team Changed';
            
            update salesTeamForCoverageObj;
            
            /* Check Whether Access is present for Manager or not*/
            Sales_Team_for_Coverage__c salesCodeObj = [ SELECT Id, Coverage_Id__c
                                                               FROM Sales_Team_for_Coverage__c 
                                                               WHERE Coverage_ID__c = '1234XX' LIMIT 1];
            
            if(salesCodeObj != null){
                List<Sales_Team_For_Coverage__Share> salesTeamForCoverageShareList = 
                    [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Sales_Team_For_Coverage__Share
                     WHERE ParentId = :salesCodeObj.Id AND RowCause = 'Manual' AND AccessLevel = 'Edit'];
                
                if(salesTeamForCoverageShareList != null && salesTeamForCoverageShareList.size() > 0){
                    boolean recordForManagerPresent = FALSE;
                    for(Sales_Team_For_Coverage__Share salesTeamForCoverageShare : salesTeamForCoverageShareList){
                        if(salesTeamForCoverageShare.UserOrGroupId == userAsMgrObj.Id){
                            recordForManagerPresent = TRUE;
                            break;
                        }
                    }
                    
                    //System.assertEquals(TRUE, recordForManagerPresent);
                }
            }
            
           Test.stopTest();
            
        }
    }
    
    
    static testMethod void testCreateSharingForJointSalesCode() {
    	/* Insert User Records*/
        List<User> userList = UtilityTesting.CreateUsersWithManager(2);
        
        
        User integrationUserObj = [SELECT Id, Login_Id__c, Alias, LastName, Email, UserName, ProfileId 
                        		   FROM User WHERE Login_Id__c = 'sfadmin' LIMIT 1];
        
        System.runAs(integrationUserObj){
            Test.startTest();
            
            /* Insert Sales_Team_for_Coverage__c */
            Sales_Team_for_Coverage__c salesTeamForCoverageObj = new Sales_Team_for_Coverage__c();
            salesTeamForCoverageObj.Coverage_ID__c = '1234XX';
            salesTeamForCoverageObj.Name = 'Test Dummy Joint';
            salesTeamForCoverageObj.Sales_Team__c = 'Test Team';
            salesTeamForCoverageObj.Sales_Desk_Region__c = 'USA';
            salesTeamForCoverageObj.Sales_Desk_Division__c = 'Fixed Income';
            salesTeamForCoverageObj.Sales_Code_Login_ID__c = 'testdumx';
            salesTeamForCoverageObj.Is_Split_Sales_Code__c = TRUE;
            salesTeamForCoverageObj.Active__c = TRUE;
            salesTeamForCoverageObj.Process_Coverage_Related_Entities__c = FALSE;
             
            insert salesTeamForCoverageObj;
            
            /* Insert Sales_Team_User__c */
            if(userList != null && userList.size() == 2){
                List<Sales_Team_User__c> salesTeamUserList = new List<Sales_Team_User__c>();
                Sales_Team_User__c salesTeamUserObj1 = new Sales_Team_User__c();
                salesTeamUserObj1.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
                salesTeamUserObj1.User__c = userList.get(0).Id;
                salesTeamUserObj1.Source_Id__c = salesTeamForCoverageObj.Coverage_ID__c + '#' + userList.get(0).Login_ID__c;
                salesTeamUserList.add(salesTeamUserObj1);
                
                Sales_Team_User__c salesTeamUserObj2 = new Sales_Team_User__c();
                salesTeamUserObj2.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
                salesTeamUserObj2.User__c = userList.get(1).Id;
                salesTeamUserObj2.Source_Id__c = salesTeamForCoverageObj.Coverage_ID__c + '#' + userList.get(1).Login_ID__c;
                salesTeamUserList.add(salesTeamUserObj2);
                
                insert salesTeamUserList;
            }

            
            /* Update Sales_Team_for_Coverage__c */
            salesTeamForCoverageObj.Sales_Team__c = 'Test Team Changed';
            
            update salesTeamForCoverageObj;
            
            /* Check Whether Access is present for Manager or not. Check whether Access is present for other members of Joint Sales Code*/
            Sales_Team_for_Coverage__c salesCodeObj = [ SELECT Id, Coverage_Id__c
                                                         FROM Sales_Team_for_Coverage__c 
                                                         WHERE Coverage_ID__c = '1234XX' LIMIT 1];
            
            if(salesCodeObj != null){
                List<Sales_Team_For_Coverage__Share> salesTeamForCoverageShareList = 
                    [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Sales_Team_For_Coverage__Share
                     WHERE ParentId = :salesCodeObj.Id AND RowCause = 'Manual' AND AccessLevel = 'Edit'];
                
                if(salesTeamForCoverageShareList != null && salesTeamForCoverageShareList.size() > 0){
                    Integer sharingRecordCountWithMgr = 0;
                    Integer sharingRecordCountWithOtherUser = 0;
                    
                    for(Sales_Team_For_Coverage__Share salesTeamForCoverageShare : salesTeamForCoverageShareList){
                        for(User userObj : userList){
                            if(String.isNotEmpty(userObj.ManagerId) && String.valueOf(userObj.ManagerId).equalsIgnoreCase(String.valueOf(salesTeamForCoverageShare.UserOrGroupId))){
                                sharingRecordCountWithMgr = sharingRecordCountWithMgr + 1;
                            }
                            if(String.valueOf(userObj.Id).equalsIgnoreCase(String.valueOf(salesTeamForCoverageShare.UserOrGroupId))){
                               sharingRecordCountWithOtherUser = sharingRecordCountWithOtherUser + 1; 
                            }
                        }
                    }
                    
                   // System.assertEquals(2, sharingRecordCountWithMgr);
                   // System.assertEquals(1, sharingRecordCountWithOtherUser);
                }
            }
            
           Test.stopTest();
            
        }
    }
}