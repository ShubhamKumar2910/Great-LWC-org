public class CoverageRequestSharing {
	/*public static void manualShareEditForCoverageAccessRequest(Map<Id,Set<Id>> recordUserMap){
        List<Sales_Team_For_Coverage__Share> coverageAccessRequestShareList = new List<Sales_Team_For_Coverage__Share>();
        
        for(String recordId : recordUserMap.keySet()){
            Set<Id> userRecordSet = recordUserMap.get(recordId);
            if(userRecordSet != null && userRecordSet.size() > 0){
                for(String userOrGroupId : userRecordSet){
                    if(String.isNotEmpty(userOrGroupId)){
                         Sales_Team_For_Coverage__Share coverageAccessRequestShare = new Sales_Team_For_Coverage__Share();
                         coverageAccessRequestShare.ParentId = recordId;
        				 coverageAccessRequestShare.UserOrGroupId = userOrGroupId;
        				 coverageAccessRequestShare.AccessLevel = 'Edit';
        				 coverageAccessRequestShare.RowCause = Schema.Sales_Team_For_Coverage__Share.RowCause.Manual;
                         coverageAccessRequestShareList.add(coverageAccessRequestShare);
                    }
                }
            }
        }
        
        if(coverageAccessRequestShareList.size() > 0){
            saveRecord(coverageAccessRequestShareList);
        }
    }*/
    
   /* public static void manualShareEditForRGCoverageRequest(Map<Id,Set<Id>> recordUserMap){
        List<Sales_Team_For_Coverage__Share> coverageRequestForRGShareList = new List<Sales_Team_For_Coverage__Share>();
        
        for(String recordId : recordUserMap.keySet()){
            Set<Id> userRecordSet = recordUserMap.get(recordId);
            if(userRecordSet != null && userRecordSet.size() > 0){
                for(String userOrGroupId : userRecordSet){
                    if(String.isNotEmpty(userOrGroupId)){
                         Sales_Team_For_Coverage__Share coverageRequestForRGShare = new Sales_Team_For_Coverage__Share();
                         coverageRequestForRGShare.ParentId = recordId;
        				 coverageRequestForRGShare.UserOrGroupId = userOrGroupId;
        				 coverageRequestForRGShare.AccessLevel = 'Edit';
        				 coverageRequestForRGShare.RowCause = Schema.Sales_Team_For_Coverage__Share.RowCause.Manual;
                         coverageRequestForRGShareList.add(coverageRequestForRGShare);
                    }
                }
            }
            
        }
        
        if(coverageRequestForRGShareList.size() > 0){
            saveRecord(coverageRequestForRGShareList);
        }
        
    }*/
    
    public static void manualShareEditForSalesTeamForCoverage(Map<Id,Set<Id>> recordUserMap){
        List<Sales_Team_For_Coverage__Share> shareList = new List<Sales_Team_For_Coverage__Share>();
        
        for(String recordId : recordUserMap.keySet()){
            Set<Id> userRecordSet = recordUserMap.get(recordId);
            if(userRecordSet != null && userRecordSet.size() > 0){
                for(String userOrGroupId : userRecordSet){
                    if(String.isNotEmpty(userOrGroupId)){
                         Sales_Team_For_Coverage__Share salesTeamForCoverageShare = new Sales_Team_For_Coverage__Share();
                         salesTeamForCoverageShare.ParentId = recordId;
        				 salesTeamForCoverageShare.UserOrGroupId = userOrGroupId;
        				 salesTeamForCoverageShare.AccessLevel = 'Edit';
        				 salesTeamForCoverageShare.RowCause = Schema.Sales_Team_For_Coverage__Share.RowCause.Manual;
                         shareList.add(salesTeamForCoverageShare);
                    }
                }
            }
        }
        
        if(shareList.size() > 0){
            saveRecord(shareList);
        }
    }
    
    public static List<String> saveRecord(List<sObject> recordListToInsert){
        List<String> resultList = new List<String>();
        
        Database.SaveResult[] databaseResultList = Database.insert(recordListToInsert, false);
        
        for(Database.SaveResult result : databaseResultList){
            if(result.isSuccess()){
            	resultList.add('SUCCESS:'+result.getId());
            }
            else {
                Database.Error databaseError = result.getErrors()[0];
                
				/* Check if the error is related to trival access level. 
         		 * Access level must be more permissive than the object's default. 
         		 * These sharing records are not required and thus an insert exception is acceptable */
				if(databaseError.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION && 
                   databaseError.getMessage().contains('AccessLevel')){
                    resultList.add('SUCCESS');
                }
                else {
                    resultList.add('ERROR');
                }
        	}
        }
        
        return resultList;
    }
}