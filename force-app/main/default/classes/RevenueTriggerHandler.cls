public with sharing class RevenueTriggerHandler {

      
    public static void onBeforeInsert(list<Revenue__c> newRecords )

    { 
           
           
    }
    
      
    public static void onAfterInsert(Map<Id, Revenue__c> newRecords )

    {      
       RevenueBL.CreateRevenueShareRecords(null,newRecords.values());
        
    }
    
       
    public static void onBeforeUpdate(Map<Id, Revenue__c> newRecords, Map<Id, Revenue__c> oldRecords)
    {   
       
        
    }
    
    public static void onAfterUpdate(Map<Id, Revenue__c> newRecords, Map<Id, Revenue__c> oldRecords)
    {   
    
       RevenueBL.CreateRevenueShareRecords(oldRecords, newRecords.values());          
       
    }
    
   
    public static void onAfterDelete( List< Revenue__c> oldRecords)
    
    {

    }
    
     
}