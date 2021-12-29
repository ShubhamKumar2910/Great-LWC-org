global class OneTime_Coverage_Delete implements Database.Batchable<sObject> {
    
    global final ID[] AccntID;
    
    
    global OneTime_Coverage_Delete(){
        
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        string query = 'SELECT Account__c, Team_Member__c,Team_Role__c FROM Coverage_Team_Member__c WHERE End_Date__c <> null and Is_Deleted__c = true';      
        
        return Database.getQueryLocator(query);
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<sObject>scope){
        
        Map<string,string> cvgMemMap = new Map<string,string>();
        Map<string,string> acntTmMem = new Map<string,string>();
        Set<ID> revenueRollup = new Set<ID>();
        Set<ID> cvgAccount = new Set<ID>();
        Set<ID> cvgTeamMember = new Set<ID>();
        Set<ID> cvgAccountFinal = new Set<ID>();
        Set<ID> cvgTeamMemberFinal = new Set<ID>();
        
        List<Coverage_Team_Member__c> cvgMemDeleted = (List<Coverage_Team_Member__c>) scope;
        
        for(Coverage_Team_Member__c cvgMemDelete : cvgMemDeleted){
            string cvgKey = string.valueOf(cvgMemDelete.Account__c)+'#'+string.valueOf(cvgMemDelete.Team_Member__c);
            cvgMemMap.put(cvgKey, cvgKey);
            cvgAccount.add(cvgMemDelete.Account__c);
            cvgTeamMember.add(cvgMemDelete.Team_Member__c);
        }
        
        List<AccountTeamMember> acntTmMembers = [SELECT Id,AccountId,UserId FROM AccountTeamMember 
                          WHERE AccountId IN : cvgAccount AND UserId IN : cvgTeamMember];
        for(AccountTeamMember acntTmMembr : acntTmMembers){
            string actTmKey = string.valueOf(acntTmMembr.AccountId)+'#'+string.valueOf(acntTmMembr.UserId);
            acntTmMem.put(actTmKey, actTmKey);
        }
        
        for(string keyValue : cvgMemMap.keySet()){
            if(!acntTmMem.containsKey(keyValue)){
                cvgAccountFinal.add(keyValue.split('#')[0]);
                cvgTeamMemberFinal.add(keyValue.split('#')[1]);
            }
        }
        
        List<Revenue_Rollup__c> revenueRollups = [SELECT Id,RM__c from Revenue_Rollup__c WHERE RM__c IN : cvgAccountFinal];
        
        for(Revenue_Rollup__c revenueRollupit : revenueRollups){
            revenueRollup.add(revenueRollupit.id);               
        }
        
          List<Revenue_Rollup__Share> revenueRollupshares = [SELECT Id,ParentId,UserOrGroupId FROM Revenue_Rollup__Share WHERE ParentId IN :  revenueRollup AND UserOrGroupId IN : cvgTeamMemberFinal
                                                            AND RowCause = 'Manual']; 
        
       if(revenueRollupshares.size() > 0){
                     try {
                         delete revenueRollupshares;
                     }
        catch(exception ex){
                revenueRollupshares[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()); 
            }
                     }
    
    }
                     
                     

    
    global void finish(Database.BatchableContext BC){
        // Logic to be Executed at finish
    }
}