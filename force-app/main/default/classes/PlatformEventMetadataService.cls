/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : This class implements the Service class for various Matadata Types used in 
**				  capturing the conditions to publish the Platform Events
**
**/ 
public class PlatformEventMetadataService {
	// Structure to hold the Platform_Event_Trigger_Condition__mdt by Unique MD Record Name
	private static Map<String, Platform_Event_Trigger_Condition__mdt> PlatEvtTriggerCondByUniqNameMap;
	// Structure to hold the List of Object_Platform_Event_Field_Mapping__mdt by its Parent RecordId.
	private static Map<String, List<Object_Platform_Event_Field_Mapping__mdt>> SObjPlatEvtFldMappingMDListBySObjEvtMppingIdMap; 
	
	static {
		// initialize the structure
		SObjPlatEvtFldMappingMDListBySObjEvtMppingIdMap = new Map<String, List<Object_Platform_Event_Field_Mapping__mdt>>();
	}
	
	/**
	  * Description : to get the list of a Object_Platform_Event_Mapping__mdt MD mapped by 
	  *				  Platform Event Api name 
	  *
	  *	@param String sObjectApiName - API name of the SObject name for which to identify the generate events
	  *	@param Boolean isInsert   - indicates whether the DML insert operation is being performed 
	  *	@param Boolean isUpdate   - indicates whether the DML update operation is being performed
	  *	@param Boolean isDelete   - indicates whether the DML delete operation is being performed
	  *	@param Boolean isUndelete - indicates whether the DML undelete operation is being performed
	  *	@return Map<String, Object_Platform_Event_Mapping__mdt> - Returns the SObject and Platform Event mapping structure
	**/
	// returns Map<PlatformEventApiName, List<Object_Platform_Event_Mapping__mdt>>
	public static Map<String, Object_Platform_Event_Mapping__mdt> getObjectEventMapping(String sObjApiName, 
			Boolean isInsert, Boolean isUpdate,	Boolean isDelete, Boolean isUndelete) {
		System.debug('#### PlatformEventMetadataService::getObjectEventMapping()');
		Map<String, Object_Platform_Event_Mapping__mdt> ObjEvtMappingByEvtNameMap = new Map<String, Object_Platform_Event_Mapping__mdt>(); 
		try {
			
			// query each time the MD in order to avoid wo maintain the big Map build for this MD during the whole transaction 
			// as it is very unlikey we will need call this function again in same transaction.
			// Also, query MD is really very fast as it is cached and doesn't counts against the SOQL limits 
			String query = 'SELECT Id, DeveloperName, sObject_Api_Name__c, Platform_Event_Api_Name__c, Order__c, '+
					'Trigger_On_Insert__c, Trigger_On_Update__c, Trigger_On_Delete__c, Event_Trigger_Condition_Postfix__c, '+
					'Run_Asynchronously__c, Platform_Event_Generator_Class_API_Name__c, Is_Active__c '+
				'FROM Object_Platform_Event_Mapping__mdt '+
				'WHERE Is_Active__c=True AND '+
					'sObject_Api_Name__c=:sObjApiName AND ';
					//'Platform_Event_Api_Name__c IN :EventApiNameSet AND ';
			// if none of the following is true, the above query will throw error as query will be invalid
			if(isUpdate) {
				query += 'Trigger_On_Update__c=True ';
			} else if(isInsert) {
				query += 'Trigger_On_Insert__c=True ';
			} else if(isDelete) {
				query += 'Trigger_On_Delete__c=True ';
			} else if(isUndelete) {
				query += 'Trigger_On_UnDelete__c=True ';
			}
			query += 'ORDER BY Order__c ASC ';
			System.debug('query : '+query);
			List<Object_Platform_Event_Mapping__mdt> ObjPlatEvntMDList = Database.query(query);
			System.debug(ObjPlatEvntMDList.size());
			for(Object_Platform_Event_Mapping__mdt oObjEvntMD : ObjPlatEvntMDList) {
				ObjEvtMappingByEvtNameMap.put(oObjEvntMD.Platform_Event_Api_Name__c, oObjEvntMD);
			}
		} catch(Exception ex) {
			System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new PlatformEventMetadataServiceException('Error Occured in PlatformEventMetadataService::getObjectEventMapping() : '+
            	ex.getMessage());
		}
		return ObjEvtMappingByEvtNameMap;
	}
	
	
	/**
	  * Description : to get the list of a Platform_Event_Trigger_Condition__mdt MD mapped by 
	  *				  unique Recor Name for that MD record 
	  *
	  *	@return Map<String, Platform_Event_Trigger_Condition__mdt> - Returns the Trgger Condition MD map
	**/
	public static Map<String, Platform_Event_Trigger_Condition__mdt> getPlatEvtTriggerConditions() {
		System.debug('#### PlatformEventMetadataService::getPlatEvtTriggerConditions()');
		try {
			if(PlatEvtTriggerCondByUniqNameMap==null) {
				PlatEvtTriggerCondByUniqNameMap = new Map<String, Platform_Event_Trigger_Condition__mdt>();  
				List<Platform_Event_Trigger_Condition__mdt> PlatEvtTriggerCondMDList = [SELECT Id, DeveloperName, sObject_Field_Api_Name__c,
						On_Value_Change__c, Is_Equal_To_Specific_Value__c, Value_Type__c, Value__c
					FROM Platform_Event_Trigger_Condition__mdt];
				for(Platform_Event_Trigger_Condition__mdt oPlatEvtTriggerCondMD : PlatEvtTriggerCondMDList) {
					PlatEvtTriggerCondByUniqNameMap.put(oPlatEvtTriggerCondMD.DeveloperName, oPlatEvtTriggerCondMD);
				}
			}
		} catch(Exception ex) {
			System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new PlatformEventMetadataServiceException('Error Occured in PlatformEventMetadataService::getPlatEvtTriggerConditions() : '+
            	ex.getMessage());
		}
		return PlatEvtTriggerCondByUniqNameMap;
	}
	
	/**
	  * Description : overloaded function to get the list of Object_Platform_Event_Field_Mapping__mdt  
	  *
	  * @param List<Object_Platform_Event_Mapping__mdt> ObjEvtMappingList - List of Object_Platform_Event_Mapping__mdt
	  *			for which to get the FieldMapping MD  
	  *	@return Map<String, List<Object_Platform_Event_Field_Mapping__mdt>> - Returns the list of 
	  *			Object_Platform_Event_Field_Mapping__mdt for a parent SObject Event mapping MD
	**/
	public static Map<String, List<Object_Platform_Event_Field_Mapping__mdt>> getObjPlatEvntFieldMappings(
			List<Object_Platform_Event_Mapping__mdt> ObjEvtMappingList) {
		Set<String> ObjEvtMappingIdSet = new Set<String>();
		if(ObjEvtMappingList!=null) {
			for(Object_Platform_Event_Mapping__mdt oObjEvtMappingMD : ObjEvtMappingList) {
				ObjEvtMappingIdSet.add(oObjEvtMappingMD.Id);
			}
		}
		return getObjPlatEvntFieldMappings(ObjEvtMappingIdSet);
	}
	
	/**
	  * Description : overloaded function to get the list of Object_Platform_Event_Field_Mapping__mdt  
	  *
	  * @param Set<String> SObjPlatEvntMappingIdSet - List of RecIds of Object_Platform_Event_Mapping__mdt
	  *			for which to get the FieldMapping MD  
	  *	@return Map<String, List<Object_Platform_Event_Field_Mapping__mdt>> - Returns the list of 
	  *			Object_Platform_Event_Field_Mapping__mdt for a parent SObject Event mapping MD
	**/
	public static Map<String, List<Object_Platform_Event_Field_Mapping__mdt>> getObjPlatEvntFieldMappings(
				Set<String> SObjPlatEvntMappingIdSet) {
		System.debug('#### PlatformEventMetadataService::getObjPlatEvntFieldMappings()');
		Map<String, List<Object_Platform_Event_Field_Mapping__mdt>> ObjEvtFldMappingMap = 
			new Map<String, List<Object_Platform_Event_Field_Mapping__mdt>>();  
		try {
			if(SObjPlatEvntMappingIdSet!=null) {
				Set<String> ObjEvtMappingIdSet = new Set<String>(SObjPlatEvntMappingIdSet);
				for(String objEvtMappingId : SObjPlatEvtFldMappingMDListBySObjEvtMppingIdMap.keySet()) {
					if(SObjPlatEvtFldMappingMDListBySObjEvtMppingIdMap.containsKey(objEvtMappingId)) {
						ObjEvtMappingIdSet.remove(objEvtMappingId);
					}
				}
				
				if(!ObjEvtMappingIdSet.isEmpty()) {
					List<Object_Platform_Event_Field_Mapping__mdt> ObjPlatEvtFieldMappingList = [SELECT Id, Object_Platform_Event_Mapping__c, 
							Event_Field_Api_Name__c, Set_From_Object_Field_Api_Name__c, Is_Set_From_SObject_Field__c, Is_Reference_Field__c, 
							Is_Set_From_Constant_Value__c, Constant_Value_Type__c, Constant_Value__c, 
							Is_Set_From_Polymorphic_Parent__c, Polymorphic_Parent_Object_API_Name__c, Polymorphic_Parent_Field_API_Name__c, 
							Is_Active__c 
						FROM Object_Platform_Event_Field_Mapping__mdt
						WHERE Object_Platform_Event_Mapping__c IN :ObjEvtMappingIdSet AND Is_Active__c=true];
						
					for(Object_Platform_Event_Field_Mapping__mdt oObjEvtFldMappingMD : ObjPlatEvtFieldMappingList) {
						List<Object_Platform_Event_Field_Mapping__mdt> ObjEvtFldMappingList = 
							SObjPlatEvtFldMappingMDListBySObjEvtMppingIdMap.containsKey(oObjEvtFldMappingMD.Object_Platform_Event_Mapping__c) ?
								SObjPlatEvtFldMappingMDListBySObjEvtMppingIdMap.get(oObjEvtFldMappingMD.Object_Platform_Event_Mapping__c) :
								new List<Object_Platform_Event_Field_Mapping__mdt>(); 
						ObjEvtFldMappingList.add(oObjEvtFldMappingMD);
						
						SObjPlatEvtFldMappingMDListBySObjEvtMppingIdMap.put(oObjEvtFldMappingMD.Object_Platform_Event_Mapping__c, ObjEvtFldMappingList);
					}		
				}
				
				// finally construct the result
				for(String objEvtMappingId : SObjPlatEvntMappingIdSet) {
					ObjEvtFldMappingMap.put(objEvtMappingId, SObjPlatEvtFldMappingMDListBySObjEvtMppingIdMap.get(objEvtMappingId));
				}
			}
		} catch(Exception ex) {
			System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new PlatformEventMetadataServiceException('Error Occured in PlatformEventMetadataService::getObjPlatEvntFieldMappings() : '+
            	ex.getMessage());
		}
		
		return ObjEvtFldMappingMap;
	}
	
	public class PlatformEventMetadataServiceException extends Exception {}
}