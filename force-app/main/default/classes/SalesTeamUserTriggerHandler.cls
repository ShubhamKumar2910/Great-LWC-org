public class SalesTeamUserTriggerHandler {
    
    public static void onAfterInsert(Map<Id, Sales_Team_User__c> newRecords)
    {    
       SalesTeamUserTriggerBL.updateSalesCodeDetailsForInsert(newRecords);
    }
    
    public static void onAfterUpdate(Map<Id, Sales_Team_User__c> newRecords, Map<Id, Sales_Team_User__c> oldRecords)
    {    
       SalesTeamUserTriggerBL.updateSalesCodeDetailsForUpdate(newRecords, oldRecords);
    }

}