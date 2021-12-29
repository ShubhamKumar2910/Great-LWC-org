Public without sharing class RevenueBL{    

   Public static void CreateRevenueShareRecords(Map<Id, Revenue__c> oldRecords,List<Revenue__c> newRecords){
       
       List<Revenue__share> RevenueSharesToDelete = new List<Revenue__share>();
       List<Revenue__share> RevenueSharesToCreate = new List<Revenue__share>();
       Set<String> groupSet = new Set<String>();
       
       Set<string> revid = new Set<string>();
       Set<string> groupid = new set<string>();
       Map<String, String> salesIdToNameMap = new Map<String, String>();
       for(Revenue__c rev : newRecords){
         
          if(oldRecords==null){
          
            if(rev.group__c!=null && rev.group__c!='')
               groupSet.add(rev.group__c);
               
          }else if (oldRecords!=null && rev.group__c!= oldRecords.get(rev.id).group__c) {
          
             if(rev.group__c!=null && rev.group__c!='')
                groupSet.add(rev.group__c);
                
             if(oldRecords.get(rev.id).group__c!=null && oldRecords.get(rev.id).group__c!='')
                 groupSet.add(oldRecords.get(rev.id).group__c);
             
          }
           if (oldRecords!=null) {
               Revenue__c oldRev = oldRecords.get(rev.Id);
               if (rev.Salesperson__c != null && rev.Salesperson__c!='' && rev.Salesperson__c!= 'LEAVER' && oldRev != null) {
                   System.debug('Comparing old salesperson value to new Salesperson value');
                   if (oldRev.Salesperson__c != rev.Salesperson__c) {
                       System.debug('Salesperson name changed from '+ oldRev.Salesperson__c + ' to '+ rev.Salesperson__c + '. Adding to update map with Sales_Id value of '+ rev.Sales_Id__c);
                       salesIdToNameMap.put(rev.Sales_Id__c, rev.Salesperson__c);
                   }
               } 
           }
       
       }
       
       List<group> groupList = [select id,name,developername from group where name in : groupSet ];
       
       Map<string,group> groupMap = new Map<string,group>();
       
       for(group gp : groupList){
          groupMap.put(gp.name,gp);
       }
       
       
       for(Revenue__c rev : newRecords){
         
          if(oldRecords==null){
          
            if(rev.group__c!=null && rev.group__c!='' && groupMap.containskey(rev.group__c)){
                
                revenue__share revShare = new revenue__share();
                revShare.parentid = rev.id;
                revShare.userorgroupid = groupMap.get(rev.group__c).id;
                revShare.accesslevel = 'Read';
                RevenueSharesToCreate.add(revShare);            
            }
              
               
          }else if (oldRecords!=null && rev.group__c!= oldRecords.get(rev.id).group__c) {
          
             if(rev.group__c!=null && rev.group__c!='' && groupMap.containskey(rev.group__c)){
             
                revenue__share revShare = new revenue__share();
                revShare.parentid = rev.id;
                revShare.userorgroupid = groupMap.get(rev.group__c).id;
                revShare.accesslevel = 'Read';
                RevenueSharesToCreate.add(revShare); 
             
             }
               
                
             if(oldRecords.get(rev.id).group__c!=null && oldRecords.get(rev.id).group__c!=''){
                revid.add(rev.id);
                if(groupmap.containskey(oldRecords.get(rev.id).group__c))
                groupid.add(groupMap.get(oldRecords.get(rev.id).group__c).id);
                 
              }
             
          }
       
       }
       
       if(revid.size()>0 && groupid.size()>0){
           RevenueSharesToDelete = [select id,parentid,userorgroupid,accesslevel from revenue__share where parentid in :revid and userorgroupid in :groupid and accesslevel = 'Read'];
           
           if(RevenueSharesToDelete.size()>0)
             delete RevenueSharesToDelete;
       }
       
       if(RevenueSharesToCreate.size()>0){
          system.debug('+++++'+RevenueSharesToCreate);
          insert RevenueSharesToCreate;
       }
       
       if (!salesIdToNameMap.isEmpty()) {
           List<Analytic_Revenue_Persona_Link__c> updateList = new List<Analytic_Revenue_Persona_Link__c>();
           for (List<Analytic_Revenue_Persona_Link__c> personas : [SELECT Id, SMS_Sales_Id__c, SMS_Salesperson__c,Is_Active__c FROM Analytic_Revenue_Persona_Link__c where Is_Active__c=true and SMS_Sales_Id__c in: salesIdToNameMap.keySet()]) {
               System.debug('Number of active personas returned = ' + personas.size());
               for (Analytic_Revenue_Persona_Link__c persona: personas) {
                   persona.SMS_Salesperson__c = salesIdToNameMap.get(persona.SMS_Sales_Id__c);
                   updateList.add(persona);
               }
           }
           if (updateList.size()>0) {
               System.debug('Updating Analytic Revenue Persona Links');
               update updateList;
           } else {
               System.debug('No active personas found to update');
           }
       }
       
   
   }
   
}