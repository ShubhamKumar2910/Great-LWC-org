public with sharing class OnboardingReqAndProdController {
    
    public class OnbProdWrapper {
        @AuraEnabled
        public Onboarding_Product__c oOnbProd;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String subStatus;
        @AuraEnabled
        public String icon;
        @AuraEnabled
        public String iconVariant;

        public OnbProdWrapper(Onboarding_Product__c oOnbProd, String status, String subStatus) {
            //System.debug('status');
            this.oOnbProd = oOnbProd;
            this.status = status;
            if(status=='Completed') {
                if(subStatus=='Onboarded') {
                    icon = 'utility:check';
                    iconVariant = ''; // Completed - green
                } else if(subStatus=='Cancelled') {
                    icon = 'utility:close';
                    iconVariant = 'error'; // Cancelled - red
                }
            }  else {
                icon = 'utility:macros';
                iconVariant = ''; // In Progress - blue
            }
        }
    }
    
    public class OnbRequestWrapper {
        @AuraEnabled
        public Onboarding_Request__c oOnbReq;
        @AuraEnabled
        public Boolean isCurrentReq;
        @AuraEnabled
        public List<OnbProdWrapper> OnbProdWrapperList; 

        public OnbRequestWrapper(Onboarding_Request__c oOnbReq, Boolean isCurrentReq) {
            this.oOnbReq = oOnbReq;
            this.isCurrentReq = isCurrentReq;
            OnbProdWrapperList = new List<OnbProdWrapper>();
            if(oOnbReq!=null && oOnbReq.Onboarding_Products__r !=null) {
                for(Onboarding_Product__c oOnbProd : oOnbReq.Onboarding_Products__r) {
                    //System.debug('oOnbProd : '+oOnbProd);
                    OnbProdWrapperList.add(new OnbProdWrapper(oOnbProd, oOnbReq.Status__c, oOnbReq.Sub_Status__c)); 
                }
            } 
        }
    }

    @AuraEnabled //(cacheable=true)
    public static Boolean deleteProdReqs(List<String> ProdReqIdList) {
        System.debug('#### OnboardingProductFormController.deleteProdReqs()');
        Boolean isSuccess  = false;
        if(ProdReqIdList!=null && !ProdReqIdList.isEmpty()) {
            List<Onboarding_Product__c> ProdReqList = new List<Onboarding_Product__c>();
            for(String prodReqId : ProdReqIdList) {
                ProdReqList.add(new Onboarding_Product__c(Id=prodReqId));
            }
            delete ProdReqList;
            isSuccess = true;
        }
        return isSuccess;
    }
    
    @AuraEnabled
    public static Map<String, List<String>> getAdditionalApproverNames(String subStatus) {
        Map<String, List<String>> delegatedApproverNames = new Map<String, List<String>>();
        delegatedApproverNames.put('primary', new List<String>());
        delegatedApproverNames.put('secondary', new List<String>());
        
        if(String.isNotBlank(subStatus)) {
            List<String> additionalPermissions;
            if(subStatus == 'NFPE Approval') {
                additionalPermissions = UserHelper.NFPE_APPROVAL_GROUP_DEV_NAMES;
            } else if(subStatus == 'Futures Clearing Approval') {
                additionalPermissions = UserHelper.FUTURES_CLEARING_APPROVAL_GROUP_DEV_NAMES;
            } else if(subStatus == 'Prime Approval') {
                additionalPermissions = UserHelper.PRIME_APPROVAL_GROUP_DEV_NAMES;
            }
                        
            if (additionalPermissions != null) {
                Map<String, String> approverIdToType = new Map<String, String>();
                for (Group grp : [SELECT Id, DeveloperName, (SELECT Id, UserOrGroupId FROM GroupMembers) FROM Group WHERE DeveloperName IN :additionalPermissions]) {
                    String context = grp.DeveloperName.containsIgnoreCase('Primary') ? 'primary' : 'secondary';
                    for(GroupMember member : grp.GroupMembers) {
                        approverIdToType.put(member.UserOrGroupId, context);
                    }
                }
                
                for(User user : [SELECT Id, Name FROM User WHERE Id IN: approverIdToType.keySet()]) {
                    delegatedApproverNames.get(approverIdToType.get(user.Id)).add(user.Name);
                }
            }
        }
        return delegatedApproverNames;
    }
    
    @AuraEnabled
    public static List<Account_Product__c> getAccountProductData(String obReqId) {
        List<Account_Product__c> accountProducts = new List<Account_Product__c>();
        if (String.isNotBlank(obReqId)) {
            List<Onboarding_Request__c> obRequest = [SELECT Id, RM_Account__c FROM Onboarding_Request__c WHERE Id = :obReqId AND RM_Account__c != null];
            if(!obRequest.isEmpty()) {
                accountProducts = [SELECT Id, BookingEntityName__c, EventType__c, ProductCategory__c, ProductType__c, CaseId__c, CaseStatus__c, LastModifiedDate FROM Account_Product__c WHERE Account__c = :obRequest[0].RM_Account__c ORDER BY LastModifiedDate DESC];
            }            
        }
        return accountProducts;
    }

    @AuraEnabled 
    public static List<OnbRequestWrapper> loadOnbReqWithOnbProds(String rmAccId, String reqId) {
        System.debug('#### OnboardingReqAndProdController::loadOnbReqWithOnbProds()');
        //System.debug(rmAccId+' : '+reqId);
        List<OnbRequestWrapper> OnbReqWrapperList = new List<OnbRequestWrapper>();
        if(String.isNotBlank(reqId)) {
            if(String.isBlank(rmAccId)) {
                rmAccId = OnboardingReqAndProdService.getRmAccForObRequest(new List<String>{reqId}).get(reqId);
            }
            if(String.isNotBlank(rmAccId)) {
                Map<String, Map<String, Onboarding_Request__c>> OnbReqWithProdsByOnbReqIdMapByRmAccIdMap = 
                    OnboardingReqAndProdService.getOnbReqAndOnbProdReqDetails(new List<String>{rmAccId});  
                Map<String, Onboarding_Request__c> OnbReqWithProdsByOnbReqIdMap = 
                    OnbReqWithProdsByOnbReqIdMapByRmAccIdMap.get(rmAccId);
                //System.debug('OnbReqWithProdsByOnbReqIdMap : '+OnbReqWithProdsByOnbReqIdMap);
                if(OnbReqWithProdsByOnbReqIdMap!=null) {
                    for(Onboarding_Request__c oOnbReq : OnbReqWithProdsByOnbReqIdMap.values()) {
                        OnbReqWrapperList.add(new OnbRequestWrapper(oOnbReq, oOnbReq.Id==reqId));
                    }
                }
            }
        }
        return OnbReqWrapperList;
    }
    
    @AuraEnabled 
    public static Boolean isCurrentUserAnApprover(String obRequestId) {
        if(String.isNotBlank(obRequestId) && UserHelper.isCurrentPreOnboardingApprover) {
            String userId = UserInfo.getUserId();
            List<Onboarding_Request__c> onboardingRequest = [SELECT Id, Status__c, Desk_Head_Approver__c FROM Onboarding_Request__c WHERE Id = :obRequestId AND 
                                                             (Status__c = 'Desk Head Approval' OR Status__c = 'Sales CAO Approval') LIMIT 1];
            if (!onboardingRequest.isEmpty()) {
                if(onboardingRequest[0].Status__c == 'Desk Head Approval' && onboardingRequest[0].Desk_Head_Approver__c == userId) {
                    return true;
                } else if (onboardingRequest[0].Status__c == 'Sales CAO Approval') {
                    List<ProcessInstanceWorkItem> approvalWorkItem = [SELECT ID, OriginalActorId, ActorId FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObject.Id = :obRequestId LIMIT 1];
                    if (!approvalWorkItem.isEmpty() && String.valueOf(approvalWorkItem[0].OriginalActorId).startsWith('00G')) {
                        List<GroupMember> groupMember = [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId = :approvalWorkItem[0].OriginalActorId AND UserOrGroupId = :userId LIMIT 1];
                        if (!groupMember.isEmpty()) {
                            return true;
                        }
                    }
                }
            }
        }
        return false;
    }
    
    @AuraEnabled
    public static void updateOnbProductProposedPriority(List<String> obProductIds, String proposedPriority, String obRequestId, Date tradeDeadline, String priorityJustification) {
        if (obProductIds != null && !obProductIds.isEmpty() && String.isNotBlank(proposedPriority) && String.isNotBlank(obRequestId)) {
            List<Onboarding_Request__c> onboardingRequest = [SELECT Id FROM Onboarding_Request__c WHERE Id = :obRequestId AND (Status__c = 'Desk Head Approval' OR Status__c = 'Sales CAO Approval') LIMIT 1];
            if (!onboardingRequest.isEmpty()) {
                List<Onboarding_Product__c> obProductsToUpdate = new List<Onboarding_Product__c>();
                for (String obProductId : obProductIds) {
                    Onboarding_Product__c obProduct = new Onboarding_Product__c (
                        Id = obProductId,
                        Proposed_Priority__c = proposedPriority,
                        Trade_Deadline__c = proposedPriority == 'Urgent' ? tradeDeadline : null,
                        Additional_Priority_Justification__c = priorityJustification
                    );
                    obProductsToUpdate.add(obProduct);
                }
                try {
                    update obProductsToUpdate;
                } catch (DMLException e) { 
                    String errorMessage = e.getDmlMessage(0);
                    throw new AuraHandledException(errorMessage);
                } catch (Exception ex) {
                    throw new AuraHandledException(ex.getMessage());
                }
            } else {
                throw new AuraHandledException('Product Priority can only be updated during Approval stages');
            }
        }
    }
    
    public class OnbRequestValidationData {
        @AuraEnabled
        public Boolean aumValidation = false;
        @AuraEnabled
        public Boolean estRevenueValidation = false;
        @AuraEnabled
        public Boolean noFaceToFaceValidation = false;
        @AuraEnabled
        public Boolean isCurrentUserCAOApprover = false;
    }
    
    @AuraEnabled
    public static OnbRequestValidationData getOnboardingRequestValidationObj(String onbReqId, String currentUserId) {
        if(String.isNotBlank(onbReqId) && String.isNotBlank(currentUserId)) {
            OnbRequestValidationData onbReqValidationObj = new OnbRequestValidationData();
            
            for (Onboarding_Product__c onbProduct : [SELECT Id, Display_AUM_Less_Than_100m_Justification__c, Est_Revenue_Exceptional_Approval_Error__c, Display_No_F2F_Meeting_Justification__c FROM Onboarding_Product__c WHERE Onboarding_Request__c = :onbReqId]) {
                if (onbProduct.Display_AUM_Less_Than_100m_Justification__c) {
                    onbReqValidationObj.aumValidation = true;
                }
                if (onbProduct.Est_Revenue_Exceptional_Approval_Error__c) {
                    onbReqValidationObj.estRevenueValidation = true;
                }
                if (onbProduct.Display_No_F2F_Meeting_Justification__c) {
                    onbReqValidationObj.noFaceToFaceValidation = true;
                } 
            }
            
            List<ProcessInstanceWorkItem> workItem = [SELECT ID, ProcessInstanceId, ProcessInstance.TargetObject.Name, ProcessInstance.TargetObjectId, OriginalActorId FROM ProcessInstanceWorkItem WHERE IsDeleted = False AND ProcessInstance.TargetObjectId = :onbReqId ORDER BY CreatedDate DESC LIMIT 1];
            if (!workItem.isEmpty() && String.isNotBlank(workItem[0].OriginalActorId)) {
                List<GroupMember> groupMem = [SELECT Id, Group.Name FROM GroupMember WHERE UserOrGroupId = :currentUserId AND GroupId = :workItem[0].OriginalActorId LIMIT 1];
                onbReqValidationObj.isCurrentUserCAOApprover = groupMem.isEmpty() ? false : true;
            } else {
                throw new AuraHandledException('Failed To Retireve Validation Data for Sales CAO - Failed To Retrieve Approval Process. OnboardingReqAndProdController.getOnboardingRequestValidationObj()'); 
            }
            
            return onbReqValidationObj;
            
        } else {
            throw new AuraHandledException('Failed To Retireve Validation Data for Sales CAO - Onb Request Id or Current User Id is blank. OnboardingReqAndProdController.getOnboardingRequestValidationObj()'); 
        }
    }
    
	
    /*
    @AuraEnabled 
    public static List<OnbRequestWrapper> loadOnbReqWithOnbProds(String rmAccId, String reqId) {
        System.debug('#### SchRequestController::loadOnbReqWithOnbProds()');
        System.debug(rmAccId+' : '+reqId);
        List<OnbRequestWrapper> OnbReqWrapperList = new List<OnbRequestWrapper>();
        if(String.isNotBlank(rmAccId)) {
            Map<String, Map<String, Onboarding_Request__c>> OnbReqWithProdsByOnbReqIdMapByRmAccIdMap = 
                OnboardingReqAndProdService.getOnbReqAndOnbProdReqDetails(new List<String>{rmAccId});  
            Map<String, Onboarding_Request__c> OnbReqWithProdsByOnbReqIdMap = 
                OnbReqWithProdsByOnbReqIdMapByRmAccIdMap.get(rmAccId);
            System.debug('OnbReqWithProdsByOnbReqIdMap : '+OnbReqWithProdsByOnbReqIdMap);
            if(OnbReqWithProdsByOnbReqIdMap!=null) {
                for(Onboarding_Request__c oOnbReq : OnbReqWithProdsByOnbReqIdMap.values()) {
                    OnbReqWrapperList.add(new OnbRequestWrapper(oOnbReq, oOnbReq.Id==reqId));
                }
            }      
        }
        return OnbReqWrapperList;
    }
    */
}