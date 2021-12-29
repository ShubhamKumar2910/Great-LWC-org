@isTest
public class ChampionUpdatesCRTest {

    static testMethod void testChampionUpdatesForClientRemediation() {
        Integer numTestUsers = 1;  
        List<User> users = UtilityTesting.CreateUsersWithManager(numTestUsers);
        
        RecordType recordTypeRG = [SELECT Id FROM RecordType WHERE Name = 'RG Account' LIMIT 1];
       
        system.runas(users[0]){
       
            //Insert Accounts
            Account oldAccountObj = new Account();
            oldAccountObj.Name = 'Old_Account';
            oldAccountObj.RDM_Org_Id__c = 'RG1';
            oldAccountObj.RecordTypeId = recordTypeRG.Id;
            oldAccountObj.Active__c = TRUE;   
           
            insert oldAccountObj;
            
            Account newAccountObj = new Account();
            newAccountObj.Name = 'New_Account';
            newAccountObj.RDM_Org_Id__c = 'RG2';
            newAccountObj.RecordTypeId = recordTypeRG.Id;
            newAccountObj.Active__c = TRUE;   
            
            insert newAccountObj;
            
            //Insert User
            Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
            
            User userObj = new User();
            userObj.Login_ID__c = 'crtest';
            userObj.Alias = 'crtest';
            userObj.LastName = 'crtest';
            userObj.Email = 'crtest@crtest.com';
            userObj.UserName = 'crtest@crtest.com';
            userObj.ProfileId = profileNomuraSales.Id;
            userObj.EmailEncodingKey = 'UTF-8';
            userObj.LanguageLocaleKey = 'en_US';
            userObj.LocaleSidKey = 'en_US';
            userObj.TimeZoneSidKey = 'America/Los_Angeles';
            userObj.Region__c = 'Americas';
           
            insert userObj;
            
            
            //Insert Champions
            List<Sales_Champion__c> salesChampionList = new List<Sales_Champion__c>();
            
            Sales_Champion__c championForOldAccountObj = new Sales_Champion__c();
            championForOldAccountObj.Account__c = oldAccountObj.Id;
            championForOldAccountObj.Region__c = 'Americas';
            championForOldAccountObj.Champion_Type__c = 'Rsch Sales Champion';
            championForOldAccountObj.Sales_Champion__c = userObj.Id;
            
            salesChampionList.add(championForOldAccountObj);
            
            Sales_Champion__c championForNewAccountObj = new Sales_Champion__c();
            championForNewAccountObj.Account__c = newAccountObj.Id;
            championForNewAccountObj.Region__c = 'Americas';
            championForNewAccountObj.Champion_Type__c = 'Rsch Sales Champion';
            championForNewAccountObj.Sales_Champion__c = userObj.Id;
            
            salesChampionList.add(championForNewAccountObj);
            
            Sales_Champion__c dupChampionForNewAccountObj = new Sales_Champion__c();
            dupChampionForNewAccountObj.Account__c = newAccountObj.Id;
            dupChampionForNewAccountObj.Region__c = 'Americas';
            dupChampionForNewAccountObj.Champion_Type__c = 'Rsch Sales Champion';
            dupChampionForNewAccountObj.Sales_Champion__c = userObj.Id;
            
            salesChampionList.add(dupChampionForNewAccountObj);
            
            
            insert salesChampionList;
            
            //Insert entry in Client_Remediation__c Obect
            Client_Remediation__c crObj = new Client_Remediation__c();
            
            crObj.OLD_RG__c = 'RG1';
            crObj.NEW_RG__c = 'RG2';
            crObj.RG_ACTION__c = 'MERGE';
            crObj.OLD_RG_Account__c = oldAccountObj.Id;
            crObj.NEW_RG_Account__c = newAccountObj.Id;
            
            insert crObj;
            
            //Execute the Job
            Test.startTest();
        
            Database.executeBatch(new ChampionUpdatesForClientRemediationBatch(), 1);
           
            Test.stopTest();  
            
            //Not Checking Updates as reparenting is not allowed
                     
        }
            
    }
    
}