@isTest
public class USMnthlyEmail_Test {
    static testmethod void testEmails(){ 
         list<user> user = UtilityTesting.CreateUsers(3);
         system.runas(user[0]){
        Test.startTest();
        
      /*  Profile p  = [SELECT Id From Profile WHERE Name='Nomura - Business Management' limit 1];
        Profile p1  = [SELECT Id From Profile WHERE Name='Nomura - Sales' limit 1];
        
        User supUser = new User();
        supUser.Alias = 'Vipin';
        supUser.UserRoleId = '00E28000000dzxQEAQ';
        supUser.Email = 'a@a.com';
        supUser.LastName = 'Pillai';
        supUser.Username = 'a@a.com';
        supUser.ProfileId = p.id;
        supUser.TimeZoneSidKey = 'America/Los_Angeles';
        supUser.EmailEncodingKey = 'UTF-8';        
        supUser.LanguageLocaleKey='en_US';
        supUser.LocaleSidKey='en_US';
        
        
        insert supuser;
        
        User subUser = new User();
        
        subUser.Alias = 'Som';
        subUser.UserRoleId = '00E28000000dzyoEAA';
        subUser.Email = 'b@b.com';
        subUser.LastName = 'Magre';
        subUser.Username = 'b@b.com';
        subUser.ProfileId = p1.id;
        subUser.TimeZoneSidKey = 'America/Los_Angeles';
        subUser.EmailEncodingKey = 'UTF-8';        
        subUser.LanguageLocaleKey='en_US';
        subUser.LocaleSidKey='en_US';
        
        
        insert subUser; */
        
        Supervisors__c supData = new Supervisors__c();
        supData.Supervisor_User_Id__c = user[1].id;
        supData.Supervisor_Name__c = 'Vipin~Pillai';
        supData.Supervisor_Role_Id__c = '00E28000000dzxQEAQ';
        supData.Supervisor_Role_Name__c = 'Desk Head';
        supData.Supervisor_Email_Address__c = 'a@a.com';
        
        insert supData;
        
        Coverage__c cvgDataAdd = new Coverage__c();
        
        cvgDataAdd.User_Id__c = user[1].id;
        cvgDataAdd.RG_Account_Name__c='test Account';
        cvgDataAdd.Coverage_Start_Date__c = Date.newInstance(2016, 11, 22);
        
        insert cvgDataAdd;
        
        Reportees__c userReportee = new Reportees__c();
        userReportee.Supervisor_Id__c = user[1].id;
        userReportee.Reportee_User_Id__c = user[2].id;
        userReportee.Reportee_User_Name__c = 'Somendra~Magre';
        userReportee.Reportee_Role_Id__c = '00E28000000dzyoEAA';
        userReportee.Reportee_Role_Name__c =  'Team Head';
        userReportee.Reportee_Email__c = 'b@b.com';
        insert userReportee;
        
        cvgDataAdd = new Coverage__c();
        
        cvgDataAdd.User_Id__c = user[2].id;
        cvgDataAdd.RG_Account_Name__c='test Account 1';
        cvgDataAdd.Coverage_Start_Date__c = Date.newInstance(2016, 11, 22);
        
        insert cvgDataAdd;
        
        US_Monthly_Emails eclass = new US_Monthly_Emails();
        Database.executeBatch(eclass);
        Test.stopTest();
    }
    }
}