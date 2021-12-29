public class EventTriggerHandler {
    
    public static void validateNoInActiveContact(Map<Id,Event> triggerOldMap, List<Event> triggerNew , boolean isInsert, boolean isUpdate){       
        EventTriggerBL.validateNoInActiveContact(triggerOldMap, triggerNew , isInsert, isUpdate);        
    }
    
    public static void validateWhatId(List<Event> triggerNew ){        
    	EventTriggerBL.validateWhatId( triggerNew );        
    }
    
    public static void validateOutlook(List<Event> triggerNew ){        
    	EventTriggerBL.validateOutlook( triggerNew );
    }
        
    public static void validateNomuraWhoId(List<Event> triggerNew){
        List<Id> eventIdList = new List<Id>();
            for(Event t : triggerNew){
			if(t.Source__c != 'Outlook Plugin'){
				eventIdList.add(t.id);
			}
        }                
        EventTriggerBL.validateNomuraWhoId( eventIdList );        
    }
   
    public static void validateOtherFields(List<Event> triggerNew){
        EventTriggerBL.validateOtherFields(triggerNew);
    }    
    
    public static void updateServiceStatsSummarized(Map<Id,Event> triggerOldMap,List<Event> triggerNew){
      EventTriggerBL.updateServiceStats(triggerOldMap, triggerNew);       
    }

    public static void makeOwnerAsInvitee(List<Event> triggerNew){
        EventTriggerBL.makeOwnerAsInvitee(triggerNew);
    }

    public static void deleteEventRelation(List<Event> triggerNew){
        EventTriggerBL.deleteEventRelation(triggerNew);
    }

    public static void changeSource(List<Event> triggerNew){
        EventTriggerBL.changeSource(triggerNew);
    }
    
    public static void populateDurationAndL0Type(List<Event> triggerNew){
        EventTriggerBL.populateDurationAndL0Type(triggerNew);
    }
}