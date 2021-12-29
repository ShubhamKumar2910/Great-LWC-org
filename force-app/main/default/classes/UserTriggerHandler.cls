public with sharing class UserTriggerHandler {

   
    public static void onAfterInsert(List<User> newRecords, Map<Id, User> oldRecords, Map<Id, User> newRecordsMap)
    {    
        UserHelper.InsertUserTOGroup(newRecords,null); 
        UserHelper.InsertResearchUserToResearchGroups(newRecords, null);
        UserHelper.handleForUserToRevenueStatsGroup(newRecords,null);

        UserPermissionSetAssignment.singleTrackMiFIDAssignment(newRecords, oldRecords);
        
        // Check and set-up the Permission Sets for the Users being added
        UserHelper.checkAndConfigurePermissionSetsForUser(null, newRecordsMap);

        // Confirigure SCH approvers
        UserHelper.checkAndConfigureSchApprovalQueues(null, newRecordsMap);
        // Configure Onboarding Approval queues
        UserHelper.checkAndConfigureSalesCAOsApprovalQueues(null, newRecordsMap);
        UserHelper.checkAndConfigureDeskHeadApprovals(oldRecords, newRecordsMap);        
        UserHelper.configureNFPEApproverQueues(null, newRecordsMap);
        UserHelper.configureFuturesClearingApproverQueues(null, newRecordsMap);
        UserHelper.configurePrimeApproverQueues(null, newRecordsMap);
    }
    
   
    
    public static void onAfterUpdate(Map<Id, User> newRecords, Map<Id, User> oldRecords, Map<Id, User> newRecordsMap)
    {
        UserHelper.InsertUserTOGroup(newRecords.values(),oldRecords);
        userHelper.InsertResearchUserToResearchGroupsOnUserUpdate(newRecords.values(),oldRecords);
        UserHelper.handleForUserToRevenueStatsGroup(newRecords.values(),oldRecords);
        UserHelper.deleteChampionRecordsForTerminatedUsers(newRecords.values(), oldRecords);
        UserHelper.updateUserNameOnDeactivate(newRecords.values(), oldRecords);

        UserPermissionSetAssignment.singleTrackMiFIDAssignment(newRecords.values(), oldRecords);
        
        // Check and set-up the Permission Sets for the Users being modified
        UserHelper.checkAndConfigurePermissionSetsForUser(oldRecords, newRecordsMap);

        // Confirigure SCH approvers
        UserHelper.checkAndConfigureSchApprovalQueues(oldRecords, newRecordsMap);
        // Configure Onboarding Approval queues
        UserHelper.checkAndConfigureSalesCAOsApprovalQueues(oldRecords, newRecordsMap);
        UserHelper.checkAndConfigureDeskHeadApprovals(oldRecords, newRecordsMap);
        UserHelper.configureNFPEApproverQueues(oldRecords, newRecordsMap);
        UserHelper.configureFuturesClearingApproverQueues(oldRecords, newRecordsMap);
        UserHelper.configurePrimeApproverQueues(oldRecords, newRecordsMap);
    }
    
    public static void onBeforeInsert(List<User> newRecords){
        UserHelper.updateUserDetails(newRecords, null);
        UserHelper.ComputeManagerIdBeforeInsert(newRecords);
    }
    
    public static void onBeforeUpdate(Map<Id, User> newRecords, Map<Id, User> oldRecords){
        UserHelper.updateUserDetails(newRecords.values(), oldRecords);
        UserHelper.ComputeManagerIdBeforeUpdate(newRecords.values(), oldRecords);
    }
    
}