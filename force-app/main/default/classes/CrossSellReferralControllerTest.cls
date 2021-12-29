@isTest
public class CrossSellReferralControllerTest {
    @testSetup
    private static void setupTestData(){

    }
    static testmethod void CrossSellReferralControllerTest() {
        Test.startTest();
        CrossSellReferralController CrossSellReferralControllerObj = new CrossSellReferralController();
        String commonTool_recordId = CommonTools.getRecordTypeId('Opportunity','Cross Sell Referral');
        String crossSellReferral_recordId = CrossSellReferralController.getRecordTypeId('Opportunity','Cross Sell Referral');        
        Test.stopTest(); 
        System.assertEquals(commonTool_recordId, crossSellReferral_recordId,'Mismatch Record Type Id');
    }
}