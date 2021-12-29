/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : This is an extendeble, generic implementation class for evaluating the various conditons to generate events  
**				  and generate the events for the records which satisfy the conditions  
**				  This class can be further extended to change the implmentation behaviour for generating the events
**				  This class also implements the Queueable interface in order to generate the events asynchronously.
**/
public virtual class PlatformEventGeneratorGenericImpl implements Queueable {

	// following are the protected member variables so that it is not vivible publically but onle 
	// visible to class extending this class.
	// These variables are mainly used to maintain the state when generating the events asynchronously 
	protected String sObjectApiName; 
	protected Boolean isInsert;
	protected Boolean isUpdate;
	protected Boolean isDelete;
	protected Boolean isUndelete;
	protected Object_Platform_Event_Mapping__mdt oObjEvntMappingMD;
	protected Map<Id, sObject> OldMap; 
	protected Map<Id, sObject> NewMap;
	
	protected List<SObject> EventsToFireList;

	// following variable is only set by unit test coverage for test coverage and will be removed in future 
	// when we have a use-case of generating the Platform Event Asynchronously
	@TestVisible
	private static Boolean runAsyncWhenIsRunningTest;
	static {
		runAsyncWhenIsRunningTest = false;
	}

	/**
	  * Description : Public Default Constructor. A class is required to have a public default constructor when
	  *				  intantiated using Type.newInstance()  
	  *
	**/
	public PlatformEventGeneratorGenericImpl() {}
	
	/**
	  * Description : Private paramaterized contructor. This constructor is used to initiate the object internally 
	  *				  from one of the functions in this class, when events needs to be generated asynchronously.  
	  *
	  *	@param String sObjectApiName - API name of the SObject name for which to identify the generate events
	  *	@param Boolean isInsert   - indicates whether the DML insert operation is being performed 
	  *	@param Boolean isUpdate   - indicates whether the DML update operation is being performed
	  *	@param Boolean isDelete   - indicates whether the DML delete operation is being performed
	  *	@param Boolean isUndelete - indicates whether the DML undelete operation is being performed
	  * @param Object_Platform_Event_Mapping__mdt oObjEvntMappingMD - record of the Custom Metadata Type
	  								which includes all the information of the event that needs to be generated 
	  *	@param Map<Id, sObject> OldMap - Map of Records with old Values, is null for after-insert and after-undelete operations  
	  *	@param Map<Id, sObject> NewMap - Map of Records with New Values, is null for after-delete operations
	**/
	private PlatformEventGeneratorGenericImpl(String sObjectApiName, Boolean isInsert, Boolean isUpdate,
			Boolean isDelete, Boolean isUndelete, Object_Platform_Event_Mapping__mdt oObjEvntMappingMD,
			Map<Id, sObject> OldMap, Map<Id, sObject> NewMap) {
		System.debug('#### PlatformEventGeneratorGenericImpl::PlatformEventGeneratorGenericImpl()');
		// initialize the required member variables
		this.sObjectApiName = sObjectApiName; 
		this.isInsert = isInsert;
		this.isUpdate = isUpdate;
		this.isDelete = isDelete;
		this.isUndelete = isUndelete;
		this.oObjEvntMappingMD = oObjEvntMappingMD;
		this.OldMap = OldMap; 
		this.NewMap = NewMap;
		this.EventsToFireList = new List<SObject>();
	}

	/**
	  * Description : virtual function which can be overrided by a derived class for a different implmentation
	  *				  if required. This is the only public funtion in this class and is called by the 
	  *				  event generation manager class.  
	  *
	  *	@param String sObjectApiName - API name of the SObject name for which to identify the generate events
	  *	@param Boolean isInsert   - indicates whether the DML insert operation is being performed 
	  *	@param Boolean isUpdate   - indicates whether the DML update operation is being performed
	  *	@param Boolean isDelete   - indicates whether the DML delete operation is being performed
	  *	@param Boolean isUndelete - indicates whether the DML undelete operation is being performed
	  * @param Object_Platform_Event_Mapping__mdt oObjEvntMappingMD - record of the Custom Metadata Type
	  								which includes all the information of the event that needs to be generated 
	  *	@param Map<Id, sObject> OldMap - Map of Records with old Values, is null for after-insert and after-undelete operations  
	  *	@param Map<Id, sObject> NewMap - Map of Records with New Values, is null for after-delete operations
	  * @return void 
	**/
	public virtual void evaluateAndPublsihEvents(String sObjectApiName, Boolean isInsert, Boolean isUpdate,
			Boolean isDelete, Boolean isUndelete, Object_Platform_Event_Mapping__mdt oObjEvntMappingMD,
			Map<Id, sObject> OldMap, Map<Id, sObject> NewMap) {
		System.debug('#### PlatformEventGeneratorGenericImpl::evaluateAndPublsihEvents()');
		// Step 1: First indentify from the meta data type record, whether to generate the events 
		//		   synchronously in this same transaction or asynchronously in a seperate transaction 
		if(oObjEvntMappingMD.Run_Asynchronously__c || (runAsyncWhenIsRunningTest && test.isRunningTest() )) {
			// enque the Job for asynchronously generation of the events.
			enqueueJobForAsynchExecution(sObjectApiName, isInsert, isUpdate, isDelete, isUndelete, 
					oObjEvntMappingMD, OldMap, NewMap);
		} else {
			// initialize the required member variables and generate the events synchronously in this 
			// same transaction
			this.sObjectApiName = sObjectApiName; 
			this.isInsert = isInsert;
			this.isUpdate = isUpdate;
			this.isDelete = isDelete;
			this.isUndelete = isUndelete;
			this.oObjEvntMappingMD = oObjEvntMappingMD;
			this.OldMap = OldMap; 
			this.NewMap = NewMap;
			this.EventsToFireList = new List<SObject>();
			
			// this method will evaluate the condition and will generate events
			this.generateEvents();
		}
	}

	/**
	  * Description : protected virtual function which enqueues the job by creating the instance of this class.
	  *  			  NOTE : Please override the implementation of this class in the entended class and 
	  *						 enqueue the class of that particular class, if it is not extended in derived class
	  *						 then it will end up enqueueing this class and you may get un-expected results	
	  *
	  *	@param String sObjectApiName - API name of the SObject name for which to identify the generate events
	  *	@param Boolean isInsert   - indicates whether the DML insert operation is being performed 
	  *	@param Boolean isUpdate   - indicates whether the DML update operation is being performed
	  *	@param Boolean isDelete   - indicates whether the DML delete operation is being performed
	  *	@param Boolean isUndelete - indicates whether the DML undelete operation is being performed
	  * @param Object_Platform_Event_Mapping__mdt oObjEvntMappingMD - record of the Custom Metadata Type
	  								which includes all the information of the event that needs to be generated 
	  *	@param Map<Id, sObject> OldMap - Map of Records with old Values, is null for after-insert and after-undelete operations  
	  *	@param Map<Id, sObject> NewMap - Map of Records with New Values, is null for after-delete operations
	  * @return void 
	**/
	protected virtual void enqueueJobForAsynchExecution(String sObjectApiName, Boolean isInsert, Boolean isUpdate,
			Boolean isDelete, Boolean isUndelete, Object_Platform_Event_Mapping__mdt oObjEvntMappingMD,
			Map<Id, sObject> OldMap, Map<Id, sObject> NewMap) {
		System.debug('#### PlatformEventGeneratorGenericImpl::enqueueJobForAsynchExecution()');
		System.enqueueJob(new PlatformEventGeneratorGenericImpl(sObjectApiName, isInsert, isUpdate, 
					isDelete, isUndelete, oObjEvntMappingMD, OldMap, NewMap));
	}

	/**
	  * Description : A interface method that needs to be implemented as this class implements Queueable interface
	  *				  Please note that the class that extends this class don't have to implement the Queueable interface
	  *				  again as it derives this method.
	  *
	  *	@param QueueableContext context
	  * @return void 
	**/
	public void execute(QueueableContext context) {
		System.debug('#### PlatformEventGeneratorGenericImpl::execute()');
		this.generateEvents();
	}

	/**
	  * Description : protected virtual function which loops through each record and evaluates the 
	  *				  conditions as configured in Metadata Type and generates the events for the recrds that
	  *				  satisfy the condition.
	  *
	  * @return void 
	**/
	protected virtual void generateEvents() {
		System.debug('#### PlatformEventGeneratorGenericImpl::generateEvents()');
		try {
			if(oObjEvntMappingMD!=null) {
				// Get all the records for metadata type - Platform_Event_Trigger_Condition__mdt
				Map<String, Platform_Event_Trigger_Condition__mdt> PlatEvtTriggerCondByUniqNameMap = 
							PlatformEventMetadataService.getPlatEvtTriggerConditions();
				// Get all the Field Mapping MD (Object_Platform_Event_Field_Mapping__mdt) records for a 
				// given SObject API name 
				Map<String, List<Object_Platform_Event_Field_Mapping__mdt>> SObjPlatEvtFldMappingMDListBySObjEvtMppingIdMap = 
							PlatformEventMetadataService.getObjPlatEvntFieldMappings(new List<Object_Platform_Event_Mapping__mdt>{oObjEvntMappingMD});
							
				// RT Describe for a give SObject
				Schema.DescribeSobjectResult[] DescResults = Schema.describeSObjects(new String[]{sObjectApiName});
				Map<String,Schema.RecordTypeInfo> RTInfoByRTDevNameMap =  DescResults[0].getRecordTypeInfosByDeveloperName();
				
				// GGet the SObject description for the Platform Event API name that needs to be generated
				Map<String, Schema.DescribeSobjectResult> SObjeDescRsltByEvntNameMap = new Map<String, Schema.DescribeSobjectResult>();
				// intensionally in block so that list is destryed after exiting the block
				for(Schema.DescribeSobjectResult entDescRslt : Schema.describeSObjects(new List<String>{oObjEvntMappingMD.Platform_Event_Api_Name__c})) {
					SObjeDescRsltByEvntNameMap.put(entDescRslt.getName(), entDescRslt);
				}
				
				// Depending on what operations are being performed on the records of an SObject for 
				// which we need to genetrate Platform Events.
				// IF Records are being Updated
				if(isUpdate) {
					// in case of update operation, both oldMap and newMap are present and non-null
					Map<Id, SObject> GenerateEventsForSObjMap = new Map<Id, SObject>(); 
					Integer indx = 0;
					for(SObject oNewSObj : NewMap.values()) {
						// get correponding old SObject
						SObject oOldSObj = OldMap.values().get(indx);
						// Evaluate the condition as mentioned in MetadataType 
						if(evaluatePostfixExpression(oObjEvntMappingMD.Event_Trigger_Condition_Postfix__c, PlatEvtTriggerCondByUniqNameMap, 
								RTInfoByRTDevNameMap, oOldSObj, oNewSObj)) 
						{
							// If condition is true then populate the intance of a Platform Event from the 
							// New SObject record
							//EventsToFireList.add(
							//	populatePlatEventFromSObject(SObjPlatEvtFldMappingMDListBySObjEvtMppingIdMap.get(oObjEvntMappingMD.Id),
							//		oObjEvntMappingMD.Platform_Event_Api_Name__c, SObjeDescRsltByEvntNameMap.get(oObjEvntMappingMD.Platform_Event_Api_Name__c),
							//		oNewSObj, SObjectsWithReferenceFieldsByIdMap.get(oNewSObj.Id), null)
							//);
							GenerateEventsForSObjMap.put(oNewSObj.Id, oNewSObj);
						} 
						++indx;
					}
					
					if(!GenerateEventsForSObjMap.isEmpty()) {
						Map<Id, SObject> SObjectsWithReferenceFieldsByIdMap = populateReferenceFields(sObjectApiName, 
							SObjPlatEvtFldMappingMDListBySObjEvtMppingIdMap.get(oObjEvntMappingMD.Id), GenerateEventsForSObjMap);
					
						Map<String, Map<String, Object>> ParentSObjByParentFldMapByEvntFldApiNameMap = populatePolymorphicParentFields(sObjectApiName, 
							SObjPlatEvtFldMappingMDListBySObjEvtMppingIdMap.get(oObjEvntMappingMD.Id), GenerateEventsForSObjMap);
						System.debug('ParentSObjByParentFldMapByEvntFldApiNameMap : '+ParentSObjByParentFldMapByEvntFldApiNameMap);
						
						for(SObject oNewSObj : GenerateEventsForSObjMap.values()) {
							EventsToFireList.add(
								populatePlatEventFromSObject(SObjPlatEvtFldMappingMDListBySObjEvtMppingIdMap.get(oObjEvntMappingMD.Id),
									oObjEvntMappingMD.Platform_Event_Api_Name__c, SObjeDescRsltByEvntNameMap.get(oObjEvntMappingMD.Platform_Event_Api_Name__c),
									oNewSObj, SObjectsWithReferenceFieldsByIdMap.get(oNewSObj.Id), ParentSObjByParentFldMapByEvntFldApiNameMap)
							);
						}
					} 
				} 
				// else if - the record is being either inerted or undeleted
				else if(isInsert || isUndelete) {
					// in case of Insert or Undelete, only newMap is present and oldMap is null

					Map<Id, SObject> GenerateEventsForSObjMap = new Map<Id, SObject>();  
					for(SObject oNewSObj : NewMap.values()) {
						// Evaluate the condition as mentioned in MetadataType
						if(evaluatePostfixExpression(oObjEvntMappingMD.Event_Trigger_Condition_Postfix__c, PlatEvtTriggerCondByUniqNameMap, 
								RTInfoByRTDevNameMap, null, oNewSObj)) 
						{
							// If condition is true then populate the intance of a Platform Event from the 
							// New SObject record
							//EventsToFireList.add(
							//	populatePlatEventFromSObject(SObjPlatEvtFldMappingMDListBySObjEvtMppingIdMap.get(oObjEvntMappingMD.Id),
							//		oObjEvntMappingMD.Platform_Event_Api_Name__c, SObjeDescRsltByEvntNameMap.get(oObjEvntMappingMD.Platform_Event_Api_Name__c),
							//		oNewSObj, SObjectsWithReferenceFieldsByIdMap.get(oNewSObj.Id), ParentSObjByParentFldMapByEvntFldApiNameMap)
							//);
							GenerateEventsForSObjMap.put(oNewSObj.Id, oNewSObj);
						} 
					}
					
					if(!GenerateEventsForSObjMap.isEmpty()) {
						Map<Id, SObject> SObjectsWithReferenceFieldsByIdMap = populateReferenceFields(sObjectApiName, 
							SObjPlatEvtFldMappingMDListBySObjEvtMppingIdMap.get(oObjEvntMappingMD.Id), GenerateEventsForSObjMap);
					
						Map<String, Map<String, Object>> ParentSObjByParentFldMapByEvntFldApiNameMap = populatePolymorphicParentFields(sObjectApiName, 
							SObjPlatEvtFldMappingMDListBySObjEvtMppingIdMap.get(oObjEvntMappingMD.Id), GenerateEventsForSObjMap);
						System.debug('ParentSObjByParentFldMapByEvntFldApiNameMap : '+ParentSObjByParentFldMapByEvntFldApiNameMap);
						
						for(SObject oNewSObj : GenerateEventsForSObjMap.values()) {
							EventsToFireList.add(
								populatePlatEventFromSObject(SObjPlatEvtFldMappingMDListBySObjEvtMppingIdMap.get(oObjEvntMappingMD.Id),
									oObjEvntMappingMD.Platform_Event_Api_Name__c, SObjeDescRsltByEvntNameMap.get(oObjEvntMappingMD.Platform_Event_Api_Name__c),
									oNewSObj, SObjectsWithReferenceFieldsByIdMap.get(oNewSObj.Id), ParentSObjByParentFldMapByEvntFldApiNameMap)
							);
						}
					} 
				} 
				// else if - the record is being deleted
				else if(isdelete) {
					// in case of Delete, only oldMap is present and newMap is null
					for(SObject oOldSObj : OldMap.values()) {
						// please note - how we are passing the oOldSObj as a newObje, this is to manipulate to check when to
						// fire events on deletion. In case of delete, we will be mainly testing if the value of record being deleted
						// is equal to specific value and not the value change as valu change condition is not valid for Delete case
						if(evaluatePostfixExpression(oObjEvntMappingMD.Event_Trigger_Condition_Postfix__c, PlatEvtTriggerCondByUniqNameMap, 
								RTInfoByRTDevNameMap, null, oOldSObj)) 
						{
							// If condition is true then populate the intance of a Platform Event from the 
							// Old SObject record
							EventsToFireList.add(
								populatePlatEventFromSObject(SObjPlatEvtFldMappingMDListBySObjEvtMppingIdMap.get(oObjEvntMappingMD.Id),
									oObjEvntMappingMD.Platform_Event_Api_Name__c, SObjeDescRsltByEvntNameMap.get(oObjEvntMappingMD.Platform_Event_Api_Name__c),
									oOldSObj, null, null)
							);
						} 
					}
				}
				
				// finally call the method to publish the events
				publishEvents();
			}
		} catch(Exception ex) {
			System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new PlatformEventGeneratorGenericImplException('Error Occured in GenericGeneratePlatformEvents::generateEvents() : '+
            	ex.getMessage());
		}
	}
	
	/**
	  * Description : protected virtual function to publish the events. Override this method for any pre-processing
	  *				  that needs to be performed before generating events.
	  *
	  * @return void 
	**/
	protected void publishEvents() {
		System.debug('#### PlatformEventGeneratorGenericImpl::publishEvents()');
		if(!EventsToFireList.isEmpty()) {
			List<Database.SaveResult> pubResults = EventBus.publish(EventsToFireList);
			System.debug(EventsToFireList.size() + ' EVENTS WILL BE FIRED....');
			for(SObject oObj : EventsToFireList) {
				System.debug('This Event Will be Fired : '+oObj);
			}
		
			// ToDo - Error handing strategy when there are failures in publising events	
			// Inspect publishing result for each event
			for (Database.SaveResult sr : pubResults) {
			    if (sr.isSuccess()) {
			        System.debug('Successfully published event.');
			    } else {
			        for(Database.Error err : sr.getErrors()) {
			            System.debug('Error returned: ' +
			                        err.getStatusCode() +
			                        ' - ' +
			                        err.getMessage());
			        }
			    }       
			}
		}
	}

	/**
	  * Description : protected virtual function to populate the instance of a Platform Event from 
	  *				  the instance of a SObject. The way fields are populated on a Platform Event are 
	  *				  configures in a Object_Platform_Event_Field_Mapping__mdt MD type  
	  *				  
	  *	@param List<Object_Platform_Event_Field_Mapping__mdt> ObjEvtFldMappingList - list of field mappings to 
	  *				to populate fields on the Platform Event that is being generated
	  *	@param String eventName   - Platfrom Event API name 
	  *	@param Schema.DescribeSobjectResult evntDescRslt - Platform Event's SObject description result 
	  *	@param SObject sObj   - instnace of the SObject from which Platform events to be populated
	  * @return SObject - return the populate SObject type for a Platform Event that needs to be generated.
	**/
	protected SObject populatePlatEventFromSObject(List<Object_Platform_Event_Field_Mapping__mdt> ObjEvtFldMappingList, String eventName,
			Schema.DescribeSobjectResult evntDescRslt, SObject sObj, SObject oSObjWithReferenceFields,
			Map<String, Map<String, Object>> ParentSObjByParentFldMapByEvntFldApiNameMap) {
		System.debug('#### PlatformEventGeneratorGenericImpl::populatePlatEventFromSObject()');
		// we will not check conditions like eventName!=null and assume that it is configured correctly in MD
		// in order to make this code as eficient as possible by avoiding un-necessary checks
		sObject oEventObj = evntDescRslt.getSobjectType().newSObject();
		for(Object_Platform_Event_Field_Mapping__mdt oObjEvtFldMappingMD : ObjEvtFldMappingList) {
			if(oObjEvtFldMappingMD.Is_Set_From_SObject_Field__c) {
				// set the value from SObject field
				oEventObj.put(oObjEvtFldMappingMD.Event_Field_Api_Name__c, sObj.get(oObjEvtFldMappingMD.Set_From_Object_Field_Api_Name__c));
			} else if(oObjEvtFldMappingMD.Is_Set_From_Constant_Value__c) {
				oEventObj.put(oObjEvtFldMappingMD.Event_Field_Api_Name__c, oObjEvtFldMappingMD.Constant_Value__c);
				// Currently it supports the Constant Value of type String only. 
				// If we get a use0-case to support different types, the following code could be uncommented
				// and various different types can be supported. 
				/*switch on Integer.valueOf(oObjEvtFldMappingMD.Constant_Value_Type__c) {
					when 1 { // 1 == String type
	                	condResult = newVal==oPlatEvntCond.Value__c;
	                }
					when 2 { // 2 == Boolean type
	               		operand1Val = newVal==Boolean.valueOf(oPlatEvntCond.Value__c);		     
	                }
				}*/
			} else if(oObjEvtFldMappingMD.Is_Reference_Field__c) {
				// set the value from reference field
				sObject childObj;
				if(oSObjWithReferenceFields!=null) {
				    List<String> RelObjList=(String.isNotBlank(oObjEvtFldMappingMD.Set_From_Object_Field_Api_Name__c) ? 
				    		oObjEvtFldMappingMD.Set_From_Object_Field_Api_Name__c.split('\\.') : new List<String>());
				    System.debug('RelObjList : '+RelObjList);
				    childObj=oSObjWithReferenceFields;	
				    for(Integer i=0; i<RelObjList.size()-1; ++i) {
						String objName = RelObjList.get(i);
				        System.debug('objName '+objName);
				        if(childObj!=null) {
				            childObj=childObj.getSObject(objName);
				        } else {
				        	break;
				        }
				    }
					System.debug('childObj : '+childObj);
				    //System.debug('Val : '+childObj.get(RelObjList.get(RelObjList.size()-1)));
				    Object refValue = childObj != null ? childObj.get(RelObjList.get(RelObjList.size()-1)) : null;
				    System.debug('refValue : '+refValue);
				    oEventObj.put(oObjEvtFldMappingMD.Event_Field_Api_Name__c, refValue);
				}
			} else if(oObjEvtFldMappingMD.Is_Set_From_Polymorphic_Parent__c) {
				Map<String, Object> ParentSObjByParentFldMap = 
					ParentSObjByParentFldMapByEvntFldApiNameMap.get(oObjEvtFldMappingMD.Event_Field_Api_Name__c);	
				if(ParentSObjByParentFldMap!=null) {
					oEventObj.put(oObjEvtFldMappingMD.Event_Field_Api_Name__c, 
						ParentSObjByParentFldMap.get((String)sObj.get(oObjEvtFldMappingMD.Set_From_Object_Field_Api_Name__c)));
				}
				
			}
		}

		return oEventObj;
	}
	
	/**
	  * Description : protected virtual function to populate the fields from related Objects  
	  *				  
	  * @param String sObjectApiName - API name of the SObject name for which to identify the generate events
	  *	@param List<Object_Platform_Event_Field_Mapping__mdt> ObjEvtFldMappingList - list of field mappings to 
	  *				to populate fields on the Platform Event that is being generated
	  *	@param Map<Id, sObject> SObjectByIdMap - Map of Records with New Values
	  * @return Map<Id, SObject> Map of populated objects with refrenece fields from related object
	**/
	protected Map<Id, SObject> populateReferenceFields(String sObjectApiName, 
			List<Object_Platform_Event_Field_Mapping__mdt> ObjEvtFldMappingList, Map<Id, SObject> SObjectByIdMap) {
		System.debug('#### PlatformEventGeneratorGenericImpl::populateReferenceFields()');
		Map<Id, SObject> SObjectsWithReferenceFieldsByIdMap = new Map<Id, SObject>();
		String query = 'SELECT Id';
		for(Object_Platform_Event_Field_Mapping__mdt oObjEvtFldMappingMD : ObjEvtFldMappingList) {
			if(oObjEvtFldMappingMD.Is_Reference_Field__c) {
				query += ','+oObjEvtFldMappingMD.Set_From_Object_Field_Api_Name__c;
			}
		}
		System.debug('query SO FAR : '+query);
		if(query.contains(',')) {
			System.debug('Contang comma');
			Set<Id> SObjIdSet = SObjectByIdMap.keySet();
			// this means there is atlest one reference field
			query += ' FROM '+sObjectApiName+' WHERE Id IN :SObjIdSet';
			List<SObject> SObjectList = Database.query(query);
			System.debug('RESULT : '+SObjectList);
			for(SObject oSObj : SObjectList) {
				SObjectsWithReferenceFieldsByIdMap.put(oSObj.Id, oSObj);
			}
			
			System.debug('SObjectsWithReferenceFieldsByIdMap : '+SObjectsWithReferenceFieldsByIdMap);
		}
		
		return SObjectsWithReferenceFieldsByIdMap;
	}
	
	/**
	  * Description : protected virtual function to populate the fields from the related polymorphic Parent fields   
	  *				  
	  * @param String sObjectApiName - API name of the SObject name for which to identify the generate events
	  *	@param List<Object_Platform_Event_Field_Mapping__mdt> ObjEvtFldMappingList - list of field mappings to 
	  *				to populate fields on the Platform Event that is being generated
	  *	@param Map<Id, sObject> SObjectByIdMap - Map of Records with New Values
	  * @return Map<Id, SObject> Map of field value from Parent Object by Parent Id by Event's field API name  
	**/
	protected Map<String, Map<String, Object>> populatePolymorphicParentFields(String sObjectApiName, List<Object_Platform_Event_Field_Mapping__mdt> ObjEvtFldMappingList,
			  Map<Id, SObject> SObjectByIdMap) {
		System.debug('#### PlatformEventGeneratorGenericImpl::populatePolymorphicParentFields()');
		// e.g. Map<GrpName__c, Map<'Id of Collaborative Group', Name field from Collaborative Group>>
		Map<String, Map<String, Object>> ParentSObjByParentFldMapByEvntFldApiNameMap = new Map<String, Map<String, Object>>();
		for(Object_Platform_Event_Field_Mapping__mdt oObjEvtFldMappingMD : ObjEvtFldMappingList) {
			if(oObjEvtFldMappingMD.Is_Set_From_Polymorphic_Parent__c) {
				Set<Id> PolymorphicParentFldSet = new Set<Id>();
				for(SObject oSObj : SObjectByIdMap.values()) {
					PolymorphicParentFldSet.add((Id)oSObj.get(oObjEvtFldMappingMD.Set_From_Object_Field_Api_Name__c));
				}
				System.debug('PolymorphicParentFldSet : '+PolymorphicParentFldSet);
				String query = 'SELECT Id,'+oObjEvtFldMappingMD.Polymorphic_Parent_Field_API_Name__c+
					' FROM '+oObjEvtFldMappingMD.Polymorphic_Parent_Object_API_Name__c+
					' WHERE Id IN :PolymorphicParentFldSet';
				System.debug('query : '+query);
				List<SObject> ParentObjList = Database.query(query);
				for(SObject oPrntObj : ParentObjList) {
					Map<String,Object> ParentSObjByParentFldMap = 
						ParentSObjByParentFldMapByEvntFldApiNameMap.containsKey(oObjEvtFldMappingMD.Event_Field_Api_Name__c) ?
						ParentSObjByParentFldMapByEvntFldApiNameMap.get(oObjEvtFldMappingMD.Event_Field_Api_Name__c) : new Map<String,Object>();
					ParentSObjByParentFldMap.put(oPrntObj.Id, oPrntObj.get(oObjEvtFldMappingMD.Polymorphic_Parent_Field_API_Name__c));
					
					ParentSObjByParentFldMapByEvntFldApiNameMap.put(oObjEvtFldMappingMD.Event_Field_Api_Name__c, ParentSObjByParentFldMap); 
				}
			}
		}
		return ParentSObjByParentFldMapByEvntFldApiNameMap;
	}
	
	/**
	  * Description : protected virtual function to evaluate the postfix expression on the  
	  *				  instance of Old and New SObjects. 			  				  
	  *				  
	  *	@param String postfixExpression - postfix expression 
	  *	@param Map<String, Platform_Event_Trigger_Condition__mdt> PlatEvtTriggerCondByUniqNameMap -
	  			Various Platform event Trigger Conditions  
	  *	@param SObject oOldSObj  -  instance of old SObject 
	  * @param SObject oNewSObj  -  instance of new SObject 
	  * @return Boolean - returns the outcome of evaluating the postfix expression
	**/
	@TestVisible
	protected Boolean evaluatePostfixExpression(String postfixExpression, Map<String, 
			Platform_Event_Trigger_Condition__mdt> PlatEvtTriggerCondByUniqNameMap, 
			Map<String,Schema.RecordTypeInfo> RTInfoByRTDevNameMap, SObject oOldSObj, SObject oNewSObj) {
		System.debug('PlatformEventGeneratorGenericImpl::evaluatePostfixExpression()');
		// return result
		Boolean expressionResult;
		// indicated whether there are any errors in evaluating the expression
		Boolean isErr = false;
		try {
			if(String.isBlank(postfixExpression)) {
				isErr = true;
			} else {
				// create the inetance of a stack
				GenericStack stack = new GenericStack();
				// split the postfix expression using ' '. Please make sure that expressions are configured using
				// only single ' 'between tokens else it wil result in error.
				// Intensionally trim() or similar functions are avoided to format the expression as this code has to to be 
				// very efficient and such issues can be taken care where configuring the expression in MD 
				List<String> tokenList = postfixExpression.split(' ');
				for(String token : tokenList) {
					System.debug('token : '+token);
					if(token=='||') {
						String operand1 = (String)stack.pop();
						String operand2 = (String)stack.pop();
						
						System.debug('|| operand1 : '+operand1);
						System.debug('|| operand2 : '+operand2);
						
						// if either of the operands is already true, then the resultant expression will be 
						// true in OR operation, and there is no need to evaluate the other operand
						if(operand1=='t' || operand2=='t') {
							stack.push('t');
							System.debug('One of the || opernad is true so eqauation evaluated to true');
						} else {
							Boolean operand1Val=false;
							Boolean operand2Val=false;
							if(operand1!='f') {
								// evaluate the condition
								operand1Val = evaluateCondition(RTInfoByRTDevNameMap, PlatEvtTriggerCondByUniqNameMap.get(operand1), oOldSObj, oNewSObj);
							}
							
							if(operand2!='f') {
								// evaluate the condition
								operand2Val = evaluateCondition(RTInfoByRTDevNameMap, PlatEvtTriggerCondByUniqNameMap.get(operand2), oOldSObj, oNewSObj);
							}
							
							System.debug('pushing result of :'+operand1Val+' || '+operand2Val);
							stack.push((operand1Val || operand2Val) ? 't' : 'f');
						}
					} else if(token=='&&') {
						String operand1 = (String)stack.pop();
						String operand2 = (String)stack.pop();
						
						System.debug('&& operand1 : '+operand1);
						System.debug('&& operand2 : '+operand2);
						
						// if either of the operands is already false, then the resultant expression will be 
						// false in && operation, and there is no need to evaluate the other operand
						if(operand1=='f' || operand2=='f') {
							stack.push('f');
							System.debug('One of the && opernad is false so eqauation evaluated to false');
						} else {
							Boolean operand1Val=true;
							Boolean operand2Val=true;
							if(operand1!='t') {
								// evaluate the condition
								operand1Val = evaluateCondition(RTInfoByRTDevNameMap, PlatEvtTriggerCondByUniqNameMap.get(operand1), oOldSObj, oNewSObj);
							}
							
							if(operand2!='t') {
								// evaluate the condition
								operand2Val = evaluateCondition(RTInfoByRTDevNameMap, PlatEvtTriggerCondByUniqNameMap.get(operand2), oOldSObj, oNewSObj);
							}
							System.debug('pushing result of : '+operand1Val+' && '+operand2Val);
							stack.push((operand1Val && operand2Val) ? 't' : 'f');
						}
					} else {
						stack.push(token);
						System.debug('Just push the operand on stack : '+token);
					}
				}

				if(!stack.empty()) {
					String operand = (String)stack.pop();
					Boolean operandVal; 
					if(operand!='t' && operand!='f') {
						// evaluate the condition
						operandVal = evaluateCondition(RTInfoByRTDevNameMap, PlatEvtTriggerCondByUniqNameMap.get(operand), oOldSObj, oNewSObj);
					} else {
						operandVal = operand=='t';
					}
					//expressionResult = stack.pop()=='t';
					expressionResult = operandVal;
					System.debug('Finally fetch the result : '+expressionResult);
				} else {
					isErr=true;
				}
			}
		} catch(Exception ex) {
			System.debug('Error in Expression Parser : '+ex.getMessage()+' : '+ex.getLineNumber()+' : '+ex.getLineNumber());
			throw new PlatformEventGeneratorGenericImplException('There was an Exception in Parsing the expression : '+ex.getMessage());
		}

		if(isErr) {
			throw new PlatformEventGeneratorGenericImplException('Error in Parsing the expression');	
		}
		return expressionResult;
	}
	
	/**
	  * Description : protected virtual function to evaluate the individual condition from instances of
	  *				  Old and New SObjects baased on configuration in MD
	  *				  
	  *	@param Map<String,Schema.RecordTypeInfo> RTInfoByRTDevNameMap - RT info for a SObject for 
	  *			which events are being generated in order to evaluate the conditions to check the specific RT 
	  *	@param Platform_Event_Trigger_Condition__mdt oPlatEvntCond - Specific Trigger Condition MD
	  *	@param SObject oOldSObj  -  instance of old SObject 
	  * @param SObject oNewSObj  -  instance of new SObject 
	  * @return Boolean - returns the outcome of evaluating the individual condition
	**/
	protected Boolean evaluateCondition(Map<String,Schema.RecordTypeInfo> RTInfoByRTDevNameMap, 
			Platform_Event_Trigger_Condition__mdt oPlatEvntCond, SObject oOldSObj, SObject oNewSObj) {
		System.debug('#### evaluateCondition()');
		Boolean condResult = false;
		// evaluate the condition
		// intentionally ignore the checks that oPlatEvntCond  is not null and always assume we get a value
		// as these kind of checks here will make this code slower. And we can always rely that MetaData Types are
		// set-up correctly  
		// if(oPlatEvntCond != null)
		Object oldVal = oOldSObj!=null ? oOldSObj.get(oPlatEvntCond.sObject_Field_Api_Name__c) : null;
		Object newVal = oNewSObj!=null ? oNewSObj.get(oPlatEvntCond.sObject_Field_Api_Name__c) : null;
		
		System.debug('oPlatEvntCond : '+oPlatEvntCond);
		System.debug('oldVal : '+oldVal);
		System.debug('newVal : '+newVal);
		
		//	On_Value_Change__c   Is_Equal_To_Specific_Value__c	Interprete
		//		T						T						Value has changed and mus be equal to specific val	
		//		T						F						Value has changed and need not be equal to specific val
		//		F						T						Value need not change but and must be equal to specific val
		//		F						F						INVALID SCENARIO
		Boolean performValChk = false;
		if(oPlatEvntCond.On_Value_Change__c) {
			System.debug('Should be on On Value Change');
			// check this condition first because in most of cases trigger would on change of value codition
			if(oldVal!=newVal) {
				System.debug('Yes Value Changed');
				// inside this indicates that value has changed
				// currently it is assumed that specific value are always of type string, else we may need to
				// handle the logic of different types. There are several ways like
				// 1) Intrducing one additional field Value_Type__c to indicate the type lide - Integeer, Boolean etc
				if(oPlatEvntCond.Is_Equal_To_Specific_Value__c) {
					performValChk = true;
					System.debug('Equal to specific value will be performed');
				} else {
					condResult = true;
					System.debug('No Check on Equal to specific value will be performed...returning true');
				}
			}	
		} else {
			performValChk=true;
			System.debug('Just perform Equal to specific value will be performed');
		} 
		
		if(performValChk) {
			System.debug('Performing specific value check');
			switch on Integer.valueOf(oPlatEvntCond.Value_Type__c) {
				when 1 { // 1 == String type
                	condResult = newVal==oPlatEvntCond.Value__c;
                	System.debug('String Check - condResult : '+ condResult);
                }
				//when 2 { // 2 == Boolean type
               	//	operand1Val = newVal==Boolean.valueOf(oPlatEvntCond.Value__c);		     
                //}
                when 99 { // 99 == RecordTypeId for a given RecordType Developer name
                	condResult = newVal==RTInfoByRTDevNameMap.get(oPlatEvntCond.Value__c).getRecordTypeId();
                	System.debug('RT Check - condResult : '+ condResult);
                }
			}
		}
		
		System.debug('Final Condition Ootput : '+condResult);
		return condResult;
	}
	
	public class PlatformEventGeneratorGenericImplException extends Exception {}
}