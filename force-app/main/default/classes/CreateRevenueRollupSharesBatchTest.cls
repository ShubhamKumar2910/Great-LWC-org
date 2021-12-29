@isTest
private class CreateRevenueRollupSharesBatchTest {
  static testMethod void TestRevenueRolupShares() {
    list<user> user = UtilityTesting.CreateUsers(3);
    system.runas(user[0]){
    
     Account acct = UtilityTesting.CreateAccount();     
      
      Revenue_Rollup__c revRollup = new Revenue_Rollup__c();
      revRollup.region__c = 'MSP';
      revRollup.account__c = acct.id;
      
      insert revRollup;
      
     list<AccountTeamMember> acctTeamList = new  list<AccountTeamMember>();
      
      AccountTeamMember acctTeamMember = new AccountTeamMember();
      acctTeamMember.accountid = acct.id;
      acctTeamMember.userid = user[1].id;
      acctTeamMember.TeamMemberRole = 'Account Manager';
      acctTeamList.add(acctTeamMember);
      
      acctTeamMember = new AccountTeamMember();
      acctTeamMember.accountid = acct.id;
      acctTeamMember.userId = user[2].id;
      acctTeamMember.TeamMemberRole = 'Account Manager';
      acctTeamList.add(acctTeamMember);
      
      insert acctTeamList;
      
      Test.starttest();
        
      Database.executeBatch(new CreateRevenueRollupSharesBatch(), 200);
   
      Test.stopTest();     
    
    
    }
  }
  
  
 
    @isTest static void testSchedule(){

    String sched_exp = '0 0 1 1 4 ?';

    Test.startTest();

    String jobId = system.schedule('Create RevenueRollup Share Test', sched_exp, new CreateRevenueRollupSharesBatchScheduler());

    CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
   
    System.assertEquals(sched_exp,ct.CronExpression);

       Test.stopTest();
   }
}