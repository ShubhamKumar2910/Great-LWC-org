public class SalesTeamForCoverageTriggerHandler {
    
    public static void onBeforeInsert(List<Sales_Team_for_Coverage__c> newRecords){
        SalesTeamForCoverageTriggerBL.changeOwner(newRecords);
    }
    
    public static void onBeforeUpdate(List<Sales_Team_for_Coverage__c> newRecords, 
                                      Map<Id,Sales_Team_for_Coverage__c> oldRecordsMap){
		SalesTeamForCoverageTriggerBL.changeOwner(newRecords);
        SalesTeamForCoverageTriggerBL.changeOwnerForJointSalesCode(newRecords);                              
    }
    
    public static void onAfterInsert(List<Sales_Team_for_Coverage__c> newRecords, 
                                     Map<Id,Sales_Team_for_Coverage__c> oldRecordsMap){
        SalesTeamForCoverageTriggerBL.createSharing(newRecords);
    }
    
    public static void onAfterUpdate(Map<Id, Sales_Team_for_Coverage__c> newRecords, 
                                     Map<Id, Sales_Team_for_Coverage__c> oldRecords)
    {    
        SalesTeamForCoverageTriggerBL.createSharing(newRecords.values());
        SalesTeamForCoverageTriggerBL.createSharingForJointSalesCode(newRecords.values());
        SalesTeamForCoverageTriggerBL.processBatchforSalesCodes(newRecords, oldRecords);
    }
	
}