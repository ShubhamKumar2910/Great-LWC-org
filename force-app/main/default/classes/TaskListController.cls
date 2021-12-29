public without sharing class TaskListController {

    public String searchTerm {get; set;}
    @AuraEnabled
    public static String baseURL {get;set;}
    
    @AuraEnabled
    public static List<Task> searchTasks(string searchTerm) {
       string tempInput = '%' + searchTerm + '%';

        return [SELECT Id, Subject , Type, Status, ActivityDate
                FROM Task where Subject like : tempInput LIMIT 20];
    }

    
    @AuraEnabled
    public static String getBaseURL(){
        baseURL = CommonTools.getBaseURL();
        
       return baseURL;
    }
    
    @AuraEnabled
    public static List<Task> getTasks() {
 	

        return [SELECT Id, Subject , Type, Status, ActivityDate, OwnerId, Owner.Name
                FROM Task LIMIT 3];
    }

    @AuraEnabled
    public static List<Task> getTaskByEventId(String recordId) {
    

        return [SELECT Id, Subject , Type, Status, ActivityDate, Parent_Event_Id__c, OwnerId, Owner.Name
                FROM Task
                WHERE Parent_Event_Id__c = :recordId];
    }

    @AuraEnabled
    public static Event getEventDetails(String recordId) {
    
        Event e = new Event();

        e = [SELECT Id, Subject , Type, ActivityDate, WhatId, WhoId, Description
             FROM Event
             WHERE Id = :recordId
             Limit 1];

        system.debug('Event: ' + e);

        Map<String, UserRecordAccess> recordAccessMap = new Map<String, UserRecordAccess>();

        recordAccessMap = CommonTools.checkIfUserHasAccessToRecordMap(new List<Id>{e.WhoId, e.WhatId});

        System.debug(recordAccessMap);

        if(recordAccessMap.isEmpty() == false){
            if(recordAccessMap.containsKey(e.WhoId)){
                UserRecordAccess accessResult = recordAccessMap.get(e.WhoId);

                if(accessResult != null && accessResult.HasReadAccess == false){
                        e.WhoId = null;
                }
            }
            /*if(recordAccessMap.containsKey(e.WhatId)){
                UserRecordAccess accessResult = recordAccessMap.get(e.WhatId);

                if(accessResult != null && accessResult.HasReadAccess == false){
                        e.WhatId = null;
                }
            }*/
        }else{
            e.WhoId = null;
        }
        return e;
    }

    @AuraEnabled
    public static List<RecordType> getAvailableRecordTypes() {
        return [SELECT Id, DeveloperName, IsActive, SobjectType
                FROM RecordType
                Where SobjectType = 'Task'];
    }

    @AuraEnabled
    public static RecordType getStandardRecordType() {
        return [SELECT Id, DeveloperName, IsActive, SobjectType
                FROM RecordType
                Where SobjectType = 'Task'
                And DeveloperName = 'Standard_Task'
                Limit 1];
    }

    @AuraEnabled
    public static RecordType getReferralRecordType() {
        return [SELECT Id, DeveloperName, IsActive, SobjectType
                FROM RecordType
                Where SobjectType = 'Task'
                And DeveloperName = 'Referral_Task'
                Limit 1];
    }

     public static Map<Id, String> recordtypemap {get;set;}
    
   @AuraEnabled        
    public static List<String> fetchRecordTypeValues(){
        List<Schema.RecordTypeInfo> recordtypes = Task.SObjectType.getDescribe().getRecordTypeInfos();    
        recordtypemap = new Map<Id, String>();
        for(RecordTypeInfo rt : recordtypes){
            if(rt.getName() != 'Master')
            recordtypemap.put(rt.getRecordTypeId(), rt.getName());
        }        
        return recordtypemap.values();
    }
    
    @AuraEnabled
    public static Id getRecTypeId(String recordTypeLabel){
        Id recid = Schema.SObjectType.Task.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();        
        return recid;
    }     
}