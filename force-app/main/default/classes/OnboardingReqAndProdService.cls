/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : This class implements the Service class for Onboarding_Request__c and Onboarding_Product__c object 
**                to implement business tasks, calculations and processes around these objects.
**
** Consumer of the Service Layer : Batch, Schedulable, Queuable/Apex API/UI Controllers/Inbpound Email Handlers/Invocable Method
**/
public without sharing class OnboardingReqAndProdService {
    
    public static final String DRAFT_STATUS = 'Draft';
    public static final String SUBMITTED_STATUS = 'Submitted';
    public static final String SENT_STATUS = 'Sent';
    public static final String SUCCESS_SUB_STATUS = 'Success';
    public static final String DESK_HEAD_APPROVAL_STATUS = 'Desk Head Approval';
    public static final String SALES_CAO_APPROVAL_STATUS = 'Sales CAO Approval';
    public static final String ADDT_APPROVAL_STATUS = 'Additional Approval';
    public static final String PRIME_APPROVAL_SUB_STATUS = 'Prime Approval';
    public static final String NFPE_APPROVAL_SUB_STATUS = 'NFPE Approval';
    public static final String FUTURES_CLEARING_APPROVAL_SUB_STATUS = 'Futures Clearing Approval';
    
    public static Map<String, Onboarding_Request__c> getOnbReqReqDetails(Set<String> OnbReqIdSet ) {
        Map<String, Onboarding_Request__c> OnbReqByIdMap = new Map<String, Onboarding_Request__c>();
        if(OnbReqIdSet!=null && !OnbReqIdSet.isEmpty()) {
            OnbReqByIdMap = new Map<String, Onboarding_Request__c>([SELECT Id, Name, RM_Account__c, Campaign__c, 
                                                                    CreatedById, Requestor__c, Sales_Requestor__c, Sales_CAO_Approver__c, Desk_Head_Approver__c,
                                                                    Role_Based_Region_Of_Sales_Requestor__c, Sales_Requestors_Functional_Group__c, Status__c, Sub_Status__c
                                                                    FROM Onboarding_Request__c 
                                                                    WHERE Id IN :OnbReqIdSet]);
        }
        return OnbReqByIdMap;
    }
    
    private static Map<UserHelper.USER_DETAILS_AND_PERMISSIONS, Set<String>> UserIdSetByDetAndPermEnum;
    
    public static Map<UserHelper.USER_DETAILS_AND_PERMISSIONS, Set<String>> getOnbReqUserDetailsAndPermissions(List<Onboarding_Request__c> OnbRequestList) {
            System.debug('#### OnboardingReqAndProdService::getOnbReqUserDetailsAndPermissions()');
            try{
                if(UserIdSetByDetAndPermEnum==null) {
                    if(OnbRequestList!=null) {
                        Set<String> UserIdSet = new Set<String>();
                        for(Onboarding_Request__c oOnbReq : OnbRequestList) {
                            if(String.isNotBlank(oOnbReq.Sales_Requestor__c)) {
                                UserIdSet.add(oOnbReq.Sales_Requestor__c);
                            }
                        }
                        if(!UserIdSet.isEmpty()) {
                            Set<UserHelper.USER_DETAILS_AND_PERMISSIONS> DetailsAndPermissionSet = new Set<UserHelper.USER_DETAILS_AND_PERMISSIONS> 
                            {UserHelper.USER_DETAILS_AND_PERMISSIONS.IS_ROLE_BASED_REGION_EMEA, 
                                UserHelper.USER_DETAILS_AND_PERMISSIONS.IS_ROLE_BASED_REGION_AMERICAS, 
                                UserHelper.USER_DETAILS_AND_PERMISSIONS.IS_ROLE_BASED_REGION_AEJ, 
                                UserHelper.USER_DETAILS_AND_PERMISSIONS.IS_ROLE_BASED_REGION_JAPAN};
                                UserIdSetByDetAndPermEnum = UserHelper.getUserDetailsAndPermissionMap(DetailsAndPermissionSet, UserIdSet);
                        }
                    }
                }
            } catch(Exception ex) {
                System.debug('ERROR : '+ex.getMessage());
                System.debug('ERROR Stack : '+ex.getStackTraceString());
                throw new OnboardingReqAndProdServiceException('Error Occured in OnboardingReqAndProdService::getOnbReqUserDetailsAndPermissions() : '+ex.getMessage());
            }
            return UserIdSetByDetAndPermEnum;
        }
    
    /**
     * @Description: Share onboarding request with groups by Developer Name 
     */
    public static void shareOnbRequestWithGroups (List<Onboarding_Request__c> obReqs, List<String> groupDevNames, String accessLevel) {
        if(obReqs != null && groupDevNames != null && String.isNotBlank(accessLevel)) {
            List<Onboarding_Request__Share> onbShareRecords = new List<Onboarding_Request__Share>();
            for(Group grp : [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN :groupDevNames]) {
                for(Onboarding_Request__c obReq : obReqs) {
                    Onboarding_Request__Share onbShare = new Onboarding_Request__Share();
                    onbShare.ParentId = obReq.Id;
                    onbShare.UserOrGroupId = grp.Id;
                    onbShare.AccessLevel = 'Edit';
                    onbShareRecords.add(onbShare);
                }
            }
            try {
                insert onbShareRecords;
            } catch (Exception ex) {
                System.debug('ERROR while sharing Onboarding Request with Group : ' + ex.getMessage());
                throw new OnboardingReqAndProdServiceException('Error Occured in OnboardingReqAndProdService::shareOnbRequestWithGroups()');           
            }
        }
    }    
    
    
     /**
     * @Description: Start NFPE / Futures Clearing / Other additional approval process for Onboarding Requests
     */
    public static void startOnboardingApprovalProcess (List<Onboarding_Request__c> obRequests, String approvalProcessName) {
        if (obRequests != null && !obRequests.isEmpty() && String.isNotBlank(approvalProcessName)) {
            
            List<ProcessDefinition> queriedApprovalDefinition = [SELECT Id, Name, DeveloperName FROM ProcessDefinition WHERE DeveloperName = :approvalProcessName AND State = 'Active' LIMIT 1];
            
            if (!queriedApprovalDefinition.isEmpty()) {
                List<Approval.ProcessSubmitRequest> approvalProcessRequestList = new List<Approval.ProcessSubmitRequest>();
                ProcessDefinition approvalDefinition = queriedApprovalDefinition[0];
                
                for (Onboarding_Request__c onbReq : obRequests) {
                    Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                    approvalRequest.setComments('Auto Submitting Onboarding Request for ' + approvalDefinition.Name);
                    approvalRequest.setObjectId(onbReq.Id);
                    approvalRequest.setSubmitterId(onbReq.Requestor__c);
                    approvalRequest.setSkipEntryCriteria(false);
                    approvalRequest.setProcessDefinitionNameOrId(approvalDefinition.DeveloperName);
                    approvalProcessRequestList.add(approvalRequest);
                }
                
                if (!approvalProcessRequestList.isEmpty()) {
                    try {
                        Approval.ProcessResult[] approvalProcessRsltList = Approval.process(approvalProcessRequestList);
                        for (Approval.ProcessResult result : approvalProcessRsltList) {
                            if (!result.isSuccess()) {
                                for(Database.Error err : result.getErrors()) {
                                    System.debug('ERROR WHILE SUBMITTING FOR APPROVAL @@@ ' + err.message);
                                    System.debug('ERROR WHILE SUBMITTING FOR APPROVAL @@@ ' + err.fields);
                                }
                            }
                        }
                    } catch (Exception e) {
                        System.debug('ERROR Submitting Onboarding request for approval : '+e.getMessage());
                        System.debug('ERROR Submitting Onboarding request for approval StackTrace : '+e.getStackTraceString());
                        throw new OnboardingReqAndProdServiceException('Error Occured in OnboardingReqAndProdService::startOnboardingApprovalProcess()');
                    }
                }
            }
        }
    }
    
    @future
    public static void submitOnbReqForSalesCaoApproval(List<String> OnbReqToSubmitForSalesCaoApprList) {
        System.debug('#### OnboardingReqAndProdService::submitOnbReqForSalesCaoApproval()');
        try {
            if(OnbReqToSubmitForSalesCaoApprList!=null && !OnbReqToSubmitForSalesCaoApprList.isEmpty()) {
                Map<String, Onboarding_Request__c> OnbReqByIdMap = getOnbReqReqDetails(new Set<String>(OnbReqToSubmitForSalesCaoApprList));
                getOnbReqUserDetailsAndPermissions(OnbReqByIdMap.values());
                Map<String, Map<String, Set<String>>> TargetIdSetByEmailTempNameMapByWhatIdMap = new Map<String, Map<String, Set<String>>>();
                List<Approval.ProcessSubmitRequest> ApprovalProcessRequestList = new List<Approval.ProcessSubmitRequest>();
                for(String onbReqId : OnbReqToSubmitForSalesCaoApprList) {
                    Onboarding_Request__c oOnbReq = OnbReqByIdMap.get(onbReqId);
                    if(String.isNotBlank(oOnbReq.Role_Based_Region_Of_Sales_Requestor__c)) {
                        if(String.isNotBlank(oOnbReq.Requestor__c)) {
                            String roleBasedRegion = oOnbReq.Role_Based_Region_Of_Sales_Requestor__c.toUpperCase();
                            String addPerm = '';
                            if(oOnbReq.Sales_Requestors_Functional_Group__c == 'Equity') {
                                addPerm = UserHelper.USER_ADD_PERMISSION_SALES_CAO_EQ_REG;
                            } else if(oOnbReq.Sales_Requestors_Functional_Group__c == 'Fixed Income') {
                                addPerm = UserHelper.USER_ADD_PERMISSION_SALES_CAO_FI_REG;
                            } else {
                                addPerm = UserHelper.USER_ADD_PERMISSION_SALES_CAO_SUPER_REG;
                            }
                            if(String.isNotBlank(addPerm)) {
                                List<ProcessDefinition> salesCAOProcess = [SELECT Id FROM ProcessDefinition WHERE DeveloperName = 'Onb_Req_Sales_CAO_Approval_Process' AND State = 'Active'];
                                if (!salesCAOProcess.isEmpty()) {
                                    Approval.ProcessSubmitRequest oReq = new Approval.ProcessSubmitRequest();
                                    oReq.setComments('Auto Submitting Onboarding Request for Sales CAO approval');
                                    oReq.setObjectId(onbReqId);
                                    String approverId = UserHelper.SalesCaoQueueIdsByQueueName.get(UserHelper.SalesCaoQueueNameListByLocMapByAddPermMap.get(addPerm).get(roleBasedRegion)[0]);
                                    oReq.setNextApproverIds(new Id[] {approverId});
                                    oReq.setSkipEntryCriteria(true);
                                    oReq.setSubmitterId(oOnbReq.Requestor__c);
                                    oReq.setProcessDefinitionNameOrId('Onb_Req_Sales_CAO_Approval_Process');
                                    ApprovalProcessRequestList.add(oReq);
                                    
                                    String queueApiName = UserHelper.SalesCaoQueueNameListByLocMapByAddPermMap.get(addPerm).get(roleBasedRegion)[0];
                                    //Assign Queue name on OnboardingRequest
                                    if(String.isNotBlank(approverId)){
                                        Group grpObj = [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName = :queueApiName];
                                        if(grpObj != null){
                                            oOnbReq.Sales_CAO_Queue__c = grpObj.Name;
                                            System.debug('------oOnbReq.Sales_CAO_Queue__c---' + oOnbReq.Sales_CAO_Queue__c);
                                            update oOnbReq;
                                        }
                                    }
                                    
                                    if(UserHelper.SalesCaoApprUserIdSetBySalesCaoApprQueueIdMap.containsKey(approverId) && 
                                       !UserHelper.SalesCaoApprUserIdSetBySalesCaoApprQueueIdMap.get(approverId).isEmpty()) {
                                           Set<String> TargetIdSet = new Set<String>();
                                           TargetIdSet.addAll(UserHelper.SalesCaoApprUserIdSetBySalesCaoApprQueueIdMap.get(approverId));
                                           
                                           Map<String, Set<String>> TargetIdSetByEmailTempNameMap = new Map<String, Set<String>>();
                                           TargetIdSetByEmailTempNameMap.put(System.Label.Onb_Req_Sales_CAO_Approval_Req_By_Sales_Requestor_Email_Template, TargetIdSet);
                                           TargetIdSetByEmailTempNameMapByWhatIdMap.put(onbReqId, TargetIdSetByEmailTempNameMap);
                                           
                                       } else {
                                           System.debug('Email will not be sent to the Sales CAOs for '+oOnbReq.Name+' Onboarding Request as corroesponding Queue is empty');
                                       }
                                } else {
                                    System.debug('Could not submit onboarding request for approval as Sales CAO Approval Request does not exist');
                                }
                            } else {
                                System.debug('Request : '+oOnbReq.Name+' not submitted for Sales CAO approval as Sales Requestor\' Functional Group is not setup correctly');
                            }
                        } else {
                            System.debug('Request : '+oOnbReq.Name+' not submitted for Sales CAO approval as Requestor__c field is blank');
                        }
                    } else {
                        System.debug('Request : '+oOnbReq.Name+' not submitted for Sales CAO approval as Sales Requestor\' Role based Region is not setup correctly');
                    }                        
                }
                if(!ApprovalProcessRequestList.isEmpty()) {
                    // Submit the approval request for the Opportunity
                    Approval.ProcessResult[] ApprovalProcessRsltList = Approval.process(ApprovalProcessRequestList);
                    for(Approval.ProcessResult oReqRslt : ApprovalProcessRsltList) {
                        System.debug('App Req Submit Err : '+ oReqRslt.getEntityId()+' : '+oReqRslt.getEntityId()+' : '+oReqRslt.getErrors());
                    }
                    if(!TargetIdSetByEmailTempNameMapByWhatIdMap.isEmpty()) {
                        EmailNotificationService.sendUsingSingleEmail(TargetIdSetByEmailTempNameMapByWhatIdMap);
                    }
                }
            }
        } catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new OnboardingReqAndProdServiceException('Error Occured in OnboardingReqAndProdService::getOnbReqUserDetailsAndPermissions() : '+ex.getMessage());
        }
    }
    
    public static Map<String, List<Onboarding_Product__c>> getOnbProdReqsForOnbReqs(Set<String> OnbReqIdSet, String prodCode, String prodType) {
        System.debug('#### OnboardingReqAndProdService::getOnbProdReqsForOnbReqs()');
        Map<String, List<Onboarding_Product__c>> OnbProdReqListByOnbReqIdMap = new Map<String, List<Onboarding_Product__c>>();
        try {
            if(OnbReqIdSet!=null && !OnbReqIdSet.isEmpty() && String.isNotBlank(prodCode) && String.isNotBlank(prodType)) {
                List<Onboarding_Product__c> OnbProdReqList = [SELECT Id, Name, Onboarding_Request__c, RM_Account__c, Additional_Priority_Justification__c,
                                                              Anticipated_Avg_Monthly_Frequency__c, Anticipated_Avg_Monthly_Transaction_Size__c, 
                                                              Approx_no_of_underlying_funds_if_app__c, Are_You_Registered_As_Authorised_Person__c, 
                                                              Are_you_trading_in_principal_with_client__c, Justification_for_the_entity__c, 
                                                              Market_Standard_Settlements__c, Market_Standard_Settlement_Justification__c, Name_of_Trader_consulted__c, Non_Fenergo_AEJ_Entity_Selected__c, New_or_existing_business_activity__c, 
                                                              Nomura_Entity_client_being_onboarded_to__c, Trader_Consulted__c, Trader_Consulted__r.Name, Product_Type__c, Products_Category__c, 
                                                              Proposed_Priority__c, Restrict_Client_for_Extended_Settlement__c, Sales_Location__c, Status__c, Trade_Deadline__c,
                                                              Trader_Consulted_Free_Text__c, Trader_Location__c, Trading_conditions_for_Swap_Transactions__c, 
                                                              Trading_Desk_Rank_Monetisation_Of_Flow__c, Trading_Desk_Rank_Relevance_To_Market__c, Unique_Key__c,
                                                              Onboarding_Request__r.Physical_Location_Of_Sales_Requestor__c, Onboarding_Request__r.Role_Based_Region_Of_Sales_Requestor__c, Onboarding_Request__r.RecordType.DeveloperName, Other_Reason_Justification_For_Entity__c
                                                              FROM Onboarding_Product__c 
                                                              WHERE Onboarding_Request__c IN :OnbReqIdSet AND Products_Category__c = :prodCode AND Product_Type__c = :prodType];
                for(Onboarding_Product__c oOnbReq : OnbProdReqList) {
                    List<Onboarding_Product__c> ProdReqList = OnbProdReqListByOnbReqIdMap.containsKey(oOnbReq.Onboarding_Request__c) ?
                        OnbProdReqListByOnbReqIdMap.get(oOnbReq.Onboarding_Request__c) : new List<Onboarding_Product__c>();
                    ProdReqList.add(oOnbReq);
                    OnbProdReqListByOnbReqIdMap.put(oOnbReq.Onboarding_Request__c, ProdReqList);
                }
            }
        } catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new OnboardingReqAndProdServiceException('Error Occured in OnboardingReqAndProdService::getOnbProdReqsForOnbReqs() : '+ex.getMessage());
        }
        return OnbProdReqListByOnbReqIdMap;
    }
    
    public static Map<String, String> getRmAccForObRequest(List<String> ObReqIdList) {
        System.debug('#### OnboardingReqAndProdService::getRmAccForObRequest()');
        Map<String, String> RmAccIdByObReqIdMap = new Map<String, String>();
        if(ObReqIdList!=null && !ObReqIdList.isEmpty()) {
            for(Onboarding_Request__c oObReq : [SELECT Id, RM_Account__c FROM Onboarding_Request__c WHERE Id IN :ObReqIdList]) {
                RmAccIdByObReqIdMap.put(oObReq.Id, oObReq.RM_Account__c);
            }
        }
        return RmAccIdByObReqIdMap;
    }
    
    public static Map<String, Map<String, Onboarding_Request__c>> getOnbReqAndOnbProdReqDetails(List<String> RmAccIdList) {
        System.debug('#### OnboardingReqAndProdService::getOnbReqAndOnbProdReqDetails()');
        Map<String, Map<String, Onboarding_Request__c>> OnbReqWithProdsByOnbReqIdMapByRmAccIdMap = 
            new Map<String, Map<String, Onboarding_Request__c>>();
        System.debug('RmAccIdList : '+RmAccIdList);
        List<Onboarding_Request__c> OnbReqList = [SELECT Id, Name, RM_Account__c, Status__c, Sub_Status__c, Role_Based_Region_Of_Sales_Requestor__c,
                                                  (SELECT Id, Name, RM_Account__c, Onboarding_Request__c,AEJ_Regional_Product_Market__c, Agreement_Type__c, Beneficial_Owner_Markets__c, Billing_Party_Name__c, 
                                                   Clearing_Account__c, Clearing_Broker_Name__c,Customer_Entity__c, EMEA_Regional_Product_Market__c, Email_of_Broker_Not_On_DOCS__c, Estimated_Notional_Amount_Per_Day__c,
                                                   Estimated_Number_of_Trades_Per_Day__c, Estimated_Portfolio_Turnover__c, Executing_Broker_Name__c, Execution_Connectivity_required__c, Execution_Rate_Schedule__c,
                                                   Fund_Assets_Under_Management__c, Give_up_Structure__c, In_Business_Risk_Analyst_Engaged__c, Is_Client_available_on_DOCS__c, Is_Nomura_the_Clearing_Broker__c,
                                                   Is_Nomura_the_Executing_Broker__c, Is_this_existing_Instinet_relationship__c, Is_this_an_existing_Nomura_relationship__c, Japan_Regional_Product_Market__c,
                                                   Name_of_Client_Contact_Not_On_DOCS__c, Name_of_Broker_Not_On_DOCS__c, Nomura_Credit_Analyst_engaged__c, Number_of_days_agreed_on_the_CMA__c, 
                                                   Order_placing_broker_entity_name__c, Phone_of_Client_Contact_Not_On_DOCS__c, Phone_of_Broker_not_on_DOCS__c, Prime_Baskets__c, Prime_Coverts__c, 
                                                   Prime_Equities__c, Prime_Other__c, Prime_SPAC__c, Trader_Entity_Name__c, US_Regional_Product_Market__c, 
                                                   Anticipated_Avg_Monthly_Frequency__c, Anticipated_Avg_Monthly_Transaction_Size__c, Email_of_Client_Contact_Not_On_DOCS__c, 
                                                   Approx_no_of_underlying_funds_if_app__c, Are_you_registered_as_Authorised_Person__c, Market_Standard_Settlements__c, 
                                                   Market_Standard_Settlement_Justification__c, Are_you_trading_in_principal_with_client__c, CreatedById, Justification_for_the_entity__c,
                                                   Name_of_Trader_consulted__c, New_or_existing_business_activity__c, Nomura_Entity_client_being_onboarded_to__c, 
                                                   Trader_consulted__c, Trader_Consulted_Free_Text__c, Product_Type__c, Products_Category__c, Proposed_Priority__c, Additional_Priority_Justification__c,
                                                   Restrict_Client_for_Extended_Settlement__c, Sales_Location__c, Trade_Deadline__c, Trader_Location__c,
                                                   Trading_conditions_for_Swap_Transactions__c, Trading_desk_rank_Monetisation_of_Flow__c, Trader_Consulted__r.Name,
                                                   Trading_desk_rank_relevance_to_market__c, Unique_Key__c, Onboarding_Request__r.RecordType.DeveloperName, Non_Fenergo_AEJ_Entity_Selected__c
                                                   FROM Onboarding_Request__c.Onboarding_Products__r ORDER BY Unique_Key__c) 
                                                  FROM Onboarding_Request__c 
                                                  WHERE RM_Account__c IN :RmAccIdList 
                                                  ORDER BY CreatedDate DESC];
        
        System.debug('OnbReqList : '+OnbReqList);
        
        for(Onboarding_Request__c oObReq : OnbReqList) {
            Map<String, Onboarding_Request__c> OnbReqWithProdsByOnbReqIdMap = 
                OnbReqWithProdsByOnbReqIdMapByRmAccIdMap.containsKey(oObReq.RM_Account__c) ? 
                OnbReqWithProdsByOnbReqIdMapByRmAccIdMap.get(oObReq.RM_Account__c) : new Map<String, Onboarding_Request__c>();
            OnbReqWithProdsByOnbReqIdMap.put(oObReq.Id, oObReq);
            OnbReqWithProdsByOnbReqIdMapByRmAccIdMap.put(oObReq.RM_Account__c, OnbReqWithProdsByOnbReqIdMap);
        }
        
        return OnbReqWithProdsByOnbReqIdMapByRmAccIdMap;
    }
    
    public static Onboarding_Request__c getOnbReqDetails(String obReqId) {
        System.debug('#### OnboardingReqAndProdService::getOnbReqDetails()');
        Onboarding_Request__c oOnbReq;
        try {
            if(String.isNotBlank(obReqId)) {
                oOnbReq = [SELECT Id, Physical_Location_Of_Sales_Requestor__c, Role_Based_Region_Of_Sales_Requestor__c
                           FROM Onboarding_Request__c 
                           WHERE Id = :obReqId];
            }
        } catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new OnboardingReqAndProdServiceException('Error Occured in OnboardingReqAndProdService::getOnbReqDetails() : '+ex.getMessage());
        }
        return oOnbReq;
    }
    
    /////////////////
    
    public static Map<String, String> getHistoricProdReqData(String onbReqId, String prodCode, String prodType) {
        System.debug('#### OnboardingReqAndProdService::getOnbReqDetails()');
        Map<String, String> HistoricValByFldNameMap = new Map<String, String>();
        try{
            if(String.isNotBlank(onbReqId) && String.isNotBlank(prodCode) && String.isNotBlank(prodType)) {
                List<Onboarding_Product__c> OnbProdReqList = [SELECT Id, Name, Onboarding_Request__c, RM_Account__c, 
                                                              Anticipated_Avg_Monthly_Frequency__c, Anticipated_Avg_Monthly_Transaction_Size__c, 
                                                              Approx_no_of_underlying_funds_if_app__c, Are_You_Registered_As_Authorised_Person__c, 
                                                              Are_you_trading_in_principal_with_client__c, Justification_for_the_entity__c, 
                                                              Market_Standard_Settlements__c, Market_Standard_Settlement_Justification__c, Name_of_Trader_consulted__c, New_or_existing_business_activity__c, 
                                                              Nomura_Entity_client_being_onboarded_to__c, Trader_Consulted__c, Trader_Consulted__r.Name, Product_Type__c, Products_Category__c, 
                                                              Proposed_Priority__c, Restrict_Client_for_Extended_Settlement__c, Sales_Location__c, Status__c, Trade_Deadline__c,
                                                              Trader_Consulted_Free_Text__c, Trader_Location__c, Trading_conditions_for_Swap_Transactions__c, 
                                                              Trading_Desk_Rank_Monetisation_Of_Flow__c, Trading_Desk_Rank_Relevance_To_Market__c, Unique_Key__c,
                                                              Onboarding_Request__r.Physical_Location_Of_Sales_Requestor__c, Onboarding_Request__r.Role_Based_Region_Of_Sales_Requestor__c, Other_Reason_Justification_For_Entity__c
                                                              FROM Onboarding_Product__c
                                                              WHERE RM_Account__c IN (SELECT RM_Account__c FROM Onboarding_Request__c WHERE Id = :onbReqId AND RM_Account__r.Stage__c='Fenergo Managed Client') AND 
                                                              Onboarding_Request__r.Status__c='Submitted' 
                                                              ORDER BY CreatedDate DESC];
                
                Boolean fld1Fnd = false, fld2Fnd = false, fld3Fnd = false, fld4Fnd = false, fld5Fnd = false, fld6Fnd = false;
                for(Onboarding_Product__c oProdReq : OnbProdReqList) {
                    System.debug('oProdReq : '+oProdReq);
                    
                    if(!fld1Fnd && String.isNotBlank(oProdReq.Approx_no_of_underlying_funds_if_app__c)) {
                        HistoricValByFldNameMap.put('Approx_no_of_underlying_funds_if_app__c', oProdReq.Approx_no_of_underlying_funds_if_app__c);
                        fld1Fnd = true;
                    }

                    if(oProdReq.Products_Category__c==prodCode && oProdReq.Product_Type__c==prodType) {

                        if(!fld2Fnd && String.isNotBlank(oProdReq.Anticipated_Avg_Monthly_Frequency__c)) {
                            HistoricValByFldNameMap.put('Anticipated_Avg_Monthly_Frequency__c', oProdReq.Anticipated_Avg_Monthly_Frequency__c);
                            fld2Fnd = true;
                        }
                        if(!fld3Fnd && String.isNotBlank(oProdReq.Anticipated_Avg_Monthly_Transaction_Size__c)) {
                            HistoricValByFldNameMap.put('Anticipated_Avg_Monthly_Transaction_Size__c', oProdReq.Anticipated_Avg_Monthly_Transaction_Size__c);
                            fld3Fnd = true;
                        }
                        if(!fld4Fnd && String.isNotBlank(oProdReq.Trading_Desk_Rank_Relevance_To_Market__c)) {
                            HistoricValByFldNameMap.put('Trading_Desk_Rank_Relevance_To_Market__c', oProdReq.Trading_Desk_Rank_Relevance_To_Market__c);
                            fld4Fnd = true;
                        }
                        if(!fld5Fnd && String.isNotBlank(oProdReq.Trading_Desk_Rank_Monetisation_Of_Flow__c)) {
                            HistoricValByFldNameMap.put('Trading_Desk_Rank_Monetisation_Of_Flow__c', oProdReq.Trading_Desk_Rank_Monetisation_Of_Flow__c);
                            fld5Fnd = true;
                        }
                        if(!fld6Fnd) { 
                            if(String.isNotBlank(oProdReq.Trader_Consulted__c)) {
                                HistoricValByFldNameMap.put('Trader_Consulted__c', oProdReq.Trader_Consulted__c);
                                fld6Fnd = true;
                            } else if(String.isNotBlank(oProdReq.Trader_Consulted_Free_Text__c)) {
                                HistoricValByFldNameMap.put('Trader_Consulted_Free_Text__c', oProdReq.Trader_Consulted_Free_Text__c);
                                fld6Fnd = true;
                            }
                        }   
                    }
                    
                    if(fld1Fnd && fld2Fnd && fld3Fnd && fld4Fnd && fld5Fnd && fld6Fnd) {
                        break;
                    }
                }
            }
        } catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new OnboardingReqAndProdServiceException('Error Occured in OnboardingReqAndProdService::getOnbReqDetails() : '+ex.getMessage());
        }
        return HistoricValByFldNameMap;
    }
    
    
    
    ////////////////
    
    public static List<Nomura_Booking_Entity__mdt> getNomuraBEMetaDataDetails() {    
        System.debug('#### OnboardingReqAndProdService::getNomuraBEMetaDataDetails()');
        List<Nomura_Booking_Entity__mdt> NomuraBEMetaDataList = new List<Nomura_Booking_Entity__mdt>();
        try {
            NomuraBEMetaDataList = [SELECT Id, DeveloperName, Booking_Entity_Name__c, Booking_Entity_Region__c, Is_Active__c 
                                    FROM Nomura_Booking_Entity__mdt 
                                    WHERE Is_Active__c = true];        
        } catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new OnboardingReqAndProdServiceException('Error Occured in OnboardingReqAndProdService::getNomuraBEMetaDataDetails() : '+ex.getMessage());
        }
        return NomuraBEMetaDataList;
    }
    
    @future
    public static void setupCampaignForOnbRequestAsynch(List<String> OnbReqIdList) {
        System.debug('#### OnboardingReqAndProdService::setupCampaignForOnbRequestAsynch()');
        setupCampaignForOnbRequest(OnbReqIdList);
    }
    
    public static void setupCampaignForOnbRequest(List<String> OnbReqIdList) {
        System.debug('#### OnboardingReqAndProdService::setupCampaignForOnbRequest()');
        try {
            if(OnbReqIdList!=null && !OnbReqIdList.isEmpty()) {
                Map<String, Onboarding_Request__c> OnbReqByIdMap = getOnbReqReqDetails(new Set<String>(OnbReqIdList));
                Map<String, Onboarding_Request__c> OnbReqByCampNameMap = new Map<String, Onboarding_Request__c>();
                for(Onboarding_Request__c oOnbReq : OnbReqByIdMap.values()) {
                    if(String.isBlank(oOnbReq.Campaign__c)) {
                        OnbReqByCampNameMap.put('Contacts For : '+oOnbReq.Name, oOnbReq);
                    }
                }
                
                if(!OnbReqByCampNameMap.isEmpty()) {
                    Map<String, String> CampIdByCampNameMap =  CampaignService.setupOnboardingCampaign(OnbReqByCampNameMap);
                    for(Onboarding_Request__c oOnbReq : OnbReqByCampNameMap.values()) {
                        oOnbReq.Campaign__c = CampIdByCampNameMap.get('Contacts For : '+oOnbReq.Name);
                    }
                    update OnbReqByCampNameMap.values();
                }
            }
        } catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new OnboardingReqAndProdServiceException('Error Occured in OnboardingReqAndProdService::setupCampaignForOnbRequest() : '+ex.getMessage());
        }
    }
    
    public static void setupPrimaryContact(List<Onboarding_Request__c> OnbReqList) {
        System.debug('#### OnboardingReqAndProdService::setupPrimaryContact()');
        try {
            Map<String, String> AddPrimContIdByObReqIdMap = new Map<String, String>();
            Map<String, String> CampIdByObReqIdMap = new Map<String, String>();
            Set<String> RemPrimContForObReqIdSet = new Set<String>();
            for(Onboarding_Request__c oObReq : OnbReqList) {
                if(String.isNotBlank(oObReq.Campaign__c)) {
                    CampIdByObReqIdMap.put(oObReq.Id, oObReq.Campaign__c);
                    if(String.isNotBlank(oObReq.Who_did_you_meet_from_the_client_side__c)) {
                        AddPrimContIdByObReqIdMap.put(oObReq.Id, oObReq.Who_did_you_meet_from_the_client_side__c);
                    } else {
                        RemPrimContForObReqIdSet.add(oObReq.Id);
                    }
                }
            }
            CampaignService.setupOnboardingCampaignMembers(CampIdByObReqIdMap, AddPrimContIdByObReqIdMap, RemPrimContForObReqIdSet);
        } catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new OnboardingReqAndProdServiceException('Error Occured in OnboardingReqAndProdService::setupCampaignForOnbRequest() : '+ex.getMessage());
        }
    }
    
    public static Set<String> getObRequestRequiredFieldNames() {
        Set<String> requiredFields = new Set<String> ();
        for (SObjectField field : SObjectType.Onboarding_Request__c.fields.getMap().values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            if (!fieldDescribe.isNillable() && !fieldDescribe.isCalculated()) {
                requiredFields.add(fieldDescribe.getName());
            }
        }
        return requiredFields;
    }
    
    public static Map<String, String> findOnbRequestForCampaign(Set<string> CampIdSet) {
        System.debug('#### OnboardingReqAndProdService::findOnbRequestForCampaign()');
        Map<String, String> OnbReqIdByCampIdMap = new Map<String, String>();
        try {
            if(CampIdSet!=null && !CampIdSet.isEmpty()) {
                List<Onboarding_Request__c> OnbReqList = [SELECT Id, Campaign__c FROM Onboarding_Request__c 
                                                          WHERE Campaign__c IN :CampIdSet]; 
                for(Onboarding_Request__c oOnbReq : OnbReqList) {
                    OnbReqIdByCampIdMap.put(oOnbReq.Campaign__c, oOnbReq.Id);
                }
            }
        } catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new OnboardingReqAndProdServiceException('Error Occured in OnboardingReqAndProdService::findOnbRequestForCampaign() : '+ex.getMessage());
        }
        return OnbReqIdByCampIdMap;
    }
    

    public enum ONB_REQUEST_BULK_ACTION {ONB_REQ_APPROVE, ONB_REQ_REJECT, ONB_REQ_ADD_COMMENT}

    public class OnbRequestAction {
        @InvocableVariable(required=true)
        public String onbReqAction; 
        @InvocableVariable(required=true)
        public List<String> onbReqIdList;
        @InvocableVariable(required=false)
        public String comments;
    }

    @InvocableMethod(label='Add Comments, Approve/Reject Onboarding Request' description='Returns the message with the list of Onboarding Requests that cannot be completed.')
    public static List<String> processOnbReqAction(List<OnbRequestAction> OnbReqActionList) {

        System.debug('-- OnbRequestService::processApprovalRequest()');
        List<String> ProcessOutputMsgList = new List<String>();
        try {
            if(OnbReqActionList!=null && !OnbReqActionList.isEmpty() && !String.isBlank(OnbReqActionList[0].onbReqAction) && 
                    OnbReqActionList[0].OnbReqIdList!=null && !OnbReqActionList[0].OnbReqIdList.isEmpty()) {
                // Return result for each record
                Map<String, String> ErrorByOnbReqIdMap = new Map<String, String>();
                String processReqMsg = processOnbReqAction(OnbReqActionList[0].onbReqAction, OnbReqActionList[0].comments, 
                        OnbReqActionList[0].OnbReqIdList, ErrorByOnbReqIdMap);
                if(String.isNotBlank(processReqMsg)) { 
                    ProcessOutputMsgList.add(processReqMsg);
                }
                ProcessOutputMsgList.addAll(ErrorByOnbReqIdMap.values());
            } else {
                // error
                ProcessOutputMsgList.add('Error: Invalid Request');
            }
        } catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            ProcessOutputMsgList.add(ex.getMessage() + '\n' + ex.getStackTraceString());
            throw new OnboardingReqAndProdServiceException('Error Occured in OnbRequestService::processApprovalRequest() : '+ex.getMessage());
        }
        if(ProcessOutputMsgList.isEmpty()) {
            ProcessOutputMsgList.add('Action performed Successfully');

            //Event bus is used to publish event which is received by UtilityBarNotificatio and BulkApproval components.
            List<Request_Notification__e> requestNotifications = new List<Request_Notification__e>();
			Request_Notification__e requestNotification = new Request_Notification__e();
			requestNotification.Message__c = 'RequestProcessed';
			requestNotifications.add(requestNotification);
			
			EventBus.publish(requestNotifications);
        } else {
            String errorMsg = '';
            for(String err : ProcessOutputMsgList) {
                errorMsg+=err;
            }
            errorMsg+='\r\n'+'<b>Note: No Records are updated until all errors are fixed</b>';
            ProcessOutputMsgList.clear();
            ProcessOutputMsgList.add(errorMsg);
        }
        return ProcessOutputMsgList;

    }

    public static String processOnbReqAction(String onbReqAction, String comments, List<String> onbReqIdList, 
            Map<String, String> ErrorByOnbReqIdMap) {
        
        System.debug('---OnbRequestService::processOnbReqAction()');
        System.debug(onbReqAction);
        System.debug(comments);
        System.debug(onbReqIdList);
        String error = '';
        try {
            
            if(!String.isBlank(onbReqAction) && onbReqIdList!=null && !onbReqIdList.isEmpty())
            {
                Savepoint sp = Database.setSavepoint();
                if(onbReqAction==ONB_REQUEST_BULK_ACTION.ONB_REQ_APPROVE.name() || 
                        onbReqAction==ONB_REQUEST_BULK_ACTION.ONB_REQ_REJECT.name() ||
                        onbReqAction==ONB_REQUEST_BULK_ACTION.ONB_REQ_ADD_COMMENT.name() )
                {
                    String actionPerformed = onbReqAction==ONB_REQUEST_BULK_ACTION.ONB_REQ_APPROVE.name() ? 'Approve' : 
                                onbReqAction==ONB_REQUEST_BULK_ACTION.ONB_REQ_REJECT.name()  ? 'Reject' : null;
                    
                    //addCommentToOnbRequest(OnbReqIdList, comments);
                    
                    if(String.isNotBlank(actionPerformed)) {
                        //Approve,reject the record programmatically
                        Set<String> onbReqIdSet = new Set<String>();
                        for(String onbReqId : onbReqIdList)
                            onbReqIdSet.add(onbReqId);

                        Map<String, Onboarding_Request__c> onbRequestMap = OnboardingReqAndProdService.getOnbReqReqDetails(onbReqIdSet);
                        
                       
                        System.debug('--onbRequestMap--' + onbRequestMap);
                    
                        Map<String, ProcessInstanceWorkitem> ProcInstWorkItemList = new Map<String, ProcessInstanceWorkitem>([SELECT Id, ProcessInstanceId, ActorId, OriginalActorId, 
                                ProcessInstance.ProcessDefinitionId, ProcessInstance.ProcessDefinition.DeveloperName , ProcessInstance.Status, ProcessInstance.TargetObjectId  
                                FROM ProcessInstanceWorkitem 
                                WHERE ProcessInstanceId IN (SELECT Id FROM ProcessInstance 
                                        WHERE TargetObjectId IN :onbReqIdList AND Status IN ('Pending'))]);
                        System.debug('--ProcInstWorkItemList--' + ProcInstWorkItemList);
                        
                        Map<String, ProcessInstanceWorkitem> ProcWIBySchReqIdMap = new Map<String, ProcessInstanceWorkitem>();
                        for(ProcessInstanceWorkitem oPWI : ProcInstWorkItemList.values()) {
                            ProcWIBySchReqIdMap.put(oPWI.ProcessInstance.TargetObjectId, oPWI);
                            System.debug('ProcessInstance.ProcessDefinition.DeveloperName : '+oPWI.ProcessInstance.ProcessDefinition.DeveloperName);
                        }

            
                        List<Approval.ProcessWorkitemRequest> ProcessWorkitemReqList = new List<Approval.ProcessWorkitemRequest>();
                        for(String onbReqId : onbReqIdList) {
                            if(ProcWIBySchReqIdMap.containsKey(onbReqId) && !ErrorByOnbReqIdMap.containsKey(onbReqId)) {
                                ProcessInstanceWorkitem oProcInstWrkItem = ProcWIBySchReqIdMap.get(onbReqId);

                                System.debug('--oProcInstWrkItem.ActorId --' + oProcInstWrkItem.ActorId );                            
                                System.debug('--UserId --' + UserInfo.getUserId() );

                                // its a Approve or Reject or Cancel
                                if(oProcInstWrkItem.ActorId == UserInfo.getUserId() ||
                                                (UserHelper.SalesCaoApprUserIdSetBySalesCaoApprQueueIdMap.containsKey(oProcInstWrkItem.ActorId) && UserHelper.SalesCaoApprUserIdSetBySalesCaoApprQueueIdMap.get(oProcInstWrkItem.ActorId).contains(UserInfo.getUserId())) || 
                                  				(UserHelper.queueIdToAdditionalApprovers.containsKey(oProcInstWrkItem.ActorId) && UserHelper.queueIdToAdditionalApprovers.get(oProcInstWrkItem.ActorId).contains(UserInfo.getUserId())))
                                {
                                    System.debug('--inside approval method' );
                                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                                    req.setAction(actionPerformed);
                                    req.setWorkitemId(oProcInstWrkItem.Id);
                                    req.setComments(comments);
                                    ProcessWorkitemReqList.add(req);
                                } else {
                                    ErrorByOnbReqIdMap.put(onbReqId, onbRequestMap.get(onbReqId).Name+' cannot be processed by you');    
                                }
                            } 
                            else {
                                // error
                                ErrorByOnbReqIdMap.put(onbReqId, OnbRequestMap.get(onbReqId).Name+' is not in a Approval - Pending state');
                            } 
                        }

                        System.debug('---ProcessWorkitemReqList : '+ ProcessWorkitemReqList);
                        if(!ProcessWorkitemReqList.isEmpty()) {
                            // try to approve the records to check the errors
                            Approval.ProcessResult[] ApprovalProcessRsltList = Approval.process(ProcessWorkitemReqList, false);
                            Integer i=0;
                            for(Approval.ProcessResult oReqRslt : ApprovalProcessRsltList) {
                                System.debug('App Req Approval Error Err : '+ ' : '+oReqRslt.getEntityId()+' : '+oReqRslt.getErrors()+' : '+oReqRslt.getInstanceId()+' : '+oReqRslt.getInstanceStatus()+' : '+oReqRslt.getNewWorkitemIds());
                                System.debug('id : '+ProcInstWorkItemList.get(ProcessWorkitemReqList.get(i).getWorkitemId()).ProcessInstance.TargetObjectId);
                                String onbReqId = ProcInstWorkItemList.get(ProcessWorkitemReqList.get(i).getWorkitemId()).ProcessInstance.TargetObjectId;
                                if(!oReqRslt.isSuccess()) {
                                    String err = '';
                                    for(Database.Error dbErr : oReqRslt.getErrors()) {
                                        System.debug('err  : '+dbErr.getMessage());
                                        err+=dbErr.getMessage()+' , ';
                                    }
                                    err+='\r\n';
                                    ErrorByOnbReqIdMap.put(onbReqId, 
                                                        onbRequestMap.get(onbReqId).Name+' failed to \''+actionPerformed +
                                                        '\' with Errors: '+err);
                                } else {
                                    System.debug(onbRequestMap.get(oReqRslt.getEntityId()).Name+' : performed '+
                                                actionPerformed +' successfully');
                                }
                                ++i;
                            }
                        }
                    }
                }
                else {
                    // add error - invalid action
                    error = 'Error: Invalid Action';
                }
                if(String.isNotBlank(error) || !ErrorByOnbReqIdMap.isEmpty()) {
                    Database.rollback(sp);
                    System.debug('Rollback');
                } 
            } 
            else {
                // add error
                error = 'Error: Invalid Request';
            }
        } catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            error += ex.getMessage();
            throw new OnboardingReqAndProdServiceException('Error Occured in OnbRequestService::processApprovalRequest() : '+ex.getMessage());
        }
        
        return error;
    }



    public class OnboardingReqAndProdServiceException extends Exception {}
}
/*
@AuraEnabled (cacheable=true)
public static List<LookupSearchResult> searchRecords(String entityName) {
System.debug('#### OnboardingRequestService::searchRecords()');
List<LookupSearchResult> results = new List<LookupSearchResult>();
if(String.isNotBlank(entityName)) {
List<String> AccRTList = new List<String>(1);
AccRTList[0] = AccountService.AccountRecTypeInfoByRecTypeDevNameMap.get(AccountService.ACCOUNT_RT_NAME_RM_ACCOUNT).getRecordTypeId();
List<String> AccStageList = new List<String>{'Prospect', 'Fenergo Managed Client'};
List<Account> AccList = AccountService.findAccounts(entityName, null, null, null, false, AccRTList, AccStageList, true, 10, 0);
// Prepare results
// Extract Accounts & convert them into LookupSearchResult
String accountIcon = 'standard:account';
for (Account oAcc : AccList) {
results.add(
new LookupSearchResult(
oAcc.Id,
'Account',
accountIcon,
oAcc.Name,
'Account • ' + oAcc.Domicile_Country__c
)
);
}
}
return results;
}

@AuraEnabled (cacheable=true)
public static List<LookupSearchResult> searchNomuraPerson(String srcStr) {
System.debug('#### OnboardingRequestService::searchNomuraPerson()');
List<LookupSearchResult> results = new List<LookupSearchResult>();
if(String.isNotBlank(srcStr)) {
List<List<SObject>> SearchResults = [FIND :srcStr IN ALL FIELDS RETURNING USER(Id, Name, IsActive, Email, Title, UserRole.Name WHERE IsActive=True ORDER BY NAME ASC), 
CONTACT(Id,Name,Email,Active__c,Account.Parent.Name, Title, Account.RDM_Org_ID__c, RG_Account__r.RDM_Org_Id__c 
WHERE RG_Account__r.RDM_Org_Id__c = 'CPG12345' AND Active__c=True) Limit 10];

List<User> UserList = (List<User>)SearchResults[0]; 
for (User oUser : UserList) {
results.add(
new LookupSearchResult(
oUser.Id,
'User',
'standard:user',
oUser.Name,
'Title • ' + oUser.Title
)
);
}


List<Contact> ContactList = (List<Contact>)SearchResults[1]; 
for (Contact oCont : ContactList) {
results.add(
new LookupSearchResult(
oCont.Id,
'Contact',
'standard:contact',
oCont.Name,
'Title • ' + oCont.Title
)
);
}
}
return results;
}



*/