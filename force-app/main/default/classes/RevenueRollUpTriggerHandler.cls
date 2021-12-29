public with sharing class RevenueRollUpTriggerHandler {

      
    public static void onBeforeInsert(list<Revenue_Rollup__c> newRecords )

    { 
           
           
    }
    
     /*
     * Method which takes a set of Opportunity records that are being inserted 
     * and executes logic AFTER the records have been INSERTED.
     * @param newRecords the map of Opportunity records and their new id's
     */ 
    public static void onAfterInsert(Map<Id, Revenue_Rollup__c> newRecords )

    {      
       RevenueRollUpBL.CreateRevenueShareRecords(newRecords);
        
    }
    
       
    public static void onBeforeUpdate(Map<Id, Revenue_Rollup__c> newRecords, Map<Id, Revenue_Rollup__c> oldRecords)
    {   
       
        
    }
    
    public static void onAfterUpdate(Map<Id, Revenue_Rollup__c> newRecords, Map<Id, Revenue_Rollup__c> oldRecords)
    {   
    
                 
       
    }
    
   
    public static void onAfterDelete( List< Revenue_Rollup__c> oldRecords)
    
    {

    }
    
     
}