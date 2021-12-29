/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : Service calss for User_Permission_Set_Matrix__mdt and provides reusable functionality
**/  
public class UserPermissionSetMatrixService {
	// e.g. Map<'User_FieldApiName_1', Map<'val1', List<PSName1,PSName2>>>
	// in the first map, key = ObjectApiName +'_'+ FieldApiName
	// e.g. key = 'User_AdditionalPermissions__c'
	private static Map<String, Map<String, List<String>>> UserPSNameListByFldValMapByObjAndFieldApiMap;
	
	static {
		UserPSNameListByFldValMapByObjAndFieldApiMap=new Map<String, Map<String, List<String>>>();
	}

    
    public static Map<String, List<String>> getPSNameMatrixByFieldValues(String objApiName, String fieldApiName) {
    	System.debug('#### UserPermissionSetMatrixService.getUserPSMatrixMDByFieldValues()');
		// Return Value
		Map<String, List<String>> UserPSNameListByFldValMap;
		
		String mapKey = objApiName+'_'+fieldApiName;
		if(UserPSNameListByFldValMapByObjAndFieldApiMap.containsKey(mapKey)) {
			// Information for given Object and for given field already exists
			UserPSNameListByFldValMap = UserPSNameListByFldValMapByObjAndFieldApiMap.get(mapKey);
		} else {
			// Find and buffer the information in Map so that it is reused in same transaction without quering again 
			UserPSNameListByFldValMap = new Map<String, List<String>>();
    		List<User_Permission_Set_Matrix__mdt> UserPSMarixList = [SELECT Id, Label, Active__c,Object_API_Name__c,
    				Field_API_Name__c,Field_Value__c,Permission_Set_Names_List__c
    			FROM User_Permission_Set_Matrix__mdt 
    			WHERE Object_API_Name__c=:objApiName AND Field_API_Name__c=:fieldApiName AND Active__c=True];
			// populate the map	
    		for(User_Permission_Set_Matrix__mdt oUserPSMatrix : UserPSMarixList) {
    			List<String> PSNameList = new List<String>();
    			if(String.isNotBlank(oUserPSMatrix.Permission_Set_Names_List__c)) {
    				PSNameList=oUserPSMatrix.Permission_Set_Names_List__c.split(',');
    			}
    			UserPSNameListByFldValMap.put(oUserPSMatrix.Field_Value__c, PSNameList);
    		}
			     		
    		UserPSNameListByFldValMapByObjAndFieldApiMap.put(mapKey, UserPSNameListByFldValMap);
		}
		
		return UserPSNameListByFldValMap;
   }
    
}