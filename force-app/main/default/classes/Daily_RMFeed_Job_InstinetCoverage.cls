/*
    Description : RM Feed Job (Batch 6)
				//a.	Batch 1: Process Daily_RMFeed_Job_Contacts (RM Contacts to NEW RG)
				//b.	Batch 2: Process Daily_RMFeed_Job_Events (Events to NEW RG)
				//c.	Batch 3: Process Daily_RMFeed_Job_Tasks (Tasks to NEW RG)
				//d.	Batch 4: Process Daily_RMFeed_Job_Opportunity (Opportunity)
				//e.	Batch 5: Process Daily_RMFeed_Job_InstinetChampion
				f.  	Batch 6: Process Daily_RMFeed_Job_InstinetCoverage
				//g.    Batch 7.1: Process Daily_QueryCvgTeamMemberRequestType (Query Coverage records to update label as RG/RM)
                //h.    Batch 7.2: Process Daily_UpdateCvgTeamMemberRequestType (Update Coverage records label as RG/RM))
				//i.	Batch 8: Process Daily_RMFeed_Job_Coverage_Movement (Coverage Movement @ RG Salesperson)
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
public class Daily_RMFeed_Job_InstinetCoverage implements Database.batchable<sObject>, Database.Stateful {

    List<String> salesCodeCompanyIncludeList = CoverageUtil.salescode_company_to_exclude;
    List<String> instinetProductExcludeList = CoverageUtil.productsWithRegionsToIncludeForInstinet;
    List<Coverage_Team_Member__c> coverageErrorUpdateList; 
    public string generatedErrorCSVfile = '';
    public Boolean hasFeedError = false;
    
    public Daily_RMFeed_Job_InstinetCoverage(Boolean hasFeedError) {
        this.hasFeedError = hasFeedError;
        coverageErrorUpdateList = new List<Coverage_Team_Member__c>();
        generatedErrorCSVfile = 'Id\n';
    }
    
    public Database.QueryLocator start(Database.BatchableContext batchableContext){
        String query = 'SELECT Id, UniqueId__c, Account__c, Account__r.RDM_Org_Id__c, '
            + 'RG_Account__c, RG_Account__r.RDM_Org_Id__c, '
            + 'Account__r.ParentId '
            + 'FROM Coverage_Team_Member__c ' 
            + 'WHERE RecordType.DeveloperName = \'Active_Coverage\' AND ' 
            + 'End_Date__c = null AND '
            + 'Sales_Team_for_Coverage__r.Active__c = TRUE AND '
            + 'Sales_Team_for_Coverage__r.Company__c IN :salesCodeCompanyIncludeList AND '
            + 'Product__c NOT IN :instinetProductExcludeList AND '
            + 'Account__r.isRMChanged__c = TRUE';
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext batchableContext, List<sObject> scope){
        List<Coverage_Team_Member__c> instinetCoverageList = (List<Coverage_Team_Member__c>)scope;
        List<Coverage_Team_Member__c> updateInstinetCoverageList = new List<Coverage_Team_Member__c>();
        Map<Id,Id> currentRMRGMap = new Map<Id,Id>();
        
        if(instinetCoverageList != null && !instinetCoverageList.isEmpty()){
            for(Coverage_Team_Member__c coverageObj : instinetCoverageList){
                currentRMRGMap.put(coverageObj.Account__c, coverageObj.Account__r.ParentId);
            }
            
            for(Coverage_Team_Member__c coverageObj : instinetCoverageList){
                String currentRG = String.valueOf(currentRMRGMap.get(coverageObj.Account__c));
                String coverageRG = String.valueOf(coverageObj.RG_Account__c);
                if(String.isNotEmpty(currentRG) && !currentRG.equalsIgnoreCase(coverageRG)){
                    coverageObj.RG_Account__c = currentRG;
                    updateInstinetCoverageList.add(coverageObj);
                }
            }
            
            if(!updateInstinetCoverageList.isEmpty()){
                updateCoverageTeamMemberRecords(updateInstinetCoverageList);
            }
        }
    }
    
    public void finish(Database.BatchableContext batchableContext){
    	//Check whether error got generated. If yes then fill the error message
        Boolean hasError = FALSE;
        if(!coverageErrorUpdateList.isEmpty()){
            hasError = TRUE;
            for(Coverage_Team_Member__c coverageObj : coverageErrorUpdateList){
                generatedErrorCSVfile = generatedErrorCSVfile + '"' + coverageObj.Id + '"\n';
            }
        }
        
        if(hasError){
            System.debug('Errors processing Instinet Coverage records. Attached records processing for email');
            System.debug(generatedErrorCSVfile);
            CommonTools.emailLog('ERRORS','RM Feed Daily JOB - Instinet Coverage','Attached are the records which have errors\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'TECH');
        }
        
        Nomura_Trigger_Activation__c coverageMovementBatchJob = Nomura_Trigger_Activation__c.getInstance('Daily_RMFeed_Job_Coverage_Movement');
        Boolean codeToBeExecuted = (coverageMovementBatchJob == null || (coverageMovementBatchJob != null && coverageMovementBatchJob.Active__c == true)) ? true : false;
        if(codeToBeExecuted){
            if(!Test.isRunningTest()){
                System.debug('Calling Query Coverage Team Member Request Type Job');
                Database.executeBatch(new Daily_QueryCvgTeamMemberRequestType(hasFeedError), 1);
            }
        }
    }
    
    public void updateCoverageTeamMemberRecords(List<Coverage_Team_Member__c> coverageTeamMemberList){
        if(coverageTeamMemberList != null && coverageTeamMemberList.size() > 0){
            Database.SaveResult[] saveResultList = Database.update(coverageTeamMemberList, false);
            for(Integer i=0; i<saveResultList.size(); i++){            
                Database.SaveResult resultObj = saveResultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        System.debug('Error Status Code for Coverage Team Member Update :'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                    }
                    
                    coverageErrorUpdateList.add(coverageTeamMemberList.get(i));
                }
            }
        }
    }
    
}