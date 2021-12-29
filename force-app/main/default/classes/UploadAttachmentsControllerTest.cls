/**
 * @Description: Unit test for the UploadAttachmentsController
 *
 * Change Log
 *
 * Date         Author          Change Description
 * ---------------------------------------------------------------------------------------------------------------------------------
 * 8/11/2017   T.Sotiraki      Created Class
 */
@isTest(SeeAllData = false)
private class UploadAttachmentsControllerTest {

    @isTest 
    private static void doesUserHaveChatterPermissionTest() {
		//Generate Test Data
		User salesUser = UtilityTesting.createUsersWithProfile(1, 'Nomura - Sales')[0];
        Test.startTest();
        System.runAs(salesUser){
			UploadAttachmentsController controller = new UploadAttachmentsController();
			
			Boolean result = UploadAttachmentsController.doesUserHaveChatterPermission();
			
			System.assertEquals(result, false);
		}
        
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Chatter_Permission_Set'];
		
		PermissionSetAssignment psa = new PermissionSetAssignment();        
        psa.AssigneeId = salesUser.Id;
        psa.PermissionSetId = ps.Id;

        insert psa;
        
        
        
        System.runAs(salesUser){
			UploadAttachmentsController controller = new UploadAttachmentsController();
			
			Boolean result = UploadAttachmentsController.doesUserHaveChatterPermission();
			
			System.assertEquals(result, true);
		}
        Test.stopTest();
	}
    
    @isTest
    private static void doesUserHaveEditPermission() {
		UploadAttachmentsController controllerObj = new UploadAttachmentsController();
        
        User integrationUserObj = [SELECT Id, Login_Id__c, Name, Email, UserName, ProfileId 
                        		   FROM User 
                                   WHERE Login_Id__c = 'sfadmin' LIMIT 1];
        
        System.runAs(integrationUserObj){
           Id recordTypeIdForRG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();   
            
           Account accountRG  = new Account(); 
           accountRG.Name = 'RG_Account_Dummy';
           accountRG.RDM_Org_ID__c = 'RGXXXXXX';            
           accountRG.RecordTypeId = recordTypeIdForRG;
           accountRG.Active__c = TRUE;  
            
           insert accountRG;
            
           Boolean hasAccess = UploadAttachmentsController.doesUserHaveEditPermission(accountRG.Id);
           System.assert(hasAccess);
        }
        
		User salesUser = UtilityTesting.createUsersWithProfile(1, 'Nomura - Sales')[0];  
        
        System.runAs(salesUser){
            List<Account> accountList = [SELECT Id, Name, RDM_Org_Id__c FROM Account
                                         WHERE RDM_Org_Id__c = 'RGXXXXXX'];
            if(accountList != null && accountList.size() > 0){
                Account accountObj = accountList.get(0);
                
                Boolean hasAccess = UploadAttachmentsController.doesUserHaveEditPermission(accountObj.Id);
           		System.assertEquals(FALSE, hasAccess);
            }
        }
    }
    
}