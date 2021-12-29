public without sharing class ContactListExtension {

    /* 
     * We have created this class because if user (A) has shared ContactList with other user (B) as Read/Write
     * And If that user (B) add contacts (on which user(A) do not have access) to that shared list
     * Then User (A) will not able able to see all the details of those contacts
	
	*/
    
    /**
	* @Description: This method fetches the campaign members for given query 
	* @Param: String query
	* @Return: List<CampaignMember>
	* */
    public static List<CampaignMember> getCampaignMembers(String query){
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        
        if(String.isNotEmpty(query)){
            campaignMemberList = (List<CampaignMember>)Database.query(query);
        }
        
        return campaignMemberList;
    }
    
    /**
	* @Description: This method fetches the campaign members for given Campaign Id and with limit criteria 
	* @Param: String campaignId, Integer limitCriteria
	* @Return: List<CampaignMember>
	* */
    public static List<CampaignMember> getCampaignMembersForCampaign(String campaignId, String filterCondition, Integer limitCriteria){
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        
        if(String.isNotEmpty(campaignId) && limitCriteria != 0){
            String query = 'SELECT Id, ContactId, CampaignId FROM CampaignMember WHERE CampaignId = :campaignId AND Contact.Active__c = true ';
            
            
            if(String.isNotEmpty(filterCondition))
                query = query + ' AND ' + filterCondition;
            
            query  = query + ' LIMIT :limitCriteria';
            campaignMemberList = (List<CampaignMember>)Database.query(query);
        }
        
        return campaignMemberList;
    }

    /**
	* @Description: This method fetches the Event Relation List  for the given set of contacts
	* @Param: Set<Id> contactIdSet
	* @Return: List<EventRelation>
	* */
    public static List<EventRelation> getEventRelationList(Set<Id> contactIdSet){
        List<EventRelation> eventRelationList = new List<EventRelation>();
        
        if(contactIdSet != null && contactIdSet.size() > 0){
            //Activities by LoggedIn user
            eventRelationList = [
                				 SELECT Id, RelationId, 
                                 Event.Id, Event.ActivityDateTime, Event.Type
                                 FROM EventRelation
                                 WHERE RelationId IN :contactIdSet AND 
                                 Event.OwnerId = :UserInfo.getUserId() AND
                                 Event.IsChild = FALSE AND
                                 Event.RecordType.DeveloperName = 'Standard_Event' AND
                                 Event.ActivityDateTime <> null AND
                                 Event.ActivityDateTime = LAST_N_DAYS:30
                                 ORDER BY RelationId, Event.ActivityDateTime
                                ];

        }
        
        return eventRelationList;
    }
    
    /**
	* @Description: This method fetches the group which is related to Logged In User's Role
	* @Return: String
	* */
    public static String getGroupIdRelatedToUserRole(){
        String groupId = null;
        
        List<Group> groupList = [SELECT Id FROM Group WHERE Type = 'Role' AND RelatedId =: UserInfo.getUserRoleId()];
        
        if(groupList != null && groupList.size() == 1){
            groupId = (groupList.get(0) != null) ? groupList.get(0).Id : null;
        }
        
        return groupId;
    }
    
    /**
	* @Description: This method returns campaign members count for given Campaign Id and filter criteria
	* @Param: String campaignId, String filterCondition
	* @Return: Integer
	* */
    public static Integer getCampaignMemberCount(String campaignId, String filters, String device){
        Integer campaignMemberCount = 0;
        Set<Id> contactIdSet = new Set<Id>();
        String strQuery = '';
        
        ContactListFilter contactListFilter  = (ContactListFilter) JSON.deserialize(filters, ContactListFilter.class);
        String filterCondition = CommonTools.createFilterCondition(filters, device);
        
        if(contactListFilter == null || (contactListFilter != null && contactListFilter.showNonCoveredContacts == false)){
        	strQuery = 'SELECT Count() FROM CampaignMember WHERE Contact.Active__c = true AND Campaign.Id = \'' + campaignId + '\'';
        	if(String.isNotEmpty(filterCondition))
            	strQuery = strQuery + ' AND ' + filterCondition;
            
            campaignMemberCount = Database.countQuery(strQuery);
        }
        else {
            strQuery = 'SELECT ContactId FROM CampaignMember WHERE Contact.Active__c = true AND Campaign.Id = \'' + campaignId + '\'';
        	if(String.isNotEmpty(filterCondition))
            	strQuery = strQuery + ' AND ' + filterCondition;
            
            List<CampaignMember> campaignMemberList = (List<CampaignMember>)Database.query(strQuery);
            
            for(CampaignMember campaignMemberObj : campaignMemberList){
                contactIdSet.add(campaignMemberObj.ContactId);
            }
            
            //We have to split list into multiple lists (each with size of 200). 
            //Because for querying UserRecordAccess, we cannot provide more than 200 record Ids
            Map<Integer,List<Id>> contactIdMap = getContactIdLists(contactIdSet);
            
            for(Integer i : contactIdMap.keySet()){
                List<Id> contactIdInnerList = contactIdMap.get(i);
                
                List<UserRecordAccess> contactAccessList = [SELECT RecordId, HasEditAccess
                                                           	   FROM UserRecordAccess
                                                           	   WHERE UserId = :UserInfo.getUserId() AND RecordId IN :contactIdInnerList];
            
            	for(UserRecordAccess recordAccess : contactAccessList){
                    if(recordAccess.HasEditAccess == false){
                        campaignMemberCount = campaignMemberCount + 1;
                    }
                }
                
            }
            
        }
        
        return campaignMemberCount;
    }
    
    
    
    /**
	* @Description: This method fetches EditAccess for each contact record for logged in user
	* @Param: contactIdSet
	* @Return: Map<Id,Boolean> 
	* */
    public static Map<Id,Boolean> getContactEditAccessDetails(Set<Id> contactIdSet){
    	Map<Id,Boolean> contactEditAccessMap = new Map<Id,Boolean>();
       
        
        if(contactIdSet != null && contactIdSet.size() > 0){
            
            //We have to split list into multiple lists (each with size of 200). 
            //Because for querying UserRecordAccess, we cannot provide more than 200 record Ids
            Map<Integer,List<Id>> contactIdMap = getContactIdLists(contactIdSet);
            
            for(Integer i : contactIdMap.keySet()){
                List<Id> contactIdInnerList = contactIdMap.get(i);
                
                List<UserRecordAccess> userRecordAccessList = [SELECT RecordId, HasEditAccess, MaxAccessLevel
                                                           FROM UserRecordAccess
                                                           WHERE UserId = :UserInfo.getUserId() AND
                                                          	RecordId IN :contactIdInnerList];
            
            	if(userRecordAccessList != null && userRecordAccessList.size() > 0){
                    for(UserRecordAccess recordAccessObj : userRecordAccessList){
                        contactEditAccessMap.put(recordAccessObj.RecordId, recordAccessObj.HasEditAccess);
                    }
            	}
                
            }
        }
        
        return contactEditAccessMap;
    }
    
    public static Map<Integer,List<Id>> getContactIdLists(Set<Id> contactIdSet){
        
        Integer batchSize = 200;
        Map<Integer,List<Id>> contactIdMap = new Map<Integer,List<Id>>();
        List<Id> contactIdInputList = new List<Id>();
        
        if(contactIdSet != null && contactIdSet.size() > 0){
            
            contactIdInputList.addAll(contactIdSet);
            
            for(Integer outerLoop = 0; outerLoop < (contactIdInputList.size()/batchSize) + 1; outerLoop++){
                List<Id> contactIdList = new List<Id>();
                
                for(Integer innerLoop = (outerLoop*batchSize); innerLoop < (outerLoop*batchSize)+batchSize && innerLoop < contactIdInputList.size() ; innerLoop++){
                    contactIdList.add(contactIdInputList.get(innerLoop));
                }
                
                contactIdMap.put(outerLoop,contactIdList);
                
            }
        }
        
        return contactIdMap;
    }
    
    /**
	* @Description: This method removes campaign members for given Campaign Id or for selected campaign members. It returns the list of Ids which got failed
	* @Param: Boolean completeListSelected, String selectedCampaignId, List<String> selectedContacts, String filterCondition
	* @Return: List<Id> 
	* */
    public static List<Id> removeCampaignMembers(Boolean completeListSelected, String selectedCampaignId, List<String> selectedContacts, String filters){
        List<Id> failedRecordsIdList = new List<Id>();
        List<String> memberToBeDeletedList = new List<String>();
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        boolean result = true;
        String device = 'DESKTOP';
        
        ContactListFilter contactListFilter  = (ContactListFilter) JSON.deserialize(filters, ContactListFilter.class);   
        String filterCondition = CommonTools.createFilterCondition(filters, device);
        
        if(String.isNotEmpty(selectedCampaignId)){
            //If SelectAll is selected then fetch all Campaign Members of selected Campaign Id and Non Covered Contacts is not selected
            if(completeListSelected && 
               (contactListFilter == null || (contactListFilter != null && !contactListFilter.showNonCoveredContacts))){
                String query = 'SELECT Id, ContactId FROM CampaignMember WHERE CampaignId = :selectedCampaignId ';
                
                if(String.isNotEmpty(filterCondition))
                	query = query + ' AND ' + filterCondition;
                
                campaignMemberList = (List<CampaignMember>)Database.query(query);
            }
            else {
                campaignMemberList = [SELECT Id, ContactId FROM CampaignMember
                                      WHERE CampaignId = :selectedCampaignId AND 
                                            ContactId IN :selectedContacts];
            }
            
            if(campaignMemberList != null && campaignMemberList.size() > 0){
                List<Database.DeleteResult> resultList = Database.delete(campaignMemberList, false);
                for(Integer i=0; i<resultList.size(); i++){            
                    Database.DeleteResult resultObj = resultList.get(i);
                    if(!resultObj.isSuccess()){ 
                        for(Database.Error errorObj : resultObj.getErrors()){
                            if(String.isNotEmpty(errorObj.getMessage()) &&
                               errorObj.getMessage().contains('insufficient access rights on object id')
                              ){
                                result = false;
                                failedRecordsIdList.add(campaignMemberList.get(i).ContactId);
                            }
                        }
                    }
                }
            }
        }
        
        return failedRecordsIdList;
        
    }
    
    /**
	* @Description: This method deletes campaign. It returns Boolean flag indicating whether delete was successful or not
	* @Param: String campaignId
	* @Return: Boolean
	* */
    public static Boolean deleteCampaign(String campaignId){
        Boolean deleteSuccessful = false;
        
        if(String.isNotEmpty(campaignId)){
        	Database.DeleteResult resultObj = Database.delete(campaignId, false);
            if(resultObj != null && !resultObj.isSuccess()){
                for(Database.Error errorObj : resultObj.getErrors()){
                    if(String.isNotEmpty(errorObj.getMessage())){
                        System.debug('Delete Failed:'+errorObj.getMessage());  
                    }
                }
            }
            else if(resultObj != null && resultObj.isSuccess()){
                deleteSuccessful = true;
            }
        }

        return deleteSuccessful;
    }
    
    
}