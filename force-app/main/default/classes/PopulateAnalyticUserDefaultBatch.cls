global class PopulateAnalyticUserDefaultBatch implements Database.Batchable<sObject>, Database.Stateful {
	String query;
    private Datetime lastRunDate;
    private boolean hasError = false;
	private static final String jobName = 'PopulateAnalyticUserDefaultBatch';
    private Set<Id> userDefaultToUpdateSet = new Set<Id>();
    private String configName;
    private String paramName;
    global PopulateAnalyticUserDefaultBatch(String configName,String paramName) {
        this.configName = configName;
        this.paramName = paramName;
        Datetime dt = AnalyticsUserDefaultHelper.getLastRunDate(configName, paramName);
        lastRunDate = dt;
        query = 'select id, Region__c, UserRole.Name from user where isactive=True and Region__c!=null and UserRoleId != null';
        if (null != dt) {
            String dateString = dt.format('yyyy-MM-dd\'T\'hh:mm:ss\'z\'');
            query = 'select id, Region__c, UserRole.Name from user where isactive=True and Region__c!=null and UserRoleId != null and LastModifiedDate >= ' + dateString;
        }
        if (Test.isRunningTest()) {
            query = query + ' LIMIT ' + 200;
        }
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
		System.debug('firing query '+query);
		return Database.getQueryLocator(query);
	}

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        System.debug('Number of users to test '+ scope.size());
        List<User> users = (List<User>) scope;
        //create user id to user map
        Map<Id, User> userIdMap = new Map<Id, User>();
        for (User u: users) {
            userIdMap.put(u.id, u);
        }
        //get the analytic user default obj -- these are the objects that have been created but still might need updating.
        List<Analytics_User_Default__c> defs = [SELECT id, Accounting_Filter__c, Currency_Filter__c, Default_Revenue_Dashboard__c,ClientScorecardConfig__c,User__c,Regional_Client_Scorecard_Rev_2_Group__c from Analytics_User_Default__c where User__c = : userIdMap.keySet()];
        List<Analytics_User_Default__c> defaultsToUpdate = new List<Analytics_User_Default__c>();
		for (Analytics_User_Default__c d: defs) {
    		//for each default object found, remove it from the userIdMap
    		User u = userIdMap.remove(d.User__c);
    		//get the default values
    		Analytics_User_Default__c defaultUserValues = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(u);
            //populate existing list if its blank
            Analytics_User_Default__c defToUpdate = setDefaultValues(d, defaultUserValues);
            //put it in the update list
            if (null != defToUpdate) {
                System.debug('found incomplete AUD user that needed to be updated. Id = ' + u.id);
                defaultsToUpdate.add(defToUpdate);
                userDefaultToUpdateSet.add(defToUpdate.id);
            }
		}
		List<Analytics_User_Default__c> defaultsToCreate = new List<Analytics_User_Default__c>();
        //the remainder in the map have to have fresh default objects
        System.debug('Number of user default objects to create = ' + userIdMap.size());
        for (User u: userIdMap.values()) {
            Analytics_User_Default__c d = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(u);
            d.User__c = u.id;
            defaultsToCreate.add(d);
        }
        Database.SaveResult[] results;
        Map<String, String> jobStats = RevenueRankUtility.getJobStats(BC.getJobId());
        List<String> errorList = new List<String>();
        Map<Integer, String> errorMap;
        boolean hasErrors = false;
        if (defaultsToCreate.size() > 0) {
            System.debug('Number of defaults to create = ' + defaultsToCreate.size());
            results = Database.insert(defaultsToCreate, false);
            errorMap = RevenueRankUtility.logErrors(results, null, null, jobName, '');
            AnalyticsUserDefaultHelper.populateErrorList(errorMap, jobName, defaultsToCreate, errorList);
            hasErrors = RevenueRankUtility.listErrorsAndNotify(errorList, jobName,BC.getJobId(), jobStats);
            System.debug('Errors generated during insert of new user defaults: ' + hasErrors);  
            if (hasErrors) {
                hasError = true;
            }
            for (Analytics_User_Default__c d: defaultsToCreate) {
                if (null != d.id) {
                    userDefaultToUpdateSet.add(d.id);
                }
            }
        }
        
        updateExistingDefaults(defaultsToUpdate, true, jobStats,BC.getJobId());
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('In finish method');
        finishUpdatingModifiedUserDefaults(BC);
        if (!hasError) {
            Datetime dt = Datetime.now();
            AnalyticsUserDefaultHelper.saveLastRunDate(dt, configName, paramName);
        } else {
            System.debug('Process ran with errors. Not updating batch process run time');
        }
    }
    
    private void finishUpdatingModifiedUserDefaults(Database.BatchableContext BC) {
        if (null != lastRunDate) {
            //if the this update has run before, lets find all aud objs that have been updated since and check for null values
            List<Analytics_User_Default__c> allModifiedDefaults = [SELECT id, Accounting_Filter__c, Currency_Filter__c, Default_Revenue_Dashboard__c,ClientScorecardConfig__c,User__c,Regional_Client_Scorecard_Rev_2_Group__c from Analytics_User_Default__c where LastModifiedDate >= : lastRunDate];
            List<Analytics_User_Default__c> testDefaultValues = new List<Analytics_User_Default__c>();
            //only test those that weren't already touched by the user object route
            for (Analytics_User_Default__c d: allModifiedDefaults) {
                if (!userDefaultToUpdateSet.contains(d.id)) {
                    testDefaultValues.add(d);
                }
            }
            //not iterate this pared back list and isolate the users for a attribute pull
            List<Id> userIds = new List<Id>();
            for (Analytics_User_Default__c d: testDefaultValues) {
                userIds.add(d.User__c);
            }
            List<User> testUsers = [select id, Region__c, UserRole.Name from user where isactive=True and Region__c!=null and UserRoleId != null and id in: userIds];
            Map<Id, User> userIdMap = new Map<Id, User>();
            for (User u: testUsers) {
                userIdMap.put(u.id, u);
            }
            List<Analytics_User_Default__c> defaultsToUpdate = new List<Analytics_User_Default__c>();
            for (Analytics_User_Default__c d: testDefaultValues) {
                User u = userIdMap.get(d.User__c);  //this will only return an active user since3 userIdMap contains only active users
                if (null != u) {
                    Analytics_User_Default__c defaultValueHolder = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(u);
                    Analytics_User_Default__c defToUpdate = setDefaultValues(d, defaultValueHolder);
                    //put it in the update list
                    if (null != defToUpdate) {
                        if (!userDefaultToUpdateSet.contains(defToUpdate.id)) {
                            defaultsToUpdate.add(defToUpdate);
                        }
                    }
                }
            }
            
            updateExistingDefaults(defaultsToUpdate, false, null, BC.getJobId());
        }
    }
    
    private static Analytics_User_Default__c setDefaultValues(Analytics_User_Default__c d, Analytics_User_Default__c defaultUserValues) {
        boolean isComplete = true;
        Analytics_User_Default__c returnValue = new Analytics_User_Default__c();
        returnValue.id = d.id;
        returnValue.Accounting_Filter__c = d.Accounting_Filter__c;
        returnValue.Currency_Filter__c = d.Currency_Filter__c;
        returnValue.Default_Revenue_Dashboard__c = d.Default_Revenue_Dashboard__c;
        if (null == returnValue.Accounting_Filter__c) {
            isComplete = false;
            returnValue.Accounting_Filter__c = defaultUserValues.Accounting_Filter__c;
        }
        if (null == returnValue.Currency_Filter__c) {
            isComplete = false;
            returnValue.Currency_Filter__c = defaultUserValues.Currency_Filter__c;
        }
        
        if (null == returnValue.Default_Revenue_Dashboard__c) {
            isComplete = false;
            returnValue.Default_Revenue_Dashboard__c = defaultUserValues.Default_Revenue_Dashboard__c;
        }
        
        if (null == returnValue.Regional_Client_Scorecard_Rev_2_Group__c) {
            isComplete = false;
            returnValue.Regional_Client_Scorecard_Rev_2_Group__c = defaultUserValues.Regional_Client_Scorecard_Rev_2_Group__c;
        }
        if (null == returnValue.ClientScorecardConfig__c) {
            isComplete = false;
            returnValue.ClientScorecardConfig__c = defaultUserValues.ClientScorecardConfig__c;
        }

        if (isComplete) 
            return null;
        else
            return returnValue;

    }
    
    private void updateExistingDefaults(List<Analytics_User_Default__c> defaultsToUpdate, boolean addToComparisonSet, Map<String, String> jobStats, Id jobId) {
        System.debug('in updateExistingDefaults with value of addToComparisonSet = ' + addToComparisonSet +'. Updating ' +defaultsToUpdate.size() + ' default entries' );
        if (defaultsToUpdate.size()>0) {
            if (null == jobStats) {
                jobStats = RevenueRankUtility.getJobStats(jobId);
            }
            System.debug('Number of defaults to update = ' + defaultsToUpdate.size());
           	Database.SaveResult[] results = Database.update(defaultsToUpdate, false);
            for (Integer x=0; x<results.size(); x++) {
                Database.SaveResult r = results[x];
                if (r.success && addToComparisonSet) {
                    userDefaultToUpdateSet.add(defaultsToUpdate.get(x).id);
                }
            }
            Map<Integer, String> errorMap = RevenueRankUtility.logErrors(results, null, null, jobName, '');
            List<String> errorList = new List<String>();
            AnalyticsUserDefaultHelper.populateErrorList(errorMap, jobName, defaultsToUpdate, errorList);
            boolean hasErrors = RevenueRankUtility.listErrorsAndNotify(errorList, jobName,jobId, jobStats);
            System.debug('Errors generated during update of new user defaults: ' + hasErrors);
            if (hasErrors) {
                hasError = true;
            }
        }
    }
}