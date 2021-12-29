/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : Service class which provides reusable functionality for "Coverage Team Member" object
**				  and could be called by various clients (UI Contrller classes, Asynchronous classes, api classes etc.)
** Consumer of the Service Layer : Batch, Schedulable, Queuable/Apex API/UI Controllers/Inbpound Email Handlers/Invocable Method
**				   
**/  

public class CoverageTeamMemberService {

	public static final String COVERAGE_TEAM_MEM_RT_NAME_ACTIVE_COVERAGE = 'Active Coverage';
	public static Map<String, Schema.RecordTypeInfo> CoverageTeamMemRecTypeInfoByRecTypeNameMap = 
				Schema.SObjectType.Coverage_Team_Member__c.getRecordTypeInfosByName();

	public static List<Coverage_Team_Member__c> getCoverageTeamMembersForSalesCode(Set<String> SalesTeamForCoverageIdSet) {
		System.debug('CoverageTeamMemberService::getCoverageTeamMembersForSalesCode()');
		List<Coverage_Team_Member__c> CoverageTeamMemberList = new List<Coverage_Team_Member__c>(); 
		try {
			String activeCoverageRTId = CoverageTeamMemRecTypeInfoByRecTypeNameMap.get(COVERAGE_TEAM_MEM_RT_NAME_ACTIVE_COVERAGE).getRecordTypeId();
			if(!SalesTeamForCoverageIdSet.isEmpty()) {
				CoverageTeamMemberList = [SELECT  Id,Sales_Team_for_Coverage__c,
					Account__c, Account__r.Parent.Id, Account__r.Parent.Name 
			 	FROM  Coverage_Team_Member__c
			 	WHERE Sales_Team_for_Coverage__c IN :SalesTeamForCoverageIdSet AND 
			 		RecordTypeId=:activeCoverageRTId];
			}
		} catch(Exception ex) {
			System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new CoverageTeamMemberServiceException('Error Occured in CoverageTeamMemberService::getCoverageTeamMembersForSalesCode() : '+ex.getMessage());
		}
		return CoverageTeamMemberList; 
	}
	
	public class CoverageTeamMemberServiceException extends Exception {}
}