/**
**  Author      : Pravin Kundal
**  Company     : Nomura
**  Description : This class implements the Service class for ECH Request object to implement 
**                business tasks, calculations and processes around SCH Request object.
**
** Consumer of the Service Layer : Batch, Schedulable, Queuable/Apex API/UI Controllers/Inbpound Email Handlers/Invocable Method
**/
public without sharing class SchRequestService {

    private static Map<UserHelper.USER_DETAILS_AND_PERMISSIONS, Set<String>> UserIdSetByDetAndPermEnum;

    public static Map<UserHelper.USER_DETAILS_AND_PERMISSIONS, Set<String>> getSchReqUserDetailsAndPermissions(
                    List<SCH_Request__c> SchRequestList) {
        System.debug('#### SchRequestService::getSchReqUserDetailsAndPermissions()');
        try{
            if(UserIdSetByDetAndPermEnum==null) {
                if(SchRequestList!=null) {
                    Set<String> UserIdSet = new Set<String>();
                    for(SCH_Request__c oSchReq : SchRequestList) {
                        if(String.isNotBlank(oSchReq.CreatedById)) {
                            UserIdSet.add(oSchReq.CreatedById);
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
            throw new SchRequestServiceException('Error Occured in SchRequestService::getSchReqUserDetailsAndPermissions() : '+ex.getMessage());
        }        
        return UserIdSetByDetAndPermEnum;
    }
    
    @future
    public static void submitSchReqForApproval(List<String> SchReqToSubmitForFinalApprList) {
        System.debug('#### SchRequestService::submitSchReqForApproval');
        try {
            List<String> SchReqIdList = new List<String>();
            if(SchReqToSubmitForFinalApprList!=null && !SchReqToSubmitForFinalApprList.isEmpty()) {
               
                Map<String, SCH_Request__c> SCHRequestMap = getSchReqDetails(new List<String>(SchReqToSubmitForFinalApprList));
                getSchReqUserDetailsAndPermissions(SCHRequestMap.values());
                Map<String, Map<String, Set<String>>> TargetIdSetByEmailTempNameMapByWhatIdMap = 
                        new Map<String, Map<String, Set<String>>>();
                List<Approval.ProcessSubmitRequest> ApprovalProcessRequestList = new List<Approval.ProcessSubmitRequest>();
            
                for(String schReqId : SchReqToSubmitForFinalApprList) {
                    System.debug('Submitting for final approval : '+schReqId);
                    SCH_Request__c oSchReq = SCHRequestMap.get(schReqId);
                    
                    if(oSchReq != null && String.isNotBlank(oSchReq.Role_Based_Region_Of_Requestor__c)) {
                        if(String.isNotBlank(oSchReq.CreatedById)) {
                            String addPerm = UserHelper.USER_ADD_PERMISSION_SCH_APPROVER_REG;
                            String roleBasedRegion = oSchReq.Role_Based_Region_Of_Requestor__c.toUpperCase();
                            List<String> podRecordTypes = new List<String>{'POD_Creation', 'POD_Account_Modification'};

                            List<ProcessDefinition> SCHApprovalProcess = [SELECT Id FROM ProcessDefinition 
                                                                   WHERE DeveloperName = 'Second_Level_Approval_For_All_Regions' 
                                                                   AND State = 'Active'];
                            if (!SCHApprovalProcess.isEmpty()) {
                                Approval.ProcessSubmitRequest oReq = new Approval.ProcessSubmitRequest();
                                oReq.setComments('Auto Submitting SCH Request for approval');
                                oReq.setObjectId(schReqId);
                                String approverId = UserHelper.SCHApproverQueueIdsByQueueName.get(UserHelper.SCHApproverQueueNameListByLocMapByAddPermMap.get(addPerm).get(roleBasedRegion)[0]);
                                if(roleBasedRegion != 'JAPAN' && podRecordTypes.contains(oSchReq.RecordType.DeveloperName)) {
                                    oReq.setNextApproverIds(new Id[] {oSchReq.Desk_Head_Approver__c});
                                    SchRequestController.shareRequestWithDeskHeadApprover(oSchReq);
                                }
                                else
                                    oReq.setNextApproverIds(new Id[] {approverId});
                                oReq.setSkipEntryCriteria(true);
                                oReq.setSubmitterId(oSchReq.CreatedById);
                                oReq.setProcessDefinitionNameOrId('Second_Level_Approval_For_All_Regions');
                                ApprovalProcessRequestList.add(oReq);
                                        
                                String queueApiName = UserHelper.SCHApproverQueueNameListByLocMapByAddPermMap.get(addPerm).get(roleBasedRegion)[0];
                                //Assign Queue name on SCH Request
                                if(String.isNotBlank(approverId)){
                                    Group grpObj = [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName = :queueApiName];
                                    if(grpObj != null){
                                        if(roleBasedRegion != 'JAPAN' && podRecordTypes.contains(oSchReq.RecordType.DeveloperName)) {
                                            oSchReq.Approver__c = oSchReq.Desk_Head_Approver__r.Name;
                                        }
                                        else {
                                            oSchReq.Approver__c = grpObj.Name;
                                        }
                                        System.debug('------1oSchReq.Approver__c---' + oSchReq.Approver__c);
                                        update oSchReq;
                                    }
                                }
                            
                                if(UserHelper.SCHApprUserIdSetBySCHApprQueueIdMap.containsKey(approverId) && 
                                   !UserHelper.SCHApprUserIdSetBySCHApprQueueIdMap.get(approverId).isEmpty()) {
                                       Set<String> TargetIdSet = new Set<String>();
                                       if(roleBasedRegion != 'JAPAN' && podRecordTypes.contains(oSchReq.RecordType.DeveloperName)) {
                                            TargetIdSet.add(oSchReq.Desk_Head_Approver__c);
                                        }
                                        else {
                                            TargetIdSet.addAll(UserHelper.SCHApprUserIdSetBySCHApprQueueIdMap.get(approverId));
                                        }
                                       Map<String, Set<String>> TargetIdSetByEmailTempNameMap = new Map<String, Set<String>>();
                                       TargetIdSetByEmailTempNameMap.put(System.Label.SCH_Req_Approval_Req_By_Creator_Email_Template, TargetIdSet);
                                       TargetIdSetByEmailTempNameMapByWhatIdMap.put(schReqId, TargetIdSetByEmailTempNameMap);
                                       
                                } else {
                                       System.debug('Email will not be sent to the Approver for '+oSchReq.Name+' SCH Request as corroesponding Queue is empty');
                                }
            
                            }
                            else {
                                System.debug('Could not submit SCH request for approval as Approval Request does not exist');
                            }
                        }   
                        else {
                            System.debug('Request : '+oSchReq.Name+' not submitted for approval as CreatedById field is blank');
                        }
                    }
                    else {
                        System.debug('Request : '+oSchReq+' not submitted for approval as Creator\'s Role based Region is not setup correctly');
                    }
                }           

                if(!ApprovalProcessRequestList.isEmpty()) {
                    // Submit the approval request
                    Approval.ProcessResult[] ApprovalProcessRsltList = Approval.process(ApprovalProcessRequestList);
                    for(Approval.ProcessResult oReqRslt : ApprovalProcessRsltList) {
                        System.debug('App Req Submit Err : '+ oReqRslt.getEntityId()+' : '+oReqRslt.getEntityId()+' : '+oReqRslt.getErrors());
                    }

                    EmailNotificationService.sendUsingSingleEmail(TargetIdSetByEmailTempNameMapByWhatIdMap);
                }
            }
        } catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new SchRequestServiceException('Error Occured in SchRequestService::submitSchReqForApproval() : '+ex.getMessage());
        }
     }

    private static Map<String, SCH_Request__c> SchRequestMap;
    public static Map<String, SCH_Request__c> getSchReqDetails(List<String> SchReqIdList) {
        System.debug('#### SchRequestService::getSchReqDetails');
        //Map<String, SCH_Request__c> SchRequestMap = new Map<String, SCH_Request__c>();
        try {
            if(SchRequestMap==null) {
                if(SchReqIdList!=null && !SchReqIdList.isEmpty()) {
                    SchRequestMap = new Map<String, SCH_Request__c>([SELECT Id, Name, CreatedById, Role_Based_Region_Of_Requestor__c,Is_Final_Approval_Completed__c, Desk_Head_Approver__c, Desk_Head_Approver__r.Name, Status__c, Sub_Status__c, Is_Cancelled__c, RecordType.Name, RecordType.DeveloperName FROM SCH_Request__c 
                    WHERE  Id IN :SchReqIdList AND RecordType.DeveloperName IN ('Create_RM_Prospect', 'POD_Creation', 'POD_Account_Modification')]);
                }
            }
        } catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new SchRequestServiceException('Error Occured in SchRequestService::getSchReqDetails() : '+ex.getMessage());
        }        
        return SchRequestMap; 
    }  

    // this method will throw an exception if invalid recordId is passed to it
    public static SCH_Request__c getSchRequest(String recordId) {
        System.debug('#### SchRequestService::getSchRequest');
        SCH_Request__c oSchReq;
        try {
            oSchReq = [SELECT Id, Name, CreatedById, Is_Final_Approval_Completed__c,
                    Status__c, Sub_Status__c,
                    Bloomberg_Legal_Entity__c, Bloomberg_Legal_Entity__r.Name, Bloomberg_Legal_Entity__r.LONG_COMP_NAME__c, 
                    Bloomberg_Ultimate_Parent_Entity__c, Bloomberg_Ultimate_Parent_Entity__r.Name, 
                    Bloomberg_Ultimate_Parent_Entity__r.LONG_COMP_NAME__c, RS_Client_Location__c,
                    RM_Client_Location__c, 
                    RG_Account__c, RG_Account_Name__c, RM_Account__c, RM_Account_Name__c,
                    RS_Account__c, RS_Account_Name__c, 
                    RM_Account_Data_Source__c, RG_Account_Data_Source__c, RS_Account_Data_Source__c, 
                    Legal_Entity_Stage__c, Client_Type__c, Sales_Client_Type__c,
                    Legal_RM_Entity_Full_Name__c, Coverage_RG_Entity_Full_Name__c, Ultimate_Parent_RS_Entity_Full_Name__c
                FROM SCH_Request__c
                WHERE  Id = :recordId];
        } catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new SchRequestServiceException('Error Occured in SchRequestService::getSchRequest() : '+ex.getMessage());
        }
        return oSchReq; 
    }

    public static Map<String, Map<String, Boolean>> isSchRequestEditableByUser(List<String> UserIdList, List<String> SchReqIdList) {
        System.debug('#### SchRequestService::isSchRequestEditableByUser()');
        Map<String, Map<String, Boolean>> SchReqEditableBySchReqIdMapByUserIdMap = new Map<String, Map<String, Boolean>>();
        try {
            // first find all the requests with Status = Draft OR In Review 
            if(UserIdList!=null && !UserIdList.isEmpty() && SchReqIdList!=null && !SchReqIdList.isEmpty()) {
                Map<String, SCH_Request__c> SchRequestMap = new Map<String, SCH_Request__c>(
                    [SELECT Id, Name, CreatedById, 
                        Is_Final_Approval_Completed__c, Status__c, Sub_Status__c, Is_In_Final_Approval__c,
                        Role_Based_Region_Of_Requestor__c
                     FROM SCH_Request__c 
                    WHERE  Id IN :SchReqIdList AND Status__c IN ('Draft', 'In Review')]);

                //Fetch the requests for Pending Approval
                List<ProcessInstanceWorkitem> secondLevelProcInstWorkItemList = 
                        [SELECT Id, ProcessInstanceId, ActorId, OriginalActorId, 
                            ProcessInstance.ProcessDefinitionId, ProcessInstance.ProcessDefinition.DeveloperName, 
                            ProcessInstance.Status, ProcessInstance.TargetObjectId  
                         FROM ProcessInstanceWorkitem 
                         WHERE ProcessInstanceId IN 
                            (SELECT Id FROM ProcessInstance WHERE TargetObjectId IN :SchRequestMap.keySet() AND Status IN ('Pending')) 
                            AND
                            ProcessInstance.ProcessDefinition.DeveloperName='Second_Level_Approval_For_All_Regions'];
                System.debug('secondLevelProcInstWorkItemList');
                Map<String, ProcessInstanceWorkitem> secondLevelProcWIBySchReqIdMap = new Map<String, ProcessInstanceWorkitem>();
                for(ProcessInstanceWorkitem oPWI : secondLevelProcInstWorkItemList) {
                    secondLevelProcWIBySchReqIdMap.put(oPWI.ProcessInstance.TargetObjectId, oPWI);
                    System.debug('ProcessInstance.ProcessDefinition.DeveloperName : '+oPWI.ProcessInstance.ProcessDefinition.DeveloperName);
                }
                
                Set<String> UserIdSet = new Set<String>(UserIdList);
                Set<UserHelper.USER_DETAILS_AND_PERMISSIONS> DetailsAndPermissionSet = new Set<UserHelper.USER_DETAILS_AND_PERMISSIONS> 
                    {UserHelper.USER_DETAILS_AND_PERMISSIONS.IS_SCH_APPROVER_GBL,
                     UserHelper.USER_DETAILS_AND_PERMISSIONS.IS_SCH_APPROVER_REG};
                UserIdSetByDetAndPermEnum = UserHelper.getUserDetailsAndPermissionMap(DetailsAndPermissionSet, UserIdSet); 
        
                // now loop through all the SCH Request Ids and find who can edit it from the UserIdList
                for(String userId : UserIdList) {
                    Map<String, Boolean> SchReqEditableBySchReqIdMap = new Map<String, Boolean>();
                    for(String  schReqId : SchReqIdList) {
                        Boolean isEditable = false;
                        if(SchRequestMap.containsKey(schReqId)) {
                            SCH_Request__c oSchReq = SchRequestMap.get(schReqId);
                            if(oSchReq.Status__c == 'Draft') {
                                isEditable = oSchReq.CreatedById==userId;
                            } 
                            else if(oSchReq.Status__c == 'In Review' && 
                                    secondLevelProcWIBySchReqIdMap.containsKey(schReqId)) 
                            {
                                ProcessInstanceWorkitem oProcWorkItem = secondLevelProcWIBySchReqIdMap.get(schReqId);
                                isEditable = (oProcWorkItem.ActorId == userId) || 
                                            (UserHelper.SCHApprUserIdSetBySCHApprQueueIdMap.containsKey(oProcWorkItem.ActorId) &&
                                             UserHelper.SCHApprUserIdSetBySCHApprQueueIdMap.get(oProcWorkItem.ActorId).contains(userId));
                            }
                        }
                        SchReqEditableBySchReqIdMap.put(schReqId, isEditable);
                    }
                    SchReqEditableBySchReqIdMapByUserIdMap.put(userId, SchReqEditableBySchReqIdMap);
                }
            }
            
        } catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new SchRequestServiceException('Error Occured in SchRequestService::isSchRequestEditableByUser() : '+ex.getMessage());
        }
        return SchReqEditableBySchReqIdMapByUserIdMap;
    }


    public enum SCH_REQUEST_BULK_ACTION {SCH_REQ_APPROVE, SCH_REQ_REJECT, SCH_REQ_ADD_COMMENT, SCH_REQ_CANCEL}

    public class SchRequestAction {
        @InvocableVariable(required=true)
        public String schReqAction; 
        @InvocableVariable(required=true)
        public List<String> SchReqIdList;
        @InvocableVariable(required=true)
        public String comments;
    }

    @InvocableMethod(label='Add Comments, Approve/Reject SCH Request' description='Returns the message with the list of SCH Requests that cannot be completed.')
    public static List<String> processSchReqAction(List<SchRequestAction> SchReqActionList) {
        System.debug('#### SchRequestService::processApprovalRequest()');
        List<String> ProcessOutputMsgList = new List<String>();
        try {
            System.debug('SchReqActionList[0].schReqAction : '+SchReqActionList[0].schReqAction);
            System.debug('SchReqActionList[0].SchReqIdList : '+SchReqActionList[0].SchReqIdList);
            System.debug('SchReqActionList[0].comments : '+SchReqActionList[0].comments);
            
            if(SchReqActionList!=null && !SchReqActionList.isEmpty() && !String.isBlank(SchReqActionList[0].schReqAction) && 
                    !String.isBlank(SchReqActionList[0].comments) &&
                    SchReqActionList[0].SchReqIdList!=null && !SchReqActionList[0].SchReqIdList.isEmpty()) {
                // Return result for each record
                Map<String, String> ErrorBySchReqIdMap = new Map<String, String>();
                String error = processSchReqAction(SchReqActionList[0].schReqAction, SchReqActionList[0].comments, 
                        SchReqActionList[0].SchReqIdList, ErrorBySchReqIdMap);
                if(String.isNotBlank(error)) { 
                    ProcessOutputMsgList.add(error);
                }
                ProcessOutputMsgList.addAll(ErrorBySchReqIdMap.values());
            } else {
                // error
                ProcessOutputMsgList.add('Error: Invalid Request');
            }
        } catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            ProcessOutputMsgList.add(ex.getMessage() + '\n' + ex.getStackTraceString());
            throw new SchRequestServiceException('Error Occured in SchRequestService::processApprovalRequest() : '+ex.getMessage());
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

    public static void updateCommentAndStatus(List<String> SchReqIdList, String comments, Boolean cancelReq) {
        System.debug('#### SchRequestService::updateCommentAndStatus()');
        try {
            if(SchReqIdList!=null && !SchReqIdList.isEmpty() && String.isNotBlank(comments)) {
                List<SCH_Request__c> SchReqList = new List<SCH_Request__c>();
                for(String schReqId : SchReqIdList) {
                    SCH_Request__c oSchReq = new SCH_Request__c(Id=schReqId, Latest_Comment__c=comments);
                    if(cancelReq) {
                        oSchReq.Status__c = 'Completed';
                        oSchReq.Sub_Status__c = 'Cancelled';
                    }
                    SchReqList.add(oSchReq);
                }

                update SchReqList;
            }
        } catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new SchRequestServiceException('Error Occured in SchRequestService::updateCommentAndStatus() : '+ex.getMessage());
        }
    }

    public static String processSchReqAction(String schReqAction, String comments, List<String> SchReqIdList, 
            Map<String, String>ErrorBySchReqIdMap) {
        System.debug('#### SchRequestService::processSchReqAction()');
        System.debug(schReqAction);
        System.debug(comments);
        System.debug(SchReqIdList);
        String error = '';
        List<String> podRecordTypes = new List<String>{'POD_Creation', 'POD_Account_Modification'};
        try {
            Boolean isCancelReq = schReqAction==SCH_REQUEST_BULK_ACTION.SCH_REQ_CANCEL.name();
            if(!String.isBlank(schReqAction) && !String.isBlank(comments) && SchReqIdList!=null && !SchReqIdList.isEmpty()) {
                Savepoint sp = Database.setSavepoint();
                if(schReqAction==SCH_REQUEST_BULK_ACTION.SCH_REQ_APPROVE.name() || 
                        schReqAction==SCH_REQUEST_BULK_ACTION.SCH_REQ_REJECT.name() ||
                        schReqAction==SCH_REQUEST_BULK_ACTION.SCH_REQ_ADD_COMMENT.name() ||
                        schReqAction==SCH_REQUEST_BULK_ACTION.SCH_REQ_CANCEL.name()) {
                    String approvalAction = schReqAction==SCH_REQUEST_BULK_ACTION.SCH_REQ_APPROVE.name() ? 'Approve' : 
                                ((schReqAction==SCH_REQUEST_BULK_ACTION.SCH_REQ_REJECT.name() ||
                                    schReqAction==SCH_REQUEST_BULK_ACTION.SCH_REQ_CANCEL.name()) ? 'Reject' : null);
                    
                    //addCommentToSchRequest(SchReqIdList, comments);
                    
                    if(String.isNotBlank(approvalAction)) {
                        // get SCH Request details
                        Map<String, SCH_Request__c> SchRequestMap = getSchReqDetails(SchReqIdList);

                        // If this is a Cancel Request and so far there are no errors then set the cancel flg on SCH Request to
                        // avoid rejection email being sent to Requestor
                        // Also it is important to reject the SCH request when cancelling state, because if it stays in cancel state and if the request
                        // is assigned to a specific one approver (in case of JPN first approver) then it if required then this approver cannot be removed from
                        // approver list because there are pending request in approval state assigned to the user
                        if(isCancelReq) {
                            for(SCH_Request__c oSchReq : SchRequestMap.values()) {
                                oSchReq.Is_Cancelled__c = true;
                            }
                            //update SchRequestMap.values();
                            List<SCH_Request__c> SCHReqList = SchRequestMap.values();
                            Database.SaveResult[] reqSrList = Database.update(SCHReqList, false);
                            Integer indx = 0;
                            for (Database.SaveResult sr : reqSrList) {
                                if (!sr.isSuccess()) {
                                    ErrorBySchReqIdMap.put(SCHReqList.get(indx).Id, String.format(System.Label.SCH_Req_Cannot_Be_Cancelled_By_User_Error, 
                                                        new List<String>{SchRequestMap.get(SCHReqList.get(indx).Id).Name}));
                                    
                                }
                                ++indx;
                            }
                        }

                        Map<String, ProcessInstanceWorkitem> ProcInstWorkItemList = new Map<String, ProcessInstanceWorkitem>([SELECT Id, ProcessInstanceId, ActorId, OriginalActorId, 
                                ProcessInstance.ProcessDefinitionId, ProcessInstance.ProcessDefinition.DeveloperName , ProcessInstance.Status, ProcessInstance.TargetObjectId  
                            FROM ProcessInstanceWorkitem 
                            WHERE ProcessInstanceId IN (SELECT Id FROM ProcessInstance 
                                    WHERE TargetObjectId IN :SchReqIdList AND Status IN ('Pending'))]);
                            
                        Map<String, ProcessInstanceWorkitem> ProcWIBySchReqIdMap = new Map<String, ProcessInstanceWorkitem>();
                        for(ProcessInstanceWorkitem oPWI : ProcInstWorkItemList.values()) {
                            ProcWIBySchReqIdMap.put(oPWI.ProcessInstance.TargetObjectId, oPWI);
                            System.debug('ProcessInstance.ProcessDefinition.DeveloperName : '+oPWI.ProcessInstance.ProcessDefinition.DeveloperName);
                        }

                        List<Approval.ProcessWorkitemRequest> ProcessWorkitemReqList = new List<Approval.ProcessWorkitemRequest>();
                        for(String schReqId : SchReqIdList) {
                            
                            if(schReqAction!= null && schReqAction == 'SCH_REQ_REJECT' && podRecordTypes.contains(SchRequestMap.get(schReqId).RecordType.DeveloperName))
                                ErrorBySchReqIdMap.put(schReqId, SchRequestMap.get(schReqId).Name + ' ' + System.Label.POD_SCH_Request_Cannot_Be_Referred_Back_By_User_Error + '\n');

                            else if(ProcWIBySchReqIdMap.containsKey(schReqId) && !ErrorBySchReqIdMap.containsKey(schReqId)) {
                                ProcessInstanceWorkitem oProcInstWrkItem = ProcWIBySchReqIdMap.get(schReqId);
                                // its a Approve or Reject or Cancel
                                if(oProcInstWrkItem.ActorId == UserInfo.getUserId() || 
                                        (UserHelper.SCHApprUserIdSetBySCHApprQueueIdMap.containsKey(oProcInstWrkItem.ActorId) &&
                                         UserHelper.SCHApprUserIdSetBySCHApprQueueIdMap.get(oProcInstWrkItem.ActorId).contains(UserInfo.getUserId()))) {
                                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                                    req.setAction(approvalAction);
                                    req.setWorkitemId(oProcInstWrkItem.Id);
                                    req.setComments(comments);
                                    ProcessWorkitemReqList.add(req);
                                } else {
                                    ErrorBySchReqIdMap.put(schReqId, SchRequestMap.get(schReqId).Name+' cannot be processed by you');    
                                }
                            } else if(!isCancelReq) {
                                // error
                                ErrorBySchReqIdMap.put(schReqId, SchRequestMap.get(schReqId).Name+' is not in a Approval - Pending state');
                            } else if(isCancelReq && !podRecordTypes.contains(SchRequestMap.get(schReqId).RecordType.DeveloperName) && (SchRequestMap.get(schReqId).CreatedById != UserInfo.getUserId() || SchRequestMap.get(schReqId).Status__c!='Draft')) {
                                ErrorBySchReqIdMap.put(schReqId, String.format(System.Label.SCH_Req_Cannot_Be_Cancelled_By_User_Error, 
                                                        new List<String>{SchRequestMap.get(schReqId).Name}));
                            }
                        }

                        if(!ProcessWorkitemReqList.isEmpty()) {
                            // try to approve the records to check the errors
                            Approval.ProcessResult[] ApprovalProcessRsltList = Approval.process(ProcessWorkitemReqList, false);
                            Integer i=0;
                            for(Approval.ProcessResult oReqRslt : ApprovalProcessRsltList) {
                                System.debug('App Req Approval Error Err : '+ ' : '+oReqRslt.getEntityId()+' : '+oReqRslt.getErrors()+' : '+oReqRslt.getInstanceId()+' : '+oReqRslt.getInstanceStatus()+' : '+oReqRslt.getNewWorkitemIds());
                                System.debug('id : '+ProcInstWorkItemList.get(ProcessWorkitemReqList.get(i).getWorkitemId()).ProcessInstance.TargetObjectId);
                                String schReqId = ProcInstWorkItemList.get(ProcessWorkitemReqList.get(i).getWorkitemId()).ProcessInstance.TargetObjectId;
                                if(!oReqRslt.isSuccess()) {
                                    String err = '';
                                    for(Database.Error dbErr : oReqRslt.getErrors()) {
                                        System.debug('err  : '+dbErr.getMessage());
                                        err+=dbErr.getMessage()+' , ';
                                    }
                                    err+='\r\n';
                                    ErrorBySchReqIdMap.put(schReqId, 
                                                            SchRequestMap.get(schReqId).Name+' failed to \''+approvalAction+
                                                            '\' with Errors: '+err);
                                } else {
                                    System.debug(SchRequestMap.get(oReqRslt.getEntityId()).Name+' : performed '+
                                                approvalAction+' successfully');
                                }
                                ++i;
                            }
                        }
                    }
                } else {
                    // add error - invalid action
                    error = 'Error: Invalid Action';
                }
                if(String.isNotBlank(error) || !ErrorBySchReqIdMap.isEmpty()) {
                    Database.rollback(sp);
                    System.debug('Roolback');
                } else {
                    updateCommentAndStatus(SchReqIdList, comments, isCancelReq);
                }
            } else {
                // add error
                error = 'Error: Invalid Request';
            }
        } catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            error += ex.getMessage();
            throw new SchRequestServiceException('Error Occured in SchRequestService::processApprovalRequest() : '+ex.getMessage());
        }
        
        return error;
    }

    public static void checkAndCompleteSchReqForRmRdmIds(Map<String, Id> accountIds) {
        System.debug('#### SchRequestService::checkAndCompleteSchReqForRmRdmIds()');
        //Prospect_SCH_Request__c, RM_Account__c, New_RM_Account_RDM_Id__c 
        List<SCH_Request__c> SCHReqList = new List<SCH_Request__c>();
        try {
            if(accountIds!=null && !accountIds.isEmpty()) {
                Map<Id, SCH_Request__c> SCHReqs = new Map<Id, SCH_Request__c>([SELECT Id, New_RM_Account_RDM_Id__c, Status__c, Sub_Status__c 
                    FROM SCH_Request__c
                    WHERE New_RM_Account_RDM_Id__c IN :accountIds.keySet() AND Status__c = 'Processing' AND Sub_Status__c = 'Success']);

                if(SCHReqs != null && !SCHReqs.isEmpty()) {
                    for(SCH_Request__c oSchReq : SCHReqs.values()) {
                        oSchReq.Status__c = 'Completed';
                        oSchReq.Sub_Status__c = 'Setup Completed';
                        SCHReqList.add(oSchReq);
                    }
                    
                    Map<Id, SCH_Request__c> relatedSCHReqs = new Map<Id, SCH_Request__c>([SELECT Id, Prospect_SCH_Request__c, RM_Account__c, Status__c, Sub_Status__c 
                    FROM SCH_Request__c
                    WHERE Prospect_SCH_Request__c IN :SCHReqs.keySet()  AND Status__c = 'In Review' /*AND Sub_Status__c = 'Success'*/]);
                    
                    if(relatedSCHReqs != null && !relatedSCHReqs.isEmpty()) {
                        for(SCH_Request__c rSchReq : relatedSCHReqs.values()) {
                            //rSchReq.RM_Account__c = accountIds.get(((SCH_Request__c)SCHReqs.get(rSchReq.Prospect_SCH_Request__c)).New_RM_Account_RDM_Id__c);
                            if(rSchReq.RM_Account__c == null){
                                rSchReq.RM_Account__c = accountIds.get(((SCH_Request__c)SCHReqs.get(rSchReq.Prospect_SCH_Request__c)).New_RM_Account_RDM_Id__c);
                            }
                            rSchReq.Status__c = 'Approved';
                            rSchReq.Sub_Status__c = 'Success';
                            SCHReqList.add(rSchReq);
                        }
                    }
                }
                
                if(!SCHReqList.isEmpty()){
                    update SCHReqList;
                }
            }
        } catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new SchRequestServiceException('Error Occured in SchRequestService::checkAndCompleteSchReqForRmRdmIds() : '+ex.getMessage());
        }
    }

    public class SchRequestServiceException extends Exception{}
}