global class AttachmentReparentingBatch implements Database.Batchable<sObject>,Database.Stateful {

    global Map<Id, String> errorMapForDelete;
    global Map<Id,Attachment> errorInsertMap;
    global Map<Id,Boolean> attachmentIdProcessedMap;
    global Map<Id,Attachment> attachmentMap;
    global Set<Id> subBatchIdSet;
    global Set<Id> failedBatchIdSet;
    
    
    global AttachmentReparentingBatch(){
        errorMapForDelete = new Map<Id, String>();
        errorInsertMap = new Map<Id,Attachment>();
        attachmentIdProcessedMap = new Map<Id,Boolean>();
        attachmentMap = new Map<Id,Attachment>();
        subBatchIdSet = new Set<Id>();
        failedBatchIdSet = new Set<Id>();
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT RG_ACTION__c, OLD_RG__c, NEW_RG__c, OLD_RM__c, NEW_RM__c, OLD_RG_Account__c, NEW_RG_Account__c, OLD_RM_Account__c, NEW_RM_Account__c FROM Client_Remediation__c WHERE RG_ACTION__c IN (\'MERGE\',\'MOVE\') ORDER BY OLD_RG__c, NEW_RG__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        Map<Id,Id> oldNewIdMap = new Map<Id,Id>();
        Map<Id,Attachment> insertAttachmentMap = new Map<Id,Attachment>();
        List<Attachment> attachmenListToBeProcessed = new List<Attachment>();
        List<Client_Remediation__c> clientRemediationList = (List<Client_Remediation__c>) scope;
        
        if(clientRemediationList != null && clientRemediationList.size() > 0){
            for(Client_Remediation__c crObj : clientRemediationList){
                if(String.isNotEmpty(crObj.OLD_RG__c) &&
                   String.isNotEmpty(crObj.NEW_RG__c) &&
                   crObj.OLD_RG_Account__c != null && crObj.NEW_RG_Account__c != null &&
                  !crObj.OLD_RG__c.equalsIgnoreCase(crObj.NEW_RG__c)) 
                {
                    if(!String.valueOf(crObj.OLD_RG_Account__c).equalsIgnoreCase(String.valueOf(crObj.NEW_RG_Account__c))){
                    	oldNewIdMap.put(crObj.OLD_RG_Account__c, crObj.NEW_RG_Account__c);    
                    }
                }
            }
            
           
            
            if(oldNewIdMap.size() > 0){
                /*List<Attachment> attachmentList = [SELECT Id, ParentId, Name, IsPrivate,
                                                   ContentType, Body, OwnerId, Description
                                                   FROM Attachment 
                                                   WHERE ParentId IN :oldNewIdMap.keySet()];*/
                
                /* Not Included Body */
                List<Attachment> attachmentList = [SELECT Id, ParentId, Name, IsPrivate,
                                                   ContentType, OwnerId, Description
                                                   FROM Attachment 
                                                   WHERE ParentId IN :oldNewIdMap.keySet()];
                
                if(attachmentList != null && attachmentList.size() > 0){
                    
                    for(Attachment attachmentObj : attachmentList){
                        if(!attachmentIdProcessedMap.containsKey(attachmentObj.Id)){
                            attachmentIdProcessedMap.put(attachmentObj.Id, FALSE);
                            attachmenListToBeProcessed.add(attachmentObj);
                        }
                    }
                    
                    if(attachmenListToBeProcessed.size() > 0){
                        for(Attachment attachmentObj : attachmenListToBeProcessed){
                            if(oldNewIdMap.get(attachmentObj.ParentId) != null){
                                 Attachment attachment = new Attachment();
                                 attachment.ParentId = oldNewIdMap.get(attachmentObj.ParentId); 
                                 //attachment.Name = attachmentObj.Name;
                                 attachment.Name = attachmentObj.Id; /* For now, storing Id in Name field, but it will get changed to Name in SubBatch */ 
                                 attachment.IsPrivate = attachmentObj.IsPrivate;
                                 attachment.ContentType = attachmentObj.ContentType;
                                 //attachment.Body = attachmentObj.Body;
                                 attachment.OwnerId = attachmentObj.OwnerId;
                                 attachment.Description = attachmentObj.Description;
                                
                                 attachmentMap.put(attachmentObj.Id, attachment);
                                
                                 //insertAttachmentMap.put(attachmentObj.Id, attachment);
                            }
                        }
                        
                        /*(insertAttachmentMap.size() > 0){
                            
                            //Perform Attachment Insert
                            insertAttachment(insertAttachmentMap);
                            
                            
                            //Remove the records from the list for which we do not have to perform the deletion
                            List<Attachment> attachmentDeletionList = getRecordsForDeletion(attachmentList);
                            
                            //Delete Attachments
                            if(attachmentDeletionList != null && attachmentDeletionList.size() > 0){
                                deleteAttachment(attachmentDeletionList);
                            }
                            
                            
                        }*/
                    }
                }
            }
            
        }
    }
    
    global void finish(Database.BatchableContext bc){
    	System.debug('***attachmentIdProcessedMap:'+attachmentIdProcessedMap.size());
        
        //Call Sub Batches for Inserting Attachments
        callSubBatchForAttachmentReparenting();
        
        if(subBatchIdSet != null && subBatchIdSet.size() > 0){
             List<AsyncApexJob> apexJobList = 
                 [SELECT Id, JobType, Status, JobItemsProcessed, TotalJobItems, 
                  NumberOfErrors, CompletedDate, MethodName, ExtendedStatus
                  FROM AsyncApexJob 
                  WHERE JobType = 'BatchApex' AND Id IN :subBatchIdSet
                 ];
            
            if(apexJobList != null && apexJobList.size() > 0){
                for(AsyncApexJob apexSubJob : apexJobList){
                    if(apexSubJob != null && apexSubJob.NumberOfErrors > 0){
                       failedBatchIdSet.add(apexSubJob.Id);
                    }
                }
            }
        }
        
        
        String toEmailAddress = null;
        String emailBody = null;
        String subject = null;
        
        
        AsyncApexJob apexJob = [SELECT Id, JobType, Status, JobItemsProcessed, TotalJobItems, 
                               NumberOfErrors, CompletedDate, MethodName, ExtendedStatus
                               FROM AsyncApexJob 
                               WHERE JobType = 'BatchApex' AND Id = :bc.getJobId()
                               ];
        
        if(apexJob != null && (apexJob.NumberOfErrors > 0 || errorMapForDelete.size() > 0 || errorInsertMap.size() > 0)){
            /* If Apex Batch fails then email will be sent out */
        	NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
        	toEmailAddress = nomuraSettings.To_Email_Addr_NomuraEmpReplacement_Batch__c;
            
            if(String.isNotEmpty(toEmailAddress)){
            	String[] toEmailArray = toEmailAddress.split(';');
                subject = 'SF - Attachment Reparenting Status';
                emailBody = getEmailBody(apexJob);
                Boolean isSuccess = MailUtility.sendMail(toEmailArray, subject, emailBody);
                if(!isSuccess){
                    System.debug('Error Occurred while sending mail');
                }
            }
        }
    }
    
    global void callSubBatchForAttachmentReparenting(){
    	List<Attachment> insertAttachmentList = new List<Attachment>();
        Map<Integer,List<Attachment>> insertAttachmentMap = new Map<Integer,List<Attachment>>();
        
        //Fetch Attachments that are to be inserted
        for(Id attachmentId : attachmentIdProcessedMap.keySet()){
            Boolean processFlag = attachmentIdProcessedMap.get(attachmentId);
            if(processFlag == FALSE){
                Attachment attachObj = attachmentMap.get(attachmentId);
                insertAttachmentList.add(attachObj);
            }
        }
        
        
        Integer count = 1;
        for(Attachment attachObj : insertAttachmentList){
            Boolean processed = FALSE;
            if(insertAttachmentMap.containsKey(count)){
                List<Attachment> subList = insertAttachmentMap.get(count);
                if(subList.size() < 3){
                    processed = TRUE;
                    subList.add(attachObj);
                    insertAttachmentMap.put(count, subList);
                }
                else if(subList.size() >= 3){
                    count = count + 1;
                }
                
            }
            
            if(processed == FALSE){
                List<Attachment> subList = new List<Attachment>();
                subList.add(attachObj);
                insertAttachmentMap.put(count, subList);
            }
        }
        
        if(insertAttachmentMap.size() > 0){
            for(Integer countKey : insertAttachmentMap.keySet()){
                List<Attachment> subAttachmentList = insertAttachmentMap.get(countKey);
                if(subAttachmentList != null && subAttachmentList.size() > 0){
                    AttachmentReparentingSubBatch subBatch = new AttachmentReparentingSubBatch(subAttachmentList);
                    Id batchProcessId = Database.executeBatch(subBatch);
                    System.debug('**batchProcessId:'+batchProcessId);
                    subBatchIdSet.add(batchProcessId);
                    
                    for(Attachment attachmentObj : subAttachmentList){
                        Id oldAttachmentId = attachmentObj.Name;
                        if(attachmentIdProcessedMap.containsKey(oldAttachmentId)){
                            attachmentIdProcessedMap.put(oldAttachmentId, TRUE);
                        }
                    }
                    
                    
                }
            }
        }
    }
    
    /*global void insertAttachment(Map<Id,Attachment> insertAttachmentMap){
        List<Attachment> attachmentList = insertAttachmentMap.values();
        
        if(attachmentList != null && attachmentList.size() > 0){
            Database.SaveResult[] saveResultList = Database.insert(attachmentList, false);
            
            for(Integer i=0; i<saveResultList.size(); i++){            
                Database.SaveResult resultObj = saveResultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        System.debug('Error Status Code for Attachment Insert:'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                    }
                    
                    //Fetch the attachment for which we do not have to perform the deletion since insertion failed for that attachment
                    Attachment attachmentObj = attachmentList.get(i);
                    
                    for(Id oldAttachmentId : insertAttachmentMap.keySet()){
                        Attachment newAttachment = insertAttachmentMap.get(oldAttachmentId);
                        
                        if( 
                            attachmentObj.Name.equalsIgnoreCase(newAttachment.Name) &&
                           	attachmentObj.Description.equalsIgnoreCase(newAttachment.Description) &&
                           	System.EncodingUtil.convertToHex(attachmentObj.Body).equalsIgnoreCase(System.EncodingUtil.convertToHex(newAttachment.Body)) &&
                           	String.valueOf(attachmentObj.ParentId).equalsIgnoreCase(String.valueOf(newAttachment.ParentId)) &&
                           	String.valueOf(attachmentObj.OwnerId).equalsIgnoreCase(String.valueOf(newAttachment.OwnerId)))
                        {
                        	errorInsertMap.put(oldAttachmentId, attachmentObj);  
                        }
                    }
                }
                
            }
        }
    }*/
    
    /*global void deleteAttachment(List<Attachment> attachmentList){
        Database.DeleteResult[] deleteResultList = Database.delete(attachmentList, false);
        
        for(Integer i=0; i<deleteResultList.size(); i++){            
            Database.DeleteResult deleteResult = deleteResultList.get(i);
            
            if(!deleteResult.isSuccess()){ 
                Attachment attachmentObj = attachmentList.get(i);
                String errorMsg = 'Attachment Id : ' + attachmentObj.Id;
                
                for(Database.Error errorObj : deleteResult.getErrors()){
                    System.debug('Attachment Id :' + attachmentObj.Id + ' Error Status Code for Attachment Delete:'+errorObj.getStatusCode() +' Message:'+errorObj.getMessage());
                    errorMsg = errorMsg + ' ' + ' Status Code: ' + errorObj.getStatusCode() + ' Message: ' + errorObj.getMessage() ; 
                }
                
                //Put failed records in error map
            	errorMapForDelete.put(attachmentObj.Id, errorMsg);
            }
       }
    }*/
    
    /*global List<Attachment> getRecordsForDeletion(List<Attachment> attachmentList){
        List<Attachment> attachmentDeletionList = new List<Attachment>();
        
        if(errorInsertMap != null && errorInsertMap.size() > 0){
            for(Attachment attachmentObj : attachmentList){
                if(!errorInsertMap.containsKey(attachmentObj.Id)){
                    attachmentDeletionList.add(attachmentObj);
                }
            }
        }
        else {
            attachmentDeletionList = attachmentList;
        }
        
        return attachmentDeletionList;
    }*/
    
    global String getEmailBody(AsyncApexJob apexJob){
        String emailBody = null;
        String apexJobId = apexJob.Id;
        emailBody = '<p> The Batch Apex Job (' + apexJobId.substring(0,15) + ') processed '
                    + apexJob.TotalJobItems + ' batche(s) with ' + apexJob.NumberOfErrors + ' failure(s). </p>';
        
        /* Insert Record Failure */
        /*if(errorInsertMap.size() > 0){
        	emailBody = emailBody + '<p> Failed for below Insert Attachment records : </p><br>';
            emailBody = emailBody + '<br>'
                + '<table border=1 cellspacing=1 cellpadding=1>';
            emailBody = emailBody + '<tr>';
            emailBody = emailBody + '<td>Attachment Id to Replicate</td>';
            emailBody = emailBody + '<td>Attachment Details</td>';
            emailBody = emailBody + '</tr>';
            
            for(Id attachmentId : errorInsertMap.keySet()){
                Attachment attachmentObj = errorInsertMap.get(attachmentId);
                String attachmentDetails = 'Attachment Name : ' + attachmentObj.Name + ' Description : ' + attachmentObj.Description + ' Parent Id :' + attachmentObj.ParentId;
                emailBody = emailBody + '<tr>';
                
                emailBody = emailBody + '<td>';
                emailBody = emailBody + attachmentId ;
                emailBody = emailBody + '</td>';
                
                emailBody = emailBody + '<td>';
                emailBody = emailBody + attachmentDetails ;
                emailBody = emailBody + '</td>';
                
                emailBody = emailBody + '</tr>';
            }
            emailBody = emailBody + '</table> <br>';
        }*/
        
        /* Delete Record Failure */
        /*if(errorMapForDelete.size() > 0){
        	emailBody = emailBody + '<p> Failed for below Delete Attachment records : </p><br>';
            emailBody = emailBody + '<br>'
                + '<table border=1 cellspacing=1 cellpadding=1>';
            emailBody = emailBody + '<tr>';
            emailBody = emailBody + '<td>Attachment Id Not Deleted</td>';
            emailBody = emailBody + '<td>Error Message</td>';
            emailBody = emailBody + '</tr>';
            
            for(Id attachmentId : errorMapForDelete.keySet()){
                    String errorMsg = errorMapForDelete.get(attachmentId);
                	emailBody = emailBody + '<tr>';
                
                    emailBody = emailBody + '<td>';
                    emailBody = emailBody + attachmentId ;
                    emailBody = emailBody + '</td>';
                
                 	emailBody = emailBody + '<td>';
                    emailBody = emailBody + errorMsg ;
                    emailBody = emailBody + '</td>';
                
                    emailBody = emailBody + '</tr>';
            }
            emailBody = emailBody + '</table>';
        }*/
       
        if(failedBatchIdSet.size() > 0){
        	emailBody = emailBody + '<p> Failed for below Sub Batches : </p><br>';
            emailBody = emailBody + '<br>'
                + '<table border=1 cellspacing=1 cellpadding=1>';
            emailBody = emailBody + '<tr>';
            emailBody = emailBody + '<td>Batch Id</td>';
            emailBody = emailBody + '</tr>';
            
            for(Id batchId : failedBatchIdSet){
                    emailBody = emailBody + '<tr>';
                
                    emailBody = emailBody + '<td>';
                    emailBody = emailBody + batchId ;
                    emailBody = emailBody + '</td>';
                
                 	emailBody = emailBody + '</tr>';
            }
            emailBody = emailBody + '</table>';
        }
            
        return emailBody;
    }
}