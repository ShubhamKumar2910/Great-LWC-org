global class DeactivateCoverageBatchJob implements Database.batchable<sObject>, Database.Stateful{
    
    public string query{get;set;}
    private String exception_message = '';
    private Boolean IsError = false;
    private Boolean batchExecutionSuccessfully = true;
    //SALES-3653 for Reason for Coverege deletion
	String strReason = 'Coverage Deactivation';
    List<string> salescode_company_to_exclude = CoverageUtil.salescode_company_to_exclude;		
    List<string> productsaccessforInstinet = CoverageUtil.productsWithRegionsToIncludeForInstinet;    
    
    global DeactivateCoverageBatchJob()
    { 
        if(Test.isRunningTest())
            query = 'select id from Coverage_Team_Member__c limit 1';
        else //Updated Query for SALES-3693
            query = 'select id from Coverage_Team_Member__c where (Sales_Team_for_Coverage__r.Active__c = false or Account__r.Active__c = false) and RecordType.DeveloperName = \'Active_Coverage\' and Account__r.RecordType.DeveloperName = \'RM_Account\'';
        
       // query = 'select id from Coverage_Team_Member__c where Account__r.rdm_org_ID__c = \'RM255049\' and RecordType.Name = \'Active Coverage\'';
     
        system.debug(query);
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }  
    
    
    global void execute(Database.batchableContext info, List<sObject> scope){
        SavePoint sp;
        Set<Id> Ids = new Set<Id>();
        Set<Id> salesCodeTeamIds = new Set<Id>();
        List<Coverage_Team_Member__c> coverageToUpdate = new List<Coverage_Team_Member__c>();
        List<Coverage_Team_Member__c> existingDeletecoverageToUpdate = new List<Coverage_Team_Member__c>();
        Set<String> accountAndTeamMemberSet = new Set<String>();
        Set<String> uniqueKeys = new Set<String>();
        Id InactiveCoverageRecordTypeId = CommonTools.getRecordTypeId('Coverage_Team_Member__c', 'Inactive Coverage');
		        
        try
        {
            Ids = (new Map<Id,SObject>(scope)).keySet();
            for(Coverage_Team_Member__c coverage :[select Id,End_Date__c,
                                                   Is_Deleted__c,UniqueId__c,
                                                   Sales_Team_for_Coverage__r.Active__c,
                                                   Sales_Team_for_Coverage__r.Owner_Active__c,
                                                   Reason__c,Account__r.Active__c,Account__r.Closing_Date__c
                                                   from Coverage_Team_Member__c where Id in:Ids])
            {
                if(coverage.UniqueId__c!=null)                
                {
                    //SALES-3693
                    if(coverage.Account__r.Active__c != true && coverage.Account__r.Closing_Date__c != null){
                        coverage.End_Date__c = CommonTools.convertStringToDate(coverage.Account__r.Closing_Date__c);
                        //SALES-3653 Set the reason value
						coverage.Reason__c = strReason;
                    }
                    else{
                        coverage.End_Date__c = system.today();
                    }                    
                    coverage.Is_Deleted__c = true;    
                    coverage.UniqueId__c = string.valueOf(coverage.UniqueId__c).replace('FALSE','TRUE'); 
                    coverage.RecordTypeId = InactiveCoverageRecordTypeId;
                    system.debug(InactiveCoverageRecordTypeId);
                    //coverage.Sales_Team_for_Coverage__r.Active__c = false;
                    //if(coverage.Sales_Team_for_Coverage__r.Active__c)
                    //salesCodeTeamIds.add(coverage.Sales_Team_for_Coverage__c);
                    uniqueKeys.add(coverage.UniqueId__c);
                    coverageToUpdate.add(coverage);
                }
            }
            
            if(uniqueKeys.size() > 0)
            {
                List<Coverage_Team_Member__c> alreadyDeletedCoverages = [SELECT Id,UniqueID__c FROM Coverage_Team_Member__c
                                                                         WHERE UniqueID__c IN: uniqueKeys];
                if(alreadyDeletedCoverages.size() >0){
                    for(Coverage_Team_Member__c existingDeletedOnes : alreadyDeletedCoverages){
                        existingDeletedOnes.UniqueId__c = existingDeletedOnes.UniqueId__c.Replace('TRUE','PREVDELETE')+'#'+ existingDeletedOnes.Id ;
                        existingDeletecoverageToUpdate.add(existingDeletedOnes);
                    }
                }
            }
             
            if(existingDeletecoverageToUpdate.size() > 0)
            {
                Database.SaveResult[] results = Database.update(existingDeletecoverageToUpdate, false);
                for(Database.SaveResult sr : results)
                {
                    if(!sr.isSuccess())
                    {
                        string errormsg = '';
                        for(Database.Error err : sr.getErrors()) {
                            errormsg = err.getMessage()+'.'; 
                        }
                        IsError = true;
                    }
                    
                }
            }
            
            system.debug('isError: '+isError);
            system.debug('coverageToUpdate: '+coverageToUpdate.size());
            
            if(!IsError && coverageToUpdate.size() > 0)
            {
                update coverageToUpdate;
            }   
            
        }
        
        catch(Exception e)
        {
            exception_message += e+'\n'+e.getStackTraceString();
            exception_message += '\n';
            batchExecutionSuccessfully = false;
            system.debug('Exception '+exception_message);
            if(sp!=null)
                Database.rollback(sp);
            system.abortJob(info.getJobId());
        }
    }
    
    global void finish(Database.batchableContext info){
        CoverageBulkUploadUtility bulkManager = new CoverageBulkUploadUtility();
        
        if(exception_message!=null && exception_message!='')
        {
            system.debug(LoggingLevel.WARN,'Batch Status: ERROR');
            system.debug(exception_message);
            emailLog('FAILURE','There has been an issue deactivating coverages.\nSalesforce Tech has been notified of the same.\n\nPlease contact Salesforce Tech for further clarifications.\n\nRegards,\nSalesforce Tech',null,'Exception',exception_message+'\n\nRegards,\nSalesforce Tech',null);
        }
        else
        {
            if(batchExecutionSuccessfully && !isError)
            {
                system.debug(LoggingLevel.WARN,'Batch Status: SUCCESS');
            }
        }
        
        deleteOutStandingRequest();
        
    }
    
    public void deleteOutStandingRequest(){
    	List<RG_Coverage_Request__c> rgRequest = [select id from RG_Coverage_Request__c where (RG_Account__r.Active__c = false or Sales_Team_for_Coverage__r.Active__c = false)];
        if(rgRequest.size() > 0)
            delete rgRequest;
        
        List<Coverage_Access_Request__c> rmRequest = [select id from Coverage_Access_Request__c where (Account__r.Active__c = false or Sales_Team_for_Coverage__r.Active__c = false)];
        if(rmRequest.size() > 0)
            delete rmRequest;
        
         /*Set<Id> cancelRequestIds = new Set<Id>();
        Set<Id> rgRequestIds = new Map<Id,RG_Coverage_Request__c>([select id from RG_Coverage_Request__c where (RG_Account__r.Active__c = false or Sales_Team_for_Coverage__r.Active__c = false) and status__c = 'Pending Approval']).keyset();
        
        Set<Id> rmRequestIds = new Map<Id,Coverage_Access_Request__c>([select id from Coverage_Access_Request__c where (Account__r.Active__c = false or Sales_Team_for_Coverage__r.Active__c = false) and status__c = 'Pending Approval']).keyset();
        
        if(rgRequestIds.size()>0)
            cancelRequestIds.addAll(rgRequestIds);
        
        if(rmRequestIds.size()>0)
            cancelRequestIds.addAll(rmRequestIds);
        
        if(cancelRequestIds.size()>0)
        {
            List<ProcessInstanceWorkItem> pinstanceWkItm = [Select ID, ProcessInstanceId, Isdeleted,processInstance.TargetObject.Id,OriginalActorId from processinstanceWorkitem where processInstance.TargetObject.Id IN :cancelRequestIds];
            List<Id> workitemsToReject = new List<Id>();
            if(pinstanceWkItm.size() > 0){
                
                for(ProcessInstanceWorkItem pwkitem : pinstanceWkItm){
                    workitemsToReject.add(pwkitem.Id);
                }
            }
            String workitemsString = (String)JSON.serialize(workitemsToReject);
            BulkapprovalController.submitRejectedRequests(workitemsString,'false', 'cancel');
            
        }*/
    }
    
    public void emailLog(String subject, string body, string csvFile, string logType, string salesforceTechMessage,Set<string> approverIds)
    {
        Boolean isSandbox = runningInASandbox();
        OrgWideEmailAddress[] owea = [select Id, Address from OrgWideEmailAddress where DisplayName  = 'Salesforce Tech' limit 1];
        String subjectText = '';
        Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage(); //Sales Tech
        
        //defining Subject
        if(isSandbox)
        {
            subjectText = '[Sandbox - '+getInstanceName()+']: Deactivate Coverage Batch Job : '+subject;
        }
        else
        {
            subjectText = 'Deactivate Coverage Batch Job  : '+subject; 
        }
       
        if(subject=='FAILURE') //Failure
        {
            mail2.setOrgWideEmailAddressId(owea.get(0).Id);
            mail2.setReplyTo(owea.get(0).Address);
            mail2.setToAddresses(new String[]{owea.get(0).Address}); //To Sales Tech  
            mail2.setSubject(subjectText);
            mail2.setPlainTextBody(salesforceTechMessage);
            Messaging.sendEmailResult[] sendEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail2});
        }
         
        
    }
    
    public Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    public String getInstanceName() {
        return [SELECT InstanceName FROM Organization LIMIT 1].InstanceName;
    }
    
   
}