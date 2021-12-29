@isTest
public class LookupControllerLWCTest {

    @testSetup
    static void testDataSetup(){
        Id RSRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('RS_Account').getRecordTypeId();
        Id RGRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('RG_Account').getRecordTypeId();
        Id RMRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('RM_Account').getRecordTypeId();

        //RG Account
        Account newRGAccount1 = new Account();
        newRGAccount1.Name = 'RG Account 1';
        newRGAccount1.RDM_Org_ID__c = 'RG12345';
        newRGAccount1.RecordTypeId = RGRecordType;
        newRGAccount1.BillingCity = 'Mumbai';
        newRGAccount1.BillingStreet = 'ABC Street';
        newRGAccount1.Domicile_Country__c = 'US';
        newRGAccount1.Active__c = true;
        insert newRGAccount1;

        List<Sales_Team_for_Coverage__c> salesTeamForCoverageList = new List<Sales_Team_for_Coverage__c>();
        Sales_Team_for_Coverage__c salesTeamForCoverageObj = new Sales_Team_for_Coverage__c();
        salesTeamForCoverageObj.Coverage_ID__c = '1234XX';
        salesTeamForCoverageObj.Name = 'TestDummyJohn';
        salesTeamForCoverageObj.Sales_Team__c = 'Test Team1';
        salesTeamForCoverageObj.Desk_Code__c = 'EQ-FR-1D';
        salesTeamForCoverageObj.Sales_Desk_Region__c = 'USA';
        salesTeamForCoverageObj.Sales_Desk_Division__c = 'Equity';
        salesTeamForCoverageObj.Sales_Code_Login_ID__c = 'dummy';
        salesTeamForCoverageObj.Is_Split_Sales_Code__c = false;
        salesTeamForCoverageObj.Active__c = true;
        salesTeamForCoverageObj.is_Dummy__c = false;
        salesTeamForCoverageObj.Is_Leaver__c = false;
        salesTeamForCoverageObj.Sales_Team_Code__c = '555';
        salesTeamForCoverageList.add(salesTeamForCoverageObj);

        salesTeamForCoverageObj = new Sales_Team_for_Coverage__c();
        salesTeamForCoverageObj.Coverage_ID__c = '1234XX';
        salesTeamForCoverageObj.Name = 'TestDummyAbby';
        salesTeamForCoverageObj.Sales_Team__c = 'Test Team2';
        salesTeamForCoverageObj.Desk_Code__c = 'EQ-FR-1D';
        salesTeamForCoverageObj.Sales_Desk_Region__c = 'USA';
        salesTeamForCoverageObj.Sales_Desk_Division__c = 'Equity';
        salesTeamForCoverageObj.Sales_Code_Login_ID__c = 'dummy';
        salesTeamForCoverageObj.Is_Split_Sales_Code__c = false;
        salesTeamForCoverageObj.Active__c = false;
        salesTeamForCoverageObj.is_Dummy__c = true;
        salesTeamForCoverageObj.Is_Leaver__c = true;
        salesTeamForCoverageObj.Sales_Team_Code__c = '500';
        salesTeamForCoverageList.add(salesTeamForCoverageObj);
        insert salesTeamForCoverageList;
    }

    static testMethod void searchAccountForGivenType(){
        Test.startTest();
        Account account = [SELECT Id FROM Account WHERE RDM_Org_ID__c = 'RG12345'];
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = account.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        List<String> accountType = new List<String>();
        accountType.add('rg');
        List<LookupSearchResult> resultList = LookupControllerLWC.searchAccountForGivenType('RG Account', accountType, false, null, null);
        System.assertEquals(1, resultList.size());
        Test.stopTest();
    }

    static testMethod void searchSalesperson(){
        Test.startTest();
        List<Sales_Team_for_Coverage__c> salesTeamCoverage = [SELECT Id FROM Sales_Team_for_Coverage__c WHERE Sales_Code_Login_ID__c = 'dummy'];
        List<Id> fixedSearchResults= new List<Id>();
        for(Sales_Team_for_Coverage__c salesTeam: salesTeamCoverage){
            fixedSearchResults.add(salesTeam.Id);
        }
        Test.setFixedSearchResults(fixedSearchResults);
        List<LookupSearchResult> resultList1 = LookupControllerLWC.searchSalesperson('TestDummyJohn', false, false, true, false, '');
        System.assertEquals(1, resultList1.size());

        List<LookupSearchResult> resultList2 = LookupControllerLWC.searchSalesperson('TestDummyAbby', true, true, true, false, '');
        System.assertEquals(2, resultList2.size());
        Test.stopTest();
    }
}