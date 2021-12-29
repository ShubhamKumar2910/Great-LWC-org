@isTest
public class Sales_Champion_ControllerTest {
	@testSetup
    private static void setupTestData(){
    	Integer numTestAccounts = 3;
        Integer numTestUsers = 2;
        integer limits = 1;
        List<Account> testAccounts = new List<Account>();
		List<Sales_Champion__c> testSales = new List<Sales_Champion__c>();
        
        RecordType RGRecordType = [SELECT Id FROM RecordType WHERE Name = 'RG Account'];
        RecordType RSRecordType = [SELECT Id FROM RecordType WHERE Name = 'RS Account'];
        RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account'];
        
        system.debug('RGRecordType::'+ RGRecordType.Id);
        
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
        
        system.runAs(userList[0]){
            Account accountAdd = new Account();
            accountAdd.Name = 'TestAccount1';
            accountAdd.RDM_Org_ID__c = 'test1';
            accountAdd.RecordTypeId = RSRecordType.Id;
            accountAdd.BillingCity = 'California';
            accountAdd.BillingCountry = 'United States';
            accountAdd.BillingStreet = '52nd Street';
            insert accountAdd;
            
            Account accountAdd2 = new Account();
            accountAdd2.Name = 'TestAccount2';
            accountAdd2.RDM_Org_ID__c = 'test2';
            accountAdd2.RecordTypeId = RGRecordType.Id;
            accountAdd2.BillingCity = 'California';
            accountAdd2.BillingCountry = 'United States';
            accountAdd2.BillingStreet = '52nd Street';
            insert accountAdd2;
            
            Account accountAdd3 = new Account();
            accountAdd3.Name = 'TestAccount3';
            accountAdd3.RDM_Org_ID__c = 'test3';
            accountAdd3.RecordTypeId = RMRecordType.Id;
            accountAdd3.BillingCity = 'California';
            accountAdd3.BillingCountry = 'United States';
            accountAdd3.BillingStreet = '52nd Street';
            insert accountAdd3;
            
            system.debug('accountAdd2' + accountAdd2.Id);
            
            Sales_Champion__c salesChamp = new Sales_Champion__c();
			salesChamp.Account__c = accountAdd2.Id;
            salesChamp.Champion_Type__c = 'Rsch Sales Champion';
            salesChamp.Sales_Champion__c = userList[0].Id;
            salesChamp.Region__c = 'AEJ';
            insert salesChamp;
                      
           
        }
    }
        static testmethod void Sales_Champion_ControllerTest(){
            List<User> userList = [SELECT Id FROM User Where login_id__c =: 'test1tmp'];
            system.debug('userList:::'+ userList[0].Id);
            
            system.runAs(userList[0]){
                Test.startTest();
                
                Sales_Champion_Controller salesC = new Sales_Champion_Controller(new ApexPages.StandardController([SELECT Account__r.Id,Account__r.Name, Champion_Type__c, Region__c FROM Sales_Champion__c WHERE Account__r.isDeleted = false and Sales_Champion__r.Id =: userList[0].ID Order By Account__R.Name ]));
                salesC.limits = 1;
                salesC.counter = 3;
                salesC.recCount = 2;
                salesC.previous();
                salesC.next();
                salesC.getHasPrevious();
                salesC.getHasNext();
                salesC.getPageSize();          
                salesC.getSalesRecords();
                salesC.getPageNumber();
                salesC.getResultSize();
                salesC.getRecords();
                salesC.getTotalRecordCount();
                
                
            }
            
        }
        
    
}