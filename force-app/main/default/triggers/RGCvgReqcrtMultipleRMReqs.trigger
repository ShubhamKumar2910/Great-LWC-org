trigger RGCvgReqcrtMultipleRMReqs on RG_Coverage_Request__c (before insert,after insert,after update) {
    
    Nomura_Trigger_Activation__c triggerSettings = Nomura_Trigger_Activation__c.getInstance('RGCvgReqcrtMultipleRMReqs');
    
    if((triggerSettings != null && triggerSettings.Active__c == true) || Test.isRunningTest()){

    if (Trigger.isBefore){
      //insert event
      if (Trigger.isInsert){
         RGCoverageReqCrtMultipleRMReqTrgHndlr.onBeforeInsert(Trigger.new);
      } 
    }

    if (Trigger.isAfter){
      //insert event
      if (Trigger.isInsert){
        RGCoverageReqCrtMultipleRMReqTrgHndlr.onAfterInsert(null,Trigger.newMap);
        //update event
      } else if (Trigger.isUpdate){
          RGCoverageReqCrtMultipleRMReqTrgHndlr.onAfterUpdate(Trigger.oldMap,Trigger.newMap);
   
      } 
    } 

    

  }
}