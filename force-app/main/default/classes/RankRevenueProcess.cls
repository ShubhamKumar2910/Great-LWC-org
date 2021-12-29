global class RankRevenueProcess implements Database.batchable<sObject>, Database.Stateful {
	global List<String> errorList = new List<String>();
	
    public RankRevenueProcess() {
        RevenueRankUtility.setResettingState();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
    	return Database.getQueryLocator('SELECT id FROM Account_Revenue_Rank__c');
    }
    
    global void execute(Database.batchableContext info, List<sObject> scope) {
		RevenueRankUtility.logExecuteMethod('ResetRevenueRanks', info.getJobId(), scope.size());
        List<Account_Revenue_Rank__c> ranksToReset = (List<Account_Revenue_Rank__c>) scope;
        resetRanks(ranksToReset);
        Database.SaveResult[] results = Database.update(ranksToReset, false);
        Map<Integer, String> errorMap = RevenueRankUtility.logErrors(results, null, null, 'ResetRevenueRanks', '');
        if (errorMap.size()>0) {
            System.debug(LoggingLevel.WARN, 'Found ' + errorMap.size() +' errors trying to save revenue rank objects in ResetRevenueRanks');
            for (Integer rowNumber: errorMap.keySet()) {
                //object not saved:
                Account_Revenue_Rank__c rank = ranksToReset[rowNumber];
                String message = errorMap.get(rowNumber);
                errorList.add('Id not updated = '+ rank.Id +'. Detail: '+ message);
            }
        }
    }     
    
    public static void resetRanks(List<Account_Revenue_Rank__c> ranks ) {
        for (Account_Revenue_Rank__c rr: ranks) {
        	RevenueRankUtility.resetAccountRevenueRank(rr);
        }
    }
    
    global void finish(Database.batchableContext info){  
    	System.debug(LoggingLevel.INFO, 'In finish method of ResetRevenueRanks');
        Map<String, String> jobStats = RevenueRankUtility.getJobStats(info.getJobId());
        boolean hasErrors = RevenueRankUtility.listErrorsAndNotify(errorList, 'ResetRevenueRanks',info.getJobId(), jobStats);
    	if (!hasErrors) {
            RevenueRankUtility.setPopulatingState();
    		Database.executeBatch(new PopulateAccountRevenueStats(),2000);
        } else {
            System.debug(LoggingLevel.ERROR, 'Aborting ResetRevenueRanks on errors');
            RevenueRankUtility.setErrorState();
        }           
    } 

}