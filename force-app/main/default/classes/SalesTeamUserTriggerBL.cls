public class SalesTeamUserTriggerBL {
    public static void updateSalesCodeDetailsForInsert(Map<Id, Sales_Team_User__c> newRecords){
        if(newRecords != null && newRecords.size() > 0){
            updateSalesTeamForCoverageDetails(newRecords.keySet(), newRecords);
        }
    }
    
    public static void updateSalesCodeDetailsForUpdate(Map<Id, Sales_Team_User__c> newRecords, Map<Id, Sales_Team_User__c> oldRecords){
        Set<Id> salesTeamUserIdSet = new Set<Id>();
        
        for(Sales_Team_User__c salesTeamUserObj : newRecords.values()){
            Sales_Team_User__c oldSalesUserTeamObj = oldRecords.get(salesTeamUserObj.Id);
            if(
            	salesTeamUserObj != null &&
                salesTeamUserObj.Is_User_Active__c == TRUE &&
                oldSalesUserTeamObj.Is_User_Active__c == FALSE
              )
            {
                salesTeamUserIdSet.add(salesTeamUserObj.Id);
            }
        }
        if(salesTeamUserIdSet.size() > 0){
            updateSalesTeamForCoverageDetails(salesTeamUserIdSet, newRecords);
        }
    }
    
    public static void updateSalesTeamForCoverageDetails(Set<Id> salesTeamUserIdSet, Map<Id, Sales_Team_User__c> newRecords){
        List<Sales_Team_for_Coverage__c>  salesTeamForCoverageList = null;
        
        if(salesTeamUserIdSet != null && salesTeamUserIdSet.size() > 0){
            	salesTeamForCoverageList = 
                    [SELECT Id, Coverage_Id__c, Process_Coverage_Related_Entities__c
                     FROM Sales_Team_for_Coverage__c
                    // WHERE Is_Split_Sales_Code__c = TRUE 
                        WHERE Active__c = TRUE
                        AND Process_Coverage_Related_Entities__c = FALSE
                        AND Id IN (SELECT Sales_Team_for_Coverage__c FROM Sales_Team_User__c
                                   WHERE Id IN :salesTeamUserIdSet AND User__r.IsActive = TRUE)];
                
                if(salesTeamForCoverageList != null && salesTeamForCoverageList.size() > 0){
                    for(Sales_Team_for_Coverage__c salesCodeObj : salesTeamForCoverageList){
                        salesCodeObj.Process_Coverage_Related_Entities__c = TRUE;
                    }
                    
                    try {
                        update salesTeamForCoverageList;
                    }
                    catch(Exception ex){
                        newRecords.values()[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
                    }
                }
         }
    }
}