@isTest
public class CampaignMemberTriggerHandlerTest {

    @testSetup
    static void testData() {
        Id coverageCampaignId = Schema.getGlobalDescribe().get('Campaign').getDescribe().getRecordTypeInfosByName().get('Onboarding').getRecordTypeId();
        Campaign campaign = new Campaign();
        campaign.name = 'Test Campaign';
        campaign.RecordTypeId = coverageCampaignId;
        insert campaign;
        
        Account rgAccount = UtilityTesting.createRGAccount('RG Account', null, '12345', 'Biling street', 'Billing City', 'United Kingdom', true);
        insert rgAccount;
        
        Account rmAccount = UtilityTesting.createRMAccount('RM Test Account 1', rgAccount.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        rmAccount.Override_Contacts_MiFID_II_Entitlement__c = true;
        rmAccount.MiFID_II_Research_In_Scope__c = true;
        rmAccount.MiFIDII_Sales_Commentary_Allowed__c = 'Allowed';
        insert rmAccount; 
        
        Contact cont = UtilityTesting.createContact('firstname', 'lastname', 'test@test.com', '020204040404', 'Mr', rmAccount.Id, true);
        insert cont;
        
        Onboarding_Request__c obRequest = UtilityTesting.createOnboardingRequest ('LegacyAccount', cont.Id, 'meet', 'New Contact', 1200000.0, 'No', 'Yes','No', UserInfo.getUserId(), UserInfo.getUserId(), rmAccount.Id);
        insert obRequest;
        
        CampaignMemberStatus campMemberStatus = new CampaignMemberStatus(
            Label = CampaignService.ONBOARDING_CAMPAIGN_MEMBER_STATUS_PRIMARY,
            CampaignId = campaign.Id
        );
        insert campMemberStatus;
  
        CampaignMember campMember = new CampaignMember(
            CampaignId = campaign.Id,
            ContactId = cont.Id,
            Onboarding_Request__c = obRequest.Id,
            Status = CampaignService.ONBOARDING_CAMPAIGN_MEMBER_STATUS_PRIMARY
        );
        insert campMember;
    }
    
    @isTest
    static void getPreventDeleteOfPrimaryContact() {
        Map<Id, CampaignMember> campaignMemberIdToCampaignMember = new Map<Id, CampaignMember>();
        List<CampaignMember> campaignMembers = [SELECT Id, Name, CampaignId, Campaign_Record_Type_Id__c, Onboarding_Request__c, Status FROM CampaignMember];
        
        Test.startTest();
        String exMessage; 
        try {
            delete campaignMembers;
        } catch (Exception e) {
            exMessage = e.getMessage();
        }
        Test.stopTest();
        
        System.assertEquals(true, String.isNotBlank(exMessage));
        System.assertEquals(campaignMembers.size(), [SELECT COUNT() FROM CampaignMember]);
    }
    
    @isTest
    static void testValidateCampaignMemberWithoutObRequest() {
        Campaign campaign = [SELECT Id, Name FROM Campaign WHERE Name = 'Test Campaign' LIMIT 1];
        Account rmAccount = [SELECT Id FROM Account WHERE Name = 'RM Test Account 1'];
        Contact cont = UtilityTesting.createContact('firstname22', 'lastname2', 'test2@test.com', '020204040404', 'Mr', rmAccount.Id, true);
        insert cont;     
        
        CampaignMemberStatus campMemberStatus = new CampaignMemberStatus(
            Label = CampaignService.ONBOARDING_CAMPAIGN_MEMBER_STATUS_SECONDARY,
            CampaignId = campaign.Id
        );
        insert campMemberStatus;
        
        Test.startTest();
        String errMessage;
        try {
            CampaignMember campMember = new CampaignMember(
                CampaignId = campaign.Id,
                ContactId = cont.Id,
                Status = CampaignService.ONBOARDING_CAMPAIGN_MEMBER_STATUS_SECONDARY
            );
            insert campMember;
        } catch (exception e) {
            errMessage = e.getMessage();
        }
        Test.stopTest();
        
        System.assertEquals(true, String.isNotBlank(errMessage));
    }
    
    @isTest
    static void testInsertOfTwoPrimaryCampaignMembers() {
        Campaign campaign = [SELECT Id, Name FROM Campaign WHERE Name = 'Test Campaign' LIMIT 1];
        Account rmAccount = [SELECT Id FROM Account WHERE Name = 'RM Test Account 1'];
        Contact cont = UtilityTesting.createContact('firstname22', 'lastname2', 'test2@test.com', '020204040404', 'Mr', rmAccount.Id, true);
        insert cont;     
        
        Test.startTest();
        String errMessage;
        try {
            CampaignMember campMember = new CampaignMember(
                CampaignId = campaign.Id,
                ContactId = cont.Id,
                Status = CampaignService.ONBOARDING_CAMPAIGN_MEMBER_STATUS_PRIMARY
            );
            insert campMember;
        } catch (exception e) {
            errMessage = e.getMessage();
        }
        Test.stopTest();
        
        System.assertEquals(true, String.isNotBlank(errMessage));
    }    
    
    @isTest
    static void testPreventPrimaryContactStatusChange() {
        Campaign campaign = [SELECT Id, Name FROM Campaign WHERE Name = 'Test Campaign' LIMIT 1];
        CampaignMember campaignMemb = [SELECT Id, Status FROM CampaignMember WHERE CampaignId = :campaign.Id AND Status = :CampaignService.ONBOARDING_CAMPAIGN_MEMBER_STATUS_PRIMARY LIMIT 1];
        Test.startTest();
        String errMessage;
        try {
            campaignMemb.Status = CampaignService.ONBOARDING_CAMPAIGN_MEMBER_STATUS_SECONDARY;
            update campaignMemb;
        } catch (exception e) {
            errMessage = e.getMessage();
        }
        Test.stopTest();
        
        System.assertEquals(true, String.isNotBlank(errMessage));
    }
 }