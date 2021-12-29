@isTest
private class CoverageAccessRequestTriggerBLTest {
  static testMethod void TestCreateDeleteAccountTeamMember() {
    list<user> user = UtilityTesting.CreateUsersWithManager(4);
     
    customsettings();
    User owneruser = [select id,name,ManagerId,Manager.Name,Region__c,CountryCode,Alias from user where id =:user[1].id];
    system.debug('Manager :' + owneruser.ManagerId);
    list<Account> acctList = UtilityTesting.CreateAccounts(2);
    system.runas(user[0]){
        
      Sales_Team_For_Coverage__c salescvgTeam = new  Sales_Team_For_Coverage__c ();
      salescvgTeam.Name = 'Test';
      salescvgTeam.Sales_Team__c = 'Test Sales Team';
      salescvgTeam.Coverage_ID__c = '1234';
      salescvgTeam.Sales_Code_Login_ID__c = owneruser.Alias;
      salescvgTeam.Active__c = true;
      //salescvgTeam.OwnerId  = owneruser.id;
      
      insert salescvgTeam;
        
      system.debug('salescvgTeam.id :' + salescvgTeam.id);
        
      /* Insert Sales_Team_User__c */
      Sales_Team_User__c salesTeamUserObj = new Sales_Team_User__c();
      salesTeamUserObj.Sales_Team_for_Coverage__c = salescvgTeam.Id;
      salesTeamUserObj.User__c = owneruser.Id;
        
      insert salesTeamUserObj;
        
     List<Approver__c>   approvers = new List<Approver__c>();
     Approver__c approver = new Approver__c();
     approver.Region__c = 'Americas';
     approver.user__c = user[0].Id;
     approvers.add(approver);
     approver = new Approver__c();   
     approver.Region__c = 'Americas';
     approver.user__c = user[1].Id;
     approvers.add(approver);
     
     insert approvers;
      
      
      Revenue_Rollup__c revRollup = new Revenue_Rollup__c();
      revRollup.RM__c= acctList[0].id;
      insert revRollup;
      
      Coverage_Access_Request__c covgReq = new Coverage_Access_Request__c();
      covgReq.account__c = acctList[0].id;
      covgReq.Approved__c = true; 
      covgReq.Requested_for_User__c =  user[1].Id;  
      //covgReq.Ownerid = owneruser.id;
      
      system.debug('++++'+covgreq);
      system.debug('+++'+userinfo.getuserid());
      
      account acc = [select id,name,ownerid from account where id=:acctList[0].id];
      Sales_Team_For_Coverage__c salescvg = [SELECT Id FROM Sales_Team_For_Coverage__c WHERE Id =: salescvgTeam.id];  
      system.debug('+++'+acc.ownerid);
      covgReq.Sales_Team_for_Coverage__c = salescvg.id;    
        
        try{ 
            insert covgReq;
        }
         catch(exception ex){            
             
            if(string.valueOf(ex.getMessage()).contains('FIELD_FILTER_VALIDATION_EXCEPTION'))
              System.debug('Exception in RGCvgReqCrtMultipleRMReqTriggerBL_Test : '+ ex.getMessage());
          }
      
      
      Coverage_Access_Request__c covgReq1 = new Coverage_Access_Request__c();
      covgReq1.account__c = acctList[0].id;
        covgReq1.Approved__c = false; 
        covgReq1.Requested_for_User__c =  user[1].Id;  
      //covgReq1.Ownerid = owneruser.id;
      covgReq1.Sales_Team_for_Coverage__c = salescvgTeam.id;
      
      try{     
      insert covgReq1; 
      }catch(exception ex){            
             
            if(string.valueOf(ex.getMessage()).contains('FIELD_FILTER_VALIDATION_EXCEPTION'))
              System.debug('Exception in CoverageAccessRequestTriggerBLTest : '+ ex.getMessage());
          }

      
      Coverage_Access_Request__c covgReq2 = new Coverage_Access_Request__c();
      covgReq2.account__c = acctList[1].id;
      covgReq2.Approved__c = false;
        covgReq2.Requested_for_User__c =  user[1].Id;  
      //covgReq2.Ownerid = owneruser.id;  
      covgReq2.Sales_Team_for_Coverage__c = salescvgTeam.id;
       try{    
      insert covgReq2;
    }catch(exception ex){            
             
            if(string.valueOf(ex.getMessage()).contains('FIELD_FILTER_VALIDATION_EXCEPTION'))
              System.debug('Exception in CoverageAccessRequestTriggerBLTest : '+ ex.getMessage());
          }
      
     List<Coverage_Access_Request__c> req = [select id,Approved__c from Coverage_Access_Request__c  where id = : covgReq2.id];
        for(Coverage_Access_Request__c request : req){
       request.Approved__c =true;
     }
      update req;
     
    }
      
    Sales_Team_For_Coverage__c salescvgTeam = new  Sales_Team_For_Coverage__c ();
    salescvgTeam.Name = 'Test Sales Team';
    salescvgTeam.Coverage_ID__c = '1234';
    salescvgTeam.Sales_Code_Login_ID__c = owneruser.Alias;
      
      
    insert salescvgTeam;
      
    /* Insert Sales_Team_User__c */
    Sales_Team_User__c salesTeamUserObj = new Sales_Team_User__c();
    salesTeamUserObj.Sales_Team_for_Coverage__c = salescvgTeam.Id;
    salesTeamUserObj.User__c = owneruser.Id;
        
    insert salesTeamUserObj; 
    
    Coverage_Access_Request__c covgReq3 = new Coverage_Access_Request__c();
    covgReq3.account__c = acctList[1].id;
    covgReq3.Approved__c = false; 
    covgReq3.Sales_Team_for_Coverage__c = salescvgTeam.id; 
      covgReq3.Requested_for_User__c =  user[1].Id;  
    try{    
      insert covgReq3;
    }catch(exception ex){            
             
            if(string.valueOf(ex.getMessage()).contains('FIELD_FILTER_VALIDATION_EXCEPTION'))
              System.debug('Exception in CoverageAccessRequestTriggerBLTest : '+ ex.getMessage());
          }

    
    
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

	static testMethod void InsertCoverageAccessRequest(){
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
        userAsMgrObj.CountryCode = 'US';
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
        userAsMgrObj.CountryCode = 'US';
        userObj.UserRoleId = (userRoleObj != null ? userRoleObj.Id : null);
        userObj.ManagerId = userAsMgrObj.Id; 
        
        insert userObj;
        
        System.runas(userAsMgrObj){
            /* Insert Accounts */
            Id recordTypeIdForRM = null;
            List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType WHERE Name IN ('RM Account')];
            
             if(recordTypeList != null && recordTypeList.size() > 0){
                for(RecordType recordTypeObj : recordTypeList){
                    if('RM Account'.equalsIgnoreCase(recordTypeObj.Name)){
                        recordTypeIdForRM = recordTypeObj.Id; 
                        break;
                    }
                }
        	}
            
            Account accountRestrictedRM  = new Account();  
       		accountRestrictedRM.Name = 'RM_Account_Dummy_Restricted';
        	accountRestrictedRM.RDM_Org_ID__c = 'RMXXXXXX';            
        	accountRestrictedRM.RecordTypeId = recordTypeIdForRM;
        	accountRestrictedRM.BillingStreet = '10 Marina Boulevard, Marina Bay Financial Centre Tower 2, #36-01' ;
        	accountRestrictedRM.BillingCity = 'Japan';
        	accountRestrictedRM.BillingPostalCode = '018983';
        	accountRestrictedRM.BillingCountry = 'Japan';
            accountRestrictedRM.Domicile_Country__c = 'JP';
        	accountRestrictedRM.Active__c = TRUE; 
            accountRestrictedRM.Restricted_Flag__c = true;
            
            insert accountRestrictedRM;
            
            Account accountNonRestrictedRM  = new Account();  
       		accountNonRestrictedRM.Name = 'RM_Account_Dummy';
        	accountNonRestrictedRM.RDM_Org_ID__c = 'RMYYYYYY';            
        	accountNonRestrictedRM.RecordTypeId = recordTypeIdForRM;
        	accountNonRestrictedRM.BillingStreet = '52nd Street' ;
        	accountNonRestrictedRM.BillingCity = 'Los Angeles';
        	accountNonRestrictedRM.BillingPostalCode = '90001';
        	accountNonRestrictedRM.BillingCountry = 'United States';
            accountNonRestrictedRM.Domicile_Country__c = 'US';
        	accountNonRestrictedRM.Active__c = TRUE; 
            
            insert accountNonRestrictedRM;
        }
        
        
        System.runas(userObj){
            Test.startTest();
            
            Account accountRestrictedRM, accountNonRestrictedRM;
            
            /* Insert Sales_Team_for_Coverage__c */
            Sales_Team_for_Coverage__c salesTeamForCoverageObj = new Sales_Team_for_Coverage__c();
            salesTeamForCoverageObj.Coverage_ID__c = '1234XX';
            salesTeamForCoverageObj.Name = 'TestTemp_FN TestTemp_LN';
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
            List<Account> accountList = [SELECT Id, RDM_Org_Id__c,Domicile_Country__c, BillingCountry,Restricted_Flag__c FROM Account 
                                         WHERE RDM_Org_Id__c IN ('RMXXXXXX','RMYYYYYY')];
            
            if(accountList != null && accountList.size() > 0){
                for(Account accountObj : accountList){
                    if(accountObj.Restricted_Flag__c){
                        accountRestrictedRM = accountObj;
                    }
                    else {
                        accountNonRestrictedRM = accountObj;
                    }
                }
            }
            
            /* Insert Approvers */
            User approverUser= [SELECT Id, login_Id__c FROM User WHERE IsActive = TRUE AND Login_Id__c IN ('testMgr')];
            if(approverUser != null){
            
                List<Approver__c> approverList = new List<Approver__c>();
                
                Approver__c firstApproverObj = new Approver__c();
                firstApproverObj.Region__c = 'AEJ';
                firstApproverObj.Countries_Under_Approval__c = 'Singapore';
                firstApproverObj.User__c = approverUser.id;
                firstApproverObj.Country_Code__c = 'SG';
                approverList.add(firstApproverObj);
                
                Approver__c secondApproverObj = new Approver__c();
                secondApproverObj.Region__c = 'Japan';
                secondApproverObj.Countries_Under_Approval__c = 'Japan';
                secondApproverObj.User__c = approverUser.id;
                 secondApproverObj.Country_Code__c = 'JP';
                approverList.add(secondApproverObj);
                
                insert approverList;
                
            }
            
            /* Insert Coverage_Access_Request__c For Restricted Account */
            /* Without Product */
            Coverage_Access_Request__c coverageRequestObj = new Coverage_Access_Request__c();
            
            coverageRequestObj.Account__c = accountRestrictedRM.Id;
            coverageRequestObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
            coverageRequestObj.Type_of_Coverage__c = 'Add';
            coverageRequestObj.Start_Date__c = Date.today();
            coverageRequestObj.Role__c = 'Primary';
            coverageRequestObj.Requested_for_User__c =  approverUser.Id;  
            
            
            
           /* try{ 
            insert coverageRequestObj;
        }
         catch(exception ex){            
             
            if(string.valueOf(ex.getMessage()).contains('FIELD_FILTER_VALIDATION_EXCEPTION'))
              System.debug('Exception in RGCvgReqCrtMultipleRMReqTriggerBL_Test : '+ ex.getMessage());
          }*/
            
            /* With Product */
            Coverage_Access_Request__c coverageRequestWithProductObj = new Coverage_Access_Request__c();
            
            coverageRequestWithProductObj.Account__c = accountRestrictedRM.Id;
            coverageRequestWithProductObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
            coverageRequestWithProductObj.Type_of_Coverage__c = 'Add';
            coverageRequestWithProductObj.Start_Date__c = Date.today();
            coverageRequestWithProductObj.Role__c = 'Primary';
            coverageRequestWithProductObj.Product__c = 'Flow Credit - USA';
            coverageRequestWithProductObj.Requested_for_User__c =  approverUser.Id;  
            coverageRequestWithProductObj.Product_Group__c = 'Fixed Income';
            //coverageRequestWithProductObj.Approved__c = TRUE;
            
             try{ 
            insert coverageRequestWithProductObj;
        }
         catch(exception ex){            
             
            if(string.valueOf(ex.getMessage()).contains('FIELD_FILTER_VALIDATION_EXCEPTION'))
              System.debug('Exception in RGCvgReqCrtMultipleRMReqTriggerBL_Test : '+ ex.getMessage());
          }
            
            /* Delete Request */
            Coverage_Access_Request__c coverageDeleteRequestObj = new Coverage_Access_Request__c();
            
            coverageDeleteRequestObj.Account__c = accountRestrictedRM.Id;
            coverageDeleteRequestObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
            coverageDeleteRequestObj.Type_of_Coverage__c = 'Delete';
            coverageDeleteRequestObj.End_Date__c = Date.today();
            coverageDeleteRequestObj.Role__c = 'Primary';
            coverageDeleteRequestObj.Requested_for_User__c =  approverUser.Id;  
            coverageDeleteRequestObj.Product__c = 'Flow Credit - USA';
            coverageDeleteRequestObj.Product_Group__c = 'Fixed Income';
            
           
            
             try{ 
            insert coverageDeleteRequestObj;
        }
         catch(exception ex){            
             
            if(string.valueOf(ex.getMessage()).contains('FIELD_FILTER_VALIDATION_EXCEPTION'))
              System.debug('Exception in RGCvgReqCrtMultipleRMReqTriggerBL_Test : '+ ex.getMessage());
          }
            
            
            /* Insert Coverage_Access_Request__c For Non Restricted Account */
            /* Without Product 
            Coverage_Access_Request__c coverageRequestForNonRestrictedAccObj = new Coverage_Access_Request__c();
            
            coverageRequestForNonRestrictedAccObj.Account__c = accountNonRestrictedRM.Id;
            coverageRequestForNonRestrictedAccObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
            coverageRequestForNonRestrictedAccObj.Type_of_Coverage__c = 'Add';
            coverageRequestForNonRestrictedAccObj.Start_Date__c = Date.today();
            coverageRequestForNonRestrictedAccObj.Requested_for_User__c =  approverUser.Id;  
            coverageRequestForNonRestrictedAccObj.Role__c = 'Primary';
            coverageRequestForNonRestrictedAccObj.Product__c = 'EMERGING MARKETS - USA';
            coverageRequestForNonRestrictedAccObj.Product_Group__c = 'Fixed Income';
            
            insert coverageRequestForNonRestrictedAccObj;*/
            
            
            
            Test.stopTest();
         }
        
    }
    
    	static testMethod void InsertCoverageAccessRequestTool(){
        Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        
        UserRole userRoleObj = [SELECT Id, Name  FROM UserRole WHERE Name LIKE 'Americas - FI - Sales%' LIMIT 1];

        Id clientApprovalRecordType = Schema.getGlobalDescribe().get('Approval_Override__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Client_Coverage').getRecordTypeId();
        Id podApprovalRecordType = Schema.getGlobalDescribe().get('Approval_Override__c').getDescribe().getRecordTypeInfosByDeveloperName().get('POD_Coverage').getRecordTypeId();
        
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
        userAsMgrObj.CountryCode = 'US';
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
        userObj.CountryCode = 'US';    
        userObj.UserRoleId = (userRoleObj != null ? userRoleObj.Id : null);
        userObj.ManagerId = userAsMgrObj.Id;         
        insert userObj;
        
        System.runas(userAsMgrObj){
            /* Insert Accounts */
            Id recordTypeIdForRM = null;
            List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType WHERE Name IN ('RM Account')];
            
             if(recordTypeList != null && recordTypeList.size() > 0){
                for(RecordType recordTypeObj : recordTypeList){
                    if('RM Account'.equalsIgnoreCase(recordTypeObj.Name)){
                        recordTypeIdForRM = recordTypeObj.Id; 
                        break;
                    }
                }
        	}
            
            Account accountRestrictedRM  = new Account();  
       		accountRestrictedRM.Name = 'RM_Account_Dummy_Restricted';
        	accountRestrictedRM.RDM_Org_ID__c = 'RMXXXXXX';            
        	accountRestrictedRM.RecordTypeId = recordTypeIdForRM;
        	accountRestrictedRM.BillingStreet = '10 Marina Boulevard, Marina Bay Financial Centre Tower 2, #36-01' ;
        	accountRestrictedRM.BillingCity = 'Japan';
        	accountRestrictedRM.BillingPostalCode = '018983';
        	accountRestrictedRM.BillingCountry = 'Japan';
            accountRestrictedRM.Domicile_Country__c = 'JP';
        	accountRestrictedRM.Active__c = TRUE; 
            accountRestrictedRM.Restricted_Flag__c = true;
            
            insert accountRestrictedRM;
            system.debug('accountRestrictedRM : '+accountRestrictedRM.Id);
            
            Account accountNonRestrictedRM  = new Account();  
       		accountNonRestrictedRM.Name = 'RM_Account_Dummy';
        	accountNonRestrictedRM.RDM_Org_ID__c = 'RMYYYYYY';            
        	accountNonRestrictedRM.RecordTypeId = recordTypeIdForRM;
        	accountNonRestrictedRM.BillingStreet = '52nd Street' ;
        	accountNonRestrictedRM.BillingCity = 'Los Angeles';
        	accountNonRestrictedRM.BillingPostalCode = '90001';
        	accountNonRestrictedRM.BillingCountry = 'United States';
            accountNonRestrictedRM.Domicile_Country__c = 'US';
        	accountNonRestrictedRM.Active__c = TRUE; 
            
            insert accountNonRestrictedRM;
            system.debug('accountNonRestrictedRM 2 : '+accountNonRestrictedRM.Id);

            //Approval Override
            List<Approval_Override__c> approvalList = new List<Approval_Override__c>();
            Approval_Override__c approval = new Approval_Override__c();
            approval.Description__c = 'Approval Override for Americas - FI';
            approval.Business_Approver_1__c = userAsMgrObj.Id;
            approval.Business_Approver_2__c = userAsMgrObj.Id;
            approval.RecordTypeId = clientApprovalRecordType;
            approval.Criteria__c = 'Americas - FI';
            approval.Criteria_Type__c = 'Role begins with';
            approval.Manager_Override__c = false;
            approvalList.add(approval);

            Approval_Override__c approval1 = new Approval_Override__c();
            approval1.Description__c = 'Approval Override for Americas - FI';
            approval1.Business_Approver_1__c = userAsMgrObj.Id;
            approval1.Business_Approver_2__c = userAsMgrObj.Id;
            approval1.RecordTypeId = podApprovalRecordType;
            approval1.Criteria__c = 'Americas - FI';
            approval1.Criteria_Type__c = 'Role begins with';
            approval1.Manager_Override__c = false;
            approvalList.add(approval1);

            Approval_Override__c approval2 = new Approval_Override__c();
            approval2.Description__c = 'Approval Override for Sales';
            approval2.Business_Approver_1__c = userAsMgrObj.Id;
            approval2.Business_Approver_2__c = userAsMgrObj.Id;
            approval2.RecordTypeId = clientApprovalRecordType;
            approval2.Criteria__c = 'Sales';
            approval2.Criteria_Type__c = 'Role contains';
            approval2.Manager_Override__c = true;
            approvalList.add(approval2);

            Approval_Override__c approval3 = new Approval_Override__c();
            approval3.Description__c = 'Approval Override for Americas - FI,Sales';
            approval3.Business_Approver_1__c = userAsMgrObj.Id;
            approval3.Business_Approver_2__c = userAsMgrObj.Id;
            approval3.RecordTypeId = podApprovalRecordType;
            approval3.Criteria__c = 'Americas - FI, Sales';
            approval3.Criteria_Type__c = 'Role contains';
            approval3.Manager_Override__c = true;
            approvalList.add(approval3);
            insert approvalList;            
        }
        
        
        System.runas(userObj){
            Test.startTest();
            
            Account accountRestrictedRM, accountNonRestrictedRM;
            
            /* Insert Sales_Team_for_Coverage__c */
            Sales_Team_for_Coverage__c salesTeamForCoverageObj = new Sales_Team_for_Coverage__c();
            salesTeamForCoverageObj.Coverage_ID__c = '1234XX';
            salesTeamForCoverageObj.Name = 'TestTemp_FN TestTemp_LN';
            salesTeamForCoverageObj.Sales_Team__c = 'Test Team';
            salesTeamForCoverageObj.Sales_Desk_Region__c = 'USA';
            salesTeamForCoverageObj.Sales_Desk_Division__c = 'Fixed Income';
            salesTeamForCoverageObj.Sales_Code_Login_ID__c = userObj.Login_Id__c;
            salesTeamForCoverageObj.Active__c = TRUE;
            salesTeamForCoverageObj.is_Dummy__c = false;
            insert salesTeamForCoverageObj;
            
            /* Insert Sales_Team_User__c */
            Sales_Team_User__c salesTeamUserObj = new Sales_Team_User__c();
            salesTeamUserObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
            salesTeamUserObj.User__c = userObj.Id;
            salesTeamUserObj.Source_Id__c = salesTeamForCoverageObj.Coverage_ID__c + '#' + userObj.Login_Id__c;
            
            insert salesTeamUserObj;
            
            //Fetch Accounts
            List<Account> accountList = [SELECT Id, RDM_Org_Id__c, Domicile_Country__c,BillingCountry,Restricted_Flag__c FROM Account 
                                         WHERE RDM_Org_Id__c IN ('RMXXXXXX','RMYYYYYY')];
            
            system.debug('accountList size: '+accountList.size());
            
            if(accountList != null && accountList.size() > 0){
                for(Account accountObj : accountList){
                    if(accountObj.Restricted_Flag__c){
                        accountRestrictedRM = accountObj;
                    }
                    else {
                        accountNonRestrictedRM = accountObj;
                    }
                }
            }
            
            /* Insert Approvers */
            User approverUser= [SELECT Id, login_Id__c FROM User WHERE IsActive = TRUE AND Login_Id__c IN ('testMgr')];
            if(approverUser != null){
            
                List<Approver__c> approverList = new List<Approver__c>();
                
                Approver__c firstApproverObj = new Approver__c();
                firstApproverObj.Region__c = 'AEJ';
                firstApproverObj.Countries_Under_Approval__c = 'Singapore';
                firstApproverObj.User__c = approverUser.id;
                firstApproverObj.Country_Code__c = 'SG';
                approverList.add(firstApproverObj);
                
                Approver__c secondApproverObj = new Approver__c();
                secondApproverObj.Region__c = 'Japan';
                secondApproverObj.Countries_Under_Approval__c = 'Japan';
                secondApproverObj.User__c = approverUser.id;
                secondApproverObj.Country_Code__c = 'JP';
                approverList.add(secondApproverObj);
                
                insert approverList;
                
            }
            
            /* Insert Coverage_Access_Request__c For Restricted Account */
            /* Without Product */
            Coverage_Access_Request__c coverageRequestObj = new Coverage_Access_Request__c();
            
            coverageRequestObj.Account__c = accountRestrictedRM.Id;
            coverageRequestObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
            coverageRequestObj.Type_of_Coverage__c = 'Add';
            coverageRequestObj.Start_Date__c = Date.today();
            coverageRequestObj.Requested_for_User__c =  approverUser.Id;  
            coverageRequestObj.Role__c = 'Primary';
            coverageRequestObj.SourceUpload__c = 'Tool';
            
            
            
         /*    try{ 
            insert coverageRequestObj;
        }
         catch(exception ex){            
             
            if(string.valueOf(ex.getMessage()).contains('FIELD_FILTER_VALIDATION_EXCEPTION'))
              System.debug('Exception in RGCvgReqCrtMultipleRMReqTriggerBL_Test : '+ ex.getMessage());
          }*/
            /* With Product */
            Coverage_Access_Request__c coverageRequestWithProductObj = new Coverage_Access_Request__c();
            
            coverageRequestWithProductObj.Account__c = accountRestrictedRM.Id;
            coverageRequestWithProductObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
            coverageRequestWithProductObj.Type_of_Coverage__c = 'Add';
            coverageRequestWithProductObj.Start_Date__c = Date.today();
            coverageRequestWithProductObj.Role__c = 'Primary';
            coverageRequestWithProductObj.Product__c = 'Flow Credit - USA';
            coverageRequestWithProductObj.Requested_for_User__c =  approverUser.Id;  
            coverageRequestWithProductObj.Product_Group__c = 'Fixed Income';
            coverageRequestWithProductObj.SourceUpload__c = 'Tool';
            
            
             try{ 
            insert coverageRequestWithProductObj;
        }
         catch(exception ex){            
             
            if(string.valueOf(ex.getMessage()).contains('FIELD_FILTER_VALIDATION_EXCEPTION'))
              System.debug('Exception in RGCvgReqCrtMultipleRMReqTriggerBL_Test : '+ ex.getMessage());
          }
            
            /* Nonrestricted without product */
            Coverage_Access_Request__c cvgAddNonRestricted = new Coverage_Access_Request__c();
            cvgAddNonRestricted.Account__c = accountNonRestrictedRM.Id;
            cvgAddNonRestricted.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
            cvgAddNonRestricted.Type_of_Coverage__c = 'Add';
            cvgAddNonRestricted.Start_Date__c = Date.today();
            cvgAddNonRestricted.Requested_for_User__c =  approverUser.Id;  
            cvgAddNonRestricted.Role__c = 'Primary';
            cvgAddNonRestricted.Product__c = '';
            cvgAddNonRestricted.Product_Group__c = '';
            cvgAddNonRestricted.SourceUpload__c = 'Tool';
            cvgAddNonRestricted.Group_By__c = 'POD';
            insert cvgAddNonRestricted;
            /* Delete Request */
            Coverage_Access_Request__c coverageDeleteRequestObj = new Coverage_Access_Request__c();
            
            coverageDeleteRequestObj.Account__c = accountRestrictedRM.Id;
            coverageDeleteRequestObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
            coverageDeleteRequestObj.Type_of_Coverage__c = 'Delete';
            coverageDeleteRequestObj.End_Date__c = Date.today();
            coverageDeleteRequestObj.Requested_for_User__c =  approverUser.Id;  
            coverageDeleteRequestObj.Role__c = 'Primary';
            coverageDeleteRequestObj.Product__c = 'Flow Credit - USA';
            coverageDeleteRequestObj.Product_Group__c = 'Fixed Income';
            coverageDeleteRequestObj.SourceUpload__c = 'Tool';
           try{ 
            insert coverageDeleteRequestObj;
        }
         catch(exception ex){            
             
            if(string.valueOf(ex.getMessage()).contains('FIELD_FILTER_VALIDATION_EXCEPTION'))
              System.debug('Exception in RGCvgReqCrtMultipleRMReqTriggerBL_Test : '+ ex.getMessage());
          }
            
            
         
            
            
            /* Coverage_Access_Request__c coverageUpdateRequestForRestrictedAccObj = new Coverage_Access_Request__c();
            
            coverageUpdateRequestForRestrictedAccObj.Account__c = accountNonRestrictedRM.Id;
            coverageUpdateRequestForRestrictedAccObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
            coverageUpdateRequestForRestrictedAccObj.Type_of_Coverage__c = 'Update';
            coverageUpdateRequestForRestrictedAccObj.Start_Date__c = Date.today();
            coverageUpdateRequestForRestrictedAccObj.Requested_for_User__c =  approverUser.Id;  
            coverageUpdateRequestForRestrictedAccObj.Role__c = 'Primary';
            coverageUpdateRequestForRestrictedAccObj.Product__c = 'EMERGING MARKETS - USA';
            coverageUpdateRequestForRestrictedAccObj.Product_Group__c = 'Fixed Income';
            coverageUpdateRequestForRestrictedAccObj.SourceUpload__c = 'Tool';
            insert coverageUpdateRequestForRestrictedAccObj;
             system.debug('IMP: '+coverageUpdateRequestForRestrictedAccObj);*/
            Test.stopTest();
         } 
            
        
    }
  
  
 
}