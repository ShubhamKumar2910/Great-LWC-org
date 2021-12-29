/**
 *	Author 		: Pravin Kundal
 *	Company 	: Nomura
 *  Description : This class contains unit tests for validating the behavior of Apex class -  SchRequestService
 *
 */

@isTest
public class SchRequestServiceTest {
    static testMethod void testProcessSchReqAction() {    
        List<SchRequestService.SchRequestAction> SchReqApprActionList = new List<SchRequestService.SchRequestAction>();
        SchRequestService.SchRequestAction schReqApprAction = new SchRequestService.SchRequestAction();
        
        schReqApprAction.schReqAction = 'Approve';//SchRequestService.SCH_REQUEST_APPROVAL_ACTION.SCH_REQ_APPROVE; 
        schReqApprAction.SchReqIdList = new List<String>();
        schReqApprAction.comments = 'Hello';
        SchReqApprActionList.add(schReqApprAction);
        SchRequestService.processSchReqAction(SchReqApprActionList);
    }
}