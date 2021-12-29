public with sharing class RevenueKPITriggerHandler {
          
     /*
     * Method which takes a set of Opportunity records that are being inserted 
     * and executes logic AFTER the records have been INSERTED.
     * @param newRecords the map of Opportunity records and their new id's
     */ 
    public static void onAfterInsert(Map<Id, Revenue_KPI__c> newRecords ) {      
       RevenueKPIBL.createRevenueShareRecords(newRecords.values());
    }
	
}