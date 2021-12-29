@isTest
public class OnboardingReqAndProdServiceTest {
    @testSetup
    static void testData() {
        Account rgAccount = UtilityTesting.createRGAccount('RG Account', null, '12345', 'Biling street', 'Billing City', 'United Kingdom', true);
        insert rgAccount;
        
        Account rmAccount = UtilityTesting.createRMAccount('RM Test Account 1', rgAccount.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        rmAccount.Override_Contacts_MiFID_II_Entitlement__c = true;
        rmAccount.MiFID_II_Research_In_Scope__c = true;
        rmAccount.MiFIDII_Sales_Commentary_Allowed__c = 'Allowed';
        insert rmAccount; 
        
        Contact cont =  UtilityTesting.createContact('firstname', 'lastname', 'test@test.com', '020204040404', 'Mr', rmAccount.Id, true);
        insert cont;
        
        User salesRequestor = UtilityTesting.createUsersWithProfile(1, 'Nomura - Sales')[0];
        salesRequestor.Region__c = 'EMEA';
        salesRequestor.IsActive = true;
        update salesRequestor;
        
        Onboarding_Request__c obRequest = UtilityTesting.createOnboardingRequest ('LegacyAccount', cont.Id, 'meet', 'New Contact', 1200000.0, 'No', 'Yes','No', salesRequestor.Id, UserInfo.getUserId(),rmAccount.Id);
        insert obRequest;
        
        Onboarding_Product__c obProduct = UtilityTesting.createOnboardingProduct('Cash', 'Fixed Income Cash', obRequest.Id, 'High', 'Principal', '6-10', '3M-5M', 'Yes', 
                                                                                'Consistently highly relevant to market price action and trends', 'Straightforward bid offer and capturable predictability/ programs plus reliable dialogue around intentions/axes',
                                                                                'United Kingdom - London', new List<String> {'NIHK - NOMURA INTERNATIONAL (HONG KONG) LIMITED'}, 
                                                                                'United Kingdom - London');
        insert obProduct;
    }
    
    @isTest
    static void testSubmitRequestForSalesCAOApproval() {
        Onboarding_Request__c obRequest = [SELECT Id, Status__c, CreatedById, OwnerId FROM Onboarding_Request__c LIMIT 1];
        System.assertEquals(0, [SELECT COUNT() FROM ProcessInstance WHERE TargetObjectId = :obRequest.Id AND Status = 'Pending']);
        
        Test.startTest();
        OnboardingReqAndProdService.submitOnbReqForSalesCaoApproval(new List<String> {obRequest.Id});
        Test.stopTest();
        System.assertEquals(UtilityTesting.salesCAOProcessExists, [SELECT COUNT() FROM ProcessInstance WHERE TargetObjectId = :obRequest.Id AND Status = 'Pending']);
    }
    
    @isTest
    static void testGetOnbProdReqsForOnbReqs() {
        Onboarding_Request__c obRequest = [SELECT Id FROM Onboarding_Request__c LIMIT 1];
        Test.startTest();
        Map<String,List<Onboarding_Product__c>> obProducts = OnboardingReqAndProdService.getOnbProdReqsForOnbReqs(new Set<String> {obRequest.Id}, 'Cash', 'Fixed Income Cash');
        Test.stopTest();
        
        System.assert(!obProducts.isEmpty(), 'Products should have been returned');
        System.assertEquals(1, obProducts.get(obRequest.Id).size());
    }
    
    @isTest 
    static void testGetHistoricProdReqData() {
        Onboarding_Request__c obRequest = [SELECT Id, RM_Account__c, Status__c FROM Onboarding_Request__c LIMIT 1];
        Account rmAccount = [SELECT Id, Stage__c FROM Account WHERE Id = :obRequest.RM_Account__c];

        Test.startTest();
        rmAccount.Stage__c = 'Fenergo Managed Client';
        update rmAccount;
        obRequest.Status__c = 'Submitted';
        update obRequest;
        Map<String, String> historicData = OnboardingReqAndProdService.getHistoricProdReqData(obRequest.Id, 'Cash', 'Fixed Income Cash');
        Test.stopTest();
        
        System.assert(!historicData.isEmpty());
        System.assertEquals(historicData.get('Trading_Desk_Rank_Relevance_To_Market__c'), [SELECT Trading_Desk_Rank_Relevance_To_Market__c FROM Onboarding_Product__c WHERE Products_Category__c = 'Cash' LIMIT 1].Trading_Desk_Rank_Relevance_To_Market__c);
    }
    
    @isTest
    static void testGetOnbReqAndProdReqDetails() {
        Account rmAccount = [SELECT Id FROM Account WHERE Name = 'RM Test Account 1'];
        Test.startTest();
        Map<String,Map<String,Onboarding_Request__c>> obReqAndProds = OnboardingReqAndProdService.getOnbReqAndOnbProdReqDetails(new List<String> {rmAccount.Id});
        Test.stopTest();
        
        System.assert(!obReqAndProds.isEmpty(), 'Onboarding Req details should have been returned');
        System.assertEquals(1, obReqAndProds.get(rmAccount.Id).size());
    }
    
    @isTest
    static void testGetOnbReqDetails() {
        Onboarding_Request__c obRequest = [SELECT Id, Physical_Location_Of_Sales_Requestor__c FROM Onboarding_Request__c LIMIT 1];
        
        Test.startTest();
        Onboarding_Request__c obReqReturned = OnboardingReqAndProdService.getOnbReqDetails(obRequest.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, obReqReturned, 'Onboarding Request should have been returned');
        System.assertEquals(obRequest.Physical_Location_Of_Sales_Requestor__c, obReqReturned.Physical_Location_Of_Sales_Requestor__c);
    }
    
    @isTest
    static void testSetupCampaignAsync() {
        Onboarding_Request__c obRequest = [SELECT Id, Campaign__c FROM Onboarding_Request__c LIMIT 1];
       	obRequest.Campaign__c = null;
        update obRequest;
        
        System.assertEquals(null, [SELECT Campaign__c FROM Onboarding_Request__c LIMIT 1].Campaign__c);
        System.assertEquals(1, [SELECT COUNT() FROM Campaign]);

        Test.startTest();
        OnboardingReqAndProdService.setupCampaignForOnbRequest(new List<String> {obRequest.Id});
        Test.stopTest();
        
        System.assertNotEquals(null, [SELECT Campaign__c FROM Onboarding_Request__c LIMIT 1].Campaign__c);
        System.assertEquals(2, [SELECT COUNT() FROM Campaign]);
    }
    
    @isTest
    static void testSetupPrimaryContact() {
        Contact cont = [SELECT Id, AccountId FROM Contact WHERE Email = 'test@test.com'];
        Onboarding_Request__c obRequest = UtilityTesting.createOnboardingRequest ('LegacyAccount', cont.Id, 'meet', 'New Contact', 1200000.0, 'No', 'Yes','No',  UserInfo.getUserId(), UserInfo.getUserId(), cont.AccountId);
        insert obRequest;  
        
        System.assertEquals(0, [SELECT COUNT() FROM CampaignMember WHERE Onboarding_Request__c = :obRequest.Id AND Status = 'Primary']);
        
        Test.startTest();
        OnboardingReqAndProdService.setupCampaignForOnbRequest(new List<String> {obRequest.Id});
		OnboardingReqAndProdService.setupPrimaryContact(new List<Onboarding_Request__c> {obRequest});
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM CampaignMember WHERE Onboarding_Request__c = :obRequest.Id AND Status = 'Primary']);
    }
    
    @isTest
    static void testFindOnbRequestForCampaign() {
        Onboarding_Request__c obRequest = [SELECT Id, Campaign__c FROM Onboarding_Request__c LIMIT 1];
        Test.startTest();
        Map<String, String> campIdToOnbReqId = OnboardingReqAndProdService.findOnbRequestForCampaign(new Set<String> {obRequest.Campaign__c});
        Test.stopTest();
        
        System.assertEquals(1, campIdToOnbReqId.size());
        System.assertEquals(obRequest.Id, campIdToOnbReqId.get(obRequest.Campaign__c));
    }
    
    @isTest
    static void testProcessOnbAction() {        
        Onboarding_Request__c obRequest = [SELECT Id, Status__c, CreatedById, OwnerId FROM Onboarding_Request__c LIMIT 1];
        System.assertEquals(0, [SELECT COUNT() FROM ProcessInstance WHERE TargetObjectId = :obRequest.Id AND Status = 'Pending']);
        
        Test.startTest();
        OnboardingReqAndProdService.submitOnbReqForSalesCaoApproval(new List<String> {obRequest.Id});
        Test.stopTest();
        
        System.assertEquals(UtilityTesting.salesCAOProcessExists, [SELECT COUNT() FROM ProcessInstance WHERE TargetObjectId = :obRequest.Id AND Status = 'Pending']);
        
        OnboardingReqAndProdService.OnbRequestAction obReqAction = new OnboardingReqAndProdService.OnbRequestAction();
        obReqAction.onbReqAction = OnboardingReqAndProdService.ONB_REQUEST_BULK_ACTION.ONB_REQ_APPROVE.name();
        obReqAction.onbReqIdList = new List<String> {obRequest.Id};
        obReqAction.comments = '';
        List<String> strList = OnboardingReqAndProdService.processOnbReqAction(new List<OnboardingReqAndProdService.OnbRequestAction> {obReqAction});
        System.debug('--after--' + strList);
        if(strList != null){
            if(strList[0] == 'Action performed Successfully')
        		System.assertEquals(UtilityTesting.salesCAOProcessExists, [SELECT COUNT() FROM ProcessInstance WHERE TargetObjectId = :obRequest.Id AND Status = 'Approved']);
            else
                System.assertEquals(0, [SELECT COUNT() FROM ProcessInstance WHERE TargetObjectId = :obRequest.Id AND Status = 'Approved']);
        }
        
    }

}