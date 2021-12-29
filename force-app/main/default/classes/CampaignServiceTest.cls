/**
 *	Author 		: Pravin Kundal
 *	Company 	: Nomura
 *  Description : This class contains unit tests for validating the behavior of Apex class - CampaignService 
 *
 */
@isTest 
public class CampaignServiceTest {
	static testMethod void testBulkUploadCampaignFunctionality() {
		System.debug('#### CampaignServiceTest::testBulkUploadCampaignFunctionality()');
		final String CAMPAIGN_RT_NAME_BULK_UPLOAD  = 'Bulk_Upload';
		String campId = CampaignService.getBulkUploadCampaignRec(null, CAMPAIGN_RT_NAME_BULK_UPLOAD, 'ApplyMiFIDIIEntitlements');
		System.assertEquals(String.isNotBlank(campId), true);
		
		String reportURL = CampaignService.getBulkUploadReportURL(campId, 'Bulk_Upload_Campaign_Report');
		System.assertEquals(String.isNotBlank(reportURL), true);
		
		delete ([SELECT Id From campaign]);		
		// create some accounts	
    	List<Account> testAccounts =  new List<Account>();  
   		List<Contact> contacts = new List<Contact>(); 

        Account sLevel = UtilityTesting.createRSAccount(
            'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(sLevel);
            
        Account rg1 = UtilityTesting.createRGAccount(
                'G1 Test Account', sLevel.Id, 'RGTest1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1);
            
        Account rg1rm1 = UtilityTesting.createRMAccount(
                'RM Test Account 1', rg1.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        rg1rm1.Override_Contacts_MiFID_II_Entitlement__c = true;
        rg1rm1.MiFID_II_Research_In_Scope__c = true;
        rg1rm1.MiFIDII_Sales_Commentary_Allowed__c = 'Not Allowed';
        testAccounts.add(rg1rm1);
        
        insert testAccounts;
        System.debug('Accounts inserted');
        
        List<Contact> ContactList = new List<Contact>();
        Contact oCOnt = UtilityTesting.createContact('John', 'Smith', 'johnnysmith@test.com', '(212) 333-4561', 'Dear [FirstName]', rg1rm1.Id, true);
    	oCOnt.RG_Account__c=rg1.Id;
    	ContactList.add(oCOnt);
        insert ContactList;
        
        System.debug('contacts inserted');
        
      	Boolean isErr=false;
      	Test.startTest();
      	try {
      		List<Account> AccToUpdList = new List<Account>();
      		AccToUpdList.add(new Account(Id=rg1rm1.Id, MiFIDII_Sales_Commentary_Allowed__c = 'Allowed', MiFID_II_Product_Subscriptions__c='FIGL',
      				Service_Type__c='Full Service'));
      		update AccToUpdList;
      	} catch(Exception ex) {
      		System.debug('Error : '+ex.getMessage());
      		isErr = true;
      	}
      	System.debug('Before stopTest');
      	Test.stopTest();
      	System.debug('After stopTest');

		System.assertEquals(isErr, false);
		
		String campaignId = [SELECT Id FROM Campaign][0].Id;
		System.assertEquals(String.isNotBlank(campaignId), true);
		CampaignService.BulkUpdateJobRunInfo bulkUpldJobInfo = CampaignService.getBulkUploadJobDetails(campaignId);
		System.assertNotEquals(bulkUpldJobInfo.jobId, null);
		String campIdFromJobDetails = CampaignService.getBulkUploadCampaignRec(bulkUpldJobInfo.jobId, CAMPAIGN_RT_NAME_BULK_UPLOAD, 'ApplyMiFIDIIEntitlements');
		System.assertEquals(campaignId, campIdFromJobDetails);
		
		List<CampaignService.BulkUpdateJobRunInfo> PerviousJobRunInforList = CampaignService.getPreviousJobRunInfoForUser(UserInfo.getUserId(), 
    				CampaignService.BulkUploadCampaignJobTypes.BULK_UPLOAD_MIFIDII_ENTITLEMENTS_FROM_RM_ACCOUNT.name(), 10);
		
		CampaignService.updateBulkUploadCampaignJobStatus(campaignId, bulkUpldJobInfo);		
		System.assertEquals(CampaignService.getNumbeContactsInCampaign(campaignId), 1); 	
	
	}
}