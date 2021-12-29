/*
    Author 		: Sagar Kambli
    Company 	: Nomura 
    Date 		: 06/07/2018
    Description : RM Feed Job (Batch 12 / Batch 16)
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
                m.      Batch 12. Process Daily_RMFeed_Job_Clear (Reset RM Movement flag)
				//n.    Batch 13.1: Process Daily_QueryCvgTeamMemberRequestType (Chaining Batch 7.1 Job)
                //o.    Batch 13.2: Process Daily_UpdateCvgTeamMemberRequestType (Chaining Batch 7.2 Job)
				//p.	Batch 14: Process Daily_RMFeed_Job_Coverage_NewRM
				//q.	Batch 15: Process Daily_RMFeed_Coverage_NewRM_Insert
				r.      Batch 16. Process Daily_RMFeed_Job_Clear (Reset new RM flag - Chaning Batch 12)
                //s.    Batch 17. Process Daily_RMPODLinkStartBatch
                //t.    Batch 18. Process Daily_RMPodLinkProcessBatch
                //u.    Batch 19. Process Daily_RMPodLinkEndBatch
                //v.    Batch 20. Process Daily_DeletePODCoverage
*/
global class Daily_RMFeed_Job_Clear implements Database.batchable<sObject>, Database.Stateful{ 
    
    public string query {get;set;}
    public Boolean hasError  = false;
    public Boolean hasRMfeedError = false;
    public Boolean hasNewRMFeedError = false;
    public Boolean hasRMCoverageMovementFeedError = false;
    public Set<Id> new_rmIds = new Set<Id>();
    public Set<Id> new_rgIds = new Set<Id>();
    public Boolean isPrevJobRMMovement = false;
    public Set<Id> rmIds = new Set<Id>();
    List<account> rmAccountsReset_movement = new List<account>();
    List<account> rmAccountsReset_new = new List<account>();
    
    public Daily_RMFeed_Job_Clear(Boolean hasRMfeedError, Boolean hasNewRMFeedError,Boolean hasRMCoverageMovementFeedError){ 
        //called from Daily_RMFeed_Coverage_NewRM_Insert
        this.hasRMfeedError = hasRMfeedError;
        this.hasNewRMFeedError = hasNewRMFeedError;
        this.hasRMCoverageMovementFeedError= hasRMCoverageMovementFeedError;
        this.rmIds = rmIds;
        isPrevJobRMMovement = false;
        //Fix for JIRA 3643 check for only active records
        query = 'SELECT Id FROM Account where isNewRM__c=true and Active__c = true';
    }

    public Daily_RMFeed_Job_Clear(Set<Id> new_rmIds,Set<Id> new_rgIds,Boolean hasRMfeedError,Boolean hasRMCoverageMovementFeedError){
        //called from Daily_RMFeed_Coverage_Movement_Insert
        this.new_rmIds = new_rmIds;
        this.new_rgIds = new_rgIds;
        this.hasRMfeedError = hasRMfeedError;
        this.hasRMCoverageMovementFeedError = hasRMCoverageMovementFeedError;
        isPrevJobRMMovement = true;
        query = 'SELECT Id FROM Account where isRMChanged__c = true and Active__c = true';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.batchableContext info, List<sObject> scope){
        SavePoint sp;
        try
        {
            Set<Id> Ids = (new Map<Id,SObject>(scope)).keySet();
           
                for(Account accp: [select id,Previous_RG__c,isRMChanged__c,isNewRM__c from Account where id in:Ids]){
                    accp.Previous_RG__c = null;
                    
                    if(!hasRMfeedError && accp.isRMChanged__c){
                        rmAccountsReset_movement.add(accp);
                    }
                    
                    if(accp.isNewRM__c)
                    rmAccountsReset_new.add(accp);
                    
                }
               
           
        }
        catch(Exception e)
        {
            if(sp!=null)
                Database.rollback(sp);
        }
    }
    
    global void finish(Database.batchableContext info){ 
        if(rmAccountsReset_movement.size()>0){
            update rmAccountsReset_movement;
            system.debug('successful reset movement');
        }
        if(rmAccountsReset_new.size()>0){
            update rmAccountsReset_new;
            system.debug('successful reset new');
        }
        if(isPrevJobRMMovement){
            System.debug('Calling Query Coverage Team Member Request Type Job');
            Database.executeBatch(new Daily_QueryCvgTeamMemberRequestType(new_rmIds,new_rgIds,hasRMfeedError,hasRMCoverageMovementFeedError), 1);
        }else{
            if(!Test.isRunningTest()){
                system.debug('Calling RM POD link Job - Start');
                Database.executeBatch(new Daily_RMPODLinkStartBatch(), 100);
            }
        }
    }
}