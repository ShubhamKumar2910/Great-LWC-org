global class CleanAccountRevenueStats implements Database.batchable<sObject>, Database.Stateful {
    global List<String> errorList = new List<String>();
	global final Integer newVersion = null;
    global final static String JOB_NAME='CleanAccountRevenueStats';
    public CleanAccountRevenueStats (Integer version) {
        newVersion = version;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('Created new instance of class with a version of '+ newVersion);
        String query = 'SELECT Id FROM Account_Revenue_Rank__c where Version__c!=:newVersion';
		System.debug('Querying Account_Revenue_Rank with this soql = ' + query);
    	return Database.getQueryLocator(query);
    }
    
    global void execute(Database.batchableContext info, List<sObject> scope) {
        System.debug('In execute method of ' + JOB_NAME +'. Operating on batch of ' + scope.size() + ' Account_Revenue_Rank objects');
        List<Account_Revenue_Rank__c> rankList = (List<Account_Revenue_Rank__c>) scope;
        Database.DeleteResult[] results = Database.delete(rankList, false);
        Map<Integer, String> errorMap = RevenueRankUtility.logErrors(null, null, results, JOB_NAME, '');
        RevenueRankUtility.populateErrorList(errorMap,JOB_NAME,rankList,errorList);
        //remove the deletes from the recycle bin
        List<Id> itemsToRemoveFromRecycle = new List<Id>();
        for (Database.DeleteResult result: results) {
            if (result.isSuccess()) {
                itemsToRemoveFromRecycle.add(result.getId());
            }
        }
        if (itemsToRemoveFromRecycle.size()>0) {
            System.debug(LoggingLevel.INFO,'Removing old account revenue stats from the recycle bin. Number of items to remove: '+ itemsToRemoveFromRecycle.size());
            DataBase.emptyRecycleBin(itemsToRemoveFromRecycle);
        }
		
    }
    
    global void finish(Database.batchableContext info) {
        Map<String, String> jobStats = RevenueRankUtility.getJobStats(info.getJobId());
        boolean hasErrors = RevenueRankUtility.listErrorsAndNotify(errorList, JOB_NAME,info.getJobId(), jobStats);
    	if (hasErrors) {
            System.debug(LoggingLevel.ERROR, 'Aborting ' + JOB_NAME + 'on errors');
            RevenueRankUtility.setErrorState();
        } else {
            System.debug(LoggingLevel.INFO, 'Account Revenue Rank has completed succesfully');
            RevenueRankUtility.setCompleteState();
        }           

    }
}