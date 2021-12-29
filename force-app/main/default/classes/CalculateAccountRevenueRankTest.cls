@isTest
private class CalculateAccountRevenueRankTest {
    @isTest public static void populateAccountRevenueRanksNoExistingRanksTest() {
        //Create account
        Map<Account, List<Account>> rgToRmMap = RevenueRankTestingUtility.getRgToRmMap(20, 1);
        //Create Revenue by product
     	List<Revenue_Rollup__c> rollUps = RevenueRankTestingUtility.createRollups(rgToRmMap, 1);
        System.debug('Test rollup size = ' + rollUps.size());
     	insert rollUps;
     	Set<Id> ids = new Set<Id>();
        Set<String> products = new Set<String>();
        //products.add(RevenueRankUtility.TOTAL_PRODUCT_NAME);
        Integer currentVersion = RevenueRankUtility.getCurrentAccountRevenueRankVersion();
		currentVersion += 1;
        
     	for (Revenue_Rollup__c ru: rollUps) {
     		ids.add(ru.RG__c);
            products.add(ru.Product_2_5__c);
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
                expectedValue.Account__c = ru.RG__c;
    			expectedValue.Account_Product_Key__c = key;
                expectedValue.Product__c = ru.Product_2_5__c;
                expectedValue.Version__c = currentVersion;
    			expectedValueMap.put(key,expectedValue);
    		}				    			
    		RevenueRankTestingUtility.populateRevenueRankWithRollup(ru, expectedValue);		    		
	   	}
        //save these 
        System.debug('Saving revenue ranks populated with revenue.  Number of objects to insert = ' + expectedValueMap.values().size());
        Database.SaveResult[] saveResults =  Database.insert(expectedValueMap.values(),true);
        for (Database.SaveResult sr: saveResults) {
            System.assert(sr.isSuccess());
        }
        
        //run
        Map<String, List<RevenueRankQueryObject>> queryProductMap = new Map<String, List<RevenueRankQueryObject>>();
        List<RevenueRankQueryObject> queryList;
        for (String product: products) {
            queryList = new List<RevenueRankQueryObject>();
            queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.AMERICA_FY, currentVersion));
            queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.AMERICA_PFY, currentVersion));
            queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.EUROPE_FY, currentVersion));
            queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.EUROPE_PFY, currentVersion));
            queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.ASIA_FY, currentVersion));
            queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.ASIA_PFY, currentVersion));
            queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.JAPAN_FY, currentVersion));
            queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.JAPAN_PFY, currentVersion));
            queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.GLOBAL_FY, currentVersion));
            queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.GLOBAL_PFY, currentVersion));
            queryProductMap.put(product+'|FY', queryList);
            queryList = new List<RevenueRankQueryObject>();
            queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.AMERICA_CY, currentVersion));
            queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.AMERICA_PCY, currentVersion));
            queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.EUROPE_CY, currentVersion));
            queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.EUROPE_PCY, currentVersion));
            queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.ASIA_CY, currentVersion));
            queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.ASIA_PCY, currentVersion));
            queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.JAPAN_CY, currentVersion));
            queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.JAPAN_PCY, currentVersion));
            queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.GLOBAL_CY, currentVersion));
            queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.GLOBAL_PCY, currentVersion));
            queryProductMap.put(product+'|CY', queryList);
        }
        System.debug('Starting test');
    	Test.startTest();
    	CalculateAccountRevenueRank testClass = new CalculateAccountRevenueRank(queryProductMap, currentVersion);
    	Database.executeBatch(testClass);
    	Test.stopTest(); //need to stop here in order to test the assertions
        Map<Id, Account_Revenue_Rank__c> rankMap = new Map<Id, Account_Revenue_Rank__c>();
    	List<Account_Revenue_Rank__c> testRanks = [SELECT Id,Product__c, Current_FY_AsiaEx_Rank__c,Current_FY_Europe_Rank__c, Current_FY_Japan_Rank__c, Current_FY_US_Rank__c, Current_FY_Global_Rank__c,  
    		Current_CY_AsiaEx_Rank__c,Current_CY_Europe_Rank__c, Current_CY_Japan_Rank__c, Current_CY_US_Rank__c, Current_CY_Global_Rank__c,  
    		Previous_FY_AsiaEx_Rank__c,Previous_FY_Europe_Rank__c, Previous_FY_Japan_Rank__c, Previous_FY_US_Rank__c, Previous_FY_Global_Rank__c,  
    		Previous_CY_AsiaEx_Rank__c,Previous_CY_Europe_Rank__c, Previous_CY_Japan_Rank__c, Previous_CY_US_Rank__c, Previous_CY_Global_Rank__c
    		FROM Account_Revenue_Rank__c];
        for (Account_Revenue_Rank__c rank: testRanks) {
            rankMap.put(rank.Id, rank);
        }
        List<String> productList = new List<String>(products);
        String product = productList[0];
        List<RevenueRankQueryObject> queries = new List<RevenueRankQueryObject>();
        for (Integer x=0; x<RevenueRankUtility.FIELDS.values().size(); x++) {
            Integer sortCount = 1;
        	Double priorRevenue = null;
        	Double currentRevenue = null;
            RevenueRankQueryObject query = new RevenueRankQueryObject(product,RevenueRankUtility.FIELDS.values()[x],currentVersion);
            for (List<Account_Revenue_Rank__c> ranks : Database.query(query.getRevenueQuery())) {
                for (Account_Revenue_Rank__c rank: ranks) {
                    if (null != priorRevenue) {
                        currentRevenue= RevenueRankUtility.getRevenue(rank, query.getQueryField());
                        if (currentRevenue!=priorRevenue) {
                            ++sortCount;
                        }
                        System.assertEquals(sortCount, getRank(rankMap.get(rank.Id), RevenueRankUtility.FIELDS.values()[x]));
                    }
                }
            }
        }
    }

    private static Decimal getRank(Account_Revenue_Rank__c rank, RevenueRankUtility.FIELDS sortField) {
        Decimal revenueRank;
        if (sortField == RevenueRankUtility.FIELDS.AMERICA_FY) {
            revenueRank = rank.Current_FY_US_Rank__c;
        } else if (sortField == RevenueRankUtility.FIELDS.AMERICA_PFY) {
            revenueRank = rank.Previous_FY_US_Rank__c;
        } else if (sortField == RevenueRankUtility.FIELDS.AMERICA_CY) {
            revenueRank = rank.Current_CY_US_Rank__c;
        } else if (sortField == RevenueRankUtility.FIELDS.AMERICA_PCY) {
            revenueRank = rank.Previous_CY_US_Rank__c;
        } else if (sortField == RevenueRankUtility.FIELDS.EUROPE_FY) {
            revenueRank = rank.Current_FY_Europe_Rank__c;
        } else if (sortField == RevenueRankUtility.FIELDS.EUROPE_PFY) {
            revenueRank = rank.Previous_FY_Europe_Rank__c;
        } else if (sortField == RevenueRankUtility.FIELDS.EUROPE_CY) {
            revenueRank = rank.Current_CY_Europe_Rank__c;
        } else if (sortField == RevenueRankUtility.FIELDS.EUROPE_PCY) {
            revenueRank = rank.Previous_CY_Europe_Rank__c;
        } else if (sortField == RevenueRankUtility.FIELDS.ASIA_FY) {
            revenueRank = rank.Current_FY_AsiaEx_Rank__c;
        } else if (sortField == RevenueRankUtility.FIELDS.ASIA_PFY) {
            revenueRank = rank.Previous_FY_AsiaEx_Rank__c;
        } else if (sortField == RevenueRankUtility.FIELDS.ASIA_CY) {
            revenueRank = rank.Current_CY_AsiaEx_Rank__c;
        } else if (sortField == RevenueRankUtility.FIELDS.ASIA_PCY) {
            revenueRank = rank.Previous_CY_AsiaEx_Rank__c;
        }  else if (sortField == RevenueRankUtility.FIELDS.JAPAN_FY) {
            revenueRank = rank.Current_FY_Japan_Rank__c;
        } else if (sortField == RevenueRankUtility.FIELDS.JAPAN_PFY) {
            revenueRank = rank.Previous_FY_Japan_Rank__c;
        } else if (sortField == RevenueRankUtility.FIELDS.JAPAN_CY) {
            revenueRank = rank.Current_CY_Japan_Rank__c;
        } else if (sortField == RevenueRankUtility.FIELDS.JAPAN_PCY) {
            revenueRank = rank.Previous_CY_Japan_Rank__c;
        } else if (sortField == RevenueRankUtility.FIELDS.GLOBAL_FY) {
            revenueRank = rank.Current_FY_Global_Rank__c;
        } else if (sortField == RevenueRankUtility.FIELDS.GLOBAL_PFY) {
            revenueRank = rank.Previous_FY_Global_Rank__c;
        } else if (sortField == RevenueRankUtility.FIELDS.GLOBAL_CY) {
            revenueRank = rank.Current_CY_Global_Rank__c;
        } else {
            revenueRank = rank.Previous_CY_Global_Rank__c;
        }
        return revenueRank;
    }
	

}