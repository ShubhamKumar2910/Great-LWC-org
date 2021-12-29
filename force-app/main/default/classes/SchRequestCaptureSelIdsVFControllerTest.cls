/*
	Author 		: Pravin Kundal
	Company 	: Nomura
	Date 		: 16/01/2020
	Description : Tests for the SchRequestCaptureSelIdsVFController class.
*/
@isTest
public class SchRequestCaptureSelIdsVFControllerTest {
    static testMethod void testVFController() {
        System.debug('#### SchRequestCaptureSelIdsVFControllerTest.testVFController()');
        List<SCH_Request__c>SCHReqList = new List<SCH_Request__c>();
        SCHReqList.add(UtilityTesting.createSchRequest('Test RM Acc Name', 'US',  'BK', 'Prospect', 
                null, 'Test RG Acc (RG)', 
                null, 'Test RS Acc (RS)', 'US',
                false));
        SCHReqList.add(UtilityTesting.createSchRequest('Test RM Acc Name1', 'US',  'BK', 'Prospect', 
                null, 'Test RG Acc1 (RG)', 
                null, 'Test RS Acc1 (RS)', 'US',
                false));
        insert SCHReqList;
        Test.startTest();
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(SCHReqList);
            stdSetController.setSelected(SCHReqList);
            SchRequestCaptureSelIdsVFController apexCont = new SchRequestCaptureSelIdsVFController(stdSetController);
            apexCont.initializeApproveAction();
            apexCont.initializeRejectAction();
            apexCont.initAddCommentAction();
            apexCont.initializeCancelAction();
        Test.stopTest();
    }
}