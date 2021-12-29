trigger CoverageAccessRequestTrigger on Coverage_Access_Request__c (after insert, after update, before insert) {
    
  Nomura_Trigger_Activation__c triggerSettings = Nomura_Trigger_Activation__c.getInstance('CoverageAccessRequestTrigger');

  if((triggerSettings != null && triggerSettings.Active__c == true) || Test.isRunningTest()){

    if (Trigger.isBefore){
      //insert event
      if (Trigger.isInsert){
        //samye
        CoverageAccessRequestTriggerHandler.onBeforeInsert(Trigger.new);    
      } 
    }

    if (Trigger.isAfter){
      //insert event
      if (Trigger.isInsert){
        CoverageAccessRequestTriggerHandler.onAfterInsert(null,Trigger.newMap);
        //update event
      } else if (Trigger.isUpdate){
          //System.debug('==== CoverageAccessRequestTrigger after update: newMap.size=' + Trigger.newMap.size() + '; Trigger.newMap: ' + Trigger.newMap);
          CoverageAccessRequestTriggerHandler.UpdateApprovalStatusForRGCoverageRequest(Trigger.new);
          CoverageAccessRequestTriggerHandler.onAfterUpdate(Trigger.oldMap,Trigger.newMap);
        
      } 
    }


  }
    
  
}