@isTest
public class IsUserOnCoverageOrBMProfile_Test {
    
    @testSetup static void bmUser()
    {
        Profile bmUserProfile = [SELECT Id FROM Profile WHERE Name='Nomura - Business Management'];
       	Profile instinetUserProfile = [SELECT Id FROM Profile WHERE Name='Instinet - Business Management']; 
       	Profile salesUserProfile = [SELECT Id FROM Profile WHERE Name='Nomura - Sales'];
        User bmUser = new User(Alias = 'bmUser', Email='bmUser@testorg.com', 
                               EmailEncodingKey='UTF-8', LastName='bmUserTesting', LanguageLocaleKey='en_US', 
                               LocaleSidKey='en_US', ProfileId = bmUserProfile.Id, 
                               TimeZoneSidKey='America/Los_Angeles', UserName='bmUser@testorg.com'+ System.currentTimeMillis()); 
        insert bmUser;
        
        
        UserRole RoleForId= [SELECT Id FROM UserRole Where DeveloperName='Americas_FI_Team_Head_NY_Pass_Thru_Agency_Mortgages'];
        User childUser = new User(Alias = 'ncUser', Email='ncUser@testorg.com', 
                                  EmailEncodingKey='UTF-8', LastName='ncUserTesting', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = salesUserProfile.Id,UserRoleId=RoleForId.Id,
                                  TimeZoneSidKey='America/Los_Angeles', UserName='ncUser@testorg.com'+ System.currentTimeMillis(), Login_Id__c = 'ncUser');
        insert childUser;
        
        
        UserRole RoleForId1= [SELECT Id FROM UserRole Where DeveloperName='Americas_FI_Desk_Head_Agency_Mortgages_and_SP_Sales_Amer'];
        User parentUser = new User(Alias = 'npUser', Email='npUser@testorg.com', 
                                   EmailEncodingKey='UTF-8', LastName='npUserTesting', LanguageLocaleKey='en_US', 
                                   LocaleSidKey='en_US', ProfileId = salesUserProfile.Id,UserRoleId= RoleForId1.Id,
                                   TimeZoneSidKey='America/Los_Angeles', UserName='npUser@testorg.com'+ System.currentTimeMillis());
        insert parentUser;
        
        
        User IUser = new User(Alias = 'IUser', Email='IUser@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName='IUserTesting', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = instinetUserProfile.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='I@testorg.com'+ System.currentTimeMillis()); 
        insert IUser;
        
        User nonCUser = new User(Alias = 'nonCUser', Email='nonCovUser@testorg.com', 
                                  EmailEncodingKey='UTF-8', LastName='nonCovUserTesting', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = salesUserProfile.Id,UserRoleId=RoleForId.Id,
                                  TimeZoneSidKey='America/Los_Angeles', UserName='nonCovUser@testorg.com'+ System.currentTimeMillis(), Login_Id__c = 'nonCUser');
        insert nonCUser;
    }
    
    static testmethod void testIsBMUser(){
        Test.startTest();
        
            RecordType RGRecordType = [SELECT Id FROM RecordType WHERE Name = 'RG Account' ];
            RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account' ];
            Account rgAccount  = new Account(); 
            rgAccount.Name = 'RGTestAccount';
            rgAccount.RDM_Org_ID__c = 'TRG12345';            
            rgAccount.RecordTypeId = RGRecordType.Id;
            rgAccount.Active__c = true;
            rgAccount.BillingCity = 'California';
            rgAccount.BillingCountry = 'United States';
            rgAccount.BillingStreet = '52nd Street' ;
            insert rgAccount;
                
            Account rmAccount  = new Account(); 
            rmAccount.Name = 'RMTestAccount';
            rmAccount.RDM_Org_ID__c = 'TRM12345';            
            rmAccount.RecordTypeId = RMRecordType.Id;
            rmAccount.ParentId = rgAccount.Id;
            rmAccount.Active__c = true;
            rmAccount.BillingCity = 'California';
            rmAccount.BillingCountry = 'United States';
            rmAccount.BillingStreet = '52nd Street' ;
            insert rmAccount; 
            
            User bmUser = [Select Id from User where Alias='bmUser' ];
            User parentUser = [Select Id from User where Alias='npUser' ];
            User childUser = [Select Id,Login_ID__c,IsActive from User where Alias='ncUser' ];
            User IUser = [Select Id,Login_ID__c from User where Alias='IUser'];
       		User sfadmin = [Select Id from User where alias='sfadmin'];
            User nonCovUser = [Select Id from User where alias='nonCUser'];
          
            System.runAs(sfadmin)
            {
                Sales_Team_for_Coverage__c STC = new Sales_Team_for_Coverage__c();
                STC.Name = 'ncUserTesting';
                STC.Coverage_Id__c = '1234';
                STC.Sales_Code_Login_ID__c = childUser.Login_ID__c;
                insert STC;
                
                
                Sales_Team_User__c STU = new Sales_Team_User__c();
                STU.Sales_Team_for_Coverage__c= STC.Id;
                STU.User__c = childUser.Id;
                Insert STU;

                RecordType rmCoverageTeamRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Active_Coverage' ];
                Coverage_Team_Member__c rmCoverageTeam = new Coverage_Team_Member__c();
                rmCoverageTeam.Account__c = rmAccount.id;
                rmCoverageTeam.RecordTypeId =rmCoverageTeamRecordType.Id;
                rmCoverageTeam.Sales_Team_for_Coverage__c = STC.Id;
                insert rmCoverageTeam;

            }
            
           
        
           
        
            
         
             
            System.runAs(bmUser) {
                // The following code runs as user 'bmUser' 
                
                Test.setCurrentPageReference(new PageReference('Page.GMClientScorecard')); 
                System.currentPageReference().getParameters().put('id', rmAccount.id);    
                IsUserOnCoverageOrBMProfileController controllerObj = new IsUserOnCoverageOrBMProfileController(new ApexPages.StandardController(rmAccount));
                boolean hasAccess = controllerObj.getCoveringOrIsBM();
                System.debug('has RM Access:'+ hasAccess);
            
                System.currentPageReference().getParameters().put('id', rgAccount.id);    
                controllerObj = new IsUserOnCoverageOrBMProfileController(new ApexPages.StandardController(rgAccount));
                hasAccess = controllerObj.getCoveringOrIsBM();
                System.debug('has RG Access:'+ hasAccess);
            } 
              System.runAs(nonCovUser) {
                // The following code runs as user 'bmUser' 
                
                Test.setCurrentPageReference(new PageReference('Page.GMClientScorecard')); 
                System.currentPageReference().getParameters().put('id', rmAccount.id);    
                IsUserOnCoverageOrBMProfileController controllerObj = new IsUserOnCoverageOrBMProfileController(new ApexPages.StandardController(rmAccount));
                boolean hasAccess = controllerObj.getCoveringOrIsBM();
                System.debug('has RM Access:'+ hasAccess);
            
                System.currentPageReference().getParameters().put('id', rgAccount.id);    
                controllerObj = new IsUserOnCoverageOrBMProfileController(new ApexPages.StandardController(rgAccount));
                hasAccess = controllerObj.getCoveringOrIsBM();
                System.debug('has RG Access:'+ hasAccess);
            } 
        
             System.runAs(childUser) {
                // The following code runs as user 'childUser' 
                Sales_Team_for_Coverage__c Stc = [select OwnerId from Sales_Team_for_Coverage__c where OwnerId = :childUser.Id];
                Test.setCurrentPageReference(new PageReference('Page.GMClientScorecard')); 
                System.currentPageReference().getParameters().put('id', rmAccount.id);    
                IsUserOnCoverageOrBMProfileController controllerObj = new IsUserOnCoverageOrBMProfileController(new ApexPages.StandardController(rmAccount));
                boolean hasAccess = controllerObj.getCoveringOrIsBM();
                System.debug('has RM Access:'+ hasAccess);
                System.currentPageReference().getParameters().put('id', rgAccount.id);    
                controllerObj = new IsUserOnCoverageOrBMProfileController(new ApexPages.StandardController(rgAccount));
                hasAccess = controllerObj.getCoveringOrIsBM();
                System.debug('has RG Access:'+ hasAccess);
            }  
             
             System.runAs(parentUser) {
                // The following code runs as user 'parentUser' 
                
                Test.setCurrentPageReference(new PageReference('Page.GMClientScorecard')); 
                System.currentPageReference().getParameters().put('id', rmAccount.id);    
                IsUserOnCoverageOrBMProfileController controllerObj = new IsUserOnCoverageOrBMProfileController(new ApexPages.StandardController(rmAccount));
                boolean hasAccess = controllerObj.getCoveringOrIsBM();
                System.debug('has RM Access:'+ hasAccess);
            
                System.currentPageReference().getParameters().put('id', rgAccount.id);    
                controllerObj = new IsUserOnCoverageOrBMProfileController(new ApexPages.StandardController(rgAccount));
                hasAccess = controllerObj.getCoveringOrIsBM();
                System.debug('has RG Access:'+ hasAccess);
            }  
        System.runAs(IUser) {
                // The following code runs as user 'parentUser' 
                System.debug('Current User: ' + UserInfo.getUserName());
                System.debug('Current Profile: ' + UserInfo.getProfileId()); 
                
                Test.setCurrentPageReference(new PageReference('Page.GMClientScorecard')); 
                System.currentPageReference().getParameters().put('id', rmAccount.id);    
                IsUserOnCoverageOrBMProfileController controllerObj = new IsUserOnCoverageOrBMProfileController(new ApexPages.StandardController(rmAccount));
                boolean hasAccess = controllerObj.getCoveringOrIsBM();
                System.debug('has RM Access:'+ hasAccess);
            
                System.currentPageReference().getParameters().put('id', rgAccount.id);    
                controllerObj = new IsUserOnCoverageOrBMProfileController(new ApexPages.StandardController(rgAccount));
                hasAccess = controllerObj.getCoveringOrIsBM();
                System.debug('has RG Access:'+ hasAccess);
            }  
             
        Test.stopTest();
     }    

}