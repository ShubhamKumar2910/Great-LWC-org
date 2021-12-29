/**
 *	Author 		: Pravin Kundal
 *	Company 	: Nomura
 *  Description : This class contains unit tests for validating the behavior of Apex class - PlatformEventMetadataService
 *
 */
 @isTest
public class PlatformEventMetadataServiceTest {
	static testMethod void testPlatformEventMetadataService() {
		Map<String, Object_Platform_Event_Mapping__mdt> ObjEvtMappingByEvtNameMap = PlatformEventMetadataService.getObjectEventMapping('ETradingEnablement__c', 
				true, false, false, false);
		PlatformEventMetadataService.getObjPlatEvntFieldMappings(ObjEvtMappingByEvtNameMap.values());

		ObjEvtMappingByEvtNameMap = PlatformEventMetadataService.getObjectEventMapping('ETradingEnablement__c', 
				false, true, false, false);
		PlatformEventMetadataService.getObjPlatEvntFieldMappings(ObjEvtMappingByEvtNameMap.values());

		ObjEvtMappingByEvtNameMap = PlatformEventMetadataService.getObjectEventMapping('ETradingEnablement__c', 
				false, false, true, false);
		PlatformEventMetadataService.getObjPlatEvntFieldMappings(ObjEvtMappingByEvtNameMap.values());

		ObjEvtMappingByEvtNameMap = PlatformEventMetadataService.getObjectEventMapping('ETradingEnablement__c', 
				false, false, false, true);
		PlatformEventMetadataService.getObjPlatEvntFieldMappings(ObjEvtMappingByEvtNameMap.values());
		
		PlatformEventMetadataService.getPlatEvtTriggerConditions();
	}
}