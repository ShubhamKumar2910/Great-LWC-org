/**
 * Tests execute method of RankRevenueProcess 
 */
@isTest 
private class RankRevenueProcessTest {
    @isTest public static void resetRanksTest() {
        //generate a list of populated revenue rank objects then reset them
        List<Account_Revenue_Rank__c> accountRevenueRanks = getTestRanks(200);
        //now reset to zero
        RankRevenueProcess.resetRanks(accountRevenueRanks);
        for (Account_Revenue_Rank__c r: accountRevenueRanks) {
        	testRevenueRanks(r);
        }
        
    }
    
    @isTest public static void resetRanksBatchTest() {
    	//set up the data
    	List<Account_revenue_rank__c> allRanks = getTestRankList(10,10);
    	Test.startTest();
    	RankRevenueProcess testClass = new RankRevenueProcess();
    	Database.executeBatch(testClass,200);
    	Test.stopTest(); //need to stop here in order to test the assertions
    	System.debug('Running asserts in test mode');
    	Set<id> rankIds = new Set<Id>();
    	for (Account_Revenue_Rank__c r: allRanks) {
    		rankIds.add(r.id);
    	}
    	for (List<Account_Revenue_Rank__c> testRanks: [SELECT Current_FY_AsiaEx_Net_Revenue__c,Current_FY_Europe_Net_Revenue__c, Current_FY_Japan_Net_Revenue__c, Current_FY_US_Net_Revenue__c, Current_FY_Global_Net_Revenue__c,  
    		Current_FY_AsiaEx_Rank__c,Current_FY_Europe_Rank__c, Current_FY_Japan_Rank__c, Current_FY_US_Rank__c, Current_FY_Global_Rank__c,  
    		Current_CY_AsiaEx_Net_Revenue__c,Current_CY_Europe_Net_Revenue__c, Current_CY_Japan_Net_Revenue__c, Current_CY_US_Net_Revenue__c, Current_CY_Global_Net_Revenue__c,  
    		Current_CY_AsiaEx_Rank__c,Current_CY_Europe_Rank__c, Current_CY_Japan_Rank__c, Current_CY_US_Rank__c, Current_CY_Global_Rank__c,  
    		Previous_FY_AsiaEx_Net_Revenue__c,Previous_FY_Europe_Net_Revenue__c, Previous_FY_Japan_Net_Revenue__c, Previous_FY_US_Net_Revenue__c, Previous_FY_Global_Net_Revenue__c, 
    		Previous_FY_AsiaEx_Rank__c,Previous_FY_Europe_Rank__c, Previous_FY_Japan_Rank__c, Previous_FY_US_Rank__c, Previous_FY_Global_Rank__c,  
    		Previous_CY_AsiaEx_Net_Revenue__c,Previous_CY_Europe_Net_Revenue__c, Previous_CY_Japan_Net_Revenue__c, Previous_CY_US_Net_Revenue__c, Previous_CY_Global_Net_Revenue__c,  
    		Previous_CY_AsiaEx_Rank__c,Previous_CY_Europe_Rank__c, Previous_CY_Japan_Rank__c, Previous_CY_US_Rank__c, Previous_CY_Global_Rank__c 
    		FROM Account_Revenue_Rank__c where Id in :rankIds]) {
			for (Account_Revenue_Rank__c testRank: testRanks) {
				testRevenueRanks(testRank);
			}
		}
		System.debug('Finished running asserts in test mode');
    	
    }

    @isTest public static void resetRanksBatchWithErrorTest() {
    	//set up the data
    	List<Account_revenue_rank__c> allRanks = getTestRankList(10,10);
    	//now remove a random element and set its key to null
    	Account_Revenue_Rank__c rank = allRanks[13];
    	rank.Account_Product_Key__c = allRanks[14].Account_Product_Key__c;  //key must be unique, so this should fail on update
    	Id rankNotChanged = rank.Id;
    	
		System.debug('Running test with bad data');
    	Test.startTest();
    	RankRevenueProcess testClass = new RankRevenueProcess();
    	testClass.execute(new MockBatchableContext(), allRanks);

    	
    	Test.stopTest(); //need to stop here in order to test the assertions
    	System.debug('Running asserts in test mode');
    	Set<id> rankIds = new Set<Id>();
    	for (Account_Revenue_Rank__c r: allRanks) {
    		rankIds.add(r.id);
    	}
    	for (List<Account_Revenue_Rank__c> testRanks: [SELECT Current_FY_AsiaEx_Net_Revenue__c,Current_FY_Europe_Net_Revenue__c, Current_FY_Japan_Net_Revenue__c, Current_FY_US_Net_Revenue__c, Current_FY_Global_Net_Revenue__c,  
    		Current_FY_AsiaEx_Rank__c,Current_FY_Europe_Rank__c, Current_FY_Japan_Rank__c, Current_FY_US_Rank__c, Current_FY_Global_Rank__c,  
    		Current_CY_AsiaEx_Net_Revenue__c,Current_CY_Europe_Net_Revenue__c, Current_CY_Japan_Net_Revenue__c, Current_CY_US_Net_Revenue__c, Current_CY_Global_Net_Revenue__c,  
    		Current_CY_AsiaEx_Rank__c,Current_CY_Europe_Rank__c, Current_CY_Japan_Rank__c, Current_CY_US_Rank__c, Current_CY_Global_Rank__c,  
    		Previous_FY_AsiaEx_Net_Revenue__c,Previous_FY_Europe_Net_Revenue__c, Previous_FY_Japan_Net_Revenue__c, Previous_FY_US_Net_Revenue__c, Previous_FY_Global_Net_Revenue__c, 
    		Previous_FY_AsiaEx_Rank__c,Previous_FY_Europe_Rank__c, Previous_FY_Japan_Rank__c, Previous_FY_US_Rank__c, Previous_FY_Global_Rank__c,  
    		Previous_CY_AsiaEx_Net_Revenue__c,Previous_CY_Europe_Net_Revenue__c, Previous_CY_Japan_Net_Revenue__c, Previous_CY_US_Net_Revenue__c, Previous_CY_Global_Net_Revenue__c,  
    		Previous_CY_AsiaEx_Rank__c,Previous_CY_Europe_Rank__c, Previous_CY_Japan_Rank__c, Previous_CY_US_Rank__c, Previous_CY_Global_Rank__c 
    		FROM Account_Revenue_Rank__c where Id in :rankIds]) {
			for (Account_Revenue_Rank__c testRank: testRanks) {
				if (testRank.id == rankNotChanged)
					testRevenueRanksNotZero(testRank);
				else
					testRevenueRanks(testRank);
			}
		}
    	
    }

    private static List<Account_Revenue_Rank__c> getTestRankList(Integer numberOfAccounts, Integer numberOfProducts) {
    	List<Account> accounts = UtilityTesting.CreateAccounts(numberOfAccounts);
    	List<Account_revenue_rank__c> allRanks = new List<Account_revenue_rank__c> ();
    	List<Account_Revenue_Rank__c>  ranks;
    	Integer accountIndex = 0;
    	Set<Id> accountIds = new Set<Id>();
    	for (Account acct: accounts) {
    		ranks = getTestRanks(numberOfProducts);
    		Integer productNumber = 0;
    		for (Account_Revenue_Rank__c rank: ranks) {
    			rank.Account__c = acct.id;
    			rank.Product__c = 'Product'+ productNumber++;
    			rank.Account_Product_Key__c = rank.Account__c + '|' + rank.Product__c;
    			rank.Version__c = 1;
    		}
    		allRanks.addAll(ranks);
    	}
    	insert allRanks;
    	return allRanks;
    }
    
    //Test utility methods
    private static List<Account_Revenue_Rank__c> getTestRanks(Integer ranksToCreate) {
        List<Double> revenues = new List<Double>();
        List<Integer> ranks = new List<Integer>(); 
        List<Account_Revenue_Rank__c> accountRevenueRanks = new List<Account_Revenue_Rank__c>();
        Account_Revenue_Rank__c rank;
        for (integer y=0; y< ranksToCreate; y++) {
	        revenues = new List<Double>();
	        ranks = new List<Integer>(); 
	        for (integer x=0; x<16; x++) {
	        	revenues.add(UtilityTesting.getRandomDouble(100,100000));
	        	ranks.add(UtilityTesting.getRandomInteger(3,10));
	        }
	        rank = getTestRank(revenues, ranks);
	        accountRevenueRanks.add(rank);
	        
        }
    	return accountRevenueRanks;
    }
    
    private static void testRevenueRanks(Account_Revenue_Rank__c rr) {
    	System.assert(rr.Current_FY_AsiaEx_Net_Revenue__c == 0);
    	System.assert(rr.Current_FY_AsiaEx_Rank__c == null);
    	System.assert(rr.Current_FY_Europe_Net_Revenue__c == 0);
    	System.assert(rr.Current_FY_Europe_Rank__c == null);
    	System.assert(rr.Current_FY_Japan_Net_Revenue__c == 0);
    	System.assert(rr.Current_FY_Japan_Rank__c == null);
    	System.assert(rr.Current_FY_US_Net_Revenue__c == 0);
    	System.assert(rr.Current_FY_US_Rank__c == null);
    	System.assert(rr.Current_FY_Global_Net_Revenue__c == 0);
    	System.assert(rr.Current_FY_Global_Rank__c == null);
        	
    	System.assert(rr.Current_CY_AsiaEx_Net_Revenue__c == 0);
    	System.assert(rr.Current_CY_AsiaEx_Rank__c == null);
    	System.assert(rr.Current_CY_Europe_Net_Revenue__c == 0);
    	System.assert(rr.Current_CY_Europe_Rank__c == null);
    	System.assert(rr.Current_CY_Japan_Net_Revenue__c == 0);
    	System.assert(rr.Current_CY_Japan_Rank__c == null);
    	System.assert(rr.Current_CY_US_Net_Revenue__c == 0);
    	System.assert(rr.Current_CY_US_Rank__c == null);
    	System.assert(rr.Current_CY_Global_Net_Revenue__c == 0);
    	System.assert(rr.Current_CY_Global_Rank__c == null);

    	System.assert(rr.Previous_FY_AsiaEx_Net_Revenue__c == 0);
    	System.assert(rr.Previous_FY_AsiaEx_Rank__c == null);
    	System.assert(rr.Previous_FY_Europe_Net_Revenue__c == 0);
    	System.assert(rr.Previous_FY_Europe_Rank__c == null);
    	System.assert(rr.Previous_FY_Japan_Net_Revenue__c == 0);
    	System.assert(rr.Previous_FY_Japan_Rank__c == null);
    	System.assert(rr.Previous_FY_US_Net_Revenue__c == 0);
    	System.assert(rr.Previous_FY_US_Rank__c == null);
    	System.assert(rr.Previous_FY_Global_Net_Revenue__c == 0);
    	System.assert(rr.Previous_FY_Global_Rank__c == null);
        	
    	System.assert(rr.Previous_FY_AsiaEx_Net_Revenue__c == 0);
    	System.assert(rr.Previous_FY_AsiaEx_Rank__c == null);
    	System.assert(rr.Previous_FY_Europe_Net_Revenue__c == 0);
    	System.assert(rr.Previous_FY_Europe_Rank__c == null);
    	System.assert(rr.Previous_FY_Japan_Net_Revenue__c == 0);
    	System.assert(rr.Previous_FY_Japan_Rank__c == null);
    	System.assert(rr.Previous_FY_US_Net_Revenue__c == 0);
    	System.assert(rr.Previous_FY_US_Rank__c == null);
    	System.assert(rr.Previous_FY_Global_Net_Revenue__c == 0);
    	System.assert(rr.Previous_FY_Global_Rank__c == null);
    	
    }
    
    private static void testRevenueRanksNotZero(Account_Revenue_Rank__c rr) {
    	System.assert(rr.Current_FY_AsiaEx_Net_Revenue__c != 0);
    	System.assert(rr.Current_FY_AsiaEx_Rank__c != 0);
    	System.assert(rr.Current_FY_Europe_Net_Revenue__c != 0);
    	System.assert(rr.Current_FY_Europe_Rank__c != 0);
    	System.assert(rr.Current_FY_Japan_Net_Revenue__c != 0);
    	System.assert(rr.Current_FY_Japan_Rank__c != 0);
    	System.assert(rr.Current_FY_US_Net_Revenue__c != 0);
    	System.assert(rr.Current_FY_US_Rank__c != 0);
    	System.assert(rr.Current_FY_Global_Net_Revenue__c != 0);
    	System.assert(rr.Current_FY_Global_Rank__c != 0);
        	
    	System.assert(rr.Current_CY_AsiaEx_Net_Revenue__c != 0);
    	System.assert(rr.Current_CY_AsiaEx_Rank__c != 0);
    	System.assert(rr.Current_CY_Europe_Net_Revenue__c != 0);
    	System.assert(rr.Current_CY_Europe_Rank__c != 0);
    	System.assert(rr.Current_CY_Japan_Net_Revenue__c != 0);
    	System.assert(rr.Current_CY_Japan_Rank__c != 0);
    	System.assert(rr.Current_CY_US_Net_Revenue__c != 0);
    	System.assert(rr.Current_CY_US_Rank__c != 0);
    	System.assert(rr.Current_CY_Global_Net_Revenue__c != 0);
    	System.assert(rr.Current_CY_Global_Rank__c != 0);

    	System.assert(rr.Previous_FY_AsiaEx_Net_Revenue__c != 0);
    	System.assert(rr.Previous_FY_AsiaEx_Rank__c != 0);
    	System.assert(rr.Previous_FY_Europe_Net_Revenue__c != 0);
    	System.assert(rr.Previous_FY_Europe_Rank__c != 0);
    	System.assert(rr.Previous_FY_Japan_Net_Revenue__c != 0);
    	System.assert(rr.Previous_FY_Japan_Rank__c != 0);
    	System.assert(rr.Previous_FY_US_Net_Revenue__c != 0);
    	System.assert(rr.Previous_FY_US_Rank__c != 0);
    	System.assert(rr.Previous_FY_Global_Net_Revenue__c != 0);
    	System.assert(rr.Previous_FY_Global_Rank__c != 0);
        	
    	System.assert(rr.Previous_FY_AsiaEx_Net_Revenue__c != 0);
    	System.assert(rr.Previous_FY_AsiaEx_Rank__c != 0);
    	System.assert(rr.Previous_FY_Europe_Net_Revenue__c != 0);
    	System.assert(rr.Previous_FY_Europe_Rank__c != 0);
    	System.assert(rr.Previous_FY_Japan_Net_Revenue__c != 0);
    	System.assert(rr.Previous_FY_Japan_Rank__c != 0);
    	System.assert(rr.Previous_FY_US_Net_Revenue__c != 0);
    	System.assert(rr.Previous_FY_US_Rank__c != 0);
    	System.assert(rr.Previous_FY_Global_Net_Revenue__c != 0);
    	System.assert(rr.Previous_FY_Global_Rank__c != 0);
    	
    }
	
    private static Account_Revenue_Rank__c getTestRank(List<Double> revenues, List<Integer> ranks) {
    	Account_Revenue_Rank__c rr =  new Account_Revenue_Rank__c();
    	integer index=0;
    	rr.Current_FY_AsiaEx_Net_Revenue__c = revenues[index];
    	rr.Current_FY_AsiaEx_Rank__c = ranks[index++];
    	rr.Current_FY_Europe_Net_Revenue__c = revenues[index];
    	rr.Current_FY_Europe_Rank__c = ranks[index++];
    	rr.Current_FY_Japan_Net_Revenue__c = revenues[index];
    	rr.Current_FY_Japan_Rank__c = ranks[index++];
    	rr.Current_FY_US_Net_Revenue__c = revenues[index];
    	rr.Current_FY_US_Rank__c = ranks[index];
    	rr.Current_FY_Global_Net_Revenue__c = rr.Current_FY_AsiaEx_Net_Revenue__c + rr.Current_FY_Europe_Net_Revenue__c +rr.Current_FY_Japan_Net_Revenue__c + rr.Current_FY_US_Net_Revenue__c ;
    	rr.Current_FY_Global_Rank__c = ranks[index++];
        	
    	rr.Current_CY_AsiaEx_Net_Revenue__c = revenues[index];
    	rr.Current_CY_AsiaEx_Rank__c = ranks[index++];
    	rr.Current_CY_Europe_Net_Revenue__c = revenues[index];
    	rr.Current_CY_Europe_Rank__c = ranks[index++];
    	rr.Current_CY_Japan_Net_Revenue__c = revenues[index];
    	rr.Current_CY_Japan_Rank__c = ranks[index++];
    	rr.Current_CY_US_Net_Revenue__c = revenues[index];
    	rr.Current_CY_US_Rank__c = ranks[index];
    	rr.Current_CY_Global_Net_Revenue__c = rr.Current_CY_AsiaEx_Net_Revenue__c + rr.Current_CY_Europe_Net_Revenue__c + rr.Current_CY_Japan_Net_Revenue__c + rr.Current_CY_US_Net_Revenue__c;
    	rr.Current_CY_Global_Rank__c = ranks[index++];

    	rr.Previous_FY_AsiaEx_Net_Revenue__c = revenues[index];
    	rr.Previous_FY_AsiaEx_Rank__c = ranks[index++];
    	rr.Previous_FY_Europe_Net_Revenue__c = revenues[index];
    	rr.Previous_FY_Europe_Rank__c = ranks[index++];
    	rr.Previous_FY_Japan_Net_Revenue__c = revenues[index];
    	rr.Previous_FY_Japan_Rank__c = ranks[index++];
    	rr.Previous_FY_US_Net_Revenue__c = revenues[index];
    	rr.Previous_FY_US_Rank__c = ranks[index];
    	rr.Previous_FY_Global_Net_Revenue__c = rr.Previous_FY_AsiaEx_Net_Revenue__c + rr.Previous_FY_Europe_Net_Revenue__c + rr.Previous_FY_Japan_Net_Revenue__c + rr.Previous_FY_US_Net_Revenue__c;
    	rr.Previous_FY_Global_Rank__c = ranks[index++];
        	
    	rr.Previous_CY_AsiaEx_Net_Revenue__c = revenues[index];
    	rr.Previous_CY_AsiaEx_Rank__c = ranks[index++];
    	rr.Previous_CY_Europe_Net_Revenue__c = revenues[index];
    	rr.Previous_CY_Europe_Rank__c = ranks[index++];
    	rr.Previous_CY_Japan_Net_Revenue__c = revenues[index];
    	rr.Previous_CY_Japan_Rank__c = ranks[index++];
    	rr.Previous_CY_US_Net_Revenue__c = revenues[index];
    	rr.Previous_CY_US_Rank__c = ranks[index];
    	rr.Previous_CY_Global_Net_Revenue__c = rr.Previous_CY_AsiaEx_Net_Revenue__c + rr.Previous_CY_Europe_Net_Revenue__c + rr.Previous_CY_Japan_Net_Revenue__c + rr.Previous_CY_US_Net_Revenue__c;
    	rr.Previous_CY_Global_Rank__c = ranks[index++];
    	return rr;
	}
	
	
	class MockBatchableContext implements Database.BatchableContext {
		public Id getChildJobId() {
			return Id.valueOf('001xa000003DIlo');
		}
		public Id getJobId() {
			return Id.valueOf('001xa000003DIlo');
		}
	}	
}