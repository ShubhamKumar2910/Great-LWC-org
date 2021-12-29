global class CreateRevenueRollupSharesBatch implements Database.Batchable<sObject> {
    
   //Logic will create revenue rollup share records  which will give access to revenue rollup record. revenue rollup share records are created for all the account team members recently modified and whose account have revenue rollup reocrds asscoicated.
     
   String query;        
    
    global CreateRevenueRollupSharesBatch() {

        query= 'select id,accountid,TeamMemberRole,UserId,user.region__c  from AccountTeamMember where lastmodifieddate>=yesterday';
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
       Set<Id> accountSet = new Set<Id>();
       Set<String> RegionSet = new Set<String>();
       Map<id,list<AccountTeamMember>> accountTeamMemberMap = new Map<id,list<AccountTeamMember>>();
       
       List<AccountTeamMember> acctTeamMembers = (List<AccountTeamMember>) scope;
       
       for(AccountTeamMember acctTeam : acctTeamMembers){
           accountSet.add(acctTeam.accountid);     
           //RegionSet.add(acctTeam.user.region__c); 
           
           list<AccountTeamMember> actTeamList = accountTeamMemberMap.get(acctTeam.accountid)!=null? accountTeamMemberMap.get(acctTeam.accountid): new list<AccountTeamMember>();
           actTeamList.add(acctTeam);
           accountTeamMemberMap.put(acctTeam.accountid,actTeamList);
           
       }
       
      // List<Revenue_Rollup__c > RevenueRollupList = [Select id,name,Region__c,ownerid,account__c from Revenue_Rollup__c where account__c in : accountset and region__c in : RegionSet];
         List<Revenue_Rollup__c > RevenueRollupList = [Select id,name,Region__c,ownerid,account__c from Revenue_Rollup__c where account__c in : accountset];
         List<Revenue_Rollup__share> reverollupshareList = new List<Revenue_Rollup__share>();
         
       For(Revenue_Rollup__c revrollup : RevenueRollupList){
       
         if(accountTeamMemberMap.containskey(revrollup.account__c)){
         
           for(AccountTeamMember acctTeam : accountTeamMemberMap.get(revrollup.account__c)){
         
              //if(acctTeam.user.region__c == revrollup.region__c && revrollup.ownerid!=acctTeam.userid){
              if(revrollup.ownerid!=acctTeam.userid){
              
                Revenue_Rollup__share share = new Revenue_Rollup__share();
                share.parentid = revrollup.id;
                share.userorgroupid = acctTeam.UserId;
                share.accesslevel = 'Read';
                reverollupshareList.add(share);
              }
           }
          
         }
       
       }
       
       if(reverollupshareList.size()>0){
         insert reverollupshareList;
        
       }
           
    }
    
    global void finish(Database.BatchableContext BC) {
            
    
    }
    
}