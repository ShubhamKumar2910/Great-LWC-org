/*
    Author      : Sagar Kambli
    Company     : Nomura 
    Date        : 06/07/2018
    Description : RM Feed Job (Batch 11)
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
				l.	    Batch 11: Process Daily_RMFeed_Coverage_Movement_Insert
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
public class Daily_RMFeed_Coverage_Movement_Insert implements Database.batchable<sObject>, Database.Stateful{ 
    
    public string query {get;set;}
    public Boolean hasError  = false;
    public Boolean hasRMFeedError = false;
    public Boolean hasCoverageDeactivateError = false;
    public Boolean hasCoverageInsertError = false;
    private String exception_message = '';
    private Boolean batchExecutionSuccessfully = true;
    public string generatedErrorCSVfile = '';
    Set<Id> unprocessed_rmIds = new Set<Id>();
    List<Coverage_Team_Member__c> coveragesToCreate = new List<Coverage_Team_Member__c>();
    
    public Daily_RMFeed_Coverage_Movement_Insert(List<Coverage_Team_Member__c> coveragesToCreate,
                                               Boolean hasRMFeedError,
                                               Boolean hasCoverageDeactivateError){
                                                   this.coveragesToCreate = coveragesToCreate;
                                                   this.hasRMFeedError = hasRMFeedError;
                                                   this.hasCoverageDeactivateError = hasCoverageDeactivateError;
                                                   generatedErrorCSVfile = 'Id,RM Account,Current RG,Previous RG,Error\n';
    }
    public List<sObject> start(Database.BatchableContext BC){
        return coveragesToCreate;
    }
    
    public void execute(Database.batchableContext info, List<sObject> scope){
        try
        {
            List<Coverage_Team_Member__c> coveragesToCreate = (List<Coverage_Team_Member__c>)scope;
            system.debug('Coverage Movement - Insert Job');
            /*for(Coverage_Team_Member__c tm: coveragesToCreate){
                system.debug(tm.uniqueId__c);
            }*/
            if(coveragesToCreate.size()>0){
                Integer i = 0;
                Database.SaveResult[] saveResult = Database.insert(coveragesToCreate, false);
                for (Database.SaveResult output : saveResult){  
                    if (!output.isSuccess()){  
                        for (Database.Error error : output.getErrors()){  
                            // errors here  
                            generatedErrorCSVfile += '"'+coveragesToCreate.get(i).UniqueID__c+'"'+','
                                +'"'+coveragesToCreate.get(i).Account__c+'"'+','
                                +'"'+coveragesToCreate.get(i).Account__r.Current_RG__c+'"'+','
                                +'"'+coveragesToCreate.get(i).Account__r.Previous_RG__c+'"'+','
                                +'"'+error.getMessage()+'"'+'\n';
                            
                            unprocessed_rmIds.add(coveragesToCreate.get(i).Account__c);
                            hasError = true;
                        }   
                    }
                    i++;
                }
            }
        }
        catch(Exception e)
        {
            exception_message += e+'\n'+e.getStackTraceString();
            exception_message += '\n';
            hasCoverageInsertError = true;
            batchExecutionSuccessfully = false;
        }
    }
    
    public void finish(Database.batchableContext info){ 
        if(hasError)
        {
            system.debug('Error processing Source & Destination Coverage Insert Feed. Attached records processing for email');
            CommonTools.emailLog('ERRORS','RM Feed Daily JOB - Daily_RMFeed_Source_InsertCoverages','Attached are the records which have errors\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'TECH');
        }
        if(!batchExecutionSuccessfully)
        {
            system.debug('Exception processing Source & Destination Coverage Insert Feed.....');
            system.debug(exception_message);
            CommonTools.emailLog('FAILURE','RM Feed Daily JOB - Daily_RMFeed_Source_InsertCoverages',exception_message+'\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'TECH');
        }
        
        //Fix for JIRA 3643
        //Set<Id> new_rmIds= new Map<Id,Account>([SELECT Id FROM Account where isNewRM__c=true and Active__c = true]).keyset();
        //List<Account> lst_rmIds= new List<Account>([SELECT Id,parentid FROM Account where isNewRM__c=true and Active__c = true]);
        Set<Id> newRGId = new Set<Id>();
        Set<Id> new_rmIds = new Set<Id>();
        for(Account rmAccount: [SELECT Id,parentid FROM Account where RecordType.DeveloperName = 'RM_Account' and isNewRM__c=true and Active__c = true]){
            newRGId.add(rmAccount.parentid);
            new_rmIds.add(rmAccount.Id);
        }        
        //for(Account rmAccount: [select id, parentid from Account where id in:new_rmIds])
        //{newRGId.add(rmAccount.parentid);}
        System.debug('Calling Clear Job for RM Movement flag');        
        Database.executeBatch(new Daily_RMFeed_Job_Clear(new_rmIds,newRGId,hasRMFeedError,hasCoverageInsertError), 200);

         
    }
}