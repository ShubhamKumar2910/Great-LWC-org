public class RevenueRankUtility {
    private final static String CONFIG_NAME='RevenueRankBatch';
    private final static String CONFIG_PARAM_STATE = 'STATE';
    public final static String STATE_COMPLETE='Complete';
    public final static String STATE_RESETTING='Resetting Revenue & Ranks';
    public final static String STATE_POPULATING='Populating Revenue';
    public final static String STATE_CALCULATING='Ranking Revenue';
    public final static String STATE_RANKING='Ranking Revenue';
    public final static String STATE_ERROR='Error';
    
    public final static String TOTAL_PRODUCT_NAME='Total';
    private final static String keyConcatenator = '|';
    public final static String JOB_ITEMS = 'JobItems';
    public final static String JOB_ERRORS = 'JobErrors';
    private final static String JOB_ITEMS_PROCESSED = 'JobItemsProcessed';
    private final static String JOB_STATUS = 'JobStatus';
    private final static String JOB_EXTENDED_STATUS='ExtendedStatus';
    public final static String JOB_LASTPRODUCT='Product';
    
    public enum FIELDS {AMERICA_FY, AMERICA_PFY, AMERICA_CY, AMERICA_PCY,
        EUROPE_FY, EUROPE_PFY, EUROPE_CY, EUROPE_PCY,
        ASIA_FY, ASIA_PFY, ASIA_CY, ASIA_PCY,
        JAPAN_FY, JAPAN_PFY, JAPAN_CY, JAPAN_PCY,
        GLOBAL_FY, GLOBAL_PFY, GLOBAL_CY, GLOBAL_PCY}
    
    public static Map<Integer, String> logErrors(Database.SaveResult[] saveResults, Database.UpsertResult[] upsertResults, Database.DeleteResult[] deleteResults, String jobName, String modelName) {
        Map<Integer, String> errorMessageMap = new Map<Integer, String>();
        Integer counter = 0;
    	if (null != saveResults) {
	        for (Database.SaveResult sr : saveResults) {
            	if (!sr.isSuccess()) {
	                // Operation failed, so get all errors                
	                for(Database.Error err : sr.getErrors()) {
	                    String errorMessage = generateErrorMessage(err, jobName, modelName);
	                    errorMessageMap.put(counter, errorMessage);
	                }
            	
	            }
        	    counter = counter+1;
    	    }   
    		
    	} else if (null != upsertResults) {
	        for (Database.UpsertResult sr : upsertResults) {
            	if (!sr.isSuccess()) {
	                // Operation failed, so get all errors                
	                for(Database.Error err : sr.getErrors()) {
	                    String errorMessage = generateErrorMessage(err, jobName, modelName);
	                    errorMessageMap.put(counter, errorMessage);
	                }
            	
	            }
        	    counter = counter+1;
    	    }   
        } else {
	        for (Database.DeleteResult dr : deleteResults) {
            	if (!dr.isSuccess()) {
	                // Operation failed, so get all errors                
	                for(Database.Error err : dr.getErrors()) {
	                    String errorMessage = generateErrorMessage(err, jobName, modelName);
	                    errorMessageMap.put(counter, errorMessage);
	                }
	            }
        	    counter = counter+1;
    	    }   
        }
    	return errorMessageMap;
    }
    
    public static void populateErrorList(Map<Integer, String> errorMap, String jobName,List<Account_Revenue_Rank__c> rankList,List<String> errorList) {
        if (errorMap.size()>0) {
        	System.debug(LoggingLevel.WARN, 'Found ' + errorMap.size() +' errors trying to save revenue rank objects in '+jobName);
        	for (Integer rowNumber: errorMap.keySet()) {
        		//object not saved:
        		Account_Revenue_Rank__c rank = rankList[rowNumber];
        		String message = errorMap.get(rowNumber);
        		errorList.add('Id not updated = '+ rank.Id +'. Detail: '+ message);
        	}
        }
    }
    
    private static String generateErrorMessage(Database.Error err, String jobName, String rowName) {
        return 'Job: ' + jobName +'. Upsert failed for row '+rowName + '. Error status = ' +  err.getStatusCode() +
            ', Error message = ' + err.getMessage() + ', Error fields = ' + err.getFields();
    }
    
    public static boolean emailResults(String[] toAddresses, String subject, Id apexJobId, List<String> errorMessageList, Integer totalJobItems, Integer numberOfErrors, String jobName) {
        if ((apexJobId != null && numberOfErrors > 0 ) || errorMessageList.size() > 0) {
            Messaging.SingleEmailMessage mailObj = new Messaging.SingleEmailMessage();
            mailObj.setToAddresses(toAddresses);
            mailObj.setSubject(subject);
            String emailBody = getEmailBody(errorMessageList, apexJobId, totalJobItems, numberOfErrors,jobName);
            System.debug('Email body ' +emailBody);
            mailObj.setHtmlBody(emailBody);
            boolean returnValue = false;
            Messaging.SendEmailResult [] emailResults= Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mailObj}); 
            if(emailResults != null && emailResults.size() > 0 && emailResults[0].success){
                System.debug('The email was sent successfully to ' + toAddresses);
                returnValue = true;
            }
            System.debug(returnValue ? 'Sent error notification': 'Failed to send Email');
            return returnValue;
        } else {
        	System.debug('No errors to email for job Id '+ apexJobId);
        	return false;
        }
    }
    
    private static String getEmailBody(List<String> errorMessageList, String apexJobId, Integer totalJobItems, Integer numberOfErrors, String jobName) {
        String emailBody = null;
        if (null == apexJobId) {
	        emailBody = '<p> The Batch Apex Job ('+ jobName +') processed '
                + totalJobItems + ' batche(s) with ' + numberOfErrors + ' failure(s). </p>';
    		    	
        } else {
	        emailBody = '<p> The Batch Apex Job (' + apexJobId.substring(0,15) + ') processed '
                    + totalJobItems + ' batche(s) with ' + numberOfErrors + ' failure(s). </p>';
        }
        emailBody = emailBody + '<p> Failed for below records : </p><br>';
        
        for (String errorMessage: errorMessageList) {
             emailBody = emailBody + '<br>' + errorMessage;
        }
        return emailBody;
    }   
    
	public static String[] getToAddress(String configName, String paramName, String delimiter) {
		Configuration__c[] toAddress = [SELECT Parameter_Value__c from Configuration__c where Param_Name__c=:paramName and Name=:configName LIMIT 1];
		String[] toAddresses = new String[]{};
		if (null != toAddress && toAddress.size()>0) {
			Configuration__c c = toAddress[0];
			toAddresses = c.Parameter_Value__c.split(delimiter);    			
		} else {
			System.debug('Email not found for config '+ configName +' and parameter name ' + paramName+'.  Using sfadmin');
			User sfadmin = [SELECT id, email from User where alias='sfadmin' LIMIT 1];
			toAddresses.add(sfadmin.email);
		}
		return toAddresses;
	}
	
    public static Double getRevenue(Account_Revenue_Rank__c rank, FIELDS sortField) {
        Double amount;
        if (sortField == FIELDS.AMERICA_FY) {
            amount = rank.Current_FY_US_Net_Revenue__c;
        } else if (sortField == FIELDS.AMERICA_PFY) {
            amount = rank.Previous_FY_US_Net_Revenue__c;
        } else if (sortField == FIELDS.AMERICA_CY) {
            amount = rank.Current_CY_US_Net_Revenue__c;
        } else if (sortField == FIELDS.AMERICA_PCY) {
            amount = rank.Previous_CY_US_Net_Revenue__c;
        } else if (sortField == FIELDS.EUROPE_FY) {
            amount = rank.Current_FY_Europe_Net_Revenue__c;
        } else if (sortField == FIELDS.EUROPE_PFY) {
            amount = rank.Previous_FY_Europe_Net_Revenue__c;
        } else if (sortField == FIELDS.EUROPE_CY) {
            amount = rank.Current_CY_Europe_Net_Revenue__c;
        } else if (sortField == FIELDS.EUROPE_PCY) {
            amount = rank.Previous_CY_Europe_Net_Revenue__c;
        } else if (sortField == FIELDS.ASIA_FY) {
            amount = rank.Current_FY_AsiaEx_Net_Revenue__c;
        } else if (sortField == FIELDS.ASIA_PFY) {
            amount = rank.Previous_FY_AsiaEx_Net_Revenue__c;
        } else if (sortField == FIELDS.ASIA_CY) {
            amount = rank.Current_CY_AsiaEx_Net_Revenue__c;
        } else if (sortField == FIELDS.ASIA_PCY) {
            amount = rank.Previous_CY_AsiaEx_Net_Revenue__c;
        }  else if (sortField == FIELDS.JAPAN_FY) {
            amount = rank.Current_FY_Japan_Net_Revenue__c;
        } else if (sortField == FIELDS.JAPAN_PFY) {
            amount = rank.Previous_FY_Japan_Net_Revenue__c;
        } else if (sortField == FIELDS.JAPAN_CY) {
            amount = rank.Current_CY_Japan_Net_Revenue__c;
        } else if (sortField == FIELDS.JAPAN_PCY) {
            amount = rank.Previous_CY_Japan_Net_Revenue__c;
        } else if (sortField == FIELDS.GLOBAL_FY) {
            amount = rank.Current_FY_Global_Net_Revenue__c;
        } else if (sortField == FIELDS.GLOBAL_PFY) {
            amount = rank.Previous_FY_Global_Net_Revenue__c;
        } else if (sortField == FIELDS.GLOBAL_CY) {
            amount = rank.Current_CY_Global_Net_Revenue__c;
        } else {
            amount = rank.Previous_CY_Global_Net_Revenue__c;
        }
        return amount;
    }
    
	public static Integer getCurrentAccountRevenueRankVersion() {
        String val = getRevenueRankParamValue('Version', '0');
        val = val.trim();
        return Integer.valueOf(val);
	}
	
	public static void updateCurrentAccountRevenueRankVersion(Integer version) {
		System.debug('>>> updateCurrentAccountRevenueRankVersion . version: '+version);
        String paramName = 'Version';
        updateCurrentAccountRevenueParamValue(paramName, String.valueOf(version));
	}
    public static void setResettingState() {
        setProcessState(STATE_RESETTING);
    }
    public static void setPopulatingState() {
        setProcessState(STATE_POPULATING);
    }
    public static void setCompleteState() {
        setProcessState(STATE_COMPLETE);
    }
    
    public static void setRankingState() {
        setProcessState(STATE_RANKING);
    }
    public static void setRankProgress(Integer totalGroupsToProcess) {
        setProcessState(totalGroupsToProcess.format() +' groups left to rank');
    }
    public static void setErrorState() {
        setProcessState(STATE_ERROR);
    }
    
    private static void setProcessState(String state) {
        String priorState = getRevenueRankParamValue(CONFIG_PARAM_STATE,STATE_COMPLETE);
        System.debug('Prior process state = ' + priorState +', new state: '+state);
        updateCurrentAccountRevenueParamValue(CONFIG_PARAM_STATE, state);
    }
    
    private static String getRevenueRankParamValue(String paramName, String createValueOnNull) {
        String val = null;
        Configuration__c[] versions = [SELECT Parameter_Value__c from Configuration__c where Param_Name__c=:paramName and Name=:CONFIG_NAME LIMIT 1];
		if (null == versions || versions.size() == 0) {
            if (null != createValueOnNull) {
                System.debug('Result not found, creating new configuration with value of 0');
                Configuration__c newVersion = new Configuration__c();
                newVersion.Parameter_Value__c = createValueOnNull;
                newVersion.Param_Name__c = paramName;
                newVersion.Name = CONFIG_NAME;
                Database.insert(newVersion, true);
                val = createValueOnNull;
            }
        } else {
            Configuration__c config = versions[0];
            val = config.Parameter_Value__c;
            if (null == val) {
                System.debug(LoggingLevel.WARN, 'Config value was null.  Update it with value of '+createValueOnNull);
				config.Parameter_Value__c = createValueOnNull;
				Database.update(config, true);
                val = config.Parameter_Value__c;
			}
        }
        return val;
    }
	
	private static void updateCurrentAccountRevenueParamValue(String paramName, String paramValue) {
		Configuration__c[] configs = [SELECT Parameter_Value__c from Configuration__c where Param_Name__c=:paramName and Name=:CONFIG_NAME LIMIT 1];
		if (null == configs || configs.size() == 0) {
			System.debug('Configuration not found, creating new entry');
			Configuration__c newVersion = new Configuration__c();
			newVersion.Parameter_Value__c = paramValue;
			newVersion.Param_Name__c = paramName;
			newVersion.Name = CONFIG_NAME;
			Database.insert(newVersion, true);
		} else {
			System.debug('updating current configuration with paramValue of '+ paramValue + ' for paramName of '+ paramName);
			Configuration__c config = configs[0];
			config.Parameter_Value__c = paramValue;
			Database.update(config, true);
		}
	}

    public static void resetAccountRevenueRank(Account_Revenue_Rank__c rr) {
    	rr.Current_CY_AsiaEx_Net_Revenue__c = 0;
    	rr.Current_CY_AsiaEx_Rank__c = null;
    	rr.Current_CY_Europe_Net_Revenue__c = 0;
    	rr.Current_CY_Europe_Rank__c = null;
    	rr.Current_CY_Global_Net_Revenue__c = 0;
    	rr.Current_CY_Global_Rank__c = null;
    	rr.Current_CY_Japan_Net_Revenue__c = 0;
    	rr.Current_CY_Japan_Rank__c = null;
    	rr.Current_CY_US_Net_Revenue__c = 0;
    	rr.Current_CY_US_Rank__c = null;
        	
    	rr.Current_FY_AsiaEx_Net_Revenue__c = 0;
    	rr.Current_FY_AsiaEx_Rank__c = null;
    	rr.Current_FY_Europe_Net_Revenue__c = 0;
    	rr.Current_FY_Europe_Rank__c = null;
    	rr.Current_FY_Global_Net_Revenue__c = 0;
    	rr.Current_FY_Global_Rank__c = null;
    	rr.Current_FY_Japan_Net_Revenue__c = 0;
    	rr.Current_FY_Japan_Rank__c = null;
    	rr.Current_FY_US_Net_Revenue__c = 0;
    	rr.Current_FY_US_Rank__c = null;

    	rr.Previous_CY_AsiaEx_Net_Revenue__c = 0;
    	rr.Previous_CY_AsiaEx_Rank__c = null;
    	rr.Previous_CY_Europe_Net_Revenue__c = 0;
    	rr.Previous_CY_Europe_Rank__c = null;
    	rr.Previous_CY_Global_Net_Revenue__c = 0;
    	rr.Previous_CY_Global_Rank__c = null;
    	rr.Previous_CY_Japan_Net_Revenue__c = 0;
    	rr.Previous_CY_Japan_Rank__c = null;
    	rr.Previous_CY_US_Net_Revenue__c = 0;
    	rr.Previous_CY_US_Rank__c = null;
        	
    	rr.Previous_FY_AsiaEx_Net_Revenue__c = 0;
    	rr.Previous_FY_AsiaEx_Rank__c = null;
    	rr.Previous_FY_Europe_Net_Revenue__c = 0;
    	rr.Previous_FY_Europe_Rank__c = null;
    	rr.Previous_FY_Global_Net_Revenue__c = 0;
    	rr.Previous_FY_Global_Rank__c = null;
    	rr.Previous_FY_Japan_Net_Revenue__c = 0;
    	rr.Previous_FY_Japan_Rank__c = null;
    	rr.Previous_FY_US_Net_Revenue__c = 0;
    	rr.Previous_FY_US_Rank__c = null;
	}
	
	public static void logExecuteMethod(String callingClass, Id jobId, Integer batchSize) {
        Map<String, String> jobStats = getJobStats(jobId) ;
        System.debug('Executing ' + callingClass +' job with id ' + jobId +
         	'. Total Job Items= '+ jobStats.get(JOB_ITEMS) +
             '.  Total items processed= ' + jobStats.get(JOB_ITEMS_PROCESSED) +
             '. Status = '+ jobStats.get(JOB_STATUS) + '. Current batch size: '+ batchSize);
	}
	
    public static String getAccountProductKey(Id account, String product) {
		return account+keyConcatenator+product;
	}
    
    public static void updateRank(Account_Revenue_Rank__c rank, FIELDS field, Integer ordinal) {
        if (field == FIELDS.AMERICA_FY) {
            rank.Current_FY_US_Rank__c = ordinal;
        } else if (field == FIELDS.AMERICA_PFY) {
            rank.Previous_FY_US_Rank__c = ordinal;
        } else if (field == FIELDS.AMERICA_CY) {
            rank.Current_CY_US_Rank__c = ordinal;
        } else if (field == FIELDS.AMERICA_PCY) {
            rank.Previous_CY_US_Rank__c = ordinal;
        } else if (field == FIELDS.EUROPE_FY) {
            rank.Current_FY_Europe_Rank__c = ordinal;
        } else if (field == FIELDS.EUROPE_PFY) {
            rank.Previous_FY_Europe_Rank__c = ordinal;
        } else if (field == FIELDS.EUROPE_CY) {
            rank.Current_CY_Europe_Rank__c = ordinal;
        } else if (field == FIELDS.EUROPE_PCY) {
            rank.Previous_CY_Europe_Rank__c = ordinal;
        } else if (field == FIELDS.ASIA_FY) {
            rank.Current_FY_AsiaEx_Rank__c = ordinal;
        } else if (field == FIELDS.ASIA_PFY) {
            rank.Previous_FY_AsiaEx_Rank__c = ordinal;
        } else if (field == FIELDS.ASIA_CY) {
            rank.Current_CY_AsiaEx_Rank__c = ordinal;
        } else if (field == FIELDS.ASIA_PCY) {
            rank.Previous_CY_AsiaEx_Rank__c = ordinal;
        }  else if (field == FIELDS.JAPAN_FY) {
            rank.Current_FY_Japan_Rank__c = ordinal;
        } else if (field == FIELDS.JAPAN_PFY) {
            rank.Previous_FY_Japan_Rank__c = ordinal;
        } else if (field == FIELDS.JAPAN_CY) {
            rank.Current_CY_Japan_Rank__c = ordinal;
        } else if (field == FIELDS.JAPAN_PCY) {
            rank.Previous_CY_Japan_Rank__c = ordinal;
        } else if (field == FIELDS.GLOBAL_FY) {
            rank.Current_FY_Global_Rank__c = ordinal;
        } else if (field == FIELDS.GLOBAL_PFY) {
            rank.Previous_FY_Global_Rank__c = ordinal;
        } else if (field == FIELDS.GLOBAL_CY) {
            rank.Current_CY_Global_Rank__c = ordinal;
        } else {
            rank.Previous_CY_Global_Rank__c = ordinal;
        }
    }
    
    public static Boolean mapErrorsAndNotify(Map<Integer, String> errorMap, String jobName,List<Account_Revenue_Rank__c> allRanksByProduct, Integer totalJobItems, Integer numberOfErrors, Id jobId) {
        Boolean returnValue = false;
        if (errorMap.size()>0) {
            System.debug(LoggingLevel.WARN, 'Found ' + errorMap.size() +' errors trying to save revenue rank objects in '+jobName);
            List<String> errorList = new List<String>();
        	for (Integer rowNumber: errorMap.keySet()) {
        		//object not saved:
        		Account_Revenue_Rank__c rank = allRanksByProduct[rowNumber];
        		String message = errorMap.get(rowNumber);
        		errorList.add('Id not updated = '+ rank.Id +'. Detail: '+ message);
        	}
    		String[] toAddresses = getToAddress('RevenueRankBatch', 'Error_Email_Addresses',',');
            emailResults(toAddresses, 'Red: Salesforce Batch failure - ' + jobName, jobId, errorList,totalJobItems, numberOfErrors,jobName);    			
            returnValue = true;
        }
        return  returnValue;
    }

    public static Boolean listErrorsAndNotify(List<String> errorList, String jobName, Id jobId, Map<String, String> jobStats) {
        Integer total = Integer.valueOf(jobStats.get(JOB_ITEMS));
        Integer errCount = Integer.valueOf(jobStats.get(JOB_ERRORS));

        Boolean returnValue = false;
        if (errorList.size()==0 && errCount>0) {
            String message = jobStats.get(JOB_EXTENDED_STATUS);
            if (null == message) {
                message = '';
            }
            if (jobStats.containsKey(JOB_LASTPRODUCT)) {
                message += '. ';
                message += jobStats.get(JOB_LASTPRODUCT);
            }
            errorList.add(message);
        }
        if (errorList.size()>0) {
            returnValue = true;
            System.debug(LoggingLevel.WARN, 'Found ' + errorList.size() +' errors trying to save revenue rank objects in '+jobName);
            Id orgId = UserInfo.getOrganizationId();
            String orgName = UserInfo.getOrganizationName();
    		String[] toAddresses = getToAddress('RevenueRankBatch', 'Error_Email_Addresses',',');
            emailResults(toAddresses, 'Red: Salesforce Batch failure - ' + jobName +'. Organization Name (id) '+ orgName + ' (' + orgId + ')', jobId, errorList,total, errCount,jobName);    			
        }
        return  returnValue;
    }
    
    public static Map<String, String> getJobStats(Id jobId) {
        Map<String, String> returnValue = new Map<String, String>();
        returnValue.put(JOB_ITEMS, '0');
        returnValue.put(JOB_ERRORS, '0');
        returnValue.put(JOB_ITEMS_PROCESSED, '0');
        returnValue.put(JOB_STATUS, '');
        returnValue.put(JOB_EXTENDED_STATUS,'');
        try {
            AsyncApexJob apexJob = [SELECT Id, TotalJobItems, NumberOfErrors, JobItemsProcessed, Status,ExtendedStatus FROM AsyncApexJob WHERE JobType = 'BatchApex' AND Id = :jobId];
            returnValue.put(JOB_ITEMS, apexJob.TotalJobItems.format());
        	returnValue.put(JOB_ERRORS, apexJob.NumberOfErrors.format());
            returnValue.put(JOB_ITEMS_PROCESSED, apexJob.JobItemsProcessed.format());
            returnValue.put(JOB_STATUS, apexJob.Status);
            returnValue.put(JOB_EXTENDED_STATUS, apexJob.ExtendedStatus);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error querying apex job with id: ' + jobId +'. Message: '+e.getMessage());
        }
        return returnValue;
		
    }
}