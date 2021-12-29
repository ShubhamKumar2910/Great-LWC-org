trigger EventTrigger on Event ( before delete, before insert, before update,
                               after delete, after insert, after update, after undelete) {                                      
    Nomura_Trigger_Activation__c triggerSettings = Nomura_Trigger_Activation__c.getInstance('EventTrigger');
    
    if(triggerSettings != null && triggerSettings.Active__c == true){
        System.debug('SYSTEM BATCH ' + System.isBatch());
        if(System.isBatch()){
            Map<String,String> whoIdMap = new Map<String,String>();
            for (Event t : trigger.new){
                if(t.source__c!='BulkInsert')
                {
                    System.debug('is IsChild outside ' + t.IsChild);
                    if(null==t.WhatId && !t.IsChild){
                        if(null!=t.WhoId ){
                            System.debug('whatID is null');
                            System.debug('is IsChild inside ' + t.IsChild);
                            System.debug('Event is : ' + t.id);
                            whoIdMap.put(t.id,t.WhoId);
                        }
                    }
                }
                else if(t.source__c == 'BulkInsert' && Trigger.isUpdate)
                {
                    system.debug('Old value: '+Trigger.oldMap.get(t.Id).source__c);
                    system.debug('New value: '+t.source__c);
                    if (Trigger.oldMap.get(t.Id).source__c!=null)
                    {
                        if(Trigger.oldMap.get(t.Id).source__c != t.source__c)
                        t.Source__c = Trigger.oldMap.get(t.Id).source__c; 
                    }
                }
            }
            
            System.debug('WhoIdMap: '+whoIdMap);
            if(whoIdMap.size() > 0){
                System.debug('Inside WhoIdMap If');
                Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id,Account.ParentId FROM Contact WHERE Id IN:whoIdMap.values()]);
                System.debug('Contact Map Size:'+contactMap.size());
                for (Event t : trigger.new){
                    if(contactMap.get(t.whoId) != null){
                        System.debug('Inside inner If');
                        Contact con = contactMap.get(t.WhoId);
                        t.WhatId = con.Account.ParentId;
                        System.debug('RG: '+con.Account.ParentId);
                    }
                }
            }
        }
        else {
            if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate )  ){
                System.debug('Inside Before Insert or Update Trigger');
                EventTriggerHandler.validateNoInActiveContact(Trigger.oldMap,Trigger.new,Trigger.isInsert, Trigger.isUpdate );
                EventTriggerHandler.validateOtherFields(Trigger.new);
                EventTriggerHandler.populateDurationAndL0Type(Trigger.new);
            }

            if ( Trigger.isAfter && (Trigger.isInsert ) )  { 
                System.debug('Inside After Insert Trigger');
                EventTriggerHandler.validateWhatId(Trigger.new);
                if(!System.isFuture()){
                    EventTriggerHandler.validateNomuraWhoId(Trigger.new);
                }
            }
            
            if ( Trigger.isBefore && (Trigger.isInsert ) )  { 
                System.debug('Inside Before Insert Trigger');
                EventTriggerHandler.validateOutlook(Trigger.new);
                EventTriggerHandler.changeSource(Trigger.new);                
            }
            
            if( Trigger.isAfter && Trigger.isUpdate){
                System.debug('Inside After Update Trigger');
                EventTriggerHandler.deleteEventRelation(Trigger.new);
                EventTriggerHandler.validateWhatId(Trigger.new);    
                if(!System.isFuture()){
                    EventTriggerHandler.validateNomuraWhoId(Trigger.new);
                }
                // for Instinet Feed
                EventTriggerHandler.makeOwnerAsInvitee(Trigger.new);
            }
        }
        
        if (Trigger.isBefore && Trigger.isUpdate  ){
            if(Trigger.isUpdate)
            {
                System.debug('Inside Before Update Trigger');
                EventTriggerHandler.updateServiceStatsSummarized(Trigger.oldMap,Trigger.new);
            }
        } 
        
        if( Trigger.isAfter ){
            if (trigger.isUpdate) {
                System.debug('Inside After Update Trigger');
                ServiceROIUtility.updateModelImpacted(trigger.oldMap, trigger.newMap);
            }
            if (trigger.isDelete) {
                System.debug('Inside After Delete Trigger');
                ServiceROIUtility.updateModelImpacted(trigger.old);
            }
        }
    }
}