@IsTest
private class CoverageViewQueryWithoutSharingTest
{
    @IsTest
    static void testGetYTDRevenueRGJP()
    {
        Set<String> coverageIds = new Set<String>{'Test_Id999'};
        Set<String> accountIds = new Set<String>{[SELECT Id FROM Account WHERE Name LIKE 'Test RG revenue account'].Id};
        String userRegion = 'japan';
        String clientLevel = 'rg';

        CoverageViewQueryWithoutSharing cvqws = new CoverageViewQueryWithoutSharing();
        Test.startTest();
        Map<String,String> mapYTDRevenueByRG = cvqws.getYTDRevenue(coverageIds,accountIds,userRegion,clientLevel);
        Test.stopTest();
        System.assert(mapYTDRevenueByRG != null && !mapYTDRevenueByRG.isEmpty(),'mapYTDRevenueByRG map of revenue figures cannot be null or empty');
    }

    @IsTest
    static void testGetYTDRevenueRGNonJP()
    {
        Set<String> coverageIds = new Set<String>{'Test_Id999'};
        Set<String> accountIds = new Set<String>{[SELECT Id FROM Account WHERE Name LIKE 'Test RG revenue account'].Id};
        String userRegion = 'europe';
        String clientLevel = 'rg';

        CoverageViewQueryWithoutSharing cvqws = new CoverageViewQueryWithoutSharing();
        Test.startTest();
        Map<String,String> mapYTDRevenueByRG = cvqws.getYTDRevenue(coverageIds,accountIds,userRegion,clientLevel);
        Test.stopTest();
        System.assert(mapYTDRevenueByRG != null && !mapYTDRevenueByRG.isEmpty(),'mapYTDRevenueByRG map of revenue figures cannot be null or empty');
    }

    @IsTest
    static void testGetYTDRevenueRMJP()
    {
        Set<String> coverageIds = new Set<String>{'Test_Id999'};
        Set<String> accountIds = new Set<String>{[SELECT Id FROM Account WHERE Name LIKE 'Test RM revenue account'].Id};
        String userRegion = 'japan';
        String clientLevel = 'rm';

        CoverageViewQueryWithoutSharing cvqws = new CoverageViewQueryWithoutSharing();
        Test.startTest();
        Map<String,String> mapYTDRevenueByRG = cvqws.getYTDRevenue(coverageIds,accountIds,userRegion,clientLevel);
        Test.stopTest();
        System.assert(mapYTDRevenueByRG != null && !mapYTDRevenueByRG.isEmpty(),'mapYTDRevenueByRG map of revenue figures cannot be null or empty');
    }

    @IsTest
    static void testGetYTDRevenueRMNonJP()
    {
        Set<String> coverageIds = new Set<String>{'Test_Id999'};
        Set<String> accountIds = new Set<String>{[SELECT Id FROM Account WHERE Name LIKE 'Test RM revenue account'].Id};
        String userRegion = 'europe';
        String clientLevel = 'rm';

        CoverageViewQueryWithoutSharing cvqws = new CoverageViewQueryWithoutSharing();
        Test.startTest();
        Map<String,String> mapYTDRevenueByRG = cvqws.getYTDRevenue(coverageIds,accountIds,userRegion,clientLevel);
        Test.stopTest();
        System.assert(mapYTDRevenueByRG != null && !mapYTDRevenueByRG.isEmpty(),'mapYTDRevenueByRG map of revenue figures cannot be null or empty');
    }

    @IsTest
    static void testDBQueryMethods()
    {
        CoverageViewQueryWithoutSharing cvqws = new CoverageViewQueryWithoutSharing();
        cvqws.getDBData('SELECT Id FROM ACCOUNT LIMIT 0',null,null,null,null,null,null,null);

        List<Sales_Team_for_Coverage__c> lstSTFC = CoverageViewQueryWithoutSharing.getSalesTeamUsersForLoginIds(new List<String>{});
        System.assert(lstSTFC != null, 'List of Sales_Team_for_Coverage__c cannot be null when querying this object');
    }

    @TestSetup
    private static void setupTestData()
    {
        Account rgAccount = UtilityTesting.createRGAccount('Test RG revenue account',null,'RG000000','Test billing street', 'London', 'United Kingdom',true);
        insert rgAccount;

        Account rmAccount = UtilityTesting.createRMAccount('Test RM revenue Account',rgAccount.Id,'RM000001','Test RM billing str', 'London', 'United Kingdom',true);
        insert rmAccount;

        List<Revenue__c> lstRevenues = new List<Revenue__c>();
        for (integer i=0; i<20; i++)
        {
            Revenue__c revenue = new Revenue__c();
            revenue.RG__c = rgAccount.id;
            revenue.RM__c = rmAccount.id;
            revenue.Sales_Id__c = 'Test_Id999';
            revenue.RG_Id__c = rgAccount.RDM_Org_ID__c;
            revenue.RM_Id__c = rmAccount.RDM_Org_ID__c;
            revenue.fytd_gross_yen__c = i*10;
            revenue.WTD_Gross_Yen__c = i*10;
            revenue.MTD_Gross_Yen__c = i*10;
            revenue.FYTD_Budget_Gross_Yen__c = i*10;
            revenue.fytd_gross_usd__c = i*10;
            revenue.WTD_Gross_USD__c = i*10;
            revenue.MTD_Gross_USD__c = i*10;
            revenue.FYTD_Budget_Gross_USD__c = i*10;

            lstRevenues.add(revenue);
        }

        insert lstRevenues;

    }
}