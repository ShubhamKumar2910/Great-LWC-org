/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : Controller class for lightning compoment c:BulkUpdateDeskCommentaryProhibited
**/  
public without sharing class BulkUpdateDeskCommentaryProhController {
	
	private static final Integer FILE_SIZE_LIMIT = 500000; // Around 5 MB 
	//private static final String ACCOUNT_RT_NAME_RG_ACCOUNT = 'RG Account';
	//private static final String ACCOUNT_RT_NAME_RM_ACCOUNT = 'RM Account';
	//private static Map<String, Schema.RecordTypeInfo> AccountRecTypeInfoByRecTypeNameMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
	//private static Map<String, Schema.RecordTypeInfo> CampaignRecTypeInfoByRecTypeNameMap = Schema.SObjectType.Campaign.getRecordTypeInfosByName();
	private static final String CAMPAIGN_RT_NAME_BULK_UPLOAD = 'Bulk_Upload';
	private static final Integer REPORT_NO_OF_UPLOAD_JOBS=25;
	private static final Integer BATCH_SIZE = String.isNotBlank(Label.MiFID_II_Bulk_Update_Default_Batch_Size) ?
		Integer.valueOf(Label.MiFID_II_Bulk_Update_Default_Batch_Size) : 200;
	@TestVisible
	private static Map<String, Map<String, String>> FieldApiByFieldLabelMapByLoadTypeMap;	
	//private static Map<String, String> FieldApiByFieldLabelMap;
	static {
		FieldApiByFieldLabelMapByLoadTypeMap=new Map<String, Map<String, String>>(); 
		// RG Account
		Map<String, String> FieldApiByFieldLabelMap=new Map<String, String>();
		FieldApiByFieldLabelMap.put('RG Acc Name Or Unique Identifier', 'Identifier');
		FieldApiByFieldLabelMap.put(String.isNotBlank(System.Label.Desk_Commentary_Label) ? System.Label.Desk_Commentary_Label : 'Desk Commentary Allowed', 'DeskCommentaryProhibited__c');
		FieldApiByFieldLabelMapByLoadTypeMap.put('RG', FieldApiByFieldLabelMap);
		// RM Account
		FieldApiByFieldLabelMap=new Map<String, String>(); 
		FieldApiByFieldLabelMap.put('RM Acc Name Or Unique Identifier', 'Identifier');
		FieldApiByFieldLabelMap.put(String.isNotBlank(System.Label.Desk_Commentary_Label) ? System.Label.Desk_Commentary_Label : 'Desk Commentary Allowed', 'DeskCommentaryProhibited__c');
		FieldApiByFieldLabelMapByLoadTypeMap.put('RM', FieldApiByFieldLabelMap);
		// Contact
		FieldApiByFieldLabelMap=new Map<String, String>(); 
		FieldApiByFieldLabelMap.put('Email Id', 'Identifier');
		FieldApiByFieldLabelMap.put(String.isNotBlank(System.Label.Desk_Commentary_Label) ? System.Label.Desk_Commentary_Label : 'Desk Commentary Allowed', 'DeskCommentaryProhibited__c');
		FieldApiByFieldLabelMapByLoadTypeMap.put('CONT', FieldApiByFieldLabelMap);
	}
	

	@AuraEnabled 
    public static BulkUpdDeskCommInitInfo initialize() {
    	System.debug('#### BulkUpdateDeskCommentaryProhController.initialize()');
    	BulkUpdDeskCommInitInfo bulkUpdDskCommInit = new BulkUpdDeskCommInitInfo();
    	try {
    		// delete older empty campaigns
    		deleteOldEmptyCampaigns();
    		// get any jobs started/in progress/queued
    		String[] JobsInProcessStatusesList = new String[]{'Holding','Queued','Preparing','Processing'};
    		List<AsyncApexJob> AsyncApexJobList = getJobDetails(null, JobsInProcessStatusesList);
    		if(!AsyncApexJobList.isEmpty()) {
    			bulkUpdDskCommInit.runningJobId = AsyncApexJobList[0].Id;
    			System.debug('JOB ID FOUND : '+bulkUpdDskCommInit.runningJobId);
    			bulkUpdDskCommInit.campaignId = CampaignService.getBulkUploadCampaignRec(AsyncApexJobList[0].Id, CAMPAIGN_RT_NAME_BULK_UPLOAD, 'BulkUpdateDeskCommentary');
    			System.debug('bulkUpdDskCommInit.campaignId : '+bulkUpdDskCommInit.campaignId);
    		} else {
				bulkUpdDskCommInit.campaignId = CampaignService.getBulkUploadCampaignRec(null, CAMPAIGN_RT_NAME_BULK_UPLOAD, 'BulkUpdateDeskCommentary');
				//CampaignService.setupCampaignMemStatus(bulkUpdDskCommInit.campaignId);    			
    		}
    		//bulkUpdDskCommInit.PreviousJobRunList=new List<BulkUpdDeskCommPreviousJobRunInfo>();
    		bulkUpdDskCommInit.PreviousJobRunList = populateJobInfo();
    		
    	} catch (Exception ex) {
    		System.debug('Error : '+ex.getMessage());
    		System.debug('Error stack: '+ex.getStackTraceString());
    		throw new AuraHandledException('Controller Initilization Failed : '+ex.getMessage());
    	}
    	
    	return bulkUpdDskCommInit;
    }
    
    @AuraEnabled 
	public static String downloadFileTempl(String campaignId, Boolean isLoadByRGAcc, Boolean isLoadByRMAcc, 
			Boolean isLoadByEmail) {
		System.debug('#### BulkUpdateDeskCommentaryProhController.downloadFileTempl()');
		String contDocId;
		try {
			String t;
			String loadType;
			String fileBodyTxt = '';
			if(isLoadByRGAcc) {
				fileBodyTxt+='RGXXXXXX,US;EMEA;AEJ\nRG_ACC_NAME,EMEA;US\n';
				t='RG_Template';
				loadType='RG';				
			} else if (isLoadByRMAcc) {
				fileBodyTxt+='RMXXXXXX,US;EMEA;AEJ\nRM_ACC_NAME,EMEA;US\n';
				t='RM_Template';
				loadType='RM';
			} else if(isLoadByEmail) {
				fileBodyTxt+='abcd@xyz.com,US;EMEA;AEJ\nlmn@opq.com,EMEA;US\n';
				t='Email_Template';
				loadType='CONT';
			}

			String fileHeader='';
			Map<String, String> FieldApiByFieldLabelMap = FieldApiByFieldLabelMapByLoadTypeMap.get(loadType);
			for(String colHeader : FieldApiByFieldLabelMap.keySet()) {
				fileHeader+=colHeader+',';
			}
			fileHeader.removeEnd(',');
			fileHeader+='\n';
			
			// append file header and example file body
			fileBodyTxt = fileHeader+fileBodyTxt; 
			
			Blob bodyBlob=Blob.valueOf(fileBodyTxt); 
			ContentVersion oContVer = new ContentVersion(
				Title=t, 
				PathOnClient ='/'+t+'.csv',
				VersionData = bodyBlob, 
				origin = 'H'
			);
			insert oContVer;
			contDocId= [SELECT contentdocumentid FROM ContentVersion WHERE Id=:oContVer.Id].contentdocumentid;
			
			ContentDocumentLink oContentlink = new ContentDocumentLink();
            oContentlink.LinkedEntityId = campaignId;
            oContentlink.contentdocumentid = contDocId;
            oContentlink.ShareType = 'V';
            insert oContentlink; 
			
		} catch(Exception ex) {
			System.debug('Error : '+ex.getMessage());
    		System.debug('Error stack: '+ex.getStackTraceString());
    		throw new AuraHandledException('File Download Template Failed : '+ex.getMessage());
		}	 	
		
		return contDocId;
	}
	
	
	
    @AuraEnabled 
    public static BulkUpdDeskValidateFile verifyUploadedFile(String uploadedDocId, Boolean isLoadByRGAcc, Boolean isLoadByRMAcc, Boolean isLoadByEmail) {
    	System.debug('#### BulkUpdateDeskCommentaryProhController.verifyUploadedFile()');
    	String errors='';
		BulkUpdDeskValidateFile validateFileInfo = new BulkUpdDeskValidateFile();
		try {
    		// Fetch the file from DB and 
			List<ContentVersion> ContentVersionList = [SELECT Id,VersionData FROM ContentVersion WHERE ContentDocumentId=:uploadedDocId];
			if(!ContentVersionList.isEmpty()) {
				// Currently supports around 5MB file size otherwise the ContentVersionList[0].VersionData.split('\n')
				// throws Governor Limits - 'Regex Too Complicated' exception
				// We see the same exception even if this is ran in ASynch job, it only sopports boby size < 500000
				Blob fileBody = ContentVersionList[0].VersionData;
				// delete the uploaded file for contacts right away
				List<ContentDocument> ContDocList = [SELECT Id FROM ContentDocument WHERE Id=:uploadedDocId];
				delete ContDocList;
				if(fileBody.size() <= FILE_SIZE_LIMIT) {
					//Map<String, String>FieldApiByFieldLabelMap=new Map<String, String>();
					//FieldApiByFieldLabelMap.put('Identifier', 'Identifier');
					//FieldApiByFieldLabelMap.put('VALUE', 'DeskCommentaryProhibited__c');
					if(isLoadByEmail) {
						// after the file load verify that header is correct
						Map<Integer, String> FieldApiByHeaderIndxMap = FileParserUtil.parseHeader(fileBody,
								FieldApiByFieldLabelMapByLoadTypeMap.get('CONT'), '\n', ',');
						validateFileInfo.fileBodyTxt = fileBody.toString();
					} else if(isLoadByRGAcc || isLoadByRMAcc) {
						String uploadType = (isLoadByRGAcc) ? 'RG' : 'RM';
						Map<String, sObject> ParsedDataByIdentMap = FileParserUtil.parseFile(fileBody, 'Contact', 
							FieldApiByFieldLabelMapByLoadTypeMap.get(uploadType), '\n', ',');
						if(ParsedDataByIdentMap!=null && !ParsedDataByIdentMap.isEmpty()) {
							//if(isLoadByRGAcc || isLoadByRMAcc) {
							// Acc RT will aloow us to write optimized query as RT is indexed
							// and also validate on specific Account Tyoes only
							Set<String>IdentifierSet = new Set<String>(ParsedDataByIdentMap.keySet());
							// cleaned the Parsed Data once we get the keys to free some heap memory
							ParsedDataByIdentMap.clear();
							
							String accRTId;
							String keyFieldName;
							String accType;
							String query='SELECT Id,Name,RDM_Org_ID__c,Parent_RDM_Org_ID__c FROM Account ';
							if(isLoadByRGAcc) {
								accType='RG';
								keyFieldName='RDM_Org_ID__c';
								//accRTId = AccountRecTypeInfoByRecTypeNameMap.get(ACCOUNT_RT_NAME_RG_ACCOUNT).getRecordTypeId();
								accRTId = AccountService.AccountRecTypeInfoByRecTypeDevNameMap.get(AccountService.ACCOUNT_RT_NAME_RG_ACCOUNT).getRecordTypeId();
								 
								query+='WHERE RecordTypeId=:accRTId AND Active__c=true AND '+
								// RDM_Org_ID__c is an External Id field - so unique and indexed, so query on this field first
								'((Name IN :IdentifierSet) OR '+ 
								'(RDM_Org_ID__c IN :IdentifierSet)) ';
							} else if(isLoadByRMAcc) {
								accType='RM';
								keyFieldName='RDM_Org_ID__c';
								//accRTId = AccountRecTypeInfoByRecTypeNameMap.get(ACCOUNT_RT_NAME_RM_ACCOUNT).getRecordTypeId();
								accRTId = AccountService.AccountRecTypeInfoByRecTypeDevNameMap.get(AccountService.ACCOUNT_RT_NAME_RM_ACCOUNT).getRecordTypeId();
								query+='WHERE RecordTypeId=:accRTId AND Active__c=true AND '+
								// Parent_RDM_Org_ID__c is a formula field so lets not filter on it first
								'((RDM_Org_ID__c IN :IdentifierSet) OR '+
								'(Name IN :IdentifierSet)) ';
							}
							System.debug('keyFieldName : '+keyFieldName);
							System.debug('accRTId : '+accRTId);
							System.debug('Query : '+query);
							List<Account> AccList = Database.query(query);
							Map<String,Set<String>> AccKeySetByAccName=new Map<String,Set<String>>();
							Map<String,String> AccNameByAccKey=new Map<String,String>();
							for(Account oAcc : AccList) {
								// Validate if there are Accounts with same name
								// if Account.Name is present in the Identefier column in file
								// And there are multiple Accounts with same name in the System the we will get the following error
								String accName=oAcc.Name.toUpperCase();
								if(IdentifierSet.contains(accName) && AccKeySetByAccName.containsKey(accName) && !AccKeySetByAccName.get(accName).isEmpty()) {
									//errors+='Duplicate Accounts with same Account Name Or RM/RG Account key and Account Name both are present in the upload file  : '+oAcc.Name+' => '+(String)oAcc.get(keyFieldName)+'\n';
									errors+='Duplicate Accounts with same Account Name found, in this case load using '+accType+' key for specific account : '+accName+' => '+
											(String)oAcc.get(keyFieldName)+','+AccKeySetByAccName.get(accName)+'\n';
									break;
								} else {
									// no error
									//AccKeyByAccName.put(oAcc.Name, (String)oAcc.get(keyFieldName));
									Set<String>AccKeySet = AccKeySetByAccName.containsKey(accName) ? 
											AccKeySetByAccName.get(accName) : new Set<String>();
									AccKeySet.add((String)oAcc.get(keyFieldName));  
									AccKeySetByAccName.put(accName, AccKeySet);	
								}
								
								// Validate if there are Accounts with same name
								String key=((String)oAcc.get(keyFieldName)).toUpperCase();
								if(String.isNotBlank(key)) {
									// no error
									AccNameByAccKey.put(key, accName);
								}
							}
							System.debug('AccKeySetByAccName : '+AccKeySetByAccName);
							System.debug('AccNameByAccKey : '+AccNameByAccKey);
							
							if(String.isBlank(errors)) {
								// now loop through all keySet and check if it exists in either of the map and
								for(String identifier : IdentifierSet) {
									// e.g. in DB there are 2 acconts with following Acc Name -> RMkey -> IsActive 
									// Acc1 => RM1 ->　true
									// Acc1 => RM2　-> false
									// And the following file is loaded
									// Identifier, VALUE
									// RM1	,  US
									// RM2  ,  EMEA
									// Now in the above file second row for RM2 will now load as it is not an active account
									// after running through this code we will get the following map structures in the code
									// AccKeySetByAccName :　＜Ａｃｃ１　＜ＲＭ１>>
									// AccNameByAccKey　　　　： <RM1, Acc1>
									//if(!(AccKeyByAccName.containsKey(identifier) || AccNameByAccKey.containsKey(identifier))) {
									if(!(AccKeySetByAccName.containsKey(identifier) || AccNameByAccKey.containsKey(identifier))) {
										// error 
										errors+='No active Account Name or '+accType+' key found for an Account with identifier value : '+identifier+'\n';
									} 
									// Finally check the inderct duplicates
									//e.g.
									//
									// IdentifierSet : {
									//	BFAM PARTNERS (HONG KONG) LTD, 
									//	RM255560, 
									//	RM256018, 
									//	RM256991, 
									//	RM269150, 
									//	RM279430, 
									//	RM385296, 
									//	RM436648, 
									//	RM445420, 
									//	RM777777
									//}
									//
									//AccKeyByAccName : {
									//	Adlee RM=RM777777, 
									//	BFAM PARTNERS (HONG KONG) LTD=RM436648, 
									//	BLACKROCK INVESTMENT MANAGEMENT UK=RM255560, 
									//	EMERGENT ASSET MANAGEMENT UK=RM256018, 
									//	MILLGATE CAPITAL LONDON=RM269150, 
									//	NEWSMITH CAPITAL PARTNERS (ASIA) PTE LTD=RM279430, 
									//	PIMCO ADVISORS CT=RM385296, 
									//	PIMCO ASIA LIMITED (HK)=RM445420, 
									//	PROSPECTIVE UK ACCOUNTS UK=RM256991
									//}
									//
									// AccNameByAccKey : {
									//	RM255560=BLACKROCK INVESTMENT MANAGEMENT UK, 
									//	RM256018=EMERGENT ASSET MANAGEMENT UK, 
									//	RM256991=PROSPECTIVE UK ACCOUNTS UK, 
									//	RM269150=MILLGATE CAPITAL LONDON, 
									//	RM279430=NEWSMITH CAPITAL PARTNERS (ASIA) PTE LTD, 
									//	RM385296=PIMCO ADVISORS CT, 
									//	RM436648=BFAM PARTNERS (HONG KONG) LTD, 
									//	RM445420=PIMCO ASIA LIMITED (HK), 
									//	RM777777=Adlee RM
									//}
									//
									// then the following condition will be false for - identifier = RM279430
									// but will be true for - identifier = RM436648 Or for identifier = BFAM PARTNERS (HONG KONG) LTD
									//else if(IdentifierSet.contains(AccKeyByAccName.get(identifier)) || IdentifierSet.contains(AccNameByAccKey.get(identifier))) {
									else if(IdentifierSet.contains(AccNameByAccKey.get(identifier))) {
										// indirect duplicates
										errors+='Indirect duplicate records found by Account Name and '+accType+' key - for identifier : '+identifier+' => '+AccNameByAccKey.get(identifier)+'\n';
										break;
									} else {
										// indirect duplicates
										Set<String> AccKeySet = AccKeySetByAccName.get(identifier);
										if(AccKeySet!=null) {
											for(String key : AccKeySet) {
												if(IdentifierSet.contains(key)) {
													errors+='Indirect duplicate records found by Account Name and '+accType+' key - for identifier : '+identifier+' => '+key+'\n';
													break;
												}
											}
											if(String.isNotBlank(errors)) {
												break;
											}	
										}
									} // end of - else
								}
							}
							//} // end of - for(String identifier : IdentifierSet) {
						} else {
							errors='File Parsing errors';
						}
						if(String.isBlank(errors)) {
							validateFileInfo.fileBodyTxt = fileBody.toString();
						}
					}
				} else {// if file-body size > 5MB then throw an exception
					errors='Maximum file size of around 5MB is supported, the file being uploaded is greater than 5MB';				
				} 
			} 
		} catch(Exception ex) {
    		//throw new AuraHandledException('File Parsing Failed : '+ex.getMessage());
    		//throw new ParseCSVException('FAILED : '+ex.getMessage());
    		errors = ex.getMessage();
    	}
    	
    	validateFileInfo.errors = errors;
    	return validateFileInfo; 
    }
    
    @AuraEnabled 
    public static BulkUpdDeskCommInitInfo startBulkUpload(String campaignId, String fileBodyTxt,
    		Boolean isLoadByRGAcc, Boolean isLoadByRMAcc, Boolean isLoadByEmail) {
    	System.debug('#### BulkUpdateDeskCommentaryProhController::startBulkUpload()');
    	System.debug('campaignId : '+campaignId);
    	String error='';
    	BulkUpdDeskCommInitInfo bulkUpdDskCommInit = new BulkUpdDeskCommInitInfo();
    	try {
    		//first check if there is any running job 
    		// get any jobs started/in progress/queued
    		String[] JobsInProcessStatusesList = new String[]{'Holding','Queued','Preparing','Processing'};
    		List<AsyncApexJob> AsyncApexJobList = getJobDetails(null, JobsInProcessStatusesList);
    		System.debug('AsyncApexJobList : '+AsyncApexJobList);
    		if(!AsyncApexJobList.isEmpty()) {
    			// this error message is matched exactly as it on UI-Controller side to refresh the screen
    			error='An upload job is already started by another user';
    		} else {
    			bulkUpdDskCommInit.campaignId = campaignId;
	    		//List<ContentVersion> ContentVersionList = [SELECT Id,VersionData FROM ContentVersion WHERE ContentDocumentId=:uploadedDocId];
				if(String.isNotBlank(fileBodyTxt)) {
					Blob fileBody = Blob.valueOf(fileBodyTxt);
					CampaignService.BulkUpdateJobRunInfo jobRunInfo;
					if(isLoadByRGAcc || isLoadByRMAcc) {
						jobRunInfo = startBulkUploadByAcc(campaignId, fileBody, isLoadByRGAcc, isLoadByRMAcc);
					} else if (isLoadByEmail) {
						jobRunInfo = startBulkUploadByCont(campaignId, fileBody);
					} else {
						error='Unknown Load Type';
					}
					if(jobRunInfo!=null) {
						bulkUpdDskCommInit.runningJobId = jobRunInfo.jobId; 
						bulkUpdDskCommInit.PreviousJobRunList = new List<CampaignService.BulkUpdateJobRunInfo>();
						bulkUpdDskCommInit.PreviousJobRunList.add(jobRunInfo); 
					}
				} else {
					error='Error : Empty file boby';
				}
    		}
    	} catch(Exception ex) {
    		error=ex.getMessage();
    	}
    	
    	if(String.isNotBlank(error)) {
    		System.debug('Found Error : '+error);
    		throw new AuraHandledException(error);
    	}
    	System.debug('BEFORE RETURN bulkUpdDskCommInit : '+ bulkUpdDskCommInit);
    	return bulkUpdDskCommInit;
	}
    
    
    @AuraEnabled 
    public static CampaignService.BulkUpdateJobRunInfo startBulkUploadByAcc(String campaignId, Blob fileData, 
    		Boolean isLoadByRGAcc, Boolean isLoadByRMAcc) {
    	System.debug('#### BulkUpdateDeskCommentaryProhController::startBulkUploadByAcc()');
    	System.debug('campaignId : '+campaignId);
    	CampaignService.BulkUpdateJobRunInfo bulkUpldInfo;
    	try {
    			String uploadType = (isLoadByRGAcc) ? 'RG' : 'RM';
				Map<String, sObject> Data = FileParserUtil.parseFile(fileData, 'Contact', 
						FieldApiByFieldLabelMapByLoadTypeMap.get(uploadType), '\n', ',');
				
				if(Data!=null && !Data.isEmpty()) {
					UpdateContactsBatch.IdentifierType identType;
					if(isLoadByRGAcc) {
						identType=UpdateContactsBatch.IdentifierType.ACC_RG_ACC; 
					} else if(isLoadByRMAcc) {
						identType=UpdateContactsBatch.IdentifierType.ACC_RM_ACC; 
					} 

    				//DeskCommentaryProhibitedUpdateBatch batcObj = new DeskCommentaryProhibitedUpdateBatch(
					//	campaignId, identType,
					//	Data);
					String subject = 'UPLOAD : '+(String.isNotBlank(System.Label.Desk_Commentary_Label) ? 
						System.Label.Desk_Commentary_Label : 'Desk Commentary Allowed')+' upload for Contacts Completed';
					UpdateContactsBatch batcObj = new UpdateContactsBatch(campaignId, identType, null, null, subject, Data);
					// start Job
					String jobId = Database.executeBatch(batcObj, BATCH_SIZE);
					bulkUpldInfo = new CampaignService.BulkUpdateJobRunInfo();
					bulkUpldInfo.jobId=jobId;
					if(isLoadByRGAcc) {
						bulkUpldInfo.uploadTypeIcon='standard:investment_account';
						bulkUpldInfo.uploadType='RG Account';						
					} else if(isLoadByRMAcc) {
						bulkUpldInfo.uploadTypeIcon='standard:account';						
						bulkUpldInfo.uploadType='RM Account'; 
					}
					//bulkUpldInfo.reportURL='/one/one.app#/sObject/' + getCampResltReportId() + '/view?fv0=' + campaignId;
					//bulkUpldInfo.jobRunDate = ''+DateTime.now();
			 		bulkUpldInfo.jobStatus='Queued';
			 		bulkUpldInfo.percentProg='0';
			 		bulkUpldInfo.emailSent='No';
			 		bulkUpldInfo.jobType = CampaignService.BulkUploadCampaignJobTypes.BULK_UPLOAD_DESK_COMMENTARY.name();
					//Campaign oCamp = new Campaign(Id=campaignId, Description=JSON.serialize(bulkUpldInfo));
					//update oCamp;
					CampaignService.updateBulkUploadCampaignJobStatus(campaignId, bulkUpldInfo);
    			}
			//}
    	} catch(Exception ex) {
    		throw new AuraHandledException('File Upload failed with an error : '+ex.getMessage());
    		//throw new ParseCSVException('FAILED : '+ex.getMessage());
    	}
    	return bulkUpldInfo;
    }
    
    @AuraEnabled 
    public static CampaignService.BulkUpdateJobRunInfo startBulkUploadByCont(String campaignId, Blob fileData) {
    	System.debug('#### BulkUpdateDeskCommentaryProhController::startBulkUploadByCont');
		CampaignService.BulkUpdateJobRunInfo bulkUpldInfo;
		try{
			Map<Integer, String> FieldApiByHeaderIndxMap = FileParserUtil.parseHeader(fileData,  
					FieldApiByFieldLabelMapByLoadTypeMap.get('CONT'), '\n', ',');
		
			DeskCommentaryProhUpdByContQueueable loadJob = new DeskCommentaryProhUpdByContQueueable(campaignId, 
				FieldApiByHeaderIndxMap, fileData, 1, BATCH_SIZE);
			String jobId = System.enqueueJob(loadJob);
			bulkUpldInfo = new CampaignService.BulkUpdateJobRunInfo();
			bulkUpldInfo.jobId=jobId;
			bulkUpldInfo.uploadTypeIcon='standard:contact';
			bulkUpldInfo.uploadType='Contact';
			//bulkUpldInfo.reportURL='/one/one.app#/sObject/' + getCampResltReportId() + '/view?fv0=' + campaignId;
			//bulkUpldInfo.jobRunDate = ''+DateTime.now();
	 		bulkUpldInfo.jobStatus='Queued';
	 		bulkUpldInfo.percentProg='0';
	 		bulkUpldInfo.emailSent='No';
	 		//Campaign oCamp = new Campaign(Id=campaignId, Description=JSON.serialize(bulkUpldInfo));
			//update oCamp;
			bulkUpldInfo.jobType = CampaignService.BulkUploadCampaignJobTypes.BULK_UPLOAD_DESK_COMMENTARY.name();
			CampaignService.updateBulkUploadCampaignJobStatus(campaignId, bulkUpldInfo);
			//}
		} catch (Exception ex) {
			System.debug('Error : '+ex.getMessage());
		}
		
		return bulkUpldInfo;
    }
    
    private static void deleteOldEmptyCampaigns() {
    	System.debug('#### BulkUpdateDeskCommentaryProhController::deleteOldEmptyCampaigns');
    	try {
    		//String campRTId = CampaignRecTypeInfoByRecTypeNameMap.get(CAMPAIGN_RT_NAME_BULK_UPLOAD).getRecordTypeId();
    		String campRTId = CampaignService.CampaignRecTypeInfoByRecTypeDevNameMap.get(CampaignService.CAMPAIGN_RT_NAME_BULK_UPLOAD).getRecordTypeId();
    		String campNameSrchStr = 'BulkUpdateDeskCommentary-'+UserInfo.getUserId()+'-'+'__-__-____-%';
    		System.debug('campNameSrchStr : '+campNameSrchStr);
			List<Campaign> CampaignList = [SELECT Id,Name,Description 
				FROM Campaign 
				WHERE RecordTypeId=:campRTId AND 
					Name LIKE :campNameSrchStr AND
					CreatedDate < YESTERDAY LIMIT 1000];
 			List<Campaign> CampToDelList = new List<Campaign>();
 			for(Campaign oCamp : CampaignList) {
 				if(String.isBlank(oCamp.Description)) {
 					CampToDelList.add(ocamp);
 				}
 			} 
 			if(!CampToDelList.isEmpty()) {
 				delete CampToDelList;
 			}
    	} catch (Exception ex) {
    		System.debug('Absorb the exception as we just try to clean some old data');
    		
    	}
    } 
    
	@AuraEnabled
	public static BulkUpdDeskCommInitInfo getJobStatus(String campaignId) {
		System.debug('#### BulkUpdateDeskCommentaryProhController::getJobStatus');	
		System.debug('getJobStatus- campaignId '+campaignId);
		BulkUpdDeskCommInitInfo bulkUpdDskCommInit = new BulkUpdDeskCommInitInfo();
		try {
			CampaignService.BulkUpdateJobRunInfo bulkUpldInfo = CampaignService.getBulkUploadJobDetails(campaignId);
	        System.debug('JOB STATUS bulkUpldInfo : '+bulkUpldInfo);
	        if(bulkUpldInfo!= null && String.isNotBlank(bulkUpldInfo.jobId)) {
	        	List<AsyncApexJob> AsyncApexJobList = getJobDetails(new List<String>{bulkUpldInfo.jobId}, 
	        		new List<String>{'Holding','Queued','Preparing','Processing'});
	        	if(!AsyncApexJobList.isEmpty()) {
	        		// this means the Job with jobId in Campaign desription is still running
	        		bulkUpdDskCommInit.campaignId = campaignId;
					bulkUpdDskCommInit.runningJobId=bulkUpldInfo.jobId;
	        	} else {
	        		// this means the Job with jobId in Campaign desription is not running anymore
	        		bulkUpdDskCommInit.campaignId = CampaignService.getBulkUploadCampaignRec(null, CAMPAIGN_RT_NAME_BULK_UPLOAD, 'BulkUpdateDeskCommentary');
					bulkUpdDskCommInit.runningJobId = null;
					//setupCampaignMemStatus(bulkUpdDskCommInit.campaignId);
	        	}
	        	bulkUpdDskCommInit.PreviousJobRunList = new List<CampaignService.BulkUpdateJobRunInfo>();
				bulkUpdDskCommInit.PreviousJobRunList.add(bulkUpldInfo);
			}
		} catch(Exception ex) {
			throw new AuraHandledException('Error in refreshing Job Status : '+ex.getMessage());
		}
		return bulkUpdDskCommInit;
	}
    
    private static List<CampaignService.BulkUpdateJobRunInfo> populateJobInfo() {
    	System.debug('#### BulkUpdateDeskCommentaryProhController::populateJobInfo');
    	List<CampaignService.BulkUpdateJobRunInfo> PerviousJobRunInforList = new List<CampaignService.BulkUpdateJobRunInfo>();  
    	try {
    		PerviousJobRunInforList = CampaignService.getPreviousJobRunInfoForUser(UserInfo.getUserId(), 
    				CampaignService.BulkUploadCampaignJobTypes.BULK_UPLOAD_DESK_COMMENTARY.name(), REPORT_NO_OF_UPLOAD_JOBS);
    	} catch(Exception ex) {
    		System.debug('Error : '+ex.getMessage());
    		// absorb the exception here 
    	}
    	return PerviousJobRunInforList;
    }
    
    private static List<AsyncApexJob> getJobDetails(List<String> JobIdList, List<String> StatusList) {
    	System.debug('#### BulkUpdateDeskCommentaryProhController::getJobDetails');
    	List<AsyncApexJob> AsyncApexJobList = new List<AsyncApexJob>(); 
		//List<AsyncApexJob> AsyncApexJobList = [SELECT Id,Status,ApexClassID FROM AsyncApexJob 
		//		WHERE ApexClassID =:ApexClassList[0].Id AND Status IN :JobsInProcessStatusesList];
		Map<Id,ApexClass> ApexClassMap = new Map<Id,ApexClass>([SELECT Id,Name,Status 
			FROM ApexClass WHERE Name IN ('DeskCommentaryProhUpdByContQueueable', 'UpdateContactsBatch') AND Status='Active']);
		List<Id> ApexLcassIdList = new List<Id>(ApexClassMap.keySet());
		List<String> JobTypeList = new List<String>{'BatchApex','Queueable'}; 
		String query = 'SELECT Id,JobItemsProcessed,CompletedDate,JobType,NumberOfErrors,Status,TotalJobItems,createdDate '+
			'FROM AsyncApexJob '+
			'WHERE ApexClassID IN :ApexLcassIdList AND '+
			'Status IN :StatusList AND '+
			'JobType IN :JobTypeList ';
		if(JobIdList!=null && !JobIdList.isEmpty()) {
			query+=' AND Id IN :JobIdList';
		}
		
		query+=' ORDER BY createdDate DESC';
		
		System.debug('query : '+query);
		AsyncApexJobList = Database.query(query);
    	
    	return AsyncApexJobList;
    }
    
    public class BulkUpdDeskValidateFile{
		@AuraEnabled
        public String errors;
        @AuraEnabled
        public String fileBodyTxt;
	}
    
    public class BulkUpdDeskCommInitInfo {
		@AuraEnabled
        public String campaignId;
        @AuraEnabled
        public String runningJobId;
        @AuraEnabled
        public List<CampaignService.BulkUpdateJobRunInfo> PreviousJobRunList;
	}
}