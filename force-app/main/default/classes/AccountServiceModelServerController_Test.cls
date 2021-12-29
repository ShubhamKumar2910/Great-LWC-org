@isTest
public class AccountServiceModelServerController_Test {
        
    static testMethod void testASM(){
        Test.startTest();
        
        RecordType actualType = [SELECT Id FROM RecordType WHERE Name = 'Actual' AND RecordType.SobjectType= 'Account_Service_Model__c'];
		
        Account_Service_Model__c asm = new Account_Service_Model__c();
        asm.Name = 'Equity Core (value)';
        asm.RecordTypeId = actualType.Id;
        asm.Is_Contact_Count__c = 'NO';
        asm.Item_Name__c = 'Analyst : calls';
        asm.Order__c = 3;
		asm.stable_version__c=1;
		asm.CALL_REPORT_TYPE__C='Idea Pitch;Model Request';
		asm.WEIGHT__C= 5;
        	
        Map<String, Map<String, String>> labels = AccountServiceModelServerController.initialiseLabels();
        System.assertEquals(1, labels.size());
        
    	List<String> models = AccountServiceModelServerController.getAccountModels();
        //System.assert(models.size() > 0);
        
        List<String> callReport = AccountServiceModelServerController.getCallReportType();
        System.assert(callReport.size() > 0);
        
    	List<String> dealAxisEventType = AccountServiceModelServerController.getDealAxisEventType();
        System.assert(dealAxisEventType.size() > 0);
        
       // List<String> dealAxisEventMeetingType = AccountServiceModelServerController.getDealAxisEventMeetingType();
       // System.assert(dealAxisEventMeetingType.size() > 0);
        
        List<String> contactCount = AccountServiceModelServerController.getContactCount();
        System.assert(contactCount.size() > 0);
        
        String listViewId = AccountServiceModelServerController.getListViews();
        System.assert(listViewId.length() > 0);

        String savedRecord = AccountServiceModelServerController.saveAccountServiceModel(asm);
        system.debug(LoggingLevel.INFO, 'saveRecordID----' + savedRecord);
        
    }
}