/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**  Date 		: 09/03/2020
**	Description : This class is trigger handler for SObject - Onboarding_Request__c
**/ 
public without sharing class OnboardingRequestTriggerHandler {
    
    private static Set<String> OnbReqAlreadySubmittedForApproval = new Set<String>();
    public static void mainEntry(System.TriggerOperation opType, List<Onboarding_Request__c> OldList, List<Onboarding_Request__c> NewList,
            Map<Id, Onboarding_Request__c> OldMap, Map<Id, Onboarding_Request__c> NewMap) {
        System.debug('#### OnboardingRequestTriggerHandler::mainEntry');
        switch on opType {
            when BEFORE_INSERT {
                handleBeforeInsert(newList);
            }
            when BEFORE_UPDATE {
                handleBeforeUpdate(OldMap, newList);
            }
            when AFTER_INSERT {
                handleAfterInsert(NewList);
            }
            when AFTER_UPDATE {
                handleAfterUpdate(OldMap, NewList);
            }
            when BEFORE_DELETE {
                handleBeforeDelete(oldMap, newList);
            }
        }
    }
    
    public static void handleBeforeDelete(Map<Id, Onboarding_Request__c> oldMap, List<Onboarding_Request__c> newList) {
        allowOrDenyDeleteOfOnboardingRequest(oldMap);
    }
    
    public static void handleBeforeInsert(List<Onboarding_Request__c> newList) { 
        enrichOnboardingRequestAttributes(null, newList);
    }
    
    public static void handleBeforeUpdate(Map<Id, Onboarding_Request__c> OldMap, List<Onboarding_Request__c> newList) { 
        System.debug('#### OnboardingRequestTriggerHandler::handleBeforeUpdate()');
        preventInlineEditOfRequiredFields(oldMap, newList); //must be called first
        handleApprovalComments(newList, oldMap);
        checkAndMaintainStateOfReq(OldMap, NewList);
        enrichOnboardingRequestAttributes(OldMap, newList);
        copyAccountNameIntoTextField(newList);
        maintainRegisteredAddress(newList);
        validateRequestBeforeApproval(oldMap, newList);
        setSalesPersonFromSalesTeamForCoverage(oldMap, newList);
        //setSalesCAOApprovalDate(newList, oldMap);
    }
    
    public static void handleAfterInsert(List<Onboarding_Request__c> NewList) {
        System.debug('#### OnboardingRequestTriggerHandler::handleAfterInsert()');
    }
    
    public static void handleAfterUpdate(Map<Id, Onboarding_Request__c> OldMap, List<Onboarding_Request__c> NewList) {
        System.debug('#### OnboardingRequestTriggerHandler::handleAfterUpdate()');
        updateCampaignOwnerOnSalesReqChange(oldMap, newList);
        setupCampaign(null, NewList);
        setupPrimaryContact(OldMap, NewList);
        //checkAndSubmitForSalesCaoApproval(OldMap, NewList);
        updateOnboardingContactType(oldMap, newList);
        shareOnbRequestWithRequestor(oldMap, newList);
        shareWithDeskHeadApprover(oldMap, newList);
        handleCampaignShareWithRequestor(oldMap, newList);
        CampaignService.shareCampaignWithDeskHead(oldMap, NewList);
        manageApprovals(oldMap, newList);
        getSubmittedRequestsForPDF(oldMap, newList);
    }
    
    /**
    * @Description: Share onboarding request with relevant groups and start relevant approval process 
    */
    public static void manageApprovals(Map<Id, Onboarding_Request__c> oldMap, List<Onboarding_Request__c> newList) {
        List<String> salesCAOApprovalReqIds = new List<String>();
        Map<String, List<Onboarding_Request__c>> approvalTypeToObRequest = new Map<String, List<Onboarding_Request__c>> {
            OnboardingReqAndProdService.PRIME_APPROVAL_SUB_STATUS => new List<Onboarding_Request__c>(), 
            OnboardingReqAndProdService.FUTURES_CLEARING_APPROVAL_SUB_STATUS => new List<Onboarding_Request__c>(),
            OnboardingReqAndProdService.NFPE_APPROVAL_SUB_STATUS => new List<Onboarding_Request__c>()
        };
        
        for (Onboarding_Request__c newRequest : newList) { 
            Onboarding_Request__c oldRequest = oldMap.get(newRequest.Id);
            if(newRequest.Status__c == OnboardingReqAndProdService.ADDT_APPROVAL_STATUS && newRequest.Sub_Status__c == OnboardingReqAndProdService.PRIME_APPROVAL_SUB_STATUS && newRequest.Sub_Status__c != oldRequest.Sub_Status__c && !newRequest.Prime_Approval_Completed__c && newRequest.Prime_Product_Selected__c >= 1) {
                approvalTypeToObRequest.get(OnboardingReqAndProdService.PRIME_APPROVAL_SUB_STATUS).add(newRequest);
            } else if (newRequest.Status__c == OnboardingReqAndProdService.SALES_CAO_APPROVAL_STATUS && newRequest.Status__c != oldRequest.Status__c && !newRequest.Is_Sales_CAO_Approval_Completed__c) {
                salesCAOApprovalReqIds.add(newRequest.Id);
            } else if (newRequest.Status__c == OnboardingReqAndProdService.ADDT_APPROVAL_STATUS && newRequest.Additional_Approval_Required__c && newRequest.Sub_Status__c != oldRequest.Sub_Status__c) {
                if(newRequest.Sub_Status__c == OnboardingReqAndProdService.NFPE_APPROVAL_SUB_STATUS && !newRequest.NFPE_Approval_Completed__c && newRequest.NFPE_Product_Selected__c >= 1) {
                    approvalTypeToObRequest.get(OnboardingReqAndProdService.NFPE_APPROVAL_SUB_STATUS).add(newRequest);
                } else if (newRequest.Sub_Status__c == OnboardingReqAndProdService.FUTURES_CLEARING_APPROVAL_SUB_STATUS && newRequest.Futures_Clearing_Product_Selected__c >= 1 && !newRequest.Futures_Clearing_Approval_Completed__c) {
                    approvalTypeToObRequest.get(OnboardingReqAndProdService.FUTURES_CLEARING_APPROVAL_SUB_STATUS).add(newRequest);
                }
            }
        }
        
        if (!approvalTypeToObRequest.get(OnboardingReqAndProdService.PRIME_APPROVAL_SUB_STATUS).isEmpty()) {
            // Share records with Prime Primary and Secondary Groups then Start Pime Approval Process
            OnboardingReqAndProdService.shareOnbRequestWithGroups(approvalTypeToObRequest.get(OnboardingReqAndProdService.PRIME_APPROVAL_SUB_STATUS), UserHelper.PRIME_APPROVAL_GROUP_DEV_NAMES, 'Edit');
            CampaignService.shareOnbReqCampaignWithGroups(approvalTypeToObRequest.get(OnboardingReqAndProdService.PRIME_APPROVAL_SUB_STATUS), UserHelper.PRIME_APPROVAL_GROUP_DEV_NAMES, 'Edit');
            OnboardingReqAndProdService.startOnboardingApprovalProcess(approvalTypeToObRequest.get(OnboardingReqAndProdService.PRIME_APPROVAL_SUB_STATUS), 'Onboarding_Request_Prime_Approval');
            
        } 
        if (!salesCAOApprovalReqIds.isEmpty()) {
            OnboardingReqAndProdService.submitOnbReqForSalesCaoApproval(salesCAOApprovalReqIds);
        } 
        if (!approvalTypeToObRequest.get(OnboardingReqAndProdService.NFPE_APPROVAL_SUB_STATUS).isEmpty()) {
            // Share records with NFPE Primary and Secondary Groups then Start NFPE Approval Process
            OnboardingReqAndProdService.shareOnbRequestWithGroups(approvalTypeToObRequest.get(OnboardingReqAndProdService.NFPE_APPROVAL_SUB_STATUS), UserHelper.NFPE_APPROVAL_GROUP_DEV_NAMES, 'Edit');
            CampaignService.shareOnbReqCampaignWithGroups(approvalTypeToObRequest.get(OnboardingReqAndProdService.NFPE_APPROVAL_SUB_STATUS), UserHelper.NFPE_APPROVAL_GROUP_DEV_NAMES, 'Edit');
            OnboardingReqAndProdService.startOnboardingApprovalProcess(approvalTypeToObRequest.get(OnboardingReqAndProdService.NFPE_APPROVAL_SUB_STATUS), 'Onboarding_Request_NFPE_Approval');
        } 
        if (!approvalTypeToObRequest.get(OnboardingReqAndProdService.FUTURES_CLEARING_APPROVAL_SUB_STATUS).isEmpty()) {
            // Share records with Futures Clearing Primary and Secondary Groups then Start futures clearing approval process
            OnboardingReqAndProdService.shareOnbRequestWithGroups(approvalTypeToObRequest.get(OnboardingReqAndProdService.FUTURES_CLEARING_APPROVAL_SUB_STATUS), UserHelper.FUTURES_CLEARING_APPROVAL_GROUP_DEV_NAMES, 'Edit');
            CampaignService.shareOnbReqCampaignWithGroups(approvalTypeToObRequest.get(OnboardingReqAndProdService.FUTURES_CLEARING_APPROVAL_SUB_STATUS), UserHelper.FUTURES_CLEARING_APPROVAL_GROUP_DEV_NAMES, 'Edit');
            OnboardingReqAndProdService.startOnboardingApprovalProcess(approvalTypeToObRequest.get(OnboardingReqAndProdService.FUTURES_CLEARING_APPROVAL_SUB_STATUS), 'Onboarding_Req_Futures_Clearing_Approval');
        }
    }
    
    public static void validateRequestBeforeApproval(Map<Id, Onboarding_Request__c> oldMap, List<Onboarding_Request__c> newList) {
        for(Onboarding_Request__c newRequest : newList) {
            Onboarding_Request__c oldRequest = oldMap.get(newRequest.Id);
            if (oldRequest.Status__c == 'Draft' && newRequest.Status__c == 'Desk Head Approval') {
                try {
                    OnboardingRequestValidation validation = new OnboardingRequestValidation(newRequest.Id);
                } catch (Exception e){
                    newRequest.addError(e.getMessage());
                }
            }
        }    
    }
    
    public static void handleCampaignShareWithRequestor(Map<Id, Onboarding_Request__c> oldMap, List<Onboarding_Request__c> newList) {
        Map<String,String> campaignIdToRequestorId = new Map<String,String>();
        
        for (Onboarding_Request__c newRequest : newList) {
            Onboarding_Request__c oldRequest = oldMap.get(newRequest.Id);
            if (newRequest.Requestor__c != null && newRequest.Sales_Requestor__c != null) {
                if (newRequest.Campaign__c != null && oldRequest.Sales_Requestor__c != newRequest.Sales_Requestor__c) {
                    campaignIdToRequestorId.put(newRequest.Campaign__c, newRequest.Requestor__c);
                } else if (oldRequest.Campaign__c == null && newRequest.Campaign__c != null) {
                    campaignIdToRequestorId.put(newRequest.Campaign__c, newRequest.Requestor__c);
                }
            }
        }
        
        CampaignService.shareCampaignWithRequestor(campaignIdToRequestorId);
    }
    
    public static void updateCampaignOwnerOnSalesReqChange(Map<Id, Onboarding_Request__c> oldMap, List<Onboarding_Request__c> newList) {
        List<Campaign> campaignsToUpdate = new List<Campaign>(); 
        for(Onboarding_Request__c newReq : newList) {
            Onboarding_Request__c oldReq = oldMap.get(newReq.Id);
            if(String.isNotBlank(newReq.Campaign__c) && newReq.Sales_Requestor__c != null && oldReq.Sales_Requestor__c != newReq.Sales_Requestor__c) {
                Campaign campaignToUpdate = new Campaign(
                    Id = newReq.Campaign__c,
                    OwnerId = newReq.Sales_Requestor__c
                );
                campaignsToUpdate.add(campaignToUpdate);
            }
        }
        
        update campaignsToUpdate;
    }
    
    public static void getSubmittedRequestsForPDF(Map<Id,Onboarding_Request__c> oldMap, List<Onboarding_Request__c> newList) {
        Set<Id> submittedRequests = new Set<Id>();
        for (Onboarding_Request__c newReq : newList) {
            Onboarding_Request__c oldReq = oldMap.get(newReq.Id);
            if (oldReq.Status__c != 'Submitted' && newReq.Status__c == 'Submitted') {
                submittedRequests.add(newReq.Id);
            }
        }
        if (!submittedRequests.isEmpty() && !test.isRunningTest()) {
            generatePDF(submittedRequests);
        }
    }
    
    @future(callout=true)
    public static void generatePDF(Set<Id> submittedRequests) {
        for (Id requestId : submittedRequests) {
            SubmitFinalOnbReqController.createFileAndSendEmail(requestId);
        }
    }
    
    public static void copyAccountNameIntoTextField(List<Onboarding_Request__c> newList) {
        Map<Id,Onboarding_Request__c> existingOnbRequests = new Map<Id,Onboarding_Request__c>([SELECT Id, RM_Account__r.Name FROM Onboarding_Request__c WHERE Id IN :newList]);
        for(Onboarding_Request__c onbReq : newList) {
            if(existingOnbRequests.containsKey(onbReq.Id)){
                onbReq.Account_Name__c = existingOnbRequests.get(onbReq.Id).RM_Account__r.Name;
            }
        }
    }
    
    public static void setupCampaign(Map<Id, Onboarding_Request__c> OldMap, List<Onboarding_Request__c> NewList) {
        System.debug('#### OnboardingRequestTriggerHandler::setupCampaign()');
        List<String> OnbReqIdList = new List<String>();
        for(Onboarding_Request__c oNewObReq : NewList) {
            //Onboarding_Request__c oOldObReq = OldMap != null ? OldMap.get(oNewObReq.Id) : null;
            // Campaign is not set and the Who_did_you_meet_from_the_client_side__c is being set for the first time
            if(String.isBlank(oNewObReq.Campaign__c)) {
                OnbReqIdList.add(oNewObReq.Id);
            }
        }
        if(!OnbReqIdList.isEmpty()) {
            OnboardingReqAndProdService.setupCampaignForOnbRequestAsynch(OnbReqIdList);
        }
    }
    
    public static void setupPrimaryContact(Map<Id, Onboarding_Request__c> OldMap, List<Onboarding_Request__c> NewList) {
        System.debug('#### OnboardingRequestTriggerHandler::setupPrimaryContact()');
        List<Onboarding_Request__c> OnbReqList = new List<Onboarding_Request__c>();
        for(Onboarding_Request__c oNewObReq : NewList) {
            Onboarding_Request__c oOldObReq = OldMap.get(oNewObReq.Id);
            if( (String.isNotBlank(oNewObReq.Campaign__c) && String.isBlank(oOldObReq.Campaign__c)) ||
                    (oNewObReq.Who_did_you_meet_from_the_client_side__c != oOldObReq.Who_did_you_meet_from_the_client_side__c) ) {
                OnbReqList.add(oNewObReq);
            }
        }
        if(!OnbReqList.isEmpty()) {
            OnboardingReqAndProdService.setupPrimaryContact(OnbReqList);
        }
    }
    
    public static void maintainRegisteredAddress(List<Onboarding_Request__c> newList) {
        for (Onboarding_Request__c onbReq : newList) {
            if(onbReq.Registered_Address_Country__c != null) {
                if(String.isBlank(onbReq.Registered_Address_Street__c)) {
                    onbReq.Registered_Address_Street__c = '**Not Entered**';
                }
                if(String.isBlank(onbReq.Registered_Address_City__c)) {
                    onbReq.Registered_Address_City__c = '**Not Entered**';
                }
            } else {
                onbReq.Registered_Address_City__c = null;
                onbReq.Registered_Address_Street__c = null;
                onbReq.Registered_Address_Postal_Code__c = null;
                onbReq.Registered_Address_State__c = null;
                onbReq.Registered_Address_Country__c = null;
            }
        }
    }
    
    // 1. If new status is Draft but old Status was Submitted or Sent (Request was Recalled) ==> Reset all variables
    // 2. If Desk Head Approval is complete ==> Set status to Prime Approval or Sales CAO Approval
    // 3. If Sales CAO Approval is completed or Additional Approval is required ==> Update Sub Status to correct additional approval step
    // 4. If Additional Approval is completed / not required and Sales CAO Approval is completed ==> Set status to submitted
    public static void checkAndMaintainStateOfReq(Map<Id, Onboarding_Request__c> oldMap, List<Onboarding_Request__c> newList) {
        for(Onboarding_Request__c newReq : newList) {
            Onboarding_Request__c oldReq = oldMap.get(newReq.Id);

            if(newReq.Status__c == OnboardingReqAndProdService.DRAFT_STATUS && (oldReq.Status__c == OnboardingReqAndProdService.SUBMITTED_STATUS || oldReq.Status__c == OnboardingReqAndProdService.SENT_STATUS)) {
                newReq.Is_Sales_CAO_Approval_Completed__c = false;
                newReq.Sales_CAO_Approver__c = null;
                newReq.NFPE_Approval_Completed__c = false;
                newReq.Futures_Clearing_Approval_Completed__c = false;
                newReq.Prime_Approval_Completed__c = false;
                newReq.Sub_Status__c = null;
            } else if(newReq.Status__c == OnboardingReqAndProdService.DESK_HEAD_APPROVAL_STATUS && newReq.Sub_Status__c ==  OnboardingReqAndProdService.SUCCESS_SUB_STATUS && newReq.Sub_Status__c != oldReq.Sub_Status__c) {
                if(newReq.Prime_Product_Selected__c >= 1 && !newReq.Prime_Approval_Completed__c) { 
                    newReq.Status__c = OnboardingReqAndProdService.ADDT_APPROVAL_STATUS;
                    newReq.Sub_Status__c = OnboardingReqAndProdService.PRIME_APPROVAL_SUB_STATUS;
                } else if(!newReq.Is_Sales_CAO_Approval_Completed__c) {
                    newReq.Status__c = OnboardingReqAndProdService.SALES_CAO_APPROVAL_STATUS;
                    newReq.Sub_Status__c = null;
                }
            } else if ((newReq.Status__c == OnboardingReqAndProdService.SALES_CAO_APPROVAL_STATUS && !oldReq.Is_Sales_CAO_Approval_Completed__c && newReq.Is_Sales_CAO_Approval_Completed__c) || (newReq.Status__c == OnboardingReqAndProdService.ADDT_APPROVAL_STATUS && newReq.Sub_Status__c == OnboardingReqAndProdService.SUCCESS_SUB_STATUS && newReq.Sub_Status__c != oldReq.Sub_Status__c)) {
                if(!oldReq.Is_Sales_CAO_Approval_Completed__c && newReq.Is_Sales_CAO_Approval_Completed__c) {
                    newReq.Sales_CAO_Approver__c = UserInfo.getUserId();
                    newReq.Sales_CAO_Approval_DateTime__c = DateTime.now();
                }
                if(newReq.Additional_Approval_Required__c) {
                    if(newReq.NFPE_Product_Selected__c >= 1 && !newReq.NFPE_Approval_Completed__c) {
                        newReq.Status__c = OnboardingReqAndProdService.ADDT_APPROVAL_STATUS;
                        newReq.Sub_Status__c = OnboardingReqAndProdService.NFPE_APPROVAL_SUB_STATUS;
                    } else if (newReq.Futures_Clearing_Product_Selected__c >= 1 && !newReq.Futures_Clearing_Approval_Completed__c) {
                        newReq.Status__c = OnboardingReqAndProdService.ADDT_APPROVAL_STATUS;
                        newReq.Sub_Status__c = OnboardingReqAndProdService.FUTURES_CLEARING_APPROVAL_SUB_STATUS;
                    } 
                } else {
                    newReq.Status__c = OnboardingReqAndProdService.SUBMITTED_STATUS;
                    newReq.Sub_Status__c = null;
                }
            } else {
                System.debug('Unknown Error Occured OnboardingRequestTriggerHandler.checkAndMaintainStateOfReq() @@@');
            }
        }
    }
    
    /*public static void checkAndSubmitForSalesCaoApproval(Map<Id, Onboarding_Request__c> OldMap, List<Onboarding_Request__c> NewList) {
        System.debug('#### OnbRequestTriggerHandler::checkAndSubmitForSalesCaoApproval');
        List<String> OnbReqToSubmitForSalesCaoApprList = new List<String>();
        
        for(Onboarding_Request__c oNewOnbReq : NewList) {
            if(!OnbReqAlreadySubmittedForApproval.contains(oNewOnbReq.Id)) {
                Onboarding_Request__c oOldOnbReq = OldMap != null ? OldMap.get(oNewOnbReq.Id) : null;
                Boolean hasStatusChngdToInSalesCaoAppr = oNewOnbReq.Status__c=='Sales CAO Approval' && (oOldOnbReq==null || oOldOnbReq.Status__c!='Sales CAO Approval');
                if(hasStatusChngdToInSalesCaoAppr) {
                    OnbReqToSubmitForSalesCaoApprList.add(oOldOnbReq.Id);
                }
            }
        }
        if(!OnbReqToSubmitForSalesCaoApprList.isEmpty()) {
            OnbReqAlreadySubmittedForApproval.addAll(OnbReqToSubmitForSalesCaoApprList);
            OnboardingReqAndProdService.submitOnbReqForSalesCaoApproval(OnbReqToSubmitForSalesCaoApprList);
        }
    }*/
    
    /*
     * Description: Prevents users from being able to modify required fields using inline edit. 
     */
    public static void preventInlineEditOfRequiredFields(Map<Id, Onboarding_Request__c> oldMap, List<Onboarding_Request__c> newList) {
        if (oldMap != null && !oldMap.isEmpty()) {
            Set<String> fieldsToIgnore = FieldSetService.getFieldSetValuesByAPIName('Onboarding_Request__c', 'Bypass_Field_Edit_Validation');
            Set<String> requiredFields = OnboardingReqAndProdService.getObRequestRequiredFieldNames();
            for (Onboarding_Request__c newRequest : newList) {
                Onboarding_Request__c oldRequest = oldMap.get(newRequest.Id);
                if (!newRequest.Request_Edited_From_Flow__c) {
                    for (String requiredFieldName : requiredFields) {
                        if (!fieldsToIgnore.contains(requiredFieldName.toLowerCase()) && newRequest.get(requiredFieldName) != oldRequest.get(requiredFieldName)) {
                            newRequest.addError('Please use the "Edit Request" button to update this request.');
                        }
                    }
                } else {
                    newRequest.Request_Edited_From_Flow__c = false;
                }
            }
        }
    }

	 /*
     * Description: Updates the Onboarding Contact Type of the Contact selected in the Pre-Onboarding flow.
     */    
    public static void updateOnboardingContactType(Map<Id,Onboarding_Request__c> oldMap, List<Onboarding_Request__c> newList) {
        Map<Id, String> contactIdToObContactType = new Map<Id, String>(); 
        for (Onboarding_Request__c newRequest : newList) {
            Onboarding_Request__c oldRequest = oldMap != null ? oldMap.get(newRequest.Id) : null;
            if (newRequest.Who_did_you_meet_from_the_client_side__c != null && 
                (oldRequest == null || newRequest.Onboarding_Contact_Type__c != oldRequest.Onboarding_Contact_Type__c)) {
                contactIdToObContactType.put(newRequest.Who_did_you_meet_from_the_client_side__c, newRequest.Onboarding_Contact_Type__c);
            }
        }
        
        List<Contact> contactsToUpdate = new List<Contact> ();
        for (Id contactId : contactIdToObContactType.keySet()) {
            Contact contact = new Contact (
                Id = contactId,
            	Onboarding_Contact_Type__c = contactIdToObContactType.get(contactId)	
            );
            contactsToUpdate.add(contact);
        }
        
        try {
            update contactsToUpdate;
        } catch (Exception e) {
            System.debug('Failed To Update Contact - IN OpportunityRequestTriggerHandler.updateOnboardingContactType ' + e);
        }
    }

    //Method to Share Onb record with DeskHeadApprover as DeskHead can be in different hierarchy and role
    public static void shareWithDeskHeadApprover(Map<Id,Onboarding_Request__c> oldMap, List<Onboarding_Request__c> newList){
        System.debug('--shareWithDeskHeadApprover--');
        Onboarding_Request__Share onbShare;
        List<Onboarding_Request__Share> onbShareAddList = new List<Onboarding_Request__Share>();
        List<String> onbIdList = new List<String>();
        List<String> deskHeadId = new List<String>();
        Boolean isDeskHeadChanged = false;

        for(Onboarding_Request__c oNewOnbReq : NewList) {
            Onboarding_Request__c oldRequest = oldMap != null ? oldMap.get(oNewOnbReq.Id) : null;

            if(oNewOnbReq != null && oNewOnbReq.Desk_Head_Approver__c != null){
                //share it with Desk_Head_Approver in case of Insertion
                onbShare = new Onboarding_Request__Share();
                onbShare.ParentId = oNewOnbReq.Id;
                onbShare.UserOrGroupId = oNewOnbReq.Desk_Head_Approver__c;
                onbShare.AccessLevel = 'Edit';
                //onbShare.RowCause = Schema.Onboarding_Request__Share.RowCause.Manual;
                
                onbShareAddList.add(onbShare);

                if(oNewOnbReq.Desk_Head_Approver__c != null && oldRequest != null &&  oldRequest.Desk_Head_Approver__c != null 
                    && oNewOnbReq.Desk_Head_Approver__c != oldRequest.Desk_Head_Approver__c){
                        //remove existing assigned Sharing if any                        
                        isDeskHeadChanged = true;
                        onbIdList.add(oNewOnbReq.Id);
                        deskHeadId.add(oldRequest.Desk_Head_Approver__c);
                        System.debug('--onbIdList--' + onbIdList + '--deskHeadId--' + deskHeadId);
                }
            }
        }

        if(isDeskHeadChanged){
            List<Onboarding_Request__Share> onbShareDelList = [SELECT Id FROM Onboarding_Request__Share 
                            WHERE ParentId IN :onbIdList AND USerOrGroupId IN :deskHeadId];
            
            if(onbShareDelList != null && onbShareDelList.size() > 0){
                List<Database.DeleteResult> resultList = Database.delete(onbShareDelList,false) ;
                System.debug('resultList: '+resultList.size());
                for(Integer i=0; i<resultList.size(); i++){            
                    Database.DeleteResult resultObj = resultList.get(i);
                    if(!resultObj.isSuccess()){ 
                        for(Database.Error errorObj : resultObj.getErrors()){
                            if(String.isNotEmpty(errorObj.getMessage())){
                                System.debug('Error on Delete. Error Message: '+errorObj.getMessage());
                            }
                        }
                    }
                }
            }
        }
        if(onbShareAddList != null){
            List<Database.SaveResult> srList = Database.insert(onbShareAddList,false);
            // Process the save results.
            for(Database.SaveResult sr : srList){
                if(sr.isSuccess()){
                                // Indicates success
                                System.debug('--Access given to Desk Head Approver Successfull');
                            }
                else {
                    // Get first save result error.
                    Database.Error err = sr.getErrors()[0];
                    
                    // Check if the error is related to trival access level.
                    // Access level must be more permissive than the object's default.
                    // These sharing records are not required and thus an insert exception is acceptable. 
                    if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
                            err.getMessage().contains('AccessLevel')){
                        // Indicates success.
                        System.debug('--1. Error--' + err.getStatusCode());
                    }
                    else{
                        // Indicates failure.
                        System.debug('--2. Error--' + err.getStatusCode());
                    }
                }
            }            
        }   
    }

    public static void shareOnbRequestWithRequestor(Map<Id, Onboarding_Request__c> oldMap, List<Onboarding_Request__c> newList) {
        if (oldMap != null && !oldMap.isEmpty()) {
            List<Onboarding_Request__Share> onbShareToAdd = new List<Onboarding_Request__Share>();

            // Create Share for Requestor When Sales Requestor is first populated
            for (Onboarding_Request__c newRequest : newList) {
                Onboarding_Request__c oldRequest = oldMap.get(newRequest.Id);
                if (oldRequest != null && newRequest.Sales_Requestor__c != null && newRequest.Requestor__c != null && oldRequest.Sales_Requestor__c != newRequest.Sales_Requestor__c) {
                    Onboarding_Request__Share onbShare = new Onboarding_Request__Share();
                    onbShare.ParentId = newRequest.Id;
                    onbShare.UserOrGroupId = newRequest.Requestor__c;
                    onbShare.AccessLevel = 'Edit';
                    onbShareToAdd.add(onbShare);
                } 
            }
            
            if (!onbShareToAdd.isEmpty()) {
                List<Database.SaveResult> saveResults = Database.insert(onbShareToAdd,false);
                for (Database.SaveResult saveRes : saveResults) {
                    if (saveRes.isSuccess()) {
                        System.debug('--Onboarding Req Access given to Sales Requestor Successfull');
                    } else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : saveRes.getErrors()) {
                            if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  err.getMessage().contains('AccessLevel')){
                                System.debug('--1. Error--' + err.getStatusCode());
                            } else{
                                // Indicates failure.
                                System.debug('--2. Error--' + err.getStatusCode());
                            }
                        }
                    }
                }
            }
        }
    }    
    
    public static void enrichOnboardingRequestAttributes(Map<Id, Onboarding_Request__c> OldMap, List<Onboarding_Request__c> newList){
         
        List<String> whoIdList = new List<String>();      

        for(Onboarding_Request__c oNewOnbReq : NewList) {
            Onboarding_Request__c oldRequest = oldMap != null ? oldMap.get(oNewOnbReq.Id) : null;

            if( oNewOnbReq.Who_did_you_meet_from_the_client_side__c != null){                
                whoIdList.add(oNewOnbReq.Who_did_you_meet_from_the_client_side__c);
             }
             else{
                oNewOnbReq.Primary_Campaign_Member_Id__c = null;
                oNewOnbReq.Primary_Campaign_Member_Name__c = null;
             }
        }

        if(whoIdList != null && whoIdList.size() > 0){
            Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Name FROM Contact WHERE Id IN :whoIdList]);
            for(Onboarding_Request__c oNewOnbReq : NewList){
                if(oNewOnbReq.Who_did_you_meet_from_the_client_side__c != null){
                    Contact con = contactMap.get(oNewOnbReq.Who_did_you_meet_from_the_client_side__c);

                    oNewOnbReq.Primary_Campaign_Member_Id__c = con.Id;
                    oNewOnbReq.Primary_Campaign_Member_Name__c = con.Name;
                }
            }
        }
    }
    
    public static void allowOrDenyDeleteOfOnboardingRequest(Map<Id, Onboarding_Request__c> oldMap) {
        String loggedInUserId = UserInfo.getUserId();
        Boolean isAutomatedProcessUser = UserInfo.getUserType() == 'AutomatedProcess' ? true : false;
        for (Onboarding_Request__c onbReq : oldMap.values()) {
            if (isAutomatedProcessUser && onbReq.Status__c != 'Draft') {
                onbReq.addError('Failed to delete ' + onbReq.Name + '. ' + 'Only Requests In Draft Stage can be Deleted');
            } else if (!isAutomatedProcessUser && (onbReq.Status__c != 'Draft' || (onbReq.Status__c == 'Draft' && onbReq.Sales_Requestor__c != loggedInUserId && onbReq.Requestor__c != loggedInUserId))) {
                onbReq.addError('Failed to delete ' + onbReq.Name + '. ' + 'The request must be in the Draft stage and you must be a Requestor or Sales Requestor');
            }
        }
    }
    
    /*public static void setSalesCAOApprovalDate(List<Onboarding_Request__c> newList, Map<Id, Onboarding_Request__c> oldMap) {
        for (Onboarding_Request__c newRequest : newList) {
            Onboarding_Request__c oldRequest =  oldMap.containsKey(newRequest.Id) ? oldMap.get(newRequest.Id) : null;
            if (oldRequest != null && oldRequest.Status__c == 'Sales CAO Approval' && newRequest.status__c == 'Submitted') {
                newRequest.Sales_CAO_Approval_DateTime__c = newRequest.LastModifiedDate;
            }  
        }
    }*/
    
    public static void setSalesPersonFromSalesTeamForCoverage(Map<Id,Onboarding_Request__c> oldMap, List<Onboarding_Request__c> newList) {
        Set<String> salesRequestorIds = new Set<String>();
        
        // Get Set of Sales Requestor Ids
        for(Onboarding_Request__c newReq : newList) {
            Onboarding_Request__c oldReq = oldMap.containsKey(newReq.Id) ? oldMap.get(newReq.Id) : null;
            if (oldReq != null && String.isNotBlank(newReq.Sales_Requestor__c) && oldReq.Sales_Requestor__c != newReq.Sales_Requestor__c) {
                salesRequestorIds.add(newReq.Sales_Requestor__c);
            }
        }
                
        if (!salesRequestorIds.isEmpty()) {
            Map<String,String> salesRequestorIdToSalesTeamForCovId = new Map<String,String>();
            // Get Sales Team For Coverage Id for Sales Requestor
            for(Sales_Team_for_Coverage__c salesTeamForCov : [SELECT Id, Desk_Name__c, OwnerId FROM Sales_Team_for_Coverage__c WHERE OwnerId IN :salesRequestorIds AND Active__c = true AND Desk_Name__c != null]) {
                if(!salesRequestorIdToSalesTeamForCovId.containsKey(salesTeamForCov.OwnerId)) {
                    salesRequestorIdToSalesTeamForCovId.put(salesTeamForCov.OwnerId, salesTeamForCov.Id);
                }
            }
                        
            if(!salesRequestorIdToSalesTeamForCovId.isEmpty()) {
                // update Onboarding Requests
                for(Onboarding_Request__c onbReq : newList) {
                    if (onbReq.Sales_Requestor__c != null) {
                        onbReq.Sales_Team_for_Coverage__c = salesRequestorIdToSalesTeamForCovId.get(onbReq.Sales_Requestor__c);
                    }
                }
            }
        } 
    }

    public static void handleApprovalComments (List<Onboarding_Request__c> newList, Map<Id, Onboarding_Request__c> oldMap) {
        Set<Id> onboardingReqIds = new Set<Id>();
        Set<String> acceptedStatuses = new Set<String> {'Draft', 'Sales CAO Approval', 'Submitted', 'Additional Approval'};
            
        for (Onboarding_Request__c newReq : newList) {
            Onboarding_Request__c oldReq  = oldMap.containsKey(newReq.Id) ? oldMap.get(newReq.Id) : null;
             
            if (oldReq != null && oldReq.Status__c != OnboardingReqAndProdService.SENT_STATUS && oldReq.Status__c != OnboardingReqAndProdService.SUBMITTED_STATUS && 
                ((newReq.Status__c == OnboardingReqAndProdService.DRAFT_STATUS && oldReq.Status__c != newReq.Status__c) || 
                 ((newReq.Status__c == OnboardingReqAndProdService.ADDT_APPROVAL_STATUS || newReq.Status__c == OnboardingReqAndProdService.DESK_HEAD_APPROVAL_STATUS) && newReq.Sub_Status__c == OnboardingReqAndProdService.SUCCESS_SUB_STATUS && oldReq.Sub_Status__c != newReq.Sub_Status__c) || 
                 (newReq.Status__c == OnboardingReqAndProdService.SALES_CAO_APPROVAL_STATUS && newReq.Is_Sales_CAO_Approval_Completed__c && !oldReq.Is_Sales_CAO_Approval_Completed__c))) {
                     onboardingReqIds.add(newReq.Id);
            }
        }
        
        if (!onboardingReqIds.isEmpty()) {
            Map<Id, ProcessInstance> onbReqIdToApprovalHistory = new Map<Id, ProcessInstance> ();
            List<ProcessInstance> processInstances = [SELECT Id, ProcessDefinition.DeveloperName, Status, TargetObjectId, (SELECT Id, StepStatus, Actor.Name, Comments FROM StepsAndWorkitems WHERE StepStatus = 'Approved' OR StepStatus = 'Rejected' ORDER BY CreatedDate DESC) FROM ProcessInstance WHERE TargetObjectId IN :onboardingReqIds AND (Status = 'Approved' OR Status = 'Rejected') ORDER BY CompletedDate DESC];
            
            for (ProcessInstance pi : processInstances) {
                if (!onbReqIdToApprovalHistory.containsKey(pi.TargetObjectId)) {
                    onbReqIdToApprovalHistory.put(pi.TargetObjectId, pi);
                }
            }  
            
            if (!onbReqIdToApprovalHistory.isEmpty()) {
                for (Onboarding_Request__c newReq : newList) {
                    if (onbReqIdToApprovalHistory.containsKey(newReq.Id)) {
                        ProcessInstance processInfo = onbReqIdToApprovalHistory.get(newReq.Id);
                        ProcessInstanceHistory processHistory = processInfo.StepsAndWorkitems[0];

                        String commentHistory = String.isNotBlank(processHistory.Comments) ? processHistory.Comments : '';
                        String approvalProcessName = '';
                        switch on processInfo.ProcessDefinition.DeveloperName {
                            when 'Onb_Req_Desk_Head_Approval_Process' {
                                approvalProcessName = 'Desk Head';
                            }
                            when 'Onb_Req_Sales_CAO_Approval_Process' {
                                approvalProcessName = 'Sales CAO';
                            }
                            when 'Onboarding_Request_NFPE_Approval' {
                                approvalProcessName = 'NFPE Approval';
                            }
                            when 'Onboarding_Req_Futures_Clearing_Approval' {
                                approvalProcessName = 'Futures Clearing Approval';
                            } 
                            when 'Onboarding_Request_Prime_Approval' {
                                approvalProcessName = 'Prime Approval';
                            }
                        }
                        String stepStatus = processHistory.StepStatus == 'Rejected' ? 'Referred Back' : processHistory.StepStatus;
                        String newCommentEntry = '[' + approvalProcessName + ' : ' + stepStatus + ' : ' + processHistory.Actor.Name + ' : ' + Datetime.now() + ']' + ' - ' + commentHistory;
                        
                        newReq.Approval_Comments__c = String.isNotBlank(newReq.Approval_Comments__c) ? newReq.Approval_Comments__c + '\n\n' + newCommentEntry : newCommentEntry; 
                    }
                }
            }  
        }
    }

    
    /*
        Map<UserHelper.USER_DETAILS_AND_PERMISSIONS, Set<String>> UserPermissionMap = SchRequestService.getSchReqUserDetailsAndPermissions(NewList);
        UserHelper.USER_DETAILS_AND_PERMISSIONS jpnRegEnum = UserHelper.USER_DETAILS_AND_PERMISSIONS.IS_ROLE_BASED_REGION_JAPAN;
        UserHelper.USER_DETAILS_AND_PERMISSIONS schApprEnum = UserHelper.USER_DETAILS_AND_PERMISSIONS.IS_SCH_APPROVER;
        
        for(SCH_Request__c oNewSchReq : NewList) {
            if(!SchReqAlreadySubmittedForApproval.contains(oNewSchReq.Id)) {
                SCH_Request__c oOldSchReq = OldMap != null ? OldMap.get(oNewSchReq.Id) : null;
                Boolean hasStatusChngdToInReview = oNewSchReq.Status__c=='In Review' && (oOldSchReq==null || oOldSchReq.Status__c!='In Review');
                Boolean firstApprJustCompleted = oNewSchReq.Is_First_Approval_Completed__c && !oOldSchReq.Is_First_Approval_Completed__c;
                Boolean isJpnUser = UserPermissionMap.get(jpnRegEnum)!=null && UserPermissionMap.get(jpnRegEnum).contains(oNewSchReq.CreatedById);
                Boolean isSchAppr = UserPermissionMap.get(schApprEnum)!=null && UserPermissionMap.get(schApprEnum).contains(oNewSchReq.CreatedById); 
                Boolean firstApprJustUnChkd = !oNewSchReq.Is_First_Approval_Completed__c && oOldSchReq!=null && 
                                            oOldSchReq.Is_First_Approval_Completed__c;
                Boolean hasSubStatusChangdToReferBack = oNewSchReq.Sub_Status__c=='Referred Back' && oOldSchReq!=null && 
                                                        oOldSchReq.Sub_Status__c=='Final Review';
                System.debug('hasStatusChngdToInReview : '+hasStatusChngdToInReview);
                System.debug('firstApprJustCompleted : '+firstApprJustCompleted);
                System.debug('isJpnUser : '+isJpnUser);
                System.debug('isSchAppr : '+isSchAppr);
                System.debug('firstApprJustUnChkd: '+firstApprJustUnChkd);
                System.debug('hasSubStatusChangdToReferBack: '+hasSubStatusChangdToReferBack);
                if((!oNewSchReq.Is_First_Approval_Completed__c && hasStatusChngdToInReview && isJpnUser && !isSchAppr) ||
                        (firstApprJustUnChkd && oNewSchReq.Status__c=='In Review' && hasSubStatusChangdToReferBack)) {
                    // First Approval Condition met
                    System.debug('First Approval');
                    SchReqToSubmitForFirstApprList.add(oNewSchReq.Id);
                }
                else if( (hasStatusChngdToInReview && !isJpnUser) ||
                        (hasStatusChngdToInReview && isJpnUser && isSchAppr) ||
                        (firstApprJustCompleted && oNewSchReq.Status__c=='In Review' && isJpnUser && 
                            !isSchAppr && oNewSchReq.Is_Request_Modified_By_First_Approver__c) ) {
                    System.debug('Second Approval');
                    
                    String queueId;
                    if(!isJpnUser) {
                        System.debug('1');
                        queueId = UserHelper.SchReqAprQueueIdByQueueDevNameMap.get(System.Label.SCH_Req_All_EDM_Approver_Queue_DeveloperName);
                    } else if(isSchAppr) {
                        System.debug('2');
                        queueId = UserHelper.SchReqAprQueueIdByQueueDevNameMap.get(String.format(System.Label.SCH_Req_Exclude_JPN_Approver_Queue_DeveloperName_Template, 
                                        new List<String>{oNewSchReq.createdById}));
                    } else if(oNewSchReq.Is_Request_Modified_By_First_Approver__c && String.isNotBlank(oNewSchReq.First_Approval_Done_By_User__c)) {
                        System.debug('3');
                        queueId = UserHelper.SchReqAprQueueIdByQueueDevNameMap.get(String.format(System.Label.SCH_Req_Exclude_JPN_Approver_Queue_DeveloperName_Template, 
                                        new List<String>{oNewSchReq.First_Approval_Done_By_User__c}));
                    } else {
                        System.debug('4');
                        oNewSchReq.addError('Failed to find next approver queue');
                        break;
                    }
                    SchReqToSubmitForFinalApprList.add(oNewSchReq.Id);
                }
            }
        } // end of - for(SCH_Request__c oNewSchReq : NewList) 
        if(!SchReqToSubmitForFirstApprList.isEmpty() || !SchReqToSubmitForFinalApprList.isEmpty()) {
            SchReqAlreadySubmittedForApproval.addAll(SchReqToSubmitForFirstApprList);
            SchReqAlreadySubmittedForApproval.addAll(SchReqToSubmitForFinalApprList);
            SchRequestService.submitSchReqForApproval(SchReqToSubmitForFirstApprList, SchReqToSubmitForFinalApprList);
        }
    }*/
}