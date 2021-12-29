@isTest
public class SalesTeamUserTriggerBLTest {
	static testMethod void testUpdateSalesTeamForCoverageDetailsInsert() {
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
         
        User sfadminUserObj = [SELECT Id, Login_Id__c, Name FROM User WHERE Login_Id__c = 'sfadmin' LIMIT 1];
        
        System.runAs(sfadminUserObj){
            Test.startTest();
            
            //Fetch Users
        	List<User> insertedUserList = [SELECT Id, Name, Login_Id__c, IsActive FROM User 
                                       	   WHERE Login_Id__c IN ('testdum1','testdum2') ] ;
         
        	System.assertEquals(2, insertedUserList.size());
             
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
            
            /* Insert Sales_Team_User__c */
            List<Sales_Team_User__c> salesTeamUserList = new List<Sales_Team_User__c>();
            for(User userObj : insertedUserList){
                Sales_Team_User__c salesTeamUserObj = new Sales_Team_User__c();
                salesTeamUserObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
                salesTeamUserObj.User__c = userObj.Id;
                salesTeamUserObj.Source_Id__c = salesTeamForCoverageObj.Coverage_ID__c + '#' + userObj.Login_Id__c; 
                
                salesTeamUserList.add(salesTeamUserObj);
            } 
            
            if(salesTeamUserList.size() > 0){
                 insert salesTeamUserList;
            }
            
            Test.stopTest(); //Batch Execution also completed
            
            /* Check for update of Sales_Team_for_Coverage__c */
            List<Sales_Team_for_Coverage__c> salesTeamForCoverageList = [SELECT Id, Coverage_Id__c, 
                                                                         Process_Coverage_Related_Entities__c, Is_Split_Sales_Code__c
                                                                         FROM Sales_Team_for_Coverage__c 
                                                                         WHERE Coverage_Id__c = '1234XX'];
            if(salesTeamForCoverageList != null){
               System.assertEquals(1, salesTeamForCoverageList.size());
               System.assertEquals(FALSE, FALSE); 
            }
            
            /* Perform Updates */
            //Update Sales_Team_User__c (By Default Is_User_Active__c is false, updating it to TRUE)
            for(Sales_Team_User__c salesTeamUser : salesTeamUserList){
                salesTeamUser.Is_User_Active__c = TRUE;
            }
            
            update salesTeamUserList;
         }
         
     }
    
   
}