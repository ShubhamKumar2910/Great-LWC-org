/**
 * This class contains unit tests for RevenueRankUtiltity methods
 */
@isTest
private class CleanAccountRevenueStatsTest {
    @isTest public static void testCleanAll() {
        List<Account> accounts = UtilityTesting.CreateAccounts(1);
        List<Account_Revenue_Rank__c> ranks = new List<Account_Revenue_Rank__c>();
        Integer version =1;
        //create some revenue ranks
        Account_Revenue_Rank__c rank = RevenueRankTestingUtility.getNewRank();
        rank.version__c=version;
        rank.Account__c = accounts[0].id;
        ranks.add(rank);
        Account_Revenue_Rank__c rank2 = RevenueRankTestingUtility.getNewRank();
        rank2.version__c=version;
        rank2.Account__c = accounts[0].id;
        ranks.add(rank2);
        insert ranks;
        ranks = [SELECT id FROM Account_Revenue_Rank__c];
        System.assert(ranks.size()==2);

        System.debug('Starting test');
        Test.startTest();
        CleanAccountRevenueStats testClass = new CleanAccountRevenueStats(version-1);
        Database.executeBatch(testClass);
        Test.stopTest(); //need to stop here in order to test the assertions
        ranks = [SELECT id FROM Account_Revenue_Rank__c];
        System.assert(ranks.size()==0);
        
    }
    
    @isTest public static void testCleanNone() {
        List<Account> accounts = UtilityTesting.CreateAccounts(1);
        List<Account_Revenue_Rank__c> ranks = new List<Account_Revenue_Rank__c>();
        Integer version =1;
        //create some revenue ranks
        Account_Revenue_Rank__c rank = RevenueRankTestingUtility.getNewRank();
        rank.version__c=version;
        rank.Account__c = accounts[0].id;
        ranks.add(rank);
        Account_Revenue_Rank__c rank2 = RevenueRankTestingUtility.getNewRank();
        rank2.version__c=version;
        rank2.Account__c = accounts[0].id;
        ranks.add(rank2);
        insert ranks;
        ranks = [SELECT id FROM Account_Revenue_Rank__c];
        System.assert(ranks.size()==2);

        System.debug('Starting test');
        Test.startTest();
        CleanAccountRevenueStats testClass = new CleanAccountRevenueStats(version);
        Database.executeBatch(testClass);
        Test.stopTest(); //need to stop here in order to test the assertions
        ranks = [SELECT id FROM Account_Revenue_Rank__c];
        System.assert(ranks.size()==2);
        
    }

    @isTest public static void testCleanSome() {
        List<Account> accounts = UtilityTesting.CreateAccounts(1);
        List<Account_Revenue_Rank__c> ranks = new List<Account_Revenue_Rank__c>();
        Integer version = 1;
        //create some revenue ranks
        Account_Revenue_Rank__c rank = RevenueRankTestingUtility.getNewRank();
        rank.version__c=version;
        rank.Account__c = accounts[0].id;
        ranks.add(rank);
        Account_Revenue_Rank__c rank2 = RevenueRankTestingUtility.getNewRank();
        rank2.version__c=version-1;
        rank2.Account__c = accounts[0].id;
        ranks.add(rank2);
        insert ranks;
        ranks = [SELECT id FROM Account_Revenue_Rank__c];
        System.assert(ranks.size()==2);

        System.debug('Starting test');
        Test.startTest();
        CleanAccountRevenueStats testClass = new CleanAccountRevenueStats(version);
        Database.executeBatch(testClass);
        Test.stopTest(); //need to stop here in order to test the assertions
        ranks = [SELECT id FROM Account_Revenue_Rank__c];
        System.assert(ranks.size()==1);
        
    }

    @isTest public static void testCleanBulk() {
        List<Account> accounts = UtilityTesting.CreateAccounts(1);
        List<Account_Revenue_Rank__c> ranks = new List<Account_Revenue_Rank__c>();
        Integer version = 1;
        
        for (Integer x=0; x<200; x++) {
        //create some revenue ranks
            Account_Revenue_Rank__c rank = RevenueRankTestingUtility.getNewRank();
            rank.version__c=version;
            rank.Account__c = accounts[0].id;
            ranks.add(rank);
        }
        insert ranks;
        ranks = [SELECT id FROM Account_Revenue_Rank__c];
        System.assert(ranks.size()==200);

        System.debug('Starting test');
        Test.startTest();
        CleanAccountRevenueStats testClass = new CleanAccountRevenueStats(version+1);
        Database.executeBatch(testClass);
        Test.stopTest(); //need to stop here in order to test the assertions
        ranks = [SELECT id FROM Account_Revenue_Rank__c];
        System.assert(ranks.size()==0);
        
    }

}