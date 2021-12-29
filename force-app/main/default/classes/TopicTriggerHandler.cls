public with sharing class TopicTriggerHandler {
    
    public static void mainEntry(System.TriggerOperation operationType, List<Topic> newList, List<Topic> oldList, 
                                Map<Id, Topic> newMap, Map<Id, Topic> oldMap){

        System.debug('--operationType--' + operationType);
        switch on operationType {
            when AFTER_INSERT {
                handleAfterInsert(newList);
            }
            when AFTER_UPDATE {
                handleAfterUpdate(oldMap, newList);
            }
            when BEFORE_DELETE {
                handleBeforeDelete(oldList);
            }
        }
    }

    public static void handleAfterInsert(List<Topic> newList){
        Boolean isManagementUser = CommonTools.isBusinessManagementUser();
        Boolean isAdministratorUser = CommonTools.isAdministratorUser();

        List<Topic__c> customTopicList = new List<Topic__c>();
        if(newList != null && newList.size() > 0){
            for(Topic topicObj : newList){
                //Boolean validTopicInsertion = true;
                Boolean validCustomTopicInsertion = false; //flag for creating ony Product Focus list topics in Topic__c object

                //Only System Adminstrator and Nomura - Integration profile user can insert Global Tiering in Topic
                if(topicObj.Name.startsWith('$') && !isAdministratorUser){
                    topicObj.addError('You cant create this topic.');
                    //validTopicInsertion = false;
                }
                else if(topicObj.Name.startsWith('$') && isAdministratorUser){
                    validCustomTopicInsertion = true;
                }
                else if(topicObj.Name.startsWith('@') && !isAdministratorUser && !isManagementUser ){
                    //Only System Adminstrator, Nomura - Integration & Business Management profile user can insert Product Focus List in Topic & Topic__c
                    topicObj.addError('You cant create this topic.');
                    //validTopicInsertion = false;
                    validCustomTopicInsertion = false;
                }   
                else if(topicObj.Name.startsWith('@') && (isAdministratorUser || isManagementUser) ) {
                    validCustomTopicInsertion = true;
                }                

                if(validCustomTopicInsertion){
                    Topic__c customTopicObj = new Topic__c();
                    customTopicObj.Name = topicObj.Name;

                    customTopicList.add(customTopicObj);  
                }                          
            }
            System.debug('--customTopicList--' + customTopicList);
            if(customTopicList != null && customTopicList.size() > 0)
                insert customTopicList;
        }
    }

    public static void handleAfterUpdate(Map<Id, Topic> oldMap, List<Topic> newList){
        Boolean isManagementUser = CommonTools.isBusinessManagementUser();
        Boolean isAdministratorUser = CommonTools.isAdministratorUser();

        Map<String, Topic> newTopicMap = new Map<String, Topic>();
        List<Topic__c> customTopicUpdateList = new List<Topic__c>();

        if(newList != null && newList.size() > 0){
            for(Topic topicObj : newList){
                
                Boolean validCustomTopicUpdation = false; //flag for creating ony Product Focus list topics in Topic__c object

                Topic oldTopic = oldMap.get(topicObj.Id);               
                System.debug('--eq-' + oldTopic.Name.equals(topicObj.Name) );
                if( !oldTopic.Name.equals(topicObj.Name) ){
                    //Only System Adminstrator and Nomura - Integration profile user can update Global Tiering in Topic
                    if(topicObj.Name.startsWith('$') && !isAdministratorUser){
                        topicObj.addError('You cant create this topic.');                        
                    }
                    else if(topicObj.Name.startsWith('$') && isAdministratorUser){
                        newTopicMap.put(oldTopic.Name, topicObj); //oldTopic.Name will act as key in search of Topic__c object
                    }
                    else if(topicObj.Name.startsWith('@') && !isAdministratorUser && !isManagementUser ){
                        //Only System Adminstrator, Nomura - Integration & Business Management profile user can update Product Focus List in Topic & Topic__c
                        topicObj.addError('You cant create this topic.');                        
                        validCustomTopicUpdation = false;
                    }   
                    else if(topicObj.Name.startsWith('@') && (isAdministratorUser || isManagementUser) ) {
                        newTopicMap.put(oldTopic.Name, topicObj); //oldTopic.Name will act as key in search of Topic__c object
                    }                                    
                } 
            }

            if(newTopicMap != null && newTopicMap.size() > 0){
                List<Topic__c> customTopicList = [SELECT Id, Name FROM Topic__c WHERE Name IN :newTopicMap.keySet()];

                for(Topic__c customTopic : customTopicList){
                    Topic__c cTopic = new Topic__c();
                    cTopic.Id = customTopic.Id;
                    cTopic.Name = newTopicMap.get(customTopic.Name).Name;
                    customTopicUpdateList.add(cTopic);
                }
            }
            
            System.debug('--customTopicUpdateList--' + customTopicUpdateList);
            if(customTopicUpdateList != null)        
                update customTopicUpdateList;
        }
    }

    public static void handleBeforeDelete(List<Topic> oldList){
        Boolean isManagementUser = CommonTools.isBusinessManagementUser();
        Boolean isAdministratorUser = CommonTools.isAdministratorUser();

        Map<String, Topic> topicMap = new Map<String, Topic>();
        List<Topic__c> customTopicDeleteList = new List<Topic__c>();

        System.debug('--handleAfterDelete oldList--' + oldList);
        if(oldList != null && oldList.size() > 0){
            for(Topic topicObj : oldList){                
                //Only System Adminstrator and Nomura - Integration profile user can delete Global Tiering in Topic
                if(topicObj.Name.startsWith('$') && !isAdministratorUser){
                    topicObj.addError('You cant delete this topic.');
                }
                else if(topicObj.Name.startsWith('$') && isAdministratorUser){
                    topicMap.put(topicObj.Name, topicObj); //used later to search in Topic__c object
                }
                else if(topicObj.Name.startsWith('@') && !isAdministratorUser && !isManagementUser ){
                    //Only System Adminstrator, Nomura - Integration & Business Management profile user can insert Product Focus List in Topic & Topic__c
                    topicObj.addError('You cant delete this topic.');                                        
                }   
                else if(topicObj.Name.startsWith('@') && (isAdministratorUser || isManagementUser) ) {
                    topicMap.put(topicObj.Name, topicObj); //used later to search in Topic__c object
                }                                            
            }

            System.debug('--topicMap--' + topicMap);
            if(topicMap != null && topicMap.size() > 0){
                //search in Topic_Association__c object if any association is present or not
                List<Topic_Assignment__c> customTopicAssociationList = [SELECT Id FROM Topic_Assignment__c WHERE Topic_Id__r.Name IN :topicMap.keySet()];
                System.debug('--customTopicAssociationList-' + customTopicAssociationList);
                if(customTopicAssociationList.size() == 0){
                    List<Topic__c> customTopicList = [SELECT Id, Name FROM Topic__c WHERE Name IN :topicMap.keySet()];

                    for(Topic__c customTopic : customTopicList){
                        Topic__c cTopic = new Topic__c();
                        cTopic.Id = customTopic.Id;                        
                        customTopicDeleteList.add(cTopic);
                    }
                
                
                    System.debug('--customTopicDeleteList--' + customTopicDeleteList);
                    if(customTopicDeleteList != null)        
                        delete customTopicDeleteList;
                }
                else{
                    System.debug('--topic assignment exist so throw error--');
                    oldList[0].addError('Topic Assignment exist, so cant delete');
                }
            }
                   
        }
    
    }
    
    
}