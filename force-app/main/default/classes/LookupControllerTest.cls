@isTest
private class LookupControllerTest {
    static User userAsMgrObj; 
    static User userObj;
    
    static testMethod void testLookup2(){
        createTestData();
        String singleLookupJSON = LookupControllerTest.createJSON();
        List<Account> accountList = [SELECT Id, Name FROM Account WHERE RDM_Org_Id__c = 'RGXXXXXX' LIMIT 1];
        String accountId = accountList != null ? accountList[0].Id : '';
        
        LookupController.preSelectlookup(new List<string>{'RG_Account'},'Account',false,false);
        LookupController.lookup('', 'Contact', true, true, null, false, false,false, false,'','','',false,false,false, false, accountId);
        LookupController.lookup('', 'Contact', true, false, null, false, false,false, false,'','','',false,false,false, false, accountId);
        LookupController.lookup('TestAccount2', 'Account', false, true, new List<string>{'RG_Account'}, false, false,false, false,'','','',true,false,false, false, accountId);  
        
        LookupController.recentlyViewed('Contact', true, true, null, false,false, false, false, accountId);
       // LookupController.recentlyViewed('Contact', true, false, null, false,false, false, accountId);
        LookupController.recentlyViewed('Contact', false, true, null, false,false, false, false, accountId);
        LookupController.recentlyViewed('Contact', false, false, null, false,false, false, false, accountId); 
        LookupController.recentlyViewed('Account', false, true, new List<string>{'RG_Account'}, true,false, false, false, accountId);
           
    }
    
    static testMethod void testLookup()
    {
        createTestData();
        
        String singleLookupJSON = LookupControllerTest.createJSON();
        List<Account> accountList = [SELECT Id, Name FROM Account WHERE RDM_Org_Id__c = 'RGXXXXXX' LIMIT 1];
        String accountId = accountList != null ? accountList[0].Id : '';
        
        
        LookupController.lookup('TestAccount2', 'Account', false, true, new List<string>{'RG_Account'}, false, false,false, false,'','','',false,false,false, true, accountId);
        LookupController.lookup('', 'User', true, true, null, false, false,false, false,'','','',false,false,false, false, accountId);
        LookupController.lookup('', 'User', true, false, null, false, false,false, false,'','','',false,false,false, false, accountId);
        LookupController.lookup('user1@nomura.com', 'User', true, true, null, false, false,false, false,'','','',false,false,false, false, accountId);
        LookupController.lookup('user1', 'User', true, true, null, false, false,false, false,'','','',false,false,false, false, accountId);
        LookupController.lookup('', 'User', false, true, null, false, false,false, false,'','','',false,false,false, false, accountId);
        LookupController.lookup('', 'User', false, false, null, false, false,false, false,'','','',false,false,false, false, accountId);
        LookupController.lookup('user1@nomura.com', 'User', false, true, null, false, false,false, false,'','','',false,false,false, false, accountId);
     
        LookupController.lookup('user1@nomura.com', 'Contact', true, true, null, false, false,false, false,'','','',false,false,false, false, accountId);
        LookupController.lookup('user1', 'Contact', true, true, null, false, false,false, false,'','','',false,false,false, false, accountId);
        LookupController.lookup('Mark Rossi', 'Sales_Team_for_Coverage__c', false, true, null, true, false,false, false,'','','',false,false,false, false, accountId);
            
        LookupController.recentlyViewed('Account', false, true, new List<string>{'RG_Account'}, false,false, false, true, accountId);
        LookupController.recentlyViewed('User', true, true, null, false,false, false, false, accountId);
        LookupController.recentlyViewed('User', true, false, null, false,false, false, false, accountId);
        LookupController.recentlyViewed('User', false, true, null, false,false, false, false, accountId);
        
       

    }
   
    public static void createTestData()
    {
        Id [] fixedSearchResults= new Id[15];
        Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        
        UserRole userRoleObj = [SELECT Id, Name  FROM UserRole WHERE Name LIKE 'Americas - FI - Sales%' LIMIT 1];
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        
        
        System.runAs(thisUser) {
            userAsMgrObj = createManagerUser();
            userObj = createNormalUser(userAsMgrObj.Id);
        }
        
        System.runas(userAsMgrObj){
            /* Insert Accounts */
            Id recordTypeIdForRM = null;
            List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType WHERE Name IN ('RM Account')];
            RecordType RSRecordType = [SELECT Id FROM RecordType WHERE Name = 'RS Account' ];
            RecordType RGRecordType = [SELECT Id FROM RecordType WHERE Name = 'RG Account' ];
            
            if(recordTypeList != null && recordTypeList.size() > 0){
                for(RecordType recordTypeObj : recordTypeList){
                    if('RM Account'.equalsIgnoreCase(recordTypeObj.Name)){
                        recordTypeIdForRM = recordTypeObj.Id; 
                        break;
                    }
                }
            }            
            
            Account accountAdd = new Account();
            accountAdd.Name = 'TestAccount1';
            accountAdd.RDM_Org_ID__c = 'RSXXXXXX';  
            accountAdd.BillingCity = 'California';
            accountAdd.BillingCountry = 'United States';
            accountAdd.BillingStreet = '52nd Street';
            accountAdd.RecordTypeId = RSRecordType.Id; 
            insert accountAdd;    
            fixedSearchResults[0] =  accountAdd.Id; 
            
            Account account2  = new Account(); 
            account2.Name = 'TestAccount2';
            account2.RDM_Org_ID__c = 'RGXXXXXX';            
            account2.RecordTypeId = RGRecordType.Id;
            account2.BillingCity = 'California';
            account2.BillingCountry = 'United States';
            account2.BillingStreet = '52nd Street';
            account2.ParentId = accountAdd.Id;
            insert account2;
            fixedSearchResults[1] =  account2.Id;
            system.debug(' account 2**'+ account2);
            
            Account account3  = new Account(); 
            account3.Name = 'TestAccount2 Inac';
            account3.RDM_Org_ID__c = 'RGInactive';            
            account3.RecordTypeId = RGRecordType.Id;
            account3.BillingCity = 'California';
            account3.BillingCountry = 'United States';
            account3.BillingStreet = '52nd Street';
            account3.ParentId = accountAdd.Id;
            insert account3;
            fixedSearchResults[2] = account3.Id;
            
            Account accountRestrictedRM  = new Account();  
            accountRestrictedRM.Name = 'RM_Account_Dummy_Restricted';
            accountRestrictedRM.RDM_Org_ID__c = 'RMXXXXXX';            
            accountRestrictedRM.RecordTypeId = recordTypeIdForRM;
            accountRestrictedRM.BillingStreet = '10 Marina Boulevard, Marina Bay Financial Centre Tower 2, #36-01' ;
            accountRestrictedRM.BillingCity = 'Singapore';
            accountRestrictedRM.BillingPostalCode = '018983';
            accountRestrictedRM.BillingCountry = 'Singapore';
            accountRestrictedRM.Active__c = TRUE; 
            accountRestrictedRM.ParentId = account2.Id;
            accountRestrictedRM.Restricted_Flag__c = TRUE;            
            insert accountRestrictedRM;
            fixedSearchResults[3] =  accountRestrictedRM.Id; 
            
            Account accountRestrictedRMInActive  = new Account();  
            accountRestrictedRMInActive.Name = 'RM_Account_Dummy_Restricted Inac';
            accountRestrictedRMInActive.RDM_Org_ID__c = 'RMInactive';            
            accountRestrictedRMInActive.RecordTypeId = recordTypeIdForRM;
            accountRestrictedRMInActive.BillingStreet = '10 Marina Boulevard, Marina Bay Financial Centre Tower 2, #36-01' ;
            accountRestrictedRMInActive.BillingCity = 'Singapore';
            accountRestrictedRMInActive.BillingPostalCode = '018983';
            accountRestrictedRMInActive.BillingCountry = 'Singapore';
            accountRestrictedRMInActive.Active__c = False; 
            accountRestrictedRMInActive.ParentId = account2.Id;
            accountRestrictedRMInActive.Restricted_Flag__c = TRUE;            
            insert accountRestrictedRMInActive;
            fixedSearchResults[4] = accountRestrictedRMInActive.Id;
            
            Account accountNonRestrictedRM  = new Account();  
            accountNonRestrictedRM.Name = 'RM_Account_Dummy';
            accountNonRestrictedRM.RDM_Org_ID__c = 'RMYYYYYY';            
            accountNonRestrictedRM.RecordTypeId = recordTypeIdForRM;
            accountNonRestrictedRM.BillingStreet = '52nd Street' ;
            accountNonRestrictedRM.BillingCity = 'Los Angeles';
            accountNonRestrictedRM.BillingPostalCode = '90001';
            accountNonRestrictedRM.BillingCountry = 'United States';
            accountNonRestrictedRM.ParentId = account2.Id;
            accountNonRestrictedRM.Active__c = TRUE;             
            insert accountNonRestrictedRM;
            fixedSearchResults[5] =  accountNonRestrictedRM.Id;     

            test.startTest();
            List<Contact> contactList = new List<Contact>();
            for(integer i = 0; i< 5 ; i++){
                Contact newContact = new Contact();
                newContact.FirstName = 'Test' + i; 
                newContact.LastName = 'Contact'; 
                newContact.AccountId = accountNonRestrictedRM.Id;
                newContact.RG_Account__c = account2.Id;
                newContact.Active__c = true;
                newContact.Key_Person__c = true;
                newContact.Email = 'a@a' + i + '.com';
                //fix for phone validation SALEs-3531
                newContact.Phone = '+1 (212) 33' + i + '-4567'; 
                newContact.Salutation = 'Dear [FirstName]';    
                
                contactList.add(newContact);
                
            }
            insert contactList;
            integer i=0;
            for(Contact cc : contactList){
                fixedSearchResults[6+i] =  cc.Id;
                i++;
            }
            
           Id phoneBookRecordTypeId = Schema.getGlobalDescribe().get('Campaign').getDescribe().getRecordTypeInfosByName().get('Phone Book').getRecordTypeId(); 
            
           //Insert Campaign of Type Phone Book
           Campaign phoneBookCampaignObj = new Campaign();
           phoneBookCampaignObj.Name = 'Test Contact List' ;
           phoneBookCampaignObj.RecordTypeId = phoneBookRecordTypeId;
           insert phoneBookCampaignObj;
           fixedSearchResults[11] =  phoneBookCampaignObj.Id;
           system.debug(' Fixed **'+ fixedSearchResults);
            Test.setFixedSearchResults(fixedSearchResults);
            test.stopTest();
    }
}
    
     public static User createManagerUser()
    {
        Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        UserRole userRoleObj = [SELECT Id, Name  FROM UserRole WHERE Name LIKE 'Americas - FI - Sales%' LIMIT 1];
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
        return [select id,UserRoleId,Region__c,Login_ID__c from User where id =:userAsMgrObj.id];
    }
    public static User createNormalUser(Id managerId)
    {
        Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        UserRole userRoleObj = [SELECT Id, Name  FROM UserRole WHERE Name LIKE 'Americas - FI - Sales%' LIMIT 1];
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
        insert userObj;        
        return [select id,UserRoleId,Region__c,Login_ID__c from User where id =:userObj.id];
    }
    
    public static String createJSON(){
       	List<Account> accountList = [SELECT Id, Name FROM Account WHERE RDM_Org_Id__c = 'RGXXXXXX' LIMIT 1];
        String account = accountList[0].Id;
        
        String query = 'SELECT Id, Name, RG_Account__c FROM Contact WHERE RG_Account__c = \'' + account +'\' LIMIT 1';
        List<Contact> contacts = (List<Contact>)Database.query(query);         
        String jsonString = '{"rgAccount":"' + contacts[0].RG_Account__c + '", "contactId": "' + contacts[0].Id + '"}';
        
        return jsonString;		
    }

    
}