global class ProcessStagingCoverages implements Database.batchable<sObject>, Database.Stateful{ 
    
    private String exception_message = '';
    private String generatedErrorCSVfile='';
    private Boolean batchExecutionSuccessfully = true;
    private Boolean IsError = false;
    private String useGUID = '';
    private Boolean isProcessed = false;
    Boolean isRequesterNonApprover = false;
    Boolean isRequesterInApproverLevel1 = false;
    Boolean isRequesterInApproverLevel2 = false;
    Boolean processLevel1 = false;
    Boolean processLevel2 = false;
    Set<string> UserEmailIds = new Set<string>();
    public static Id  requestorId;
    Boolean isCVGTool = false;
    public static string FLAG_NFPE = CoverageUtil.FLAG_NFPE;
    public static string FLAG_NFPE1 = CoverageUtil.FLAG_NFPE1;
    
	//added for JIRA 1588 
	public static String strOpportunityflow = CoverageUtil.CROSS_SELL_REFERRAL;
    
    //static List<RG_Coverage_Request__c> rgRequestsToDelete = new List<RG_Coverage_Request__c>();
    //static List<Coverage_Access_Request__c> rmRequestsToDelete = new List<Coverage_Access_Request__c>();
    
    public string stagingquery{get;set;}
    CoverageBulkUploadUtility bulkManager = new CoverageBulkUploadUtility();
    List<Coverage_Temp__c> updateStagingRecords = new List<Coverage_Temp__c>();
    Set<string> restrictedCountries = new Set<string>();
    Set<String> delKeys = new Set<String>();
    Set<String> rmRequestsdelKeys = new Set<String>();
	Set<Id> SetIDsExisting = new Set<Id>();
    Set<String> rmRequestsCancelKeys = new Set<String>();
    String deleteRMRequestCondition = '';
    //commented as not needed JIRA Sales 1588
    //List<RG_Coverage_Request__c> rgRequestsToDelete = new List<RG_Coverage_Request__c>();
    //List<Coverage_Access_Request__c> rmRequestsToDelete = new List<Coverage_Access_Request__c>();
    //List<RG_Coverage_Request__c> rgRequestsToCancel = new List<RG_Coverage_Request__c>();
    //List<Coverage_Access_Request__c> rmRequestsToCancel = new List<Coverage_Access_Request__c>();
    Set<string> processedKeySet = new Set<string>();
    
    //added for JIRA SALES 1588
    public Set<String> deleteRequestKeys = new Set<String>();
    //commented for JIRA SALES 1588
    /*global ProcessStagingCoverages(string useGUID, boolean isProcessed,List<RG_Coverage_Request__c> rgRequestsToDelete,List<Coverage_Access_Request__c> rmRequestsToDelete)
    {
        try
        {
            this.useGUID = useGUID;
            this.isProcessed = isProcessed;
            this.rgRequestsToDelete = rgRequestsToDelete;
            this.rmRequestsToDelete = rmRequestsToDelete;
            
            if(!test.isRunningTest()){
                for (Restricted_Countries__c rc:[select Restricted_Country_Name__c from Restricted_Countries__c])
                    restrictedCountries.add(rc.Restricted_Country_Name__c);
            }
            generatedErrorCSVfile = 'rowNo,clientRGKey,clientKey,salesCode,productGroup,productRegion,productName,role,action,fromDate,Error\n';
            stagingquery = 'select id from Coverage_Temp__c where isProcessed__c = ' + isProcessed + ' and GUID__c = \'' + useGUID + '\'';
            if(test.isRunningTest())
{Decimal a = 2/0;}
        }
        catch(Exception e)
        {   
            exception_message += e+'\n'+e.getStackTraceString();
            exception_message += '\n';
            batchExecutionSuccessfully = false;
            UserEmailIds = null;
            bulkManager.emailLog('FAILURE',exception_message,null,'Exception',null,null);
        }
    }*/
    //added for JIRA SALES 1588
    global ProcessStagingCoverages(string useGUID)
    {
        try
        {
            this.useGUID = useGUID;
            system.debug('Use Identifier: '+useGUID);
            this.isProcessed = true;
           
            if(!test.isRunningTest()){
                for (Restricted_Countries__c rc:[select Restricted_Country_Name__c from Restricted_Countries__c])
                    restrictedCountries.add(rc.Restricted_Country_Name__c);
            }
            generatedErrorCSVfile = 'rowNo,clientRGKey,clientKey,salesCode,productGroup,productRegion,productName,role,action,fromDate,Error\n';
            stagingquery = 'select id from Coverage_Temp__c where isProcessed__c = false and GUID__c = \'' + useGUID + '\'';
        }
        catch(Exception e)
        {   
            exception_message += e+'\n'+e.getStackTraceString();
            exception_message += '\n';
            batchExecutionSuccessfully = false;
            UserEmailIds = null;
            bulkManager.emailLog('FAILURE',exception_message,null,'Exception',null,null);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(stagingquery);
    }  
    
    global void execute(Database.batchableContext info, List<sObject> scope){
        processRequest(scope);
    }     
    
    global void finish(Database.batchableContext info){  
        if(batchExecutionSuccessfully)
        {
            
            List<Request_Notification__e> notifications = new List<Request_Notification__e>();
            Request_Notification__e notify = new Request_Notification__e();         
            notify.Message__c = 'RequestCreated';
            notifications.add(notify);
            List<Database.SaveResult> publishResult = EventBus.publish(notifications);
            
            for(Database.SaveResult sr : publishResult){
                if(sr.isSuccess()){
                    system.debug('SuccessFully published event.'); 
                }
                else
                {
                    for(Database.Error err : sr.errors){
                        System.debug('Error returned :' +
                                     err.getStatusCode() + ' - '+ err.getMessage());
                    }
                }
            }
            
            if(isCVGTool)
                CoverageBulkUploadUtility.isCoverageTool = true;
            
            system.debug('processedKeySet: '+processedKeySet);
            
            if(processedKeySet.size()>0)//delete request without product
            {
                //delete request without product
                List<RG_Coverage_Request__c> finaldeleteRGRequest = new  List<RG_Coverage_Request__c>();
                List<Coverage_Access_Request__c> finaldeleteRMRequest = new  List<Coverage_Access_Request__c>();
                List<RG_Coverage_Request__c> finalcancelRGRequest = new  List<RG_Coverage_Request__c>();
                List<Coverage_Access_Request__c> finalcancelRMRequest = new  List<Coverage_Access_Request__c>();
                system.debug('ToDelete: '+delKeys);
                
                for(RG_Coverage_Request__c rg: [select id,Sales_Team_for_Coverage__c,RG_Account__r.rdm_org_ID__c,UniqueID__c from RG_Coverage_Request__c where UniqueID__c in:delKeys and status__c='Pending Approval']){
                    string rgkey = rg.rg_account__r.rdm_org_Id__c + '#' + rg.Sales_Team_for_Coverage__c;
                    system.debug(rgkey);
                    if(processedKeySet.contains(rgkey))
                        finaldeleteRGRequest.add(rg);
                }
                String coverageAccessRequestQuery = 'select id,Sales_Team_for_Coverage__c,Account__r.rdm_org_ID__c,Account__r.Parent.rdm_org_ID__c,UniqueID__c '+ 
                                                    'from Coverage_Access_Request__c where (UniqueID__c in:delKeys' + deleteRMRequestCondition +') '+ 
                                                     'and status__c=\'Pending Approval\'';
                system.debug('**coverageAccessRequestQuery'+coverageAccessRequestQuery);                                                     
                List<Coverage_Access_Request__c> coverageAccessRequestList = Database.query(coverageAccessRequestQuery);                                                 
                for(Coverage_Access_Request__c rm: coverageAccessRequestList){
                    string rmkey = rm.account__r.rdm_org_Id__c + '#' + rm.Sales_Team_for_Coverage__c;
                    string rgkey = rm.account__r.parent.rdm_org_Id__c + '#' + rm.Sales_Team_for_Coverage__c;
                    system.debug(rmkey);
                    if(processedKeySet.contains(rmkey) || processedKeySet.contains(rgkey))
                        finaldeleteRMRequest.add(rm);
                }
                system.debug('finaldeleteRGRequest G** '+ finaldeleteRGRequest);
                system.debug('finaldeleteRMRequest M ** '+ finaldeleteRMRequest);
                if(finaldeleteRGRequest.size()>0)
                {
                    system.debug('RG Hard deleted:');
                    system.debug(finaldeleteRGRequest);
                    delete finaldeleteRGRequest;
                }
                if(finaldeleteRMRequest.size()>0)
                {
                    system.debug('RM Hard deleted:');
                    delete finaldeleteRMRequest;
                    system.debug(finaldeleteRMRequest);
                }
                //cancel duplicate request 
                Set<Id> setIdItems = new Set<Id>();
                List<Approval.ProcessWorkitemRequest> lstapproval = new List<Approval.ProcessWorkitemRequest>();
                system.debug('ToCancel: '+SetIDsExisting);
               if(SetIDsExisting.size() > 0){
                      //reject the approval process items 
                    ProcessInstanceWorkitem[] workItems = [ SELECT Id FROM ProcessInstanceWorkitem 
                                                                          WHERE ProcessInstance.TargetObjectId IN: SetIDsExisting
                                                               AND ProcessInstance.Status = 'Pending' ]; 
                    for(ProcessInstanceWorkitem workitem : workItems){
                        Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();  
                        pwr.setAction('Reject');
                        pwr.setComments('Created new request for this request');
                        pwr.setWorkItemId(workitem.id); 
                        lstapproval.add(pwr);
                    }
                    if(lstapproval.size() > 0){
                        List<Approval.ProcessResult> result = Approval.process(lstapproval);
                        system.debug('recall result **'+ result);
                    }  
                }
                for(RG_Coverage_Request__c rg: [select id,Sales_Team_for_Coverage__c,RG_Account__r.rdm_org_ID__c,UniqueID__c from RG_Coverage_Request__c where ID in:SetIDsExisting and status__c='Pending Approval']){
                    string rgkey = rg.rg_account__r.rdm_org_Id__c + '#' + rg.Sales_Team_for_Coverage__c;
                    system.debug(rgkey);
                    if(processedKeySet.contains(rgkey)){
                        rg.status__c = 'Recalled';
                        finalcancelRGRequest.add(rg);
                    }                       
                }
                for(Coverage_Access_Request__c rm: [select id,Sales_Team_for_Coverage__c,Account__r.rdm_org_ID__c,UniqueID__c  from Coverage_Access_Request__c where ID in:SetIDsExisting and status__c='Pending Approval']){
                    string rmkey = rm.account__r.rdm_org_Id__c + '#' + rm.Sales_Team_for_Coverage__c;
                    system.debug(rmkey);
                    if(processedKeySet.contains(rmkey)){
                        rm.status__c = 'Recalled';
                        finalcancelRMRequest.add(rm);
                    }                        
                }
                system.debug('finaldeleteRGRequest G** '+ finalcancelRGRequest);
                system.debug('finalcancelRMRequest M ** '+ finalcancelRMRequest);
                if(finalcancelRGRequest.size()>0)
                {
                    system.debug('RG Cancel : '+ finalcancelRGRequest);
                    update finalcancelRGRequest;
                }
                if(finalcancelRMRequest.size()>0)
                {
                    system.debug('RM cancel:' + finalcancelRMRequest);
                    update finalcancelRMRequest;  
                }
            }
            
            
            if(generatedErrorCSVfile!='' && IsError)
            {
                system.debug(generatedErrorCSVfile); 
                if(isCVGTool)
                    bulkManager.emailLog('ERRORS','Attached are the records which have errors.\nPlease rectify and re-submit only these records.\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'User',null,null);
                else
                    bulkManager.emailLog('ERRORS','Attached are the records which have errors.\nPlease rectify and re-upload only these records.\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'User',null,null);
            } 
            /*else
{
system.debug('Successfully uploaded.');
bulkManager.emailLog('SUCCESS','Regards,\nSalesforce Tech',null,'User',null,null);
}*/
            
            //Stopped sending emails as we had provided them with Items to Aprove section
            /*system.debug('UserEmailIds: '+UserEmailIds);
if(UserEmailIds.size()>0) // send Email Template to users about coverage request approval
{ bulkManager.emailLog('SUCCESS','Regards,\nSalesforce Tech',null,'User',null,UserEmailIds);}*/
            
        }
        else
        {
            if(isCVGTool)
                bulkManager.emailLog('FAILURE','There has been an issue processing your coverages.\nSalesforce Tech has been notified of the same.\n\nPlease contact Salesforce Tech for further clarifications.\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'Exception',exception_message+'\n\nRegards,\nSalesforce Tech',null);
            else
                bulkManager.emailLog('FAILURE','There has been an issue processing your bulk upload coverages.\nSalesforce Tech has been notified of the same.\n\nPlease contact Salesforce Tech for further clarifications.\n\nRegards,\nSalesforce Tech',generatedErrorCSVfile,'Exception',exception_message+'\n\nRegards,\nSalesforce Tech',null);
            
        }
        
    } 
    
    Boolean checkIfCoverageExists(Coverage_Temp__c record)
    {
        Set<string> setOfCoverageExist = new  Set<string>();
        for(Coverage_Team_Member__c tm: [SELECT Id,Sales_Team_for_Coverage__c,Account__c FROM Coverage_Team_Member__c where Sales_Team_for_Coverage__c =:record.SalesTeamCoverageId__c and Account__c =:record.accountId__c and End_Date__c = null])
        {
            setOfCoverageExist.add(tm.Sales_Team_for_Coverage__c+':'+tm.Account__c);
        }
        if(setOfCoverageExist.contains(record.SalesTeamCoverageId__c+':'+record.accountId__c))
            return true;
        
        return false;
        
    }
    
    public void addToCSV(List<Coverage_Temp__c> copyOfCSVLines, Integer rowNumber, string errormsg)
    {
        string rgkey = '';
        string rmkey = '';
        string salesCode = '';
        string pGroup = '';
        string pRegion = '';
        string pName = '';
        string role = '';
        string action = '';
        string fromDate = '';
        
        system.debug(copyOfCSVLines);
        system.debug(rowNumber);
        
        
        
        if(copyOfCSVLines[rowNumber].clientRGKey__c == null)
            rgkey = '';
        else
            rgkey = copyOfCSVLines[rowNumber].clientRGKey__c;	
        
        
        if(copyOfCSVLines[rowNumber].clientKey__c == null)
            rmkey = '';
        else
            rmkey = copyOfCSVLines[rowNumber].clientKey__c;
        
        
        if(copyOfCSVLines[rowNumber].salesCode__c == null)
            salesCode = '';
        else
            salesCode = copyOfCSVLines[rowNumber].salesCode__c;	
        
        
        if(copyOfCSVLines[rowNumber].productGroup__c == null)
            pGroup = '';
        else
            pGroup = copyOfCSVLines[rowNumber].productGroup__c;	
        
        if(copyOfCSVLines[rowNumber].productRegion__c == null)
            pRegion = '';
        else
            pRegion = copyOfCSVLines[rowNumber].productRegion__c;	
        
        if(copyOfCSVLines[rowNumber].productName__c == null)
            pName = '';
        else
            pName = copyOfCSVLines[rowNumber].productName__c;	
        
        if(copyOfCSVLines[rowNumber].role__c == null)
            role = '';
        else
            role = copyOfCSVLines[rowNumber].role__c;	
        
        if(copyOfCSVLines[rowNumber].action__c == null)
            action = '';
        else
            action = copyOfCSVLines[rowNumber].action__c;
        
        if(copyOfCSVLines[rowNumber].fromDate__c == null)
            fromDate = '';
        else
            fromDate = String.valueOf(copyOfCSVLines[rowNumber].fromDate__c);		
        
        
        
        generatedErrorCSVfile += '"'+copyOfCSVLines[rowNumber].rowNumber__c+'"'+','+'"'+rgkey+'"'+','+'"'+rmkey+'"'+','+'"'+salesCode+'"'+','+'"'+pGroup+'"'+','+'"'+pRegion+'"'+','+'"'+pName+'"'+','+'"'+role+'"'+','+'"'+action+'"'+','+'"'+fromDate+'"'+','+'"'+ errormsg + '"'+'\n';
        copyOfCSVLines[rowNumber].ErrorText__c = errormsg;
        copyOfCSVLines[rowNumber].hasError__c = true;
        copyOfCSVLines[rowNumber].isProcessed__c = true;
        updateStagingRecords.add(copyOfCSVLines[rowNumber]); 
    }
    
    public void markAsProcessed(List<Coverage_Temp__c> copyOfCSVLines, Integer rowNumber)
    {
        copyOfCSVLines[rowNumber].isProcessed__c = true;
        string rgkey = '';
        string rmkey = '';
        string rmParentKey = '';
        if(copyOfCSVLines[rowNumber].clientRGKey__c == null)
            rgkey = '';
        else
            rgkey = copyOfCSVLines[rowNumber].clientRGKey__c;	
        
        
        if(copyOfCSVLines[rowNumber].clientKey__c == null)
            rmkey = '';
        else{
            rmkey = copyOfCSVLines[rowNumber].clientKey__c;
            rmParentKey = copyOfCSVLines[rowNumber].AccountId__r.Parent.rdm_org_ID__c;
        }
        
        system.debug(copyOfCSVLines[rowNumber].clientRGKey__c);
        system.debug(copyOfCSVLines[rowNumber].clientKey__c);
        system.debug(rgKey);
        system.debug(rmkey);
        
        if(rgkey!='')
            processedKeySet.add(rgkey+'#'+copyOfCSVLines[rowNumber].SalesTeamCoverageId__c );
        if(rmkey!=''){
            processedKeySet.add(rmkey+'#'+copyOfCSVLines[rowNumber].SalesTeamCoverageId__c);
            processedKeySet.add(rmParentKey+'#'+copyOfCSVLines[rowNumber].SalesTeamCoverageId__c);
        }
        
        updateStagingRecords.add(copyOfCSVLines[rowNumber]); 
    }
    
    
    
    void resetValues()
    {
        isRequesterNonApprover = false;
        isRequesterInApproverLevel1 = false;
        isRequesterInApproverLevel2 = false;
        processLevel1 = false;
        processLevel2 = false;
    }
    
    //added for JIRA SALES 1588
    public void processRequest(List<SObject> scope){
        Set<Id> Ids = new Set<Id>();
        Set<String> cancelKeys = new Set<String>();
		String strKey;
        List<Profile> bmProfile = new List<Profile>();
        List<Coverage_Temp__c> copyOfCSVLines_RM = new List<Coverage_Temp__c>();
        List<Coverage_Temp__c> copyOfCSVLines_RG = new List<Coverage_Temp__c>();
        Set<Id> accountIdSet = new Set<Id>();
        updateStagingRecords = new List<Coverage_Temp__c>();
        Map<String,String> urMap =  new Map<String,String>();
        Map<String,String> userDataMap =  new Map<String,String>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        If(!Test.isRunningTest())
            requestorId = UserInfo.getUserId();
        Boolean createTeamMember =false;
        Boolean createAccessRequest =false;
        List<Coverage_Access_Request__c> rmRequest = new List<Coverage_Access_Request__c>();
        List<RG_Coverage_Request__c> rgRequest = new List<RG_Coverage_Request__c>();
        CoverageApprovalFlowUtil utility = new CoverageApprovalFlowUtil();
        SavePoint sp;
        System.debug('restrictedCountries: '+restrictedCountries.size());
        try
        {
            sp = Database.setSavepoint();
            bmProfile = [SELECT Id from Profile WHERE Name LIKE '%Business Management'];
            Ids = (new Map<Id,SObject>(scope)).keySet();
            urMap =  utility.getUserRoleMap();
            Map<string,List<Approver__c>> type_approversMap = new Map<string,List<Approver__c>>();
            for(Approver__c approvers: [SELECT Id, Name, User__c, Region__c,Desk__c,Type__c,Country_Code__c FROM Approver__c 
                                        Where User__r.IsActive = TRUE])
            {
                
                if(approvers.Type__c == null){
                    if(type_approversMap.get('Standard') == null)
                        type_approversMap.put('Standard',new List<Approver__c>{approvers});
                    else
                        type_approversMap.get('Standard').add(approvers);  
                }
                else
                {
                    String[] typeList = approvers.Type__c.split(';');
                    for(string approverType: typeList){
                        if(type_approversMap.get(approverType) == null)
                            type_approversMap.put(approverType,new List<Approver__c>{approvers});
                        else
                            type_approversMap.get(approverType).add(approvers);  
                    }
                }
            }
            
            Set<string> teamCoverageIds = new Set<string>();
            
            
            
            List<Approval_Override__c> approvalOverrides = new List<Approval_Override__c>();
            approvalOverrides = [Select Id, Name, Description__c, Business_Approver_1__c, Business_Approver_2__c,
                                 RecordTypeId,Type__c, Criteria__c, Criteria_Type__c,Manager_Override__c
                                 From Approval_Override__c];
            
            
            //3. Read all group Members for dummy public groups <PublicGroupName, set<UserIds>>
            Map<string, List<Id>> groupMemberMap = CommonTools.getDummySalesCodeGroupMembers();
            system.debug(groupMemberMap);
            
            List<Coverage_Temp__c> tempRecords = [select Id,Type__c,isAttested__c,Sub_Type__c,Is_dummy__c,rowNumber__c,accountId__r.BillingCountry,accountId__r.Domicile_Country__c,Comment__c,del_salesCode__c,Source__c, clientKey__c,ManagerId__c,ErrorText__c,hasError__c,Country__c,SalesTeamCoverageId__c,RoleId__c, clientRGKey__c, TeamMemberId__c, salesCode__c, productGroup__c, productRegion__c, productName__c, role__c, action__c, fromDate__c, SalesDeskDivision__c ,SalesDeskRegion__c,IsRG__c, IsRM__c, accountId__c, GUID__c,IsProcessed__c,AccountId__r.RecordType.Name,AccountId__r.rdm_org_ID__c,AccountId__r.Parent.rdm_org_ID__c,Group_By__c,is_POD_Coverage_Error__c from coverage_Temp__c where Id in:Ids];
            for(Coverage_Temp__c record :tempRecords)
            {
                teamCoverageIds.add(record.SalesTeamCoverageId__c);
                accountIdSet.add(record.accountId__c);
                //added for JIRA SALES 3333
                if(strOpportunityflow.contains(record.Source__c)){
                     strKey = record.accountId__r.rdm_org_ID__c + '#' + record.salesCode__c + '#' +  record.productGroup__c  + '#' + record.productName__c  + '#' + record.productRegion__c ;				
                     cancelKeys.add(strKey);			
                }
            }
            system.debug('cancelKeys **'+ cancelKeys);
            //added for JIRA SALES 3333
            if(cancelKeys.size() > 0){
                processcancelRequest(cancelKeys);
            }
            
            
            if(accountIdSet.size() > 0){
                accountMap = new Map<Id,Account>([
                    SELECT Id, Restricted_Flag__c, BillingCountry,Domicile_Country__c, Closing_Date__c, Active__c FROM Account 
                    WHERE Id IN :accountIdSet
                ]);
                accountMap = (accountMap == null) ? new Map<Id,Account>() : accountMap;
            }
            
            Map<Id,Set<Sales_Team_User__c>> salesCodeUserCountryMap  = new Map<Id,Set<Sales_Team_User__c>>();
            for(Sales_Team_User__c user1: [select Sales_Team_for_Coverage__c, Sales_Team_for_Coverage__r.OwnerId,Sales_Team_for_Coverage__r.is_Split_Sales_Code__c, User__c,Is_User_Active__c,User__r.Country,User__r.CountryCode from Sales_Team_User__c 
                                           where Sales_Team_for_Coverage__c in:teamCoverageIds and Is_User_Active__c =true
                                           and Sales_Team_for_Coverage__r.Active__c=true ]) //and Sales_Team_for_Coverage__r.Is_Country_Same__c = false
            {
                if(salesCodeUserCountryMap.get(user1.Sales_Team_for_Coverage__c) == null)
                    salesCodeUserCountryMap.put(user1.Sales_Team_for_Coverage__c, new Set<Sales_Team_User__c>{user1});
                else
                    salesCodeUserCountryMap.get(user1.Sales_Team_for_Coverage__c).add(user1);
            }
            
            system.debug('salesCodeUserCountryMap: '+salesCodeUserCountryMap);
            string EQ = coverageutil.EQUITY;
            string FI = coverageutil.FIXED_INCOME;
            string IB = coverageutil.INVESTMENT_BANKING;
            for(Coverage_Temp__c record :tempRecords)
            {
                system.debug(record);
				//added check for JIRA 1588
                if(record.Source__c == 'CVGTOOL' || strOpportunityflow.contains(record.Source__c))
                    isCVGTool = true;
                
                ID[] approversList = utility.getApprovers(record.roleId__c,  urMap, bmProfile,'');
                ID[] approvalLevel1 = new ID[]{};
                    ID[] approvalLevel2 = new ID[]{};    
                        
                        //Approval override - business
                        List<UserRole> submitterRoles = new List<UserRole>();
                Map<Id, List<Approval_Override__c>> roleIdToApproverOverrideMap = new Map<Id, List<Approval_Override__c>>();
                submitterRoles = [SELECT Id, Name, DeveloperName 
                                  FROM UserRole 
                                  WHERE Id IN (SELECT UserRoleId FROM User WHERE Id = :record.TeamMemberId__c)];
                if(submitterRoles.size() > 0){
                    system.debug('submitterRoles size: '+submitterRoles.size());
                    
                    for(UserRole ur : submitterRoles){
                        for(Approval_Override__c ao : approvalOverrides){
                            string[] criteria = ao.Criteria__c.split(',');
                            system.debug('criteria: '+criteria);
                            system.debug('Criteria_type__c: '+ao.Criteria_type__c);
                            system.debug('ur.Name: '+ur.Name);
                            if(ao.Type__c == 'Client_Coverage' || ao.Type__c == 'POD_Coverage'){
                                if(criteria.size() == 1){
                                    system.debug(ur.Name.startsWithIgnoreCase(criteria[0].trim()));
                                    system.debug(ur.Name.contains(criteria[0].trim()));
                                    if(ao.Criteria_type__c == 'Role begins with' && (ur.Name.startsWithIgnoreCase(criteria[0].trim()) == true)){
                                        if(roleIdToApproverOverrideMap.get(ur.Id) != null){
                                            List<Approval_Override__c> approvalOverrideList = roleIdToApproverOverrideMap.get(ur.Id);
                                            approvalOverrideList.add(ao);
                                            roleIdToApproverOverrideMap.put(ur.Id, approvalOverrideList);
                                        }else{
                                            roleIdToApproverOverrideMap.put(ur.Id, new List<Approval_Override__c>{ao});
                                        }                                            
                                        system.debug(roleIdToApproverOverrideMap);                                        
                                    }
                                    if(ao.Criteria_type__c == 'Role contains' && (ur.Name.contains(criteria[0].trim()) == true)){
                                        if(roleIdToApproverOverrideMap.get(ur.Id) != null){
                                            List<Approval_Override__c> approvalOverrideList = roleIdToApproverOverrideMap.get(ur.Id);
                                            approvalOverrideList.add(ao);
                                            roleIdToApproverOverrideMap.put(ur.Id, approvalOverrideList);
                                        }else{
                                            roleIdToApproverOverrideMap.put(ur.Id, new List<Approval_Override__c>{ao});
                                        }
                                        system.debug(roleIdToApproverOverrideMap);                                        
                                    }    
                                }
                                else if(criteria.size() > 1){
                                    boolean conditionSatisfied = true;
                                    for(string condition:criteria){
                                        system.debug('ur.Name.startsWithIgnoreCase(condition.trim()): '+ur.Name.startsWithIgnoreCase(condition.trim()));
                                        system.debug('ur.Name.contains(condition.trim()): '+ur.Name.contains(condition.trim()));
                                        system.debug('condition: '+condition);
                                        if(ao.Criteria_type__c == 'Role begins with'){
                                            if(!(ur.Name.startsWithIgnoreCase(condition.trim()))){
                                                system.debug('1.');
                                                conditionSatisfied = false;
                                            }
                                        }
                                        if(ao.Criteria_type__c == 'Role contains'){
                                            if(!(ur.Name.contains(condition.trim()))){
                                                system.debug('2.');
                                                conditionSatisfied = false;
                                            }  
                                        }
                                        
                                        
                                        system.debug('conditionSatisfied: '+conditionSatisfied);
                                        
                                    }
                                    system.debug('ao.Criteria_type__c: '+ao.Criteria_type__c);
                                    system.debug('conditionSatisfied: '+conditionSatisfied);
                                    if(conditionSatisfied){
                                        if(roleIdToApproverOverrideMap.get(ur.Id) != null){
                                            List<Approval_Override__c> approvalOverrideList = roleIdToApproverOverrideMap.get(ur.Id);
                                            approvalOverrideList.add(ao);
                                            roleIdToApproverOverrideMap.put(ur.Id, approvalOverrideList);
                                        }else{
                                            roleIdToApproverOverrideMap.put(ur.Id, new List<Approval_Override__c>{ao});
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                }
                
                List<Approval_Override__c> approvalOverrideList = new List<Approval_Override__c>();
                Id ownerRoleId = record.RoleId__c; 
                system.debug('approvers');
                Id bmApproverID;
                system.debug('bmApproverID: '+bmApproverID);
                system.debug(approversList);
                system.debug('requestorId: '+requestorId);
                for(Id s1 : approversList)
                {
                    if(s1 == requestorId)
                    {
                        bmApproverID = s1;
                        break;
                    }
                }
                string req_region = '';
                string req_division = ''; 
                string currentUser_publicGroup_dummy = '';
                if(record.SalesDeskDivision__c!=null)
                    req_division = record.SalesDeskDivision__c;
                if(record.SalesDeskRegion__c!=null)
                    req_region = record.SalesDeskRegion__c;
                 
                
                if(req_division.toLowerCase() == EQ.toLowerCase())
                    currentUser_publicGroup_dummy = req_region.toUpperCase()+'_EQ_NON_SF_COVERAGE_APPROVERS';
                else if(req_division.toLowerCase() == FI.toLowerCase())
                    currentUser_publicGroup_dummy = req_region.toUpperCase()+'_FI_NON_SF_COVERAGE_APPROVERS';
                else if(req_division.toLowerCase() == IB.toLowerCase())
                    currentUser_publicGroup_dummy = req_region.toUpperCase()+'_IB_NON_SF_COVERAGE_APPROVERS';
                
                //commented for error JIRA 1588
                //system.debug('currentUser_publicGroup_dummy: '+currentUser_publicGroup_dummy);
                //system.debug('groupMemberMap contains: '+groupMemberMap.get(currentUser_publicGroup_dummy).contains(requestorId));  
                //system.debug('groupMemberMap size: '+groupMemberMap.get(currentUser_publicGroup_dummy).size());  
                
                if(record.IsRG__c)
                { 
                    Boolean hasUserManagerId = false;
                    
                    if(!record.is_Dummy__c )
                    {
                        if(record.Managerid__c != null)
                        {
                            approvalLevel1.add(record.Managerid__c); //1
                            hasUserManagerId = true;
                        }
                    }
                    
                    if(record.is_Dummy__c && groupMemberMap.get(currentUser_publicGroup_dummy)!=null)
                    {
                        if(groupMemberMap.get(currentUser_publicGroup_dummy).contains(requestorId) && groupMemberMap.size() >=1){
                            approvalLevel1.add(groupMemberMap.get(currentUser_publicGroup_dummy)[0]);
                            approvalLevel1.add(requestorId);
                            approvalLevel1.add(groupMemberMap.get(currentUser_publicGroup_dummy)[0]);
                        }
                        else if(!(groupMemberMap.get(currentUser_publicGroup_dummy).contains(requestorId)) && groupMemberMap.size() >=1){
                            if(groupMemberMap.get(currentUser_publicGroup_dummy).size()==1)
                            {
                                approvalLevel1.add(groupMemberMap.get(currentUser_publicGroup_dummy)[0]);
                                approvalLevel1.add(groupMemberMap.get(currentUser_publicGroup_dummy)[0]);
                                approvalLevel1.add(groupMemberMap.get(currentUser_publicGroup_dummy)[0]);
                            }
                            else if(groupMemberMap.get(currentUser_publicGroup_dummy).size()==2)
                            {
                                approvalLevel1.add(groupMemberMap.get(currentUser_publicGroup_dummy)[0]);
                                approvalLevel1.add(groupMemberMap.get(currentUser_publicGroup_dummy)[1]);
                                approvalLevel1.add(groupMemberMap.get(currentUser_publicGroup_dummy)[1]);
                            }
                            else if(groupMemberMap.get(currentUser_publicGroup_dummy).size()==3){
                                approvalLevel1.add(groupMemberMap.get(currentUser_publicGroup_dummy)[0]);
                                approvalLevel1.add(groupMemberMap.get(currentUser_publicGroup_dummy)[1]);
                                approvalLevel1.add(groupMemberMap.get(currentUser_publicGroup_dummy)[2]);
                            }
                        }
                    }
                    else
                    {
                        if(roleIdToApproverOverrideMap.containsKey(ownerRoleId)){ // && (bmApproverID == '')
                            approvalOverrideList = roleIdToApproverOverrideMap.get(ownerRoleId);
                            for(Approval_Override__c approvalOverride : approvalOverrideList){
                                if('POD' != record.Group_By__c && 'Client_Coverage' == approvalOverride.Type__c){
                                    if(approvalOverride.Manager_Override__c  && record.Source__c!='Cross Sell Referral')
                                    {
                                        if(hasUserManagerId)
                                        { 
                                            Integer index = approvalLevel1.indexOf(record.Managerid__c);
                                            approvalLevel1.remove(index);
                                        }
                                        approvalLevel1.add(approvalOverride.Business_Approver_1__c);  
                                    }
                                    approvalLevel1.add(approvalOverride.Business_Approver_1__c); //2
                                    approvalLevel1.add(approvalOverride.Business_Approver_2__c); //3
                                }
                            }                            
                        }
                        else
                        {
                            if(approversList.size() >= 2){
                                if(bmApproverID!=null)
                                {
                                    approvalLevel1.add(requestorId);
                                }
                                else
                                {
                                    approvalLevel1.add(approversList[0]); //2
                                }
                                approvalLevel1.add(approversList[1]); //3
                                if(!hasUserManagerId)
                                {
                                    approvalLevel1.add(approversList[1]); //1
                                }
                            }
                            else if(approversList.size() == 1){
                                if(approversList[0] == bmApproverID)
                                { approvalLevel1.add(bmApproverID); }//2
                                else
                                {approvalLevel1.add(approversList[0]);} //2
                                
                                approvalLevel1.add(approversList[0]); //3  
                                if(!hasUserManagerId)
                                {
                                    approvalLevel1.add(approversList[0]); //1 
                                }
                            } 
                            
                        }
                    }
                    
                    
                    Set<Id> level1Users = new Set<Id>();
                    level1Users.addAll(approvalLevel1);
                    
                    if(level1Users.contains(requestorId))
                        isRequesterInApproverLevel1 = true;
                    else
                        isRequesterInApproverLevel1 = false;
                    
                    if(isRequesterInApproverLevel1)
                        isRequesterNonApprover = false;
                    else
                        isRequesterNonApprover = true;
                    
                    if(!isRequesterNonApprover) //if requestor is approver
                    {  
                        processLevel1 = false;
                        processLevel2 = false;
                        createTeamMember = true;
                        createAccessRequest = true;
                    }
                    else
                    {
                        createAccessRequest = true;
                        createTeamMember = false;
                        processLevel1 = true;
                        processLevel2 = false;
                    }
                }
                
                
                if(record.IsRM__c) //Check if requestor is in approval level 1 / approval level 2
                {
                    Boolean secondlevelapproval = false;
                    Boolean hasUserManagerId = false;
                    Account accntCvgReq =accountMap.get(record.accountId__c);
                    system.debug(roleIdToApproverOverrideMap);
                    system.debug(ownerRoleId);
                    
                        /******************** Approval level  1 (RMApprover1,RMApprover2,RMApprover3)************************************/
                        system.debug('bmApproverID (batch): '+bmApproverID);
                        system.debug('ownerRoleId batch: '+roleIdToApproverOverrideMap.containsKey(ownerRoleId));
                        system.debug('ownerRoleId batch: '+ownerRoleId);
                        if(!record.is_Dummy__c )
                        {
                            if(record.Managerid__c != null)
                            {
                                approvalLevel1.add(record.Managerid__c); //1
                                hasUserManagerId = true;
                            }
                        }
                        if(record.is_Dummy__c && groupMemberMap.get(currentUser_publicGroup_dummy)!=null)
                        {
                            if(groupMemberMap.get(currentUser_publicGroup_dummy).contains(requestorId) && groupMemberMap.size() >=1){
                                approvalLevel1.add(groupMemberMap.get(currentUser_publicGroup_dummy)[0]);
                                approvalLevel1.add(requestorId);
                                approvalLevel1.add(groupMemberMap.get(currentUser_publicGroup_dummy)[0]);
                            }
                            else if(!(groupMemberMap.get(currentUser_publicGroup_dummy).contains(requestorId)) && groupMemberMap.size() >=1){
                                if(groupMemberMap.get(currentUser_publicGroup_dummy).size()==1)
                                {
                                    approvalLevel1.add(groupMemberMap.get(currentUser_publicGroup_dummy)[0]);
                                    approvalLevel1.add(groupMemberMap.get(currentUser_publicGroup_dummy)[0]);
                                    approvalLevel1.add(groupMemberMap.get(currentUser_publicGroup_dummy)[0]);
                                }
                                else if(groupMemberMap.get(currentUser_publicGroup_dummy).size()==2)
                                {
                                    approvalLevel1.add(groupMemberMap.get(currentUser_publicGroup_dummy)[0]);
                                    approvalLevel1.add(groupMemberMap.get(currentUser_publicGroup_dummy)[1]);
                                    approvalLevel1.add(groupMemberMap.get(currentUser_publicGroup_dummy)[1]);
                                }
                                else if(groupMemberMap.get(currentUser_publicGroup_dummy).size()==3){
                                    approvalLevel1.add(groupMemberMap.get(currentUser_publicGroup_dummy)[0]);
                                    approvalLevel1.add(groupMemberMap.get(currentUser_publicGroup_dummy)[1]);
                                    approvalLevel1.add(groupMemberMap.get(currentUser_publicGroup_dummy)[2]);
                                }
                            }
                        }
                        else{
                            if(roleIdToApproverOverrideMap.containsKey(ownerRoleId)){// && (bmApproverID == '')
                                approvalOverrideList = roleIdToApproverOverrideMap.get(ownerRoleId);
                                system.debug('approvalOverrideList: '+approvalOverrideList);
                                for(Approval_Override__c approvalOverride : approvalOverrideList){
                                    system.debug(approvalOverride);
                                    if('POD' != record.Group_By__c && 'Client_Coverage' == approvalOverride.Type__c){
                                        if(approvalOverride.Manager_Override__c  && record.Source__c!='Cross Sell Referral')
                                        {
                                            if(hasUserManagerId)
                                            { 
                                                Integer index = approvalLevel1.indexOf(record.Managerid__c);
                                                approvalLevel1.remove(index);
                                            }
                                            approvalLevel1.add(approvalOverride.Business_Approver_1__c);  
                                        }
                                        approvalLevel1.add(approvalOverride.Business_Approver_1__c); //2
                                        approvalLevel1.add(approvalOverride.Business_Approver_2__c); //3
                                    }else if('POD' == record.Group_By__c && 'POD_Coverage' == approvalOverride.Type__c){
                                        if(approvalOverride.Manager_Override__c  && record.Source__c!='Cross Sell Referral')
                                        {
                                            if(hasUserManagerId)
                                            { 
                                                Integer index = approvalLevel1.indexOf(record.Managerid__c);
                                                approvalLevel1.remove(index);
                                            }
                                            approvalLevel1.add(approvalOverride.Business_Approver_1__c);  
                                        }
                                        approvalLevel1.add(approvalOverride.Business_Approver_1__c); //2
                                        approvalLevel1.add(approvalOverride.Business_Approver_2__c); //3
                                    }
                                }
                            }
                            else
                            {
                                
                                if(approversList.size() >= 2){
                                    if(bmApproverID!=null)
                                    {
                                        approvalLevel1.add(requestorId);
                                    }
                                    else
                                    {approvalLevel1.add(approversList[0]);} //2
                                    
                                    approvalLevel1.add(approversList[1]); //3
                                    if(!hasUserManagerId)
                                    {
                                        approvalLevel1.add(approversList[1]); //1
                                    }
                                }
                                else if(approversList.size() == 1){
                                    if(approversList[0] == bmApproverID)
                                    {approvalLevel1.add(requestorId);} //2
                                    else
                                    {approvalLevel1.add(approversList[0]);} //2
                                    
                                    approvalLevel1.add(approversList[0]);  //3 
                                    if(!hasUserManagerId)
                                    {
                                        approvalLevel1.add(approversList[0]);// 1
                                    }
                                }
                                
                                
                                
                            }
                            
                        }

                    if((accntCvgReq.Restricted_Flag__c && string.isNotEmpty(string.valueOf(accntCvgReq.Domicile_Country__c))) || (record.Type__c != null && record.Type__c !='Standard' && record.Type__c != 'Cross Sell Referral')){
                        
                        List<Approver__c> secondlevel_approvers = new List<Approver__c>();
                        if(type_approversMap.get(record.Type__c)!=null)
                            secondlevel_approvers = type_approversMap.get(record.Type__c);
                        
                        
                        
                        /******************** Approval level  2 (RMApprover4,RMApprover5,RMApprover6, RMApprover7,RMApprover8,RMApprover9)************************************/
                        if((accntCvgReq.Domicile_Country__c == record.Country__c || checkIfCoverageExists(record)) && (record.Type__c == 'Standard' || record.Type__c=='Cross Sell')){                   
                            if(!hasUserManagerId){
                                if(approversList.size() >= 2){
                                    approvalLevel2.add(approversList[1]); 
                                    approvalLevel2.add(approversList[1]); 
                                }
                                else if(approversList.size() == 1){
                                    approvalLevel2.add(approversList[0]); 
                                    approvalLevel2.add(approversList[0]); 
                                }
                            }
                            else
                            {
                                approvalLevel2.add(record.Managerid__c); //4
                                approvalLevel2.add(record.Managerid__c); //5
                            }
                            
                        }
                        else
                        {
                            //accessRequest.Is_Second_Level_Approval_Needed__c = true;
                            secondlevelapproval = true;
                            ID[] restrctApprovers = new ID[]{}; 
                                for(Approver__c appr : secondlevel_approvers){
                                    if(appr.Desk__c == record.SalesDeskDivision__c && appr.Country_Code__c == accntCvgReq.Domicile_Country__c){
                                        restrctApprovers.add(appr.User__c);
                                    }
                                }
                            
                            if(restrctApprovers.size()>0)
                            {
                                if(restrctApprovers.size() >= 2 )
                                {
                                    approvalLevel2.add(restrctApprovers[0]); 
                                    if(!Test.isRunningTest())
                                        approvalLevel2.add(restrctApprovers[1]); 
                                    
                                }
                                if(restrctApprovers.size() ==1)
                                {
                                    approvalLevel2.add(restrctApprovers[0]); 
                                    if(!Test.isRunningTest())
                                        approvalLevel2.add(restrctApprovers[0]); 
                                }
                            } 
                        }     
                        
                        
                    }
                    
                    Boolean isRMRestricted = (accntCvgReq.Restricted_Flag__c) ? true:false;
                    Boolean userCountrySameasAccount = (accntCvgReq.Domicile_Country__c == record.Country__c || checkIfCoverageExists(record)) ? true : false;
                    
                    
                    system.debug('approvalLevel1: ' + approvalLevel1);
                    system.debug('approvalLevel2: ' + approvalLevel2);
                    system.debug('secondlevelapproval: ' + secondlevelapproval);
                    
                    
                    Set<Id> level1Users = new Set<Id>();
                    level1Users.addAll(approvalLevel1);
                    
                    Set<Id> level2Users = new Set<Id>();
                    if(secondlevelapproval)
                        level2Users.addAll(approvalLevel2);
                    
                    system.debug('requestorId: ' + requestorId);    
                    system.debug('level1Users: ' + level1Users);
                    system.debug('level2Users: ' + level2Users);
                    
                    system.debug(level1Users);
                    system.debug(level2Users);
                    
                    
                    if(level1Users.contains(requestorId))
                        isRequesterInApproverLevel1 = true;
                    
                    if(level2Users.contains(requestorId))
                        isRequesterInApproverLevel2 = true;
                    
                    system.debug(isRequesterInApproverLevel1);
                    system.debug(isRequesterInApproverLevel2);
                    
                    system.debug('isRequesterInApproverLevel1: ' + isRequesterInApproverLevel1);
                    system.debug('isRequesterInApproverLevel2: ' + isRequesterInApproverLevel2);
                    
                    if(isRequesterInApproverLevel1 || isRequesterInApproverLevel2)
                        isRequesterNonApprover = false;
                    else
                        isRequesterNonApprover = true;
                    
                    system.debug('isRequester Approver: ' + !isRequesterNonApprover);    
                    if(!isRequesterNonApprover) //if requestor is approver
                    {  
                        if(!isRMRestricted && record.Type__c !='Standard' && (isRequesterInApproverLevel1 || isRequesterInApproverLevel2)) //Step 2 & 3
                        {
                            createTeamMember = true;
                            createAccessRequest = true;
                            if(isRequesterInApproverLevel1)
                            {
                                processLevel1 = false;
                                processLevel2 = true;
                            }
                            
                            if(isRequesterInApproverLevel2)
                             {
                                processLevel1 = false;
                                processLevel2 = false;
                            }
                        }
                        
                         if(!isRMRestricted && record.Type__c =='Standard' && (isRequesterInApproverLevel1 || isRequesterInApproverLevel2)) //Step 2 & 3
                        {
                            createTeamMember = true;
                            createAccessRequest = true;
                            processLevel1 = false;
                            processLevel2 = false;
                        }
                        
                        if(isRMRestricted && userCountrySameasAccount && isRequesterInApproverLevel1) //Step 5
                        {
                            createTeamMember = true;
                            createAccessRequest = true;
                            processLevel1 = false;
                            processLevel2 = false;
                        }
                        
                        if(isRMRestricted && userCountrySameasAccount && isRequesterInApproverLevel2) //Step 6
                        {
                            createTeamMember = true;
                            createAccessRequest = true;
                            processLevel1 = false;
                            processLevel2 = false;
                        }
                        
                        if(isRMRestricted && !userCountrySameasAccount && isRequesterInApproverLevel1) //Step 8
                        {
                            createTeamMember = false;
                            createAccessRequest = true;
                            processLevel1 = false;
                            processLevel2 = true;
                        }
                        
                        if(isRMRestricted && !userCountrySameasAccount && ((isRequesterInApproverLevel1 && isRequesterInApproverLevel2) || isRequesterInApproverLevel2)) //Step 9
                        {
                            createTeamMember = true;
                            createAccessRequest = true;
                            processLevel1 = false;
                            processLevel2 = false;
                        }
                        
                    }
                    else ////if requestor is not approver
                    {
                        createAccessRequest = true;
                        processLevel1 = true;
                        processLevel2 = false;
                        createTeamMember = false;
                    }
                }
                
                system.debug('createAccessRequest: '+createAccessRequest);
                system.debug('createTeamMember: '+createTeamMember);
                system.debug('processLevel1: '+processLevel1);
                system.debug('processLevel2: '+processLevel2);   
                
                //Step 1: Prepare Mapping of AccessRequest
                utility.createAccessRequest(record,rmRequest,rgRequest,createTeamMember,processLevel1,processLevel2,copyOfCSVLines_RM,copyOfCSVLines_RG,restrictedCountries,salesCodeUserCountryMap); 
                
                
            }
            
            Set<Id> insertedRM = new Set<Id>();
            Set<Id> insertedRg = new Set<Id>();
            
            system.debug('copyOfCSVLines_RM'+copyOfCSVLines_RM.size());
            system.debug('copyOfCSVLines_RG'+copyOfCSVLines_RG.size());
            system.debug('copyOfCSVLines_RM'+copyOfCSVLines_RM);
            system.debug('copyOfCSVLines_RG'+copyOfCSVLines_RG);
            
            
            
            //Step 2: Insert
            if(rmRequest.size()>0)
            {
                Database.SaveResult[] results = Database.insert(rmRequest, false);
                Integer rowNumber = 0;
                
                for(Database.SaveResult sr : results)
                {
                    if(!sr.isSuccess())
                    {
                        string errormsg = '';
                        for(Database.Error err : sr.getErrors()) {
                            system.debug('EROR: '+err.getMessage());
                            errormsg = err.getMessage()+'.'; 
                        }
                        IsError = true;
                        addToCSV(copyOfCSVLines_RM, rowNumber, errormsg);     
                    }
                    else
                    {
                        system.debug('Successfully inserted: '+sr.getId());
                        markAsProcessed(copyOfCSVLines_RM, rowNumber);
                        insertedRM.add(sr.getId());  
                    }
                    rowNumber++;
                }
                
                
                
                
                //Inserted Ids
                
            }
            if(rgRequest.size()>0)
            {
                Database.SaveResult[] results = Database.insert(rgRequest, false);
                Integer rowNumber = 0;
                for(Database.SaveResult sr : results)
                {
                    if(!sr.isSuccess())
                    {
                        string errormsg = '';
                        for(Database.Error err : sr.getErrors()) {
                            system.debug('EROR: '+err.getMessage());
                            errormsg = err.getMessage()+'.'; 
                        }
                        IsError = true;
                        addToCSV(copyOfCSVLines_RG, rowNumber, errormsg);    
                    }
                    else
                    {
                        system.debug('Success fully inserted: '+sr.getId());
                        markAsProcessed(copyOfCSVLines_RG, rowNumber);
                        insertedRg.add(sr.getId());
                        
                    }
                    rowNumber++;
                }
                
                
            }
            //added call to function for JIRA SALES 1588
            if(insertedRM.size()>0 || insertedRG.size()>0){
                utility.processApprovalRequest(insertedRM,insertedRG,UserEmailIds); //e.g. pass 1
                processdeleteRequest(tempRecords,accountMap);                              
            }
            system.debug('SetIDsExisting ***' + SetIDsExisting);
            
            if(updateStagingRecords.size()>0)
            {
                update updateStagingRecords;
            }
            
            /*if(Test.isRunningTest() && updateStagingRecords.size() > 0)
{
addToCSV(updateStagingRecords, 1, 'Test msg');
addErrorneousRecord(updateStagingRecords[0]);
}*/
            
            resetValues(); //reset values 
            
            /*if(test.isRunningTest())
{Decimal a = 2/0;}*/
        }
        catch(Exception e)
        {
            exception_message += e+'\n'+e.getStackTraceString();
            exception_message += '\n';
            batchExecutionSuccessfully = false;
            system.debug('Exception '+exception_message);
            // if(sp!=null)
            //  Database.rollback(sp);
            //system.abortJob(info.getJobId());
        }
    }
    //added for JIRA SALES 1588
    public void processdeleteRequest(List<Coverage_Temp__c> CoverageTempList, Map<Id,Account> accountMap){
      String strKey = '';	
      deleteRMRequestCondition = deleteRMRequestCondition;
      for(Coverage_Temp__c record :CoverageTempList){
          strKey = '';
          if(record.IsRG__c){
            deleteRMRequestCondition += ' OR (Account__r.Parent.rdm_org_ID__c = \'' + record.accountId__r.rdm_org_ID__c + '\' AND ' +
                            'Sales_Team_for_coverage__r.Coverage_Id__c = \'' + record.salesCode__c + '\' AND ' + 
                            'Product_Group__c = \'\' AND Product_Region__c = \'\' AND Product2__c = \'\' AND Account__r.Restricted_Flag__c = FALSE AND Account__r.RecordType.DeveloperName = \'RM_Account\')';
            if(record.productname__c != NULL && record.productname__c != ''){
                deleteRMRequestCondition += ' OR (Account__r.Parent.rdm_org_ID__c = \'' + record.accountId__r.rdm_org_ID__c + '\' AND ' +
                                'Sales_Team_for_coverage__r.Coverage_Id__c = \'' + record.salesCode__c + '\' AND ' + 
                                'Product_Group__c = \'' + record.productGroup__c + '\' AND ' + 
                                'Product_Region__c = \'' + record.productRegion__c + '\' AND ' + 
                                'Product2__c = \'' + record.productName__c + '\' AND Account__r.Restricted_Flag__c = FALSE AND Account__r.RecordType.DeveloperName = \'RM_Account\')';

                deleteRMRequestCondition += ' OR (Account__r.Parent.rdm_org_ID__c = \'' + record.accountId__r.rdm_org_ID__c + '\' AND ' +
                                'Sales_Team_for_coverage__r.Coverage_Id__c = \'' + record.salesCode__c + '\' AND ' + 
                                'Product_Group__c = \'\' AND Product_Region__c = \'\' AND Product2__c = \'\' AND Account__r.Restricted_Flag__c = TRUE AND Group_By__c = \'RG\' AND Account__r.RecordType.DeveloperName = \'RM_Account\')';
            }
          }
          if(record.productname__c != NULL && record.productname__c != ''){
            strKey = record.accountId__r.rdm_org_ID__c;
            strKey +=  '#' + record.salesCode__c + '###';		
            delKeys.add(strKey);	

            /* Add RM's Parent Key to delete without product record from RG_Coverage_Request when an entry with product is made in Coverage_Access_Request for unrestrcited Account */
            Account account =accountMap.get(record.accountId__c);
            if(record.Group_By__c.toLowerCase() == 'rm' && account.Restricted_Flag__c == false){
                strKey = record.AccountId__r.Parent.rdm_org_ID__c;
                strKey +=  '#' + record.salesCode__c + '###';
                delKeys.add(strKey);
                deleteRMRequestCondition += ' OR (Account__r.Parent.rdm_org_ID__c = \'' + record.accountId__r.Parent.rdm_org_ID__c + '\' AND ' +
                                'Sales_Team_for_coverage__r.Coverage_Id__c = \'' + record.salesCode__c + '\' AND ' + 
                                'Product_Group__c = \'\' AND Product_Region__c = \'\' AND Product2__c = \'\' AND Account__r.Restricted_Flag__c = TRUE AND Group_By__c = \'RG\')';
            }
          }
      }
      system.debug('delKeys **'+delKeys);   
      system.debug('deleteRMRequestCondition** '+deleteRMRequestCondition); 
    }
    //added for JIRA SALES 3333
    public void processcancelRequest(Set<String> cancelKeys){
       for(RG_Coverage_Request__c rg: [select id,SourceUpload__c,Sales_Team_for_Coverage__c,RG_Account__r.rdm_org_ID__c,UniqueID__c,Status__c from RG_Coverage_Request__c where UniqueID__c in:cancelKeys and status__c='Pending Approval' ]){
            SetIDsExisting.add(rg.Id);
       }
       for(Coverage_Access_Request__c rm: [select id,SourceUpload__c,Sales_Team_for_Coverage__c,Account__r.rdm_org_ID__c,UniqueID__c,Status__c  from Coverage_Access_Request__c where UniqueID__c in:cancelKeys and status__c='Pending Approval']){
          SetIDsExisting.add(rm.Id);
      }          
    } 
    
}