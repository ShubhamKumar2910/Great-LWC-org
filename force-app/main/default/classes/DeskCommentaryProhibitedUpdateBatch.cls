/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : Batch Apex class for bulk updating the Desk Commentary Allowed on Contact using RM/RG accounts
**/ 

// NOTE - This class has been depricated and replaced with class - 'UpdateContactsBatch.cls'. Delete this class
//
public class DeskCommentaryProhibitedUpdateBatch {}
/*public class DeskCommentaryProhibitedUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {

    public enum IdentifierType {ACC_RG_ACC, ACC_RM_ACC}
    public String query;
    public String campaignId;
    public Set<String> IdentifierKeySet;
    public Map<String, sObject> ObjectByIdntMap;
    public IdentifierType identType;
    public Integer batchCount;
    //public Map<String, CampaignMemberStatus> CampaignMemberStatusByStatusMap;
    
    // e.g. Map<contId, Map<DeskCommProh val, Err msg>>
    public Map<String, Map<String, String>> ErrNotAddedToCampByDCPValByContId;
    
    public List<Id> SuccessfullyUpdatedContactIdList;
    public Map<Id, String> ErrorsInUpdContByContIdMap;
    //public Integer noOfContsFailedToUpdate;
    public Map<Integer, String> ExceptionMsgByBatchNoMap;
    
    private Integer totalNoOfContactsToUpdate;
    private Integer noOfFailedCampMemCreation;
    private List<Id> AccIdList;
    // this Map holds the list of contact-Ids by the Batch Process No.
    public Map<Integer, List<Id>> FailedGLContIdListByBatchProcNoMap;
    
    public DeskCommentaryProhibitedUpdateBatch(String campaignId, IdentifierType identType, Map<String, sObject> ObjectByIdntMap) {
    	System.debug('IN CONST campaignId : '+campaignId);
    	this.campaignId=campaignId;
    	this.identType = identType;
    	this.ObjectByIdntMap = ObjectByIdntMap;
    	this.IdentifierKeySet=this.ObjectByIdntMap.keySet();
    	System.debug('IdentifierKeySet : '+IdentifierKeySet);
    	//Set<String> IdentifierKeySet = ObjectByIdntMap.keySet(); 
    	query='SELECT Id,DeskCommentaryProhibited__c,RG_Account__c,RG_Account__r.RDM_Org_ID__c,RG_Account__r.Name,'+
    		'AccountId,Account.RDM_Org_ID__c,Account.Name,Email FROM Contact ';

		Map<Id, Account> AccByIdMap = new Map<Id, Account>([SELECT Id 
			FROM Account 
			WHERE (RDM_Org_ID__c IN :IdentifierKeySet) OR
				  (Name IN :IdentifierKeySet)]);
		AccIdList = new List<Id>(AccByIdMap.keySet());
		System.debug('Account Ids : '+AccIdList); 

    	if(this.identType==IdentifierType.ACC_RG_ACC) {
    		//query+='WHERE RG_Account__c IN :IdentifierKeySet ';
    		//query+='WHERE RG_Account__c IN (SELECT Id FROM Account WHERE Parent_RDM_Org_ID__c  IN :IdentifierKeySet) ';
    		
    		//query+='WHERE RG_Account__c IN (SELECT Id FROM Account WHERE RDM_Org_ID__c IN :IdentifierKeySet) ';
    		query+='WHERE RG_Account__c IN :AccIdList ';
    	} else if(this.identType==IdentifierType.ACC_RM_ACC) {
    		//query+='WHERE AccountId IN (SELECT Id FROM Account WHERE RDM_Org_ID__c IN :IdentifierKeySet) ';
    		query+='WHERE AccountId IN :AccIdList ';
    	} //else if(this.identType==IdentifierType.CONT_EMAIL) {
    	//	query+='WHERE Email IN :IdentifierKeySet ';
    	//}
    	query+='AND Active__c=true ';
    	//query+='LIMIT 300';
    	
    	SuccessfullyUpdatedContactIdList = new List<Id>();
    	ErrorsInUpdContByContIdMap = new Map<Id, String>();
    	//noOfContsFailedToUpdate=0;
    	ExceptionMsgByBatchNoMap = new Map<Integer, String>();
    	batchCount=0;
    	totalNoOfContactsToUpdate=0;
    	noOfFailedCampMemCreation=0;
    	FailedGLContIdListByBatchProcNoMap = new Map<Integer, List<Id>>();
    	ErrNotAddedToCampByDCPValByContId = new Map<String, Map<String, String>>(); 
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
    	System.debug('#### DeskCommentaryProhibitedUpdateBatch.start()');
    	System.debug('query : '+query);
    	
    	// Setup CampaignMemberStatus for a give campaignId
    	//setUpCampaignMemberStatus();
    	
    	return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
    	System.debug('#### DeskCommentaryProhibitedUpdateBatch.execute()');
    	System.debug('scope '+scope);
    	List<CampaignMember> CampaignMemberList = new List<CampaignMember>();
    	++batchCount;
    	Boolean throwException = false;
    	String error='';
    	List<Contact> ContactList=new List<Contact>();
    	Set<Id> LocalSuccessUpdContIdSet = new Set<Id>();
    	Map<Id, String> LocalErrsInUpdContByContIdMap = new Map<Id, String>(); 
    	try {
			ContactList = (List<Contact>)(scope);
			System.debug('ContactList : '+ContactList);
			totalNoOfContactsToUpdate+=ContactList.size();
    		// Before executing the batch, hold all the contact-Ids for that batch before any other processing
    		// and is there is not Governer Limits exception which cannot be handled later in the code, we will 
    		// use this structure to get hold of the failed records.
    		// Else if there were no governer limets exception we will clear the contact-Ids for this batch
    		List<Id> ContIdList = new List<Id>();
    		for(Contact oCont : ContactList) {
    			ContIdList.add(oCont.Id);
    		}
    		FailedGLContIdListByBatchProcNoMap.put(batchCount, ContIdList);
    		System.debug('IN BATCH : '+batchCount+ ' : FailedGLContIdListByBatchProcNoMap : '+FailedGLContIdListByBatchProcNoMap);
    		
    		List<Contact> ContactToUpdateList = new List<Contact>();
	    	for(Contact oCont : ContactList) {
	    		String keyRDMOrgID;
	    		String keyName;
	    		if(this.identType==IdentifierType.ACC_RG_ACC) {
	    			if(String.isNotBlank(oCont.RG_Account__r.RDM_Org_ID__c)) {
	    				keyRDMOrgID=oCont.RG_Account__r.RDM_Org_ID__c.toUpperCase();
	    			}
	    			keyName = oCont.RG_Account__r.Name.toUpperCase();
		    	} else if(this.identType==IdentifierType.ACC_RM_ACC) {
		    		if(String.isNotBlank(oCont.Account.RDM_Org_ID__c)) {
		    			keyRDMOrgID=oCont.Account.RDM_Org_ID__c.toUpperCase();
		    		}
		    		keyName=oCont.Account.Name.toUpperCase();
		    	} //else if(this.identType==IdentifierType.CONT_EMAIL) {
		    	//	key=oCont.Email;
		    	//}
	    		
	    		System.debug('keyRDMOrgID : '+keyRDMOrgID);
	    		System.debug('keyName : '+keyName);
	    		//if((String.isNotBlank(keyRDMOrgID) && ObjectByIdntMap.containsKey(keyRDMOrgID)) ||
	    		//		(String.isNotBlank(keyName) && ObjectByIdntMap.containsKey(keyName)) ) {
    			String value;
    			Boolean isValid = false;
    			if(String.isNotBlank(keyRDMOrgID) && ObjectByIdntMap.containsKey(keyRDMOrgID)) {
    				value=(String)ObjectByIdntMap.get(keyRDMOrgID).get('DeskCommentaryProhibited__c');
    				isValid=true;
    			} else if(String.isNotBlank(keyName) && ObjectByIdntMap.containsKey(keyName)) {
    				value=(String)ObjectByIdntMap.get(keyName).get('DeskCommentaryProhibited__c');
    				isValid=true;
    			}
    			
    			
    			//if(this.identType==IdentifierType.ACC_RG_ACC || this.identType==IdentifierType.ACC_RM_ACC) {
    			//	value=(String)ObjectByIdntMap.get(key).get('DeskCommentaryProhibited__c');
    			//} //else if(this.identType==IdentifierType.CONT_EMAIL) {
    				//value=(String)ObjectByIdntMap.get(key).get('DeskCommentaryProhibited__c');
    			//}
    			if(isValid) {
		    		System.debug('value : '+value);
		
					if(String.isBlank(value)) {
						oCont.DeskCommentaryProhibited__c=null;	
					} else {
						oCont.DeskCommentaryProhibited__c=value;
					}
					
					ContactToUpdateList.add(oCont);
    			} else {
	    			// raise an error for this contact
	    			CampaignMemberList.add(new CampaignMember(ContactId=oCont.Id, CampaignId=this.campaignId, Status='ERROR', 
	                    	Value__c='VALUE NOT FOUND', Short_Description__c='Value not found in the file for the Account unique key or Name related to this Contact'));
	    		}
	    	}
	    	
	    	if(!ContactToUpdateList.isEmpty()) {
	    		// use the Database.update() with partial update set to true, instead of update statement
	    		// so that whole batch doesn't fail when few records fail.
	    		Database.SaveResult[] srList = Database.Update(ContactToUpdateList, false);        
	            Integer indx=0;
        	    String updError;
				// success and failure results should be added to a local structure in this transaction before adding
				// there results to the global result structures, in case transaction fails due to some exception then
				// we can manipulate the results accordingly.
            	for (Database.SaveResult sr : srList) {
	                updError='';
	                Contact oCont = ContactToUpdateList.get(indx);
	                if (sr.isSuccess()) {
	                    //SuccessfullyUpdatedContactIdList.add(oCont.Id);
	                    LocalSuccessUpdContIdSet.add(oCont.Id);
	                    CampaignMemberList.add(new CampaignMember(ContactId=oCont.Id, CampaignId=this.campaignId, 
	                    	Status='SUCCESS', Value__c=oCont.DeskCommentaryProhibited__c));
	                }
	                else {
	                    // Operation failed, so get all errors                
	                    for(Database.Error err : sr.getErrors()) {
	                        updError+=err.getStatusCode() + ': ' + err.getMessage() + '\n';
	                    }
	                    LocalErrsInUpdContByContIdMap.put(oCont.Id, updError);
	                    CampaignMemberList.add(new CampaignMember(ContactId=oCont.Id, CampaignId=this.campaignId, Status='ERROR', 
	                    	Value__c=oCont.DeskCommentaryProhibited__c, Short_Description__c=updError));
	                    System.debug('Error : '+updError);
	                }
	                
	                ++indx;
            	}
	    		//update ContactToUpdateList;
	    	}
    	} catch(Exception ex) {
    		System.debug('Exception occured in Batch No : '+batchCount+' Error : '+ex.getMessage()+'\n'+ex.getStackTraceString());
            ExceptionMsgByBatchNoMap.put(batchCount, ex.getMessage()+' <br/>'+ex.getStackTraceString());
            error+=ex.getMessage();
            // clear the campaign Member list so far and re-create with errors
            CampaignMemberList.clear();
    		for(Contact oCont : ContactList) {
    			ErrorsInUpdContByContIdMap.put(oCont.Id, ex.getMessage());
    			campaignMemberList.add(new CampaignMember(ContactId=oCont.Id, CampaignId=this.campaignId, Status='ERROR'));
    			//++noOfContsFailedToUpdate;
    		}
    		//throwException = true;
    	}
    	
    	// try inserting the CampaignMembers in a seerate try catch block and explicitly throw exception is any errors are fouund
    	try {
    		System.debug('INSERTING : '+campaignMemberList);
    		insert campaignMemberList;
    	} catch(Exception ex) {
    		System.debug('Exception while inserting the CampignMembers to the Campaign: '+batchCount+' Error : '+ex.getMessage()+'\n'+ex.getStackTraceString());
            error = ExceptionMsgByBatchNoMap.containsKey(batchCount) ? ExceptionMsgByBatchNoMap.get(batchCount) : '';
            error+='<br/>'+ex.getMessage()+' <br/>'+ex.getStackTraceString();
            ExceptionMsgByBatchNoMap.put(batchCount, error);
            // Also add the contact-id to the structure for Failed due to inserting CampaignMembers
            for(Contact oCont : ContactList) {
    			String excpErr=ErrorsInUpdContByContIdMap.containsKey(oCont.Id) ? ErrorsInUpdContByContIdMap.get(oCont.Id) : '';
    			excpErr += '\n'+ex.getMessage();
    			//ErrorsInUpdContByContIdMap.put(oCont.Id, excpErr);
    			ErrNotAddedToCampByDCPValByContId.put(oCont.Id, new Map<String, String>{oCont.DeskCommentaryProhibited__c => excpErr});
    			ErrorsInUpdContByContIdMap.remove(oCont.Id);
    		}
    		noOfFailedCampMemCreation+=ContactList.size(); 
    		throwException=true;
    	}
    	// if there were no Governer Limits - unhandled exceptions then code will hot the following line
    	// and clear the governor limits failed contact-Ids for this batch
    	FailedGLContIdListByBatchProcNoMap.remove(batchCount);
    	
    	if(throwException) {
    		throw new DeskCommentaryProhBulkUploadException(error);
    	}
    	
    	// at this point all the processing is finished and there is no no exception so add the local results to the
		// global results
		SuccessfullyUpdatedContactIdList.addAll(LocalSuccessUpdContIdSet);
		ErrorsInUpdContByContIdMap.putAll(LocalErrsInUpdContByContIdMap);
		
		updateCampaign(campaignId, BC.getJobId(), null, 'No');
    }
    
    private  void updateCampaign(String campId, String jobId, String jobStatus, String emailSent) {
    	List<Campaign> CampList = [Select Id, Description FROM Campaign WHERE Id=:campaignId];
    	if(!CampList.isEmpty()) {
    		BulkUpdateDeskCommentaryProhController.BulkUpdDeskCommPreviousJobRunInfo bulkUpldInfo;
			if(CampList[0].Description!=null) {
				bulkUpldInfo = (BulkUpdateDeskCommentaryProhController.BulkUpdDeskCommPreviousJobRunInfo)JSON.deserialize(
	               		CampList[0].Description, BulkUpdateDeskCommentaryProhController.BulkUpdDeskCommPreviousJobRunInfo.class);
			} else {
				bulkUpldInfo = new BulkUpdateDeskCommentaryProhController.BulkUpdDeskCommPreviousJobRunInfo();
			}
			if(String.isNotBlank(jobId)) {
				//bulkUpldInfo.jobId=jobId;
			}
			
			
			bulkUpldInfo.totalNoOfRecsToProc = ObjectByIdntMap.size();
			bulkUpldInfo.totalNoOfRecsProc = totalNoOfContactsToUpdate;
			bulkUpldInfo.noOfSucc = SuccessfullyUpdatedContactIdList.size();
			bulkUpldInfo.noOfErrs = ErrorsInUpdContByContIdMap.size();
			bulkUpldInfo.noOfErrsNoInCamp = noOfFailedCampMemCreation;
			
			List<AsyncApexJob> AsyncApexJobList = [SELECT Id,JobItemsProcessed,CompletedDate,JobType,NumberOfErrors,Status,TotalJobItems,createdDate 
				FROM AsyncApexJob 
				WHERE Id = :bulkUpldInfo.jobId OR Id=:jobId];
			System.debug('AsyncApexJobList : '+AsyncApexJobList);
			if(!AsyncApexJobList.isEmpty()) {
				if (AsyncApexJobList[0].JobItemsProcessed!=null && AsyncApexJobList[0].TotalJobItems!=null && 
						AsyncApexJobList[0].TotalJobItems!=0) {
					Decimal percent = (AsyncApexJobList[0].JobItemsProcessed * 100)/AsyncApexJobList[0].TotalJobItems;
					System.debug('AsyncApexJobList[0].JobItemsProcessed : '+AsyncApexJobList[0].JobItemsProcessed);
					System.debug('AsyncApexJobList[0].TotalJobItems '+AsyncApexJobList[0].TotalJobItems);
					bulkUpldInfo.percentProg = ''+percent.round();
					bulkUpldInfo.jobStatus = jobStatus;
					System.debug('percent : '+percent.round()); 
					if(String.isBlank(jobStatus) || jobStatus=='Complete') {
						if(AsyncApexJobList[0].Status=='Completed') {
						//if(percent.round()==100) { -> 
							bulkUpldInfo.percentProg = '100';
							String status='Complete';
							if(!ErrorsInUpdContByContIdMap.isEmpty() || !ErrNotAddedToCampByDCPValByContId.isEmpty() ||
    								!FailedGLContIdListByBatchProcNoMap.isEmpty()) {
    							status='Completed with Errors';	
							} 
							bulkUpldInfo.jobStatus = status;
						} else {
							bulkUpldInfo.jobStatus = 'Processing';
						}
					}
				}
			}

			bulkUpldInfo.emailSent=emailSent;
			System.debug('bulkUpldInfo : '+bulkUpldInfo);
			// update other parameters
			Campaign oCamp = new Campaign(Id=campaignId, Description=JSON.serialize(bulkUpldInfo));
			update oCamp;
    	}
    }
    
    
    public class DeskCommentaryProhBulkUploadException extends Exception {}
    
    public void finish(Database.BatchableContext BC){
    	System.debug('#### DeskCommentaryProhibitedUpdateBatch.finish()');
    	System.debug('Transaction_Finish'+'->ObjectByIdntMap : '+ObjectByIdntMap);
    	
    	String reportURL; 
		List<Campaign> CampList = [Select Id, Description FROM Campaign WHERE Id=:campaignId];
    	if(!CampList.isEmpty()) {
    		BulkUpdateDeskCommentaryProhController.BulkUpdDeskCommPreviousJobRunInfo bulkUpldInfo;
			if(CampList[0].Description!=null) {
				bulkUpldInfo = (BulkUpdateDeskCommentaryProhController.BulkUpdDeskCommPreviousJobRunInfo)JSON.deserialize(
	               		CampList[0].Description, BulkUpdateDeskCommentaryProhController.BulkUpdDeskCommPreviousJobRunInfo.class);
	            if(bulkUpldInfo!=null) {
	            	reportURL = bulkUpldInfo.reportURL;	
	            }
			}
    	}
    	
    	String error='';
    	List<CampaignMember> CampaignMemberList = new List<CampaignMember>();
    	try {
	    	if(!FailedGLContIdListByBatchProcNoMap.isEmpty()) {
	    		for(Integer batchNo : FailedGLContIdListByBatchProcNoMap.keySet()) {
	    			for(Id ContId : FailedGLContIdListByBatchProcNoMap.get(batchNo)) {
	    				CampaignMemberList.add(new CampaignMember(ContactId=ContId, CampaignId=this.campaignId, Status='ERROR', 
	    					Value__c='UNKNOWN', Short_Description__c='Governor Limits Error'));
	    			}
	    		}
	    		if(!CampaignMemberList.isEmpty()) {
	    			insert CampaignMemberList;
	    		}
	    	}
    	} catch(Exception ex) {
    		System.debug('Failed to insert CampignMebers for contacts failed due to Governor Execuion limits');
    		error+='Failed to insert CampignMebers for contacts failed due to Governor Execuion limits';
    		for(CampaignMember oCampMem : CampaignMemberList) {
				ErrNotAddedToCampByDCPValByContId.put(oCampMem.ContactId, new Map<String, String>{'UNKOWN'=>oCampMem.Short_Description__c});    			
    		}
    	}
    	
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setTargetObjectId(UserInfo.getUserId());
		//mail.setToAddresses(new String[]{'abcd@xyz.com'});

    	AsyncApexJob apexJob = [SELECT Id,Status,NumberOfErrors,JobItemsProcessed,TotalJobItems,ApexClassID,CreatedBy.Email 
    		FROM AsyncApexJob WHERE Id =:BC.getJobId()];

    	// Set the email subject
    	String subject = 'UPLOAD : '+(String.isNotBlank(System.Label.Desk_Commentary_Label) ? System.Label.Desk_Commentary_Label : 'Desk Commentary Allowed')+' upload for Contacts Completed';
    	mail.setSubject(subject);

		// governor limits error for contatct-ids
		List<Id> GovernorLimitErrorContIdList = new List<Id>();
		System.debug('FailedGLContIdListByBatchProcNoMap : '+FailedGLContIdListByBatchProcNoMap);
		for(Integer batchNo : FailedGLContIdListByBatchProcNoMap.keySet()) {
			if(FailedGLContIdListByBatchProcNoMap.get(batchNo)!=null) {
				GovernorLimitErrorContIdList.addAll(FailedGLContIdListByBatchProcNoMap.get(batchNo));
			}
		}

    	// Set email body
    	String htmlBody ='<font face="verdana"><b>Upload summary:</b>'+
    							'<br/>Total number entries in file : '+ObjectByIdntMap.size()+
    							'<br/>Total number of Contacts to be Updated: '+totalNoOfContactsToUpdate+
    							'<br/>Total number of Contacts updated successfully and results added to Campaign : '+SuccessfullyUpdatedContactIdList.size()+
    							'<br/>Total number of Contacts failed to update and results added to Campaign : '+ErrorsInUpdContByContIdMap.size()+
    							'<br/>Total number of Errors not added to Campaign and reported in email : '+ErrNotAddedToCampByDCPValByContId.size()+
    							'<br/>Total number of Contacts failed to update due to Governor Limits : '+GovernorLimitErrorContIdList.size()+
    							'<br/>Bulk Upload Report (please open it in Google Chrome) : <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+reportURL+'">Report URL</a>'+
								'<br><br><b>Job Execution Details</b>'+	
								'<br/>Job Status: '+apexJob.Status+
								'<br/>Total Number of Sub Jobs: '+apexJob.TotalJobItems+
								'<br/>Number of Sub Jobs has Errors: '+apexJob.NumberOfErrors+
								'<br/>Number of Sub Jobs Processed: '+apexJob.JobItemsProcessed+
								'<br/>Number of Sub Jobs Processed: '+apexJob.ApexClassID;
								
		//htmlBody+='<br/><br/><b>Upload Details : </b>';
		
		if(!ErrNotAddedToCampByDCPValByContId.isEmpty()) {
			htmlBody+='<br/><br/>List of Errors that cannot be added to Campaign : <br/>';
			// check if we have sufficient limits to query the Contact details to show the results
			if(ErrNotAddedToCampByDCPValByContId.size() <= Limits.getLimitQueryRows()-Limits.getQueryRows()) {
				Map<Id,Contact> ContErrsNotAddedToCamp = new Map<Id,Contact>([SELECT Id,DeskCommentaryProhibited__c,
							RG_Account__c,RG_Account__r.Name,AccountId,Account.Name,Email 
						FROM Contact 
						WHERE Id IN :ErrNotAddedToCampByDCPValByContId.keySet()
						ORDER BY RG_Account__c,AccountId]);
				htmlBody+='<table><tr><th>RG Account</th><th>RM Account</th>'+
					'<th>Contact Id</th><th>Email</th><th>Desk Commentary Allowed</th><th>Errors</th></tr>';
				for(Contact oCont : ContErrsNotAddedToCamp.values()) {
					String deskCommPrh;
					String err;
					if(ErrNotAddedToCampByDCPValByContId.containsKey(oCont.Id)) {
						if(ErrNotAddedToCampByDCPValByContId.get(oCont.Id) != null) {
							List<String> KeyList = new List<String>(ErrNotAddedToCampByDCPValByContId.get(oCont.Id).keySet());
							if(!KeyList.isEmpty()) {
								deskCommPrh=KeyList[0];
								err=ErrNotAddedToCampByDCPValByContId.get(oCont.Id).get(deskCommPrh);
							}
						}
					}
					htmlBody+='<tr><td>'+oCont.RG_Account__r.Name+'</td><td>'+oCont.Account.Name+'</td>'+
						'<td>'+oCont.Id+'</td>'+'<td>'+oCont.Email+'</td>'+'<td>'+deskCommPrh+'</td><td>'+err+'</td></tr>';
						
					
				}
			} else {
				htmlBody+='<table><tr><th>Contact Id</th><th>'+(String.isNotBlank(System.Label.Desk_Commentary_Label) ? System.Label.Desk_Commentary_Label : 'Desk Commentary Allowed')+'</th><th>Error</th></tr>';
				for(String contId : ErrNotAddedToCampByDCPValByContId.keySet()) {
					htmlBody+='<tr><td>'+contId+'</td><td>'+ErrNotAddedToCampByDCPValByContId.get(contId).keySet()+'</td><td>'+ErrNotAddedToCampByDCPValByContId.get(contId).values()+'</td></tr>';
				}
			}
			
			htmlBody+='</table>';
		}
		
		htmlBody+='</font>';
		system.debug('htmlBody : '+htmlBody);
    	mail.setHtmlBody(htmlBody);
    	mail.setSaveAsActivity(false);
    	// Finally send email
    	Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
    	System.debug('Email Sent');
    	
    	updateCampaign(campaignId, BC.getJobId(), 'Complete', 'Yes');
    }
}*/