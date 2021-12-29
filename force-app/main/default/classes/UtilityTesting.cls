@isTest
public class UtilityTesting {

  public static string userDomain = '@nomtestorg.com';
    
  public static list<user> CreateUsers(integer NoOfUsers){
       list<user> uList = new list<user>();
       Profile p  = [SELECT Id From Profile WHERE Name='System Administrator' limit 1];
       if(NoOfUsers>0){
         for(integer i=0;i<NoOfUsers; i++){
            string iNo= string.valueof(i);
            User u    = new User( Alias = 'newUser'+iNo,
                        Email ='newuser'+iNo+'@testorg.com',
                        EmailEncodingKey = 'UTF-8',
                        LastName = 'Testing'+iNo,
                        LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', 
                        UserName='event1newuser123'+iNo+userDomain,
                        ProfileId=p.Id,
                        TimeZoneSidKey = 'America/Los_Angeles'
                        
                        );
           uList.add(u);
         }
         
         insert uList;
         list<user> user = [select id,name  from user where id in : uList];
         return user;
       }
       
       return uList;
       
    }
    
  public static list<User> createUsersWithProfile(Integer NoOfUsers, String profileName) {
       list<user> uList = new list<user>();
       Profile p  = [SELECT Id From Profile WHERE Name=:profileName limit 1];
       if(NoOfUsers>0){
         for(integer i=0;i<NoOfUsers; i++){
            string iNo= string.valueof(i);
            User u    = new User( Alias = 'newUser'+iNo,
                        Email ='newuser'+iNo+'@testorg.com',
                        EmailEncodingKey = 'UTF-8',
                        LastName = 'Testing'+iNo,
                        LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', 
                        UserName='event1newuser123'+iNo+userDomain,
                        ProfileId=p.Id,
                        TimeZoneSidKey = 'America/Los_Angeles'
                        
                        );
           uList.add(u);
         }
         System.debug('uList: ' + uList);
         insert uList;
         list<user> user = [select id,name,Profile.Name  from user where id in : uList];
         return user;
       }
       
       return uList;
    }
    
  public static list<user> CreateUsersWithManager(integer NoOfUsers){
       list<user> uLists = new list<user>();
       Profile p  = [SELECT Id From Profile WHERE Name='System Administrator' limit 1];  
     
        User uManager    = new User( Alias = 'UserMgr',
                        Email ='UserMgr@testorg.com',
                        EmailEncodingKey = 'UTF-8',
                        LastName = 'UserMgr',
                        LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', 
                        UserName='event1UserMgr123' + userDomain,
                        ProfileId=p.Id,                         
                        TimeZoneSidKey = 'America/Los_Angeles',                                                        
                        Region__c = 'Americas'
                                    
                        ); 
            
          insert uManager;  
       if(NoOfUsers>0){
         for(integer i=0;i<NoOfUsers; i++){
            string iNo= string.valueof(i);
            User u    = new User( Alias = 'UserMgr'+iNo,
                        Email ='UserMgr'+iNo+'@testorg.com',
                        EmailEncodingKey = 'UTF-8',
                        LastName = 'UserMgr'+iNo,
                        LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', 
                        UserName='event1UserMgr123'+iNo+userDomain,
                        ProfileId=p.Id,                         
                        TimeZoneSidKey = 'America/Los_Angeles',                                                        
                        Region__c = 'Americas',
                        Login_ID__c = 'UserMgr'+(iNo+1)                                 
                        );             
           u.ManagerId = uManager.Id;
           uLists.add(u);             
         }
         
         insert uLists;
         list<user> users = [select id,name,ManagerId,Manager.Name,Region__c,UserName, Login_Id__c, IsActive from user where id in : uLists];
         return users;
       }
       
       return uLists;
       
    }//added for test class fix for failure JIRA SALES - 3082  

  //SALES-3651
  public static list<user> CreateUsersWithManagerForAEJ(integer NoOfUsers){
      list<user> uLists = new list<user>();
      Profile p  = [SELECT Id From Profile WHERE Name='System Administrator' limit 1];  
      
      User uManager    = new User( Alias = 'UserMgr1',
                                  Email ='UserMgr1@testorg.com',
                                  EmailEncodingKey = 'UTF-8',
                                  LastName = 'UserMgr1',
                                  LanguageLocaleKey='en_US',
                                  LocaleSidKey='en_US', 
                                  UserName='event1UserMgr1123' + userDomain,
                                  ProfileId=p.Id,                         
                                  TimeZoneSidKey = 'America/Los_Angeles',                                                        
                                  Region__c = 'Americas',
                                  Login_ID__c = 'UserMgr1'
                                 ); 
      
      insert uManager;  
      
      User uManager2    = new User( Alias = 'UserMgr2',
                                   Email ='UserMgr2@testorg.com',
                                   EmailEncodingKey = 'UTF-8',
                                   LastName = 'UserMgr2',
                                   LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', 
                                   UserName='event1UserMgr2123' + userDomain,
                                   ProfileId=p.Id,                         
                                   TimeZoneSidKey = 'America/Los_Angeles',                                                        
                                   Region__c = 'Americas',
                                   Login_ID__c = 'UserMgr2'
                                  ); 
      
      insert uManager2;  
      
      if(NoOfUsers>0){
          for(integer i=0;i<NoOfUsers; i++){
              string iNo= string.valueof(i);
              User u    = new User( Alias = 'UserMgr'+iNo,
                                   Email ='UserMgr'+iNo+'@testorg.com',
                                   EmailEncodingKey = 'UTF-8',
                                   LastName = 'UserMgr'+iNo,
                                   LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', 
                                   UserName='event1UserMgr456'+iNo+userDomain,
                                   ProfileId=p.Id,                         
                                   TimeZoneSidKey = 'America/Los_Angeles',                                                        
                                   Region__c = 'Americas',
                                   Login_ID__c = 'UserMgr'+(iNo+1)                                 
                                  ); 
              u.ManagerCode__c = uManager2.Login_ID__c;
              u.ManagerId = uManager.Id;
              uLists.add(u);             
          }
          insert uLists;
          list<user> users = [select id,name,ManagerId,Manager.Name,Region__c,UserName, Login_Id__c, IsActive from user where id in : uLists];
          return users;
      }      
      return uLists;      
  }  
    
  public static list<user> CreateUsersWithManagerwithRole(integer NoOfUsers){
       list<user> uLists = new list<user>();
       Profile p  = [SELECT Id From Profile WHERE Name='System Administrator' limit 1];  
       UserRole userRoleObj = [SELECT Id, Name  FROM UserRole WHERE Name LIKE 'Americas - FI - Sales - Boston Agency Mortgages' LIMIT 1];
        User uManager    = new User( Alias = 'UserMgr',
                        Email ='UserMgr@testorg.com',
                        EmailEncodingKey = 'UTF-8',
                        LastName = 'UserMgr',
                        LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', 
                        UserName='event1UserMgr123'+userDomain,
                        ProfileId=p.Id,                         
                        TimeZoneSidKey = 'America/Los_Angeles',                                                        
                        Region__c = 'Americas',
                        UserRoleId = userRoleObj.Id            
                        ); 
            
          insert uManager;  
       if(NoOfUsers>0){
         for(integer i=0;i<NoOfUsers; i++){
            string iNo= string.valueof(i);
            User u    = new User( Alias = 'UserMgr'+iNo,
                        Email ='UserMgr'+iNo+'@testorg.com',
                        EmailEncodingKey = 'UTF-8',
                        LastName = 'UserMgr'+iNo,
                        LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', 
                        UserName='event1UserMgr123'+iNo+userDomain,
                        ProfileId=p.Id,                         
                        TimeZoneSidKey = 'America/Los_Angeles',                                                        
                        Region__c = 'Americas',
                        Login_ID__c = 'UserMgr'+(iNo+1) ,                                
                        UserRoleId = userRoleObj.Id )  ;          
           u.ManagerId = uManager.Id;
           uLists.add(u);             
         }
         
         insert uLists;
         list<user> users = [select id,name,ManagerId,Manager.Name,Region__c,UserName, Login_Id__c, IsActive from user where id in : uLists];
         return users;
       }
       
       return uLists;
       
    }
    
  //added for test class fix for failure JIRA SALES -  
  public static list<user> CreateUsersWithManagerwithRole(integer NoOfUsers, String Rolename){
       String []strRole = Rolename.split(';');
       system.debug(strRole);
       list<user> uLists = new list<user>();
       Profile p  = [SELECT Id From Profile WHERE Name='System Administrator' limit 1];  
       UserRole userRoleObj = [SELECT Id, Name  FROM UserRole WHERE Name LIKE 'Americas - FI - Sales - Boston Agency Mortgages' LIMIT 1];
        User uManager    = new User( Alias = 'UserMgr',
                        Email ='UserMgr@testorg.com',
                        EmailEncodingKey = 'UTF-8',
                        LastName = 'UserMgr',
                        LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', 
                        UserName='event1UserMgr123'+userDomain,
                        ProfileId=p.Id,                         
                        TimeZoneSidKey = 'America/Los_Angeles',                                                        
                        Region__c = 'Americas',
                        UserRoleId = userRoleObj.Id            
                        ); 
            
          insert uManager;  
       if(NoOfUsers>0){
         for(integer i=0;i<NoOfUsers; i++){
            string iNo= string.valueof(i);
            User u    = new User( Alias = 'UserMgr'+iNo,
                        Email ='UserMgr'+iNo+'@testorg.com',
                        EmailEncodingKey = 'UTF-8',
                        LastName = 'UserMgr'+iNo,
                        LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', 
                        UserName='event1UserMgr123'+iNo+userDomain,
                        ProfileId=p.Id,                         
                        TimeZoneSidKey = 'America/Los_Angeles',                                                        
                        Region__c = 'Americas',
                        Login_ID__c = 'UserMgr'+(iNo+1) ,                                
                        UserRoleId = userRoleObj.Id )  ;          
           u.ManagerId = uManager.Id;
           uLists.add(u);             
         }
         
         insert uLists;
         list<user> users = [select id,name,ManagerId,Manager.Name,Region__c,UserName, Login_Id__c, IsActive from user where id in : uLists];
         return users;
       }
       
       return uLists;
       
    }

  public static list<account> CreateAccounts(integer NoOfAccounts){
      List<Account> AccountList = new List<Account>();
      if(NoOfAccounts>0){
         for(integer i=0;i<NoOfAccounts; i++){
            string iNo= string.valueof(i);
            Account acc = new Account();
            acc.Name = 'TestAccount'+iNo;
            acc.RDM_Org_ID__c = 'test'+i; 
             acc.BillingCity = 'California';
             acc.BillingCountry = 'United States';
             acc.BillingStreet = '52nd Street';
            AccountList .add(acc);
         }
         
         insert AccountList;
         List<Account> Accounts = [Select id,name,RDM_Org_ID__c,ParentId from account where id in : AccountList];
         return Accounts;
      }
       
      return AccountList;  
   }
   
  public static account CreateAccount(){
      Account acc = new Account();
      acc.name = 'test account';
      acc.RDM_Org_ID__c= 'testaccount';
        acc.BillingCity = 'California';
             acc.BillingCountry = 'United States';
             acc.BillingStreet = '52nd Street';
      insert acc;
      account a = [select id,name,RDM_Org_ID__c from account where id=:acc.id];       
      return a;  
   }
       
  public static list<user> CreateUserswithcountryandcity(){
       list<user> uList = new list<user>();
       Profile p  = [SELECT Id From Profile WHERE Name='System Administrator' limit 1];
            integer i =1;
            string iNo= string.valueof(i);
            User u    = new User( Alias = 'newUser'+iNo,
                        Email ='newuser'+iNo+'@testorg.com',
                        EmailEncodingKey = 'UTF-8',
                        LastName = 'Testing'+iNo,
                        LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', 
                        UserName='event1newuser'+iNo+userDomain,
                        ProfileId=p.Id,
                        TimeZoneSidKey = 'America/Los_Angeles',
                        country = 'Japan'
                        
                        );
           uList.add(u);
           
            i =2;
            iNo= string.valueof(i);
            u    = new User( Alias = 'newUser'+iNo,
                        Email ='newuser'+iNo+'@testorg.com',
                        EmailEncodingKey = 'UTF-8',
                        LastName = 'Testing'+iNo,
                        LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', 
                        UserName='event1newuser'+iNo+userDomain,
                        ProfileId=p.Id,
                        TimeZoneSidKey = 'America/Los_Angeles',
                        country = 'United States',
                        city = 'Boston'
                        );
           uList.add(u);
           
            i =3;
            iNo= string.valueof(i);
            u    = new User( Alias = 'newUser'+iNo,
                        Email ='newuser'+iNo+'@testorg.com',
                        EmailEncodingKey = 'UTF-8',
                        LastName = 'Testing'+iNo,
                        LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', 
                        UserName='event1newuser'+iNo+userDomain,
                        ProfileId=p.Id,
                        TimeZoneSidKey = 'America/Los_Angeles',
                        country = 'Japan',
                        city ='tokyo'
                        );
           uList.add(u);
        
         
         insert uList;
         list<user> user = [select id,name from user where id in : uList];
         return user;
       }
   
  public static Double getRandomDouble (Integer min, Integer max) {
		return Math.floor(Math.random() * ((max-min)+1) + min);

	}   
	
  public static Integer getRandomInteger (Integer min, Integer max) {
		return (getRandomDouble(min, max)).intValue();
	}

  public static List<User> createUsersWithProfileAndRole(Integer NoOfUsers, String profileName, String roleName, String roleDeveloperName) {
       
       List<User> userList = new List<User>();
       List<User> users = new List<User>();
       UserRole role; 
       Profile p  = [SELECT Id From Profile WHERE Name=:profileName limit 1];
      
       List<UserRole> roles  = [SELECT Id, Name From UserRole WHERE Name=:roleName Limit 1];
       
       if(roles.size() == 0){
          role = new UserRole(DeveloperName = roleDeveloperName, Name = roleName);
          insert role;
       }else{
          role = roles[0]; 
       }
       

       if(NoOfUsers>0){
           final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
           String randomAlias = '';
          
           
         for(integer i = 0; i<NoOfUsers; i++){
             while (randomAlias.length() < 4) {
                 Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
                 randomAlias += chars.substring(idx, idx+1);
             }
            String iNo = string.valueof(i) + (String.valueOf(UtilityTesting.getRandomInteger(1, 100)));
            User u= new User( Alias = randomAlias+ iNo ,
                              Email ='newuser'+iNo+'@testorg.com',
                              EmailEncodingKey = 'UTF-8',
                              LastName = 'Testing'+iNo,
                              LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', 
                              UserName='event1newuser123'+iNo+userDomain,
                              ProfileId=p.Id,
                              TimeZoneSidKey = 'America/Los_Angeles',
                              UserRoleId = role.Id);
           userList.add(u);
         }
         
         insert userList;
         
         users = [Select Id,Name,Profile.Name
                  From User 
                  Where Id IN: userList];
         
       }
       
       return users;
    }

  public static Sales_Team_For_Coverage__c createSalesTeamForCoverage(String name, String salesTeam, String coverageId){
    Sales_Team_For_Coverage__c salesCoverageTeam = new  Sales_Team_For_Coverage__c ();
    salesCoverageTeam.Name = name;
    salesCoverageTeam.Sales_Team__c = salesTeam;
    salesCoverageTeam.Coverage_ID__c = coverageId;      
    return salesCoverageTeam;
  }

  public static Sales_Team_User__c createSalesTeamUser(Id salesCoverageTeamId, Id userId){
    Sales_Team_User__c salesTeamUser = new Sales_Team_User__c();
    salesTeamUser.Sales_Team_for_Coverage__c = salesCoverageTeamId;
    salesTeamUser.User__c = userId;

    return salesTeamUser;
  }

  public static Account createRSAccount(String name, String rdmOrgId, String billingStreet, String billingCity, String billingCountry, Boolean active){
    
    RecordType RSRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'RS_Account' ];

    Account a = new Account();
    a.Name = name;
    a.RDM_Org_ID__c = rdmOrgId;            
    a.RecordTypeId = RSRecordType.Id;
    a.BillingCity = billingCity;
    a.BillingCountry = billingCountry;
    a.BillingStreet = billingStreet;  
    a.Active__c = active;  
    
    return a;

  }

  public static Account createRGAccount(String name, Id parentId, String rdmOrgId, String billingStreet, String billingCity, String billingCountry, Boolean active){
    
    RecordType RGRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'RG_Account' ];

    Account a = new Account();
    a.Name = name;
    a.RDM_Org_ID__c = rdmOrgId;            
    a.RecordTypeId = RGRecordType.Id;
    a.ParentId = parentId;
    a.BillingCity = billingCity;
    a.BillingCountry = billingCountry;
    a.BillingStreet = billingStreet;    
    a.Active__c = active;
    
    return a;

  }

  public static Account createRMAccount(String name, Id parentId, String rdmOrgId, String billingStreet, String billingCity, String billingCountry, Boolean active){
    
    RecordType RMRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'RM_Account' ];

    Account a = new Account();
    a.Name = name;
    a.RDM_Org_ID__c = rdmOrgId;            
    a.RecordTypeId = RMRecordType.Id;
    a.ParentId = parentId;
    a.BillingCity = billingCity;
    a.BillingCountry = billingCountry;
    a.BillingStreet = billingStreet;    
    a.Active__c = active;
    return a;

  }

public static Account createPODAccount(String name, Id parentId, String rdmOrgId, String billingStreet, String billingCity, String billingCountry, Boolean active){
    
    RecordType PODRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'POD_Account' ];

    Account a = new Account();
    a.Name = name;
    a.RDM_Org_ID__c = rdmOrgId;            
    a.RecordTypeId = PODRecordType.Id;
    a.ParentId = parentId;
    a.BillingCity = billingCity;
    a.BillingCountry = billingCountry;
    a.BillingStreet = billingStreet;    
    a.Active__c = active;
    return a;

  }

  public static Contact createContact(String firstName, String lastName, String email, String phone, String salutation, Id accountId, Boolean active){
    
    Contact c = new Contact();

    c.AccountId = accountId;
    c.FirstName = firstName; 
    c.LastName = lastName;  
      if(active)
          c.Active__c = active;
      else
      {
          c.Inactive_Reason__c = 'Other';
          c.Other_Inactive_Reason__c = 'Other';
      }
    c.Email = email;
    c.Phone = phone; 
    c.Salutation = salutation;  

    return c;

  }

  public static Task createTask(Id whatId, Id whoId, Id ownerId, String description, String status, String priority, String type, String division, String region){
    
    Task t = new Task();

    t.WhatId = whatId;
    t.WhoId = whoId;  
    t.OwnerId = ownerId;
    t.Description = description;
    t.Region__c = region;
    t.Division__c = division; 
    t.Type = type;
    t.Priority = priority;
    t.Status = status; 

    return t;

  }

  public static Sales_Champion__c createSalesChampion(Id accountId, String region, String championType, Id userId){
    
    Sales_Champion__c sc = new Sales_Champion__c();

    sc.Account__c = accountId;
    sc.Region__c = region;
    sc.Champion_Type__c = championType;
    sc.Sales_Champion__c = userId;
            

    return sc;

  }

  public static EventRelation createEventRelation(Id eId, Id rId, Boolean parent, Boolean invitee){

    EventRelation er = new EventRelation();

    er.EventId = eId;
    er.RelationId = rId;
    er.IsParent = parent;
    er.IsInvitee = invitee;

    return er;
  }

  public static Event createEvent(String recordTypeDeveloperName, Id whoId, String type){

    Event e = new Event();

    RecordType actualRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = :recordTypeDeveloperName ];

    if(actualRecordType != null){
      e.RecordTypeId = actualRecordType.Id;
    }
    e.IsServiceStatsSummarized__c = false;

    if(recordTypeDeveloperName == 'DealAxis_Event_Integration'){
        e.Subject = 'Test DA';
        e.OwnerId = UserInfo.getUserId();
        e.Type = type;
        e.Event_Type__c  = 'External Speaker';
        e.StartDateTime = System.now();
        e.EndDateTime = System.now() + 1;
        e.WhoId = whoId;
    }else{
        e.Subject = 'Test CP';
        e.OwnerId = UserInfo.getUserId();
        e.Type = type;
        e.StartDateTime = System.now();
        e.EndDateTime = System.now() + 1;
        e.WhoId = whoId;
    }

    return e;
  }

  public static Account_Service_Model__c createAccountSeviceModel(String name, Id recordTypeId, String itemname, String daEventType, String daEventMeetingType){

    Account_Service_Model__c asm = new Account_Service_Model__c();
    asm.Name = name;
    asm.RecordTypeId = recordTypeId;
    asm.Item_Name__c = itemname;
    //asm.dealaxis_event_type__c = daEventType;
    //asm.DealAxis_Event_Meeting_Type__c = daEventMeetingType;
      asm.DealAxis_Type__c = daEventType+'~'+daEventMeetingType;
    asm.Order__c = 1;
    asm.stable_version__c = 1;
    asm.External_Id__c = 'abc';


    return asm;
  }

  public static Revenue_Rollup__c createRevenueRollup(String accountId, String accountRDMOrgId){

    Revenue_Rollup__c rr = new Revenue_Rollup__c();
    rr.Account__c = accountId;  
    rr.RG_Id__c = accountRDMOrgId;  
    rr.FYTD_Gross_YEN__c = 1234567898;
    rr.FYTD_Net_YEN__c   = 434343;
    rr.QTD_Gross_YEN__c = 2367865;
    rr.QTD_Net_YEN__c = 34334343;
    rr.WTD_Gross_YEN__c = 3223144;  
    rr.WTD_Net_YEN__c = 45554354;
    rr.Daily_Gross_YEN__c  = 7676754;
    rr.Daily_Net_YEN__c  = 6464690;
    rr.MTD_Gross_YEN__c = 434234234;
    rr.MTD_Net_YEN__c   = 45326453;

    return rr;
  }

  public static Coverage_Team_Member__c createCoverageTeamMember(String accountId, String accountRDMOrgId){

    Coverage_Team_Member__c ctm = new Coverage_Team_Member__c();
    ctm.Account__c = accountId;  
    
    return ctm;
  }

  public static SCH_Request__c createSchRequest(String rmAccName, String rmClientLoc,  String clientType, String legalEntStage, 
      String rgAcc, String rgAccName, 
      String rsAcc, String rsAccName, String rsClientLoc,
      Boolean isCommit) {
	  Id createProspectRecordTypeId = Schema.SObjectType.Sch_Request__c.getRecordTypeInfosByDeveloperName().get('Create_RM_Prospect').getRecordTypeId();
    SCH_Request__c oSchReq = new SCH_Request__c();
    oSchReq.RM_Account_Name__c = rmAccName;
    oSchReq.RM_Client_Location__c = rmClientLoc;
    oSchReq.Client_Type__c = clientType;
    oSchReq.Sales_Client_Type__c = 'BANKS';
    oSchReq.Legal_Entity_Stage__c = legalEntStage;
	oSchReq.Status__c = 'In Review';
   	oSchReq.Is_Final_Approval_Completed__c = true;
    oSchReq.RG_Account__c = rgAcc;
    oSchReq.RG_Account_Name__c = rgAccName;

    oSchReq.RS_Account__c = rsAcc;
    oSchReq.RS_Account_Name__c = rsAccName;
    oSchReq.RS_Client_Location__c = rsClientLoc;
    oSchReq.RecordTypeId = createProspectRecordTypeId;
          System.debug('--oSchReq--' + oSchReq);
    if(isCommit) {
      insert oSchReq;
    }
    return oSchReq;
  }

  public static Bloomberg_Entity_Data__c createBloombergEntData(String ID_BB_COMPANY, String COMPANY_LEGAL_NAME, String CNTRY_OF_DOMICILE, 
      String ID_BB_PARENT_CO, String LONG_COMP_NAME, String LONG_PARENT_COMP_NAME, String ID_BB_ULTIMATE_PARENT_CO, String LONG_ULT_PARENT_COMP_NAME, String Status,      
      Boolean isCommit) {
    Bloomberg_Entity_Data__c oBbgEntData = new Bloomberg_Entity_Data__c();
    oBbgEntData.Name = ID_BB_COMPANY;
    oBbgEntData.COMPANY_LEGAL_NAME__c = COMPANY_LEGAL_NAME;
    oBbgEntData.CNTRY_OF_DOMICILE__c = CNTRY_OF_DOMICILE;
    oBbgEntData.ID_BB_PARENT_CO__c = ID_BB_PARENT_CO;
    oBbgEntData.LONG_COMP_NAME__c = LONG_COMP_NAME;
    oBbgEntData.LONG_PARENT_COMP_NAME__c = LONG_PARENT_COMP_NAME;
    oBbgEntData.ID_BB_ULTIMATE_PARENT_CO__c = ID_BB_ULTIMATE_PARENT_CO;
    oBbgEntData.LONG_ULT_PARENT_COMP_NAME__c = LONG_ULT_PARENT_COMP_NAME;
    oBbgEntData.Status__c = Status;
    if(isCommit) {
      insert oBbgEntData;
    }
    return oBbgEntData;
  }
  
  public static Fenergo_Case__c createFenergoCase(String preObReqId, String caseName, Integer caseId, String caseType, String caseStatus, Integer rMId, 
          Integer legalEntityId, String legalEntityName, String bookingEntityName, String productType, String productCategory,
          Boolean isCommit) {
    Fenergo_Case__c oFenCase = new Fenergo_Case__c();
    oFenCase.Onboarding_Request__c = preObReqId;
    oFenCase.CaseName__c = caseName;
    oFenCase.CaseId__c = caseId;
    oFenCase.CaseStatus__c = caseStatus;
    oFenCase.RMId__c = rMId;
    oFenCase.LegalEntityId__c = legalEntityId;
    oFenCase.LegalEntityName__c = legalEntityName;
    oFenCase.CaseType__c = caseType;
    oFenCase.BookingEntityName__c = bookingEntityName;
    oFenCase.ProductType__c = productType;
    oFenCase.ProductCategory__c = productCategory;
    if(isCommit) {
      insert oFenCase;
    }
    return oFenCase;
  }

  public static Fenergo_Case_Stage__c createFenergoCaseStage(String stageName, Integer stageNumber, Integer caseId, 
        String fenergoCaseId, Integer legalEntityId, DateTime stageStatusTime, Boolean isCommit) {
    Fenergo_Case_Stage__c oFenCaseStage = new Fenergo_Case_Stage__c();
      oFenCaseStage.StageName__c = stageName;
      oFenCaseStage.StageNumber__c = stageNumber;
      oFenCaseStage.CaseId__c = caseId;
      oFenCaseStage.Fenergo_Case__c = fenergoCaseId;
      oFenCaseStage.LegalEntityId__c = legalEntityId;
      oFenCaseStage.StageStatusTime__c = stageStatusTime;
      //oFenCaseStage.StageStartTime__c = stageStartTime;
      //oFenCaseStage.StageEndTime__c = stageEndTime;
    if(isCommit) {
      insert oFenCaseStage;
    }
    return oFenCaseStage; 
  }

  public static Fenergo_Task__c createFenergoTask(String taskName, Integer taskId, Integer taskTemplateId, String taskStatus, 
          Integer caseId, String caseStage, String assignedTo, Boolean isCommit) {
    Fenergo_Task__c oFenTask = new Fenergo_Task__c();
    oFenTask.TaskName__c = taskName;
    oFenTask.TaskId__c = taskId;
    oFenTask.TaskTemplateId__c = taskTemplateId;
    oFenTask.CaseStage__c = caseStage;
    oFenTask.CaseId__c = caseId; 
    oFenTask.TaskStatus__c = taskStatus;
    oFenTask.AssignedTo__c = assignedTo;
    if(isCommit) {
      insert oFenTask;
    }
    return oFenTask; 
  }
    
    public static Onboarding_Request__c createOnboardingRequest(String recordTypeDevName, String contactId, String howDoYouKnowClient, String howLongHaveYouKnownClient, 
                                                                Decimal estRevenuePAFromClient, String revenueEstimatedBasedOnPrevRel, String didYouOriginateClientRel, 
                                                                String awareOfMatterInPublicDomain, Id salesRequestorId, Id requestorId, Id legalEntityId) {
        Onboarding_Request__c obRequest = new Onboarding_Request__c(
            RecordTypeId = getRecordTypeIdFromDevName('Onboarding_Request__c', recordTypeDevName),
            Confirmation_for_face_to_face_meeting__c = 'Yes',
            Who_did_you_meet_from_the_client_side__c = contactId,
            How_do_you_know_of_this_client__c = howDoYouKnowClient,
            How_long_have_you_known_them__c = howLongHaveYouKnownClient,
            Estimated_Revenue_p_a_USD_from_client__c = estRevenuePAFromClient,
            Revenue_estimate_based_on_prior_rltnshp__c = revenueEstimatedBasedOnPrevRel,
            Did_you_originate_this_client_rltnshp__c = didYouOriginateClientRel,
            Are_you_aware_of_matter_in_public_domain__c = awareOfMatterInPublicDomain,
            Sales_Requestor__c = salesRequestorId,
            Requestor__c = requestorId,
            RM_Account__c = legalEntityId
        );
        return obRequest;
    }
    
    public static Onboarding_Product__c createOnboardingProduct(String productCategory, String productType, String obRequestId, String proposedPriority, String areTradingInPrincipal,
                                                               String avgMonthlyFreq, String avgMonthlyTransactionSize, String registeredAsAuthorisedPerson,
                                                               String tradingRelevanceToMarket, String tradingDeskRankMonetisation, String salesLocation, 
                                                               List<String> nomuraEntityBeingOnboarded, String traderLocation) {

    Schema.DescribeFieldResult fieldResult = Onboarding_Product__c.Justification_for_the_entity__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    String justificationForEntityValue = ple[0].getLabel();

 		Onboarding_Product__c obProduct = new Onboarding_Product__c(
        	Products_Category__c = productCategory,
            Product_Type__c = productType,
            Market_Standard_Settlements__c = productCategory == 'Cash' ? 'Standard' : null,
            Justification_for_the_entity__c = justificationForEntityValue,
            Market_Standard_Settlement_Justification__c = 'Test',
            Onboarding_Request__c = obRequestId, 
            Proposed_Priority__c = proposedPriority,
            Additional_Priority_Justification__c = (proposedPriority == 'Urgent' || proposedPriority == 'High') ? 'Test Priority' : null,
            Are_you_trading_in_principal_with_client__c = areTradingInPrincipal,
            Anticipated_Avg_Monthly_Frequency__c = avgMonthlyFreq,
            Anticipated_Avg_Monthly_Transaction_Size__c = avgMonthlyTransactionSize,
            Are_You_Registered_As_Authorised_Person__c = registeredAsAuthorisedPerson,
            Trading_Desk_Rank_Relevance_To_Market__c = tradingRelevanceToMarket,
            Trading_Desk_Rank_Monetisation_Of_Flow__c = tradingDeskRankMonetisation,
            Sales_Location__c = salesLocation,
            Nomura_Entity_client_being_onboarded_to__c = (nomuraEntityBeingOnboarded != null && !nomuraEntityBeingOnboarded.isEmpty()) ? String.join(nomuraEntityBeingOnboarded, ';') : null,
            Trader_Location__c = traderLocation
        );
        return obProduct;                                                           
    }
    
    public static String getRecordTypeIdFromDevName(String objectAPIName, String recordTypeDevName) {
        return Schema.getGlobalDescribe().get(objectAPIName).getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();
    }
    
    public static List<String> getOnboardingBookingEntities() {
        List<String> bookingEntities = new List<String> ();
        Schema.DescribeFieldResult fieldResult = Onboarding_product__c.Nomura_Entity_client_being_onboarded_to__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry entry : ple) {
            bookingEntities.add(entry.getValue());
        }
        return bookingEntities;
    }
    
    public static Integer salesCAOProcessExists {
        get{
            List<ProcessDefinition> salesCAOProcess = [SELECT Id FROM ProcessDefinition WHERE DeveloperName = 'Onb_Req_Sales_CAO_Approval_Process' AND State = 'Active'];
            if (!salesCAOProcess.isEmpty()) {
                return 1;
            } 
            return 0;
        }
        set;
    }
}