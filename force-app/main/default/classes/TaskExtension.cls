public class TaskExtension {

    public Task t {get;set;}
    public Task_LTA__C tLTA {get;set;}

    public TaskExtension(ApexPages.StandardController c) {
        t = (Task) c.getRecord();
        tLTA = new Task_LTA__c();
        if(t.Id == null){
            t.whoId = null;
        }
        else{
            t = [SELECT Subject, OwnerID, Status, Type, ActivityDate, WhoId, WhatId, Priority 
                 FROM Task WHERE Id = :t.Id];
            try {
            	tLTA = [SELECT Id, Parent_Task__c, LTA_1__c from Task_LTA__c where Parent_Task__c = :t.Id];
            } catch(Exception e) {
                // guard against tasks that don't have the associated task extension record
                tLTA = new Task_LTA__c();
                System.debug('Task has no TaskExtension; creating tLTA');
                tLTA.Parent_Task__c = t.Id;
        	}
        }
    }
}