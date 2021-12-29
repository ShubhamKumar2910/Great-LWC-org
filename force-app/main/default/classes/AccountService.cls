/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : This class implements the Service class for Account object to implement 
** 				  business tasks, calculations and processes around Account object.
**
** Consumer of the Service Layer : Batch, Schedulable, Queuable/Apex API/UI Controllers/Inbpound Email Handlers/Invocable Method
**/

public without sharing class AccountService {

	public static final String ACCOUNT_RT_NAME_RS_ACCOUNT = 'RS_Account';
	public static final String ACCOUNT_RT_NAME_RG_ACCOUNT = 'RG_Account';
	public static final String ACCOUNT_RT_NAME_RM_ACCOUNT = 'RM_Account';
	public static final String ACCOUNT_RT_NAME_NOMURA_EMPLOYEE_ACCOUNT = 'NOMURA_EMPLOYEES';
	public static Map<String, Schema.RecordTypeInfo> AccountRecTypeInfoByRecTypeDevNameMap {public get {
			if(AccountRecTypeInfoByRecTypeDevNameMap==null) {
				AccountRecTypeInfoByRecTypeDevNameMap = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
				System.debug('--AccountRecTypeInfoByRecTypeDevNameMap--' + AccountRecTypeInfoByRecTypeDevNameMap);
			}
			return AccountRecTypeInfoByRecTypeDevNameMap;
		}
		private set;
	}
	
	
	

	/**
	  * Description : Get the RG Account coverage for given list of User Ids 
	  *				  The covergae is calulated based on both Sales Code and Split sales Code	
	  *
	  *	@param List<String> UserIdList - List of User Ids for which to get the coverage
	  * @return Map<Id, Map<Id, Account>> - Inner map is a map of RG Accounts by it's Id 
	  *										and outer map is the map of the inner map by User Id	  
	  *										e.g. map<userId , map<rgAccId, RG-Account object>>	
	**/
	public static Map<String, Map<String, Account>> getRGAccountCoverageForUsers(List<String> UserIdList) {
		system.debug('AccountService::getRGAccountCoverageForUsers()');
		Map<String, Map<String, Account>> RGAccountByAccIdMapByUserIdMap = new Map<String, Map<String, Account>>();
		try {
			if(UserIdList!=null && !UserIdList.isEmpty()) {
				
				// We could use follwing single query but to get the Accounts abased on User will become complex and messy otr may be not poosiblle at all
				//List<Coverage_Team_Member__c> CoverageTeamMemberList = [SELECT Id,Account__c,Account__r.Parent.Id,Sales_Team_for_Coverage__c 
				//	FROM Coverage_Team_Member__c 
				//	WHERE RecordTypeId='0120I000000plJhQAI' AND 
				//		Sales_Team_for_Coverage__c IN (SELECT  Sales_Team_for_Coverage__c
				// 				FROM Sales_Team_User__c 
				// 				WHERE User__c IN :UserIdList AND Sales_Team_for_Coverage__r.Active__c=true)];
				
				// Step 1: First get the list of Sales_Team_User__c for a given list of UserIds 
				
				Map<String, Set<String>> UserIdSetBySalesCodeIdMap = 
						SalesTeamForCoverageService.getAllActiveSalesCodeForUsers(UserIdList);
				Set<String> SalesTeamForCoverageIdSet = UserIdSetBySalesCodeIdMap.keySet();
				                
				List<Coverage_Team_Member__c> CoverageTeamMemberList = 
						CoverageTeamMemberService.getCoverageTeamMembersForSalesCode(SalesTeamForCoverageIdSet);
				
				for(Coverage_Team_Member__c oCovMem : CoverageTeamMemberList) {
					Account oRGAccount = new Account(Id=oCovMem.Account__r.Parent.Id, Name=oCovMem.Account__r.Parent.Name);
					if(UserIdSetBySalesCodeIdMap.containsKey(oCovMem.Sales_Team_for_Coverage__c)) {
						for(String userId : UserIdSetBySalesCodeIdMap.get(oCovMem.Sales_Team_for_Coverage__c)) {
							Map<String, Account> AccountByIdMap = RGAccountByAccIdMapByUserIdMap.containsKey(userId) ?
								 RGAccountByAccIdMapByUserIdMap.get(userId) : new Map<String, Account>();
							if(!AccountByIdMap.containsKey(oCovMem.Account__r.Parent.Id)) {
								AccountByIdMap.put(oCovMem.Account__r.Parent.Id, oRGAccount);
								RGAccountByAccIdMapByUserIdMap.put(userId, AccountByIdMap);
							} 
						}
					}
				}
			}
		} catch(Exception ex) {
			System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new AccountServiceException('Error Occured in AccountService::getRGAccountCoverageForUsers() : '+ex.getMessage());
		}
		
		//System.debug('SIZE : '+RGAccountByAccIdMapByUserIdMap.get(UserIdList[0]).size());
		//System.debug(RGAccountByAccIdMapByUserIdMap);
		return RGAccountByAccIdMapByUserIdMap;
	}
	
	public static Map<String, String> getBulkUploadCampaignForRMAccount(List<String> RMAccountIdList) {
		system.debug('AccountService::getBulkUploadCampaignForRMAccount()');
		Map<String, String> BulkUploadCampIdByRMAccIdMap = new Map<String, String>();
		try { 
			if(RMAccountIdList!=null && !RMAccountIdList.isEmpty()) {
				Id rmRecTypeId = AccountRecTypeInfoByRecTypeDevNameMap.get(ACCOUNT_RT_NAME_RM_ACCOUNT).getRecordTypeId(); 
				List<Account> AccountList = [SELECT Id, Bulk_Upload_Campaign__c 
					FROM Account
					WHERE RecordTypeId = :rmRecTypeId AND
						Id IN :RMAccountIdList];
					
				for(Account oAcc : AccountList) {
					BulkUploadCampIdByRMAccIdMap.put(oAcc.Id, oAcc.Bulk_Upload_Campaign__c);
				}
			}
		} catch(Exception ex) {
			System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new AccountServiceException('Error Occured in AccountService::getBulkUploadCampaignForRMAccount() : '+ex.getMessage());
		}	
		return BulkUploadCampIdByRMAccIdMap;
	}
	
	public static Map<Id, Account> identifyAndGetRMAccountsToDefaultForMiFIDIIEntitlement(Set<String> RMAccountIdSet) {
		system.debug('AccountService::identifyAndGetRMAccountsToDefaultForMiFIDIIEntitlement()');
		Map<Id, Account> RmAccountToDefaultForMiFIDIIEntByAccIdMap = new Map<Id, Account>(); 
		try {
			string rmAccRTId = AccountRecTypeInfoByRecTypeDevNameMap.get(ACCOUNT_RT_NAME_RM_ACCOUNT).getRecordTypeId();
			RmAccountToDefaultForMiFIDIIEntByAccIdMap = new Map<Id, Account>([SELECT Id, Default_New_Contact_MiFID_II_Entitlement__c, Override_Contacts_MiFID_II_Entitlement__c,
				 	MiFID_II_Research_In_Scope__c, MiFIDII_Sales_Commentary_Allowed__c, Service_Type__c, MiFID_II_Product_Subscriptions__c,
				 	Is_MiFIDII_Entitlements_In_Progress__c
				 FROM Account 
				 WHERE Id IN :RMAccountIdSet AND RecordTypeId=:rmAccRTId AND 
				 	(Default_New_Contact_MiFID_II_Entitlement__c=true OR Override_Contacts_MiFID_II_Entitlement__c=true)]);
		} catch(Exception ex) {
			System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new AccountServiceException('Error Occured in AccountService::getBulkUploadCampaignForRMAccount() : '+ex.getMessage());
		}
		return RmAccountToDefaultForMiFIDIIEntByAccIdMap; 
	}
	
	public static void updateMiFIDIIInScopeAtRMandRGAcountLevel(List<Contact> NewContactList, Map<Id,Contact> OldContactMap) {
		System.debug('#### AccountService::updateMiFIDIIInScopeAtRMandRGAcountLevel()');
		
		// Step 1: Find the RM Account IDs whether to turn on or turn off the MiFID-II In Scope flag 
		Set<Id> RMAccIdToSetMiFIDIIFlagToTrueSet = new Set<Id>();
		Set<Id> RMAccIdToSetMiFIDIIFlagToFalseSet = new Set<Id>();
		for(Contact oNewCont : NewContactList) {
			Contact oOldCont = OldContactMap==null ? null : OldContactMap.get(oNewCont.Id); 
			// in this case we only need to consider if oNewCont.MiFIDII_In_Scope__c == true
			// else ignore it
			Boolean hasRMAccountChanged = oOldCont == null ? false : String.isNotBlank(oNewCont.AccountId) && (oNewCont.AccountId != oOldCont.AccountId);  
			if(oNewCont.MiFIDII_In_Scope__c==true && oNewCont.Active__c==true && hasRMAccountChanged==false &&
					( (oOldCont==null || oOldCont.MiFIDII_In_Scope__c==false) || (oOldCont!=null && oOldCont.Active__c==false) ) ) {
				RMAccIdToSetMiFIDIIFlagToTrueSet.add(oNewCont.AccountId);
				System.debug('Account Not changed and added to RMAccIdToSetMiFIDIIFlagToTrueSet');
			} else if( (oNewCont.MiFIDII_In_Scope__c==false && oNewCont.Active__c==true && oOldCont!=null && oOldCont.MiFIDII_In_Scope__c==true && hasRMAccountChanged==false) ||
					(oNewCont.Active__c==false && oOldCont!=null && oOldCont.Active__c==true && oOldCont.MiFIDII_In_Scope__c==true && hasRMAccountChanged==false) ) {
				RMAccIdToSetMiFIDIIFlagToFalseSet.add(oNewCont.AccountId);
				System.debug('Account Not changed and added here RMAccIdToSetMiFIDIIFlagToFalseSet');
			}
			
			if(hasRMAccountChanged) {
				if(oNewCont.MiFIDII_In_Scope__c==true ) {
					RMAccIdToSetMiFIDIIFlagToTrueSet.add(oNewCont.AccountId);
					System.debug('Adding Contact with MiFIDII_In_Scope__c==true to RM Account : '+oNewCont.AccountId);
				}

				if(oOldCont.MiFIDII_In_Scope__c==true ) {
					RMAccIdToSetMiFIDIIFlagToFalseSet.add(oOldCont.AccountId);
					System.debug('Removing Contact with MiFIDII_In_Scope__c==true from RM Account : '+oOldCont.AccountId);
				}
			}
		}
		System.debug('RMAccIdToSetMiFIDIIFlagToTrueSet : '+RMAccIdToSetMiFIDIIFlagToTrueSet);
		System.debug('RMAccIdToSetMiFIDIIFlagToFalseSet : '+RMAccIdToSetMiFIDIIFlagToFalseSet);

		// Step 2: There could be a following scenario
		//		A RM Account may have 10 Contacts and before this update there was only one Contact with MiFIDII_In_Scope__c==true
		//		And now in this update, two Contacts on this Account are being updated as below
		//			1) One on which MiFIDII_In_Scope__c was true is now being set to false
		//			2) and the other on which MiFIDII_In_Scope__c was false is now being set to true
		//		so in nutshell the MiFIDII_In_Scope__c==true on RM Account should remail true
		// 		and so we perform the following opration, to remove the Id of this account from setting this flag to false 
		RMAccIdToSetMiFIDIIFlagToFalseSet.removeAll(RMAccIdToSetMiFIDIIFlagToTrueSet);
		System.debug('After removing RMAccIdToSetMiFIDIIFlagToFalseSet : '+RMAccIdToSetMiFIDIIFlagToFalseSet);
		
		// For DEBUG
		/*AggregateResult[] groupedResults1 = [SELECT AccountId, COUNT(Id) noOfConts
			FROM Contact 
			WHERE (AccountId IN :RMAccIdToSetMiFIDIIFlagToFalseSet OR AccountId IN :RMAccIdToSetMiFIDIIFlagToTrueSet) AND MiFIDII_In_Scope__c = false AND Active__c=true
			GROUP BY ROLLUP(AccountId) ];
		for (AggregateResult ar : groupedResults1) {
			system.debug('Groupr Result : '+ar.get('AccountId')+' : '+ar.get('noOfConts'));
		}*/
	
		// Step 3: Now if there are RM Acc Ids to for which to set this flag to false 
		if(!RMAccIdToSetMiFIDIIFlagToFalseSet.isEmpty()) {
			// Run the aggregation query to find the number of the Contacts on these account for which 
			// MiFIDII_In_Scope__c==true.
			// Please note that suppose the Contacts that are being updated in this transaction will
			// also get picked up based on their latest value and not the old value 
			AggregateResult[] groupedResults = [SELECT AccountId, COUNT(Id) noOfConts
				FROM Contact 
				WHERE AccountId IN :RMAccIdToSetMiFIDIIFlagToFalseSet AND MiFIDII_In_Scope__c = true AND Active__c=true
				GROUP BY ROLLUP(AccountId) HAVING COUNT(Id) > 0];
			
			for (AggregateResult ar : groupedResults) {
				String rmAccId = (String)ar.get('AccountId');
				if(String.isNotBlank(rmAccId)) {
					// if the Account Id is found in the group result that means after this transaction there will be
					// atleast one Contact on this Account with MiFIDII_In_Scope__c = true, so don't set this flag to false
					// on this Account
					RMAccIdToSetMiFIDIIFlagToFalseSet.remove(rmAccId);
				}
			}
			System.debug('RMAccIdToSetMiFIDIIFlagToFalseSet : '+RMAccIdToSetMiFIDIIFlagToFalseSet);
		}
		
		// Step 4: Finally update the RM Account and its corresponding with appropriate MiFIDII_In_Scope__c flag
		if(!RMAccIdToSetMiFIDIIFlagToTrueSet.isEmpty() || !RMAccIdToSetMiFIDIIFlagToFalseSet.isEmpty()) {
			// the following query will select both RM and RG acounts
			String query = 'SELECT Id, ParentId, MiFIDII_in_Scope__c '+ 
				'FROM Account ';
			if(!RMAccIdToSetMiFIDIIFlagToTrueSet.isEmpty()) {
				query += 'WHERE Id IN :RMAccIdToSetMiFIDIIFlagToTrueSet ';
			}
			if(!RMAccIdToSetMiFIDIIFlagToFalseSet.isEmpty()) {
				query += (RMAccIdToSetMiFIDIIFlagToTrueSet.isEmpty() ? ' WHERE ' : ' OR ') + ' Id IN :RMAccIdToSetMiFIDIIFlagToFalseSet ';
			}
			System.debug('query : '+query);
			List<Account> RMAccList = Database.query(query);
			List<Account> RGandRMAccountToUpdateList = new List<Account>();
			for(Account oRMAcc : RMAccList) {
				if(RMAccIdToSetMiFIDIIFlagToTrueSet.contains(oRMAcc.Id)) {
					System.debug('oRMAcc : '+oRMAcc);
					if(oRMAcc.MiFIDII_in_Scope__c==false) {
						RGandRMAccountToUpdateList.add(new Account(Id=oRMAcc.Id, MiFIDII_In_Scope__c=true));
						//if(String.isNotBlank(oRMAcc.ParentId)) {
						//	RGandRMAccountToUpdateMap.put(oRMAcc.ParentId, new Account(Id=oRMAcc.ParentId, MiFIDII_In_Scope__c=true));
						//}
					}
				} else if(RMAccIdToSetMiFIDIIFlagToFalseSet.contains(oRMAcc.Id)) {
					if(oRMAcc.MiFIDII_in_Scope__c==true) {
						RGandRMAccountToUpdateList.add(new Account(Id=oRMAcc.Id, MiFIDII_In_Scope__c=false));
						//if(String.isNotBlank(oRMAcc.ParentId) && !RGandRMAccountToUpdateMap.containsKey(oRMAcc.ParentId)) {
						//	RGandRMAccountToUpdateMap.put(oRMAcc.ParentId, new Account(Id=oRMAcc.ParentId, MiFIDII_In_Scope__c=false));
						//}
					}					
				}
			}
			
			System.debug('RGandRMAccountToUpdateList:'+RGandRMAccountToUpdateList.size());
			
			if(!RGandRMAccountToUpdateList.isEmpty()) {
				update RGandRMAccountToUpdateList;
			}
		}
	}
	
	public static Map<Id, Account> getRMAccMiFIDIIEntitlementWithOverrideFlagForContacts(List<Contact> ContactList) {
		System.debug('#### AccountService::getRMAccMiFIDIIEntitlementWithOverrideFlagForContacts()');
		Map<Id, Account> RMAccMiFIDIIEntitlementWithOverrideFlagByIdMap = new Map<Id, Account>();
		try{
			if(ContactList!=null && !ContactList.isEmpty()) {
				Set<Id> RMAccIdSet = new Set<Id>();
				for(Contact oCont : ContactList) {
	    			RMAccIdSet.add(oCont.AccountId);
	    		}
	    		if(!RMAccIdSet.isEmpty()) {
	    			RMAccMiFIDIIEntitlementWithOverrideFlagByIdMap = new Map<Id, Account>([SELECT Id, 
	    					MiFID_II_Research_In_Scope__c, MiFIDII_Sales_Commentary_Allowed__c, 
	    					Service_Type__c, MiFID_II_Product_Subscriptions__c, Override_Contacts_MiFID_II_Entitlement__c 
	    				FROM Account 
	    				WHERE Id IN :RMAccIdSet AND Override_Contacts_MiFID_II_Entitlement__c=true]);
	    		}
			}
		} catch(Exception ex) {
			System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new AccountServiceException('Error Occured in AccountService::getRMAccountMiFIDIIOverrideFalgForContacts() : '+ex.getMessage());
		}
		
		return RMAccMiFIDIIEntitlementWithOverrideFlagByIdMap;
	} 

	private static String getEntitySearchString(String entityName, String operator) {
		String srchStr = '';
 		if(String.isNotBlank(entityName)) {
			operator = String.isBlank(operator) ? ' AND ' : (' '+operator+' ');
			entityName = entityName.trim();
			if(String.isNotBlank(entityName)) {
				//entityName = entityName.replace('-','\\-');
				//entityName = entityName.replace('+','\\+');
				String regExp1 = '(&\\s{1,}|\\|\\s{1,}|!\\s{1,}|\\(\\s{1,}|\\)\\s{1,}|\\{\\s{1,}|\\}\\s{1,}|\\[\\s{1,}|\\]\\s{1,}|\\^\\s{1,}|"\\s{1,}|~\\s{1,}|\\*\\s{1,}|\\?\\s{1,}|:\\s{1,}|\\+\\s{1,}|\\-\\s{1,}|\\\\\\s{1,}|\'\\s{1,})';
				entityName = entityName.replaceAll(regExp1, ' ');
				System.debug('entityName : after regExp1 : '+entityName);
				
				//Now escape the special characters & | ! ( ) { } [ ] ^ " ~ * ? : \ + -  except '
				//string regExp2 = '(&|\\||!|\\|\\(|\\)|\\{|\\}|\\[|\\]|\\^|"|~|\\*|\\?|:|\\+|\\-|\\\\|\')';
				//string regExp2 = '(&|\\||!|\\|\\{|\\}|\\[|\\]|\\^|"|~|\\*|\\?|:|\\+|\\-|\\\\|\')';
				//entityName = entityName.replaceAll(regExp2, '\\\\$1');
				entityName = entityName.replaceAll('\\p{Punct}', ' ');
				System.debug('entityName : after regExp2 : '+entityName);
				
				List<String> EntityNameTokList = entityName.split(' ');
				srchStr = EntityNameTokList[0]+'*';
				for(Integer i=1; i<EntityNameTokList.size() &&  Limits.getLimitSoslQueries()>Limits.getSoslQueries(); ++i) {
					srchStr += operator + EntityNameTokList[i]+'*';
				}
			}
		}
		System.debug('srchStr : '+srchStr);
		return srchStr;
	}

	public static List<Account> findAccounts(String entityName, String entityNameOperator, 
			List<String> ParentIdList, String entityLocation, Boolean includeInActive,
			List<String>AccountRTList, List<String>AccStageList, Boolean isCoverageReq, 
			Integer limitRecs, Integer offset) {
        System.debug('#### AccountService::findAccounts');
                
        List<Account> AccList = new List<Account>();
        try{ 
			String srchStr = getEntitySearchString(entityName, entityNameOperator);
			if(String.isNotBlank(srchStr)) {
				String accQuery = 'FIND {' + srchStr + '} IN NAME FIELDS RETURNING Account ' +  
					'(Id, Name, Domicile_Country__c, Client_Type__c, ParentId, Parent.ParentId, Parent.Name, Stage__c '+
					' WHERE RecordTypeId IN :AccountRTList ';
				if(ParentIdList!=null && !ParentIdList.isEmpty()) {
					accQuery += ' AND ParentId IN :ParentIdList ';
				}
				if(String.isNotBlank(entityLocation)) {
					accQuery += ' AND Domicile_Country__c = :entityLocation ';
				}
				if(!includeInActive) {
					accQuery += ' AND Active__c = true ';
				}
				if(AccountRTList[0]==AccountRecTypeInfoByRecTypeDevNameMap.get(ACCOUNT_RT_NAME_RM_ACCOUNT).getRecordTypeId()) {
					if(AccStageList!=null && !AccStageList.isEmpty()) {
						accQuery += ' AND Stage__c IN :AccStageList ';	
					}
					accQuery += ' AND ParentId != null AND Parent.ParentId != null ';
				} else if(AccountRTList[0]==AccountRecTypeInfoByRecTypeDevNameMap.get(ACCOUNT_RT_NAME_RG_ACCOUNT).getRecordTypeId()) {
					accQuery += ' AND ParentId != null ';
				}
				accQuery += ' ORDER BY NAME ASC LIMIT :limitRecs';
				if(offset!=null) {
					accQuery += ' OFFSET :offset';
				}
				accQuery += ')';
				List<List<Account>> SearchList = (List<List<Account>>)search.query(accQuery);
				AccList = SearchList[0];
				// check Coverage	
				if(isCoverageReq && !AccList.isEmpty()) {
					System.debug('Considering Coverage');
					Map<Id, Account> AccByIdMap = new Map<Id, Account>();
					for(Account oAcc : AccList) {
						AccByIdMap.put(oAcc.Id, oAcc);
					}
					AccList.clear();
					System.debug('AccByIdMap size : '+AccByIdMap.size());
					Set<Id> AccIdWithCoverageSet = RecordAccess.getRecordEditAccessDetails(
								AccByIdMap.keySet(), true);
					System.debug('AccIdWithCoverageSet size : '+ AccIdWithCoverageSet.size() +' : '+AccIdWithCoverageSet);
					for(Id accId : AccIdWithCoverageSet) {
						AccList.add(AccByIdMap.get(accId));
					}
					System.debug('return final Acc List : '+AccList.size() + ' : '+AccList);
				}
			}
        } catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new AccountServiceException('Error Occured in AccountService::findAccounts() : '+ex.getMessage());
        }
        return AccList;
    }

	public static List<Account> getAccountHierarchy(Set<String> RGEntityIdSet, 
			Set<String> RSEntityIdSet, Boolean includeChildRGAccs, Boolean includeInActive) {
        System.debug('#### AccountService::getRMAccountWithHierarchyDetails');
		List<Account> RSAccountHierarchyList = new List<Account>();
		try {
			if(RGEntityIdSet!=null && !RGEntityIdSet.isEmpty()) {
				List<Account> RGAccList = [SELECT Id, ParentId FROM Account WHERE Id IN :RGEntityIdSet];
				if(RSEntityIdSet==null) {
					RSEntityIdSet = new Set<String>();
				}
				for(Account oRGAcc : RGAccList) {
					RSEntityIdSet.add(oRGAcc.ParentId);
				}
			}
			
			if(RSEntityIdSet != null && !RSEntityIdSet.isEmpty()) {
				String query = 'SELECT Id, Name, Active__c ';
				if(includeChildRGAccs) {
					query += ', (SELECT Id, Name, Active__c FROM ChildAccounts ';
					Boolean whereClauseAdded = false;
					if(RGEntityIdSet != null && !RGEntityIdSet.isEmpty()) {
						query += 'WHERE Id IN :RGEntityIdSet ';
						whereClauseAdded = true;
					}
					if(!includeInActive) {
						query += (whereClauseAdded ? 'AND' : 'WHERE')+ ' Active__c = true ';
					}
					query += 'ORDER BY Name) ';
				}
				
				query += 'FROM Account '+
						 'WHERE ID IN :RSEntityIdSet ';
				if(!includeInActive) {
					query += 'AND Active__c = true ';
				}
				query += 'ORDER BY Name';
				System.debug('query: '+query);
				RSAccountHierarchyList = (List<Account>)Database.query(query);
				/*for(Account oRSAcc : RSAccountHierarchyList) {
					System.debug('RS NAme : '+oRSAcc.Name);
					for(Account oRGAcc : oRSAcc.ChildAccounts) {
						System.debug('--'+oRGAcc.Name);
					}
				}*/
			} 
		} catch(Exception ex) {
			System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new AccountServiceException('Error Occured in AccountService::getRMAccountWithHierarchyDetails() : '+ex.getMessage());
		}
		return RSAccountHierarchyList;
	}

	public static Map<String, Account> getAccountsFoRdmIds(Set<String> AccRdmIdSet) {
		System.debug('#### AccountService::getAccountsFoRdmIds');
		Map<String, Account> AccountByRdmIdMap = new Map<String, Account>();
		try {
			if(AccRdmIdSet!=null && !AccRdmIdSet.isEmpty()) {
				List<Account> AccList = [SELECT Id, Name, RDM_Org_ID__c, ParentId 
					FROM Account 
					WHERE RDM_Org_ID__c IN :AccRdmIdSet];
				for(Account oAcc : AccList) {
					AccountByRdmIdMap.put(oAcc.RDM_Org_ID__c, oAcc);
				}
			}
		} catch(Exception ex) {
			System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new AccountServiceException('Error Occured in AccountService::getRMAccountWithHierarchyDetails() : '+ex.getMessage());
		}
		return AccountByRdmIdMap;
	}
	
	public static void updateFenLegalEntityId(Map<String, Integer> FenLEIdByRmAccIdMap) {
		System.debug('#### AccountService::updateFenLegalEntityId');
		try {
			if(FenLEIdByRmAccIdMap!=null && !FenLEIdByRmAccIdMap.isEmpty()) {
				Map<String, Account> AccByIdMap = new Map<String, Account>([SELECT Id, Fenergo_LegalEntityId__c 
						FROM Account
						WHERE Id IN :FenLEIdByRmAccIdMap.keySet() AND Fenergo_LegalEntityId__c != NULL]);
				List<Account> AccList = new List<account>();
                System.debug('AccByIdMap ' + AccByIdMap);
				for(String accId : FenLEIdByRmAccIdMap.keySet()) {
					if(!AccByIdMap.containsKey(accId)) {
						AccList.add(new Account(Id=accId, Fenergo_LegalEntityId__c=FenLEIdByRmAccIdMap.get(accId)));
					}
				}
                System.debug('accList ' + AccList);
				if(!AccList.isEmpty()) {
					update AccList;
				}
			}
		} catch(Exception ex) {
			System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new AccountServiceException('Error Occured in AccountService::updateFenLegalEntityId() : '+ex.getMessage());
		}
	}

	public static String getAccountName(Id accountId){
		String accountName = '';
		List<Account> accountList = [Select Id, Name from Account WHERE Id = :accountId];
		
		if(accountList != null)
			accountName = accountList[0].Name;

		return accountName;
	}
	public class AccountServiceException extends Exception{}
}


/*
public static void updateMiFIDIIInScopeAtRMandRGAcountLevel(List<Contact> NewContactList, Map<Id,Contact> OldContactMap) {
		System.debug('#### AccountService::updateMiFIDIIInScopeAtRMandRGAcountLevel()');
		
		// Step 1: Find the RM Account IDs whether to turn on or turn off the MiFID-II In Scope flag 
		Set<Id> RMAccIdToSetMiFIDIIFlagToTrueSet = new Set<Id>();
		Set<Id> RMAccIdToSetMiFIDIIFlagToFalseSet = new Set<Id>();
		for(Contact oNewCont : NewContactList) {
			Contact oOldCont = OldContactMap==null ? null : OldContactMap.get(oNewCont.Id); 
			// in this case we only need to consider if oNewCont.MiFIDII_In_Scope__c == true
			// else ignore it
			if(oNewCont.MiFIDII_In_Scope__c==true && oNewCont.Active__c==true && 
					( (oOldCont==null || oOldCont.MiFIDII_In_Scope__c==false) || (oOldCont!=null && oOldCont.Active__c==false) ) ) {
				RMAccIdToSetMiFIDIIFlagToTrueSet.add(oNewCont.AccountId);
			} else if( (oNewCont.MiFIDII_In_Scope__c==false && oNewCont.Active__c==true && oOldCont!=null && oOldCont.MiFIDII_In_Scope__c==true) ||
					(oNewCont.Active__c==false && oOldCont!=null && oOldCont.Active__c==true && oOldCont.MiFIDII_In_Scope__c==true) ) {
				RMAccIdToSetMiFIDIIFlagToFalseSet.add(oNewCont.AccountId);
			}
		}
		System.debug('RMAccIdToSetMiFIDIIFlagToTrueSet : '+RMAccIdToSetMiFIDIIFlagToTrueSet);
		System.debug('RMAccIdToSetMiFIDIIFlagToFalseSet : '+RMAccIdToSetMiFIDIIFlagToFalseSet);

		// Step 2: There could be a following scenario
		//		A RM Account may have 10 Contacts and before this update there was only one Contact with MiFIDII_In_Scope__c==true
		//		And now in this update, two Contacts on this Account are being updated as below
		//			1) One on which MiFIDII_In_Scope__c was true is now being set to false
		//			2) and the other on which MiFIDII_In_Scope__c was false is now being set to true
		//		so in nutshell the MiFIDII_In_Scope__c==true on RM Account should remail true
		// 		and so we perform the following opration, to remove the Id of this account from setting this flag to false 
		RMAccIdToSetMiFIDIIFlagToFalseSet.removeAll(RMAccIdToSetMiFIDIIFlagToTrueSet);
		System.debug('After removing RMAccIdToSetMiFIDIIFlagToFalseSet : '+RMAccIdToSetMiFIDIIFlagToFalseSet);
		
		// Step 3: Now if there are RM Acc Ids to for which to set this flag to false 
		if(!RMAccIdToSetMiFIDIIFlagToFalseSet.isEmpty()) {
			// Run the aggregation query to find the number of the Contacts on these account for which 
			// MiFIDII_In_Scope__c==true.
			// Please note that suppose the Contacts that are being updated in this transaction will
			// also get picked up based on their latest value and not the old value 
			AggregateResult[] groupedResults = [SELECT AccountId, COUNT(Id) noOfConts
				FROM Contact 
				WHERE AccountId IN :RMAccIdToSetMiFIDIIFlagToFalseSet AND MiFIDII_In_Scope__c = true AND Active__c=true
				GROUP BY ROLLUP(AccountId) HAVING COUNT(Id) > 0];
			
			for (AggregateResult ar : groupedResults) {
				String rmAccId = (String)ar.get('AccountId');
				if(String.isNotBlank(rmAccId)) {
					// if the Account Id is found in the group result that means after this transaction there will be
					// atleast one Contact on this Account with MiFIDII_In_Scope__c = true, so don't set this flag to false
					// on this Account
					RMAccIdToSetMiFIDIIFlagToFalseSet.remove(rmAccId);
				}
			}
			System.debug('RMAccIdToSetMiFIDIIFlagToFalseSet : '+RMAccIdToSetMiFIDIIFlagToFalseSet);
		}
		
		// Step 4: Finally update the RM Account and its corresponding with appropriate MiFIDII_In_Scope__c flag
		if(!RMAccIdToSetMiFIDIIFlagToTrueSet.isEmpty() || !RMAccIdToSetMiFIDIIFlagToFalseSet.isEmpty()) {
			// the following query will select both RM and RG acounts
			String query = 'SELECT Id, ParentId, MiFIDII_in_Scope__c '+ 
				'FROM Account ';
			if(!RMAccIdToSetMiFIDIIFlagToTrueSet.isEmpty()) {
				query += 'WHERE Id IN :RMAccIdToSetMiFIDIIFlagToTrueSet ';
			}
			if(!RMAccIdToSetMiFIDIIFlagToFalseSet.isEmpty()) {
				query += (RMAccIdToSetMiFIDIIFlagToTrueSet.isEmpty() ? ' WHERE ' : ' OR ') + ' Id IN :RMAccIdToSetMiFIDIIFlagToFalseSet ';
			}
			System.debug('query : '+query);
			List<Account> RMAccList = Database.query(query);
			List<Account> RGandRMAccountToUpdateList = new List<Account>();
			for(Account oRMAcc : RMAccList) {
				if(RMAccIdToSetMiFIDIIFlagToTrueSet.contains(oRMAcc.Id)) {
					if(oRMAcc.MiFIDII_in_Scope__c==false) {
						RGandRMAccountToUpdateList.add(new Account(Id=oRMAcc.Id, MiFIDII_In_Scope__c=true));
						if(String.isNotBlank(oRMAcc.ParentId)) {
							RGandRMAccountToUpdateList.add(new Account(Id=oRMAcc.ParentId, MiFIDII_In_Scope__c=true));
						}
					}
				} else if(RMAccIdToSetMiFIDIIFlagToFalseSet.contains(oRMAcc.Id)) {
					if(oRMAcc.MiFIDII_in_Scope__c==true) {
						RGandRMAccountToUpdateList.add(new Account(Id=oRMAcc.Id, MiFIDII_In_Scope__c=false));
						if(String.isNotBlank(oRMAcc.ParentId)) {
							RGandRMAccountToUpdateList.add(new Account(Id=oRMAcc.ParentId, MiFIDII_In_Scope__c=false));
						}
					}					
				}
			}
			
			System.debug('RGandRMAccountToUpdateList :'+RGandRMAccountToUpdateList.size());
			
			if(!RGandRMAccountToUpdateList.isEmpty()) {
				update RGandRMAccountToUpdateList;
			}
		}
	}

*/