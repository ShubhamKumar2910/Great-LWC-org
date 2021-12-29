/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : This class implements the Service class for Fenergo Case, Fenergo Stage and Fenergo Task objects to implement 
** 				  business tasks, calculations and processes around these objects.
**
** Consumer of the Service Layer : Batch, Schedulable, Queuable/Apex API/UI Controllers/Inbpound Email Handlers/Invocable Method
**/
public without sharing class FenergoCaseAndStageAndTaskService {

    public static String FEN_CASE_SHR_REASON_REQ_REQUESTOR = Schema.Fenergo_Case__Share.RowCause.Ob_Req_Requestor__c;
    public static String FEN_CASE_SHR_REASON_REQ_SALES_REQUESTOR = Schema.Fenergo_Case__Share.RowCause.Ob_Req_Sales_Requestor_Appr__c;
    public static String FEN_CASE_SHR_REASON_REQ_DESK_HEAD = Schema.Fenergo_Case__Share.RowCause.Ob_Req_Desk_Head_Appr__c;
    public static String FEN_CASE_SHR_REASON_FEN_TASK_SALES_APPR = Schema.Fenergo_Case__Share.RowCause.Fen_Task_Sales_Appr__c;
    public static String FEN_CASE_SHR_REASON_FEN_TASK_DESK_HEAD_APPR = Schema.Fenergo_Case__Share.RowCause.Fen_Task_Desk_Head_Appr__c;

    public static Integer FEN_TASK_TEMP_ID_THAT_NEEDS_SALES_APPROVAL {
        public get{
            return Integer.valueOf(System.Label.Fenergo_Task_Template_Id_That_Req_Sales_Approval);
        }
        private set;
    }

    public static Integer FEN_TASK_TEMP_ID_THAT_NEEDS_DESK_HEAD_APPROVAL {
        public get{
            return Integer.valueOf(System.Label.Fenergo_Task_Template_Id_That_Req_Desk_Head_Approval);
        }
        private set;
    } 

    public static void manageFenCaseSharingBasedOnPreObReq(Map<String, List<String>> DelSharFenCaseIdListByPreObReqIdMap, 
            Map<String, List<String>> CrtSharFenCaseIdListByPreObReqIdMap) {
        System.debug('#### FenergoCaseAndStageAndTaskService.manageFenCaseSharingBasedOnPreObReq()');
        try{
            Set<String> PreObReqIdSet = new Set<String>();
            if(CrtSharFenCaseIdListByPreObReqIdMap!=null && !CrtSharFenCaseIdListByPreObReqIdMap.isEmpty()) {
                PreObReqIdSet.addAll(CrtSharFenCaseIdListByPreObReqIdMap.keySet());
            }
            if(DelSharFenCaseIdListByPreObReqIdMap!=null && !DelSharFenCaseIdListByPreObReqIdMap.isEmpty()) {
                PreObReqIdSet.addAll(DelSharFenCaseIdListByPreObReqIdMap.keySet());
            }
            Map<String, Onboarding_Request__c> PreObReqByIdMap = OnboardingReqAndProdService.getOnbReqReqDetails(PreObReqIdSet); 

            Set<String> FenCaseIdSet = new Set<String>(), 
                        RequestorIdSet = new Set<String>(), 
                        SalesRequestorIdSet = new Set<String>(), 
                        DeskHeadIdSet  = new Set<String>();
            if(DelSharFenCaseIdListByPreObReqIdMap!=null) {
                for(String onbReqId : DelSharFenCaseIdListByPreObReqIdMap.keySet()) {
                    Onboarding_Request__c oOnbReq = PreObReqByIdMap.get(onbReqId);
                    FenCaseIdSet.addAll(DelSharFenCaseIdListByPreObReqIdMap.get(onbReqId));
                    RequestorIdSet.add(oOnbReq.CreatedById);
                    if(String.isNotEmpty(oOnbReq.Sales_Requestor__c)) {
                        SalesRequestorIdSet.add(oOnbReq.Sales_Requestor__c);
                    }
                    if(String.isNotEmpty(oOnbReq.Desk_Head_Approver__c)) {
                        DeskHeadIdSet.add(oOnbReq.Desk_Head_Approver__c);
                    }
                }
            }

            // query Fenergo_Case__Share
            /*List<Fenergo_Case__Share> FenCaseShareList = [SELECT Id 
                FROM Fenergo_Case__Share 
                WHERE ParentId IN :FenCaseIdSet AND 
                      ((UserOrGroupId IN :RequestorIdSet AND RowCause = :Schema.Fenergo_Case__Share.RowCause.Requestor__c) OR
                       (UserOrGroupId IN :SalesRequestorIdSet AND RowCause = :Schema.Fenergo_Case__Share.RowCause.Sales_Requestor__c) OR
                       (UserOrGroupId IN :DeskHeadIdSet AND RowCause = :Schema.Fenergo_Case__Share.RowCause.Desk_Head__c))];
            */
            List<Fenergo_Case__Share> FenCaseShareList = getFenCaseShareForPreObReq(FenCaseIdSet, RequestorIdSet, 
                                                            SalesRequestorIdSet, DeskHeadIdSet);
            if(!FenCaseShareList.isEmpty()) {
                delete FenCaseShareList;
            }

            FenCaseShareList.clear();
            if(CrtSharFenCaseIdListByPreObReqIdMap!=null) {
                for(String onbReqId : CrtSharFenCaseIdListByPreObReqIdMap.keySet()) {
                    Onboarding_Request__c oOnbReq = PreObReqByIdMap.get(onbReqId);
                    for(String fenCaseId : CrtSharFenCaseIdListByPreObReqIdMap.get(onbReqId)) {
                        if (oOnbReq != null) {
                            if(oOnbReq.CreatedById != oOnbReq.Sales_Requestor__c) {
                                FenCaseShareList.add(createFenergoShareRec(fenCaseId, 
                                                                           oOnbReq.CreatedById, 'read', FEN_CASE_SHR_REASON_REQ_REQUESTOR));
                            }
                            if(String.isNotEmpty(oOnbReq.Sales_Requestor__c)) {
                                FenCaseShareList.add(createFenergoShareRec(fenCaseId, 
                                                                           oOnbReq.Sales_Requestor__c, 'read', FEN_CASE_SHR_REASON_REQ_SALES_REQUESTOR));
                            }
                            if(String.isNotEmpty(oOnbReq.Desk_Head_Approver__c)) {
                                FenCaseShareList.add(createFenergoShareRec(fenCaseId, 
                                                                           oOnbReq.Desk_Head_Approver__c, 'read', FEN_CASE_SHR_REASON_REQ_DESK_HEAD));
                            }
                        }
                    }
                }
            }
            if(!FenCaseShareList.isEmpty()) {
                insert FenCaseShareList;
            }
        } catch(Exception ex) {
			System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new FenergoCaseAndStageAndTaskServiceException('Error Occured in FenergoCaseAndStageAndTaskService::manageFenCaseSharingBasedOnPreObReq() : '+ex.getMessage());
		}
    }

    public static List<Fenergo_Case__Share> getFenCaseShareForPreObReq(Set<String> FenCaseIdSet, Set<String> RequestorIdSet, 
            Set<String> SalesRequestorIdSet, Set<String> DeskHeadIdSet) {
        System.debug('#### FenergoCaseAndStageAndTaskService.getFenCaseShareForPreObReq()');
        List<Fenergo_Case__Share> FenCaseShareList = new List<Fenergo_Case__Share>();
        if(FenCaseIdSet!=null && !FenCaseIdSet.isEmpty()) {
            Boolean isValidQuery = false;
            String query = 'SELECT Id, UserOrGroupId, ParentId, RowCause FROM Fenergo_Case__Share WHERE ParentId IN :FenCaseIdSet AND ( ';
            if(RequestorIdSet!=null && !RequestorIdSet.isEmpty()) {
                query += '(UserOrGroupId IN :RequestorIdSet AND RowCause = :FEN_CASE_SHR_REASON_REQ_REQUESTOR)';
                isValidQuery = true;
            }
            if(SalesRequestorIdSet!=null && !SalesRequestorIdSet.isEmpty()) {
                query += (isValidQuery ? ' OR ' : '')+
                        '(UserOrGroupId IN :SalesRequestorIdSet AND RowCause = :FEN_CASE_SHR_REASON_REQ_SALES_REQUESTOR)';
                isValidQuery = true;
            }
            if(DeskHeadIdSet!=null && !DeskHeadIdSet.isEmpty()) {
                query += (isValidQuery ? ' OR ' : '')+
                        '(UserOrGroupId IN :DeskHeadIdSet AND RowCause = :FEN_CASE_SHR_REASON_REQ_DESK_HEAD)';
                isValidQuery = true;
            }
            query +=')';
            System.debug('query : '+query);
            if(isValidQuery) {
                FenCaseShareList = (List<Fenergo_Case__Share>)Database.query(query);
            }
        }
        return FenCaseShareList;
    }

    public static List<Fenergo_Case__Share> getFenCaseShareForFenTask(Set<String> FenCaseIdSalesApprShrSet, Set<String> UserIdSalesApprShrSet, 
                    Set<String> FenCaseIdDeskHeadApprShrSet, Set<String> UserIdDeskHeadApprShrSet) {
        System.debug('#### FenergoCaseAndStageAndTaskService.getFenCaseShare()');
        List<Fenergo_Case__Share> FenCaseShareList = new List<Fenergo_Case__Share>();
        Boolean isValidQuery = false;
        String query = 'SELECT Id, UserOrGroupId, ParentId, RowCause FROM Fenergo_Case__Share WHERE ';
        if(FenCaseIdSalesApprShrSet!=null && !FenCaseIdSalesApprShrSet.isEmpty() &&
                UserIdSalesApprShrSet!=null && !UserIdSalesApprShrSet.isEmpty()) {
            query += '(ParentId IN :FenCaseIdSalesApprShrSet AND UserOrGroupId IN :UserIdSalesApprShrSet AND '+
                     'RowCause = :FEN_CASE_SHR_REASON_FEN_TASK_SALES_APPR) ';
            isValidQuery = true;
        }
        if(FenCaseIdDeskHeadApprShrSet!=null && !FenCaseIdDeskHeadApprShrSet.isEmpty() &&
                UserIdDeskHeadApprShrSet!=null && !UserIdDeskHeadApprShrSet.isEmpty()) {
            query += (isValidQuery ? 'OR' : '') +
                     '(ParentId IN :FenCaseIdDeskHeadApprShrSet AND UserOrGroupId IN :UserIdDeskHeadApprShrSet AND '+
                     'RowCause = :FEN_CASE_SHR_REASON_FEN_TASK_DESK_HEAD_APPR) ';
            isValidQuery = true;
        }
        System.debug('query : '+query);
        if(isValidQuery) {
            FenCaseShareList = (List<Fenergo_Case__Share>)Database.query(query);
        }
        return FenCaseShareList;
    }

    // e.g. Map<'kundalpr', Map<'Fen_Task_Sales_Appr__c', Set<FenCase1.Id, FenCase2.Id>>> 
    public static void manageFenCaseSharingBasedOnFenTask(Map<String, Map<String, Set<String>>> DelShrFenCaseIdSetByShrTypeMapByUserFedIdMap,
                Map<String, Map<String, Set<String>>> CrtShrFenCaseIdSetByShrTypeMapByUserFedIdMap) {
        System.debug('#### FenergoCaseAndStageAndTaskService.manageFenCaseSharingBasedOnFenTask()');
        Set<String> UserFedIsSet = new Set<String>();
        try {
            // Step 1: Get the User.Id of all the Users for whom the Share needs to be deleted or created.
            //         it could be possible that we may not find a User against a given User Federation Id, this is
            //         specially in scenarios where Fenergo sends us dummy values for AssignedT=='KYC etc...' on task   
            if(DelShrFenCaseIdSetByShrTypeMapByUserFedIdMap!=null && !DelShrFenCaseIdSetByShrTypeMapByUserFedIdMap.isEmpty()) {
                UserFedIsSet.addAll(DelShrFenCaseIdSetByShrTypeMapByUserFedIdMap.keySet());
            }
            if(CrtShrFenCaseIdSetByShrTypeMapByUserFedIdMap!=null && !CrtShrFenCaseIdSetByShrTypeMapByUserFedIdMap.isEmpty()) {
                UserFedIsSet.addAll(CrtShrFenCaseIdSetByShrTypeMapByUserFedIdMap.keySet());
            }
            // get the User details 
            Map<String, String> UserIdByFedIdMap = UserHelper.getUserDetailsByUserFedId(UserFedIsSet);

            // Step 2: If there are Users found against the given Federatiuon IDs that means we need to manipulate sharing
            if(!UserIdByFedIdMap.isEmpty()) {
                // Step 3 : construct the data-structures sets for FenCase.Ids, User.Ids based on Sharing type from
                //          DelShrFenCaseIdSetByShrTypeMapByUserFedIdMap and CrtShrFenCaseIdSetByShrTypeMapByUserFedIdMap
                Set<String> UserIdToDelSalesShrSet = new Set<String>(), UserIdToDelDeskHeadShrSet = new Set<String>(),
                        FenCaseIdToDelSalesReqShrSet = new Set<String>(), FenCaseIdToDelDeskHeadReqShrSet = new Set<String>();
                Set<String> FenCaseIdSet = new Set<String>(), UserIdSet = new Set<String>(); 
                // loop throug the User.FedIds which we have found in the System
                for(String userFedId : UserIdByFedIdMap.keySet()) {
                    String userId = UserIdByFedIdMap.get(userFedId);
                    // populate the structures to get the Fen_Case_Share records based on sharing from FenTasks
                    Map<String, Set<String>> DelShrFenCaseIdSetByShrTypeMap = DelShrFenCaseIdSetByShrTypeMapByUserFedIdMap.get(userFedId);
                    if(DelShrFenCaseIdSetByShrTypeMap!=null) {
                        if(DelShrFenCaseIdSetByShrTypeMap.containsKey(FEN_CASE_SHR_REASON_FEN_TASK_SALES_APPR)) {
                            UserIdToDelSalesShrSet.add(userId);
                            FenCaseIdToDelSalesReqShrSet.addAll(DelShrFenCaseIdSetByShrTypeMap.get(FEN_CASE_SHR_REASON_FEN_TASK_SALES_APPR));
                        }
                        if(DelShrFenCaseIdSetByShrTypeMap.containsKey(FEN_CASE_SHR_REASON_FEN_TASK_DESK_HEAD_APPR)) {
                            UserIdToDelDeskHeadShrSet.add(userId);
                            FenCaseIdToDelDeskHeadReqShrSet.addAll(DelShrFenCaseIdSetByShrTypeMap.get(FEN_CASE_SHR_REASON_FEN_TASK_DESK_HEAD_APPR));
                        }
                    }

                    // populate the structures to get the Fen_Case_Share records based on sharing from Pre-OB request
                    Map<String, Set<String>> CrtShrFenCaseIdSetByShrTypeMap = CrtShrFenCaseIdSetByShrTypeMapByUserFedIdMap.get(userFedId);
                    if(CrtShrFenCaseIdSetByShrTypeMap!=null) {
                        if(CrtShrFenCaseIdSetByShrTypeMap.containsKey(FEN_CASE_SHR_REASON_FEN_TASK_SALES_APPR)) {
                            UserIdSet.add(userId);
                            FenCaseIdSet.addAll(CrtShrFenCaseIdSetByShrTypeMap.get(FEN_CASE_SHR_REASON_FEN_TASK_SALES_APPR));
                        }
                        if(CrtShrFenCaseIdSetByShrTypeMap.containsKey(FEN_CASE_SHR_REASON_FEN_TASK_DESK_HEAD_APPR)) {
                            UserIdSet.add(userId);
                            FenCaseIdSet.addAll(CrtShrFenCaseIdSetByShrTypeMap.get(FEN_CASE_SHR_REASON_FEN_TASK_DESK_HEAD_APPR));
                        }
                    }
                }
                
                // Step 4: query and delete the FenCaseShare based on Fen Task
                // query Fenergo_Case__Share that should be deleted based on FenTask sharing
                List<Fenergo_Case__Share> FenCaseShareList = getFenCaseShareForFenTask(FenCaseIdToDelSalesReqShrSet, UserIdToDelSalesShrSet, 
                        FenCaseIdToDelDeskHeadReqShrSet, UserIdToDelDeskHeadShrSet);
                System.debug('Fen-Task FenCaseShareList : '+FenCaseShareList.size()+' : '+FenCaseShareList);
                if(!FenCaseShareList.isEmpty()) {
                    delete FenCaseShareList;
                }

                // Step 5: query and the FenCaseShare based on Pre-OB request and only create a new FenTask based sharing
                //         if the FenTask has not already been shared based on Pre-Ob 
                // query the existing Fenergo Case Shares based on Pre-Onb request so that duplicates are not created again.
                FenCaseShareList.clear();
                FenCaseShareList = getFenCaseShareForPreObReq(FenCaseIdSet, UserIdSet, UserIdSet, UserIdSet);
                System.debug('Pre-Ob FenCaseShareList : '+FenCaseShareList.size()+' : '+FenCaseShareList);
                // the following map holds if the User has any access on a list of Fenergo Cases
                Map<String, Set<String>> FenCaseIdSetByUserIdMap = new Map<String, Set<String>>();
                for(Fenergo_Case__Share oFenCaseShare : FenCaseShareList) {
                    FenCaseIdSet = FenCaseIdSetByUserIdMap.containsKey(oFenCaseShare.UserOrGroupId) ?
                                FenCaseIdSetByUserIdMap.get(oFenCaseShare.UserOrGroupId) : new Set<String>();
                    FenCaseIdSet.add(oFenCaseShare.ParentId);
                    FenCaseIdSetByUserIdMap.put(oFenCaseShare.UserOrGroupId, FenCaseIdSet);
                }

                // Step 6: Now check that no FenCaseShare already exists for a given User and a FenCase and create a new 
                //         FenCaseShare based on FenTask 
                List<Fenergo_Case__Share> FenCaseShareToAddList = new List<Fenergo_Case__Share>();
                for(String userFedId : UserIdByFedIdMap.keySet()) {
                    Map<String, Set<String>> CrtShrFenCaseIdSetByShrTypeMap = CrtShrFenCaseIdSetByShrTypeMapByUserFedIdMap.get(userFedId);
                    
                    if(CrtShrFenCaseIdSetByShrTypeMap!=null) {
                        String userId = UserIdByFedIdMap.get(userFedId);
                        FenCaseIdSet = FenCaseIdSetByUserIdMap.containsKey(userId) ? FenCaseIdSetByUserIdMap.get(userId) : new Set<String>();
                        if(CrtShrFenCaseIdSetByShrTypeMap.containsKey(FEN_CASE_SHR_REASON_FEN_TASK_SALES_APPR)) {
                            for(String fenCaseId : CrtShrFenCaseIdSetByShrTypeMap.get(FEN_CASE_SHR_REASON_FEN_TASK_SALES_APPR)) {
                                if(!FenCaseIdSet.contains(fenCaseId)) {
                                    FenCaseShareToAddList.add(createFenergoShareRec(fenCaseId, userId, 'read', FEN_CASE_SHR_REASON_FEN_TASK_SALES_APPR));
                                }
                            }
                        }
                        if(CrtShrFenCaseIdSetByShrTypeMap.containsKey(FEN_CASE_SHR_REASON_FEN_TASK_DESK_HEAD_APPR)) {
                            for(String fenCaseId : CrtShrFenCaseIdSetByShrTypeMap.get(FEN_CASE_SHR_REASON_FEN_TASK_DESK_HEAD_APPR)) {
                                if(!FenCaseIdSet.contains(fenCaseId)) {
                                    FenCaseShareToAddList.add(createFenergoShareRec(fenCaseId, userId, 'read', FEN_CASE_SHR_REASON_FEN_TASK_DESK_HEAD_APPR));
                                }
                            }
                        }
                    }
                }
                // create new share records
                if(!FenCaseShareToAddList.isEmpty()) {
                    insert FenCaseShareToAddList;
                }
            }
        } catch(Exception ex) {
			System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new FenergoCaseAndStageAndTaskServiceException('Error Occured in FenergoCaseAndStageAndTaskService::manageFenCaseSharingBasedOnFenTask() : '+ex.getMessage());
		}
    }


    public static void getFenergoTaskAndStagesForFenergoCaseIds(Set<Integer> FenCaseIdSet, Map<Integer, Fenergo_Case__c> FenCaseByFenCaseIdMap, 
            Map<Integer, Map<String, Fenergo_Case_Stage__c>> FenStageByFenStageNameMapByFenCaseIdMap) {
        System.debug('#### FenergoCaseAndStageAndTaskService.getFenergoTaskAndStagesForFenergoCaseIds()');
        try {
            if(FenCaseIdSet!=null && !FenCaseIdSet.isEmpty()) {
                for(Fenergo_Case__c oFenCase : [SELECT Id, CaseId__c, RM_Account__c, RG_Account__c, LegalEntityId__c, Onboarding_Request__c,
                            (SELECT Id, Name, StageName__c FROM Fenergo_Case_Stages__r)
                        FROM Fenergo_Case__c
                        WHERE CaseId__c IN : FenCaseIdSet]) {
                    Integer caseId = (Integer)oFenCase.CaseId__c;
                    FenCaseByFenCaseIdMap.put(caseId, oFenCase);
                    for(Fenergo_Case_Stage__c oFenStage : oFenCase.Fenergo_Case_Stages__r) {
                        if(String.isNotBlank(oFenStage.StageName__c)) {
                            Map<String, Fenergo_Case_Stage__c> FenStageByFenStageNameMap = FenStageByFenStageNameMapByFenCaseIdMap.containsKey(caseId) ? 
                                   FenStageByFenStageNameMapByFenCaseIdMap.get(caseId)  : new Map<String, Fenergo_Case_Stage__c>();
                            FenStageByFenStageNameMap.put(oFenStage.StageName__c, oFenStage);
                            FenStageByFenStageNameMapByFenCaseIdMap.put(caseId, FenStageByFenStageNameMap);
                        }
                    }
                }
            }
        } catch(Exception ex) {
			System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new FenergoCaseAndStageAndTaskServiceException('Error Occured in FenergoCaseAndStageAndTaskService::manageFenCaseSharingBasedOnPreObReq() : '+ex.getMessage());
		}
    }

    public static Fenergo_Case__Share createFenergoShareRec(String fenCaseId, 
            String userOrGrpId, String accessLevel, String rowCause) {
        Fenergo_Case__share oFenCaseShare = new Fenergo_Case__share();
        // Set the ID of record being shared.
        oFenCaseShare.ParentId = fenCaseId;
        // Set the ID of user or group being granted access.
        oFenCaseShare.UserOrGroupId = userOrGrpId;
        // Set the access level.
        oFenCaseShare.AccessLevel = accessLevel;
        // Set the Apex sharing reason for Requestor
        oFenCaseShare.RowCause = rowCause; 
        return oFenCaseShare;
    }

    public class FenergoCaseAndStageAndTaskServiceException extends Exception {}
}

/*
// e.g. Map<'kundalpr', Map<'Sales_Requestor__c', Set<FenCase1.Id, FenCase2.Id>>> 
    public static void manageFenCaseSharingBasedOnFenTask(Map<String, Map<String, Set<String>>> DelShrFenCaseIdSetByShrTypeMapByUserFedIdMap,
                Map<String, Map<String, Set<String>>> CrtShrFenCaseIdSetByShrTypeMapByUserFedIdMap) {
        System.debug('#### FenergoCaseAndStageAndTaskService.manageFenCaseSharingBasedOnFenTask()');
        Set<String> UserFedIsSet = new Set<String>();
        try {
            if(DelShrFenCaseIdSetByShrTypeMapByUserFedIdMap!=null && !DelShrFenCaseIdSetByShrTypeMapByUserFedIdMap.isEmpty()) {
                UserFedIsSet.addAll(DelShrFenCaseIdSetByShrTypeMapByUserFedIdMap.keySet());
            }
            if(CrtShrFenCaseIdSetByShrTypeMapByUserFedIdMap!=null && !CrtShrFenCaseIdSetByShrTypeMapByUserFedIdMap.isEmpty()) {
                UserFedIsSet.addAll(CrtShrFenCaseIdSetByShrTypeMapByUserFedIdMap.keySet());
            }

            // get the User details 
            Map<String, String> UserIdByFedIdMap = UserHelper.getUserDetailsByUserFedId(UserFedIsSet);

            if(!UserIdByFedIdMap.isEmpty()) {
                // First delete the share records that needs to be deleted
                List<Fenergo_Case__Share> FenCaseShareToAddList = new List<Fenergo_Case__Share>();
                Set<String> UserIdToDelSalesShrSet = new Set<String>(), UserIdToDelDeskHeadShrSet = new Set<String>(),
                        FenCaseIdToDelSalesReqShrSet = new Set<String>(), FenCaseIdToDelDeskHeadReqShrSet = new Set<String>();
                for(String userFedId : UserIdByFedIdMap.keySet()) {
                    String userId = UserIdByFedIdMap.get(userFedId);
                    Map<String, Set<String>> DelShrFenCaseIdSetByShrTypeMap = DelShrFenCaseIdSetByShrTypeMapByUserFedIdMap.get(userFedId);
                    if(DelShrFenCaseIdSetByShrTypeMap!=null) {
                        if(DelShrFenCaseIdSetByShrTypeMap.containsKey(Schema.Fenergo_Case__Share.RowCause.Sales_Requestor__c)) {
                            UserIdToDelSalesShrSet.add(userId);
                            FenCaseIdToDelSalesReqShrSet.addAll(DelShrFenCaseIdSetByShrTypeMap.get(Schema.Fenergo_Case__Share.RowCause.Sales_Requestor__c));
                        }
                        if(DelShrFenCaseIdSetByShrTypeMap.containsKey(Schema.Fenergo_Case__Share.RowCause.Desk_Head__c)) {
                            UserIdToDelDeskHeadShrSet.add(userId);
                            FenCaseIdToDelDeskHeadReqShrSet.addAll(DelShrFenCaseIdSetByShrTypeMap.get(Schema.Fenergo_Case__Share.RowCause.Desk_Head__c));
                        }
                    } 

                    Map<String, Set<String>> CrtShrFenCaseIdSetByShrTypeMap = CrtShrFenCaseIdSetByShrTypeMapByUserFedIdMap.get(userFedId);
                    if(CrtShrFenCaseIdSetByShrTypeMap!=null) {
                        if(CrtShrFenCaseIdSetByShrTypeMap.containsKey(Schema.Fenergo_Case__Share.RowCause.Sales_Requestor__c)) {
                            for(String fenCaseId : CrtShrFenCaseIdSetByShrTypeMap.get(Schema.Fenergo_Case__Share.RowCause.Sales_Requestor__c)) {
                                FenCaseShareToAddList.add(createFenergoShareRec(fenCaseId, 
                                    userId, 'read', Schema.Fenergo_Case__Share.RowCause.Sales_Requestor__c));
                            }
                        }
                        if(CrtShrFenCaseIdSetByShrTypeMap.containsKey(Schema.Fenergo_Case__Share.RowCause.Desk_Head__c)) {
                            for(String fenCaseId : CrtShrFenCaseIdSetByShrTypeMap.get(Schema.Fenergo_Case__Share.RowCause.Desk_Head__c)) {
                                FenCaseShareToAddList.add(createFenergoShareRec(fenCaseId, 
                                    userId, 'read', Schema.Fenergo_Case__Share.RowCause.Desk_Head__c));
                            }
                        }
                    }
                }
                // query Fenergo_Case__Share
                List<Fenergo_Case__Share> FenCaseShareList = getFenCaseShareForFenTask(FenCaseIdToDelSalesReqShrSet, UserIdToDelSalesShrSet, 
                        FenCaseIdToDelDeskHeadReqShrSet, UserIdToDelDeskHeadShrSet);
                if(!FenCaseShareList.isEmpty()) {
                    delete FenCaseShareList;
                }

                // create new share records
                if(!FenCaseShareToAddList.isEmpty()) {
                    insert FenCaseShareToAddList;
                }
            }
        } catch(Exception ex) {
			System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new FenergoCaseAndStageAndTaskServiceException('Error Occured in FenergoCaseAndStageAndTaskService::manageFenCaseSharingBasedOnFenTask() : '+ex.getMessage());
		}
    }
*/