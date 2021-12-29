global class DAUpdatesforClientRemediationBatch implements Database.Batchable<String>,Database.Stateful {
    global List<DA_CorpClient_Attendee__c> errorUpdateList;
    global List<String> oldNewCPIdList;
    
    global DAUpdatesforClientRemediationBatch(List<String> inputList){
    	errorUpdateList = new List<DA_CorpClient_Attendee__c>();
        oldNewCPIdList = inputList;
    }
    
    global List<String> start(Database.BatchableContext bc){
        return oldNewCPIdList;
    }
    
    global void execute(Database.BatchableContext bc, List<String> inputList){
        Map<String,String> oldNewCPIdMap = new Map<String,String>();
        List<DA_CorpClient_Attendee__c> finalListToBeUpdated = new List<DA_CorpClient_Attendee__c>();
        
        if(inputList != null && inputList.size() > 0){
            for(String oldNewCPId : inputList){
                if(String.isNotEmpty(oldNewCPId) && oldNewCPId.contains('~')){
                    List<String> oldNewCPIdList = oldNewCPId.split('~');
                    oldNewCPIdMap.put(oldNewCPIdList.get(0), oldNewCPIdList.get(1));
                }
            }
            
            //We would be running in very small batch sizes
            if(oldNewCPIdMap.size() > 0){
                for(String oldCPId : oldNewCPIdMap.keySet()){
                    List<DA_CorpClient_Attendee__c> corpClientList = [SELECT Id, Name, Event_Meeting_ID__c 
                        											  FROM DA_CorpClient_Attendee__c 
                                                                      WHERE Event_Meeting_ID__c = :oldCPId
                                                                    ];
                    
                    if(corpClientList != null && corpClientList.size() > 0){
                        for(DA_CorpClient_Attendee__c corpClient : corpClientList){
                            String newCPId = oldNewCPIdMap.get(oldCPId);
                            if(String.isNotEmpty(newCPId)){
                                corpClient.Event_Meeting_ID__c= newCPId;
                                finalListToBeUpdated.add(corpClient);
                            }
                        }
                    }
                }
            }
            
            if(finalListToBeUpdated.size() > 0){
                updateDACorpClientAttendees(finalListToBeUpdated);
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
                subject = 'SF - DA CorpClient Attendee Updates For Client Remediation Status';
                emailBody = getEmailBody(apexJob);
                Boolean isSuccess = MailUtility.sendMail(toEmailArray, subject, emailBody);
                if(!isSuccess){
                    System.debug('Error Occurred while sending mail');
                }
            }
        }
    }
    
    global void updateDACorpClientAttendees(List<DA_CorpClient_Attendee__c> corpClientList){
        if(corpClientList != null && corpClientList.size() > 0){
            Database.SaveResult[] saveResultList = Database.update(corpClientList, false);
            
            for(Integer i=0; i<saveResultList.size(); i++){            
                Database.SaveResult resultObj = saveResultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        System.debug('Error Status Code for DA CorpClient Attendee Update :'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                    }
                    
                    errorUpdateList.add(corpClientList.get(i));
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
        	emailBody = emailBody + '<p> Failed for below Update DA_CorpClient_Attendee records : </p><br>';
            emailBody = emailBody + '<br>'
                + '<table border=1 cellspacing=1 cellpadding=1>';
            emailBody = emailBody + '<tr>';
            emailBody = emailBody + '<td>DA_CorpClient_Attendee Details</td>';
            emailBody = emailBody + '</tr>';
            
            for(DA_CorpClient_Attendee__c corpClientObj : errorUpdateList){
                String corpClientDetails = 'Id : ' + corpClientObj.Id + ' Name : ' + corpClientObj.Name;
                emailBody = emailBody + '<tr>';
                
                emailBody = emailBody + '<td>';
                emailBody = emailBody + corpClientDetails ;
                emailBody = emailBody + '</td>';
                
                emailBody = emailBody + '</tr>';
            }
            emailBody = emailBody + '</table> <br>';
        }
        
        return emailBody;
    }
}