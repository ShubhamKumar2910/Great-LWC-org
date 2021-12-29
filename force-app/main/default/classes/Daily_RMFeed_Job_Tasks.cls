/*
	Author 		: Sagar Kambli
	Company 	: Nomura 
	Date 		: 06/07/2018
    Description : RM Feed Job (Batch 3)
				//a.	Batch 1: Process Daily_RMFeed_Job_Contacts (RM Contacts to NEW RG)
				//b.	Batch 2: Process Daily_RMFeed_Job_Events (Events to NEW RG)
				c.	    Batch 3: Process Daily_RMFeed_Job_Tasks (Tasks to NEW RG)
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
                //s.    Batch 17. Process Daily_RMPODLinkStartBatch
                //t.    Batch 18. Process Daily_RMPodLinkProcessBatch
                //u.    Batch 19. Process Daily_RMPodLinkEndBatch
                //v.    Batch 20. Process Daily_DeletePODCoverage
*/
global class Daily_RMFeed_Job_Tasks implements Database.batchable<sObject>, Database.Stateful{ 
    
    public string query {get;set;}
    public Boolean hasError  = false;
    public Boolean hasFeedError = false;
    private String exception_message = '';
    private Boolean batchExecutionSuccessfully = true;
    public string generatedErrorCSVfile = '';
    Set<Id> contactIds = new Set<Id>();
    Map<Id,string> contact_rm_map = new Map<Id,string>();
    
    public Daily_RMFeed_Job_Tasks(Map<Id,string> contact_rm_map,Boolean hasFeedError){
        this.hasFeedError = hasFeedError;
        contactIds  = contact_rm_map.keyset();
        this.contact_rm_map = contact_rm_map;
        query = 'SELECT Id FROM Task where whoId in:contactIds and IsDeleted = false ALL ROWS';
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
            Set<Id> taskIds = (new Map<Id,SObject>(scope)).keySet();
            List<Task> rmTasks_to_Update = new List<Task>();
            String accountInfo = '';
            string Current_RG = '';
            string Previous_RG = '';
            string rm_Account = '';
            for(Task e :[select Id,whatId,whoId from Task where Id in:taskIds])
            {
                accountInfo = '';
                Current_RG = '';
                Previous_RG = '';
                rm_Account = '';
                
                if(e.WhoId!=null)
                {
                    if(contact_rm_map.get(e.whoId)!=null){
                        accountInfo = contact_rm_map.get(e.whoId);
                        System.debug('-------(e.whoId)-------' + e.whoId);
                        System.debug('-------contact_rm_map.get(e.whoId)-------' + contact_rm_map.get(e.whoId));
                        System.debug('-------accountInfo-------' + accountInfo + '-----e.whatID---' + e.WhatId);
                        string[] accountArr = accountInfo.split('~');
                        if(accountArr.size()==3){
                            rm_Account  = accountArr[0];
                            Current_RG  = accountArr[1];
                            Previous_RG =  accountArr[2];
                            System.debug('-------rm_Account-------' + rm_Account + '---Current_RG--' + Current_RG + '--Previous_RG-' + Previous_RG);
                            if(rm_Account!='' && Current_RG!='' && Previous_RG!='' &&
                              e.WhatId==Previous_RG){
                                  e.WhatId = Current_RG;
                                  rmTasks_to_Update.add(e);
                            }
                        }
                    }
                }
                
               
            }
            
            if(rmTasks_to_Update.size()>0)
            {
                system.debug('rmTasks_to_Update size: '+rmTasks_to_Update.size());
                Database.SaveResult[] updateResult = Database.update(rmTasks_to_Update, false);
                Integer i = 0;
                accountInfo = '';
                Current_RG = '';
                Previous_RG = '';
                rm_Account = '';
                for (Database.SaveResult output : updateResult){  
                    if (!output.isSuccess()){  
                        for (Database.Error error : output.getErrors()){  
                            if(contact_rm_map.get(rmTasks_to_Update.get(i).whoId)!=null){
                                accountInfo = contact_rm_map.get(rmTasks_to_Update.get(i).whoId);
                                string[] accountArr = accountInfo.split('~');
                                if(accountArr.size()==3){
                                    rm_Account  = accountArr[0];
                                    Current_RG  = accountArr[1];
                                    Previous_RG =  accountArr[2];
                                    // errors here  
                                    generatedErrorCSVfile += '"'+rmTasks_to_Update.get(i).Id+'"'+','
                                        +'"'+rm_Account+'"'+','
                                        +'"'+Current_RG+'"'+','
                                        +'"'+Previous_RG+'"'+','
                                        +'"'+error.getMessage()+'"'+'\n';
                                }
                            }
                            hasError = true;
                            //hasFeedError = true;
                        }   
                    }
                    /*else
                    {
                    contact_rm_map.put(rmContacts_to_Update.get(i).Id, rmContacts_to_Update.get(i).AccountId+'~'+rmContacts_to_Update.get(i).Account.Current_RG__c+'~'+rmContacts_to_Update.get(i).Account.Previous_RG__c);//contactId,rmId
                    }*/
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
            system.debug('Errors processing tasks. Attached records processing for email');
            system.debug(generatedErrorCSVfile);
            CommonTools.emailLog('ERRORS','RM Feed Daily JOB - Tasks','Attached are the records which have errors\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'TECH');
        }
        if(!batchExecutionSuccessfully)
        {
            
            system.debug('Exception processing tasks');
            system.debug(exception_message);
            CommonTools.emailLog('FAILURE','RM Feed Daily JOB - Tasks',exception_message+'\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'TECH');
        }
        system.debug('Calling Opportunity.....');
        Database.executeBatch(new Daily_RMFeed_Job_Opportunity(hasFeedError), 200); 
    }
}