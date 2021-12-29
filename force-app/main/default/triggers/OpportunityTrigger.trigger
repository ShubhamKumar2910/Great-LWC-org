trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update, before delete) {
    //added check for JIRA SALES 1588
    if (Trigger.isDelete){
            OpportunityTriggerHandler.onBeforeDelete(Trigger.Old);
    } else if(Trigger.isBefore){
         for(Opportunity o : Trigger.New) {
           if(o.RecordTypeId != CommonTools.getRecordTypeIdUsingDeveloperName('Opportunity','Automated')){
                o.AccountId = o.Account__c;
           }  
        }
        //added section for Cross Referral for JIRA 1588
        if(Trigger.isInsert){
            OpportunityTriggerHandler.BeforeInsertHandler(Trigger.New);
        }   
       
    }
    //added section for Cross Referral for JIRA 1588
    else if(Trigger.isAfter && Trigger.isInsert){
        OpportunityTriggerHandler.AfterInsertHandler(Trigger.New);   
    }
    else if(Trigger.isAfter && Trigger.isUpdate){
        OpportunityTriggerHandler.AfterUpdateHandler(Trigger.New,Trigger.oldMap);   
    }
}