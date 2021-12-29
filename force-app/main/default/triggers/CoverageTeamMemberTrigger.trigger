trigger CoverageTeamMemberTrigger on Coverage_Team_Member__c (after insert, after update, before insert, before update) {

  Nomura_Trigger_Activation__c triggerSettings = Nomura_Trigger_Activation__c.getInstance('CoverageTeamMemberTrigger');

   if(triggerSettings != null && triggerSettings.Active__c == true){

    if (Trigger.isBefore){
      //insert event
      if (Trigger.isInsert){
          CoverageTeamMemberTriggerHandler.onBeforeInsert(Trigger.new);    
        //update event
      } else if (Trigger.isUpdate)
      { 
        CoverageTeamMemberTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
      }

    }

    if (Trigger.isAfter){
      //insert event
      if (Trigger.isInsert){
        CoverageTeamMemberTriggerHandler.onAfterInsert(Trigger.newMap);
        //update event
      } else if (Trigger.isUpdate){
          CoverageTeamMemberTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap); 
      } 
    }

   }
     

}