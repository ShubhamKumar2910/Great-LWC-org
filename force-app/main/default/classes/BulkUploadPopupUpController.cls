public with sharing class BulkUploadPopupUpController {
    
    public string objName{get;set;}
    public string fieldName{get;set;}
    public string fieldLabel{get;set;}
    public string fieldValues{get;set;}
    public string recordTypeName{get;set;}
    public string REcordTypeIdValue{get;set;} //dealAxis
    public List<string> eqList{get;set;}
    public List<string> eqListWithRegion{get;set;}
    public List<string> FIList{get;set;}
    public Map<string,List<string>> productRegionMap{get;set;}
                    
    Map<String, Schema.SObjectField> fieldMap;
    
    Schema.DescribeFieldResult fieldResult;
    
    public BulkUploadPopupUpController()
    {
        objName =  ApexPages.currentPage().getParameters().get('objectName');
        fieldName =  ApexPages.currentPage().getParameters().get('fieldName');
        recordTypeName =  ApexPages.currentPage().getParameters().get('type');
        if(objName!=null && fieldName!=null)
        {
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType objSchema = schemaMap.get(objName);
            fieldMap = objSchema.getDescribe().fields.getMap();
            
			if(objName == 'Event')
            { 
                if(recordTypeName!=null)
                {
                    REcordTypeIdValue = [select id from RecordType where DeveloperName=:recordTypeName limit 1].id;
                }
                if(fieldName == 'Event_Origination_Region__c')
                {
                    fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
                }
                else if(fieldName == 'Event_Type__c')
                {
                    fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
                }
                else if(fieldName == 'Type')
                {
                    fieldLabel = 'Event Meeting Types';
                }    
            }
            
            if(objName == 'Coverage_Team_Member__c')
            {
                if(fieldName == 'Product_Group__c')
                {
                    fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
                }
                if(fieldName == 'Product2__c')
                {
                     Map<String,List<String>> valueMap = PicklistFieldController.getDependentOptionsImpl('Coverage_Team_Member__c','Product_Group__c','Product2__c');
        			 eqList = valueMap.get('Equity');
                     
                     FIList = valueMap.get('Fixed Income');
                   /* productRegionMap = new Map<string,List<string>>();
                    for(Schema.Picklistentry pe:getValues(fieldName))
                    {
                        List<string> productRegionList = pe.getvalue().split('-');
                        if(productRegionList.size()>0)
                        {
                            if(productRegionMap.get(productRegionList[0].trim()) == null)
                                productRegionMap.put(productRegionList[0].trim(), new List<string>{productRegionList[1].trim().toLowerCase()});  
                            else
                                productRegionMap.get(productRegionList[0].trim()).add(productRegionList[1].trim().toLowerCase());
                        }
                    }
                    for(String contr : productRegionMap.keySet()){
                        System.debug('Product: ' + contr);
                        System.debug('Regions: ' + productRegionMap.get(contr));
                        system.debug('-----------------------------------------------');
                    }
                    eqListWithRegion = new List<string>();
                    for(String eqProduct: eqList)
                    {
                        String regionValues = '';
                        Integer i=1;
                        System.debug('Actual Product: ' + eqProduct);
                        try{
                            system.debug(productRegionMap.get(eqProduct.toLowerCase()));
                            if(productRegionMap.get(eqProduct.toLowerCase())!=null)
                            {
                                for(String region: productRegionMap.get(eqProduct.toLowerCase()))
                                {
                                    if(regionValues == '')
                                        regionValues = '['+region;
                                    else
                                        regionValues +='/'+ region;
                                    
                                    if(i==productRegionMap.get(eqProduct.toLowerCase()).size())
                                        regionValues += ']';
                                    i++;
                                }
                                eqProduct = eqProduct + ''+regionValues;
                                eqListWithRegion.add(eqProduct);
                                system.debug('eqProduct: '+eqProduct);
                            }
                            
                        }
                        catch(Exception e)
                        {
                            system.debug('Exception - '+eqProduct.toLowerCase());
                        }
                       
                    }*/
                }
            }
            	
        }
            
        if((recordTypeName==null || recordTypeName == ''))
        {
            system.debug('fieldName'+fieldName);
            if(fieldName!=null)
            {
                fieldValues = '';
                
                if(fieldName == 'TimeZone')
                {
                    fieldLabel = 'TimeZones';
                    fieldValues='Pacific/Kiritimati<br/>Pacific/Enderbury<br/>Pacific/Tongatapu<br/>Pacific/Chatham<br/>Pacific/Auckland<br/>Pacific/Fiji<br/>Asia/Kamchatka<br/>Pacific/Norfolk<br/>Australia/Lord_Howe<br/>Pacific/Guadalcanal<br/>Australia/Adelaide<br/>Australia/Sydney<br/>Australia/Brisbane<br/>Australia/Darwin<br/>Asia/Seoul<br/>Asia/Tokyo<br/>Asia/Hong_Kong<br/>Asia/Kuala_Lumpur<br/>Asia/Manila<br/>Asia/Shanghai<br/>Asia/Singapore<br/>Asia/Taipei<br/>Australia/Perth<br/>Asia/Bangkok<br/>Asia/Ho_Chi_Minh<br/>Asia/Jakarta<br/>Asia/Rangoon<br/>Asia/Dhaka<br/>Asia/Kathmandu<br/>Asia/Colombo<br/>Asia/Kolkata<br/>Asia/Karachi<br/>Asia/Tashkent<br/>Asia/Yekaterinburg<br/>Asia/Kabul<br/>Asia/Baku<br/>Asia/Dubai<br/>Asia/Tbilisi<br/>Asia/Yerevan<br/>Asia/Tehran<br/>Africa/Nairobi<br/>Asia/Baghdad<br/>Asia/Kuwait<br/>Asia/Riyadh<br/>Europe/Minsk<br/>Europe/Moscow<br/>Africa/Cairo<br/>Asia/Beirut<br/>Asia/Jerusalem<br/>Europe/Athens<br/>Europe/Bucharest<br/>Europe/Helsinki<br/>Europe/Istanbul<br/>Africa/Johannesburg<br/>Europe/Amsterdam<br/>Europe/Berlin<br/>Europe/Brussels<br/>Europe/Paris<br/>Europe/Prague<br/>Europe/Rome<br/>Europe/Lisbon<br/>Africa/Algiers<br/>Europe/London<br/>Atlantic/Cape_Verde<br/>Africa/Casablanca<br/>Europe/Dublin<br/>GMT<br/>America/Scoresbysund<br/>Atlantic/Azores<br/>Atlantic/South_Georgia<br/>America/St_Johns<br/>America/Sao_Paulo<br/>America/Argentina/Buenos_Aires<br/>America/Santiago<br/>America/Halifax<br/>America/Puerto_Rico<br/>Atlantic/Bermuda,America/Caracas<br/>America/Indiana/Indianapolis<br/>America/New_York<br/>America/Bogota<br/>America/Lima<br/>America/Panama<br/>America/Mexico_City<br/>America/Chicago<br/>America/El_Salvador<br/>America/Denver<br/>America/Mazatlan<br/>America/Phoenix<br/>America/Los_Angeles<br/>America/Tijuana<br/>Pacific/Pitcairn<br/>America/Anchorage<br/>Pacific/Gambier<br/>America/Adak<br/>Pacific/Marquesas<br/>Pacific/Honolulu<br/>Pacific/Niue<br/>Pacific/Pago_Pago';
                } 
                else
                {
                    for(Schema.Picklistentry pe:getValues(fieldName))
                    {
                        if(fieldValues == '')
                            fieldValues = pe.getvalue();
                        else
                            fieldValues += '<br/>'+pe.getvalue();    
                    }
                }
                
            }
            else
            {
                fieldValues = 'Value not found.';
            }
        }
    }
    
    public List<Schema.PicklistEntry> getValues(string fieldName)
    {
        system.debug('Object Name: '+objName);
        system.debug('fieldName Name: '+fieldName);
        if(objName!=null)
        {
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
           
            if(objName == 'Event')
            {
                Schema.SObjectType objSchema = schemaMap.get(objName);
                Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();
                
                if(fieldName == 'Event_Origination_Region__c')
                {
                    Schema.DescribeFieldResult fieldResult = Event.Event_Origination_Region__c.getDescribe();
                    fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
                    return fieldResult.getPicklistValues();
                }
                else if(fieldName == 'Event_Type__c')
                {
                    Schema.DescribeFieldResult fieldResult = Event.Event_Type__c.getDescribe();
                    fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
                    return fieldResult.getPicklistValues();
                }
                else if(fieldName == 'Type')
                {
                    Schema.DescribeFieldResult fieldResult = Event.Type.getDescribe();
                    fieldLabel = 'Event Meeting Types';
                    return fieldResult.getPicklistValues();
                }                
            }
            
            if(objName == 'Survey_Question__c')
            {
                Schema.SObjectType objSchema = schemaMap.get('Survey_Question__c');
                Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();
                
                if(fieldName == 'Category__c')
                {
                    Schema.DescribeFieldResult fieldResult = Survey_Question__c.Category__c.getDescribe();
                    fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
                    return fieldResult.getPicklistValues();
                }
            }
            
            if(objName == 'Coverage_Team_Member__c')
            {
                if(fieldName == 'Product_Group__c')
                {
                    Schema.DescribeFieldResult fieldResult = Coverage_Team_Member__c.Product_Group__c.getDescribe();
                    fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
                    return fieldResult.getPicklistValues();
                }
                if(fieldName == 'Product_Region__c')
                {
                    Schema.DescribeFieldResult fieldResult = Coverage_Team_Member__c.Product_Region__c.getDescribe();
                    fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
                    return fieldResult.getPicklistValues();
                }
                if(fieldName == 'Product2__c')
                {
                    Schema.DescribeFieldResult fieldResult = Coverage_Access_Request__c.Product__c.getDescribe();
                    fieldLabel = 'Product Name';
                    return fieldResult.getPicklistValues();
                }
                 if(fieldName == 'Team_Role__c')
                {
                    Schema.DescribeFieldResult fieldResult = Coverage_Team_Member__c.Team_Role__c.getDescribe();
                    fieldLabel = 'Role';
                    return fieldResult.getPicklistValues();
                }
            }
        }
        return null;
    }
    
}