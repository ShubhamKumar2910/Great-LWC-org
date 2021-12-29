/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : This is a service/manager class called from the various Trigger Handlers for different SObjects.
**				  This service class could be called from 'after-Insert', 'after-Delete', 'after-Update', 
**				  and 'after-Undelete' Trigger contexts.    
**
**/ 
public class PlatformEventGenerationService {

	/**
	  * Description : Is called from the various Trigger Handlers for different SObjects.
	  *				  This method could be called from 'after-Insert', 'after-Delete', 'after-Update', 
	  *				  and 'after-Undelete' Trigger contexts.
	  *				  It identifies the set of Platform Events that needs to be fired from MetaDataType and 
	  *				  calls the corresponding Event Genration Implementation apex-class as configured in MD.  
	  *
	  *	@param String sObjectApiName - API name of the SObject name for which to identify the generate events
	  *	@param Boolean isInsert   - indicates whether the DML insert operation is being performed 
	  *	@param Boolean isUpdate   - indicates whether the DML update operation is being performed
	  *	@param Boolean isDelete   - indicates whether the DML delete operation is being performed
	  *	@param Boolean isUndelete - indicates whether the DML undelete operation is being performed
	  *	@param Map<Id, sObject> OldMap - Map of Records with old Values, is null for after-insert and after-undelete operations  
	  *	@param Map<Id, sObject> NewMap - Map of Records with New Values, is null for after-delete operations
	  * @return void 
	**/ 
	public static void evaluateAndPublishEvents(String sObjectApiName, 
				Boolean isInsert, Boolean isUpdate, Boolean isDelete, Boolean isUndelete, 
				Map<Id, sObject> OldMap, Map<Id, sObject> NewMap) {
		System.debug('#### PlatformEventGenerationService::evaluateAndPublishEvents()');
		try {
			Map<String, Object_Platform_Event_Mapping__mdt> ObjEvntMappingListByEvtNameMap = 
				PlatformEventMetadataService.getObjectEventMapping(sObjectApiName, isInsert, isUpdate,	isDelete, isUndelete);

			if(!ObjEvntMappingListByEvtNameMap.isEmpty()) {
				for(Object_Platform_Event_Mapping__mdt oObjEvtMD : ObjEvntMappingListByEvtNameMap.values()) {
					System.debug('For SObject : '+oObjEvtMD.sObject_Api_Name__c+
						' Use Handler Class : '+oObjEvtMD.Platform_Event_Generator_Class_API_Name__c+
						' To Fire event : '+oObjEvtMD.Platform_Event_Api_Name__c);
					// create the type from class name
					Type t = Type.forName(oObjEvtMD.Platform_Event_Generator_Class_API_Name__c);
					PlatformEventGeneratorGenericImpl platformEventGenerator = (PlatformEventGeneratorGenericImpl)t.newInstance();
					
					// use polimorism to call the function from corresponding implementation
					platformEventGenerator.evaluateAndPublsihEvents(sObjectApiName, isInsert, isUpdate,
						isDelete, isUndelete, oObjEvtMD, OldMap, NewMap);
				}
			}

		} catch(Exception ex) {
			System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new PlatformEventGenerationServiceException('Error Occured in PlatformEventGenerationService::evaluateAndPublishEvents() : '+
            	ex.getMessage());
		}
	}
	
	public class PlatformEventGenerationServiceException extends Exception {}
}