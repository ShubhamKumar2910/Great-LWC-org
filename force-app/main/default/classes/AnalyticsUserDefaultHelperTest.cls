@isTest
private class AnalyticsUserDefaultHelperTest {
	@isTest 
    public static void testGetDefaultValuesFromUserFromNullValues() {
    	Analytics_User_Default__c testVal = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(null);
        System.assertEquals(AnalyticsUserDefaultHelper.defaultAccounting, testVal.Accounting_Filter__c);
        System.assertEquals(AnalyticsUserDefaultHelper.defaultCurrency, testVal.Currency_Filter__c);
        System.assertEquals(AnalyticsUserDefaultHelper.defaultDashboard, testVal.Default_Revenue_Dashboard__c);
        System.assertEquals(AnalyticsUserDefaultHelper.defaultClientScorecardConfig, testVal.ClientScorecardConfig__c);
    }
    
    @isTest
    public static void testJapanRegion() {
        Analytics_User_Default__c testVal = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(getUser(null, 'Japan', false));
        System.assertEquals(AnalyticsUserDefaultHelper.defaultAccounting, testVal.Accounting_Filter__c);
        System.assertEquals('Yen', testVal.Currency_Filter__c);
        System.assertEquals(AnalyticsUserDefaultHelper.defaultDashboard, testVal.Default_Revenue_Dashboard__c);
        System.assertEquals(AnalyticsUserDefaultHelper.defaultGroupRegionalDB, testVal.Regional_Client_Scorecard_Rev_2_Group__c);
        
        testVal = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(getUser('Japan - EQ Sales - Region Head', 'Japan',false));
        System.assertEquals('Net', testVal.Accounting_Filter__c);
        System.assertEquals('Yen', testVal.Currency_Filter__c);
        System.assertEquals('Covered_Client_Scorecard', testVal.Default_Revenue_Dashboard__c);
        System.assertEquals(AnalyticsUserDefaultHelper.defaultAPACEQSalesClientScorecardConfig, testVal.ClientScorecardConfig__c);
        System.assertEquals('GRR_Region__c', testVal.Regional_Client_Scorecard_Rev_2_Group__c);
    }

    @isTest
    public static void testTopLineSummary() {
        Analytics_User_Default__c testVal = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(getUser(null, 'Japan',true));
        System.assertEquals(AnalyticsUserDefaultHelper.defaultAccounting, testVal.Accounting_Filter__c);
        System.assertEquals('Yen', testVal.Currency_Filter__c);
        System.assertEquals(AnalyticsUserDefaultHelper.defaultDashboard, testVal.Default_Revenue_Dashboard__c);
        System.assertEquals(AnalyticsUserDefaultHelper.defaultGroupRegionalDB, testVal.Regional_Client_Scorecard_Rev_2_Group__c);
    }

    @isTest
    public static void testAEJRegion() {
        Analytics_User_Default__c testVal = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(getUser(null, 'AEJ',false));
        System.assertEquals(AnalyticsUserDefaultHelper.defaultAccounting, testVal.Accounting_Filter__c);
        System.assertEquals('USD', testVal.Currency_Filter__c);
        System.assertEquals(AnalyticsUserDefaultHelper.defaultDashboard, testVal.Default_Revenue_Dashboard__c);
        System.assertEquals(AnalyticsUserDefaultHelper.defaultGroupRegionalDB, testVal.Regional_Client_Scorecard_Rev_2_Group__c);
        
        testVal = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(getUser('AEJ - EQ - Desk Head - Syndication (AEJ)', 'AEJ',false));
        System.assertEquals('Net', testVal.Accounting_Filter__c);
        System.assertEquals('USD', testVal.Currency_Filter__c);
        System.assertEquals('Covered_Client_Scorecard', testVal.Default_Revenue_Dashboard__c);
        System.assertEquals(AnalyticsUserDefaultHelper.defaultAPACEQSalesClientScorecardConfig, testVal.ClientScorecardConfig__c);
        System.assertEquals('GRR_Region__c', testVal.Regional_Client_Scorecard_Rev_2_Group__c);
        
        testVal = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(getUser('AEJ - EQ - Team Head - AEJ - Ideas Hub - AEJ', 'AEJ',false));
        System.assertEquals('Net', testVal.Accounting_Filter__c);
        System.assertEquals('USD', testVal.Currency_Filter__c);
        System.assertEquals('Covered_Client_Scorecard', testVal.Default_Revenue_Dashboard__c);
        System.assertEquals(AnalyticsUserDefaultHelper.defaultAPACEQSalesClientScorecardConfig, testVal.ClientScorecardConfig__c);
        System.assertEquals('GRR_Region__c', testVal.Regional_Client_Scorecard_Rev_2_Group__c);

        testVal = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(getUser('AEJ - EQ - Team Head - AEJ - Ideas Hub - AEJ', 'AEJ',false));
        System.assertEquals('Net', testVal.Accounting_Filter__c);
        System.assertEquals('USD', testVal.Currency_Filter__c);
        System.assertEquals('Covered_Client_Scorecard', testVal.Default_Revenue_Dashboard__c);
        System.assertEquals(AnalyticsUserDefaultHelper.defaultAPACEQSalesClientScorecardConfig, testVal.ClientScorecardConfig__c);
        System.assertEquals('GRR_Region__c', testVal.Regional_Client_Scorecard_Rev_2_Group__c);
        
        testVal = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(getUser('AEJ - EQ - Sales - AEJ - QUANT PB EXECUTION - AEJ', 'AEJ',false));
        System.assertEquals('Net', testVal.Accounting_Filter__c);
        System.assertEquals('USD', testVal.Currency_Filter__c);
        System.assertEquals('Covered_Client_Scorecard', testVal.Default_Revenue_Dashboard__c);
        System.assertEquals(AnalyticsUserDefaultHelper.defaultAPACEQSalesClientScorecardConfig, testVal.ClientScorecardConfig__c);
        System.assertEquals('GRR_Region__c', testVal.Regional_Client_Scorecard_Rev_2_Group__c);
    }
    
    @IsTest
    public static void testEquitySales() {
        Analytics_User_Default__c testVal = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(getUser('Test - EQ - Sales - Testtst', 'Americas',false));
        System.assertEquals('Net', testVal.Accounting_Filter__c);
        System.assertEquals(AnalyticsUserDefaultHelper.defaultCurrency, testVal.Currency_Filter__c);
        System.assertEquals('Covered_Client_Scorecard', testVal.Default_Revenue_Dashboard__c);
        System.assertEquals(AnalyticsUserDefaultHelper.defaultGroupRegionalDB, testVal.Regional_Client_Scorecard_Rev_2_Group__c);
        System.assertEquals(AnalyticsUserDefaultHelper.defaultClientScorecardConfig, testVal.ClientScorecardConfig__c);
        
        testVal = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(getUser('Test - EQ - Team Head - Testtst', 'Americas',false));
        System.assertEquals('Covered_Client_Scorecard', testVal.Default_Revenue_Dashboard__c);
        
        testVal = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(getUser('Americas - EQ - Sales - US - DERIVS FLOW SALES - US - Test', 'Americas',false));
        System.assertEquals(AnalyticsUserDefaultHelper.defaultAccounting, testVal.Accounting_Filter__c);
        System.assertEquals(AnalyticsUserDefaultHelper.defaultCurrency, testVal.Currency_Filter__c);
        System.assertEquals('Team_Scorecard', testVal.Default_Revenue_Dashboard__c);
        System.assertEquals(AnalyticsUserDefaultHelper.defaultGroupRegionalDB, testVal.Regional_Client_Scorecard_Rev_2_Group__c);

        testVal = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(getUser('Americas - EQ - Team Head - US - DERIVS FLOW SALES - US - Test', 'Americas',false));
        System.assertEquals(AnalyticsUserDefaultHelper.defaultAccounting, testVal.Accounting_Filter__c);
        System.assertEquals(AnalyticsUserDefaultHelper.defaultCurrency, testVal.Currency_Filter__c);
        System.assertEquals('Team_Scorecard', testVal.Default_Revenue_Dashboard__c);
        System.assertEquals(AnalyticsUserDefaultHelper.defaultGroupRegionalDB, testVal.Regional_Client_Scorecard_Rev_2_Group__c);

        testVal = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(getUser('Americas - EQ - Desk Head - Flow Derivatives (USA) - Test', 'Americas',false));
        System.assertEquals(AnalyticsUserDefaultHelper.defaultAccounting, testVal.Accounting_Filter__c);
        System.assertEquals(AnalyticsUserDefaultHelper.defaultCurrency, testVal.Currency_Filter__c);
        System.assertEquals('Team_Scorecard', testVal.Default_Revenue_Dashboard__c);
        System.assertEquals(AnalyticsUserDefaultHelper.defaultGroupRegionalDB, testVal.Regional_Client_Scorecard_Rev_2_Group__c);

		testVal = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(getUser('Japan - EQ - Sales - US - DERIVS FLOW SALES - US - Test', 'Japan',false));
        System.assertEquals('GRR_Region__c', testVal.Regional_Client_Scorecard_Rev_2_Group__c);
        
    }
    
    @IsTest
    public static void testFISales() {
        Analytics_User_Default__c testVal = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(getUser('Test - FI - Sales - Testtst', 'Americas',false));
        System.assertEquals(AnalyticsUserDefaultHelper.defaultAccounting, testVal.Accounting_Filter__c);
        System.assertEquals(AnalyticsUserDefaultHelper.defaultCurrency, testVal.Currency_Filter__c);
        System.assertEquals(AnalyticsUserDefaultHelper.defaultDashboard, testVal.Default_Revenue_Dashboard__c);
        testVal = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(getUser('Test - FI - Team Head - Testtst', 'Americas',false));
        System.assertEquals('Team_Scorecard', testVal.Default_Revenue_Dashboard__c);
        
    }

    @IsTest
    public static void testPopulateErrorList() {
        List<String> errorList = new List<String>();
        //create a aud
        List<Analytics_User_Default__c> defaults = new List<Analytics_User_Default__c>();
        Analytics_User_Default__c testVal = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(getUser('Test - EQ - Sales - Testtst', 'Americas', false));
        defaults.add(testVal);
        defaults.add(testVal);
        
        Map<Integer, String> errorMap = new Map<Integer, String>();
        errorMap.put(1, 'Test error');
        AnalyticsUserDefaultHelper.populateErrorList(errorMap,'TEST', defaults, errorList);
        System.assertEquals(1, errorList.size());
        
    }
    
    @IsTest
    public static void testGetLastRunDate_Null() {
        DateTime d = AnalyticsUserDefaultHelper.getLastRunDate('testConfigName','testParamName');
        System.assert(null == d);
        d = AnalyticsUserDefaultHelper.getLastRunDate(null,null);
        
    }
    @isTest
    public static void testSaveLastRunDate() {
        DateTime dt = DateTime.now();
        AnalyticsUserDefaultHelper.saveLastRunDate(dt, 'testConfigName','testParamName');
        Datetime d = AnalyticsUserDefaultHelper.getLastRunDate('testConfigName','testParamName');
        System.assert(null != d);
        System.assertEquals(dt, d);
        AnalyticsUserDefaultHelper.saveLastRunDate(dt, null, null);
        d = AnalyticsUserDefaultHelper.getLastRunDate(null, null);
        System.assertEquals(dt, d);
        AnalyticsUserDefaultHelper.saveLastRunDate(dt, null, null);
        d = AnalyticsUserDefaultHelper.getLastRunDate(null, null);
        System.assertEquals(dt, d);
    }
    
    private static User getUser(String roleName, String region, Boolean viewResearchStats) {
        User u = new User();
        if (null != roleName) {
            UserRole r = new UserRole();
            r.name = roleName;
            u.UserRole = r;
        }
        u.Region__c = region;
        u.View_Research_Statistics__c = viewResearchStats;
        return u;
    }
}