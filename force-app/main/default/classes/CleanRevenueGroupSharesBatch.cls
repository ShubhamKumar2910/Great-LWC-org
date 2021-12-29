global class CleanRevenueGroupSharesBatch implements Database.Batchable<sObject>, Database.Stateful{
    String integrationUser;  //integration user id
    Map<String, String> groupNameToIdMap = new Map<String, String>(); //holds the dev name to id relationship for revenue groups
    private static final String jobName = 'CleanRevenueGroupSharesBatch';
    List<String> sharesInsertErrorList = new List<String>();
    class CleanRevenueGroupSharesBatchException extends Exception {}
    Integer sharesInserted = 0;
    
    global CleanRevenueGroupSharesBatch(String integrationAccountAlias) {
        System.debug(LoggingLevel.INFO,'>>>>CleanRevenueGroupSharesBatch. integrationAccountAlias='+integrationAccountAlias);
        List<User> userList = [SELECT Login_ID__c, ID from User WHERE IsActive = true and Alias=:integrationAccountAlias];
        if (userList.size()>0) {
            integrationUser = userList.get(0).Id;
        } else {
            throw new CleanRevenueGroupSharesBatchException('Could not find active user with alias of ' +integrationAccountAlias);
        }
        
        List<Group> groups = [SELECT Id, DeveloperName from Group where DeveloperName like 'Revenue_%'];
        for (Group g: groups ) {
            groupNameToIdMap.put(g.DeveloperName, g.Id);
        }
        
        System.debug(LoggingLevel.INFO, '<<<<<CleanRevenueGroupSharesBatch  Initialized with sfAdmin id of '+ integrationUser + ' and groupName To Id map size of ' + groupNameToIdMap.size());
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = 'select Id, Group__c, OwnerId, (select UserOrGroupId from Shares) from Revenue__c where Group__c like \'Revenue_%\' and OwnerId=\'' + integrationUser + '\'';
        if (Test.isRunningTest()) {
            query = query + ' LIMIT ' + 200;
        }
        System.debug('>>>>start. firing query '+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        System.debug(LoggingLevel.INFO,'>>>>execute In execute method.  Operating on ' + scope.size() + ' revenue records');
        List<Revenue__c> revenuesToProcess = (List<Revenue__c>)scope;
        List<String> userOrGroupIds;
        boolean isSfAdminOwner = false;
        String groupId;
        List<Revenue__Share> sharesToCreate = new List<Revenue__Share>();

        for (Revenue__c rev: revenuesToProcess) {
            userOrGroupIds = new List<String>();
            groupId = groupNameToIdMap.get(rev.Group__c);
            if (null == groupId) {
                System.debug(LoggingLevel.ERROR, 'Did not find group id for name ' + rev.Group__c + '. Continuing with null as group id value');
                groupId = null;
            }
            
            if (null != groupId ) {
                for (Revenue__Share s: rev.getSObjects('Shares')) {
                    userOrGroupIds.add(s.UserOrGroupId);
                }
                //is the share missing?
                if (!userOrGroupIds.contains(groupId)) {
                    //create the revenueshare
                    Revenue__Share s = new Revenue__Share();
                    s.ParentId = rev.Id;
                    s.UserOrGroupId = groupId;
                    s.AccessLevel = 'Read';
                    sharesToCreate.add(s);
                }
            }
        }
        //do the update here.
        Database.SaveResult[] results;
        
        Map<Integer, String> errorMap = new Map<Integer, String>();
        boolean hasErrors = false;
        if (sharesToCreate.size() > 0) {
            System.debug('Number of missing revenue shares to create = ' + sharesToCreate.size());
            results = Database.insert(sharesToCreate, false);
            errorMap = RevenueRankUtility.logErrors(results, null, null, jobName, '');
            integer recordsProcessed = sharesToCreate.size();
            recordsProcessed = recordsProcessed - errorMap.keySet().size();
            sharesInserted += recordsProcessed;
            //add to list
            sharesInsertErrorList.addAll(CleanRevenueGroupShareBatchUtility.populateRevenueShareErrorList(errorMap, jobName, sharesToCreate));
        } else {
            System.debug(LoggingLevel.INFO, 'No revenue shares found missing');
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug(LoggingLevel.INFO,'Nothing to implement in finish');
        Map<String, String> jobStats = RevenueRankUtility.getJobStats(BC.getJobId());
        String[] toAddresses = RevenueRankUtility.getToAddress('RevenueRankBatch', 'Error_Email_Addresses',',');
        CleanRevenueGroupShareBatchUtility.listErrorsAndNotify(sharesInsertErrorList, jobName+': Missing Share Addition',BC.getJobId(), jobStats, toAddresses);
        System.debug(LoggingLevel.INFO, 'Shares inserted ' + sharesInserted); 
    }
    
}