public with sharing class ObjectUtil{ 
    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    public static string getCreatableFieldsSOQL(String objectName, String whereClause){
        String selects = '';
       /* if (whereClause == null || whereClause == ''){ return null; }*/
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
        string soql = 'SELECT ' + selects + ' FROM ' + objectName;
        if(objectName == 'Coverage_Team_Member__c') 
        {
           return 'SELECT id,' + selects + ',Account__r.Domicile_Country__c,Account__r.BillingCountry,Account__r.isNewRM__c,Account__r.isRMChanged__c,Account__r.Restricted_Flag__c,Account__r.Current_RG__c,Account__r.Previous_RG__c,Account__r.RDM_Org_Id__c,Account__r.ParentId,Account__r.Name,Sales_Team_For_Coverage__r.Is_dummy__c,Sales_Team_For_Coverage__r.Company__c,Sales_Team_For_Coverage__r.Coverage_ID__c,Sales_Team_For_Coverage__r.Name,Sales_Team_For_Coverage__r.Sales_Code_Login_Id__c,Sales_Team_For_Coverage__r.Sales_Team__c,Sales_Team_For_Coverage__r.Active__c,Sales_Team_For_Coverage__r.Owner_Active__c,Sales_Team_For_Coverage__r.Is_Split_Sales_Code__c,Sales_Team_For_Coverage__r.OwnerId,Sales_Team_For_Coverage__r.Sales_Desk_Division__c, Sales_Team_For_Coverage__r.Sales_Desk_Region__c, Sales_Team_For_Coverage__r.Desk_Name__c FROM ' + objectName;
        }   
        else
            return soql;
         
    }
 
}