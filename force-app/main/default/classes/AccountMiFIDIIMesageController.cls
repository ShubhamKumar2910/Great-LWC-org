/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : Controller class for lightning compoment c:AccountMiFIDIIMesage
**/  
public without sharing class AccountMiFIDIIMesageController {
	
	@AuraEnabled
	public static Boolean initialize(String csvProfileAndPSList) {
		System.debug('csvProfileAndPSList : '+csvProfileAndPSList);
		Boolean isVisible = false;
		try {
			if(String.isNotBlank(csvProfileAndPSList)) {
				String currentUserId = UserInfo.getUserId();
				Map<String, String> UserProfileNameByUserIdMap = new Map<String, String>(); 
	    		Map<String, Set<String>> PSNameSetByUserIdMap = new Map<String, Set<String>>();			
				UserHelper.getProfileAndPermissionSetsForUser(new List<String>{currentUserId}, UserProfileNameByUserIdMap,
						PSNameSetByUserIdMap);
				
				for(String token : csvProfileAndPSList.split(',')) {
					if(UserProfileNameByUserIdMap.get(currentUserId)==token ||
						(PSNameSetByUserIdMap.containsKey(currentUserId) && PSNameSetByUserIdMap.get(currentUserId).contains(token))) 
					{
						isVisible = true;
						break;
					}
				}
			}
		} catch(Exception ex) {
			System.debug('Error : '+ex.getMessage());
			throw new AuraHandledException('Error in initialization : '+ex.getMessage());
		}
		System.debug('return isVisible : '+isVisible);
		return isVisible;
	}
	
	
	@AuraEnabled
	public static MiFIDIIEntitlementJobInfo getJobStatus(String accRecId, String campaignId) {
		System.debug('#### AccountMiFIDIIMesageController::getJobStatus');
		System.debug('getJobStatus- accRecId '+accRecId);
		System.debug('getJobStatus- campaignId '+campaignId);
		
		MiFIDIIEntitlementJobInfo jobInfo = new MiFIDIIEntitlementJobInfo();
		//jobInfo.isUploadJobRunning=false;
		try {
			if(String.isBlank(campaignId) && String.isNotBlank(accRecId)) {
				Map<String, String> BulkUploadCampIdByRMAccIdMap = 
					AccountService.getBulkUploadCampaignForRMAccount(new List<String>{accRecId});
				if(BulkUploadCampIdByRMAccIdMap!=null && !BulkUploadCampIdByRMAccIdMap.isEmpty()) {
					campaignId = BulkUploadCampIdByRMAccIdMap.get(accRecId);	
				}
			}
			
			if(String.isNotBlank(campaignId)) {
				jobInfo.campaignId = campaignId;
				CampaignService.BulkUpdateJobRunInfo bulkUpldInfo = CampaignService.getBulkUploadJobDetails(campaignId);
		        System.debug('JOB STATUS bulkUpldInfo : '+bulkUpldInfo);
		        if(bulkUpldInfo!= null) {
		        	jobInfo.reportURL = bulkUpldInfo.reportURL;  
		        	jobInfo.percentProg = bulkUpldInfo.percentProg;
		        	if(String.isNotBlank(bulkUpldInfo.jobId)) {
			        	List<AsyncApexJob> AsyncApexJobList = getJobDetails(new List<String>{bulkUpldInfo.jobId}, 
			        		new List<String>{'Holding','Queued','Preparing','Processing'});
			        	// this means the Job with jobId in Campaign desription is still running
			        	jobInfo.isUploadJobRunning = !AsyncApexJobList.isEmpty();
		        	}
				}
			} else {
				jobInfo.isUploadJobRunning = true;
			} 
		} catch(Exception ex) {
			throw new AuraHandledException('Error in refreshing Job Status : '+ex.getMessage());
		}
		System.debug('jobInfo: '+jobInfo);
		return jobInfo;
	}
	
	private static List<AsyncApexJob> getJobDetails(List<String> JobIdList, List<String> StatusList) {
    	System.debug('#### AccountMiFIDIIMesageController::getJobDetails');
    	List<AsyncApexJob> AsyncApexJobList = new List<AsyncApexJob>(); 

		Map<Id,ApexClass> ApexClassMap = new Map<Id,ApexClass>([SELECT Id,Name,Status 
			FROM ApexClass WHERE Name IN ('UpdateContactsBatch') AND Status='Active']);
		List<Id> ApexLcassIdList = new List<Id>(ApexClassMap.keySet());

		List<String> JobTypeList = new List<String>{'BatchApex'}; 

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
    
    public class MiFIDIIEntitlementJobInfo {
    	@AuraEnabled
        public String campaignId;
		@AuraEnabled
        public String reportURL;
        @AuraEnabled
        public Boolean isUploadJobRunning;
        @AuraEnabled
        public String percentProg;
	}
}