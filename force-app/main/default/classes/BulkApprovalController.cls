public without sharing class BulkApprovalController {
    public static Map<ID,ID> mapWkItmReqID = new Map<ID,ID>();
    public static Map<ID,String> mapUserName = new Map<ID,String>();
    public static Map<ID,String> mapActorId = new Map<ID,String>();
    public static List<ID> userSet = new List<ID>();
    public static List<ID> createdUserSet = new List<ID>();
    public static List<ID> OriginalActorUserSet = new List<ID>();
    public static List<ApprovalQueueItem> approvalItems = new List<ApprovalQueueItem>();
    public static string businessProfile = 'Business';
    public static string salesProfile = 'Sales';
    public static Map<String,String> mapWkItmUserId = new Map<String,String>();
    
    
    public BulkApprovalController(){
        
    }
    
    
    public class ApprovalQueueItem
    {
        @AuraEnabled public ID processInstanceWorkItemID {get;set;}
        @AuraEnabled public String ApprovalRequest {get; set;}
        @AuraEnabled public String CreatedDate {get;set;}
        @AuraEnabled public String RequestedFor {get;set;}
        @AuraEnabled public String RequestedBy {get;set;}
        @AuraEnabled public String AccountName {get;set;}
        @AuraEnabled public String Product {get;set;}
        @AuraEnabled public String ProductRegion {get;set;}
        @AuraEnabled public String RequestType {get;set;}
        @AuraEnabled public String Role {get;set;}
        @AuraEnabled public String Approvers {get;set;}
        @AuraEnabled public String FromDate {get;set;}
        @AuraEnabled public String Type {get;set;}
        //added for JIRA SALES 1588       
        @AuraEnabled public String Stage {get;set;}
        //added for JIRA SALES 3525       
        @AuraEnabled public Decimal Amount {get;set;}
        @AuraEnabled public String ParentAccountName {get;set;}
        @AuraEnabled public String RelatedRMAccountName {get;set;}
        @AuraEnabled public String FunctionalLevel {get;set;}
        @AuraEnabled public String ErrorMessage {get;set;}
        
    }

    public with sharing class WithSharingMethods {
		public WithSharingMethods(){}
        public Map<String, Integer> getApprovalCount(){
			Map<String, Integer> reqCountMap = new Map<String,Integer>();
			
			Integer integerResult = 0;
			System.debug('---isCurrentSchApprover--' + UserHelper.isCurrentSchApprover);
			Boolean isCurrentSchApprover = UserHelper.isCurrentSchApprover;
			if(isCurrentSchApprover){
				List<AggregateResult> schCount = [SELECT COUNT(ID) IDCount FROM SCH_Request__c where Show_To_All_Approvers__c = true];
				//integerResult += Integer.valueOf(schCount[0].get('IDCount'));
				reqCountMap.put('SCH', Integer.valueOf(schCount[0].get('IDCount')));
				
			}
			else
				reqCountMap.put('SCH', 0);

			System.debug('---isCurrentPreOnboardingApprover--' + UserHelper.isCurrentPreOnboardingApprover);
			Boolean isCurrentPreOnboardingApprover = UserHelper.isCurrentPreOnboardingApprover;
			if(isCurrentPreOnboardingApprover){
				List<AggregateResult> onbCount = [SELECT COUNT(ID) IDCount FROM Onboarding_Request__c where Show_To_All_Approvers__c = true 
										AND Desk_Head_Approver__c != :UserInfo.getUserId()];
				//integerResult += Integer.valueOf(onbCount[0].get('IDCount'));
				reqCountMap.put('OnbReq', Integer.valueOf(onbCount[0].get('IDCount')));
				
			}
			else
				reqCountMap.put('OnbReq', 0);

			System.debug('--reqCountMap--' + reqCountMap);
			return reqCountMap;
		} 
        
        public Integer getFenergoTasksCount() {
            return [SELECT COUNT() FROM Fenergo_Task__c WHERE Eligible_To_Modify_Task__c = true];
        }
    }

    @AuraEnabled
    public static List<ApprovalQueueItem> getApprovalRequestsByRG(string rgId,string scode){
         approvalItems =  getPendingRequestStatusByRG(rgId,scode);
        return approvalItems;
    }

    @AuraEnabled
    public static List<ApprovalQueueItem> getApprovalRequestsByRM(string rmId,string scode){
         approvalItems =  getPendingRequestStatusByRM(rmId,scode);
        return approvalItems;
    }

    @AuraEnabled
    public static List<ApprovalQueueItem> getApprovalRequestsByPOD(string podId,string scode){
         approvalItems =  getPendingRequestStatusByPOD(podId,scode);
        return approvalItems;
    }
    
    @AuraEnabled
    public static List<ApprovalQueueItem> getApprovalRequests(String cmpisApproval){ 
        List<String> idsQueued = new List<String>();
        
        if(cmpisApproval == 'true'){
            approvalItems = getApprovalRequestsQueued(idsQueued);
        }
        else{
            approvalItems =  getPendingRequests(idsQueued);
        }
        
        return approvalItems;
    }
    
    public static List<ApprovalQueueItem> getApprovalItemsByRequestId(List<ID> RequestIds,List<RG_Coverage_Request__c> rgReqs,List<Coverage_Access_Request__c> rmReqs,Map<Id,String> relatedPODRMMap){
        List<ProcessInstanceWorkItem> pinstanceWkItm = [Select ID, ProcessInstanceId, Isdeleted,processInstance.TargetObject.Id,OriginalActorId from processinstanceWorkitem where processInstance.TargetObject.Id IN :RequestIds];
        
        
        if(pinstanceWkItm.size() > 0){
            for(ProcessInstanceWorkItem pwkitem : pinstanceWkItm){
                mapWkItmReqID.put(pwkitem.ProcessInstance.TargetObject.Id,pwkitem.Id);
                mapWkItmUserId.put(pwkitem.OriginalActorId+'#'+pwkitem.ProcessInstance.TargetObject.Id,pwkitem.OriginalActorId+'#'+pwkitem.ProcessInstance.TargetObject.Id);
                OriginalActorUserSet.add(pwkitem.OriginalActorId);
            }
            
            List<User> usrs = [SELECT Id,Name FROM User WHERE (ID IN :userSet OR ID IN : createdUserSet)];
            List<User> usrActor = [SELECT Id,Name FROM User WHERE ID IN :OriginalActorUserSet];
            
            for(User usr : usrs){
                mapUserName.put(usr.Id,usr.Name);
            }
            
            for(User usra : usrActor){
                mapActorId.put(usra.Id,usra.Name);
            }
            
            
            for(RG_Coverage_Request__c rgReq : rgReqs){
                
                if(mapWkItmReqID.containsKey(rgReq.Id)){
                    ApprovalQueueItem item = new ApprovalQueueItem();
                    item.processInstanceWorkItemID = mapWkItmReqID.get(rgReq.Id);
                    
                    item.ApprovalRequest = rgReq.Name;                
                    DateTime dt = rgReq.CreatedDate;                
                    item.CreatedDate = dt.format('yyyy/MM/dd');
                    if(mapUserName.containsKey(rgReq.requested_For_User__c)){
                        item.RequestedFor = rgReq.Sales_Team_for_Coverage__r.Name; //mapUserName.get(rgReq.Sales_Team_for_Coverage__r.Name);
                    }
                    if(mapUserName.containsKey(rgReq.CreatedById)){
                        item.RequestedBy = mapUserName.get(rgReq.CreatedById);
                    }
                    item.AccountName = rgReq.RG_Account__r.Name;
                    item.ParentAccountName = rgReq.RG_Account__r.Parent.Name;
                    item.FunctionalLevel = rgReq.RG_Account__r.RecordType.DeveloperName == 'RG_Account' ? 'RG' : '';
                    item.Product = rgReq.Product2__c;
                    item.ProductRegion = rgReq.Product_Region__c;
                    item.RequestType = rgReq.Type_of_Coverage__c; 
                    item.Role = rgReq.Role__c;
                    String Approvers = '';
                    for(string key  :mapWkItmUserId.keySet()){
                        string [] splitValues = key.split('#');
                        
                        if(splitValues[1] == rgReq.Id){
                            Approvers = Approvers+';'+ mapActorId.get(splitValues[0]);
                        }
                        
                    }
                    Approvers = Approvers.removeStart(';');
                    item.Approvers = Approvers.removeEnd(';');
                    DateTime dtStartDate = rgReq.Start_Date__c;
                    DateTime dtEndDate = rgReq.End_Date__c;
                    if(string.isNotBlank(string.valueOf(dtStartDate)) && (string.valueOf(rgReq.Type_of_Coverage__c).tolowerCase() == 'add' || string.valueOf(rgReq.Type_of_Coverage__c).tolowerCase() == 'update' )){
                        item.FromDate = dtStartDate.format('yyyy/MM/dd');
                    }
                    
                    else if(string.isNotBlank(string.valueOf(dtEndDate)) && string.valueOf(rgReq.Type_of_Coverage__c).tolowerCase() == 'delete'){
                        item.FromDate = dtEndDate.format('yyyy/MM/dd');
                    }
                    approvalItems.add(item);
                }
            }
            
            for(Coverage_Access_Request__c rmReq : rmReqs){
                
                if(mapWkItmReqID.containsKey(rmReq.Id)){
                    ApprovalQueueItem item = new ApprovalQueueItem();
                    item.processInstanceWorkItemID = mapWkItmReqID.get(rmReq.Id);
                    if(rmReq.Type__c!=null && rmReq.Type__c!='Standard' && (rmReq.sub_Type__c == null || rmReq.sub_Type__c == ''))
                    item.Type = rmReq.Type__c.toUpperCase();
                    else if(rmReq.Type__c!='Standard' && (rmReq.sub_Type__c != null && rmReq.sub_Type__c != ''))
                    item.Type =rmReq.sub_Type__c.toUpperCase();
                        
                    item.ApprovalRequest = rmReq.Name;
                    
                    DateTime dt = rmReq.CreatedDate;                
                    item.CreatedDate = dt.format('yyyy/MM/dd');
                    
                    if(mapUserName.containsKey(rmReq.requested_For_User__c)){
                        item.RequestedFor = rmReq.Sales_Team_for_Coverage__r.Name; //mapUserName.get(rmReq.Sales_Team_for_Coverage__r.Name);
                    }
                    if(mapUserName.containsKey(rmReq.CreatedById)){
                        item.RequestedBy = mapUserName.get(rmReq.CreatedById);
                    }
                    if(rmReq.Account__r.Domicile_country__c != null && rmReq.Account__r.Restricted_Flag__c){
                        item.AccountName =  '(' + rmReq.Account__r.Domicile_country__c + '-Restricted Jurisdiction) - ' + rmReq.Account__r.Name;
                    } else {
                        item.AccountName = rmReq.Account__r.Name;
                    }   
                    item.ParentAccountName = rmReq.Account__r.Parent.Name;
                    item.FunctionalLevel = rmReq.Account__r.RecordType.DeveloperName == 'RM_Account' ? 'RM' : rmReq.Account__r.RecordType.DeveloperName == 'POD_Account' ? 'POD' : '';
                    item.Product = rmReq.Product2__c;
                    item.ProductRegion = rmReq.Product_Region__c;
                    item.RequestType = rmReq.Type_of_Coverage__c;
                    item.Role = rmReq.Role__c;
                    if(relatedPODRMMap != null){
                        item.RelatedRMAccountName = relatedPODRMMap.get(rmReq.Account__c) != null ?  relatedPODRMMap.get(rmReq.Account__c) : '';
                    }
                    DateTime dtStartDate = rmReq.Start_Date__c;
                    DateTime dtEndDate = rmReq.End_Date__c;
                    if(string.isNotBlank(string.valueOf(dtStartDate)) && (string.valueOf(rmReq.Type_of_Coverage__c).tolowerCase() == 'add' || string.valueOf(rmReq.Type_of_Coverage__c).tolowerCase() == 'update')){
                        item.FromDate = dtStartDate.format('yyyy/MM/dd');
                    }
                    
                    else if(string.isNotBlank(string.valueOf(dtEndDate)) && string.valueOf(rmReq.Type_of_Coverage__c).tolowerCase() == 'delete'){
                        item.FromDate = dtEndDate.format('yyyy/MM/dd');
                    }
                    String Approvers='';
                    for(string key  :mapWkItmUserId.keySet()){
                        string [] splitValues = key.split('#');
                        
                        if(splitValues[1] == rmReq.Id){
                            Approvers = Approvers+';'+ mapActorId.get(splitValues[0]);
                        }
                        
                    }
                    Approvers = Approvers.removeStart(';');
                    
                    item.Approvers = Approvers.removeStart(';');
                    approvalItems.add(item);  
                }
            }
        }
        
        return approvalItems;
    }
    
    public static List<ApprovalQueueItem> getPendingRequestStatusByRG(string rgId,string scode){
        Set<Id> restricted_rmIds = new Set<Id>();
        List<ID> RequestIds = new List<ID>();
       
        
        List<RG_Coverage_Request__c> rgReqs = [SELECT Id,Name,CreatedDate,requested_For_User__c,Sales_Team_for_Coverage__r.Name,RG_Account__r.Name,RG_Account__r.Parent.Name,
                                               Product2__c,Product_Region__c, CreatedById,Type_of_Coverage__c,Start_Date__c,Role__c,End_Date__c,RG_Account__r.RecordType.DeveloperName from 
                                               RG_Coverage_Request__c WHERE Approved__c =false 
                                               AND Status__c <> 'Rejected' AND Status__c <> 'Recalled' AND RG_Account__c =:rgId AND Sales_team_for_Coverage__r.Coverage_Id__c =:scode];
        for(RG_Coverage_Request__c rgReq :rgReqs){
            RequestIds.add(rgReq.Id);
            userSet.add(rgReq.requested_For_User__c);
            createdUserSet.add(rgReq.CreatedById);
            }
        
        //can be removed
        //restricted_rmIds = new Map<Id,Account>([select id from Account where parentId=:rgId and Active__c = true and recordType.DeveloperName = 'RM_Account'
        //                                       and (restricted_flag__c = true or (NFPE1__c = true or NFPE__c = true))]).keyset();
    
        
        
        List<Coverage_Access_Request__c> rmReqs = [SELECT Id,Type__c,Name,sub_type__c,CreatedDate,requested_For_User__c,Sales_Team_for_Coverage__r.Name,Account__r.Name,Account__r.Parent.Name,Account__r.Domicile_country__c, Account__r.Restricted_Flag__c, CreatedById,
                                                   Type_of_Coverage__c,Product2__c,Product_Region__c,Start_Date__c,Role__c,End_Date__c,Account__r.RecordType.DeveloperName from 
                                                   Coverage_Access_Request__c WHERE Approved__c = false 
                                                   AND Status__c <> 'Rejected' and Status__c <> 'Recalled' AND Account__r.ParentId =: rgId AND Sales_team_for_Coverage__r.Coverage_Id__c =:scode AND Account__r.RecordType.DeveloperName = 'RM_Account']; //Account__c IN:restricted_rmIds AND
        
        for(Coverage_Access_Request__c rmReq :rmReqs){
            RequestIds.add(rmReq.Id);
            userSet.add(rmReq.requested_For_User__c);
            createdUserSet.add(rmReq.CreatedById);            
        }
         system.debug(rgId);
        system.debug(scode);
         system.debug(RequestIds.size());
        system.debug(rgReqs.size());
        system.debug(rmReqs.size());
        approvalItems = getApprovalItemsByRequestId(RequestIds,rgReqs,rmReqs,null);
        return approvalItems;
    }

    public static List<ApprovalQueueItem> getPendingRequestStatusByRM(string rmId,string scode){
        List<ID> RequestIds = new List<ID>();
        List<RG_Coverage_Request__c> rgReqs = new List<RG_Coverage_Request__c>();
       
        List<Coverage_Access_Request__c> rmReqs = [SELECT Id,Type__c,Name,sub_type__c,CreatedDate,requested_For_User__c,Sales_Team_for_Coverage__r.Name,Account__r.Name,Account__r.Parent.Name,Account__r.Domicile_country__c, Account__r.Restricted_Flag__c, CreatedById,
                                                   Type_of_Coverage__c,Product2__c,Product_Region__c,Start_Date__c,Role__c,End_Date__c,Account__r.RecordType.DeveloperName from 
                                                   Coverage_Access_Request__c WHERE Approved__c = false 
                                                   AND Status__c <> 'Rejected' and Status__c <> 'Recalled' AND Account__c =:rmId AND Sales_team_for_Coverage__r.Coverage_Id__c =:scode];
        
        for(Coverage_Access_Request__c rmReq :rmReqs){
            RequestIds.add(rmReq.Id);
            userSet.add(rmReq.requested_For_User__c);
            createdUserSet.add(rmReq.CreatedById);            
        }

        approvalItems = getApprovalItemsByRequestId(RequestIds,rgReqs,rmReqs,null);
        return approvalItems;
    }

    public static List<ApprovalQueueItem> getPendingRequestStatusByPOD(string podId,string scode){
        List<ID> RequestIds = new List<ID>();
        List<RG_Coverage_Request__c> rgReqs = new List<RG_Coverage_Request__c>();
        List<Id> podAccountIdList = new List<Id>();
        Map<Id,String> relatedPODRMMap = new Map<Id,String>();
       
        List<Coverage_Access_Request__c> rmReqs = [SELECT Id,Type__c,Name,sub_type__c,CreatedDate,requested_For_User__c,Sales_Team_for_Coverage__r.Name,Account__r.Name,Account__r.Parent.Name,Account__r.Domicile_country__c, Account__r.Restricted_Flag__c, CreatedById,
                                                   Type_of_Coverage__c,Product2__c,Product_Region__c,Start_Date__c,Role__c,End_Date__c,Account__r.RecordType.DeveloperName from 
                                                   Coverage_Access_Request__c WHERE Approved__c = false 
                                                   AND Status__c <> 'Rejected' and Status__c <> 'Recalled' AND Account__c =:podId AND Sales_team_for_Coverage__r.Coverage_Id__c =:scode];
        
        for(Coverage_Access_Request__c rmReq :rmReqs){
            RequestIds.add(rmReq.Id);
            userSet.add(rmReq.requested_For_User__c);
            createdUserSet.add(rmReq.CreatedById);
            podAccountIdList.add(rmReq.Account__c);
        }

        List<RM_POD_Link__c> relatedRMAccList = [SELECT POD_Account__c,RM_Account__r.Name FROM RM_POD_Link__c WHERE POD_Account__c IN : podAccountIdList];
        for(RM_POD_Link__c relatedAcc : relatedRMAccList){
            if(relatedPODRMMap.get(relatedAcc.POD_Account__c) != null){
                String rmAccList = relatedPODRMMap.get(relatedAcc.POD_Account__c);
                rmAccList = rmAccList + '; ' + relatedAcc.RM_Account__r.Name;
                relatedPODRMMap.put(relatedAcc.POD_Account__c, rmAccList);
            }else{
                relatedPODRMMap.put(relatedAcc.POD_Account__c, relatedAcc.RM_Account__r.Name);
            }
        }

        approvalItems = getApprovalItemsByRequestId(RequestIds,rgReqs,rmReqs,relatedPODRMMap);
        return approvalItems;
    }
    
    public static List<ApprovalQueueItem> getPendingRequests(List<String> idsQueued){
        
        
        
        List<ID> processedRequestIds = new List<ID>();
        List<Id> podAccountIdList = new List<Id>();
        Map<Id,String> relatedPODRMMap = new Map<Id,String>();
        
        if(idsQueued.size() > 0){
            List<ProcessInstanceWorkItem> procsInsWk = [SELECT processInstance.TargetObject.Id FROM processinstanceWorkitem where Id in : idsQueued];
            for(ProcessInstanceWorkItem pr : procsInsWk){
                processedRequestIds.add(pr.processInstance.TargetObject.Id);
            }
        }
        
        List<ID> RequestIds = new List<ID>();
        List<RG_Coverage_Request__c> rgReqs = [SELECT Id,Name,CreatedDate,requested_For_User__c,Sales_Team_for_Coverage__r.Name,RG_Account__r.Name,RG_Account__r.Parent.Name,
                                               Product2__c,Product_Region__c, CreatedById,Type_of_Coverage__c,Start_Date__c,Role__c,End_Date__c,RG_Account__r.RecordType.DeveloperName from 
                                               RG_Coverage_Request__c WHERE Approved__c =false and (requested_For_User__c = : UserInfo.getUserId() OR createdById = : UserInfo.getUserId())
                                               AND Status__c <> 'Rejected' AND Status__c <> 'Recalled' AND Id NOT IN : processedRequestIds];
        
        for(RG_Coverage_Request__c rgReq :rgReqs){
            RequestIds.add(rgReq.Id);
            userSet.add(rgReq.requested_For_User__c);
            createdUserSet.add(rgReq.CreatedById);
            
        }
        
        List<Coverage_Access_Request__c> rmReqs = [SELECT Id,Name,Type__c,sub_type__c,CreatedDate,requested_For_User__c,Sales_Team_for_Coverage__r.Name,Account__r.Name,Account__r.Parent.Name,Account__r.Domicile_country__c, Account__r.Restricted_Flag__c, CreatedById,
                                                   Type_of_Coverage__c,Product2__c,Product_Region__c,Start_Date__c,Role__c,End_Date__c,Group_By__c,Account__r.RecordType.DeveloperName from 
                                                   Coverage_Access_Request__c WHERE Approved__c = false and (requested_For_User__c = : UserInfo.getUserId() OR createdById = : UserInfo.getUserId())
                                                  AND Status__c <> 'Rejected' and Status__c <> 'Recalled' AND Id NOT IN : processedRequestIds];
        
        for(Coverage_Access_Request__c rmReq :rmReqs){
            RequestIds.add(rmReq.Id);
            userSet.add(rmReq.requested_For_User__c);
            createdUserSet.add(rmReq.CreatedById);            
            if('POD' == rmReq.Group_By__c){
                podAccountIdList.add(rmReq.Account__c);
            }
        }

        List<RM_POD_Link__c> relatedRMAccList = [SELECT POD_Account__c,RM_Account__r.Name FROM RM_POD_Link__c WHERE POD_Account__c IN : podAccountIdList];
        for(RM_POD_Link__c relatedAcc : relatedRMAccList){
            if(relatedPODRMMap.get(relatedAcc.POD_Account__c) != null){
                String rmAccList = relatedPODRMMap.get(relatedAcc.POD_Account__c);
                rmAccList = rmAccList + '; ' + relatedAcc.RM_Account__r.Name;
                relatedPODRMMap.put(relatedAcc.POD_Account__c, rmAccList);
            }else{
                relatedPODRMMap.put(relatedAcc.POD_Account__c, relatedAcc.RM_Account__r.Name);
            }
        }
        
        approvalItems = getApprovalItemsByRequestId(RequestIds,rgReqs,rmReqs,relatedPODRMMap);
        return approvalItems;
        
         return approvalItems;
    }
    
   
    public static List<ApprovalQueueItem> getApprovalRequestsQueued(List<String> idsQueued) {
        List<ProcessInstanceWorkItem> pinstanceWkItm = new List<ProcessInstanceWorkItem>();
        List<Id> podAccountIdList = new List<Id>();
        Map<Id,String> relatedPODRMMap = new Map<Id,String>();
        
        /////////////////////////////////////////////
        if(Test.isRunningTest()){
            pinstanceWkItm = [Select ID, ProcessInstanceId, Isdeleted,processInstance.TargetObject.Id from processinstanceWorkitem where ID IN : idsQueued
                                                        ];
        }
        else
            pinstanceWkItm = [Select ID, ProcessInstanceId, Isdeleted,processInstance.TargetObject.Id from processinstanceWorkitem where ID NOT IN : idsQueued
                                                        AND OriginalActorId IN (SELECT ID from User WHERE Id=: userinfo.getUserId())];
        
        system.debug(pinstanceWkItm);
        for(ProcessInstanceWorkItem pwkitem : pinstanceWkItm){
            mapWkItmReqID.put(pwkitem.ProcessInstance.TargetObject.Id,pwkitem.Id);
            
        }
        
        List<RG_Coverage_Request__c> rgReqs = [SELECT Name,CreatedDate,requested_For_User__c,Sales_Team_for_Coverage__r.Name,RG_Account__r.Name,RG_Account__r.Parent.Name,
                                               Product2__c,Product_Region__c, CreatedById,Type_of_Coverage__c,Start_Date__c,Role__c,End_Date__c,RG_Account__r.RecordType.DeveloperName from 
                                               RG_Coverage_Request__c WHERE ID IN : mapWkItmReqID.keySet()];
        
        for(RG_Coverage_Request__c rgReq :rgReqs){
            userSet.add(rgReq.requested_For_User__c);
            createdUserSet.add(rgReq.CreatedById);
            
        }
        
        List<Coverage_Access_Request__c> rmReqs = [SELECT Name,Type__c,sub_type__c,CreatedDate,requested_For_User__c,Sales_Team_for_Coverage__r.Name,Account__c,Account__r.Name,Account__r.Parent.Name, Account__r.Domicile_country__c, Account__r.Restricted_Flag__c, CreatedById,
                                                   Type_of_Coverage__c,Product2__c,Product_Region__c,Start_Date__c,Role__c,End_Date__c,Group_By__c,Account__r.RecordType.DeveloperName,Error_Message__C from 
                                                   Coverage_Access_Request__c WHERE ID IN :mapWkItmReqID.keySet()];
        
        for(Coverage_Access_Request__c rmReq :rmReqs){
            userSet.add(rmReq.requested_For_User__c);
            createdUserSet.add(rmReq.CreatedById);            
            if('POD' == rmReq.Group_By__c){
                podAccountIdList.add(rmReq.Account__c);
            }
        }

        List<RM_POD_Link__c> relatedRMAccList = [SELECT POD_Account__c,RM_Account__r.Name FROM RM_POD_Link__c WHERE POD_Account__c IN : podAccountIdList];
        for(RM_POD_Link__c relatedAcc : relatedRMAccList){
            if(relatedPODRMMap.get(relatedAcc.POD_Account__c) != null){
                String rmAccList = relatedPODRMMap.get(relatedAcc.POD_Account__c);
                rmAccList = rmAccList + '; ' + relatedAcc.RM_Account__r.Name;
                relatedPODRMMap.put(relatedAcc.POD_Account__c, rmAccList);
            }else{
                relatedPODRMMap.put(relatedAcc.POD_Account__c, relatedAcc.RM_Account__r.Name);
            }
        }
        
        List<User> usrs = [SELECT Id,Name FROM User WHERE (ID IN :userSet OR ID IN : createdUserSet)];
        
        for(User usr : usrs){
            mapUserName.put(usr.Id,usr.Name);
        }
        
        for(RG_Coverage_Request__c rgReq : rgReqs){
            ApprovalQueueItem item = new ApprovalQueueItem();
            if(mapWkItmReqID.containsKey(rgReq.Id)){
                item.processInstanceWorkItemID = mapWkItmReqID.get(rgReq.Id);
            }
            item.ApprovalRequest = rgReq.Name;
              DateTime dt = rgReq.CreatedDate;                
                item.CreatedDate = dt.format('yyyy/MM/dd');
            if(mapUserName.containsKey(rgReq.requested_For_User__c)){
                item.RequestedFor = rgReq.Sales_Team_for_Coverage__r.Name;//mapUserName.get(rgReq.requested_For_User__c);
            }
            if(mapUserName.containsKey(rgReq.CreatedById)){
                item.RequestedBy = mapUserName.get(rgReq.CreatedById);
            }
            item.AccountName = rgReq.RG_Account__r.Name;
            item.ParentAccountName = rgReq.RG_Account__r.Parent.Name;
            item.FunctionalLevel = rgReq.RG_Account__r.RecordType.DeveloperName == 'RG_Account' ? 'RG' : '';
            item.Product = rgReq.Product2__c;
            item.ProductRegion = rgReq.Product_Region__c;
            item.RequestType = rgReq.Type_of_Coverage__c; 
            item.Role = rgReq.Role__c;
            DateTime dtStartDate = rgReq.Start_Date__c;
                DateTime dtEndDate = rgReq.End_Date__c;
                 if(string.isNotBlank(string.valueOf(dtStartDate)) && (string.valueOf(rgReq.Type_of_Coverage__c).tolowerCase() == 'add' || string.valueOf(rgReq.Type_of_Coverage__c).tolowerCase() == 'update')){
            item.FromDate = dtStartDate.format('yyyy/MM/dd');
            }
            
               else if(string.isNotBlank(string.valueOf(dtEndDate)) && string.valueOf(rgReq.Type_of_Coverage__c).tolowerCase() == 'delete'){
            item.FromDate = dtEndDate.format('yyyy/MM/dd');
            }
            approvalItems.add(item);
        }
        
        for(Coverage_Access_Request__c rmReq : rmReqs){
            ApprovalQueueItem item = new ApprovalQueueItem();
            if(mapWkItmReqID.containsKey(rmReq.Id)){
                item.processInstanceWorkItemID = mapWkItmReqID.get(rmReq.Id);
            }
            item.ApprovalRequest = rmReq.Name;
              DateTime dt = rmReq.CreatedDate;                
                item.CreatedDate = dt.format('yyyy/MM/dd');
            if(mapUserName.containsKey(rmReq.requested_For_User__c)){
                item.RequestedFor = rmReq.Sales_Team_for_Coverage__r.Name; //mapUserName.get(rmReq.requested_For_User__c);
            }
            if(mapUserName.containsKey(rmReq.CreatedById)){
                item.RequestedBy = mapUserName.get(rmReq.CreatedById);
            }
            
            if(rmReq.Type__c!=null && rmReq.Type__c!='Standard' && (rmReq.sub_Type__c == null || rmReq.sub_Type__c == ''))
                item.Type = rmReq.Type__c.toUpperCase();
            else if(rmReq.Type__c!='Standard' && (rmReq.sub_Type__c != null && rmReq.sub_Type__c != ''))
                item.Type =rmReq.sub_Type__c.toUpperCase();
            
            if(rmReq.Account__r.Domicile_country__c != null && rmReq.Account__r.Restricted_Flag__c){
                item.AccountName =  '(' + rmReq.Account__r.Domicile_country__c + '-Restricted Jurisdiction) - ' + rmReq.Account__r.Name;
            } else {
                item.AccountName = rmReq.Account__r.Name;
            }          
            
            item.ParentAccountName = rmReq.Account__r.Parent.Name;
            item.FunctionalLevel = rmReq.Account__r.RecordType.DeveloperName == 'RM_Account' ? 'RM' : rmReq.Account__r.RecordType.DeveloperName == 'POD_Account' ? 'POD' : '';
            item.Product = rmReq.Product2__c;
            item.ProductRegion = rmReq.Product_Region__c;
            item.RequestType = rmReq.Type_of_Coverage__c;
            item.Role = rmReq.Role__c;
            item.RelatedRMAccountName = relatedPODRMMap.get(rmReq.Account__c) != null ?  relatedPODRMMap.get(rmReq.Account__c) : '';
            item.ErrorMessage = rmReq.Error_Message__C;
            DateTime dtStartDate = rmReq.Start_Date__c;
                DateTime dtEndDate = rmReq.End_Date__c;
                 if(string.isNotBlank(string.valueOf(dtStartDate)) && (string.valueOf(rmReq.Type_of_Coverage__c).tolowerCase() == 'add' || string.valueOf(rmReq.Type_of_Coverage__c).tolowerCase() == 'update')){
            item.FromDate = dtStartDate.format('yyyy/MM/dd');
            }
            
               else if(string.isNotBlank(string.valueOf(dtEndDate)) && string.valueOf(rmReq.Type_of_Coverage__c).tolowerCase() == 'delete'){
            item.FromDate = dtEndDate.format('yyyy/MM/dd');
            }
            approvalItems.add(item);            
        }
        
        return approvalItems;
        
    }
    
    @AuraEnabled 
    public static List<ApprovalQueueItem>  submitApprovedRequests(String cmpApprovedIds,String cmpisApproval){
        
        List<String> approvedIDs = (List<String>)JSON.deserialize(cmpApprovedIds, List<String>.class);
        
       if(!Test.isRunningTest()){
        id batchBulkApprovalRequest = database.executeBatch(new BulkApproveCoverageRequest(userInfo.getUserName(),'Bulk Approval',approvedIDs,'Approve'),1);
        }
          if(cmpisApproval == 'true'){
            approvalItems = getApprovalRequestsQueued(approvedIDs);
        }
        
       else{
            approvalItems =  getPendingRequests(approvedIDs);
        }

        
        
        
        return approvalItems ;
        
    }
    
    @AuraEnabled 
    public static List<ApprovalQueueItem> submitRejectedRequests(string cmpRejectedIds,String cmpisApproval, string cancelorReject){
        
        List<String> rejectedIds = (List<String>)JSON.deserialize(cmpRejectedIds, List<String>.class);
       
        if(!Test.isRunningTest()){
            id batchBulkRejectionRequest;
            //added for JIRA 3246
            if(cancelorReject=='cancel'){
                Set<Id> setInitalProcessInstance = new Set<Id> ();
                Set<Id> setInitalTargetObjectId = new Set<Id> ();
                Set<Id> setFinalTargetObjectId = new Set<Id> ();
                Set<String> setFinalProcessInstance = new Set<String> ();
                Set<String> setRGId = new Set<String> ();
                Set<String> setRMId = new Set<String> ();
                Set<String> setRGKEYId = new Set<String> ();
                //Map<Id, RG_Coverage_Request__c > mapRGKEY = new Map<Id, RG_Coverage_Request__c> ();
                Set<Id> setRMKEYId = new Set<Id> ();
                Map<Id, Coverage_Access_Request__c > mapRMKEY = new Map<Id, Coverage_Access_Request__c> ();
                if(rejectedIds.size () > 0){
                    system.debug('rejectedIds **'+ rejectedIds);
                   //get the target object
                   for(ProcessinstanceWorkitem workitem: [Select ID, ProcessInstanceId, Isdeleted from processinstanceWorkitem where Id IN : rejectedIds]){
                      setInitalProcessInstance.add(workitem.ProcessInstanceId);
                   }
                   for(ProcessInstance pi: [Select ID, TargetObjectId, Status from ProcessInstance where Id IN : setInitalProcessInstance]){
                      setInitalTargetObjectId.add(pi.TargetObjectId);
                   }
                    system.debug('setInitalProcessInstance **'+ setInitalProcessInstance);
                    system.debug('setInitalTargetObjectId **'+ setInitalTargetObjectId);
                    //get if RG or RM request
                    for(Id idrecord : setInitalTargetObjectId){
                        String sId = String.valueof(idrecord);
                        if(sId.startsWith('a0C')){
                           setRGId.add(sId);
                        }
                        else if(sId.startsWith('a06')){
                           setRMId.add(sId); 
                        }
                    }
                    system.debug('setRGId **'+ setRGId);
                    system.debug('setRMId **'+ setRMId);
                    //get the RG request select
                    for(RG_Coverage_Request__c covRG: [Select Id , Name ,RG_Account__c,UniqueID__c from RG_Coverage_Request__c where Id IN : setRGId]){
                        setRGKEYId.add(covRG.UniqueID__c);
                        //mapRGKEY.put(covRG.UniqueID__c, covRG);
                    }
                     system.debug('setRGKEYId **'+ setRGKEYId);
                    //if RG request get all RM and add to list
                    for(Coverage_Access_Request__c covRG: [Select Id , Name ,Account__c,UniqueID__c,ParentUniqueID__c from Coverage_Access_Request__c where ParentUniqueID__c IN : setRGKEYId]){
                        //remove the same RM if already in the list
                        if(!setRMId.contains(covRG.Id)){
                            setRMId.add(covRG.Id);
                        }
                    }
                    system.debug('setRMId 2**'+ setRMId);
                    if(setRMId.size() > 0)
                       setRGId.addAll(setRMId);
                    system.debug('setRMId 3**'+ setRMId);
                    for(ProcessInstance pi: [Select ID, TargetObjectId, Status from ProcessInstance where TargetObjectId IN : setRGId]){
                       setFinalTargetObjectId.add(pi.ID);
                    }
                     system.debug('setRMId 3**'+ setFinalTargetObjectId);
                    for(ProcessinstanceWorkitem workitem: [Select ID, ProcessInstanceId, Isdeleted from processinstanceWorkitem where ProcessInstanceId IN : setFinalTargetObjectId]){
                       setFinalProcessInstance.add(workitem.ID);
                    }
                      system.debug('setRMId 3**'+ setFinalProcessInstance);
                    if(setFinalProcessInstance.size() >0){
                        rejectedIds = new List<String>(setFinalProcessInstance);
                        system.debug('rejectedIds **'+ rejectedIds);
                        batchBulkRejectionRequest = database.executeBatch(new BulkApproveCoverageRequest(userInfo.getUserName(),'Bulk Rejection',rejectedIds,'Removed'),1);
                    }
                }
               
            }else
                batchBulkRejectionRequest = database.executeBatch(new BulkApproveCoverageRequest(userInfo.getUserName(),'Bulk Rejection',rejectedIds,'Reject'),1);    
            
        }
         if(cmpisApproval == 'true'){
            approvalItems = getApprovalRequestsQueued(rejectedIds);
        }
        
       else{
            approvalItems =  getPendingRequests(rejectedIds);
           
        }
        
        return approvalItems;
        
    }
    
    @AuraEnabled
 	public static String getETradingEnablementApprovalRequests()
 	{
 		return getETradingEnablementApprovalRequests('myApprovals');
 	}
    
    @AuraEnabled
 	public static String getETradingEnablementApprovalRequests(String selectedView)
 	{
 		ETradingEnablementData eTradingEnablementData = new ETradingEnablementData();

        Set<Id> salesTeamForCoverageOwnerIds = readSalesTeamForCoverageOwnerIds(selectedView);
        List<ETradingEnablement__c> eTradingEnablements = readETradingEnablementApprovalRequests(salesTeamForCoverageOwnerIds);
        Set<Id> eTradingEnablementsCoverage = readETradingEnablementsCoverage(eTradingEnablements, salesTeamForCoverageOwnerIds); 

		eTradingEnablementData = getETradingEnablementData(eTradingEnablements, eTradingEnablementsCoverage);
		
		return JSON.serialize(eTradingEnablementData);
 	}
 	
    private static Set<Id> readSalesTeamForCoverageOwnerIds(String selectedView)
    {
        Set<Id> salesTeamForCoverageOwnerIds = new Set<Id>();

        switch on selectedView 
		{
			when 'myApprovals' 
			{
                salesTeamForCoverageOwnerIds.add(UserInfo.getUserId());
            }

            when 'reporteeApprovals'             
            {
                for (User user : [SELECT Id, ManagerId 
								  FROM User 
								  WHERE ManagerId = :UserInfo.getUserId()])
				{
					salesTeamForCoverageOwnerIds.add(user.Id);
				}			
            }
        }

        return salesTeamForCoverageOwnerIds;
    }
    
    private static List<ETradingEnablement__c> readETradingEnablementApprovalRequests(Set<Id> salesTeamForCoverageOwnerIds)
    {
        List<ETradingEnablement__c> eTradingEnablements = new List<ETradingEnablement__c>();

        Id eTradingEnablementRequestRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Request').getRecordTypeId();
        
        eTradingEnablements = [SELECT Id, Name, 
                               Contact__r.Name,
                               Contact__r.AccountId, 
                               Contact__r.RG_Account__c,
                               Contact__r.RG_Account__r.Name,
                               Electronic_Platform__c,
                               Status__c,  
                               ETradingEnablementProduct__r.Name,  
                               Request_Type__c, 
                               Sales_Team_for_Coverage__c,
                               Sales_Team_for_Coverage__r.OwnerId,
                               Sales_Team_for_Coverage__r.Owner.Name,    
                               Comments__c,
                               CreatedById, 
                               CreatedBy.Name, 
                               CreatedDate, 
                               RecordType.Name   
                               FROM ETradingEnablement__c 
                               WHERE RecordTypeId =:eTradingEnablementRequestRecordTypeId 
                               AND Status__c = 'Pending Approval'  
                               AND Sales_Team_for_Coverage__r.OwnerId IN :salesTeamForCoverageOwnerIds];
    
		return eTradingEnablements;
    }

    private static Set<Id> readETradingEnablementsCoverage(List<ETradingEnablement__c> eTradingEnablements, Set<Id> salesTeamForCoverageOwnerIds)
    {
        Set<Id> eTradingEnablementsCoverage = new Set<Id>();

        Id coverageTeamMemberActiveRecordTypeId = Schema.getGlobalDescribe().get('Coverage_Team_Member__c').getDescribe().getRecordTypeInfosByName().get('Active Coverage').getRecordTypeId();
        
        Set<Id> accountIds = new Set<Id>();
        Set<Id> accountIdsCoverage = new Set<Id>();

        for (ETradingEnablement__c eTradingEnablement : eTradingEnablements)
        {
            accountIds.add(eTradingEnablement.Contact__r.AccountId);
        }

		for (Coverage_Team_Member__c  coverageTeamMember : 
            [SELECT Id, 
             Account__c, 
             Sales_Team_for_Coverage__c, 
             Sales_Team_for_Coverage__r.OwnerId, 
             RecordTypeId 
             FROM Coverage_Team_Member__c 
             WHERE RecordTypeId = :coverageTeamMemberActiveRecordTypeId  
             AND Sales_Team_for_Coverage__r.OwnerId IN :salesTeamForCoverageOwnerIds  
             AND Account__c IN :accountIds]) 
        {
            accountIdsCoverage.add(coverageTeamMember.Account__c);
        }

        for (ETradingEnablement__c eTradingEnablement : eTradingEnablements)
        {
            if (accountIdsCoverage.contains(eTradingEnablement.Contact__r.AccountId))
            {
                eTradingEnablementsCoverage.add(eTradingEnablement.Id);
            }
        }
        
        return eTradingEnablementsCoverage;
    }

 	public static ETradingEnablementData getETradingEnablementData (List<ETradingEnablement__c> eTradingEnablements, Set<Id> eTradingEnablementsCoverage)
 	{
 		ETradingEnablementData eTradingEnablementData = new ETradingEnablementData();
 		eTradingEnablementData.eTradingEnablementRequestData = new List<ETradingEnablementRequestData>();
        eTradingEnablementData.eTradingEnablementNoCoverageRequestData = new List<ETradingEnablementRequestData>();
 		
 		if (!eTradingEnablements.isEmpty())
 		{
	 		for (ETradingEnablement__c eTradingEnablement : eTradingEnablements)
			{
				ETradingEnablementRequestData eTradingEnablementRequestData = new ETradingEnablementRequestData();
				
				eTradingEnablementRequestData.id = eTradingEnablement.Id;  
                eTradingEnablementRequestData.name = eTradingEnablement.Name;
                eTradingEnablementRequestData.nameLink = '/' + eTradingEnablement.Id; 
				eTradingEnablementRequestData.contact = eTradingEnablement.Contact__r.Name;
                eTradingEnablementRequestData.accountId = eTradingEnablement.Contact__r.RG_Account__c; 
				eTradingEnablementRequestData.accountLink = '/lightning/r/Account/' + eTradingEnablement.Contact__r.RG_Account__c  +  '/view';
				eTradingEnablementRequestData.accountName = eTradingEnablement.Contact__r.RG_Account__r.Name;   
				eTradingEnablementRequestData.electronicPlatform = eTradingEnablement.Electronic_Platform__c;
				eTradingEnablementRequestData.product = eTradingEnablement.ETradingEnablementProduct__r.Name; 

                if (eTradingEnablement.Request_Type__c == 'Add')
                {
                    eTradingEnablementRequestData.requestTypeIcon = 'utility:new';
                }
                else if(eTradingEnablement.Request_Type__c == 'Revoke')
                {
                    eTradingEnablementRequestData.requestTypeIcon = 'utility:clear';
                }
                else if(eTradingEnablement.Request_Type__c == 'Transfer')
                {
                    eTradingEnablementRequestData.requestTypeIcon = 'utility:rotate';
                }
                else 
                {
                   eTradingEnablementRequestData.requestTypeIcon = '';
                }

				eTradingEnablementRequestData.salesTeamForCoverageOwnerName = eTradingEnablement.Sales_Team_for_Coverage__r.Owner.Name; 
				eTradingEnablementRequestData.comments = eTradingEnablement.Comments__c;
				eTradingEnablementRequestData.createdBy = eTradingEnablement.CreatedBy.Name;
				eTradingEnablementRequestData.createdDate = eTradingEnablement.CreatedDate;

                if (eTradingEnablementsCoverage.contains(eTradingEnablement.Id))
                {
                    eTradingEnablementData.eTradingEnablementRequestData.add(eTradingEnablementRequestData);
                }
                else 
                {
                    eTradingEnablementData.eTradingEnablementNoCoverageRequestData.add(eTradingEnablementRequestData);
                }

			}
 		}
		
        if (eTradingEnablementData.eTradingEnablementRequestData.isEmpty())
        {
            eTradingEnablementData.displayETradingApprovalList = false;
        }
        else 
        {
            eTradingEnablementData.displayETradingApprovalList = true;
        }

        if (eTradingEnablementData.eTradingEnablementNoCoverageRequestData.isEmpty())
        {
            eTradingEnablementData.displayETradingNoCoverageList = false;
        }
        else 
        {
           eTradingEnablementData.displayETradingNoCoverageList = true;
        }

		return eTradingEnablementData;
 	}
 	
 	@AuraEnabled 
    public static String processRequests(List<Id> eTradingEnablementIds, String approvalAction)
    {
    	ApprovalData approvalData = new ApprovalData();
    	
    	if (eTradingEnablementIds.isEmpty())
    	{
    		approvalData.error = true;
			approvalData.errorMessage = 'No items selected';
			
			return JSON.serialize(approvalData);
    	}
		
		try
    	{
    		processETradingEnablements(eTradingEnablementIds, approvalAction);
    		
    		List<Request_Notification__e> requestNotifications = new List<Request_Notification__e>();
			Request_Notification__e requestNotification = new Request_Notification__e();
			requestNotification.Message__c = 'RequestProcessed';
			requestNotifications.add(requestNotification);
			
			EventBus.publish(requestNotifications);
    	} 
		catch (Exception e) 
    	{
    		approvalData.error = true;
			approvalData.errorMessage = e.getMessage();
			
			return JSON.serialize(approvalData);
    	}

    	return JSON.serialize(approvalData);
    }
    
    // Approve or reject 
    private static void processETradingEnablements(List<Id> eTradingEnablementIds, String approvalAction)
	{
		List<ETradingEnablement__c> eTradingEnablements = new List<ETradingEnablement__c>();
		
		for (Id eTradingEnablementId : eTradingEnablementIds)
		{
			ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c(Id = eTradingEnablementId);
			eTradingEnablement.Status__c = approvalAction;
			
			eTradingEnablements.add(eTradingEnablement);
		}
		  
		update eTradingEnablements;
	}
 	
 	public class ETradingEnablementData
 	{
        public Boolean displayETradingNoCoverageList;
        public Boolean displayETradingApprovalList;
        public List<ETradingEnablementRequestData> eTradingEnablementNoCoverageRequestData;
		public List<ETradingEnablementRequestData> eTradingEnablementRequestData;
 	}
 	
 	public class ETradingEnablementRequestData 
    {
        public String id;  
        public String name;
        public String nameLink;
		public String contact;
        public String accountId;
		public String accountLink;
		public String accountName;   
		public String electronicPlatform;
		public String product;
        public String requestTypeIcon;
		public String salesTeamForCoverageOwnerName; 
		public String comments;
		public String createdBy; 
		public DateTime createdDate; 
	}
	
	public class ApprovalData
 	{
 		public ApprovalData() 
        {
        	error = false;
            errorMessage = '';
        }   
        
        public Boolean error;
		public String errorMessage;
 	}
    
    //added section for JIRA SALES 1588
    @AuraEnabled    
    public static List<ApprovalQueueItem> getItemstoApprove(){
        String strActorId = userinfo.getUserId();
        //added for JIRA 3333
        List<ApprovalQueueItem> opptapprovalItems = new List<ApprovalQueueItem>();
        system.debug('strActorId ***'+ strActorId);
        Set<Id> targets = new Set<Id>();
        Map<Id,Id> mapProcessInstanceWorkItem = new Map<Id,Id>();
        List<Opportunity> lstOppt = new List<Opportunity>();
        for (ProcessInstanceWorkItem workItem : [SELECT ProcessInstance.TargetObjectId FROM ProcessInstanceWorkItem WHERE ProcessInstance.Status = 'Pending' AND ActorId = :strActorId]) {
           targets.add(workItem.ProcessInstance.TargetObjectId);
           mapProcessInstanceWorkItem.put(workItem.ProcessInstance.TargetObjectId,workItem.Id);
        }
        //added amount field for SALES 3525 
        for(Opportunity oppt: [SELECT Id,Name,AccountId,Account.name,CreatedDate,Parent_Product__c,Amount, toLabel(Product_Region__c),Referee__r.name,StageName,Referral__r.name, Start_Date__c FROM Opportunity WHERE Id IN :targets order by createddate desc]){
            ApprovalQueueItem item = new ApprovalQueueItem();
            if(mapProcessInstanceWorkItem.containsKey(oppt.Id)){
                item.processInstanceWorkItemID = mapProcessInstanceWorkItem.get(oppt.Id);
            }
            item.ApprovalRequest = oppt.Name;           
            item.AccountName = oppt.Account.name;
            item.Product = oppt.Parent_Product__c;
            item.ProductRegion = oppt.Product_Region__c;
            item.RequestedFor = oppt.Referral__r.name;
            item.RequestedBy = oppt.Referee__r.name;
            item.Stage = oppt.StageName;  
            DateTime dt = oppt.CreatedDate;                
            item.CreatedDate = dt.format('yyyy/MM/dd');            
            dt = oppt.Start_Date__c;                
            item.FromDate = dt.format('yyyy/MM/dd');
            
            //added for SALES-3525
            item.Amount = oppt.Amount;
            opptapprovalItems.add(item);
        }        
        return opptapprovalItems;
    }
    
   
    @AuraEnabled 
    public static List<ApprovalQueueItem> processOpptRequests(String ProcessingIds, String strAction,String Comments) {
       
        List<String> requestIds = (List<String>)JSON.deserialize(ProcessingIds, List<String>.class);
        List<Approval.ProcessWorkitemRequest> lstapprovalitems = new List<Approval.ProcessWorkitemRequest>();
        List<ProcessInstanceWorkItem> opptitems = [Select ID, ProcessInstanceId, Isdeleted from processinstanceWorkitem where Id IN : requestIds];
        for (ProcessInstanceWorkItem prc : opptitems){
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments(Comments);
            req2.setAction(strAction);
            req2.setWorkitemId(prc.id);  
            lstapprovalitems.add(req2);                         
        }
        if(lstapprovalitems.size() > 0){
           try{
               List<Approval.ProcessResult> result = Approval.process(lstapprovalitems);

               List<Request_Notification__e> requestNotifications = new List<Request_Notification__e>();
                Request_Notification__e requestNotification = new Request_Notification__e();
                requestNotification.Message__c = 'RequestProcessed';
                requestNotifications.add(requestNotification);
                
                EventBus.publish(requestNotifications);

               system.debug('result : '+ result);
            }            
            catch(exception ex){
               //throw new AuraHandledException('Error Occured:'+ ex.getMessage());
               system.debug('Exception '+ex.getStackTraceString()); 
            }
        }        
        approvalItems =  getItemstoApprove();
   
        return approvalItems ;      
    }

/*
    @AuraEnabled
    public static Boolean isCurrentSchApprover(){
       return UserHelper.isCurrentSchApprover;
    }

    @AuraEnabled
    public static Boolean isCurrentPreOnboardingApprover(){
       return UserHelper.isCurrentPreOnboardingApprover;
    }
*/

    public static Integer getEtradingEnablementCount(){
		Id eTradingEnablementRequestRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Request').getRecordTypeId();
		Integer eTradingCount = 0;
		List<AggregateResult> eTradingEnablementsCount = [SELECT COUNT(Id) IdCount 
														  FROM ETradingEnablement__c 
														  WHERE RecordTypeId = :eTradingEnablementRequestRecordTypeId  
														  AND Status__c = 'Pending Approval' 
														  AND Sales_Team_for_Coverage__c IN 
														  (SELECT Id  
														  FROM Sales_Team_for_Coverage__c 
														  WHERE OwnerId = :UserInfo.getUserId())];
        
		eTradingCount = Integer.valueOf(eTradingEnablementsCount[0].get('IdCount'));

		return eTradingCount;
	}

    //Below method return JSON string which is used to display count in UtilityBarNotification and BuklApprovals
	@AuraEnabled
	public static String pendingApprovals(){
    
		List<Id> processInstanceIdList = new List<Id>();
		List<Id> coverageProcessIdList = new List<Id>();
		List<Id> crossSellProcessIdList = new List<Id>();
		List<Id> deskHeadProcessIdList = new List<Id>();	///as DeskHead OnbRequest is assigned to user, it is calcuated seperately.
		
		Integer onbReqCountExDeskHead = 0;
		Integer onbReqDeskHeadCount = 0;
		Map<String, Integer> reqCountMap = new Map<String, Integer>();
		ItemsToApproveCount approvalCountObj = new ItemsToApproveCount();

		List<ProcessInstanceWorkitem> processInstanceWorkItemList = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObject.Type FROM ProcessInstanceWorkitem WHERE OriginalActorId =:UserInfo.getUserId()];
		
			if(processInstanceWorkItemList != null){
				for(ProcessInstanceWorkitem processInsWrkObj : processInstanceWorkItemList){
					//seperate out pending items to approve request which is assigned to user as per Objects
					if('Coverage_Access_Request__c'.equals(processInsWrkObj.ProcessInstance.TargetObject.Type) ||
							'RG_Coverage_Request__c'.equals(processInsWrkObj.ProcessInstance.TargetObject.Type))
						coverageProcessIdList.add(processInsWrkObj.Id);
					else if('Opportunity'.equals(processInsWrkObj.ProcessInstance.TargetObject.Type))
						crossSellProcessIdList.add(processInsWrkObj.Id);
					else if('Onboarding_Request__c'.equals(processInsWrkObj.ProcessInstance.TargetObject.Type))
						deskHeadProcessIdList.add(processInsWrkObj.Id);
				}
			}
		
		approvalCountObj.coverageRequestCount = coverageProcessIdList != null ? coverageProcessIdList.size() : 0;
		approvalCountObj.crossSellCount = crossSellProcessIdList != null ? crossSellProcessIdList.size() : 0;

		//Inner with sharing class created to enforce sharing rules for SCH request and Pre-Onboarding request
		WithSharingMethods ws = new WithSharingMethods();
		reqCountMap = ws.getApprovalCount();
		approvalCountObj.schRequestCount =  reqCountMap.get('SCH') ;
		onbReqCountExDeskHead = reqCountMap.get('OnbReq');
		onbReqDeskHeadCount = deskHeadProcessIdList != null ? deskHeadProcessIdList.size() : 0;
		approvalCountObj.onbRequestCount =  onbReqCountExDeskHead + onbReqDeskHeadCount;
        approvalCountObj.fenTaskCount = ws.getFenergoTasksCount();
	
		//eTrading Count
		approvalCountObj.etradingCount = getEtradingEnablementCount();


		approvalCountObj.totalApprovalsCount = approvalCountObj.coveragerequestCount + approvalCountObj.etradingCount + approvalCountObj.crossSellCount +
												approvalCountObj.schRequestCount + approvalCountObj.onbRequestCount + approvalCountObj.fenTaskCount;
												
		System.debug('--json approvalCountObj--' + JSON.serialize(approvalCountObj));
		return JSON.serialize(approvalCountObj);
		
	}
    
    /*@AuraEnabled
    public Static Integer getCountOfObPendingRequests() {
        Integer obPendingRequestsCount = 0;
        try {
            obPendingRequestsCount = [SELECT COUNT() FROM Onboarding_Request__c WHERE Pending_Request__c = True];
        } catch (Exception e) {
            throw new AuraHandledException ('Failed to retrieve number of Pending Onboarding Requests - Error: ' + e.getMessage());
        }
        
        return obPendingRequestsCount;
    }*/
    
    @AuraEnabled
    public Static PendingRequestsWrapper getCountOfPendingRequests() {
        PendingRequestsWrapper pendingRequests;
        try {
            //List<ApprovalQueueItem> approvalItems = getApprovalRequests(cmpisApproval);
            //Integer coverageRequestCount =approvalItems != null ? approvalItems.size() : 0;
            //System.debug('---coverageRequestCount--' + coverageRequestCount);
            Integer obPendingRequestsCount = [SELECT COUNT() FROM Onboarding_Request__c WHERE Pending_Request__c = True];
            Integer schPendingRequestsCount = [SELECT COUNT() FROM SCH_Request__c WHERE Is_My_Pending_Request__c = True];
            pendingRequests = new PendingRequestsWrapper(obPendingRequestsCount, schPendingRequestsCount);
        } catch (Exception e) {
            throw new AuraHandledException ('Failed to retrieve number of Pending Requests - Error: ' + e.getMessage());
        }    
        
        return pendingRequests;
    }
    
    public with sharing class PendingRequestsWrapper {
        @AuraEnabled
        public Integer onBoardingPendingRequestsCount {get;set;}
        @AuraEnabled
        public Integer schPendingReqeuestsCount {get;set;}
                    
        public PendingRequestsWrapper(Integer obRequestsCount, Integer schRequestsCount) {            
           	this.onBoardingPendingRequestsCount = obRequestsCount != null ? obRequestsCount : 0;
            this.schPendingReqeuestsCount = schRequestsCount != null ? schRequestsCount : 0;
        }
        public PendingRequestsWrapper() {
            
        }
    }
}