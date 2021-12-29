/*
	Author 		: Simon Foden
	Company 	: Nomura
	Date 		: 30/11/2018
	Description : Controller for the ETradingEnablementAssignContact 
				  Lightning component.
	
*/  
public with sharing class ETradingAssignContactController 
{
    @AuraEnabled(cacheable=true) 
    public static String getETradingData()
    {
        ETrading eTrading = new ETrading();

		if (!checkFieldLevelSecurity())
		{
			eTrading.error = true;
            eTrading.errorMessage = 'Field Level Security Error : User does not have permission to view the data';
            
			return JSON.serialize(eTrading);
		}

		eTrading.eTradingData = getETradingEnablementData();

		return JSON.serialize(eTrading);
    }

	public static Boolean checkFieldLevelSecurity()
    {
		String [] accessFields = new String [] 
        {
            'Contact__c', 
            'Electronic_Platform__c', 
			'Platform_Id__c',
			'Platform_First_Name__c',
			'Platform_Last_Name__c',
			'Platform_Contact__c',
			'Platform_Account__c'
        };
    	
        Map<String, Schema.SObjectField> eTradingEnablementFields = Schema.SObjectType.ETradingEnablement__c.fields.getMap();
    
        for (String fieldToCheck : accessFields)
        {
            if (!eTradingEnablementFields.get(fieldToCheck).getDescribe().isAccessible())
            {
                return false;
            }
        }
        
        return true;
    }

	public static List<ETradingData> getETradingEnablementData()
	{
		List<ETradingData> eTradingEnablementData = new List<ETradingData>();

		Map<String, ETradingEnablement__c> eTradingEnablements = readETradingEnablements();

		for (ETradingEnablement__c eTradingEnablement : eTradingEnablements.values())
		{
			ETradingData eTradingData = new ETradingData();

			eTradingData.platformId = eTradingEnablement.Platform_Id__c;
			eTradingData.platformUser = eTradingEnablement.Platform_First_Name__c + ' ' + eTradingEnablement.Platform_Last_Name__c;
			eTradingData.platformEmail = eTradingEnablement.Platform_Email__c;
			eTradingData.platform = eTradingEnablement.Electronic_Platform__c;
			eTradingData.platformAccount = eTradingEnablement.Platform_Account__c;

			eTradingEnablementData.add(eTradingData);
		}  

		return eTradingEnablementData;
	}

	public static Map<String, ETradingEnablement__c> readETradingEnablements()
	{
		Id eTradingEnablementRequestRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Request').getRecordTypeId();
		
		Map<String, ETradingEnablement__c> eTradingEnablements = new Map<String, ETradingEnablement__c>();

		for (ETradingEnablement__c eTradingEnablement : [SELECT 
														 Platform_Id__c, 
											     		 Platform_First_Name__c, 
											     		 Platform_Last_Name__c, 
														 Platform_Email__c, 
														 Electronic_Platform__c, 
												 		 Platform_Account__c 
												 		 FROM ETradingEnablement__c 
												 		 WHERE Contact__r.Developer_Reference__c = 'Unassigned eTrading'
												 		 AND Status__c = 'On Hold' 
														 AND RecordTypeId = :eTradingEnablementRequestRecordTypeId 
														 ORDER BY CreatedDate DESC
														])
		{
			eTradingEnablements.put(eTradingEnablement.Platform_Id__c + eTradingEnablement.Electronic_Platform__c, eTradingEnablement);
		}
		
		return eTradingEnablements;
	}

	@AuraEnabled
	public static String saveETradingPlatformContactData(String eTradingPlatformIdContactId)
	{
		ETradingPlatformIdContactIds eTradingPlatformIdContactIds = (ETradingPlatformIdContactIds) JSON.deserialize(eTradingPlatformIdContactId, ETradingPlatformIdContactIds.class);

		ETradingAssignContact eTradingAssignContact = new ETradingAssignContact();

		try 
		{
			updateETradingEnablements(eTradingPlatformIdContactIds);
		}
		catch(Exception e)
		{
			eTradingAssignContact.error = true;
			eTradingAssignContact.errorMessage = e.getMessage();

			return JSON.serialize(eTradingAssignContact);
		}

		return JSON.serialize(eTradingAssignContact);
	}

	public static void updateETradingEnablements(ETradingPlatformIdContactIds eTradingPlatformIdContactIds)
	{
		Map<String, Id> eTradingPlatformIdContactIdMap = new Map<String, Id>();

		for (ETradingPlatformIdContactId eTradingPlatformIdContactId : eTradingPlatformIdContactIds.eTradingPlatformIdContactIds)
		{
			if (!String.isBlank(eTradingPlatformIdContactId.contactId))
			{
				eTradingPlatformIdContactIdMap.put(eTradingPlatformIdContactId.platformId, eTradingPlatformIdContactId.contactId);
			}
		}

		Id eTradingEnablementRequestRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Request').getRecordTypeId();

		List<ETradingEnablement__c> eTradingEnablements = [SELECT Id, 
														   Contact__c, 
														   Contact__r.Developer_Reference__c, 
														   Status__c, 
														   RecordTypeId, 
														   Platform_Id__c 
														   FROM ETradingEnablement__c 
														   WHERE Contact__r.Developer_Reference__c = 'Unassigned eTrading'
														   AND Status__c = 'On Hold' 
														   AND RecordTypeId = :eTradingEnablementRequestRecordTypeId 
														   AND Platform_Id__c IN : eTradingPlatformIdContactIdMap.keySet()]; 

		for (ETradingEnablement__c eTradingEnablement : eTradingEnablements)
		{
			eTradingEnablement.Contact__c = eTradingPlatformIdContactIdMap.get(eTradingEnablement.Platform_Id__c);
			eTradingEnablement.Status__c = 'Pending Approval';
		}

		update eTradingEnablements;
	}

	public class ETrading
 	{
        public ETrading()
		{
			error = false;
            errorMessage = '';
		}

		public Boolean error;
		public String errorMessage;

		public Boolean displayETradingData;
		public List<ETradingData> eTradingData;
 	}

	public class ETradingData
	{
		public String platformId;
		public String platformUser; 
		public String platformEmail; 
		public String platform;
		public String platformAccount;
		public DateTime createdDate; 
	}

	public class ETradingPlatformIdContactIds
	{
		public ETradingPlatformIdContactId[] eTradingPlatformIdContactIds;
	}
	
	public class ETradingPlatformIdContactId
    {
		public String platformId;
		public String contactId;
    }

	public class ETradingAssignContact
 	{
        public ETradingAssignContact()
		{
			error = false;
            errorMessage = '';	
		}

		public Boolean error;
		public String errorMessage;
	}
}