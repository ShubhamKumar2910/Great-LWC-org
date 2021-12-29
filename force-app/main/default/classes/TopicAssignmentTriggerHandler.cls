public class TopicAssignmentTriggerHandler {

	public static void handleBeforeInsert(List<TopicAssignment> newTopicAssignmentList){
        TopicAssignmentTriggerBL.validateTopicAssignment(newTopicAssignmentList);  
    }

    public static void handleBeforeUpdate(List<TopicAssignment> newTopicAssignmentList, Map<Id,TopicAssignment> oldMap){
    }

    public static void handleBeforeDelete(List<TopicAssignment> oldTopicAssignmentList){
        String type = 'beforeDelete';
        TopicAssignmentTriggerBL.validateTopicAssignmentDeletion(oldTopicAssignmentList);
        TopicAssignmentTriggerBL.removeCustomTopicAssignment(oldTopicAssignmentList);
    }
    
    public static void handleAfterInsert(List<TopicAssignment> newTopicAssignmentList){      
        TopicAssignmentTriggerBL.addTopic(newTopicAssignmentList);
        TopicAssignmentTriggerBL.addCustomTopicAssignment(newTopicAssignmentList);
    }

    public static void handleAfterUpdate(Map<Id,TopicAssignment> oldMap,Map<Id,TopicAssignment> newMap){        
    }   

    public static void handleAfterDelete(List<TopicAssignment> oldTopicAssignmentList){       
        if(TopicAssignmentTriggerBL.userAllowedToDeleteTopic)
            TopicAssignmentTriggerBL.removeTopic(oldTopicAssignmentList);
    }
}