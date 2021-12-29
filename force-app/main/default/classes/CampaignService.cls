/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : This class implements the Service class for Campaign object to implement 
** 				  business processes around campaign object.
**
** Consumer of the Service Layer : Trigger, Batch, Schedulable, Queuable/Apex API/UI Controllers/Inbpound Email Handlers/Invocable Method
**/
public class CampaignService {
	
	public enum BulkUploadCampaignJobTypes {BULK_UPLOAD_MIFIDII_ENTITLEMENTS_FROM_RM_ACCOUNT, BULK_UPLOAD_DESK_COMMENTARY}
	public static final Integer MAX_CAMPAIGN_MEMBERS_CUSTOM_SORTED = 1900;

	public static final String CAMPAIGN_RT_NAME_PHONE_BOOK 	 = 'Phone_Book';
	public static final String CAMPAIGN_RT_NAME_COVERAGE 	 = 'Coverage';
	public static final String CAMPAIGN_RT_NAME_BULK_UPLOAD  = 'Bulk_Upload';
	public static final String CAMPAIGN_RT_NAME_MASS_EMAIL 	 = 'Mass_Email';
	public static final String CAMPAIGN_RT_NAME_MASS_ACIVITY = 'Mass_Activity';
	public static final String CAMPAIGN_RT_NAME_BULK_MOVEMENT_CONTACT = 'Bulk_Movement_Contact';
	public static final String CAMPAIGN_RT_NAME_ONBOARDING = 'Onboarding';

	public static final String ONBOARDING_CAMPAIGN_MEMBER_STATUS_PRIMARY = 'PRIMARY';
	public static final String ONBOARDING_CAMPAIGN_MEMBER_STATUS_SECONDARY = 'SECONDARY';

	public static Map<String, Schema.RecordTypeInfo> CampaignRecTypeInfoByRecTypeDevNameMap {public get {
			if(CampaignRecTypeInfoByRecTypeDevNameMap==null) {
				CampaignRecTypeInfoByRecTypeDevNameMap = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName();
			}
			return CampaignRecTypeInfoByRecTypeDevNameMap;
		}
		private set;
	}
	
	public static Map<String, List<CampaignMember>> getOnboardingPrimaryCampaignMembers(Set<String> CampIdSet) {
		System.debug('#### CampaignService::setupOnboardingCampaignMembers()');	
		Map<String, List<CampaignMember>> CampMemListByCampIdMap = new Map<String, List<CampaignMember>>();
		if(CampIdSet!=null && !CampIdSet.isEmpty()) {
			List<CampaignMember> PrimaryCampMemList = [SELECT Id, CampaignId, ContactId, Status 
				FROM CampaignMember WHERE CampaignId IN :CampIdSet AND Status=:ONBOARDING_CAMPAIGN_MEMBER_STATUS_PRIMARY];
			for(CampaignMember oCampMem : PrimaryCampMemList) {
				List<CampaignMember> CampMemList = CampMemListByCampIdMap.containsKey(oCampMem.CampaignId) ? 
					CampMemListByCampIdMap.get(oCampMem.CampaignId) : new List<CampaignMember>();
				CampMemList.add(oCampMem);
				CampMemListByCampIdMap.put(oCampMem.CampaignId, CampMemList);
			}
		}
		return CampMemListByCampIdMap;
	}

	public static void setupOnboardingCampaignMembers(Map<String, String> CampIdByObReqIdMap, 
			Map<String, String> AddPrimContIdByObReqIdMap, Set<String> RemPrimContForObReqIdSet) {
		System.debug('#### CampaignService::setupOnboardingCampaignMembers()');	
		try{
			String query = '';//'SELECT Id, ContactId, Onboarding_Request__c FROM CampaignMember ';
			Boolean isValid = false;
			List<String> ContIdList = AddPrimContIdByObReqIdMap.values();
			List<String> OnbReqIdList = new List<String>(AddPrimContIdByObReqIdMap.keySet());
			if(AddPrimContIdByObReqIdMap!=null && !AddPrimContIdByObReqIdMap.isEmpty()) {

				//query += ' (ContactId IN :ContIdList AND Onboarding_Request__c IN :OnbReqIdList) ';
				query += ' Onboarding_Request__c IN :OnbReqIdList ';
				isValid = true;
			}
			if(RemPrimContForObReqIdSet!=null && !RemPrimContForObReqIdSet.isEmpty()) {
				if(isValid) {
					query = ' ('+query+' OR ';
				} 
				//query += ' (Onboarding_Request__c IN :RemPrimContForObReqIdSet) ' + (isValid ? ')' : '');
				query += ' Onboarding_Request__c IN :RemPrimContForObReqIdSet ' + (isValid ? ')' : '');
				isValid = true;
			}
			//query += isValid ? ' AND Status = :ONBOARDING_CAMPAIGN_MEMBER_STATUS_PRIMARY ' : '';
			query = 'SELECT Id, ContactId, Onboarding_Request__c, Status FROM CampaignMember WHERE ' + query;
			System.debug('query : '+query);
			if(isValid) {
				List<CampaignMember> ExstCampMemList = (List<CampaignMember>)Database.query(query);
				Map<String, Map<String, CampaignMember>> CampMemByContIdMapByOnbReqIdMap = new Map<String, Map<String, CampaignMember>>();
				Map<String, CampaignMember> PrimaryCampMemByOnbReqIdMap = new Map<String, CampaignMember>();
				for(CampaignMember oCampMem : ExstCampMemList) {
					System.debug('Existing cM : '+oCampMem);
					Map<String, CampaignMember> CampMemByContIdMap = CampMemByContIdMapByOnbReqIdMap.containsKey(oCampMem.Onboarding_Request__c) ? 
						CampMemByContIdMapByOnbReqIdMap.get(oCampMem.Onboarding_Request__c) : new Map<String, CampaignMember>();
					CampMemByContIdMap.put(oCampMem.ContactId, oCampMem);
 					CampMemByContIdMapByOnbReqIdMap.put(oCampMem.Onboarding_Request__c, CampMemByContIdMap);

					if(oCampMem.Status==ONBOARDING_CAMPAIGN_MEMBER_STATUS_PRIMARY) {
						PrimaryCampMemByOnbReqIdMap.put(oCampMem.Onboarding_Request__c, oCampMem);
					}
				}

				List<CampaignMember> DelCampMemList = new List<CampaignMember>(), AddCampMemList = new List<CampaignMember>();
				if(AddPrimContIdByObReqIdMap!=null && !AddPrimContIdByObReqIdMap.isEmpty()) {
					for(String onbReqId : AddPrimContIdByObReqIdMap.keySet()) {
						String campId = CampIdByObReqIdMap.get(onbReqId);
						if(String.isNotBlank(campId)) {
							String newContId = AddPrimContIdByObReqIdMap.get(onbReqId);
							CampaignMember oExstCampMem;
							if(CampMemByContIdMapByOnbReqIdMap.containsKey(onbReqId) && 
									CampMemByContIdMapByOnbReqIdMap.get(onbReqId).containsKey(newContId)) {
								oExstCampMem = CampMemByContIdMapByOnbReqIdMap.get(onbReqId).get(newContId);
							}
							
							if(oExstCampMem==null || oExstCampMem.status!=ONBOARDING_CAMPAIGN_MEMBER_STATUS_PRIMARY) {
								AddCampMemList.add(new CampaignMember(ContactId = newContId, Status=ONBOARDING_CAMPAIGN_MEMBER_STATUS_PRIMARY,
										CampaignId = CampIdByObReqIdMap.get(onbReqId), Onboarding_Request__c=onbReqId));
								if(oExstCampMem!=null) {
									DelCampMemList.add(oExstCampMem);
								} else if(PrimaryCampMemByOnbReqIdMap.containsKey(onbReqId)) {
									DelCampMemList.add(PrimaryCampMemByOnbReqIdMap.get(onbReqId));
								}
							} // else it means that the required primay contact already exists
						}
					}
				}

				if(RemPrimContForObReqIdSet!=null && !RemPrimContForObReqIdSet.isEmpty()) {
					for(String onbReqId : RemPrimContForObReqIdSet) {
						if(PrimaryCampMemByOnbReqIdMap.containsKey(onbReqId)) {
							DelCampMemList.add(PrimaryCampMemByOnbReqIdMap.get(onbReqId));
						}
					}
				}

				System.debug('DelCampMemList : '+DelCampMemList);
				if(!DelCampMemList.isEmpty()) {
					delete DelCampMemList;
				}
				System.debug('AddCampMemList : '+AddCampMemList);
				if(!AddCampMemList.isEmpty()) {
					insert AddCampMemList;	
				}
			}
		} catch(Exception ex) {
			System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
			throw new CampaignServiceException('Error occured in CampaignService::setupOnboardingCampaignMembers() : '+ex.getMessage());
		}

	}

	/* 
	public static void setupOnboardingCampaignMembers(Map<String, String> CampIdByObReqIdMap, 
			Map<String, String> AddPrimContIdByObReqIdMap, Set<String> RemPrimContForObReqIdSet) {
		System.debug('#### CampaignService::setupOnboardingCampaignMembers()');	
		try{
			String query = '';//'SELECT Id, ContactId, Onboarding_Request__c FROM CampaignMember ';
			Boolean isValid = false;
			List<String> ContIdList = AddPrimContIdByObReqIdMap.values();
			List<String> OnbReqIdList = new List<String>(AddPrimContIdByObReqIdMap.keySet());
			if(AddPrimContIdByObReqIdMap!=null && !AddPrimContIdByObReqIdMap.isEmpty()) {

				query += ' (ContactId IN :ContIdList AND Onboarding_Request__c IN :OnbReqIdList) ';
				isValid = true;
			}
			if(RemPrimContForObReqIdSet!=null && !RemPrimContForObReqIdSet.isEmpty()) {
				if(isValid) {
					query = ' ('+query+' OR ';
				} 
				query += ' (Onboarding_Request__c IN :RemPrimContForObReqIdSet) ' + (isValid ? ')' : '');
				isValid = true;
			}
			query += isValid ? ' AND Status = :ONBOARDING_CAMPAIGN_MEMBER_STATUS_PRIMARY ' : '';
			query = 'SELECT Id, ContactId, Onboarding_Request__c FROM CampaignMember WHERE ' + query;
			System.debug('query : '+query);
			if(isValid) {
				List<CampaignMember> ExstCampMemList = (List<CampaignMember>)Database.query(query);
				Map<String, CampaignMember> CampMemdByOnbReqIdMap = new Map<String, CampaignMember>();
				for(CampaignMember oCampMem : ExstCampMemList) {
					CampMemdByOnbReqIdMap.put(oCampMem.Onboarding_Request__c, oCampMem);
				}

				List<CampaignMember> DelCampMemList = new List<CampaignMember>(), AddCampMemList = new List<CampaignMember>();
				if(AddPrimContIdByObReqIdMap!=null && !AddPrimContIdByObReqIdMap.isEmpty()) {
					for(String onbReqId : AddPrimContIdByObReqIdMap.keySet()) {
						if(CampIdByObReqIdMap.containsKey(onbReqId)) {
							String newContId = AddPrimContIdByObReqIdMap.get(onbReqId);
							String oldContId = CampMemdByOnbReqIdMap.containsKey(onbReqId) ? 
									CampMemdByOnbReqIdMap.get(onbReqId).ContactId : null; 
							if(newContId != oldContId) {
								AddCampMemList.add(new CampaignMember(ContactId = newContId, 
										CampaignId = CampIdByObReqIdMap.get(onbReqId), Onboarding_Request__c=onbReqId));
								if(String.isNotBlank(oldContId)) {
									DelCampMemList.add(CampMemdByOnbReqIdMap.get(onbReqId));
								}
							} // else it means that the required primay contact already exists
						}
					}
				}

				if(RemPrimContForObReqIdSet!=null && !RemPrimContForObReqIdSet.isEmpty()) {
					for(String onbReqId : RemPrimContForObReqIdSet) {
						if(CampMemdByOnbReqIdMap.containsKey(onbReqId)) {
							DelCampMemList.add(CampMemdByOnbReqIdMap.get(onbReqId));
						} 
					}
				}

				System.debug('DelCampMemList : '+DelCampMemList);
				if(!DelCampMemList.isEmpty()) {
					delete DelCampMemList;
				}
				System.debug('AddCampMemList : '+AddCampMemList);
				if(!AddCampMemList.isEmpty()) {
					insert AddCampMemList;
				}
			}
		} catch(Exception ex) {
			System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
			throw new CampaignServiceException('Error occured in CampaignService::setupOnboardingCampaignMembers() : '+ex.getMessage());
		}

	}
	*/

	public static Map<String, String> setupOnboardingCampaign(Map<String, Onboarding_Request__c> OnbReqByCampNameMap) {
    	System.debug('#### CampaignService::setupOnboardingCampaign()');
		Map<String, String> CampIdByCampNameMap = new Map<String, String>();
		try{
			List<Campaign> CampaignList = new List<Campaign>();
			Set<String> CampaignNameSet = OnbReqByCampNameMap.keySet();
			for(String campName : CampaignNameSet) {
				CampaignList.add(new Campaign(Name=campName, 
						RecordTypeId = CampaignRecTypeInfoByRecTypeDevNameMap.get(CAMPAIGN_RT_NAME_ONBOARDING).getRecordTypeId(),
						OwnerId = OnbReqByCampNameMap.values().Sales_Requestor__c));
			}
			insert CampaignList;
			for(Campaign oCamp : CampaignList) {
				CampIdByCampNameMap.put(oCamp.Name, oCamp.Id);
			}

			List<CampaignMemberStatus> CampMemStatusList = new List<CampaignMemberStatus>();
			CampMemStatusList.add(new CampaignMemberStatus(Label = ONBOARDING_CAMPAIGN_MEMBER_STATUS_PRIMARY, HasResponded=true, SortOrder = 5, isDefault=false));
			CampMemStatusList.add(new CampaignMemberStatus(Label = ONBOARDING_CAMPAIGN_MEMBER_STATUS_SECONDARY, HasResponded=true, SortOrder = 6, isDefault=true));
			setupCampaignMemStatus(CampIdByCampNameMap.values(), CampMemStatusList);
		} catch(Exception ex) {
			System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
			throw new CampaignServiceException('Error occured in CampaignService::getOnboardingCampaign() : '+ex.getMessage());
		}


		return CampIdByCampNameMap;
    }

	public static void setupCampaignMemStatus(List<String> CampIdList, List<CampaignMemberStatus> CampMemStatusList) {
		System.debug('#### CampaignService::setupCampaignMemStatus()');
		if(CampIdList!=null && !CampIdList.isEmpty() && CampMemStatusList!=null && !CampMemStatusList.isEmpty()) {
			List<CampaignMemberStatus> ExistingCampMemStatusList = [SELECT Id, Label, CampaignId FROM CampaignMemberStatus 
				WHERE CampaignId IN :CampIdList ORDER BY CampaignId];
			Map<String, Map<String, CampaignMemberStatus>> CampMemStatByStatusMapByCampIdMap = new Map<String, Map<String, CampaignMemberStatus>>(); 
			for(CampaignMemberStatus oCampMemStat : ExistingCampMemStatusList) {
				Map<String, CampaignMemberStatus> CampMemStatByStatusMap = CampMemStatByStatusMapByCampIdMap.containsKey(oCampMemStat.CampaignId) ?
						CampMemStatByStatusMapByCampIdMap.get(oCampMemStat.CampaignId) : new Map<String, CampaignMemberStatus>();
				CampMemStatByStatusMap.put(oCampMemStat.Label.toUpperCase(), oCampMemStat);
				CampMemStatByStatusMapByCampIdMap.put(oCampMemStat.CampaignId, CampMemStatByStatusMap);
			}
			List<CampaignMemberStatus> NewCampMemStatusList = new List<CampaignMemberStatus>();
			for(String campId : CampIdList) {
				for(CampaignMemberStatus oCmpMemStatus : CampMemStatusList) {
					CampaignMemberStatus oNewCmpMemStatus = oCmpMemStatus.clone(false, true);
					oNewCmpMemStatus.CampaignId = campId;
					if(CampMemStatByStatusMapByCampIdMap.containsKey(campId) &&
							CampMemStatByStatusMapByCampIdMap.get(campId).containsKey(oCmpMemStatus.Label.toUpperCase())) {
						oNewCmpMemStatus.Id = CampMemStatByStatusMapByCampIdMap.get(campId).get(oCmpMemStatus.Label.toUpperCase()).Id;
						CampMemStatByStatusMapByCampIdMap.get(campId).remove(oCmpMemStatus.Label.toUpperCase());
					}
                    NewCampMemStatusList.add(oNewCmpMemStatus);
                }
            }
            
			if(!NewCampMemStatusList.isEmpty()) {
				insert NewCampMemStatusList;
			}

			List<CampaignMemberStatus> DelCampMemStatusList = new List<CampaignMemberStatus>();
			for(String campId : CampIdList) {
                if(CampMemStatByStatusMapByCampIdMap.containsKey(campId)) {
                    for(CampaignMemberStatus oCmapMemStatus : CampMemStatByStatusMapByCampIdMap.get(campId).values()) {
                        DelCampMemStatusList.add(oCmapMemStatus);
                    }
                }
            }

            if(!DelCampMemStatusList.isEmpty()) {
                delete DelCampMemStatusList;
            }
            
            
        }
	}

//////////////////////////////////////////////

	public static String getBulkUploadCampaignRec(String jobId, String recordTypeDeveloperName, String campNamePrefix) {
    	System.debug('#### CampaignService::getCampaignBulkUploadRec');
    	String campId;
    	String campRTId = CampaignRecTypeInfoByRecTypeDevNameMap.get(recordTypeDeveloperName).getRecordTypeId();
    	if(String.isNotBlank(jobId)) {
    		// get 15 character Id
    		jobId = jobId.substring(0, 14);
    		List<Campaign> CampList = [SELECT Id, Description, createdDate 
    			FROM Campaign 
    			WHERE RecordTypeId=:campRTId ORDER BY createdDate DESC LIMIT 5000];
    		for(Campaign oCamp : CampList) {
    			if(oCamp.Description!=null && oCamp.Description.contains(jobId)) {
    				campId=oCamp.Id;
    				break;
    			}
    		}
    	} else {
    		System.debug('Create new Bulk Upload Campaign');
	    	Datetime currDateTime= DateTime.now();
	    	String campName = (String.isNotBlank(campNamePrefix) ? campNamePrefix+'-' : '') +UserInfo.getUserId()+'-';
			if(currDateTime.day() < 10) {
			    campName+='0'+currDateTime.day()+'-';
			} else {
			    campName+=currDateTime.day()+'-';
			}
			if(currDateTime.month()<10) {
			    campName+='0'+currDateTime.month()+'-';
			} else {
			    campName+=currDateTime.month()+'-';
			}
			campName+=currDateTime.year()+'-';
			campName+=currDateTime.hour()+':'+currDateTime.minute()+':'+currDateTime.second();
			System.debug('campName : '+campName);
			Campaign oCamp = new Campaign(Name=campName, RecordTypeId=campRTId);
			insert oCamp;
			System.debug('inserted oCamp : '+oCamp);
			// configure campaign members
			setupBulkUploadCampaignMemStatus(oCamp.Id);
			campId=oCamp.Id;
    	}
    	System.debug('Returning : '+campId);
		return campId;
    }
    
    public static void setupBulkUploadCampaignMemStatus(String campId) {
		System.debug('#### CampaignService::setupBulkUploadCampaignMemStatus');
		
		List<CampaignMemberStatus> ExistingCampMemStatusList = [SELECT Id,Label FROM CampaignMemberStatus 
				WHERE CampaignId=:campId];
		Map<String, CampaignMemberStatus> CampMemStatByStatusMap = new Map<String, CampaignMemberStatus>(); 
		for(CampaignMemberStatus oCampMemStat : ExistingCampMemStatusList) {
			CampMemStatByStatusMap.put(oCampMemStat.Label.toUpperCase(), oCampMemStat);
		}
		System.debug('CampMemStatByStatusMap : '+CampMemStatByStatusMap);
		Map<String, CampaignMemberStatus> CampaignMemberStatusByStatusMap = new Map<String, CampaignMemberStatus>();
		
		CampaignMemberStatus oCampMemStatErr = new CampaignMemberStatus(CampaignId=campId, HasResponded=true,
             	Label = 'ERROR', SortOrder = 5, isDefault=true);
        if(CampMemStatByStatusMap.containsKey('ERROR')) {
        	System.debug('CONTAIN ERR ALREADY : ');
        	oCampMemStatErr.Id=CampMemStatByStatusMap.get('ERROR').Id;
        	CampMemStatByStatusMap.remove('ERROR');
        }
		CampaignMemberStatusByStatusMap.put('ERROR', oCampMemStatErr);
        
		CampaignMemberStatus oCampMemStatSucc = new CampaignMemberStatus(CampaignId=campId, HasResponded=true,
             	Label = 'SUCCESS', SortOrder = 6, isDefault=false);
		if(CampMemStatByStatusMap.containsKey('SUCCESS')) {
        	System.debug('CONTAIN ERR ALREADY : ');
        	oCampMemStatSucc.Id=CampMemStatByStatusMap.get('SUCCESS').Id;
        	CampMemStatByStatusMap.remove('SUCCESS');
        }
		CampaignMemberStatusByStatusMap.put('SUCCESS', oCampMemStatSucc);
		System.debug('CampaignMemberStatusByStatusMap : '+CampaignMemberStatusByStatusMap);
    	upsert CampaignMemberStatusByStatusMap.values();

    	if(!CampMemStatByStatusMap.isEmpty()) {
			delete CampMemStatByStatusMap.values();
		}
	}
	
	public static String getBulkUploadReportURL(String CampaignId, String reportDeveloperName) {
		System.debug('#### CampaignService::getBulkUploadReportURL');
		String reportURL = '';
		reportURL= String.isNotBlank(System.Label.Bulk_Upload_Campaign_Report_Link) ? 
					System.Label.Bulk_Upload_Campaign_Report_Link : '/one/one.app#/sObject/{0}/view?fv0={1}';
		reportURL = String.format(reportURL, new String[]{CommonTools.getReportId(reportDeveloperName), CampaignId});
		System.debug('reportURL : '+reportURL);
		return reportURL; 		
	}
	
	public static void updateBulkUploadCampaignJobStatus(String campId, BulkUpdateJobRunInfo inpBulkUpdJobInfo) {
		System.debug('#### CampaignService::updateBulkUploadCampaignJobStatus');

		System.debug('inpBulkUpdJobInfo : '+inpBulkUpdJobInfo);

		if(inpBulkUpdJobInfo!=null && String.isNotBlank(campId)) {
			List<Campaign> CampList = [Select Id, Description FROM Campaign WHERE Id=:campId];
			if(!CampList.isEmpty()) {
	    		BulkUpdateJobRunInfo bulkUpldInfo = new BulkUpdateJobRunInfo();
				if(String.isNotBlank(CampList[0].Description)) {
					bulkUpldInfo = (BulkUpdateJobRunInfo)JSON.deserialize(
		               		CampList[0].Description, BulkUpdateJobRunInfo.class);
				}
				
				if(String.isNotBlank(inpBulkUpdJobInfo.jobType)) {
					bulkUpldInfo.jobType = inpBulkUpdJobInfo.jobType;
				}
				
				if(string.isNotBlank(inpBulkUpdJobInfo.jobId)) {
					bulkUpldInfo.jobId = inpBulkUpdJobInfo.jobId;
				}
				
				if(String.isNotBlank(inpBulkUpdJobInfo.uploadTypeIcon)) {
					bulkUpldInfo.uploadTypeIcon = inpBulkUpdJobInfo.uploadTypeIcon;
				}

				if(String.isNotBlank(inpBulkUpdJobInfo.uploadType)) {
					bulkUpldInfo.uploadType = inpBulkUpdJobInfo.uploadType;
				}
				
				bulkUpldInfo.jobRunDate = ''+DateTime.now();
				
				if(String.isNotBlank(inpBulkUpdJobInfo.jobStatus)) {
					bulkUpldInfo.jobStatus = inpBulkUpdJobInfo.jobStatus;
				}
				
				if(String.isNotBlank(inpBulkUpdJobInfo.percentProg)) {
		 			bulkUpldInfo.percentProg = inpBulkUpdJobInfo.percentProg;
				}
				
				if(String.isNotBlank(inpBulkUpdJobInfo.emailSent)) {
		 			bulkUpldInfo.emailSent = inpBulkUpdJobInfo.emailSent;
				}
				
				if(String.isBlank(bulkUpldInfo.reportURL)) {
					//bulkUpldInfo.reportURL= String.isNotBlank(System.Label.Bulk_Upload_Campaign_Report_Link) ? 
					//	System.Label.Bulk_Upload_Campaign_Report_Link : '/one/one.app#/sObject/{0}/view?fv0={1}';
					//bulkUpldInfo.reportURL = String.format(bulkUpldInfo.reportURL, new String[]{CommonTools.getReportId('Bulk_Upload_Campaign_Report'), campId});
					bulkUpldInfo.reportURL = getBulkUploadReportURL(campId, 'Bulk_Upload_Campaign_Report');		
				}
				
				if(inpBulkUpdJobInfo.totalNoOfRecsToProc != null) {
					bulkUpldInfo.totalNoOfRecsToProc = inpBulkUpdJobInfo.totalNoOfRecsToProc; 
				}
				
				if(inpBulkUpdJobInfo.totalNoOfRecsProc != null) {
					bulkUpldInfo.totalNoOfRecsProc = inpBulkUpdJobInfo.totalNoOfRecsProc; 
				}
				
				if(inpBulkUpdJobInfo.noOfSucc != null) {
					bulkUpldInfo.noOfSucc = inpBulkUpdJobInfo.noOfSucc; 
				}
				
				if(inpBulkUpdJobInfo.noOfErrs != null) {
					bulkUpldInfo.noOfErrs = inpBulkUpdJobInfo.noOfErrs; 
				}
				
				if(inpBulkUpdJobInfo.noOfErrsNoInCamp != null) {
					bulkUpldInfo.noOfErrs = inpBulkUpdJobInfo.noOfErrsNoInCamp; 
				}

				Campaign oCamp = new Campaign(Id=campId, Description=JSON.serialize(bulkUpldInfo));
				update oCamp;
			}
		}
	}
		
	public static List<BulkUpdateJobRunInfo> getPreviousJobRunInfoForUser(String userId, String jobType, Integer numOfJobs) {
    	System.debug('#### BulkUpdateDeskCommentaryProhController::getPrevJobRuns');
    	List<BulkUpdateJobRunInfo> PreviousJobRunList = new List<BulkUpdateJobRunInfo>();
    	try {
	    	String campRTId = CampaignRecTypeInfoByRecTypeDevNameMap.get(CAMPAIGN_RT_NAME_BULK_UPLOAD).getRecordTypeId();
	    	//String currUserId = UserInfo.getUserId();
			List<Campaign> CampList = [SELECT Id, Description, createdDate 
				FROM Campaign 
				WHERE RecordTypeId=:campRTId AND CreatedById=:userId ORDER BY createdDate DESC LIMIT 5000];
			Integer count=0;
			for(Campaign oCamp : CampList) {
				if(oCamp.Description!=null) {
					BulkUpdateJobRunInfo bulkUpldInfo = (BulkUpdateJobRunInfo)JSON.deserialize(
		               		ocamp.Description, BulkUpdateJobRunInfo.class);
		            if(bulkUpldInfo!=null && bulkUpldInfo.jobType == jobType) {
		            	PreviousJobRunList.add(bulkUpldInfo);
		            }
					++count;
					if(count==numOfJobs) {
						break;
					}
				}
			}
    	} catch(Exception ex) {
    		// absorb the exception here
    	}
    	
    	return PreviousJobRunList;
    }
    
    public static BulkUpdateJobRunInfo getBulkUploadJobDetails(String campaignId) {
    	System.debug('#### CampaignService::getBulkUploadJobDetails()');	
    	System.debug('getJobStatus- campaignId '+campaignId);
    	BulkUpdateJobRunInfo bulkUpldInfo;
		try {
			if(String.isNotBlank(campaignId)) {
		    	List<Campaign> CampList = [SELECT Id,Description FROM Campaign WHERE Id=:campaignId];
		    	if(!CampList.isEmpty()) {
		    		if(String.isNotBlank(CampList[0].Description)) {
		    			bulkUpldInfo = (BulkUpdateJobRunInfo)JSON.deserialize(
				               		CampList[0].Description, BulkUpdateJobRunInfo.class);
				        System.debug('JOB STATUS bulkUpldInfo : '+bulkUpldInfo);
		    		}	
		    	}
			}
		} catch(Exception ex) {
			throw new CampaignServiceException('Error in getting Job Details from Bulk Upload Campaign : '+ex.getMessage());
		}
		return bulkUpldInfo;
    }
		
	public static Integer getNumbeContactsInCampaign(String campaignId) {
		System.debug('#### CampaignService::getNumbeContactsInCampaign()');
		Integer noOfCampaignMembers;
		try {
			if(String.isNotBlank(campaignId)) {
				noOfCampaignMembers = [SELECT Name, NumberOfContacts FROM Campaign WHERE Id=:campaignId][0].NumberOfContacts;
			}
		} catch(Exception ex) {
			System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new CampaignServiceException('Error Occured in CampaignService::getNumbeContactsInCampaign() : '+ex.getMessage());
		}
		return noOfCampaignMembers;
	}

	public static Boolean deleteOldEmptyCampaigns(String recordTypeId, String campaignNamePattern){
		Boolean deleteSuccessful = true;
		List<Campaign> campaignDeleteList = new List<Campaign>();

		if(String.isNotEmpty(recordTypeId) && String.isNotEmpty(campaignNamePattern)){
			List<Campaign> campaignList = [SELECT Id, Name, Description 
										   FROM Campaign
										   WHERE RecordTypeId = :recordTypeId AND
											Name LIKE :campaignNamePattern AND
											CreatedDate < YESTERDAY
											LIMIT 1000
										   ];
			if(campaignList != null && !campaignList.isEmpty()){

				for(Campaign campaignObj : campaignList){
					if(String.isBlank(campaignObj.Description)){
						campaignDeleteList.add(campaignObj);
					}
				}

				if(!campaignDeleteList.isEmpty()){
					List<Database.DeleteResult> resultList = Database.delete(campaignDeleteList, false);
					for(Integer i=0; i<resultList.size(); i++){            
						Database.DeleteResult resultObj = resultList.get(i);
						if(!resultObj.isSuccess()){ 
							for(Database.Error errorObj : resultObj.getErrors()){
								if(String.isNotEmpty(errorObj.getMessage()) ){
									deleteSuccessful = false;
								}
							}
						}
					}
				}
			}
		}

		return deleteSuccessful;
    }

	/**
    * @Description: Share Campaign with groups by Developer Name 
    */
    public static void shareOnbReqCampaignWithGroups (List<Onboarding_Request__c> onbRequests, List<String> groupDevNames, String accessLevel) {
        if(onbRequests != null && groupDevNames != null && String.isNotBlank(accessLevel)) {
            List<CampaignShare> campaignShareRecords = new List<CampaignShare>();
            for(Group grp : [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN :groupDevNames]) {
                for(Onboarding_Request__c obRequest : onbRequests) {
                    if (obRequest.campaign__c != null) {
                        CampaignShare campaignShare = new CampaignShare();
                        campaignShare.CampaignId = obRequest.campaign__c;
                        campaignShare.UserOrGroupId = grp.Id;
                        campaignShare.CampaignAccessLevel = 'Edit';
                        campaignShareRecords.add(campaignShare);
                    }
                }
            }
            try {
                insert campaignShareRecords;
            } catch (Exception ex) {
                System.debug('ERROR while sharing Campaign with Group : ' + ex.getMessage());
                throw new CampaignServiceException('Error Occured in CampaignService::shareOnbReqCampaignWithGroups()');           
            }
        }
    } 
    
    public static void shareCampaignWithRequestor(Map<String, String> campaignIdToRequestorId) {
        if (campaignIdToRequestorId != null && !campaignIdToRequestorId.isEmpty()) {
            List<CampaignShare> campaignShareToAdd = new List<CampaignShare>();
            for (String campaignId : campaignIdToRequestorId.keySet()) {
                if (String.isNotBlank(campaignIdToRequestorId.get(campaignId))) {
                    campaignShareToAdd.add(
                        new CampaignShare(
                            CampaignId = campaignId,
                            UserorGroupId = campaignIdToRequestorId.get(campaignId),
                            CampaignAccessLevel = 'Edit'
                        )
                    );
                }
            }
            
            if (!campaignShareToAdd.isEmpty()) {
                List<Database.SaveResult> saveResults = Database.insert(campaignShareToAdd,false);
                for (Database.SaveResult saveRes : saveResults) {
                    if (saveRes.isSuccess()) {
                        System.debug('--Campaign Access given to Sales Requestor Successfull');
                    } else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : saveRes.getErrors()) {
                            if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION && err.getMessage().contains('AccessLevel')){
                                System.debug('--1. Error--' + err.getStatusCode());
                            } else{
                                // Indicates failure.
                                System.debug('--2. Error--' + err.getStatusCode());
                            }
                        }
                    }
                }
            }
        }
    }

	//Method to Share Campaign with DeskHeadApprover as DeskHead can be in different hierarchy and role
	public static void shareCampaignWithDeskHead(Map<Id,Onboarding_Request__c> oldMap, List<Onboarding_Request__c> newOnbReqList){

		List<CampaignShare> campShareList = new List<CampaignShare>();
		Boolean isDeskHeadChanged = false;
		List<Id> campaignIdList = new List<Id>();
		List<Id> deskHeadIdList = new List<Id>();
		
		if(newOnbReqList != null){
			for(Onboarding_Request__c oNewOnbReq : newOnbReqList){
				Onboarding_Request__c oldRequest = oldMap != null ? oldMap.get(oNewOnbReq.Id) : null;

				CampaignShare campShare = new CampaignShare();
				campShare.CampaignId = oNewOnbReq.Campaign__c;
				campShare.UserOrGroupId = oNewOnbReq.Desk_Head_Approver__c;
				campShare.CampaignAccessLevel = 'Edit';

				campShareList.add(campShare);
				System.debug('--campShareList--' + campShareList);

				if(oNewOnbReq.Desk_Head_Approver__c != null && oldRequest != null &&  oldRequest.Desk_Head_Approver__c != null 
                    && oNewOnbReq.Desk_Head_Approver__c != oldRequest.Desk_Head_Approver__c){
                        //remove existing assigned Sharing if any                        
                        isDeskHeadChanged = true;
                        campaignIdList.add(oNewOnbReq.Campaign__c);
                        deskHeadIdList.add(oldRequest.Desk_Head_Approver__c);                        
                }
			}
		}

		if(isDeskHeadChanged){
            List<CampaignShare> campaignShareDeleteList = [SELECT Id FROM CampaignShare 
                            WHERE CampaignId IN :campaignIdList AND UserOrGroupId IN :deskHeadIdList];
            
            if(campaignShareDeleteList != null && campaignShareDeleteList.size() > 0){
                List<Database.DeleteResult> resultList = Database.delete(campaignShareDeleteList,false) ;
                System.debug('resultList: '+resultList.size());
                for(Integer i=0; i<resultList.size(); i++){            
                    Database.DeleteResult resultObj = resultList.get(i);
                    if(!resultObj.isSuccess()){ 
                        for(Database.Error errorObj : resultObj.getErrors()){
                            if(String.isNotEmpty(errorObj.getMessage())){
                                System.debug('Error on Delete. Error Message: '+errorObj.getMessage());
                            }
                        }
                    }
                }
            }
        }

		if(campShareList != null){
            List<Database.SaveResult> srList = Database.insert(campShareList,false);
            // Process the save results.
			for(Database.SaveResult sr : srList){
				if(sr.isSuccess()){
                // Indicates success
                System.debug('--OnbReq Campaign shared with Desk Head Approver Successfull');
				}
				else {
					// Get first save result error.
					Database.Error err = sr.getErrors()[0];
					
					// Check if the error is related to trival access level.
					// Access level must be more permissive than the object's default.
					// These sharing records are not required and thus an insert exception is acceptable. 
					if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
							err.getMessage().contains('AccessLevel')){
						// Indicates success.
						System.debug('--1. Error--' + err.getStatusCode());
					}
					else{
						// Indicates failure.
						System.debug('--2. Error--' + err.getStatusCode());
					}
				}
			}
		}
	}

	public class BulkUpdateJobRunInfo {
		@AuraEnabled
		public String jobId;
		@AuraEnabled
		public String jobType;
		@AuraEnabled
		public String uploadType;
		@AuraEnabled
		public String uploadTypeIcon;
		@AuraEnabled
		public String reportURL;
		@AuraEnabled
	 	public String jobRunDate;
	 	@AuraEnabled
	 	public String jobStatus;
	 	@AuraEnabled
	 	public Integer totalNoOfRecsToProc;
	 	@AuraEnabled
	 	public Integer totalNoOfRecsProc;
	 	@AuraEnabled
	 	public Integer noOfSucc;
	 	@AuraEnabled
	 	public Integer noOfErrs;
	 	@AuraEnabled
	 	public Integer noOfErrsNoInCamp;
	 	@AuraEnabled
	 	public String percentProg;
	 	@AuraEnabled
	 	public String emailSent;
	}
	
	public class CampaignServiceException extends Exception {}
}