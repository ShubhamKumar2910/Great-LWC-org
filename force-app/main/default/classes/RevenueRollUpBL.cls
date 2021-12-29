Public without sharing class RevenueRollUpBL{    

   //Logic will create revenue rollup share records to give read to all the account team members asscoicated with revenue rollup account
   //Logic will create on insert of new revenue rollup record 
   
   Public static void CreateRevenueShareRecords(Map<Id, Revenue_Rollup__c> newRecords){
      Set<id> AccountSet = new Set<id>();
      Map<id,list<Revenue_Rollup__c>> AccountRevRollupMap = new Map<id,list<Revenue_Rollup__c>>();
      for(Revenue_Rollup__c revrollup : newRecords.values()){
          //if(revrollup.Region__c!=null && revrollup.Region__c!='' && revrollup.account__c!=null){
          if(revrollup.RM__c!=null){
              AccountSet.add(revrollup.RM__C);
              list<Revenue_Rollup__c> revRollList = AccountRevRollupMap.get(revrollup.RM__C)!=null? AccountRevRollupMap.get(revrollup.RM__C): new list<Revenue_Rollup__c>();
              revRollList.add(revrollup);
              AccountRevRollupMap.put(revrollup.RM__C,revRollList);
                            
          }
      }
      
      List<Revenue_Rollup__share> reverollupshareList = new List<Revenue_Rollup__share>();
      
      list<AccountTeamMember> accountTeamList = [select accountid,UserId from AccountTeamMember where accountid in : AccountSet and User.IsActive=true];
      
      for(accountteammember acctTeam : accountTeamList){
         
         if(AccountRevRollupMap.containskey(acctTeam.accountid)){
            
            for(Revenue_Rollup__c revrollup : AccountRevRollupMap.get(acctTeam.accountid)){
              
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
        try{
            insert reverollupshareList;            
        }
        catch(exception ex){
           newRecords.values()[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
        }
      }
   
   }
}