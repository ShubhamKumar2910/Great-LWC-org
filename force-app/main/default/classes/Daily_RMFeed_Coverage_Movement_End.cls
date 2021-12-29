/*
    Author      : Sagar Kambli
    Company     : Nomura 
    Date        : 06/07/2018
    Description : RM Feed Job (Batch 10)
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
				k.      Batch 10: Process Daily_RMFeed_Coverage_Movement_End
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
public class Daily_RMFeed_Coverage_Movement_End implements Database.batchable<sObject>, Database.Stateful{ 
    
    public string query {get;set;}
    public Boolean hasError  = false;
    public Boolean hasRMFeedError = false;
    public Boolean hasCoverageDeactivateError = false;
    private String exception_message = '';
    private Boolean batchExecutionSuccessfully = true;
    public string generatedErrorCSVfile = '';
    public Set<Id> unprocessed_rmCoverageIds = new Set<Id>();
    List<Coverage_Team_Member__c> coveragesToEnd = new List<Coverage_Team_Member__c>();
    List<Coverage_Team_Member__c> coveragesToCreate = new List<Coverage_Team_Member__c>();
    
    public Daily_RMFeed_Coverage_Movement_End(List<Coverage_Team_Member__c> coveragesToEnd, 
                                            List<Coverage_Team_Member__c> coveragesToCreate,
                                            Boolean hasRMFeedError){
                                                this.coveragesToEnd = coveragesToEnd;
                                                this.coveragesToCreate = coveragesToCreate;
                                                this.hasRMFeedError = hasRMFeedError;
                                                generatedErrorCSVfile = 'Id,RM Account,Unique Id,Error\n';
    }
    public List<sObject> start(Database.BatchableContext BC){
        return coveragesToEnd;
    }
    
    public void execute(Database.batchableContext info, List<sObject> scope){
        SavePoint sp;
        try
        {
            List<Coverage_Team_Member__c> coveragesToDeactivate = (List<Coverage_Team_Member__c>)scope;
            system.debug('Coverage Movement - Deactivate Job');
            /*for(Coverage_Team_Member__c tm: coveragesToDeactivate){
                system.debug(tm.uniqueId__c);
            }*/
            Set<String> del_uniqueKeys = new Set<String>();
            List<Coverage_Team_Member__c> existingDeletecoverageToUpdate = new List<Coverage_Team_Member__c>();
            
            for(Coverage_Team_Member__c coverage :coveragesToDeactivate)
            { 
                del_uniqueKeys.add(coverage.UniqueId__c);
            }
            if(del_uniqueKeys.size() > 0)
            {
                List<Coverage_Team_Member__c> alreadyDeletedCoverages = [SELECT Id,UniqueID__c FROM Coverage_Team_Member__c
                                                                         WHERE UniqueID__c IN: del_uniqueKeys];
                if(alreadyDeletedCoverages.size() >0){
                    for(Coverage_Team_Member__c existingDeletedOnes : alreadyDeletedCoverages){
                        existingDeletedOnes.UniqueId__c = existingDeletedOnes.UniqueId__c.Replace('TRUE','PREVDELETE')+'#'+ existingDeletedOnes.Id ;
                        existingDeletecoverageToUpdate.add(existingDeletedOnes);
                    }
                }
                
                Boolean exist_IsError = false;
                if(existingDeletecoverageToUpdate.size() > 0)
                {
                    Database.SaveResult[] results = Database.update(existingDeletecoverageToUpdate, false);
                    
                }
                
                if(coveragesToDeactivate.size() > 0)
                {
                    Integer i = 0;
                    Database.SaveResult[] updateResult = Database.update(coveragesToDeactivate, false);
                    for (Database.SaveResult output : updateResult){  
                        if (!output.isSuccess()){  
                            for (Database.Error error : output.getErrors()){  
                                // errors here  
                                generatedErrorCSVfile += '"'+coveragesToDeactivate.get(i).Id+'"'+','
                                    +'"'+coveragesToDeactivate.get(i).Account__r.rdm_org_ID__c+'"'+','
                                    +'"'+coveragesToDeactivate.get(i).UniqueId__c+'"'+','
                                    +'"'+error.getMessage()+'"'+'\n';
                                unprocessed_rmCoverageIds.add(coveragesToDeactivate.get(i).Id);
                                hasError = true;
                            }   
                        }
                        i++;
                    }
                } 
            }
            
            
        }
        catch(Exception e)
        {
            exception_message += e+'\n'+e.getStackTraceString();
            exception_message += '\n';
            hasCoverageDeactivateError = true;
            batchExecutionSuccessfully = false;
        }
    }
    
    public void finish(Database.batchableContext info){ 
        if(hasError)
        {
            system.debug('Error Source Coverage Deactivation Feed. Attached records processing for email');
            CommonTools.emailLog('ERRORS','RM Feed Daily JOB - Daily_RMFeed_Source_EndCoverages','Attached are the records which have errors\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'TECH');
        }
        if(!batchExecutionSuccessfully)
        {
            system.debug('Exception processing Source Coverage Deactivation Feed.....');
            system.debug(exception_message);
            CommonTools.emailLog('FAILURE','RM Feed Daily JOB - Daily_RMFeed_Source_EndCoverages',exception_message+'\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'TECH');
        }
        Database.executeBatch(new Daily_RMFeed_Coverage_Movement_Insert(coveragesToCreate,hasRMFeedError,hasCoverageDeactivateError), 10);    
         
    }
}