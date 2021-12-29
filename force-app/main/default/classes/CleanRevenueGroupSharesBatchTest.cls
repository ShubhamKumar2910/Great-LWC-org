@isTest
private class CleanRevenueGroupSharesBatchTest {
    @isTest public static void TestSingleCreateMissingShare() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            //create the 'integration user'
            User integrationUser = createUser('iTstUsr','iTstUsr@test.com');
            //create the 'real user'
            User realUser = createUser('realUser','iRealUsr@test.com');

            //create rg account
            Account rg = TestRevenueKPIDataFactory.createRgAccount('RGTest');
            List<Account> rms = TestRevenueKPIDataFactory.createAccountsWithRg(1, rg);
            
            //create revenue with group
            Group g = createGroup('Revenue_Test');
            Revenue__c rev = createRevenue(rg, rms[0], integrationUser, g.Name);
            //remove the group share
            List<Revenue__Share> shares = [Select Id from Revenue__Share where parentid=:rev.Id and userorgroupid=:g.id];
            Integer preTestShareCount = shares.size();
            System.assert(preTestShareCount == 1);
            List<Revenue__Share> sharesToRemove = new List<Revenue__Share>();
            sharesToRemove.add(shares[0]);
            delete sharesToRemove;
            shares = [Select Id from Revenue__Share where parentid=:rev.Id and userorgroupid=:g.id];
            preTestShareCount = shares.size();
            System.assert(preTestShareCount == 0);
            
            Test.startTest();
            //fire the batch
            Database.executeBatch(new CleanRevenueGroupSharesBatch('iTstUsr'), 200);
            Test.stopTest();
            shares = [Select Id from Revenue__Share where parentid=:rev.Id and userorgroupid=:g.id];
            preTestShareCount = shares.size();
            System.assert(preTestShareCount == 1);
        }
    }
    
    @isTest public static void TestBatchCreateMissingShare() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            //create the 'integration user'
            User integrationUser = createUser('iTstUsr','iTstUsr@test.com');
            //create the 'real user'
            User realUser = createUser('realUser','iRealUsr@test.com');

            //create rg account
            Account rg = TestRevenueKPIDataFactory.createRgAccount('RGTest');
            List<Account> rms = TestRevenueKPIDataFactory.createAccountsWithRg(1, rg);
            
            //create revenue with group
            Group g = createGroup('Revenue_Test');
            List<Revenue__c> revenueWithSharesToRemove = new List<Revenue__c>();
            List<Id> revIds = new List<Id>();
            revenueWithSharesToRemove = createRevenues(rg, rms[0], integrationUser, g.Name,200);
            for (Revenue__c rev: revenueWithSharesToRemove) {
                revIds.add(rev.Id);
            }
            
            //remove the group share
            List<Revenue__Share> shares = [Select Id from Revenue__Share where parentid in :revIds and userorgroupid=:g.id];
            Integer preTestShareCount = shares.size();
            System.assert(preTestShareCount == 200);
            List<Revenue__Share> sharesToRemove = new List<Revenue__Share>();
            sharesToRemove.addAll(shares);
            delete sharesToRemove;
            shares = [Select Id from Revenue__Share where parentid in :revIds and userorgroupid=:g.id];
            preTestShareCount = shares.size();
            System.assert(preTestShareCount == 0);
            
            Test.startTest();
            //fire the batch
            Database.executeBatch(new CleanRevenueGroupSharesBatch('iTstUsr'), 200);
            Test.stopTest();
            shares = [Select Id from Revenue__Share where parentid in:revIds and userorgroupid=:g.id];
            preTestShareCount = shares.size();
            System.assert(preTestShareCount == 200);
            

        }
    }

    private static User createUser(String alias, String userName) {
        Profile p  = [SELECT Id From Profile WHERE Name='System Administrator' limit 1];
        User kpiOwner = new User( Alias = alias,
                                 Email ='newUserKPIOwner@testorg.com',
                                 EmailEncodingKey = 'UTF-8',
                                 LastName = 'newUserKPIOwner',
                                 LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', 
                                 UserName=userName,
                                 ProfileId=p.Id,
                                 TimeZoneSidKey = 'America/Los_Angeles'
                                );
        kpiOwner.IsActive = True;
        insert kpiOwner;
        System.debug('Init. owner id ' + kpiOwner.Id);
        return kpiOwner;
    }

    private static Revenue__c createRevenue(Account rg, Account rm, User owner, String groupName) {
    	Revenue__c rev = new Revenue__c();
    	rev.RG__c = rg.id;
        rev.RM__c = rm.id;
    	rev.RevenueKey__c = getRandomAccountName('xxxx');

    	rev.RG_Id__c = rg.RDM_Org_ID__c;
        rev.RM_Id__c = rm.RDM_Org_ID__c;
        rev.ownerId = owner.id;
        rev.Group__c = groupName;
    	insert rev;
    	return rev;
    }
    
    private static List<Revenue__c> createRevenues(Account rg, Account rm, User owner, String groupName, integer count) {
        List<Revenue__c> vals = new List<Revenue__c>();
        for (integer x=0; x<count; x++) {
            Revenue__c rev = new Revenue__c();
            rev.RG__c = rg.id;
            rev.RM__c = rm.id;
            rev.RevenueKey__c = getRandomAccountName('xxxx');
    
            rev.RG_Id__c = rg.RDM_Org_ID__c;
            rev.RM_Id__c = rm.RDM_Org_ID__c;
            rev.ownerId = owner.id;
            rev.Group__c = groupName;
            vals.add(rev);
        }
        insert vals;
        return vals;
    }
    
    private static Revenue__c updateRevenue(Revenue__c revenue, String ownerId) {
        revenue.OwnerId = ownerId;
        update revenue;
        return revenue;
    }

    private static List<Revenue__c> updateRevenues(List<Revenue__c> revenue, String ownerId) {
        List<Revenue__c> revToUpdate = new List<Revenue__c>();
        for (Revenue__c rev: revenue) {
            Revenue__c r = new Revenue__c();
            r.Id = rev.Id;
            r.OwnerId = ownerId;
            r.Group__c = rev.Group__c;
            revToUpdate.add(r);
        }
        System.debug(LoggingLevel.INFO, 'Updating ' + revToUpdate.size() + ' revenues with new ownerid');
        update revToUpdate;
        return revToUpdate;
    }
    
    static private String getRandomAccountName(String prefix) {
    	Integer rand = Math.round(Math.random()*1000000);
    	return prefix + rand.format(); 
    }
    
    private static Group createGroup(String name) {
        //create the group
        Group g = new Group();
        g.DeveloperName = name;
        g.Name = name;
        g.Type = 'Regular';
        insert g;
        return g;
    }

}