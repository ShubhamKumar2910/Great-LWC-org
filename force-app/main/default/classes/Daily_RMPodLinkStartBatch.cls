/*
    Description : RM Feed Job (Batch 17)
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
				//p.	Batch 14: Process Daily_RMFeed_Job_Coverage_NewRM
				//q.	Batch 15: Process Daily_RMFeed_Coverage_NewRM_Insert
				//r.    Batch 16. Process Daily_RMFeed_Job_Clear (Reset new RM flag - Chaning Batch 12)
                s.      Batch 17. Process Daily_RMPODLinkStartBatch
                //t.    Batch 18. Process Daily_RMPodLinkProcessBatch
                //u.    Batch 19. Process Daily_RMPodLinkEndBatch
                //v.    Batch 20. Process Daily_DeletePODCoverage
*/
global class Daily_RMPodLinkStartBatch implements Database.Batchable<SObject>{

    global String generatedErrorCSVfile = '';
    global String exception_message = '';
    global Boolean batchExecutionSuccessfully = true;
    global Boolean hasError  = false;

    public Daily_RMPodLinkStartBatch() {}

    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, Processed__c FROM RM_POD_Link__c';
        return Database.getQueryLocator(query); 
    }

    global void execute(Database.BatchableContext bc, List<RM_POD_Link__c> rmPodLinkList){
        try{
            if(rmPodLinkList.size() > 0) {
                for(RM_POD_Link__c  rmPodLinkObj : rmPodLinkList)
                {
                    rmPodLinkObj.Processed__c = false;
                }
                Database.SaveResult[] updateResult = Database.update(rmPodLinkList, false);
                    Integer i = 0;
                    for (Database.SaveResult output : updateResult){  
                        if (!output.isSuccess()){
                            for (Database.Error error : output.getErrors()){  
                                // errors here  
                                generatedErrorCSVfile += '"'+rmPodLinkList.get(i).Id+'"'+','
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
            system.debug(exception_message);
        }

    }

    global void finish(Database.BatchableContext bc){
        if(hasError)
        {
            system.debug('Errors processing RMPodLinkStartBatch. Attached records processing for email');
            system.debug(generatedErrorCSVfile);
            CommonTools.emailLog('ERRORS','RM Feed Daily JOB - Daily_RMPodLinkStartBatch','Attached are the records which have errors\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'TECH');
        }
		if(!batchExecutionSuccessfully)
        {
            system.debug('Exception processing RMPodLinkStartBatch.....');
            system.debug(exception_message);
            CommonTools.emailLog('FAILURE','RM Feed Daily JOB - Daily_RMPodLinkStartBatch',exception_message+'\n\nRegards,\nSalesforce Tech',null,'TECH');
        }
        else{
            if(!Test.isRunningTest()){
                system.debug('Calling RM POD link Job - Process');
                Database.executeBatch(new Daily_RMPodLinkProcessBatch(), 10);
            }
        }
    }
    
}