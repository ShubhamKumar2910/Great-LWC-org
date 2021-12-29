public class AnalyticsUserDefaultHelper {
    public final static String defaultCurrency = 'USD';
    public final static String defaultAccounting = 'Gross';
    public final static String defaultDashboard= 'My_Scorecard';
    public final static String defaultClientScorecardConfig = 'Default';
    public final static String defaultAPACEQSalesClientScorecardConfig = 'JapanEqSales';
    public final static String defaultGroupRegionalDB = 'Desk__c';
    public final static String configurationName = 'PopulateAnalyticUserDefaultBatch';
    public final static String defaultClientScorecard = 'Client_Scorecard';
    public final static String parameterName = 'LAST_RUN_TIME';
    
    public static Analytics_User_Default__c getDefaultValuesFromUser (String roleName, String regionName) {
        User u = new User();
        UserRole ur = new UserRole();
        ur.Name = roleName;
        u.UserRole = ur;
        u.Region__c = regionName;
        return getDefaultValuesFromUser(u);
    }
    public static Analytics_User_Default__c getDefaultValuesFromUser(User u) {
        String roleName = null;
        String region = null;
        if (null != u) {
            if (null != u.UserRole) {
                roleName = u.UserRole.Name;
            }
            region = u.Region__c;
        }
        Analytics_User_Default__c defaultValue = new Analytics_User_Default__c();
        defaultValue.Accounting_Filter__c = defaultAccounting;
        defaultValue.Currency_Filter__c = defaultCurrency;
        defaultValue.Default_Revenue_Dashboard__c = defaultDashboard;
        defaultValue.ClientScorecardConfig__c = defaultClientScorecardConfig;
        defaultValue.Default_Client_Scorecard__c = defaultClientScorecard;
        String defaultGroup = defaultGroupRegionalDB;
        defaultValue.Regional_Client_Scorecard_Rev_2_Group__c = defaultGroup;
        boolean isJapanRegion = false;
        boolean isApacRegion = false;
        if (null != region && region.equals('Japan')) {
            isJapanRegion = true;
            isApacRegion = true;
            defaultValue.Currency_Filter__c = 'Yen';
        } else if (null != region && region.equals('AEJ')) {
            isApacRegion = true;
        }
        if (null != roleName) {
            String defDb = defaultDashboard;
            boolean isFlowDerivatives = false;
            if (roleName.contains('Flow Derivatives') || roleName.contains('DERIVS FLOW SALES')) {
                isFlowDerivatives = true;
            }
            if (roleName.containsIgnoreCase('- EQ -') || roleName.containsIgnoreCase('- EQ Sales -')) {
                if (isApacRegion) {
                    defaultGroup = 'GRR_Region__c';
                    defaultValue.ClientScorecardConfig__c = defaultAPACEQSalesClientScorecardConfig;
                }
                if (!isFlowDerivatives) {
	                defaultValue.Accounting_Filter__c = 'Net';
    	            defDb = 'Covered_Client_Scorecard';
                } else  {
                    defDb = 'Team_Scorecard';
                }
            } else {
                if (!roleName.containsIgnoreCase('FI - Sales')) {
                    defDb = 'Team_Scorecard';
                }
            }
            defaultValue.Default_Revenue_Dashboard__c = defDb;
            defaultValue.Regional_Client_Scorecard_Rev_2_Group__c = defaultGroup;
        }
        
        return defaultValue;
    }
    
    public static void populateErrorList(Map<Integer, String> errorMap, String jobName,List<Analytics_User_Default__c> defaultList,List<String> errorList) {
        if (errorMap.size()>0) {
        	System.debug(LoggingLevel.WARN, 'Found ' + errorMap.size() +' errors trying to save analytic user default objects in '+jobName);
        	for (Integer rowNumber: errorMap.keySet()) {
        		//object not saved:
        		Analytics_User_Default__c d = defaultList[rowNumber];
        		String message = errorMap.get(rowNumber);
        		errorList.add('Id not updated = '+ d.Id +'. Detail: '+ message);
        	}
        }
    }
	
    public static DateTime getLastRunDate(String name, String paramName) {
        if (null == name) {
            System.debug('Using default config name of ' + configurationName);
            name = configurationName;
        }
        if (null == paramName) {
            System.debug('Using default param name of ' + paramName);
            paramName = parameterName;
        }

        DateTime runDate = null;
        Configuration__c config = getRunConfig(name, paramName);
        if (null != config) {
            String paramVal = config.Parameter_value__c;
            System.debug('Last run date pulled ' + paramVal);
			runDate = Datetime.valueOf(paramVal);
        }
        return runDate;
    }
    
    public static void saveLastRunDate(Datetime lastRun,String name, String paramName) {
        if (null == name) {
            System.debug('Using default config name of ' + AnalyticsUserDefaultHelper.configurationName);
            name = AnalyticsUserDefaultHelper.configurationName;
        }
        if (null == paramName) {
            System.debug('Using default param name of ' + AnalyticsUserDefaultHelper.parameterName);
            paramName = AnalyticsUserDefaultHelper.parameterName;
        }
        
        Configuration__c config = getRunConfig(name, paramName);
        String paramValue = String.valueOf(lastRun);
        List<Configuration__c> configs = new List<Configuration__c>();
        if (null == config) {
            config = new Configuration__c();
            config.Param_Name__c=paramName;
            config.Parameter_Value__c = paramValue;
            config.Name=name;
            System.debug('Inserting '+ name + ' config last run param of ' + paramValue +' for parameter '+ paramName);
            try {
                configs.add(config);
                Database.insert(configs);
            } catch (Exception e) {
                System.debug('Error inserting configuration object: '+ e.getMessage());
            }
        } else {
            config.Parameter_value__c = paramValue;
            
            System.debug('updating '+ name + ' config last run param of ' + paramValue +' for parameter '+ paramName);
            try {
                configs.add(config);
                Database.update(configs);
            } catch (Exception e) {
                System.debug('Error updating configuration object: '+ e.getMessage());
            }
            update config;
        }
        
    }
    
    private static Configuration__c getRunConfig(String name, String paramName) {
        System.debug('Getting run configuration for config name ' + name + ' and param '+ paramName);
        List<Configuration__c> configs = [select Parameter_value__c from Configuration__c where Name=:name and Param_Name__c=:paramName];
        System.debug('configs size = '+ configs.size());
        if (configs.size()>0) {
            return configs.get(0);
        } else {
            return null;
        }
    }
}