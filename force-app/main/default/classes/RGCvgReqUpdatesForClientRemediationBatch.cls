global class RGCvgReqUpdatesForClientRemediationBatch implements Database.Batchable<sObject>,Database.Stateful {
	global List<RG_Coverage_Request__c> errorUpdateList;
    
    
    global RGCvgReqUpdatesForClientRemediationBatch(){
    	errorUpdateList = new List<RG_Coverage_Request__c>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT RG_ACTION__c, OLD_RG__c, NEW_RG__c, OLD_RM__c, NEW_RM__c, OLD_RG_Account__c, OLD_RG_Account__r.Active__c, NEW_RG_Account__c, OLD_RM_Account__c, NEW_RM_Account__c FROM Client_Remediation__c WHERE RG_ACTION__c IN (\'MERGE\')';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        Set<Id> oldRGIdSet = new Set<Id>();
        List<Client_Remediation__c> clientRemediationList = (List<Client_Remediation__c>) scope;
        
        //Cancel the RG Coverage Requests for Merge Scenario when Old RG is inactive
        if(clientRemediationList != null && clientRemediationList.size() > 0){
            for(Client_Remediation__c crObj : clientRemediationList){
                if(String.isNotEmpty(crObj.OLD_RG__c) &&
                   String.isNotEmpty(crObj.NEW_RG__c) &&
                   crObj.OLD_RG_Account__c != null && crObj.NEW_RG_Account__c != null &&
                   crObj.OLD_RG_Account__r.Active__c == FALSE &&
                   !crObj.OLD_RG__c.equalsIgnoreCase(crObj.NEW_RG__c)) 
                {
                   oldRGIdSet.add(crObj.OLD_RG_Account__c);    
                }
            }
            
            if(oldRGIdSet.size() > 0){
                List<RG_Coverage_Request__c> covReqListForRG = 
                    	[SELECT Id, Name, RG_Account__c, RG_Account__r.RDM_Org_Id__c, Status__c
                         FROM RG_Coverage_Request__c
                         WHERE RG_Account__c IN :oldRGIdSet 
                         AND Status__c IN ('Pending Approval','Not Submitted')];
                
                if(covReqListForRG != null && covReqListForRG.size() > 0){
                    for(RG_Coverage_Request__c covReqObj : covReqListForRG){
                        covReqObj.Status__c = 'Recalled';
                    }
                    
                    //Update Coverage Request
                    updateCoverageRequestForRG(covReqListForRG);
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
                subject = 'SF - Coverage Request (RG) For Client Remediation Status';
                emailBody = getEmailBody(apexJob);
                Boolean isSuccess = MailUtility.sendMail(toEmailArray, subject, emailBody);
                if(!isSuccess){
                    System.debug('Error Occurred while sending mail');
                }
            }
        }
    }
    
    global void updateCoverageRequestForRG(List<RG_Coverage_Request__c> coverageRequestList){
        if(coverageRequestList != null && coverageRequestList.size() > 0){
            Database.SaveResult[] saveResultList = Database.update(coverageRequestList, false);
            
            for(Integer i=0; i<saveResultList.size(); i++){            
                Database.SaveResult resultObj = saveResultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        System.debug('Error Status Code for Coverage Request Update :'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                    }
                    
                    errorUpdateList.add(coverageRequestList.get(i));
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
        	emailBody = emailBody + '<p> Failed for below Update RG Coverage Request records : </p><br>';
            emailBody = emailBody + '<br>'
                + '<table border=1 cellspacing=1 cellpadding=1>';
            emailBody = emailBody + '<tr>';
            emailBody = emailBody + '<td>RG Coverage Request Details</td>';
            emailBody = emailBody + '</tr>';
            
            for(RG_Coverage_Request__c covReqObj : errorUpdateList){
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