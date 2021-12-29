/*
	Author 		: Simon Foden
	Company 	: Nomura
	Date 		: 19/10/2018
	Description : Controller for the ETradingEnablementClone 
				  Lightning component.
	
*/  
public with sharing class ETradingEnablementCloneController 
{
    @AuraEnabled(cacheable=true) 
    public static String getETradingEnablements(String sourceContactId)
    {
        ETradingEnablementData eTradingEnablementData = new ETradingEnablementData();

        if (String.isBlank(sourceContactId))
        {
            eTradingEnablementData.error = true;
            eTradingEnablementData.errorMessage = 'Error : No Contact selected';
            
            return JSON.serialize(eTradingEnablementData);
        }

        if (!checkFieldLevelSecurity())
        {
            eTradingEnablementData.error = true;
            eTradingEnablementData.errorMessage = 'Field Level Security Error : User does not have permission to view the data';
            
            return JSON.serialize(eTradingEnablementData);
        }

        eTradingEnablementData.eTradingEnablements = readETradingEnablements(sourceContactId);

        return JSON.serialize(eTradingEnablementData);
    }

    public static Boolean checkFieldLevelSecurity()
    {
        String [] accessFields = new String [] 
        {
            'Contact__c', 
            'Electronic_Platform__c', 
            'Sales_Team_for_Coverage__c', 
            'ETradingEnablementProduct__c',
            'Comments__c'
        };
    	
        Map<String, Schema.SObjectField> eTradingEnablementFields = Schema.SObjectType.ETradingEnablement__c.fields.getMap();
    
        for (String fieldToCheck : accessFields)
        {
            if (!eTradingEnablementFields.get(fieldToCheck).getDescribe().isAccessible())
            {
                return false;
            }
        }
        
        accessFields = new String [] 
        {
            'Id', 
            'Name', 
			'Category__c', 
			'Subcategory__c',  
			'Product__c', 
			'ProductLabel__c'
        };
    	
        Map<String, Schema.SObjectField> eTradingEnablementProductFields = Schema.SObjectType.ETradingEnablementProduct__c.fields.getMap();
    
        for (String fieldToCheck : accessFields)
        {
            if (!eTradingEnablementProductFields.get(fieldToCheck).getDescribe().isAccessible())
            {
                return false;
            }
        }
        
        accessFields = new String [] 
        {
            'Id', 
            'Name', 
			'Coverage_ID__c', 
			'Sales_Team__c'
        };
    	
        Map<String, Schema.SObjectField> salesTeamForCoverageFields = Schema.SObjectType.Sales_Team_for_Coverage__c.fields.getMap();
    
        for (String fieldToCheck : accessFields)
        {
            if (!salesTeamForCoverageFields.get(fieldToCheck).getDescribe().isAccessible())
            {
                return false;
            }
        }

        return true;
    }

    private static List<ETradingEnablement> readETradingEnablements(Id sourceContactId)
    {
        List<ETradingEnablement> eTradingEnablements = new List<ETradingEnablement>();

        Id eTradingEnablementCoverageRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Coverage').getRecordTypeId();

        for (ETradingEnablement__c eTradingEnablement : [SELECT Id, 
                                                         Contact__c, 
                                                         Electronic_Platform__c, 
                                                         Sales_Team_for_Coverage__c, 
                                                         Sales_Team_for_Coverage__r.Coverage_ID__c,
                                                         Sales_Team_for_Coverage__r.Name, 
                                                         Sales_Team_for_Coverage__r.Sales_Team__c,
                                                         ETradingEnablementProduct__c, 
                                                         ETradingEnablementProduct__r.Category__c, 
                                                         ETradingEnablementProduct__r.Subcategory__c, 
                                                         ETradingEnablementProduct__r.ProductLabel__c, 
                                                         Status__c, RecordTypeId 
                                                         FROM ETradingEnablement__c 
                                                         WHERE Contact__c = :sourceContactId 
                                                         AND Status__c = 'Active' 
                                                         AND RecordTypeId = :eTradingEnablementCoverageRecordTypeId 
                                                         ORDER BY Electronic_Platform__c, 
                                                         ETradingEnablementProduct__r.ProductLabel__c])
        {
            ETradingEnablement eTradingEnablementObject = new ETradingEnablement();

            eTradingEnablementObject.platform = eTradingEnablement.Electronic_Platform__c;

            eTradingEnablementObject.salesCode = '';

            if (!String.isBlank(eTradingEnablement.Sales_Team_for_Coverage__r.Name))
            {
                eTradingEnablementObject.salesCode = eTradingEnablement.Sales_Team_for_Coverage__r.Name;
            }

            if (!String.isBlank(eTradingEnablement.Sales_Team_for_Coverage__r.Coverage_ID__c))
            {
                eTradingEnablementObject.salesCode += ' (' + eTradingEnablement.Sales_Team_for_Coverage__r.Coverage_ID__c + ') ';
            }

            if (!String.isBlank(eTradingEnablement.Sales_Team_for_Coverage__r.Sales_Team__c))
            {
                eTradingEnablementObject.salesCode += eTradingEnablement.Sales_Team_for_Coverage__r.Sales_Team__c;
            }

            eTradingEnablementObject.salesCodeId = eTradingEnablement.Sales_Team_for_Coverage__c;

            eTradingEnablementObject.product = '';

            if (!String.isBlank(eTradingEnablement.ETradingEnablementProduct__r.Category__c))
            {
                eTradingEnablementObject.product += eTradingEnablement.ETradingEnablementProduct__r.Category__c + ' - ';
            }

            if (!String.isBlank(eTradingEnablement.ETradingEnablementProduct__r.Subcategory__c))
            {
                eTradingEnablementObject.product += eTradingEnablement.ETradingEnablementProduct__r.Subcategory__c + ' - ';
            }

            if (!String.isBlank(eTradingEnablement.ETradingEnablementProduct__r.ProductLabel__c))
            {
                eTradingEnablementObject.product += eTradingEnablement.ETradingEnablementProduct__r.ProductLabel__c;
            }
            
            eTradingEnablementObject.productId = eTradingEnablement.ETradingEnablementProduct__c;

            eTradingEnablements.add(eTradingEnablementObject);
        }

        return eTradingEnablements;
    }

    @AuraEnabled 
    public static String cloneETradingEnablements(String sourceContactId, String[] targetContactIds, String comments, String cloneData)
    {
        List<ETradingEnablement> eTradingEnablementObjects = (List<ETradingEnablement>) JSON.deserialize(cloneData, List<ETradingEnablement>.class);

        ETradingEnablementClone eTradingEnablementClone = new ETradingEnablementClone();

        try 
        {
            List<ETradingEnablement__c> eTradingEnablements = new List<ETradingEnablement__c>();

            for (Id targetContactId : targetContactIds)
            {
                for (ETradingEnablement eTradingEnablement : eTradingEnablementObjects)
                {
                    ETradingEnablement__c request = new ETradingEnablement__c();

                    request.Contact__c = targetContactId;
                    request.Electronic_Platform__c = eTradingEnablement.platform;
                    request.Sales_Team_for_Coverage__c = eTradingEnablement.salesCodeId;
                    request.ETradingEnablementProduct__c = eTradingEnablement.productId;
                    request.Comments__c = comments;

                    eTradingEnablements.add(request);
                }
            }

            insert eTradingEnablements;
        }
        catch(Exception e)
        {
            eTradingEnablementClone.error = true;
            eTradingEnablementClone.errorMessage = 'Error : ' + e.getMessage();
        }

        return JSON.serialize(eTradingEnablementClone); 
    }

    public class ETradingEnablementData
    {
        public ETradingEnablementData() 
        {
        	error = false;
            errorMessage = '';
        }   
        
        public Boolean error;
		public String errorMessage;  

        public List<ETradingEnablement> eTradingEnablements;
    }

    public class ETradingEnablement
    {
        public String platform;
        public String salesCode;
        public Id salesCodeId;
        public String product;
        public Id productId;
    }

    public class ETradingEnablementClone
    {
        public ETradingEnablementClone() 
        {
        	error = false;
            errorMessage = '';
        }   
        
        public Boolean error;
		public String errorMessage;  
    }
}