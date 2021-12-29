/*
    Description : RM Feed Job (Batch 7.1 / Batch 13.1)
				//a.	Batch 1: Process Daily_RMFeed_Job_Contacts (RM Contacts to NEW RG)
				//b.	Batch 2: Process Daily_RMFeed_Job_Events (Events to NEW RG)
				//c.	Batch 3: Process Daily_RMFeed_Job_Tasks (Tasks to NEW RG)
				//d.	Batch 4: Process Daily_RMFeed_Job_Opportunity (Opportunity)
				//e.	Batch 5: Process Daily_RMFeed_Job_InstinetChampion
				//f.	Batch 6: Process Daily_RMFeed_Job_InstinetCoverage
				g.      Batch 7.1: Process Daily_QueryCvgTeamMemberRequestType (Query Coverage records to update label as RG/RM)
                //h.    Batch 7.2: Process Daily_UpdateCvgTeamMemberRequestType (Update Coverage records label as RG/RM))
				//i.	Batch 8: Process Daily_RMFeed_Job_Coverage_Movement (Coverage Movement @ RG Salesperson)
				//j.	Batch 9: Process Daily_RMFeed_Job_Coverage_Movement_RM (Coverage Movement @ RM Salesperson)
				//k.	Batch 10: Process Daily_RMFeed_Coverage_Movement_End
				//l.	Batch 11: Process Daily_RMFeed_Coverage_Movement_Insert
                //m.    Batch 12. Process Daily_RMFeed_Job_Clear (Reset RM Movement flag)
				n.      Batch 13.1: Process Daily_QueryCvgTeamMemberRequestType (Chaining Batch 7.1 Job)
                //o.    Batch 13.2: Process Daily_UpdateCvgTeamMemberRequestType (Chaining Batch 7.2 Job)
				//p.	Batch 14: Process Daily_RMFeed_Job_Coverage_NewRM
				//q.	Batch 15: Process Daily_RMFeed_Coverage_NewRM_Insert
				//r.    Batch 16. Process Daily_RMFeed_Job_Clear (Reset new RM flag - Chaning Batch 12)
                //s.    Batch 17. Process Daily_RMPODLinkStartBatch
                //t.    Batch 18. Process Daily_RMPodLinkProcessBatch
                //u.    Batch 19. Process Daily_RMPodLinkEndBatch
                //v.    Batch 20. Process Daily_DeletePODCoverage
*/
global class Daily_QueryCvgTeamMemberRequestType implements Database.Batchable<AggregateResult>, Database.Stateful,Database.AllowsCallouts{

    global String currentTimeStamp = '';
    global String lastUpdatedTimestamp = '';
    global Datetime lastUpdatedDateTime = null;
    global final String CONFIG_NAME = 'UpdateCvgTeamMemberRequestType';
    global final String PARAM_NAME = 'LastUpdatedTimeStamp';
    global Boolean isPrevJobRMMovement = false;
    global Set<Id> new_rmIds = new Set<Id>();
    global Set<Id> new_rgIds = new Set<Id>();
    global Boolean hasRMFeedError = false;
    global Boolean hasCoverageInsertError = false;
    global String exception_message = '';
    global Boolean batchExecutionSuccessfully = true;
    global List<Coverage_Team_Member__c> recordsToUpdate = new List<Coverage_Team_Member__c>();

    public Daily_QueryCvgTeamMemberRequestType(Boolean hasRMFeedError){
        //called from Daily_RMFeed_Job_InstinetCoverages
	    this.hasRMFeedError = hasRMFeedError;
        isPrevJobRMMovement = false;
    }

    public Daily_QueryCvgTeamMemberRequestType(Set<Id> new_rmIds,Set<Id> new_rgIds,Boolean hasRMFeedError,Boolean hasCoverageInsertError){
        //called from Daily_RMFeed_Job_Clear
        this.hasRMFeedError = hasRMFeedError;
        this.new_rmIds = new_rmIds;
        this.new_rgIds = new_rgIds;
        this.hasCoverageInsertError = hasCoverageInsertError;
        isPrevJobRMMovement = true;
    }

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
        if(Test.isRunningTest()){
            coverageTeamMemberRGList = [SELECT RG_Account__c FROM Coverage_Team_Member__c WHERE Account__r.Restricted_Flag__c = FALSE AND Sales_Team_for_Coverage__r.Active__c = TRUE AND lastModifiedDate >: lastUpdatedDateTime GROUP BY RG_Account__c LIMIT 1];
        }else{
            coverageTeamMemberRGList = [SELECT RG_Account__c FROM Coverage_Team_Member__c WHERE Account__r.Restricted_Flag__c = FALSE AND Sales_Team_for_Coverage__r.Active__c = TRUE AND lastModifiedDate >: lastUpdatedDateTime GROUP BY RG_Account__c]; // and RecordType.DeveloperName = 'Active_Coverage' ..not checking for this as we need deleted modified also to tag other RM under Rg as 'RM'
        }

        return coverageTeamMemberRGList;
    }

    global void execute(Database.BatchableContext bc, List<AggregateResult> coverageTeamMemberRGList){
        try{    
            System.debug('coverageTeamMemberRGList size: '+coverageTeamMemberRGList.size());
            System.debug('coverageTeamMemberRGList : '+coverageTeamMemberRGList);

            List<Id> rgAccountIdList = new List<Id>();
            List<Coverage_Team_Member__c> coverageTeamMemberRMList = new List<Coverage_Team_Member__c>();
            Map<String,List<Coverage_Team_Member__c>> cvgTeamMemberMap = new Map<String,List<Coverage_Team_Member__c>>();
            List<AggregateResult> accountList = new List<AggregateResult>();

            for(AggregateResult cvgTeamMember : coverageTeamMemberRGList){
                rgAccountIdList.add((Id)cvgTeamMember.get('RG_Account__c'));
            }
            System.debug('rgAccountIdList: '+rgAccountIdList);

            if(rgAccountIdList != null){
                coverageTeamMemberRMList = [SELECT Id, Account__c,Account__r.Name, RG_Account__c, Product_Region__c, Product__c, Team_Role__c, Sales_Team_for_Coverage__c, Sales_Team_for_Coverage__r.Name, Group_By__c FROM Coverage_Team_Member__c
                                            WHERE Account__r.Restricted_Flag__c = FALSE and Account__r.RecordType.DeveloperName = 'RM_Account' AND RecordType.DeveloperName = 'Active_Coverage' AND RG_Account__c IN : rgAccountIdList]; //AND lastModifiedDate >: lastUpdatedDateTime ..INCLUDE SALESPERSON ALSO?
            }
            System.debug('coverageTeamMemberRMList size: '+coverageTeamMemberRMList.size());
            
            accountList = [SELECT Count(Id) RMCOUNT, ParentId FROM Account WHERE Active__c = TRUE AND RecordType.DeveloperName = 'RM_Account' AND restricted_flag__c = FALSE AND isNewRM__c = FALSE AND isRMChanged__c = FALSE AND ParentId IN : rgAccountIdList GROUP BY ParentId]; // AND ParentId != null  ...required ?..giving error Below on argument | as for each trascation limit is resetso we can query one RG each
            System.debug('accountList size: '+accountList.size());

            for(Coverage_Team_Member__c cvgTeamMember : coverageTeamMemberRMList){
                String key = '';
                key = cvgTeamMember.RG_Account__c+'#'+cvgTeamMember.Product_Region__c+'#'+cvgTeamMember.Product__c+'#'+cvgTeamMember.Team_Role__c+'#'+cvgTeamMember.Sales_Team_for_Coverage__c;
                if(cvgTeamMemberMap.get(key) == null){
                    List<Coverage_Team_Member__c> cvgList = new List<Coverage_Team_Member__c>();
                    cvgList.add(cvgTeamMember);
                    cvgTeamMemberMap.put(key,cvgList);
                }
                else{
                    List<Coverage_Team_Member__c> cvgList = cvgTeamMemberMap.get(key);
                    cvgList.add(cvgTeamMember);
                    cvgTeamMemberMap.put(key,cvgList);
                }
            }
            
            for(AggregateResult acc: accountList){
                System.debug('Account: '+acc);
                for(String str : cvgTeamMemberMap.keySet()){
                    if(str.contains((Id)acc.get('ParentId')) && ((Integer)acc.get('RMCOUNT') <= cvgTeamMemberMap.get(str).size())){
                        System.debug('RG Match FOUND '+str);
                        //Update record here
                        List<Coverage_Team_Member__c>  cvgTeamMemberList = cvgTeamMemberMap.get(str);
                        for(Coverage_Team_Member__c cvg : cvgTeamMemberList){
                            if(cvg.Group_By__c != 'RG'){ //check here if not already RG then update RG
                                cvg.Group_By__c = 'RG';
                                recordsToUpdate.add(cvg);
                            }
                        }
                    }else if (str.contains((Id)acc.get('ParentId')) && ((Integer)acc.get('RMCOUNT') > cvgTeamMemberMap.get(str).size())){
                        System.debug('RM Match FOUND '+str);
                        List<Coverage_Team_Member__c>  cvgTeamMemberList = cvgTeamMemberMap.get(str);
                        for(Coverage_Team_Member__c cvg : cvgTeamMemberList){
                            if(cvg.Group_By__c != 'RM'){ //check here if not already RM then update RM
                                cvg.Group_By__c = 'RM';
                                recordsToUpdate.add(cvg);
                            }
                        }
                    }
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
		if(!batchExecutionSuccessfully)
        {
            system.debug('Exception processing Coverage Team Member Request Type Query.....');
            system.debug(exception_message);
            CommonTools.emailLog('FAILURE','RM Feed Daily JOB - Daily_QueryCvgTeamMemberRequestType',exception_message+'\n\nRegards,\nSalesforce Tech',null,'TECH');
        }

        if(!isPrevJobRMMovement){
            if(batchExecutionSuccessfully){
                System.debug('Calling Update Coverage Team Member Request Type Job');
                Database.executeBatch(new Daily_UpdateCvgTeamMemberRequestType(hasRMFeedError,recordsToUpdate,currentTimeStamp), 200);
            }else{
                System.debug('Failure in Daily_QueryCvgTeamMemberRequestType. Not calling other chained jobs');
            }
        }else{
            System.debug('Calling Update Coverage Team Member Request Type Job');
            Database.executeBatch(new Daily_UpdateCvgTeamMemberRequestType(new_rmIds,new_rgIds,hasRMFeedError,hasCoverageInsertError,recordsToUpdate,currentTimeStamp), 200);
        }
    }
}