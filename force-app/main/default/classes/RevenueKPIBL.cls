public without sharing class RevenueKPIBL {
    //Logic will create revenue rollup share records to give read to all the account team members asscoicated with revenue rollup account
   //Logic will create on insert of new revenue rollup record 
   private final static String INSERT_SHARE = 'INSERT';
   private final static String DELETE_SHARE = 'DELETE';
   public static void createRevenueShareRecords(List<Revenue_KPI__c> newRecords){
   		Set<id> accountSet = new Set<id>();
        Set<Id> revKpiIdSet = new Set<ID>();
      	for(Revenue_KPI__c revKpi : newRecords){
			if(revKpi.RG__c!=null){
            	accountSet.add(revKpi.RG__C);
                revKpiIdSet.add(revKpi.Id);
	        }
    	}
        //get all the shares associated with these kpis.  only create those that don't exist
        //on new revenues, these might not exist but will be needed for cleaning permissions that might be missed
        Map<Id, Set<ID>> kpiIdToUserShareId = new Map<Id, Set<Id>>();
        for (List<Revenue_KPI__c> kpiList : [select Id,(select UserOrGroupID from Shares) from Revenue_KPI__c where id in: revKpiIdSet]) {
            for (Revenue_KPI__c kpi: kpiList) {
                Set<Id> userShareIds = null != kpiIdToUserShareId.get(kpi.Id) ?
                    	kpiIdToUserShareId.get(kpi.Id) : new Set<ID>();
                for (Revenue_KPI__share share: kpi.Shares) { 
                    userShareIds.add(share.UserOrGroupID);
               	}
				kpiIdToUserShareId.put(kpi.Id, userShareIds);               
            }
        }
      	List<Revenue_KPI__share> revKpiShareList = new List<Revenue_KPI__share>();
      	Map<Id, Set<Id>> rgToUserIdMap= getRgIdToUserIdMapFromRGs(accountSet);
      	//for each entry in accountRevKPIMap
      	for (Revenue_KPI__c revKpi: newRecords) {
			//use the RG id on the kpi to grab the list of users the record needs to be shared to
      		Set<Id> userSet = rgToUserIdMap.get(revKpi.RG__c);
			//for each member of the list of rev kpis, create a share for each member of the list if 
			//its not the record owner or doesn't already exist in the share table.
			for (Id userId: userSet) {
				if (userId!=revKpi.ownerId) {
                    Set<Id> existingShares = kpiIdToUserShareId.get(revKpi.id);
                    if (!existingShares.contains(userId)) {
                        addShareToList(revKpiShareList, revKpi.id,userId, null);
                    }
				}
			}
      	}
      	executeKPIShareDML(revKpiShareList,newRecords, INSERT_SHARE);
   }
   
   //will add shares to revenuekpi shares for a new set of coverage
   public static void createRevenueSharesFromNewCoverage(List<Coverage_Team_Member__c> newCoverage, Map<Id,Set<Id>> salesCodeUserMap) {
   		//for each coverage, get the RG id.  For the RG, get all the rms
   		System.debug('In createRevenueSharesFromNewCoverage. New coverage members = ' + newCoverage);
       
		Map<Id, Set<Id>> rgToUserIdCoverageMap = new Map<Id, Set<Id>>();
   		List<Revenue_KPI__share> revKpiShareList = new List<Revenue_KPI__share>();
		//first generate the coverage rm to rg map
       	Map<Id, Id> rmToRgMap = getRmToRgMap(newCoverage);
       
   		for (Coverage_Team_Member__c ctm: newCoverage) {
            Id coverageRgId = rmToRgMap.get(ctm.Account__c);
   			Set<Id> userSet = rgToUserIdCoverageMap.get(coverageRgId)!=null ? rgToUserIdCoverageMap.get(coverageRgId) : new Set<Id>();
   			/* Changes for JIRA SALES-1490 : Start */
            if(salesCodeUserMap.containsKey(ctm.Sales_Team_for_Coverage__c)){
                Set<Id> userIdSet = salesCodeUserMap.get(ctm.Sales_Team_for_Coverage__c);
                if(userIdSet != null && userIdSet.size() > 0){
                	userSet.addAll(userIdSet);
                }
            }
            if(userSet.size() > 0){
                rgToUserIdCoverageMap.put(coverageRgId,userSet);
            }
   			/* Changes for JIRA SALES-1490 : End */
        }
		//get the set of existing shares for the rgs
		for (List<Revenue_KPI__c> kpiList : [select Id, RG__c,(select UserOrGroupID from Shares) from Revenue_KPI__c where RG__c in: rgToUserIdCoverageMap.keySet()]) {
			for (Revenue_KPI__c kpi: kpiList) {
				Set<id> users = rgToUserIdCoverageMap.get(kpi.RG__c).clone();
                for (Revenue_KPI__share share: kpi.Shares) {
                    users.remove(share.UserOrGroupId);
                }
                for (Id userId: users) {
					addShareToList(revKpiShareList, kpi.id,userId, null);                	
                }
			}
		}
		executeKPIShareDML(revKpiShareList,newCoverage,INSERT_SHARE);
   }

   //will remove coverage from kpi
   public static void updateRevenueSharesCoverage(List<Coverage_Team_Member__c> alteredCoverageTeamCoverage, Set<String> accountAndTeamMemberSet) {
       System.debug('in updateRevenueSharesCoverage. Altered coverage teams '+ alteredCoverageTeamCoverage);
       List<Coverage_Team_Member__c> membersToRemove = new List<Coverage_Team_Member__c>();
       Map<Id, Set<Id>> rmToUserMap = new Map<Id, Set<Id>>();
       
        /*for(Coverage_Team_Member__c cvgTeamUpdate : alteredCoverageTeamCoverage){
            if (!string.valueOf(cvgTeamUpdate.UniqueId__c).contains('PREVDELETE') 
                && cvgTeamUpdate.End_Date__c != null) {
                    membersToRemove.add(cvgTeamUpdate);
                    Set<Id> userIds = null != rmToUserMap.get(cvgTeamUpdate.Account__c) 
                        ? rmToUserMap.get(cvgTeamUpdate.Account__c) 
                        : new Set<Id>();
                    userIds.add(cvgTeamUpdate.Team_Member__c);
                    rmToUserMap.put(cvgTeamUpdate.Account__c, userIds);
            }
        }*/
       
       /* Changes for JIRA SALES-1490 : Start */
       //This method gets the final list of Account and Team Member Id for which the deletions are to be performed
       for(String acctAndTMStr : accountAndTeamMemberSet){
           String accountId = acctAndTMStr.substring(0,acctAndTMStr.lastIndexOf('#'));
           String teamMemberId = acctAndTMStr.substring(acctAndTMStr.lastIndexOf('#') + 1);
           
           Set<Id> userIds = rmToUserMap.get(accountId) != null ? rmToUserMap.get(accountId) : new Set<Id>();
           userIds.add(teamMemberId);
           
           rmToUserMap.put(accountId, userIds);
       }
       /* Changes for JIRA SALES-1490 : End */
       

       //system.debug('membersToRemove :'+ membersToRemove);
       //provides a way of going from rm coverage removal to rg coverage removal
       Map<Id, Id> rmToRgMap = getRmToRgMap(rmToUserMap.keySet()); //Changes for JIRA SALES-1490
       //System.debug('rmToRgMap size = ' + rmToRgMap.size());
       //this map relates these coverage losers to the rg
       Map<Id, Set<Id>> rgToUserMap = new Map<Id, Set<Id>>();
       for (Id key: rmToRgMap.keySet()) {
           //get rg value
           Id rgId = rmToRgMap.get(key);
           //get users for that rm and add to set
           Set<Id> rgUsers = null!=rgToUserMap.get(rgId) ? rgToUserMap.get(rgId) : new Set<Id>();
           //get the rm users from the coverage delete map
           Set<id> userFromRm = rmToUserMap.get(key);
           //add the rm users to the rg users and put back
           rgUsers.addAll(userFromRm);
           rgToUserMap.put(rgId,rgUsers);
       }
       //System.debug('Rg To User Map size ' + rgToUserMap.size());
       
       //this maps the rg to rm hierarchy
       Map<Id, Set<Id>> rgToRmIds = getRgIdToRmIdMap(rgToUserMap.keySet());
       //generate a list of all rms that we need active coverage on
       Set<Id> allRmIds = new Set<Id>();
       for (Set<id> rms: rgToRmIds.values()) {
           allRmIds.addAll(rms);
       }
       //System.debug('All Rms under coverage for rgs '+ allRmIds.size());
       //find coverage by rm on all the rms in this set
       //these represent all the coverage for all the rms for all the rgs that 
       //are being soft-deleted. 
       Map<Id, Set<Id>> rmToCoverageMap = getRmIdToActiveCoverageMembers(allRmIds);
       //System.debug('rmCoverageMap entries ' + rmToCoverageMap.size());
       
       //this accumulates the users losing coverage at the rg level
       Map<Id, Set<Id>> rgIdToUserLosingCoverageMap = new Map<Id, set<Id>>(); 
       //1. for each rm where users are losing coverage
       //2. find the coverage losers
       //3. find the rg associated with this rm
       //4. find all the rm's in the hierarchy that roll up to this rg
       //5. exclude the rm from step one from this set
       //6. for each of these rm's, pull the set of users under current coverage from rmToCoverageMap
       //7. for the user losing coverage in step one, if it is not in this set, then 
       //8. they lose rg coverage and are added to rgIdToUserLosingCoverageMap

       for(Id rmId: rmToUserMap.keySet()) {
           //2. find the coverage losers
           Set<Id> cvgTeamMembersToDelete = rmToUserMap.get(rmId);
           //3. this is the rm key.  use it to find the rg
           Id rgId = rmToRgMap.get(rmId);
           //4. find the set of rms under this rg
           if (null != rgToRmIds.get(rgId)) {
               Set<Id> rmIdsToRgParentId = rgToRmIds.get(rgId).clone();
               //System.debug('Number of RMs assigned to RG '+ rgId +' = '+rmIdsToRgParentId.size());
               //5. exclude the rm from step one from this set
               rmIdsToRgParentId.remove(rmId);
               //System.debug('Number of RMs assigned to RG '+ rgId +' after removal of source rm = '+rmIdsToRgParentId.size());
               //6. for each of these rm's, pull the set of users under current coverage from rmToCoverageMap
               Set<Id> usersUnderRGCoverage = new Set<Id>();
               for (Id siblingRmId: rmIdsToRgParentId) {
                   //System.debug('Examining coverage for rm '+ siblingRmId);
                   if (null != rmToCoverageMap.get(siblingRmId)) {
                       //System.debug('Found users under coverage map for rm ' + siblingRmId + ' size = ' + rmToCoverageMap.get(siblingRmId).size());
                       usersUnderRGCoverage.addAll(rmToCoverageMap.get(siblingRmId));
                   }
               }
               //7. for the user losing coverage in step one, if it is not in this set, then 
               for (Id userUnderRmCoverage: cvgTeamMembersToDelete) {
                   if (!usersUnderRGCoverage.contains(userUnderRmCoverage)) {
                       //System.debug('User id ' + userUnderRmCoverage +' not under rmcoverage for rgid '+rgId);
                       Set<Id> users = null!=rgIdToUserLosingCoverageMap.get(rgId) ?
                           rgIdToUserLosingCoverageMap.get(rgId) : new Set<Id>();
                       users.add(userUnderRmCoverage);
                       rgIdToUserLosingCoverageMap.put(rgId, users);
                   }
               }
           }
       } 
   		List<Revenue_KPI__share> revKpiShareList = new List<Revenue_KPI__share>();
		//first generate the coverage rm to rg map
		for (List<Revenue_KPI__c> kpiList : [select Id, RG__c,(select Id, UserOrGroupID from Shares) from Revenue_KPI__c where RG__c in: rgIdToUserLosingCoverageMap.keySet()]) {
			for (Revenue_KPI__c kpi: kpiList) {
				Set<id> users = rgIdToUserLosingCoverageMap.get(kpi.RG__c);
                for (Revenue_KPI__share share: kpi.Shares) {
                    //if this user is in the remove list, mark it for removal
                    if (users.contains(share.UserOrGroupId) ) {
                    	addShareToList(revKpiShareList, kpi.id,share.UserOrGroupId, share.id);                	    
                    }
                }
			}
		}
		executeKPIShareDML(revKpiShareList,alteredCoverageTeamCoverage, DELETE_SHARE);
   }
    
	
   //all rms that are of interest are passed as part of the account team member
   //and are returned as map key values and the value is the parent rg.
   private static Map<id,id> getRmToRgMap(List<Coverage_Team_Member__c> coverage) {
      	Map<Id, Id> rmToRgMap = new Map<Id, Id>();
       	Set<Id> rmAccountIds = new Set<Id>();
       	for (Coverage_Team_Member__c ctm: coverage) {
	       	rmAccountIds.add(ctm.Account__c);
	   	}
       	//now query
       	for (List<Account> rms: [SELECT id, ParentId FROM account where id in: rmAccountIds ]) {
           for (Account rm: rms) {
               rmToRgMap.put(rm.id, rm.ParentId);
           }
       	}
   		return rmToRgMap;
   }
    
   //all rms that are of interest are passed as part of rmAccountIds
   //and are returned as map key values and the value is the parent rg.
   private static Map<Id,Id> getRmToRgMap(Set<Id> rmAccountIds) {
   		Map<Id, Id> rmToRgMap = new Map<Id, Id>();
        for (List<Account> rms: [SELECT Id, ParentId FROM account where Id in: rmAccountIds ]) {
           for (Account rm: rms) {
               rmToRgMap.put(rm.Id, rm.ParentId);
           }
       	}
        return rmToRgMap;
   } 
    
   //utility method that creates a share on kpi object as represented by the kpiId and for userId
   //if the shareId is included, the share will be identified so it can be removed.
   private static void addShareToList(List<Revenue_KPI__share> revKpiShareList, Id kpiId, Id userId, Id shareId) {
		Revenue_KPI__share share = new Revenue_KPI__share();
		share.parentId = kpiId;
		share.userOrGroupId = userId;
		share.accessLevel = 'Read';
       if (null != shareId) {
           share.id = shareId;
       }
		revKpiShareList.add(share);
   }

   //returns a map of rgIds keys with a value of list of userids that have coverage for that rg
   //input is set of account rg ids
   private static Map<Id, Set<Id>> getRgIdToUserIdMapFromRGs(set<Id>rgAccountSet) {
   		Map<Id,Id> accountRmToRgMap = new Map<id,Id>();
   		//get map where key is the rm and value is the rg.
   		for (List<Account> rmAccounts: [Select id,ParentId,RM_Account__c from Account where Active__c= true  and parent.id in : rgAccountSet]) {
	   		for (Account account: rmAccounts) {
   				if (account.RM_Account__c) {
   					accountRmToRgMap.put(account.id,account.ParentId);
   				}
   			}
   		}
        
   		Map<Id, Set<Id>> rgToUserMap = new Map<Id,set<Id>>();  //this holds return values.
   		
   		//use the key set to grab coverage 
   		for (List<AccountTeamMember> accountTeamList : [select accountid,UserId from AccountTeamMember where accountid in : accountRmToRgMap.keySet() and User.IsActive=true]) {
	   		for (AccountTeamMember member: accountTeamList) {
	   			//find the rg of the rm
	   			Id rgId = accountRmToRgMap.get(member.accountId);
	   			Set<id> userUnderRgCoverage = rgToUserMap.get(rgId)!=null ? rgToUserMap.get(rgId): new Set<Id>();
	   			userUnderRgCoverage.add(member.UserId);
	   			rgToUserMap.put(rgId, userUnderRgCoverage);
	   		}
   		}
   		//finally, if any rgs didn't have coverage, just add a empty set to the return map
   		for (Id id: rgAccountSet) {
   			if (!rgToUserMap.containsKey(id)) rgToUserMap.put(id, new Set<Id>());
   		}
   		return rgToUserMap;
   } 

   //returns a map of rg id to all rm ids that map to it, given a list of rgids.
   private static Map<Id, Set<Id>> getRgIdToRmIdMap(Set<Id> rgAccountIds) {
        //accumulate the RG Ids in a set
        Map<Id,Set<Id>> rgToRmMap= new Map<Id, Set<Id>>();
        for (List<Account> accounts: [SELECT ParentId, Id FROM Account where ParentId in : rgAccountIds]) {
            for (Account acc: accounts) {
                Set<Id> rmIds = rgToRmMap.get(acc.ParentId)!=null? rgToRmMap.get(acc.ParentId): new Set<Id>();
                rmIds.add(acc.Id);
                rgToRmMap.put(acc.ParentId, rmIds);
            }
        }
        return rgToRmMap;
    }
   
   //returns a map of rm id to set of users in account team for that rm
   private static Map<Id, Set<Id>> getRmIdToActiveCoverageMembers(Set<id> rmIds) {
//       System.debug('getRmIdToActiveCoverageMembers. Number or RM entries '+ rmIds.size() );
//       System.debug('rms to query '+ rmIds);
        Map<Id, Set<Id>> rmToCoverageMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> rmToSalesCodeMap = new Map<Id, Set<Id>>();
       	/* Changes for JIRA SALES-1490 : Start */
        
        Id activeCoverageRecordTypeId = CommonTools.getRecordTypeId('Coverage_Team_Member__c', 'Active Coverage');
        if(activeCoverageRecordTypeId != null) {
            for (List<Coverage_Team_Member__c> ctmList: [SELECT Account__c, Sales_Team_for_Coverage__c from Coverage_Team_Member__c where RecordTypeId = :activeCoverageRecordTypeId and Account__c in : rmIds]) 
            {
                /*for (Coverage_Team_Member__c ctm: ctmList) {
                    Set<Id> members = rmToCoverageMap.get(ctm.Account__c)!=null? 
                        rmToCoverageMap.get(ctm.Account__c): 
                    new Set<Id>();
                    members.add(ctm.Team_Member__c);
                    rmToCoverageMap.put(ctm.Account__c, members);
                }*/
                for(Coverage_Team_Member__c ctm : ctmList){
                    Set<Id> salesCodeSet = rmToSalesCodeMap.containsKey(ctm.Account__c) ? rmToSalesCodeMap.get(ctm.Account__c) : new Set<Id>();
                    salesCodeSet.add(ctm.Sales_Team_for_Coverage__c);
                    rmToSalesCodeMap.put(ctm.Account__c, salesCodeSet);
                }
            }
       }
        
       if(rmToSalesCodeMap.values().size() > 0){
           Set<Id> salesTeamForCoverageIdSet = new Set<Id>();
           for(Set<Id> salesCodeSet : rmToSalesCodeMap.values()){
           		salesTeamForCoverageIdSet.addAll(salesCodeSet);    
           }
           
           Map<Id,Set<Id>> salesCodeUserMap = CoverageRequestUtility.fetchSalesCodeAllUserDetails(salesTeamForCoverageIdSet, FALSE);
           
           for(Id rmAccountId : rmToSalesCodeMap.keySet()){
               Set<Id> salesCodeIdSet = rmToSalesCodeMap.get(rmAccountId);
               for(Id salesCodeId : salesCodeIdSet){
                   if(salesCodeUserMap.containsKey(salesCodeId)){
                       Set<Id> userIdSet = rmToCoverageMap.containsKey(rmAccountId) ? rmToCoverageMap.get(rmAccountId) : new Set<Id>();
                       userIdSet.addAll(salesCodeUserMap.get(salesCodeId));
                       rmToCoverageMap.put(rmAccountId, userIdSet);
                   }
               }
           }
       }
       
        /* Changes for JIRA SALES-1490 : End */
//       System.debug('Number or RM entries '+ rmToCoverageMap.size() );
        return rmToCoverageMap;
    }
   
   //execute insert or delete of kpi shares
   private static void executeKPIShareDML(List<Revenue_KPI__share> revKpiShareList, List<SObject>newObjectList, String operation) {
		if(revKpiShareList.size()>0){
			try{
                System.debug('Size of KPI shares to operate on = ' + revKpiShareList.size() + '. operation: '+ operation);
                if (INSERT_SHARE.equals(operation)) {
                    insert revKpiShareList;            
                } else if (DELETE_SHARE.equals(operation)) {
                    delete revKpiShareList;
                }
		    	
			} catch(exception ex){
		   		newObjectList[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()+ '. DML Op= '+ operation);
			}
        }
   }
    
}