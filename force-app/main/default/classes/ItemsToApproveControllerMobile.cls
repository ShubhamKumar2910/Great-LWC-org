public without sharing class ItemsToApproveControllerMobile {
    
    
    @AuraEnabled 
    public static List<BulkApprovalController.ApprovalQueueItem> getApprovalRequests(String cmpisApproval) 
    {
        return BulkApprovalController.getApprovalRequests(cmpisApproval);
    }
    
    @AuraEnabled 
    public static List<BulkApprovalController.ApprovalQueueItem> submitRejectedRequests(string cmpRejectedIds,String cmpisApproval,string cancelorreject){
        return BulkApprovalController.submitRejectedRequests(cmpRejectedIds,cmpisApproval,cancelorreject);
    }
    
    @AuraEnabled
    public static List<BulkApprovalController.ApprovalQueueItem>  submitApprovedRequests(String cmpApprovedIds,String cmpisApproval){
        return BulkApprovalController.submitApprovedRequests(cmpApprovedIds,cmpisApproval);
    }
}