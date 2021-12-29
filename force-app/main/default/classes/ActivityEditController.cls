public without sharing class ActivityEditController {
    
    @AuraEnabled
    public static List<Event> checkForEventType(String recordId){
        List<Event> eventList = [SELECT Id, Subject, WhatId, What.Name, What.RecordType.Name FROM EVENT WHERE Id = :recordId];
        
        return eventList;
    }
}