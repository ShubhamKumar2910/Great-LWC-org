global class BulkApproveCoverageRequest implements Database.Batchable<sObject> {
    
    global final String apprXPID;
    global final string commentText;
    global final String [] processInstanceWorkItemIds;
    Set<String> targetObjectIds = new Set<String>();
    global final String Status;
    List<RG_Coverage_Request__c> finalrejectRGRequest = new  List<RG_Coverage_Request__c>();
    List<Coverage_Access_Request__c> finalrejectRMRequest = new  List<Coverage_Access_Request__c>();
    
    global BulkApproveCoverageRequest(String ApproverName, String comment, string[] Ids, string userChoice){
        apprXPID = ApproverName;
        commentText = comment;
        processInstanceWorkItemIds = Ids;
        Status = userChoice;
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        string query = 'Select ID, ProcessInstanceId,ProcessInstance.TargetObjectId, Isdeleted from processinstanceWorkitem where Id IN : processInstanceWorkItemIds';
        
        
        return Database.getQueryLocator(query);
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<sObject>scope){
      
             
        List<ProcessInstanceWorkItem> prcsinst = (List<ProcessInstanceWorkItem>)scope;
        system.debug('prcsinst :'+ prcsinst);
        
        for (ProcessInstanceWorkItem prc : prcsinst){
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments(Status + ': ' + commentText);
            req2.setAction(Status);
            req2.setWorkitemId(prc.id);          

            try
            {
                approval.ProcessResult result = Approval.process(req2);
                system.debug('result : '+ result);
                //added for JIRA 3419 
                system.debug('Status **' +Status);
                if(Status == 'Reject' && !Test.isRunningTest())
                    targetObjectIds.add(prc.ProcessInstance.TargetObjectId);
            }
            
            catch(exception ex){
                req2.setComments('Rejected :' + commentText);
                req2.setAction('Reject');                
                req2.setWorkitemId(prc.id);
                
                try{                
                    approval.ProcessResult result = Approval.process(req2);
                    system.debug('result : '+ result);
                    if(!Test.isRunningTest())
                    targetObjectIds.add(prc.ProcessInstance.TargetObjectId);
                }                
                catch(exception ex1){
                req2.setComments('Removed :' + commentText);
                req2.setAction('Removed');                
                req2.setWorkitemId(prc.id);
                }
            }
           
        }
        system.debug('targetObjectIds **' +targetObjectIds);
        //added for JIRA 3419
        if(targetObjectIds.size() > 0){
            for(RG_Coverage_Request__c rg: [select id,Sales_Team_for_Coverage__c,RG_Account__r.rdm_org_ID__c,UniqueID__c from RG_Coverage_Request__c where ID in:targetObjectIds and status__c='Pending Approval']){
                rg.status__c = 'Rejected';
                finalrejectRGRequest.add(rg);                      
            }
            for(Coverage_Access_Request__c rm: [select id,Sales_Team_for_Coverage__c,Account__r.rdm_org_ID__c,UniqueID__c  from Coverage_Access_Request__c where ID in:targetObjectIds and status__c='Pending Approval']){
                rm.status__c = 'Rejected';
                finalrejectRMRequest.add(rm);                     
            }
        }
        system.debug('finaldeleteRGRequest G** '+ finalrejectRGRequest);
        system.debug('finalcancelRMRequest M ** '+ finalrejectRMRequest);
        if(finalrejectRGRequest.size()>0) {
           update finalrejectRGRequest;
        }
        if(finalrejectRMRequest.size()>0){
           update finalrejectRMRequest;  
        } 
    }
    
    global void finish(Database.BatchableContext BC){
        
        List<Request_Notification__e> notifications = new List<Request_Notification__e>();
        Request_Notification__e notify = new Request_Notification__e();         
        notify.Message__c = 'RequestProcessed';
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
    }
}