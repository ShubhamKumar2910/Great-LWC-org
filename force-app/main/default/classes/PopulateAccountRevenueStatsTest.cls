@isTest
private class PopulateAccountRevenueStatsTest {
    @isTest public static void populateAccountRevenueRanksNoExistingRanksTest() {
        //Create account
        Map<Account, List<Account>> rgToRmMap = RevenueRankTestingUtility.getRgToRmMap(1, 5);
        //Create Revenue by product
     	List<Revenue_Rollup__c> rollUps = RevenueRankTestingUtility.createRollups(rgToRmMap, 9);
     	insert rollUps;
     	Set<Id> ids = new Set<Id>();
     	for (Revenue_Rollup__c ru: rollUps) {
     		ids.add(ru.RG__c);
     	}
     	List<Revenue_Rollup__c> rolls = [select RG__c, GRR_Region__c, Product_2_5__c, FYTD_Net_USD__c, PFY_Net_USD__c, CYTD_Net_USD__c, PCY_Net_USD__c  
    		from Revenue_Rollup__c Where (FYTD_Net_USD__c<>0 and PFY_Net_USD__c<>0 and CYTD_Net_USD__c<>0 and PCY_Net_USD__c<>0) 
    		ORDER BY RG__c];
		Map<String, Account_Revenue_Rank__c> expectedValueMap = new Map<String, Account_Revenue_Rank__c>();
    	for (Revenue_Rollup__c ru: rolls) {
    		String key = RevenueRankUtility.getAccountProductKey(ru.RG__c, ru.Product_2_5__c);
    		Account_Revenue_Rank__c expectedValue = expectedValueMap.get(key);
    		if (null == expectedValue) {
    			expectedValue = RevenueRankTestingUtility.getNewRank();
    			expectedValue.Account_Product_Key__c = key;
    			expectedValueMap.put(key,expectedValue);
    		}				    			
			key = RevenueRankUtility.getAccountProductKey(ru.RG__c, 'Total');
    		Account_Revenue_Rank__c totalValue = expectedValueMap.get(key);
    		if (null == totalValue) {
    			totalValue = RevenueRankTestingUtility.getNewRank();
    			totalValue.Account_Product_Key__c = key;
    			expectedValueMap.put(key,totalValue);
    		}		
    		RevenueRankTestingUtility.populateRevenueRankWithRollup(ru, expectedValue);		    		
    		RevenueRankTestingUtility.populateRevenueRankWithRollup(ru, totalValue);
	   	}
        //run
    	Test.startTest();
    	PopulateAccountRevenueStats testClass = new PopulateAccountRevenueStats();
    	Database.executeBatch(testClass,200);
    	Test.stopTest(); //need to stop here in order to test the assertions
    	for (List<Account_Revenue_Rank__c> testRanks: [SELECT Current_FY_AsiaEx_Net_Revenue__c,Current_FY_Europe_Net_Revenue__c, Current_FY_Japan_Net_Revenue__c, Current_FY_US_Net_Revenue__c, Current_FY_Global_Net_Revenue__c,  
    		Current_FY_AsiaEx_Rank__c,Current_FY_Europe_Rank__c, Current_FY_Japan_Rank__c, Current_FY_US_Rank__c, Current_FY_Global_Rank__c,  
    		Current_CY_AsiaEx_Net_Revenue__c,Current_CY_Europe_Net_Revenue__c, Current_CY_Japan_Net_Revenue__c, Current_CY_US_Net_Revenue__c, Current_CY_Global_Net_Revenue__c,  
    		Current_CY_AsiaEx_Rank__c,Current_CY_Europe_Rank__c, Current_CY_Japan_Rank__c, Current_CY_US_Rank__c, Current_CY_Global_Rank__c,  
    		Previous_FY_AsiaEx_Net_Revenue__c,Previous_FY_Europe_Net_Revenue__c, Previous_FY_Japan_Net_Revenue__c, Previous_FY_US_Net_Revenue__c, Previous_FY_Global_Net_Revenue__c, 
    		Previous_FY_AsiaEx_Rank__c,Previous_FY_Europe_Rank__c, Previous_FY_Japan_Rank__c, Previous_FY_US_Rank__c, Previous_FY_Global_Rank__c,  
    		Previous_CY_AsiaEx_Net_Revenue__c,Previous_CY_Europe_Net_Revenue__c, Previous_CY_Japan_Net_Revenue__c, Previous_CY_US_Net_Revenue__c, Previous_CY_Global_Net_Revenue__c,  
    		Previous_CY_AsiaEx_Rank__c,Previous_CY_Europe_Rank__c, Previous_CY_Japan_Rank__c, Previous_CY_US_Rank__c, Previous_CY_Global_Rank__c,
    		Account_Product_Key__c 
    		FROM Account_Revenue_Rank__c where Account__c in :ids]) {
			for (Account_Revenue_Rank__c testRank: testRanks) {
				Account_Revenue_Rank__c expectedValue = expectedValueMap.get(testRank.Account_Product_Key__c);
				testRevenueRanks(testRank, expectedValue);
			}
		}
    }
    
    private static void testRevenueRanks(Account_Revenue_Rank__c actual, Account_Revenue_Rank__c expected) {
		System.assert(actual.Current_CY_US_Net_Revenue__c == expected.Current_CY_US_Net_Revenue__c);
		System.assert(actual.Current_FY_US_Net_Revenue__c == expected.Current_FY_US_Net_Revenue__c);
		System.assert(actual.Previous_CY_US_Net_Revenue__c == expected.Previous_CY_US_Net_Revenue__c);
		System.assert(actual.Previous_FY_US_Net_Revenue__c == expected.Previous_FY_US_Net_Revenue__c);
		System.assert(actual.Current_CY_Europe_Net_Revenue__c == expected.Current_CY_Europe_Net_Revenue__c);
		System.assert(actual.Current_FY_Europe_Net_Revenue__c == expected.Current_FY_Europe_Net_Revenue__c);
		System.assert(actual.Previous_CY_Europe_Net_Revenue__c == expected.Previous_CY_Europe_Net_Revenue__c);
		System.assert(actual.Previous_FY_Europe_Net_Revenue__c == expected.Previous_FY_Europe_Net_Revenue__c);
		System.assert(actual.Current_CY_AsiaEx_Net_Revenue__c == expected.Current_CY_AsiaEx_Net_Revenue__c);
		System.assert(actual.Current_FY_AsiaEx_Net_Revenue__c == expected.Current_FY_AsiaEx_Net_Revenue__c);
		System.assert(actual.Previous_CY_AsiaEx_Net_Revenue__c == expected.Previous_CY_AsiaEx_Net_Revenue__c);
		System.assert(actual.Previous_FY_AsiaEx_Net_Revenue__c == expected.Previous_FY_AsiaEx_Net_Revenue__c);
		System.assert(actual.Current_CY_Japan_Net_Revenue__c == expected.Current_CY_Japan_Net_Revenue__c);
		System.assert(actual.Current_FY_Japan_Net_Revenue__c == expected.Current_FY_Japan_Net_Revenue__c);
		System.assert(actual.Previous_CY_Japan_Net_Revenue__c == expected.Previous_CY_Japan_Net_Revenue__c);
		System.assert(actual.Previous_FY_Japan_Net_Revenue__c == expected.Previous_FY_Japan_Net_Revenue__c);
		System.assert(actual.Current_CY_Global_Net_Revenue__c == expected.Current_CY_Global_Net_Revenue__c);
		System.assert(actual.Current_FY_Global_Net_Revenue__c == expected.Current_FY_Global_Net_Revenue__c);
		System.assert(actual.Previous_CY_Global_Net_Revenue__c == expected.Previous_CY_Global_Net_Revenue__c);
		System.assert(actual.Previous_FY_Global_Net_Revenue__c == expected.Previous_FY_Global_Net_Revenue__c);
    }
}