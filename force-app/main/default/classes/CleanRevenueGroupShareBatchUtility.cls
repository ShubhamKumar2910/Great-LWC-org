public class CleanRevenueGroupShareBatchUtility {
    public static List<String> populateRevenueShareErrorList(Map<Integer, String> errorMap, String jobName,List<Revenue__Share> shareInsertList) {
        List<String> errorList = new List<String>();
        if (errorMap.size()>0) {
        	System.debug(LoggingLevel.WARN, 'Found ' + errorMap.size() +' errors trying to save revenue objects in '+jobName);
        	for (Integer rowNumber: errorMap.keySet()) {
        		//object not saved:
                Revenue__Share share = shareInsertList[rowNumber];
                String objId = share.id;
        		
        		String message = errorMap.get(rowNumber);
        		errorList.add('Id not updated = '+ objId +'. Detail: '+ message);
        	}
        }
        return errorList;
    }

    public static Boolean listErrorsAndNotify(List<String> errorList, String jobName, Id jobId, Map<String, String> jobStats, String[] toAddresses) {
        Integer total = Integer.valueOf(jobStats.get(RevenueRankUtility.JOB_ITEMS));
        Integer errCount = Integer.valueOf(jobStats.get(RevenueRankUtility.JOB_ERRORS));

        Boolean returnValue = false;
        if (errorList.size()==0 && errCount>0) {
            String message = jobStats.get('ExtendedStatus');
            if (null == message) {
                message = '';
            }
            errorList.add(message);
        }
        
        if (errorList.size()>0) {
            returnValue = true;
            System.debug(LoggingLevel.WARN, 'Found ' + errorList.size() +' errors trying to save revenue rank objects in '+jobName);
            RevenueRankUtility.emailResults(toAddresses, 'Red: Salesforce Batch failure - ' + jobName, jobId, errorList,total, errCount,jobName);    			
        }
        return  returnValue;
    }

}