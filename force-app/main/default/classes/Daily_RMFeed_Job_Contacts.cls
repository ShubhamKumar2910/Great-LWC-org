/*
	Author 		: Sagar Kambli
	Company 	: Nomura 
	Date 		: 05/07/2018
    Description : RM Feed Job (Batch 1)
				a.	    Batch 1: Process Daily_RMFeed_Job_Contacts (RM Contacts to NEW RG)
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
                //s.    Batch 17. Process Daily_RMPODLinkStartBatch
                //t.    Batch 18. Process Daily_RMPodLinkProcessBatch
                //u.    Batch 19. Process Daily_RMPodLinkEndBatch
                //v.    Batch 20. Process Daily_DeletePODCoverage
*/
global class Daily_RMFeed_Job_Contacts implements Database.batchable<sObject>, Database.Stateful{ 
    
    public string query {get;set;}
    public Boolean hasError  = false;
    public Boolean hasFeedError = false;
    private String exception_message = '';
    private Boolean batchExecutionSuccessfully = true;
    public string generatedErrorCSVfile = '';
    public Map<Id,string> contact_rm_map = new Map<Id,string>();
    
    public Daily_RMFeed_Job_Contacts(){
        
        query = 'SELECT Id FROM Contact where Account.isRMChanged__c = true';
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
            Set<Id> contactIds = (new Map<Id,SObject>(scope)).keySet();
            List<Contact> rmContacts_to_Update = new List<Contact>();
            for(Contact contactRecord :[select Id,POD_Account__c,RG_Account__r.RDM_Org_ID__c,AccountId,Account.Parent.RDM_Org_ID__c,Account.Current_RG__c,Account.Previous_RG__c,RG_Account__c from Contact where Id in:contactIds])
            {
                system.debug('------------------CONTACT RECORD START PROCESS--------------------');
                if(contactRecord.RG_Account__c == contactRecord.Account.Previous_RG__c){
                    contactRecord.RG_Account__c = contactRecord.Account.Current_RG__c;
                    contactRecord.POD_Account__c = null;
                    contactRecord.Source__c = 'RM Movement';
                    rmContacts_to_Update.add(contactRecord);
                    system.debug(contactRecord);
                }
                //test forcefully events if not run
                //contact_rm_map.put(contactRecord.Id, contactRecord.AccountId+'~'+contactRecord.Account.Current_RG__c+'~'+'0015D000004gKU6');//contactId,rmId
                system.debug('------------------CONTACT RECORD END PROCESS----------------------');
            }
            if(rmContacts_to_Update.size()>0)
            {
                system.debug('rmContacts_to_Update size: '+rmContacts_to_Update.size());
                Database.SaveResult[] updateResult = Database.update(rmContacts_to_Update, false);
                Integer i = 0;
                for (Database.SaveResult output : updateResult){  
                    if (!output.isSuccess()){  
                        for (Database.Error error : output.getErrors()){  
                            // errors here  
                            generatedErrorCSVfile += '"'+rmContacts_to_Update.get(i).Id+'"'+','
                                +'"'+rmContacts_to_Update.get(i).AccountId+'"'+','
                                +'"'+rmContacts_to_Update.get(i).Account.Current_RG__c+'"'+','
                                +'"'+rmContacts_to_Update.get(i).Account.Previous_RG__c+'"'+','
                                +'"'+error.getMessage()+'"'+'\n';
                            hasError = true;
                            //hasFeedError = true;
                        }   
                    }
                    else
                    {
                        contact_rm_map.put(rmContacts_to_Update.get(i).Id, rmContacts_to_Update.get(i).AccountId+'~'+rmContacts_to_Update.get(i).Account.Current_RG__c+'~'+rmContacts_to_Update.get(i).Account.Previous_RG__c);//contactId,rmId
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
        }
    }
    
    global void finish(Database.batchableContext info){  
        if(hasError)
        {
            system.debug('Errors processing contacts. Attached records processing for email');
            system.debug(generatedErrorCSVfile);
            CommonTools.emailLog('ERRORS','RM Feed Daily JOB - Contacts','Attached are the records which have errors\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'TECH');
        }
        if(!batchExecutionSuccessfully)
        {
            system.debug('Exception processing contacts');
            system.debug(exception_message);
            CommonTools.emailLog('FAILURE','RM Feed Daily JOB - Contacts',exception_message+'\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'TECH');
        }
        system.debug('Total Contacts Processed: '+contact_rm_map.keySet().size());
        system.debug('Calling Events....');
        Database.executeBatch(new Daily_RMFeed_Job_Events(contact_rm_map,hasFeedError), 5000);
    }
}