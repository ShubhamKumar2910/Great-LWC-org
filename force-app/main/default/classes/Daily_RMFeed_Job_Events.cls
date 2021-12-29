/*
	Author 		: Sagar Kambli
	Company 	: Nomura 
	Date 		: 06/07/2018
    Description : RM Feed Job (Batch 2)
				//a.	Batch 1: Process Daily_RMFeed_Job_Contacts (RM Contacts to NEW RG)
				b.	    Batch 2: Process Daily_RMFeed_Job_Events (Events to NEW RG)
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
global class Daily_RMFeed_Job_Events implements Database.batchable<sObject>, Database.Stateful{ 
    
    public string query {get;set;}
    public Boolean hasError  = false;
    public Boolean hasFeedError = false;
    private String exception_message = '';
    private Boolean batchExecutionSuccessfully = true;
    public string generatedErrorCSVfile = '';
    Set<Id> contactIds = new Set<Id>();
    Map<Id,string> contact_rm_map = new Map<Id,string>();
    public Map<string,string> newRGRDM = new Map<string,string>();
    
    public Daily_RMFeed_Job_Events(Map<Id,string> contact_rm_map,Boolean hasFeedError){
        this.hasFeedError = hasFeedError;
        contactIds  = contact_rm_map.keyset();
        this.contact_rm_map = contact_rm_map;
        query = 'SELECT Id FROM Event where isChild = false and whoId in:contactIds and IsDeleted = false ALL ROWS';
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
            Set<Id> eventIds = (new Map<Id,SObject>(scope)).keySet();
            List<Event> rmEvents_to_Update = new List<Event>();
            String accountInfo = '';
            string Current_RG = '';
            string Previous_RG = '';
            string rm_Account = '';
			Set<string> rgIds = new Set<string>();
            //Map<id,string> rdmbyId = new Map<id,string>();
            
            for(Event e :[select Id,whatId,whoId,cp_id__c,RecordType.DeveloperName from Event where Id in:eventIds])
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
                              e.WhatId==Previous_RG ){
                                  rgIds.add(Current_RG);
                                  rgIds.add(Previous_RG);
                                  e.WhatId = Current_RG;
                                  rmEvents_to_Update.add(e);
                            }
                        }
                    }
                }
                
               
            }
            
            /*for(Account act: [select id, rdm_org_ID__c from Account where id in:rgIds]){
                rdmbyId.put(act.id,act.rdm_org_ID__c);
            }
            system.debug(rmEvents_to_Update);
            for(Event eventToUpdate : rmEvents_to_Update){
                if(eventToUpdate.RecordType.DeveloperName == 'DealAxis_Event_Integration'){
                    accountInfo = contact_rm_map.get(eventToUpdate.whoId);
                    string[] accountArr = accountInfo.split('~'); 
                    if(accountArr.size()==3){
                        rm_Account  = accountArr[0];
                        Current_RG  = accountArr[1];
                        Previous_RG =  accountArr[2];
                        eventToUpdate.CP_ID__c = eventToUpdate.CP_ID__c.replace(rdmbyId.get(Previous_RG).trim(),rdmbyId.get(Current_RG).trim());
                    }
                }
                
            }*/
            
            
            if(rmEvents_to_Update.size()>0)
            {
                system.debug('rmEvents_to_Update size: '+rmEvents_to_Update.size());
                Database.SaveResult[] updateResult = Database.update(rmEvents_to_Update, false);
                Integer i = 0;
                accountInfo = '';
                Current_RG = '';
                Previous_RG = '';
                rm_Account = '';
                for (Database.SaveResult output : updateResult){  
                    if (!output.isSuccess()){  
                        for (Database.Error error : output.getErrors()){  
                            if(contact_rm_map.get(rmEvents_to_Update.get(i).whoId)!=null){
                                accountInfo = contact_rm_map.get(rmEvents_to_Update.get(i).whoId);
                                string[] accountArr = accountInfo.split('~');
                                if(accountArr.size()==3){
                                    rm_Account  = accountArr[0];
                                    Current_RG  = accountArr[1];
                                    Previous_RG =  accountArr[2];
                                    // errors here  
                                    generatedErrorCSVfile += '"'+rmEvents_to_Update.get(i).Id+'"'+','
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
                        if(rmEvents_to_Update.get(i).RecordType.DeveloperName=='DealAxis_Event_Integration')
                        {
                            accountInfo = contact_rm_map.get(rmEvents_to_Update.get(i).whoId);
                            string[] accountArr = accountInfo.split('~');
                            if(accountArr.size()==3){
                                rm_Account  = accountArr[0];
                                Current_RG  = accountArr[1];
                                Previous_RG =  accountArr[2];
                                newRGRDM.put(rmEvents_to_Update.get(i).cp_id__c,rdmbyId.get(Current_RG)+'~'+rdmbyId.get(Previous_RG));
                            }
                        }
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
            system.debug('Errors processing events. Attached records processing for email');
            system.debug(generatedErrorCSVfile);
            CommonTools.emailLog('ERRORS','RM Feed Daily JOB - Events','Attached are the records which have errors\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'TECH');
        }
        if(!batchExecutionSuccessfully)
        {
             system.debug('Exception processing events');
            system.debug(exception_message);
            CommonTools.emailLog('FAILURE','RM Feed Daily JOB - Events',exception_message+'\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'TECH');
        }
      
        /*//Update all DA Events
            List<DA_CorpClient_Attendee__c> daListToUpdate = new  List<DA_CorpClient_Attendee__c>();
            for(DA_CorpClient_Attendee__c da: [SELECT Id, Event_Meeting_ID__c FROM DA_CorpClient_Attendee__c WHERE Event_Meeting_ID__c in:newRGRDM.Keyset()])
            {
            if(newRGRDM.get(da.Event_Meeting_ID__c)!=null){
            string newMeetingId = newRGRDM.get(da.Event_Meeting_ID__c);
            list<string> Ids = newMeetingId.split('~');
            if(Ids.size()==2){
            string currentRG_RDM = Ids[0];
            string prevRG_RDM = Ids[1];
            da.Event_Meeting_ID__c = da.Event_Meeting_ID__c.replace(prevRG_RDM.trim(),currentRG_RDM.trim());
            daListToUpdate.add(da);
            }
            
            }
            }
            if(daListToUpdate.size()>0)
            update daListToUpdate;*/
                    
                    //CommonTools.emailLog('SUCCESS','RM Feed Daily JOB - Events','No Errors.\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'TECH');
        //Call another batch
        system.debug('Calling Task....');
        Database.executeBatch(new Daily_RMFeed_Job_Tasks(contact_rm_map,hasFeedError), 5000);
        
    }
}