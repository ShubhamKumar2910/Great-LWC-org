/*
    Description : RM Feed Job (Batch 9)
				//a.	Batch 1: Process Daily_RMFeed_Job_Contacts (RM Contacts to NEW RG)
				//b.	Batch 2: Process Daily_RMFeed_Job_Events (Events to NEW RG)
				//c.	Batch 3: Process Daily_RMFeed_Job_Tasks (Tasks to NEW RG)
				//d.	Batch 4: Process Daily_RMFeed_Job_Opportunity (Opportunity)
				//e.	Batch 5: Process Daily_RMFeed_Job_InstinetChampion
				//f.	Batch 6: Process Daily_RMFeed_Job_InstinetCoverage
				//g.    Batch 7.1: Process Daily_QueryCvgTeamMemberRequestType (Query Coverage records to update label as RG/RM)
                //h.    Batch 7.2: Process Daily_UpdateCvgTeamMemberRequestType (Update Coverage records label as RG/RM))
				//i.	Batch 8: Process Daily_RMFeed_Job_Coverage_Movement (Coverage Movement @ RG Salesperson)
				j.      Batch 9: Process Daily_RMFeed_Job_Coverage_Movement_RM (Coverage Movement @ RM Salesperson)
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
global class Daily_RMFeed_Job_Coverage_Movement_RM implements Database.batchable<sObject>, Database.Stateful {

	/**** GLOBAL VARIABLES *******/
	String main_query = '';
    String exception_message = '';
    Boolean hasRMFeedError = false;
    Boolean batchExecutionSuccessfully = true;
    List<Coverage_Team_Member__c> coveragesToDeactivate = new List<Coverage_Team_Member__c>();
    List<Coverage_Team_Member__c> create_Coverage_List = new List<Coverage_Team_Member__c>();
    String coverage_schema_query = ObjectUtil.getCreatableFieldsSOQL('Coverage_Team_Member__c','');
	Id RMAccountRecordTypeId = CommonTools.getRecordTypeId('Account', 'RM Account');
	Id InactiveCoverageRecordTypeId = CommonTools.getRecordTypeId('Coverage_Team_Member__c', 'Inactive Coverage');
    Set<Id> movedRMIds = new Map<Id,Account>([SELECT Id FROM Account where RecordtypeId =:RMAccountRecordTypeId and isRMChanged__c = true and Active__c = true]).keyset();
    List<string> salescode_company_to_exclude = CoverageUtil.salescode_company_to_exclude;		      
	List<string> productsaccessforInstinet = CoverageUtil.productsWithRegionsToIncludeForInstinet;
	String strReason = 'RM Movement';	
    
	public Daily_RMFeed_Job_Coverage_Movement_RM(List<Coverage_Team_Member__c> coveragesToEnd, List<Coverage_Team_Member__c> coveragesToCreate, Boolean hasRMFeedError){
        coveragesToDeactivate = coveragesToEnd;
        create_Coverage_List = coveragesToCreate;
        this.hasRMFeedError = hasRMFeedError;
        main_query = 'SELECT Id FROM Account where RecordtypeId =:RMAccountRecordTypeId and isRMChanged__c = true and Active__c = true '; 
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(main_query);
    }

    global void execute(Database.batchableContext info, List<sObject> scope){
        try{
            Account sourceRM;
            Id newRGid;
			String query = '';
			String unique_id = '';
			Date currentdate = System.today();
			
			Map<string,Coverage_Team_Member__c> sourceCoverage_uniqueKey_Coverage_map = new Map<string,Coverage_Team_Member__c>();
			List<Coverage_Team_Member__c> sourceCoverages = new List<Coverage_Team_Member__c>();
			List<Coverage_Team_Member__c> destinationCoverages = new List<Coverage_Team_Member__c>();
            Map<string,Coverage_Team_Member__c> create_Coverage_map = new Map<string,Coverage_Team_Member__c>();
            Set<String> destinationCodeAndAccountIdSet = new Set<String>();
            Map<Id,User> destinationSalesCodeAndUserMapRM = new Map<Id,User>();
			
			String sourceSalesCode  = '';
			
			/**** SOURCE COVERAGE *******/
		    Set<Id> rmIdToProcess = (new Map<Id,SObject>(scope)).keySet();
            System.debug(rmIdToProcess);
			query = coverage_schema_query;
            query += ' where Account__c in:rmIdToProcess and (NOT UniqueId__c like \'%#Equity#Flow Derivatives - USA%\') and recordType.Name = \'Active Coverage\' and  (Sales_Team_for_Coverage__r.Company__c not in:salescode_company_to_exclude or Product_Including_Region__c in:productsaccessforInstinet) and Sales_Team_for_Coverage__r.Active__c = true and (Sales_Team_for_Coverage__r.Desk_SearchKey__c not in(\'Equity-USA-Flow Derivatives (USA)\',\'Fixed Income-USA-Credit Sales (Amer)\')) and Sales_Team_for_Coverage__r.Coverage_Maintenance_Level__r.Sales_Client_Hierarchy_Level__c = \'RM\'';
            sourceCoverages =(List<Coverage_Team_Member__c>)Database.query(query);
            System.debug('**Source Query: '+sourceCoverages);
            for(Coverage_Team_Member__c coverage :sourceCoverages)
            { 
				unique_id = '';
                System.debug('parent Id ::'+coverage.Account__r.ParentId ); 
                System.debug('parent Id ::'+coverage.Account__r.RDM_Org_ID__c ); 
                System.debug('parent Id ::'+ coverage.RG_Account__c);
                //added for JIRA 3163 check if the new RG is not equal to old RG
                if(coverage.Account__r.ParentId != coverage.RG_Account__c){
                    
                    if(sourceRM == null){
                        sourceRM = coverage.Account__r;
                    }

                    if(newRGid == null) {
                        System.debug(coverage.Account__r.rdm_org_id__c);
                        newRGid = sourceRM.Current_RG__c;
                    }
					
					unique_id = coverage.UniqueId__c;
					coverage.is_Deleted__c = true;
                    coverage.End_Date__c = coverage.Start_Date__c > currentdate ? coverage.Start_Date__c : currentdate;
                    sourceCoverage_uniqueKey_Coverage_map.put(unique_id,coverage.clone(false,true));
                    coverage.RecordTypeId = InactiveCoverageRecordTypeId;
                    coverage.UniqueId__c = unique_id.replace('FALSE','TRUE'); 
					//SALES-3653 Set the reason value
					coverage.Reason__c = strReason;
					coveragesToDeactivate.add(coverage);					
                }
            }
            System.debug('coveragesToDeactivate :'+ coveragesToDeactivate);

            /**** DESTINATION COVERAGE *******/
            System.debug(newRGid);
            Map<String,List<Coverage_Team_Member__c>> cvgTeamMemberMap = new Map<String,List<Coverage_Team_Member__c>>();         
            if(newRGid==null){
                List<Account> accountsMoved = [SELECT Id, RDM_Org_ID__c, Current_RG__c, Restricted_Flag__c, Domicile_Country__c FROM Account where Id in :rmIdToProcess limit 1];
                if(accountsMoved.size() > 0){
                    sourceRM = accountsMoved.get(0);
                    newRGid =sourceRM.Current_RG__c;
                    System.debug('sourceRM : '+ sourceRM);
                }
            }
		    if(newRGid!=null){
				query = coverage_schema_query;
				query += ' where Account__r.ParentId =:newRGid and Account__r.Active__c = TRUE and (Sales_Team_for_Coverage__r.Company__c not in:salescode_company_to_exclude or Product_Including_Region__c in:productsaccessforInstinet) and Account__c !=:movedRMIds and (NOT UniqueId__c like \'%#Equity#Flow Derivatives - USA%\') and RecordType.Name=\'Active Coverage\' and Sales_Team_for_Coverage__r.Active__c = true and (Sales_Team_for_Coverage__r.Desk_SearchKey__c not in(\'Equity-USA-Flow Derivatives (USA)\',\'Fixed Income-USA-Credit Sales (Amer)\')) and Sales_Team_for_Coverage__r.Coverage_Maintenance_Level__r.Sales_Client_Hierarchy_Level__c = \'RM\'';
				destinationCoverages =(List<Coverage_Team_Member__c>)Database.query(query); 
                System.debug('**Destination query: '+destinationCoverages);  
            	for(Coverage_Team_Member__c coverage :destinationCoverages){
                    String key = '';
                    String salescodeId = coverage.Sales_Team_for_Coverage__c;
                    key = coverage.RG_Account__c+'#'+coverage.Product_Region__c+'#'+coverage.Product__c+'#'+coverage.Team_Role__c+'#'+coverage.Sales_Team_for_Coverage__r.Coverage_ID__c;
                    if(cvgTeamMemberMap.get(key) == null){
                        List<Coverage_Team_Member__c> cvgList = new List<Coverage_Team_Member__c>();
                        cvgList.add(coverage);
                        cvgTeamMemberMap.put(key,cvgList);
                    }
                    else{
                        List<Coverage_Team_Member__c> cvgList = cvgTeamMemberMap.get(key);
                        cvgList.add(coverage);
                        cvgTeamMemberMap.put(key,cvgList);
                    }
                    destinationCodeAndAccountIdSet.add(salescodeId+'#'+sourceRM.Id);
              	}

                if(destinationCodeAndAccountIdSet.size() > 0)
				{
					Map<Id,Account> accountMap = new Map<Id,Account>();
					accountMap.put(sourceRM.Id, sourceRM);
					destinationSalesCodeAndUserMapRM = CoverageRequestUtility.fetchRequestedForUserForRMRequest(destinationCodeAndAccountIdSet, accountMap);
				}

                System.debug('cvgTeamMemberMap size: '+cvgTeamMemberMap.size());

                if(sourceCoverage_uniqueKey_Coverage_map.size() > 0){
                    //Create coverage from source towards destination if it covers
                    for(Coverage_Team_Member__c sourceCoverage : sourceCoverage_uniqueKey_Coverage_map.values()){
                        System.debug('sourceCoverage: '+sourceCoverage);
                        sourceSalesCode = sourceCoverage.Sales_Team_for_Coverage__r.Coverage_ID__c;
                        
                        Boolean foundSameProductCvg = false;
                        Boolean foundDiffProductCvg = false;
                        for(String destinationUniqueKeyStr : cvgTeamMemberMap.keySet()){
                            System.debug('**destinationUniqueKeyStr: '+destinationUniqueKeyStr);
                            // Step 1: create only if salesperson of source covers at destination ?
                            if(destinationUniqueKeyStr.contains(sourceSalesCode)){
                                sourceCoverage.Start_Date__c = currentdate;
                                sourceCoverage.End_Date__c = null;
                                sourceCoverage.Called_from__c ='';
                                sourceCoverage.Id = null;
                                sourceCoverage.Is_Deleted__c = false;                            
                                List<Coverage_Team_Member__c>  cvgTeamMemberList = cvgTeamMemberMap.get(destinationUniqueKeyStr);
                                //Creating Source Coverage on destination
                                for(Coverage_Team_Member__c cvg : cvgTeamMemberList){
                                    System.debug('Destination Cvg: '+cvg);
                                    if(cvg.Group_By__c == 'RG' && cvg.Product__c == sourceCoverage.Product__c && cvg.Product_Region__c == sourceCoverage.Product_Region__c){
                                        sourceCoverage.Group_By__c = 'RG';
                                        sourceCoverage.Team_Role__c = cvg.Team_Role__c;
                                        System.debug('source Covearge: 1 '+sourceCoverage);
                                        create_Coverage_map.put(sourceCoverage.UniqueId__c,sourceCoverage);
                                        System.debug('**1');
                                        foundSameProductCvg = true;
                                    }else if(cvg.Group_By__c == 'RG' && cvg.Product__c != null && cvg.Product__c != sourceCoverage.Product__c){
                                        System.debug('cvg.Product__c: '+cvg.Product__c);
                                        System.debug('confiton: '+cvg.Product__c != sourceCoverage.Product__c);
                                        Coverage_Team_Member__c newCoverage = cvg.clone(false,true);
                                        newCoverage.UniqueId__c = newCoverage.UniqueId__c.replace(newCoverage.Account__r.RDM_Org_ID__c,sourceCoverage.Account__r.RDM_Org_ID__c); //chamnge prduct
                                        newCoverage.Account__c = sourceCoverage.Account__c;
                                        newCoverage.Start_Date__c = currentdate;
                                        newCoverage.End_Date__c =null;
                                        newCoverage.Called_from__c ='';
                                        newCoverage.Is_Deleted__c = false;
                                        newCoverage.Group_By__c = 'RG';
                                        System.debug('source Covearge: 2 '+newCoverage);
                                        if(!create_Coverage_map.containsKey(newCoverage.UniqueId__c))
                                            create_Coverage_map.put(newCoverage.UniqueId__c,newCoverage);
                                        System.debug('**2');
                                        foundDiffProductCvg = true;
                                    }
                                    break;
                                }
                            }
                        }
                        if(!foundSameProductCvg && ((sourceCoverage.Product__c == null && !foundDiffProductCvg) || sourceCoverage.Product__c != null)){
                            System.debug('**3');
                            sourceCoverage.Group_By__c = 'RM';
                            System.debug('source Covearge: 3 '+sourceCoverage);
                            create_Coverage_map.put(sourceCoverage.UniqueId__c,sourceCoverage);
                        }
                    }
                }else{
                    Boolean needToCreate = false;
                    for(String destinationUniqueKeyStr : cvgTeamMemberMap.keySet()){
                        List<Coverage_Team_Member__c>  cvgTeamMemberList = cvgTeamMemberMap.get(destinationUniqueKeyStr);
                        //Creating Source Coverage on destination
                        for(Coverage_Team_Member__c cvg : cvgTeamMemberList){
                            Boolean isDummy = cvg.Sales_Team_For_Coverage__r.Is_dummy__c;
                            String destinationSalescodeId = cvg.Sales_Team_for_Coverage__c;
                            if(sourceRM.Restricted_Flag__c){
                                if(destinationSalesCodeAndUserMapRM.get(destinationSalescodeId)!=null){
                                    if(destinationSalesCodeAndUserMapRM.get(destinationSalescodeId).CountryCode == sourceRM.Domicile_Country__c && !isDummy){
                                        needtoCreate = true;   
                                    }
                                }
                            }else{
                                needtoCreate = true;
                            }

                            if(needToCreate){
                                System.debug('Destination Cvg: '+cvg);
                                if(cvg.Group_By__c == 'RG'){
                                    Coverage_Team_Member__c newCoverage = cvg.clone(false,true);
                                    newCoverage.UniqueId__c = newCoverage.UniqueId__c.replace(newCoverage.Account__r.RDM_Org_ID__c,sourceRM.RDM_Org_ID__c);
                                    newCoverage.Account__c = sourceRM.Id;
                                    newCoverage.Start_Date__c = currentdate;
                                    newCoverage.End_Date__c =null;
                                    newCoverage.Called_from__c ='';
                                    newCoverage.Is_Deleted__c = false;
                                    newCoverage.Group_By__c = 'RG';
                                    System.debug('source Covearge: 2 '+newCoverage);
                                    if(!create_Coverage_map.containsKey(newCoverage.UniqueId__c))
                                        create_Coverage_map.put(newCoverage.UniqueId__c,newCoverage);
                                    System.debug('**4');
                                }
                            }
                            break;
                        }
                    }
                }
                //convert from map to list
                create_Coverage_List.addAll(create_Coverage_map.values());
                System.debug('create_Coverage_List size: '+create_Coverage_List.size());
                System.debug('create_Coverage_List : '+create_Coverage_List);


                //clear out local variables
                if(sourceCoverage_uniqueKey_Coverage_map!=null)
                sourceCoverage_uniqueKey_Coverage_map.clear();
                if(sourceCoverages!=null)
                sourceCoverages.clear();
                if(destinationCoverages!=null)
                destinationCoverages.clear();
                if(rmIdToProcess!=null)
                rmIdToProcess.clear();
                if(destinationCodeAndAccountIdSet!=null)
                destinationCodeAndAccountIdSet.clear();
                if(destinationSalesCodeAndUserMapRM!=null)
                destinationSalesCodeAndUserMapRM.clear();
            }
        }
        catch(Exception e){
            exception_message += e+'\n'+e.getStackTraceString();
            exception_message += '\n';
            batchExecutionSuccessfully = false;
            hasRMFeedError = true;
            System.debug(exception_message);
        }
    }

    global void finish(Database.batchableContext info){
        if(!batchExecutionSuccessfully)
        {
            System.debug('Exception processing Coverage Movement Feed.....');
            System.debug(exception_message);
            CommonTools.emailLog('FAILURE','RM Feed Daily JOB - Daily_RMFeed_Job_Coverage_Movement_RM',exception_message+'\n\nRegards,\nSalesforce Tech',null,'TECH');
        }

		Database.executeBatch(new Daily_RMFeed_Coverage_Movement_End(coveragesToDeactivate,create_Coverage_List,hasRMFeedError), 10);
    }
}