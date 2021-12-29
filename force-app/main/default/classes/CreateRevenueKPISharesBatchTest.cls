@isTest
private class CreateRevenueKPISharesBatchTest {
    @isTest public static void TestCreateRevenueKPISharesOneAccountOneKPI() {
    	
    	//create the users
    	System.debug('Creating test users');
    	List<User> users = UtilityTesting.CreateUsers(3);
        System.debug('Creating test RG account');
        Account rgAccount = TestRevenueKPIDataFactory.createRgAccount('RGNAME');
        List<Account> rgAccounts = new List<Account>();
        rgAccounts.add(rgAccount);
        System.debug('Creating test rm accounts for rg');
        List<Account> rmAccounts = TestRevenueKPIDataFactory.createAccountsWithRg(3, rgAccount);
        System.debug('Creating kpiOwner');
        User kpiOwner = TestRevenueKPIDataFactory.createKPIOwner();
        //create the kpi
        System.debug('Creating test kpi');
        List<Revenue_KPI__c> kpis = TestRevenueKPIDataFactory.createKPIs(rgAccounts, kpiOwner);
        
        List<AccountTeamMember> acctTeamList = new List<AccountTeamMember>();
        //create the account team members directly on the account			
        for (Account account: rmAccounts) {
            for (User u: users) {
                AccountTeamMember member = new AccountTeamMember();
                member.accountId = account.id;
                member.userId = u.id;
                member.TeamMemberRole = 'Account Manager';
                acctTeamList.add(member);
            }
        }
        insert acctTeamList;
        Test.startTest();
        Map<Id, Integer> countMap = getShareCountsByKPI(kpis, kpiOwner);
        for (Id key: countMap.keySet()) {
            System.assert(countMap.get(key) == 0);
        }
        //fire the batch
        Database.executeBatch(new CreateRevenueKPISharesBatch(rgAccount), 200);
        countMap = getShareCountsByKPI(kpis, kpiOwner);
        for (Id key: countMap.keySet()) {
            System.assert(countMap.get(key) == 3);
        }
        Test.stopTest();						
    	
    } 

    @isTest public static void TestCreateRevenueKPISharesOneAccountManyKPI() {
    	
    	//create the users
    	System.debug('Creating test users');
        List<User> users = UtilityTesting.CreateUsers(3);
        System.debug('Creating test RG account');
        Test.startTest();
        Account rgAccount = TestRevenueKPIDataFactory.createRgAccount('RGNAME');
        List<Account> rgAccounts = new List<Account>();
        rgAccounts.add(rgAccount);
        System.debug('Creating test rm accounts for rg');
        List<Account> rmAccounts = TestRevenueKPIDataFactory.createAccountsWithRg(3, rgAccount);
        Account rgAccount2 = TestRevenueKPIDataFactory.createRgAccount('RGNAME2');
        rgAccounts.add(rgAccount2);
        rmAccounts.addAll(TestRevenueKPIDataFactory.createAccountsWithRg(3, rgAccount2));
        System.debug('Creating kpiOwner');
        User kpiOwner = TestRevenueKPIDataFactory.createKPIOwner();
        //create the kpi
        System.debug('Creating test kpis');
        List<Revenue_KPI__c> kpis = TestRevenueKPIDataFactory.createKPIsForAccount(rgAccount, kpiOwner,150);
        kpis.addAll(TestRevenueKPIDataFactory.createKPIsForAccount(rgAccount2, kpiOwner,150));
        
        List<AccountTeamMember> acctTeamList = new List<AccountTeamMember>();
        
        //create the account team members directly on the account			
        for (Account account: rmAccounts) {
            for (User u: users) {
                AccountTeamMember member = new AccountTeamMember();
                member.accountId = account.id;
                member.userId = u.id;
                member.TeamMemberRole = 'Account Manager';
                acctTeamList.add(member);
            }
        }
        insert acctTeamList;
        //Test.startTest();
        Map<Id, Integer> countMap = getShareCountsByKPI(kpis, kpiOwner);
        for (Id key: countMap.keySet()) {
            System.assert(countMap.get(key) == 0);
        }
        //fire the batch
        System.debug('Firing Batch for creating kpi shares');
        Database.executeBatch(new CreateRevenueKPISharesBatch(), kpis.size());
        countMap = getShareCountsByKPI(kpis, kpiOwner);
        for (Id key: countMap.keySet()) {
            System.assert(countMap.get(key) == 3);
        }
        Test.stopTest();						
    } 

    @isTest static void testSchedule(){
	    String sched_exp = '0 0 1 1 4 ?';
	    Test.startTest();
	    String jobId = system.schedule('Create RevenueKPI Share Test', sched_exp, new CreateRevenueKPISharesBatch());
	    CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
   	    System.assertEquals(sched_exp,ct.CronExpression);
	    Test.stopTest();
   }

    private static Map<Id, Integer> getShareCountsByKPI(List<Revenue_KPI__c> kpis, User owner) {
    	Map<Id, Integer> countMap = new Map<Id, Integer>();
    	Map<Id, List<Revenue_KPI__share>> tempMap = TestRevenueKPIDataFactory.getKpiShares(owner.Id, kpis);
    	for (Id key: tempMap.keySet()) {
    		countMap.put(key, null != tempMap.get(key) ? tempMap.get(key).size(): 0);
    	}
    	return countMap;
    }
}