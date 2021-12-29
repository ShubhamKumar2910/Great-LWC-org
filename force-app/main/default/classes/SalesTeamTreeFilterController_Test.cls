@isTest(SeeAllData=true)
public class SalesTeamTreeFilterController_Test {
    static testMethod void testSalesTeamSearch() {
        List<Sales_Team_for_Coverage__c> salesCodeList = [select Sales_Desk_Division__c,Sales_Desk_Region__c,Desk_Name__c,Sales_Team__c from Sales_Team_for_Coverage__c where Sales_Team__c !=null limit 1];
        if(salesCodeList.size() > 0)
        {
			string salesTeam = salesCodeList[0].Sales_Team__c;
			system.debug('Sales Team included for search : '+salesTeam);
        	SalesTeamTreeFilterController.searchSalesTeam(salesTeam);    
        }
    }
    @isTest static void coverEmailLogs()
    {
        Test.startTest();
        CoverageBulkUploadUtility bulkManager = new CoverageBulkUploadUtility();
        bulkManager.emailLog('ERROR', 'Test', null, 'User', 'Test', null);
        bulkManager.emailLog('FAILURE', 'Test', null, 'User', 'Test', null);
        bulkManager.emailLog('FAILURE', 'Test', null, 'User', null, null);
        Test.stopTest();
    }

}