/**
 * This class contains unit tests for RevenueRankUtiltity methods
 */
 @isTest
private class RevenueRankUtilityTest {
    @isTest public static void testLogErrors() {
		//test empty map
		Database.SaveResult[] saveResults = new Database.SaveResult[]{};
		Database.UpsertResult[] upsertResults = new Database.UpsertResult[]{};
            Database.DeleteResult[] deleteResults = new Database.DeleteResult[]{};
		Map<Integer, String> errorMessageMap = RevenueRankUtility.logErrors(saveResults, null, null, 'test','test');
		System.assert(errorMessageMap.size() == 0);		    
		errorMessageMap = RevenueRankUtility.logErrors(null, upsertResults, null, 'test','test');
		System.assert(errorMessageMap.size() == 0);
		errorMessageMap = RevenueRankUtility.logErrors(null, null, deleteResults, 'test','test');
		System.assert(errorMessageMap.size() == 0);
        
		//not success
		Account_Revenue_Rank__c rank = new Account_Revenue_Rank__c();
		List<Account> acts = UtilityTesting.CreateAccounts(2);
		String testKey = 'TESTTESTTEST';
		rank.Account__c = acts[0].id;
		rank.Account_Product_Key__c = testKey;
		
		saveResults.add(Database.insert(rank,false));
		errorMessageMap = RevenueRankUtility.logErrors(saveResults, null, null, 'test','test');
		System.assert(errorMessageMap.size() == 0);
		Account_Revenue_Rank__c rank2 = new Account_Revenue_Rank__c();
		rank2.Account__c= acts[1].id;
		rank2.Account_Product_Key__c = testKey;
		saveResults.add(Database.insert(rank2,false));
		errorMessageMap = RevenueRankUtility.logErrors(saveResults, null, null, 'test','test');
		System.assert(errorMessageMap.size() != 0);
		
		Account_Revenue_Rank__c rank3 = new Account_Revenue_Rank__c();
		//don't put the account on it
		rank3.Account_Product_Key__c = testKey;
		Database.UpsertResult upResult = Database.upsert(rank3, false);
		System.debug('Upsert result ' + upResult.isSuccess());
		upsertResults.add(upResult);
		errorMessageMap = RevenueRankUtility.logErrors(null, upsertResults, null, 'test','test');
		System.assert(errorMessageMap.size() != 0);
        
        //delete the first rank but capture the id before hand
        Id rankId = rank.id;
        Database.delete(rankId);
        //now try to delete again
        deleteResults.add(Database.delete(rankId, false));
        errorMessageMap = RevenueRankUtility.logErrors(null, null, deleteResults, 'test','test');
		System.assert(errorMessageMap.size() != 0);
    }
    
    @isTest public static void testEmailResults() {
    	//test false
    	List<String> errorMessageList = new List<String>();
    	Id apexJobId = null;
    	Integer totalJobItems = 1;
    	Integer numberOfErrors = 0;
    	String[] address = new String[] {'test@test.test'};
    	//test not sent
    	boolean result = RevenueRankUtility.emailResults(address, 'subject',apexJobId, errorMessageList, totalJobItems, numberOfErrors,'test job');
    	System.assert(!result);
    	errorMessageList.add('Test error message');
    	result = RevenueRankUtility.emailResults(address, 'subject',apexJobId, errorMessageList, totalJobItems, numberOfErrors,'test job');
    	System.assert(result);
    	result = RevenueRankUtility.emailResults(address, 'subject','000000010000010000', errorMessageList, totalJobItems, numberOfErrors,'test job');
    	System.assert(result);
    }
    
    @isTest public static void testGetToAddress() {
    	Configuration__c testConfig = createConfiguration('testConfigName','testParamName','peter.test@test.test');
    	Configuration__c testConfig2 = createConfiguration('testConfigName2','testParamName2','peter.test@test.test,peter.test2@test.test');
		//for test not found
		User sfadmin = [SELECT id, email from User where alias='sfadmin' LIMIT 1];
		
		Test.startTest();
		String[] toAddress = RevenueRankUtility.getToAddress('testConfigName','testParamName',',');
		System.assert(toAddress.size() == 1);
		System.assert(toAddress[0].equals('peter.test@test.test'));
		
		toAddress = RevenueRankUtility.getToAddress('testConfigName2','testParamName2',',');
		System.assert(toAddress.size() == 2);
		System.assert(toAddress[0].equals('peter.test@test.test'));
		System.assert(toAddress[1].equals('peter.test2@test.test'));
		
		toAddress = RevenueRankUtility.getToAddress('testUnknownConfigName','testUnknownConfigParam',',');
		System.assert(toAddress.size() == 1);
		System.assert(toAddress[0].equals(sfadmin.Email));
		Test.stopTest();
				    	 
    }
    
    @isTest public static void testGetCurrentAccountRevenueRankVersion() {
    	Configuration__c testConfig1 = createConfiguration('RevenueRankBatch','Version','100');
    	Integer result = RevenueRankUtility.getCurrentAccountRevenueRankVersion();
        System.assertEquals(100, result);
    }

    @isTest public static void testGetCurrentAccountRevenueRankVersionNullInitialVersion() {
    	Configuration__c testConfig1 = createConfiguration('RevenueRankBatch','Version',null);
    	Integer result = RevenueRankUtility.getCurrentAccountRevenueRankVersion();
        System.assertEquals(0, result);
    }
    
    @isTest public static void testUpdateCurrentAccountRevenueRankVersion() {
    	RevenueRankUtility.updateCurrentAccountRevenueRankVersion(100);
    	Integer result = RevenueRankUtility.getCurrentAccountRevenueRankVersion();
    	System.assert(result == 100);
    	RevenueRankUtility.updateCurrentAccountRevenueRankVersion(101);
    	result = RevenueRankUtility.getCurrentAccountRevenueRankVersion();
    	System.assert(result == 101);
    }
    
    @isTest public static void testSet() {
        RevenueRankUtility.setCompleteState();
        String actual = getCurrentState();
        System.assertEquals(RevenueRankUtility.STATE_COMPLETE, actual);
    }
    
    @isTest public static void testSetRankProgress() {
        RevenueRankUtility.setRankProgress(1);
        System.assertNotEquals(null, getCurrentState());
    }

    @isTest public static void testSetErrorState() {
        RevenueRankUtility.setErrorState();
        String actual = getCurrentState();
        System.assertEquals(RevenueRankUtility.STATE_ERROR, actual);
    }
    
    @isTest public static void testResetAccountRevenueRank() {
    	//set up a rank with non-zero values();
    	Account_Revenue_Rank__c rr = new Account_Revenue_Rank__c();
    	rr.Current_CY_AsiaEx_Net_Revenue__c = 100;
    	rr.Current_CY_AsiaEx_Rank__c = 10;
    	rr.Current_CY_Europe_Net_Revenue__c = 100;
    	rr.Current_CY_Europe_Rank__c = 10;
    	rr.Current_CY_Global_Net_Revenue__c = 100;
    	rr.Current_CY_Global_Rank__c = 10;
    	rr.Current_CY_Japan_Net_Revenue__c = 100;
    	rr.Current_CY_Japan_Rank__c = 10;
    	rr.Current_CY_US_Net_Revenue__c = 100;
    	rr.Current_CY_US_Rank__c = 10;
        	
    	rr.Current_FY_AsiaEx_Net_Revenue__c = 100;
    	rr.Current_FY_AsiaEx_Rank__c = 10;
    	rr.Current_FY_Europe_Net_Revenue__c = 100;
    	rr.Current_FY_Europe_Rank__c = 10;
    	rr.Current_FY_Global_Net_Revenue__c = 100;
    	rr.Current_FY_Global_Rank__c = 10;
    	rr.Current_FY_Japan_Net_Revenue__c = 100;
    	rr.Current_FY_Japan_Rank__c = 10;
    	rr.Current_FY_US_Net_Revenue__c = 100;
    	rr.Current_FY_US_Rank__c = 10;

    	rr.Previous_CY_AsiaEx_Net_Revenue__c = 100;
    	rr.Previous_CY_AsiaEx_Rank__c = 10;
    	rr.Previous_CY_Europe_Net_Revenue__c = 100;
    	rr.Previous_CY_Europe_Rank__c = 10;
    	rr.Previous_CY_Global_Net_Revenue__c = 100;
    	rr.Previous_CY_Global_Rank__c = 10;
    	rr.Previous_CY_Japan_Net_Revenue__c = 100;
    	rr.Previous_CY_Japan_Rank__c = 10;
    	rr.Previous_CY_US_Net_Revenue__c = 100;
    	rr.Previous_CY_US_Rank__c = 10;
        	
    	rr.Previous_FY_AsiaEx_Net_Revenue__c = 100;
    	rr.Previous_FY_AsiaEx_Rank__c = 10;
    	rr.Previous_FY_Europe_Net_Revenue__c = 100;
    	rr.Previous_FY_Europe_Rank__c = 10;
    	rr.Previous_FY_Global_Net_Revenue__c = 100;
    	rr.Previous_FY_Global_Rank__c = 10;
    	rr.Previous_FY_Japan_Net_Revenue__c = 100;
    	rr.Previous_FY_Japan_Rank__c = 10;
    	rr.Previous_FY_US_Net_Revenue__c = 100;
    	rr.Previous_FY_US_Rank__c = 10;
    	
    	RevenueRankUtility.resetAccountRevenueRank(rr);
		//do the asserts here
		
    	System.assert(rr.Current_CY_AsiaEx_Net_Revenue__c == 0);
    	System.assert(rr.Current_CY_AsiaEx_Rank__c == null);
    	System.assert(rr.Current_CY_Europe_Net_Revenue__c == 0);
    	System.assert(rr.Current_CY_Europe_Rank__c == null);
    	System.assert(rr.Current_CY_Global_Net_Revenue__c == 0);
    	System.assert(rr.Current_CY_Global_Rank__c == null);
    	System.assert(rr.Current_CY_Japan_Net_Revenue__c == 0);
    	System.assert(rr.Current_CY_Japan_Rank__c == null);
    	System.assert(rr.Current_CY_US_Net_Revenue__c == 0);
    	System.assert(rr.Current_CY_US_Rank__c == null);
        	
    	System.assert(rr.Current_FY_AsiaEx_Net_Revenue__c == 0);
    	System.assert(rr.Current_FY_AsiaEx_Rank__c == null);
    	System.assert(rr.Current_FY_Europe_Net_Revenue__c == 0);
    	System.assert(rr.Current_FY_Europe_Rank__c == null);
    	System.assert(rr.Current_FY_Global_Net_Revenue__c == 0);
    	System.assert(rr.Current_FY_Global_Rank__c == null);
    	System.assert(rr.Current_FY_Japan_Net_Revenue__c == 0);
    	System.assert(rr.Current_FY_Japan_Rank__c == null);
    	System.assert(rr.Current_FY_US_Net_Revenue__c == 0);
    	System.assert(rr.Current_FY_US_Rank__c == null);

    	System.assert(rr.Previous_CY_AsiaEx_Net_Revenue__c == 0);
    	System.assert(rr.Previous_CY_AsiaEx_Rank__c == null);
    	System.assert(rr.Previous_CY_Europe_Net_Revenue__c == 0);
    	System.assert(rr.Previous_CY_Europe_Rank__c == null);
    	System.assert(rr.Previous_CY_Global_Net_Revenue__c == 0);
    	System.assert(rr.Previous_CY_Global_Rank__c == null);
    	System.assert(rr.Previous_CY_Japan_Net_Revenue__c == 0);
    	System.assert(rr.Previous_CY_Japan_Rank__c == null);
    	System.assert(rr.Previous_CY_US_Net_Revenue__c == 0);
    	System.assert(rr.Previous_CY_US_Rank__c == null);
        	
    	System.assert(rr.Previous_FY_AsiaEx_Net_Revenue__c == 0);
    	System.assert(rr.Previous_FY_AsiaEx_Rank__c == null);
    	System.assert(rr.Previous_FY_Europe_Net_Revenue__c == 0);
    	System.assert(rr.Previous_FY_Europe_Rank__c == null);
    	System.assert(rr.Previous_FY_Global_Net_Revenue__c == 0);
    	System.assert(rr.Previous_FY_Global_Rank__c == null);
    	System.assert(rr.Previous_FY_Japan_Net_Revenue__c == 0);
    	System.assert(rr.Previous_FY_Japan_Rank__c == null);
    	System.assert(rr.Previous_FY_US_Net_Revenue__c == 0);
    	System.assert(rr.Previous_FY_US_Rank__c == null);
    	
    	
    	
    }
    
    @isTest public static void testLogExecuteMethod() {
    	System.debug('testLogExecuteMethod');
    	RevenueRankUtility.logExecuteMethod('Test', Id.valueOf('001xa000003DIlo'), 100);
    }
    
    @isTest public static void testGetAccountProductKey() {
    	Id testId = Id.valueOf('001xa000003DIlo');
    	String product = 'testproduct';
    	System.assert(RevenueRankUtility.getAccountProductKey(testId, product).equals(testId+'|'+product));
    }
    
    @isTest public static void testUpdateRank() {
        List<Account_Revenue_Rank__c> testRanks = getTestRanks(1);
        Account_Revenue_Rank__c rank = testRanks[0];
        for (Integer i=0 ; i< RevenueRankUtility.FIELDS.values().size(); i++) {
            RevenueRankUtility.updateRank(rank,RevenueRankUtility.FIELDS.values()[i],i);
            System.assertEquals(i, getRank(rank, RevenueRankUtility.FIELDS.values()[i]));
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

    @isTest public static void testMapErrorsAndNotify(){
        Map<Integer, String> errorMap = new Map<Integer, String>();
        String jobName = 'testMapErrorsAndNotify';
        List<Account_Revenue_Rank__c> allRanksByProduct = new List<Account_Revenue_Rank__c>();
        boolean result = RevenueRankUtility.mapErrorsAndNotify(errorMap, jobName, allRanksByProduct, 1, 1, Id.valueOf('001xa000003DIlo'));
        System.assert(!result);
        errorMap.put(0, 'test error');
        allRanksByProduct.add(new Account_Revenue_Rank__c());
		result = RevenueRankUtility.mapErrorsAndNotify(errorMap, jobName, allRanksByProduct, 1, 1, Id.valueOf('001xa000003DIlo'));
        System.assert(result);
    }

    @isTest public static void testListErrorsAndNotify(){
        String jobName = 'testMapErrorsAndNotify';
        List<String> errors = new List<String>();
        Map<String, String> jobStats = new Map<String, String>();
        jobStats.put(RevenueRankUtility.JOB_ITEMS, '1');
        jobStats.put(RevenueRankUtility.JOB_ERRORS, '0');
        
        boolean result = RevenueRankUtility.listErrorsAndNotify(errors, jobName, Id.valueOf('001xa000003DIlo'),jobStats);
        System.assert(!result);
        jobStats.put(RevenueRankUtility.JOB_ERRORS, '1');
        jobStats.put(RevenueRankUtility.JOB_LASTPRODUCT,'test');
        result = RevenueRankUtility.listErrorsAndNotify(errors, jobName, Id.valueOf('001xa000003DIlo'),jobStats);
        System.assert(result);
        
        errors.add('Test error');
		result = RevenueRankUtility.listErrorsAndNotify(errors, jobName, Id.valueOf('001xa000003DIlo'), jobStats);
        System.assert(result);
    }
    
    @isTest public static void testGetJobStats() {
        Map<String, String> results = RevenueRankUtility.getJobStats(Id.valueOf('001xa000003DIlo'));
        System.assert(results.get(RevenueRankUtility.JOB_ITEMS)=='0');
        System.assert(results.get(RevenueRanKUtility.JOB_ERRORS)=='0');
    }
    
    @isTest public static void testPopulateErrorList() {
        Map<Integer, String> errorMap = new Map<Integer, String>();
        errorMap.put(1, 'Test message 2');
        errorMap.put(4, 'Test message 5');
        List<Account_Revenue_Rank__c> ranks = new List<Account_Revenue_Rank__c>();
        List<Account> accounts = UtilityTesting.CreateAccounts(1);
        Account account = accounts[0];
        
        for (Integer x=0; x<5; x++) {
            Account_Revenue_Rank__c rank = new Account_Revenue_Rank__c();
            rank.Account__c = account.id;
            rank.Product__c='Product'+x;
            rank.Account_Product_Key__c = account.id+'|Product'+x;
            ranks.add(rank);
        }
        Test.startTest();
        Database.insert(ranks, true);
        List<String> errorList = new List<String>();
        RevenueRankUtility.populateErrorList(errorMap, 'test', ranks, errorList);
        Test.stopTest();
        System.assertEquals(2, errorList.size());
    }
    
    @isTest public static void testGetRevenue() {
        Account_Revenue_Rank__c rr = new Account_Revenue_Rank__c();
        rr.Current_CY_AsiaEx_Net_Revenue__c = 100;
    	rr.Current_CY_Europe_Net_Revenue__c = 100;
    	rr.Current_CY_Global_Net_Revenue__c = 100;
    	rr.Current_CY_Japan_Net_Revenue__c = 100;
    	rr.Current_CY_US_Net_Revenue__c = 100;
    	rr.Current_FY_AsiaEx_Net_Revenue__c = 100;
    	rr.Current_FY_Europe_Net_Revenue__c = 100;
    	rr.Current_FY_Global_Net_Revenue__c = 100;
    	rr.Current_FY_Japan_Net_Revenue__c = 100;
    	rr.Current_FY_US_Net_Revenue__c = 100;
    	rr.Previous_CY_AsiaEx_Net_Revenue__c = 100;
    	rr.Previous_CY_Europe_Net_Revenue__c = 100;
    	rr.Previous_CY_Global_Net_Revenue__c = 100;
    	rr.Previous_CY_Japan_Net_Revenue__c = 100;
    	rr.Previous_CY_US_Net_Revenue__c = 100;
    	rr.Previous_FY_AsiaEx_Net_Revenue__c = 100;
    	rr.Previous_FY_Europe_Net_Revenue__c = 100;
    	rr.Previous_FY_Global_Net_Revenue__c = 100;
    	rr.Previous_FY_Japan_Net_Revenue__c = 100;
    	rr.Previous_FY_US_Net_Revenue__c = 100;
        for (Integer x=0; x<RevenueRankUtility.FIELDS.values().size(); x++) {
            System.assertEquals(100, RevenueRankUtility.getRevenue(rr, RevenueRankUtility.FIELDS.values()[x]));
        }
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
    
    private static String getCurrentState() {
        String configName='RevenueRankBatch';
        String paramName = 'STATE';
        String val = null;
        Configuration__c[] versions = [SELECT Parameter_Value__c from Configuration__c where Param_Name__c=:paramName and Name=:configName LIMIT 1];
        if (null != versions || versions.size() > 0) {
            Configuration__c config = versions[0];
            val = config.Parameter_Value__c;
        }
        return val;

    }

    private static Configuration__c createConfiguration(String name, String paramName, String paramValue) {
        List<Configuration__c> testConfigs = new List<Configuration__c>();
        Configuration__c testConfig = new Configuration__c();
        testConfig.Parameter_Value__c = paramValue;
        testConfig.Param_Name__c = paramName;
        testConfig.Name = name;
        testConfigs.add(testConfig);
        Database.insert(testConfigs, true);
        return testConfigs[0];
    }

}