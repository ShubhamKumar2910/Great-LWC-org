@isTest
public class CustomToolBarController_Test {
	static testmethod void testCustomToolbarController(){
        
        Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        
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
        
        insert userObj;
        
        System.runas(userObj){
            Test.startTest();
        
            CustomToolBarController controllerObj = new CustomToolBarController();
            CustomToolBarController.CurrentUserDetail currentUserDetailObj = CustomToolBarController.getCurrentUserDetails();
            CustomToolBarController.getEMALink();
            
            System.debug('currentUserDetailObj.showCoverageButton--' + currentUserDetailObj.showCoverageButton);            
            
            System.assertEquals(TRUE, currentUserDetailObj.showCoverageButton);
            System.assertEquals(FALSE, currentUserDetailObj.showSalesChampionButton);
            System.assertEquals(TRUE, currentUserDetailObj.showUploadBulkCoverageButton);
            //System.assert(CustomToolBarController.getCoverageOptionvisibility() != NULL);
           
            Test.stopTest();
        }
        
        
    }
}