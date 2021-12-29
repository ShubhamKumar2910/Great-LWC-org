global class UpdateCoverageRelatedEntitiesBatch implements Database.Batchable<sObject>{
    
     /*
     * This class will identify split sales codes.
     * If new user added to split sales code then we have to add AccountTeamMember, AccountShare, Revenue_Rollup__share, Revenue_KPI__Share
     * for active coverages of that user's split sales code
     */
    
    public Set<Id> salesTeamForCoverageIdSet;
    
    global UpdateCoverageRelatedEntitiesBatch(Set<Id> salesCodeIdSet){
        salesTeamForCoverageIdSet = salesCodeIdSet;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, UniqueId__c, Account__c, Sales_Team_for_Coverage__c, Account__r.ParentId FROM Coverage_Team_Member__c ' 
            + 'WHERE Sales_Team_for_Coverage__r.Active__c = TRUE '
            + 'AND Is_Deleted__c = FALSE AND Recordtype.DeveloperName = \'Active_Coverage\' AND Sales_Team_for_Coverage__r.Is_Dummy__c = FALSE '
            + 'AND Sales_Team_for_Coverage__c IN :salesTeamForCoverageIdSet';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        Map<Id,Set<Id>> salesCodeAccountMap = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> salesCodeUserMap = new Map<Id,Set<Id>>();
        Map<String,String> userAccountMap = new Map<String,String>();
        Map<String,String> userRGAccountMap = new Map<String,String>();
        Set<Id> completeAccountIdSet = new Set<Id>();
        Map<Id,Id> accountAndParentAccountMap = new Map<id,Id>();
        Set<Id> completeUserIdSet = new Set<Id>();
        
        //Coverage_Team_Member__c List
        List<Coverage_Team_Member__c> covTeamMemberList = (List<Coverage_Team_Member__c>)scope;
        
        for(Coverage_Team_Member__c covTeamMemberObj : covTeamMemberList){
            Id salesCodeId = covTeamMemberObj.Sales_Team_for_Coverage__c;
            Set<Id> accountIdSet = salesCodeAccountMap.containsKey(salesCodeId) ? salesCodeAccountMap.get(salesCodeId) : new Set<Id>();
            accountIdSet.add(covTeamMemberObj.Account__c);
            salesCodeAccountMap.put(salesCodeId, accountIdSet);
            
            completeAccountIdSet.add(covTeamMemberObj.Account__c);
            accountAndParentAccountMap.put(covTeamMemberObj.Account__c, covTeamMemberObj.Account__r.ParentId);
        }
        
        System.debug('salesCodeAccountMap:'+salesCodeAccountMap);
        
        //Fetch the users for each salescode
        salesCodeUserMap = CoverageRequestUtility.fetchSalesCodeAllUserDetails(salesCodeAccountMap.keySet(), TRUE);
        
        for(Id SalesCodeId : salesCodeUserMap.keySet()){
            completeUserIdSet.addAll(salesCodeUserMap.get(SalesCodeId));
        }
        
        //Fetch the userAccountMap details
        userAccountMap = getUserAccountDetails(salesCodeAccountMap, salesCodeUserMap);
        
        //Fetch the userRGAccountMap details
        userRGAccountMap = getUserRGAccountDetails(salesCodeAccountMap, salesCodeUserMap, accountAndParentAccountMap);
        
        List<AccountTeamMember> accountTeamMemberList = getAccountTeamMemberList(userAccountMap, completeUserIdSet, completeAccountIdSet);
        List<AccountShare> accountShareList = getAccountShareList(userAccountMap, completeUserIdSet, completeAccountIdSet);
        List<Revenue_Rollup__Share> revenueRollupShareList = getRevenueRollupShareList(userAccountMap, completeUserIdSet, completeAccountIdSet);
        List<Revenue_KPI__Share> revenueKPIShareList = getRevenueKPIShareList(userRGAccountMap, completeUserIdSet, accountAndParentAccountMap.values());
        
        executeDML(accountTeamMemberList);
        executeDML(accountShareList);
        executeDML(revenueRollupShareList);
        executeDML(revenueKPIShareList);
        
    }
    
    global void finish(Database.BatchableContext bc){
    	String toEmailAddress = null;
        String emailBody = null;
        String subject = null;
        
        AsyncApexJob apexJob = [SELECT Id, JobType, Status, JobItemsProcessed, TotalJobItems, 
                                NumberOfErrors, CompletedDate, MethodName, ExtendedStatus
                                FROM AsyncApexJob 
                                WHERE JobType = 'BatchApex' AND Id = :bc.getJobId()
                               ];
        //In case of success update Process_Coverage_Related_Entities__c
        if(apexJob != null && apexJob.NumberOfErrors == 0){
        	updateSalesTeamForCoverageDetails();
        }
        
        //Again fetch the job details to check for errors 
        apexJob = [SELECT Id, JobType, Status, JobItemsProcessed, TotalJobItems, 
                   NumberOfErrors, CompletedDate, MethodName, ExtendedStatus
                   FROM AsyncApexJob 
                   WHERE JobType = 'BatchApex' AND Id = :bc.getJobId()
                  ];
        
        //Send Mail only in case of errors
        if(apexJob != null && apexJob.NumberOfErrors > 0){
            NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
        	toEmailAddress = nomuraSettings.To_Email_Addr_NomuraEmpReplacement_Batch__c;
            
            if(String.isNotEmpty(toEmailAddress)){
                String[] toEmailArray = toEmailAddress.split(';');
                subject = 'SF - Update Coverage Related Entities for Split Codes Batch Job Status';
                emailBody = getEmailBody(apexJob);
                Boolean isSuccess = MailUtility.sendMail(toEmailArray, subject, emailBody);
                if(!isSuccess){
                    System.debug('Error Occurred while sending mail');
                }
            }
        }
        
        
        
    }
    
    public Map<String,String> getUserAccountDetails( Map<Id,Set<Id>> salesCodeAccountMap, Map<Id,Set<Id>> salesCodeUserMap){
        Map<String,String> userAccountMap = new Map<String,String>();
        
        //Form the userAccountMap
        for(Id salesCodeId : salesCodeAccountMap.keySet()){
            Set<Id> accountIdSet = salesCodeAccountMap.get(salesCodeId);
            if(salesCodeUserMap.containsKey(salesCodeId)){
                Set<Id> userIdSet = salesCodeUserMap.get(salesCodeId);
                if(userIdSet != null && userIdSet.size() > 0){
                    for(Id userId : userIdSet){
                        for(Id accountId : accountIdSet){
                            String userAccountKey = userId + '#' + accountId;
                            userAccountMap.put(userAccountKey, userAccountKey);
                        }
                    }
                }
            }
        }
        
        return userAccountMap;
    }
    
    public Map<String,String> getUserRGAccountDetails( Map<Id,Set<Id>> salesCodeAccountMap, 
                                                       Map<Id,Set<Id>> salesCodeUserMap,
                                                       Map<Id,Id> accountAndParentAccountMap){
        Map<String,String> userRGAccountMap = new Map<String,String>();
        
        //Form the userRGAccountMap
        for(Id salesCodeId : salesCodeAccountMap.keySet()){
            Set<Id> accountIdSet = salesCodeAccountMap.get(salesCodeId);
            if(salesCodeUserMap.containsKey(salesCodeId)){
                Set<Id> userIdSet = salesCodeUserMap.get(salesCodeId);
                if(userIdSet != null && userIdSet.size() > 0){
                    for(Id userId : userIdSet){
                        for(Id accountId : accountIdSet){
                            String parentAccountId = accountAndParentAccountMap.get(accountId);
                            if(String.isNotEmpty(parentAccountId)){
                            	String userRGAccountKey = userId + '#' + parentAccountId;
                                if(!userRGAccountMap.containsKey(userRGAccountKey)){
                                    userRGAccountMap.put(userRGAccountKey, userRGAccountKey);
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return userRGAccountMap;
    }
    
    public List<AccountTeamMember> getAccountTeamMemberList(Map<String,String> userAccountMap, Set<Id> userIdSet, Set<Id> accountIdSet){
        List<AccountTeamMember> accountTeamMemberList = new List<AccountTeamMember>();
        Map<String,String> acctTMMap = new Map<String,String>();
        
        if(userIdSet != null && userIdSet.size() > 0 &&
           accountIdSet != null && accountIdSet.size() > 0){
        
               List<AccountTeamMember> acctTMList = [SELECT AccountId, UserId FROM AccountTeamMember
                                                     WHERE AccountId IN :accountIdSet AND UserId IN :userIdSet];
               if(acctTMList != null && acctTMList.size() > 0){
                   for(AccountTeamMember acctTMObj : acctTMList){
                       String userAccountKey = acctTMObj.UserId + '#' + acctTMObj.AccountId;
                       acctTMMap.put(userAccountKey, userAccountKey);
                   }
               }
        }
        
        for(String userAccountKey : userAccountMap.keySet()){
            if(!acctTMMap.containsKey(userAccountKey)){
                Integer index = userAccountKey.indexOf('#');
                String userId = userAccountKey.substring(0, index);
                String accountId = userAccountKey.substring(index + 1);
                
                 accountTeamMemberList.add(CoverageRequestUtility.getAccountTeamMember(accountId, userId));
            }
        }
        
        return accountTeamMemberList;
    }
    
    public List<AccountShare> getAccountShareList(Map<String,String> userAccountMap, Set<Id> userIdSet, Set<Id> accountIdSet){
        List<AccountShare> accountShareList = new List<AccountShare>();
        Map<String,String> accountShareDetailsMap = new Map<String,String>();
        
        if(userIdSet != null && userIdSet.size() > 0 &&
           accountIdSet != null && accountIdSet.size() > 0){
        
               List<AccountShare> acctShareList = [SELECT AccountId, UserOrGroupId FROM AccountShare
                                                   WHERE AccountId IN :accountIdSet AND UserOrGroupId IN :userIdSet];
               if(acctShareList != null && acctShareList.size() > 0){
                   for(AccountShare acctShareObj : acctShareList){
                       String userAccountKey = acctShareObj.UserOrGroupId + '#' + acctShareObj.AccountId;
                       accountShareDetailsMap.put(userAccountKey, userAccountKey);
                   }
               }
        }
        
        for(String userAccountKey : userAccountMap.keySet()){
            if(!accountShareDetailsMap.containsKey(userAccountKey)){
                Integer index = userAccountKey.indexOf('#');
                String userId = userAccountKey.substring(0, index);
                String accountId = userAccountKey.substring(index + 1);
                
                accountShareList.add(CoverageRequestUtility.getAccountShare(accountId, userId, 'Edit', 'Edit', 'None', 'None'));
            }
        }
        
        return accountShareList;
    }
    
    public List<Revenue_Rollup__Share> getRevenueRollupShareList(Map<String,String> userAccountMap, Set<Id> userIdSet, Set<Id> accountIdSet){
        List<Revenue_Rollup__Share> revenueRollupShareList = new List<Revenue_Rollup__Share>();
        List<Revenue_Rollup__c> revenueRollupList = new List<Revenue_Rollup__c>();
        Map<Id,Map<Id,Id>> accountAndRevenueRollUpIdMap = new Map<Id,Map<Id,Id>>();  
        Map<String,String> revRollupShareDetailsMap = new Map<String,String>();
        
        //Fetch details for Revenue_Rollup__c
        if(accountIdSet != null && accountIdSet.size() > 0){
            revenueRollupList = [SELECT Id, OwnerId, RM__c FROM Revenue_Rollup__c WHERE RM__c IN : accountIdSet];
            if(revenueRollupList != null && revenueRollupList.size() > 0){
                for(Revenue_Rollup__c revenueRollUpObj : revenueRollupList){
                    Map<Id,Id> revenueRollUpAndOwnerIdMap = accountAndRevenueRollUpIdMap.containsKey(revenueRollUpObj.RM__c) ? accountAndRevenueRollUpIdMap.get(revenueRollUpObj.RM__c) : new Map<Id,Id>();
                    revenueRollUpAndOwnerIdMap.put(revenueRollUpObj.Id, revenueRollUpObj.OwnerId);
                    
                	accountAndRevenueRollUpIdMap.put(revenueRollUpObj.RM__c, revenueRollUpAndOwnerIdMap); 
                    
                }
            }
        }
        
        if(userIdSet != null && userIdSet.size() > 0 &&
           accountAndRevenueRollUpIdMap.size() > 0){
           
           Set<Id> revenueRollUpIdSet = new Set<Id>();
           for(Id accountId : accountAndRevenueRollUpIdMap.keySet()){
           		revenueRollUpIdSet.addAll(accountAndRevenueRollUpIdMap.get(accountId).keySet());   
           }
           
           List<Revenue_Rollup__Share> revRollupShareList = [SELECT Id, ParentId, UserOrGroupId FROM Revenue_Rollup__Share
                                                             WHERE UserOrGroupId IN :userIdSet AND ParentId IN :revenueRollUpIdSet];
               
            if(revRollupShareList != null && revRollupShareList.size() > 0){
               for(Revenue_Rollup__Share revRollUpShareObj : revRollupShareList){
               	   String userAndRevenueRollupKey = revRollUpShareObj.UserOrGroupId + '#' + revRollUpShareObj.ParentId;     
                   revRollupShareDetailsMap.put(userAndRevenueRollupKey, userAndRevenueRollupKey);
               }
           }
               
        }
        
        for(String userAccountKey : userAccountMap.keySet()){
            Integer index = userAccountKey.indexOf('#');
            String userId = userAccountKey.substring(0, index);
            String accountId = userAccountKey.substring(index + 1);
            Map<Id,Id> revenueRollUpAndOwnerIdMap = null;
  			
            
            if(accountAndRevenueRollUpIdMap.containsKey(accountId)){
                revenueRollUpAndOwnerIdMap = accountAndRevenueRollUpIdMap.get(accountId);
            }
            
            if(revenueRollUpAndOwnerIdMap != null && revenueRollUpAndOwnerIdMap.size() > 0){
                for(Id revenueRollUpId : revenueRollUpAndOwnerIdMap.keySet()){
                    String actualKey = userId + '#' + revenueRollupId;
                    
                    if(!revRollupShareDetailsMap.containsKey(actualKey) && 
                       !userId.equalsIgnoreCase(revenueRollUpAndOwnerIdMap.get(revenueRollUpId)) //Not equal to Owner of Revenue_Rollup__c record
                      )
                    {
                          revenueRollupShareList.add(CoverageRequestUtility.getRevenueRollupShare(revenueRollupId, userId));
                    }
                    
                }
                
            }
            
            
        }
        
        return revenueRollupShareList;
    }
    
    public List<Revenue_KPI__Share> getRevenueKPIShareList(Map<String,String> userRGAccountMap, Set<Id> userIdSet, 
                                                           List<Id> parentAccountIdList){
        List<Revenue_KPI__Share> revenueKPIShareList = new List<Revenue_KPI__Share>();
        List<Revenue_KPI__c> revenueKPIList = new List<Revenue_KPI__c>();
        Map<Id,Map<Id,Id>> accountAndRevenueKPIIdMap = new Map<Id,Map<Id,Id>>();  
        Map<String,String> revKPIShareDetailsMap = new Map<String,String>();
		Map<Id,Set<Id>> accountRGUserMap = new Map<Id,Set<Id>>();
        
        //Fetch details for Revenue_KPI__c and Revenue_KPI__share
        if(parentAccountIdList != null && parentAccountIdList.size() > 0 &&
           userIdSet != null && userIdSet.size() > 0){
               
        	revenueKPIList = [SELECT Id, OwnerId, RG__c, 
                              (SELECT UserOrGroupId FROM Shares WHERE UserOrGroupId IN :userIdSet) 
                              FROM Revenue_KPI__c
                              WHERE RG__c IN :parentAccountIdList];
            if(revenueKPIList.size() > 0){
                for(Revenue_KPI__c revenueKPIObj : revenueKPIList) {
                    Map<Id,Id> revenueKPIAndOwnerIdMap = accountAndRevenueKPIIdMap.containsKey(revenueKPIObj.RG__c) ? accountAndRevenueKPIIdMap.get(revenueKPIObj.RG__c) : new Map<Id,Id>();
                    revenueKPIAndOwnerIdMap.put(revenueKPIObj.Id, revenueKPIObj.OwnerId);
                    
                	accountAndRevenueKPIIdMap.put(revenueKPIObj.RG__c, revenueKPIAndOwnerIdMap); 
                    
                    for(Revenue_KPI__share share : revenueKPIObj.Shares){
                        String userAndRevenueKPIKey = share.UserOrGroupId + '#' + revenueKPIObj.Id;  
                        revKPIShareDetailsMap.put(userAndRevenueKPIKey, userAndRevenueKPIKey);
                    }
                }  
            }   
        }
                                                               
        for(String userRGAccountKey : userRGAccountMap.keySet()){
            Integer index = userRGAccountKey.indexOf('#');
            String userId = userRGAccountKey.substring(0, index);
            String accountRGId = userRGAccountKey.substring(index + 1);
            Map<Id,Id> revenueKPIAndOwnerIdMap = null;
  			
            if(accountAndRevenueKPIIdMap.containsKey(accountRGId)){
                revenueKPIAndOwnerIdMap = accountAndRevenueKPIIdMap.get(accountRGId);
            }
            
			if(revenueKPIAndOwnerIdMap != null && revenueKPIAndOwnerIdMap.size() > 0){
                for(Id revenueKPIId : revenueKPIAndOwnerIdMap.keySet()){
                    String actualKey = userId + '#' + revenueKPIId;
                
                    if(!revKPIShareDetailsMap.containsKey(actualKey) && 
                       !userId.equalsIgnoreCase(revenueKPIAndOwnerIdMap.get(revenueKPIId)) //Not equal to Owner of Revenue_KPI__c record
                      )
                    {
                          revenueKPIShareList.add(CoverageRequestUtility.getRevenueKPIShare(revenueKPIId, userId));
                    }
                }
            }
            
            
        }
        
        return revenueKPIShareList;
    }
    
    public void executeDML(List<sObject> sObjectList){
        if(sObjectList != null && sObjectList.size() > 0){
        	insert sObjectList;
        }
    }
    
    public String getEmailBody(AsyncApexJob apexJob){
        String emailBody = null;
        String apexJobId = apexJob.Id;
        emailBody = '<p> The Batch Apex Job (' + apexJobId.substring(0,15) + ') processed '
                    + apexJob.TotalJobItems + ' batche(s) with ' + apexJob.NumberOfErrors + ' failure(s). </p>';
        emailBody = emailBody + '<p> Status Detail : </p><br>';
        emailBody = emailBody + '<p>' + apexJob.ExtendedStatus + '</p>';
        
        return emailBody;
    }
    
    public void updateSalesTeamForCoverageDetails(){
        if(salesTeamForCoverageIdSet != null && salesTeamForCoverageIdSet.size() > 0){
        	List<Sales_Team_for_Coverage__c> salesCodeList = [SELECT Id, Coverage_Id__c, Process_Coverage_Related_Entities__c
                                                          FROM Sales_Team_for_Coverage__c
                                                          WHERE Id IN :salesTeamForCoverageIdSet];
            if(salesCodeList != null && salesCodeList.size() > 0){
                for(Sales_Team_for_Coverage__c salesCodeObj : salesCodeList){
                    salesCodeObj.Process_Coverage_Related_Entities__c = FALSE;
                }
                update salesCodeList;
            }
        }
    }
}