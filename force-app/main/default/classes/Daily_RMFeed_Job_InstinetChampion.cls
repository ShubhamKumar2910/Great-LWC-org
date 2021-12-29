/*
    Description : RM Feed Job (Batch 5)
				//a.	Batch 1: Process Daily_RMFeed_Job_Contacts (RM Contacts to NEW RG)
				//b.	Batch 2: Process Daily_RMFeed_Job_Events (Events to NEW RG)
				//c.	Batch 3: Process Daily_RMFeed_Job_Tasks (Tasks to NEW RG)
				//d.	Batch 4: Process Daily_RMFeed_Job_Opportunity (Opportunity)
				e.	    Batch 5: Process Daily_RMFeed_Job_InstinetChampion
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
public class Daily_RMFeed_Job_InstinetChampion implements Database.batchable<sObject>, Database.Stateful {
    List<Sales_Champion__c> salesChampionErrorDeleteList; 
    List<Instinet_Coverage_Champion_Aggregated__c> instinetChampionAggregatedErrorDeleteList; 
    public string generatedErrorCSVfile = '';
    public Boolean hasFeedError = false;


    public Daily_RMFeed_Job_InstinetChampion(Boolean hasFeedError) {
        this.hasFeedError = hasFeedError;
        salesChampionErrorDeleteList = new List<Sales_Champion__c>();
        instinetChampionAggregatedErrorDeleteList = new List<Instinet_Coverage_Champion_Aggregated__c>();
        generatedErrorCSVfile = 'Id\n';
    }

    public Database.QueryLocator start(Database.BatchableContext batchableContext){
        String query = 'SELECT Id, Subset_Unique_ID__c, Champion_Login_ID_Detail__c, Champion_Login_ID_Detail__r.Login_Id__c, '
            + 'Account__c, Account__r.ParentId, Account__r.Previous_RG__c, Account__r.isRMChanged__c, Product_Region__c, Active__c ' 
            + 'FROM Instinet_Coverage_Champion_Aggregated__c ' 
            + 'WHERE RecordType.DeveloperName = \'Instinet_Champion\' AND ' 
            + 'Active__c = true AND '
            + 'Account__r.isRMChanged__c = true';
        
        return Database.getQueryLocator(query);
    }

    //scope would be 1 - one record would be handled at a time (one RM Movement)
    public void execute(Database.BatchableContext batchableContext, List<sObject> scope){
        List<Instinet_Coverage_Champion_Aggregated__c> instinetChampionAggregatedList = (List<Instinet_Coverage_Champion_Aggregated__c>)scope;

        Map<Id,String> championIdAndUniqueIdUsingRGMap = new Map<Id,String>();
        Set<Id> oldRGAccountIdSet = new Set<Id>();
        Set<String> uniqueIdUsingRGSet = new Set<String>();
        List<Sales_Champion__c> deleteInstinetChampionList =  new List<Sales_Champion__c>();
        String championQueryCriteria = '', salesChampionQuery = '';

        if(instinetChampionAggregatedList != null && instinetChampionAggregatedList.size() > 0){
            for(Instinet_Coverage_Champion_Aggregated__c instinetChampionAggregatedObj : instinetChampionAggregatedList){
                
                if(String.isNotEmpty(instinetChampionAggregatedObj.Account__r.Previous_RG__c)){
                    String subsetUniqueIdAtRGLevel = instinetChampionAggregatedObj.Account__r.Previous_RG__c + '#'
                     + instinetChampionAggregatedObj.Champion_Login_ID_Detail__r.Login_Id__c + '#'
                     + instinetChampionAggregatedObj.Product_Region__c;

                    oldRGAccountIdSet.add(instinetChampionAggregatedObj.Account__r.Previous_RG__c);
                    championIdAndUniqueIdUsingRGMap.put(instinetChampionAggregatedObj.Id, subsetUniqueIdAtRGLevel);
                }
                
            }

            //Fetch other active Champion Records present with Old RG (apart from RM Account whose RG is changed)
            if(championIdAndUniqueIdUsingRGMap.size() > 0 && oldRGAccountIdSet.size() > 0){
                List<Instinet_Coverage_Champion_Aggregated__c> activeChampionWithOldRGList = 
                    [SELECT Id, Account__c, Account__r.ParentId, Champion_Login_ID_Detail__c, Champion_Login_ID_Detail__r.Login_Id__c, Product_Region__c, Subset_Unique_ID__c FROM Instinet_Coverage_Champion_Aggregated__c
                     WHERE Active__c = TRUE AND Id NOT IN :championIdAndUniqueIdUsingRGMap.keySet() AND Account__r.ParentId IN :oldRGAccountIdSet 
                    ];

                 if(activeChampionWithOldRGList != null && activeChampionWithOldRGList.size() > 0){
                     for(Instinet_Coverage_Champion_Aggregated__c instinetChampionAggregatedObj : activeChampionWithOldRGList){
                        String subsetUniqueIdAtRGLevel = instinetChampionAggregatedObj.Account__r.ParentId + '#'
                            + instinetChampionAggregatedObj.Champion_Login_ID_Detail__r.Login_Id__c + '#'
                            + instinetChampionAggregatedObj.Product_Region__c;

                         uniqueIdUsingRGSet.add(subsetUniqueIdAtRGLevel);   

                     }
                 } 

                 /*
                  * If champion record is present because of other records then deletion is required only from Instinet_Coverage_Champion_Aggregated__c and not from Sales_Champion__c
                  * If champion record is not present then deletion is required from both
                  * Insertion using new RG will be handled by Instinet Champion Staging Batch Job
                  */

                 for(Instinet_Coverage_Champion_Aggregated__c instinetChampionAggregatedObj : instinetChampionAggregatedList){
                    if(championIdAndUniqueIdUsingRGMap.containsKey(instinetChampionAggregatedObj.Id))
                    {
                        Boolean recordToBeDeletedFromChampionTable = true;
                        String subsetUniqueIdAtRGLevel = championIdAndUniqueIdUsingRGMap.get(instinetChampionAggregatedObj.Id);

                        if(uniqueIdUsingRGSet.contains(subsetUniqueIdAtRGLevel)){
                            recordToBeDeletedFromChampionTable = false;
                        }

                        if(recordToBeDeletedFromChampionTable){
                            championQueryCriteria = championQueryCriteria + '(Account__c = \'' + instinetChampionAggregatedObj.Account__r.Previous_RG__c 
                                + '\' AND Instinet_Champion__c = \'' + instinetChampionAggregatedObj.Champion_Login_ID_Detail__c 
                                + '\' AND Region__c = \'' + InstinetFeedUtility.getSalesChampionRegion(instinetChampionAggregatedObj.Product_Region__c) + '\') OR ';
                        }
                    }
                 } 


                 //Delete the records from Sales_Champion__c
                 if(String.isNotEmpty(championQueryCriteria)){
                    championQueryCriteria = championQueryCriteria.substring(0, championQueryCriteria.lastIndexOf('OR'));
                    salesChampionQuery = 'SELECT Id FROM Sales_Champion__c WHERE RecordType.DeveloperName = \'Instinet_Champion\' AND ' + championQueryCriteria;
                    deleteInstinetChampionList = Database.query(salesChampionQuery);
                    salesChampionErrorDeleteList.addAll(InstinetFeedUtility.deleteInstinetChampionRecords(deleteInstinetChampionList));
                 }

                 //Delete the records from Instinet_Coverage_Champion_Aggregated__c
                 instinetChampionAggregatedErrorDeleteList.addAll(InstinetFeedUtility.deleteInstinetChampionAggregatedRecords(instinetChampionAggregatedList));
            }

         
        }

        
    }

    public void finish(Database.BatchableContext batchableContext){
          //Check whether error got generated. If yes then fill the error message
          Boolean hasError = FALSE;
          if(!salesChampionErrorDeleteList.isEmpty()){
              hasError = TRUE;
              for(Sales_Champion__c salesChampionObj : salesChampionErrorDeleteList){
                  generatedErrorCSVfile = generatedErrorCSVfile + '"' + salesChampionObj.Id + '"\n';
              }
          }

          if(!instinetChampionAggregatedErrorDeleteList.isEmpty()){
              hasError = TRUE;
              for(Instinet_Coverage_Champion_Aggregated__c aggregatedChampionObj : instinetChampionAggregatedErrorDeleteList){
                  generatedErrorCSVfile = generatedErrorCSVfile + '"' + aggregatedChampionObj.Id + '"\n';
              }
          }

          if(hasError){
            System.debug('Errors processing Sales_Champion__c records. Attached records processing for email');
            System.debug(generatedErrorCSVfile);
            CommonTools.emailLog('ERRORS','RM Feed Daily JOB - Sales_Champion__c','Attached are the records which have errors\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'TECH');
          }

          System.debug('Calling Instinet Coverage Job');
          Database.executeBatch(new Daily_RMFeed_Job_InstinetCoverage(hasFeedError), 5);
    }

    

}