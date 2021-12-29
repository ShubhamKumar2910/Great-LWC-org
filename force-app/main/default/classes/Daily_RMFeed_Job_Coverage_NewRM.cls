/*
    Author 		: Sagar Kambli
    Company 	: Nomura 
    Date 		: 06/07/2018
    Description : RM Feed Job (Batch 14)
				//a.	Batch 1: Process Daily_RMFeed_Job_Contacts (RM Contacts to NEW RG)
				//b.	Batch 2: Process Daily_RMFeed_Job_Events (Events to NEW RG)
				//c.	Batch 3: Process Daily_RMFeed_Job_Tasks (Tasks to NEW RG)
				//d.	Batch 4: Process Daily_RMFeed_Job_Opportunity (Opportunity)
				//e.	Batch 5: Process Daily_RMFeed_Job_InstinetChampion
				//f.	Batch 6: Process Daily_RMFeed_Job_InstinetCoverage
				//g.    Batch 7.1: Process Daily_QueryCvgTeamMemberRequestType (Query Coverage records to update label as RG/RM)
                //h.    Batch 7.2: Process Daily_UpdateCvgTeamMemberRequestType (Update Coverage records label as RG/RM))
				//i.	Batch 8: Process Daily_RMFeed_Job_Coverage_Movement (Coverage Movement @ RG Salesperson)
				//j.	Batch 9: Process Daily_RMFeed_Job_Coverage_Movement_RM (Coverage Movement @ RM Salesperson)
				//k.	Batch 10: Process Daily_RMFeed_Coverage_Movement_End
				//l.	Batch 11: Process Daily_RMFeed_Coverage_Movement_Insert
                //m.    Batch 12. Process Daily_RMFeed_Job_Clear (Reset RM Movement flag)
				//n.    Batch 13.1: Process Daily_QueryCvgTeamMemberRequestType (Chaining Batch 7.1 Job)
                //o.    Batch 13.2: Process Daily_UpdateCvgTeamMemberRequestType (Chaining Batch 7.2 Job)
				p.      Batch 14: Process Daily_RMFeed_Job_Coverage_NewRM
				//q.	Batch 15: Process Daily_RMFeed_Coverage_NewRM_Insert
				//r.    Batch 16. Process Daily_RMFeed_Job_Clear (Reset new RM flag - Chaning Batch 12)
                //s.    Batch 17. Process Daily_RMPODLinkStartBatch
                //t.    Batch 18. Process Daily_RMPodLinkProcessBatch
                //u.    Batch 19. Process Daily_RMPodLinkEndBatch
                //v.    Batch 20. Process Daily_DeletePODCoverage
*/
global class Daily_RMFeed_Job_Coverage_NewRM implements Database.batchable<sObject>, Database.Stateful{ 
    
    public string query {get;set;}
    public Boolean hasError  = false;
    public Boolean hasRMFeedError = false;
    private String exception_message = '';
    private Boolean batchExecutionSuccessfully = true;
    public string generatedErrorCSVfile = ''; 
    public Set<Id> new_rmIds = new Set<Id>();
    public Set<Id> new_rgIds = new Set<Id>();
    public Integer totSize = 0;
    //public Set<string> partUniqueCoverageIdentifier_non_res = new Set<string>();
    ///public Set<string> partUniqueCoverageIdentifier_res = new Set<string>();
    public Set<Id> unprocessedNewRMIds = new Set<Id>();
    public Boolean hasCoverageInsertError = false;
    List<Coverage_Team_Member__c> newCoveragesToCreate  = new List<Coverage_Team_Member__c>();
    List<string> salescode_company_to_exclude = CoverageUtil.salescode_company_to_exclude;		
    List<string> productsaccessforInstinet = CoverageUtil.productsWithRegionsToIncludeForInstinet;
    
    public Daily_RMFeed_Job_Coverage_NewRM(Set<Id> new_rmIds,Set<Id> new_rgIds,Boolean hasRMFeedError,Boolean hasCoverageInsertError){
        this.hasRMFeedError = hasRMFeedError;
        this.new_rmIds = new_rmIds;
        this.new_rgIds = new_rgIds;
        this.hasCoverageInsertError = hasCoverageInsertError;
        query = 'SELECT Id FROM Coverage_Team_Member__c where Account__r.parentId in:new_rgIds and Account__r.Active__c = TRUE and Account__c not in:new_rmIds and RecordType.Name=\'Active Coverage\' and Sales_Team_for_Coverage__r.Active__c = true';
        generatedErrorCSVfile = 'RM Account,Error\n';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.batchableContext info, List<sObject> scope){
        SavePoint sp;
        try
        {
            sp = Database.setSavepoint();
            system.debug('Record Size: '+scope.size());
            Set<Id> coverageIds = (new Map<Id,SObject>(scope)).keySet();
            //STEP 1:-------------------FIND OUT - NEW RG's covers which SalesCode - Non-Restricted Coverage?----------------------------------------------------------------------
            query = ObjectUtil.getCreatableFieldsSOQL('Coverage_Team_Member__c','');
            Set<Id> new_salescodeIds = new Set<Id>();
            Map<Id,List<Coverage_Team_Member__c>> newRG_Coverage_map = new Map<Id,List<Coverage_Team_Member__c>>();
            Set<String> salesCodeAndAccountIdSet = new Set<String>(); 
            Set<String> accountIdSet = new Set<String>(); 
            Map<Id,User> new_salesCodeAndUserMapRM = new Map<Id,User>();
            //SALES 3653 Changes for fixing bug
            //query += ' WHERE id in:coverageIds and (Sales_Team_for_Coverage__r.Company__c not in:salescode_company_to_exclude or Product__c in:productsaccessforInstinet) ';
            query += ' WHERE id in:coverageIds and (NOT UniqueId__c like \'%#Equity#Flow Derivatives - USA%\') and recordType.Name = \'Active Coverage\' and  (Sales_Team_for_Coverage__r.Company__c not in:salescode_company_to_exclude or Product_Including_Region__c in:productsaccessforInstinet) and Sales_Team_for_Coverage__r.Active__c = true and (Sales_Team_for_Coverage__r.Desk_SearchKey__c not in(\'Equity-USA-Flow Derivatives (USA)\',\'Fixed Income-USA-Credit Sales (Amer)\')) and Group_By__c = \'RG\'';
            List<Coverage_Team_Member__c> newCoverages =(List<Coverage_Team_Member__c>)Database.query(query);
            for(Coverage_Team_Member__c coverage :newCoverages){
                string rgId = coverage.Account__r.ParentId;
                string salescodeId = coverage.Sales_Team_for_Coverage__c;
                //string salescode = coverage.Sales_Team_for_Coverage__r.Coverage_ID__c;
                //string uniqueId  = coverage.UniqueId__c;
                //string rdmOrgId = coverage.Account__r.RDM_Org_ID__c;
                //string partUniqueId = uniqueId.replace(rdmOrgId, '').trim();
                string rmId = coverage.Account__c;
                //string key = 'Flow Derivatives~Equity~USA';
                //string salescodeKey1 = 'Flow Derivatives (USA)~Equity~USA';
                //string salescodeKey2 = 'Credit Sales (Amer)~Fixed Income~USA';
                //string recordkey = coverage.Product__c+'~'+coverage.Product_Group__c+'~'+coverage.Product_Region__c;
                //string record_sales_code_key = coverage.Sales_Team_for_Coverage__r.Desk_Name__c+'~'+coverage.Sales_Team_for_Coverage__r.Sales_Desk_Division__c+'~'+coverage.Sales_Team_for_Coverage__r.Sales_Desk_Region__c;
                
                //if(key!=recordkey && salescodeKey1!=record_sales_code_key && salescodeKey2!=record_sales_code_key)
                //{
                    //system.debug('**** salescode: '+salescode);                
                    accountIdSet.add(rmId);
                    salesCodeAndAccountIdSet.add(salescodeId+'#'+rmId);
                    if(newRG_Coverage_map.get(rgId)==null)
                        newRG_Coverage_map.put(rgId, new List<Coverage_Team_Member__c>{coverage});
                    else
                        newRG_Coverage_map.get(rgId).add(coverage);
               // }
                
            }
            
            if(salesCodeAndAccountIdSet.size() > 0 && accountIdSet.size() > 0)
            {
                Map<Id,Account> accountMap = new Map<Id,Account>([
                    SELECT Id, Restricted_Flag__c, Domicile_Country__c, Closing_Date__c, Active__c FROM Account 
                    WHERE Id IN :accountIdSet
                ]);
                accountMap = (accountMap == null) ? new Map<Id,Account>() : accountMap;
                new_salesCodeAndUserMapRM = CoverageRequestUtility.fetchRequestedForUserForRMRequest(salesCodeAndAccountIdSet, accountMap);
            }
            
            //STEP 3:-------------------FIND OUT - NEW RG's & its non res RM and res RM----------------------------------------------------------------------
            Map<Id,Account> newRG_ResRM_Countrymap = new Map<Id,Account>();
            // Map<Id,string> newRG_ResRM_Countrymap = new Map<Id,string>();
            Map<Id,string> rmIdbyOrgId = new Map<Id,string>();
            for(Account rmAccount :[select id,parentId,Restricted_Flag__c,Domicile_Country__c,RDM_Org_ID__c from Account where ParentId in:new_rgIds 
                                    and Active__c = TRUE])
            {
                //newRG_ResRM_Countrymap.put(rmAccount.id,rmAccount.Domicile_Country__c);
                newRG_ResRM_Countrymap.put(rmAccount.id,rmAccount);
                rmIdbyOrgId.put(rmAccount.id,rmAccount.RDM_Org_ID__c);
            }
           
            //commented for JIRA 3653     
            //STEP 2:-------------------Prepare New Coverages to create----------------------------------------------------------------------
            /*for(Account acc : [select id,parentId,RDM_Org_ID__c, restricted_Flag__c from Account where id in:new_rmIds]){
                 //newRG_NRCoverage_map.putAll(newRG_RCoverage_map);
                newCoveragesToCreate.addAll(CoverageUtil.getDatafromNewRGCoveragesOnNewRM(newRG_Coverage_map, acc.parentId, acc.id, acc.RDM_Org_ID__c,newRG_ResRM_Countrymap,partUniqueCoverageIdentifier_non_res,partUniqueCoverageIdentifier_res,acc.restricted_Flag__c,new_salesCodeAndUserMapRM));
            }*/
            newCoveragesToCreate.addAll(CoverageUtil.getDatafromNewRGCoveragesOnNewRM(newRG_Coverage_map, new_rmIds,newRG_ResRM_Countrymap,new_salesCodeAndUserMapRM));
            totSize += newCoveragesToCreate.size();
            
           /* if(newCoveragesToCreate.size()>0){
                Integer i = 0;
                Database.SaveResult[] saveResult = Database.insert(newCoveragesToCreate, false);
                for (Database.SaveResult output : saveResult){  
                    if (!output.isSuccess()){  
                        for (Database.Error error : output.getErrors()){  
                            // errors here  
                            generatedErrorCSVfile += '"'+newCoveragesToCreate.get(i).Account__r.RDM_Org_ID__c+'"'+','
                                +'"'+error.getMessage()+'"'+'\n';
                            hasError = true;
                            unprocessedNewRMIds.add(newCoveragesToCreate.get(i).Account__c);
                        }   
                    }
                   
                    i++;
                }
            }*/
            
        }
        catch(Exception e)
        {
            exception_message += e+'\n'+e.getStackTraceString();
            exception_message += '\n';
            batchExecutionSuccessfully = false;
            system.debug(exception_message);
           // System.abortJob(info.getJobId());
        }
    }
    
      
    global void finish(Database.batchableContext info){  
        if(hasError)
        {
            system.debug('Errors processing NEW RM Coverage Feed. Attached records processing for email');
            system.debug(generatedErrorCSVfile);
            CommonTools.emailLog('ERRORS','RM Feed Daily JOB - Daily_RMFeed_Job_Coverage_NewRM','Attached are the records which have errors\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'TECH');
        }
        if(!batchExecutionSuccessfully)
        {
            system.debug('Exception processing NEW RM Coverage Feed.....');
            system.debug(exception_message);
            CommonTools.emailLog('FAILURE','RM Feed Daily JOB - Daily_RMFeed_Job_Coverage_NewRM',exception_message+'\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'TECH');
            
        }
        system.debug('Calling New RM Movement Insert.....');
        /*system.debug(newCoveragesToCreate.size());
        for(Coverage_Team_Member__c tm: newCoveragesToCreate)
            system.debug(tm.uniqueId__c);*/
        List<Coverage_Team_Member__c> actualInserts = new List<Coverage_Team_Member__c>();
        /*for(Coverage_Team_Member__c tm: newCoveragesToCreate){
            string uniqueKey = tm.uniqueId__c;
            string tobeCreatedKey_partial = uniqueKey.replace('#FALSE', '').trim();
            boolean found = false;
            for(Coverage_Team_Member__c tm1: newCoveragesToCreate){
                if(tm1.uniqueId__c.contains(tobeCreatedKey_partial)){
                    found = true;
                    break;
                }
            }
            if(!found)
            {
                actualInserts.add(tm);
            }
        }*/
        /*boolean found = false;
        for(Coverage_Team_Member__c tm: newCoveragesToCreate){
            String tobeCreatedKey = tm.uniqueId__c;
            String tobeCreatedKey_partial = tobeCreatedKey.replace('#FALSE', '').trim();
            found = false;
            
            if(!found){
                            for(Coverage_Team_Member__c tm3: newCoveragesToCreate){
                                String tobeCreatedKey1 = tm3.uniqueId__c;
                                            if(tobeCreatedKey1.contains(tobeCreatedKey_partial) && tobeCreatedKey1!=tobeCreatedKey){
                                                            found = true;
                                                            break;
                                            }
                            }
            }

            if(found)
            {
                actualInserts.add(tm);
            }
        }*/ 
        
        system.debug('size of records:: '+ newCoveragesToCreate.size());
        for(Coverage_Team_Member__c tm: newCoveragesToCreate){
            system.debug(tm.uniqueId__c);
        }
        
        Database.executeBatch(new Daily_RMFeed_Coverage_NewRM_Insert(newCoveragesToCreate,hasRMFeedError,hasCoverageInsertError), 10);
        //Database.executeBatch(new Daily_RMFeed_Job_Clear(hasRMFeedError,hasNewRMFeedError,hasCoverageInsertError), 200);
    }
}