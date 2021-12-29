/*
	Author 		: Sagar Kambli
	Company 	: Nomura 
	Date 		: 06/07/2018
    Description : RM Feed Job (Batch 4)
				//a.	Batch 1: Process Daily_RMFeed_Job_Contacts (RM Contacts to NEW RG)
				//b.	Batch 2: Process Daily_RMFeed_Job_Events (Events to NEW RG)
				//c.	Batch 3: Process Daily_RMFeed_Job_Tasks (Tasks to NEW RG)
				d.	    Batch 4: Process Daily_RMFeed_Job_Opportunity (Opportunity)
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
                //s.    Batch 17. Process Daily_RMPODLinkStartBatch
                //t.    Batch 18. Process Daily_RMPodLinkProcessBatch
                //u.    Batch 19. Process Daily_RMPodLinkEndBatch
                //v.    Batch 20. Process Daily_DeletePODCoverage
*/
global class Daily_RMFeed_Job_Opportunity implements Database.batchable<sObject>, Database.Stateful{ 
    
    public string query {get;set;}
    public Boolean hasError  = false;
    public Boolean hasFeedError = false;
    private String exception_message = '';
    private Boolean batchExecutionSuccessfully = true;
    public string generatedErrorCSVfile = '';
    
    public Daily_RMFeed_Job_Opportunity(Boolean hasFeedError){
        this.hasFeedError = hasFeedError;
        query = 'SELECT Id FROM Opportunity where Account.isRMChanged__c = true and RecordType.DeveloperName=\'Automated\'';
        generatedErrorCSVfile = 'Id,RM Account,Current RG,Previous RG,Error\n';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.batchableContext info, List<sObject> scope){
        system.debug('Record Size: '+scope.size());
        SavePoint sp;
        try
        {
            sp = Database.setSavepoint();
            Set<Id> oppIds = (new Map<Id,SObject>(scope)).keySet();
            List<Opportunity> rmOpportunity_to_Update = new List<Opportunity>();
           for(Opportunity opp :[select Id,Account__c,AccountId,Account.Current_RG__c,Account.Previous_RG__c from Opportunity where Id in:oppIds])
            {
                system.debug('------------------OPPORTUNITY RECORD START PROCESS--------------------');
                if(opp.Account__c == opp.Account.Previous_RG__c){
                    opp.Account__c = opp.Account.Current_RG__c;
                    rmOpportunity_to_Update.add(opp);
                    system.debug(opp);
                }
                system.debug('------------------OPPORTUNITY RECORD END PROCESS----------------------');
            }
            
            if(rmOpportunity_to_Update.size()>0)
            {
                system.debug('rmOpportunity_to_Update size: '+rmOpportunity_to_Update.size());
                Database.SaveResult[] updateResult = Database.update(rmOpportunity_to_Update, false);
                Integer i = 0;
                for (Database.SaveResult output : updateResult){  
                    if (!output.isSuccess()){  
                        for (Database.Error error : output.getErrors()){  
                            // errors here  
                            generatedErrorCSVfile += '"'+rmOpportunity_to_Update.get(i).Id+'"'+','
                                +'"'+rmOpportunity_to_Update.get(i).AccountId+'"'+','
                                +'"'+rmOpportunity_to_Update.get(i).Account.Current_RG__c+'"'+','
                                +'"'+rmOpportunity_to_Update.get(i).Account.Previous_RG__c+'"'+','
                                +'"'+error.getMessage()+'"'+'\n';
                            hasError = true;
                            //hasFeedError = true;
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
            hasFeedError = true;
            system.debug(exception_message);
        }
    }
    
    global void finish(Database.batchableContext info){  
        if(hasError)
        {
            system.debug('Errors processing Opportunity. Attached records processing for email');
            system.debug(generatedErrorCSVfile);
            CommonTools.emailLog('ERRORS','RM Feed Daily JOB - Opportunity','Attached are the records which have errors\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'TECH');
        }
        if(!batchExecutionSuccessfully)
        {
            system.debug('Exception processing Opportunity.....');
            system.debug(exception_message);
            CommonTools.emailLog('FAILURE','RM Feed Daily JOB - Opportunity',exception_message+'\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'TECH');
        }
        
        system.debug('Calling Instinet Champion Movement Job.....');
        Database.executeBatch(new Daily_RMFeed_Job_InstinetChampion(hasFeedError), 1);
    }
}