/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : Batch Apex class for bulk updating the Desk Commentary Allowed on Contact  
**/ 
public class DeskCommentaryProhUpdByContQueueable implements Queueable, Database.AllowsCallouts {
    public String campaignId;
    //public String contentDocId;
    Blob fileBody;
    private Integer filePointer; 
    private Integer bufferSize;
    private Map<Integer, String> FieldApiByHeaderIndxMap;
    
    private Integer batchNo;
    private Integer totalNoOfRecsToParse;
	private Integer totalNoOfRecsParsed;
	private List<String> SuccessfullyUpdContEmailList;
	private List<String> ErrorAddedToCampaignList;
	private List<String> ErrorNotAddedToCampaignList;
    
    public DeskCommentaryProhUpdByContQueueable(Integer ii) {
    	batchNo=ii;
    }
    
    public DeskCommentaryProhUpdByContQueueable(String campaignId, Map<Integer, String> FieldApiByHeaderIndxMap, 
    		blob fileBody, Integer filePointer, Integer bufferSize) {
    	system.debug('#### DeskCommentaryProhUpdByContQueueable::DeskCommentaryProhUpdByContQueueable()');
    	System.debug('filePointer : '+filePointer);
    	System.debug('bufferSize : '+bufferSize);
    	this.campaignId=campaignId;
    	this.FieldApiByHeaderIndxMap=FieldApiByHeaderIndxMap;
    	this.fileBody = fileBody;
    	this.filePointer=filePointer; 
    	this.bufferSize=bufferSize;
    	this.totalNoOfRecsToParse=fileBody.toString().split('\n').size()-1;
    	
		batchNo=1;
		totalNoOfRecsParsed=0;
		SuccessfullyUpdContEmailList = new List<String>();
		ErrorAddedToCampaignList = new List<String>();
		ErrorNotAddedToCampaignList = new List<String>();
		
		//setUpCampaignMemberStatus();
    }
    
    private DeskCommentaryProhUpdByContQueueable(String campaignId, Map<Integer, String> FieldApiByHeaderIndxMap, 
    		blob fileBody, Integer filePointer, Integer bufferSize, Integer totalNoOfRecsToParse, Integer batchNo, Integer totalNoOfRecsParsed,
			List<String> SuccessfullyUpdContEmailList, List<String> ErrorAddedToCampaignList, List<String> ErrorNotAddedToCampaignList) {

    	system.debug('#### DeskCommentaryProhUpdByContQueueable::DeskCommentaryProhUpdByContQueueable()');
    	System.debug('filePointer : '+filePointer);
    	System.debug('bufferSize : '+bufferSize);
    	this.campaignId=campaignId;
    	this.FieldApiByHeaderIndxMap=FieldApiByHeaderIndxMap;
    	this.fileBody = fileBody; 
    	this.filePointer=filePointer; 
    	this.bufferSize=bufferSize;
    	this.totalNoOfRecsToParse=totalNoOfRecsToParse;
    	
		this.batchNo = batchNo;
		this.totalNoOfRecsParsed = totalNoOfRecsParsed;
		this.SuccessfullyUpdContEmailList = SuccessfullyUpdContEmailList;
		this.ErrorAddedToCampaignList = ErrorAddedToCampaignList;
		this.ErrorNotAddedToCampaignList = ErrorNotAddedToCampaignList;
    }
    
    public void execute(QueueableContext context) {
    	system.debug('#### DeskCommentaryProhUpdByContQueueable::execute()');
		System.debug('batchNo : '+batchNo);
		//System.enqueueJob(new DeskCommentaryProhUpdByContQueueable(++batchNo));
		//if(batchNo==2) {
		//	throw new ABCException('TEST EXCEPTION');
		//} else if(batchNo<5) {
		//	System.debug('Finished....');
		//}
		//return;
		
		// infinite loop for testing
		//for(Integer i=0;i<1000;) { }
		String unhandledError='';
		FileParserUtil.FileReaderInfo fileReadInfo;
		List<String> LocalSuccessUpdContEmailList = new List<String>();
		List<String> LocalErrors = new List<String>();
    	try {
    		if(fileBody==null) {
    			unhandledError='File cannot be as it is an emoty file';
    		} else {
    			Map<String, sObject> RowDataSObjByDecryptedEmailMap = new Map<String, sObject>(); 
    			//
    			fileReadInfo = FileParserUtil.parseNRows(fileBody, FieldApiByHeaderIndxMap, 
    					filePointer, bufferSize, 'Contact', '\n', ',');
    			System.debug('fileReadInfo.isEOF '+fileReadInfo.isEOF);
    			System.debug('fileReadInfo.filePointer '+fileReadInfo.filePointer);
    			System.debug('totalNoOfRecsParsed : '+totalNoOfRecsParsed);
    			if(fileReadInfo!=null && fileReadInfo.ErrorByLineNoMap!=null && !fileReadInfo.ErrorByLineNoMap.isEmpty()) {
    				ErrorNotAddedToCampaignList.addAll(fileReadInfo.ErrorByLineNoMap.values());
    				totalNoOfRecsParsed+=fileReadInfo.ErrorByLineNoMap.size();
    				System.debug('fileReadInfo.ErrorByLineNoMap.size() : '+fileReadInfo.ErrorByLineNoMap.size());
    			}
    			if(fileReadInfo!=null && fileReadInfo.RowDataSObjByIdenrMap!=null && !fileReadInfo.RowDataSObjByIdenrMap.isEmpty()) {
	    			// Parse the File
	    			totalNoOfRecsParsed+=fileReadInfo.RowDataSObjByIdenrMap.size();
	    			Set<String> ReqDecryptedEmailList = new Set<String>(fileReadInfo.RowDataSObjByIdenrMap.keySet());
	    			System.debug('fileReadInfo.RowDataSObjByIdenrMap : '+fileReadInfo.RowDataSObjByIdenrMap);
					System.debug('totalNoOfRecsParsed : '+totalNoOfRecsParsed);

					// Get the encryped Emails from skyHigh
	    			// SHIELD - String emailListStr = JSON.serialize(ReqDecryptedEmailList);
			        // SHIELD - emailListStr = emailListStr.replace('["', '');
			        // SHIELD - emailListStr = emailListStr.replace('"]', '');
			        // SHIELD - System.debug('JSON Format : '+emailListStr);
			        // SHIELD - List<String> RespEncryptedEmailList = CommonTools.getContactEmailList(emailListStr);
			        // SHIELD - if(Test.isRunningTest()) {
			        	// when in testing, set the response same as request emails
			        // SHIELD - 	RespEncryptedEmailList = new List<String>(ReqDecryptedEmailList); 
			        // SHIELD - }
			        System.debug('ReqDecryptedEmailList : '+ReqDecryptedEmailList);
			        // SHIELD - System.debug('RespEncryptedEmailList : '+RespEncryptedEmailList);
			        
			        // Map the Decrypted Email to Encrypted Emails
			        // SHIELD - if(RespEncryptedEmailList.size() == ReqDecryptedEmailList.size()) {
				    // SHIELD -     Map<String, String> DecEmailByEncEmailMap = new Map<String, String>();
					// SHIELD - 	for(integer i = 0 ; i <RespEncryptedEmailList.size(); ++i){
		            // SHIELD -     	DecEmailByEncEmailMap.put(RespEncryptedEmailList.get(i), ReqDecryptedEmailList.get(i));
		            // SHIELD - 	}
			        
			        	// now query the database based on Encrypted Emails
			        	List<Contact> ContactList = [SELECT Id,Email,DeskCommentaryProhibited__c 
							FROM Contact
							WHERE Email IN :ReqDecryptedEmailList /* SHIELD - :DecEmailByEncEmailMap.keySet()*/ AND Active__c=true];
						System.debug('ContactList.size() : '+ContactList.size());
						
						// now construct the Contact Map based on Decrypted Email
						Map<String, List<Contact>> ContactListByDecryptedEmailMail = new Map<String, List<Contact>>();
						for(Contact oCont : ContactList) {
							// SHIELD - String decryptedEmail = DecEmailByEncEmailMap.get(oCont.Email); 
							// SHIELD - List<Contact> ContList = ContactListByDecryptedEmailMail.containsKey(decryptedEmail) ?
							// SHIELD -  ContactListByDecryptedEmailMail.get(decryptedEmail) : new List<Contact>();
							String emailKey = String.isNotBlank(oCont.Email) ? oCont.Email.toUpperCase() : null;
							List<Contact> ContList = ContactListByDecryptedEmailMail.containsKey(emailKey) ?
													 ContactListByDecryptedEmailMail.get(emailKey) : new List<Contact>();
							ContList.add(oCont);
							ContactListByDecryptedEmailMail.put(emailKey, ContList);
							//List<Contact> ContList = ContactListByDecryptedEmailMail.containsKey(oCont.Email) ?
							//	ContactListByDecryptedEmailMail.get(oCont.Email) : new List<Contact>();
							//ContList.add(oCont);
							//ContactListByDecryptedEmailMail.put(oCont.Email.toUpperCase(), ContList);
							//System.debug(' EMAL : CONT : '+decryptedEmail.toUpperCase()+' : '+ContList.size()+' : '+ContList);
						}
						System.debug('ContactListByDecryptedEmailMail : '+ContactListByDecryptedEmailMail);
						
						// List contruct the List of Contacts to be updated
						Map<String, CampaignMember> CampaignMemberByContIdMap = new Map<String, CampaignMember>();
						Map<Id, Contact> ContactToUpdateMap = new Map<Id,Contact>();
						Set<String> UniqueEmailSet = new Set<String>();
						for(String decryptedEmail : fileReadInfo.RowDataSObjByIdenrMap.keySet()) 
						{
							if(UniqueEmailSet.add(decryptedEmail.toUppercase())) {
								String value = (String)fileReadInfo.RowDataSObjByIdenrMap.get(decryptedEmail).get('DeskCommentaryProhibited__c');
								if(ContactListByDecryptedEmailMail.containsKey(decryptedEmail.toUpperCase())) 
								{
									List<Contact> ContList = ContactListByDecryptedEmailMail.get(decryptedEmail.toUpperCase());
									if(ContList.size()==1) {
										ContList[0].DeskCommentaryProhibited__c=value;
										ContactToUpdateMap.put(ContList[0].Id, ContList[0]);
										CampaignMemberByContIdMap.put(ContList[0].Id, new CampaignMember(ContactId=ContList[0].Id, 
												CampaignId=this.campaignId));
									} else {
										// error - duplicate contacts found for an email-id
										ErrorNOtAddedToCampaignList.add(decryptedEmail+' : Duplicate active Contacts found in the system for this email');
									}
								} else {
									// error - Contact not present for the given Email
									ErrorNOtAddedToCampaignList.add(decryptedEmail+' : No active Contact found in the system for thie email');																
								}
							} else {
								ErrorNOtAddedToCampaignList.add(decryptedEmail+' : Duplicate entry found for update, only first occurance is updated');
							}
						}
						
						System.debug('CampaignMemberByContIdMap : '+CampaignMemberByContIdMap);
						
						
						if(!ContactToUpdateMap.isEmpty()) {
							// First try inserting the CampignMembers
							List<CampaignMember> CampMemList = CampaignMemberByContIdMap.values(); 
							Database.SaveResult[] campSrList = Database.insert(CampMemList, false);
							Integer indx=0;
			        	    String insError;
			        	    Set<String> ContIdToRemoveSet = new Set<String>();
							// success and failure results should be added to a local structure in this transaction before adding
							// there results to the global result structures, in case transaction fails due to some exception then
							// we can manipulate the results accordingly.
			            	for (Database.SaveResult sr : campSrList) {
				                insError='';
				                CampaignMember oCampMem = CampMemList.get(indx);
				                Contact oCont = ContactToUpdateMap.get(oCampMem.ContactId);
				                if (!sr.isSuccess()) {
				                    // Operation failed, so get all errors                
				                    for(Database.Error err : sr.getErrors()) {
				                        insError+=err.getStatusCode() + ': ' + err.getMessage() + '\n';
				                        //System.debug('The following error has occurred.');
				                        //System.debug(err.getStatusCode() + ': ' + err.getMessage());
				                    }
				                    ContIdToRemoveSet.add(oCampMem.ContactId);
				                    ErrorNOtAddedToCampaignList.add(oCont.Email+' : '+insError);
				                }
				                ++indx;
			            	}
			            	// Now the remove the Contact for which CampaignMember Creation failed and these contacts are not updated and
			            	// instead and error is added for these Contacts
			            	for(String contId : ContIdToRemoveSet) {
								ContactToUpdateMap.remove(contId);
								CampaignMemberByContIdMap.remove(contId);		            		
			            	}
			            	
			            	// Now try to Update the Contacts for which we have successfully created the CampaignMembers
			            	if(!ContactToUpdateMap.isEmpty()) {
			            		List<Contact> ContsToUpdateList = ContactToUpdateMap.values(); 
			            		Database.SaveResult[] contSrList = Database.update(ContsToUpdateList, false);
			            		List<CampaignMember>CampaignMemberToUpdList = new List<CampaignMember>();
			            		String updError='';
			            		indx=0;
			            		for (Database.SaveResult sr : contSrList) {
					                updError='';
					                Contact oCont = ContsToUpdateList.get(indx);
					                CampaignMember oCampMem = CampaignMemberByContIdMap.get(oCont.Id);
					                if (sr.isSuccess()) {
					                    LocalSuccessUpdContEmailList.add(oCont.Email);
					                    CampaignMemberToUpdList.add(new CampaignMember(Id=oCampMem.Id, Status='SUCCESS',
					                    	Value__c=oCont.DeskCommentaryProhibited__c));
					                }
					                else {
					                    // Operation failed, so get all errors                
					                    for(Database.Error err : sr.getErrors()) {
					                        updError+=err.getStatusCode() + ': ' + err.getMessage() + '\n';
					                        //System.debug('The following error has occurred.');
					                        //System.debug(err.getStatusCode() + ': ' + err.getMessage());
					                        //System.debug('Account fields that affected this error: ' + err.getFields());
					                    }
					                    CampaignMemberToUpdList.add(new CampaignMember(Id=oCampMem.Id, Status='ERROR',
					                    	Value__c=oCont.DeskCommentaryProhibited__c, Short_Description__c=updError));
					                    LocalErrors.add(oCont.Email+' : '+updError);
					                }
					                ++indx;
			            		}
			            		
			            		// once we have updated the status on CampaignMember, try updating it
			            		// but this time use the update statement instead ofDatabase.update so that if any exceptions are caught
			            		// and process of uploading will stop.
			            		update CampaignMemberToUpdList;
			            	}
		            	}
						 
			        // SHIELD - } else {
			        	// error - RespEncryptedEmailList.size() != ReqDecryptedEmailList.size()
			        // SHIELD - 	unhandledError = 'Number of actual emails from file and number of corresponding encrypted emails from sky-high mis-match';
			        // SHIELD - }
    			}
    		}
    	} catch (Exception ex) {
    		System.debug('Error : '+ex.getMessage());
    		System.debug('Error Stack : '+ex.getStackTraceString());
    		unhandledError=ex.getMessage();
    	}

		if(String.isNotBlank(unhandledError)) {
			//throw new DeskCommentaryProhUpdByContException(unhandledError);
			ErrorAddedToCampaignList.add(unhandledError); 
		}
    	
    	// add the errors or success results
    	SuccessfullyUpdContEmailList.addAll(LocalSuccessUpdContEmailList);
    	ErrorAddedToCampaignList.addAll(LocalErrors);
    	
    	System.debug('SuccessfullyUpdContEmailList.size() : '+SuccessfullyUpdContEmailList.size());
		System.debug('ErrorAddedToCampaignList.size() : '+ErrorAddedToCampaignList.size());
		System.debug('ErrorNOtAddedToCampaignList.size() : '+ErrorNOtAddedToCampaignList.size());
    	
    	if(String.isBlank(unhandledError) && fileReadInfo!=null && !fileReadInfo.isEOF) {
    		// enque the job again.
    		String jobId = System.enqueueJob(new DeskCommentaryProhUpdByContQueueable(campaignId, FieldApiByHeaderIndxMap, 
    			fileBody, fileReadInfo.filePointer, bufferSize, totalNoOfRecsToParse, (batchNo+1), totalNoOfRecsParsed, 
				SuccessfullyUpdContEmailList, ErrorAddedToCampaignList, ErrorNotAddedToCampaignList));
				updateCampaign(campaignId, jobId, 'Processing', 'No');
    	} else {
    		System.debug('EOF....or error');
    		sendEmail(unhandledError);
    		// after seding the email update the campaign description one last time
    		String status='Complete';
    		if(!ErrorAddedToCampaignList.isEmpty() || !ErrorNotAddedToCampaignList.isEmpty()) {
    			status='Completed with Errors';
    		}
    		updateCampaign(campaignId, null, status, 'Yes');
    	}
    } // emd of - function - execute()
    
    private  void updateCampaign(String campId, String jobId, String jobStatus, String emailSent) {
    	System.debug('#### DeskCommentaryProhUpdByContQueueable.updateCampaign()');
    	CampaignService.BulkUpdateJobRunInfo bulkUpldInfo = new CampaignService.BulkUpdateJobRunInfo();
    	if(String.isNotBlank(jobId)) {
			bulkUpldInfo.jobId=jobId;
		}
		bulkUpldInfo.jobStatus = jobStatus;
		bulkUpldInfo.totalNoOfRecsToProc = totalNoOfRecsToParse;
		bulkUpldInfo.totalNoOfRecsProc = totalNoOfRecsParsed;
		bulkUpldInfo.noOfSucc = SuccessfullyUpdContEmailList.size();
		bulkUpldInfo.noOfErrs = ErrorAddedToCampaignList.size();
		bulkUpldInfo.noOfErrsNoInCamp = ErrorNotAddedToCampaignList.size();
		if(bulkUpldInfo.totalNoOfRecsToProc!=null && bulkUpldInfo.totalNoOfRecsToProc > 0 && bulkUpldInfo.totalNoOfRecsProc!=null) {
			Decimal percent = (bulkUpldInfo.totalNoOfRecsProc * 100)/bulkUpldInfo.totalNoOfRecsToProc;
			System.debug(' percent : '+percent);
			bulkUpldInfo.percentProg = ''+percent.round();
			System.debug('bulkUpldInfo.percentProg : '+bulkUpldInfo.percentProg);
		}
		bulkUpldInfo.emailSent=emailSent;
		// update other parameters
		CampaignService.updateBulkUploadCampaignJobStatus(campId, bulkUpldInfo);
    }
    
    /*private  void updateCampaign(String campId, String jobId, String jobStatus, String emailSent) {
    	System.debug('#### DeskCommentaryProhUpdByContQueueable.updateCampaign()');
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
				bulkUpldInfo.jobId=jobId;
			}
			
			bulkUpldInfo.jobStatus = jobStatus;
			bulkUpldInfo.totalNoOfRecsToProc = totalNoOfRecsToParse;
			bulkUpldInfo.totalNoOfRecsProc = totalNoOfRecsParsed;
			bulkUpldInfo.noOfSucc = SuccessfullyUpdContEmailList.size();
			bulkUpldInfo.noOfErrs = ErrorAddedToCampaignList.size();
			bulkUpldInfo.noOfErrsNoInCamp = ErrorNotAddedToCampaignList.size();
			if(bulkUpldInfo.totalNoOfRecsToProc!=null && bulkUpldInfo.totalNoOfRecsToProc > 0 && bulkUpldInfo.totalNoOfRecsProc!=null) {
				Decimal percent = (bulkUpldInfo.totalNoOfRecsProc * 100)/bulkUpldInfo.totalNoOfRecsToProc;
				System.debug(' percent : '+percent);
				bulkUpldInfo.percentProg = ''+percent.round();
				System.debug('bulkUpldInfo.percentProg : '+bulkUpldInfo.percentProg);
			}
			bulkUpldInfo.emailSent=emailSent;
			// update other parameters
			Campaign oCamp = new Campaign(Id=campaignId, Description=JSON.serialize(bulkUpldInfo));
			update oCamp;
    	}
    }*/
    
   	private void sendEmail(String unhandledError) {
   		System.debug('Sending email...');
   		// send an email to the user
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setTargetObjectId(UserInfo.getUserId());
		//mail.setToAddresses(new String[]{'abcd@xyz.com'});

    	// Set the email subject
    	String subject = 'UPLOAD : '+(String.isNotBlank(System.Label.Desk_Commentary_Label) ? System.Label.Desk_Commentary_Label : 'Desk Commentary Allowed')+' upload for Contacts Completed';
    	mail.setSubject(subject);
    	
    	/*String reportURL; 
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
    	}*/
	
		String htmlBody ='<font face="verdana"><b>Upload summary:</b>'+
							'<br/>Total number of entries in file : '+totalNoOfRecsToParse+
							'<br/>Total number of Contacts Parsed: '+totalNoOfRecsParsed+
							'<br/>Total number of Contacts updated successfully and results added to Campaign : '+SuccessfullyUpdContEmailList.size()+
							'<br/>Total number of Contacts failed to update and results added to Campaign : '+ErrorAddedToCampaignList.size()+
							'<br/>Total number of Errors not added to Campaign and reported in email : '+ErrorNotAddedToCampaignList.size()+
							'<br/>Bulk Upload Report (please open it in Google Chrome) : <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+CampaignService.getBulkUploadReportURL(campaignId, 'Bulk_Upload_Campaign_Report')+'">Report URL</a>';
		
		if(String.isNotBlank(unhandledError)) {
			htmlBody+='<br/><br/>Upload Process interrupted due to an error : '+unhandledError+'</br></br>';
		}	
		if(!ErrorNotAddedToCampaignList.isEmpty()) {
			htmlBody+='<br/><br/><b>Upload Details : </b>';
			
			htmlBody+='<br/>List of Errors that cannot be added to Campaign : <br/>';
			htmlBody+='<table><tr><th align="left">Errors Not added to Campaign</th></tr>';
			for(String errs : ErrorNotAddedToCampaignList) {
				htmlBody+='<tr><td>'+errs+'</td></tr>';
			}
			htmlBody+='</table>';
	
			/* // Do not send error and success results as they are added to Campaign
			htmlBody+='<br/>List of Errors that are added to Campaign : <br/>';
			htmlBody+='<table><tr><th align="left">Errors added to Campaign</th></tr>';
			for(String errs : ErrorAddedToCampaignList) {
				htmlBody+='<tr><td>'+errs+'</td></tr>';
			}
			htmlBody+='</table>';
	    	
	    	htmlBody+='<br/>List of Contact Email updated successfully : <br/>';
			htmlBody+='<table><tr><th align="left">Contact Emails updated</th></tr>';
			for(String email : SuccessfullyUpdContEmailList) {
				htmlBody+='<tr><td>'+email+'</td></tr>';
			}
			htmlBody+='</table>';	
			*/
		}
		htmlBody+='</font>';
		system.debug('htmlBody : '+htmlBody);
    	mail.setHtmlBody(htmlBody);
    	mail.setSaveAsActivity(false);
    	// Finally send email
    	Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
    	System.debug('Email Sent');
   	} 
   
    public class DeskCommentaryProhUpdByContException extends Exception {}
}