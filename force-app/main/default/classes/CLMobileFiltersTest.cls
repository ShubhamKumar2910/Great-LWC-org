@isTest
public class CLMobileFiltersTest {

    @isTest
    public static void testDataSetup(){
        
        Id recordTypeIdForRG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();   
        Id recordTypeIdForRM = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
        Id phoneBookRecordTypeId = Schema.getGlobalDescribe().get('Campaign').getDescribe().getRecordTypeInfosByName().get('Phone Book').getRecordTypeId(); 
        
        Account rgAccount1 = new Account();
        rgAccount1.Name = 'test_account';
        rgAccount1.RecordTypeId = recordTypeIdForRG;        
        rgAccount1.Active__c = true;
        insert rgAccount1;
        
        Account rmAccount1 = new Account();
        rmAccount1.Name = 'test_account';
        rmAccount1.RecordTypeId = recordTypeIdForRM;
		rmAccount1.ParentId = rgAccount1.Id;        
        rmAccount1.BillingCity = 'California';
        rmAccount1.BillingStreet = '52nd Street';
        rmAccount1.BillingCountry = 'United States';
        rmAccount1.Active__c = true;
        insert rmAccount1;
        
        Contact contact1 = UtilityTesting.createContact('manmeet', 'test', 'manmeet@test.com', '+000 9279 1771', 'Mr.', rmAccount1.Id, true);
        insert contact1;
            
        Campaign campaign1 = new Campaign();
        campaign1.Name = 'Test Campaign';
        campaign1.RecordTypeId = phoneBookRecordTypeId;
        insert campaign1;
        
        CampaignMember camMember1 = new CampaignMember();
        camMember1.ContactId = contact1.Id;
        camMember1.CampaignId = campaign1.Id;
        insert camMember1;
        
    }
    
    @isTest
    public static void startTesting(){
    	Test.startTest();
        testDataSetup();
        List<Account> accountList = [SELECT Id, Name FROM Account WHERE Name LIKE 'test_account' LIMIT 1];
        List<Campaign> campaignList = [SELECT Id, Name FROM Campaign WHERE Name LIKE 'Test Campaign' LIMIT 1];
        
        System.debug('--campaignList[0].Id--' + campaignList[0].Id);
        
       	List<CLMobileFilterRGAcc> rgList =  CLMobileFilters.getRGAccounts(campaignList[0].Id);
       	System.assertNotEquals(rgList, null);
        
       	List<ComboboxListItemWrapper> wrapperList = CLMobileFilters.getAddressesForAccount(accountList[0].Id, campaignList[0].Id);        
        System.assertNotEquals(wrapperList, null);
        
        Test.stopTest();
    }
}