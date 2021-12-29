public with sharing class AccountServiceModelServerController {
 
    public static Set<String> modelName = new Set<String>();
    public static List<String> listModel = new List<String>();
    public static Map<String, Map<String, String>> labels;
    
    @AuraEnabled
    public static List<String> getAccountModels(){
        system.debug(LoggingLevel.Info, 'in class');      
        List<Account_Service_Model__c> accServiceModel = [SELECT name from Account_Service_Model__c WHERE RecordType.Name = 'Actual' AND RecordType.SobjectType= 'Account_Service_Model__c'];
        
        for(Account_Service_Model__c asmName : accServiceModel){
        	modelName.add(asmName.Name);           
        }            
        
        listModel.addAll(modelName);        
      	 
        return listModel;
    }
    
    @AuraEnabled
    public static List<String> getCallReportType(){
        List<String> callReportTypeOptions = new List<String>();
		Schema.DescribeFieldResult callReportTypeResult = Account_Service_Model__c.Call_Report_Type__c.getDescribe();
		List<Schema.PicklistEntry> callReportTypeValues = callReportTypeResult.getPicklistValues();
		for (Schema.PicklistEntry values: callReportTypeValues) 
            callReportTypeOptions.add(values.getLabel());
              
        return callReportTypeOptions;
    }
    
    @AuraEnabled
    public static List<String> getContactCount(){
        List<String> contactCountOptions = new List<String>();
        Schema.DescribeFieldResult contactCountResult = Account_Service_Model__c.Is_Contact_Count__c.getDescribe();
        List<Schema.PicklistEntry> contactCountValues = contactCountResult.getPicklistValues();
        for(Schema.PicklistEntry values: contactCountValues)
            contactCountOptions.add(values.getLabel());
        
        return contactCountOptions;
    }
    
    
    @AuraEnabled
    public static List<String> getDealAxisEventType(){
        List<String> dealAxisEventTypeOptions = new List<String>();
        Schema.DescribeFieldResult dealAxisEventTypeResult = Account_Service_Model__c.DealAxis_Type__c.getDescribe();
        List<Schema.PicklistEntry> dealAxisEventTypeValues = dealAxisEventTypeResult.getPicklistValues();
        for(Schema.PicklistEntry values : dealAxisEventTypeValues){
            //string[] arrayDAEventType = values.getLabel().split('~');
            dealAxisEventTypeOptions.add(values.getLabel());
        }
        return dealAxisEventTypeOptions;
    }
    
    /*@AuraEnabled
    public static List<String> getDealAxisEventMeetingType(){
        List<String> dealAxisEventMeetingTypeOptions = new List<String>();
        Schema.DescribeFieldResult dealAxisEventMeetingTypeResult = Account_Service_Model__c.DealAxis_Type__c.getDescribe();
        List<Schema.PicklistEntry> dealAxisEventMeetingTypeValues = dealAxisEventMeetingTypeResult.getPicklistValues();
        for(Schema.PicklistEntry values : dealAxisEventMeetingTypeValues){
            string[] arrayDAEventType = values.getLabel().split('~');
            dealAxisEventMeetingTypeOptions.add(arrayDAEventType[1]);
        }        
        return dealAxisEventMeetingTypeOptions;
    }*/
    
   /* @AuraEnabled
    public static String getUser(){        
        String userName =  UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        return userName;
        
    }*/
    
    @AuraEnabled
    public static String saveAccountServiceModel(Account_Service_Model__c newASMRecord){
        	String result =  '';        
            Account_Service_Model__c newASM = new Account_Service_Model__c();       
        
            newASM.Name = newASMRecord.Name;
            newASM.Item_Name__c = newASMRecord.Item_Name__c;
            newASM.Call_Report_Type__c = newASMRecord.Call_Report_Type__c;
        
        	if(newASMRecord.Is_Contact_Count__c == '--None--')
                newASM.Is_Contact_Count__c = 'No';
        	else
            	newASM.Is_Contact_Count__c = newASMRecord.Is_Contact_Count__c;
        
            newASM.Weight__c = newASMRecord.Weight__c;
        
            //newASM.DealAxis_Event_Type__c = newASMRecord.DealAxis_Event_Type__c;
        
        	/*if(newASMRecord.DealAxis_Event_Meeting_Type__c == '--None--')
                 newASM.DealAxis_Event_Meeting_Type__c = '';
        	else
                 newASM.DealAxis_Event_Meeting_Type__c = newASMRecord.DealAxis_Event_Meeting_Type__c;
        */
        if(newASMRecord.DealAxis_Type__c!=null)
        newASM.DealAxis_Type__c = newASMRecord.DealAxis_Type__c;
        newASM.Order__c = newASMRecord.Order__c;
                  system.debug(newASM);   
            insert newASM;        
        	result += newASM.Id;
        
         return result;
    }
    
    @AuraEnabled
    public static String getListViews(){
        List<ListView> listViews = [SELECT Id FROM ListView WHERE SobjectType='Account_Service_Model__c' AND Name='All'];        
        String listId = null;
        if(listViews != null && listViews.size() > 0){
            listId = listViews.get(0).Id;
        }
        
        return listId;
    }
    
    @AuraEnabled
    public static Map<String, Map<String, String>> initialiseLabels(){
        labels = new Map<String, Map<String, String>>();        
        Map<String, List<String>> fieldsToGetLabelsMap = new Map<String, List<String>>();
        fieldsToGetLabelsMap.put('Account_Service_Model__c', new List<String>{'Name', 'Item_Name__c', 'Call_Report_Type__c', 'Weight__c', 'DealAxis_Type__c', 'Is_Contact_Count__c', 'Order__c' });
        labels = CommonTools.getSObjectFieldLabelMap(fieldsToGetLabelsMap); 

        return labels;
    }
}