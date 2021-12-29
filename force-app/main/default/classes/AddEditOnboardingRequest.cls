public without sharing class AddEditOnboardingRequest {

public class RequestDetails{
        @AuraEnabled public String status {get; set;}
        @AuraEnabled public String subStatus {get; set;}
    }

    @AuraEnabled
    public static RequestDetails getOnboardingStatus(String recordId){
            RequestDetails request = new RequestDetails();

        System.debug('----in method--');
        Onboarding_Request__c onbRecord = [SELECT Id, Status__c, Sub_Status__c from Onboarding_Request__c WHERE Id= :recordId];
        if(null != onbRecord ){
            request.status = onbRecord.Status__c;
            request.subStatus = onbRecord.Sub_Status__c;
        }

        return request;
    }
    
    @AuraEnabled
    public static String getNewlyCreatedOnboardingRecordIdbyUser(){
        system.debug('---in getNewlyCreatedOnboardingRecordIdbyUser--');
        Onboarding_Request__c onbRecord = [SELECT Id from Onboarding_Request__c WHERE CreatedById = :UserInfo.getUserId() ORDER By CreatedDate DESC LIMIT 1];
        
        return onbRecord.Id;
    }
    
    @AuraEnabled
    public static String getDummyRecordId() {
        String onbReqId;
        String loggedInUserId = UserInfo.getUserId();
        List<Onboarding_Request__c> dummyOnboardingRequest = [SELECT Id FROM Onboarding_Request__c WHERE Requestor__c = :loggedInUserId AND RM_Account__c = NULL ORDER BY CreatedDate DESC LIMIT 1];
        if(!dummyOnboardingRequest.isEmpty()) {
            onbReqId = dummyOnboardingRequest[0].Id;
        } else {
            Onboarding_Request__c onbReq = new Onboarding_Request__c (
                Are_you_aware_of_matter_in_public_domain__c = 'No',
                Confirmation_for_face_to_face_meeting__c = 'Yes',
                Did_you_originate_this_client_rltnshp__c = 'No',
                Estimated_Revenue_p_a_USD_from_client__c = 0,
                How_do_you_know_of_this_client__c = '-',
                How_long_have_you_known_them__c = 'New Contact',
                Revenue_estimate_based_on_prior_rltnshp__c = 'No',
                OwnerId = loggedInUserId,
                Requestor__c = loggedInUserId,
                Status__c = 'Draft'
            );
            try {
                insert onbReq;
                onbReqId = onbReq.Id;
            } catch (exception e) {
                System.debug('Failed To Insert Dummy Onboarding Request IN AddEditOnboardingReq.cls ' + e.getMessage());
            }
        }
        return onbReqId;
    }
    
    @AuraEnabled
    public static OnboardingRequestWrapper getOnboardingRequestDetails(String recordId) {
        OnboardingRequestWrapper requestInfo = new OnboardingRequestWrapper();
        requestInfo.dummyRequestId = getDummyRecordId();
        if (String.isNotBlank(recordId) && Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'Account') {
            Onboarding_Request__c onbReq = getDraftRequestForRM(recordId);
            if(onbReq != null) {
                requestInfo.draftRequestExistsForRM = true;
                requestInfo.accountName = onbReq.RM_Account__r.Name;
            }
        }
        return requestInfo;
    }
    
    @AuraEnabled
    public static String getInterviewsForRecord(String recordId) {
        if(String.isNotBlank(recordId)) {
            List<FlowRecordRelation> flowInterviewIds = [ SELECT ParentId FROM FlowRecordRelation WHERE RelatedRecordId = :recordId ORDER BY Parent.CreatedDate DESC LIMIT 1 ];
            if (!flowInterviewIds.isEmpty()) {
                return flowInterviewIds[0].ParentId;
            }
        }
        return null;
    }
    
    @AuraEnabled
    public static Onboarding_Request__c getDraftRequestForRM(String rmAccountId) {
        List<Onboarding_Request__c> onboardingReqs = [SELECT Id, RM_Account__r.Name FROM Onboarding_Request__c WHERE RM_Account__c = :rmAccountId AND Status__c = 'Draft' AND Requestor__c =:UserInfo.getUserId() LIMIT 1];
        if (!onboardingReqs.isEmpty()) {
            return onboardingReqs[0];
        } 
        return null;
    }
    
    public class OnboardingRequestWrapper {
        @AuraEnabled
        public String dummyRequestId {get;set;}
        @AuraEnabled
        public String accountName {get;set;}
        @AuraEnabled
        public Boolean draftRequestExistsForRM {get{
            if(this.draftRequestExistsForRM == null) {
                return false;
            }
            return draftRequestExistsForRM;
        }set;}
    }
}