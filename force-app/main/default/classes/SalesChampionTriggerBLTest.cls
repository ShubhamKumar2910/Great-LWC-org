@isTest
public class SalesChampionTriggerBLTest {
    
    static testMethod void testCreateAndDeleteAccountShare()
    {
        List<Account> testAccounts = new List<Account>();
        List<Sales_Champion__c> testSales = new List<Sales_Champion__c>();
        Account accountObj;
        
        Id RGRecordType = CommonTools.getRecordTypeId('Account','RG Account');
        Id RSRecordType = CommonTools.getRecordTypeId('Account','RS Account');
        Id RMRecordType = CommonTools.getRecordTypeId('Account','RM Account');
        
        User integrationUserObj = [SELECT Id, Name, Login_Id__c FROM User WHERE Login_Id__c = 'sfadmin' 
                        and Profile.Name = 'Nomura - Integration' AND IsActive = TRUE LIMIT 1];
        
        List<User> userList = new List<User>();
        Profile profileNomuraBusinessManagers = [SELECT id, Name From Profile WHERE Name = 'Nomura - Business Management' LIMIT 1];
        
        User userObj1 = new User();
        userObj1.Login_ID__c = 'test1tmp';
        userObj1.Alias = 'test1tmp';
        userObj1.FirstName = 'Test1TempFN';
        userObj1.LastName = 'Test1TempLN';
        userObj1.Email = 'Test1Temp@testOrg.com';
        userObj1.UserName = 'Test1Temp@testOrg.com';
        userObj1.ProfileId = profileNomuraBusinessManagers.Id;
        userObj1.EmailEncodingKey = 'UTF-8';
        userObj1.LanguageLocaleKey = 'en_US';
        userObj1.LocaleSidKey = 'en_US';
        userObj1.TimeZoneSidKey = 'America/Los_Angeles';
        userObj1.Region__c = 'Americas';
        userList.add(userObj1);
        
        User userObj2 = new User();
        userObj2.Login_ID__c = 'test2tmp';
        userObj2.Alias = 'test2tmp';
        userObj2.FirstName = 'Test2TempFN';
        userObj2.LastName = 'Test2TempLN';
        userObj2.Email = 'Test2Temp@testOrg.com';
        userObj2.UserName = 'Test2Temp@testOrg.com';
        userObj2.ProfileId = profileNomuraBusinessManagers.Id;
        userObj2.EmailEncodingKey = 'UTF-8';
        userObj2.LanguageLocaleKey = 'en_US';
        userObj2.LocaleSidKey = 'en_US';
        userObj2.TimeZoneSidKey = 'America/Los_Angeles';
        userObj2.Region__c = 'Americas';
        userList.add(userObj2);
        
        insert userList;
        
        
        system.runAs(integrationUserObj){             
            //Insert Account
            accountObj = new Account();
            accountObj.Name = 'TestAccount';
            accountObj.RDM_Org_ID__c = 'RG111';
            accountObj.RecordTypeId = RGRecordType;
            accountObj.BillingCity = 'California';
            accountObj.BillingCountry = 'United States';
            accountObj.BillingStreet = '52nd Street'; 
            
            insert accountObj;
        }
        
        List<Sales_Champion__c> testSalesChampionList =  new List<Sales_Champion__c>();
        
        //Insert Champion    
        Sales_Champion__c salesChamp = new Sales_Champion__c();
        salesChamp.Account__c = accountObj.Id;
        salesChamp.Champion_Type__c = 'Rsch Sales Champion';
        salesChamp.Sales_Champion__c = userList[1].Id;
        salesChamp.Region__c = 'AEJ';
        testSalesChampionList.add(salesChamp);
        insert salesChamp;
        
        Integer accountShareCount = [Select count() from AccountShare WHERE (UserOrGroupId = :salesChamp.Sales_Champion__c AND  AccountId = :salesChamp.Account__c)];
        System.assert(accountShareCount > 0);
        
        Sales_Champion__c salesChamp2 = new Sales_Champion__c();
        salesChamp2.Account__c = accountObj.Id;
        salesChamp2.Champion_Type__c = 'Rsch Sales Champion';
        salesChamp2.Sales_Champion__c = userList[0].Id;
        salesChamp2.Region__c = 'AEJ';
        testSalesChampionList.add(salesChamp2);
        insert salesChamp2;
        Integer accountShareCount2 = [Select count() from AccountShare WHERE (UserOrGroupId = :salesChamp2.Sales_Champion__c AND  AccountId = :salesChamp2.Account__c)];
        System.assert(accountShareCount2 > 0);
        
        Sales_Champion__c salesChamp3 = new Sales_Champion__c();
        salesChamp3.Account__c = accountObj.Id;
        salesChamp3.Champion_Type__c = 'SRM Leader 1';
        salesChamp3.Sales_Champion__c = userList[1].Id;
        salesChamp3.Region__c = 'AEJ';
        testSalesChampionList.add(salesChamp3);
        insert salesChamp3;
        Integer accountShareCount3 = [Select count() from AccountShare WHERE (UserOrGroupId = :salesChamp3.Sales_Champion__c AND  AccountId = :salesChamp3.Account__c)];
        System.assert(accountShareCount3 > 0);
        
        Delete testSalesChampionList;
        Integer accountShareAfterDelete =[Select count() from AccountShare WHERE (UserOrGroupId = :salesChamp3.Sales_Champion__c AND  AccountId = :salesChamp3.Account__c) Or
                                          (UserOrGroupId = :salesChamp2.Sales_Champion__c AND  AccountId = :salesChamp2.Account__c) OR
                                          (UserOrGroupId = :salesChamp.Sales_Champion__c AND  AccountId = :salesChamp.Account__c)];
        
        System.assert(accountShareAfterDelete <= 0);
        
    }

    @testSetUp
    public static void testSetupForInstinetChampion(){
        Id recordTypeIdForRG = CommonTools.getRecordTypeId('Account','RG Account');
        Id recordTypeIdForNomuraEmployees = CommonTools.getRecordTypeId('Account','NOMURA EMPLOYEES');
        Id instinetChampionRecordTypeId = CommonTools.getRecordTypeId('Sales_Champion__c','Instinet Champion');
        
        //Insert Accounts
        Account accountRG  = new Account(); 
        accountRG.Name = 'RG_Account_Dummy';
        accountRG.RDM_Org_ID__c = 'RGXXXXXX';            
        accountRG.RecordTypeId = recordTypeIdForRG;
        accountRG.Active__c = TRUE;  
        
        insert accountRG;

        Account instinetEmployeesParentAccount  = new Account();  
        instinetEmployeesParentAccount.Name = 'NOMURA EMPLOYEES (G)';
        instinetEmployeesParentAccount.RDM_Org_ID__c = 'CPG12345';            
        instinetEmployeesParentAccount.RecordTypeId = recordTypeIdForRG;
        instinetEmployeesParentAccount.Active__c = TRUE; 
        
        insert instinetEmployeesParentAccount;

        Account instinetEmployeesAccount  = new Account();  
        instinetEmployeesAccount.Name = 'INSTINET EMPLOYEES';
        instinetEmployeesAccount.RDM_Org_ID__c = 'IN12345';            
        instinetEmployeesAccount.RecordTypeId = recordTypeIdForNomuraEmployees;
        instinetEmployeesAccount.Active__c = TRUE; 
        instinetEmployeesAccount.ParentId = instinetEmployeesParentAccount.Id;
        
        insert instinetEmployeesAccount;

        //Insert Contact
        Contact contactObj = new Contact();
        contactObj.AccountId = instinetEmployeesAccount.Id;
        contactObj.RG_Account__c = instinetEmployeesParentAccount.Id;
        contactObj.FirstName = 'TestDummyFN_1'; 
        contactObj.LastName = 'TestDummyLN_1';    
        contactObj.Active__c = TRUE;
        contactObj.Email = 'TestDummy1@testOrg.com';
        contactObj.Phone = '+0000000000'; 
        contactObj.Salutation = 'M.';    
        contactObj.Mailing_Address_Same_As_Account_Address__c = FALSE;

        insert contactObj;

        
        User sfadminUserObj = [SELECT Id, Name, Login_Id__c FROM User 
                               WHERE Login_Id__c = 'sfadmin' AND Profile.Name = 'Nomura - Integration' AND 
                               IsActive = TRUE LIMIT 1];

        System.runAs(sfadminUserObj){

            //Insert Sales_Champion__c
            Sales_Champion__c championObj = new Sales_Champion__c();
            championObj.Account__c = accountRG.Id;
            championObj.Instinet_Champion__c = contactObj.Id;
            championObj.Region__c = 'Japan';
            championObj.Champion_Type__c = 'EQ - Execution Champion';
            championObj.RecordTypeId = instinetChampionRecordTypeId;

            insert championObj;
        }

    }

    static testMethod void testPopulateUniqueID(){
        //Fetch Champion
        List<Sales_Champion__c> championList = [SELECT Id, Unique_ID__c FROM Sales_Champion__c 
                                                WHERE RecordType.DeveloperName = 'Instinet_Champion' LIMIT 1];

        if(championList != null && !championList.isEmpty()){
            Sales_Champion__c resultChampionObj = championList.get(0);
            System.assert(resultChampionObj.Unique_ID__c != null && !String.isEmpty(resultChampionObj.Unique_ID__c));
        }                                                    
            
    }

    static testMethod void testRestrictDeleteForInstinetChampion(){
        /* Insert User Record*/
        Profile profileNomuraBusinessMgmt = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Business Management' LIMIT 1];
        List<UserRole> userRoleList = [SELECT Id, Name, DeveloperName FROM UserRole WHERE DeveloperName = 'Japan_EQ_Sales_Region_Head'];
        
        User userObj = new User();
        userObj.Login_ID__c = 'testdummy';
        userObj.Alias = 'testdum';
        userObj.LastName = 'TestDummyLN';
        userObj.Email = 'TestDummyXXX@testOrg.com';
        userObj.UserName = 'TestDummyXXX@testOrg.com';
        userObj.ProfileId = profileNomuraBusinessMgmt.Id;
        userObj.EmailEncodingKey = 'UTF-8';
        userObj.LanguageLocaleKey = 'en_US';
        userObj.LocaleSidKey = 'en_US';
        userObj.TimeZoneSidKey = 'America/Los_Angeles';
        userObj.Region__c = 'Americas';
        if(userRoleList != null && !userRoleList.isEmpty()){
            userObj.UserRoleId = userRoleList.get(0).Id;
        }
        
        insert userObj;

        //Delete Champion using 'Nomura - Business Management' profile 
         System.runAs(userObj){
            //Fetch Champion
            List<Sales_Champion__c> championList = [SELECT Id, Unique_ID__c FROM Sales_Champion__c 
                                                    WHERE RecordType.DeveloperName = 'Instinet_Champion' LIMIT 1];

            if(championList != null && !championList.isEmpty()){
                Sales_Champion__c resultChampionObj = championList.get(0);

                 
                try {
                    delete resultChampionObj;
                }
                catch(Exception exObj){
                    System.assert(exObj.getMessage().contains(System.Label.Delete_has_been_disabled));
                }
            }                                                 
         }           
    }
    
}