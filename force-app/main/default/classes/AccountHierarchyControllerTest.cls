/*
	Author 		: Pravin Kundal
	Company 	: Nomura
	Date 		: 16/01/2020
	Description : Tests for the AccountHierarchyController class.
*/
@isTest
public class AccountHierarchyControllerTest {
    static testMethod void testSearchParentHierarchy() {
        System.debug('#### SchRequestTriggerHandlerTest.testSearchParentHierarchy()');
        
        List<Account>AccList = new List<Account>();
        Account sLevel1 = UtilityTesting.createRSAccount(
                'S Test Account1', 'Test2', '52nd Street', 'California', 'United States', true);
        AccList.add(sLevel1);
        Account sLevel2 = UtilityTesting.createRSAccount(
                'S Test Account2', 'Test2', '52nd Street', 'California', 'United States', true);
        AccList.add(sLevel2);
        insert AccList;
        AccList.clear();
        
        Account rs1rg1 = UtilityTesting.createRGAccount(
                'G Test Account1', sLevel1.Id, 'Test11', '52nd Street', 'California', 'United States', true);
        AccList.add(rs1rg1);
        Account rs1rg2 = UtilityTesting.createRGAccount(
                'G Test Account2', sLevel1.Id, 'Test22', '52nd Street', 'California', 'United States', true);
        AccList.add(rs1rg2);
        Account rs1rg3 = UtilityTesting.createRGAccount(
                'G Test Account3', sLevel1.Id, 'Test23', '52nd Street', 'California', 'United States', true);
        AccList.add(rs1rg3);
        Account rs1rg4 = UtilityTesting.createRGAccount(
                'G Test Account4', sLevel1.Id, 'Test24', '52nd Street', 'California', 'United States', true);
        AccList.add(rs1rg4);

        Account rs2rg1 = UtilityTesting.createRGAccount(
                'G Test Account5', sLevel2.Id, 'Test21', '52nd Street', 'California', 'United States', true);
        AccList.add(rs2rg1);
        Account rs2rg2 = UtilityTesting.createRGAccount(
                'G Test Account6', sLevel2.Id, 'Test32', '52nd Street', 'California', 'United States', true);
        AccList.add(rs2rg2);
        Account rs2rg3 = UtilityTesting.createRGAccount(
                'G Test Account7', sLevel2.Id, 'Test43', '52nd Street', 'California', 'United States', true);
        AccList.add(rs2rg3);
        Account rs2rg4 = UtilityTesting.createRGAccount(
                'G Test Account8', sLevel2.Id, 'Test44', '52nd Street', 'California', 'United States', true);
        AccList.add(rs2rg4);
        insert AccList;
        AccList.clear();
        
        Id [] fixedSearchResultsRGAcc = new Id[8];
        fixedSearchResultsRGAcc[0] = rs1rg1.Id;
        fixedSearchResultsRGAcc[1] = rs1rg2.Id;
        fixedSearchResultsRGAcc[2] = rs1rg3.Id;
        fixedSearchResultsRGAcc[3] = rs1rg1.Id;
        fixedSearchResultsRGAcc[4] = rs2rg1.Id;
        fixedSearchResultsRGAcc[5] = rs2rg2.Id;
        fixedSearchResultsRGAcc[6] = rs2rg3.Id;
        fixedSearchResultsRGAcc[7] = rs2rg1.Id;
        Test.setFixedSearchResults(fixedSearchResultsRGAcc);
        List<Account> RgAccRsltList = AccountHierarchyController.searchParentHierarchy('Test', null, 'Test', null, null, false);
        System.debug('RgAccRsltList : '+RgAccRsltList);
        Id [] fixedSearchResultsRSAcc = new Id[2];
        fixedSearchResultsRSAcc[0] = sLevel1.Id;
        fixedSearchResultsRSAcc[1] = sLevel2.Id;
        Test.setFixedSearchResults(fixedSearchResultsRSAcc);
        List<Account> RsAccRsltList = AccountHierarchyController.searchParentHierarchy(null, null,
            'Test', null, null, false);
        System.debug('RsAccRsltList : '+RsAccRsltList);
    }
}