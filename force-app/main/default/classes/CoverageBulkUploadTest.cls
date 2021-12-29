@isTest
public class CoverageBulkUploadTest {
    public static User userAsMgrObj; 
    public static User userObj;
    public static string jsonString;
    public static Id dummyRMNonRestrictedId;  
    public static Id dummySalesCodeActiveId;  
    public static Profile profileNomuraSales;
    public static UserRole userRoleObj;
    public static List<Account> rmAccountList = new List<Account>();
    
    @isTest static void stepPass1NonApprover()
    {
        //createTestData();
        try{
            System.debug('------------------in stepPass1NonApprover----------');
            ProcessStagingCoverages.requestorId = UserInfo.getUserId();
            Test.startTest();
            CoverageBulkUploadController.processImportFromTool(getRGJSONString(),'CVGTOOL');
            //CoverageBulkUploadController.processImportFromCSV(getRMNonRestrictedJSONString());
          
            List<Coverage_Temp__c> templist = new List<Coverage_Temp__c>();
            Coverage_Temp__c temp = new Coverage_Temp__c();
            temp.action__c = 'add';
            templist.add(temp);
            List<RG_Coverage_Request__c> rgRequestsToDelete = new List<RG_Coverage_Request__c>();
            List<Coverage_Access_Request__c> rmRequestsToDelete = new List<Coverage_Access_Request__c>();
            
            ProcessStagingCoverages ps = new ProcessStagingCoverages('GUID-1');
            ps.addToCSV(templist, 0, 'errormsg');
            Test.stopTest();
            System.debug('------------------end stepPass1NonApprover----------');
         }
        catch(Exception e)
        {
            system.debug('Test exception: '+e.getStackTraceString());
        }
    }
    @isTest static void stepPass1User()
    {
        //createTestData();        
        try{
            Test.startTest();
            if(userObj==null){
               userObj = [SELECT Id, Name FROM USER WHERE Login_ID__c = 'testtmp']; 
            } 
            System.debug('------------------in stepPass1User------userObj----');
            System.runas(userObj){                
                ProcessStagingCoverages.requestorId = userObj.Id;                
                CoverageBulkUploadController.processImportFromTool(getRGJSONString(),'CVGTOOL');
            }            
        	Test.stopTest();
        }
        catch(Exception e)
        {
            system.debug('Test exception: '+e.getStackTraceString());
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
    
    static testMethod void testBulkUploadPopupUpController(){
        PageReference popupPage = Page.BulkUploadPopup;
        Test.setCurrentPage(popupPage);
        CoverageBulkUploadUtility.accessByProfile('ABC');
        popupPage.getParameters().put('objectName', 'Coverage_Team_Member__c');
        popupPage.getParameters().put('fieldName', 'Product_Group__c');
        BulkUploadPopupUpController obj = new BulkUploadPopupUpController();
        
        popupPage.getParameters().put('objectName', 'Coverage_Team_Member__c');
        popupPage.getParameters().put('fieldName', 'Product_Region__c');
        BulkUploadPopupUpController obj1 = new BulkUploadPopupUpController();
        
        popupPage.getParameters().put('objectName', 'Coverage_Team_Member__c');
        popupPage.getParameters().put('fieldName', 'Product2__c');
        BulkUploadPopupUpController obj2 = new BulkUploadPopupUpController();
        
        popupPage.getParameters().put('objectName', 'Coverage_Team_Member__c');
        popupPage.getParameters().put('fieldName', 'Product_Group__c');
        BulkUploadPopupUpController obj3 = new BulkUploadPopupUpController();
        
        popupPage.getParameters().put('objectName', 'Coverage_Team_Member__c');
        popupPage.getParameters().put('fieldName', 'Team_Role__c');
        BulkUploadPopupUpController obj4 = new BulkUploadPopupUpController();
        
        popupPage.getParameters().put('objectName', 'Event');
        popupPage.getParameters().put('fieldName', 'Type');
        BulkUploadPopupUpController obj5 = new BulkUploadPopupUpController();
        
        popupPage.getParameters().put('objectName', 'Event');
        popupPage.getParameters().put('fieldName', 'Event_Origination_Region__c');
        BulkUploadPopupUpController obj6 = new BulkUploadPopupUpController();
        
        popupPage.getParameters().put('objectName', 'Event');
        popupPage.getParameters().put('fieldName', 'Event_Type__c');
        BulkUploadPopupUpController obj7 = new BulkUploadPopupUpController();
        
        popupPage.getParameters().put('objectName', 'Event');
        popupPage.getParameters().put('fieldName', 'TimeZone');
        BulkUploadPopupUpController obj8 = new BulkUploadPopupUpController();
        
        popupPage.getParameters().put('objectName', 'Event');
        popupPage.getParameters().put('fieldName', null);
        BulkUploadPopupUpController obj9 = new BulkUploadPopupUpController();
        
        popupPage.getParameters().put('objectName', 'Survey_Question__c');
        popupPage.getParameters().put('fieldName', 'Category__c');
        BulkUploadPopupUpController obj10 = new BulkUploadPopupUpController();
    }
   
    @isTest static void stepPass1ApproverforRG()
    {
        //createTestData();
        try{
            system.debug('Test Class approver: '+userAsMgrObj);
            Test.startTest();
            if(userAsMgrObj == null){
             	userAsMgrObj = [SELECT Id, Name FROM USER WHERE Login_ID__c = 'testMgr'];
            }
            System.debug('------------------in stepPass1ApproverforRG------userAsMgrObj----' + userAsMgrObj);
            
            System.runas(userAsMgrObj){
                ProcessStagingCoverages.requestorId = userAsMgrObj.Id;                 
                CoverageBulkUploadController.processImportFromTool(getRGJSONString(),'CVGTOOL');                 
            }
            Test.stopTest();
        }
        catch(Exception e)
        {
            system.debug('Test exception: '+e.getStackTraceString());
        }
    }
    
    
    @isTest static void stepPass1ApproverforRM()
    {
        //createTestData();
        try{  
            Test.startTest();
            system.debug('Test Class approver: '+userAsMgrObj);
            if(userAsMgrObj == null){
             	userAsMgrObj = [SELECT Id, Name FROM USER WHERE Login_ID__c = 'testMgr'];
            }
            System.debug('------------------in stepPass1ApproverforRM-----userAsMgrObj----' + userAsMgrObj);
            System.runas(userAsMgrObj){
                ProcessStagingCoverages.requestorId = userAsMgrObj.Id;                
                //added for JIRA 1588
                CoverageBulkUploadController.processImportFromTool(getRMJSONString(),'CVGTOOL');
               
            }
            Test.stopTest();
        }
        catch(Exception e)
        {
            system.debug('Test exception: '+e.getStackTraceString());
        }
    }  
    
    public static string getRGJSONString()
    {
        string dummyjson = '[ {    "clientRGKey": "RGXXXXXX", "salesCode": "1234XX",    "productGroup": "Fixed Income",    "productRegion": "Asia",    "productName": "EMERGING MARKETS",    "role": "Primary",    "action": "Add",    "fromDate": "2/21/2016"  },{    "clientKey": "RMXXXXXX", "salesCode": "1234XX",    "productGroup": "Fixed Income",    "productRegion": "Asia",    "productName": "EMERGING MARKETS",    "role": "Primary",    "action": "Add",    "fromDate": "2/21/2016"  },{    "clientRGKey": "", "salesCode": "1234XX",    "productGroup": "Fixed Income",    "productRegion": "Asia",    "productName": "EMERGING MARKETS",    "role": "Primary",    "action": "Add",    "fromDate": "2/21/2016"  },{    "clientRGKey": "ABC111", "salesCode": "1234XX",    "productGroup": "Fixed Income",    "productRegion": "Asia",    "productName": "EMERGING MARKETS",    "role": "Primary",    "action": "Add",    "fromDate": "2/21/2016"  },{    "clientRGKey": "ABC111", "salesCode": "12346X",    "productGroup": "Fixed Income1",    "productRegion": "Asia1",    "productName": "EMERGING MARKETS1",    "role": "Primary1",    "action": "Add123",    "fromDate": "2/21/2016"  },{    "clientRGKey": "RGXXXXXX", "salesCode": "1234XX",    "productGroup": "Fixed Income",    "productRegion": "Asia",    "productName": "EMERGING MARKETS",    "role": "Primary",    "action": "Add",    "fromDate": "2/21/2016"  },{    "clientRGKey": "RGXXXXXX", "salesCode": "1234XX",    "productGroup": "Fixed Income",    "productRegion": "Asia",    "productName": "EMERGING MARKETS",    "role": "Primary",    "action": "Delete",    "fromDate": "2/21/2016"  },{"clientRGKey": "RGXXXXXX", "salesCode": "1234XX",    "productGroup": "Fixed Income",    "productRegion": "Asia",    "productName": "EMERGING MARKETS",    "role": "Primary",    "action": "Add",    "fromDate": "21/2/2016"  },{    "clientRGKey": "RGXXXXXX", "salesCode": "1234XX",    "productGroup": "",    "productRegion": "Europe",    "productName": "NES-PT",    "role": "Primary",    "action": "Add",    "fromDate": "2/21/2016"  },{    "clientRGKey": "RGXXXXXX", "salesCode": "1234XX",    "productGroup": "Fixed Income",    "productRegion": "Asia1",    "productName": "NES-PT",    "role": "Primary",    "action": "Add",    "fromDate": "2/21/2016"  }]';
        return dummyjson;
    }
    
    public static string getRMJSONString()
    {
        string dummyjson = '[{    "clientKey": "RMXXXXXX", "salesCode": "1234XX",    "productGroup": "Fixed Income",    "productRegion": "Asia",    "productName": "EMERGING MARKETS",    "role": "Primary",    "action": "Add",    "fromDate": "2/21/2016"  },{    "clientKey": "", "salesCode": "1234XX",    "productGroup": "Fixed Income",    "productRegion": "Asia",    "productName": "EMERGING MARKETS",    "role": "Primary",    "action": "Add",    "fromDate": "2/21/2016"  },{    "clientKey": "RMXRGT", "salesCode": "1234XX",    "productGroup": "Fixed Income",    "productRegion": "Asia",    "productName": "EMERGING MARKETS",    "role": "Primary",    "action": "Add",    "fromDate": "2/21/2016"  },{    "clientKey": "RMXXXXXX", "salesCode": "1234XX",    "productGroup": "Fixed Income",    "productRegion": "Asia",    "productName": "EMERGING MARKETS",    "role": "Primary",    "action": "Add1234",    "fromDate": "2/21/2016"  },{    "clientKey": "RMXXXXXX", "salesCode": "1234XX",    "productGroup": "Fixed Income",    "productRegion": "Asia",    "productName": "",    "role": "Primary",    "action": "Add",    "fromDate": "2/21/2016"  },{    "clientKey": "RMYYYYYY", "salesCode": "1234XX",    "productGroup": "Fixed Income",    "productRegion": "Asia",    "productName": "EMERGING MARKETS",    "role": "Primary",    "action": "Add",    "fromDate": "2/21/2016"  }]';return dummyjson;
    }
   
    @testSetup
    public static void createTestData()
    {      
        Test.StartTest();
		Id accountNonRestrictedRM_Id = null;
        Id accountNonRestrictedRG_Id = null;
        System.debug('------------------in createTestData----------');
        if(profileNomuraSales==null) {
        	profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        }        
        if(userRoleObj==null) {
        	userRoleObj = [SELECT Id, Name  FROM UserRole WHERE Name LIKE 'Americas - FI - Sales%' LIMIT 1];   
        }
        User sfadminUser = [SELECT Id, Login_Id__c FROM User WHERE IsActive = TRUE AND Login_Id__c = 'sfadmin' LIMIT 1];
        //User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        
        
        System.runAs(sfadminUser) {
            userAsMgrObj = createManagerUser();
            userObj = createNormalUser(userAsMgrObj.Id);
        }
        
        System.runas(userAsMgrObj){
            /* Insert Accounts */
                       
            Id RSRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RS Account').getRecordTypeId();   
            Id RGRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();   
            Id RMRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();   	

            
            Account accountAdd = new Account();
            accountAdd.Name = 'TestAccount1';
            accountAdd.RDM_Org_ID__c = 'RSXXXXXX';  
            accountAdd.BillingCity = 'California';
            accountAdd.BillingCountry = 'United States';
            accountAdd.BillingStreet = '52nd Street';
            accountAdd.RecordTypeId = RSRecordTypeId; 
            accountAdd.Active__c = TRUE; 
            insert accountAdd;    
            
            Account account2  = new Account(); 
            account2.Name = 'TestAccount2';
            account2.RDM_Org_ID__c = 'RGXXXXXX';            
            account2.RecordTypeId = RGRecordTypeId;
            account2.BillingCity = 'California';
            account2.BillingCountry = 'United States';
            account2.BillingStreet = '52nd Street';
            account2.ParentId = accountAdd.Id;
            account2.Active__c = TRUE; 
            insert account2;
            accountNonRestrictedRG_Id = account2.Id;
            
            Account account3  = new Account(); 
            account3.Name = 'TestAccount2 Inac';
            account3.RDM_Org_ID__c = 'RGInactive';            
            account3.RecordTypeId = RGRecordTypeId;
            account3.BillingCity = 'California';
            account3.BillingCountry = 'United States';
            account3.BillingStreet = '52nd Street';
            account3.ParentId = accountAdd.Id;
            insert account3;
            
            Account accountRestrictedRM  = new Account();  
            accountRestrictedRM.Name = 'RM_Account_Dummy_Restricted';
            accountRestrictedRM.RDM_Org_ID__c = 'RMXXXXXX';            
            accountRestrictedRM.RecordTypeId = RMRecordTypeId;
            accountRestrictedRM.BillingStreet = '10 Marina Boulevard, Marina Bay Financial Centre Tower 2, #36-01' ;
            accountRestrictedRM.BillingCity = 'Singapore';
            accountRestrictedRM.BillingPostalCode = '018983';
            accountRestrictedRM.BillingCountry = 'Singapore';
            accountRestrictedRM.Active__c = TRUE; 
            accountRestrictedRM.ParentId = account2.Id;
            accountRestrictedRM.Restricted_Flag__c = TRUE;
            
            insert accountRestrictedRM;
            
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
            
            insert accountRestrictedRMInActive;
            
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
            
            insert accountNonRestrictedRM;
            
            accountNonRestrictedRM_Id = accountNonRestrictedRM.id;
            dummyRMNonRestrictedId = accountNonRestrictedRM.id;
            
            rmAccountList.add(accountRestrictedRM);
            rmAccountList.add(accountNonRestrictedRM);
        }
        
        
        
        if(sfadminUser != null){
             System.runas(sfadminUser){
                 /* Insert Sales_Team_for_Coverage__c */
                Sales_Team_for_Coverage__c salesTeamForCoverageObj = new Sales_Team_for_Coverage__c();
                salesTeamForCoverageObj.Coverage_ID__c = '1234XX';
                salesTeamForCoverageObj.Name = 'TestTemp_FN TestTemp_LN';
                salesTeamForCoverageObj.Sales_Team__c = 'Test Team';
                salesTeamForCoverageObj.Sales_Desk_Region__c = 'USA';
                salesTeamForCoverageObj.Sales_Desk_Division__c = 'Fixed Income';
                salesTeamForCoverageObj.Sales_Code_Login_ID__c = userObj.Login_Id__c;
                salesTeamForCoverageObj.Active__c = TRUE;
                salesTeamForCoverageObj.Sales_Code_Login_ID__c = 'testtmp';
                
                insert salesTeamForCoverageObj;
                dummySalesCodeActiveId = salesTeamForCoverageObj.Id; 
                system.debug(userObj.Id);
                 
                Sales_Team_for_Coverage__c salesTeamForCoverageObj1 = new Sales_Team_for_Coverage__c(); //Inactive salescode
                salesTeamForCoverageObj1.Coverage_ID__c = '1235XX';
                salesTeamForCoverageObj1.Name = 'TestTemp_FN TestTemp_LN';
                salesTeamForCoverageObj1.Sales_Team__c = 'Test Team';
                salesTeamForCoverageObj1.Sales_Desk_Region__c = 'USA';
                salesTeamForCoverageObj1.Sales_Desk_Division__c = 'Fixed Income';
                salesTeamForCoverageObj1.Sales_Code_Login_ID__c = userObj.Login_Id__c;
                salesTeamForCoverageObj1.Active__c = False;
                salesTeamForCoverageObj1.Sales_Code_Login_ID__c = 'testtmp';
                
                insert salesTeamForCoverageObj1;
                
                /* Insert Sales_Team_User__c */
                Sales_Team_User__c salesTeamUserObj = new Sales_Team_User__c();
                salesTeamUserObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
                salesTeamUserObj.User__c = userObj.Id;
                salesTeamUserObj.Source_Id__c = salesTeamForCoverageObj.Coverage_ID__c + '#' + userObj.Login_Id__c;
                
                insert salesTeamUserObj;
                
                Sales_Team_User__c salesTeamUserObj1= new Sales_Team_User__c(); //Inactive
                salesTeamUserObj1.Sales_Team_for_Coverage__c = salesTeamForCoverageObj1.Id;
                salesTeamUserObj1.User__c = userObj.Id;
                salesTeamUserObj1.Source_Id__c = salesTeamForCoverageObj1.Coverage_ID__c + '#' + userObj.Login_Id__c;
                
                insert salesTeamUserObj1;
                 
                Coverage_Team_Member__c tm = new Coverage_Team_Member__c();
                 tm.Account__c = accountNonRestrictedRM_Id;
                 tm.Product_Group__c = 'Fixed Income';
                 tm.Product__c = 'EMERGING MARKETS';
                 tm.Product_Region__c   = 'Asia';
                 tm.Team_Role__c = 'Primary';
                 tm.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.id;
                 tm.Start_Date__c = Date.today();      
                 tm.RG_Account__c = accountNonRestrictedRG_Id;
                 insert tm;
                 
                 Coverage_Team_Member__c tm1 = new Coverage_Team_Member__c();
                 tm1.Account__c = accountNonRestrictedRM_Id;
                 tm1.Product_Group__c = 'Fixed Income';
                 tm1.Product__c = 'FUTURES';
                 tm1.Product_Region__c   = 'Asia';
                 tm1.Team_Role__c = 'Primary';
                 tm1.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.id;
                 tm1.Start_Date__c = Date.today();      
                 tm1.NFPE_Primary_Product_Coverage__c = true;
                 tm1.NFPE_Primary_Relationship_Coverage__c = false;
                 tm1.RG_Account__c = accountNonRestrictedRG_Id;
                 insert tm1;
                 
                 
             }
        }
        
        System.runas(userObj){
            //Test.startTest();
            
            Account accountRestrictedRM, accountNonRestrictedRM;
            
            
            //Fetch Accounts
            if(rmAccountList==null || rmAccountList.size()==0){
            	rmAccountList = [SELECT Id, RDM_Org_Id__c, BillingCountry,Restricted_Flag__c FROM Account 
                                         WHERE RDM_Org_Id__c IN ('RMXXXXXX','RMYYYYYY')];
            }
            
            if(rmAccountList != null && rmAccountList.size() > 0){
                for(Account accountObj : rmAccountList){
                    if(accountObj.Restricted_Flag__c){
                        accountRestrictedRM = accountObj;
                    }
                    else {
                        accountNonRestrictedRM = accountObj;
                    }
                }
            }
            
            /* Insert Approvers */
                      
            if(userAsMgrObj == null){
             	userAsMgrObj = [SELECT Id, Name FROM USER WHERE Login_ID__c = 'testMgr'];
            }
            if(userAsMgrObj != null){
                
                List<Approver__c> approverList = new List<Approver__c>();
                
                Approver__c firstApproverObj = new Approver__c();
                firstApproverObj.Region__c = 'AEJ';
                firstApproverObj.Countries_Under_Approval__c = 'Singapore';
                firstApproverObj.User__c = userAsMgrObj.id;
                approverList.add(firstApproverObj);
                
                Approver__c secondApproverObj = new Approver__c();
                secondApproverObj.Region__c = 'AEJ';
                secondApproverObj.Countries_Under_Approval__c = 'Singapore';
                secondApproverObj.User__c = userAsMgrObj.id;
                approverList.add(secondApproverObj);
                
                insert approverList;
                
            }
           // Test.stopTest();
           System.debug('--------End TestDataSetup---userAsMgrObj----' + userAsMgrObj);
        }
        Test.stoptest();
    }
    public static User createManagerUser()
    {
        if(profileNomuraSales==null) {
        	profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        }
        if(userRoleObj==null) {
        	userRoleObj = [SELECT Id, Name  FROM UserRole WHERE Name LIKE 'Americas - FI - Sales%' LIMIT 1];   
        }
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
        userAsMgrObj.Login_Id__c = 'testMgr';
        insert userAsMgrObj;
        return userAsMgrObj;
    }
    public static User createNormalUser(Id managerId)
    {
        if(profileNomuraSales==null) {
        	profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        }
        if(userRoleObj==null) {
        	userRoleObj = [SELECT Id, Name  FROM UserRole WHERE Name LIKE 'Americas - FI - Sales%' LIMIT 1];   
        }
        
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
        userObj.ManagerId = managerId; 
        userObj.Login_Id__c = 'testtmp';
        insert userObj;        
        return userObj;
    }
}