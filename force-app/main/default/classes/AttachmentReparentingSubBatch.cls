global class AttachmentReparentingSubBatch implements Database.Batchable<Attachment>,Database.Stateful {
    global List<Attachment> errorInsertList;
    global List<Attachment> attachmentList;
    
    global AttachmentReparentingSubBatch(List<Attachment> inputList){
    	errorInsertList = new List<Attachment>();
        attachmentList = inputList;
    }
    
    global List<Attachment> start(Database.BatchableContext bc){
        return attachmentList;
    }
    
    global void execute(Database.BatchableContext bc, List<Attachment> inputList){
        Set<Id> attachmentIdSet = new Set<Id>();
        List<Attachment> newAttachmentList = new List<Attachment>();
        if(inputList != null && inputList.size() > 0){
            
            for(Attachment attachmentObj : inputList){
                attachmentIdSet.add(attachmentObj.Name); 
                //In Parent Batch, we have stored Id in Name Field
                //Because Batch cannot process Map
            }
            
            if(attachmentIdSet.size() > 0){
                Map<Id,Attachment> oldAttachmentMap = new Map<Id,Attachment>([SELECT Id, Name, Body FROM Attachment WHERE Id IN :attachmentIdSet]);
                if(oldAttachmentMap != null && oldAttachmentMap.size() > 0){
                    
                    for(Attachment newAttachmentObj : inputList){
                        Id oldAttachmentId = newAttachmentObj.Name;
                        if(oldAttachmentMap.containsKey(oldAttachmentId)){
                            Attachment oldAttachmentObj = oldAttachmentMap.get(oldAttachmentId);
                            newAttachmentObj.Name = oldAttachmentObj.Name;
                            newAttachmentObj.Body = oldAttachmentObj.Body;
                            newAttachmentList.add(newAttachmentObj);
                        }
                    }
                    
                }
            }
            
            if(newAttachmentList.size() > 0){
                System.debug('***newAttachmentList size in SubBatch:'+newAttachmentList.size());
                insertAttachment(newAttachmentList);
            }
            
        }
    }
    
    global void insertAttachment(List<Attachment> insertAttachmentList){
        if(insertAttachmentList != null && insertAttachmentList.size() > 0){
            Database.SaveResult[] saveResultList = Database.insert(insertAttachmentList, false);
            
            for(Integer i=0; i<saveResultList.size(); i++){            
                Database.SaveResult resultObj = saveResultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        System.debug('Error Status Code for Attachment Insert:'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                        
                    }
                    
                    Attachment attachmentObj = insertAttachmentList.get(i);
                    System.debug('Failed for Attachment Name :'+attachmentObj.Name);
                    System.debug('Failed for Attachment Description :'+attachmentObj.Description);
                    System.debug('Failed for Attachment ParentId :'+attachmentObj.ParentId);
                    
                    errorInsertList.add(attachmentObj);
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
        if(apexJob != null && (apexJob.NumberOfErrors > 0 || errorInsertList.size() > 0)){
            /* If Apex Batch fails then email will be sent out */
        	NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
        	toEmailAddress = nomuraSettings.To_Email_Addr_NomuraEmpReplacement_Batch__c;
            
            if(String.isNotEmpty(toEmailAddress)){
            	String[] toEmailArray = toEmailAddress.split(';');
                subject = 'SF - Attachment Sub Batch Updates For Client Remediation Status';
                emailBody = getEmailBody(apexJob);
                Boolean isSuccess = MailUtility.sendMail(toEmailArray, subject, emailBody);
                if(!isSuccess){
                    System.debug('Error Occurred while sending mail');
                }
            }
        }
    }
    
    global String getEmailBody(AsyncApexJob apexJob){
        String emailBody = null;
        String apexJobId = apexJob.Id;
        emailBody = '<p> The Batch Apex Job (' + apexJobId.substring(0,15) + ') processed '
                    + apexJob.TotalJobItems + ' batche(s) with ' + apexJob.NumberOfErrors + ' failure(s). </p>';
        
        /* Insert Record Failure */
        if(errorInsertList.size() > 0){
        	emailBody = emailBody + '<p> Failed for below Update Attachment Sub Batch records : </p><br>';
            emailBody = emailBody + '<br>'
                + '<table border=1 cellspacing=1 cellpadding=1>';
            emailBody = emailBody + '<tr>';
            emailBody = emailBody + '<td>Attachment Details</td>';
            emailBody = emailBody + '</tr>';
            
            for(Attachment attachmentObj : errorInsertList){
                String attachmentDetails = 'Name : ' + attachmentObj.Name + ' Description : ' + attachmentObj.Description + ' ParentId : ' + attachmentObj.ParentId;
                emailBody = emailBody + '<tr>';
                
                emailBody = emailBody + '<td>';
                emailBody = emailBody + attachmentDetails ;
                emailBody = emailBody + '</td>';
                
                emailBody = emailBody + '</tr>';
            }
            emailBody = emailBody + '</table> <br>';
        }
        
        return emailBody;
    }
}