@isTest
public class OpportunityTriggerHandler_Test {
    public static User userAsMgrObj; 
    public static User userObj;
    public static User userRefereeAsMgrObj;
    public static User userRefereeObj;
	public static User sfadminUser;
    public static Contact contactInstinetObj;
	public static Account account2;
	public static Account account3;
	public static Account instinetAccount;
	public static Account nomuraAccG;
	public static Profile profileNomuraSales;
    
    @isTest static void TestDeleteOpportunity(){
        Test.starttest();
        Id recordTypeIdForRG = CommonTools.getRecordTypeId('Account','RG Account');

        Account account = new Account(); 
        account.Name = 'RG_Account_Dummy';
        account.RDM_Org_ID__c = 'RGXXXXXX';            
        account.RecordTypeId = recordTypeIdForRG;
        account.Active__c = TRUE;         
        insert account;
        
        //Creating Opportunity Data
        List<Opportunity> opptyList = new List<Opportunity>();
        Opportunity opptyObj1 = new Opportunity();
        opptyObj1.Name='TestOppo1';
        opptyObj1.Account__c=account.Id;
        opptyObj1.CloseDate=DATE.today();
        opptyObj1.StageName='Closed Won';
        opptyList.add(opptyObj1);
        
        Opportunity opptyObj2 = new Opportunity();
        opptyObj2.Name='TestOppo2';
        opptyObj2.Account__c=account.Id;
        opptyObj2.CloseDate=DATE.today();
        opptyObj2.StageName='Closed Won';
        opptyList.add(opptyObj2);

        insert opptyList;
        System.debug('-------new oppty-------' + opptyObj1 + ' and ' + opptyObj2);

        Task newTask  = new Task();
        newTask.Subject = 'Test Task';
        newTask.Type = 'Internal account review';
        newTask.WhatId = opptyObj2.Id;
        insert newTask;
        System.debug('-------newTask-------' + newTask);

        Boolean isSuccess =false;

        try{
            delete opptyObj1;
            isSuccess = true;
        }Catch (DMLException e){
			isSuccess = false;
		}
        System.assertEquals(true, isSuccess);
        isSuccess = false;
        try{
            delete opptyObj2;
            isSuccess = false;
        }Catch (DMLException e){ 
            isSuccess = true;
        }       
        System.assertEquals(true, isSuccess); 
        Test.stopTest();
     }
     
    @isTest static void TestCreateOPPT(){
         
         Test.starttest();
         Opportunity opp = null;
         if(userRefereeAsMgrObj==null){
			userRefereeAsMgrObj = [SELECT Id, Name FROM USER WHERE Login_ID__c = 'testMgr1'];
		 }
         if(userObj==null){
			userObj = [SELECT Id, Name FROM USER WHERE Login_ID__c = 'testtmp'];
		 }
		 if(userAsMgrObj==null){		 
			userAsMgrObj = [SELECT Id, Name FROM USER WHERE Login_ID__c = 'testMgr'];
         }
		 if(userRefereeObj==null){
			userRefereeObj = [SELECT Id, Name FROM USER WHERE Login_ID__c = 'testtmp1'];
         }
		 if(contactInstinetObj==null){
			contactInstinetObj = [SELECT Id, Name FROM Contact WHERE Login_ID__c = 'instinetTest'];
         }
         if(account2==null){
            account2 = [SELECT Id, Name From Account where Name = 'TestAccount2' Limit 1];
         }
         if(account3==null){
            account3 = [SELECT Id, Name From Account where Name = 'TestAccount3' Limit 1];
         }
         System.runas(userAsMgrObj){
             //updated label Active Opportunity to Opportunity 
              opp = new Opportunity(Name=account2.Name + ' Opportunity',
          				                     StageName='Referral Requested',
                                             CloseDate=System.today().addMonths(1),
                                             Account__c=account2.Id,
                                             Referral__c = userObj.Id,
                                             Referee__c = userRefereeAsMgrObj.Id,
                                             ProductVal__c ='AGENCY MORTGAGES',
                                             Product_Region__c = 'Fixed Income - USA',   
                                             RecordTypeId = CommonTools.getRecordTypeIdUsingDeveloperName('Opportunity','Cross_Sell_Referral'));
             insert opp;
             
             Opportunity oppAtTeamLevel = new Opportunity(Name=account3.Name + ' Opportunity',
          				                     StageName='Referral Requested',
                                             CloseDate=System.today().addMonths(1),
                                             Account__c=account3.Id,
                                             Referral__c = userObj.Id,
                                             Referee__c = userRefereeAsMgrObj.Id,
                                             ProductVal__c ='{CVA}CVA CFS',
                                             Product_Region__c = 'Fixed Income - USA',   
                                             Referral_Type__c = 'Team',             
                                             RecordTypeId = CommonTools.getRecordTypeIdUsingDeveloperName('Opportunity','Cross_Sell_Referral'));
             insert oppAtTeamLevel;


             try{
                 Opportunity opp1 = new Opportunity(Name=account2.Name + ' Opportunity',
          				                     StageName='Referral Request',
                                             CloseDate=System.today().addMonths(1),
                                   
                                                    Account__c=account2.Id,
                                             ProductVal__c ='AGENCY MORTGAGES',
                                             Product_Region__c = 'Fixed Income - USA',   
                                             RecordTypeId = CommonTools.getRecordTypeIdUsingDeveloperName('Opportunity','Cross_Sell_Referral'));
                 insert opp1;
             }
             catch(Exception ex){
                 system.debug('exception **'+ex.getMessage());
                 //system.assertEquals(ex.getMessage().contains('Either Referred Nomura User or Referred Instinet User is mandatory for Cross Sell'),true);
             } 
             try{
                 Opportunity opp2 = new Opportunity(Name=account2.Name + ' Opportunity',
          				                     StageName='Referral Request',
                                             CloseDate=System.today().addMonths(1),
                                             Account__c=account2.Id,
                                             Referral__c = userObj.Id,
                                             ProductVal__c ='AGENCY MORTGAGES',
                                             Product_Region__c = 'Fixed Income - USA',   
                                             RecordTypeId = CommonTools.getRecordTypeIdUsingDeveloperName('Opportunity','Cross_Sell_Referral'));
                 insert opp2;
             }
             catch(Exception ex){
                 system.debug('exception **'+ex.getMessage());
                 //system.assertEquals(ex.getMessage().contains('The request for this Account and Product already exists'),true);
             }  
             
             try{
                 Opportunity opp3 = new Opportunity(Name=account2.Name + ' Opportunity',
          				                     StageName='Referral Request',
                                             CloseDate=System.today().addMonths(1),
                                             Account__c=account2.Id,
                                             Referral__c = userObj.Id,
                                             ProductVal__c ='AGENCY MORTGAGES',
                                             Product_Region__c = 'Fixed Income - USA',
                                             Referral_Type__C = 'Team',       
                                             RecordTypeId = CommonTools.getRecordTypeIdUsingDeveloperName('Opportunity','Cross_Sell_Referral'));
                 insert opp3;
             }
             catch(Exception ex){
                 system.debug('exception **'+ex.getMessage());
             }
             
             try{
                 Opportunity opp4 = new Opportunity(Name=account3.Name + ' Opportunity',
          				                     StageName='Referral Request',
                                             CloseDate=System.today().addMonths(1),
                                             Account__c=account3.Id,
                                             Referral__c = userObj.Id,
                                             ProductVal__c ='CVA',
                                             Product_Region__c = 'Fixed Income - USA',
                                             Referral_Type__C = 'Team',       
                                             RecordTypeId = CommonTools.getRecordTypeIdUsingDeveloperName('Opportunity','Cross_Sell_Referral'));
                 insert opp4;
             }
             catch(Exception ex){
                 system.debug('exception **'+ex.getMessage());
                 //system.assertEquals(ex.getMessage().contains('The request for this Account and Product already exists'),true);
             }
             
         }
         
         system.runas(userObj){     
              Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
              req.setComments('Approving request for Opportunity');             
              //Approve or Reject Record
              req.setAction('Approve');
              List<ProcessInstanceWorkitem> pItems = [Select Id from ProcessInstanceWorkitem  where ProcessInstance.TargetObjectId =: opp.id];
              if(pItems.size()>0)
              {req.setWorkitemId(pItems[0].Id); 
              Approval.ProcessResult result = Approval.process(req);
              system.debug('result **'+result);
             }
         }
         system.runas(userAsMgrObj){
             Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
             req.setComments('Approving request for Opportunity');             
             //Approve or Reject Record
             req.setAction('Approve');
             List<ProcessInstanceWorkitem> pItems = [Select Id from ProcessInstanceWorkitem  where ProcessInstance.TargetObjectId =: opp.id];
             if(pItems.size()>0)
             {req.setWorkitemId(pItems[0].Id); 
             Approval.ProcessResult result = Approval.process(req);
             system.debug('result **'+result);
             }
         }
          Test.stoptest();
     }
    @isTest static void TestUpdateOPPT(){
         
         Test.starttest();
         Opportunity opp = null;
         system.debug('Test Class approver: '+userAsMgrObj);
         if(userRefereeAsMgrObj==null){
			userRefereeAsMgrObj = [SELECT Id, Name FROM USER WHERE Login_ID__c = 'testMgr1'];
		 }
         if(userObj==null){
			userObj = [SELECT Id, Name FROM USER WHERE Login_ID__c = 'testtmp'];
		 }
		 if(userAsMgrObj==null){		 
			userAsMgrObj = [SELECT Id, Name FROM USER WHERE Login_ID__c = 'testMgr'];
         }
        if(account2==null){
            account2 = [SELECT Id, Name From Account where Name = 'TestAccount2' Limit 1];
        }
         System.runas(userAsMgrObj){             
             System.debug('------------------in stepPass1ApproverforRG------userAsMgrObj----' + account2);
             //updated label Active Opportunity to Opportunity 
              opp = new Opportunity(Name=account2.Name + ' Opportunity',
          				                     StageName='Referral Requested',
                                             CloseDate=System.today().addMonths(1),
                                             Account__c=account2.Id,
                                             Referral__c = userObj.Id,
                                             Referee__c = userRefereeAsMgrObj.Id,
                                             ProductVal__c ='AGENCY MORTGAGES',
                                             Product_Region__c = 'Fixed Income - USA',   
                                             RecordTypeId = CommonTools.getRecordTypeIdUsingDeveloperName('Opportunity','Cross_Sell_Referral'));
             insert opp;
             String status = OpportunityTriggerHandler.processapprovalrecords(opp.Id, 'Invalidated');
             status = OpportunityTriggerHandler.saveapprovalrecords(opp.Id, 'Invalidated');
             system.debug('status **'+ status);
         }
          Test.stoptest();
     }
    @isTest static void TestCreateOPPTforAdmin(){
         
        Test.starttest();
        Opportunity opp = null;
        system.debug('Test Class approver: '+userAsMgrObj);
		if(sfadminUser==null){
			sfadminUser = [SELECT Id, Login_Id__c FROM User WHERE IsActive = TRUE AND Login_Id__c = 'sfadmin' LIMIT 1];  
		}
        System.runAs(sfadminUser) {
        list<user> user = UtilityTesting.CreateUsersWithManager(4);
        List<Approver__c>   approvers = new List<Approver__c>();
        Approver__c approver = new Approver__c();
        approver.Region__c = 'AEJ';
        approver.Countries_Under_Approval__c = 'Singapore';
        approver.user__c = user[0].Id;
        approvers.add(approver);
        approver = new Approver__c();   
        approver.Region__c = 'AEJ';
        approver.Countries_Under_Approval__c = 'Singapore';
        approver.user__c = user[1].Id;
        approvers.add(approver);
        approver = new Approver__c();
        approver.Region__c = 'Americas';
        approver.user__c = user[0].Id;
        approvers.add(approver);
        approver = new Approver__c();   
        approver.Region__c = 'Americas';
        approver.user__c = user[1].Id;
        approvers.add(approver);
        
        insert approvers;
		
		if(userRefereeAsMgrObj==null){
			userRefereeAsMgrObj = [SELECT Id, Name FROM USER WHERE Login_ID__c = 'testMgr1'];
		 }
		 if(userObj==null){
			userObj = [SELECT Id, Name FROM USER WHERE Login_ID__c = 'testtmp'];
		 }
		if(account3==null){
            account3 = [SELECT Id, Name From Account where Name = 'TestAccount3' Limit 1];
        }
        
        opp = new Opportunity(Name=account3.Name + ' Opportunity',
         				                     StageName='Referral Approved',
                                             CloseDate=System.today().addMonths(1),
                                             Account__c=account3.Id,
                                             Referral__c = userObj.Id,
                                             Referee__c = userRefereeAsMgrObj.Id,
                                             ProductVal__c ='AGENCY MORTGAGES',
                                             Product_Region__c = 'Fixed Income - USA',   
                                             RecordTypeId = CommonTools.getRecordTypeIdUsingDeveloperName('Opportunity','Cross_Sell_Referral'));
        insert opp;
        Test.stoptest();    
        }        
    }
    @testSetup
    public static void createTestData()
    {
        System.debug('------------------in createTestData----------');
        if(sfadminUser==null){
			sfadminUser = [SELECT Id, Login_Id__c FROM User WHERE IsActive = TRUE AND Login_Id__c = 'sfadmin' LIMIT 1];  
		} 
        System.runAs(sfadminUser) {
            userAsMgrObj = CoverageBulkUploadTest.createManagerUser();
            userObj = CoverageBulkUploadTest.createNormalUser(userAsMgrObj.Id);
            userRefereeAsMgrObj = createRefereeManagerUser();
            userRefereeObj = createRefereeUser(userRefereeAsMgrObj.Id);            
        }        
        
        System.runas(userAsMgrObj){
            /* Insert Accounts */
            Id recordTypeIdForRM = null;
            //List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType WHERE Name IN ('RM Account')];
                       
            Id RSRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RS Account').getRecordTypeId();   
            Id RGRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();   
            Id RMRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
            Id NomuraAccRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('NOMURA EMPLOYEES').getRecordTypeId();

            Account accountAdd = new Account();
            accountAdd.Name = 'TestAccount1';
            accountAdd.RDM_Org_ID__c = 'RSXXXXXX';  
            accountAdd.BillingCity = 'California';
            accountAdd.BillingCountry = 'United States';
            accountAdd.BillingStreet = '52nd Street';
            accountAdd.RecordTypeId = RSRecordTypeId; 
            accountAdd.Active__c = TRUE; 
            insert accountAdd;    
            
            List<Account> lstAccParent = new List<Account>();       
            account2  = new Account(); 
            account2.Name = 'TestAccount2';
            account2.RDM_Org_ID__c = 'RGXXXXXX';            
            account2.RecordTypeId = RGRecordTypeId;
            account2.BillingCity = 'California';
            account2.BillingCountry = 'United States';
            account2.BillingStreet = '52nd Street';
            account2.ParentId = accountAdd.Id;
            account2.Active__c = TRUE; 
            lstAccParent.add(account2);
			

            account3  = new Account(); 
            account3.Name = 'TestAccount3';
            account3.RDM_Org_ID__c = 'RGYYYYYY';            
            account3.RecordTypeId = RGRecordTypeId;
            account3.BillingCity = 'California';
            account3.BillingCountry = 'United States';
            account3.BillingStreet = '52nd Street';
            account3.ParentId = accountAdd.Id;
            account3.Active__c = TRUE; 
            lstAccParent.add(account3);
			
            
            nomuraAccG  = new Account(); 
            nomuraAccG.Name = 'NOMURA EMPLOYEES (G)';
            nomuraAccG.RDM_Org_ID__c = 'CPG12345';            
            nomuraAccG.RecordTypeId = RGRecordTypeId;
            nomuraAccG.Active__c = TRUE; 
            lstAccParent.add(nomuraAccG);
            insert lstAccParent;    		

            List<Account> lstAcc = new List<Account>();        
            Account accountNonRestrictedRM1  = new Account();  
            accountNonRestrictedRM1.Name = 'RM_Account_Dummy_1';
            accountNonRestrictedRM1.RDM_Org_ID__c = 'RMXXXXXX';            
            accountNonRestrictedRM1.RecordTypeId = RMRecordTypeId;
            accountNonRestrictedRM1.BillingStreet = '10 Marina Boulevard, Marina Bay Financial Centre Tower 2, #36-01' ;
            accountNonRestrictedRM1.BillingCity = 'California';
            accountNonRestrictedRM1.BillingPostalCode = '76890';
            accountNonRestrictedRM1.BillingCountry = 'United States';
            accountNonRestrictedRM1.Active__c = TRUE; 
            accountNonRestrictedRM1.ParentId = account3.Id;
            lstAcc.add(accountNonRestrictedRM1);
            
            instinetAccount  = new Account();  
            instinetAccount.Name = 'INSTINET EMPLOYEES';
            instinetAccount.RDM_Org_ID__c = 'IN12345';            
            instinetAccount.RecordTypeId = NomuraAccRecordTypeId;
            instinetAccount.BillingStreet = '52nd Street' ;
            instinetAccount.BillingCity = 'California';
            instinetAccount.BillingPostalCode = '84569';
            instinetAccount.BillingCountry = 'United States';
            instinetAccount.Active__c = TRUE; 
            instinetAccount.ParentId = nomuraAccG.Id;
            lstAcc.add(instinetAccount);

            Account accountRestrictedRM  = new Account();  
            accountRestrictedRM.Name = 'RM_Account_Dummy_Restricted';
            accountRestrictedRM.RDM_Org_ID__c = 'RMZZZZZZ';            
            accountRestrictedRM.RecordTypeId = RMRecordTypeId;
            accountRestrictedRM.BillingStreet = '10 Marina Boulevard, Marina Bay Financial Centre Tower 2, #36-01' ;
            accountRestrictedRM.BillingCity = 'Singapore';
            accountRestrictedRM.BillingPostalCode = '018983';
            accountRestrictedRM.BillingCountry = 'Singapore';
            accountRestrictedRM.Active__c = TRUE; 
            accountRestrictedRM.ParentId = account2.Id;
            accountRestrictedRM.Restricted_Flag__c = TRUE;
            
            lstAcc.add(accountRestrictedRM);
            
            Account accountRestrictedRMInActive  = new Account();  
            accountRestrictedRMInActive.Name = 'RM_Account_Dummy_Restricted Inac';
            accountRestrictedRMInActive.RDM_Org_ID__c = 'RMInactive';            
            accountRestrictedRMInActive.RecordTypeId = RMRecordTypeId;
            accountRestrictedRMInActive.BillingStreet = '10 Marina Boulevard, Marina Bay Financial Centre Tower 2, #36-01' ;
            accountRestrictedRMInActive.BillingCity = 'Singapore';
            accountRestrictedRMInActive.BillingPostalCode = '018983';
            accountRestrictedRMInActive.BillingCountry = 'Singapore';
            accountRestrictedRMInActive.Active__c = False; 
            accountRestrictedRMInActive.ParentId = account2.Id;
            accountRestrictedRMInActive.Restricted_Flag__c = TRUE;
            
            lstAcc.add(accountRestrictedRMInActive);
            
            Account accountNonRestrictedRM  = new Account();  
            accountNonRestrictedRM.Name = 'RM_Account_Dummy';
            accountNonRestrictedRM.RDM_Org_ID__c = 'RMYYYYYY';            
            accountNonRestrictedRM.RecordTypeId = RMRecordTypeId;
            accountNonRestrictedRM.BillingStreet = '52nd Street' ;
            accountNonRestrictedRM.BillingCity = 'Los Angeles';
            accountNonRestrictedRM.BillingPostalCode = '90001';
            accountNonRestrictedRM.BillingCountry = 'United States';
            accountNonRestrictedRM.ParentId = account2.Id;
            accountNonRestrictedRM.Active__c = TRUE; 
            
            lstAcc.add(accountNonRestrictedRM);
            insert lstAcc;
        }
        
        System.runAs(userRefereeObj) {
            contactInstinetObj = createInstinetContact();
        }
        if(sfadminUser==null){
			sfadminUser = [SELECT Id, Login_Id__c FROM User WHERE IsActive = TRUE AND Login_Id__c = 'sfadmin' LIMIT 1]; 
		}		
        if(sfadminUser != null){
             System.runas(sfadminUser){
                /* Insert Sales_Team_for_Coverage__c */
                List<Sales_Team_for_Coverage__c> lstcov = new List<Sales_Team_for_Coverage__c>();
                Sales_Team_for_Coverage__c salesTeamForCoverageObj = new Sales_Team_for_Coverage__c();
                salesTeamForCoverageObj.Coverage_ID__c = '1234XX';
                salesTeamForCoverageObj.Name = 'TestTemp_FN TestTemp_LN';
                salesTeamForCoverageObj.Sales_Team__c = 'Test Team';
                salesTeamForCoverageObj.Sales_Team_Code__c = '123';
                salesTeamForCoverageObj.Sales_Desk_Region__c = 'USA';
                salesTeamForCoverageObj.Sales_Desk_Division__c = 'Fixed Income';
                salesTeamForCoverageObj.Sales_Code_Login_ID__c = userObj.Login_Id__c;
                salesTeamForCoverageObj.Active__c = TRUE;
                salesTeamForCoverageObj.Company__c = 'N';
                salesTeamForCoverageObj.Sales_Code_Login_ID__c = 'testtmp';
                
                lstcov.add(salesTeamForCoverageObj);
                 
                Sales_Team_for_Coverage__c salesTeamForCoverageObj1 = new Sales_Team_for_Coverage__c(); //Inactive salescode
                salesTeamForCoverageObj1.Coverage_ID__c = '1235XX';
                salesTeamForCoverageObj1.Name = 'TestTemp_FN TestTemp_LN';
                salesTeamForCoverageObj1.Sales_Team__c = 'Test Team';
                 salesTeamForCoverageObj.Sales_Team_Code__c = '123';
                salesTeamForCoverageObj1.Sales_Desk_Region__c = 'USA';
                salesTeamForCoverageObj1.Sales_Desk_Division__c = 'Fixed Income';
                salesTeamForCoverageObj1.Sales_Code_Login_ID__c = userRefereeAsMgrObj.Login_Id__c;
                salesTeamForCoverageObj1.Active__c = TRUE;
                salesTeamForCoverageObj1.Company__c = 'N';
                salesTeamForCoverageObj1.Sales_Code_Login_ID__c = 'testMgr1';
                
                lstcov.add(salesTeamForCoverageObj1);
               
                Sales_Team_for_Coverage__c salesTeamForCoverageObj2 = new Sales_Team_for_Coverage__c(); //Inactive salescode
                salesTeamForCoverageObj2.Coverage_ID__c = '1236XX';
                salesTeamForCoverageObj2.Name = 'TestTemp_FN TestTemp_LN';
                salesTeamForCoverageObj2.Sales_Team__c = 'Test Team';
                 salesTeamForCoverageObj.Sales_Team_Code__c = '123';
                salesTeamForCoverageObj2.Sales_Desk_Region__c = 'USA';
                salesTeamForCoverageObj2.Sales_Desk_Division__c = 'Fixed Income';
                salesTeamForCoverageObj2.Sales_Code_Login_ID__c = userAsMgrObj.Login_Id__c;
                salesTeamForCoverageObj2.Active__c = TRUE;
                salesTeamForCoverageObj2.Company__c = 'N';
                salesTeamForCoverageObj2.Sales_Code_Login_ID__c = 'testMgr';
                lstcov.add(salesTeamForCoverageObj2);
                 
                Sales_Team_for_Coverage__c salesTeamForCoverageObj3 = new Sales_Team_for_Coverage__c(); //Inactive salescode
                salesTeamForCoverageObj3.Coverage_ID__c = '1237XX';
                salesTeamForCoverageObj3.Name = 'TestTemp_FN TestTemp_LN';
                salesTeamForCoverageObj3.Sales_Team__c = 'Test Team';
                 salesTeamForCoverageObj.Sales_Team_Code__c = '123';
                salesTeamForCoverageObj3.Sales_Desk_Region__c = 'USA';
                salesTeamForCoverageObj3.Sales_Desk_Division__c = 'Fixed Income';
                salesTeamForCoverageObj3.Sales_Code_Login_ID__c = userRefereeObj.Login_Id__c;
                salesTeamForCoverageObj3.Active__c = TRUE;
                salesTeamForCoverageObj3.Company__c = 'N';
                salesTeamForCoverageObj3.Sales_Code_Login_ID__c = 'testtmp1';
                lstcov.add(salesTeamForCoverageObj3);
                 
                Sales_Team_for_Coverage__c salesTeamForCoverageObj4 = new Sales_Team_for_Coverage__c();
                salesTeamForCoverageObj4.Coverage_ID__c = '1238XX';
                salesTeamForCoverageObj4.Name = 'TestTemp_FN TestTemp_LN';
                salesTeamForCoverageObj4.Sales_Team__c = 'Test Team 2';
                 salesTeamForCoverageObj.Sales_Team_Code__c = '456';
                salesTeamForCoverageObj4.Sales_Desk_Region__c = 'USA';
                salesTeamForCoverageObj4.Sales_Desk_Division__c = 'Fixed Income';
                salesTeamForCoverageObj4.Sales_Code_Login_ID__c = contactInstinetObj.Login_Id__c;
                salesTeamForCoverageObj4.Active__c = TRUE;
                salesTeamForCoverageObj4.Company__c = 'I';
                salesTeamForCoverageObj4.Sales_Code_Login_ID__c = 'instinetTest';
                lstcov.add(salesTeamForCoverageObj4);
                 
                insert lstcov;
                 
                 /* Insert Sales_Team_User__c */
                 List<Sales_Team_User__c> lstsalesteam = new List<Sales_Team_User__c>();
                Sales_Team_User__c salesTeamUserObj = new Sales_Team_User__c();
                salesTeamUserObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
                salesTeamUserObj.User__c = userObj.Id;
                salesTeamUserObj.Source_Id__c = salesTeamForCoverageObj.Coverage_ID__c + '#' + userObj.Login_Id__c;
                
                lstsalesteam.add(salesTeamUserObj);
                
                Sales_Team_User__c salesTeamUserObj1= new Sales_Team_User__c(); 
                salesTeamUserObj1.Sales_Team_for_Coverage__c = salesTeamForCoverageObj1.Id;
                salesTeamUserObj1.User__c = userRefereeAsMgrObj.Id;
                salesTeamUserObj1.Source_Id__c = salesTeamForCoverageObj1.Coverage_ID__c + '#' + userRefereeAsMgrObj.Login_Id__c;
                
                lstsalesteam.add(salesTeamUserObj1);
                 
                Sales_Team_User__c salesTeamUserObj2= new Sales_Team_User__c(); 
                salesTeamUserObj2.Sales_Team_for_Coverage__c = salesTeamForCoverageObj2.Id;
                salesTeamUserObj2.User__c = userAsMgrObj.Id;
                salesTeamUserObj2.Source_Id__c = salesTeamForCoverageObj2.Coverage_ID__c + '#' + userAsMgrObj.Login_Id__c;
                
                lstsalesteam.add(salesTeamUserObj2);
                 
                Sales_Team_User__c salesTeamUserObj3= new Sales_Team_User__c(); 
                salesTeamUserObj3.Sales_Team_for_Coverage__c = salesTeamForCoverageObj3.Id;
                salesTeamUserObj3.User__c = userRefereeObj.Id;
                salesTeamUserObj3.Source_Id__c = salesTeamForCoverageObj3.Coverage_ID__c + '#' + userRefereeObj.Login_Id__c;
                
                lstsalesteam.add(salesTeamUserObj3);
                insert lstsalesteam;
             }
        }     
       
    }
    public static User createRefereeManagerUser()
    {
		if(profileNomuraSales==null){
			profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
		}
        UserRole userRoleObj = [SELECT Id, Name  FROM UserRole WHERE Name = 'Wholesale' LIMIT 1];
        User userAsMgrObj = new User();
        userAsMgrObj.Login_ID__c = 'testMgr1';
        userAsMgrObj.Alias = 'testMgr1';
        userAsMgrObj.LastName = 'TestMgr_LN1';
        userAsMgrObj.FirstName = 'TestMgr_FN1';
        userAsMgrObj.Email = 'TestMgr1@testOrg.com';
        userAsMgrObj.UserName = 'TestMgr1@testOrg.com';
        userAsMgrObj.ProfileId = profileNomuraSales.Id;
        userAsMgrObj.EmailEncodingKey = 'UTF-8';
        userAsMgrObj.LanguageLocaleKey = 'en_US';
        userAsMgrObj.LocaleSidKey = 'en_US';
        userAsMgrObj.TimeZoneSidKey = 'America/Los_Angeles';
        userAsMgrObj.Region__c = 'Americas';
        userAsMgrObj.UserRoleId = (userRoleObj != null ? userRoleObj.Id : null);        
        insert userAsMgrObj;
        return userAsMgrObj;
    }    
    public static User createRefereeUser(Id refereeManagerId)
    {
        if(profileNomuraSales==null){
			profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
		}
        UserRole userRoleObj = [SELECT Id, Name  FROM UserRole WHERE Name LIKE 'Americas - FI - Sales%' LIMIT 1];
        User userObj = new User();
        userObj.Login_ID__c = 'testtmp1';
        userObj.Alias = 'testtmp1';
        userObj.LastName = 'TestTemp_LN1';
        userObj.FirstName = 'TestTemp_FN1';
        userObj.Email = 'TestTemp1@testOrg.com';
        userObj.UserName = 'TestTemp1@testOrg.com';
        userObj.ProfileId = profileNomuraSales.Id;
        userObj.EmailEncodingKey = 'UTF-8';
        userObj.LanguageLocaleKey = 'en_US';
        userObj.LocaleSidKey = 'en_US';
        userObj.TimeZoneSidKey = 'America/Los_Angeles';
        userObj.Region__c = 'Americas';
        userObj.UserRoleId = (userRoleObj != null ? userRoleObj.Id : null);
        userObj.ManagerId = refereeManagerId; 
        insert userObj;        
        return userObj;
    }
    public static Contact createInstinetContact()
    {
        //create Instinet Contact
        Contact contact = new Contact();
        contact.AccountId = instinetAccount.Id;
        contact.RG_Account__c = nomuraAccG.Id;
        contact.FirstName = 'Instinet_FN';
        contact.LastName = 'Instinet_LN';
        contact.Login_Id__c = 'instinetTest';
        contact.Active__c = true;
        contact.Key_Person__c = false;    
        contact.Email = 'instinetdummyxx@testxx.comx';
        contact.Phone = '+0000000000'; 
        contact.Salutation = 'M.';
        insert contact;
        return contact;
    }
    
    //added section for JIRA 1588
    static testMethod void OpportunityApprovalTest(){
        Test.starttest();
        Opportunity opp = null;
         if(userRefereeAsMgrObj==null){
			userRefereeAsMgrObj = [SELECT Id, Name FROM USER WHERE Login_ID__c = 'testMgr1'];
		 }
         if(userObj==null){
			userObj = [SELECT Id, Name FROM USER WHERE Login_ID__c = 'testtmp'];
		 }
		 if(userAsMgrObj==null){		 
			userAsMgrObj = [SELECT Id, Name FROM USER WHERE Login_ID__c = 'testMgr'];
         }
		 if(userRefereeObj==null){
			userRefereeObj = [SELECT Id, Name FROM USER WHERE Login_ID__c = 'testtmp1'];
         }
		 if(contactInstinetObj==null){
			contactInstinetObj = [SELECT Id, Name FROM Contact WHERE Login_ID__c = 'instinetTest'];
         }
        if(account2==null){
            account2 = [SELECT Id, Name From Account where Name = 'TestAccount2' Limit 1];
        }
		System.runas(userRefereeAsMgrObj){
             //updated label Active Opportunity to Opportunity 
            opp = new Opportunity(Name=account2.Name + ' Opportunity',
                                  StageName='Referral Requested',
                                  CloseDate=System.today().addMonths(1),
                                  Account__c=account2.Id,
                                  Referral__c = userObj.Id,
                                  Referee__c = userRefereeAsMgrObj.Id,                                    		 
                                  ProductVal__c ='AGENCY MORTGAGES',
                                  Product_Region__c = 'Fixed Income - USA',   
                                  RecordTypeId = CommonTools.getRecordTypeIdUsingDeveloperName('Opportunity','Cross_Sell_Referral'));
            insert opp;
            
            Opportunity opp1 = new Opportunity(Name=account2.Name + ' Opportunity',
          				                     StageName='Referral Requested',
                                             CloseDate=System.today().addMonths(1),
                                             Account__c=account2.Id,
                                             Referred_Contact__c = contactInstinetObj.Id,
                                             Referee__c = userRefereeObj.Id,                                    		 
                                             ProductVal__c ='{FLOW CREDIT}FCT FINANCING',
                                             Product_Region__c = 'Fixed Income - USA',   
                                             RecordTypeId = CommonTools.getRecordTypeIdUsingDeveloperName('Opportunity','Cross_Sell_Referral'));
             insert opp1;
             
             try{
                 Opportunity opp2 = new Opportunity(Name=account2.Name + ' Opportunity',
          				                     StageName='Referral Requested',
                                             CloseDate=System.today().addMonths(1),
                                             Account__c=account2.Id,
                                             ProductVal__c ='AGENCY MORTGAGES',
                                             Product_Region__c = 'Fixed Income - USA',   
                                             RecordTypeId = CommonTools.getRecordTypeIdUsingDeveloperName('Opportunity','Cross_Sell_Referral'));
                 insert opp2;
             }
             catch(Exception ex){
                 system.debug('exception **'+ex.getMessage());
                 //system.assertEquals(ex.getMessage().contains('Either Referred Nomura User or Referred Instinet User is mandatory for Cross Sell'),true);
             } 
             try{
                 Opportunity opp3 = new Opportunity(Name=account2.Name + ' Opportunity',
          				                     StageName='Referral Requested',
                                             CloseDate=System.today().addMonths(1),
                                             Account__c=account2.Id,
                                             Referral__c = userObj.Id,
                                             ProductVal__c ='AGENCY MORTGAGES',
                                             Product_Region__c = 'Fixed Income - USA',   
                                             RecordTypeId = CommonTools.getRecordTypeIdUsingDeveloperName('Opportunity','Cross_Sell_Referral'));
                 insert opp3;
             }
             catch(Exception ex){
                 system.debug('exception **'+ex.getMessage());
                 //system.assertEquals(ex.getMessage().contains('The request for this Account and Product already exists'),true);
             }  
         }

         List<String> processIds = new List<String>();
         List<ProcessInstanceWorkitem> pItems = [Select Id from ProcessInstanceWorkitem  where ProcessInstance.TargetObjectId =: opp.id];
        
         if(pItems.size()>0)
         {
         	processIds.add(pItems[0].Id);
         }

         system.runas(userObj){     
            List<BulkApprovalController.ApprovalQueueItem> lstApprovalitem = BulkApprovalController.getItemstoApprove();
            //system.assertEquals(lstApprovalitem.size() > 0, true);
            lstApprovalitem = BulkApprovalController.processOpptRequests(JSON.serialize(processIds),'Approve','Approve record in test class');
         }
         system.runas(userAsMgrObj){
            List<BulkApprovalController.ApprovalQueueItem> lstApprovalitem = BulkApprovalController.getItemstoApprove();
            //system.assertEquals(lstApprovalitem.size() > 0, true);
            lstApprovalitem = BulkApprovalController.processOpptRequests(JSON.serialize(processIds),'Approve','Approve record in test class');
         }
        Test.stoptest();
    }
}