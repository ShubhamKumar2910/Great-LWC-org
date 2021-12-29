/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**  Date 		: 04/02/2020
**	Description : This class is trigger handler for SObject - Fenergo_Task__c
**/ 
public without sharing class FenergoTaskTriggerHandler {
    public static void mainEntry(System.TriggerOperation opType, List<Fenergo_Task__c> OldList, List<Fenergo_Task__c> NewList,
        Map<Id, Fenergo_Task__c> OldMap, Map<Id, Fenergo_Task__c> NewMap) {
        System.debug('#### FenergoTaskTriggerHandler::mainEntry');
        switch on opType {
            when BEFORE_INSERT {
                handleBeforeInsert(NewList);
            }
            when BEFORE_UPDATE {
                handleBeforeUpdate(oldMap, newMap, newList);
            }
            when AFTER_INSERT {
                handleAfterInsert(NewList);
            }
            when AFTER_UPDATE {
                handleAfterUpdate(oldMap, newList);
            }
        }
    }

    public static void handleBeforeInsert(List<Fenergo_Task__c> NewList) {
        System.debug('#### FenergoTaskTriggerHandler::handleBeforeInsert()');
        updateFenergoTaskRecord(null, NewList);
        setApprovalStatusToPending(newList);
		updateAssignedToUserLookup(newList, null);
    }

    public static void handleBeforeUpdate(Map<Id, Fenergo_Task__c> OldMap, Map<Id, Fenergo_Task__c> newMap, List<Fenergo_Task__c> NewList) {
        System.debug('#### FenergoTaskTriggerHandler::handleBeforeUpdate()');
        validateFenergoTasks(oldMap, newMap);
        updateFenergoTaskRecord(OldMap, NewList);
        updateTaskWhenChangedFromTerminated(oldMap,newList);
		updateAssignedToUserLookup(newList, oldMap);
    }

    public static void handleAfterInsert(List<Fenergo_Task__c> NewList) {
        System.debug('#### FenergoTaskTriggerHandler::handleBeforeUpdate()');
        shareFenCaseBasedOnFenTask(null, NewList);
    }

    public static void handleAfterUpdate(Map<Id, Fenergo_Task__c> OldMap, List<Fenergo_Task__c> newList) {
        System.debug('#### FenergoTaskTriggerHandler::handleBeforeUpdate()');
        shareFenCaseBasedOnFenTask(OldMap, newList);
    } 
    
    public static void validateFenergoTasks(Map<Id, Fenergo_Task__c> oldMap, Map<Id,Fenergo_Task__c> newMap) {
        for (Fenergo_Task__c fenergoTask : newMap.values()) {
            Fenergo_Task__c oldFenergoTask = oldMap == null ? null : oldMap.get(fenergoTask.Id);
            if (oldFenergoTask != null && oldFenergoTask.Approval_Status__c == 'Pending' && fenergoTask.Approval_Status__c != 'Pending' && String.isBlank(oldFenergoTask.Approval_Review_Outcome__c) 
                && String.isNotBlank(fenergoTask.Approval_Review_Outcome__c) && !oldFenergoTask.Eligible_To_Modify_Task__c) {
                    fenergoTask.addError('This task is not eligible to be updated');
                }
        }
    }
    
    public static void updateTaskWhenChangedFromTerminated(Map<Id, Fenergo_Task__c> oldMap, List<Fenergo_Task__c> newList) {
        for (Fenergo_Task__c fenergoTask : newList) {
            Fenergo_Task__c oldFenergoTask = oldMap.containsKey(fenergoTask.Id) ? oldMap.get(fenergoTask.Id) : null;
            
            if (oldFenergoTask != null && oldFenergoTask.TaskStatus__c == 'Terminated' && fenergoTask.TaskStatus__c == 'In Progress' && 
               (fenergoTask.Required_Approval__c == 'Desk Head Approval' || fenergoTask.Required_Approval__c == 'Sales Approval')) {
                fenergoTask.Approval_Status__c = 'Pending';
               	fenergoTask.Approval_Review_Outcome__c = '';
                fenergoTask.ReviewNotes__c = '';
                fenergoTask.ReviewerId__c = '';
                fenergoTask.ReviewDate__c = null;
            }
        }
    }
    
    public static void setApprovalStatusToPending(List<Fenergo_Task__c> newList) {
        List<Fenergo_Task__c> fenergoTasksToUpdate = new List<Fenergo_Task__c>();
        for (Fenergo_Task__c fenergoTask : newList) {
            if (fenergoTask.Required_Approval__c == 'Desk Head Approval' || fenergoTask.Required_Approval__c == 'Sales Approval') {
                fenergoTask.Approval_Status__c = 'Pending';
            } else {
                fenergoTask.Approval_Status__c = 'Not Required';
            }
        }
    }

    public static void updateFenergoTaskRecord(Map<Id, Fenergo_Task__c> OldMap, List<Fenergo_Task__c> NewList) {
        System.debug('#### FenergoTaskTriggerHandler::updateFenergoTaskRecord()');
        Map<Integer, List<Fenergo_Task__c>> FenTaskListByFenCaseIdMap = new Map<Integer, List<Fenergo_Task__c>>();
        for(Fenergo_Task__c oNewFenTask : NewList) {
            Fenergo_Task__c oOldFenTask = OldMap==null ? null : OldMap.get(oNewFenTask.Id);
            if((oOldFenTask!=null && (oNewFenTask.CaseId__c!=oOldFenTask.CaseId__c || oNewFenTask.CaseStage__c!=oOldFenTask.CaseStage__c) ) ||
                    (oNewFenTask.CaseId__c!=null && oOldFenTask==null) ) { 
                if(oNewFenTask.CaseId__c!=null) {
                    Integer caseId = (Integer)oNewFenTask.CaseId__c;
                    List<Fenergo_Task__c> FenTaskList = FenTaskListByFenCaseIdMap.containsKey(caseId) ? 
                            FenTaskListByFenCaseIdMap.get(caseId) : new List<Fenergo_Task__c>();
                    FenTaskList.add(oNewFenTask);
                    FenTaskListByFenCaseIdMap.put(caseId, FenTaskList);
                } else {
                    // this will generate an error because Fenergo Task is on detail side of Marte-Detail relation with 
                    // Fenergo case and should be related to Fenergo 
                    //oNewFenTask.Fenergo_Case__c = null;
                    //oNewFenTask.Fenergo_Case_Stage__c = null;
                }
            }
        }
        
        if(!FenTaskListByFenCaseIdMap.isEmpty()) {
            // e.g. Map<10, oFenCase>
            Map<Integer, Fenergo_Case__c> FenCaseByFenCaseIdMap = new Map<Integer, Fenergo_Case__c>();
            // e.g. Map<10, Map<'Risk Assessment', oFenStage>>
            Map<Integer, Map<String, Fenergo_Case_Stage__c>> FenStageByFenStageNameMapByFenCaseIdMap = 
                    new Map<Integer, Map<String, Fenergo_Case_Stage__c>>();
            FenergoCaseAndStageAndTaskService.getFenergoTaskAndStagesForFenergoCaseIds(FenTaskListByFenCaseIdMap.keyset(), 
                    FenCaseByFenCaseIdMap, FenStageByFenStageNameMapByFenCaseIdMap);
            for(Integer caseId : FenCaseByFenCaseIdMap.keySet()) {
                Fenergo_Case__c oFenCase = FenCaseByFenCaseIdMap.get(caseId);
                for(Fenergo_Task__c oFenTask : FenTaskListByFenCaseIdMap.get(caseId)) {
                    oFenTask.Fenergo_Case__c = oFenCase.Id;
                    oFenTask.Onboarding_Request__c = oFenCase.Onboarding_Request__c;	
                    oFenTask.RM_Account__c = oFenCase.RM_Account__c;
                    oFenTask.RG_Account__c = oFenCase.RG_Account__c;

                    if(String.isNotBlank(oFenTask.CaseStage__c) && FenStageByFenStageNameMapByFenCaseIdMap.containsKey(caseId) && 
                            FenStageByFenStageNameMapByFenCaseIdMap.get(caseId).containsKey(oFenTask.CaseStage__c)) {
                        oFenTask.Fenergo_Case_Stage__c = FenStageByFenStageNameMapByFenCaseIdMap.get(caseId).get(oFenTask.CaseStage__c).Id;
                    } else {
                        oFenTask.Fenergo_Case_Stage__c = null;
                    }
                }
            }
        }
    }

    public static void shareFenCaseBasedOnFenTask(Map<Id, Fenergo_Task__c> OldMap, List<Fenergo_Task__c> NewList) {
        System.debug('#### FenergoTaskTriggerHandler::shareFenCaseBasedOnFenTask()');
        // e.g. Map<'kundalpr', Map<'Fen_Task_Sales_Appr__c', List<oFenCase1.Id, oFenCase2.Id>>> 
        Map<String, Map<String, Set<String>>> CrtShrFenCaseIdSetByShrTypeMapByUserFedIdMap = new Map<String, Map<String, Set<String>>>(),
                DelShrFenCaseIdSetByShrTypeMapByUserFedIdMap = new Map<String, Map<String, Set<String>>>();
        for(Fenergo_Task__c oNewFenTask : NewList) {
            // template id
            Integer fenTaskTempId = (Integer)oNewFenTask.TaskTemplateId__c; // get fenergoTask TaskTemplateId__c
            if(fenTaskTempId==FenergoCaseAndStageAndTaskService.FEN_TASK_TEMP_ID_THAT_NEEDS_SALES_APPROVAL ||
                    fenTaskTempId==FenergoCaseAndStageAndTaskService.FEN_TASK_TEMP_ID_THAT_NEEDS_DESK_HEAD_APPROVAL) { // Check if the template id of the task = needs approval
                // get previous Fen Task
                Fenergo_Task__c oOldFenTask = OldMap==null ? null : OldMap.get(oNewFenTask.Id);
                String apexSharingReason = fenTaskTempId==FenergoCaseAndStageAndTaskService.FEN_TASK_TEMP_ID_THAT_NEEDS_SALES_APPROVAL ? //Get Apex Sharing Reason
                            FenergoCaseAndStageAndTaskService.FEN_CASE_SHR_REASON_FEN_TASK_SALES_APPR : 
                            FenergoCaseAndStageAndTaskService.FEN_CASE_SHR_REASON_FEN_TASK_DESK_HEAD_APPR;
                if(String.isNotBlank(oNewFenTask.AssignedTo__c)) { // Check if AssignedTo__c is populated
                    if(oOldFenTask==null) {
                        // If this is a new Fenergo Task then add sharing based on Assigned To
                        populateSharingDataStructHelper(oNewFenTask.Fenergo_Case__c, apexSharingReason, oNewFenTask.AssignedTo__c,
                                CrtShrFenCaseIdSetByShrTypeMapByUserFedIdMap);
                    } else if(oOldFenTask.AssignedTo__c != oNewFenTask.AssignedTo__c) {
                        // If this is an existing Fenergo Task then update the sharing 
                        populateSharingDataStructHelper(oNewFenTask.Fenergo_Case__c, apexSharingReason, oNewFenTask.AssignedTo__c,
                                CrtShrFenCaseIdSetByShrTypeMapByUserFedIdMap);
                        populateSharingDataStructHelper(oOldFenTask.Fenergo_Case__c, apexSharingReason, oOldFenTask.AssignedTo__c,
                                DelShrFenCaseIdSetByShrTypeMapByUserFedIdMap);
                    }
                } else if(oOldFenTask != null && String.isNotBlank(oOldFenTask.AssignedTo__c)) {
                    // if this is existing task and Assigned to is blank then delete any sharing based on previous Assigned To
                    populateSharingDataStructHelper(oOldFenTask.Fenergo_Case__c, apexSharingReason, oOldFenTask.AssignedTo__c,
                                DelShrFenCaseIdSetByShrTypeMapByUserFedIdMap);
                }
            }
        }
        if(!DelShrFenCaseIdSetByShrTypeMapByUserFedIdMap.isEmpty() || !CrtShrFenCaseIdSetByShrTypeMapByUserFedIdMap.isEmpty()) {
            FenergoCaseAndStageAndTaskService.manageFenCaseSharingBasedOnFenTask(DelShrFenCaseIdSetByShrTypeMapByUserFedIdMap,
                                                    CrtShrFenCaseIdSetByShrTypeMapByUserFedIdMap);
        }
    }

    private static void populateSharingDataStructHelper(string fenCaseId, String apexSharingReason, String userFedId,
            Map<String, Map<String, Set<String>>> FenCaseIdSetBySharTypeMapByUserFedIdMap) {
        // add the userFedId for a given case with required sharing
        Map<String, Set<String>> FenCaseIdSetBySharTypeMap = FenCaseIdSetBySharTypeMapByUserFedIdMap.containsKey(userFedId) ? 
                FenCaseIdSetBySharTypeMapByUserFedIdMap.get(userFedId) : new Map<String, Set<String>>();
        Set<String> FenCaseIdSet = FenCaseIdSetBySharTypeMap.containsKey(apexSharingReason) ? 
                FenCaseIdSetBySharTypeMap.get(apexSharingReason) : new Set<String>();
        FenCaseIdSet.add(fenCaseId);
        FenCaseIdSetBySharTypeMap.put(apexSharingReason, FenCaseIdSet);
        FenCaseIdSetBySharTypeMapByUserFedIdMap.put(userFedId, FenCaseIdSetBySharTypeMap);
    }
    
    public static void updateAssignedToUserLookup(List<Fenergo_Task__c> newList, Map<Id,Fenergo_Task__c> oldMap) {
        Set<String> assignedToSet = new Set<String>();
        for (Fenergo_Task__c newTask : newList) {
            Fenergo_Task__c oldTask = oldMap != null ? oldMap.get(newTask.Id) : null;
            if (String.isNotBlank(newTask.AssignedTo__c) && ((oldTask != null && newTask.AssignedTo__c != oldTask.AssignedTo__c) || oldTask == null)) {
                assignedToSet.add(newTask.AssignedTo__c);
            } else if (String.isBlank(newTask.AssignedTo__c) && newTask.Assigned_To_User__c != null) {
                newTask.Assigned_To_User__c = null;
            }
        }
		
        if (!assignedToSet.isEmpty()) {
            Map<String, Id> federationIdToUserId = new Map<String, Id>();
            for (User user : [SELECT Id, FederationIdentifier FROM User WHERE FederationIdentifier IN :assignedToSet AND IsActive = True]) {
                federationIdToUserId.put(user.FederationIdentifier.toLowerCase(), user.Id);
            }
            
            for (Fenergo_Task__c newTask : newList) {
                String assignedToLowerCase = String.isNotBlank(newTask.AssignedTo__c) ? newTask.AssignedTo__c.toLowerCase() : null;
                if(String.isNotBlank(assignedToLowerCase) && federationIdToUserId.containsKey(assignedToLowerCase)) {
                    newTask.Assigned_To_User__c = federationIdToUserId.get(assignedToLowerCase);
                } else {
                    newTask.Assigned_To_User__c = null;
                }
            }
        }
    }
}