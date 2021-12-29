/*
    Description : RM Feed Job (Batch 18)
                //a.    Batch 1: Process Daily_RMFeed_Job_Contacts (RM Contacts to NEW RG)
                //b.    Batch 2: Process Daily_RMFeed_Job_Events (Events to NEW RG)
                //c.    Batch 3: Process Daily_RMFeed_Job_Tasks (Tasks to NEW RG)
                //d.    Batch 4: Process Daily_RMFeed_Job_Opportunity (Opportunity)
                //e.    Batch 5: Process Daily_RMFeed_Job_InstinetChampion
                //f.    Batch 6: Process Daily_RMFeed_Job_InstinetCoverage
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
                t.      Batch 18. Process Daily_RMPodLinkProcessBatch
                //u.    Batch 19. Process Daily_RMPodLinkEndBatch
                //v.    Batch 20. Process Daily_DeletePODCoverage
*/
global class Daily_RMPodLinkProcessBatch implements Database.Batchable<AggregateResult>, Database.Stateful, Database.AllowsCallouts{
    
    global String generatedErrorCSVfile = '';
    global String exception_message = '';
    global Boolean batchExecutionSuccessfully = true;
    global Boolean hasError  = false;

    public Daily_RMPodLinkProcessBatch() {}

     global Iterable<AggregateResult> start(Database.BatchableContext bc){

        /*
          Get all distinct RM-POD linkage from Contact and pass it to execute method 
        */
        List<AggregateResult> rmPodLinkList = [SELECT AccountId, POD_Account__c, Account.RDM_Org_ID__c RM_RDM_Org_Id, POD_Account__r.RDM_Org_ID__c POD_RDM_Org_Id FROM Contact
                             WHERE POD_Account__c != '' GROUP BY AccountId, POD_Account__c, Account.RDM_Org_ID__c, POD_Account__r.RDM_Org_ID__c];
        return rmPodLinkList;
    }

    global void execute(Database.BatchableContext bc, List<AggregateResult> rmPodLinkItems){

        Map<String,RM_POD_Link__c> RM_POD_Link_Map = new Map<String,RM_POD_Link__c>();

        try{
          /*
            Form the RM_POD_Link list of object from the data received from start method
          */
          for(AggregateResult item : rmPodLinkItems)
          {
              String RmPodKey = string.valueOf(item.get('RM_RDM_Org_Id')) + '#' + string.valueOf(item.get('POD_RDM_Org_Id'));

              RM_POD_Link__c RM_POD_Link_obj = new RM_POD_Link__c();

              RM_POD_Link_obj.RM_POD_Key__c = RmPodKey;
              RM_POD_Link_obj.RM_Account__c = string.valueOf(item.get('AccountId'));
              RM_POD_Link_obj.POD_Account__c = string.valueOf(item.get('POD_Account__c'));

              RM_POD_Link_Map.put(RmPodKey, RM_POD_Link_obj);
          }

          /*
            Compare the above formed list with RM_POD_Link object in the system
          */

          List<RM_POD_Link__c> rmPodLinkList = [SELECT Id, RM_Account__c, POD_Account__c, Processed__c, RM_POD_Key__c FROM RM_POD_Link__c];

          Boolean rmPodKeyFound;
          List<RM_POD_Link__c> recordsToUpsert = new List<RM_POD_Link__c>();
          List<RM_POD_Link__c> recordsToInsert = new List<RM_POD_Link__c>();
          
          for(String mapkey : RM_POD_Link_Map.keySet()){
              
              rmPodKeyFound = false;

              RM_POD_Link__c mapItems = RM_POD_Link_Map.get(mapkey);

              for(RM_POD_Link__c item : rmPodLinkList)
              {
                  if(mapkey.equals(item.RM_POD_Key__c))  //RM-POD mapping found, upsert the record
                  {
                      rmPodKeyFound = true;
                      item.Processed__c = true;
                      recordsToUpsert.add(item);
                      break;
                  }
              }

              if(!rmPodKeyFound)  //RM-POD mapping not found, insert the record
              {
                  RM_POD_Link__c obj = new RM_POD_Link__c();
                  obj.RM_Account__c = mapItems.RM_Account__c;
                  obj.POD_Account__c =  mapItems.POD_Account__c;
                  obj.Processed__c = true;
                  obj.RM_POD_Key__c = mapkey;
                  recordsToInsert.add(obj);
              }

          }
           Database.UpsertResult[] saveResult = Database.upsert(recordsToUpsert, false);
                  Integer itr = 0;
                  for (Database.UpsertResult output : saveResult){
                    if (!output.isSuccess()){
                        for (Database.Error error : output.getErrors()){
                            // errors here  
                            generatedErrorCSVfile += '"'+recordsToUpsert.get(itr).Id+'"'+','
                                +'"'+recordsToUpsert.get(itr).RM_Account__r.Name+'"'+','
                                +'"'+recordsToUpsert.get(itr).POD_Account__r.Name+'"'+','
                                +'"'+recordsToUpsert.get(itr).Processed__c+'"'+','
                                +'"'+recordsToUpsert.get(itr).RM_POD_Key__c+'"'+','
                                +'"'+error.getMessage()+'"'+'\n';                            
                            hasError = true;
                        }   
                    }
                    itr++;
                  }

            Database.SaveResult[] saveResult1 = Database.insert(recordsToInsert, false);
                  Integer itr1 = 0;
                  for (Database.SaveResult output : saveResult1){
                    if (!output.isSuccess()){
                        for (Database.Error error : output.getErrors()){
                            // errors here  
                            generatedErrorCSVfile += '"'+recordsToInsert.get(itr1).Id+'"'+','
                                +'"'+recordsToInsert.get(itr1).RM_Account__r.Name+'"'+','
                                +'"'+recordsToInsert.get(itr1).POD_Account__r.Name+'"'+','
                                +'"'+recordsToInsert.get(itr1).Processed__c+'"'+','
                                +'"'+recordsToInsert.get(itr1).RM_POD_Key__c+'"'+','
                                +'"'+error.getMessage()+'"'+'\n';                            
                            hasError = true;
                        }
                    }
                    itr1++;
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
        /*
          Now the one with Processed flag set to false needs to be deleted in next Job
        */
        if(hasError)
        {
            system.debug('Errors processing RMPodLinkProcessBatch. Attached records processing for email');
            system.debug(generatedErrorCSVfile);
            CommonTools.emailLog('ERRORS','RM Feed Daily JOB - Daily_RMPodLinkProcessBatch','Attached are the records which have errors\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'TECH');
        }
		    if(!batchExecutionSuccessfully)
        {
            system.debug('Exception processing RMPodLinkProcessBatch.....');
            system.debug(exception_message);
            CommonTools.emailLog('FAILURE','RM Feed Daily JOB - Daily_RMPodLinkProcessBatch',exception_message+'\n\nRegards,\nSalesforce Tech',null,'TECH');
        }
        else{
          if(!Test.isRunningTest()){
              system.debug('Calling RM POD link Job - End');
              Database.executeBatch(new Daily_RMPodLinkEndBatch(), 200);
          }
        }
    }
}