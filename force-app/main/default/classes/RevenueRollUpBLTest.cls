@isTest
private class RevenueRollUpBLTest {
  static testMethod void TestRevenueRolupShares() {
    list<user> user = UtilityTesting.CreateUsers(3);
    system.runas(user[0]){
       Account acct = UtilityTesting.CreateAccount();     
             
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
      
      Revenue_Rollup__c revRollup = new Revenue_Rollup__c();
      revRollup.region__c = 'MSP';
      revRollup.RM__c = acct.id;
      
      insert revRollup;
      
      update revRollup;
      
      delete revRollup;
      
           
    
    
    }
  }
  
  
}