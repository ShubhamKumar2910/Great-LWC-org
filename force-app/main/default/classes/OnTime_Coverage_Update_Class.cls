global class OnTime_Coverage_Update_Class implements Database.Batchable<sObject>,Database.Stateful {
    
    global final ID[] AccntID;
    global final String[] errorMessage;
    
    
    global OnTime_Coverage_Update_Class(){
        
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        string query = 'SELECT Account__c, Account__r.ParentId, Team_Member__c,Team_Role__c,Sales_Team_for_Coverage__c FROM Coverage_Team_Member__c WHERE End_Date__c = null AND Team_Member__r.IsActive = TRUE AND Sales_Team_For_Coverage__r.Is_Dummy__c = FALSE';
        
        return Database.getQueryLocator(query);
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<sObject>scope){
        
        Map<string,string> cvgMemMap = new Map<string,string>();
        Map<ID,List<ID>> cvgMap = new Map<ID,List<ID>>();
        List<AccountTeamMember> accountTeamMemberToInsert = new List<AccountTeamMember>();
        List<AccountShare> actSharestoInsert = new List<AccountShare>();
        Map<ID,List<Coverage_Team_Member__c>> cvgMapforRevenue = new Map<ID,List<Coverage_Team_Member__c>>();
        Map<ID,List<Coverage_Team_Member__c>> cvgMapforRevenueKPI = new Map<ID,List<Coverage_Team_Member__c>>();
        Set<ID> cvgUser = new Set<ID>();
        Set<ID> cvgSalesTeam = new Set<ID>();
        Map<ID,string> cvgUserMap = new Map<ID,string>();
        Map<ID,string> cvgSalesCodeMap = new Map<ID,string>();
        List<User> cvgUsers = new List<User>();
        List<Sales_Team_for_Coverage__c> salescvg = new List<Sales_Team_for_Coverage__c>(); 
        
        List<Coverage_Team_Member__c> cvgMem = (List<Coverage_Team_Member__c>)scope;
        
        boolean matchFound = false;
        
        for(Coverage_Team_Member__c cvgMember : cvgMem){
            List<Id> userList = cvgMap.get(cvgMember.Account__c) != null ? cvgMap.get(cvgMember.Account__c) : new List<Id>();
            userList.add(cvgMember.Team_Member__c);
            cvgMap.put(cvgMember.Account__c,userList);
            
            cvgMemMap.put(string.valueOf(cvgMember.Account__c) + string.valueOf(cvgMember.Team_Member__c),string.valueOf(cvgMember.Account__c) +'#'+ string.valueOf(cvgMember.Team_Member__c) + '#'+string.valueOf(cvgMember.Team_Role__c));
            
            //Revenue Rollup
            List<Coverage_Team_Member__c> covTeamMemberList = cvgMapforRevenue.get(cvgMember.Account__c) != null ? cvgMapforRevenue.get(cvgMember.Account__c) : new List<Coverage_Team_Member__c>();
            covTeamMemberList.add(cvgMember);
            cvgMapforRevenue.put(cvgMember.Account__c,covTeamMemberList);
            
            //Revenue KPI
            String parentAccountId = cvgMember.Account__r.ParentId;
            if(String.isNotEmpty(parentAccountId)){
                List<Coverage_Team_Member__c> covTeamMemberListForRevenueKPI = cvgMapforRevenueKPI.get(parentAccountId) != null ? cvgMapforRevenueKPI.get(parentAccountId) : new List<Coverage_Team_Member__c>();
            	covTeamMemberListForRevenueKPI.add(cvgMember);
            	cvgMapforRevenueKPI.put(parentAccountId,covTeamMemberListForRevenueKPI);
            }
            
            cvgUser.add(cvgMember.Team_Member__c);
            
            cvgSalesTeam.add(cvgMember.Sales_Team_for_Coverage__c);
        }
        
        //logic for updating display name and sales code-Code Start
        
        /*cvgUsers =    [SELECT Id,Login_id__c,Name FROM User WHERE Id IN : cvgUser];       
        salescvg  = [SELECT Id,Name,Coverage_ID__c FROM Sales_Team_for_Coverage__c WHERE Id IN : cvgSalesTeam];
        
        for(User cvgUsr :  cvgUsers){
            cvgUserMap.put(cvgUsr.Id, cvgUsr.Name); 
        } 
        
        for(Sales_Team_for_Coverage__c cvgSalesCode :  salescvg){
            cvgSalesCodeMap.put(cvgSalesCode.Id, cvgSalesCode.Name); 
        } 
        
        for(Coverage_Team_Member__c cvgMember : cvgMem){
            if(cvgUserMap.containsKey(cvgMember.Team_Member__c)){
                cvgMember.Display_Name__c = cvgUserMap.get(cvgMember.Team_Member__c);
            }
            if(cvgSalesCodeMap.containsKey(cvgMember.Sales_Team_for_Coverage__c)){
                cvgMember.Sales_Team_Name__c = cvgSalesCodeMap.get(cvgMember.Sales_Team_for_Coverage__c);
            }
        } 
        try{
            UPDATE cvgMem;
        }
        catch(exception ex){
            cvgMem[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()); 
        }*/
        //logic for updating display name and sales code-Code End
        
        //Account Team Member and Account Share
        Map<String,String> acctTMMap = new Map<String,String>();
        Map<String,String> accountShareDetailsMap = new Map<String,String>();
        
        Set<Id> userIdSet = new Set<Id>();
        for(Id accountId : cvgMap.keySet()){
            userIdSet.addAll(cvgMap.get(accountId));   
        }
        
        List<AccountTeamMember> acntMemb = [SELECT AccountId,UserId FROM AccountTeamMember WHERE AccountId IN :cvgMap.keySet() AND UserId IN : userIdSet];
        
        if(acntMemb != null && acntMemb.size() > 0){
            for(AccountTeamMember acctTMObj : acntMemb){
                String accountUserKey = String.valueOf(acctTMObj.AccountId) + String.valueOf(acctTMObj.UserId);
                acctTMMap.put(accountUserKey, accountUserKey);
            }
        }
        
        List<AccountShare> actShare = [SELECT AccountId,UserorGroupId FROM AccountShare WHERE UserorGroupId in (SELECT Id from User) AND AccountId IN :cvgMap.keySet() AND UserorGroupId IN : userIdSet];
        if(actShare != null && actShare.size() > 0){
            for(AccountShare acctShareObj : actShare){
                String accountUserKey = String.valueOf(acctShareObj.AccountId) + String.valueOf(acctShareObj.UserOrGroupId);
                accountShareDetailsMap.put(accountUserKey, accountUserKey);
            }
        }
        
        // Account Team Member Share
        for(string keystring : cvgMemMap.keySet()){
            if(!acctTMMap.containsKey(keystring)){
                string [] arrcvgValues = cvgMemMap.get(keystring).split('#'); 
                AccountTeamMember act = new AccountTeamMember();
                act.accountid = string.valueOf(arrcvgValues[0]);
                act.userid = string.valueOf(arrcvgValues[1]);
                accountTeamMemberToInsert.add(act); 
            }
       }
        
        
        //Account Share
        for(string keystring : cvgMemMap.keySet()){
            if(!accountShareDetailsMap.containsKey(keystring)){
                string [] arrcvgValues = cvgMemMap.get(keystring).split('#'); 
                AccountShare acctShare = new AccountShare();
                acctShare.AccountId = string.valueOf(arrcvgValues[0]);
                acctShare.UserOrGroupId = string.valueOf(arrcvgValues[1]);
                acctShare.AccountAccessLevel = 'Edit';
                acctShare.ContactAccessLevel = 'Edit';
                acctShare.OpportunityAccessLevel = 'None';
                acctShare.CaseAccessLevel = 'None';
                actSharestoInsert.add(acctShare);
            }  
            
        }
        
        
        //Revenue Roll up Share
        List<Revenue_Rollup__c > RevenueRollupList = [Select id,name,Region__c,ownerid,account__c,RM__c from Revenue_Rollup__c where RM__c in : cvgMap.keySet()];
        List<Revenue_Rollup__share> reverollupshareList = new List<Revenue_Rollup__share>();
        
        for(Revenue_Rollup__c revrollup : RevenueRollupList){
            
            if(cvgMapforRevenue.containsKey(revrollup.RM__c)){
                
                List<Coverage_Team_Member__c> covTeamMemberList = cvgMapforRevenue.get(revrollup.RM__c);
                
                for(Coverage_Team_Member__c covTeamMember : covTeamMemberList){
                    if(revrollup.ownerid != covTeamMember.Team_Member__c)
                    {
                        Revenue_Rollup__share share = new Revenue_Rollup__share();
                        share.parentId = revrollup.id;
                        share.userorgroupid = covTeamMember.Team_Member__c;
                        share.accesslevel = 'Read';
                        reverollupshareList.add(share);                
                	}
                }
           }
        }
        
        //Revenue KPI Share
        List<Revenue_KPI__share> revKPIshareList = new List<Revenue_KPI__share>();
        if(cvgMapforRevenueKPI.size() > 0){
            List<Revenue_KPI__c> revenueKPIList = [SELECT Id, OwnerId, RG__c 
                              				   		FROM Revenue_KPI__c
                              				   		WHERE RG__c IN :cvgMapforRevenueKPI.keySet()];
            
            for(Revenue_KPI__c revenueKPI : revenueKPIList){
            
            if(cvgMapforRevenueKPI.containsKey(revenueKPI.RG__c)){
                
                List<Coverage_Team_Member__c> covTeamMemberList = cvgMapforRevenueKPI.get(revenueKPI.RG__c);
                
                for(Coverage_Team_Member__c covTeamMember : covTeamMemberList){
                    if(revenueKPI.ownerId != covTeamMember.Team_Member__c)
                    {
                        Revenue_KPI__share revenueKPIShare = new Revenue_KPI__share();
                        revenueKPIShare.ParentId = revenueKPI.Id;
                        revenueKPIShare.UserOrGroupId = covTeamMember.Team_Member__c;
                        revenueKPIShare.AccessLevel = 'Read';
                        revKPIshareList.add(revenueKPIShare);                
                	}
                }
           }
        }
        }
        
        
        
        if(reverollupshareList.size()>0){
            try{
                insert reverollupshareList;
            }
            
            catch(exception ex){
                errorMessage.add(ex.getMessage());
                cvgMem[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()); 
            }
        }
        
        if(revKPIshareList.size()>0){
            try{
                insert revKPIshareList;
            }
            
            catch(exception ex){
                errorMessage.add(ex.getMessage());
                cvgMem[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()); 
            }
        }
        
        if (!accountTeamMemberToInsert.isEmpty()){
            try{
                insert accountTeamMemberToInsert;
            }
            catch(exception ex){
                errorMessage.add(ex.getMessage());
                cvgMem[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()); 
            }
        }
        
        if (!actSharestoInsert.isEmpty()){
            try{
                insert actSharestoInsert;
            }
            catch(exception ex){
                errorMessage.add(ex.getMessage());
                cvgMem[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()); 
            }
        }     
    }
    
    global void finish(Database.BatchableContext BC){
       system.debug('errorMessage :'+ errorMessage);
    }
}