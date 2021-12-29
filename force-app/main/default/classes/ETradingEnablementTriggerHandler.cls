/*
	Author 		: Simon Foden
	Company 	: Nomura
	Date 		: 02/07/2018
	Description : Trigger handler for the ETradingEnablement object.   
				   
	
*/  
public class ETradingEnablementTriggerHandler 
{
	// this flag indicates whether the logic to complete the eTrading Request has already been executed in
	// a current transaction in order to avoid re-executing the same logic (because of WF field updates)
	// to avoid the errors 
	@TestVisible 
	private static Boolean isCompleteEtradingReqExecuted = false;
	// Set of the ETrading-Add-Requests to be completed
	@TestVisible 
	private static Set<String> ETAddRequestIdToCompleteSet = new Set<String>();
	// Set of the ETrading-Revoke-Requests to be completed
	private static Set<String> ETRevokeRequestIdToCompleteSet = new Set<String>();
	// List of ETrading Reqest Records to be completed by Platform_D uniqu key
	private static Map<String, List<ETradingEnablement__c>> ETradingToCompListByPlaformIDUnqKeyMap = new Map<String, List<ETradingEnablement__c>>();
	// Set of PlatfromID unique keys by ETrading Request to be completed
	private static Map<String, Set<String>> PlaformIDUnqKeySetByEtradingIdMap = new Map<String, Set<String>>();
	// Existing ContactPlatform__c records by Platfrom Unique key
	private static Map<String, ContactPlatform__c> ExistingContPlatfromByUnqKeyMap = new Map<String, ContactPlatform__c>();
	// Set of PlatfromID unique keys to be created 
	private static Set<String> NewPlaformIDUnqKeySet = new Set<String>(); 
	// New contactPlatform__c that are created successfully
	private static Map<String, ContactPlatform__c> NewContPlatByUnqKeyMap = new Map<String, ContactPlatform__c>();
	// Errors in creating new contactPlatform__c by PlatfromID - uniqu key
	private static Map<String, String> ErrsByContPlatUnqKeyMap = new Map<String, String>();
	// Errors by ETrading Request Id that needs to be completed 
	private static Map<String, String> ErrsByEtradingRequestIdMap = new Map<String, String>();
	// List of eTCoverage Records by Parent-eTRequest Id
	private static Map<String, List<ETradingEnablement__c>> ETCoverageListByETRequestIdMap = new Map<String, List<ETradingEnablement__c>>();

    public static void handleBeforeInsert(List<ETradingEnablement__c> newRecords)
    {
    	populateUniqueKey(null, newRecords);
    	//populateETEnablementFromExtSystem(newRecords);
    	Map<Id, Sales_Team_for_Coverage__c> salesTeamForCoverageOwners = readsalesTeamForCoverageOwners(newRecords); 
    	skipApproval(newRecords, salesTeamForCoverageOwners);
    }
    
    public static void handleAfterInsert(Map<Id, ETradingEnablement__c> newRecords)
    {
    	// OLD CODE
    	//sendInsertedRecordsEmails(newRecords);
    	
    	// NEW CODE
    	// call the following and check that the Coverage ETrading records that are being created 
    	// have any errors and if there are errors then add the errors to the correspodingcoverage recrds under
    	// the same ETrading request record
    	checkCoverageCreation(newRecords);
    	sendInsertedRecordsEmails(newRecords);
    }
    
	public static void handleBeforeUpdate(Map<Id, ETradingEnablement__c> oldRecords, Map<Id, ETradingEnablement__c> newRecords)
	{
		populateUniqueKey(oldRecords, newRecords.values());
		updateETradingEnablementStatus(oldRecords, newRecords);
		cheackReApprovalRequired(oldRecords, newRecords);
	}

    public static void handleAfterUpdate(Map<Id, ETradingEnablement__c> oldRecords, Map<Id, ETradingEnablement__c> newRecords)
    {
    	// COMMNETED FOLLOWING EXISTING CODE
    	//sendUpdatedRecordsEmails(oldRecords, newRecords);
    	//updateETradingEnablementCoverage(oldRecords, newRecords);
    	
    	// NEW CODE
    	// call completeETradinRequests to check, verify and find whether the ETrading records can be completed
    	// and if it can be completed 
    	completeETradingRequests(oldRecords, newRecords);
    	sendUpdatedRecordsEmails(oldRecords, newRecords);
    }
    
    /* commented out for Simon's changes
	private void populateETEnablementFromExtSystem(List<ETradingEnablement__c> newRecords) {
    	System.debug('#### ETradingEnablementTriggerHandler.populateETEnablementFromExtSystem()');
		ETradingEnablementService.populateStatusAndRecordType(null, newRecords);
		ETradingEnablementService.populateContact(null, newRecords);
		ETradingEnablementService.populateProduct(null, newRecords);
		ETradingEnablementService.populateSalesCode(null, newRecords);
    }
	*/
    
    private static Map<Id, Sales_Team_for_Coverage__c> readsalesTeamForCoverageOwners(List<ETradingEnablement__c> newRecords)
    {
		Set<Id> salesTeamForCoverageIds = new Set<Id>();
		
		for (ETradingEnablement__c eTradingEnablement : newRecords)
		{
			if (eTradingEnablement.Sales_Team_for_Coverage__c != null)
			{
				salesTeamForCoverageIds.add(eTradingEnablement.Sales_Team_for_Coverage__c);
			}
		}    

		Map<Id, Sales_Team_for_Coverage__c> salesTeamForCoverageOwners = new Map<Id, Sales_Team_for_Coverage__c>([
			SELECT Id, OwnerId 
			FROM Sales_Team_for_Coverage__c 
			WHERE OwnerId = :UserInfo.getUserId() 
			OR Id IN :salesTeamForCoverageIds
       	]);
		
		return salesTeamForCoverageOwners;
    }
    
    // If the approval is for the user who requested it then 
	// it does not need to be approved
    private static void skipApproval(List<ETradingEnablement__c> newRecords, Map<Id, Sales_Team_for_Coverage__c> salesTeamForCoverageOwners)
    {
		Id eTradingEnablementRequestRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Request').getRecordTypeId();
		
		Map<Id, Sales_Team_for_Coverage__c> currentUserSalesCodes = readCurrentUserSalesCodes(salesTeamForCoverageOwners); 
		
		for (ETradingEnablement__c eTradingEnablement : newRecords)
		{
			
			if (eTradingEnablement.RecordTypeId == eTradingEnablementRequestRecordTypeId
				&& eTradingEnablement.Status__c == 'Pending Approval'
               	&& currentUserSalesCodes.containsKey(eTradingEnablement.Sales_Team_for_Coverage__c))  
			{
				eTradingEnablement.Status__c = 'To Be Processed';	
			}
		}
		
    }
    
    private static Map<Id, Sales_Team_for_Coverage__c> readCurrentUserSalesCodes(Map<Id, Sales_Team_for_Coverage__c> salesTeamForCoverageOwners)
	{
       	Id currentUserId = UserInfo.getUserId();
       	
       	Map<Id, Sales_Team_for_Coverage__c> currentUserSalesCodes = new Map<Id, Sales_Team_for_Coverage__c>();
       	
       	for (Id salesTeamForCoverageId : salesTeamForCoverageOwners.keySet())
       	{
       		if (salesTeamForCoverageOwners.get(salesTeamForCoverageId).OwnerId == currentUserId)
       		{
       			currentUserSalesCodes.put(salesTeamForCoverageId, salesTeamForCoverageOwners.get(salesTeamForCoverageId));
       		} 
       		
       	}
       	
       	return currentUserSalesCodes;
	}
    
	// A Map won't accept duplicate key values so there will be only 
	// one ETradingEnablement__c per SalesTeamForCoverage Owner and therefore one 
	// email sent
    private static void sendInsertedRecordsEmails(Map<Id, ETradingEnablement__c> newRecords)
	{
		Map<Id, ETradingEnablement__c> eTradingEnablements = new Map<Id, ETradingEnablement__c>();
		Map<Id, Id> salesTeamForCoverageOwners = readSalesTeamForCoverageOwners(newRecords.keySet());
		
		Id eTradingEnablementRequestRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Request').getRecordTypeId();
		
		for (ETradingEnablement__c eTradingEnablement : newRecords.values())
    	{
    		if (eTradingEnablement.RecordTypeId == eTradingEnablementRequestRecordTypeId 
    			&& eTradingEnablement.Status__c == 'Pending Approval')
    		{
    			if (!eTradingEnablements.containsKey(salesTeamForCoverageOwners.get(eTradingEnablement.Sales_Team_for_Coverage__c)))
	    		{
	    			eTradingEnablements.put(salesTeamForCoverageOwners.get(eTradingEnablement.Sales_Team_for_Coverage__c), eTradingEnablement);
	    		}
    		}
    	}
    	
    	if (!eTradingEnablements.isEmpty())
    	{
    		sendEmails(eTradingEnablements);
    	}
	}
	
    // PRAVIN To Do - Remove the sendEmail notification for Etrading Request records with status == Complete
	// as there can be errors in the completing the ETrading records
    private static void sendUpdatedRecordsEmails(Map<Id, ETradingEnablement__c> oldRecords, Map<Id, ETradingEnablement__c> newRecords)
    {
    	Map<Id, ETradingEnablement__c> eTradingEnablements = new Map<Id, ETradingEnablement__c>();
    	Map<Id, Id> salesTeamForCoverageOwners = readSalesTeamForCoverageOwners(newRecords.keySet());
    	
    	Id eTradingEnablementRequestRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Request').getRecordTypeId();
    	
    	for (ETradingEnablement__c eTradingEnablement : newRecords.values())
    	{
    		if (eTradingEnablement.RecordTypeId == eTradingEnablementRequestRecordTypeId  
    			&& eTradingEnablement.Status__c != oldRecords.get(eTradingEnablement.Id).Status__c 
    			&& (eTradingEnablement.Status__c == 'Being Processed' || 
    			    (eTradingEnablement.Status__c == 'Complete' && ErrsByEtradingRequestIdMap.isEmpty() )))
    		{
    			if (!eTradingEnablements.containsKey(salesTeamForCoverageOwners.get(eTradingEnablement.Sales_Team_for_Coverage__c)))
	    		{
	    			eTradingEnablements.put(salesTeamForCoverageOwners.get(eTradingEnablement.Sales_Team_for_Coverage__c), eTradingEnablement);
	    		}
    		}
    		
    	}
    	
    	if (!eTradingEnablements.isEmpty())
    	{
    		sendEmails(eTradingEnablements);
    	}
    }
    
    private static Map<Id, Id> readSalesTeamForCoverageOwners(Set<Id> eTradingEnablementIds)
    {
    	Map<Id, Id> salesTeamForCoverageOwners = new Map<Id, Id>();
    	
    	for (ETradingEnablement__c eTradingEnablement : [
            SELECT Id, Sales_Team_for_Coverage__c, Sales_Team_for_Coverage__r.OwnerId 
            FROM ETradingEnablement__c 
            Where Id IN : eTradingEnablementIds])
    	{
    		salesTeamForCoverageOwners.put(
                eTradingEnablement.Sales_Team_for_Coverage__c, 
                eTradingEnablement.Sales_Team_for_Coverage__r.OwnerId);
    	} 
    	
    	return salesTeamForCoverageOwners;
    }
    
    private static void sendEmails(Map<Id, ETradingEnablement__c> eTradingEnablements)
    {
		Id jobId = System.enqueueJob(new ETradingEnablementSendEmail(eTradingEnablements));
    }
    
    private static void updateETradingEnablementStatus(Map<Id, ETradingEnablement__c> oldRecords, Map<Id, ETradingEnablement__c> newRecords)
	{
		for (ETradingEnablement__c eTradingEnablement : newRecords.values())
		{
			if (eTradingEnablement.Contact__c != oldRecords.get(eTradingEnablement.Id).Contact__c 
				|| eTradingEnablement.Sales_Team_for_Coverage__c != oldRecords.get(eTradingEnablement.Id).Sales_Team_for_Coverage__c)
			{
				if (eTradingEnablement.Contact__c != null && eTradingEnablement.Sales_Team_for_Coverage__c != null)
				{
					if (eTradingEnablement.Status__c == 'On Hold')
					{
						eTradingEnablement.Status__c = 'Pending Approval';
					}
				}
			}
		}
	}
	
	//Author : Pravin Kundal
	private static void populateUniqueKey(Map<Id, ETradingEnablement__c> OldMap, List<ETradingEnablement__c> NewList) {
		System.debug('#### ETradingEnablementTriggerHandler.populateUniqueKey()');
		Long indx = Datetime.now().getTime();
		String eTCoverageRTId = ETradingEnablementService.ETERecTypeInfoByRecTypeDevNameMap.get(ETradingEnablementService.ETE_RT_NAME_COVERAGE).getRecordTypeId();
		for(ETradingEnablement__c oNewET : NewList) {
			ETradingEnablement__c oOldET = (OldMap==null) ? null : OldMap.get(oNewET.Id);
			if(oOldET==null ||
					(oNewET.RecordTypeId == eTCoverageRTId && oOldET.Status__c != oNewET.Status__c) ||
					// (oOldET.Status__c != oNewET.Status__c && (oNewET.Status__c=='Active' || oNewET.Status__c=='Inactive')) ||
					oOldET.Contact__c!=oNewET.Contact__c || 
					oOldET.Sales_Team_for_Coverage__c != oNewET.Sales_Team_for_Coverage__c ||
					oOldET.ETradingEnablementProduct__c != oNewET.ETradingEnablementProduct__c ||
					oOldET.Electronic_Platform__c != oNewET.Electronic_Platform__c ||
					oOldET.Contact_Platform__c != oNewET.Contact_Platform__c) {
				// change the unique key
				oNewET.Record_Unique_Key__c = oNewET.Contact__c +'_'+
						oNewET.ETradingEnablementProduct__c +'_'+
						oNewET.Electronic_Platform__c +'_'+
						oNewET.Contact_Platform__c; 
				// if record type is Coverage record
				if(oNewET.RecordTypeId == eTCoverageRTId) {
					oNewET.Record_Unique_Key__c += (oNewET.Status__c=='Active' ? '_Active' : 
							'_'+oNewET.Status__c+'_'+Datetime.now().getTime()+'_'+indx); 
				} else { // for Request Etrading 
					oNewET.Record_Unique_Key__c += '_'+Datetime.now().getTime()+'_'+indx;	
				}
				--indx;
			}
			System.debug('Record_Unique_Key__c : '+oNewET.Record_Unique_Key__c);
		}
	}
	
	//Author : Pravin Kundal
	// call from : trigger - after insert
	// this function will only check whether all the Coverage records could be added for a give Etrading Request
	// if not then add the error for the corresponding coverage records for the same Etrading Request. 
	private static void checkCoverageCreation(Map<Id, ETradingEnablement__c> NewMap) {
		System.debug('#### ETradingEnablementTriggerHandler.checkCoverageCreation()');
		if(!ETCoverageListByETRequestIdMap.isEmpty()) {
			// List of ETrading Coverage record List by corresponding Parent ETrading Request Id
			Map<String, List<ETradingEnablement__c>> ETCoverageAfterInsertListByETRequestIdMap = new Map<String, List<ETradingEnablement__c>>();
			// Set of PlatfromID Unique keys for the ETrading Coverage recrds bein created by the Parent ETrading Request Id
			Map<String, Set<String>> PlatIDUnqKeySetByETReqIdMap = new Map<String, Set<String>>();
			for(ETradingEnablement__c oET : NewMap.values()) {
				if(oET.RecordTypeId == ETradingEnablementService.ETERecTypeInfoByRecTypeDevNameMap.get(ETradingEnablementService.ETE_RT_NAME_COVERAGE).getRecordTypeId()) {
					List<ETradingEnablement__c> ETCoverageList = ETCoverageAfterInsertListByETRequestIdMap.containsKey(oET.Parent_Request__c) ?
								ETCoverageAfterInsertListByETRequestIdMap.get(oET.Parent_Request__c) : new List<ETradingEnablement__c>();
					ETCoverageList.add(oET);
					ETCoverageAfterInsertListByETRequestIdMap.put(oET.Parent_Request__c, ETCoverageList);
					
					Set<String> PlatIDUnqKeySet = PlatIDUnqKeySetByETReqIdMap.containsKey(oET.Parent_Request__c) ? 
							PlatIDUnqKeySetByETReqIdMap.get(oET.Parent_Request__c) : new Set<String>();
					PlatIDUnqKeySet.add(oET.Electronic_Platform__c +'-'+ oET.Platform_Id__c);
					PlatIDUnqKeySetByETReqIdMap.put(oET.Parent_Request__c, PlatIDUnqKeySet);
				}
			}
			
			if(!ETCoverageAfterInsertListByETRequestIdMap.isEmpty()) {
				for(String eTradingReqId : ETCoverageAfterInsertListByETRequestIdMap.keySet()) {
					// in After Triggers you will not see the record if there was an error in some validation rule or error was added in Bofore Update Trigger
					if(ETCoverageListByETRequestIdMap.containsKey(eTradingReqId) && 
							(ETCoverageListByETRequestIdMap.get(eTradingReqId).size() != ETCoverageAfterInsertListByETRequestIdMap.get(eTradingReqId).size())) {
						// there is error in creating some coverage records for same ETradin Request
						String error = '';
						for(String pfIDUnqKey : PlaformIDUnqKeySetByEtradingIdMap.get(eTradingReqId)) {
							if(!PlatIDUnqKeySetByETReqIdMap.get(eTradingReqId).contains(pfIDUnqKey)) {
								error += String.isBlank(error) ? 'because Coverage cannot be created for Platform IDs: ' : ', ';
								error += ' pfIDUnqKey';
							}
						}
						if(String.isNotBlank(error)) {
							for(ETradingEnablement__c oETCoverage : ETCoverageAfterInsertListByETRequestIdMap.get(eTradingReqId)) {
								ETradingEnablement__c oET = NewMap.get(oETCoverage.Id);
								oET.addError('Failed to create coverage for : '+oET.Electronic_Platform__c+'-'+oET.Platform_Id__c+' '+error);
							}
						}
					}
				}
			}
		}
	}
	
	//Author : Pravin Kundal
	private static void findETRequestsToComplete(Map<Id, ETradingEnablement__c> OldMap, Map<Id, ETradingEnablement__c> NewMap) {
		System.debug('#### ETradingEnablementTriggerHandler::findETRequestsToComplete()');
		for(ETradingEnablement__c oNewET : NewMap.values()) {
			ETradingEnablement__c oOldET = (OldMap == null) ? null : OldMap.get(oNewET.Id);
			if(oNewET.RecordTypeId == ETradingEnablementService.ETERecTypeInfoByRecTypeDevNameMap.get(ETradingEnablementService.ETE_RT_NAME_REQUEST).getRecordTypeId() &&
					oNewET.Status__c == 'Complete' && (oOldET==null || oOldET.Status__c!='Complete')) {
				if(oNewET.Request_Type__c=='Add') {
					if(populateETAndPlatIDStructures(oNewET)) {
						ETAddRequestIdToCompleteSet.add(oNewET.Id);
					}
				} else if(oNewET.Request_Type__c=='Revoke') {
					ETRevokeRequestIdToCompleteSet.add(oNewET.Id);
				}
			}
		}
	}

	//Author : Pravin Kundal
	private static void completeETradingRequests(Map<Id, ETradingEnablement__c> OldMap, Map<Id, ETradingEnablement__c> NewMap) {
		System.debug('#### ETradingEnablementTriggerHandler::completeETradingRequests()');
		if(!isCompleteEtradingReqExecuted) {
			isCompleteEtradingReqExecuted=true;
			findETRequestsToComplete(OldMap, NewMap);
			
			// complete Add Requests
			if(!ETAddRequestIdToCompleteSet.isEmpty()) {
				ExistingContPlatfromByUnqKeyMap = ContactPlatformService.getContactPFDetailsByUnqKey(ETradingToCompListByPlaformIDUnqKeyMap.keySet());
				NewPlaformIDUnqKeySet = ETradingToCompListByPlaformIDUnqKeyMap.keySet();
				NewPlaformIDUnqKeySet.removeAll(ExistingContPlatfromByUnqKeyMap.keySet());
				Map<String, String> ErrsByContPlatMap = new Map<String, String>();
				ContactPlatformService.createContactPlatformFromEtradingRecords(NewPlaformIDUnqKeySet, 
						ETradingToCompListByPlaformIDUnqKeyMap, false, NewContPlatByUnqKeyMap, ErrsByContPlatMap);
				// now add the errors to all the eTrading records which are adding the PlatformIDs with errors
				for(String unqKey : ErrsByContPlatMap.keySet()) {
					String pfIDerrors = ErrsByContPlatUnqKeyMap.containsKey(unqKey) ? ErrsByContPlatUnqKeyMap.get(unqKey) : '';
					pfIDerrors += (String.isNotBlank(pfIDerrors) ? '\n' : '') + ErrsByContPlatMap.get(unqKey);
					ErrsByContPlatUnqKeyMap.put(unqKey, pfIDerrors); 
					for(ETradingEnablement__c oET : ETradingToCompListByPlaformIDUnqKeyMap.get(unqKey)) {
						addErrorByETradingRequest(oET.Id, 'This eTrading Request cannot be completed because the creation of new Contact-Platform record, '+unqKey+' failed');
					}
					ETradingToCompListByPlaformIDUnqKeyMap.remove(unqKey);
				}
				
				// now loop through and check the remaing ETrading Request which has no error so far and could be created
				// first find the remaining etrading records that could be completed
				ETAddRequestIdToCompleteSet.removeAll(ErrsByEtradingRequestIdMap.keySet());
				// create coverage records
				for(String etId : ETAddRequestIdToCompleteSet) {
					for(String unqKey : PlaformIDUnqKeySetByEtradingIdMap.get(etId)) {
						// create a coverage record
						ETradingEnablement__c eTradingRequest = NewMap.get(etId);
						ContactPlatform__c oContPlat = ExistingContPlatfromByUnqKeyMap.containsKey(unqKey) ?
								ExistingContPlatfromByUnqKeyMap.get(unqKey) : NewContPlatByUnqKeyMap.get(unqKey);
						// the following can return null for coverage record which means it wasn't able to create a coverage record
						// from passed eTradingequest and contactPlatform objects
						ETradingEnablement__c eTradingCoverage = ETradingEnablementService.createETradingCoverage(eTradingRequest, oContPlat);
						if(eTradingCoverage==null) {
							// the coverage couldn't not be created
							addErrorByETradingRequest(etId, 'Coverage record was not created for eTrading Request : '+eTradingRequest.Name+' for PlatfromId : '+unqKey);
							ETCoverageListByETRequestIdMap.remove(etId);
							break;
						} else {
							List<ETradingEnablement__c> ETCoverageList = ETCoverageListByETRequestIdMap.containsKey(etId) ?
									ETCoverageListByETRequestIdMap.get(etId) : new List<ETradingEnablement__c>();
							ETCoverageList.add(eTradingCoverage);
							ETCoverageListByETRequestIdMap.put(etId, ETCoverageList);
						}
					}
				}
				ETAddRequestIdToCompleteSet.removeAll(ErrsByEtradingRequestIdMap.keySet());
				
				List<ETradingEnablement__c> ETradingCoverageToCreateList = new List<ETradingEnablement__c>();
				for(List<ETradingEnablement__c> ETradinList : ETCoverageListByETRequestIdMap.values()) {
					ETradingCoverageToCreateList.addAll(ETradinList);
				} 
				if(!ETradingCoverageToCreateList.isEmpty()) {
					// insert coverage records
					Database.SaveResult[] srList = Database.Insert(ETradingCoverageToCreateList, false);
					String error;
					Integer indx = 0;
					for(Database.SaveResult sr : srList) {
						ETradingEnablement__c eTradingCoverage = ETradingCoverageToCreateList.get(indx);
						//String unqKey = eTradingCoverage.Platform__c+'-'+eTradingCoverage.Name;
						if(!sr.isSuccess()) {
							ETAddRequestIdToCompleteSet.remove(eTradingCoverage.Parent_Request__c);
							error='';
							for(Database.Error err : sr.getErrors()) {
		                        error+=err.getStatusCode() + ': ' + err.getMessage();
		                        System.debug('The following error has occurred.');
		                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
	                    	}
	                    	addErrorByETradingRequest(eTradingCoverage.Parent_Request__c, error);
						} else {
							System.debug('eTrading coverage inserted successfully : '+sr.getId());
						}
						indx++;
					}
				}
				
				System.debug('Now check and add errors ErrsByEtradingRequestIdMap : '+ErrsByEtradingRequestIdMap);
				// finally add errors to the ETrading Request records
				for(String etId : ErrsByEtradingRequestIdMap.keySet()) {
					System.debug('Add Error For : '+etId);
					ETradingEnablement__c eTRequest = NewMap.get(etId);
					eTRequest.addError(ErrsByEtradingRequestIdMap.get(etId));
				}
				
				// also delete the ContactplatformID records which were newly created and for which 
				// no ETrading record could be completed successfully
				if(!NewContPlatByUnqKeyMap.isEmpty()) {
					
					Set<String> NewContPlatByUnqKeyToRemoveSet = new Set<String>(NewContPlatByUnqKeyMap.keySet()); 
					for(String etReqId : ETAddRequestIdToCompleteSet) {
						if(PlaformIDUnqKeySetByEtradingIdMap.containsKey(etReqId)) {
							NewContPlatByUnqKeyToRemoveSet.removeAll(PlaformIDUnqKeySetByEtradingIdMap.get(etReqId));
						}
					}
					
					if(!NewContPlatByUnqKeyToRemoveSet.isEmpty()) {
						List<ContactPlatform__c> ContPlatToRemoveList = new List<ContactPlatform__c>(); 
						for(String platUnqKey : NewContPlatByUnqKeyToRemoveSet) {
							ContPlatToRemoveList.add(NewContPlatByUnqKeyMap.get(platUnqKey));
						}
						delete ContPlatToRemoveList;
					}
				} 
			} // end of - if(!ETAddRequestIdToCompleteSet.isEmpty()) {
			
			// Revoke request
			if(!ETRevokeRequestIdToCompleteSet.isEmpty()) {
				List<String> ETradingCoverageIdList = new List<String>();
				for(String eTRevReqId : ETRevokeRequestIdToCompleteSet) {
					ETradingEnablement__c oETRevReq = NewMap.get(eTRevReqId);
					if(String.isNotBlank(NewMap.get(eTRevReqId).Parent_Coverage__c)) {
						ETradingCoverageIdList.add(oETRevReq.Parent_Coverage__c);
					} else {
						oETRevReq.addError('No Coverage record that needs to be revoked is associated with this Request record');
					}
				}

				// step 2 - get the list of corresponding coverage records
				List<ETradingEnablement__c> ETCoverageList = 
						ETradingEnablementService.getETCoverageRecords(ETradingCoverageIdList, null);
				if(!ETCoverageList.isEmpty()) {
					System.debug('here in trigger 1');
					for(ETradingEnablement__c oETCoverage : ETCoverageList) {
						oETCoverage.Status__c = 'Inactive';
					}
					update ETCoverageList;
				}
			}
		}
 	}
 	
	 //Author : Pravin Kundal
 	private static Boolean populateETAndPlatIDStructures(ETradingEnablement__c oNewET) {
		Boolean canPopulate = false;
		if(String.isNotBlank(oNewET.Platform_IDs_To_Enable__c) && String.isNotBlank(oNewET.Electronic_Platform__c)) {
			List<String> PlatfromIDList = oNewET.Platform_IDs_To_Enable__c.split(';');
			for(String pfID : PlatfromIDList) {
				String uniqueKey = oNewET.Electronic_Platform__c+'-'+pfID;
				List<ETradingEnablement__c> ETradingList = ETradingToCompListByPlaformIDUnqKeyMap.containsKey(uniqueKey) ?
					ETradingToCompListByPlaformIDUnqKeyMap.get(uniqueKey) : new List<ETradingEnablement__c>();
				ETradingList.add(oNewET);
				ETradingToCompListByPlaformIDUnqKeyMap.put(uniqueKey, ETradingList);
				
				Set<String> PlaformIDUnqKeySet = PlaformIDUnqKeySetByEtradingIdMap.containsKey(oNewET.Id) ? 
						PlaformIDUnqKeySetByEtradingIdMap.get(oNewET.Id) : new Set<String>();
				PlaformIDUnqKeySet.add(uniqueKey);
				PlaformIDUnqKeySetByEtradingIdMap.put(oNewET.Id, PlaformIDUnqKeySet);
			}
			canPopulate = true;
		}
		return canPopulate;
	}
 	
 	private static void addErrorByETradingRequest(String eTRequestId, String error) {
 		String eTerrors = ErrsByEtradingRequestIdMap.containsKey(eTRequestId) ? ErrsByEtradingRequestIdMap.get(eTRequestId) : '';
		eTerrors += (String.isNotBlank(eTerrors) ? '\n' : '') + error;
		ErrsByEtradingRequestIdMap.put(eTRequestId, eTerrors);
 	}
    
	//Author : Pravin Kundal
 	private static void cheackReApprovalRequired(Map<Id, ETradingEnablement__c> OldMap, Map<Id, ETradingEnablement__c> NewMap) {
 		System.debug('#### ETradingEnablementTriggerHandler::cheackReApprovalRequired()');
		Set<String> SalesTeamForCovIdSet = new Set<String>();
		Set<String> ETReqSet = new Set<String>();
		for(ETradingEnablement__c oNewET : NewMap.values()) {
			ETradingEnablement__c oOldET = OldMap.get(oNewET.Id);
			if(oNewET.Sales_Team_for_Coverage__c != oOldET.Sales_Team_for_Coverage__c &&
					(oOldET.Status__c=='To Be Processed' || oOldET.Status__c=='Being Processed' || oOldET.Status__c=='Rejected')) { 
				System.debug('oNewET.Sales_Team_for_Coverage__c : '+oNewET.Sales_Team_for_Coverage__c);
				System.debug('oOldET.Sales_Team_for_Coverage__c : '+oOldET.Sales_Team_for_Coverage__c);
				SalesTeamForCovIdSet.add(oNewET.Sales_Team_for_Coverage__c);
				SalesTeamForCovIdSet.add(oOldET.Sales_Team_for_Coverage__c);
				ETReqSet.add(oNewET.Id);
			}
		}

		// if there is re-assignment of Sales Code
		System.debug('SalesTeamForCovIdSet.size() : '+SalesTeamForCovIdSet.size());
		System.debug('SalesTeamForCovIdSet : '+SalesTeamForCovIdSet);
		if(!SalesTeamForCovIdSet.isEmpty()) {
			String currUserId = UserInfo.getUserId();
			Map<String, Sales_Team_for_Coverage__c> SalesTeamForCoverageMap = 
					SalesTeamForCoverageService.getSalesTeamForCoverageRecs(SalesTeamForCovIdSet);
			System.debug('SalesTeamForCoverageMap.size() : '+SalesTeamForCoverageMap.size());
			for(String eTReqId : ETReqSet) {
				ETradingEnablement__c oNewET = NewMap.get(eTReqId);
				ETradingEnablement__c oOldET = OldMap.get(eTReqId);
				String newSalesCodeOwner = SalesTeamForCoverageMap.get(oNewET.Sales_Team_for_Coverage__c).OwnerId;
				String oldSalesCodeOwner = SalesTeamForCoverageMap.get(oOldET.Sales_Team_for_Coverage__c).OwnerId;
				if((newSalesCodeOwner != oldSalesCodeOwner) || (currUserId != oldSalesCodeOwner) || oOldET.Status__c=='Rejected') {
					oNewET.Status__c = 'Pending Approval';
					System.debug('Changed the Status to Pending Approval for eT : '+oNewET.Id);
				}
			}
		}
	}
}