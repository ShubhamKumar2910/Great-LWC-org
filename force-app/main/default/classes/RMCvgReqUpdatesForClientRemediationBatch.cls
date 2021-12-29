global class RMCvgReqUpdatesForClientRemediationBatch implements Database.Batchable<sObject>,Database.Stateful {
	global List<Coverage_Access_Request__c> errorUpdateList;
    
    
    global RMCvgReqUpdatesForClientRemediationBatch(){
    	errorUpdateList = new List<Coverage_Access_Request__c>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT RM_ACTION__c, OLD_RG__c, NEW_RG__c, OLD_RM__c, NEW_RM__c, OLD_RG_Account__c, NEW_RG_Account__c, OLD_RM_Account__c, OLD_RM_Account__r.Active__c, OLD_RM_Account__r.Restricted_Flag__c, NEW_RM_Account__c FROM Client_Remediation__c WHERE RM_ACTION__c IN (\'MERGE\',\'MERGE AND MOVE\')';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        Set<Id> oldIdSet = new Set<Id>();
        List<Client_Remediation__c> clientRemediationList = (List<Client_Remediation__c>) scope;
        
        //Cancel the RM Coverage Requests for Merge Scenario when Old RM is inactive and Restricted (As we do not currently RM Level Requests other that restricted RMs)
        if(clientRemediationList != null && clientRemediationList.size() > 0){
            for(Client_Remediation__c crObj : clientRemediationList){
                if(String.isNotEmpty(crObj.OLD_RM__c) &&
                   String.isNotEmpty(crObj.NEW_RM__c) &&
                   crObj.OLD_RM_Account__r.Active__c == FALSE &&
                   crObj.OLD_RM_Account__r.Restricted_Flag__c == TRUE &&
                   crObj.OLD_RM_Account__c != null && crObj.NEW_RM_Account__c != null ) 
                {
                   oldIdSet.add(crObj.OLD_RM_Account__c);    
                }
            }
            
            if(oldIdSet.size() > 0){
                List<Coverage_Access_Request__c> covReqListForRM = 
                    	[SELECT Id, Name, Account__c, Account__r.RDM_Org_Id__c, Status__c
                         FROM Coverage_Access_Request__c
                         WHERE Account__c IN :oldIdSet
                         AND Status__c IN ('Pending Approval','Not Submitted')
                        ];
                
                if(covReqListForRM != null && covReqListForRM.size() > 0){
                    for(Coverage_Access_Request__c covReqObj : covReqListForRM){
                        covReqObj.Status__c = 'Recalled';
                    }
                    
                    //Update Coverage Request
                    updateCoverageRequestForRM(covReqListForRM);
                }
                    
            }
        }
    }
    
    global void finish(Database.BatchableContext bc){
    	String toEmailAddress = null;
        String emailBody = null;
        String subject = null;
        
        AsyncApexJob apexJob = [SELECT Id, JobType, Status, JobItemsProcessed, TotalJobItems, 
                               NumberOfErrors, CompletedDate, MethodName, ExtendedStatus
                               FROM AsyncApexJob 
                               WHERE JobType = 'BatchApex' AND Id = :bc.getJobId()
                               ];
        if(apexJob != null && (apexJob.NumberOfErrors > 0 || errorUpdateList.size() > 0)){
            /* If Apex Batch fails then email will be sent out */
        	NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
        	toEmailAddress = nomuraSettings.To_Email_Addr_NomuraEmpReplacement_Batch__c;
            
            if(String.isNotEmpty(toEmailAddress)){
            	String[] toEmailArray = toEmailAddress.split(';');
                subject = 'SF - Coverage Request (RM) For Client Remediation Status';
                emailBody = getEmailBody(apexJob);
                Boolean isSuccess = MailUtility.sendMail(toEmailArray, subject, emailBody);
                if(!isSuccess){
                    System.debug('Error Occurred while sending mail');
                }
            }
        }
    }
    
    global void updateCoverageRequestForRM(List<Coverage_Access_Request__c> coverageAccessRequestList){
        if(coverageAccessRequestList != null && coverageAccessRequestList.size() > 0){
            Database.SaveResult[] saveResultList = Database.update(coverageAccessRequestList, false);
            
            for(Integer i=0; i<saveResultList.size(); i++){            
                Database.SaveResult resultObj = saveResultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        System.debug('Error Status Code for Coverage Request Update :'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                    }
                    
                    errorUpdateList.add(coverageAccessRequestList.get(i));
                }
            }
        }
    }
    
        
    global String getEmailBody(AsyncApexJob apexJob){
        String emailBody = null;
        String apexJobId = apexJob.Id;
        emailBody = '<p> The Batch Apex Job (' + apexJobId.substring(0,15) + ') processed '
                    + apexJob.TotalJobItems + ' batche(s) with ' + apexJob.NumberOfErrors + ' failure(s). </p>';
        
        /* Update Record Failure */
        if(errorUpdateList.size() > 0){
        	emailBody = emailBody + '<p> Failed for below Update RM Coverage Request records : </p><br>';
            emailBody = emailBody + '<br>'
                + '<table border=1 cellspacing=1 cellpadding=1>';
            emailBody = emailBody + '<tr>';
            emailBody = emailBody + '<td>RM Coverage Request Details</td>';
            emailBody = emailBody + '</tr>';
            
            for(Coverage_Access_Request__c covReqObj : errorUpdateList){
                String covReqDetails = 'Id : ' + covReqObj.Id + ' Name : ' + covReqObj.Name;
                emailBody = emailBody + '<tr>';
                
                emailBody = emailBody + '<td>';
                emailBody = emailBody + covReqDetails ;
                emailBody = emailBody + '</td>';
                
                emailBody = emailBody + '</tr>';
            }
            emailBody = emailBody + '</table> <br>';
        }
        
        return emailBody;
    }
}