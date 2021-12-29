public with sharing class ExternalCodeMappingTriggerHandler {
     public static void mainEntry(System.TriggerOperation operationType, List<External_Code_Mapping__c> newList, List<External_Code_Mapping__c> oldList, 
                                Map<Id, External_Code_Mapping__c> newMap, Map<Id, External_Code_Mapping__c> oldMap){

        System.debug('--operationType--' + operationType);
        switch on operationType {
            when AFTER_INSERT {
                createSchRequest(newList);
            }
            when BEFORE_DELETE {
                createSchRequest(oldList);
            }
        }
    }


    public static void createSchRequest(List<External_Code_Mapping__c> externalCodeMappingList){
        Id schExternalCodeMappingRecordId = Schema.getGlobalDescribe().get('Sch_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get('RM_Account_External_Code_Mapping').getRecordTypeId();
        List<Sch_Request__c> schRequestList = new List<Sch_Request__c>();
        
        if(externalCodeMappingList != null && externalCodeMappingList.size() > 0){
            for(External_Code_Mapping__c externalCodeMapping : externalCodeMappingList){
                
                if(externalCodeMapping.Source__c == 'Salesforce' || Trigger.isDelete){
                    System.debug('--externalCodeMapping.SCH_Request__c--' + externalCodeMapping.SCH_Request__c);
                    Sch_Request__c schRequest = new Sch_Request__c();
                    schRequest.RecordTypeId =  schExternalCodeMappingRecordId;
                    schRequest.RM_Account__c = externalCodeMapping.RM_Account__c != null ? externalCodeMapping.RM_Account__c : null;
                    schRequest.External_Mapping_Id__c = externalCodeMapping.External_Mapping_Id__c;
                    schRequest.External_Mapping_Type__c = externalCodeMapping.External_Mapping_Type__c;
                    schRequest.Nomura_Booking_Entity__c = externalCodeMapping.Nomura_Booking_Entity__c;
                    schRequest.Prospect_SCH_Request__c = externalCodeMapping.SCH_Request__c != null ? externalCodeMapping.SCH_Request__c : null;
                    schRequest.Action__c = Trigger.isInsert ? 'Create' : 'Delete';    
    System.debug('--schRequest.Prospect_SCH_Request__c--' + schRequest.Prospect_SCH_Request__c);
                    schRequestList.add(schRequest);
                }
            }
            System.debug('--schRequestList--' + schRequestList);

            if(schRequestList != null && schRequestList.size() > 0)
                insert schRequestList;
        }
    }

}