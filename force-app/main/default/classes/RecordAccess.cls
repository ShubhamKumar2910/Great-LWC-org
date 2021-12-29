public without sharing class RecordAccess {
    public RecordAccess() {

    }

     /**
	* @Description: This method fetches EditAccess for each record for logged in user
	* @Param: recordIdSet
    * @Param: recordsWithEditAccessOnlyRequired
	* @Return: Set<Id>
	* */
    public static Set<Id> getRecordEditAccessDetails(Set<Id> recordIdSet, Boolean recordsWithEditAccessOnlyRequired){
    	Map<Id,Boolean> recordEditAccessMap = new Map<Id,Boolean>();
        Set<Id> recordIdWithEditAccess = new Set<Id>();
        Integer batchSize = 200;
        
        if(recordIdSet != null && recordIdSet.size() > 0){
            
            //We have to split list into multiple lists (each with size of 200). 
            //Because for querying UserRecordAccess, we cannot provide more than 200 record Ids
            Map<Integer,List<Id>> recordIdMap = CommonTools.getRecordIdSubsetLists(recordIdSet, batchSize);
            System.debug('recordIdMap: '+recordIdMap);
            for(Integer i : recordIdMap.keySet()){
                List<Id> recordIdInnerList = recordIdMap.get(i);

                //We cannot perform filter on HasEditAccess
                List<UserRecordAccess> userRecordAccessList = [SELECT RecordId, HasEditAccess, MaxAccessLevel
                                                           FROM UserRecordAccess
                                                           WHERE UserId = :UserInfo.getUserId() AND
                                                            RecordId IN :recordIdInnerList];
            
            	if(userRecordAccessList != null && userRecordAccessList.size() > 0){
                    for(UserRecordAccess recordAccessObj : userRecordAccessList){
                        recordEditAccessMap.put(recordAccessObj.RecordId, recordAccessObj.HasEditAccess);
                    }

                    for(Id recordId : recordEditAccessMap.keySet()){
                        if(!recordsWithEditAccessOnlyRequired || (recordsWithEditAccessOnlyRequired && recordEditAccessMap.get(recordId))){
                            recordIdWithEditAccess.add(recordId);
                        } 
                    }
            	}
                
            }
        }
        return recordIdWithEditAccess;
    }
}