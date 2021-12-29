global class CalculateAccountRevenueRank implements Database.batchable<RevenueRankQueryObject>, Database.Stateful {
    global Map<String, List<RevenueRankQueryObject>> productRankQueryMap;
    global final Integer newVersion = null;
    global final String productTime;
    global final List<RevenueRankQueryObject> queryList;
    global List<String> errorList = new List<String>();
    
    public CalculateAccountRevenueRank(Map<String, List<RevenueRankQueryObject>> remainingProductRankQueryMap, Integer version) {
        System.debug('Created new instance of CalculateAccountRevenueRank with ' + remainingProductRankQueryMap.size() + ' products query entries to run and version of '+ version);
        productRankQueryMap = remainingProductRankQueryMap;
        newVersion = version;
        if (null != productRankQueryMap && productRankQueryMap.size()>0) {
            RevenueRankUtility.setRankProgress(productRankQueryMap.size());
            List<String> keys = new List<String>(productRankQueryMap.keySet());
            productTime = keys[0];
            queryList = productRankQueryMap.remove(productTime);
            System.debug('Processing ' + queryList.size() + ' query entries for product time measure of ' + productTime);
        } else {
            System.debug(LoggingLevel.WARN, 'Should never run out of query products in constructor! Aborting job!');
        }
    }
   
    global Iterable<RevenueRankQueryObject> start(Database.BatchableContext BC){
        System.debug('Creating revenue ranks for product ' + productTime);
        List<RevenueRankQueryObject> queries = new List<RevenueRankQueryObject>(queryList);
    	return queries;
    }
    
    global void execute(Database.batchableContext info, List<RevenueRankQueryObject> scope) {
        Map<Id, Account_Revenue_Rank__c> rankMap = new Map<Id, Account_Revenue_Rank__c>();
        Integer sortCount;
        Double priorRevenue;
        Double currentRevenue;
        Integer skipCount;
        Account_Revenue_Rank__c savedRank; //store this in the map, so we update the fields but use the query lists for the revenue compares
        for (RevenueRankQueryObject query: scope) {
            //sortCount = 1;
            priorRevenue = null;
            currentRevenue = null;
            savedRank = null;
            system.debug('query.getRevenueQuery ::'+ query.getRevenueQuery());
            for (List<Account_Revenue_Rank__c> ranks: Database.query(query.getRevenueQuery())) {                 
                for (Account_Revenue_Rank__c rank: ranks) {
                    savedRank = rankMap.get(rank.id);
                    if (null == savedRank) {
                        savedRank = rank.clone(true,true,true,true);
                        rankMap.put(rank.id, savedRank);
                    }
                    if (null != priorRevenue) {
                        //this is not the first entry, so let's test for ties
                         //commented for JIRA 3652 for having continous rank on records.  
                        currentRevenue = RevenueRankUtility.getRevenue(rank, query.getQueryField());
                        //current revenue is not equal to prior, so there is no tie and the counter is incremented
                        if (currentRevenue!=priorRevenue) {                                                 
                            //sortCount = sortCount+1; 
                            sortCount = sortCount + skipCount;
                            skipCount = 1;
                        }
                        else{
                           skipCount = skipCount + 1;
                        }
                    } else {
                        sortCount = 1;
                        skipCount = 1;
                    }
                    RevenueRankUtility.updateRank(savedRank, query.getQueryField(), sortCount);
                    priorRevenue = RevenueRankUtility.getRevenue(rank, query.getQueryField());
                }
            }
            System.debug('Number of query rows ' + Limits.getQueryRows() + ' out of ' + Limits.getLimitQueryRows() + ' for query ' + query.getRevenueQuery());
        }
        if (rankMap.values().size()>0) {
            String jobName='CalculateAccountRevenueRank3';
            System.debug('updating ' + rankMap.values().size() + ' revenue rank values');
            Database.SaveResult[] results = Database.update(rankMap.values(), false);
            Map<Integer, String> errorMap = RevenueRankUtility.logErrors(results, null, null, jobName, '');
            RevenueRankUtility.populateErrorList(errorMap, jobName, rankMap.values(), errorList);
        }
    }

    global void finish(Database.batchableContext info){
        String jobName = 'CalculateAccountRevenueRank';
        System.debug(LoggingLevel.INFO, 'In finish method of '+jobName);
        Map<String, String> jobStats = RevenueRankUtility.getJobStats(info.getJobId());
        if (Integer.valueOf(jobStats.get(RevenueRankUtility.JOB_ERRORS))>0) {
            jobStats.put(RevenueRankUtility.JOB_LASTPRODUCT,'Error found while ranking product ' + productTime);
        }
        boolean hasErrors = RevenueRankUtility.listErrorsAndNotify(errorList, jobName,info.getJobId(), jobStats);
        
        if (!hasErrors) {
            if (productRankQueryMap.size() == 0) {
                //we're done, just call cleanup
                System.debug('Cleaning up now.');
                Database.executeBatch(new CleanAccountRevenueStats(newVersion),2000);
            } else {
                //call the job again with the reduced productSet
                Database.executeBatch(new CalculateAccountRevenueRank(productRankQueryMap, newVersion),2000);  
            }
        } else {
            System.debug(LoggingLevel.ERROR, 'Found ' + errorList.size() +' errors trying to save revenue rank objects in ' + jobName + '. Notifying users');
            RevenueRankUtility.setErrorState();
        }
		
    }
}