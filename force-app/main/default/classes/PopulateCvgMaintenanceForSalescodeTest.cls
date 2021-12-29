@isTest
public class PopulateCvgMaintenanceForSalescodeTest {

    static testMethod void PopulateCvgMaintenanceForSalescodeBatch(){
        Test.startTest();

        List<Sales_Team_for_Coverage__c> salesTeamForCoverageList = new List<Sales_Team_for_Coverage__c>();
        Sales_Team_for_Coverage__c salesTeamForCoverageObj = new Sales_Team_for_Coverage__c();
        salesTeamForCoverageObj.Coverage_ID__c = '1234XX';
        salesTeamForCoverageObj.Name = 'TestDummy1LN/TestDummy2LN';
        salesTeamForCoverageObj.Sales_Team__c = 'Test Team';
        salesTeamForCoverageObj.Desk_Code__c = 'FI-AB-2D';
        salesTeamForCoverageObj.Sales_Desk_Region__c = 'Europe';
        salesTeamForCoverageObj.Sales_Desk_Division__c = 'Fixed Income';
        salesTeamForCoverageObj.Sales_Code_Login_ID__c = 'dummy';
        salesTeamForCoverageObj.Is_Split_Sales_Code__c = true;
        salesTeamForCoverageObj.Active__c = true;
        salesTeamForCoverageObj.is_Dummy__c = false;
        salesTeamForCoverageObj.Is_Leaver__c = false;
        salesTeamForCoverageList.add(salesTeamForCoverageObj);

        salesTeamForCoverageObj = new Sales_Team_for_Coverage__c();
        salesTeamForCoverageObj.Coverage_ID__c = '4567XX';
        salesTeamForCoverageObj.Name = 'TestDummy1LN/TestDummy2LN';
        salesTeamForCoverageObj.Sales_Team__c = 'Test Team1';
        salesTeamForCoverageObj.Desk_Code__c = 'EQ-UQ-1D';
        salesTeamForCoverageObj.Sales_Desk_Region__c = 'USA';
        salesTeamForCoverageObj.Sales_Desk_Division__c = 'Equity';
        salesTeamForCoverageObj.Sales_Code_Login_ID__c = 'dummy1';
        salesTeamForCoverageObj.Is_Split_Sales_Code__c = true;
        salesTeamForCoverageObj.Active__c = true;
        salesTeamForCoverageObj.is_Dummy__c = false;
        salesTeamForCoverageObj.Is_Leaver__c = false;
        salesTeamForCoverageList.add(salesTeamForCoverageObj);

        salesTeamForCoverageObj = new Sales_Team_for_Coverage__c();
        salesTeamForCoverageObj.Coverage_ID__c = '8901XX';
        salesTeamForCoverageObj.Name = 'TestDummy1LN/TestDummy2LN';
        salesTeamForCoverageObj.Sales_Team__c = 'Test Team2';
        salesTeamForCoverageObj.Desk_Code__c = 'EQ-FR-1D';
        salesTeamForCoverageObj.Sales_Desk_Region__c = 'USA';
        salesTeamForCoverageObj.Sales_Desk_Division__c = 'Equity';
        salesTeamForCoverageObj.Sales_Code_Login_ID__c = 'dummy2';
        salesTeamForCoverageObj.Is_Split_Sales_Code__c = true;
        salesTeamForCoverageObj.Active__c = true;
        salesTeamForCoverageObj.is_Dummy__c = false;
        salesTeamForCoverageObj.Is_Leaver__c = false;
        salesTeamForCoverageList.add(salesTeamForCoverageObj);
        insert salesTeamForCoverageList;

        List<Coverage_Maintenance_Preferences__c> cvgPrefList = new List<Coverage_Maintenance_Preferences__c>();
        Coverage_Maintenance_Preferences__c cvgPrefObj = new Coverage_Maintenance_Preferences__c();
        cvgPrefObj.Sales_Desk_Code__c = 'EQ-UQ-1D';
        cvgPrefObj.Sales_Desk_Region__c = 'USA';
        cvgPrefObj.Sales_Desk_Division__c = 'Equity';
        cvgPrefObj.Sales_Client_Hierarchy_Level__c = 'RM';
        cvgPrefList.add(cvgPrefObj);

        cvgPrefObj = new Coverage_Maintenance_Preferences__c();
        cvgPrefObj.Sales_Desk_Code__c = null;
        cvgPrefObj.Sales_Desk_Region__c = 'Europe';
        cvgPrefObj.Sales_Desk_Division__c = 'Fixed Income';
        cvgPrefObj.Sales_Client_Hierarchy_Level__c = 'RM';
        cvgPrefList.add(cvgPrefObj);

        cvgPrefObj = new Coverage_Maintenance_Preferences__c();
        cvgPrefObj.Sales_Desk_Code__c = null;
        cvgPrefObj.Sales_Desk_Region__c = null;
        cvgPrefObj.Sales_Desk_Division__c = 'Equity';
        cvgPrefObj.Sales_Client_Hierarchy_Level__c = 'RG';
        cvgPrefList.add(cvgPrefObj);
        insert cvgPrefList; //this will run CvgMaintenancePreferencesTriggerHandler, which in turn will run PopulateCvgMaintenanceForSalescodeBatch

        Test.stopTest();

        Coverage_Maintenance_Preferences__c cvgMainObj = [SELECT Id FROM Coverage_Maintenance_Preferences__c WHERE Sales_Desk_Code__c = 'EQ-UQ-1D' AND Sales_Desk_Region__c = 'USA' AND Sales_Desk_Division__c = 'Equity'];
        Sales_Team_for_Coverage__c salesTeamObj = [SELECT Id,Coverage_Maintenance_Level__c FROM Sales_Team_for_Coverage__c WHERE Sales_Code_Login_ID__c = 'dummy1'];
        System.assertEquals(cvgMainObj.Id, salesTeamObj.Coverage_Maintenance_Level__c);
    }
}