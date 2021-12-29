public class SalesChampionTriggerHandler{

    public static void handleBeforeInsert(List<Sales_Champion__c> newSalesChampionList){
        SalesChampionTriggerBL.populateUniqueID(newSalesChampionList);
    }
    
    public static void handleAfterInsert(Map<Id,Sales_Champion__c> oldMap,Map<Id,Sales_Champion__c> newMap){
        SalesChampionTriggerBL.createAccountShare(oldMap,newMap);
    }

    public static void handleBeforeUpdate(List<Sales_Champion__c> newSalesChampionList, Map<Id,Sales_Champion__c> oldMap){
        SalesChampionTriggerBL.populateUniqueID(newSalesChampionList);
    }
    
    public static void handleAfterUpdate(Map<Id,Sales_Champion__c> oldMap,Map<Id,Sales_Champion__c> newMap){
        SalesChampionTriggerBL.createAccountShare(oldMap,newMap);
    }

    public static void handleBeforeDelete(Map<Id,Sales_Champion__c> oldMap){
        SalesChampionTriggerBL.restrictDeleteForInstinetChampion(oldMap);
    }
    
    public static void handleAfterDelete(Map<Id,Sales_Champion__c> oldMap,Map<Id,Sales_Champion__c> newMap){
        SalesChampionTriggerBL.deleteAccountShare(oldMap,newMap);
    }
    
    
}