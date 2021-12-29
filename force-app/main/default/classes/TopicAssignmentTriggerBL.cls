public class TopicAssignmentTriggerBL {
    /*Updates the Opportunity Topic List after deleting topic*/

    static final List<String> topicEntityTypes = new List<String>{'account', 'opportunity','Legal_Agreement'};
    
    
    public static Boolean userAllowedToDeleteTopic = true;
    

    public static void removeTopic(List<TopicAssignment> oldTopicAssignmentList){

        Set<Id> idSet = new Set<Id>();
        Set<Id> accountTopicIdList = new Set<Id>();   
        Set<Id> accountEntityIdList = new Set<Id>();     
        
        for(TopicAssignment topicAssignment : oldTopicAssignmentList)
        {
            if(topicEntityTypes.contains(topicAssignment.EntityType.toLowerCase()))
            {
                idSet.add(topicAssignment.EntityId);
            }

        }
        
        updateSobjectTopics(idSet, oldTopicAssignmentList);
                
    }
    
    /*Updates the Topic List after adding topic*/
    public static void addTopic(List<TopicAssignment> newTopicAssignmentList){

        Set<Id> idSet = new Set<Id>();

        Set<Id> accountTopicIdList = new Set<Id>();
        Set<Id> accountEntityIdList = new Set<Id>();   

        for(TopicAssignment topicAssignment : newTopicAssignmentList)
        {
            if(topicEntityTypes.contains(topicAssignment.EntityType.toLowerCase()))
            {
                idSet.add(topicAssignment.EntityId);
            }

            //System.debug('--topicAssignment.EntityType-' + topicAssignment.EntityType);
            //System.debug('--topicAssignment.-' + topicAssignment);
            
        }
        //System.debug('--idSet--' + idSet);        
        updateSobjectTopics(idSet, newTopicAssignmentList);
    }

    public static void updateSobjectTopics(Set<Id> sobjectIdSet, List<TopicAssignment> topicAssignmentList){
        Map<Id, String> sobjectMap = new Map<Id, String>();
        List<SObject> sobjList = new List<SObject>();

        if(sobjectIdSet != null && !sobjectIdSet.isEmpty()){
            List<TopicAssignment> topicAssignments =  [SELECT   EntityId,Topic.Name FROM TopicAssignment
                                                        WHERE   EntityId IN: +sobjectIdSet
                                                     ORDER BY   CreatedDate];
            //System.debug('--topicAssignments--' + topicAssignments);

            for(TopicAssignment topicAssignment: topicAssignments){
                String topicName = sobjectMap.get(topicAssignment.EntityId) == null ? topicAssignment.Topic.Name : sobjectMap.get(topicAssignment.EntityId) + ';' + topicAssignment.Topic.Name;

                if(topicName != null && topicName.length() > 255){
                    topicName = topicName.substring(0,254);
                }

                sobjectMap.put(topicAssignment.EntityId,topicName);
            }
            //System.debug('--sobjectMap--' + sobjectMap);
            for(Id sobjectId : sobjectIdSet){
                SObject sobj = sobjectId.getSobjectType().newSObject();
                sobj.Id = sobjectId;
                sobj.put('Topics__c',sobjectMap.get(sobjectId));
                sobjList.add(sobj);
            }
            //System.debug('--sobjList--' + sobjList);

            if(sobjList != null && !sobjList.isEmpty()){
                try{
                    update sobjList;
                }
                catch(Exception exceptionObj){
                    topicAssignmentList[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message + exceptionObj.getmessage());
                }
            }
        }
    }

    public static void validateTopicAssignment(List<TopicAssignment> newTopicAssignmentList)
    {
        TopicAssignment topicAssignmentObj = newTopicAssignmentList.get(0);
        String sObjectType = CommonTools.getSObjectType(topicAssignmentObj.EntityId);
        if('Legal_Agreement__c'.equalsIgnoreCase(sObjectType)) {
            List<Topic> topicData = [SELECT CreatedById FROM Topic WHERE Id = :topicAssignmentObj.TopicId];
            String createdById = topicData.get(0).createdById;
            
            if( createdById != String.valueOf(UserInfo.getUserId()))
                newTopicAssignmentList[0].adderror(System.Label.Legal_Agreement_topic_insert_error);   
        }  
    }

    public static void validateTopicAssignmentDeletion(List<TopicAssignment> oldTopicAssignmentList)
    {
        TopicAssignment topicAssignmentObj = oldTopicAssignmentList.get(0);
        
        if('Legal_Agreement'.equalsIgnoreCase(topicAssignmentObj.EntityType)) {
            List<Topic> topicData = [SELECT createdById FROM Topic WHERE Id = :topicAssignmentObj.TopicId];
            String createdById = topicData.get(0).createdById;

            if(createdById != String.valueOf(UserInfo.getUserId())){
                userAllowedToDeleteTopic = false;
                oldTopicAssignmentList[0].adderror(System.Label.Legal_Agreement_topic_delete_error);
            }
        }
    }

    public static void removeCustomTopicAssignment(List<TopicAssignment> oldTopicAssignmentList){
		Set<Id> accountTopicIdList = new Set<Id>(); 
        Set<Id> accountEntityIdList = new Set<Id>(); 
        List<String> customTopicAssignmentList = new List<String>();      
        
        for(TopicAssignment topicAssignment : oldTopicAssignmentList)
        {
            if('Account'.equalsIgnoreCase(topicAssignment.EntityType) ){
				accountTopicIdList.add(topicAssignment.TopicId);
                accountEntityIdList.add(topicAssignment.EntityId);
            }
        }
        
        if(accountTopicIdList.size() > 0){
            Map<Id, Topic> topicMap = new Map<ID, Topic>([SELECT Id, Name FROM Topic WHERE Id IN :accountTopicIdList AND (Name like '@%' OR Name like '$%')]);            
            if(topicMap != null){
                Map<Id, Account> accountMap = new Map<ID, Account>([SELECT Id, RDM_ORG_ID__c FROM Account WHERE Id IN :accountEntityIdList]);
                Map<String, List<Id>> topicNameAccountsMap = new Map<String, List<Id>>();
                for(TopicAssignment tla : oldTopicAssignmentList){
                    Topic t = topicMap.get(tla.TopicId);
                    Account a = accountMap.get(tla.EntityId);
                    if(t != null && a != null){
                        String accountUniqueId = t.Name + '#' + a.RDM_ORG_ID__c;
                        customTopicAssignmentList.add(accountUniqueId);
                        if(topicNameAccountsMap.containsKey(t.Name)){
                            topicNameAccountsMap.get(t.Name).add(tla.EntityId);
                        } else {
                            List<Id> ids = new List<Id>();
                            ids.add(tla.EntityId);
                            topicNameAccountsMap.put(t.Name, ids);
                        }					
                    }
                }
                
                if(customTopicAssignmentList.size() > 0){
                    List<Topic_Assignment__c> cta = [Select Id From Topic_Assignment__c WHERE Account_Unique_Id__c IN :customTopicAssignmentList];
                    if(cta != null && cta.size() > 0){
                        delete cta;
                    }
                    createSchRequest(topicNameAccountsMap, 'remove');
                }
            }
        } 
    }
    
    public static void addCustomTopicAssignment(List<TopicAssignment> newTopicAssignmentList){

        Set<Id> accountTopicIdList = new Set<Id>();  
		List<Topic_Assignment__c> customTopicAssignmentList = new List<Topic_Assignment__c>();
		

        for(TopicAssignment topicAssignment : newTopicAssignmentList)
        {
            if('Account'.equalsIgnoreCase(topicAssignment.EntityType) ){                
                accountTopicIdList.add(topicAssignment.TopicId);
            }
        }
        
          
        if(accountTopicIdList.size() > 0){
			List<Topic> topicList = [SELECT Id, Name FROM Topic WHERE Id IN :accountTopicIdList AND (Name like '@%' OR Name like '$%')];
			if(topicList != null && topicList.size()> 0){
				Map<String, List<Id>> topicNameAccountsMap = new Map<String, List<Id>>();
				List<String> topicNames = new List<String>();
				Map<Id, String> topicMap = new Map<Id, String>();
				for(Topic topic : topicList){
					topicNames.add(topic.Name);
					topicMap.put(topic.Id, topic.Name);
				}
				
				List<Topic__c> customTopicList = [SELECT Id, Name FROM Topic__c WHERE Name IN :topicNames];		
				Map<String, Id> customTopicMap = new Map<String, Id>();
				for(Topic__c customTopic : customTopicList)
					customTopicMap.put(customTopic.Name, customTopic.Id);
				
				for(TopicAssignment tla : newTopicAssignmentList){
					String topicName = topicMap.get(tla.TopicId);
					if(topicName != null){
						Id customTopicId = customTopicMap.get(topicName);
						if(customTopicId != null){
							Topic_Assignment__c customTopicAssignment = new Topic_Assignment__c();
							customTopicAssignment.Topic_Id__c = customTopicId;
							customTopicAssignment.Account__c = tla.EntityId;
							customTopicAssignment.CreatedById = UserInfo.getUserId();

							customTopicAssignmentList.add(customTopicAssignment);
							if(topicNameAccountsMap.containsKey(topicName)){
								topicNameAccountsMap.get(topicName).add(tla.EntityId);
							} else {
								List<Id> ids = new List<Id>();
								ids.add(tla.EntityId);
								topicNameAccountsMap.put(topicName, ids);
							}
						}
					}				
				}
				if(customTopicAssignmentList.size() > 0){
					insert customTopicAssignmentList;
					createSchRequest(topicNameAccountsMap, 'add');
				}
			}
        }
    }

    public static void createSchRequest(Map<String, List<Id>> topicNameAccountsMap, String type){
        System.debug('--createSchRequest topicNameAccountsMap--' + topicNameAccountsMap);
        System.debug('--createSchRequest type--' + type);

        if(topicNameAccountsMap != null && topicNameAccountsMap.size() > 0){
            List<Priority_List__mdt> priorityList =  [SELECT Id, MasterLabel, DeveloperName, Category__c, SCH_FieldName__c, Tier__c FROM Priority_List__mdt WHERE Global_Tiering_type__c IN ('$EQR', '$PS') ORDER BY MasterLabel ASC];
			Id schRgPriorityListRecordId = Schema.getGlobalDescribe().get('Sch_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get('RG_Priority_List').getRecordTypeId();
            
            Map<String, Priority_List__mdt> plm= new Map<String, Priority_List__mdt>();
            
            for(Priority_List__mdt priorityListObj : priorityList){
                System.debug('--priorityListObj.MasterLabel-' + priorityListObj.MasterLabel);
                plm.put(priorityListObj.MasterLabel, priorityListObj);
			}
            
            List<Sch_Request__c> schRequestList =  new List<Sch_Request__c>();
            for(String priorityListName : topicNameAccountsMap.keySet()){
                Priority_List__mdt plmm = plm.get(priorityListName);
                if(plmm != null){
					for(Id aId : topicNameAccountsMap.get(priorityListName)){
                    
                        Sch_Request__c schObj = new Sch_Request__c(); 
                        schObj.RecordTypeId =  schRgPriorityListRecordId;
                        schObj.RG_Account__c = aId;
                        schObj.put(plmm.SCH_FieldName__c, plmm.Tier__c);
                        schObj.Action__c = 'add'.equalsIgnoreCase(type) ? 'Create' : 'Delete';
    
                        schRequestList.add(schObj);
                    }
				}
            }

            if(schRequestList.size() > 0)
                insert schRequestList;
        }
    }

}