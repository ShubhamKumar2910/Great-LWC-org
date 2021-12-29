public class RevenueRankTestingUtility {
    public static Map<Account, List<Account>> getRgToRmMap (Integer numberOfRgAccounts, Integer numberOfRmsPerRg) {
    	System.debug(' in getRgToRmMap. numberOfRgAccounts='+numberOfRgAccounts+', numberOfRmsPerRg='+numberOfRmsPerRg);
    	List<Account> accounts = UtilityTesting.CreateAccounts(numberOfRgAccounts + ( numberOfRgAccounts* numberOfRmsPerRg));
    	Map<Account, List<Account>> rgToRmMap = new Map<Account, List<Account>>();
    	for (Integer x=0; x<numberOfRgAccounts; x++) {
    		Account rg = accounts[x];
    		rgToRmMap.put(rg, new List<Account>());
    	}
    	Integer x = numberOfRgAccounts;
    	for (Account acct: rgToRmMap.keySet()) {
    		List<Account> rmAccounts = rgToRmMap.get(acct);
    		for (integer y=0; y<numberOfRmsPerRg; y++) {
    			rmAccounts.add(accounts[x++]);
    		}
    	}
    	System.debug('Returning from getRgToRmMap.  Map size='+ rgToRmMap.size());
    	return rgToRmMap;
    }

    public static List<Revenue_Rollup__c> createRollups(Map<Account, List<Account>> rgToRmMap, Integer numberOfProducts) {
    	System.debug('In createRollups.  Rgsize='+rgToRmMap.size() +', numberOfProducts= '+ numberOfProducts);
    	List<Revenue_Rollup__c> rollUps = new List<Revenue_Rollup__c>();
    	List<String> regions = new List<String>();
    	regions.add('US');
    	regions.add('EMEA');
    	regions.add('AEJ');
    	regions.add('JAPAN');
    	
    	for (Account acct: rgToRmMap.keySet() ) {
    		List<Account> rmAccounts = rgToRmMap.get(acct);
    		for (Account rm: rmAccounts) {
    			for (Integer x=0; x<numberOfProducts; x++) {
    				rollUps.addAll(createRevenueRollUpByRegion(acct, rm, 'Product-'+x, regions));
    			}
    		}
    	}
    	System.debug('Returning from createRollups.  list size='+ rollUps.size());
    	return rollUps;
    }
    
    public static List<Revenue_Rollup__c> createRevenueRollUpByRegion(Account rg, Account rm, String product, List<String> regions) {
    	List<Revenue_Rollup__c> rollUps = new List<Revenue_Rollup__c>();
    	for (String region: regions) {
	    	Revenue_Rollup__c rollUp = new Revenue_Rollup__c();
	    	rollUp.Division__c='Equities Division';
	    	rollUp.RG__c = rg.Id;
	    	rollUp.RM__c = rm.Id;
	    	rollUp.Product_2_5__c = product;
	    	rollUp.GRR_Region__c = region;
	    	rollUp.FYTD_Net_USD__c = UtilityTesting.getRandomDouble(100,100000);
	    	rollUp.PFY_Net_USD__c = UtilityTesting.getRandomDouble(100,100000);
	    	rollUp.CYTD_Net_USD__c = UtilityTesting.getRandomDouble(100,100000);
	    	rollUp.PCY_Net_USD__c = UtilityTesting.getRandomDouble(100,100000);
	    	rollups.add(rollUp);
    	}
    	return rollUps;
    }
    
	public static Account_Revenue_Rank__c getNewRank() {
		Account_Revenue_Rank__c rr = new Account_Revenue_Rank__c();
		RevenueRankUtility.resetAccountRevenueRank(rr);
    	return rr;
	}
    
    public static void populateRevenueRankWithRollup(Revenue_Rollup__c ru, Account_Revenue_Rank__c rank) {
		if (ru.GRR_Region__c.equalsIgnoreCase('US')) {
			rank.Current_CY_US_Net_Revenue__c += ru.CYTD_Net_USD__c;
			rank.Current_FY_US_Net_Revenue__c += ru.FYTD_Net_USD__c;
			rank.Previous_CY_US_Net_Revenue__c += ru.PCY_Net_USD__c;
			rank.Previous_FY_US_Net_Revenue__c += ru.PFY_Net_USD__c;
		} else if (ru.GRR_Region__c.equalsIgnoreCase('EMEA')) {
			rank.Current_CY_Europe_Net_Revenue__c += ru.CYTD_Net_USD__c;
			rank.Current_FY_Europe_Net_Revenue__c += ru.FYTD_Net_USD__c;
			rank.Previous_CY_Europe_Net_Revenue__c += ru.PCY_Net_USD__c;
			rank.Previous_FY_Europe_Net_Revenue__c += ru.PFY_Net_USD__c;
		} else if (ru.GRR_Region__c.equalsIgnoreCase('AEJ')) {
			rank.Current_CY_AsiaEx_Net_Revenue__c += ru.CYTD_Net_USD__c;
			rank.Current_FY_AsiaEx_Net_Revenue__c += ru.FYTD_Net_USD__c;
			rank.Previous_CY_AsiaEx_Net_Revenue__c += ru.PCY_Net_USD__c;
			rank.Previous_FY_AsiaEx_Net_Revenue__c += ru.PFY_Net_USD__c;
		} else if (ru.GRR_Region__c.equalsIgnoreCase('JAPAN')) {
			rank.Current_CY_Japan_Net_Revenue__c += ru.CYTD_Net_USD__c;
			rank.Current_FY_Japan_Net_Revenue__c += ru.FYTD_Net_USD__c;
			rank.Previous_CY_Japan_Net_Revenue__c += ru.PCY_Net_USD__c;
			rank.Previous_FY_Japan_Net_Revenue__c += ru.PFY_Net_USD__c;
		}
		rank.Current_CY_Global_Net_Revenue__c += ru.CYTD_Net_USD__c;
		rank.Current_FY_Global_Net_Revenue__c += ru.FYTD_Net_USD__c;
		rank.Previous_CY_Global_Net_Revenue__c += ru.PCY_Net_USD__c;
		rank.Previous_FY_Global_Net_Revenue__c += ru.PFY_Net_USD__c;
    }

}