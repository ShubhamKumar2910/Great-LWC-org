public class EventExtension {

    public Event t {get;set;}
    public Task_LTA__C tLTA {get;set;}

    public EventExtension(ApexPages.StandardController c) {
        t = (Event) c.getRecord();
        tLTA = new Task_LTA__c();
        if(t.Id == null){
            t.whoId = null;
        }
        else{
            t = [SELECT  OwnerID, WhatId, Subject, WhoId
                 ,IsAllDayEvent,IsPrivate,StartDateTime,EndDateTime,Location,ShowAs,Description,IsReminderSet,ReminderDateTime 
                 FROM Event WHERE Id = :t.Id];
			List<Task_LTA__C> tLTAList = [SELECT Id, Parent_Task__c, LTA_1__c from Task_LTA__c where Parent_Task__c = :t.Id];
            System.debug('<><><><><><><><><>tLTAList=' + tLTAList + ' size()=' + tLTAList.size());
            if(tLTAList.size() == 0){
                tLTA = new Task_LTA__c();
                System.debug('Event has no EventExtension; creating tLTA');
                tLTA.Parent_Task__c = t.Id;
            }else{
             tLTA= tLTAList[0];   
            }
        }
    }

}