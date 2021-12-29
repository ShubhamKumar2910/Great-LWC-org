trigger GlobalHeadSalesContactShareWithGlblResearchAccount on Account (after insert,before update, after update,before insert) {    
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            GlblHdSalesContactShareGlblRschrAccHndlr.onAfterInsert(trigger.new);
            AccountTriggerHandler.handleAfterInsert(trigger.oldMap, trigger.newMap);
        }
        
        if(Trigger.isUpdate){  
            ContactAddrChangeOnAccAddrUpdateHndlr.onAfterUpdate(trigger.new,trigger.oldMap);
            GlblHdSalesContactShareGlblRschrAccHndlr.onAfterUpdate(trigger.new,trigger.oldMap);
            GlblHdSalesContactShareGlblRschrAccHndlr.AddRSRGRMForScramblingIfAccountIsCapIntroOnly(trigger.new,trigger.oldMap);
            
            AccountTriggerHandler.handleAfterUpdate(trigger.oldMap, trigger.newMap);
        }
    }
    
      if(Trigger.isBefore){ 
          if(Trigger.isInsert){
            GlblHdSalesContactShareGlblRschrAccHndlr.OnBeforeInsert(trigger.new);  
             ContactAddrChangeOnAccAddrUpdateHndlr.OnBeforeInsert(trigger.new);
          }
          if(Trigger.isUpdate){  
              GlblHdSalesContactShareGlblRschrAccHndlr.onBeforeUpdate(trigger.new,trigger.oldMap);
              
              AccountTriggerHandler.handleBeforeUpdate(trigger.oldMap, trigger.newMap);
          }
    }
}