/*
 * @Created Date:- 30th April 2020
 * @Author : Sankar
 * @Description : Class used for operations related to fieldset
 * @Company : Nomura
 * @Name : FieldsetService
 */ 
public class FieldsetService {
    
    /*
     * @Created Date:- 30th April 2020
     * @Author : Sankar
     * @Name : getsObjects
     * @ReturnType : List<String>
     * @param : none
     * @Description : List all the Objects that have atlead one fieldSet 
     */ 
    
    public static List<String> getsObjects(){
        List<String> sObjectList = new List<String>();
        FOR(Schema.SObjectType sObj : Schema.getGlobalDescribe().values()){
            // Show only those objects which have atleast one Field Set
            Map<String, Schema.FieldSet> FieldSetMap = sObj.getDescribe().fieldSets.getMap();
            if(FieldSetMap!=null && FieldSetMap.keySet().size() > 0){
                sObjectList.add(sObj.getDescribe().getName() +'####'+sObj.getDescribe().getLabel());
            }
        }
        return sObjectList;
    }
    
    /*
     * @Created Date:- 30th April 2020
     * @Author : Sankar
     * @Name : getFieldSet
     * @ReturnType : List<String>
     * @param : String sObjectName
     * @Description : List all the Fiels Sets of a particular Object 
     */ 
    
    public static List<String> getFieldSet(String sObjectName){
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(sObjectName);
        List<String> fieldSetList = new List<String>();
        FOR(Schema.FieldSet FS : sObj.getDescribe().fieldSets.getMap().values()){
            fieldSetList.add(fs.getName() +'####'+fs.getLabel());
        }
        return fieldSetList;
    }
    
    /*
     * @Created Date:- 30th April 2020
     * @Author : Sankar
     * @Name : getFieldSetMember
     * @ReturnType : String
     * @param : String objectName , String fieldSetName
     * @Description : List all the Fields that are added into the FielsSet
     */
    public static String getFieldSetMemberJSON(String objectName , String fieldSetName){
        
        List<FieldSetMemberWrapperClass> wrapperList = new List<FieldSetMemberWrapperClass>();
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(objectName);
        
        for(Schema.FieldSetMember fieldMember : sObj.getDescribe().fieldSets.getMap().get(fieldSetName).getFields()){
            FieldSetMemberWrapperClass wrapper = new FieldSetMemberWrapperClass();
            wrapper.isDBRequired = fieldMember.getDbRequired();
            wrapper.isRequired = fieldMember.getRequired();
            wrapper.fieldType = String.valueOf(fieldMember.getType());
            wrapper.fieldLabel = fieldMember.getLabel();
            wrapper.fieldAPIName = fieldMember.getFieldPath();
            if(String.valueOf(fieldMember.getType()) == 'PICKLIST' || 
               				String.valueOf(fieldMember.getType()) == 'MULTIPICKLIST'){
                wrapper.pickListValues = sObj.getDescribe().fields.getMap().get(fieldMember.getFieldPath())
                    									   .getDescribe().getPicklistValues();
            }
            wrapperList.add(wrapper);
        }
        //System.debug('#### wrapperList '+wrapperList);
        
        return JSON.serialize(wrapperList);
    }
	
	/*
     * @Created Date:- 30th April 2020
     * @Author : Sankar
     * @Name : getFieldSetMember
     * @ReturnType : String
     * @param : String objectName , String fieldSetName
     * @Description : List all the Fields that are added into the FielsSet
     */
    public static List<FieldSetMemberWrapperClass> getFieldSetMember(String objectName , String fieldSetName){
        
        List<FieldSetMemberWrapperClass> wrapperList = new List<FieldSetMemberWrapperClass>();
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(objectName);
        
        for(Schema.FieldSetMember fieldMember : sObj.getDescribe().fieldSets.getMap().get(fieldSetName).getFields()) {
            FieldSetMemberWrapperClass wrapper = new FieldSetMemberWrapperClass();
            wrapper.isDBRequired = fieldMember.getDbRequired();
            wrapper.isRequired = fieldMember.getRequired();
            wrapper.fieldType = String.valueOf(fieldMember.getType());
            wrapper.fieldLabel = fieldMember.getLabel();
            wrapper.fieldAPIName = fieldMember.getFieldPath();
            if(String.valueOf(fieldMember.getType()) == 'PICKLIST' || 
               				String.valueOf(fieldMember.getType()) == 'MULTIPICKLIST'){
                wrapper.pickListValues = sObj.getDescribe().fields.getMap().get(fieldMember.getFieldPath())
                    									   .getDescribe().getPicklistValues();
            }
            wrapperList.add(wrapper);
        }
        
        return wrapperList;
    }
    
     /*
     * @Created Date:- 1st April 2020
     * @Author : Ahmad K
     * @Name : getFieldSetValuesByAPIName
     * @Description : Get a set of all the API names of fields in a fieldset
     */ 
    public static Set<String> getFieldSetValuesByAPIName(String objectName, String fieldSetName) {
        Set<String> fieldSetAPINames = new Set<String> ();
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(objectName);
        for(Schema.FieldSetMember fieldMember : sObj.getDescribe().fieldSets.getMap().get(fieldSetName).getFields()) {
            fieldSetAPINames.add(fieldMember.getFieldPath().toLowerCase());
        }
        return fieldSetAPINames; 
    }
	
	public static Map<Id, Boolean> hasFieldsetFieldChanged(String objectName , String fieldSetName, Map<Id, SObject> oldMap, Map<Id, SObject> newMap){
		List<FieldSetMemberWrapperClass> wrapperList = getFieldSetMember(objectName , fieldSetName);
		Map<Id, Boolean> hasAnyFieldChanged = new Map<Id, Boolean>();
        for(Id key : newMap.keySet()){
            SObject nSObj = newMap.get(key);
            SObject oSObj = oldMap.get(key);
            Boolean fieldChanged = false;
            for(FieldSetMemberWrapperClass fsmwc : wrapperList){
                if(nSObj.get(fsmwc.fieldAPIName) != oSObj.get(fsmwc.fieldAPIName)){
                    fieldChanged = true;
                    break;
                }
                hasAnyFieldChanged.put(key,  fieldChanged);
            }			
		}
		
		return hasAnyFieldChanged;
	}
    
     /*
     * @Created Date:- 4th April 2020
     * @Author : Ahmad K
     * @Name : validateRecordUpdateAgainstEditableFieldSet
     * @Description : Validates that no fields other than the editable fields are modified
     */ 
    public static Map<Id, List<String>> validateRecordUpdateAgainstEditableFieldSet(String sObjectAPIName, String editableFieldsetName, Map<Id, SObject> oldMap, List<SObject> newList) {
        Map<Id, List<String>> recordIdToListOfFieldsToError = new Map<Id, List<String>> (); 
        if (String.isNotBlank(sObjectAPIName) && String.isNotBlank(editableFieldsetName) && !oldMap.isEmpty() && !newList.isEmpty()) {
            // Get all field API Names from the field set
            Set<String> editableFields = FieldsetService.getFieldSetValuesByAPIName(sObjectAPIName, editableFieldsetName);
            
            // Get all fields from the sObject
            SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectAPIName);
            Map<String,Schema.SObjectField> sObjectFieldMap = sObjectType.getDescribe().fields.getMap();
            
            for (SObject newRecord : newList) {
                SObject oldRecord = oldMap.containsKey(newRecord.Id) ? oldMap.get(newRecord.Id) : null;
                if (oldRecord != null) {
                    for (String field : sObjectFieldMap.keySet()) {
                        if (!editableFields.contains(field) && (newRecord.get(field) != oldRecord.get(field))) {
                            if (recordIdToListOfFieldsToError.containsKey(newRecord.Id)) {
                                recordIdToListOfFieldsToError.get(newRecord.Id).add(field);
                            } else {
                                recordIdToListOfFieldsToError.put(newRecord.Id, new List<String> {field});
                            }
                        }
                    }
                }
            }
        }
        return recordIdToListOfFieldsToError;
    }
    
        
    /*
     * @Description : Wrapper class contains the information about all the fields of a FieldSet
     */ 
    public class FieldSetMemberWrapperClass{
        
        @AuraEnabled
        public Boolean isDBRequired 					 { get; set; }
        @AuraEnabled
        public Boolean isRequired 						 { get; set; }
        @AuraEnabled
        public String fieldType 						 { get; set; }
        @AuraEnabled
        public String fieldLabel 						 { get; set; }
        @AuraEnabled
        public String fieldAPIName 					     { get; set; }
        
        public List<Schema.PicklistEntry> pickListValues { get; set; }
        
    }
}