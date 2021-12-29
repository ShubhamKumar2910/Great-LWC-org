/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : Service class which provides reusable functionality for eTrading Enablement 
**				  and could be called by various clients (Contrller classes, Asynchronous classes, api classes etc.)
**  Sharing	    : This class is declared without any - with sharing or without sharing as it acquires the sharing 
**				  from caller class. 	
**				   
**/
public class ETradingEnablementService {

	public static final String ETE_RT_NAME_REQUEST  = 'Request';
	public static final String ETE_RT_NAME_COVERAGE = 'Coverage';
	public static Map<String, Schema.RecordTypeInfo> ETERecTypeInfoByRecTypeDevNameMap {public get {
			if(ETERecTypeInfoByRecTypeDevNameMap==null) {
				ETERecTypeInfoByRecTypeDevNameMap = Schema.SObjectType.ETradingEnablement__c.getRecordTypeInfosByDeveloperName();
			}
			return ETERecTypeInfoByRecTypeDevNameMap;
		}
		private set;
	}

    public static List<ETradingEnablement__c> getEtradingEnablementsForRecType(List<String> ETEnablementStatusList,
			List<String> ETEnablementPlatformList, List<String> ETEnablementProductIdList,
			List<String> ClientIDList, String recType, List<String> SalesCodeIDList, List<String> ContactIDList) {
                
        // ToDo : Move this to RecordTypeUtil class
        // PG: can these queries be removed and part of dynamic query referenceing parent relationship fields 

		// SF : This can be done more efficiently without reading the database using the following :-
		// Id eTradingEnablementRequestRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get(recType).getRecordTypeId();

        //List<RecordType> RecordTypeList = [Select Id, Name, DeveloperName, SobjectType
        //                               From RecordType
        //                               Where DeveloperName = :recType
        //                               And SobjectType = 'ETradingEnablement__c'
        //                               Limit 1];
        //String recTypeId = RecordTypeList[0].Id;
		String recTypeId = ETERecTypeInfoByRecTypeDevNameMap.get(recType).getRecordTypeId();

		Set<String> ContactRelatedoAccIDSet = new	Set<String>();
        if(!ClientIDList.isEmpty()) {
            for(List<Contact> ContactList : [SELECT Id FROM Contact WHERE RG_Account__c IN :ClientIDList]) {
                for(Contact oCont : ContactList) {
                    ContactRelatedoAccIDSet.add(oCont.Id);
                }
            }
        }  

		if(ContactIDList!=null && !ContactIDList.isEmpty()) {
        	ContactRelatedoAccIDSet.addAll(ContactIDList);	            
        }
		
        List<ETradingEnablement__c> ETradingEnablementList = new List<ETradingEnablement__c>();
        String queryStr = 'SELECT Id,Name,Request_Type__c,Comments__c,Contact__c,'+
              'Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Name,Electronic_Platform__c,'+
              'ETradingEnablementProduct__c,ETradingEnablementProduct__r.Name,'+
              'Actioned_By__c,Actioned_By__r.Name,Status__c,RecordTypeId,Contact__r.Name,'+
			  'Platform_First_Name__c, Platform_Last_Name__c, Contact__r.Developer_Reference__c, ' + 
			  'Platform_Account__c, Platform_Id__c, ' + 
              'Contact__r.RG_Account__r.Name,LastModifiedDate,CreatedBy.Name ';
        queryStr+=' FROM ETradingEnablement__c ';
        queryStr+=' WHERE RecordTypeId=:recTypeId ';
        
		if(ContactRelatedoAccIDSet!=null && !ContactRelatedoAccIDSet.isEmpty()) {
        	queryStr+=' AND Contact__c IN :ContactRelatedoAccIDSet '; 
        }
        
        if(SalesCodeIDList!=null && !SalesCodeIDList.isEmpty()) {
        	queryStr+=' AND Sales_Team_for_Coverage__c IN :SalesCodeIDList ';
        }
                
		// make sure that the status list is not null or empty to avoid SOQL query performance issues
		if(ETEnablementStatusList!=null && !ETEnablementStatusList.isEmpty()) {
            queryStr+=' AND Status__c IN :ETEnablementStatusList ';
        }
                
		if(ETEnablementPlatformList!=null && !ETEnablementPlatformList.isEmpty()) {
			queryStr+=' AND Electronic_Platform__c IN :ETEnablementPlatformList';
		}
                
        if(ETEnablementProductIdList!=null && !ETEnablementProductIdList.isEmpty()) {
            queryStr+=' AND ETradingEnablementProduct__c IN :ETEnablementProductIdList';
		}
        
        // clone 'with sharing' query as staring base for 'without sharing' query
        String queryStrWS = queryStr;  
        
        // don't read currentUser's Sales Code request/coverage via 'with sharing' (queryStr) query 
        // as it being done below via 'without sharing' (queryStrWS) query
        String currentUserId = userInfo.getUserId();
        queryStr+=' AND Sales_Team_for_Coverage__r.OwnerId !=:currentUserId '; 
        
        // query currnetUser's Sales Code request/coverage via 'without sharing'
        // (queryStrWS) query 
        // To show all request/coverage for currentUser's Sale Code(s) regardless contacts Access
        queryStrWS+=' AND (Sales_Team_for_Coverage__r.OwnerId =:currentUserId ';
        
        // for requests read all currentUser created request via 'without sharing' (queryStrWS) query
        // This to ignore Contact access for request they created
        if(recType == 'Request')
		{
			queryStr+=' AND CreatedById !=:currentUserId ';	
			queryStrWS+=' OR CreatedById =:currentUserId ';
		}
		queryStrWS+=') '; 
	
		
		queryStrWS+=' ORDER BY LastModifiedDate DESC';
		queryStrWS+=' LIMIT 2000';         
		queryStr+=' ORDER BY LastModifiedDate DESC'; 
		queryStr+=' LIMIT 2000';
		
		// 'without sharing' query
		QueryWithoutSharing queryWSCont = new QueryWithoutSharing();
		ETradingEnablementList = queryWSCont.getWithoutSharingRecords(
				queryStrWS, recTypeId, SalesCodeIDList, ETEnablementStatusList, 
				currentUserId, ContactRelatedoAccIDSet, ETEnablementPlatformList, ETEnablementProductIdList);
		
		// 'with sharing' query		   
		ETradingEnablementList.addAll((List<ETradingEnablement__c>)Database.query(queryStr));

    	return ETradingEnablementList;
    }
    
    public static List<Database.SaveResult> completeETradingEnablementRequests(List<ETradingEnablement__c> ETradingEnablementList,
			Boolean allOrNone, Boolean revertAll) {
		System.debug('#### ETradingEnablementService::completeETradingEnablementRequests()');
		List<Database.SaveResult> srList;
		try{
			if(ETradingEnablementList!=null && !ETradingEnablementList.isEmpty()) {
				for(ETradingEnablement__c oET : ETradingEnablementList) {
					oET.Status__c = 'Complete';
				}
				Savepoint sp; 
				if(revertAll) {
					sp = Database.setSavepoint();
					System.debug('Save Point created');
				}
				srList = Database.Update(ETradingEnablementList, allOrNone);
				
				if(revertAll) {
					// Now loop through the results and check if there is any error then roolback to the
					for(Database.SaveResult sr : srList) {
						if(!sr.isSuccess()) {
							// as there is atleast one error
							Database.rollback(sp);
							System.debug('Rollback performed');
							break; 
						}
					} 
				}
			}			
		} catch(Exception ex) {
			System.debug('ETradingEnablementService::completeETradingEnablementRequests() : Error : '+ex.getMessage());
            System.debug('ETradingEnablementService::completeETradingEnablementRequests() : Error Stack : '+ex.getStackTraceString());
            throw new ETradingEnablementServiceException('Error Occured in ETradingEnablementService::completeETradingEnablementRequests() : '+ex.getMessage());
		}
		return srList;
	}

    public static List<ETradingEnablement__c> getETradingRequestRecords(List<String> ETradingRequestIdList) {
    	System.debug('#### ETradingEnablementService::getETradingRequestRecords()');
    	List<ETradingEnablement__c> ETradingEnablementList = new List<ETradingEnablement__c>(); 
    	if(ETradingRequestIdList!=null && !ETradingRequestIdList.isEmpty()) {
	    	ETradingEnablementList = [SELECT Id,Name,Contact__c,Contact__r.Name,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Name,
	    		Electronic_Platform__c,ETradingEnablementProduct__c,ETradingEnablementProduct__r.Name,
				Status__c,Platform_Account__c,Contact__r.RG_Account__r.Name, Platform_Id__c, Contact__r.Developer_Reference__c,
				Platform_First_Name__c, Platform_Last_Name__c, Platform_Email__c, Request_Type__c, Parent_Coverage__c
			  FROM ETradingEnablement__c
			  WHERE Id IN :ETradingRequestIdList];
    	}
    	return ETradingEnablementList;
    }
    
    /*public static List<ETradingEnablement__c> getETCoverageRecordsForParentETRequest(List<String> ETradingRequestIdList) {
    	System.debug('#### ETradingEnablementService::getETCoverageRecordsForParentETRequest()');
    	List<ETradingEnablement__c> ETradingEnablementList = new List<ETradingEnablement__c>(); 
    	if(ETradingRequestIdList!=null && !ETradingRequestIdList.isEmpty()) {
	    	ETradingEnablementList = [SELECT Id,Name,Contact__c,Contact__r.Name,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Name,
	    		Electronic_Platform__c,ETradingEnablementProduct__c,ETradingEnablementProduct__r.Name,Contact__r.Developer_Reference__c,
				Status__c,Platform_Account__c,Contact__r.RG_Account__r.Name, Platform_Id__c, Parent_Request__c, Request_Type__c 
			  FROM ETradingEnablement__c
			  WHERE Parent_Request__c IN :ETradingRequestIdList AND Status__c='Active'];
    	}
    	return ETradingEnablementList;
    }*/
    
	public static List<ETradingEnablement__c> getETCoverageRecords(List<String> ETradingCoverageIdList, List<String> ETradingRequestIdList) {
    	System.debug('#### ETradingEnablementService::getETCoverageRecords()');
		System.debug('ETradingCoverageIdList : '+ETradingCoverageIdList);
		System.debug('ETradingRequestIdList : '+ETradingRequestIdList);
		List<ETradingEnablement__c> ETradingEnablementList = new List<ETradingEnablement__c>(); 
		String query = 'SELECT Id,Name,Contact__c,Contact__r.Name,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Name,'+
	    	'Electronic_Platform__c,ETradingEnablementProduct__c,ETradingEnablementProduct__r.Name,Contact__r.Developer_Reference__c,'+
			'Status__c,Platform_Account__c,Contact__r.RG_Account__r.Name, Platform_Id__c, Parent_Coverage__c, Parent_Request__c, Request_Type__c '+ 
			'FROM ETradingEnablement__c WHERE ';
		Boolean isValidQuery = false;
		Boolean isAndClauseReq = false;
		if(ETradingCoverageIdList!=null && !ETradingCoverageIdList.isEmpty()) {
			query+='Id IN :ETradingCoverageIdList ';
			isAndClauseReq = true;
			isValidQuery = true;
		} 
		if(ETradingRequestIdList!=null && !ETradingRequestIdList.isEmpty()) {
			query+= (isAndClauseReq ? ' AND ' : '') + ' Parent_Request__c IN :ETradingRequestIdList ';
			isValidQuery = true;
		}
		System.debug('query : '+query);
		if(isValidQuery) {
    		ETradingEnablementList = (List<ETradingEnablement__c>)Database.query(query);
		}
		return ETradingEnablementList;
    }

    public static ETradingEnablement__c createETradingCoverage(ETradingEnablement__c eTradingRequest, ContactPlatform__c oContPlat) {
    	System.debug('#### ETradingEnablementService::createETradingCoverage()');
    	System.debug('eTradingRequest : '+eTradingRequest);
    	System.debug('oContPlat : '+oContPlat);
    	ETradingEnablement__c eTradingCoverage;
    	if(eTradingRequest!=null && oContPlat!=null) {
    		eTradingCoverage = new ETradingEnablement__c();
			eTradingCoverage.RecordTypeId = ETERecTypeInfoByRecTypeDevNameMap.get(ETE_RT_NAME_COVERAGE).getRecordTypeId();
			eTradingCoverage.Parent_Request__c = eTradingRequest.Id;
			eTradingCoverage.Status__c = 'Active';
			eTradingCoverage.Contact__c = eTradingRequest.Contact__c;
			eTradingCoverage.Electronic_Platform__c = eTradingRequest.Electronic_Platform__c; 
			eTradingCoverage.ETradingEnablementProduct__c = eTradingRequest.ETradingEnablementProduct__c;
			eTradingCoverage.Sales_Team_for_Coverage__c = eTradingRequest.Sales_Team_for_Coverage__c;
			eTradingCoverage.Contact_Platform__c = oContPlat.Id;
			eTradingCoverage.Platform_Id__c = oContPlat.Name;

			// copy Clearing, Bilateral and RDM 
			eTradingCoverage.Clearing__c = eTradingRequest.Clearing__c;
			eTradingCoverage.Clearing_House__c = eTradingRequest.Clearing_House__c;
			eTradingCoverage.Bilateral__c = eTradingRequest.Bilateral__c;
			eTradingCoverage.Collateral_Type__c = eTradingRequest.Collateral_Type__c;
			eTradingCoverage.Global_Margin_Requirements__c = eTradingRequest.Global_Margin_Requirements__c;
			eTradingCoverage.Tenor_Restriction__c = eTradingRequest.Tenor_Restriction__c;
			eTradingCoverage.Collateral_Currencies__c = eTradingRequest.Collateral_Currencies__c;
			eTradingCoverage.Break_Clause__c = eTradingRequest.Break_Clause__c;
			eTradingCoverage.Cash_RDM__c = eTradingRequest.Cash_RDM__c;
			eTradingCoverage.Cash_RDM_Entity__c	 = eTradingRequest.Cash_RDM_Entity__c;
			eTradingCoverage.IRS_RDM__c = eTradingRequest.IRS_RDM__c;
			eTradingCoverage.IRS_RDM_Entity__c = eTradingRequest.IRS_RDM_Entity__c;
			eTradingCoverage.Repo_RDM__c = eTradingRequest.Repo_RDM__c;
			eTradingCoverage.Repo_RDM_Entity__c = eTradingRequest.Repo_RDM_Entity__c;
    	}
    	System.debug('eTradingCoverage : '+eTradingCoverage);
		return eTradingCoverage;
	}
    
	public static void createRevokeETradingRequests(List<String> ETradingCoverageIdList, String revokeComment) {
		System.debug('#### ETradingEnablementService::createRevokeETradingRequests()');
		try{
			if(ETradingCoverageIdList!=null && !ETradingCoverageIdList.isEmpty()) {
				List<ETradingEnablement__c> ETradingRevokeReqList = new List<ETradingEnablement__c>();
				List<ETradingEnablement__c> ETradingCoverageList = getETradingRecords(ETradingCoverageIdList);
				System.debug('ETradingCoverageList : '+ETradingCoverageList);
				for(ETradingEnablement__c oETCov : ETradingCoverageList) {
					ETradingRevokeReqList.add(new ETradingEnablement__c(
						Request_Type__c = 'Revoke',
						Parent_Coverage__c = oETCov.Id,
						RecordTypeId = ETERecTypeInfoByRecTypeDevNameMap.get(ETE_RT_NAME_REQUEST).getRecordTypeId(),
						Contact__c = oETCov.Contact__c,
						Electronic_Platform__c = oETCov.Electronic_Platform__c,
						ETradingEnablementProduct__c = oETCov.ETradingEnablementProduct__c,
						Sales_Team_for_Coverage__c = oETCov.Sales_Team_for_Coverage__c,
						Contact_Platform__c = oETCov.Contact_Platform__c,
						Platform_Id__c = oETCov.Platform_Id__c,
						Comments__c = revokeComment)
					); 
				}
				if(!ETradingRevokeReqList.isEmpty()) {
					insert ETradingRevokeReqList;
				}
			}
		} catch(Exception ex) {
			System.debug('ETradingEnablementService::createRevokeETradingRequests() : Error : '+ex.getMessage());
            System.debug('ETradingEnablementService::createRevokeETradingRequests() : Error Stack : '+ex.getStackTraceString());
            throw new ETradingEnablementServiceException('Error Occured in ETradingEnablementService::createRevokeETradingRequests() : '+ex.getMessage());
		}
	}

	public static List<ETradingEnablement__c> getETradingRecords(List<String> ETradingIdList) {
    	System.debug('#### ETradingEnablementService::getETradingRecords()');
    	List<ETradingEnablement__c> ETradingEnablementList = new List<ETradingEnablement__c>(); 
    	if(ETradingIdList!=null && !ETradingIdList.isEmpty()) {
	    	ETradingEnablementList = [SELECT Id,Name,Contact__c,Contact__r.Name,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Name,
	    		Electronic_Platform__c,ETradingEnablementProduct__c,ETradingEnablementProduct__r.Name,
				Status__c,Platform_Account__c,Contact__r.RG_Account__r.Name, Platform_Id__c, Contact__r.Developer_Reference__c,
				Platform_First_Name__c, Platform_Last_Name__c, Platform_Email__c, Contact_Platform__c
			  FROM ETradingEnablement__c
			  WHERE Id IN :ETradingIdList];	
    	}
    	return ETradingEnablementList;
    }
    
    public without sharing class QueryWithoutSharing 
	{
		public void insertEtradingEnablements(List<ETradingEnablement__c> ETradingEnablementList){
			insert ETradingEnablementList;	
		}
		
		public Database.SaveResult[] updateETEnablementRecs(
    		List<ETradingEnablement__c> ETradingEnablementList, Boolean allOrNone) {
	        Database.SaveResult[] srList = Database.Update(ETradingEnablementList, allOrNone);        
	        return srList;
    	}
		
		// require to pass dynamic SOQL varibles into method to bind on query 
	    public List<ETradingEnablement__c> getWithoutSharingRecords(
	    	String queryWithoutSharing, String recTypeId, List<String> SalesCodeIDList,
	    	List<String> ETEnablementStatusList, String currentUserId, Set<String> ContactRelatedoAccIDSet,
	    	List<String> ETEnablementPlatformList, List<String> ETEnablementProductIdList)
		{
	        List<ETradingEnablement__c> ETradingEnablementList = Database.query(queryWithoutSharing);  
	                
	    	return ETradingEnablementList;
	    }
	}
	
	
	/*OLD CODE Leave it commented 
	public static void populateRecordType(Map<Id, ETradingEnablement__c> OldETradingEnablementMap, 
										List<ETradingEnablement__c> NewETradingEnablementList)  {
		System.debug('#### ETradingEnablementService::populateRecordType()');
		try{
			Boolean isInsert = (OldETradingEnablementMap==null);
			if(isInsert) {
				for(ETradingEnablement__c oETEnablement : NewETradingEnablementList) {
					if(String.isBlank(oETEnablement.RecordTypeId) &&
								String.isNotBlank(oETEnablement.Request_Stage__c)) {
						if(oETEnablement.Request_Stage__c=='Open') {
							oETEnablement.RecordTypeId = ETERecTypeInfoByRecTypeDevNameMap.get(ETE_RT_NAME_REQUEST).getRecordTypeId();
						} else if(oETEnablement.Request_Stage__c=='Complete') {
							oETEnablement.RecordTypeId = ETERecTypeInfoByRecTypeDevNameMap.get(ETE_RT_NAME_COVERAGE).getRecordTypeId();	
						}
					}
				}
			}
		} catch(Exception ex) {
			System.debug('ETradingEnablementService::populateRecordType() : Error : '+ex.getMessage());
            System.debug('ETradingEnablementService::populateRecordType() : Error Stack : '+ex.getStackTraceString());
            throw new ETradingEnablementServiceException('Error Occured in ETradingEnablementService::populateRecordType() : '+ex.getMessage());
		}
	}*/
	
	public static void populateStatusAndRecordType(Map<Id, ETradingEnablement__c> OldETradingEnablementMap, 
										List<ETradingEnablement__c> NewETradingEnablementList)  {
		System.debug('#### ETradingEnablementService::populateStatusAndRecordType()');
		try{
			Boolean isInsert = (OldETradingEnablementMap==null);
			if(isInsert) {
				for(ETradingEnablement__c oETEnablement : NewETradingEnablementList) {
					System.debug('oETEnablement.RecordTypeId : '+oETEnablement.RecordTypeId);
					if(oETEnablement.RecordTypeId != ETERecTypeInfoByRecTypeDevNameMap.get(ETE_RT_NAME_COVERAGE).getRecordTypeId()) {
						oETEnablement.RecordTypeId = ETERecTypeInfoByRecTypeDevNameMap.get(ETE_RT_NAME_REQUEST).getRecordTypeId();
						if(oETEnablement.Request_Stage__c=='Open') {
							oETEnablement.Status__c = 'On Hold';
						} else if(oETEnablement.Request_Stage__c=='Complete') {
							oETEnablement.Status__c = 'Complete';
						}
					}
				}
			}
		} catch(Exception ex) {
			System.debug('ETradingEnablementService::populateStatusAndRecordType() : Error : '+ex.getMessage());
            System.debug('ETradingEnablementService::populateStatusAndRecordType() : Error Stack : '+ex.getStackTraceString());
            throw new ETradingEnablementServiceException('Error Occured in ETradingEnablementService::populateStatusAndRecordType() : '+ex.getMessage());
		}
	}
	
	public static void populateSalesCode(Map<Id, ETradingEnablement__c> OldETradingEnablementMap, 
										List<ETradingEnablement__c> NewETradingEnablementList)  {
		System.debug('#### ETradingEnablementService::populateSalesCode()');
		try{
			Boolean isInsert = (OldETradingEnablementMap==null);
			Set<String> SalesCodeSet = new Set<String>();
			if(isInsert) {
				for(ETradingEnablement__c oETEnablement : NewETradingEnablementList) {
					if(oETEnablement.RecordTypeId != ETERecTypeInfoByRecTypeDevNameMap.get(ETE_RT_NAME_COVERAGE).getRecordTypeId()) {
						if(String.isBlank(oETEnablement.Sales_Team_for_Coverage__c) && String.isNotBlank(oETEnablement.Platform_Sales_Code__c)) {
							SalesCodeSet.add(oETEnablement.Platform_Sales_Code__c);
						}
					}
				}
				
				Map<String, Sales_Team_for_Coverage__c> SalesTeamForCoverageBySalesCodeMap = 
						SalesTeamForCoverageService.getSalesTeamCoverageForSalesCode(SalesCodeSet);
				
				if(!SalesTeamForCoverageBySalesCodeMap.isEmpty()) {
					for(ETradingEnablement__c oETEnablement : NewETradingEnablementList) {
						if(String.isNotBlank(oETEnablement.Platform_Sales_Code__c)) {
							Sales_Team_for_Coverage__c oSTCov = SalesTeamForCoverageBySalesCodeMap.get(oETEnablement.Platform_Sales_Code__c);
							oETEnablement.Sales_Team_for_Coverage__c = (oSTCov!=null) ? oSTCov.Id : null;   
						}
					}
				}
			}
		} catch(Exception ex) {
			System.debug('ETradingEnablementService::populateSalesCode() : Error : '+ex.getMessage());
            System.debug('ETradingEnablementService::populateSalesCode() : Error Stack : '+ex.getStackTraceString());
            throw new ETradingEnablementServiceException('Error Occured in ETradingEnablementService::populateSalesCode() : '+ex.getMessage());
		}										
	}
	
	public static void populateProduct(Map<Id, ETradingEnablement__c> OldETradingEnablementMap, 
										List<ETradingEnablement__c> NewETradingEnablementList)  {
		System.debug('#### ETradingEnablementService::populateProduct()');
		try{
			Boolean isInsert = (OldETradingEnablementMap==null);
			Set<String> ProductAPINameSet = new Set<String>();
			if(isInsert) {
				for(ETradingEnablement__c oETEnablement : NewETradingEnablementList) {
					if(oETEnablement.RecordTypeId != ETERecTypeInfoByRecTypeDevNameMap.get(ETE_RT_NAME_COVERAGE).getRecordTypeId()) {
						if(String.isBlank(oETEnablement.ETradingEnablementProduct__c) && String.isNotBlank(oETEnablement.Platform_Product__c)) {
							ProductAPINameSet.add(oETEnablement.Platform_Product__c);
						}
					}
				}
				
				if(!ProductAPINameSet.isEmpty()) {
					List<ETradingEnablementProduct__c> ETProductList = [SELECT Id, Name, Product__c, ProductLabel__c 
						FROM ETradingEnablementProduct__c 
						WHERE Product__c IN :ProductAPINameSet];
					
					Map<String, ETradingEnablementProduct__c> ETProductByProductAPINameMap = new Map<String, ETradingEnablementProduct__c>(); 
					for(ETradingEnablementProduct__c oETProd : ETProductList) {
						ETProductByProductAPINameMap.put(oETProd.Product__c, oETProd);
					}
					
					if(!ETProductByProductAPINameMap.isEmpty()) {
						for(ETradingEnablement__c oETEnablement : NewETradingEnablementList) {
							if(String.isNotBlank(oETEnablement.Platform_Product__c)) {
								ETradingEnablementProduct__c oETProd = ETProductByProductAPINameMap.get(oETEnablement.Platform_Product__c);
								oETEnablement.ETradingEnablementProduct__c = (oETProd!=null) ? oETProd.Id : null;   
							}
						}
					}
				}
			}
		} catch(Exception ex) {
			System.debug('ETradingEnablementService::populateProduct : Error : '+ex.getMessage());
            System.debug('ETradingEnablementService::populateProduct : Error Stack : '+ex.getStackTraceString());
            throw new ETradingEnablementServiceException('Error Occured in ETradingEnablementService::populateProduct() : '+ex.getMessage());
		}										
	}
	
	public static void populateContact(Map<Id, ETradingEnablement__c> OldETradingEnablementMap, 
										List<ETradingEnablement__c> NewETradingEnablementList)  {
		System.debug('#### ETradingEnablementService::populateContact()');
		try{
			Boolean isInsert = (OldETradingEnablementMap==null);
			Set<String> UniquePlatformIdSet = new Set<String>();
			if(isInsert) {
				for(ETradingEnablement__c oETEnablement : NewETradingEnablementList) {
					if(oETEnablement.RecordTypeId != ETERecTypeInfoByRecTypeDevNameMap.get(ETE_RT_NAME_COVERAGE).getRecordTypeId()) {
						if(String.isBlank(oETEnablement.Contact__c) &&
								String.isNotBlank(oETEnablement.Electronic_Platform__c) && String.isNotBlank(oETEnablement.Platform_Id__c)) {
							String key = oETEnablement.Electronic_Platform__c +'-'+ oETEnablement.Platform_Id__c;
							UniquePlatformIdSet.add(key);
						}
					}
				}
				
				Map<String, ContactPlatform__c> ContPlatformByPlatIdUnqKeyMap = new Map<String, ContactPlatform__c>();
				if(!UniquePlatformIdSet.isEmpty()) {
					List<ContactPlatform__c> ContPlatformList = [SELECT Id, Name, Contact__c, Email__c, 
							External_Id__c, Platform__c, Status__c
						FROM ContactPlatform__c
						WHERE External_Id__c IN :UniquePlatformIdSet AND Status__c = 'Active'];
					 
					for(ContactPlatform__c oContPlat : ContPlatformList) {
						ContPlatformByPlatIdUnqKeyMap.put(oContPlat.External_Id__c, oContPlat);
					}
				}
					
				for(ETradingEnablement__c oETEnablement : NewETradingEnablementList) {
					if(String.isBlank(oETEnablement.Contact__c)) {
						String key = oETEnablement.Electronic_Platform__c +'-'+ oETEnablement.Platform_Id__c;
						ContactPlatform__c oContPlatform = ContPlatformByPlatIdUnqKeyMap.get(key);
						if(oContPlatform!=null) {
							oETEnablement.Contact__c = oContPlatform.Contact__c;
							// Commented as this field is going to be deleted - oETEnablement.Contact_Platform__c = oContPlatform.Id;
						} else {
							oETEnablement.Contact__c = ContactService.getUnassignedContactId();
						}   
					}
				}
			}
		} catch(Exception ex) {
			System.debug('ETradingEnablementService::populateContact : Error : '+ex.getMessage());
            System.debug('ETradingEnablementService::populateContact : Error Stack : '+ex.getStackTraceString());
            throw new ETradingEnablementServiceException('Error Occured in ETradingEnablementService::populateContact() : '+ex.getMessage());
		}
	}
	
	public class ETradingEnablementServiceException extends Exception {}
}