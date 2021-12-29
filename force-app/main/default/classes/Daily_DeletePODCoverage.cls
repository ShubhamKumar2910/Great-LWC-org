/*
    Description : RM Feed Job (Batch 20)
                //a.    Batch 1: Process Daily_RMFeed_Job_Contacts (RM Contacts to NEW RG)
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
                v.      Batch 20. Process Daily_DeletePODCoverage
*/
global class Daily_DeletePODCoverage implements Database.Batchable<AggregateResult>, Database.Stateful,Database.AllowsCallouts{
    global String currentTimeStamp = '';
    global String lastUpdatedTimestamp = '';
    global Datetime lastUpdatedDateTime = null;
    global final String CONFIG_NAME = 'DeletePODCoverage';
    global final String PARAM_NAME = 'LastUpdatedTimeStamp';
    global Map<Id,List<Id>> podToRMMap = null;
    global Map<Id,List<Id>> rmToPODMap = null;
    global String exception_message = '';    
    global Boolean batchExecutionSuccessfully = true;


    global Iterable<AggregateResult> start(Database.BatchableContext bc){
        System.debug('Start');
        List<AggregateResult> coverageTeamMemberRGList = new List<AggregateResult>();

        //Fetch lastupdated timestamp from configuration
        lastUpdatedTimestamp = CommonTools.getParameterValueFromConfiguration(CONFIG_NAME,PARAM_NAME,true);
        lastUpdatedDateTime = DateTime.valueOfGmt(lastUpdatedTimestamp);

        //Current timestamp
        currentTimeStamp = datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss');
        System.debug('lastUpdatedDateTime: '+lastUpdatedDateTime);
        System.debug('currentTimeStamp: '+currentTimeStamp);
        coverageTeamMemberRGList = [SELECT RG_Account__c, Sales_Team_for_Coverage__c FROM Coverage_Team_Member__c WHERE RecordType.DeveloperName = 'Inactive_Coverage' AND Account__r.RecordType.DeveloperName = 'RM_Account'
                                    AND lastModifiedDate >: lastUpdatedDateTime GROUP BY RG_Account__c, Sales_Team_for_Coverage__c];
        return coverageTeamMemberRGList;
    }

    global void execute(Database.BatchableContext bc, List<AggregateResult> coverageTeamMemberList){
        try{
            List<Id> rgAccountIdList = new List<Id>();
            List<Id> salesPersonIdList = new List<Id>();
            List<Coverage_Team_Member__c> activeCvgTeamMemberList = new List<Coverage_Team_Member__c>();
            List<Coverage_Team_Member__c> deletedCvgTeamMemberRMList = new List<Coverage_Team_Member__c>();
            List<AggregateResult> activeCvgTeamMemberRMList = new List<AggregateResult>();
            List<Id> activeCvgRMList = new List<Id>();
            List<Id> podIdsToDeleteList = new List<Id>();
            List<Coverage_Team_Member__c> podCoverageToDelete = new List<Coverage_Team_Member__c>();
            String todayDate = datetime.now().format('MM/dd/yyyy');

            if(podToRMMap == null && rmToPODMap == null){
                podToRMMap = new Map<Id,List<Id>>();
                rmToPODMap = new Map<Id,List<Id>>();
                List<RM_POD_Link__c> rmPODLinkList = [SELECT Id, RM_Account__c, POD_Account__c FROM RM_POD_Link__c];
                for(RM_POD_Link__c rmPODRecord : rmPODLinkList){
                    String podKey = rmPODRecord.POD_Account__c;
                    String rmKey = rmPODRecord.RM_Account__c;
                    //POD to RM Mapping
                    if(podToRMMap.get(podKey) == null){
                        List<Id> rmList = new List<Id>();
                        rmList.add(rmPODRecord.RM_Account__c);
                        podToRMMap.put(podKey,rmList);
                    }
                    else{
                        List<Id> rmList = podToRMMap.get(podKey);
                        rmList.add(rmPODRecord.RM_Account__c);
                        podToRMMap.put(podKey,rmList);
                    }

                    //RM to POD Mapping
                    if(rmToPODMap.get(rmKey) == null){
                        List<Id> podList = new List<Id>();
                        podList.add(rmPODRecord.POD_Account__c);
                        rmToPODMap.put(rmKey,podList);
                    }
                    else{
                        List<Id> podList = rmToPODMap.get(rmKey);
                        podList.add(rmPODRecord.POD_Account__c);
                        rmToPODMap.put(rmKey,podList);
                    }

                }
            }

            system.debug('rmPODLink 1: '+podToRMMap);
            system.debug('podRMLink: '+rmToPODMap);

            //find other Active Coverage for the delted Account...if result is 0 then delete POD coverage

            for(AggregateResult cvgTeamMember : coverageTeamMemberList){
                rgAccountIdList.add((Id)cvgTeamMember.get('RG_Account__c'));
                salesPersonIdList.add((Id)cvgTeamMember.get('Sales_Team_for_Coverage__c'));
            }

            //find coverage at RG_Account__c level. If there are no coverage for that RG Account delete all pods, and if there are coverage then check for each RM
            if(rgAccountIdList.size() > 0 && salesPersonIdList.size() > 0){//considering only 1 RG at a time
                activeCvgTeamMemberList = [SELECT Id FROM Coverage_Team_Member__c WHERE RecordType.DeveloperName = 'Active_Coverage'
                                            AND Account__r.RecordType.DeveloperName = 'RM_Account' AND RG_Account__c IN: rgAccountIdList AND Sales_Team_for_Coverage__c IN: salesPersonIdList];

                if(activeCvgTeamMemberList.size() > 0){
                    //active coverage(s) are there so remove PODs as per RM
                    deletedCvgTeamMemberRMList = [SELECT Id, Account__c,Account__r.Name, RG_Account__c, Product_Region__c, Product__c, Team_Role__c, Sales_Team_for_Coverage__c, Sales_Team_for_Coverage__r.Name, Group_By__c
                                                    FROM Coverage_Team_Member__c WHERE RecordType.DeveloperName = 'Inactive_Coverage' AND Account__r.RecordType.DeveloperName = 'RM_Account'
                                                    AND lastModifiedDate >: lastUpdatedDateTime AND RG_Account__c IN: rgAccountIdList AND Sales_Team_for_Coverage__c IN: salesPersonIdList];

                    //to check if each RM's have active Coverage, if no then delete POD - delted this step and found active coverage for all RM under RG

                    activeCvgTeamMemberRMList = [SELECT Account__c FROM Coverage_Team_Member__c WHERE RecordType.DeveloperName = 'Active_Coverage' AND Account__r.RecordType.DeveloperName = 'RM_Account'
                                                    AND RG_Account__c IN: rgAccountIdList AND Sales_Team_for_Coverage__c IN: salesPersonIdList GROUP BY Account__c];

                    for(AggregateResult cvgTeamMember : activeCvgTeamMemberRMList){
                        activeCvgRMList.add((Id)cvgTeamMember.get('Account__c'));
                    }

                    for(Coverage_Team_Member__c deletedCvg : deletedCvgTeamMemberRMList){
                        //if there are no active coverage for deleted RM account then delete POD
                        if(!activeCvgRMList.contains(deletedCvg.Account__c)){
                            //finding POD Account and deleting POD Coverage
                            String rmAccountId = deletedCvg.Account__c;
                            System.debug('------------------------------');
                            System.debug('rmAccountId: '+rmAccountId);
                            List<Id> podAccountIdList = rmToPODMap.get(rmAccountId);
                            System.debug('podAccountIdList: '+podAccountIdList);
                            if(podAccountIdList != null ){
                                for(Id podAccountId : podAccountIdList){
                                    System.debug('podAccountId: '+podAccountId);
                                    List<Id> rmAccountIdList = podToRMMap.get(podAccountId);
                                    System.debug('rmAccountIdList: '+rmAccountIdList);
                                    if(rmAccountIdList.size() == 1 && rmAccountIdList.contains(rmAccountId)){
                                        System.debug('Inside 1 RM');
                                        podIdsToDeleteList.add(podAccountId);
                                    }else{
                                        System.debug('Inside 2 RM');
                                        Boolean foundActiveCvg = false;
                                        for(Id rmAccId : rmAccountIdList){
                                            if(activeCvgRMList.contains(rmAccId)){
                                                foundActiveCvg = true;
                                                break;
                                            }
                                        }
                                        if(!foundActiveCvg){
                                            System.debug('Inside');
                                            podIdsToDeleteList.add(podAccountId);
                                        }
                                    }
                                }
                            }
                        }
                    }

                    if(podIdsToDeleteList.size() > 0){
                        system.debug('POD DELETE List size: '+podIdsToDeleteList.size());
                        system.debug('POD DELETE List size: '+podIdsToDeleteList);
                        podCoverageToDelete = [SELECT Id,Account__c,Account__r.RDM_Org_ID__c,Product2__c, Product_Group__c, Product_Region__c, Team_Role__c,Sales_Team_for_Coverage__c,
                                                Sales_Team_for_Coverage__r.Coverage_Id__c, Sales_Team_for_Coverage__r.Sales_Desk_Division__c, Sales_Team_for_Coverage__r.Sales_Desk_Region__c, Sales_Team_for_Coverage__r.Is_Dummy__c
                                                FROM Coverage_Team_Member__c WHERE RecordType.DeveloperName = 'Active_Coverage' AND Account__c IN : podIdsToDeleteList]; //here salesperson will come
                    }
                }else{
                    //rgAccountIdList.size() == 0 => no active coverage found for said RG_Account__c => so delete all PODs
                    //find all pod ids
                    System.debug('No active RM Coverage found. Deleting all PODs');
                    podCoverageToDelete = [SELECT Id,Account__c,Account__r.RDM_Org_ID__c,Product2__c, Product_Group__c, Product_Region__c, Team_Role__c,Sales_Team_for_Coverage__c,
                                                Sales_Team_for_Coverage__r.Coverage_Id__c, Sales_Team_for_Coverage__r.Sales_Desk_Division__c, Sales_Team_for_Coverage__r.Sales_Desk_Region__c, Sales_Team_for_Coverage__r.Is_Dummy__c
                                                FROM Coverage_Team_Member__c WHERE RecordType.DeveloperName = 'Active_Coverage' AND Account__r.RecordType.DeveloperName = 'POD_Account' AND RG_Account__c IN: rgAccountIdList AND Sales_Team_for_Coverage__c IN: salesPersonIdList];
                }

                Set<string> productSetDelete = new Set<string>();
                Set<string> productRegionSetDelete = new Set<string>();
                Set<string> productGroupSetDelete = new Set<string>();
                List<Coverage_Access_Request__c> reqsDeleteWithProduct = new List<Coverage_Access_Request__c>();
                List<Coverage_Access_Request__c> reqsDeleteWithNoProduct = new List<Coverage_Access_Request__c>();
                Set<Id> salesTeamForCoverageDeleteWithProduct = new Set<Id>();
                Set<Id> salesTeamForCoverageDeleteWithNoProduct = new Set<Id>();
                Map<String,String> mapofRMDelete = new Map<String,String>();

                if(podCoverageToDelete.size() > 0){
                    system.debug('pods to delete: '+podCoverageToDelete.size());
                    for(Coverage_Team_Member__c record : podCoverageToDelete){
                        system.debug('inside for pods to delete: ');
                        Coverage_Access_Request__c coverageRequest = new Coverage_Access_Request__c();
                        coverageRequest.Approved__c = true;
                        coverageRequest.Group_By__c = 'POD';
                        coverageRequest.End_Date__c = Date.parse(todayDate);
                        reqsDeleteWithProduct.add(coverageRequest);
                        reqsDeleteWithNoProduct.add(coverageRequest);
                        salesTeamForCoverageDeleteWithProduct.add(record.Sales_Team_for_Coverage__c);
                        salesTeamForCoverageDeleteWithNoProduct.add(record.Sales_Team_for_Coverage__c);
                        mapofRMDelete.put(record.Account__c , record.Account__c);
                        if(String.isNotBlank(record.Product2__c)){
                            productSetDelete.add(record.Product2__c);
                            productRegionSetDelete.add(record.Product_Region__c);
                            productGroupSetDelete.add(record.Product_Group__c);
                        }
                        System.debug('Deleting POD Coverage');
                        CvgDeleteBL.RMDeleteCoverage(reqsDeleteWithProduct, reqsDeleteWithNoProduct, mapofRMDelete, salesTeamForCoverageDeleteWithProduct, salesTeamForCoverageDeleteWithNoProduct, productSetDelete, productRegionSetDelete, productGroupSetDelete);
                    }
                }
            }


        }catch(Exception e){
            exception_message += e+'\n'+e.getStackTraceString();
            exception_message += '\n';
            batchExecutionSuccessfully = false;
            system.debug('exception in deleteing pod: '+exception_message);
        }
    }

    global void finish(Database.BatchableContext bc){
        //if the deleteing JOB fails do not update timestamp..how?
        if(!batchExecutionSuccessfully){
            system.debug('Exception processing Delete POD Coverage Delete.....');
            system.debug(exception_message);
            CommonTools.emailLog('FAILURE','RM Feed Daily JOB - Daily_DeletePODCoverage',exception_message+'\n\nRegards,\nSalesforce Tech',null,'TECH');            
        }else{
            system.debug('updating delete pod time stamp');
            CommonTools.updateParameterValueInConfiguration(CONFIG_NAME,PARAM_NAME,currentTimeStamp);
        }
        System.debug('Finish RM Feed Job');
    }
}