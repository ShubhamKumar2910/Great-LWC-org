trigger TaskTrigger on Task (before delete, before insert, before update,
                             after delete, after insert, after update, after undelete) {
                                 
                                 if(System.isBatch()){
                                     for (Task t : trigger.new){
                                         if(null==t.WhatId){
                                             if(null!=t.WhoId){
                                                 System.debug('whatID is null');
                                                 System.debug('Task is : ' + t.id);
                                                 Contact [] contacs = [SELECT AccountId FROM Contact WHERE Id = :t.whoId];
                                                 if(contacs.size()>0){
                                                     Account [] contactAccounts = [select id, name, parentId from Account WHERE id = :contacs[0].AccountId  ];
                                                     if(contactAccounts.size()>0){
                                                         if(null!=contactAccounts[0].parentid ){
                                                             System.debug(' kk contactAccounts[0].parentid::' + contactAccounts[0].parentid);
                                                             t.WhatId = contactAccounts[0].parentid;
                                                         }
                                                         
                                                     }
                                                 }
                                             }
                                         }
                                     }
                                     
                                 }
                                 else {
                                     string userId = UserInfo.getUserId() ;
                                     
                                     User callingUser = [SELECT Id,User_Profile_Name__c,Name FROM User WHERE Id = : userId] ;  
                                     
                                     if(string.valueOf(callingUser.User_Profile_Name__c) <> 'Nomura - Integration') {                                   
                                         
                                         if ( Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate ) )  {       
                                             TaskTriggerHandler.validateNoInActiveContact(Trigger.oldMap,Trigger.new,Trigger.isInsert, Trigger.isUpdate );
                                             TaskTriggerHandler.validateOtherFields(Trigger.new);
                                         } 
                                         
                                         if ( Trigger.isAfter && (Trigger.isInsert  ) )  { 
                                             System.debug('trigger after insert');        
                                             TaskTriggerHandler.validateWhatId(Trigger.new);   
                                             if(!System.isFuture()){
                                                 TaskTriggerHandler.validateNomuraWhoId(Trigger.new[0].id);
                                             }
                                         }
                                         
                                         if ( Trigger.isBefore && (Trigger.isInsert ) )  { 
                                             System.debug('trigger before update or insert');
                                             TaskTriggerHandler.validateOutlook(Trigger.new);                                               
                                         }
                                         
                                         if( Trigger.isAfter && Trigger.isUpdate){        
                                             System.debug('trigger after update');        
                                             TaskTriggerHandler.validateWhatId(Trigger.new);       
                                             if(!System.isFuture()){
                                                 TaskTriggerHandler.validateNomuraWhoId(Trigger.new[0].id);     
                                             }
                                         }                                 
                                     }
                                 }
                                 
                                 if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
                                     system.debug('inside isBefore update ');
                                     TaskTriggerHandler.updateTaskL0Type(Trigger.new);
                                 }
                                 
                                 
                                 
                                 
                             }