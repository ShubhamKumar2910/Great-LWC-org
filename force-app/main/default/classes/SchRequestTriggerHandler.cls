/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**  Date 		: 02/09/2018
**	Description : This class is trigger handler for SObject - SCH_Request__c
**/ 
public class SchRequestTriggerHandler {
    private static Set<String> SchReqAlreadySubmittedForApproval = new Set<String>(); 
    public static void mainEntry(System.TriggerOperation opType, List<SCH_Request__c> OldList, List<SCH_Request__c> NewList,
            Map<Id, SCH_Request__c> OldMap, Map<Id, SCH_Request__c> NewMap) {
        System.debug('#### SchRequestTriggerHandler::mainEntry');
        switch on opType {
            when BEFORE_INSERT {
                handleBeforeInsert(NewList);
            }
            when BEFORE_UPDATE {
                handleBeforeUpdate(OldMap, NewList);
            }
            when AFTER_INSERT {
                handleAfterInsert(NewList);
            }
            when AFTER_UPDATE {
                handleAfterUpdate(OldMap, NewList);
            }
        }
    }

    public static void handleBeforeInsert(List<SCH_Request__c> NewList) {
        System.debug('#### SchRequestTriggerHandler::handleBeforeInsert');
        checkRequestedAccountAlreadyPresent(NewList);
        autoApprovePODRequestForAdminsAndBM(NewList);
    }

    public static void handleAfterInsert(List<SCH_Request__c> NewList) {
        System.debug('#### SchRequestTriggerHandler::handleAfterInsert');
        checkReqIsCompletedBeforeApproval(null, NewList);
        checkAndSubmitForApproval(null, NewList);
    }

    public static void handleBeforeUpdate(Map<Id, SCH_Request__c> OldMap, List<SCH_Request__c> NewList) {
        System.debug('#### SchRequestTriggerHandler::handleBeforeUpdate');
        checkAndUpdateLongTextFeilds(OldMap, NewList);
        checkIsRequestUpdatedByFirstApprover(OldMap, NewList);
        checkAndMaintainStateOfReq(OldMap, NewList);
        checkRequestedAccountAlreadyPresent(NewList);
        checkAndFormatPODNameBeforeUpdate(OldMap, NewList);
    }

    public static void autoApprovePODRequestForAdminsAndBM(List<SCH_Request__c> NewList) {
        Boolean isAdministratorUser = CommonTools.isAdminAndIntegrationUser();
        Boolean isBusinessManagementUser = CommonTools.isBusinessManagementUser();
        Id recordTypeIdForPODCreate = CommonTools.getRecordTypeIdUsingDeveloperName('SCH_Request__c', 'POD_Creation');
        Id recordTypeIdForPODModify = CommonTools.getRecordTypeIdUsingDeveloperName('SCH_Request__c', 'POD_Account_Modification');
        
        for(SCH_Request__c schRequestObj : NewList){
            if((isAdministratorUser || isBusinessManagementUser) && (schRequestObj.RecordTypeId == recordTypeIdForPODCreate || schRequestObj.RecordTypeId == recordTypeIdForPODModify))
            {
                System.debug('***Updating Status to Approved and Sub Status to Success***');
                schRequestObj.Status__c = 'Approved';
                schRequestObj.Sub_Status__c = 'Success';
            }
        }
    }
    
    public static void checkAndFormatPODNameBeforeUpdate(Map<Id, SCH_Request__c> OldMap, List<SCH_Request__c> NewList)
    {
        System.debug('#### SchRequestTriggerHandler::checkAndFormatPODNameBeforeUpdate');

        Id recordTypeIdForPODCreate = CommonTools.getRecordTypeIdUsingDeveloperName('SCH_Request__c', 'POD_Creation');
        Id recordTypeIdForPODModify = CommonTools.getRecordTypeIdUsingDeveloperName('SCH_Request__c', 'POD_Account_Modification');
        
        String japanDomicileCode = 'JP';
        for(SCH_Request__c oNewSchReq : NewList) {
            SCH_Request__c oOldSchReq = OldMap.get(oNewSchReq.Id);
            
            if(oNewSchReq.RecordTypeId == recordTypeIdForPODCreate && String.isNotBlank(oNewSchReq.RM_Account_Name__c) && (oNewSchReq.RM_Account_Name__c != oOldSchReq.RM_Account_Name__c)) {
            
               if( (japanDomicileCode.equalsIgnoreCase(oOldSchReq.RM_Client_Location__c) && !oNewSchReq.RM_Account_Name__c.contains(oNewSchReq.POD_Account_Name__c)) ||
                    (!japanDomicileCode.equalsIgnoreCase(oOldSchReq.RM_Client_Location__c) && !oNewSchReq.RM_Account_Name__c.contains(oNewSchReq.Coverage_RG_Entity_Full_Name__c)) ) {

                    if(japanDomicileCode.equalsIgnoreCase(oOldSchReq.RM_Client_Location__c))
                        oNewSchReq.RM_Account_Name__c = oNewSchReq.POD_Account_Name__c + ' - ' + oNewSchReq.RM_Account_Name__c;
                    else
                        oNewSchReq.RM_Account_Name__c = oNewSchReq.Coverage_RG_Entity_Full_Name__c + ' - ' + oNewSchReq.RM_Account_Name__c;

                }
                else {
                    oNewSchReq.addError(String.format(System.Label.Please_Note, 
                                                           new List<String>{oNewSchReq.Name}));
                }

            }

            if(oNewSchReq.RecordTypeId == recordTypeIdForPODModify && String.isNotBlank(oNewSchReq.Legal_RM_Entity_Full_Name__c) && (oNewSchReq.Legal_RM_Entity_Full_Name__c != oOldSchReq.Legal_RM_Entity_Full_Name__c)) {
               
               if( (japanDomicileCode.equalsIgnoreCase(oOldSchReq.RM_Client_Location__c) && !oNewSchReq.Legal_RM_Entity_Full_Name__c.contains(oNewSchReq.POD_Account_Name__c)) ||
                    (!japanDomicileCode.equalsIgnoreCase(oOldSchReq.RM_Client_Location__c) && !oNewSchReq.Legal_RM_Entity_Full_Name__c.contains(oNewSchReq.Coverage_RG_Entity_Full_Name__c)) ) {

                    if(japanDomicileCode.equalsIgnoreCase(oOldSchReq.RM_Client_Location__c))
                        oNewSchReq.New_Legal_Entity_Name__c = oNewSchReq.POD_Account_Name__c + ' - ' + oNewSchReq.Legal_RM_Entity_Full_Name__c;

                    else
                        oNewSchReq.New_Legal_Entity_Name__c = oNewSchReq.Coverage_RG_Entity_Full_Name__c + ' - ' + oNewSchReq.Legal_RM_Entity_Full_Name__c;

                }
                else {
                    oNewSchReq.addError(String.format(System.Label.Please_Note, 
                                                           new List<String>{oNewSchReq.Name}));
                }

            }

        }

    }

    public static void handleAfterUpdate(Map<Id, SCH_Request__c> OldMap, List<SCH_Request__c> NewList) {
        System.debug('#### SchRequestTriggerHandler::handleAfterUpdate');
        checkReqIsCompletedBeforeApproval(OldMap, NewList);
        checkAndSubmitForApproval(OldMap, NewList);
    }

    public static void checkAndUpdateLongTextFeilds(Map<Id, SCH_Request__c> OldMap, List<SCH_Request__c> NewList) {
        System.debug('#### SchRequestTriggerHandler::checkAndUpdateLongTextFeilds');
        Integer sysLogFldLength = SCH_Request__c.System_Log__c.getDescribe().getLength();
        Integer commentsFldLength = SCH_Request__c.Comments__c.getDescribe().getLength();
        for(SCH_Request__c oNewSchReq : NewList) {
            SCH_Request__c oOldSchReq = OldMap.get(oNewSchReq.Id);
            if(String.isNotBlank(oNewSchReq.System_log__c) && (oNewSchReq.System_log__c != oOldSchReq.System_log__c)) {
                oNewSchReq.System_log__c = Datetime.now()+' : '+UserInfo.getFirstName()+' '+UserInfo.getLastName()+
                                           ' : '+oNewSchReq.System_log__c+'\r\n'+
                                           (String.isNotBlank(oOldSchReq.System_log__c) ? oOldSchReq.System_log__c : '');
                if(oNewSchReq.System_log__c.length() > sysLogFldLength) {
                    oNewSchReq.System_log__c = oNewSchReq.System_log__c.substring(0, sysLogFldLength-1);
                }
            }
            if(String.isNotBlank(oNewSchReq.Latest_Comment__c) && (oNewSchReq.Latest_Comment__c != oOldSchReq.Latest_Comment__c)) {
                oNewSchReq.Latest_Comment__c = oNewSchReq.Latest_Comment__c.replace('\n', '<br/>');
                oNewSchReq.Latest_Comment__c = '<b>'+Datetime.now()+' : '+UserInfo.getFirstName()+' '+UserInfo.getLastName()+' : </b>'+
                                                oNewSchReq.Latest_Comment__c;
                oNewSchReq.Comments__c = oNewSchReq.Latest_Comment__c+'<br/>'+
                                         (String.isNotBlank(oOldSchReq.Comments__c) ? oOldSchReq.Comments__c : '');
                System.debug('oNewSchReq.Comments__c.length() : '+oNewSchReq.Comments__c.length());
                if(oNewSchReq.Comments__c.length() > commentsFldLength) {
                    oNewSchReq.Comments__c = oNewSchReq.Comments__c.substring(0, commentsFldLength-1);
                    System.debug('After truncating oNewSchReq.Comments__c.length() : '+oNewSchReq.Comments__c.length());
                }
            }
        }

    }

    public static void checkIsRequestUpdatedByFirstApprover(Map<Id, SCH_Request__c> OldMap, List<SCH_Request__c> NewList) {
        System.debug('#### SchRequestTriggerHandler::checkIsRequestUpdatedByFirstApprover');
        // ToDo - check whether we need following condition to check whether the current user is Sch Approver or not
        //        in order to set the flag Is_Request_Modified_By_First_Approver__c to true only if the current 
        //        current user is SCH Approver.
        if(UserHelper.isCurrentSchApprover) {
            Map<String, Schema.SObjectField> fieldMap = Schema.sObjectType.SCH_Request__c.fields.getMap();
            for(SCH_Request__c oNewSchReq : NewList) {
                if(oNewSchReq.Status__c == 'In Review') {
                    for(String fldName : fieldMap.keySet()) {
                        if(fldName!='Status__c' && fldName!='Sub_Status__c' && fldName!='Is_First_Approval_Completed__c' && 
                                fldName!='Is_Final_Approval_Completed__c' && fldName!='Is_Request_Modified_By_First_Approver__c' &&
                                fldName!='Is_In_First_Approval__c' && fldName!='Is_In_Final_Approval__c' && fldName!='System_Log__c' &&
                                fldName!='Latest_Comment__c' && fldName!='Comments__c' && fldName!='Is_Cancelled__c' && 
                                fldName!= 'First_Approval_Done_By_User__c' && fldName!='Final_Approval_Done_By_User__c') 
                        {
                            Schema.DescribeFieldResult fldDsr = fieldMap.get(fldName).getDescribe();
                            if(!fldDsr.isCalculated() && !fldDsr.isAutoNumber() && fldDsr.isCustom() &&
                                    oNewSchReq.get(fldName) != OldMap.get(oNewSchReq.Id).get(fldName)) {
                                oNewSchReq.Is_Request_Modified_By_First_Approver__c = true;
                                System.debug(oNewSchReq.Name+' : '+fldName+' marked as modified by Approver');
                                break;
                            }
                        }
                    }
                }
            }
        }

    }

    // This Validation is checked in Triggers because VRs don't execute second time when field is updated in 
    // WF Rules.  
    // 10. Executes workflow rules.
    // 11. If there are workflow field updates, updates the record again.
    // 12. If the record was updated with workflow field updates, fires before update triggers and after update triggers one more 
    //     time (and only one more time), in addition to standard validations. Custom validation rules, duplicate rules, and 
    //     escalation rules are not run again.   
    // Also this methid must be caled from the after triggers as it relies on the formula fileds.
    public static void checkReqIsCompletedBeforeApproval(Map<Id, SCH_Request__c> OldMap, List<SCH_Request__c> NewList) {
        System.debug('#### SchRequestTriggerHandler::checkReqIsCompletedBeforeApproval');
        List<External_Code_Mapping__c> createExternalCdeMappingList = new List<External_Code_Mapping__c>(); 
        List<String> exterlCodesForDelete = new List<String>();
        
        Id rmExtCodeRecordTypeId = CommonTools.getRecordTypeIdUsingDeveloperName('SCH_Request__c', 'RM_Account_External_Code_Mapping');
        Id rmCreateProspectRecordTypeId = CommonTools.getRecordTypeIdUsingDeveloperName('SCH_Request__c', 'Create_RM_Prospect');

        for(SCH_Request__c oNewSchReq : NewList) {
            SCH_Request__c oOldSchReq = OldMap == null ? null : OldMap.get(oNewSchReq.Id);
            System.debug('oNewSchReq.Is_Final_Approval_Completed__c : '+oNewSchReq.Is_Final_Approval_Completed__c);
            System.debug('oNewSchReq.Legal_RM_Entity_Full_Name__c : '+oNewSchReq.Legal_RM_Entity_Full_Name__c);
            System.debug('oNewSchReq.Coverage_RG_Entity_Full_Name__c : '+oNewSchReq.Coverage_RG_Entity_Full_Name__c);
            System.debug('oNewSchReq.Ultimate_Parent_RS_Entity_Full_Name__c : '+oNewSchReq.Ultimate_Parent_RS_Entity_Full_Name__c);
            System.debug('oNewSchReq.RM_Client_Location__c : '+oNewSchReq.RM_Client_Location__c);
            System.debug('oNewSchReq.Sales_Client_Type__c : '+oNewSchReq.Sales_Client_Type__c);
            System.debug('oNewSchReq.Legal_Entity_Stage__c : '+oNewSchReq.Legal_Entity_Stage__c);
            System.debug('oNewSchReq.External_Mapping_Id__c : '+oNewSchReq.External_Mapping_Id__c);
            System.debug('oNewSchReq.RecordTypeId : '+oNewSchReq.RecordTypeId);
            System.debug('rmExtCodeRecordTypeId : '+rmExtCodeRecordTypeId);
            System.debug('rmCreateProspectRecordTypeId : '+rmCreateProspectRecordTypeId);
            if(oOldSchReq != null)
                System.debug('oOldSchReq.Status__c : '+oOldSchReq.Status__c);
            System.debug('oNewSchReq.Action__c : '+oNewSchReq.Action__c);
            System.debug('oNewSchReq.Status__c : '+oNewSchReq.Status__c);

            if(   (oNewSchReq.RecordTypeId == rmCreateProspectRecordTypeId && oNewSchReq.Status__c=='Approved' && (oOldSchReq==null || !oOldSchReq.Is_Final_Approval_Completed__c) ) &&
                  (String.isBlank(oNewSchReq.Legal_RM_Entity_Full_Name__c) || 
                   String.isBlank(oNewSchReq.Coverage_RG_Entity_Full_Name__c) || 
                   String.isBlank(oNewSchReq.Ultimate_Parent_RS_Entity_Full_Name__c) || 
                   String.isBlank(oNewSchReq.RM_Client_Location__c) || 
                   String.isBlank(oNewSchReq.Sales_Client_Type__c) || 
                   String.isBlank(oNewSchReq.Legal_Entity_Stage__c) || 
                   (oNewSchReq.RS_Account_Data_Source__c!='RDM' && String.isBlank(oNewSchReq.RS_Client_Location__c)) )) {
                // This indicates the Approver is approving the incomplete request
                oNewSchReq.addError(
                        String.format(System.Label.SCH_Req_Incomplete_Req_Cannot_Be_Completed_Error, 
                                    new List<String>{oNewSchReq.Name})
                );
                System.debug('SCH Request: '+oNewSchReq.Name+' is incomplete');
            } 
            else if (Trigger.isAfter && Trigger.isUpdate && oNewSchReq.RecordTypeId == rmExtCodeRecordTypeId && oOldSchReq != null && oOldSchReq.Status__c=='In Review' && oNewSchReq.Status__c=='Approved'){
                
                System.debug('Inside After Update');
                //External_Mapping_Id__c, External_Mapping_Type__c, RM_Account__c, Source__c, Name__c, External_Id__c, Nomura_Booking_Entity__c FROM External_Code_Mapping__c
                if(oNewSchReq.Action__c == 'Create'){
                    External_Code_Mapping__c externalCodeMapping = new External_Code_Mapping__c();
                    externalCodeMapping.RM_Account__c = oNewSchReq.RM_Account__c;
                    externalCodeMapping.External_Mapping_Id__c = oNewSchReq.External_Mapping_Id__c;
                    externalCodeMapping.External_Mapping_Type__c = oNewSchReq.External_Mapping_Type__c;
                    externalCodeMapping.Source__c = 'RDM';
                    externalCodeMapping.External_Id__c = oNewSchReq.External_Mapping_Type__c + '#' + oNewSchReq.External_Mapping_Id__c; 
                    //externalCodeMapping.Nomura_Booking_Entity__c = ;
                    createExternalCdeMappingList.add(externalCodeMapping);
                    exterlCodesForDelete.add(oNewSchReq.External_Mapping_Type__c + '#' + oNewSchReq.External_Mapping_Id__c);                    
                }
            } 
        }
        
        if(exterlCodesForDelete != null && !exterlCodesForDelete.isEmpty()){
            List<External_Code_Mapping__c> deleteExternalCdeMappingList = [SELECT ID, External_Id__c FROM External_Code_Mapping__c WHERE External_Id__c IN :exterlCodesForDelete];
            if(deleteExternalCdeMappingList != null && !deleteExternalCdeMappingList.isEmpty()){
                delete deleteExternalCdeMappingList;
            }
        }
        if(createExternalCdeMappingList != null && !createExternalCdeMappingList.isEmpty()){
            insert createExternalCdeMappingList;
        }
        
    }

    

    public static void checkAndMaintainStateOfReq(Map<Id, SCH_Request__c> OldMap, List<SCH_Request__c> NewList) {
        System.debug('#### SchRequestTriggerHandler::checkAndMaintainStateOfReq');
        Id recordTypeIdForPODCreate = CommonTools.getRecordTypeIdUsingDeveloperName('SCH_Request__c', 'POD_Creation');
        Id recordTypeIdForPODModify = CommonTools.getRecordTypeIdUsingDeveloperName('SCH_Request__c', 'POD_Account_Modification');

        for(SCH_Request__c oNewSchReq : NewList) {
            SCH_Request__c oOldSchReq = OldMap.get(oNewSchReq.Id);
            System.debug('oNewSchReq.Status__c : '+oNewSchReq.Status__c);
            System.debug('oOldSchReq.Status__c : '+oOldSchReq.Status__c);
            System.debug('oNewSchReq.Sub_Status__c : '+oNewSchReq.Sub_Status__c);
            System.debug('oOldSchReq.Sub_Status__c : '+oOldSchReq.Sub_Status__c);
            System.debug('UserHelper.isCurrentSchApprover : '+ UserHelper.isCurrentSchApprover);
            System.debug('oNewSchReq.Status__c==In Review : '+ (oNewSchReq.Status__c=='In Review'));
            System.debug('oOldSchReq.Sub_Status__c==Final Review : '+(oOldSchReq.Sub_Status__c=='Final Review'));
            System.debug('oNewSchReq.Sub_Status__c==Referred Back : '+(oNewSchReq.Sub_Status__c=='Referred Back'));
            
            if(oNewSchReq.Is_Final_Approval_Completed__c && oNewSchReq.Status__c=='Approved' &&
                    (oOldSchReq==null || (!oOldSchReq.Is_Final_Approval_Completed__c && oOldSchReq.Status__c!='Approved'))) {
                // When Request is give final approval
                oNewSchReq.Final_Approval_Done_By_User__c = UserInfo.getUserId();
                if(oNewSchReq.Final_Approval_Done_By_User__c==oNewSchReq.CreatedById) {
                    oNewSchReq.addError( String.format(System.Label.SCH_Req_Cannot_Be_Approved_By_Requestor_Error, 
                                                       new List<String>{oNewSchReq.Name}));
                }
            } else if(UserHelper.isCurrentSchApprover && 
                    oNewSchReq.Status__c=='In Review' &&
                    oOldSchReq.Sub_Status__c=='Final Review' && oNewSchReq.Sub_Status__c=='Referred Back') {
                // when the request is rejected by the team in Final Approval
                System.debug('when the request is rejected by the team in Final Approval');
                if(oNewSchReq.CreatedById==UserInfo.getUserId()) {
                    oNewSchReq.addError( String.format(System.Label.SCH_Req_Cannot_Be_Rejected_By_Requestor_Error, 
                                                       new List<String>{oNewSchReq.Name}));
                }
                oNewSchReq.Status__c = 'Draft';
                oNewSchReq.Final_Approval_Done_By_User__c = null;
                oNewSchReq.Is_Request_Modified_By_First_Approver__c = false;
            } else if(oNewSchReq.Is_Cancelled__c && 
                    (oOldSchReq==null || (!oOldSchReq.Is_Cancelled__c)) &&
                    (oNewSchReq.CreatedById==UserInfo.getUserId() && oNewSchReq.Status__c!='Draft') && (oNewSchReq.RecordTypeId != recordTypeIdForPODCreate && oNewSchReq.RecordTypeId != recordTypeIdForPODModify)) { 
                // SCH request cannot be cancelled by a requestor who is also an approver if it is not in Draft state
                oNewSchReq.addError(String.format(System.Label.SCH_Req_Cannot_Be_Cancelled_By_User_Error, 
                                                           new List<String>{oNewSchReq.Name}));
            } else if(oNewSchReq.Sub_Status__c=='Referred Back' && oOldSchReq.Sub_Status__c!='Referred Back' && 
                      (!UserHelper.isCurrentSchApprover) ) {
                System.debug('Request rejected by Admin');
                oNewSchReq.Status__c = 'Draft';
                oNewSchReq.Final_Approval_Done_By_User__c = null;
                oNewSchReq.Is_Request_Modified_By_First_Approver__c = false;
            }
        }
    }

    public static void checkAndSubmitForApproval(Map<Id, SCH_Request__c> OldMap, List<SCH_Request__c> NewList) {
        System.debug('#### SchRequestTriggerHandler::checkAndSubmitForApproval');
        List<String> SchReqToSubmitForApprList = new List<String>(); 

        Map<UserHelper.USER_DETAILS_AND_PERMISSIONS, Set<String>> UserPermissionMap = SchRequestService.getSchReqUserDetailsAndPermissions(NewList);
        UserHelper.USER_DETAILS_AND_PERMISSIONS schApprRegionalEnum = UserHelper.USER_DETAILS_AND_PERMISSIONS.IS_SCH_APPROVER_REG;
        UserHelper.USER_DETAILS_AND_PERMISSIONS schApprGlobalEnum = UserHelper.USER_DETAILS_AND_PERMISSIONS.IS_SCH_APPROVER_GBL;
        
        for(SCH_Request__c oNewSchReq : NewList) {
            if(!SchReqAlreadySubmittedForApproval.contains(oNewSchReq.Id)) {
                SCH_Request__c oOldSchReq = OldMap != null ? OldMap.get(oNewSchReq.Id) : null;
                Boolean hasStatusChngdToInReview = oNewSchReq.Status__c=='In Review' && (oOldSchReq==null || oOldSchReq.Status__c!='In Review');
                System.debug('hasStatusChngdToInReview : '+hasStatusChngdToInReview);
														
                if(hasStatusChngdToInReview) {
                    SchReqToSubmitForApprList.add(oNewSchReq.Id);
                }
            }
        } // end of - for(SCH_Request__c oNewSchReq : NewList) 

        if(!SchReqToSubmitForApprList.isEmpty()) {
            SchReqAlreadySubmittedForApproval.addAll(SchReqToSubmitForApprList);
            SchRequestService.submitSchReqForApproval(SchReqToSubmitForApprList);
        }
    }

     public static void checkRequestedAccountAlreadyPresent(List<SCH_Request__c> newList) {
          System.debug('#### SchRequestTriggerHandler::checkRequestedAccountAlreadyPresent');

          Boolean duplicateAccountExists = false;
          Set<String> accountNameList = new Set<String>();
          
          Set<Id> accountRMFromExternalSourceSet = new Set<Id>();
          Set<Id> accountRSFromExternalSourceSet = new Set<Id>();

          List<SCH_Request__c> schRequestList = new List<SCH_Request__c>();

          /*
           * If account is entered manually or chosen from Bloomberg then we have to check whether account name already exists in Salesforce
           */

          //TODO : RecordType will get added
        for(SCH_Request__c schRequestObj : newList){
            if(schRequestObj.Is_Cancelled__c == false && 
                ((schRequestObj.Status__c == 'Draft' && schRequestObj.Sub_Status__c <> 'Referred Back') 
                || 
                schRequestObj.Status__c == 'In Review' 
                || 
                schRequestObj.Status__c == 'Approved'
                )
                ){
                    schRequestList.add(schRequestObj);
            }
        }

        if(schRequestList != null && !schRequestList.isEmpty()) {
            for(SCH_Request__c schRequestObj : schRequestList){

                //For RM Accounts
                if(schRequestObj.Bloomberg_Legal_Entity__c != null){
                    accountRMFromExternalSourceSet.add(schRequestObj.Bloomberg_Legal_Entity__c);
                }
                else if(schRequestObj.RM_Account_Name__c != null && String.isNotEmpty(schRequestObj.RM_Account_Name__c)){
                    accountNameList.add(schRequestObj.RM_Account_Name__c);
                }

                //For RG Accounts
                if(schRequestObj.RG_Account_Name__c != null && String.isNotEmpty(schRequestObj.RG_Account_Name__c)){
                    accountNameList.add(schRequestObj.RG_Account_Name__c);
                }

                //For RS Accounts
                /* We cannot use Ultimate_Parent_RS_Entity_Full_Name__c if RS is existing then it will have data */
                if(schRequestObj.Bloomberg_Ultimate_Parent_Entity__c != null){
                    accountRSFromExternalSourceSet.add(schRequestObj.Bloomberg_Ultimate_Parent_Entity__c); 
                }
                else if(schRequestObj.RS_Account_Name__c != null && String.isNotEmpty(schRequestObj.RS_Account_Name__c)){
                    accountNameList.add(schRequestObj.RS_Account_Name__c);
                }
            }

            //Fetch RS Details from External Source
            if(accountRSFromExternalSourceSet != null && !accountRSFromExternalSourceSet.isEmpty()){
                List<Bloomberg_Entity_Data__c> accountRSListFromExternalSource = 
                    [SELECT Id, LONG_COMP_NAME__c FROM Bloomberg_Entity_Data__c WHERE Id IN :accountRSFromExternalSourceSet];

                if(accountRSListFromExternalSource != null && !accountRSListFromExternalSource.isEmpty()){
                    for(Bloomberg_Entity_Data__c entityRSObj :  accountRSListFromExternalSource){
                        accountNameList.add(entityRSObj.LONG_COMP_NAME__c + SchRequestController.RS_ENTITY_SUFFIX);
                    }
                }
            }

            //Fetch RM Details from External Source
            if(accountRMFromExternalSourceSet != null && !accountRMFromExternalSourceSet.isEmpty()){
                List<Bloomberg_Entity_Data__c> accountRMListFromExternalSource = 
                    [SELECT Id, LONG_COMP_NAME__c FROM Bloomberg_Entity_Data__c WHERE Id IN :accountRMFromExternalSourceSet];

                if(accountRMListFromExternalSource != null && !accountRMListFromExternalSource.isEmpty()){
                    for(Bloomberg_Entity_Data__c entityRMObj :  accountRMListFromExternalSource){
                        accountNameList.add(entityRMObj.LONG_COMP_NAME__c);
                    }
                }
            }

            //Check Duplicate Exists based on Account Name
            if(accountNameList != null && !accountNameList.isEmpty()){
                List<Account> accountList = [SELECT Id, Name, RecordType.DeveloperName FROM Account
                                            WHERE Name IN :accountNameList
                                            ];

                if(accountList != null && !accountList.isEmpty()){
                    for(Account accountObj : accountList){
                        if('RS_Account'.equalsIgnoreCase(accountObj.RecordType.DeveloperName)){
                            System.debug('****RS Duplicate Found:'+accountObj.Name);
                            String accountRSErrorMessage  = String.format(System.Label.Account_Already_Exists, new String[]{'RS', accountObj.Name});
                            newList[0].addError(accountRSErrorMessage);
                        }
                        else if('RG_Account'.equalsIgnoreCase(accountObj.RecordType.DeveloperName)){
                            System.debug('****RG Duplicate Found:'+accountObj.Name);
                            String accountRGErrorMessage  = String.format(System.Label.Account_Already_Exists, new String[]{'RG', accountObj.Name});
                            newList[0].addError(accountRGErrorMessage);
                        }
                        else if('RM_Account'.equalsIgnoreCase(accountObj.RecordType.DeveloperName)){
                            System.debug('****RM Duplicate Found:'+accountObj.Name);
                            String accountRMErrorMessage  = String.format(System.Label.Account_Already_Exists, new String[]{'RM', accountObj.Name});
                            newList[0].addError(accountRMErrorMessage);
                        }
                    }
                }
            }
        }
     }

}