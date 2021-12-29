/*
    Description : RM Feed Job (Batch 7.2 / Batch 13.2)
				//a.	Batch 1: Process Daily_RMFeed_Job_Contacts (RM Contacts to NEW RG)
				//b.	Batch 2: Process Daily_RMFeed_Job_Events (Events to NEW RG)
				//c.	Batch 3: Process Daily_RMFeed_Job_Tasks (Tasks to NEW RG)
				//d.	Batch 4: Process Daily_RMFeed_Job_Opportunity (Opportunity)
				//e.	Batch 5: Process Daily_RMFeed_Job_InstinetChampion
				//f.	Batch 6: Process Daily_RMFeed_Job_InstinetCoverage
				//g.    Batch 7.1: Process Daily_QueryCvgTeamMemberRequestType (Query Coverage records to update label as RG/RM)
                h.      Batch 7.2: Process Daily_UpdateCvgTeamMemberRequestType (Update Coverage records label as RG/RM))
				//i.	Batch 8: Process Daily_RMFeed_Job_Coverage_Movement (Coverage Movement @ RG Salesperson)
				//j.	Batch 9: Process Daily_RMFeed_Job_Coverage_Movement_RM (Coverage Movement @ RM Salesperson)
				//k.	Batch 10: Process Daily_RMFeed_Coverage_Movement_End
				//l.	Batch 11: Process Daily_RMFeed_Coverage_Movement_Insert
                //m.    Batch 12. Process Daily_RMFeed_Job_Clear (Reset RM Movement flag)
				//n.    Batch 13.1: Process Daily_QueryCvgTeamMemberRequestType (Chaining Batch 7.1 Job)
                o.	    Batch 13.2: Process Daily_UpdateCvgTeamMemberRequestType (Chaining Batch 7.2 Job)
				//p.	Batch 14: Process Daily_RMFeed_Job_Coverage_NewRM
				//q.	Batch 15: Process Daily_RMFeed_Coverage_NewRM_Insert
				//r.    Batch 16. Process Daily_RMFeed_Job_Clear (Reset new RM flag - Chaning Batch 12)
                //s.    Batch 17. Process Daily_RMPODLinkStartBatch
                //t.    Batch 18. Process Daily_RMPodLinkProcessBatch
                //u.    Batch 19. Process Daily_RMPodLinkEndBatch
                //v.    Batch 20. Process Daily_DeletePODCoverage
*/
global class Daily_UpdateCvgTeamMemberRequestType implements Database.Batchable<Coverage_Team_Member__c>, Database.Stateful,Database.AllowsCallouts{

    global String currentTimeStamp = '';
    global final String CONFIG_NAME = 'UpdateCvgTeamMemberRequestType';
    global final String PARAM_NAME = 'LastUpdatedTimeStamp';
    global Boolean isPrevJobRMMovement = false;
    global Set<Id> new_rmIds = new Set<Id>();
    global Set<Id> new_rgIds = new Set<Id>();
    global Boolean hasError  = false;
    global Boolean hasRMFeedError = false;
    global Boolean hasCoverageInsertError = false;
    global String exception_message = '';
    global Boolean batchExecutionSuccessfully = true;
    global String generatedErrorCSVfile = '';
    global List<Coverage_Team_Member__c> recordsToUpdate = new List<Coverage_Team_Member__c>();

    public Daily_UpdateCvgTeamMemberRequestType(Boolean hasRMFeedError, List<Coverage_Team_Member__c> recordsToUpdate, String currentTimeStamp){
	    this.hasRMFeedError = hasRMFeedError;
        this.recordsToUpdate = recordsToUpdate;
        this.currentTimeStamp = currentTimeStamp;
        generatedErrorCSVfile = 'Id,RM Account Id,RM Account Name,Salesperson Id,Salesperson Name,Group By,Error\n';
        isPrevJobRMMovement = false;
    }

    public Daily_UpdateCvgTeamMemberRequestType(Set<Id> new_rmIds,Set<Id> new_rgIds,Boolean hasRMFeedError,Boolean hasCoverageInsertError, List<Coverage_Team_Member__c> recordsToUpdate, String currentTimeStamp){
        this.hasRMFeedError = hasRMFeedError;
        this.new_rmIds = new_rmIds;
        this.new_rgIds = new_rgIds;
        this.hasCoverageInsertError = hasCoverageInsertError;
        this.recordsToUpdate = recordsToUpdate;
        this.currentTimeStamp = currentTimeStamp;
        generatedErrorCSVfile = 'Id,RM Account Id,RM Account Name,Salesperson Id,Salesperson Name,Group By,Error\n';
        isPrevJobRMMovement = true;
    }

    global List<Coverage_Team_Member__c> start(Database.BatchableContext bc){
        System.debug('Start');
        return recordsToUpdate;
    }

    global void execute(Database.BatchableContext bc, List<Coverage_Team_Member__c> recordsToUpdate){
        try{
            System.debug('recordsToUpdate Size ' + recordsToUpdate.size());
            if(recordsToUpdate.size() > 0){
                System.debug('Updating records');
                //update recordsToUpdate;

                Database.SaveResult[] updateResult = Database.update(recordsToUpdate, false);
                Integer i = 0;
                for (Database.SaveResult output : updateResult){  
                    if (!output.isSuccess()){  
                        for (Database.Error error : output.getErrors()){  
                            // errors here  
                            generatedErrorCSVfile += '"'+recordsToUpdate.get(i).Id+'"'+','
                                +'"'+recordsToUpdate.get(i).Account__c+'"'+','
                                +'"'+recordsToUpdate.get(i).Account__r.Name+'"'+','
                                +'"'+recordsToUpdate.get(i).Sales_Team_for_Coverage__c+'"'+','
                                +'"'+recordsToUpdate.get(i).Sales_Team_for_Coverage__r.Name+'"'+','
                                +'"'+recordsToUpdate.get(i).Group_By__c+'"'+','
                                +'"'+error.getMessage()+'"'+'\n';
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
            batchExecutionSuccessfully = false;
            hasRMFeedError = true;
            system.debug(exception_message);
        }
    }

    global void finish(Database.BatchableContext bc){
        System.debug('Finish Method');
        if(hasError)
        {
            system.debug('Errors processing Coverage Team Member Request Type Update. Attached records processing for email');
            system.debug(generatedErrorCSVfile);
            CommonTools.emailLog('ERRORS','RM Feed Daily JOB - Daily_UpdateCvgTeamMemberRequestType','Attached are the records which have errors\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'TECH');
        }
		if(!batchExecutionSuccessfully)
        {
            system.debug('Exception processing Coverage Team Member Request Type Update.....');
            system.debug(exception_message);
            CommonTools.emailLog('FAILURE','RM Feed Daily JOB - Daily_UpdateCvgTeamMemberRequestType',exception_message+'\n\nRegards,\nSalesforce Tech',null,'TECH');
        }
        if(batchExecutionSuccessfully && !hasError){
            CommonTools.updateParameterValueInConfiguration(CONFIG_NAME,PARAM_NAME,currentTimeStamp);            
        }

        if(!isPrevJobRMMovement){
            if(batchExecutionSuccessfully && !hasError){
                System.debug('Calling Coverage Movement Job');
                Database.executeBatch(new Daily_RMFeed_Job_Coverage_Movement(hasRMFeedError), 1);
            }else{
                System.debug('Failure in Daily_UpdateCvgTeamMemberRequestType. Not calling other chained jobs');
            }
        }else{
            system.debug('Calling NEW RM Coverage Feed');
            Database.executeBatch(new Daily_RMFeed_Job_Coverage_NewRM(new_rmIds,new_rgIds,hasRMFeedError,hasCoverageInsertError), 200);
        }
    }
}