global class PopulateServiceCountBatch implements Database.batchable<Map<String,Object>>, Database.Stateful{
    
    global List<String> errorMessageList = new List<String>();
    
    global PopulateServiceCountBatch() {
    }
    
    global Iterable<Map<String,Object>> start (Database.BatchableContext info) {
        return new ServiceCountIterator();
    }
    
    global void execute (Database.BatchableContext info, List<Map<String,Object>> modelAndPeriodContainerList) {
            Map<String,Object> modelAndPeriodContainer = modelAndPeriodContainerList.get(0);
            Account_Service_Model__c modelData = (Account_Service_Model__c)modelAndPeriodContainer.get('MODEL');
            ServiceROIUtility.MonthlyPeriod periodData = (ServiceROIUtility.MonthlyPeriod)modelAndPeriodContainer.get('PERIOD');
            System.debug(modelData.name +', '+modelData.Item_Name__c  +', '+periodData.startDate+', ' + periodData.endDate + ', inProgressVersion = ' + modelData.inprogress_version__c);
            List<Account_Service_Rank__c> serviceRankListForAccountEvents = getServiceRanks('Account', modelData, periodData);
	    updateServiceRankList(serviceRankListForAccountEvents);
            List<Account_Service_Rank__c> serviceRankListForCampaignEvents = getServiceRanks('Campaign', modelData, periodData);
            updateServiceRankList(serviceRankListForCampaignEvents);
    }
    
    private List<Account_Service_Rank__c> getServiceRanks (String whatType, Account_Service_Model__c modelData, 
                                                                    ServiceROIUtility.MonthlyPeriod periodData) {
        String soqlString = formSoqlString(modelData, periodData);
        AggregateResult[] results = getAggregratedResults(whatType, soqlString, modelData, periodData);
        List<Account_Service_Rank__c> serviceRankList = createServiceRankObject(whatType, results, modelData, periodData);
        System.debug('Size of service ranks for ' + whatType+ ' after aggregration is ' + serviceRankList.size());
        if (whatType.equals('Campaign') && serviceRankList != null && serviceRankList.size() > 0) {
            serviceRankList = accountForCampaignMembers(serviceRankList, modelData.id, String.valueOf(modelData.inProgress_Version__c));
            System.debug('Size of service ranks for ' + whatType+ ' after accounting for campaign member is ' + serviceRankList.size());
        }
        return serviceRankList;
    }
    
    private List<Account_Service_Rank__c> accountForCampaignMembers(List<Account_Service_Rank__c> serviceRanksBeforeList,
                                                                    Id modelId, string inprogressVersion) {
        system.debug('Inside accountForCampaignMembers size before = ' + serviceRanksBeforeList.size());
	Map<String,Account_Service_Rank__c> serviceRankMap = new Map<String,Account_Service_Rank__c> ();
        Map<Id, Set<Id>> campaignAccountMap = getCampaignAccountMap(serviceRanksBeforeList);
        for (Account_Service_Rank__c serviceRanksBefore: serviceRanksBeforeList) {
            Set<Id> accountIds = campaignAccountMap.get(serviceRanksBefore.external_id__c);
            if (accountIds != null && accountIds.size() > 0) {
                for (Id accountId : accountIds) {
		    String externalId = accountId +'_'+ modelId +'_'+ inprogressVersion; 
		    Account_Service_Rank__c serviceRanksAfter = serviceRankMap.get(externalId);
		    if (serviceRanksAfter == null) {
			serviceRanksAfter = serviceRanksBefore.clone(false, false, false, false);
			serviceRanksAfter.Account__c = accountId;
			serviceRanksAfter.external_id__c= accountId +'_'+ modelId +'_'+ inprogressVersion; 		    
			serviceRankMap.put(externalId, serviceRanksAfter);
		    }
		    else {
			System.debug('Merge');
			mergeRanks(serviceRanksAfter,serviceRanksBefore);
		    }
                }
            }
            else {
                System.debug('No account found from campaignMember for campaign ' + serviceRanksBefore.Account__c +
                                                                        '. Hence removing ' + serviceRanksBefore.external_id__c);
            }
        }
	system.debug('Inside accountForCampaignMembers size after = ' + serviceRankMap.values().size());
        return serviceRankMap.values() ;
    }
    
    private Map<Id, Set<Id>>  getCampaignAccountMap (List<Account_Service_Rank__c> serviceRanksBeforeList) {
        Map<Id, Set<Id>>  campaignAccountMap = new Map<Id, Set<Id>>();
        List<Id> campaignIds = getCampaignIds(serviceRanksBeforeList);
        List<CampaignMember> campaignMembers = getCampaignMembers(campaignIds);
        if (campaignMembers != null && campaignMembers.size() > 0) {
            for (CampaignMember member: campaignMembers) {
                if (member.contact != null && member.contact.account != null && member.contact.account.parentid != null) {
                    Id campaignId = member.campaignId;
                    id accountId = member.contact.account.parentid;
                    updateMap(campaignId, accountId, campaignAccountMap);
                }
                else {
                    System.debug('accountId is null for campaign' + member.campaignId);
                }
            }
        }
        return campaignAccountMap;
    }
    
    private void updateMap(Id campaignId, Id accountId, Map<Id, Set<Id>> campaignAccountMap) {
        Set<Id> accountIds = campaignAccountMap.get(campaignId);
        if (accountIds == null) {
            accountIds = new Set<Id>();
            campaignAccountMap.put(campaignId, accountIds);
        }
        accountIds.add(accountId);  
    }
    
    private List<CampaignMember> getCampaignMembers (List<Id> campaignIds) {
        return Database.query('select campaignId, contact.account.parentid from campaignMember where contactid != null and campaignId in : campaignIDs');
    }
    
    private List<Id> getCampaignIds (List<Account_Service_Rank__c> serviceRanksBeforeList) {
        List<Id> campaignIds = new List<Id>();
        for (Account_Service_Rank__c serviceRank :serviceRanksBeforeList ) {
            campaignIds.add(serviceRank.external_id__c);
        }
        return campaignIds;
    }
    
    global void finish (Database.BatchableContext bc) {
        AsyncApexJob apexJob = [SELECT Id, JobType, Status, JobItemsProcessed, TotalJobItems, 
                               NumberOfErrors, CompletedDate, MethodName, ExtendedStatus
                               FROM AsyncApexJob 
                               WHERE JobType = 'BatchApex' AND Id = :bc.getJobId()
                               ];
        if(apexJob != null && apexJob.NumberOfErrors > 0 ) {
            errorMessageList.add(apexJob.ExtendedStatus);
        }

        if( errorMessageList.size() > 0){
            String emailBody = getEmailBody(apexJob);
            EventServiceStatsUtility.emailErrorLog('FAILURE','PopulateServiceCountBatch',emailBody+'\n\nRegards,\nSalesforce Tech');
        }
        else {
            if(!Test.isRunningTest()){
                System.debug('isRunningTest = false. Invoking next batch');
                Database.executeBatch(new PopulateServiceRankBatch(), 1);
            } else {
                System.debug('isRunningTest = true. Not Invoking any batches');
            }
        }   
    }
    
    private String getEmailBody(AsyncApexJob apexJob){
        String emailBody = null;
        String apexJobId = apexJob.Id;
        emailBody = '<p> The Batch Apex Job (' + apexJobId.substring(0,15) + ') processed '
                    + apexJob.TotalJobItems + ' batche(s) with ' + apexJob.NumberOfErrors + ' failure(s). </p>';
        emailBody = emailBody + '<p> Failed for below records : </p><br>';
        
        for (String errorMessage: errorMessageList) {
             emailBody = emailBody + '<br>' + errorMessage;
        }
        return emailBody;
    }   
    
    private void updateServiceRankList (List<Account_Service_Rank__c> serviceRankList) {

        if (serviceRankList != null && serviceRankList.size() > 0) {
                Schema.SObjectField externalIdField = Account_Service_Rank__c.Fields.external_id__c;
                System.debug('Before update');
                Database.UpsertResult[] results = Database.upsert(serviceRankList, externalIdField , true);
                doLogging(results,  serviceRankList[0].model__r.external_id__c);
        }
    }
    
  /*  public List<Account_Service_Rank__c> mergeDuplicates(List<Account_Service_Rank__c> serviceRankList) {
        System.debug('List size before mergeDuplicates= ' + serviceRankList.size());
        Map<String, List<Account_Service_Rank__c>> duplicateMap = createMapOfDuplicatesBasedOnExternalId(serviceRankList);
        mergeDuplicatesOnFirstElement(duplicateMap);
        serviceRankList = getFirstElementFromEntrySetOfMap(duplicateMap);
        System.debug('List size after mergeDuplicates= ' + serviceRankList.size());
        return serviceRankList;
    }
    
    public List<Account_Service_Rank__c> getFirstElementFromEntrySetOfMap(Map<String,List<Account_Service_Rank__c>> duplicateMap) {
        List<Account_Service_Rank__c> serviceRankList = new List<Account_Service_Rank__c>();
        for (String externalId : duplicateMap.keySet()) {
            List<Account_Service_Rank__c> duplicateList = duplicateMap.get(externalId);
            serviceRankList.add(duplicateList[0]);
        }       
        return serviceRankList;
    }
    
    public void mergeDuplicatesOnFirstElement (Map<String,List<Account_Service_Rank__c>> duplicateMap) {
        for (String externalId : duplicateMap.keySet()) {
            List<Account_Service_Rank__c> duplicateList = duplicateMap.get(externalId);
            system.debug('Duplicate list size of ' + externalId + ' is '+ duplicateList.size() );
            if (duplicateList.size() > 1) {
                Account_Service_Rank__c firstRank = duplicateList[0];
                for (integer index = 1; index <duplicateList.size();  index ++) {
                    System.debug('Merging ' + index + ' with 0 for ' + externalId );
                    mergeRanks(firstRank, duplicateList[index]);
                }
            }
        }
    } */
    
  public void mergeRanks(Account_Service_Rank__c firstRank, Account_Service_Rank__c dulicateRank) {
        //Add count and point fields.
        //Take care of null
 
	if ( dulicateRank.CURRENT_CY_ASIAEX_COUNT__C!= null && dulicateRank.CURRENT_CY_ASIAEX_COUNT__C > 0) {
		if ( firstRank.CURRENT_CY_ASIAEX_COUNT__C!= null && firstRank.CURRENT_CY_ASIAEX_COUNT__C > 0)	
			firstRank.CURRENT_CY_ASIAEX_COUNT__C = firstRank.CURRENT_CY_ASIAEX_COUNT__C + dulicateRank.CURRENT_CY_ASIAEX_COUNT__C;
		else	
			firstRank.CURRENT_CY_ASIAEX_COUNT__C = dulicateRank.CURRENT_CY_ASIAEX_COUNT__C;
	}
	if ( dulicateRank.CURRENT_CY_EUROPE_COUNT__C!= null && dulicateRank.CURRENT_CY_EUROPE_COUNT__C > 0) {	
	if ( firstRank.CURRENT_CY_EUROPE_COUNT__C!= null && firstRank.CURRENT_CY_EUROPE_COUNT__C > 0)	
	firstRank.CURRENT_CY_EUROPE_COUNT__C = firstRank.CURRENT_CY_EUROPE_COUNT__C + dulicateRank.CURRENT_CY_EUROPE_COUNT__C;
	  else	
	  firstRank.CURRENT_CY_EUROPE_COUNT__C = dulicateRank.CURRENT_CY_EUROPE_COUNT__C; }
	  
	if ( dulicateRank.CURRENT_CY_GLOBAL_COUNT__C!= null && dulicateRank.CURRENT_CY_GLOBAL_COUNT__C > 0) {
	if ( firstRank.CURRENT_CY_GLOBAL_COUNT__C!= null && firstRank.CURRENT_CY_GLOBAL_COUNT__C > 0)	
	firstRank.CURRENT_CY_GLOBAL_COUNT__C = firstRank.CURRENT_CY_GLOBAL_COUNT__C + dulicateRank.CURRENT_CY_GLOBAL_COUNT__C;
	  else	
	  firstRank.CURRENT_CY_GLOBAL_COUNT__C = dulicateRank.CURRENT_CY_GLOBAL_COUNT__C; }
	  
	if ( dulicateRank.CURRENT_CY_JAPAN_COUNT__C!= null && dulicateRank.CURRENT_CY_JAPAN_COUNT__C > 0) {
	if ( firstRank.CURRENT_CY_JAPAN_COUNT__C!= null && firstRank.CURRENT_CY_JAPAN_COUNT__C > 0)
	firstRank.CURRENT_CY_JAPAN_COUNT__C = firstRank.CURRENT_CY_JAPAN_COUNT__C + dulicateRank.CURRENT_CY_JAPAN_COUNT__C;
	  else	
	  firstRank.CURRENT_CY_JAPAN_COUNT__C = dulicateRank.CURRENT_CY_JAPAN_COUNT__C; }
	  
	if ( dulicateRank.CURRENT_CY_US_COUNT__C!= null && dulicateRank.CURRENT_CY_US_COUNT__C > 0) {
	if ( firstRank.CURRENT_CY_US_COUNT__C!= null && firstRank.CURRENT_CY_US_COUNT__C > 0)	
	firstRank.CURRENT_CY_US_COUNT__C = firstRank.CURRENT_CY_US_COUNT__C + dulicateRank.CURRENT_CY_US_COUNT__C;
	  else	
	  firstRank.CURRENT_CY_US_COUNT__C = dulicateRank.CURRENT_CY_US_COUNT__C; }
	  
	if ( dulicateRank.CURRENT_FY_ASIAEX_COUNT__C!= null && dulicateRank.CURRENT_FY_ASIAEX_COUNT__C > 0) {
	if ( firstRank.CURRENT_FY_ASIAEX_COUNT__C!= null && firstRank.CURRENT_FY_ASIAEX_COUNT__C > 0)
	firstRank.CURRENT_FY_ASIAEX_COUNT__C = firstRank.CURRENT_FY_ASIAEX_COUNT__C + dulicateRank.CURRENT_FY_ASIAEX_COUNT__C;
	  else
	  firstRank.CURRENT_FY_ASIAEX_COUNT__C = dulicateRank.CURRENT_FY_ASIAEX_COUNT__C; }
	  
	if ( dulicateRank.CURRENT_FY_EUROPE_COUNT__C!= null && dulicateRank.CURRENT_FY_EUROPE_COUNT__C > 0) {
	if ( firstRank.CURRENT_FY_EUROPE_COUNT__C!= null && firstRank.CURRENT_FY_EUROPE_COUNT__C > 0)	
	firstRank.CURRENT_FY_EUROPE_COUNT__C = firstRank.CURRENT_FY_EUROPE_COUNT__C + dulicateRank.CURRENT_FY_EUROPE_COUNT__C;
	  else
	  firstRank.CURRENT_FY_EUROPE_COUNT__C = dulicateRank.CURRENT_FY_EUROPE_COUNT__C; }
	  
	  
	if ( dulicateRank.CURRENT_FY_GLOBAL_COUNT__C!= null && dulicateRank.CURRENT_FY_GLOBAL_COUNT__C > 0) {	
	if ( firstRank.CURRENT_FY_GLOBAL_COUNT__C!= null && firstRank.CURRENT_FY_GLOBAL_COUNT__C > 0)	
	firstRank.CURRENT_FY_GLOBAL_COUNT__C = firstRank.CURRENT_FY_GLOBAL_COUNT__C + dulicateRank.CURRENT_FY_GLOBAL_COUNT__C;
	  else
	  firstRank.CURRENT_FY_GLOBAL_COUNT__C = dulicateRank.CURRENT_FY_GLOBAL_COUNT__C; }
	  
	if ( dulicateRank.CURRENT_FY_JAPAN_COUNT__C!= null && dulicateRank.CURRENT_FY_JAPAN_COUNT__C > 0) {
	if ( firstRank.CURRENT_FY_JAPAN_COUNT__C!= null && firstRank.CURRENT_FY_JAPAN_COUNT__C > 0)	
	firstRank.CURRENT_FY_JAPAN_COUNT__C = firstRank.CURRENT_FY_JAPAN_COUNT__C + dulicateRank.CURRENT_FY_JAPAN_COUNT__C;
	  else	
	  firstRank.CURRENT_FY_JAPAN_COUNT__C = dulicateRank.CURRENT_FY_JAPAN_COUNT__C; }
	  
	if ( dulicateRank.CURRENT_FY_US_COUNT__C!= null && dulicateRank.CURRENT_FY_US_COUNT__C > 0) {
	if ( firstRank.CURRENT_FY_US_COUNT__C!= null && firstRank.CURRENT_FY_US_COUNT__C > 0)	
	firstRank.CURRENT_FY_US_COUNT__C = firstRank.CURRENT_FY_US_COUNT__C + dulicateRank.CURRENT_FY_US_COUNT__C;
	  else
	  firstRank.CURRENT_FY_US_COUNT__C = dulicateRank.CURRENT_FY_US_COUNT__C; }
	  
	if ( dulicateRank.PREVIOUS_CY_ASIAEX_COUNT__C!= null && dulicateRank.PREVIOUS_CY_ASIAEX_COUNT__C > 0) {	
	if ( firstRank.PREVIOUS_CY_ASIAEX_COUNT__C!= null && firstRank.PREVIOUS_CY_ASIAEX_COUNT__C > 0)	
	firstRank.PREVIOUS_CY_ASIAEX_COUNT__C = firstRank.PREVIOUS_CY_ASIAEX_COUNT__C + dulicateRank.PREVIOUS_CY_ASIAEX_COUNT__C;
	  else	
	  firstRank.PREVIOUS_CY_ASIAEX_COUNT__C = dulicateRank.PREVIOUS_CY_ASIAEX_COUNT__C; }
	  
	if ( dulicateRank.PREVIOUS_CY_EUROPE_COUNT__C!= null && dulicateRank.PREVIOUS_CY_EUROPE_COUNT__C > 0) {	
	if ( firstRank.PREVIOUS_CY_EUROPE_COUNT__C!= null && firstRank.PREVIOUS_CY_EUROPE_COUNT__C > 0)
	firstRank.PREVIOUS_CY_EUROPE_COUNT__C = firstRank.PREVIOUS_CY_EUROPE_COUNT__C + dulicateRank.PREVIOUS_CY_EUROPE_COUNT__C;
	  else
	  firstRank.PREVIOUS_CY_EUROPE_COUNT__C = dulicateRank.PREVIOUS_CY_EUROPE_COUNT__C; }
	  
	if ( dulicateRank.PREVIOUS_CY_GLOBAL_COUNT__C!= null && dulicateRank.PREVIOUS_CY_GLOBAL_COUNT__C > 0) {
	if ( firstRank.PREVIOUS_CY_GLOBAL_COUNT__C!= null && firstRank.PREVIOUS_CY_GLOBAL_COUNT__C > 0)	
	firstRank.PREVIOUS_CY_GLOBAL_COUNT__C = firstRank.PREVIOUS_CY_GLOBAL_COUNT__C + dulicateRank.PREVIOUS_CY_GLOBAL_COUNT__C;
	  else	
	  firstRank.PREVIOUS_CY_GLOBAL_COUNT__C = dulicateRank.PREVIOUS_CY_GLOBAL_COUNT__C; }
	  
	if ( dulicateRank.PREVIOUS_CY_JAPAN_COUNT__C!= null && dulicateRank.PREVIOUS_CY_JAPAN_COUNT__C > 0) {	
	if ( firstRank.PREVIOUS_CY_JAPAN_COUNT__C!= null && firstRank.PREVIOUS_CY_JAPAN_COUNT__C > 0)
	firstRank.PREVIOUS_CY_JAPAN_COUNT__C = firstRank.PREVIOUS_CY_JAPAN_COUNT__C + dulicateRank.PREVIOUS_CY_JAPAN_COUNT__C;
	  else	
	  firstRank.PREVIOUS_CY_JAPAN_COUNT__C = dulicateRank.PREVIOUS_CY_JAPAN_COUNT__C; }
	  
	if ( dulicateRank.PREVIOUS_CY_US_COUNT__C!= null && dulicateRank.PREVIOUS_CY_US_COUNT__C > 0) {	
	if ( firstRank.PREVIOUS_CY_US_COUNT__C!= null && firstRank.PREVIOUS_CY_US_COUNT__C > 0)
	firstRank.PREVIOUS_CY_US_COUNT__C = firstRank.PREVIOUS_CY_US_COUNT__C + dulicateRank.PREVIOUS_CY_US_COUNT__C;
	  else
	  firstRank.PREVIOUS_CY_US_COUNT__C = dulicateRank.PREVIOUS_CY_US_COUNT__C; }
	  
	if ( dulicateRank.PREVIOUS_FY_ASIAEX_COUNT__C!= null && dulicateRank.PREVIOUS_FY_ASIAEX_COUNT__C > 0) {	
	if ( firstRank.PREVIOUS_FY_ASIAEX_COUNT__C!= null && firstRank.PREVIOUS_FY_ASIAEX_COUNT__C > 0)
	firstRank.PREVIOUS_FY_ASIAEX_COUNT__C = firstRank.PREVIOUS_FY_ASIAEX_COUNT__C + dulicateRank.PREVIOUS_FY_ASIAEX_COUNT__C;
	  else
	  firstRank.PREVIOUS_FY_ASIAEX_COUNT__C = dulicateRank.PREVIOUS_FY_ASIAEX_COUNT__C; }
	  
	if ( dulicateRank.PREVIOUS_FY_EUROPE_COUNT__C!= null && dulicateRank.PREVIOUS_FY_EUROPE_COUNT__C > 0) {	
	if ( firstRank.PREVIOUS_FY_EUROPE_COUNT__C!= null && firstRank.PREVIOUS_FY_EUROPE_COUNT__C > 0)	
	firstRank.PREVIOUS_FY_EUROPE_COUNT__C = firstRank.PREVIOUS_FY_EUROPE_COUNT__C + dulicateRank.PREVIOUS_FY_EUROPE_COUNT__C;
	  else
	  firstRank.PREVIOUS_FY_EUROPE_COUNT__C = dulicateRank.PREVIOUS_FY_EUROPE_COUNT__C; }
	  
	if ( dulicateRank.PREVIOUS_FY_GLOBAL_COUNT__C!= null && dulicateRank.PREVIOUS_FY_GLOBAL_COUNT__C > 0) {	
	if ( firstRank.PREVIOUS_FY_GLOBAL_COUNT__C!= null && firstRank.PREVIOUS_FY_GLOBAL_COUNT__C > 0)	
	firstRank.PREVIOUS_FY_GLOBAL_COUNT__C = firstRank.PREVIOUS_FY_GLOBAL_COUNT__C + dulicateRank.PREVIOUS_FY_GLOBAL_COUNT__C;
	  else
	  firstRank.PREVIOUS_FY_GLOBAL_COUNT__C = dulicateRank.PREVIOUS_FY_GLOBAL_COUNT__C; }
	  
	if ( dulicateRank.PREVIOUS_FY_JAPAN_COUNT__C!= null && dulicateRank.PREVIOUS_FY_JAPAN_COUNT__C > 0) {	
	if ( firstRank.PREVIOUS_FY_JAPAN_COUNT__C!= null && firstRank.PREVIOUS_FY_JAPAN_COUNT__C > 0)	
	firstRank.PREVIOUS_FY_JAPAN_COUNT__C = firstRank.PREVIOUS_FY_JAPAN_COUNT__C + dulicateRank.PREVIOUS_FY_JAPAN_COUNT__C;
	  else
	  firstRank.PREVIOUS_FY_JAPAN_COUNT__C = dulicateRank.PREVIOUS_FY_JAPAN_COUNT__C; }
	  
	if ( dulicateRank.PREVIOUS_FY_US_COUNT__C!= null && dulicateRank.PREVIOUS_FY_US_COUNT__C > 0) {
	if ( firstRank.PREVIOUS_FY_US_COUNT__C!= null && firstRank.PREVIOUS_FY_US_COUNT__C > 0)	
	firstRank.PREVIOUS_FY_US_COUNT__C = firstRank.PREVIOUS_FY_US_COUNT__C + dulicateRank.PREVIOUS_FY_US_COUNT__C;
	  else	
	  firstRank.PREVIOUS_FY_US_COUNT__C = dulicateRank.PREVIOUS_FY_US_COUNT__C; }
	  
	if ( dulicateRank.CURRENT_CY_ASIAEX_POINTS__C!= null && dulicateRank.CURRENT_CY_ASIAEX_POINTS__C > 0) {
		if ( firstRank.CURRENT_CY_ASIAEX_POINTS__C!= null && firstRank.CURRENT_CY_ASIAEX_POINTS__C > 0)	
			firstRank.CURRENT_CY_ASIAEX_POINTS__C = firstRank.CURRENT_CY_ASIAEX_POINTS__C + dulicateRank.CURRENT_CY_ASIAEX_POINTS__C;
		else	
			firstRank.CURRENT_CY_ASIAEX_POINTS__C = dulicateRank.CURRENT_CY_ASIAEX_POINTS__C;
	}
	if ( dulicateRank.CURRENT_CY_EUROPE_POINTS__C!= null && dulicateRank.CURRENT_CY_EUROPE_POINTS__C > 0) {	
	if ( firstRank.CURRENT_CY_EUROPE_POINTS__C!= null && firstRank.CURRENT_CY_EUROPE_POINTS__C > 0)	
	firstRank.CURRENT_CY_EUROPE_POINTS__C = firstRank.CURRENT_CY_EUROPE_POINTS__C + dulicateRank.CURRENT_CY_EUROPE_POINTS__C;
	  else	
	  firstRank.CURRENT_CY_EUROPE_POINTS__C = dulicateRank.CURRENT_CY_EUROPE_POINTS__C; }
	  
	if ( dulicateRank.CURRENT_CY_GLOBAL_POINTS__C!= null && dulicateRank.CURRENT_CY_GLOBAL_POINTS__C > 0) {
	if ( firstRank.CURRENT_CY_GLOBAL_POINTS__C!= null && firstRank.CURRENT_CY_GLOBAL_POINTS__C > 0)	
	firstRank.CURRENT_CY_GLOBAL_POINTS__C = firstRank.CURRENT_CY_GLOBAL_POINTS__C + dulicateRank.CURRENT_CY_GLOBAL_POINTS__C;
	  else	
	  firstRank.CURRENT_CY_GLOBAL_POINTS__C = dulicateRank.CURRENT_CY_GLOBAL_POINTS__C; }
	  
	if ( dulicateRank.CURRENT_CY_JAPAN_POINTS__C!= null && dulicateRank.CURRENT_CY_JAPAN_POINTS__C > 0) {
	if ( firstRank.CURRENT_CY_JAPAN_POINTS__C!= null && firstRank.CURRENT_CY_JAPAN_POINTS__C > 0)
	firstRank.CURRENT_CY_JAPAN_POINTS__C = firstRank.CURRENT_CY_JAPAN_POINTS__C + dulicateRank.CURRENT_CY_JAPAN_POINTS__C;
	  else	
	  firstRank.CURRENT_CY_JAPAN_POINTS__C = dulicateRank.CURRENT_CY_JAPAN_POINTS__C; }
	  
	if ( dulicateRank.CURRENT_CY_US_POINTS__C!= null && dulicateRank.CURRENT_CY_US_POINTS__C > 0) {
	if ( firstRank.CURRENT_CY_US_POINTS__C!= null && firstRank.CURRENT_CY_US_POINTS__C > 0)	
	firstRank.CURRENT_CY_US_POINTS__C = firstRank.CURRENT_CY_US_POINTS__C + dulicateRank.CURRENT_CY_US_POINTS__C;
	  else	
	  firstRank.CURRENT_CY_US_POINTS__C = dulicateRank.CURRENT_CY_US_POINTS__C; }
	  
	if ( dulicateRank.CURRENT_FY_ASIAEX_POINTS__C!= null && dulicateRank.CURRENT_FY_ASIAEX_POINTS__C > 0) {
	if ( firstRank.CURRENT_FY_ASIAEX_POINTS__C!= null && firstRank.CURRENT_FY_ASIAEX_POINTS__C > 0)
	firstRank.CURRENT_FY_ASIAEX_POINTS__C = firstRank.CURRENT_FY_ASIAEX_POINTS__C + dulicateRank.CURRENT_FY_ASIAEX_POINTS__C;
	  else
	  firstRank.CURRENT_FY_ASIAEX_POINTS__C = dulicateRank.CURRENT_FY_ASIAEX_POINTS__C; }
	  
	if ( dulicateRank.CURRENT_FY_EUROPE_POINTS__C!= null && dulicateRank.CURRENT_FY_EUROPE_POINTS__C > 0) {
	if ( firstRank.CURRENT_FY_EUROPE_POINTS__C!= null && firstRank.CURRENT_FY_EUROPE_POINTS__C > 0)	
	firstRank.CURRENT_FY_EUROPE_POINTS__C = firstRank.CURRENT_FY_EUROPE_POINTS__C + dulicateRank.CURRENT_FY_EUROPE_POINTS__C;
	  else
	  firstRank.CURRENT_FY_EUROPE_POINTS__C = dulicateRank.CURRENT_FY_EUROPE_POINTS__C; }
	  
	  
	if ( dulicateRank.CURRENT_FY_GLOBAL_POINTS__C!= null && dulicateRank.CURRENT_FY_GLOBAL_POINTS__C > 0) {	
	if ( firstRank.CURRENT_FY_GLOBAL_POINTS__C!= null && firstRank.CURRENT_FY_GLOBAL_POINTS__C > 0)	
	firstRank.CURRENT_FY_GLOBAL_POINTS__C = firstRank.CURRENT_FY_GLOBAL_POINTS__C + dulicateRank.CURRENT_FY_GLOBAL_POINTS__C;
	  else
	  firstRank.CURRENT_FY_GLOBAL_POINTS__C = dulicateRank.CURRENT_FY_GLOBAL_POINTS__C; }
	  
	if ( dulicateRank.CURRENT_FY_JAPAN_POINTS__C!= null && dulicateRank.CURRENT_FY_JAPAN_POINTS__C > 0) {
	if ( firstRank.CURRENT_FY_JAPAN_POINTS__C!= null && firstRank.CURRENT_FY_JAPAN_POINTS__C > 0)	
	firstRank.CURRENT_FY_JAPAN_POINTS__C = firstRank.CURRENT_FY_JAPAN_POINTS__C + dulicateRank.CURRENT_FY_JAPAN_POINTS__C;
	  else	
	  firstRank.CURRENT_FY_JAPAN_POINTS__C = dulicateRank.CURRENT_FY_JAPAN_POINTS__C; }
	  
	if ( dulicateRank.CURRENT_FY_US_POINTS__C!= null && dulicateRank.CURRENT_FY_US_POINTS__C > 0) {
	if ( firstRank.CURRENT_FY_US_POINTS__C!= null && firstRank.CURRENT_FY_US_POINTS__C > 0)	
	firstRank.CURRENT_FY_US_POINTS__C = firstRank.CURRENT_FY_US_POINTS__C + dulicateRank.CURRENT_FY_US_POINTS__C;
	  else
	  firstRank.CURRENT_FY_US_POINTS__C = dulicateRank.CURRENT_FY_US_POINTS__C; }
	  
	if ( dulicateRank.PREVIOUS_CY_ASIAEX_POINTS__C!= null && dulicateRank.PREVIOUS_CY_ASIAEX_POINTS__C > 0) {	
	if ( firstRank.PREVIOUS_CY_ASIAEX_POINTS__C!= null && firstRank.PREVIOUS_CY_ASIAEX_POINTS__C > 0)	
	firstRank.PREVIOUS_CY_ASIAEX_POINTS__C = firstRank.PREVIOUS_CY_ASIAEX_POINTS__C + dulicateRank.PREVIOUS_CY_ASIAEX_POINTS__C;
	  else	
	  firstRank.PREVIOUS_CY_ASIAEX_POINTS__C = dulicateRank.PREVIOUS_CY_ASIAEX_POINTS__C; }
	  
	if ( dulicateRank.PREVIOUS_CY_EUROPE_POINTS__C!= null && dulicateRank.PREVIOUS_CY_EUROPE_POINTS__C > 0) {	
	if ( firstRank.PREVIOUS_CY_EUROPE_POINTS__C!= null && firstRank.PREVIOUS_CY_EUROPE_POINTS__C > 0)
	firstRank.PREVIOUS_CY_EUROPE_POINTS__C = firstRank.PREVIOUS_CY_EUROPE_POINTS__C + dulicateRank.PREVIOUS_CY_EUROPE_POINTS__C;
	  else
	  firstRank.PREVIOUS_CY_EUROPE_POINTS__C = dulicateRank.PREVIOUS_CY_EUROPE_POINTS__C; }
	  
	if ( dulicateRank.PREVIOUS_CY_GLOBAL_POINTS__C!= null && dulicateRank.PREVIOUS_CY_GLOBAL_POINTS__C > 0) {
	if ( firstRank.PREVIOUS_CY_GLOBAL_POINTS__C!= null && firstRank.PREVIOUS_CY_GLOBAL_POINTS__C > 0)	
	firstRank.PREVIOUS_CY_GLOBAL_POINTS__C = firstRank.PREVIOUS_CY_GLOBAL_POINTS__C + dulicateRank.PREVIOUS_CY_GLOBAL_POINTS__C;
	  else	
	  firstRank.PREVIOUS_CY_GLOBAL_POINTS__C = dulicateRank.PREVIOUS_CY_GLOBAL_POINTS__C; }
	  
	if ( dulicateRank.PREVIOUS_CY_JAPAN_POINTS__C!= null && dulicateRank.PREVIOUS_CY_JAPAN_POINTS__C > 0) {	
	if ( firstRank.PREVIOUS_CY_JAPAN_POINTS__C!= null && firstRank.PREVIOUS_CY_JAPAN_POINTS__C > 0)
	firstRank.PREVIOUS_CY_JAPAN_POINTS__C = firstRank.PREVIOUS_CY_JAPAN_POINTS__C + dulicateRank.PREVIOUS_CY_JAPAN_POINTS__C;
	  else	
	  firstRank.PREVIOUS_CY_JAPAN_POINTS__C = dulicateRank.PREVIOUS_CY_JAPAN_POINTS__C; }
	  
	if ( dulicateRank.PREVIOUS_CY_US_POINTS__C!= null && dulicateRank.PREVIOUS_CY_US_POINTS__C > 0) {	
	if ( firstRank.PREVIOUS_CY_US_POINTS__C!= null && firstRank.PREVIOUS_CY_US_POINTS__C > 0)
	firstRank.PREVIOUS_CY_US_POINTS__C = firstRank.PREVIOUS_CY_US_POINTS__C + dulicateRank.PREVIOUS_CY_US_POINTS__C;
	  else
	  firstRank.PREVIOUS_CY_US_POINTS__C = dulicateRank.PREVIOUS_CY_US_POINTS__C; }
	  
	if ( dulicateRank.PREVIOUS_FY_ASIAEX_POINTS__C!= null && dulicateRank.PREVIOUS_FY_ASIAEX_POINTS__C > 0) {	
	if ( firstRank.PREVIOUS_FY_ASIAEX_POINTS__C!= null && firstRank.PREVIOUS_FY_ASIAEX_POINTS__C > 0)
	firstRank.PREVIOUS_FY_ASIAEX_POINTS__C = firstRank.PREVIOUS_FY_ASIAEX_POINTS__C + dulicateRank.PREVIOUS_FY_ASIAEX_POINTS__C;
	  else
	  firstRank.PREVIOUS_FY_ASIAEX_POINTS__C = dulicateRank.PREVIOUS_FY_ASIAEX_POINTS__C; }
	  
	if ( dulicateRank.PREVIOUS_FY_EUROPE_POINTS__C!= null && dulicateRank.PREVIOUS_FY_EUROPE_POINTS__C > 0) {	
	if ( firstRank.PREVIOUS_FY_EUROPE_POINTS__C!= null && firstRank.PREVIOUS_FY_EUROPE_POINTS__C > 0)	
	firstRank.PREVIOUS_FY_EUROPE_POINTS__C = firstRank.PREVIOUS_FY_EUROPE_POINTS__C + dulicateRank.PREVIOUS_FY_EUROPE_POINTS__C;
	  else
	  firstRank.PREVIOUS_FY_EUROPE_POINTS__C = dulicateRank.PREVIOUS_FY_EUROPE_POINTS__C; }
	  
	if ( dulicateRank.PREVIOUS_FY_GLOBAL_POINTS__C!= null && dulicateRank.PREVIOUS_FY_GLOBAL_POINTS__C > 0) {	
	if ( firstRank.PREVIOUS_FY_GLOBAL_POINTS__C!= null && firstRank.PREVIOUS_FY_GLOBAL_POINTS__C > 0)	
	firstRank.PREVIOUS_FY_GLOBAL_POINTS__C = firstRank.PREVIOUS_FY_GLOBAL_POINTS__C + dulicateRank.PREVIOUS_FY_GLOBAL_POINTS__C;
	  else
	  firstRank.PREVIOUS_FY_GLOBAL_POINTS__C = dulicateRank.PREVIOUS_FY_GLOBAL_POINTS__C; }
	  
	if ( dulicateRank.PREVIOUS_FY_JAPAN_POINTS__C!= null && dulicateRank.PREVIOUS_FY_JAPAN_POINTS__C > 0) {	
	if ( firstRank.PREVIOUS_FY_JAPAN_POINTS__C!= null && firstRank.PREVIOUS_FY_JAPAN_POINTS__C > 0)	
	firstRank.PREVIOUS_FY_JAPAN_POINTS__C = firstRank.PREVIOUS_FY_JAPAN_POINTS__C + dulicateRank.PREVIOUS_FY_JAPAN_POINTS__C;
	  else
	  firstRank.PREVIOUS_FY_JAPAN_POINTS__C = dulicateRank.PREVIOUS_FY_JAPAN_POINTS__C; }
	  
	if ( dulicateRank.PREVIOUS_FY_US_POINTS__C!= null && dulicateRank.PREVIOUS_FY_US_POINTS__C > 0) {
	if ( firstRank.PREVIOUS_FY_US_POINTS__C!= null && firstRank.PREVIOUS_FY_US_POINTS__C > 0)	
	firstRank.PREVIOUS_FY_US_POINTS__C = firstRank.PREVIOUS_FY_US_POINTS__C + dulicateRank.PREVIOUS_FY_US_POINTS__C;
	  else	
	  firstRank.PREVIOUS_FY_US_POINTS__C = dulicateRank.PREVIOUS_FY_US_POINTS__C; }
    }	
    
  /*  private Map<String, List<Account_Service_Rank__c>> createMapOfDuplicatesBasedOnExternalId(List<Account_Service_Rank__c> serviceRankList) {
        Map<String, List<Account_Service_Rank__c>> duplicateMap = new Map<String, List<Account_Service_Rank__c>>();
        for (Account_Service_Rank__c rank: serviceRankList) {
            List<Account_Service_Rank__c> duplicateList = duplicateMap.get(rank.external_id__c);
            if (duplicateList == null) {
                duplicateList = new List<Account_Service_Rank__c>();
                duplicateMap.put(rank.external_id__c, duplicateList);
            }
            duplicateList.add(rank);
        }
        return duplicateMap;
    }*/
    
    private void doLogging(Database.UpsertResult[] results, String modelName) {
        for (Database.upsertResult sr : results) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted rank. ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        String errorMessage = 'PopulateServiceCountBatch failed for '+modelName + '. Error status = ' +  err.getStatusCode() +
                            ', Error message = ' + err.getMessage() + ', Error fields = ' + err.getFields();
                        System.debug(errorMessage);                     
                        errorMessageList.add(errorMessage);
                    }
                }
            }   
    }
    
    private List<Account_Service_Rank__c> createServiceRankObject (String whatType, AggregateResult[] results, 
                                                                    Account_Service_Model__c modelData,   
                                                                    ServiceROIUtility.MonthlyPeriod period) {
        List<Account_Service_Rank__c> serviceRankList = new List<Account_Service_Rank__c>();
        if (results != null && results.size() > 0) {
            for (AggregateResult result: results) {
                Map<String, Decimal> regionalCount = new Map<String, Decimal>();
                List<String> periods = new List<String>();
                
                Account_Service_Rank__c serviceRank = new Account_Service_Rank__c();
                if (modelData.inProgress_Version__c != null) {
                    serviceRank.version__c= modelData.inProgress_Version__c;
                }   
                
                Id modelId= modelData.Id;
                Account_Service_Model__c modelReference = new Account_Service_Model__c(Id=modelId);
                serviceRank.Model__c = modelReference.id;               
                
                System.debug(result);
                Id whatid = (Id)result.get('whatid');
                System.debug('whatid = ' + whatid);
                if (whatType.equals('Account')) {
                    Account accountReference = new Account(Id=whatid);
                    System.debug(accountReference);
                    serviceRank.Account__c = accountReference.id;
                    serviceRank.external_id__c= whatid +'_'+ modelId +'_'+ String.valueOf(modelData.inProgress_Version__c);
                }
                else {
                    serviceRank.external_id__c= whatid;
                }
                
                Decimal asiaCount = (Decimal)result.get('asia');
                if (asiaCount != null && asiaCount > 0) {
                    regionalCount.put(ServiceROIUtility.ASIAEX,asiaCount);
                }
                
                Decimal usCount= (Decimal)result.get('us');
                if (usCount != null && usCount > 0) {
                    regionalCount.put(ServiceROIUtility.US,usCount);
                }

                Decimal emCount= (Decimal)result.get('em');
                if (emCount != null && emCount > 0) {
                    regionalCount.put(ServiceROIUtility.EUROPE,emCount);
                }

                Decimal jpCount= (Decimal)result.get('jp');
                if (jpCount != null && jpCount > 0) {
                    regionalCount.put(ServiceROIUtility.JAPAN,jpCount);
                }

                Decimal gblCount= (Decimal)result.get('gbl');
                if (gblCount != null && gblCount > 0) {
                    regionalCount.put(ServiceROIUtility.GBL,gblCount);
                }                
                
                
                if (period.isCurrentCY)
                    periods.add(ServiceROIUtility.CURRENT_CY);
                
                if (period.isCurrentFY)
                    periods.add(ServiceROIUtility.CURRENT_FY);

                if (period.isPreviousCY)
                    periods.add(ServiceROIUtility.PREVIOUS_CY);

                if (period.isPreviousFY)
                    periods.add(ServiceROIUtility.PREVIOUS_FY);                
                
                updateCountAndPointFields(serviceRank, regionalCount, periods, modelData.weight__c);
                system.debug('serviceRank = '+ serviceRank);
                serviceRankList.add(serviceRank);
            }
        }
        System.debug('serviceRankList size = ' + serviceRankList.size());
        return serviceRankList;
    }
    
    private void updateCountAndPointFields (Account_Service_Rank__c serviceRank, Map<String, Decimal> regionalCount, List<String> periods,
                                                Decimal weight) {
        initializeCountAndPointFields(serviceRank);
        for (String region: regionalCount.keyset()) {
                Decimal count = regionalCount.get(region);
                if (count != null && count > 0) {
                    for (String period : periods) {
                        //Previous_CY_ASIAEX_COUNT__C
                        String countFieldName = period  + region + ServiceROIUtility.COUNT;
                        //Current_CY_GLOBAL_POINTS__C
                        String pointsFieldName = period  + region + ServiceROIUtility.POINTS;
                        System.debug('countFieldName = '+ countFieldName);
                        System.debug('pointsFieldName = '+ pointsFieldName);
                        serviceRank.put(countFieldName , count );
                        if (weight != null)
                            serviceRank.put(pointsFieldName , (count * weight) );                    
                        else
                            serviceRank.put(pointsFieldName , count );                    
                    }
                }   
        }
    }
    private void initializeCountAndPointFields(Account_Service_Rank__c serviceRank) {
    
        Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Account_Service_Rank__c.fields.getMap(); 
    
         for (String fieldName : mapFields.keyset()) 
            { 
                if (fieldName.toUpperCase().contains('_COUNT__C') || fieldName.toUpperCase().contains('_POINTS__C')) {
                    serviceRank.put(fieldName , 0);
                }
            }    
    }
    
    private AggregateResult[] getAggregratedResults (String whatType, String soqlString , Account_Service_Model__c modelData, ServiceROIUtility.MonthlyPeriod period) {
        AggregateResult[] results = null;
        // Bind variables start
        DateTime startDate = period.startDate;
        DateTime endDate = period.endDate;
        List<String> callReportType = null;
        List<String> daEventType = null;
        List<String> daEventMeetingTypes = null;
        
        if (modelData.Call_Report_Type__c != null && String.isNotEmpty(modelData.Call_Report_Type__c)) {
            callReportType = modelData.Call_Report_Type__c.split(';');
        }   
        else if (modelData.DealAxis_Type__c != null && String.isNotEmpty(modelData.DealAxis_Type__c)) {
            AccountServiceModelBL.DAMeetingEventWrapper daWrapper = AccountServiceModelBL.splitDAEventMeetingType(modelData.DealAxis_Type__c);
            daEventType = daWrapper.da_event_types.split(';');
            daEventMeetingTypes = daWrapper.da_event_meeting_types.split(';');
            
        }   
        System.debug('callReportType =' + callReportType);
        System.debug('daEventType =' + daEventType);
        System.debug('daEventMeetingType =' + daEventMeetingTypes);
        System.debug('startDate =' + startDate);
        System.debug('endDate =' + endDate);
        System.debug('whatType =' + whatType);
        //Bind variables end
        
        results  = Database.query(soqlString );
        if (results != null)
            system.debug ('Aggregrated Results size = ' + results.size());
        return results ;
    }
    
    private String formSoqlString(Account_Service_Model__c modelData, ServiceROIUtility.MonthlyPeriod period) {
        String soqlQuery = null;
        soqlQuery = getCommonSelectQuery() 
            + getModelSpecificAggregratedFields(modelData.Is_Contact_Count__c) 
            + getCommonWhereCondition() 
            + getModelSpecificWhereCondition(modelData.Is_Contact_Count__c, modelData) 
           + getCommonGroupByCondition() 
           /*+ getCommonHavingCondition()*/
            ;
            
        system.debug('soqlQuery = ' + soqlQuery);
        return soqlQuery;
        
    }
    
    private String getCommonGroupByCondition () {
        return ' group by whatid ';
    
    }
    
    private String getModelSpecificWhereCondition(String isContactCount, Account_Service_Model__c modelData) {
        string modelSpecificWhereCondition = null;
        String callReportType = modelData.Call_Report_Type__c;
        AccountServiceModelBL.DAMeetingEventWrapper daWrapper;
        String daEventType = '';
        List<string> daEventMeetingTypes = new List<string>();
        
        if(modelData.DealAxis_Type__c!=null){
            daWrapper = AccountServiceModelBL.splitDAEventMeetingType(modelData.DealAxis_Type__c);
            daEventType = daWrapper.da_event_types;
            if(daWrapper.da_event_meeting_types!=null)
                daEventMeetingTypes =daWrapper.da_event_meeting_types.split(';');
        }
        if (isContactCount != null && isContactCount.equals('YES')) {
            modelSpecificWhereCondition = ' and (SR_JP_Con_Cnt__c >0 or SR_AS_Con_Cnt__c > 0 or SR_US_Con_Cnt__c > 0 or SR_EM_Con_Cnt__c >0)';
        }
        else {
            modelSpecificWhereCondition = ' and (SR_JP_Cnt__c >0 or SR_AS_Cnt__c > 0 or SR_US_Cnt__c > 0 or SR_EM_Cnt__c >0)';
        }   
        if (callReportType != null && String.isNotEmpty(callReportType)) {
            modelSpecificWhereCondition = modelSpecificWhereCondition +
                ' and Type in :callReportType ';
        }
        else if (daEventType != null && String.isNotEmpty(daEventType)) {
             modelSpecificWhereCondition = modelSpecificWhereCondition +
                ' and Event_Type__c in :daEventType ';
            if (daEventMeetingTypes != null && daEventMeetingTypes.size() > 0) {
                 modelSpecificWhereCondition = modelSpecificWhereCondition +
                    ' and type in :daEventMeetingTypes ';
            }
        }
        return modelSpecificWhereCondition;
    }    
    
    private String getCommonWhereCondition() {
        return ' from event where isChild = false and isDeleted = false and what.type = :whatType and StartDateTime >= :startDate and StartDateTime < :endDate ';
    }
    
    private String getCommonSelectQuery() {
        return 'Select whatid ';
    }
    
    private String getModelSpecificAggregratedFields(String isContactCount) {
        string modelSpecificAggregratedFields = null;
        if (isContactCount != null && isContactCount.equals('YES')) {
            modelSpecificAggregratedFields = ' ,sum(SR_JP_Con_Cnt__c)jp, sum(SR_AS_Con_Cnt__c)asia, sum(SR_US_Con_Cnt__c)us, sum(SR_EM_Con_Cnt__c)em, sum(SR_GBL_Con_Cnt__c)gbl';
        }
        else {
            modelSpecificAggregratedFields = ' ,sum(SR_JP_Cnt__c)jp, sum(SR_AS_Cnt__c)asia, sum(SR_US_Cnt__c)us, sum(SR_EM_Cnt__c)em,  sum(SR_GBL_Cnt__c)gbl';
        }    
        return modelSpecificAggregratedFields;
    }
}

/*
   Database.executeBatch(new PopulateServiceCountBatch(), 1);


*/

/* 
String soqlQuery = 'select what.name, sum(SR_JP_Cnt__c)jp_count from event where isChild = false and isDeleted = false and SR_JP_Cnt__c != null group by what.name';
AggregateResult[] results = Database.query(soqlQuery);
integer counter = 0;
for (AggregateResult result: results) {
    System.debug(result.get('jp_count') +' = ' +result.get('Name'));
    counter = counter + 1;
}
System.debug('counter = ' + counter);

*/