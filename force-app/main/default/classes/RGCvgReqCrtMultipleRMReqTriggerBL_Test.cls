@isTest
public class RGCvgReqCrtMultipleRMReqTriggerBL_Test {
   
    @testSetup 
    private static void setupTestData(){
       Integer numTestAccounts = 4;
       
   List<Contact> contacts = new List<Contact>(); 
   List<Coverage_Team_Member__c> cvgTmMbrs =  new List<Coverage_Team_Member__c>(); 
   List<Task> Tasks = new List<Task>();
   List<Event> Events = new List<Event>(); 
   List<Opportunity> Opportunities = new List<Opportunity>(); 
   List<Revenue_Rollup__c> revenueRollups = new List<Revenue_Rollup__c>(); 
   List<Account> testAccounts =  new List<Account>();     
        
 
    RecordType RGRecordType = [SELECT Id FROM RecordType WHERE Name = 'RG Account' ];
    RecordType RSRecordType = [SELECT Id FROM RecordType WHERE Name = 'RS Account' ];
    RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account' ];
        
    system.debug('RGRecordType : ' + RGRecordType.Id);
    system.debug('RSRecordType : ' + RSRecordType.Id);  
    system.debug('RMRecordType : ' + RMRecordType.Id) ; 
        
   
    
        
    Account accountAdd = new Account();
    accountAdd.Name = 'TestAccount1';
    accountAdd.RDM_Org_ID__c = 'RSXXXXXX';  
    accountAdd.BillingCity = 'California';
    accountAdd.BillingCountry = 'United States';
    accountAdd.BillingStreet = '52nd Street';
    accountAdd.RecordTypeId = RSRecordType.Id; 
    insert accountAdd;    

    Account account2  = new Account(); 
    account2.Name = 'TestAccount2';
    account2.RDM_Org_ID__c = 'RGXXXXXX';            
    account2.RecordTypeId = RGRecordType.Id;
    account2.BillingCity = 'California';
    account2.BillingCountry = 'United States';
    account2.BillingStreet = '52nd Street';
    account2.ParentId = accountAdd.Id;
        
    insert account2;
        
    Account account3  = new Account(); 
    account3.Name = 'TestAccount3';
    account3.RDM_Org_ID__c = 'RMXXXXXX';            
    account3.RecordTypeId = RMRecordType.Id;
    account3.BillingCity = 'California';
    account3.BillingCountry = 'United States';
    account3.BillingStreet = '52nd Street';
    account3.ParentId = account2.Id;
    account3.Active__c = true;    
    insert account3; 
        
    Account account4  = new Account();  
    account4.Name = 'TestAccount4';
    account4.RDM_Org_ID__c = 'RMYYYYYY';            
    account4.RecordTypeId = RMRecordType.Id;
    account4.BillingCity = 'Mumbai';
    account4.BillingCountry = 'India';
    account4.BillingStreet = 'Hiranandani Business Park';
    account4.ParentId = account2.id;
    account4.Active__c = true;
    account4.Restricted_Flag__c = TRUE; 
        
    insert account4;  
        
    Account account5  = new Account(); 
    account5.Name = 'TestAccount5';
    account5.RDM_Org_ID__c = 'RMZZZZZZ';            
    account5.RecordTypeId = RMRecordType.Id;
    account5.BillingCity = 'California';
    account5.BillingCountry = 'United States';
    account5.BillingStreet = '52nd Street';
    account5.ParentId = account2.Id;
    account5.Active__c = true; 
    account5.Restricted_Flag__c = TRUE; 
    insert account5;     
       
    system.debug('RM Account 1 :'+ account3.Id) ;  
    system.debug('RM Account 2 :'+ account4.id) ; 
    system.debug('RM Account 3 :'+ account5.id) ; 
    system.debug('RG Account  :'+ account2.id) ;
    system.debug('RS Account  :'+ accountAdd.id) ; 
    system.debug('ParentId RM Account 1  :'+ account3.ParentId) ;
    system.debug('ParentId RM Account 2  :'+account4.ParentId) ;   
     system.debug('ParentId RG Account  :'+ account2.ParentId) ;     
        
    
    } 
    
static testMethod void customsettings()
 {
  list<Coverage_Request_Approval__c> customlist = new list<Coverage_Request_Approval__c>();
  Coverage_Request_Approval__c test  = new Coverage_Request_Approval__c(name='account', request__c='account__c', team__c='account__c');
  Coverage_Request_Approval__c test1  = new Coverage_Request_Approval__c(name='owner', request__c='ownerid', team__c='Team_Member__c');
  customlist.add(test);
  customlist.add(test1);
  insert customlist;
 
}
  
   static testMethod void InsertCvgAccessRequestForNonRestrictedRM() {
       Test.StartTest(); 
    //added for test class fix for failure JIRA SALES - 3082
    //customsettings();   
    Integer numTestUsers = 4; 
   //added for test class fix for failure JIRA SALES - 3082  
   //List<User> users = UtilityTesting.CreateUsersWithManager(numTestUsers);
    List<User> users = UtilityTesting.CreateUsersWithManagerwithRole(numTestUsers);
    User owneruser = [select id,name,Alias,ManagerId,Manager.Name,Region__c from user where id =:users[1].id];   
    system.runas(users[0]){
       
        System.debug('user Manager :' +  users[0].ManagedUsers);
        //System.debug('user Region :' +  user[0].Region__c);
        
         List<Approver__c>   approvers = new List<Approver__c>();
         Approver__c approver = new Approver__c();
         approver.Region__c = 'Americas';
         approver.user__c = users[0].Id;
         approvers.add(approver);
         approver = new Approver__c();  
         approver.user__c = users[1].Id;
         approver.Region__c = 'Americas';
         approvers.add(approver);
         
         insert approvers;  
       
            
          Sales_Team_For_Coverage__c salescvgTeam = new  Sales_Team_For_Coverage__c ();
          salescvgTeam.Name = 'Test';
        salescvgTeam.Coverage_ID__c = '1234';
        salescvgTeam.Sales_Team__c = 'Test Sales Team';
        salescvgTeam.Sales_Code_Login_ID__c = owneruser.Alias;
        salescvgTeam.Active__c = true;
        salescvgTeam.OwnerId  = owneruser.id;
        salescvgTeam.Is_Dummy__c = false;          
        insert salescvgTeam;
        
          /* Insert Sales_Team_User__c */
          Sales_Team_User__c salesTeamUserObj = new Sales_Team_User__c();
          salesTeamUserObj.Sales_Team_for_Coverage__c = salescvgTeam.Id;
          salesTeamUserObj.User__c = owneruser.Id;
            
          insert salesTeamUserObj;          
          
          Account acct = UtilityTesting.CreateAccount();
          RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account'];
          RecordType RGRecordType = [SELECT Id FROM RecordType WHERE Name = 'RG Account'];
          List<Coverage_Access_Request__c> rmCoverageRequests = new List<Coverage_Access_Request__c>();
           
              
           Account acctRGNew = [SELECT Id,Name,RecordTypeId,RDM_ORG_ID__c,ParentId FROM Account WHERE NAME = 'TestAccount2'] ;       
          
           RG_Coverage_Request__c newRGCoverageRequest = new  RG_Coverage_Request__c();
           newRGCoverageRequest.RG_Account__c = acctRGNew.id;
           newRGCoverageRequest.Type_of_Coverage__c = 'Add';
           newRGCoverageRequest.Reason_for_Request__c = 'Testing';
           newRGCoverageRequest.Start_Date__c = Date.newInstance(2016, 08, 01);
           newRGCoverageRequest.End_Date__c = Date.newInstance(2016, 08, 09);
           newRGCoverageRequest.Product2__c = 'Flow Credit - USA';
           newRGCoverageRequest.Product_Group__c = 'Fixed Income';
           newRGCoverageRequest.Role__c = 'Primary'; 
           newRGCoverageRequest.Product__c = 'Flow Credit - USA';
           //newRGCoverageRequest.OwnerId = owneruser.Id; 
           newRGCoverageRequest.Sales_Team_for_Coverage__c = salescvgTeam.id; 
            
            try{ 
                insert newRGCoverageRequest;
            }
             catch(exception ex){            
                 
                if(string.valueOf(ex.getMessage()).contains('FIELD_FILTER_VALIDATION_EXCEPTION'))
                  System.debug('Exception in RGCvgReqCrtMultipleRMReqTriggerBL_Test : '+ ex.getMessage());
              }
    
    
        
        }
   Test.StopTest();
    }
    
    static testMethod void InsertCoverageAccessRequestTool(){
             
           Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        
        UserRole userRoleObj = [SELECT Id, Name  FROM UserRole WHERE Name LIKE 'Americas - FI - Sales - Boston Agency Mortgages' LIMIT 1];
        
         UserRole userBMRoleObj = [SELECT Id, Name  FROM UserRole WHERE Name LIKE 'Americas - FI Sales - Region Head' LIMIT 1];
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
           
           
         User userObjBM = new User();
        userObjBM.Login_ID__c = 'testtmpBM';
        userObjBM.Alias = 'testtmp1';
        userObjBM.LastName = 'TestTempBM_LN';
        userObjBM.FirstName = 'TestTempBM_FN';
        userObjBM.Email = 'TestTempBM@testOrg.com';
        userObjBM.UserName = 'TestTempBM@testOrg.com';
        userObjBM.ProfileId = profileNomuraSales.Id;
        userObjBM.EmailEncodingKey = 'UTF-8';
        userObjBM.LanguageLocaleKey = 'en_US';
        userObjBM.LocaleSidKey = 'en_US';
        userObjBM.TimeZoneSidKey = 'America/Los_Angeles';
        userObjBM.Region__c = 'Americas';
        userObjBM.Country = 'United States';
        userObjBM.UserRoleId = (userBMRoleObj != null ? userBMRoleObj.Id : null);
           
        insert userObjBM;
           
          User userObjBM1 = new User();
        userObjBM1.Login_ID__c = 'testtmpBM1';
        userObjBM1.Alias = 'testtmp2';
        userObjBM1.LastName = 'TestTempBM_LN';
        userObjBM1.FirstName = 'TestTempBM_FN';
        userObjBM1.Email = 'TestTempBM1@testOrg.com';
        userObjBM1.UserName = 'TestTempBM1@testOrg.com';
        userObjBM1.ProfileId = profileNomuraSales.Id;
        userObjBM1.EmailEncodingKey = 'UTF-8';
        userObjBM1.LanguageLocaleKey = 'en_US';
        userObjBM1.LocaleSidKey = 'en_US';
        userObjBM1.TimeZoneSidKey = 'America/Los_Angeles';
        userObjBM1.Region__c = 'Americas';
        userObjBM1.Country = 'United States';
        userObjBM1.UserRoleId = (userBMRoleObj != null ? userBMRoleObj.Id : null);   
           
         insert  userObjBM1;
        
        System.runas(userObj){
            
             Test.startTest();
            /* Insert Sales_Team_for_Coverage__c */
            Sales_Team_for_Coverage__c salesTeamForCoverageObj = new Sales_Team_for_Coverage__c();
            salesTeamForCoverageObj.Name = 'TestTemp_FN TestTemp_LN';
            salesTeamForCoverageObj.Coverage_ID__c = '1234XX';
            salesTeamForCoverageObj.Sales_Team__c = 'Test Team';
            salesTeamForCoverageObj.Sales_Desk_Region__c = 'USA';
            salesTeamForCoverageObj.Sales_Desk_Division__c = 'Fixed Income';
            salesTeamForCoverageObj.Sales_Code_Login_ID__c = userObj.Login_Id__c;
            salesTeamForCoverageObj.Active__c = TRUE;
            salesTeamForCoverageObj.Is_Dummy__c = false;
            insert salesTeamForCoverageObj;
            
            /* Insert Sales_Team_User__c */
            Sales_Team_User__c salesTeamUserObj = new Sales_Team_User__c();
            salesTeamUserObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
            salesTeamUserObj.User__c = userObj.Id;
            salesTeamUserObj.Source_Id__c = salesTeamForCoverageObj.Coverage_ID__c + '#' + userObj.Login_Id__c;
            
            insert salesTeamUserObj;
            
            
            /* Insert RG_Coverage_Request__c */
            Account accountRGObj = [SELECT Id, RDM_Org_Id__c, Name FROM Account 
                                    WHERE Name = 'TestAccount2' AND RDM_Org_Id__c = 'RGXXXXXX'
                                    AND RecordType.Name = 'RG Account'];
            
           
            
            if(accountRGObj != null){
                /* Without Product */
                /*RG_Coverage_Request__c coverageRequestForRGObj = new RG_Coverage_Request__c();
                
                coverageRequestForRGObj.RG_Account__c = accountRGObj.Id;
                coverageRequestForRGObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
                coverageRequestForRGObj.Type_of_Coverage__c = 'Add';
                coverageRequestForRGObj.Start_Date__c = Date.today();
                coverageRequestForRGObj.Role__c = 'Primary';
                
                insert coverageRequestForRGObj;
                */
                
              
                
                /* With Product */
                RG_Coverage_Request__c coverageRequestWithProductForRGObj = new RG_Coverage_Request__c();
                
                coverageRequestWithProductForRGObj.RG_Account__c = accountRGObj.Id;
                coverageRequestWithProductForRGObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
                coverageRequestWithProductForRGObj.Type_of_Coverage__c = 'Add';
                coverageRequestWithProductForRGObj.Start_Date__c = Date.today();
                coverageRequestWithProductForRGObj.Role__c = 'Primary';
                //added for test class fix for failure JIRA SALES - 3082  
                coverageRequestWithProductForRGObj.Product2__c = 'FUTURES - USA';               
                coverageRequestWithProductForRGObj.Product__c = 'FUTURES - USA';
                coverageRequestWithProductForRGObj.Product_Group__c = 'Fixed Income';                              
                coverageRequestWithProductForRGObj.SourceUpload__c = 'Tool';
                
                insert coverageRequestWithProductForRGObj;
                 
                
               
            
            }
           
         }
        
Test.stopTest();     }
    
    static testMethod void InsertCoverageAccessRequest(){
           
           
        Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        
        UserRole userRoleObj = [SELECT Id, Name  FROM UserRole WHERE Name LIKE 'Americas - FI - Sales - Boston Agency Mortgages' LIMIT 1];
        
         UserRole userBMRoleObj = [SELECT Id, Name  FROM UserRole WHERE Name LIKE 'Americas - FI Sales - Region Head' LIMIT 1];
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
           
           /*
         User userObjBM = new User();
        userObjBM.Login_ID__c = 'testtmpBM';
        userObjBM.Alias = 'testtmp2';
        userObjBM.LastName = 'TestTempBM_LN';
        userObjBM.FirstName = 'TestTempBM_FN';
        userObjBM.Email = 'TestTempBM@testOrg.com';
        userObjBM.UserName = 'TestTempBM@testOrg.com';
        userObjBM.ProfileId = profileNomuraSales.Id;
        userObjBM.EmailEncodingKey = 'UTF-8';
        userObjBM.LanguageLocaleKey = 'en_US';
        userObjBM.LocaleSidKey = 'en_US';
        userObjBM.TimeZoneSidKey = 'America/Los_Angeles';
        userObjBM.Region__c = 'Americas';
        userObjBM.Country = 'United States';
        userObjBM.UserRoleId = (userBMRoleObj != null ? userBMRoleObj.Id : null);
           
        insert userObjBM;
           
          User userObjBM1 = new User();
        userObjBM1.Login_ID__c = 'testtmpBM1';
        userObjBM1.Alias = 'testtmp1';
        userObjBM1.LastName = 'TestTempBM_LN';
        userObjBM1.FirstName = 'TestTempBM_FN';
        userObjBM1.Email = 'TestTempBM1@testOrg.com';
        userObjBM1.UserName = 'TestTempBM1@testOrg.com';
        userObjBM1.ProfileId = profileNomuraSales.Id;
        userObjBM1.EmailEncodingKey = 'UTF-8';
        userObjBM1.LanguageLocaleKey = 'en_US';
        userObjBM1.LocaleSidKey = 'en_US';
        userObjBM1.TimeZoneSidKey = 'America/Los_Angeles';
        userObjBM1.Region__c = 'Americas';
        userObjBM1.Country = 'United States';
        userObjBM1.UserRoleId = (userBMRoleObj != null ? userBMRoleObj.Id : null);   
           
         insert  userObjBM1;*/
           
           
           
           
        
       
        
        System.runas(userObj){
            
            
            // Insert Sales_Team_for_Coverage__c 
            Sales_Team_for_Coverage__c salesTeamForCoverageObj = new Sales_Team_for_Coverage__c();
            salesTeamForCoverageObj.Name = 'TestTemp_FN TestTemp_LN';
            salesTeamForCoverageObj.Coverage_ID__c = '1234XX';
            salesTeamForCoverageObj.Sales_Team__c = 'Test Team';
            salesTeamForCoverageObj.Sales_Desk_Region__c = 'USA';
            salesTeamForCoverageObj.Sales_Desk_Division__c = 'Fixed Income';
            salesTeamForCoverageObj.Sales_Code_Login_ID__c = userObj.Login_Id__c;
            salesTeamForCoverageObj.Is_Dummy__c = false;
            salesTeamForCoverageObj.Active__c = TRUE;
            
            insert salesTeamForCoverageObj;
            system.debug([select id, Name, Owner.Name,Is_Dummy__c from Sales_Team_for_Coverage__c where Id = : salesTeamForCoverageObj.id]);
            // Insert Sales_Team_User__c 
            Sales_Team_User__c salesTeamUserObj = new Sales_Team_User__c();
            salesTeamUserObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
            salesTeamUserObj.User__c = userObj.Id;
            salesTeamUserObj.Source_Id__c = salesTeamForCoverageObj.Coverage_ID__c + '#' + userObj.Login_Id__c;
            
            insert salesTeamUserObj;
            
            
            // Insert RG_Coverage_Request__c 
            Account accountRGObj = [SELECT Id, RDM_Org_Id__c, Name FROM Account 
                                    WHERE Name = 'TestAccount2' AND RDM_Org_Id__c = 'RGXXXXXX'
                                    AND RecordType.Name = 'RG Account'];
            
           
            
            if(accountRGObj != null){
                /// Without Product 
               
                List<RG_Coverage_Request__c> inserts = new List<RG_Coverage_Request__c>();
                
                RG_Coverage_Request__c coverageRequestForRGObjForTool = new RG_Coverage_Request__c();
                
                coverageRequestForRGObjForTool.RG_Account__c = accountRGObj.Id;
                coverageRequestForRGObjForTool.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
                coverageRequestForRGObjForTool.Type_of_Coverage__c = 'Add';
                coverageRequestForRGObjForTool.Start_Date__c = Date.today();
                coverageRequestForRGObjForTool.Role__c = 'Primary';
                coverageRequestForRGObjForTool.SourceUpload__c = 'Tool';
                coverageRequestForRGObjForTool.del_salesCode__c = salesTeamForCoverageObj.Id;
                
                inserts.add(coverageRequestForRGObjForTool);
                
              
                
                
                RG_Coverage_Request__c coverageRequestWithProductForRGObj1 = new RG_Coverage_Request__c();
                
                coverageRequestWithProductForRGObj1.RG_Account__c = accountRGObj.Id;
                coverageRequestWithProductForRGObj1.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
                coverageRequestWithProductForRGObj1.Type_of_Coverage__c = 'Update';
                coverageRequestWithProductForRGObj1.Start_Date__c = Date.today();
                coverageRequestWithProductForRGObj1.Role__c = 'Primary';
                coverageRequestWithProductForRGObj1.Product2__c = 'EMERGING MARKETS - USA';
                coverageRequestWithProductForRGObj1.Product__c = 'EMERGING MARKETS - USA';
                coverageRequestWithProductForRGObj1.Product_Group__c = 'Fixed Income';
                coverageRequestWithProductForRGObj1.SourceUpload__c = 'Tool';
                
                inserts.add(coverageRequestWithProductForRGObj1);
            Test.StartTest();
            insert inserts;
            Test.stopTest();    
            }
            
         }
        
    }
}