/*
	Author      : Sagar Kambli
	Company     : Nomura 
	Date        : 06/07/2018
    Description : RM Feed Job (Batch 8)
				//a.	Batch 1: Process Daily_RMFeed_Job_Contacts (RM Contacts to NEW RG)
				//b.	Batch 2: Process Daily_RMFeed_Job_Events (Events to NEW RG)
				//c.	Batch 3: Process Daily_RMFeed_Job_Tasks (Tasks to NEW RG)
				//d.	Batch 4: Process Daily_RMFeed_Job_Opportunity (Opportunity)
				//e.	Batch 5: Process Daily_RMFeed_Job_InstinetChampion
				//f.	Batch 6: Process Daily_RMFeed_Job_InstinetCoverage
				//g.    Batch 7.1: Process Daily_QueryCvgTeamMemberRequestType (Query Coverage records to update label as RG/RM)
                //h.    Batch 7.2: Process Daily_UpdateCvgTeamMemberRequestType (Update Coverage records label as RG/RM))
				i.		Batch 8: Process Daily_RMFeed_Job_Coverage_Movement (Coverage Movement @ RG Salesperson)
				//j.	Batch 9: Process Daily_RMFeed_Job_Coverage_Movement_RM (Coverage Movement @ RM Salesperson)
				//k.	Batch 10: Process Daily_RMFeed_Coverage_Movement_End
				//l.	Batch 11: Process Daily_RMFeed_Coverage_Movement_Insert
                //m.    Batch 12. Process Daily_RMFeed_Job_Clear (Reset RM Movement flag)
				//n.    Batch 13.1: Process Daily_QueryCvgTeamMemberRequestType (Chaining Batch 7.1 Job)
                //o.    Batch 13.2: Process Daily_UpdateCvgTeamMemberRequestType (Chaining Batch 7.2 Job)
				//p.	Batch 14: Process Daily_RMFeed_Job_Coverage_NewRM
				//q.	Batch 15: Process Daily_RMFeed_Coverage_NewRM_Insert
				//r.    Batch 16. Process Daily_RMFeed_Job_Clear (Reset new RM flag - Chaning Batch 12)
                //s.    Batch 17. Process Daily_RMPODLinkStartBatch
                //t.    Batch 18. Process Daily_RMPodLinkProcessBatch
                //u.    Batch 19. Process Daily_RMPodLinkEndBatch
                //v.    Batch 20. Process Daily_DeletePODCoverage
*/
global class Daily_RMFeed_Job_Coverage_Movement implements Database.batchable<sObject>, Database.Stateful{ 
    
    //COMPARE THIS CODE
	/**** GLOBAL VARIABLES *******/
	String main_query = '';
    String exception_message = '';
    Boolean hasRMFeedError = false;
    Boolean batchExecutionSuccessfully = true;
    List<Coverage_Team_Member__c> coveragesToDeactivate = new List<Coverage_Team_Member__c>();
    Map<string,Coverage_Team_Member__c> create_Coverage_map = new Map<string,Coverage_Team_Member__c>();
    Set<string> coveragesToBeHardDeleted = new Set<string>(); 
    String coverage_schema_query = ObjectUtil.getCreatableFieldsSOQL('Coverage_Team_Member__c','');
	Id RMAccountRecordTypeId = CommonTools.getRecordTypeId('Account', 'RM Account');
	Id InactiveCoverageRecordTypeId = CommonTools.getRecordTypeId('Coverage_Team_Member__c', 'Inactive Coverage');
    Set<Id> movedRMIds = new Map<Id,Account>([SELECT Id FROM Account where RecordtypeId =:RMAccountRecordTypeId and isRMChanged__c = true and Active__c = true]).keyset();
    List<string> salescode_company_to_exclude = CoverageUtil.salescode_company_to_exclude;		      
	List<string> productsaccessforInstinet = CoverageUtil.productsWithRegionsToIncludeForInstinet;

	//SALES-3653 for Reason for Coverege deletion
	String strReason = 'RM Movement';	
    
	/**** BATCH CONSTRUCTOR *******/
	public Daily_RMFeed_Job_Coverage_Movement(Boolean hasRMFeedError){
	    this.hasRMFeedError = hasRMFeedError;
        ////if(test.isRunningTest())
		//////////	main_query = 'SELECT Id FROM Account where RecordtypeId =:RMAccountRecordTypeId and isRMChanged__c = true and Active__c = true limit 1';
        ////else
			main_query = 'SELECT Id FROM Account where RecordtypeId =:RMAccountRecordTypeId and isRMChanged__c = true and Active__c = true '; 
        //main_query = 'SELECT Id FROM Account where rdm_org_id__c = \'RM270137\''; 
        
    }
	
    
    /**** BATCH START *******/
	global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(main_query);
    }
	
    
	 /**** BATCH EXECUTE *******/
    global void execute(Database.batchableContext info, List<sObject> scope){
       
		try
        {      
        	Account sourceRM;
            Id oldrmid;
            Id newRGid;
			String query = '';
			String unique_id = '';
			Date currentdate = system.today();
			
			Map<string,Coverage_Team_Member__c> sourceCoverage_uniqueKey_Coverage_map = new Map<string,Coverage_Team_Member__c>();
            Map<string,Id> rmIdbyOrgId = new Map<string,Id>();
		    
			Map<string,Coverage_Team_Member__c> destinationCoverage_uniqueKey_Coverage_map = new Map<string,Coverage_Team_Member__c>();
			Map<string,Set<string>> destinationRMKeyMap  = new Map<string,Set<string>>();
			Set<String> destinationCodeAndAccountIdSet = new Set<String>(); 
            Map<Id,User> destinationSalesCodeAndUserMapRM = new Map<Id,User>();
            
			List<Coverage_Team_Member__c> sourceCoverages = new List<Coverage_Team_Member__c>();
			List<Coverage_Team_Member__c> destinationCoverages = new List<Coverage_Team_Member__c>();
			
			String salescode = '';
			String salescodeId = '';
			String sourceUniqueId = '';
			String sourcePartialId = '';
			String sourcePartialIdwoRM = '';
			String sourceSalesCode  = '';
			String destinationSalesCode = '';
            String destinationSalesCodeId = '';
			String destinationUniqueKey = '';                        
			String destinationPartialId = '';
			String hardDeleteKeyforProductCoverage = '';
			String destinationUniqueId = '';
			String destinationPartialIdwoRM = '';
			boolean isDummy = false;
			boolean needToCreate = false;
			String tobeCreatedKey_partial = '';
			
			
			/**** SOURCE COVERAGE *******/
			/* Create Source maps
			*  Create final deactivate map
			*/
		    Set<Id> rmIdToProcess = (new Map<Id,SObject>(scope)).keySet();
            system.debug(rmIdToProcess);
			query = coverage_schema_query;
            query += ' where Account__c in:rmIdToProcess and (NOT UniqueId__c like \'%#Equity#Flow Derivatives - USA%\') and recordType.Name = \'Active Coverage\' and  (Sales_Team_for_Coverage__r.Company__c not in:salescode_company_to_exclude or Product_Including_Region__c in:productsaccessforInstinet) and Sales_Team_for_Coverage__r.Active__c = true and (Sales_Team_for_Coverage__r.Desk_SearchKey__c not in(\'Equity-USA-Flow Derivatives (USA)\',\'Fixed Income-USA-Credit Sales (Amer)\')) and Sales_Team_for_Coverage__r.Coverage_Maintenance_Level__r.Sales_Client_Hierarchy_Level__c = \'RG\'';
            sourceCoverages =(List<Coverage_Team_Member__c>)Database.query(query);
			System.debug('**Source Query: '+sourceCoverages);
            for(Coverage_Team_Member__c coverage :sourceCoverages)
            { 
				unique_id = '';
                system.debug('parent Id ::'+coverage.Account__r.ParentId );
                system.debug('parent Id ::'+coverage.Account__r.RDM_Org_ID__c );
                 system.debug('parent Id ::'+ coverage.RG_Account__c);
                //added for JIRA 3163 check if the new RG is not equal to old RG
                if(coverage.Account__r.ParentId != coverage.RG_Account__c){
                    
                    if(sourceRM == null){
                        sourceRM = coverage.Account__r;
                    }
                    
                    if(oldrmid == null) {
                         system.debug(sourceRM.rdm_org_id__c);
                        oldrmid = sourceRM.Id;
                        newRGid = sourceRM.Current_RG__c;
                    }
					
					unique_id = coverage.UniqueId__c;
					coverage.is_Deleted__c = true;
                    coverage.End_Date__c =  coverage.Start_Date__c > currentdate ? coverage.Start_Date__c : currentdate;
                    sourceCoverage_uniqueKey_Coverage_map.put(unique_id,coverage.clone(false,true));
                    coverage.RecordTypeId = InactiveCoverageRecordTypeId;
                    coverage.UniqueId__c = unique_id.replace('FALSE','TRUE'); 
					//SALES-3653 Set the reason value
					coverage.Reason__c = strReason;
					coveragesToDeactivate.add(coverage);
					
					if(sourceRM!=null)
					rmIdbyOrgId.put(sourceRM.RDM_Org_ID__c,sourceRM.Id);
                }
            }
            system.debug('coveragesToDeactivate ::'+ coveragesToDeactivate);
            /**** DESTINATION COVERAGE *******/
			/* Create Destination maps
			*  Create destination coverage map
			* Create destinationRMKeyMap map
			*/
            system.debug(newRGid);
            if(newRGid==null){
                List<Account> accountsMoved = [SELECT Id, RDM_Org_ID__c, Current_RG__c, Restricted_Flag__c, Domicile_Country__c FROM Account where Id in :rmIdToProcess limit 1];
                if(accountsMoved.size() > 0){
                    sourceRM = accountsMoved.get(0);
                    newRgid = sourceRM.Current_RG__c;
                    system.debug('sourceRM : '+ sourceRM.RDM_Org_ID__c);
                }
            }
		    if(newRGid!=null){
				query = coverage_schema_query;
				unique_id = '';
				query += ' where Account__r.ParentId =:newRGid and Account__r.Active__c = TRUE and (Sales_Team_for_Coverage__r.Company__c not in:salescode_company_to_exclude or Product_Including_Region__c in:productsaccessforInstinet) and Account__c !=:movedRMIds and (NOT UniqueId__c like \'%#Equity#Flow Derivatives - USA%\') and RecordType.Name=\'Active Coverage\' and Sales_Team_for_Coverage__r.Active__c = true and (Sales_Team_for_Coverage__r.Desk_SearchKey__c not in(\'Equity-USA-Flow Derivatives (USA)\',\'Fixed Income-USA-Credit Sales (Amer)\')) and Sales_Team_for_Coverage__r.Coverage_Maintenance_Level__r.Sales_Client_Hierarchy_Level__c = \'RG\'';
				destinationCoverages =(List<Coverage_Team_Member__c>)Database.query(query); 
				System.debug('**Destination query: '+destinationCoverages);
            	for(Coverage_Team_Member__c coverage :destinationCoverages){
                        unique_id  = coverage.UniqueId__c;
                        salescode = coverage.Sales_Team_for_Coverage__r.Coverage_ID__c;
                        salescodeId = coverage.Sales_Team_for_Coverage__c;
                        destinationCoverage_uniqueKey_Coverage_map.put(unique_id,coverage.clone(false,true));
                        
                        if(destinationRMKeyMap.get(salescode)==null)
                            destinationRMKeyMap.put(salescode,new Set<string>{coverage.Account__r.RDM_Org_ID__c});
                        else    
                            destinationRMKeyMap.get(salescode).add(coverage.Account__r.RDM_Org_ID__c);
                        
                        rmIdbyOrgId.put(coverage.Account__r.RDM_Org_ID__c,coverage.Account__c);
                        destinationCodeAndAccountIdSet.add(salescodeId+'#'+sourceRM.Id);   
              	}
				
				/* Get requested for User for destination salescodes
				*/
				if(destinationCodeAndAccountIdSet.size() > 0)
				{
					Map<Id,Account> accountMap = new Map<Id,Account>();
					accountMap.put(sourceRM.Id, sourceRM);
					destinationSalesCodeAndUserMapRM = CoverageRequestUtility.fetchRequestedForUserForRMRequest(destinationCodeAndAccountIdSet, accountMap);
				}
				
				//Create coverage from source towards destination if it covers
				   for(Coverage_Team_Member__c sourceCoverage : sourceCoverage_uniqueKey_Coverage_map.values()){
					   System.debug('**sourceCoverage: '+sourceCoverage);
                       sourceUniqueId = sourceCoverage.UniqueId__c;
                       sourcePartialId = sourceUniqueId.replace('#FALSE','');
                       sourcePartialIdwoRM = sourcePartialId.replace(sourceCoverage.Account__r.RDM_Org_ID__c,'');
                       sourceSalesCode = sourceCoverage.Sales_Team_for_Coverage__r.Coverage_ID__c;
                       needToCreate = false;
                       
						// Step 1: create only if salesperson of source covers at destination ?
						for(Coverage_Team_Member__c destinationCoverage : destinationCoverage_uniqueKey_Coverage_map.values()){
							destinationSalesCode = destinationCoverage.Sales_Team_for_Coverage__r.Coverage_ID__c;
							if(destinationSalesCode == sourceSalesCode){
								needToCreate = true;
								break;
							} 
						}
						
						
						
						if(needToCreate){
							// Step 2: create active source coverage with current date as startdate
							sourceCoverage.Start_Date__c = currentdate;
							sourceCoverage.End_Date__c = null;
							sourceCoverage.Called_from__c ='';
							sourceCoverage.Id = null;
							sourceCoverage.Is_Deleted__c = false;
							create_Coverage_map.put(sourceUniqueId, sourceCoverage);
							
							// Step 3: create destination coverage from source RM coverage
							if(destinationRMKeyMap.get(sourceSalesCode)!=null){
								for(string destinationRMKey : destinationRMKeyMap.get(sourceSalesCode)){
                                	destinationUniqueKey = sourceUniqueId.replace(sourceCoverage.Account__r.RDM_Org_ID__c,destinationRMKey);                        
									destinationPartialId = destinationUniqueKey.replace('#FALSE','');
									Coverage_Team_Member__c newCoverage = sourceCoverage.clone(false,true);
									newCoverage.UniqueId__c = destinationUniqueKey;
									newCoverage.Account__c = rmIdbyOrgId.get(destinationRMKey);
									newCoverage.Start_Date__c = currentdate;
									newCoverage.End_Date__c =null;
									newCoverage.Called_from__c ='';
									newCoverage.Is_Deleted__c = false;
								   
									//Put for hard deletion if creation coverage already exist in destination Coverage?
									hardDeleteKeyforProductCoverage = '';
									if(newCoverage.Product2__c!=null) //RM12345674#wegeners#6822#Fixed Income#AGENCY MORTGAGES - Japan#FALSE
										hardDeleteKeyforProductCoverage = destinationRMKey+'#'+newCoverage.Sales_Team_for_Coverage__r.Sales_Code_Login_Id__c+'#'+newCoverage.Sales_Team_for_Coverage__r.Coverage_ID__c+'#FALSE';
									
									if(destinationCoverage_uniqueKey_Coverage_map.keyset().contains(hardDeleteKeyforProductCoverage))
										coveragesToBeHardDeleted.add(hardDeleteKeyforProductCoverage);
								
									newCoverage.Id = null;
									create_Coverage_map.put(newCoverage.UniqueId__c, newCoverage);
								} 
							}
						}
					}
					
				//Create coverage from destination towards source if it covers
				   for(Coverage_Team_Member__c destinationCoverage : destinationCoverage_uniqueKey_Coverage_map.values()){
						destinationUniqueId = destinationCoverage.UniqueId__c;
						destinationPartialId = destinationUniqueId.replace('#FALSE','');
						destinationPartialIdwoRM = destinationPartialId.replace(destinationCoverage.Account__r.RDM_Org_ID__c,'');
						needtoCreate = false; // new change 
						isDummy = destinationCoverage.Sales_Team_For_Coverage__r.Is_dummy__c;
						destinationSalescode = destinationCoverage.Sales_Team_for_Coverage__r.Coverage_ID__c;
						destinationSalescodeId = destinationCoverage.Sales_Team_for_Coverage__c;
						
						// Step 1: create only if salesperson of destination covers at source ?
						for(Coverage_Team_Member__c sourceCoverage : sourceCoverage_uniqueKey_Coverage_map.values()){
							sourceSalesCode = sourceCoverage.Sales_Team_for_Coverage__r.Coverage_ID__c;                    
							if(destinationSalesCode == sourceSalesCode){
								needToCreate = true;
								break;
							} 
						}
						
						// Step 2: destination does not covers at source ?
						if(!needToCreate){
							if(sourceRM.Restricted_Flag__c) // if restricted
							{
								if(destinationSalesCodeAndUserMapRM.get(destinationSalescodeId)!=null){
									
									if(destinationSalesCodeAndUserMapRM.get(destinationSalescodeId).CountryCode == sourceRM.Domicile_Country__c &&
										!isDummy)
									{
										needtoCreate = true;   
									}
								}
							}
							else
							{
								needtoCreate = true;
							}
						}
						
						if(needtoCreate){
							Coverage_Team_Member__c newCoverage = destinationCoverage.clone(false,true);
                            system.debug('destinationUniqueId : '+ destinationUniqueId);
                            system.debug('destinationUniqueId : '+ destinationCoverage.Account__r.RDM_Org_ID__c);
                            system.debug('destinationUniqueId : '+ sourceRM.rdm_org_ID__c);
                            system.debug('destinationUniqueId : '+ sourceRM.Id);
							newCoverage.UniqueId__c = destinationUniqueId.replace(destinationCoverage.Account__r.RDM_Org_ID__c,sourceRM.rdm_org_ID__c);
							newCoverage.Account__c = sourceRM.Id;
							newCoverage.Start_Date__c = currentdate;
							newCoverage.End_Date__c =null;
							newCoverage.Called_from__c ='';
							newCoverage.Is_Deleted__c = false;
							newCoverage.Id = null;
                            system.debug('destinationUniqueId : '+ newCoverage.UniqueId__c);
                            system.debug('destinationUniqueId : '+ newCoverage.Account__r.rdm_org_id__c);
                            system.debug('destinationUniqueId : '+ newCoverage.Account__c);
							create_Coverage_map.put(newCoverage.UniqueId__c, newCoverage);
						}                          
					}

					System.debug('create_Coverage_List size: '+create_Coverage_map.size());
                    System.debug('create_Coverage_List : '+create_Coverage_map);
             
					//Remove duplicates from destination if it exist
					boolean found = false;
					for(string tobeCreatedKey: create_Coverage_map.keyset()){ 
						tobeCreatedKey_partial = tobeCreatedKey.replace('#FALSE', '').trim();
						found = false;
						
						for(string destinationKey: destinationCoverage_uniqueKey_Coverage_map.keySet()){
							if(destinationKey.contains(tobeCreatedKey_partial)){
								found = true;
								break;
							}
						}
						
						if(!found){
							for(string tobeCreatedKey1: create_Coverage_map.keySet()){
					
								if(tobeCreatedKey1.contains(tobeCreatedKey_partial) && tobeCreatedKey1!=tobeCreatedKey){
									found = true;
									break;
								}
							}
						}
						
						if(found)
						{
							If(create_Coverage_map.get(tobeCreatedKey)!=null)
							{
								create_Coverage_map.remove(tobeCreatedKey);
							}
							
						}
					}
					
                	//clear out local variables
					if(sourceCoverage_uniqueKey_Coverage_map!=null)
					sourceCoverage_uniqueKey_Coverage_map.clear();
					if(destinationCoverage_uniqueKey_Coverage_map!=null)
					destinationCoverage_uniqueKey_Coverage_map.clear();
					if(rmIdbyOrgId!=null)
					rmIdbyOrgId.clear();
					if(destinationRMKeyMap!=null)
					destinationRMKeyMap.clear();
					if(destinationCodeAndAccountIdSet!=null)
					destinationCodeAndAccountIdSet.clear();
					if(destinationSalesCodeAndUserMapRM!=null)
					destinationSalesCodeAndUserMapRM.clear();
					if(sourceCoverages!=null)
					sourceCoverages.clear();
					if(destinationCoverages!=null)
					destinationCoverages.clear();
					if(rmIdToProcess!=null)
					rmIdToProcess.clear();
            }
                 
        }
        catch(Exception e)
        {
            exception_message += e+'\n'+e.getStackTraceString();
            exception_message += '\n';
            batchExecutionSuccessfully = false;
        }
    }
    
    global void finish(Database.batchableContext info){  
       
		if(!batchExecutionSuccessfully)
        {
            system.debug('Exception processing Coverage Movement Feed.....');
            system.debug(exception_message);
            CommonTools.emailLog('FAILURE','RM Feed Daily JOB - Daily_RMFeed_Job_Coverage_Movement',exception_message+'\n\nRegards,\nSalesforce Tech',null,'TECH');
        }
		
		/*system.debug('-------------------------------COVERAGES TO BE CREATED-------------------------------------');
		for(string newkeys1: create_Coverage_map.keyset()){
			system.debug(newkeys1);
		}
		
		
		system.debug('-------------------------------COVERAGES TO BE HARD DELETED-------------------------------------');
		for(Coverage_Team_Member__c tm: [select id,uniqueid__c from Coverage_Team_Member__c where uniqueId__c in:coveragesToBeHardDeleted]){
			system.debug(tm.uniqueid__c);
		}
		
		system.debug('-------------------------------COVERAGES TO BE END DATED-------------------------------');
		for(Coverage_Team_Member__c tm1 :coveragesToDeactivate)
		{ 
			system.debug(tm1.uniqueid__c);
		}*/
		
		List<Coverage_Team_Member__c> harddeleteDestinationCoverages = [select id from Coverage_Team_Member__c where uniqueId__c in:coveragesToBeHardDeleted];
		if(harddeleteDestinationCoverages.size()>0)
		  delete harddeleteDestinationCoverages;       
        for(Coverage_Team_Member__c cov: create_Coverage_map.values()){
            system.debug('values :: '+cov.UniqueId__c);
            system.debug('values :: '+cov.Account__r.rdm_org_id__c);
        }
		System.debug('create_Coverage_List size: '+create_Coverage_map.size());
		System.debug('create_Coverage_List : '+create_Coverage_map);
		
		Database.executeBatch(new Daily_RMFeed_Job_Coverage_Movement_RM(coveragesToDeactivate,create_Coverage_map.values(),hasRMFeedError), 1);
		
   
	}
}